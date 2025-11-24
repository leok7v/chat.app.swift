import SwiftUI

struct MessagesView: View {

    @EnvironmentObject private var fm: FontsMetric
    @ObservedObject            var  c: ContentState

    var body: some View {
        let em = fm[.body].height
        ScrollViewReader { proxy in
            List(c.session.messages, id: \.id) { (m: Message) in
                ItemView(m: m).listRowBackground(Color.clear)
                .cornerRadius(em / 2)
                .listRowSeparator(.hidden)
            }
            // SwiftUI’s List always paints its own background using
            // UITableView/NSTableView resulting that orange layer
            // sits underneath it and never shows.
            .scrollContentBackground(.hidden)
            .background(.clear)
            .padding(0)
            .listStyle(.plain)
            .onChange(of: c.session.messages.last?.id) { id, _ in
//              trace("onChange(c.session.messages.last?.id)")
                c.scrollToBottom!()
            }
            .onAppear {
                c.scrollToBottom = {
                    assert(Thread.current.isMainThread)
                    if let id = c.session.messages.last?.id {
                        proxy.scrollTo(id, anchor: .bottom)
//                      trace("scrollTo(bottom) proxy.scrollTo")
                    }
                }
            }
//          .onChange(of: c.isAtBottom) { from, to in
//              trace("onChange(c.isAtBottom) \(from) -> \(to)")
//          }
            .onChange(of: c.outputModificationsCount) { _, _ in
//              trace(".onChange(of: outputModificationsCount) \(c.outputModificationsCount)")
                if c.isAtBottom { c.scrollToBottom!() }
            }
            .onScrollGeometryChange(for: ScrollGeometry.self) { g in
                return g
            } action: { _, g in
                let threshold: CGFloat = em * 2
                let y = g.contentOffset.y + g.containerSize.height
                c.isAtBottom = y >= g.contentSize.height - threshold
//              trace("isAtBottom: \(c.isAtBottom) dy \(g.contentSize.height - y)")
            }
        }
    }
}
