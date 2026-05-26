---
name: mimo-translate
description: 2-pass ID/EN/ZH translation via Xiaomi MiMo V2.5 (native bilingual). First pass literal, second pass idiomatic rewrite. Use when the operator needs a quick translation that reads naturally to a native speaker, not just word-for-word.
---

# mimo-translate 🌐

2-pass translation skill — Indonesian, English, Chinese.

## When to use

- Quick translation between ID / EN / ZH
- Operator types in one language, downstream tool wants another

Skip when:
- High-stakes legal / medical translation — use a specialist
- Need 3-pass review for accuracy — use mimo-multilang-bridge instead

## Usage

```bash
bash translate.sh en "halo sayang, doc-nya udah dikirim ya"
bash translate.sh zh "Q2 OKR review tomorrow at 3pm"
bash translate.sh id "The vendor's onboarding doc is 40 pages long"
```

First arg: target language (id / en / zh).
Second arg: source text.

## Pipeline

1. **Pass 1** — literal translation at temperature 0.0
2. **Pass 2** — idiomatic rewrite at temperature 0.4

Output: rewritten text only.
