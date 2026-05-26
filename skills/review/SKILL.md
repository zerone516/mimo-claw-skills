---
name: mimo-review
description: Quick code review on a small diff (≤200 LOC) via Xiaomi MiMo V2.5 Pro. Use when the operator pipes a `git diff` and wants bugs / security / style feedback before merge. Pro-tier reasoning chain surfaces logic errors and security issues; cheap enough to run on every PR pre-merge instead of waiting for human review.
---

# mimo-review 🔍

Code review skill on small diffs.

## When to use

- Pre-merge sanity check on a small PR
- Quick second-opinion on a diff before pushing
- CI-integrated review on every commit

Skip when:
- Diff > 200 LOC — chunk it or use a multi-pass reviewer
- Architecture-level review needs main-model reasoning

## Usage

```bash
# Pipe git diff
git diff main..HEAD | bash review.sh

# From a patch file
bash review.sh < my-feature.patch

# Inline
bash review.sh "$(git show HEAD)"
```

## Output sections

1. **Bugs** — logic errors, off-by-one, null deref candidates
2. **Security** — input validation, auth bypass, injection vectors
3. **Style** — drift from common conventions
4. **Test coverage** — missing edge cases worth testing

## Cost-aware pattern

```bash
REVIEW=$(git diff main..HEAD | bash review.sh)
[[ -n "$REVIEW" ]] && echo "$REVIEW" | tee review.md
# Main agent reads review.md and decides merge/block
```
