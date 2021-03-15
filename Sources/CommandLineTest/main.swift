import Foundation
import UPNPDeviceScanner

func printIndent(_ text: String, _ level: Int) {
    let indent = "    "

    for _ in 0 ..< level {
        print(indent, terminator: "")
    }

    print(text)
}

func getServiceUrls(for rootDevice: DeviceDescription, locatedAt deviceLocation: URL) -> [(String, URL)] {
    var baseUrlComponents = URLComponents()
    baseUrlComponents.scheme = deviceLocation.scheme
    baseUrlComponents.host = deviceLocation.host
    baseUrlComponents.port = deviceLocation.port

    func buildUrl(_ relativeLocation: String) -> URL? {
        var components = baseUrlComponents
        components.path = relativeLocation
        return components.url!
    }

    var result = rootDevice.serviceList?.compactMap { (service) -> (String, URL)? in
        guard let url = buildUrl(service.SCPDURL) else {
            return nil
        }
        return (service.serviceId, url)
    } ?? [(String, URL)]()

    let childDeviceServices = rootDevice.deviceList?.flatMap { getServiceUrls(for: $0, locatedAt: deviceLocation) } ?? [(String, URL)]()

    result.append(contentsOf: childDeviceServices)
    return result
}

func discoverRootDevices() -> ([(URL, DeviceDescription)], [(URL, ServiceDescriptionRoot)]) {
    let deviceLocator = DiscoverySession()
    let syncQueue = DispatchQueue(label: "deviceListQueue")
    let dispatchGroup = DispatchGroup()
    var deviceList = [(URL, DeviceDescription)]()
    var services = [(URL, ServiceDescriptionRoot)]()

    let discoverToken = deviceLocator.discoverRootDevices { event in
        if case let .deviceFound(device) = event {
            print("Found device: \(device.description.device.friendlyName)")
            
            syncQueue.async {
                deviceList.append((device.url, device.description.device))
            }

            // Download service descriptions for all services of device tree

            for (_, url) in getServiceUrls(for: device.description.device, locatedAt: device.url) {
                dispatchGroup.enter()
                deviceLocator.getServiceDescription(url) {
                    defer { dispatchGroup.leave() }

                    switch $0 {
                        case let .success(serviceDescription):
                            syncQueue.async {
                                services.append((url, serviceDescription))
                            }
                        case let .failure(error):
                            print(error)
                    }
                }
            }
        }
    }

    discoverToken.wait()

    return (deviceList, services)
}

let (devices, services) = discoverRootDevices()

print()
print("Found \(devices.count) root devices, \(services.count) services")

var printer = TreePrinter()

for (url, device) in devices {
    print()
    print("URL: \(url)")
    printer.dumpDevice(device, false)
}

print()

for (url, service) in services {
    print()
    print("Service \(url)")
    if service.actionList.count > 0 {
        printIndent("Actions:", 0)
        for action in service.actionList {
            printIndent(action.name, 1)

            if let arguments = action.argumentList, arguments.count > 0 {
                printIndent("Arguments:", 2)
                for arg in arguments {
                    printIndent("[\(arg.direction)] \(arg.name) (relates to \(arg.relatedStateVariable))", 3)
                }
            }
        }
    }

    if service.serviceStateTable.count > 0 {
        printIndent("State variables:", 0)
        for variable in service.serviceStateTable {
            printIndent("\(variable.name) [\(variable.dataType)]", 1)
        }
    }
}
