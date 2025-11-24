import SwiftUI
import Combine

// typealias llm_model_ref = OpaquePointer
// typealias llm_ctx_ref   = OpaquePointer

final class ContentState: ObservableObject {
//  @Published var windowTitle      = "AI Chat"
    @Published var input            = ""
//  @Published var autoscroll       = 0.0
//  @Published var stopRequested    = false
    @Published var session          = Session()
//  @Published var em               = CGSize(width: 16, height: 16)
//  @Published var inputSize        = CGSize(width: 100, height: 60)
//  @Published var progress: Double = Double.nan
//  @Published var model:           llm_model_ref?
//  @Published var ctx:             llm_ctx_ref?
//  @Published var errorText:       String?
//  @Published var showAlert        = false
    @Published var output:          Message? = nil
    @Published var isRunning        = false
    @Published var outputModificationsCount: Int = 0
    @Published var isAtBottom       = true
    var send: ((_ text: String) -> Void)? = nil
    var stop: (() -> Void)? = nil
    var chat: (() -> Void)? = nil // start new session
    var scrollToBottom: (() -> Void)? = nil
}
