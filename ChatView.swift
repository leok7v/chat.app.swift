import SwiftUI

struct ChatView: View {

    @Environment(\.toggleSidebar)    private var toggleSidebar
    @Environment(\.isSidebarVisible) private var isSidebarVisible
    @EnvironmentObject private var fm: FontsMetric
    @ObservedObject            var  c: ContentState

    @FocusState private var focus: Bool

    @State private var input    = ""
    @State private var viewSize = CGSize.zero
    @State private var textSize = CGSize.zero

    var body: some View {
        let em = fm[.body]
        VStack {
            MessagesView(c: c)
            Spacer()
            Spacer()
            VStack(spacing: 0) {
                InputView(
                    c: c,
                    textSize: $textSize,
                    viewSize: $viewSize,
                    input: $input,
                    focus: $focus
                )
                InputTools( c: c, input: $input)
            }
            .background(.background.tertiary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(EdgeInsets(top: 0, leading: em.width / 2,
                             bottom: em.height / 2, trailing: em.width / 2))
        }
        .background(.background.secondary)
        .foregroundColor(.primary)
        .onAppear {
            focus = true
//          trace("viewSize: \(viewSize)")
        }
        .onResize { size in
            if size != viewSize { viewSize = size }
//          trace("viewSize: \(viewSize) size: \(size)")
        }
        #if os(macOS)
        .navigationTitle("\(modelName())>")
        #endif
        .toolbar {
            Toolbar(
                c: c,
                toggleSidebar: {
                    toggleSidebar()
                    #if os(iOS)
                    focus = !isSidebarVisible
                    #endif
                },
                leadingPlacement: platformLeadingPlacement,
                trailingPlacement: platformTrailingPlacement,
                showsSidebar: platformShowsSidebar,
                showsTitle: platformShowsTitle,
                title: "\(modelName())>"
            )
        }
    }
    
    #if os(iOS)
    private var platformLeadingPlacement:  ToolbarItemPlacement { .topBarLeading }
    private var platformTrailingPlacement: ToolbarItemPlacement { .topBarTrailing }
    private var platformShowsSidebar: Bool { true }
    private var platformShowsTitle:   Bool { true }
    #elseif os(macOS)
    private var platformLeadingPlacement:  ToolbarItemPlacement { .automatic }
    private var platformTrailingPlacement: ToolbarItemPlacement { .primaryAction }
    private var platformShowsSidebar: Bool { false }
    private var platformShowsTitle:   Bool { false }
    #endif
}
