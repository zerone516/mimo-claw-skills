# mimo-claw-skills 🧰

[![CI](https://github.com/zerone516/mimo-claw-skills/actions/workflows/ci.yml/badge.svg)](https://github.com/zerone516/mimo-claw-skills/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![OpenClaw Skill Pack](https://img.shields.io/badge/OpenClaw-skill%20pack-7c3aed)](https://github.com/openclaw)
[![Powered by Xiaomi MiMo](https://img.shields.io/badge/powered%20by-Xiaomi%20MiMo%20V2.5-ff6700)](https://platform.xiaomimimo.com/)
[![Skills](https://img.shields.io/badge/skills-8-blueviolet)](skills/)


> A production-tested **OpenClaw skill pack** that wires Xiaomi MiMo V2.5 into eight high-frequency agent verbs. Drop the pack into `~/.openclaw/workspace/skills/` and your main agent immediately offloads cheap auxiliary work to MiMo, keeping its own context budget for hard reasoning.

[![MiMo](https://img.shields.io/badge/Powered%20by-Xiaomi%20MiMo%20V2.5-orange)](https://platform.xiaomimimo.com)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-skills-blue)](https://openclaw.ai)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## Why this exists

I run an autonomous OpenClaw assistant 24/7 on a hardened VPS. Looking at 30 days of token telemetry, **38% of all token spend went to auxiliary tasks** — log triage, code review on small diffs, regex generation, SQL drafting, doc summarize, translation. None of those need the main reasoning model.

The right pattern is *cost-tier delegation*: send the boilerplate to a focused, fit-for-purpose model and reserve the main agent for actual reasoning. MiMo V2.5 is the natural fit — it's bilingual ZH/EN, has `reasoning_content` traces for debugging, and the Token Plan endpoint is built for high-volume routing.

This pack ships eight verbs that cover ~80% of the daily auxiliary load.

## The Eight Verbs

| Verb | Purpose | Typical tokens / call |
|---|---|---:|
| 🩺 `triage` | Summarize log noise (fail2ban, syslog, journalctl) into actionable bullets | 4-8K |
| 🔍 `review` | Quick code review on a small diff (≤200 LOC) | 6-10K |
| 📝 `draft` | Draft a Telegram / Slack reply in operator's tone | 1-2K |
| 🧪 `regex` | Generate + verify a regex against test inputs | 3-5K |
| 🧠 `sql` | Generate / explain SQL against a schema fragment | 4-7K |
| 🌐 `translate` | ID/EN/ZH translation, 2-pass | 2-4K |
| 📋 `summarize` | Bullet summary of a doc, chat thread, or transcript | 4-8K |
| 🎤 `tts` | Short voice note generation (Telegram voice, reminders) | ~1K + audio |

Average daily mix on a single operator's workspace: **~3-4M tokens / day**. Across an OpenClaw user base of ~50 active operators, this is **~150-200M tokens / day**, or **~5B tokens / month**, all routed off the main reasoning model.

## Architecture

```
                ┌──────────────────────────┐
                │   Main Agent (Ica /      │
                │   user-defined)          │
                │   GPT-5 / Claude / Kiro  │
                └────────────┬─────────────┘
                             │ delegate
                             ▼
                ┌──────────────────────────┐
                │  mimo-claw-skills        │
                │  router (mimo.sh)        │
                │  — 8 verbs               │
                └────────────┬─────────────┘
                             │ HTTPS
                             ▼
                ┌──────────────────────────┐
                │  Xiaomi MiMo V2.5        │
                │  Instruct + Pro          │
                │  Token Plan endpoint     │
                └──────────────────────────┘
```

## Quick start

```bash
# 1. Install
git clone https://github.com/zerone516/mimo-claw-skills.git
cd mimo-claw-skills
cp -r skills/* ~/.openclaw/workspace/skills/

# 2. Configure
cp .env.example ~/.config/mimo/env
# edit ~/.config/mimo/env with your MIMO_API_KEY

# 3. Verify
bash skills/triage/mimo.sh ask "halo, kamu siapa?"

# 4. Use directly (CLI)
echo "$(tail -100 /var/log/syslog)" | bash skills/triage/triage.sh -
bash skills/review/review.sh < my-diff.patch
bash skills/draft/draft.sh "casual" "user nanya kapan deploy"
```

## Verb details

### 🩺 triage — log noise → actionable bullets

```bash
journalctl -u nginx -n 500 | bash skills/triage/triage.sh -
```

Routes through `mimo-v2.5` with a system prompt that prioritizes:
1. Errors that block service
2. Repeated patterns indicating systemic issues
3. Anything matching known incident signatures

Output: 5-7 bullets, each with severity tag.

### 🔍 review — code review on a small diff

```bash
git diff main..HEAD | bash skills/review/review.sh
```

Routes through `mimo-v2.5-pro` (reasoning model) to surface:
- Bugs / logic errors
- Security concerns (input validation, auth bypass)
- Style drift from project conventions
- Missing test coverage hints

### 📝 draft — Telegram / Slack reply in operator's tone

```bash
bash skills/draft/draft.sh casual "user complains login flow stuck on OAuth"
```

Three tone modes: `formal`, `casual`, `decline`. Each ships in 2-3 variants the operator can pick from.

### 🧪 regex — generate + verify a regex

```bash
bash skills/regex/regex.sh "match Indonesian phone numbers" "0812-3456-7890,+6281234567890,021-555-1234"
```

Pipeline: MiMo generates candidate → script tests against provided inputs → if any fail, MiMo refines → return verified regex.

### 🧠 sql — generate / explain SQL

```bash
echo "schema: users(id, email, created_at); orders(id, user_id, amount)" \
  | bash skills/sql/sql.sh "top 10 users by total spend in 2026"
```

Routes through `mimo-v2.5-pro` with schema-aware prompting.

### 🌐 translate — 2-pass ID/EN/ZH

```bash
bash skills/translate/translate.sh en "halo sayang, doc-nya udah dikirim ya"
bash skills/translate/translate.sh zh "Q2 OKR review tomorrow at 3pm"
```

### 📋 summarize — bullet summary

```bash
cat long-thread.md | bash skills/summarize/summarize.sh -
bash skills/summarize/summarize.sh README.md --max-bullets 5
```

### 🎤 tts — short voice note

```bash
bash skills/tts/tts.sh "Reminder: meeting jam 3 sore" default ./reminder.mp3
```

Outputs `.mp3` via MiMo TTS.

## Cost-aware delegation pattern

This is the core idea. Every skill in the pack follows the same pattern:

```bash
# Cheap: delegate boilerplate to MiMo
TRIAGED=$(bash skills/triage/triage.sh - < /var/log/syslog)

# Then: pass clean output to main agent for actual decisions
echo "$TRIAGED" | run-main-reasoning
```

Across 30 days of telemetry on my own workspace, this saved **~1.4M tokens / week** of main-agent context budget. That's roughly $40-60 / week on a top-tier model bill.

## Model routing matrix

| Verb | Default model | Why |
|---|---|---|
| triage | mimo-v2.5 | Pattern recognition, non-reasoning |
| review | mimo-v2.5-pro | Logic + security needs reasoning chain |
| draft | mimo-v2.5 | Tone matching is shallow |
| regex | mimo-v2.5-pro | Verification loop benefits from reasoning |
| sql | mimo-v2.5-pro | Schema-aware generation |
| translate | mimo-v2.5 | Native bilingual on instruct |
| summarize | mimo-v2.5 | Bulk text → bullets |
| tts | mimo-v2.5-tts | Audio output |

Override via `MIMO_MODEL` env var per-call.

## OpenClaw discovery

Each skill folder ships its own `SKILL.md` so OpenClaw auto-discovers all eight verbs:

```
skills/
├── triage/{SKILL.md, triage.sh}
├── review/{SKILL.md, review.sh}
├── draft/{SKILL.md, draft.sh}
├── regex/{SKILL.md, regex.sh}
├── sql/{SKILL.md, sql.sh}
├── translate/{SKILL.md, translate.sh}
├── summarize/{SKILL.md, summarize.sh}
└── tts/{SKILL.md, tts.sh}
```

After `cp -r skills/* ~/.openclaw/workspace/skills/`, the agent sees all eight as first-class tools.

## Roadmap

- [x] 8 production-tested verbs
- [x] Per-verb SKILL.md for OpenClaw discovery
- [x] Cost-aware delegation pattern documented
- [ ] Token usage logging to `~/.local/share/mimo/usage.json`
- [ ] Caching layer for repeated translations
- [ ] Streaming support for long summaries
- [ ] ClawHub registry submission
- [ ] Hindi + Vietnamese verb expansion

## Credits

Built for the [Xiaomi MiMo Orbit 100T](https://100t.xiaomimimo.com/) creator program.
Tested with [OpenClaw](https://openclaw.ai) v2026.5.7 in production for 30 days.

## License

MIT — fork, ship, share.
