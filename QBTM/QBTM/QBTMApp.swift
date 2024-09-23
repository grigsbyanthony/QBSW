import SwiftUI
import Cocoa

@main
struct QBTMApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        updateWindow()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "arrow.down.circle", accessibilityDescription: "Torrent Status")
            button.action = #selector(togglePopover(_:))
        }

        popover.contentViewController = NSHostingController(rootView: ContentView())
        popover.behavior = .transient

        setUpAppMenu()
    }

    func setUpAppMenu() {
        let mainMenu = NSMenu()

        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu

        let logoutItem = NSMenuItem(title: "Log Out", action: #selector(logOut), keyEquivalent: "L")
        logoutItem.target = self
        appMenu.addItem(logoutItem)

        let newWindowItem = NSMenuItem(title: "New Window", action: #selector(openNewWindow), keyEquivalent: "N")
        newWindowItem.target = self
        appMenu.addItem(newWindowItem)

        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: "Q")
        appMenu.addItem(quitItem)

        NSApplication.shared.mainMenu = mainMenu
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = statusItem?.button {
            if let controller = popover.contentViewController as? NSHostingController<ContentView> {
                controller.view.frame.size = CGSize(width: 600, height: 400)
            }
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    @objc func logOut() {
        UserDefaults.standard.removeObject(forKey: "qbAddress")
        UserDefaults.standard.removeObject(forKey: "qbUsername")
        UserDefaults.standard.removeObject(forKey: "qbPassword")

        updateWindow()
    }

    @objc func openNewWindow() {
        updateWindow()
    }

    func credentialsExist() -> Bool {
        let address = UserDefaults.standard.string(forKey: "qbAddress") ?? ""
        let username = UserDefaults.standard.string(forKey: "qbUsername") ?? ""
        let password = UserDefaults.standard.string(forKey: "qbPassword") ?? ""
        return !address.isEmpty && !username.isEmpty && !password.isEmpty
    }

    func updateWindow() {
        let contentView = credentialsExist() ? AnyView(ContentView()) : AnyView(LoginView())

        if window == nil {
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                styleMask: [.titled, .closable, .resizable, .miniaturizable],
                backing: .buffered, defer: false)
            window.center()
            window.setFrameAutosaveName("Main Window")
            window.delegate = self
        }

        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        window = nil
    }
}
