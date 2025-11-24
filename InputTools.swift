import SwiftUI

struct InputTools: View {

    @ObservedObject    var  c: ContentState
    @EnvironmentObject var fm: FontsMetric

    @Binding var input: String

    func send() {
        c.send!(input)
        input = ""
    }

    func stop() { c.stop!() }
    func down() { c.scrollToBottom!() }

    var body: some View {
        let em = fm[.body]
        HStack(spacing: em.height / 2) {
            InputButton("plus")            { _ in trace("pluse")  }
            .disabled(true)
            InputButton("globe", "Search") { s in trace("Search: \(s)") }
            .disabled(true)
            InputButton("slider.horizontal.3") { _ in
                trace("settings")
            }
            Spacer()
            if c.isRunning {
                RoundButton("stop.fill",    true,  stop)
                RoundButton("chevron.down", false, down)
            } else {
                RoundButton("arrow.up",     false, send)
                .disabled(c.isRunning || input.isTrimmedEmpty())
            }
        }
        .padding(.horizontal, em.width  / 2)
        .padding(.vertical,   em.height / 4)
    }
}
