#!/usr/bin/env bash
# Common helpers sourced by all skill scripts in this pack.
set -euo pipefail

ENV_FILE="${MIMO_ENV_FILE:-$HOME/.config/mimo/env}"
[[ -f "$ENV_FILE" ]] && set -a && source "$ENV_FILE" && set +a

: "${MIMO_API_KEY:?MIMO_API_KEY not set in $ENV_FILE or environment}"
: "${MIMO_BASE_URL:=https://token-plan-sgp.xiaomimimo.com/v1}"
: "${MIMO_MODEL:=mimo-v2.5}"
: "${MIMO_MODEL_PRO:=mimo-v2.5-pro}"
: "${MIMO_TTS_MODEL:=mimo-v2.5-tts}"

mimo_chat() {
    # mimo_chat <model> <system> <user>
    local model="$1" system="$2" user="$3"
    local payload
    payload=$(jq -n \
        --arg model "$model" \
        --arg system "$system" \
        --arg user "$user" \
        '{model: $model, messages: [{role:"system",content:$system},{role:"user",content:$user}], temperature: 0.2}')

    local response
    for attempt in 1 2 3; do
        response=$(curl -sS -X POST "$MIMO_BASE_URL/chat/completions" \
            -H "Authorization: Bearer $MIMO_API_KEY" \
            -H "Content-Type: application/json" \
            --data-raw "$payload" \
            --max-time 120) && break
        sleep $((attempt * 2))
    done

    echo "$response" | jq -r '.choices[0].message.content // .error.message // "ERROR: empty response"'
}

mimo_tts() {
    # mimo_tts <text> <voice> <output_path>
    local text="$1" voice="${2:-default}" output="$3"
    local payload
    payload=$(jq -n \
        --arg model "$MIMO_TTS_MODEL" \
        --arg text "$text" \
        --arg voice "$voice" \
        '{model: $model, input: $text, voice: $voice, response_format: "mp3"}')

    curl -sS -X POST "$MIMO_BASE_URL/audio/speech" \
        -H "Authorization: Bearer $MIMO_API_KEY" \
        -H "Content-Type: application/json" \
        --data-raw "$payload" \
        --output "$output" \
        --max-time 120
    echo "Audio saved: $output"
}

read_input() {
    # Read from arg, file, or stdin
    if [[ "$1" == "-" ]]; then
        cat
    elif [[ -f "$1" ]]; then
        cat "$1"
    else
        echo "$1"
    fi
}
