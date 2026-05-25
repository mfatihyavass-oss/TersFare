import Cocoa
import ApplicationServices

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var retryTimer: Timer?

    private var enabled = true {
        didSet {
            if enabled {
                startEventTapIfPossible()
            } else {
                stopEventTap()
            }
            rebuildMenu()
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusItem()
        promptForAccessibilityIfNeeded()
        startEventTapIfPossible()

        retryTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.startEventTapIfPossible()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        stopEventTap()
        retryTimer?.invalidate()
    }

    fileprivate func handleScrollEvent(_ event: CGEvent) -> CGEvent {
        guard enabled else { return event }

        // Trackpads and Magic Mouse usually produce continuous scroll events.
        // Classic mouse wheels usually do not. Reverse only the wheel-style events.
        let isContinuous = event.getIntegerValueField(.scrollWheelEventIsContinuous) != 0
        guard !isContinuous else { return event }

        reverseIntegerField(.scrollWheelEventDeltaAxis1, on: event)
        reverseIntegerField(.scrollWheelEventPointDeltaAxis1, on: event)
        reverseIntegerField(.scrollWheelEventFixedPtDeltaAxis1, on: event)
        return event
    }

    fileprivate func reenableEventTap() {
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: true)
        }
    }

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.title = "↕"
        statusItem = item
        rebuildMenu()
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        let stateTitle = eventTap == nil ? "Durum: izin bekleniyor" : "Durum: aktif"
        let stateItem = NSMenuItem(title: stateTitle, action: nil, keyEquivalent: "")
        stateItem.isEnabled = false
        menu.addItem(stateItem)

        let toggleItem = NSMenuItem(
            title: enabled ? "Fare ters çevirmeyi kapat" : "Fare ters çevirmeyi aç",
            action: #selector(toggleEnabled),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        let permissionItem = NSMenuItem(
            title: "Erişilebilirlik iznini aç",
            action: #selector(openAccessibilitySettings),
            keyEquivalent: ""
        )
        permissionItem.target = self
        menu.addItem(permissionItem)

        let restartItem = NSMenuItem(
            title: "Yeniden dene",
            action: #selector(retryEventTap),
            keyEquivalent: ""
        )
        restartItem.target = self
        menu.addItem(restartItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Çık", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc private func toggleEnabled() {
        enabled.toggle()
    }

    @objc private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    @objc private func retryEventTap() {
        stopEventTap()
        promptForAccessibilityIfNeeded()
        startEventTapIfPossible()
    }

    private func promptForAccessibilityIfNeeded() {
        let options = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    private func startEventTapIfPossible() {
        guard enabled, eventTap == nil, AXIsProcessTrusted() else {
            rebuildMenu()
            return
        }

        let mask = CGEventMask(1 << CGEventType.scrollWheel.rawValue)
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: scrollEventCallback,
            userInfo: selfPointer
        ) else {
            rebuildMenu()
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        if let runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }

        CGEvent.tapEnable(tap: tap, enable: true)
        rebuildMenu()
    }

    private func stopEventTap() {
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }

        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }

        runLoopSource = nil
        eventTap = nil
        rebuildMenu()
    }

    private func reverseIntegerField(_ field: CGEventField, on event: CGEvent) {
        let value = event.getIntegerValueField(field)
        if value != 0 {
            event.setIntegerValueField(field, value: -value)
        }
    }
}

private let scrollEventCallback: CGEventTapCallBack = { _, type, event, userInfo in
    guard let userInfo else {
        return Unmanaged.passUnretained(event)
    }

    let app = Unmanaged<AppDelegate>.fromOpaque(userInfo).takeUnretainedValue()

    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        app.reenableEventTap()
        return Unmanaged.passUnretained(event)
    }

    guard type == .scrollWheel else {
        return Unmanaged.passUnretained(event)
    }

    return Unmanaged.passUnretained(app.handleScrollEvent(event))
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
