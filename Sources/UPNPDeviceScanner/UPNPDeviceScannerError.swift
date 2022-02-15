
public enum UPNPDeviceScannerError: Error, CustomStringConvertible {
    case dataFormatError(String)
    case networkError(String)
    
    public var description: String {
        switch self {
        case .dataFormatError(let description):
            return "Data format error: \(description)"
        case .networkError(let description):
            return "Network error: \(description)"
        }
    }
}
