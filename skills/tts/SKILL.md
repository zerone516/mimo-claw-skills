---
name: mimo-tts
description: Generate short voice notes via Xiaomi MiMo V2.5 TTS. Use for Telegram voice replies, reminders, audio confirmations. Output is .mp3 file.
---

# mimo-tts 🎤

Short voice note generation via MiMo TTS.

## Usage

```bash
bash tts.sh "Reminder: meeting jam 3 sore" default ./reminder.mp3
bash tts.sh "Halo sayang, mining udah berhenti ya" voice-id-1 ./out.mp3
```

Args: text, voice (default / voice-id-1 / voice-id-2 / etc), output path.
