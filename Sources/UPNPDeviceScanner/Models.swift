
public struct SpecVersion: Decodable {
    public let major: Int
    public let minor: Int
}

// MARK: - Device description

public struct DeviceDescriptionRoot: Decodable {
    public let specVersion: SpecVersion
    public let device: DeviceDescription
}

public struct DeviceService: Decodable {
    public let serviceType: String
    public let serviceId: String
    public let SCPDURL: String
}

public struct DeviceDescription: Decodable {
    public let deviceType: String
    public let friendlyName: String
    public let UDN: String
    public let deviceList: [DeviceDescription]?
    public let serviceList: [DeviceService]?
}

// MARK: - Service description

public struct ServiceDescriptionRoot: Decodable {
    public let specVersion: SpecVersion
    public let actionList: [ServiceAction]
    public let serviceStateTable: [ServiceStateVariable]
}

public enum ArgumentDirection: String, Decodable {
    case `in`
    case out
}

public enum VariableDataType: String, Decodable {
    case string
    case boolean
    case ui2
    case ui4
    case i2
    case i4
}

public struct ServiceAction: Decodable {
    public let name: String
    public let argumentList: [ActionArgument]?
}

public struct ActionArgument: Decodable {
    public let name: String
    public let direction: ArgumentDirection
    public let relatedStateVariable: String
}

public struct VariableValueRange: Decodable {
    public let minimum: String?
    public let maximum: String?
    public let step: String?
}

public struct ServiceStateVariable: Decodable {
    public let sendEvents: Bool?
    public let name: String
    public let dataType: VariableDataType
    public let defaultValue: String?
    public let allowedValueList: [String]?
    public let allowedValueRange: VariableValueRange?
}
