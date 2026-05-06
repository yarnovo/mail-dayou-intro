"""把 intro/text/*.md → intro/audio/*.mp3 · voice 真源走 agent 仓 profile.json."""
from __future__ import annotations

import os, sys, json
from pathlib import Path

import dashscope
from dashscope.audio.tts_v2 import SpeechSynthesizer

REPO_ROOT = Path(__file__).resolve().parents[2]
TEXT_DIR = REPO_ROOT / "intro" / "text"
AUDIO_DIR = REPO_ROOT / "intro" / "audio"

AGENT_REPO = "mail-dayou-agent"
AGENT_SLUG = "dayou"


def load_profile() -> dict:
    profile_path = REPO_ROOT.parent / AGENT_REPO / "workspace" / AGENT_SLUG / "profile.json"
    if not profile_path.exists():
        sys.exit(f"❌ profile 不存在: {profile_path}")
    return json.loads(profile_path.read_text(encoding="utf-8"))


def resolve_dashscope_key() -> str:
    if k := os.getenv("DASHSCOPE_API_KEY"): return k
    secrets = REPO_ROOT / ".vault" / "secrets.json"
    if secrets.exists():
        d = json.loads(secrets.read_text())
        if k := d.get("dashscope-main", {}).get("api_key"): return k
    fallback = Path.home() / ".claude/repos/vault/data/credentials/dashscope-main.json"
    if fallback.exists():
        d = json.loads(fallback.read_text())
        if k := d.get("values", {}).get("api_key"): return k
    sys.exit("❌ 没找到 DASHSCOPE_API_KEY")


def synth_one(text: str, dst: Path, voice: str, model: str) -> Path:
    dashscope.api_key = resolve_dashscope_key()
    syn = SpeechSynthesizer(model=model, voice=voice)
    audio = syn.call(text)
    if not audio: sys.exit(f"❌ CosyVoice 合成失败 voice={voice}")
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_bytes(audio)
    return dst


def build_all() -> None:
    if not TEXT_DIR.exists(): sys.exit(f"❌ {TEXT_DIR} 不存在")
    profile = load_profile()
    voice = profile["voice"]["slug"]
    model = profile["voice"].get("model", "cosyvoice-v2")
    print(f">>> using profile from {AGENT_REPO} · voice={voice} ({profile['voice']['voice_zh']})")
    for md in sorted(TEXT_DIR.glob("*.md")):
        text = md.read_text(encoding="utf-8").strip()
        if not text: continue
        out = AUDIO_DIR / f"{md.stem}.mp3"
        print(f">>> {md.name} → {out.name}")
        synth_one(text, out, voice=voice, model=model)
        print(f"    {out.stat().st_size // 1024} KB")


if __name__ == "__main__":
    build_all()
