# Repository Guidelines

## Project Structure & Module Organization

- `ColorPicker/` contains app sources. Keep the AppKit entry point in `MyApp.swift`, menu-bar behavior in `AppDelegate.swift`, and color serialization in `ColorFormat.swift`.
- `ColorPicker/Assets.xcassets/` contains asset catalogs and colors.
- `ColorPicker.xcodeproj/` contains the macOS target and scheme. Its synchronized group includes Swift files added under `ColorPicker/` automatically. Use `Scripts/package.sh` for release archives; outputs go to ignored `Release/`.
- No test target exists yet. Add tests in a dedicated `ColorPickerTests/` directory when introducing test infrastructure.

## Build, Test, and Development Commands

```sh
open ColorPicker.xcodeproj
xcodebuild -project ColorPicker.xcodeproj -scheme ColorPicker \
  -configuration Debug -destination 'platform=macOS' \
  -derivedDataPath /tmp/ColorPickerDerivedData \
  CODE_SIGNING_ALLOWED=NO build
```

Use Xcode's Run action (`Cmd+R`) for local development. The second command verifies compilation without signing.

## Coding Style & Naming Conventions

- Use Swift 5 with four-space indentation and standard Swift formatting; no formatter or linter is configured.
- Use `PascalCase` for types, `lowerCamelCase` for methods/properties, and descriptive names such as `ColorFormat`.
- Mark UI and AppKit lifecycle types `@MainActor` when adding concurrency. Keep implementation details `private`.
- Pair resource acquisition and cleanup, especially hotkey and sampler sessions. Make start/stop operations idempotent.

## Architecture & Behavior

The app is a menu-bar-only utility (`LSUIElement`) with no main window. `AppDelegate` owns the status item, starts `NSColorSampler` for magnified screen selection, and copies the selected color automatically. Left-click the status icon to pick; right-click for format-copy actions. `HotKeyManager` owns the global `Cmd+Shift+C` shortcut. Keep picking sessions single-instance and format conversion in `ColorFormat`.

## Testing Guidelines

No tests are present. If adding XCTest coverage, name cases `test<Behavior>()` and place them in the `ColorPickerTests` target. Prioritize RGB/alpha/HSL/HEX conversion, preferred-format persistence, and idempotent hotkey registration. Avoid real screen capture in unit tests; inject or mock system boundaries.

## Commit & Pull Request Guidelines

Git history currently contains only `Initial Commit`, so use concise imperative messages such as `Add screen color sampling` or `Fix hotkey cleanup`. Keep commits focused.

Pull requests should explain behavior changes, list manual verification steps, link related issues, and include screenshots or recordings for UI changes. Confirm the build command above passes.

## Configuration & Security

The app targets macOS 14.6 with App Sandbox enabled and uses `io.github.wutiange.ColorPicker`. No development team is committed; contributors should choose their own signing team. Do not commit credentials, `DerivedData`, or `xcuserdata`. Custom screen capture may require Screen Recording permission; document any permission flow.
