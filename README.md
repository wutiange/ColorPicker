# ColorPicker

一个轻量的 macOS 菜单栏取色器。无主窗口、无 Dock 图标，通过快捷键或菜单栏图标即可快速取色。

## 功能

- 左键点击菜单栏吸管图标，或按 `⌘ + ⇧ + C` 开始取色。
- 使用 macOS 系统放大镜精确选择屏幕像素。
- 单击后自动复制颜色值。
- 右键点击菜单栏图标，可切换并复制多种格式：
  - HEX、HEX（含透明度）
  - RGB、RGBA
  - HSL、HSLA
  - `NSColor`、SwiftUI `Color`
- 记住上次选择的复制格式。

## 下载与安装

1. 打开仓库右侧的 **Releases**。
2. 下载 [最新版 DMG](https://github.com/wutiange/ColorPicker/releases/latest/download/ColorPicker-v1.0.0-macOS.dmg) 或 [ZIP 包](https://github.com/wutiange/ColorPicker/releases/latest/download/ColorPicker-v1.0.0-macOS.zip)。
3. 将 `ColorPicker.app` 拖入“应用程序”文件夹。
4. 首次启动时右键点击应用并选择“打开”。

> 当前版本没有 Apple Developer ID 签名和公证，因此 macOS Gatekeeper 可能阻止双击启动。若仍被拦截，可执行：
>
> ```sh
> xattr -dr com.apple.quarantine /Applications/ColorPicker.app
> ```

## 使用

- **左键菜单栏图标**：开始取色。
- **`⌘ + ⇧ + C`**：全局快捷键取色。
- **右键菜单栏图标**：选择颜色格式、重新取色或退出。

取色结束后，当前格式的颜色值会直接写入系统剪贴板。

## 系统要求

- macOS 14.6 或更高版本
- 支持 Apple Silicon 与 Intel Mac

## 从源码构建

```sh
xcodebuild -project ColorPicker.xcodeproj -scheme ColorPicker \
  -configuration Release -destination 'generic/platform=macOS' \
  -derivedDataPath /tmp/ColorPickerDerivedData \
  CODE_SIGNING_ALLOWED=NO build
```

也可以直接使用打包脚本：

```sh
./Scripts/package.sh
```

生成文件位于 `Release/`。

## 源码

https://github.com/wutiange/ColorPicker

## 隐私

应用不联网、不收集分析数据。屏幕取色使用系统 `NSColorSampler` 完成。
