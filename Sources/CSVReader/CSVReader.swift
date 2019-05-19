import Foundation
import FileReader

public class CSVReader {
    private var fileReader: FileReader
    
    private let hasQuotes: Bool
    private let hasHeader: Bool
    public var headers: [String]?
    private(set) public var currentLine: [String?]?
    
    @inlinable
    public convenience init(fileAtPath path: String, hasHeader: Bool = true, hasQuotes: Bool = false, chunkSize: Int = 4096, encoding: String.Encoding = .utf8) throws {
        let url = URL(fileURLWithPath: path)
        try self.init(url: url, hasHeader: hasHeader, hasQuotes: hasQuotes, chunkSize: chunkSize, encoding: encoding)
    }
    
    @inlinable
    public convenience init(url: URL, hasHeader: Bool = true, hasQuotes: Bool = false, chunkSize: Int = 4096, encoding: String.Encoding = .utf8) throws {
        let fileHandle = try FileHandle(forReadingFrom: url)
        try self.init(fileHandle: fileHandle, hasHeader: hasHeader, hasQuotes: hasQuotes, chunkSize: chunkSize, encoding: encoding)
    }

    
    public init(fileHandle: FileHandle, hasHeader: Bool = true, hasQuotes: Bool = false, chunkSize: Int = 4096, encoding: String.Encoding = .utf8) throws {
        self.fileReader = FileReader(fileHandle: fileHandle, delimiter: "\n", chunkSize: chunkSize, encoding: encoding)
        self.hasQuotes = hasQuotes
        self.hasHeader = hasHeader
        if self.hasHeader {
            guard let headers = self.readLine() else {
                throw CSVReaderError.cannotReadHeaderRow
            }
            self.headers = headers as! [String]
        }
    }
    
    public init(string: String, hasHeader: Bool = true, hasQuotes: Bool = false) throws {
        self.fileReader = try FileReader(string: string, delimiter: "\n")
        self.hasQuotes = hasQuotes
        self.hasHeader = hasHeader
        if self.hasHeader {
            guard let headers = self.readLine() else {
                throw CSVReaderError.cannotReadHeaderRow
            }
            self.headers = headers as! [String]
        }
    }
    
    @discardableResult
    public func readLine() -> [String?]? {
        guard let line = self.fileReader.readLine() else {
            return nil
        }
        
        var strings: [String?] = []
        if hasQuotes {
            
            var cleanLine = line
            
            // remove start and end quotes
            if line.hasPrefix("\"") {
                cleanLine = String(cleanLine.dropFirst())
            }
            if line.hasSuffix("\"") {
                cleanLine = String(cleanLine.dropLast())
            }
            
            guard let lineData = cleanLine.data(using: self.fileReader.encoding) else {
                fatalError("Could not convert string to data")
            }
            
            let delim = "\",\"".data(using: self.fileReader.encoding)!
            
            var lowerIndex = lineData.startIndex
            
            while true {
                if let range = lineData.range(of: delim, in: lowerIndex..<lineData.endIndex) {
                    let subData = lineData.subdata(in: lowerIndex..<range.lowerBound)
                    guard let string = String(data: subData, encoding: self.fileReader.encoding) else {
                        fatalError("Could not convert data to string")
                    }
                    if string.isEmpty {
                        strings.append(nil)
                    } else {
                        strings.append(string)
                    }
                    lowerIndex = range.upperBound
                } else {
                    let subData = lineData.subdata(in: lowerIndex..<lineData.endIndex)
                    guard let string = String(data: subData, encoding: self.fileReader.encoding) else {
                        fatalError("Could not convert data to string")
                    }
                    if string.isEmpty {
                        strings.append(nil)
                    } else {
                        strings.append(string)
                    }
                    break
                }
            }
        } else {
            strings = line.split(separator: ",", omittingEmptySubsequences: false).map { String($0) }
        }
        self.currentLine = strings
        return strings
    }
    
    public func lineCount() -> Int {
        let fileLineCount = self.fileReader.lineCount()
        return hasHeader ? fileLineCount-1 : fileLineCount
    }
    
    public func linesLeft() -> Int {
        return self.fileReader.linesLeft()
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
