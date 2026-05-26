# mimo-claw-skills — Production Deploy

## Drop into OpenClaw workspace

```bash
git clone https://github.com/zerone516/mimo-claw-skills.git
cd mimo-claw-skills
cp .env.example .env
# Edit .env with MIMO_API_KEY

# Symlink each skill into the OpenClaw workspace
for s in skills/*/; do
    name=$(basename "$s")
    ln -sf "$(pwd)/$s" ~/.openclaw/workspace/skills/$name
done

# Reload OpenClaw to pick up skills
openclaw reload-skills
```

## Verify

```bash
openclaw skills list | grep -E "(triage|summarize|translate|draft|review|regex|sql|tts)"
```

Should show all 8 skills auto-discovered.

## Per-skill smoke test

```bash
echo "fail2ban[1234]: Found 192.0.2.1" | bash skills/triage/triage.sh
```

## Update workflow

```bash
cd ~/repos/mimo-claw-skills
git pull
# Symlinks already point to the repo, so changes take effect on next call
```

## Routing matrix

The pack auto-routes verb → MiMo tier:

| Verb        | Default model    | Why |
|---|---|---|
| triage      | mimo-v2.5-flash  | Fast, low complexity |
| summarize   | mimo-v2.5-flash  | High volume |
| translate   | mimo-v2.5-flash  | Single pass adequate |
| draft       | mimo-v2.5-flash  | Tone match, not reasoning |
| review      | mimo-v2.5-pro    | Multi-step reasoning needed |
| regex       | mimo-v2.5-pro    | Verification + auto-refine |
| sql         | mimo-v2.5-pro    | Schema-aware reasoning |
| tts         | mimo-tts-v1      | Voice generation |

Override per call:

```bash
MIMO_MODEL=mimo-v2.5-pro bash skills/triage/triage.sh < /var/log/syslog
```

## Telemetry export

Each invocation appends to `~/.mimo-skills/telemetry.jsonl`:

```bash
jq -s 'group_by(.skill) | map({skill: .[0].skill, calls: length, tokens: (map(.tokens) | add)})' ~/.mimo-skills/telemetry.jsonl
```
