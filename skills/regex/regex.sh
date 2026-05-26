#!/usr/bin/env bash
# regex.sh — generate + verify regex via MiMo V2.5 Pro
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../_lib/mimo_common.sh"

DESC="${1:?Usage: regex.sh <description> <comma_separated_inputs>}"
INPUTS_RAW="${2:?Usage: regex.sh <description> <comma_separated_inputs>}"

IFS=',' read -ra INPUTS <<< "$INPUTS_RAW"

generate_regex() {
    local feedback="${1:-}"
    SYSTEM="You generate POSIX extended regex (grep -E compatible). Output ONLY the regex pattern, no explanation, no anchors unless required, no slashes."
    USER_MSG="Pattern requirement: $DESC

Test inputs (each line is one input that should match):
$(printf '%s\n' "${INPUTS[@]}")"
    [[ -n "$feedback" ]] && USER_MSG="$USER_MSG

Previous attempt feedback:
$feedback"
    mimo_chat "$MIMO_MODEL_PRO" "$SYSTEM" "$USER_MSG"
}

verify_regex() {
    local pattern="$1"
    local fails=()
    local results=""
    for inp in "${INPUTS[@]}"; do
        if echo "$inp" | grep -qE "$pattern"; then
            results+="  ✓ $inp"$'\n'
        else
            results+="  ✗ $inp"$'\n'
            fails+=("$inp")
        fi
    done
    echo "$results"
    [[ ${#fails[@]} -gt 0 ]] && return 1 || return 0
}

REGEX=$(generate_regex | tr -d '\r' | head -1)
echo "Pass 1 candidate: $REGEX"
RESULTS=$(verify_regex "$REGEX") || {
    echo "Refining..."
    REGEX=$(generate_regex "Failing inputs: ${RESULTS}" | tr -d '\r' | head -1)
    echo "Pass 2 candidate: $REGEX"
    RESULTS=$(verify_regex "$REGEX")
}
echo ""
echo "Regex: $REGEX"
echo "Tested against ${#INPUTS[@]} inputs:"
echo "$RESULTS"
