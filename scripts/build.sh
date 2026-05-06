#!/usr/bin/env bash
# 一键: intro/text/*.md → intro/audio/*.mp3
set -euo pipefail
cd "$(dirname "$0")/.."

uv sync --quiet
uv run python src/intro_builder/build.py
ls -la intro/audio/
