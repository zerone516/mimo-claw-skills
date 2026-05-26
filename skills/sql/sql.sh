#!/usr/bin/env bash
# sql.sh — generate or explain SQL via MiMo V2.5 Pro
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../_lib/mimo_common.sh"

if [[ "${1:-}" == "--explain" ]]; then
    QUERY="${2:?Usage: sql.sh --explain <query>}"
    SYSTEM="You explain SQL in plain English. Output 4-6 bullets, one per clause (SELECT, FROM, JOIN, WHERE, GROUP BY, ORDER BY, LIMIT). Be concise."
    mimo_chat "$MIMO_MODEL_PRO" "$SYSTEM" "$QUERY"
else
    NL="${1:?Usage: sql.sh <natural_language_query> (schema piped from stdin)}"
    SCHEMA=$(cat)
    [[ -z "$SCHEMA" ]] && { echo "No schema piped via stdin" >&2; exit 1; }
    SYSTEM="You generate SQL given a schema and a natural-language request. Output ONLY the SQL query, no explanation, no markdown fences. Use standard SQL (PostgreSQL flavor). Be precise about JOINs, NULL handling, and aggregation."
    mimo_chat "$MIMO_MODEL_PRO" "$SYSTEM" "Schema:
$SCHEMA

Request: $NL"
fi
