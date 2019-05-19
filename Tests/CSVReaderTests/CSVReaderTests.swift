import XCTest
@testable import CSVReader

final class CSVReaderTests: XCTestCase {
    func testCSVStringRead() throws {
        let csvString = "int1,int2,int3\n1,2,3\n4,5,6"
        let csvReader = try CSVReader(string: csvString)
        XCTAssertEqual(csvReader.headers, ["int1", "int2", "int3"])
        
        let firstLine = csvReader.readLine()
        XCTAssertEqual(firstLine, ["1", "2", "3"])
        
        let secondLine = csvReader.readLine()
        XCTAssertEqual(secondLine, ["4", "5", "6"])
        
        let thirdLine = csvReader.readLine()
        XCTAssertNil(thirdLine)
    }
    
    func testCSVQuotedStringRead() throws {
        let csvString = "\"1\",\"2\",\"3\",\"4\",\"5\"\n\"hoi\",\"lol\",\"\",\"\",\"haha\""
        let csvReader = try CSVReader(string: csvString, hasQuotes: true)
        XCTAssertEqual(csvReader.headers, ["1", "2", "3", "4", "5"])
        XCTAssertEqual(csvReader.readLine(), ["hoi", "lol", nil, nil, "haha"])
    }
    
    func testLineCount() throws {
        let csvString = "int1,int2,int3\n1,2,3\n4,5,6"
        let csvReader = try CSVReader(string: csvString)
        let lineCount = csvReader.lineCount()
        print(lineCount)
    }

    static var allTests = [
        ("testCSVStringRead", testCSVStringRead),
        ("testCSVQuotedStringRead", testCSVQuotedStringRead),
        ("testLineCount", testLineCount)
    ]
}
