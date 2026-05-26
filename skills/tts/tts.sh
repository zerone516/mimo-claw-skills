#!/usr/bin/env bash
# tts.sh — generate voice note via MiMo TTS
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../_lib/mimo_common.sh"

TEXT="${1:?Usage: tts.sh <text> <voice> <output_path>}"
VOICE="${2:-default}"
OUTPUT="${3:?Usage: tts.sh <text> <voice> <output_path>}"

mimo_tts "$TEXT" "$VOICE" "$OUTPUT"
