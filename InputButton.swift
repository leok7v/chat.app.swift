import SwiftUI

struct InputButton: View {

    @EnvironmentObject private var fm: FontsMetric

    @State private var isOn = false
    private let systemName: String
    private let title: String?
    private let action: (_ isPressed: Bool) -> Void

    init(_ systemName: String, _ toggle: String = "",
             _ action: @escaping (_ isPressed: Bool) -> Void) {
        self.systemName = systemName
        self.title = toggle.isEmpty ? nil : toggle
        self.action = action
    }

    var body: some View {
        Button {
            if title != nil { isOn.toggle() }
            action(isOn)
        } label: {
            HStack(spacing: fm[.body].width / 4) {
                Image(systemName: systemName).imageScale(.large)
                if let title  {
                    Text(isOn ? title : "\u{200B}") // ZWS
                }
            }
            .padding(.horizontal, fm[.body].width  / 4)
            .padding(.vertical,   fm[.body].height / 4)
            .background(isOn && title != nil ?
                Color.accentColor.opacity(0.2) : Color.clear)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .foregroundColor(isOn && title != nil ? .accentColor : .primary)
    }
}

