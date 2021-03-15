import Foundation

final class XmlElement {
    let name: String
    let attributes: [String: String]
    var text = ""
    var children = [XmlElement]()

    init(_ name: String, _ attributes: [String: String]) {
        self.name = name
        self.attributes = attributes
    }

    func firstChild(_ name: String) -> XmlElement? {
        return children.first(where: { $0.name.lowercased() == name.lowercased() })
    }
}

fileprivate final class ParserDelegate: NSObject, XMLParserDelegate {
    var rootNode: XmlElement?
    var nodeStack = [XmlElement]()

    func parser(_: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName _: String?, attributes: [String: String] = [:]) {
        nodeStack.append(XmlElement(elementName, attributes))
    }

    func parser(_: XMLParser, foundCharacters string: String) {
        nodeStack.last?.text += string
    }

    func parser(_ parser: XMLParser, didEndElement _: String, namespaceURI _: String?, qualifiedName _: String?) {
        guard let node = nodeStack.popLast() else {
            parser.abortParsing()
            return
        }

        if let topNode = nodeStack.last {
            topNode.children.append(node)
        } else {
            rootNode = node
        }
    }
}

func decodeXml<T>(_: T.Type, _ xml: Data) throws -> T where T: Decodable {
    let parser = XMLParser(data: xml)
    let delegate = ParserDelegate()

    parser.delegate = delegate

    if !parser.parse() {
        let error = parser.parserError.flatMap { String(describing: $0) } ?? "Unknown error"
        throw UPNPDeviceScannerError.dataFormatError("XML parsing failed: \(error)")
    }

    guard let rootNode = delegate.rootNode else {
        throw UPNPDeviceScannerError.dataFormatError("XML doesn't have root node")
    }

    let decoder = XmlDecoder(rootNode)
    return try T(from: decoder)
}

func decodeXml<T>(_ type: T.Type, _ xml: String) throws -> T where T: Decodable {
    guard let data = xml.data(using: .utf8) else {
        throw UPNPDeviceScannerError.dataFormatError("Could not convert string to UTF8 bytes")
    }
    return try decodeXml(type, data)
}
