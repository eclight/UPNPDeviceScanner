
struct XmlKeyDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    let decoder: XmlDecoder
    let element: XmlElement

    init(_ decoder: XmlDecoder, _ element: XmlElement) {
        self.decoder = decoder
        self.element = element
    }

    // MARK: - KeyedDecodingContainerProtocol

    var codingPath: [CodingKey] = []

    var allKeys: [Key] = []

    func contains(_ key: Key) -> Bool {
        return decoder.contains(key)
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        return !decoder.contains(key)
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        let value = try stringValue(forKey: key)
        return try decoder.decode(stringValue: value, as: type)
    }

    func decode(_: String.Type, forKey key: Key) throws -> String {
        return try stringValue(forKey: key)
    }

    func decode(_: Double.Type, forKey _: Key) throws -> Double {
        fatalError("Not supported")
    }

    func decode(_: Float.Type, forKey _: Key) throws -> Float {
        fatalError("Not supported")
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        let value = try stringValue(forKey: key)
        return try decoder.decode(stringValue: value, as: type)
    }

    func decode(_: Int8.Type, forKey _: Key) throws -> Int8 {
        fatalError("Not supported")
    }

    func decode(_: Int16.Type, forKey _: Key) throws -> Int16 {
        fatalError("Not supported")
    }

    func decode(_: Int32.Type, forKey _: Key) throws -> Int32 {
        fatalError("Not supported")
    }

    func decode(_: Int64.Type, forKey _: Key) throws -> Int64 {
        fatalError("Not supported")
    }

    func decode(_: UInt.Type, forKey _: Key) throws -> UInt {
        fatalError("Not supported")
    }

    func decode(_: UInt8.Type, forKey _: Key) throws -> UInt8 {
        fatalError("Not supported")
    }

    func decode(_: UInt16.Type, forKey _: Key) throws -> UInt16 {
        fatalError("Not supported")
    }

    func decode(_: UInt32.Type, forKey _: Key) throws -> UInt32 {
        fatalError("Not supported")
    }

    func decode(_: UInt64.Type, forKey _: Key) throws -> UInt64 {
        fatalError("Not supported")
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        guard let element = element.firstChild(key.stringValue) else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: ""))
        }

        return try decoder.decodeValue(element, type)
    }

    func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey _: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        fatalError("Not supported")
    }

    func nestedUnkeyedContainer(forKey _: Key) throws -> UnkeyedDecodingContainer {
        fatalError("Not supported")
    }

    func superDecoder() throws -> Decoder {
        fatalError("Not supported")
    }

    func superDecoder(forKey _: Key) throws -> Decoder {
        fatalError("Not supported")
    }

    // MARK: - Private methods

    private func stringValue(forKey key: Key) throws -> String {
        if let element = element.firstChild(key.stringValue) {
            return element.text
        }

        if let attribute = element.attributes[key.stringValue] {
            return attribute
        }

        throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: ""))
    }
}
