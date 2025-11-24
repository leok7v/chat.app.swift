import SwiftUI

struct InputView: View {

    @ObservedObject            var   c: ContentState
    @EnvironmentObject private var  fm: FontsMetric

    @Binding var textSize: CGSize
    @Binding var viewSize: CGSize
    @Binding var input: String
    
    var focus: FocusState<Bool>.Binding

    var body: some View {
        #if os(macOS)
        let placeholder = "Ask anything\n(use Shift+Return to break lines)"
        #else
        let placeholder = "Ask anything"
        #endif
        let emH = fm[.body].height
        let emW = fm[.body].width
        let em2 = emH / 2
        ZStack(alignment: .topLeading) {
            ScrollView { // measuring "input" text
                Text(input.isEmpty ? "|∫jÅ" : input).font(.body)
                    .frame(maxHeight: .infinity).lineLimit(nil)
                    .opacity(0).hidden()
                    .onResize { s in if s != textSize { textSize = s } }
            }.frame(maxHeight: 1).hidden()
            if input.isEmpty && c.outputModificationsCount == 0 {
                #if os(iOS)
                let insets = EdgeInsets(top: emH * 7 / 8, leading: emW,
                                     bottom: 0,  trailing: 0)
                #elseif os(macOS)
                let insets = EdgeInsets(top: em2, leading: emW,
                                     bottom: 0,  trailing: 0)
                #endif
                Text(placeholder).font(.body).foregroundColor(.gray)
                .padding(insets)
                .allowsHitTesting(false)
            }
            CustomTextEditor(
                c: c,
                input: $input,
                focus: focus,
                textViewHeight: { textSize.height },
                parentHeight  : { viewSize.height },
            )
            .padding(em2)
            .foregroundColor(.primary)
        }
        .background(.clear)
    }

}
