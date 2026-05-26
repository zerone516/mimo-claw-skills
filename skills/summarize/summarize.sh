#!/usr/bin/env bash
# summarize.sh — bullet summary via MiMo
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../_lib/mimo_common.sh"

INPUT="${1:--}"
MAX_BULLETS=7
shift || true
while [[ $# -gt 0 ]]; do
    case "$1" in
        --max-bullets) MAX_BULLETS="$2"; shift 2;;
        *) shift;;
    esac
done

TEXT=$(read_input "$INPUT")
[[ -z "$TEXT" ]] && { echo "Empty input" >&2; exit 1; }

SYSTEM="Summarize the input in maximum $MAX_BULLETS bullet points. Each bullet captures a distinct key idea. Order by importance descending. Output bullets only, prefix '- ', no preamble."

mimo_chat "$MIMO_MODEL" "$SYSTEM" "$TEXT"
