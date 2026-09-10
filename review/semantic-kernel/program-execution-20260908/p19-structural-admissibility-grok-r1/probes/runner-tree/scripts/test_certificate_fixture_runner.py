#!/usr/bin/env python3
"""Regression tests for run_certificate_fixtures.py output directory safety.

Verifies:
1. Missing --out argument is refused before execution (exit code 2).
2. Attempting to overwrite historical evidence (e.g. agy-r5) is refused
   BEFORE execution (exit code 2) without mutating any file in that directory.
3. Supplying any non-empty existing directory is refused before execution.
4. Supplying an explicit fresh output directory is accepted.
"""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile


def sha256_dir(p: Path) -> dict:
    hashes = {}
    for f in sorted(p.glob("**/*")):
        if f.is_file():
            hashes[str(f.relative_to(p))] = hashlib.sha256(f.read_bytes()).hexdigest()
    return hashes


def test_missing_out(repo_root: Path, runner: Path):
    cmd = [sys.executable, str(runner)]
    proc = subprocess.run(cmd, cwd=repo_root, capture_output=True, text=True)
    assert proc.returncode != 0, f"Expected non-zero exit for missing --out, got {proc.returncode}"
    assert "required" in proc.stderr or "--out" in proc.stderr, f"Expected error about --out, got: {proc.stderr}"
    print("PASS: Missing --out argument refused before execution.")


def test_historical_overwrite_refused(repo_root: Path, runner: Path):
    historical_dir = repo_root / "review/semantic-kernel/certificates/p19/implementation/agy-r5"
    assert historical_dir.is_dir(), f"Historical directory {historical_dir} does not exist"
    
    hashes_before = sha256_dir(historical_dir)
    assert len(hashes_before) > 0, f"Historical directory {historical_dir} is empty"

    cmd = [sys.executable, str(runner), "--out", str(historical_dir)]
    proc = subprocess.run(cmd, cwd=repo_root, capture_output=True, text=True)
    
    assert proc.returncode == 2, f"Expected exit code 2 for historical overwrite attempt, got {proc.returncode}"
    assert "Refusing to overwrite existing output path" in proc.stderr, f"Unexpected stderr: {proc.stderr}"

    hashes_after = sha256_dir(historical_dir)
    assert hashes_before == hashes_after, "Historical evidence in agy-r5 was mutated despite refusal!"
    print("PASS: Historical overwrite refused before execution without any file mutations.")


def test_nonempty_dir_refused(repo_root: Path, runner: Path):
    with tempfile.TemporaryDirectory() as tmpdir:
        dummy_dir = Path(tmpdir) / "existing_dir"
        dummy_dir.mkdir()
        dummy_file = dummy_dir / "existing_file.txt"
        dummy_file.write_text("historical content\n")
        
        file_sha_before = hashlib.sha256(dummy_file.read_bytes()).hexdigest()

        cmd = [sys.executable, str(runner), "--out", str(dummy_dir)]
        proc = subprocess.run(cmd, cwd=repo_root, capture_output=True, text=True)

        assert proc.returncode == 2, f"Expected exit code 2 for existing non-empty directory, got {proc.returncode}"
        assert "Refusing to overwrite existing output path" in proc.stderr, f"Unexpected stderr: {proc.stderr}"

        file_sha_after = hashlib.sha256(dummy_file.read_bytes()).hexdigest()
        assert file_sha_before == file_sha_after, "File in existing directory was mutated!"
    print("PASS: Existing non-empty directory refused before execution without mutation.")


def test_symlink_dir_refused(repo_root: Path, runner: Path):
    with tempfile.TemporaryDirectory() as tmpdir:
        real_dir = Path(tmpdir) / "real_dir"
        real_dir.mkdir()
        sentinel = real_dir / "sentinel.txt"
        sentinel.write_text("sentinel data\n")
        sentinel_hash = hashlib.sha256(sentinel.read_bytes()).hexdigest()

        symlink_path = Path(tmpdir) / "symlink_dir"
        symlink_path.symlink_to(real_dir)

        cmd = [sys.executable, str(runner), "--out", str(symlink_path)]
        proc = subprocess.run(cmd, cwd=repo_root, capture_output=True, text=True)

        assert proc.returncode == 2, f"Expected exit code 2 for symlink directory, got {proc.returncode}"
        assert "Refusing output path because it is a symlink" in proc.stderr, f"Unexpected stderr: {proc.stderr}"
        assert hashlib.sha256(sentinel.read_bytes()).hexdigest() == sentinel_hash, "Sentinel file mutated!"
        assert not (real_dir / "fixture-results.json").exists(), "Runner wrote files to symlinked dir!"
    print("PASS: Symlink directory refused before execution with sentinel check.")


