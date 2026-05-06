#!/usr/bin/env bash
# 一次性 bootstrap: 建 agentaily-mail-dayou-m OSS + 绑 m.mail.agentaily.com + Let's Encrypt
set -euo pipefail

SUBDOMAIN="${SUBDOMAIN:-m.xiaohua}"
DOMAIN="${DOMAIN:-agentaily.com}"
BUCKET="${BUCKET:-agentaily-mail-dayou-m}"
PROFILE="${PROFILE:-hongniang-main}"

SUBDOMAIN="$SUBDOMAIN" DOMAIN="$DOMAIN" BUCKET="$BUCKET" PROFILE="$PROFILE" \
  bash ~/.claude/skills/aliyun-static-site/templates/setup-bucket.sh

echo ""
echo "==> 跑 HTTPS"
SUBDOMAIN="$SUBDOMAIN" DOMAIN="$DOMAIN" BUCKET="$BUCKET" PROFILE="$PROFILE" \
  bash ~/.claude/skills/aliyun-static-site/templates/setup-https.sh
