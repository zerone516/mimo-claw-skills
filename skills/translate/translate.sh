#!/usr/bin/env bash
# translate.sh — 2-pass ID/EN/ZH translation via MiMo
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../_lib/mimo_common.sh"

TARGET="${1:?Usage: translate.sh <id|en|zh> <text>}"
TEXT="${2:?Usage: translate.sh <id|en|zh> <text>}"

case "$TARGET" in
    id) TGT="Indonesian";;
    en) TGT="English";;
    zh) TGT="Chinese (Simplified)";;
    *) echo "Unknown target: $TARGET. Use id / en / zh." >&2; exit 1;;
esac

# Pass 1 — literal
LITERAL=$(mimo_chat "$MIMO_MODEL" \
    "Translate to $TGT. Literal pass: preserve exact meaning. Output translation only, no commentary." \
    "$TEXT")

# Pass 2 — idiomatic
mimo_chat "$MIMO_MODEL" \
    "You are an idiomatic $TGT editor. Rewrite the literal translation below to read naturally to a native $TGT speaker. Keep meaning identical. Output rewritten text only." \
    "Source:
$TEXT

Literal:
$LITERAL"
