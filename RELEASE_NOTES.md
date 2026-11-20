# ColorPicker v1.0.0

首个可用版本。

## 功能

- 纯菜单栏应用，无主窗口和 Dock 图标。
- 左键菜单栏图标或按 `⌘ + ⇧ + C` 进入放大取色模式。
- 单击目标像素后自动复制颜色。
- 右键菜单支持 HEX、RGBA、HSL、`NSColor`、SwiftUI `Color` 等格式。
- 记住上次选择的颜色格式。
- 同时支持 Apple Silicon 和 Intel Mac。

## 安装

1. 下载 DMG 或 ZIP。
2. 将 `ColorPicker.app` 拖入“应用程序”。
3. 首次打开时右键应用并选择“打开”。

## 说明

当前构建未使用 Apple Developer ID 签名和公证，因此可能触发 Gatekeeper 提示。若被拦截，可执行：

```sh
xattr -dr com.apple.quarantine /Applications/ColorPicker.app
```

系统要求：macOS 14.6 或更高版本。
