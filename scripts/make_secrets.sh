#!/usr/bin/env bash
# 生成 7 个 GitHub Secrets 的值 → local/ 目录(git 已忽略),逐个复制粘贴到
# 仓库 Settings → Secrets and variables → Actions。
# ⚠️ GitHub 的 Secret 只写不可读,智搜仓库里抄不到值;本脚本全部从本机原始文件生成。
# 用法(Git Bash): bash scripts/make_secrets.sh
set -euo pipefail

SRC="/c/Users/44957/Downloads/MediaSeek装机"
OUT="$(cd "$(dirname "$0")/.." && pwd)/local"
mkdir -p "$OUT"

b64() { base64 -w0 "$1" > "$OUT/$2.txt"; echo "已生成 $OUT/$2.txt"; }

[ -f "$SRC/AuthKey_8H66F4QJCN.p8" ] || { echo "❌ 找不到 $SRC 下的密钥,确认 MediaSeek装机 文件夹位置"; exit 1; }

# 复用智搜的团队级材料
b64 "$SRC/AuthKey_8H66F4QJCN.p8" ASC_API_KEY_P8
b64 "$SRC/distribution.p12"      DISTRIBUTION_P12
echo "8H66F4QJCN"                            > "$OUT/ASC_KEY_ID.txt";              echo "已生成 $OUT/ASC_KEY_ID.txt"
echo "fb64c8fb-5335-4bf6-933b-a8b1a7837103"  > "$OUT/ASC_ISSUER_ID.txt";           echo "已生成 $OUT/ASC_ISSUER_ID.txt"
echo "QBU3P5SMNS"                            > "$OUT/DEVELOPMENT_TEAM_ID.txt";     echo "已生成 $OUT/DEVELOPMENT_TEAM_ID.txt"

# 只能手工提供的一项
echo "✍  P12_PASSWORD:智搜导出 distribution.p12 时设的密码,自己回忆填入"
# 描述文件:已在浏览器操作中生成并下载到 Downloads
PROF="/c/Users/44957/Downloads/PlaneWar_AppStore.mobileprovision"
if [ -f "$PROF" ]; then
  b64 "$PROF" PROFILE_MOBILEPROVISION
else
  echo "✍  PROFILE_MOBILEPROVISION:未找到 $PROF —— 按指南 B2 生成下载后重跑本脚本"
fi
