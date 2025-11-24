import SwiftUI
import Combine

enum FontsMetricIndex: CaseIterable {
    case largeTitle, title, title2, title3, headline, subheadline,
         body, callout, footnote, caption, caption2
}

// TODO: @ScaledMetric(relativeTo: .body) var em = fm.em[.body].width ?

/// Manages and stores the measured 'em' width for different font styles.

final class FontsMetric: ObservableObject {
    @Published var em: [FontsMetricIndex: CGSize] = [:]
    subscript(key: FontsMetricIndex) -> CGSize { em[key]! }

    init() { measureAllMetrics() }

    private func measureAllMetrics() {
        for index in FontsMetricIndex.allCases {
            let a = [ NSAttributedString.Key.font: preferredFont(index) ]
            let M = NSAttributedString(string: "M", attributes: a)
            var size = M.size()
            size.width  = round(size.width)
            size.height = round(size.height)
//          trace("\(size)")
            em[index] = size
        }
    }

    #if os(iOS)
    typealias PreferredFont = UIFont
    #endif
    #if os(macOS)
    typealias PreferredFont = NSFont
    #endif

    func preferredFont(_ index: FontsMetricIndex) -> PreferredFont {
          let style: PreferredFont.TextStyle =
          switch index {
            case .largeTitle:   .largeTitle
            case .title:        .title1
            case .title2:       .title2
            case .title3:       .title3
            case .headline:     .headline
            case .subheadline:  .subheadline
            case .callout:      .callout
            case .caption:      .caption1
            case .caption2:     .caption2
            case .footnote:     .footnote
            default: /*.body */ .body
          }
          return  PreferredFont.preferredFont(forTextStyle: style)
    }
}

/// A hidden view that measures the width of the "M" character for a specific font
/// and updates the shared FontsMetric object using a specific string key.
private struct EM: View {

    @EnvironmentObject var fm: FontsMetric

    let font: Font
    let key: FontsMetricIndex

    // TODO: monospaced .font(.system(size: 12).monospacedDigit()
    // .font(.body.monospacedDigit() ?

    var body: some View {
        ScrollView {
            Text("M").font(font).fixedSize().opacity(0).hidden()
                .background(GeometryReader { g in
                    Color.clear.onAppear {
//                      let was = fm[key]
                        if fm.em[key] != g.size { fm.em[key] = g.size }
//                      trace("[\(key)] \(was) := \(fm[key])")
                    }
                })
        }
    }
}

/// A view that runs all necessary EM measurers to populate the FontsMetric object.
struct FontsMetricMeasureView: View {

    @EnvironmentObject var fm: FontsMetric

    var body: some View {
        ZStack {
            EM(font: .largeTitle,   key: .largeTitle)
            EM(font: .title,        key: .title)
            EM(font: .title2,       key: .title2)
            EM(font: .title3,       key: .title3)
            EM(font: .headline,     key: .headline)
            EM(font: .subheadline,  key: .subheadline)
            EM(font: .body,         key: .body)
            EM(font: .callout,      key: .callout)
            EM(font: .footnote,     key: .footnote)
            EM(font: .caption,      key: .caption)
            EM(font: .caption2,     key: .caption2)
        }
        .frame(width: 1, height: 1).opacity(0).hidden()
    }
}

struct FontsMetricPreview: View {
    @State var count = 0
    @State var fm = FontsMetric()
    var body: some View {
        ZStack {
            FontsMetricMeasureView()
            VStack {
                let b = fm[.body]
                Text("Body em: \(b.width) x \(b.height) pts")
                let h = fm[.headline]
                Text("Headline em: \(h.width) x \(h.height) pts")
            }
        }
        .environmentObject(fm)
    }
}

#Preview("Fonts Metric") {
    FontsMetricPreview()
}

/*
macOS:
[caption2] (9.0, 13.0)
[caption] (9.0, 13.0)
[footnote] (9.0, 13.0)
[callout] (10.5, 15.0)
[body] (11.5, 16.0)
[subheadline] (10.0, 14.0)
[headline] (12.0, 16.0)
[title3] (13.0, 19.0)
[title2] (14.5, 20.5)
[title] (18.5, 26.0)
[largeTitle] (22.0, 31.0)
*/
