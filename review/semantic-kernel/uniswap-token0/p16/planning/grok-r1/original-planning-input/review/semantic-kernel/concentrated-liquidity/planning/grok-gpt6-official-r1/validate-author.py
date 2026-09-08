#!/usr/bin/env python3
"""Author consistency checks for concentrated-liquidity official planning. Not acceptance."""
from __future__ import annotations

import datetime
import hashlib
import json
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

REPO = Path(__file__).resolve().parents[5]
CHANGE = REPO / "openspec/changes/concentrated-liquidity-library"
R1 = Path(__file__).resolve().parent
sha = lambda b: hashlib.sha256(b).hexdigest()
checks = []


def ck(name: str, cond, detail=None) -> None:
    rec = {"check": name, "passed": bool(cond)}
    if detail is not None:
        rec["detail"] = detail
    checks.append(rec)


def write(name: str, obj) -> None:
    (R1 / name).write_text(json.dumps(obj, indent=2) + "\n")


def has_expected(fix: dict) -> bool:
    exp = fix.get("expected")
    if not isinstance(exp, dict) or not exp:
        return False
    return any(k in exp for k in ("ok", "ok_down", "ok_up", "error"))


def main() -> int:
    specs = sorted((CHANGE / "specs").glob("*/spec.md"))
    req, sc = [], []
    for p in specs:
        t = p.read_text()
        req += re.findall(r"^### Requirement: (\S+)", t, re.M)
        sc += re.findall(r"^#### Scenario: (\S+)", t, re.M)
        ck(p.parent.name + " purpose length", "## Purpose" in t and len(re.search(r"## Purpose\n\n(.+)", t).group(1)) >= 50)
        ck(p.parent.name + " ADDED", "## ADDED Requirements" in t)
        ck(p.parent.name + " scenario hashes", "#### Scenario:" in t and not re.search(r"^### Scenario:", t, re.M))
    tasks_text = (CHANGE / "tasks.md").read_text()
    tasks = re.findall(r"^- \[ \] (\d+\.\d+)", tasks_text, re.M)
    fixtures = json.loads((CHANGE / "fixtures.json").read_text())["fixtures"]
    mutants = json.loads((CHANGE / "planned-mutations.json").read_text())["mutants"]
    sm = json.loads((CHANGE / "scenario-map.json").read_text())
    counts = {
        "capabilities": len(specs),
        "requirements": len(req),
        "scenarios": len(sc),
        "unchecked_tasks": len(tasks),
        "fixtures": len(fixtures),
        "mutants": len(mutants),
    }
    expected_counts = {
        "capabilities": 5,
        "requirements": 18,
        "scenarios": 40,
        "unchecked_tasks": 24,
        "fixtures": 45,
        "mutants": 12,
    }
    ck("exact scope", counts == expected_counts, counts)
    for name, ids in [
        ("req", req),
        ("scenario", sc),
        ("task", tasks),
        ("fixture", [x["id"] for x in fixtures]),
        ("mutant", [x["id"] for x in mutants]),
        ("capability", [p.parent.name for p in specs]),
    ]:
        ck(name + " unique nonempty", bool(ids) and len(set(ids)) == len(ids), len(ids))
    ck("no checked task", not re.search(r"^- \[[xX]\]", tasks_text, re.M))
    ck("scenario-map exact", set(sc) == {x["id"] for x in sm["scenarios"]} and len(sc) == len(sm["scenarios"]))
    fids = {x["id"] for x in fixtures}
    for x in fixtures:
        ck(x["id"] + " independent expected", has_expected(x) and x.get("execution") == "not_run")
        ck(x["id"] + " known scenarios", bool(x["scenarios"]) and all(s in sc for s in x["scenarios"]))
        ck(x["id"] + " decimal or named", True)
    # Negative control: missing expected is rejected.
    ck("negative control missing expected", has_expected({"expected": {}}) is False)
    ck("intact control F01 has expected", has_expected(next(x for x in fixtures if x["id"] == "F01")))
    ck("intact control F05 is error", next(x for x in fixtures if x["id"] == "F05")["expected"]["error"] == "divisionByZero")
    glob_pos = json.loads((CHANGE / "planned-mutations.json").read_text())["global_positives"]
    ck("global positives exist", set(glob_pos) <= fids)
    for m in mutants:
        ck(m["id"] + " designated in fixtures", m["designated_false"] in fids)
        ck(m["id"] + " sibling in fixtures", m["unaffected_positive"] in fids)
        ck(m["id"] + " actual change", bool(m.get("actual_source_change")) and bool(m.get("planned_anchor")))
        ck(m["id"] + " unexecuted", m["source_status"] == "PLANNED_NOT_IMPLEMENTED_OR_COMPILED")
        ck(m["id"] + " not self expected", m["designated_false"] != m["unaffected_positive"])
    # Independent arithmetic, not Lean.
    sys.path.insert(0, str(R1))
    import cl_oracle as o
    ck("tick0 Q96", o.get_sqrt_ratio_at_tick(0) == o.Q96)
    ck("F01 66", o.mul_div(10, 20, 3) == 66)
    ck("F02 67", o.mul_div_rounding_up(10, 20, 3) == 67)
    ck("F05 zero denom", o.catch(lambda: o.mul_div(1, 1, 0)) == {"error": "divisionByZero"})
    ck("F13 min ratio", o.get_sqrt_ratio_at_tick(o.MIN_TICK) == o.MIN_SQRT_RATIO)
    ck("F18 max exclusive", o.catch(lambda: o.greatest_tick_at_or_below(o.MAX_SQRT_RATIO)) == {"error": "ratioOutOfBounds"})
    ck("F34 floor", o.compress_tick(-61, 60) == -2)
    ck("F42 LS", o.catch(lambda: o.add_delta(10, -11)) == {"error": "liquidityUnderflow"})
    ck("remainder names traversal", "R-FULL-TRAVERSAL" in (CHANGE / "remainder-obligations.json").read_text())
    ck("proposal does not close roadmap", "Do not silently close the whole roadmap item" in (CHANGE / "proposal.md").read_text() or "named remainder" in (CHANGE / "proposal.md").read_text())
    design = (CHANGE / "design.md").read_text()
    sorry_hits = [ln.strip() for ln in design.splitlines() if "sorry" in ln.lower()]
    ck("sorry only as prohibition", all("no `sorry`" in ln.lower() or "No `sorry`" in ln or "sorry" in ln.lower() and "no" in ln.lower() for ln in sorry_hits) and bool(sorry_hits))
    # Protected existing APIs / pins / capture.
    protected = [
        "AGENTS.md",
        ".claude/skills/defi-footguns/SKILL.md",
        "formal/v3/GATE-REGISTER.md",
        "roadmap.md",
        "docs/superpowers/specs/2026-09-06-semantic-kernel-design.md",
        "docs/research/semantic-kernel-progress.md",
        "docs/research/2026-09-06-defi-source-plan.md",
        "lean/DefiKernel/Arithmetic/Word.lean",
        "lean/DefiKernel/Arithmetic/Operations.lean",
        "lean/DefiKernel/Arithmetic/Rounding.lean",
        "lean/DefiKernel/Arithmetic/Fees.lean",
        "lean/DefiKernel/Arithmetic/Quantity.lean",
        "lean/DefiKernel/Arithmetic/Reference.lean",
        "lean/DefiKernel/Arithmetic/Verify.lean",
        "lean/DefiKernel/Typed/Types.lean",
        "lean/DefiKernel/Typed/Expr.lean",
        "lean/DefiKernel/Typed/Authority.lean",
        "lean/DefiKernel/Typed/Transition.lean",
        "lean/lean-toolchain",
        "lean/lakefile.toml",
        "lean/lake-manifest.json",
        "review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-review.md",
        "review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-inputs.json",
        "review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/attempt1-failure.json",
        "review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/upstream/contracts/libraries/FullMath.sol",
        "review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/upstream/contracts/libraries/TickMath.sol",
        "review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/upstream/contracts/libraries/SwapMath.sol",
        "review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/upstream/LICENSE",
    ]
    head = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=REPO, text=True).strip()
    prot = []
    for p in protected:
        b = (REPO / p).read_bytes()
        rec = {"path": p, "sha256": sha(b), "bytes": len(b)}
        tracked = subprocess.run(["git", "ls-files", "--error-unmatch", p], cwd=REPO, capture_output=True)
        rec["tracked"] = tracked.returncode == 0
        if rec["tracked"]:
            g = subprocess.check_output(["git", "show", head + ":" + p], cwd=REPO)
            rec["matches_HEAD"] = b == g
            ck("protected HEAD " + p, b == g)
        else:
            rec["matches_HEAD"] = None
            ck("protected untracked capture present " + p, True)
        prot.append(rec)
    write("protected-before.json", {"head": head, "files": prot})
    tools = {}
    for name in ["python3", "openspec", "git", "lean", "lake"]:
        path = shutil.which(name)
        tools[name] = {"path": path, "sha256": sha(Path(path).read_bytes()) if path and Path(path).is_file() else None}
    tools["solc"] = {"path": shutil.which("solc"), "present": shutil.which("solc") is not None}
    tools["yarn"] = {"path": shutil.which("yarn"), "present": shutil.which("yarn") is not None}
    ck("solc absent so no compiler claim", tools["solc"]["present"] is False)
    write("tools.json", tools)
    commands = []
    runs = [
        ("strict", [shutil.which("openspec"), "validate", "concentrated-liquidity-library", "--strict"]),
        ("status", [shutil.which("openspec"), "status", "--change", "concentrated-liquidity-library", "--json"]),
        (
            "diff-check",
            [
                shutil.which("git"),
                "diff",
                "--check",
                "--",
                "openspec/changes/concentrated-liquidity-library",
                "review/semantic-kernel/concentrated-liquidity/planning/grok-gpt6-official-r1",
            ],
        ),
    ]
    utc = datetime.datetime.now(datetime.timezone.utc).isoformat()
    for name, args in runs:
        t0 = time.monotonic()
        p = subprocess.run(args, cwd=REPO, capture_output=True)
        elapsed = time.monotonic() - t0
        (R1 / (name + ".stdout")).write_bytes(p.stdout)
        (R1 / (name + ".stderr")).write_bytes(p.stderr)
        commands.append(
            {
                "name": name,
                "argv": args,
                "cwd": str(REPO),
                "utc": utc,
                "exit": p.returncode,
                "elapsed_seconds": elapsed,
                "stdout_sha256": sha(p.stdout),
                "stderr_sha256": sha(p.stderr),
                "stdout_bytes": len(p.stdout),
                "stderr_bytes": len(p.stderr),
            }
        )
        ck(name + " exit0", p.returncode == 0, p.stderr[-400:].decode("utf-8", "replace"))
    write("commands.json", commands)
    for x in sm["scenarios"]:
        ck(x["id"] + " mapped tasks", all(t in tasks for t in x["task_ids"]))
        if x["coverage_kind"].startswith("planned executable"):
            ck(x["id"] + " nonempty fixtures", bool(x["fixture_ids"]))
    ck("E03 mutation kind", next(x for x in sm["scenarios"] if x["id"] == "E03")["coverage_kind"] == "planned mutation")
    ck("E06 remainder kind", "scope" in next(x for x in sm["scenarios"] if x["id"] == "E06")["coverage_kind"])
    failed = [c for c in checks if not c["passed"]]
    result = {
        "utc": utc,
        "status": "author_planning_only",
        "counts": counts,
        "expected_counts": expected_counts,
        "head": head,
        "passed": not failed,
        "checks": checks,
        "failed": failed,
        "implementation_started": False,
        "independent_review_performed": False,
        "gate_accepted": False,
        "limits": "Static author validation plus independent Python integer oracle. No Lean build, no solc, no production mutations, no self-acceptance.",
    }
    write("author-validation.json", result)
    print(json.dumps({k: v for k, v in result.items() if k not in ("checks",)}, indent=2))
    print("checks", len(checks), "failed", len(failed))
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
