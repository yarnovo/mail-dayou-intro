#!/usr/bin/env bash
# 一次性 bootstrap: 建 agentaily-mail-intro OSS + 绑 m.mail.agentaily.com + Let's Encrypt
set -euo pipefail

SUBDOMAIN="${SUBDOMAIN:-m.mail}"
DOMAIN="${DOMAIN:-agentaily.com}"
BUCKET="${BUCKET:-agentaily-mail-intro}"
PROFILE="${PROFILE:-hongniang-main}"

SUBDOMAIN="$SUBDOMAIN" DOMAIN="$DOMAIN" BUCKET="$BUCKET" PROFILE="$PROFILE" \
  bash ~/.claude/skills/aliyun-static-site/templates/setup-bucket.sh

echo ""
echo "==> 跑 HTTPS"
SUBDOMAIN="$SUBDOMAIN" DOMAIN="$DOMAIN" BUCKET="$BUCKET" PROFILE="$PROFILE" \
  bash ~/.claude/skills/aliyun-static-site/templates/setup-https.sh
