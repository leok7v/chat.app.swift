import SwiftUI

struct RoundButton: View {

    @EnvironmentObject private var fm: FontsMetric

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.isEnabled)   var isEnabled

    private let image  : String
    private let pulsing: Bool
    private let action : () -> Void
    private var size: CGFloat = 24

    init(_ image: String, _ pulsing: Bool, _ action: @escaping () -> Void) {
        self.image = image
        self.pulsing = pulsing
        self.action = action
    }

    @State private var scale: CGFloat = 1.0
    var body: some View {
        let em = fm[.body]
        Button(action: action) {
            let f: Color = colorScheme == .dark ? .black : .white
            Image(systemName: image).imageScale(.large)
            .font(.system(size: size * 0.5, weight: .semibold))
            .foregroundColor(f)
            .padding(em.height / 2)
            .fixedSize()
            .background(.secondary)
            .clipShape(Circle())
            .scaleEffect(scale)
            .onAppear() {
                if pulsing {
                    let a = Animation.easeInOut(duration: 0.9)
                    let r = a.repeatForever(autoreverses: true)
                    withAnimation(r) { scale = 0.8 }
                }
            }
        }
        .buttonStyle(.plain)
    }
}
