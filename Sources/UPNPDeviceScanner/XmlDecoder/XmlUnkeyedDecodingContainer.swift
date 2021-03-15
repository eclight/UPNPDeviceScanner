
struct XmlUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    var codingPath: [CodingKey] = []

    var count: Int? {
        return element.children.count
    }

    var isAtEnd: Bool {
        return currentIndex >= element.children.count
    }

    var currentIndex: Int = 0

    let decoder: XmlDecoder
    let element: XmlElement

    init(_ decoder: XmlDecoder, _ element: XmlElement) {
        self.decoder = decoder
        self.element = element
    }

    mutating func decodeNil() throws -> Bool {
        fatalError("Not supported")
    }

    mutating func decode(_: Bool.Type) throws -> Bool {
        fatalError("Not supported")
    }

    mutating func decode(_: String.Type) throws -> String {
        fatalError("Not supported")
    }

    mutating func decode(_: Double.Type) throws -> Double {
        fatalError("Not supported")
    }

    mutating func decode(_: Float.Type) throws -> Float {
        fatalError("Not supported")
    }

    mutating func decode(_: Int.Type) throws -> Int {
        fatalError("Not supported")
    }

    mutating func decode(_: Int8.Type) throws -> Int8 {
        fatalError("Not supported")
    }

    mutating func decode(_: Int16.Type) throws -> Int16 {
        fatalError("Not supported")
    }

    mutating func decode(_: Int32.Type) throws -> Int32 {
        fatalError("Not supported")
    }

    mutating func decode(_: Int64.Type) throws -> Int64 {
        fatalError("Not supported")
    }

    mutating func decode(_: UInt.Type) throws -> UInt {
        fatalError("Not supported")
    }

    mutating func decode(_: UInt8.Type) throws -> UInt8 {
        fatalError("Not supported")
    }

    mutating func decode(_: UInt16.Type) throws -> UInt16 {
        fatalError("Not supported")
    }

    mutating func decode(_: UInt32.Type) throws -> UInt32 {
        fatalError("Not supported")
    }

    mutating func decode(_: UInt64.Type) throws -> UInt64 {
        fatalError("Not supported")
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        let child = element.children[currentIndex]
        let result = try decoder.decodeValue(child, type)
        currentIndex += 1
        return result
    }

    mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        fatalError("Not supported")
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError("Not supported")
    }

    mutating func superDecoder() throws -> Decoder {
        fatalError("Not supported")
    }
}
