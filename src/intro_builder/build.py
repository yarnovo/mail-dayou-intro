"""把 intro/text/*.md → intro/audio/*.mp3 · 用 MiniMax Speech-02-HD (老板 5-6 拍替 CosyVoice · 中文多音字更准)."""
from __future__ import annotations

import os, sys, json
from pathlib import Path

import requests

REPO_ROOT = Path(__file__).resolve().parents[2]
TEXT_DIR = REPO_ROOT / "intro" / "text"
AUDIO_DIR = REPO_ROOT / "intro" / "audio"

AGENT_REPO = "mail-dayou-agent"
AGENT_SLUG = "dayou"

MINIMAX_MODEL = "speech-02-hd"


def load_profile() -> dict:
    profile_path = REPO_ROOT.parent / AGENT_REPO / "workspace" / AGENT_SLUG / "profile.json"
    if not profile_path.exists():
        sys.exit(f"❌ profile 不存在: {profile_path}")
    return json.loads(profile_path.read_text(encoding="utf-8"))


def resolve_minimax_creds() -> tuple[str, str]:
    """优先 env · 再本仓 .vault · 最后 fallback ~/uat-video-composer/.vault (5-4 老板拍存这里)."""
    api_key = os.getenv("MINIMAX_API_KEY")
    group_id = os.getenv("MINIMAX_GROUP_ID")
    if api_key and group_id:
        return api_key, group_id

    for vault in [
        REPO_ROOT / ".vault" / "secrets.json",
        Path.home() / "uat-video-composer" / ".vault" / "secrets.json",
    ]:
        if vault.exists():
            d = json.loads(vault.read_text())
            entry = d.get("minimax-main") or d.get("minimax_tts") or {}
            if entry.get("api_key") and entry.get("group_id"):
                return entry["api_key"], entry["group_id"]

    sys.exit("❌ 没找到 MINIMAX_API_KEY + MINIMAX_GROUP_ID (查 ~/uat-video-composer/.vault/secrets.json::minimax_tts)")


def synth_one(text: str, dst: Path, voice: str) -> Path:
    api_key, group_id = resolve_minimax_creds()
    endpoint = f"https://api.minimaxi.com/v1/t2a_v2?GroupId={group_id}"
    r = requests.post(
        endpoint,
        headers={"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"},
        json={
            "model": MINIMAX_MODEL,
            "text": text,
            "stream": False,
            "voice_setting": {"voice_id": voice, "speed": 1.0, "vol": 1.0, "pitch": 0},
            "audio_setting": {"sample_rate": 32000, "bitrate": 128000, "format": "mp3"},
        },
        timeout=60,
    )
    r.raise_for_status()
    data = r.json()
    if "data" not in data or "audio" not in data["data"]:
        sys.exit(f"❌ MiniMax 合成失败: {json.dumps(data, ensure_ascii=False)[:300]}")
    audio_bytes = bytes.fromhex(data["data"]["audio"])
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_bytes(audio_bytes)
    return dst


def build_all() -> None:
    if not TEXT_DIR.exists(): sys.exit(f"❌ {TEXT_DIR} 不存在")
    profile = load_profile()
    voice = profile["voice"]["slug"]
    print(f">>> using profile from {AGENT_REPO} · voice={voice} (MiniMax {MINIMAX_MODEL})")
    for md in sorted(TEXT_DIR.glob("*.md")):
        text = md.read_text(encoding="utf-8").strip()
        if not text: continue
        out = AUDIO_DIR / f"{md.stem}.mp3"
        print(f">>> {md.name} → {out.name}")
        synth_one(text, out, voice=voice)
        print(f"    {out.stat().st_size // 1024} KB")


if __name__ == "__main__":
    build_all()
