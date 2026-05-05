import AppKit
import SwiftUI

@main
enum MediaDownloaderApp {
    private static var delegate: AppDelegate?

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        Self.delegate = delegate
        app.delegate = delegate
        app.setActivationPolicy(.regular)
        app.run()
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let model = AppModel()
    private var window: SpotlightWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        presentWindow(activate: true)
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        presentWindow(activate: false)
    }

    func applicationDidResignActive(_ notification: Notification) {
        window?.orderOut(nil)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        presentWindow(activate: true)
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    private func presentWindow(activate: Bool) {
        let window = makeWindowIfNeeded()
        window.makeKeyAndOrderFront(nil)

        if activate {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func makeWindowIfNeeded() -> SpotlightWindow {
        if let window {
            return window
        }

        let visibleFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 900, height: 1060)
        let windowSize = NSSize(
            width: min(860, max(760, visibleFrame.width - 32)),
            height: min(1060, max(760, visibleFrame.height - 24))
        )

        let contentView = NSHostingView(
            rootView: ContentView(model: model)
                .frame(width: windowSize.width, height: windowSize.height)
        )

        let window = SpotlightWindow(
            contentRect: NSRect(origin: .zero, size: windowSize),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.contentView = contentView
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.isMovableByWindowBackground = false
        window.level = .normal
        window.collectionBehavior = [.moveToActiveSpace]
        window.title = "Media Downloader"
        window.setFrameOrigin(NSPoint(
            x: visibleFrame.midX - windowSize.width / 2,
            y: visibleFrame.midY - windowSize.height / 2
        ))

        self.window = window
        return window
    }
}

final class SpotlightWindow: NSWindow {
    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }
}
