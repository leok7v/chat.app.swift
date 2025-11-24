#if canImport(AppKit)
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
    }

/*  iOS does not have RunLoop and delayed termination
    func applicationShouldTerminate(_ sender: NSApplication) ->
                                        NSApplication.TerminateReply {
        if onTermination == nil {
            return .terminateNow
        } else {
            onTermination!() {
                NSApplication.shared.reply(toApplicationShouldTerminate: true)
            }
            return .terminateLater
        }
    }
*/
    func applicationShouldTerminate(_ sender: NSApplication) ->
                                        NSApplication.TerminateReply {
        UserDefaults.standard.synchronize()
        onTermination?()
        return .terminateNow
    }

}

#endif

#if canImport(UIKit)
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {

    var backgroundSessionCompletionHandler: (() -> Void)?

    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }

    func applicationWillTerminate(_ application: UIApplication) {
        trace("applicationWillTerminate")
        UserDefaults.standard.synchronize()
        onTermination?()
        trace("onTermination done")
    }

}

#endif
