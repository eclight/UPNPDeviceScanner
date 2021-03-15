import UPNPDeviceScanner

struct TreePrinter {
    var levels = [Bool]()

    mutating func beginNode(_ name: String, _ hasMoreNodesOnThisLevel: Bool = true) {
        let isRoot = levels.count == 0

        if !isRoot {
            var line = ""

            for levelHasMoreNodes in levels.suffix(from: 1) {
                line += levelHasMoreNodes ? "|  " : "   "
            }

            line += "|"
            print(line)
        }

        var prefix = ""
        levels.append(hasMoreNodesOnThisLevel)
        if !isRoot {
            for i in 1 ..< levels.count - 1 {
                prefix += levels[i] ? "|  " : "   "
            }
            prefix += "+--"
        }

        print(prefix, isRoot ? "* " : "> ", name, separator: "", terminator: "\n")
    }

    mutating func endNode() {
        _ = levels.popLast()
    }
}

extension TreePrinter {
    mutating func dumpDevice(_ device: DeviceDescription, _ isLast: Bool) {
        beginNode("\(device.friendlyName) [\(device.deviceType), UDN: \(device.UDN) ]", !isLast)

        if let serviceList = device.serviceList {
            beginNode("Services", device.deviceList != nil)

            for index in 0 ..< serviceList.count {
                beginNode("\(serviceList[index].serviceId) [\(serviceList[index].SCPDURL)]", index == serviceList.count - 1)
                endNode()
            }

            endNode()
        }

        if let deviceList = device.deviceList {
            beginNode("Devices", false)

            for i in 0 ..< deviceList.count {
                dumpDevice(deviceList[i], i == deviceList.count - 1)
            }
            endNode()
        }

        endNode()
    }
}
