import SwiftUI

struct NavigationContainer<Sidebar: View, Detail: View>: View {
    
    let sidebar: Sidebar
    let detail: Detail
    
    #if os(iOS)
    @State private var showSidebarOverlay = false
    #elseif os(macOS)
    @State private var columns: NavigationSplitViewVisibility = .detailOnly
    #endif
    
    init(@ViewBuilder sidebar: () -> Sidebar, 
         @ViewBuilder detail: () -> Detail) {
        self.sidebar = sidebar()
        self.detail = detail()
    }
    
    var toggleSidebar: () -> Void {
        #if os(iOS)
        return { showSidebarOverlay.toggle() }
        #elseif os(macOS)
        return { columns = columns == .all ? .detailOnly : .all }
        #endif
    }
    
    var isSidebarVisible: Bool {
        #if os(iOS)
        return showSidebarOverlay
        #elseif os(macOS)
        return columns == .all
        #endif
    }
    
    var body: some View {
        #if os(iOS)
        NavigationStack {
            ZStack {
                detail
                    .environment(\.toggleSidebar, toggleSidebar)
                    .environment(\.isSidebarVisible, isSidebarVisible)
                if showSidebarOverlay {
                    Color.primary.opacity(0.0)
                        .background(.background.secondary)
                        .ignoresSafeArea()
                        .onTapGesture { showSidebarOverlay = false }
                    GeometryReader { geometry in
                        let screen = UIScreen.main.bounds.size
                        let width = min(geometry.size.width, screen.width)
//                      let _ = trace("maxWidth: \(width)")
                        sidebar
                            .frame(maxWidth: width, alignment: .leading)
                            .background(.background.secondary)
                            .transition(.move(edge: .leading))
                            .zIndex(1)
                    }
                }
            }
        }
        #elseif os(macOS)
        NavigationSplitView(columnVisibility: $columns) {
            sidebar
        } detail: {
            detail
                .environment(\.toggleSidebar, toggleSidebar)
                .environment(\.isSidebarVisible, isSidebarVisible)
        }
        #endif
    }
}

// Environment keys for sidebar control
private struct ToggleSidebarKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

private struct IsSidebarVisibleKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var toggleSidebar: () -> Void {
        get { self[ToggleSidebarKey.self] }
        set { self[ToggleSidebarKey.self] = newValue }
    }
    
    var isSidebarVisible: Bool {
        get { self[IsSidebarVisibleKey.self] }
        set { self[IsSidebarVisibleKey.self] = newValue }
    }
}
