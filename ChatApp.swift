import SwiftUI

@main
struct ChatApp: App {

    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    typealias BaseApplication = UIApplication
    #elseif os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    typealias BaseApplication = NSApplication
    #endif

    @StateObject private var fm = FontsMetric()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(fm)
            #if os(iOS)
            .frame(maxWidth: UIScreen.main.bounds.size.width)
            #elseif os(macOS)
            .frame(minWidth: 480, minHeight: 360)
            #endif
            .onReceive(NotificationCenter.default.publisher(
                       for: BaseApplication.willTerminateNotification)) { _ in
                trace("willTerminateNotification() done")
                // The willTerminateNotification is generally unreliable on iOS
                // and often not posted. Use didEnterBackgroundNotification
                // AppDelegate.applicationWillTerminate() is can be used instead
            }
            .onReceive(NotificationCenter.default.publisher(
                       for: BaseApplication.didBecomeActiveNotification)) { _ in
//              trace("didBecomeActiveNotification()")
            }
            .onReceive(NotificationCenter.default.publisher(
                       for: BaseApplication.willResignActiveNotification)) { _ in
                // if we need to pause generation it is a good place to do it
                trace("willResignActiveNotification()")
            }
            #if os(iOS)
            .onReceive(NotificationCenter.default.publisher(
                       for: BaseApplication.didEnterBackgroundNotification)) { _ in
                // it is a good place to save app state
                trace("didEnterBackgroundNotification()")
            }
            .onReceive(NotificationCenter.default.publisher(
                       for: BaseApplication.didReceiveMemoryWarningNotification)) { _ in
                trace("didReceiveMemoryWarningNotification()")
            }
            .onReceive(NotificationCenter.default.publisher(
                       for: BaseApplication.willEnterForegroundNotification)) { _ in
                trace("willEnterForegroundNotification()")
            }
            #endif
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                EmptyView()
            }
        }

    }
}

func modelName() -> String {
    "ModelName v.0"
}

