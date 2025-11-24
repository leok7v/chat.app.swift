import SwiftUI

struct Toolbar: ToolbarContent {

    @ObservedObject var  c: ContentState

    let toggleSidebar    : () -> Void
    let leadingPlacement : ToolbarItemPlacement
    let trailingPlacement: ToolbarItemPlacement
    let showsSidebar     : Bool
    let showsTitle       : Bool
    let title            : String

    var body: some ToolbarContent {
        if showsSidebar {
            ToolbarItem(placement: leadingPlacement) {
                Button {
                    toggleSidebar()
                } label: {
                    Image(systemName: "sidebar.leading")
                }
            }
        }
        if showsTitle {
            ToolbarItem(placement: leadingPlacement) {
                Text(title)
            }
        }
        ToolbarItem(placement: trailingPlacement) {
            let image = Image(systemName: "square.and.pencil")
            Button { c.chat!() } label: { image }
        }
    }
}
