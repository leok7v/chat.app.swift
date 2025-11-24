import SwiftUI

public var onTermination: (() -> Void)? = nil

struct ContentView: View {

    @StateObject private var c = ContentState()
    @EnvironmentObject private var fm: FontsMetric

    private var llm = LLM()

    @State var consumer: Task<Void, Never>?

    func stop() {
        llm.stop()
        consumer?.cancel()
        c.isRunning = false
    }

    func termination() {
        assert(Thread.current.isMainThread)
        if c.isRunning { llm.stop() }
        consumer?.cancel()
    }

    func output(_ text: String) {
        assert(Thread.current.isMainThread)
        let wasAtBottom = c.isAtBottom
        c.output?.text = text
        c.outputModificationsCount += 1
        if wasAtBottom { c.scrollToBottom!() }
    }

    func done() {
        assert(Thread.current.isMainThread)
        c.output?.kind = .response
        c.output = nil
        if c.isAtBottom { c.scrollToBottom!() }
    }

    func append(_ text: String) { c.output?.text.append(text) }

    func send(_ text: String) {
        assert(Thread.current.isMainThread)
        assert(!c.isRunning)
        if (c.isRunning) {
            trace("should not be called when isRunning == true")
            return
        }
        onTermination = termination
        c.session.messages.append(Session.user(text))
        c.output = Session.generating("")
        c.output!.text.reserveCapacity(32 * 1024)
        c.session.messages.append(c.output!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            c.scrollToBottom!()
        }
        let stream = llm.start(text)
        c.isRunning = true
        consumer = Task { // This block runs on the main thread
            assert(Thread.isMainThread)
            defer {
                // will execute even if Task crashes
                // the reason for async post to avoid deadlock
                // on published property asignment if RunLoop is
                // blocked on wait.
                DispatchQueue.main.async { c.isRunning = false }
                if c.isAtBottom {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        c.scrollToBottom!()
                    }
                }
            }
            for await token in stream {
                assert(Thread.isMainThread)
                if !token.text.isEmpty { append(token.text) }
                if token.done { break }
                if Task.isCancelled { trace("Task.cancelled") }
                if Task.isCancelled { break }
            }
            trace("consumer finished")
            assert(Thread.isMainThread)
        }
    }

    func chat() { trace("newChat") }

    var body: some View {
        FontsMetricMeasureView()
        .onAppear() {
            c.send = send
            c.stop = stop
            c.chat = chat
        }
        NavigationContainer {
            SidebarView()
        } detail: {
            ChatView(c: c)
        }
    }
}
