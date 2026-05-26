# Contributing

Thanks for considering a contribution.

## Getting started

```bash
git clone https://github.com/zerone516/mimo-claw-skills.git
cd mimo-claw-skills

# Configure MiMo credentials
cp .env.example .env
# Edit .env with your MIMO_API_KEY

# Symlink or copy skills/ into your OpenClaw workspace
ln -s "$(pwd)/skills"/* ~/.openclaw/workspace/skills/

# Test a single skill standalone
bash skills/triage/triage.sh < /var/log/syslog | head
```

## Adding a new skill

1. Create `skills/<verb>/` with two files:
   - `SKILL.md` — OpenClaw discovery manifest (frontmatter + body)
   - `<verb>.sh` — POSIX bash entrypoint sourcing `_lib/mimo_common.sh`
2. Add a smoke test or example in `examples/<verb>/`
3. Update `README.md` with the new verb
4. Open a PR

## Pull request workflow

1. Fork and branch from `main`
2. `bash -n skills/<verb>/<verb>.sh` (syntax check)
3. `shellcheck skills/<verb>/<verb>.sh` (style)
4. Open a PR with description + sample input/output

## Reporting issues

Open a GitHub issue with reproduction steps, expected vs actual output, and your environment.
