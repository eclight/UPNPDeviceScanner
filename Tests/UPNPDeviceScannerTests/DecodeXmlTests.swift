@testable import UPNPDeviceScanner
import XCTest

class DecodeXmlTests: XCTestCase {
    func testSimpleStruct() {
        struct S: Decodable {
            var stringField: String
            var intField: Int
        }

        let xml = """
        <root>
            <stringField>ABC</stringField>
            <intField>42</intField>
        </root>
        """

        guard let result = try? decodeXml(S.self, xml) else {
            XCTFail("Cannot decode XML")
            return
        }

        XCTAssertEqual(result.stringField, "ABC")
        XCTAssertEqual(result.intField, 42)
    }
    
    func testNullableFields() {
        struct S : Decodable {
            var stringField: String?
            var intField: Int?
        }
        
        // Non-nil values
        
        let xml1 = """
        <root>
            <stringField>ABC</stringField>
            <intField>42</intField>
        </root>
        """
        guard let result1 = try? decodeXml(S.self, xml1) else {
            XCTFail("Cannot decode XML")
            return
        }
        
        XCTAssertEqual(result1.stringField, "ABC")
        XCTAssertEqual(result1.intField, 42)
        
        // Nil values
        
        let xml2 = """
        <root>

        </root>
        """
        guard let result2 = try? decodeXml(S.self, xml2) else {
            XCTFail("Cannot decode XML")
            return
        }
        
        XCTAssertNil(result2.stringField)
        XCTAssertNil(result2.intField)
    }

    func testNestedStruct() {
        struct S1: Decodable {
            var stringField: String
            var intField: Int
        }

        struct S2: Decodable {
            var nested: S1
            var stringField1: String
        }

        let xml = """
        <root>
            <nested>
                <stringField>ABC</stringField>
                <intField>42</intField>
            </nested>
            <stringField1>def</stringField1>
        </root>
        """

        guard let result = try? decodeXml(S2.self, xml) else {
            XCTFail("Cannot decode XML")
            return
        }

        XCTAssertEqual(result.stringField1, "def")
        XCTAssertEqual(result.nested.stringField, "ABC")
        XCTAssertEqual(result.nested.intField, 42)
    }

    func testStringEnumFields() {
        enum E: String, Decodable {
            case foo
            case bar
        }

        struct S: Decodable {
            var enumField: E
            var nullableEnumField1: E?
            var nullableEnumField2: E?
            var stringField: String
        }

        let xml = """
        <root>
            <enumField>foo</enumField>
            <nullableEnumField1>bar</nullableEnumField1>
            <stringField>foo</stringField>
        </root>
        """

        guard let result = try? decodeXml(S.self, xml) else {
            XCTFail("Cannot decode XML")
            return
        }

        XCTAssertEqual(result.enumField, E.foo)
        XCTAssertEqual(result.nullableEnumField1, E.bar)
        XCTAssertNil(result.nullableEnumField2)
    }

    func testArrays() {
        struct S: Decodable {
            var stringField: String
            var intField: Int
        }

        struct S1: Decodable {
            var arr: [S]
            var emptyArr: [S]
            var stringArr: [String]
            var nullableArr1: [S]?
            var nullableArr2: [S]?
        }

        let xml = """
        <root>
            <stringArr>
                <value>Foo</value>
                <value>Bar</value>
            </stringArr>
            <arr>
                <elem>
                    <stringField>arr_0</stringField>
                    <intField>0</intField>
                </elem>
                <elem>
                    <stringField>arr_1</stringField>
                    <intField>1</intField>
                </elem>
            </arr>
            <nullableArr1>
                <elem>
                    <stringField>arr_0</stringField>
                    <intField>0</intField>
                </elem>
                <elem>
                    <stringField>arr_1</stringField>
                    <intField>1</intField>
                </elem>
            </nullableArr1>
            <emptyArr></emptyArr>
        </root>
        """

        guard let result = try? decodeXml(S1.self, xml) else {
            XCTFail("Cannot decode XML")
            return
        }

        XCTAssertEqual(result.arr.count, 2)
        XCTAssertEqual(result.arr[0].stringField, "arr_0")
        XCTAssertEqual(result.arr[0].intField, 0)
        XCTAssertEqual(result.arr[1].stringField, "arr_1")
        XCTAssertEqual(result.arr[1].intField, 1)

        XCTAssertNotNil(result.nullableArr1)
        XCTAssertEqual(result.nullableArr1![0].stringField, "arr_0")
        XCTAssertEqual(result.nullableArr1![0].intField, 0)
        XCTAssertEqual(result.nullableArr1![1].stringField, "arr_1")
        XCTAssertEqual(result.nullableArr1![1].intField, 1)

        XCTAssertEqual(result.emptyArr.count, 0)

        XCTAssertNil(result.nullableArr2)

        XCTAssertEqual(result.stringArr.count, 2)
        XCTAssertEqual(result.stringArr[0], "Foo")
        XCTAssertEqual(result.stringArr[1], "Bar")
    }

    func testAttributes() {
        struct S: Decodable {
            var field1: String
            var field2: Bool
            var field3: Bool
        }

        let xml = """
        <root field2="yes" field3="no">
             <field1>foo</field1>
        </root>
        """

        guard let result = try? decodeXml(S.self, xml) else {
            XCTFail("Cannot decode XML")
            return
        }

        XCTAssertEqual(result.field1, "foo")
        XCTAssertTrue(result.field2)
        XCTAssertFalse(result.field3)
    }
}
