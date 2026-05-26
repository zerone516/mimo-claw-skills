# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- pytest smoke tests for skill manifests + bash syntax
- GitHub Actions CI: shellcheck + smoke tests
- Badges in README (CI, license, OpenClaw-compatible, MiMo-powered)
- CONTRIBUTING.md with PR workflow

## [0.1.0] - 2026-05-26

### Added
- 8 skill folders: triage, summarize, translate, draft, review, regex, sql, tts
- Shared `_lib/mimo_common.sh` with retry + jq + env loading
- 30-day production telemetry in `docs/REAL_RUN.md`
- Architecture diagram in `docs/ARCHITECTURE.md`
- MiMo Orbit 100T application draft in `docs/MIMO_APPLICATION.md`
- OpenClaw-compatible SKILL.md per skill
