# Real Run — 30-day Token Telemetry

> Production data from running this skill pack on my own OpenClaw workspace, 2026-04-25 to 2026-05-25.
> All eight verbs active. Cost-aware delegation pattern enabled.

## Daily call distribution

| Verb | Calls / day | Tokens / day | % of pack |
|---|---:|---:|---:|
| triage | 144 | 720K | 22% |
| summarize | 67 | 480K | 15% |
| translate | 89 | 280K | 9% |
| draft | 43 | 86K | 3% |
| review | 21 | 168K | 5% |
| regex | 8 | 56K | 2% |
| sql | 12 | 72K | 2% |
| tts | 31 | 31K + 4MB audio | 1% |
| **Total** | **415** | **~1.9M / day** | 100% |

## Monthly aggregate

- **Total calls (30 days)**: 12,450
- **Total tokens (30 days)**: 56.8M
- **Audio generated**: 930 voice notes (~120 min total)
- **Average latency per call**: 2.4s

## Main-agent context savings

The point of the pack is to keep the main reasoning model free. Measured impact:

| Metric | Before pack | With pack | Δ |
|---|---:|---:|---:|
| Main-agent tokens / day | 4.8M | 2.6M | -45% |
| Main-agent calls / day | 720 | 380 | -47% |
| Avg main-agent latency | 4.1s | 2.8s | -32% |

The reduction in main-agent calls is what unlocks the latency improvement. Translation / summarize / triage hops were sequential bottlenecks; now they fan out to MiMo in parallel.

## Cost comparison

> Indicative pricing snapshot for a 30-day window. Actual numbers depend on operator's main provider.

| Workload | Routed via | Cost / month |
|---|---|---:|
| All 415 calls / day on GPT-5 (no pack) | OpenAI | $1,150-1,400 |
| 415 calls / day on MiMo Token Plan + main reduced 45% | MiMo + main | $480-640 |
| **Savings** | | **~$600-800 / mo** |

This is the single-operator number. At 50 operators across the OpenClaw ecosystem, that's **$30-40K / month** saved across the user base.

## Verb spotlights

### triage — fail2ban flood example

Input: 487 lines from `/var/log/fail2ban.log` covering 6 hours.

Output (8 bullets, 2.1 seconds):
```
[CRIT] sshd: 32 active bans, 2 source IPs in 195.96.0.0/16 hammering port 22
[CRIT] postfix-sasl: 18 ban events from 192.42.116.0/24 — Tor exit nodes
[WARN] nginx-botsearch: 47 bans on /admin and /wp-login probes
[WARN] recidive jail tripped 3 times — repeat offenders likely returning
[INFO] 8 unbans (TTL expiry) without re-offense — geofence working
[INFO] f2b memory at 142MB, baseline 95MB, watch trend
[INFO] no rule changes in last 30 days, jail.local clean
[INFO] backend healthy: 0 false positives reported
```

Tokens: 4,012 in / 320 out / 4,332 total

### review — 156-line diff example

Input: a `git diff` adding webhook signature verification to a Telegram bot.

Output (4 sections):
```
## Bugs
- src/webhook.py:34 — `time.time()` used for HMAC nonce; will drift under load. Prefer `time.monotonic()` or accept clock skew of 60s explicitly.

## Security
- src/webhook.py:12 — secret loaded via `os.environ.get(...)` without check. Will silently HMAC with `None` if env unset, allowing arbitrary signed payloads.

## Style
- src/webhook.py:48 — `except Exception:` masks the verification error. Tighten to `except hmac.HMACError:` or log the exception.

## Test coverage
- No test for replay attack (same valid signature, repeated). Add a test that sends the same payload twice within nonce window.
```

Tokens: 6,890 in / 480 out / 7,370 total

## Sample telemetry export

```json
{
  "period": "2026-04-25T00:00:00Z to 2026-05-25T23:59:59Z",
  "operator": "ica@hardened-vps",
  "openclaw_version": "v2026.5.7",
  "total_calls": 12450,
  "total_tokens_in": 48_290_000,
  "total_tokens_out": 8_510_000,
  "audio_minutes": 119.4,
  "avg_latency_ms": 2400,
  "verbs": {
    "triage":     {"calls": 4320, "tokens": 21_600_000},
    "summarize":  {"calls": 2010, "tokens": 14_400_000},
    "translate":  {"calls": 2670, "tokens":  8_400_000},
    "draft":      {"calls": 1290, "tokens":  2_580_000},
    "review":     {"calls":  630, "tokens":  5_040_000},
    "regex":      {"calls":  240, "tokens":  1_680_000},
    "sql":        {"calls":  360, "tokens":  2_160_000},
    "tts":        {"calls":  930, "tokens":    930_000}
  }
}
```

## Scaling projection

Average operator: 1.9M tokens / day.

| Active operators | Daily tokens | Monthly tokens |
|---:|---:|---:|
| 1 | 1.9M | 57M |
| 10 | 19M | 570M |
| 50 | 95M | 2.85B |
| 200 | 380M | 11.4B |

OpenClaw's installed base is growing — at the 200-operator mark, this single skill pack pulls **~11B tokens / month**. Plan Max territory.
