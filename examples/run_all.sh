#!/usr/bin/env bash
# Example: invoke each skill with a sample input
# Usage: bash examples/run_all.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Source env if available
if [ -f .env ]; then
    set -a
    # shellcheck disable=SC1091
    . .env
    set +a
fi

echo "=== triage ==="
echo -e "fail2ban[1234]: Found 192.0.2.1\nfail2ban[1234]: Ban 192.0.2.1\nsystemd[1]: Started" | bash skills/triage/triage.sh
echo

echo "=== summarize ==="
echo "Long meeting notes about Q2 roadmap. Discussed token pricing, agent latency, and skill packaging. Action items: ship pack to ClawHub by week 6." | bash skills/summarize/summarize.sh --max-bullets 3
echo

echo "=== translate ==="
echo "Halo, gimana kabar lo hari ini?" | bash skills/translate/translate.sh --to en
echo

echo "=== draft ==="
echo "Tell user the deployment is delayed by 2 hours due to RPC issue, professional but warm" | bash skills/draft/draft.sh --tone warm-pro
echo

echo "=== regex ==="
echo "match Indonesian phone numbers starting with 08" | bash skills/regex/regex.sh
echo

echo "=== sql ==="
echo "show top 10 customers by total spend in 2026" | bash skills/sql/sql.sh --schema "customers(id,name), orders(customer_id, amount, created_at)"
echo

echo "=== summarize via stdin ==="
cat README.md | bash skills/summarize/summarize.sh --max-bullets 5
echo

echo "Done. Verb pack working end to end."
