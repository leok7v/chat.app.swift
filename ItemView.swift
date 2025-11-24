import SwiftUI

struct ItemView: View {

    @EnvironmentObject private var fm: FontsMetric
    @ObservedObject            var  m: Message

    var body: some View {
        let em2 = fm[.body].height / 2
        if m.kind == .user {
            Text(m.text)
                .textSelection(.enabled)
                .padding(em2)
                .background(Color.accentColor.opacity(0.15))
        } else if m.kind == .response || m.kind == .generating {
            Text(m.text)
                .textSelection(.enabled)
                .padding(em2)
                .background(.background.secondary)
        } else {
            Text(m.text)
                .background(Color.red.opacity(0.5))
        }
    }
    
}

