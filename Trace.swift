import SwiftUI
import os.log

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let general = Logger(subsystem: subsystem, category: "general")
}

func trace(_ message: @autoclosure () -> String,
           _ file: StaticString = #file, line: Int = #line,
           _ function: StaticString = #function) {
    let name = (String(describing: file) as NSString).lastPathComponent
    let fun  = String(describing: function).components(separatedBy: "(").first!
    let text = "\(name):\(line) @\(fun) \(message())"
    print(text)
    Logger.general.info("\(text, privacy: .public)")
}
