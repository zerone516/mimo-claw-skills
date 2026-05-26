---
name: mimo-summarize
description: Bullet summary of a doc, chat thread, or transcript via Xiaomi MiMo V2.5. Configurable max-bullets (default 7). Use for daily standups, post-meeting recap, long thread digest.
---

# mimo-summarize 📋

Document / thread / transcript summarizer.

## Usage

```bash
bash summarize.sh README.md
cat slack-thread.txt | bash summarize.sh -
bash summarize.sh meeting.txt --max-bullets 5
```

## Output

Bullet summary, 5-7 by default, configurable via `--max-bullets`.
