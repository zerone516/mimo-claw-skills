"""Smoke tests for mimo_common.sh helpers — invoked via bash subprocess."""
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LIB = ROOT / "skills" / "_lib" / "mimo_common.sh"


def test_lib_exists():
    assert LIB.exists()


def test_lib_syntax_ok():
    r = subprocess.run(["bash", "-n", str(LIB)], capture_output=True, text=True)
    assert r.returncode == 0, r.stderr


def test_eight_skills_present():
    skills = [d for d in (ROOT / "skills").iterdir() if d.is_dir() and not d.name.startswith("_")]
    assert len(skills) == 8, f"Expected 8 skills, got {[s.name for s in skills]}"


def test_each_skill_has_manifest_and_entrypoint():
    skills_dir = ROOT / "skills"
    for d in skills_dir.iterdir():
        if not d.is_dir() or d.name.startswith("_"):
            continue
        assert (d / "SKILL.md").exists(), f"Missing SKILL.md in {d.name}"
        sh = d / f"{d.name}.sh"
        assert sh.exists(), f"Missing {d.name}.sh in {d.name}"


def test_all_skill_scripts_syntax_ok():
    skills_dir = ROOT / "skills"
    for d in skills_dir.iterdir():
        if not d.is_dir() or d.name.startswith("_"):
            continue
        sh = d / f"{d.name}.sh"
        if sh.exists():
            r = subprocess.run(["bash", "-n", str(sh)], capture_output=True, text=True)
            assert r.returncode == 0, f"{d.name}.sh: {r.stderr}"
