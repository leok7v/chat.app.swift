import SwiftUI

struct CustomTextEditor: View {

    @ObservedObject            var   c: ContentState
    @EnvironmentObject private var  fm: FontsMetric

    @Binding var input: String

    var focus: FocusState<Bool>.Binding

    var textViewHeight: () -> CGFloat
    var parentHeight: () -> CGFloat

    var body: some View {
        let minHeight = fm[.body].height
        let contentHeight = max(minHeight, textViewHeight() + 8)
        let maxHeight = parentHeight() / 3
        let desiredHeight = min(contentHeight, maxHeight)
        TextEditor(text: $input)
            .focused(focus)
            .frame(height: desiredHeight)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .font(.body)
            .padding(0)
            .disabled(c.isRunning)
            .onKeyPress(.return, phases: [.down]) { kp in onReturnKey(kp) }
    }

    func onReturnKey(_ kp: KeyPress) -> KeyPress.Result {
        // onKeyPress is not fired for soft keyboard on iOS
        if kp.modifiers.contains(.shift) {
            return .ignored
        } else if !c.isRunning && !input.isTrimmedEmpty() {
            c.send!(input)
            input = ""
            return .handled
        } else {
            return .ignored
        }
    }

}
