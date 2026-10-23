# 雷霆空战 TestFlight 发布指南(Windows 无 Mac 版)

> 照搬智搜「MediaSeek」已验证的发布链路:GitHub 公开仓库的 macOS 云构建(免费)
> 自动签名归档并上传 App Store Connect,TestFlight 装机。
> **与智搜那次不同:开发者账号($99)、ASC API 密钥、Apple Distribution 证书都已有了,
> 这次全程 0 元**,只需在苹果网页上给新 Bundle ID 做三件登记。
> 你的角色:按顺序做浏览器操作;自动化部分(工作流、脚本)已全部备好。

## 阶段 A:GitHub 仓库与密钥(不花钱)

### A1. 创建仓库
- 打开 <https://github.com/new> → Repository name 填 `PlaneWar`
- **可见性必须选 `Public`**(公开仓库 macOS 构建免费;私有仓库 macOS 分钟按 10 倍扣)
- 不要勾选自动生成 README → Create repository

### A2. 推送代码
本目录已 `git init` 并完成首次提交,只需(Git Bash,替换用户名):

```bash
cd ~/.zcode/workspace/draft-a676ec15-6d63-443a-affd-749cccaff327/PlaneWar
git remote add origin https://github.com/你的用户名/PlaneWar.git
git push -u origin main
```

### A3. 配置 7 个 Secrets
打开 <https://github.com/你的用户名/PlaneWar/settings/secrets/actions> → 逐条添加:

| Name | Secret 值 |
|---|---|
| `ASC_KEY_ID` | `8H66F4QJCN`(与智搜同一个团队密钥) |
| `ASC_ISSUER_ID` | `fb64c8fb-5335-4bf6-933b-a8b1a7837103` |
| `ASC_API_KEY_P8` | `base64 -w0 "C:\Users\44957\Downloads\MediaSeek装机\AuthKey_8H66F4QJCN.p8"` 的输出 |
| `DEVELOPMENT_TEAM_ID` | `QBU3P5SMNS` |
| `DISTRIBUTION_P12` | `base64 -w0 "C:\Users\44957\Downloads\MediaSeek装机\distribution.p12"` 的输出(团队证书复用) |
| `P12_PASSWORD` | 智搜时导出 distribution.p12 设的那个密码 |
| `PROFILE_MOBILEPROVISION` | B2 下载的 `PlaneWar_AppStore.mobileprovision` 做 base64 |

> 前六个都与智搜共用同一份文件;只有描述文件是这个 App 专属的,先做阶段 B 再回来填这条。

### A4. 验证编译
- 推送后打开 Actions 页,**Build Check** 会自动跑;约 5-10 分钟全绿 ✅ = 编译通过。

## 阶段 B:苹果网页登记(不花钱,约 10 分钟)

### B1. 注册 App ID
- <https://developer.apple.com/account/resources/identifiers/list/bundleId> → **+**
- App IDs → App → 能力不加,Continue
- Description `PlaneWar`,Bundle ID 选 **Explicit**,输入 `com.planewar.thunder` → Register

### B2. 生成 App Store 描述文件(本 App 唯一的新签名材料)
- <https://developer.apple.com/account/resources/profiles/list> → **+**
- Distribution 选 **App Store Connect** → Continue
- App ID 选 `com.planewar.thunder` → Continue
- 证书勾选 **Apple Distribution**(QBU3P5SMNS 名下已有的那一张)→ Generate
- **Download** 得到 `PlaneWar_AppStore.mobileprovision` → 回去完成 A3 的最后一条 secret

### B3. 在 App Store Connect 建 App 记录(TestFlight 的挂载点)
- <https://appstoreconnect.apple.com/apps> → **+** → 新建 App
- 名称:`雷霆空战`(被占用就换,只影响显示)、主要语言:简体中文
- Bundle ID:`com.planewar.thunder`,SKU:`planewar001` → 创建

## 阶段 C:发布并装机

### C1. 触发发布
- Actions → 左侧 **Release to TestFlight** → **Run workflow**
- 约 10-20 分钟:自动归档、签名(团队分发证书 + B2 描述文件)、上传苹果
- 上传后 5-15 分钟苹果处理构建,可用本地脚本查:`python scripts/asc_builds.py`

### C2. 自己装机(内部测试,免 Beta 审核,最快)
- <https://appstoreconnect.apple.com/testflight> → 点进「雷霆空战」
- **内部测试** → **App Store Connect 用户** → **+** → 勾你自己 → 邀请
- iPhone 装 **TestFlight** → 登录 → 「雷霆空战」→ 安装 🎉
  (拖动屏幕移动,自动开火,右下角按钮暂停/静音)

### C3. 给别人测(外部测试,首次要过 Beta 审核)
- Actions → **ASC Tools** → Run workflow:
  - `job=add-tester`,`email=对方邮箱`,`group=外部测试` → 自动建组并发出邀请邮件
  - 等 C1 的构建处理完后,再跑一次:`job=external-setup`,`group=外部测试`
    (有审核联系电话就把 contact_* 四项也填上)→ 自动挂构建、补描述、提交 Beta 审核
- 审核通过(几小时~一天)后,对方邮箱的 TestFlight 邀请即可正常安装

### C4. 以后的更新
改代码 → `git push` → 重跑 **Release to TestFlight**(构建号自动递增)→ TestFlight 里更新。
构建 90 天过期,过期重跑一次工作流即可。

## 常见问题

- **Build Check 挂了?** 点进红色步骤看日志发我;工程是手写 pbxproj,已用标准库校验过,常见问题多是 runner 的 Xcode 版本变动。
- **Release 报签名错误?** 核对 7 个 secret 拼写与 Team ID 无多余空格;描述文件必须含 `com.planewar.thunder` 且证书选的是同一张 Apple Distribution。
- **上传被拒 "Invalid Bundle"?** Bundle ID 要与 B1 注册完全一致(`com.planewar.thunder`)。
- **邀请邮件没收到?** 外部组九成是没跑 `external-setup`(组里没有已过审构建);内部组确认对方已是 ASC 团队成员。
- **费用总览:0 元。** 开发者账号智搜时已付;GitHub 公开仓库构建、TestFlight 均 $0。
