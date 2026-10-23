# 雷霆空战 iOS 版（PlaneWar）

把单文件 HTML5 游戏 `airplane-shooter.html`（雷霆空战）原样封装成原生 iOS App：
游戏本体 `game.html` 打包进 app，由 WKWebView 通过自定义 `thunder://` scheme 加载，
SwiftUI 只做壳（全屏、竖屏锁定、隐藏状态栏、游戏中不息屏）。

## 目录结构

```
PlaneWar/
├─ PlaneWar.xcodeproj/          # Xcode 16+ 工程（文件系统同步组，无需手动加文件）
├─ Info.plist                   # 显示名「雷霆空战」、竖屏、隐藏状态栏、启动屏
└─ PlaneWar/
   ├─ PlaneWarApp.swift         # @main SwiftUI 入口
   ├─ GameView.swift            # WKWebView 封装（WKWebView 配置 + 息屏控制）
   ├─ ThunderSchemeHandler.swift# 自定义 scheme，把包内 game.html 提供给 WebView
   ├─ game.html                 # 游戏本体（在原版基础上做了触屏适配，见下）
   └─ Assets.xcassets/          # App 图标（1024×1024，单尺寸）与强调色
```

## 相对原版 HTML 的改动（游戏逻辑零改动）

- 右下角新增两个触屏按钮：**暂停/继续** 与 **静音**（原版只能按 P / M 键）。
- 菜单与结算文案改为触屏说法（"拖动屏幕"、"点击屏幕开始"）。
- 切到后台自动暂停（`visibilitychange`，与原版 `blur` 行为一致）。
- 禁用长按选择/呼出、双击缩放、橡皮筋滚动。

其余全部保留：玩法、BOSS、道具、音效合成、
以及"首次运行把最高分种子为 200000"的一次性设定（localStorage 键不变）。

## 在 Mac 上构建运行（推荐）

要求：Xcode 16 或更高（工程用了 fileSystemSynchronizedGroups 新格式）、iOS 16+ 真机或模拟器。

1. 把 `PlaneWar/` 整个文件夹拷到 Mac，双击打开 `PlaneWar.xcodeproj`。
2. 选中左侧 PlaneWar 工程 → TARGETS `PlaneWar` → **Signing & Capabilities**：
   勾选 `Automatically manage signing`，Team 选择你的 Apple ID（免费账号即可）。
   如需改 Bundle ID：当前为 `com.planewar.thunder`，免费账号改一个独有值即可。
3. iPhone 用数据线连接并在手机上信任电脑 → 顶部设备栏选中你的 iPhone → `Cmd+R` 运行。
4. 首次安装需在手机 **设置 → 通用 → VPN 与设备管理** 里信任你的开发者证书
   （免费 Apple ID 签名 7 天有效，到期重装即可）。

导出 ipa：Xcode 菜单 Product → Archive → Distribute App → Debug/Ad-Hoc，
得到 ipa 后可用 Apple Configurator、Sideloadly 或爱思助手安装。

## 没有 Mac 怎么办

**首选：TestFlight 正式分发**（参照智搜 MediaSeek 的发布链路，本机已配好 GitHub Actions
macOS 云构建 + App Store Connect 自动上传，全程 0 元）：
按 [docs/TestFlightGuide.md](docs/TestFlightGuide.md) 走，iPhone 上通过 TestFlight 安装，
更新只需 push 后重跑工作流。

备选：
- **云 Mac / 朋友 Mac**：远程打开本工程执行上面第 2–3 步，或 Archive 导出 ipa。
- 拿到 ipa 后，你在 Windows 上已熟悉的 **Sideloadly** 流程即可安装（Apple ID 免费签名 7 天）。

## 已知取舍

- 屏幕右下角约 80×52（游戏坐标）区域是暂停/静音按钮热区，拖动飞机经过该区域不受影响，
  但在该处**点击**不会移动飞机而是触发按钮。
- 最高分保存在 WKWebView 的 localStorage（`thunder_hiscore`），卸载 app 即清零。
- 音效是 WebAudio 合成，首次点击屏幕后才会初始化（iOS 对音频的用户手势要求），属正常现象。
