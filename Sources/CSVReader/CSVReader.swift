import Foundation
import FileReader

public class CSVReader {
    private var fileReader: FileReader
    
    private let hasHeader: Bool
    public var headers: [String]?
    private(set) public var currentLine: [String]?
    
    @inlinable
    public convenience init(fileAtPath path: String, hasHeader: Bool = true, chunkSize: Int = 4096, encoding: String.Encoding = .utf8) throws {
        let url = URL(fileURLWithPath: path)
        try self.init(url: url, hasHeader: hasHeader, chunkSize: chunkSize, encoding: encoding)
    }
    
    @inlinable
    public convenience init(url: URL, hasHeader: Bool = true, chunkSize: Int = 4096, encoding: String.Encoding = .utf8) throws {
        let fileHandle = try FileHandle(forReadingFrom: url)
        try self.init(fileHandle: fileHandle, hasHeader: hasHeader, chunkSize: chunkSize, encoding: encoding)
    }

    
    public init(fileHandle: FileHandle, hasHeader: Bool = true, chunkSize: Int = 4096, encoding: String.Encoding = .utf8) throws {
        self.fileReader = FileReader(fileHandle: fileHandle, delimiter: "\n", chunkSize: chunkSize, encoding: encoding)
        self.hasHeader = hasHeader
        if self.hasHeader {
            guard let headers = self.readLine() else {
                throw CSVReaderError.cannotReadHeaderRow
            }
            self.headers = headers
        }
    }
    
    public init(string: String, hasHeader: Bool = true) throws {
        self.fileReader = try FileReader(string: string, delimiter: "\n")
        self.hasHeader = hasHeader
        if self.hasHeader {
            guard let headers = self.readLine() else {
                throw CSVReaderError.cannotReadHeaderRow
            }
            self.headers = headers
        }
    }
    
    @discardableResult
    public func readLine() -> [String]? {
        let line = self.fileReader.readLine()
        let strings = line?.split(separator: ",", omittingEmptySubsequences: false).map { String($0) }
        self.currentLine = strings
        return strings
    }
    
    public subscript(key: String) -> String?  {
        guard let headers = self.headers else {
            print("Subscripting CSVReader requires headers in file, none were found")
            return nil
        }
        
        guard let headerIndex = headers.firstIndex(of: key) else {
            return nil
        }
        
        guard let currentLine = self.currentLine else {
            print("Current line is nil. Either no lines have been read yet or file is empty")
            return nil
        }
        
        if headerIndex >= currentLine.count {
            return nil
        }
        
        return currentLine[headerIndex]
    }
}

enum CSVReaderError: Error {
    case cannotReadHeaderRow
    case fileMustHaveHeaderRow
}
