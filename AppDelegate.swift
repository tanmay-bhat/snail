import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var settingsWindow: NSWindow?
    let networkMonitor = NetworkMonitor()
    var updateTimer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the popover content view
        let popoverView = PopoverView(
            networkMonitor: networkMonitor,
            onSettings: { [weak self] in self?.openSettings() },
            onQuit: { [weak self] in self?.quitApp() }
        )
        
        // Setup popover behavior
        popover = NSPopover()
        popover.contentSize = NSSize(width: 250, height: 160)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: popoverView)
        
        // Setup the menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.title = "Initializing..."
            button.action = #selector(togglePopover(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Start monitoring network interfaces
        networkMonitor.startMonitoring()
        
        // Update the status item every second
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.networkMonitor.fetchNetworkStats()
            self?.updateStatusBarTitle()
        }
        updateTimer?.tolerance = 0.1
        RunLoop.current.add(updateTimer!, forMode: .common)
    }
    
    func updateStatusBarTitle() {
        guard let button = statusItem.button else { return }
        
        let upload = networkMonitor.formattedSpeed(bytesPerSecond: networkMonitor.currentUploadSpeed)
        let download = networkMonitor.formattedSpeed(bytesPerSecond: networkMonitor.currentDownloadSpeed)
        
        let titleString = "↓ \(download) / ↑ \(upload)"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: SettingsManager.shared.preferredTextSize.nsFont
        ]
        
        button.attributedTitle = NSAttributedString(string: titleString, attributes: attributes)
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }
        
        // Support right click for quick quit/settings if needed later, 
        // for now just toggle the main popover for any click
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            // Make sure the application is active so the popover behaves correctly
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc func openSettings() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.popover.performClose(nil)
            NSApp.activate(ignoringOtherApps: true)
            
            if self.settingsWindow == nil {
                let hostingController = NSHostingController(rootView: SettingsView())
                let window = NSWindow(
                    contentRect: NSRect(x: 0, y: 0, width: 350, height: 200),
                    styleMask: [.titled, .closable, .miniaturizable],
                    backing: .buffered,
                    defer: false
                )
                window.center()
                window.title = "Settings"
                window.contentViewController = hostingController
                window.isReleasedWhenClosed = false
                self.settingsWindow = window
            }
            
            self.settingsWindow?.makeKeyAndOrderFront(nil)
        }
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
}
