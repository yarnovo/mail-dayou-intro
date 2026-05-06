# mail-dayou-intro

阿空大邮 (xiaohua) intro · 文字 + CosyVoice TTS mp3 + 静态站。

## 老板视角

- prod: https://m.mail.agentaily.com (待 setup.sh)
- TTS voice: `longwan_v2` 温柔女声 · 跟"创作引导"调性匹配

## 跑

```bash
# 一次性 bootstrap (建 OSS + DNS + cert)
bash scripts/setup.sh

# 出 mp3 (改文字稿后跑)
bash scripts/build.sh

# 部 prod
bash scripts/deploy-oss.sh prod
```

## 内容

```
intro/text/intro-zh.md       # 文字稿 (TTS 输入)
intro/audio/intro-zh.mp3     # TTS 输出 (build.sh 生成)
intro.config.json            # 渲染参数 (avatar=xiaohua, accent=#14b8a6)
src/intro_builder/build.py   # TTS builder
scripts/{build,deploy-oss,setup}.sh
```

引用 `~/.claude/repos/akong-intro-design/render/render.py` 渲染共享设计 · 引用 `~/.claude/repos/akong-avatars/avatars/xiaohua.svg` 头像。
