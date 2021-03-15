
final class XmlDecoder: Decoder {
    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey: Any] = [:]

    private var elementStack = [XmlElement]()

    init(_ element: XmlElement) {
        elementStack.append(element)
    }

    func container<Key>(keyedBy _: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        return KeyedDecodingContainer(XmlKeyDecodingContainer<Key>(self, elementStack.last!))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return XmlUnkeyedDecodingContainer(self, elementStack.last!)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return XmlSingleValueDecodingContainer(self, elementStack.last!)
    }

    func contains(_ key: CodingKey) -> Bool {
        guard let element = elementStack.last else {
            return false
        }
        return element.firstChild(key.stringValue) != nil || element.attributes[key.stringValue] != nil
    }
    
    func decodeValue<T>(_ element: XmlElement, _: T.Type) throws -> T where T: Decodable {
        elementStack.append(element)
        defer { _ = elementStack.popLast() }
        return try T(from: self)
    }

    func decode(stringValue: String, as type: Int.Type) throws -> Int {
        guard let intValue = Int(stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: ""))
        }

        return intValue
    }

    func decode(stringValue: String, as type: Bool.Type) throws -> Bool {
        return stringValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
    }
}
