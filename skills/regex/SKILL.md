---
name: mimo-regex
description: Generate + verify a regex against test inputs via Xiaomi MiMo V2.5 Pro. Pipeline auto-refines if any test input fails. Use when the operator describes a pattern they need to match (phone numbers, log lines, structured IDs) and has a few example strings to verify against.
---

# mimo-regex 🧪

Regex generator with verification loop.

## When to use

- "I need a regex that matches X" with 3-10 example inputs
- Cleaning up a regex that almost works but fails on edge cases

Skip when:
- Inputs are too varied to characterize — use a parser instead
- Pattern needs lookbehind / non-regular constructs — main agent handles it

## Usage

```bash
bash regex.sh "match Indonesian phone numbers" "0812-3456-7890,+6281234567890,021-555-1234"
bash regex.sh "match nginx error log timestamp" "2026/05/26 10:23:45 [error]"
```

First arg: description. Second arg: comma-separated test inputs.

## Pipeline

1. MiMo Pro generates a candidate regex
2. Script tests each input via `grep -E`
3. If any input fails, MiMo refines with the failing inputs as context
4. Returns verified regex + test results

## Output

```
Regex: ^(\+62|0)8[1-9]\d{1,2}[-]?\d{4}[-]?\d{4}$
Tested against 3 inputs:
  ✓ 0812-3456-7890
  ✓ +6281234567890
  ✗ 021-555-1234 (intentional non-match — landline)
```
