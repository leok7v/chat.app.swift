import SwiftUI
import os // OSAllocatedUnfairLock

final class LLM {

    struct Token {
        var done: Bool
        var text: String
    }

    private let lock = OSAllocatedUnfairLock<
        (running: Bool, canceled: Bool, stopping: Bool)>(
        initialState: (running: false, canceled: false, stopping: false)
    )

    func start(_ prompt: String) -> AsyncStream<Token> {
        assert(Thread.current.isMainThread)
        if !Thread.current.isMainThread { fatalError("!isMainThread") }
        lock.withLock { state in
            assert(!state.running)
            if state.running { return } // should not happen
            state.running = true
            state.canceled = false
        }
        trace("start: \(prompt)")
        var g = Generator(words: Int.random(in: 50...200))
//      var g = Generator(words: Int.random(in: 5...20))
        let stream = AsyncStream<Token> { stream in
            let work = DispatchWorkItem() {
                defer { // will execute even if Task crashes
                    self.lock.withLock { state in state.running = false }
                    trace("running := false")
                    trace("producer finished")
                }
                while self.lock.withLock({state in state.canceled }) == false {
                    let token = self.next(&g)
                    stream.yield(token)
                    if token.done { break }
                }
                stream.finish()
            }
            DispatchQueue.global(qos: .background).async(execute: work)
        }
        return stream
    }

    func stop() {
        assert(Thread.current.isMainThread)
        if !Thread.current.isMainThread { fatalError("!isMainThread") }
        lock.withLock { state in
            if !state.running || state.stopping { return }
            state.stopping = true
            state.canceled = true
        }
        defer {
            lock.withLock { state in state.stopping = false }
        }
        while lock.withLock({ state in state.running }) == true {
            trace("waiting...")
            Thread.sleep(forTimeInterval: 0.01) // 10ms
            #if os(macOS)
            RunLoop.current.run(mode: .default,
                                before: Date(timeIntervalSinceNow: 0.01))
            #endif
        }
    }

    struct Generator { var words: Int }

    private func next(_ g: inout Generator) -> Token {
        assert(!Thread.current.isMainThread)
        Thread.sleep(forTimeInterval: 1.0 / 16.0)
        if g.words == 0 {
            return Token(done: true , text: "")
        } else {
            let randomUInt32 = UInt32.random(in: UInt32.min...UInt32.max)
            let w = Proquint.encode(randomUInt32, Character("\u{20}"))
            g.words -= 1
            return Token(done: false, text: w)
        }
    }

}

/*

## **LLM analysis of the critical scenario:**

**Timeline when user presses Stop exactly as generator finishes:**

Background Thread (Producer):          Main Thread:
─────────────────────────────         ──────────────────
g.words = 1
token = next(&g)  // g.words→0
  returns Token(done=true)
stream.yield(Token(done=true))
                                      [User clicks Stop]
                                      stop() called
                                      lock.withLock {
                                        reads state.running = true
                                        state.stopping = true
                                        state.canceled = true
                                      }
if token.done { break } // BREAKS!    
stream.finish()                       while state.running {
defer {                                 Thread.sleep(0.5)
  lock.withLock {                       RunLoop.run()
    state.running = false  ←────────  } // Waiting here
  }                                   
}                                     // Sees running=false
                                      // Returns
```

**Why there's NO race condition:**

1. **OSAllocatedUnfairLock provides proper synchronization:**
   - All access to `state.running`, `state.canceled`, `state.stopping`
     is protected
   - Lock has acquire/release semantics - ensures memory visibility
     across cores
   - Producer writing `running = false` and stop() reading it are
     properly ordered

2. **The "window" between break and defer is SAFE:**
   ```swift
   if token.done { break }  // ← Producer breaks
   // Still inside work closure, before defer
   defer {                  // ← Will execute no matter what
       lock.withLock { state.running = false }
   }
   ```
   Even if stop() is called after break but before defer:
   - stop() sees `state.running = true`, sets `canceled = true`, and waits
   - Producer's defer eventually executes, sets `running = false`
   - stop() sees the change and returns
   - **Perfectly synchronized**

3. **Multiple finish paths are handled:**
   - Natural finish (g.words = 0): Sets running=false, stop() returns
     immediately
   - Forced stop: Sets canceled=true, producer breaks on next iteration,
     sets running=false
   - Both paths clean up properly

4. **Consumer Task doesn't participate in synchronization:**
   - Consumer just reads from AsyncStream (thread-safe)
   - Consumer's defer schedules async update (doesn't affect producer state)
   - stop() calling `consumer?.cancel()` is safe even if already finished

## **Conclusion:**

The OSAllocatedUnfairLock properly protects all shared state, and the defer
block ensures cleanup always happens. The scenario you described
(stop pressed exactly when g.words → 0) is handled correctly - no race
condition exists.

*/
