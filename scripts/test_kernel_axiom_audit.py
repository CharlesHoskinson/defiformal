#!/usr/bin/env python3
"""Replay the real Lean axiom command against isolated imported fixture modules.

Run from any directory. Outputs, copied audit source, fixtures, command records,
tool identity, and source hashes go to a new directory outside the repository.
Exit 0 means every behavioral assertion passed; exit 1 means a test failed.
An invocation/setup error exits 3. Lean itself uses exit 1 for both forbidden
axioms and empty scope; tests distinguish their exact diagnostics.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, help="new evidence directory outside the repository")
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    lean_root = repo / "lean"
    output = args.output.resolve() if args.output else Path(tempfile.mkdtemp(prefix="kernel-axioms-"))
    if output == repo or repo in output.parents:
        raise RuntimeError("Evidence directory must be outside the repository")
    if args.output:
        output.mkdir(parents=True, exist_ok=False)
    fixture_root = output / "fixtures"
    (fixture_root / "DefiKernel").mkdir(parents=True)
    helper = lean_root / "DefiKernel/AxiomAudit.lean"
    inputs = [helper, lean_root / "lean-toolchain", lean_root / "lake-manifest.json",
              Path(__file__).resolve()]
    source_before = {str(p.relative_to(repo)): digest(p) for p in inputs}
    shutil.copyfile(helper, fixture_root / "DefiKernel/AxiomAudit.lean")
    records = []
    assertions = []
    git_head = None
    dirty_before = {}
    executable_sha256 = None

    def run(label, command, cwd, env=None):
        result = subprocess.run(command, cwd=cwd, env=env, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=120)
        log = output / f"{label}.log"
        log.write_text(result.stdout)
        records.append({"label": label, "command": command, "cwd": str(cwd),
                        "LEAN_PATH": env.get("LEAN_PATH") if env else None,
                        "exit": result.returncode, "log": log.name})
        return result

    def check(label, condition):
        assertions.append({"assertion": label, "passed": bool(condition)})
        if not condition:
            raise AssertionError(label)

    def messages(result):
        return [json.loads(line) for line in result.stdout.splitlines() if line.strip()]

    try:
        check("copied helper matches source captured before execution",
              digest(fixture_root / "DefiKernel/AxiomAudit.lean") ==
              source_before["lean/DefiKernel/AxiomAudit.lean"])
        head = run("git-head", ["git", "rev-parse", "HEAD"], repo)
        check("git revision recorded", head.returncode == 0)
        git_head = head.stdout.strip()
        for index, path in enumerate(inputs):
            relative = str(path.relative_to(repo))
            dirty = run(f"git-input-{index}",
                        ["git", "status", "--porcelain", "--untracked-files=all", "--", relative], repo)
            check(f"input {relative}: dirty state recorded", dirty.returncode == 0)
            dirty_before[relative] = dirty.stdout
        tool = run("lean-path", ["lake", "env", "which", "lean"], lean_root)
        check("pinned executable resolved", tool.returncode == 0)
        lean = tool.stdout.strip()
        check("pinned executable exists", Path(lean).is_file())
        executable_sha256 = digest(Path(lean))
        version = run("lean-version", [lean, "--version"], lean_root)
        check("tool identity recorded", version.returncode == 0)
        env = dict(os.environ, LEAN_PATH=str(fixture_root))

        def compile_module(label, module):
            path = fixture_root / (module.replace(".", "/") + ".lean")
            result = run(label, [lean, "--json", "-o", str(path.with_suffix(".olean")),
                                 str(path)], fixture_root, env)
            check(f"{label}: module compiles", result.returncode == 0)
            check(f"{label}: no compiler errors", all(m["severity"] != "error" for m in messages(result)))

        def audit(label, scope="DefiKernel.AuditProbe"):
            runner = fixture_root / "RunAudit.lean"
            runner.write_text("import DefiKernel.AxiomAudit\nimport DefiKernel.AuditProbe\n"
                              f"#audit_axioms {scope}\n")
            shutil.copyfile(runner, output / f"{label}.lean")
            return run(label, [lean, "--json", str(runner)], fixture_root, env)

        def theorem_lines(result):
            return [m["data"] for m in messages(result)
                    if m["data"].startswith("AXIOM AUDIT theorem:")]

        def has_message(result, severity, text):
            return any(m["severity"] == severity and m["data"] == text for m in messages(result))

        compile_module("build-helper", "DefiKernel.AxiomAudit")
        probe = fixture_root / "DefiKernel/AuditProbe.lean"
        probe.write_text("theorem OutsidePilotNamespace.control : True := True.intro\n")
        shutil.copyfile(probe, output / "control-source.lean")
        compile_module("build-control", "DefiKernel.AuditProbe")
        control = audit("control")
        check("control exits 0", control.returncode == 0)
        expected_control = ("AXIOM AUDIT theorem: OutsidePilotNamespace.control; "
                            "module=DefiKernel.AuditProbe; axioms=[]")
        check("module provenance selects theorem outside matching namespace",
              theorem_lines(control) == [expected_control])
        check("control exact success", has_message(control, "information",
              "AXIOM AUDIT PASSED: 1/1 theorems; forbidden=0"))

        with probe.open("a") as file:
            file.write("theorem AnotherNamespace.freshlyAdded : True := True.intro\n")
        shutil.copyfile(probe, output / "added-source.lean")
        compile_module("build-added", "DefiKernel.AuditProbe")
        added = audit("added")
        check("new theorem exits 0", added.returncode == 0)
        expected_added = ("AXIOM AUDIT theorem: AnotherNamespace.freshlyAdded; "
                          "module=DefiKernel.AuditProbe; axioms=[]")
        check("new theorem automatically discovered with unchanged command",
              set(theorem_lines(added)) == {expected_control, expected_added})
        check("new theorem exact count", has_message(added, "information",
              "AXIOM AUDIT PASSED: 2/2 theorems; forbidden=0"))
        check("command unchanged across addition",
              (output / "control.lean").read_bytes() == (output / "added.lean").read_bytes())

        dependency = fixture_root / "ForeignAssumptions.lean"
        probe.write_text("import ForeignAssumptions\n"
                         "theorem OutsidePilotNamespace.transitive : True := ForeignAssumptions.helper\n")
        shutil.copyfile(probe, output / "transitive-source.lean")
        for variant, seed in [("transitive-control", "theorem seed : True := True.intro"),
                              ("custom-axiom", "axiom seed : True"),
                              ("sorry-axiom", "theorem seed : True := by sorry")]:
            dependency.write_text("namespace ForeignAssumptions\n" + seed + "\n"
                                  "def helper : True := seed\nend ForeignAssumptions\n")
            shutil.copyfile(dependency, output / f"{variant}-dependency.lean")
            compile_module(f"build-{variant}-dependency", "ForeignAssumptions")
            compile_module(f"build-{variant}", "DefiKernel.AuditProbe")
            result = audit(variant)
            if variant == "transitive-control":
                check("transitive control exits 0", result.returncode == 0)
                check("transitive control exact success", has_message(result, "information",
                      "AXIOM AUDIT PASSED: 1/1 theorems; forbidden=0"))
            else:
                axiom = "ForeignAssumptions.seed" if variant == "custom-axiom" else "sorryAx"
                check(f"{variant}: exits 1", result.returncode == 1)
                check(f"{variant}: exact transitive dependency reported", theorem_lines(result) == [
                    "AXIOM AUDIT theorem: OutsidePilotNamespace.transitive; "
                    f"module=DefiKernel.AuditProbe; axioms=[{axiom}]"])
                check(f"{variant}: specific forbidden diagnostic", has_message(result, "error",
                      f"AXIOM AUDIT FORBIDDEN: OutsidePilotNamespace.transitive; axioms=[{axiom}]"))
                check(f"{variant}: exact rejection count", has_message(result, "error",
                      "AXIOM AUDIT FAILED: 1/1 theorems use forbidden axioms"))
                check(f"{variant}: no unrelated compiler error", all(
                    m["severity"] != "error" or m["data"].startswith("AXIOM AUDIT ")
                    for m in messages(result)))

        probe.write_text("def noTheoremsHere : Nat := 0\n")
        shutil.copyfile(probe, output / "empty-source.lean")
        compile_module("build-empty", "DefiKernel.AuditProbe")
        for label, scope in [("empty", "DefiKernel.AuditProbe"), ("missing", "UnimportedPilot")]:
            result = audit(label, scope)
            check(f"{label}: exits 1", result.returncode == 1)
            check(f"{label}: no theorem reports", theorem_lines(result) == [])
            check(f"{label}: specific blocked diagnostic", has_message(result, "error",
                  f"AXIOM AUDIT BLOCKED: empty theorem scope for imported module prefix {scope}; theorems=0"))
            check(f"{label}: no success diagnostic", not any(
                m["data"].startswith("AXIOM AUDIT PASSED:") for m in messages(result)))
        check("source inputs unchanged after execution",
              source_before == {str(p.relative_to(repo)): digest(p) for p in inputs})
        status = "passed"
    except AssertionError as error:
        status = f"failed: {error}"
    except (OSError, RuntimeError, subprocess.TimeoutExpired, ValueError, KeyError) as error:
        status = f"blocked: {error}"
    finally:
        report = {"status": status, "repository": str(repo), "git_head": git_head,
                  "input_dirty_state_before": dirty_before,
                  "source_sha256_before": source_before,
                  "source_sha256_after": {str(p.relative_to(repo)): digest(p) for p in inputs},
                  "lean_executable_sha256": executable_sha256,
                  "fixture_sha256": {str(p.relative_to(output)): digest(p)
                                     for p in output.rglob("*.lean")},
                  "assertions": assertions, "commands": records}
        (output / "results.json").write_text(json.dumps(report, indent=2) + "\n")
        print(f"{status}: {len(assertions)} assertions; evidence={output}")
    return 0 if status == "passed" else 3 if status.startswith("blocked:") else 1


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, RuntimeError) as error:
        print(f"blocked: {error}", file=sys.stderr)
        sys.exit(3)
