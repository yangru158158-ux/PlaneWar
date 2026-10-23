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
| `PROFILE_MOBILEPROVISION` | 已由 `make_secrets.sh` 自动生成(描述文件已下载到 `Downloads\PlaneWar_AppStore.mobileprovision`) |

> ⚠️ **GitHub 的 Secret 只写不可读**——智搜仓库里只能看到名字、抄不到值,
> 所以上表全部从本机原始文件现场生成。Git Bash 里跑 `bash scripts/make_secrets.sh`,
> 它会把可直接粘贴的值生成到 `local/` 目录(已被 .gitignore 忽略),
> 唯一要自己回忆的是 `P12_PASSWORD`。

## 阶段 B:苹果网页登记 ✅ 已完成(2026-10-24 浏览器自动化操作)

三项登记全部做完,以下是登记结果存档,以后查证用:

| 项目 | 结果 |
|---|---|
| App ID | `com.planewar.thunder`(Explicit,名称 PlaneWar,未勾选任何能力) |
| 描述文件 | `PlaneWar AppStore`(iOS App Store 分发,证书 yang ru (Distribution),文件已下载到 `C:\Users\44957\Downloads\PlaneWar_AppStore.mobileprovision`) |
| ASC App 记录 | 名称「雷霆空战：飞行射击」(「雷霆空战」被占用;手机上显示名仍为内置的「雷霆空战」),**ASC App ID `6826326093`**,SKU `planewar001`,主要语言简体中文,用户访问权限=有限 |

> 注意:ASC 首页提示《Apple Developer Program 许可协议》有更新待账户持有人在
> developer.apple.com/account 确认——目前创建 App 记录不受影响,但**提交构建供测试前**
> 若被要求接受协议,登录苹果后台点一次同意即可。

### A4. 验证编译
- 推送后打开 Actions 页,**Build Check** 会自动跑;约 5-10 分钟全绿 ✅ = 编译通过。

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

### 另路:免费侧载(不经 TestFlight)
Actions → **Build Unsigned IPA** → Run,跑完在页面底部 Artifacts 下载
`PlaneWar-unsigned-ipa`,解压得 `PlaneWar-unsigned.ipa`,用 Sideloadly/爱思助手
以自己的 Apple ID 签名安装(7 天有效)。适合临时自用;给别人测还是走 TestFlight。

## 发版纪律(智搜跑通验证过的运维规矩,照做)

1. **铁律**:push 后先等 **Build Check** 全绿,才允许发版;发版只认 `release.yml`。
2. **gh CLI 发版与轮询**(Windows 已装 gh 的话):
   ```bash
   gh workflow run release.yml                       # 触发发版
   gh run list --workflow=release.yml --limit 1      # 拿最新 run id
   gh run view <id> --json status,conclusion         # 轮询到 conclusion 出现
   ```
   gh 未登录时:`export GH_TOKEN=$(cat <token文件> | tr -d '\r\n')`。
3. **版本号纪律**:build 号 = 工作流的 `github.run_number`,单调递增永不撞号,
   TestFlight 显示为 `1.0(N)`;不要在代码里手写 build 号。
4. **macOS 容量拒单判别**(智搜实测,单日可连拒多次):
   job 结论 `cancelled`、**零失败 step、零日志、排队约 15-22 分钟** = 没抢到 runner,
   不是真失败 → `gh run rerun <id>` 重派即可,**别改任何东西**;
   **有 error 日志才是真失败**,读日志修。连拒可等一小时再重派;排队中的 run 会一直等,不用干预。
5. **仓库可见性**:保持 **Public**——公开仓库 macOS 构建免费;私有仓库 macOS 分钟按
   10 倍扣,智搜就是靠公开仓库免费额度跑的,别改成 Private。

## 常见问题

- **Build Check 挂了?** 点进红色步骤看日志发我;工程是手写 pbxproj,已用标准库校验过,常见问题多是 runner 的 Xcode 版本变动。
- **Release 报签名错误?** 核对 7 个 secret 拼写与 Team ID 无多余空格;描述文件必须含 `com.planewar.thunder` 且证书选的是同一张 Apple Distribution。
- **上传被拒 "Invalid Bundle"?** Bundle ID 要与 B1 注册完全一致(`com.planewar.thunder`)。
- **邀请邮件没收到?** 外部组九成是没跑 `external-setup`(组里没有已过审构建);内部组确认对方已是 ASC 团队成员。
- **费用总览:0 元。** 开发者账号智搜时已付;GitHub 公开仓库构建、TestFlight 均 $0。
