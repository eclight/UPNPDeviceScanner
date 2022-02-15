import Foundation
import SSDP
import os.log

public struct RootDevice {
    public let url: URL
    public let description: DeviceDescriptionRoot
}

public enum DiscoverEvent {
    case deviceFound(RootDevice)
    case discoverCompleted(Error?)
}

extension OSLog {
    static let discoverySessionLog = OSLog(subsystem: "com.eclight.UPNPDeviceScanner", category: "DiscoverySession")
}

public final class DiscoverySession {

    public class Token {
        private let lock = NSLock()
        private var _isCancelled = false

        private let dispatchGroup: DispatchGroup
        
        init(dispatchGroup: DispatchGroup) {
            self.dispatchGroup = dispatchGroup
        }
        
        var isCancelled : Bool {
            lock.lock()
            defer { lock.unlock() }
            return _isCancelled
        }
        
        public func cancel() {
            lock.lock()
            _isCancelled = true
            lock.unlock()
        }
        
        public func wait() {
            dispatchGroup.wait()
        }
    }
    
    private let queue = DispatchQueue(label: "com.eclight.SSDPDiscoverQueue")
    private let urlSession: URLSession = URLSession(configuration: .ephemeral)

    public init() {
        
    }
    
    public func discoverRootDevices(_ discoverEventHandler: @escaping (DiscoverEvent) -> Void) -> Token {
        let dispatchGroup = DispatchGroup()
        let token = Token(dispatchGroup: dispatchGroup)
        var knownUrls = Set<URL>()

        func downloadDeviceDescription(_ url: URL) {
            guard !token.isCancelled else {
                return
            }
            
            dispatchGroup.enter()

            get(url: url, as: DeviceDescriptionRoot.self) {
                defer { dispatchGroup.leave() }

                switch $0 {
                case let .success(result): discoverEventHandler(.deviceFound(RootDevice(url: url, description: result)))
                case let .failure(error):
                    os_log("%{public}@", log: .discoverySessionLog, type: .error, String(describing: error))
                }
            }
        }

        func handleDiscoverResponse(_ response: String) {
            do {
                let values = try parseDiscoverResponse(response)
                if let location = values["location"].flatMap({ URL(string: $0) }) {
                    if !knownUrls.contains(location) {
                        knownUrls.insert(location)

                        os_log("Downloading device description for %{public}@", log: .discoverySessionLog, type: .info, location.absoluteString)
                        downloadDeviceDescription(location)
                    }
                } else {
                    os_log("Warning: SSDP response doesn't contain location", log: .discoverySessionLog, type: .info)
                }
            } catch {
                os_log("Warning: failed to parse SSDP response", log: .discoverySessionLog, type: .info)
            }
        }

        dispatchGroup.enter()
        
        queue.async {
            var discoverError: Error? = nil
            
            do {
                try SSDP.discover({ handleDiscoverResponse($0) }, isCancelled: { token.isCancelled })
            }
            catch let error {
                discoverError = error
            }
            
            dispatchGroup.leave()
            
            dispatchGroup.notify(queue: self.queue) {
                discoverEventHandler(.discoverCompleted(discoverError))
            }
        }
        
        return token
    }

    public func getServiceDescription(_ url: URL, _ completion: @escaping (Result<ServiceDescriptionRoot, Error>) -> Void) {
        get(url: url, as: ServiceDescriptionRoot.self) { completion($0) }
    }

    private func parseDiscoverResponse(_ response: String) throws -> [String: String] {
        let lines = response.components(separatedBy: "\r\n")
        guard lines.count > 1 else {
            throw UPNPDeviceScannerError.dataFormatError("Unexpected SSDP response")
        }

        var result = [String: String]()
        for line in lines[1...] {
            guard let separatorIndex = line.firstIndex(of: ":") else {
                continue
            }

            let key = line.prefix(upTo: separatorIndex).lowercased()
            let value = line.suffix(from: line.index(after: separatorIndex)).trimmingCharacters(in: .whitespacesAndNewlines)
            result[key] = value
        }

        return result
    }

    @discardableResult
    private func get<T: Decodable>(url: URL, as _: T.Type, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionDataTask {
        let urlTask = urlSession.dataTask(with: url) { data, response, error in

            let result = Result<T, Error> {
                if let error = error {
                    throw UPNPDeviceScannerError.networkError("Could not get \(url): \(error.localizedDescription)")
                }

                guard let response = response as? HTTPURLResponse, let data = data else {
                    throw UPNPDeviceScannerError.networkError("Could not get \(url)")
                }

                if response.statusCode != 200 {
                    throw UPNPDeviceScannerError.networkError("Could not get \(url): got status code \(response.statusCode)")
                }

                return try decodeXml(T.self, data)
            }

            completion(result)
        }

        urlTask.resume()
        return urlTask
    }
}
