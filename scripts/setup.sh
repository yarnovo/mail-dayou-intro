#!/usr/bin/env bash
# 一次性 bootstrap: 建 agentaily-dayou-mail-m OSS + 绑 m.dayou.mail.agentaily.com + Let's Encrypt
# 老板 5-7 拍域名规约: m.<role>.<team>.agentaily.com (一 agent 一份 intro)
set -euo pipefail

SUBDOMAIN="${SUBDOMAIN:-m.dayou.mail}"
DOMAIN="${DOMAIN:-agentaily.com}"
BUCKET="${BUCKET:-agentaily-dayou-mail-m}"
PROFILE="${PROFILE:-default}"

SUBDOMAIN="$SUBDOMAIN" DOMAIN="$DOMAIN" BUCKET="$BUCKET" PROFILE="$PROFILE" \
  bash ~/.claude/skills/aliyun-static-site/templates/setup-bucket.sh

echo ""
echo "==> 跑 HTTPS"
SUBDOMAIN="$SUBDOMAIN" DOMAIN="$DOMAIN" BUCKET="$BUCKET" PROFILE="$PROFILE" \
  bash ~/.claude/skills/aliyun-static-site/templates/setup-https.sh
