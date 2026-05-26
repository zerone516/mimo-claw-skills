#!/usr/bin/env bash
# draft.sh — generate 2-3 reply variants in chosen tone via MiMo
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../_lib/mimo_common.sh"

TONE="${1:?Usage: draft.sh <casual|formal|decline> <context>}"
CONTEXT="${2:?Usage: draft.sh <casual|formal|decline> <context>}"

case "$TONE" in
    casual) TONE_DESC="friendly, lowercase, low-formality, contractions allowed, max 2 short paragraphs";;
    formal) TONE_DESC="professional register, full sentences, no slang, max 2 paragraphs";;
    decline) TONE_DESC="polite refusal, acknowledge the ask, decline clearly, offer an alternative path when sensible";;
    *) echo "Unknown tone: $TONE. Use casual / formal / decline." >&2; exit 1;;
esac

SYSTEM="You are drafting a reply in $TONE tone ($TONE_DESC). Produce exactly 3 distinct variants. Separate variants with a line containing only '---'. No labels, no commentary. Each variant should be self-contained and sendable as-is."

mimo_chat "$MIMO_MODEL" "$SYSTEM" "Context: $CONTEXT"
