#!/usr/bin/env bash
# triage.sh — summarize log noise into actionable bullets via MiMo
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../_lib/mimo_common.sh"

INPUT="${1:--}"
TEXT=$(read_input "$INPUT")

[[ -z "$TEXT" ]] && { echo "Empty input" >&2; exit 1; }

SYSTEM="You are a senior SRE log triage specialist. Convert raw log output into 5-7 actionable bullets. Each bullet must:
1. Start with a severity tag: [CRIT] for service-blocking, [WARN] for degraded, [INFO] for recurring patterns
2. Name the affected service / subsystem
3. Describe the issue in one sentence
4. Suggest the next investigative step or fix when obvious

Output bullets only, no preamble, no closing summary. Order by severity descending."

mimo_chat "$MIMO_MODEL" "$SYSTEM" "$TEXT"
