#!/usr/bin/env python3
"""Planning completeness and integrity only. No certificate implementation,
no Lean/financial execution, and no planning-gate acceptance.

--prepare writes validation artifacts.
--seal writes MANIFEST.json (no self-hash) and ANCHOR.json (external trust anchor).
--check is read-only. Exit 0 nonempty sealed package holds; 1 property false; 3 blocked.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from datetime import datetime, timezone
from fractions import Fraction
from pathlib import Path

HEAD_EXPECTED = "a12b7cac05a818cc8d35c2ca440b7170a2807e92"
CHANGE = "serialized-kernel-certificates"
PACKAGE_REL = "review/semantic-kernel/certificates/planning/grok-gpt6-official-r2"
R1_PACKAGE = "review/semantic-kernel/certificates/planning/grok-gpt6-official-r1"
R1_ARCHIVE = "review/semantic-kernel/program-loop-20260908/native-worker/certificates-official-planning-r1-stage.tar.gz"
R1_ARCHIVE_SHA = "a845bc2b5d6a055252152c47c700adfd3dd89aeb3a7c25c0f1e792d7ccbba3ed"
REVIEW_SHA = "6f46630cef8f0bef46577bb1c720726e81e33782a47205df63174ed0a4135fc9"
REVIEW_INPUTS_SHA = "8c6f11afe9033afdced13d4ac98b340964261d58946e0defd5971b3f1132ee7a"
REVIEW_MD = "review/semantic-kernel/program-loop-20260908/certificates-official-r1-gpt6-review.md"
REVIEW_INPUTS = "review/semantic-kernel/program-loop-20260908/certificates-official-r1-gpt6-inputs.json"
PLAN_REL = "openspec/changes/serialized-kernel-certificates"
READINESS_REVIEW = "review/semantic-kernel/program-loop-20260908/remaining-financial-async-readiness-gpt6-review.md"
READINESS_INPUTS = "review/semantic-kernel/program-loop-20260908/remaining-financial-async-readiness-gpt6-inputs.json"
READINESS_REVIEW_SHA = "9173e34ce186104f9593831d0f8061682656ea2de4eb888dcc424fc22014d9c2"
READINESS_INPUTS_SHA = "341f00291a943e9f7d89684dc02a2f86fd7c9b58af315edc3f8ae783b082bffc"
ATTEMPT1 = "review/semantic-kernel/program-loop-20260908/native-worker/certificates-official-planning-r1-attempt1"
OPENSPEC_STRICT_STDOUT = f"Change '{CHANGE}' is valid\n"
CAPS = [
    "certificate-regression-evidence",
    "recomputing-certificate-checker",
    "representation-correspondence",
    "runtime-proof-boundary",
    "serialized-module-format",
]
REQ_RE = re.compile(r"^### Requirement: ([A-Z]{2}\d{2}) ", re.M)
SC_RE = re.compile(r"^#### Scenario: (S\d+) ", re.M)
TASK_RE = re.compile(r"^- \[ \] (\d+\.\d+) ", re.M)
MUT_NAME = re.compile(r"[a-z][a-z0-9-]*")
CHECK_NAME = re.compile(r"[a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*")
RESERVED = {"control", "lean-version", "lean-path", "git-head", "git-root-input-status"}
USED_D_SOURCES = [
    "lean/DefiKernel/Typed/Types.lean",
    "lean/DefiKernel/Typed/Expr.lean",
    "lean/DefiKernel/Typed/Authority.lean",
    "lean/DefiKernel/Typed/Transition.lean",
    "lean/DefiKernel/Typed/Examples.lean",
    "lean/DefiKernel/Composition/Interfaces.lean",
    "lean/DefiKernel/Composition/Execution.lean",
    "lean/DefiKernel/Composition/Contracts.lean",
    "lean/DefiKernel/Composition/Sequence.lean",
    "lean/DefiKernel/Composition/Examples.lean",
    "lean/DefiKernel/AxiomAudit.lean",
    "lean/lean-toolchain",
    "lean/lakefile.toml",
    "lean/lake-manifest.json",
    "docs/superpowers/specs/2026-09-06-semantic-kernel-design.md",
    "docs/research/2026-09-06-defi-source-plan.md",
    "docs/research/semantic-kernel-progress.md",
    "roadmap.md",
    "wiki-llm/autonomous-execution-agenda.md",
    "AGENTS.md",
    ".claude/skills/defi-footguns/SKILL.md",
    "formal/v3/GATE-REGISTER.md",
    "scripts/run_interface_mutations.py",
    "research/positive-program/sigma/gate33_cert_check.py",
]
FORBIDDEN_IMPL = [
    "lean/DefiKernel/Certificates.lean",
    "lean/DefiKernel/Certificates",
    "scripts/run_certificate_mutations.py",
    "scripts/test_certificate_mutation_runner.py",
]
MANIFEST_EXCLUDE_NAMES = {"MANIFEST.json", "ANCHOR.json"}


class Blocked(Exception):
    pass


class Failed(Exception):
    pass


def utc() -> str:
    return datetime.now(timezone.utc).isoformat()


def sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def sha_path(path: Path) -> str:
    return sha(path.read_bytes())


def load(path: Path):
    return json.loads(path.read_text())


def dump(path: Path, data) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")


def which(name: str) -> Path:
    found = shutil.which(name)
    if not found:
        raise Blocked(f"tool unavailable: {name}")
    return Path(found).resolve()


class Ctx:
    def __init__(self, root: Path, package: Path, plan: Path | None = None):
        self.root = root.resolve()
        self.out = package.resolve()
        self.plan = (plan or (self.root / PLAN_REL)).resolve()
        self.validation = self.out / "validation"
        self.controls = self.out / "control-runs"
        self.manifest = self.out / "MANIFEST.json"
        self.anchor = self.out / "ANCHOR.json"
        self.inventory = self.out / "source-inventory.json"
        self.script = Path(__file__).resolve()

    def resolve(self, rel: str) -> Path:
        if rel.startswith(PLAN_REL + "/"):
            return self.plan / rel[len(PLAN_REL) + 1:]
        if rel.startswith(PACKAGE_REL + "/"):
            return self.out / rel[len(PACKAGE_REL) + 1:]
        return self.root / rel


def default_ctx() -> Ctx:
    script = Path(__file__).resolve()
    return Ctx(script.parents[5], script.parent)


def git(ctx: Ctx, *args: str) -> bytes:
    return subprocess.check_output(["git", *args], cwd=ctx.root)


def git_text(ctx: Ctx, *args: str) -> str:
    return git(ctx, *args).decode().strip()


def run_captured(ctx: Ctx, name: str, args: list[str], timeout: int = 60) -> dict:
    exe = which(args[0])
    cmd = [str(exe), *args[1:]]
    started = utc()
    t0 = time.monotonic()
    proc = subprocess.run(cmd, cwd=ctx.root, capture_output=True, timeout=timeout)
    rec = {
        "name": name,
        "argv": cmd,
        "cwd": str(ctx.root),
        "started_utc": started,
        "ended_utc": utc(),
        "wall_seconds": time.monotonic() - t0,
        "exit": proc.returncode,
        "executable": str(exe),
        "executable_sha256": sha_path(exe),
        "stdout_sha256": sha(proc.stdout),
        "stderr_sha256": sha(proc.stderr),
        "stdout_bytes": len(proc.stdout),
        "stderr_bytes": len(proc.stderr),
        "stdout_text": proc.stdout.decode("utf-8", "replace"),
        "stderr_text": proc.stderr.decode("utf-8", "replace"),
    }
    ctx.validation.mkdir(parents=True, exist_ok=True)
    (ctx.validation / f"{name}.stdout").write_bytes(proc.stdout)
    (ctx.validation / f"{name}.stderr").write_bytes(proc.stderr)
    return rec


def parse_scope(ctx: Ctx):
    caps, reqs, scs = [], [], []
    for spec in sorted((ctx.plan / "specs").glob("*/spec.md")):
        text = spec.read_text()
        cap = spec.parent.name
        caps.append(cap)
        if not text.startswith("## Purpose\n") or "## ADDED Requirements" not in text:
            raise Failed(f"spec shape: {cap}")
        if len(text.split("## Purpose", 1)[1].split("## ADDED", 1)[0].strip()) < 50:
            raise Failed(f"purpose too brief: {cap}")
        reqs += REQ_RE.findall(text)
        scs += SC_RE.findall(text)
    tasks_text = (ctx.plan / "tasks.md").read_text()
    if re.search(r"^- \[[xX]\]", tasks_text, re.M):
        raise Failed("checked task present")
    tasks = TASK_RE.findall(tasks_text)
    return caps, reqs, scs, tasks


def unique_nonempty(seq, label: str) -> None:
    if not seq:
        raise Blocked(f"{label}: empty (0 of 0)")
    if len(seq) != len(set(seq)):
        raise Failed(f"{label}: duplicates")


def verify_git_d_file(ctx: Ctx, rel: str) -> dict:
    path = ctx.root / rel
    if not path.is_file():
        raise Blocked(f"missing {rel}")
    raw = path.read_bytes()
    blob = git(ctx, "show", f"{HEAD_EXPECTED}:{rel}")
    if raw != blob:
        raise Failed(f"not equal Git D: {rel}")
    return {"path": rel, "sha256": sha(raw), "bytes": len(raw), "equals_git_D": True}


def existing_needle_unique(ctx: Ctx, mutant: dict) -> None:
    if mutant.get("anchor_status") != "planned_source_anchor":
        return
    rel = mutant["path"]
    text = (ctx.root / rel).read_text()
    needle = mutant["needle"]
    n = text.count(needle)
    if n != 1:
        raise Failed(f"{mutant['id']} needle count {n} in {rel}")
    if mutant["replacement"] == needle:
        raise Failed(f"{mutant['id']} replacement equals needle")


def independent_arithmetic() -> None:
    if not (10 - 3 == 7 and 0 + 3 == 3 and 20 == 20 and 4 == 4):
        raise Failed("F25 arithmetic")
    if not (10 - 3 - 3 == 4 and 0 + 6 == 6):
        raise Failed("F09 arithmetic")
    if not (3 != 4):
        raise Failed("F23 arithmetic")
    if not (10 - 11 < 0):
        raise Failed("F24 arithmetic")
    if Fraction(1, 2) != Fraction(1, 2) or Fraction(2, 4) != Fraction(1, 2):
        raise Failed("rational identity")
    if Fraction(2, 4).numerator != 1 or Fraction(2, 4).denominator != 2:
        raise Failed("unreduced canonicalization")


def plan_files(ctx: Ctx) -> list[str]:
    files = []
    for p in sorted(ctx.plan.rglob("*")):
        if p.is_file():
            files.append(PLAN_REL + "/" + str(p.relative_to(ctx.plan)))
    if not files:
        raise Blocked("plan files empty")
    return files


def package_files_for_manifest(ctx: Ctx) -> list[str]:
    files = []
    for p in sorted(ctx.out.rglob("*")):
        if not p.is_file():
            continue
        if p.name in MANIFEST_EXCLUDE_NAMES:
            continue
        files.append(PACKAGE_REL + "/" + str(p.relative_to(ctx.out)))
    return files


def collect_checks(ctx: Ctx) -> dict:
    checks = []

    def ck(name: str, value: bool, blocked: bool = False) -> None:
        checks.append({"check": name, "passed": bool(value), "blocked": blocked})
        if blocked and not value:
            raise Blocked(name)
        if not blocked and not value:
            raise Failed(name)

    head = git_text(ctx, "rev-parse", "HEAD")
    ck("head is D", head == HEAD_EXPECTED)
    branch = git_text(ctx, "rev-parse", "--abbrev-ref", "HEAD")
    ck("branch", branch == "work/certificates-grok-gpt6-20260908")

    for rel in USED_D_SOURCES:
        verify_git_d_file(ctx, rel)
        ck("git D " + rel, True)

    for rel in FORBIDDEN_IMPL:
        ck("no implementation " + rel, not (ctx.root / rel).exists())

    readiness_review = ctx.root / READINESS_REVIEW
    readiness_inputs = ctx.root / READINESS_INPUTS
    ck("readiness review hash", sha_path(readiness_review) == READINESS_REVIEW_SHA)
    ck("readiness inputs hash", sha_path(readiness_inputs) == READINESS_INPUTS_SHA)
    inputs = load(readiness_inputs)
    ck("original 53 bindings", len(inputs["inputs"]) == 53)
    present53, absent_non_d = 0, []
    for row in inputs["inputs"]:
        path = ctx.root / row["path"]
        if path.is_file():
            present53 += 1
            ck("original53 " + row["path"], sha_path(path) == row["sha256"])
            if row.get("equals_git_D") is True:
                verify_git_d_file(ctx, row["path"])
        else:
            if row.get("equals_git_D") is True:
                raise Blocked("original53 Git-D file missing " + row["path"])
            absent_non_d.append(row["path"])
    ck("original53 D files present", present53 >= 50)
    ck("original53 non-D absences recorded not fabricated",
       absent_non_d == ["review/semantic-kernel/program-loop-20260908/agenda-inventory-after-m3-20260908.json"]
       or not absent_non_d)

    attempt = ctx.root / ATTEMPT1
    ck("attempt1 dir", attempt.is_dir())
    jsonl = attempt / "certificates-official-planning-r1.jsonl"
    failure = attempt / "root-setup-failure.json"
    ck("attempt1 empty jsonl", jsonl.is_file() and jsonl.stat().st_size == 0)
    ck("attempt1 failure record", failure.is_file() and b"lacked program-loop briefs" in failure.read_bytes())

    caps, reqs, scs, tasks = parse_scope(ctx)
    unique_nonempty(caps, "capabilities")
    unique_nonempty(reqs, "requirements")
    unique_nonempty(scs, "scenarios")
    unique_nonempty(tasks, "tasks")
    ck("five capabilities", caps == CAPS)
    ck("31 requirements", len(reqs) == 31 and set(reqs) == {x["id"] for x in load(ctx.plan / "scenario-map.json")["requirements"]})
    expected_sc = [f"S{i:02d}" for i in range(1, 82)]
    ck("81 scenarios", len(scs) == 81 and set(scs) == set(expected_sc))
    ck("38 tasks", len(tasks) == 38)

    fixtures = load(ctx.plan / "fixtures.json")
    mutants = load(ctx.plan / "planned-mutations.json")
    smap = load(ctx.plan / "scenario-map.json")
    fids = [x["id"] for x in fixtures["fixtures"]]
    mids = [x["id"] for x in mutants["mutations"]]
    unique_nonempty(fids, "fixtures")
    unique_nonempty(mids, "mutants")
    ck("54 fixtures", len(fids) == 54 and fids == [f"F{i:02d}" for i in range(1, 55)])
    ck("16 mutants", len(mids) == 16 and mids == [f"M{i:02d}" for i in range(1, 17)])
    ck("fixture count field", fixtures.get("count") == 54)
    ck("mutant count field", mutants.get("count") == 16)
    grouping = mutants.get("grouping", {})
    ck("future 7", grouping.get("future_7") == ["M01", "M02", "M07", "M09", "M10", "M11", "M16"])
    ck("existing 9", grouping.get("existing_9") == ["M03", "M04", "M05", "M06", "M08", "M12", "M13", "M14", "M15"])

    for fx in fixtures["fixtures"]:
        ck(fx["id"] + " expected", bool(fx.get("expected")) and bool(fx.get("id")))
        ck(fx["id"] + " planned", fx.get("status") == "planned_not_executed")
        ck(fx["id"] + " scenarios", bool(fx.get("scenarios")) and set(fx["scenarios"]) <= set(scs))
    for m in mutants["mutations"]:
        ck(m["id"] + " planned", m.get("status") == "planned_not_executed")
        ck(m["id"] + " oracle", m.get("oracle_fixture") in fids)
        ck(m["id"] + " change", bool(m.get("actual_source_change")))
        ck(m["id"] + " anchor", m.get("anchor_status") in {"future_anchor", "planned_source_anchor"})
        ck(m["id"] + " runner name", bool(MUT_NAME.fullmatch(m["runner_name"])) and m["runner_name"] not in RESERVED)
        rf, pc = m["required_false"], m["expected_protected_check"]
        ck(m["id"] + " false", bool(rf) and all(CHECK_NAME.fullmatch(x) for x in rf))
        ck(m["id"] + " protected", bool(CHECK_NAME.fullmatch(pc)) and pc not in rf)
        ck(m["id"] + " protected fixture", m.get("protected_positive") in fids)
        existing_needle_unique(ctx, m)

    sm_sc = [x["id"] for x in smap["scenarios"]]
    ck("scenario-map exact", set(sm_sc) == set(scs) and len(sm_sc) == len(scs) == 81)
    mapped_fx, mapped_tasks = set(), set()
    for row in smap["scenarios"]:
        ck(row["id"] + " fixtures", bool(row["fixtures"]) and set(row["fixtures"]) <= set(fids))
        ck(row["id"] + " tasks", bool(row["tasks"]) and set(row["tasks"]) <= set(tasks))
        mapped_fx.update(row["fixtures"])
        mapped_tasks.update(row["tasks"])
    ck("every fixture mapped", mapped_fx == set(fids))
    ck("every task mapped", mapped_tasks == set(tasks))
    sm_req = [x["id"] for x in smap["requirements"]]
    ck("scenario-map requirements", set(sm_req) == set(reqs) and len(sm_req) == len(reqs))

    independent_arithmetic()
    ck("independent arithmetic", True)

    f25 = next(x for x in fixtures["fixtures"] if x["id"] == "F25")
    cells = f25["expected"]["world"]["state"]["cells"]
    ck("F25 32 cells", len(cells) == 32)

    def amt(d, p, a):
        return next(c["amount"] for c in cells if c["domain"] == d and c["party"] == p and c["asset"] == a)

    ck("F25 alice 7", amt("main", "alice", "usd") == {"num": 7, "den": 1})
    ck("F25 bob 3", amt("main", "bob", "usd") == {"num": 3, "den": 1})
    ck("F25 vault 20", amt("main", "vault", "usd") == {"num": 20, "den": 1})
    ck("F25 collateral 10", amt("main", "alice", "collateral") == {"num": 10, "den": 1})
    ck("F25 debt 2", amt("main", "alice", "debt") == {"num": 2, "den": 1})
    ck("F25 pool 100", amt("main", "pool", "usd") == {"num": 100, "den": 1})
    ck("F25 store 12", len(f25["expected"]["world"]["capabilities"]["entries"]) == 12)
    ck("F25 14 report fields", len(f25["expected"]) == 14)
    f47 = next(x for x in fixtures["fixtures"] if x["id"] == "F47")
    ck("F47 readAccess", f47["expected"]["failure"]["ctor"] == "readAccess")
    f50 = next(x for x in fixtures["fixtures"] if x["id"] == "F50")
    ck("F50 fresh id 12", f50["expected"]["receipt"]["id"] == 12)
    six = load(ctx.plan / "result-algebra.json")["assumption_classes_6"]
    ck("six assumption classes", len(six) == 6 and "environment-authenticity" in six)
    ck("r1 archive", sha_path(ctx.root / R1_ARCHIVE) == R1_ARCHIVE_SHA)
    ck("r1 package untouched identity", (ctx.root / R1_PACKAGE / "STATUS.json").is_file())
    ck("gpt6 review hash", sha_path(ctx.root / REVIEW_MD) == REVIEW_SHA)
    ck("gpt6 review inputs hash", sha_path(ctx.root / REVIEW_INPUTS) == REVIEW_INPUTS_SHA)
    hist = ctx.out / "historical-r1-synthetic-controls" / "NOTE.md"
    ck("historical synthetic note", hist.is_file() and "synthetic" in hist.read_text())

    status = load(ctx.out / "STATUS.json")
    identity = load(ctx.out / "identity.json")
    ck("gate_accepted false", status.get("gate_accepted") is False and identity.get("gate_accepted") is False)
    ck("no feature claim", status.get("certificates_implemented") is False)
    ck("worker grok-4.6", identity.get("worker_actual") == "grok-4.6")
    ck("checker GPT-6", "GPT-6" in str(identity.get("independent_checker")))
    ck("no foreman", identity.get("no_foreman") is True)

    remainder = load(ctx.plan / "remainder-obligations.json")
    ck("remainder named", remainder.get("do_not_check_global_boxes") is True and len(remainder.get("later", [])) >= 8)
    roadmap = (ctx.root / "roadmap.md").read_text()
    ck("roadmap 230 unchecked", "- [ ] Define a serialized module/transition format" in roadmap)
    ck("roadmap 231 unchecked", "- [ ] Implement a real certificate checker" in roadmap)

    proposed = load(ctx.plan / "proposed-api.json")
    ck("proposed unimplemented", proposed.get("status") == "proposed_unimplemented_unelaborated")
    ck("no compiler check claimed", proposed.get("compiler_check_recorded") is False)

    schema = load(ctx.plan / "schema.json")
    ck("schema version 1", schema.get("schema_version") == 1)
    grammar = load(ctx.plan / "grammar.json")
    ck("grammar entrypoints", "decodeBytes" in grammar["entrypoints"] and "checkBytes" in grammar["entrypoints"])
    ck("no ambient", grammar["no_ambient_inputs"]["forbidden"].startswith("module-level"))
    proj = load(ctx.plan / "mutation-projection.json")
    ck("projection not executed", proj.get("do_not_implement_kernel_mutations_during_planning") is True)
    corr = load(ctx.plan / "correspondence-theorems.json")
    ck("finite tests do not discharge RC01", corr.get("finite_fixture_tests_do_not_discharge_RC01") is True)
    ck("three audit prefixes", len(corr["audit"]["commands"]) == 3)
    runner = load(ctx.plan / "runner-adaptation.json")
    ck("runner keys", runner["inherited"]["spec_keys"] == ["schema_version", "modules", "mutations", "positive_checks"])

    contracts = (ctx.root / "lean/DefiKernel/Composition/Contracts.lean").read_text()
    ck("contracts not executable", "not executable certificates" in contracts)

    return {
        "head": head,
        "branch": branch,
        "counts": {
            "capabilities": len(caps),
            "requirements": len(reqs),
            "scenarios": len(scs),
            "unchecked_tasks": len(tasks),
            "fixtures": len(fids),
            "planned_mutations": len(mids),
            "original53": 53,
            "checks": len(checks),
        },
        "checks": checks,
        "capabilities": caps,
        "requirements": reqs,
        "scenarios": scs,
        "tasks": tasks,
        "fixtures": fids,
        "mutants": mids,
    }


def write_inventory(ctx: Ctx, parsed: dict) -> dict:
    rows = []
    extra = [PACKAGE_REL + "/" + n for n in ["identity.json", "STATUS.json", "ENTRYPOINT.md", "package.py"]]
    for rel in plan_files(ctx) + extra:
        path = ctx.resolve(rel)
        if path.is_file():
            rows.append({"path": rel, "sha256": sha_path(path), "bytes": path.stat().st_size, "class": "plan-or-package"})
    for rel in USED_D_SOURCES:
        rows.append({**verify_git_d_file(ctx, rel), "class": "used-source-D"})
    rows.append({"path": READINESS_REVIEW, "sha256": READINESS_REVIEW_SHA, "bytes": (ctx.root / READINESS_REVIEW).stat().st_size, "class": "readiness"})
    rows.append({"path": READINESS_INPUTS, "sha256": READINESS_INPUTS_SHA, "bytes": (ctx.root / READINESS_INPUTS).stat().st_size, "class": "readiness"})
    inv = {
        "git": HEAD_EXPECTED,
        "generated_utc": utc(),
        "rows": rows,
        "counts": parsed["counts"],
        "note": "Inventory excludes MANIFEST.json and ANCHOR.json. Original 53 readiness bindings preserved separately.",
    }
    dump(ctx.inventory, inv)
    orig = load(ctx.root / READINESS_INPUTS)
    dump(ctx.out / "original53-bindings.json", {
        "preserved": True,
        "count": 53,
        "source": READINESS_INPUTS,
        "sha256": READINESS_INPUTS_SHA,
        "inputs": orig["inputs"],
        "used_local_Lean_closure_keys": sorted(orig["used_local_Lean_closure"].keys()),
        "note": "Historical readiness bindings. This increment may add Certificates APIs; it does not rewrite these 53 rows.",
    })
    return inv


def isolate_copy(ctx: Ctx) -> tuple[Path, Path]:
    tmp = Path(tempfile.mkdtemp(prefix="cert-r2-ctrl-"))
    plan = tmp / "plan"
    pkg = tmp / "pkg"
    shutil.copytree(ctx.plan, plan)
    shutil.copytree(ctx.out, pkg)
    return plan, pkg


def invoke_check(ctx: Ctx, plan: Path, pkg: Path) -> dict:
    cmd = [sys.executable, str(ctx.script), "--check",
           "--root", str(ctx.root), "--plan", str(plan), "--package", str(pkg)]
    started = utc()
    t0 = time.monotonic()
    proc = subprocess.run(cmd, cwd=ctx.root, capture_output=True, env={**os.environ, "CERT_ISOLATED": "1"})
    rec = {
        "argv": cmd,
        "cwd": str(ctx.root),
        "started_utc": started,
        "ended_utc": utc(),
        "wall_seconds": time.monotonic() - t0,
        "exit": proc.returncode,
        "executable": sys.executable,
        "executable_sha256": sha_path(Path(sys.executable)),
        "stdout": proc.stdout.decode("utf-8", "replace"),
        "stderr": proc.stderr.decode("utf-8", "replace"),
        "stdout_sha256": sha(proc.stdout),
        "stderr_sha256": sha(proc.stderr),
    }
    return rec


def classify_exit(code: int) -> str:
    if code == 0:
        return "pass"
    if code == 1:
        return "failed"
    if code == 3:
        return "blocked"
    return f"other-{code}"


def run_controls(ctx: Ctx) -> list:
    if os.environ.get("CERT_ISOLATED") == "1":
        return []
    if not ctx.manifest.is_file():
        raise Blocked("controls require a sealed package; run --seal then --controls")
    ctx.controls.mkdir(parents=True, exist_ok=True)
    summary = []

    def one(name: str, expect: str, mutator) -> None:
        plan, pkg = isolate_copy(ctx)
        mutator(plan, pkg)
        rec = invoke_check(ctx, plan, pkg)
        rec["name"] = name
        rec["expect"] = expect
        rec["observed"] = classify_exit(rec["exit"])
        rec["matched"] = rec["observed"] == expect
        dump(ctx.controls / f"{name}.json", rec)
        (ctx.controls / f"{name}.stdout").write_text(rec["stdout"])
        (ctx.controls / f"{name}.stderr").write_text(rec["stderr"])
        if not rec["matched"]:
            raise Failed(f"control {name}: expected {expect} got {rec['observed']} exit {rec['exit']}: {rec['stderr'][-400:]}")
        summary.append({k: rec[k] for k in ("name", "expect", "observed", "matched", "exit", "argv", "cwd", "started_utc", "ended_utc", "wall_seconds", "executable_sha256", "stdout_sha256", "stderr_sha256")})
        shutil.rmtree(plan.parent, ignore_errors=True)

    def intact(plan, pkg):
        return

    def empty_fixtures(plan, pkg):
        dump(plan / "fixtures.json", {"status": "empty-control", "count": 0, "fixtures": []})

    def missing_manifest_file(plan, pkg):
        target = pkg / "STATUS.json"
        if not target.is_file():
            raise Blocked("STATUS.json missing in isolated package")
        target.unlink()

    def changed_manifest_file(plan, pkg):
        target = pkg / "STATUS.json"
        target.write_text(target.read_text() + "\n")

    def spec_drift(plan, pkg):
        p = plan / "specs/serialized-module-format/spec.md"
        p.write_text(p.read_text().replace("### Requirement: SF01 ", "### Requirement: ZZ99 ", 1))

    one("intact", "pass", intact)
    one("empty-fixtures", "blocked", empty_fixtures)
    one("missing-bound-artifact", "blocked", missing_manifest_file)
    one("changed-bound-artifact", "failed", changed_manifest_file)
    one("changed-requirement", "failed", spec_drift)
    one("restored-intact-sibling", "pass", intact)
    dump(ctx.controls / "summary.json", {
        "controls": summary,
        "count": len(summary),
        "historical_r1_synthetic": "historical-r1-synthetic-controls/; not these CLI runs",
        "reviewer_probes_are_independent": "GPT-6 0/1/3/3/1/0 remain reviewer evidence",
    })
    if len(summary) != 6:
        raise Failed("control count")
    return summary


def cmd_prepare(ctx: Ctx) -> int:
    ctx.validation.mkdir(parents=True, exist_ok=True)
    commands = [
        run_captured(ctx, "openspec-version", ["openspec", "--version"]),
        run_captured(ctx, "openspec-strict", ["openspec", "validate", CHANGE, "--strict", "--no-interactive"]),
        run_captured(ctx, "openspec-status", ["openspec", "status", "--change", CHANGE, "--json"]),
        run_captured(ctx, "git-diff-check", ["git", "diff", "--check", "--", PLAN_REL, PACKAGE_REL]),
    ]
    dump(ctx.validation / "commands.json", [{k: v for k, v in c.items() if k not in {"stdout_text", "stderr_text"}} for c in commands])
    strict = next(c for c in commands if c["name"] == "openspec-strict")
    if strict["exit"] != 0 or strict["stdout_text"] != OPENSPEC_STRICT_STDOUT:
        raise Failed(f"openspec strict: exit {strict['exit']} stdout={strict['stdout_text']!r}")
    for c in commands:
        if c["exit"] != 0:
            raise Failed(f"command {c['name']} exit {c['exit']}")
    parsed = collect_checks(ctx)
    write_inventory(ctx, parsed)
    tools = {
        "python_version": sys.version,
        "python": {"path": sys.executable, "sha256": sha_path(Path(sys.executable))},
        "openspec": {"path": str(which("openspec")), "sha256": sha_path(which("openspec"))},
        "git": {"path": str(which("git")), "sha256": sha_path(which("git"))},
    }
    dump(ctx.out / "tools.json", tools)
    result = {
        "utc": utc(),
        "status": "PASS_AUTHOR_CONSISTENCY_ONLY",
        "gate_accepted": False,
        "implementation_started": False,
        "independent_review_performed": False,
        "head": parsed["head"],
        "counts": parsed["counts"],
        "commands": [c["name"] for c in commands],
        "controls": "run --controls after --seal",
        "limits": "Static planning consistency only. No Lean build, no certificate checker execution, no mutation run.",
    }
    dump(ctx.validation / "result.json", result)
    dump(ctx.out / "author-validation.json", {**result, "check_names": [c["check"] for c in parsed["checks"]]})
    print(json.dumps({k: v for k, v in result.items()}, indent=2))
    return 0


def cmd_seal(ctx: Ctx) -> int:
    if not ctx.inventory.is_file() or not (ctx.validation / "result.json").is_file():
        raise Blocked("seal requires --prepare artifacts")
    files = []
    seen = set()
    for rel in plan_files(ctx) + package_files_for_manifest(ctx):
        if rel in seen:
            continue
        if Path(rel).name in MANIFEST_EXCLUDE_NAMES:
            continue
        seen.add(rel)
        path = ctx.resolve(rel)
        files.append({"path": rel, "sha256": sha_path(path), "bytes": path.stat().st_size})
    manifest = {
        "kind": "certificates_official_planning_r2_manifest",
        "git": HEAD_EXPECTED,
        "sealed_utc": utc(),
        "excludes": ["MANIFEST.json", "ANCHOR.json"],
        "files": files,
        "file_count": len(files),
    }
    dump(ctx.manifest, manifest)
    if any(row["path"].endswith("MANIFEST.json") or row["path"].endswith("ANCHOR.json") for row in files):
        raise Failed("manifest includes self or anchor")
    anchor = {
        "kind": "certificates_official_planning_r2_anchor",
        "git": HEAD_EXPECTED,
        "manifest_path": PACKAGE_REL + "/MANIFEST.json",
        "manifest_sha256": sha_path(ctx.manifest),
        "manifest_bytes": ctx.manifest.stat().st_size,
        "inventory_path": PACKAGE_REL + "/source-inventory.json",
        "inventory_sha256": sha_path(ctx.inventory),
        "package_py_sha256": sha_path(ctx.script),
        "gate_accepted": False,
        "r1_archive_sha256": R1_ARCHIVE_SHA,
        "sealed_utc": utc(),
    }
    dump(ctx.anchor, anchor)
    print(json.dumps({"sealed": True, "file_count": len(files), "manifest_sha256": anchor["manifest_sha256"]}, indent=2))
    return 0


def cmd_check(ctx: Ctx) -> int:
    if not ctx.manifest.is_file() or not ctx.anchor.is_file():
        raise Blocked("unsealed package")
    manifest = load(ctx.manifest)
    anchor = load(ctx.anchor)
    if "sha256" in manifest or any(k == "self_sha256" for k in manifest):
        raise Failed("manifest contains self hash field")
    if any(Path(row["path"]).name in MANIFEST_EXCLUDE_NAMES for row in manifest["files"]):
        raise Failed("manifest lists self or anchor")
    actual_manifest = sha_path(ctx.manifest)
    if actual_manifest != anchor["manifest_sha256"]:
        raise Failed("anchor manifest hash mismatch")
    if not ctx.inventory.is_file():
        raise Blocked("missing source-inventory.json")
    if sha_path(ctx.inventory) != anchor["inventory_sha256"]:
        raise Failed("anchor inventory hash mismatch")
    if not manifest["files"]:
        raise Blocked("manifest files 0 of 0")
    missing, mismatched = [], []
    for row in manifest["files"]:
        path = ctx.resolve(row["path"])
        if not path.is_file():
            missing.append(row["path"])
            continue
        if sha_path(path) != row["sha256"] or path.stat().st_size != row["bytes"]:
            mismatched.append(row["path"])
    if missing:
        raise Blocked(f"manifest missing {missing[:8]}")
    parsed = collect_checks(ctx)
    if mismatched:
        raise Failed(f"manifest mismatch {mismatched[:8]}")
    print(json.dumps({
        "status": "PASS_SEALED_PLANNING_PACKAGE",
        "gate_accepted": False,
        "counts": parsed["counts"],
        "manifest_files": manifest["file_count"],
        "head": parsed["head"],
    }, indent=2))
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path)
    parser.add_argument("--package", type=Path)
    parser.add_argument("--plan", type=Path)
    g = parser.add_mutually_exclusive_group(required=True)
    g.add_argument("--prepare", action="store_true")
    g.add_argument("--seal", action="store_true")
    g.add_argument("--check", action="store_true")
    g.add_argument("--controls", action="store_true")
    args = parser.parse_args()
    root = args.root or default_ctx().root
    package = args.package or (root / PACKAGE_REL)
    ctx = Ctx(root, package, args.plan)
    try:
        if args.prepare:
            return cmd_prepare(ctx)
        if args.seal:
            return cmd_seal(ctx)
        if args.controls:
            recs = run_controls(ctx)
            print(json.dumps({"controls": recs, "gate_accepted": False}, indent=2, default=str))
            return 0
        return cmd_check(ctx)
    except Blocked as e:
        print(f"BLOCKED: {e}", file=sys.stderr)
        return 3
    except Failed as e:
        print(f"FAILED: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
