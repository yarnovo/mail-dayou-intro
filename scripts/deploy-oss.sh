#!/usr/bin/env bash
# 用 akong-intro-astro 共享 template 渲染 + 上传 dist/ 到 m.mail OSS bucket
# 第一次跑前必跑 setup.sh (建 bucket + 关 BPA + 绑 cname + 证书)

set -euo pipefail
cd "$(dirname "$0")/.."

ENV="${1:-prod}"
case "$ENV" in
  prod)    BUCKET="${BUCKET:-agentaily-mail-intro}" ;;
  staging) BUCKET="${BUCKET:-agentaily-mail-intro-staging}" ;;
  *) echo "用法: $0 [prod|staging]"; exit 1 ;;
esac
PROFILE="${PROFILE:-hongniang-main}"
ASTRO_DIR="${HOME}/.claude/repos/akong-intro-astro"
SLUG="dayou"

[ -d "$ASTRO_DIR" ] || { echo "❌ akong-intro-astro 不存在 · git clone yarnovo/akong-intro-astro 同级"; exit 1; }
AVATAR="${HOME}/.claude/repos/akong-avatars/avatars/${SLUG}.svg"
[ -f "$AVATAR" ] || { echo "❌ 头像 SVG 不存在: $AVATAR"; exit 1; }

# 1. inject 本仓 config + 资源到 astro template public/
echo "==> inject 本仓资源到 astro public/"
mkdir -p "$ASTRO_DIR/public"
cp intro.config.json         "$ASTRO_DIR/public/intro.config.json"
cp intro/audio/intro-zh.mp3  "$ASTRO_DIR/public/intro-zh.mp3"
cp intro/text/intro-zh.md    "$ASTRO_DIR/public/transcript.md"
cp "$AVATAR"                 "$ASTRO_DIR/public/avatar.svg"

# 2. astro build
echo "==> astro build"
( cd "$ASTRO_DIR" && pnpm install --silent && pnpm build )

# 3. cp dist 回本仓
rm -rf dist
mkdir -p dist
cp -r "$ASTRO_DIR/dist/"* dist/

# 4. 上传整 dist (cp -r -f 强制 overwrite + sync 清孤儿)
echo "==> upload dist/ → oss://$BUCKET/"
aliyun ossutil cp dist/ "oss://$BUCKET/" -r -f \
  --cache-control "public, max-age=300, must-revalidate" \
  --profile "$PROFILE"
aliyun ossutil sync dist/ "oss://$BUCKET/" \
  --delete --update --profile "$PROFILE"

case "$ENV" in
  prod)    echo "✓ deployed → https://m.mail.agentaily.com/" ;;
  staging) echo "✓ deployed → https://staging.m.mail.agentaily.com/" ;;
esac
