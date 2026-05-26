#!/usr/bin/env bash
# review.sh — code review a small diff via MiMo V2.5 Pro
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../_lib/mimo_common.sh"

INPUT="${1:--}"
DIFF=$(read_input "$INPUT")

[[ -z "$DIFF" ]] && { echo "Empty diff" >&2; exit 1; }

LINES=$(echo "$DIFF" | wc -l)
if [[ "$LINES" -gt 1000 ]]; then
    echo "WARN: diff is $LINES lines, this skill is tuned for <200 LOC. Output may be shallow." >&2
fi

SYSTEM="You are a senior staff engineer reviewing a code diff. Output four sections in this exact order, using ## headers:

## Bugs
List logic errors, off-by-one, null deref candidates. Empty section if none — write 'None spotted.'

## Security
List input validation gaps, auth bypass, injection vectors. Empty section if none — write 'None spotted.'

## Style
List drift from common conventions (naming, error handling, async patterns). Empty section if none — write 'None spotted.'

## Test coverage
List missing edge cases worth testing.

For each finding, cite the file path + line number from the diff hunks. Be concise — one or two sentences per finding."

mimo_chat "$MIMO_MODEL_PRO" "$SYSTEM" "$DIFF"