def test_broken_symlink_refused(repo_root: Path, runner: Path):
    with tempfile.TemporaryDirectory() as tmpdir:
        nonexistent_target = Path(tmpdir) / "nonexistent_target"
        broken_symlink = Path(tmpdir) / "broken_symlink"
        broken_symlink.symlink_to(nonexistent_target)

        cmd = [sys.executable, str(runner), "--out", str(broken_symlink)]
        proc = subprocess.run(cmd, cwd=repo_root, capture_output=True, text=True)

        assert proc.returncode == 2, f"Expected exit code 2 for broken symlink, got {proc.returncode}"
        assert "Refusing output path because it is a symlink" in proc.stderr, f"Unexpected stderr: {proc.stderr}"
        assert not nonexistent_target.exists(), "Nonexistent target was created despite broken symlink!"
    print("PASS: Broken symlink refused before execution with no target creation.")


def test_relative_symlink_refused(repo_root: Path, runner: Path):
    with tempfile.TemporaryDirectory(dir=repo_root) as tmpdir:
        tmp_path = Path(tmpdir)
        real_dir = tmp_path / "real_rel_dir"
        real_dir.mkdir()
        sentinel = real_dir / "sentinel.txt"
        sentinel_payload = "live_relative_symlink_sentinel_content_p19"
        sentinel.write_text(sentinel_payload, encoding="utf-8")

        symlink_path = tmp_path / "symlink_rel"
        # Create a genuinely relative symlink pointing to sibling "real_rel_dir"
        symlink_path.symlink_to("real_rel_dir")

        # Verify symlink is live, relative, and resolves correctly before invocation
        assert symlink_path.is_symlink(), "Expected symlink_path to be a symlink"
        assert os.readlink(symlink_path) == "real_rel_dir", f"Expected relative symlink target 'real_rel_dir', got {os.readlink(symlink_path)}"
        assert symlink_path.resolve() == real_dir.resolve(), "Expected relative symlink to resolve to real_dir"
        assert symlink_path.exists(), "Expected relative symlink to be live (target exists)"
        assert (symlink_path / "sentinel.txt").read_text(encoding="utf-8") == sentinel_payload, "Sentinel must be readable through symlink"

        # Test runner refusal on relative path argument
        rel_arg = symlink_path.relative_to(repo_root)
        cmd_rel = [sys.executable, str(runner), "--out", str(rel_arg)]
        proc_rel = subprocess.run(cmd_rel, cwd=repo_root, capture_output=True, text=True)

        assert proc_rel.returncode == 2, f"Expected exit code 2 for relative symlink, got {proc_rel.returncode}\nStderr: {proc_rel.stderr}"
        assert "Refusing output path because it is a symlink" in proc_rel.stderr, f"Unexpected stderr: {proc_rel.stderr}"
        assert sentinel.read_text(encoding="utf-8") == sentinel_payload, "Target sentinel was modified despite refusal!"
        assert not (real_dir / "fixture-results.json").exists(), "Target directory was written to despite refusal!"

        # Test runner refusal on absolute path argument
        cmd_abs = [sys.executable, str(runner), "--out", str(symlink_path)]
        proc_abs = subprocess.run(cmd_abs, cwd=repo_root, capture_output=True, text=True)

        assert proc_abs.returncode == 2, f"Expected exit code 2 for absolute symlink to relative target, got {proc_abs.returncode}"
        assert "Refusing output path because it is a symlink" in proc_abs.stderr, f"Unexpected stderr: {proc_abs.stderr}"
        assert sentinel.read_text(encoding="utf-8") == sentinel_payload, "Target sentinel was modified despite refusal!"
    print("PASS: Live relative symlink refused before execution with target and sentinel preserved.")


def test_fresh_path_accepted(repo_root: Path, runner: Path):
    with tempfile.TemporaryDirectory() as tmpdir:
        fresh_out = Path(tmpdir) / "fresh_out_dir"
        assert not fresh_out.exists()

        # Test targeted fixture F01 on fresh directory
        cmd = [sys.executable, str(runner), "--out", str(fresh_out), "--fixture", "F01"]
        proc = subprocess.run(cmd, cwd=repo_root, capture_output=True, text=True)

        assert proc.returncode == 0, f"Expected exit code 0 for fresh path with F01, got {proc.returncode}\nStdout: {proc.stdout}\nStderr: {proc.stderr}"
        assert fresh_out.is_dir(), "Fresh output directory was not created"
        assert (fresh_out / "fixture-results.json").is_file(), "fixture-results.json was not created in fresh directory"
        assert (fresh_out / "compiler-axiom-audit.log").is_file(), "compiler-axiom-audit.log was not created in fresh directory"
        assert (fresh_out / "scenario-results.json").is_file(), "scenario-results.json was not created in fresh directory"
    print("PASS: Explicit fresh output path accepted and executed properly.")


def main():
    repo_root = Path(__file__).resolve().parent.parent
    runner = repo_root / "scripts/run_certificate_fixtures.py"
    assert runner.is_file(), f"Runner {runner} not found"

    print("Running fixture runner output safety regressions...")
    test_missing_out(repo_root, runner)
    test_historical_overwrite_refused(repo_root, runner)
    test_nonempty_dir_refused(repo_root, runner)
    test_symlink_dir_refused(repo_root, runner)
    test_broken_symlink_refused(repo_root, runner)
    test_relative_symlink_refused(repo_root, runner)
    test_fresh_path_accepted(repo_root, runner)
    print("\nALL FIXTURE RUNNER OUTPUT SAFETY REGRESSIONS PASSED.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
