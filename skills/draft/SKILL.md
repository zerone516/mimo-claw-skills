---
name: mimo-draft
description: Draft a Telegram / Slack / email reply in the operator's tone (formal, casual, or polite decline) via Xiaomi MiMo V2.5. Returns 2-3 variants. Use when the operator forwards a customer message or team thread and needs a tonally-correct draft fast.
---

# mimo-draft 📝

Reply drafting skill — produces 2-3 variants in operator's tone.

## When to use

- Customer support reply where tone matters more than content
- Internal Slack reply that needs to land politely
- Decline message (sponsor request, scope creep) that needs to stay professional

Skip when:
- Reply needs deep reasoning about substance — main agent drafts it
- Reply must reference internal data — main agent has the context

## Usage

```bash
bash draft.sh casual "user nanya kapan deploy"
bash draft.sh formal "vendor minta extension 2 weeks"
bash draft.sh decline "sponsor minta exclusive untuk vertical X"
```

## Tones

- `casual` — friendly, lowercase, low-formality, includes contractions
- `formal` — full sentences, professional register, no slang
- `decline` — polite refusal, offers alternative when possible

## Output

Three variants, separated by `---`. Operator picks one and sends.
