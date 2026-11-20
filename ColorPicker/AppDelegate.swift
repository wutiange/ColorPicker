import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    private static let preferredFormatKey = "preferredColorFormat"

    private let hotKeyManager = HotKeyManager()
    private var statusItem: NSStatusItem?
    private var statusMenu: NSMenu?
    private var colorSampler: NSColorSampler?
    private var lastColor: NSColor?
    private var isPicking = false
    private var preferredFormat: ColorFormat = .hex
    private var feedbackWorkItem: DispatchWorkItem?

    override init() {
        super.init()

        if let rawValue = UserDefaults.standard.string(forKey: Self.preferredFormatKey),
           let format = ColorFormat(rawValue: rawValue) {
            preferredFormat = format
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        ProcessInfo.processInfo.disableAutomaticTermination("ColorPicker must remain in the menu bar")
        configureStatusItem()

        hotKeyManager.onHotKeyPressed = { [weak self] in
            self?.startPicking()
        }
        hotKeyManager.register()
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotKeyManager.unregister()
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = item.button {
            button.image = NSImage(
                systemSymbolName: "eyedropper",
                accessibilityDescription: "取色"
            )
            button.image?.isTemplate = true
            button.target = self
            button.action = #selector(statusItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.toolTip = "左键取色，右键复制颜色格式"
        }

        statusItem = item
    }

    @objc
    private func statusItemClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        let opensMenu = event?.type == .rightMouseUp
            || event?.modifierFlags.contains(.control) == true
            || event?.modifierFlags.contains(.option) == true

        if opensMenu {
            showStatusMenu()
        } else {
            startPicking()
        }
    }

    private func showStatusMenu() {
        rebuildStatusMenu()

        guard let button = statusItem?.button, let statusMenu else { return }
        statusMenu.popUp(
            positioning: nil,
            at: NSPoint(x: 0, y: button.bounds.height + 4),
            in: button
        )
    }

    private func rebuildStatusMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false

        if let lastColor {
            let currentValue = preferredFormat.string(from: lastColor) ?? "当前颜色"
            let currentItem = NSMenuItem(title: currentValue, action: nil, keyEquivalent: "")
            currentItem.image = swatchImage(for: lastColor)
            currentItem.isEnabled = false
            menu.addItem(currentItem)
        } else {
            let emptyItem = NSMenuItem(title: "尚未取色", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            menu.addItem(emptyItem)
        }

        let pickItem = NSMenuItem(title: "取色  ⌘⇧C", action: #selector(pickFromMenu), keyEquivalent: "")
        pickItem.target = self
        menu.addItem(pickItem)
        menu.addItem(.separator())

        let formatHeader = NSMenuItem(title: "复制为", action: nil, keyEquivalent: "")
        formatHeader.isEnabled = false
        menu.addItem(formatHeader)

        for format in ColorFormat.allCases {
            let item = NSMenuItem(
                title: format.menuTitle,
                action: #selector(copyFormatFromMenu(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = format.rawValue
            item.state = format == preferredFormat ? .on : .off
            item.isEnabled = lastColor != nil
            menu.addItem(item)
        }

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "退出 ColorPicker", action: #selector(quit), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = [.command]
        quitItem.target = self
        menu.addItem(quitItem)

        statusMenu = menu
    }

    @objc
    private func pickFromMenu() {
        DispatchQueue.main.async { [weak self] in
            self?.startPicking()
        }
    }

    private func startPicking() {
        guard !isPicking else { return }
        isPicking = true

        let sampler = NSColorSampler()
        colorSampler = sampler

        sampler.show { [weak self] selectedColor in
            MainActor.assumeIsolated {
                guard let self else { return }

                self.isPicking = false
                self.colorSampler = nil

                guard let selectedColor else { return }
                self.lastColor = selectedColor
                self.copy(selectedColor, using: self.preferredFormat)
            }
        }
    }

    @objc
    private func copyFormatFromMenu(_ sender: NSMenuItem) {
        guard let rawValue = sender.representedObject as? String,
              let format = ColorFormat(rawValue: rawValue),
              let lastColor else {
            return
        }

        preferredFormat = format
        UserDefaults.standard.set(format.rawValue, forKey: Self.preferredFormatKey)
        copy(lastColor, using: format)
    }

    private func copy(_ color: NSColor, using format: ColorFormat) {
        guard let value = format.string(from: color) else {
            NSSound.beep()
            return
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
        showCopyFeedback(value)
    }

    private func showCopyFeedback(_ value: String) {
        feedbackWorkItem?.cancel()

        statusItem?.button?.image = NSImage(
            systemSymbolName: "checkmark.circle.fill",
            accessibilityDescription: "颜色已复制"
        )
        statusItem?.button?.image?.isTemplate = true
        statusItem?.button?.toolTip = "已复制：\(value)"

        let workItem = DispatchWorkItem { [weak self] in
            self?.restoreStatusIcon()
        }
        feedbackWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: workItem)
    }

    private func restoreStatusIcon() {
        statusItem?.button?.image = NSImage(
            systemSymbolName: "eyedropper",
            accessibilityDescription: "取色"
        )
        statusItem?.button?.image?.isTemplate = true
        statusItem?.button?.toolTip = "左键取色，右键复制颜色格式"
    }

    private func swatchImage(for color: NSColor) -> NSImage {
        NSImage(size: NSSize(width: 16, height: 16), flipped: false) { rect in
            let swatchRect = rect.insetBy(dx: 1.5, dy: 1.5)
            let path = NSBezierPath(roundedRect: swatchRect, xRadius: 3, yRadius: 3)
            color.setFill()
            path.fill()
            NSColor.separatorColor.setStroke()
            path.lineWidth = 1
            path.stroke()
            return true
        }
    }

    @objc
    private func quit() {
        NSApp.terminate(nil)
    }
}
