---
name: mimo-triage
description: Summarize log noise (fail2ban, syslog, journalctl) into 5-7 actionable bullets via Xiaomi MiMo V2.5. Use when the operator pipes raw log output and needs to know what's actually wrong before the main agent decides whether to act. Cheap delegation — saves main-model context budget on systemd / nginx / cron / fail2ban floods.
---

# mimo-triage 🩺

Log triage skill — converts log noise into actionable bullets.

## When to use

- Operator pastes a wall of `journalctl` / `syslog` / `fail2ban.log` output
- Cron job fires "anything in the logs?" heartbeat scan
- Post-incident review needs noise summarized before reasoning

Skip when:
- Logs already structured (JSON / parsed) — feed to main agent directly
- Single error message — main agent handles it inline

## Setup

```bash
export MIMO_API_KEY=***
# (or in ~/.config/mimo/env)
```

## Usage

```bash
# From a log file
bash triage.sh /var/log/syslog

# From stdin
journalctl -u nginx -n 500 | bash triage.sh -

# Inline
bash triage.sh "$(tail -100 /var/log/auth.log)"
```

## Output format

5-7 bullets, each tagged with severity:
- `[CRIT]` — service-blocking
- `[WARN]` — degraded but running
- `[INFO]` — recurring patterns worth knowing about

## Cost-aware pattern

```bash
TRIAGED=$(journalctl -u nginx -n 500 | bash triage.sh -)
echo "$TRIAGED" | run-main-reasoning  # main agent decides action
```
