#!/usr/bin/env bash
# render 共享 intro 设计 + 上传 dist/index.html + mp3 到 m.xiaohua OSS bucket
# 第一次跑前必跑 setup.sh (建 bucket + 关 BPA + 绑 cname + 证书)

set -euo pipefail
cd "$(dirname "$0")/.."

ENV="${1:-prod}"
case "$ENV" in
  prod)    BUCKET="${BUCKET:-agentaily-mail-dayou-m}" ;;
  staging) BUCKET="${BUCKET:-agentaily-mail-dayou-m-staging}" ;;
  *) echo "用法: $0 [prod|staging]"; exit 1 ;;
esac
PROFILE="${PROFILE:-hongniang-main}"
DESIGN="${HOME}/.claude/repos/akong-intro-design"

# 1. 渲染
mkdir -p dist
python3 "$DESIGN/render/render.py" \
  --config intro.config.json \
  --transcript intro/text/intro-zh.md \
  --out dist/index.html

# 2. 上传 index.html
aliyun ossutil cp "dist/index.html" "oss://$BUCKET/index.html" \
  --cache-control "public, max-age=300, must-revalidate" \
  --content-type "text/html; charset=utf-8" \
  --profile "$PROFILE" -f

# 3. 上传 mp3
aliyun ossutil cp "intro/audio/intro-zh.mp3" "oss://$BUCKET/intro-zh.mp3" \
  --cache-control "public, max-age=86400" \
  --content-type "audio/mpeg" \
  --profile "$PROFILE" -f

case "$ENV" in
  prod)    echo "✓ deployed → https://m.mail.agentaily.com/" ;;
  staging) echo "✓ deployed → https://staging.m.mail.agentaily.com/" ;;
esac
