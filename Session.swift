import SwiftUI
import Combine

final class Message: ObservableObject, Identifiable {
    enum Kind {
        case user
        case warning
        case response
        case generating
        case progress
    }
    let id = UUID()
    @Published var text: String
    @Published var channel: String
    @Published var kind: Kind
    init(_ text: String, _ kind: Kind) {
        self.text = text
        self.kind = kind
        self.channel = "final"
    }
}

final class Session: ObservableObject, Identifiable {
    let id = UUID()
    @Published var messages: [Message] = []
    var map: [UUID: Message] = [:]

    func get(_ id: UUID) -> Message? {
        var m = map[id]
        if m == nil {
            m = messages.last(where: { $0.id == id })
            if m != nil { map[id] = m }
        }
        return m
    }
    
    static func user(_ s: String) -> Message { Message(s, .user) }
    static func warning(_ s: String) -> Message { Message(s, .warning) }
    static func response(_ s: String) -> Message { Message(s, .response) }
    static func generating(_ s: String) -> Message { Message(s, .generating) }
    static func progress(_ s: String) -> Message { Message(s, .progress) }

}
