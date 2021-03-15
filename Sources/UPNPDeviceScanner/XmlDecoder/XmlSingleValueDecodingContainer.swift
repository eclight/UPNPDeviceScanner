
struct XmlSingleValueDecodingContainer: SingleValueDecodingContainer {
    var codingPath: [CodingKey] = []

    let decoder: Decoder
    let element: XmlElement

    init(_ decoder: Decoder, _ element: XmlElement) {
        self.decoder = decoder
        self.element = element
    }

    func decodeNil() -> Bool {
        fatalError("Not supported")
    }

    func decode(_: Bool.Type) throws -> Bool {
        fatalError("Not supported")
    }

    func decode(_: String.Type) throws -> String {
        return element.text
    }

    func decode(_: Double.Type) throws -> Double {
        fatalError("Not supported")
    }

    func decode(_: Float.Type) throws -> Float {
        fatalError("Not supported")
    }

    func decode(_: Int.Type) throws -> Int {
        fatalError("Not supported")
    }

    func decode(_: Int8.Type) throws -> Int8 {
        fatalError("Not supported")
    }

    func decode(_: Int16.Type) throws -> Int16 {
        fatalError("Not supported")
    }

    func decode(_: Int32.Type) throws -> Int32 {
        fatalError("Not supported")
    }

    func decode(_: Int64.Type) throws -> Int64 {
        fatalError("Not supported")
    }

    func decode(_: UInt.Type) throws -> UInt {
        fatalError("Not supported")
    }

    func decode(_: UInt8.Type) throws -> UInt8 {
        fatalError("Not supported")
    }

    func decode(_: UInt16.Type) throws -> UInt16 {
        fatalError("Not supported")
    }

    func decode(_: UInt32.Type) throws -> UInt32 {
        fatalError("Not supported")
    }

    func decode(_: UInt64.Type) throws -> UInt64 {
        fatalError("Not supported")
    }

    func decode<T>(_: T.Type) throws -> T where T: Decodable {
        fatalError("Not supported")
    }
}
