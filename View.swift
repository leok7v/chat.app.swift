import SwiftUI

extension View {
    func onResize(_ action: @escaping (CGSize) -> Void) -> some View {
        self.onGeometryChange(for: CGSize.self, of: \.size) { size in
            DispatchQueue.main.async { action(size) }
        }
    }
}

