# Architecture

## Skill pack design

Each skill is a self-contained directory with two files:
- `SKILL.md` — OpenClaw discovery manifest
- `<verb>.sh` — POSIX bash entrypoint

All skills share `_lib/mimo_common.sh` which provides:
- Env loading from `~/.config/mimo/env` or process env
- `mimo_chat` helper (curl + retry + jq)
- `mimo_tts` helper for audio output
- `read_input` helper (file / stdin / inline arg)

## Why bash, not Python

OpenClaw skills are auto-discovered by scanning for `SKILL.md`. The runtime is language-agnostic, but bash has zero install cost and integrates with shell pipelines naturally. For ops work — log triage, diff review, draft replies — pipelines win.

```bash
# Trivially composable
journalctl -u nginx -n 500 \
  | bash skills/triage/triage.sh - \
  | bash skills/draft/draft.sh formal "incident report"
```

## Token routing matrix

| Verb | Default model | Reasoning |
|---|---|---|
| triage | mimo-v2.5 | Pattern recognition, no chain-of-thought needed |
| review | mimo-v2.5-pro | Logic + security needs reasoning |
| draft | mimo-v2.5 | Tone matching is shallow |
| regex | mimo-v2.5-pro | Verification loop benefits from reasoning |
| sql | mimo-v2.5-pro | Schema-aware generation |
| translate | mimo-v2.5 | Native bilingual on instruct tier |
| summarize | mimo-v2.5 | Bulk text → bullets |
| tts | mimo-v2.5-tts | Audio output |

This split is what makes the pack cost-aware. Pro tier only fires when reasoning is genuinely needed (review, regex, sql). Everything else uses the cheaper instruct tier.

## Verification loop pattern (regex)

The `regex` verb is the pack's most novel piece. It's the only one that runs a verification loop:

```
generate candidate
   │
   ▼
run grep -E against test inputs
   │
   ├── all pass → return
   │
   └── any fail → feed failing inputs back to MiMo
                 │
                 ▼
              refined candidate (max 1 retry)
                 │
                 ▼
              return verified or best-effort regex
```

This is a 2-call loop. Costs ~6-10K tokens but produces a regex you can actually trust.

## Token telemetry

Each skill writes a JSONL line to `~/.local/share/mimo/usage.jsonl` per call (when `MIMO_USAGE_LOG=1`):

```json
{"ts": "2026-05-26T02:00:00Z", "verb": "triage", "model": "mimo-v2.5", "tokens_in": 4012, "tokens_out": 320, "duration_ms": 2100}
```

Aggregate via:
```bash
jq -s 'group_by(.verb) | map({verb: .[0].verb, calls: length, tokens: (map(.tokens_in + .tokens_out) | add)})' \
  ~/.local/share/mimo/usage.jsonl
```

## Failure modes

| Failure | Mitigation |
|---|---|
| 401 | Hard fail — script exits with clear "MIMO_API_KEY not set" message |
| 429 | curl retries 3x with exponential backoff (2s, 4s, 8s) |
| 5xx | curl retries 3x; if all fail, returns `.error.message` from response |
| Empty input | Each script checks and exits 1 with clear message |
| Diff > 200 LOC | review.sh prints WARN to stderr but continues |
| Regex 0% pass after refine | Returns best-effort regex with test results showing fails |
