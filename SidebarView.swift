import SwiftUI

struct SidebarView: View {

    @EnvironmentObject private var fm: FontsMetric

    var body: some View {
        let em = fm[.body]
//      let _ = trace("\(em.width) x \(em.height)")
        let n = 16.0 // 16 x "M"
        #if os(iOS)
//      let _ = trace("UIScreen.main.bounds \(UIScreen.main.bounds.size)")
        let maxWidth = UIScreen.main.bounds.width
        let minWidth = min(em.width * n, maxWidth)
//      let _ = trace("width: \(minWidth)..\(maxWidth)")
        #elseif os(macOS)
        let minWidth = em.width * n
        let _ = trace("minWidth \(minWidth)")
        #endif
        VStack {
            List {
                TextField("Search", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(0)
                Section(header: Text("Models")) {
                    Label("GPT", systemImage: "chevron.right")
                    Text("DeepSeek")
                    Text("Falcoln")
                    Text("Llama")
                    Text("Gemma")
                }
                Section(header: Text("Chats")) {
                    Label("New Chat", systemImage: "square.and.pencil")
                    Label("Saved chat...", systemImage: "doc")
                    Label("Another chat", systemImage: "doc")
                    Text("... See More")
                }
                Spacer()
                HStack {
                    Image(systemName: "person.circle")
                    Text("Mr. Smith")
                }
                .padding()
            }
            .listStyle(SidebarListStyle())
            .background(.clear)
            .scrollContentBackground(.hidden)
//          .onResize() { bounds in trace("\(bounds)") }
        }
        #if os(iOS)
        .frame(minWidth: minWidth, maxWidth: maxWidth)
        #elseif os(macOS)
        .frame(minWidth: minWidth)
        #endif

    }
}
