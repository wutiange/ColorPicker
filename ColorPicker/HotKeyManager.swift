import AppKit
import Carbon

@MainActor
final class HotKeyManager {

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var isRegistered = false

    var onHotKeyPressed: (() -> Void)?

    func register() {
        guard !isRegistered else { return }

        let keyCode = UInt32(kVK_ANSI_C)
        let modifiers = UInt32(cmdKey | shiftKey)

        let hotKeyID = EventHotKeyID(
            signature: OSType(0x434F4C52),
            id: 1
        )

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let handlerStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in
                guard let event, let userData else {
                    return OSStatus(eventNotHandledErr)
                }

                var triggeredHotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &triggeredHotKeyID
                )

                guard status == noErr,
                      triggeredHotKeyID.signature == OSType(0x434F4C52),
                      triggeredHotKeyID.id == 1 else {
                    return OSStatus(eventNotHandledErr)
                }

                let manager = Unmanaged<HotKeyManager>
                    .fromOpaque(userData)
                    .takeUnretainedValue()

                DispatchQueue.main.async {
                    manager.onHotKeyPressed?()
                }

                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )

        guard handlerStatus == noErr else {
            print("全局快捷键事件处理器安装失败：\(handlerStatus)")
            return
        }

        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        guard status == noErr else {
            if let eventHandler {
                RemoveEventHandler(eventHandler)
                self.eventHandler = nil
            }
            print("全局快捷键注册失败：\(status)")
            return
        }

        isRegistered = true
        print("全局快捷键注册成功：⌘ + ⇧ + C")
    }

    func unregister() {
        guard isRegistered else { return }
        isRegistered = false

        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        if let eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }

    deinit {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }

        if let eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }
}
