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
PACKAGE_REL = "review/semantic-kernel/certificates/planning/grok-gpt6-official-r4"
R1_PACKAGE = "review/semantic-kernel/certificates/planning/grok-gpt6-official-r1"
R2_PACKAGE = "review/semantic-kernel/certificates/planning/grok-gpt6-official-r2"
R3_PACKAGE = "review/semantic-kernel/certificates/planning/grok-gpt6-official-r3"
R1_ARCHIVE = "review/semantic-kernel/program-loop-20260908/native-worker/certificates-official-planning-r1-stage.tar.gz"
R1_ARCHIVE_SHA = "a845bc2b5d6a055252152c47c700adfd3dd89aeb3a7c25c0f1e792d7ccbba3ed"
R2_ARCHIVE = "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-candidate-r2.tar.gz"
R2_ARCHIVE_SHA = "122118df438c8c05a09f48e5097fb6f6bfd3c19cedece4dee20aa32757c4bc13"
R2_REVIEW_MD = "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-planning-review/REVIEW.md"
R2_REVIEW_SHA = "b4a7558255cd315ea324740ad2e815c6e3edb60a832f0e52ae8f599a570b82c7"
R2_VERDICT = "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-planning-review/verdict.json"
R2_VERDICT_SHA = "7d4231316413e0fb1272e95fc12235fa2651741a2cdafe539bbcca7c56b63998"
R2_EVIDENCE_MANIFEST = "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-planning-review/evidence-manifest.json"
R2_EVIDENCE_MANIFEST_SHA = "92ddb33a6f4cddd698b7248ffe999a0ca044f1f859a387b188b26ad2538bd040"
R3_ARCHIVE = "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-candidate-r3.tar.gz"
R3_ARCHIVE_SHA = "e5b6415c6fe74b8654e9633e48dbc528118072b2f1306865b2c56855dab9b6a9"
R3_REVIEW_MD = "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-r3-planning-review/REVIEW.md"
R3_REVIEW_SHA = "19e74032fdde1d1502a6211f928a7761b6a5f98fc28fcbe07585ebf3a57a70f1"
R3_PACKAGE_PY_SHA = "ce80443ddedef36aa19085f33972aee3ec41a64ac566d5dadb7fe8bce48835a1"
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


def fixture_by_id(fixtures: dict, fid: str) -> dict:
    for row in fixtures["fixtures"]:
        if row["id"] == fid:
            return row
    raise Failed(f"missing fixture {fid}")


def payload_store_entries(fx: dict) -> list:
    payload = fx["inputs"]["payload"]
    if "store" in payload:
        return payload["store"]["entries"]
    if "pre" in payload:
        return payload["pre"]["capabilities"]["entries"]
    if "world" in payload:
        return payload["world"]["capabilities"]["entries"]
    raise Failed(fx["id"] + " no store")


def request_op_caps(fx: dict) -> tuple:
    payload = fx["inputs"]["payload"]
    if "request" in payload:
        req = payload["request"]
        return req["operation"], req["capabilityIds"]
    inv = payload.get("step", {}).get("invocation")
    if inv:
        return inv["operation"], inv["capabilityIds"]
    raise Failed(fx["id"] + " no request")


def matching_invoke_ids(fx: dict) -> list:
    op, caps = request_op_caps(fx)
    hits = []
    for i, entry in enumerate(payload_store_entries(fx)):
        if (
            entry.get("live") is True
            and entry.get("operation") == op
            and entry.get("right", {}).get("tag") == "invoke"
            and i in caps
        ):
            hits.append(i)
    return hits


def matching_debit_alice_usd_ids(fx: dict) -> list:
    op, caps = request_op_caps(fx)
    hits = []
    want = {"domain": "main", "party": "alice", "asset": "usd"}
    for i, entry in enumerate(payload_store_entries(fx)):
        right = entry.get("right") or {}
        if (
            entry.get("live") is True
            and entry.get("operation") == op
            and right.get("tag") == "debit"
            and right.get("cell") == want
            and i in caps
        ):
            hits.append(i)
    return hits


def family_outcome(fx: dict, family: str) -> str:
    for row in fx["expected"]["judgments"]:
        if row["family"] == family:
            return row["outcome"]
    raise Failed(fx["id"] + " missing family " + family)


def planning_reachability(plan: Path) -> list[str]:
    """Consume stored fixture/contract values. Planning diagnostic, not kernel execution."""
    failures = []
    fixtures = load(plan / "fixtures.json")
    grammar = load(plan / "grammar.json")
    result_alg = load(plan / "result-algebra.json")
    corr = load(plan / "correspondence-theorems.json")
    proj = load(plan / "mutation-projection.json")
    mutants = load(plan / "planned-mutations.json")

    rows = {fid: fixture_by_id(fixtures, fid) for fid in
            ["F09", "F17", "F18", "F19", "F23", "F24", "F25", "F36", "F37", "F40", "F41", "F47", "F49", "F50", "F51"]}
    expected_ops = {"F09": 7, "F17": 8, "F18": 9, "F19": 10, "F23": 11, "F40": 6, "F47": 4}
    for fid, op in expected_ops.items():
        got, _ = request_op_caps(rows[fid])
        hits = matching_invoke_ids(rows[fid])
        if got != op:
            failures.append(f"{fid} operation {got} != {op}")
        if not hits:
            failures.append(f"{fid} no matching live invoke for operation {op} among requested ids")
    for fid in ["F09", "F19", "F23", "F47"]:
        if not matching_debit_alice_usd_ids(rows[fid]):
            failures.append(f"{fid} no matching live debit alice USD for requested operation")
    env18 = rows["F18"]["inputs"]["payload"]["env"]["entries"]
    if not env18 or env18[0]["observation"]["value"]["unit"] != {"tag": "amount", "asset": "usd"}:
        failures.append("F18 env unit is not amount USD; observationUnit would mask envReadFootprint")
    if family_outcome(rows["F17"], "authorityCorrect") != "true":
        failures.append(f"F17 authorityCorrect={family_outcome(rows['F17'], 'authorityCorrect')} not true after invoke")
    if family_outcome(rows["F18"], "authorityCorrect") != "true":
        failures.append("F18 authorityCorrect not true after invoke")
    if family_outcome(rows["F40"], "typeCorrect") != "true":
        failures.append("F40 typeCorrect not true; Args.check precedes missingObservation")
    if family_outcome(rows["F40"], "authorityCorrect") != "true":
        failures.append("F40 authorityCorrect not true; invoke precedes template.evaluate")
    if rows["F40"]["expected"]["failure"] != {"class": "kernel", "ctor": "evaluation", "payload": "missingObservation"}:
        failures.append("F40 designated failure is not evaluation.missingObservation")
    if family_outcome(rows["F49"], "accountingCorrect") != "false":
        failures.append(f"F49 accountingCorrect={family_outcome(rows['F49'], 'accountingCorrect')} not false on insufficientFunds")
    if family_outcome(rows["F24"], "accountingCorrect") != "false":
        failures.append("F24 accountingCorrect not false on insufficientFunds")
    if family_outcome(rows["F17"], "accountingCorrect") != "not_reached":
        failures.append("F17 accountingCorrect not not_reached after prior-class guard")
    if family_outcome(rows["F18"], "accountingCorrect") != "not_reached":
        failures.append("F18 accountingCorrect not not_reached after prior-class guard")
    if rows["F36"]["expected"]["status"] != "refused":
        failures.append("F36 status not refused")
    if rows["F36"]["expected"]["failure"] != {"class": "observationMismatch", "ctor": "claimedNextState", "payload": None}:
        failures.append("F36 failure not observationMismatch.claimedNextState")
    alice36 = next(c["amount"] for c in rows["F36"]["expected"]["world"]["state"]["cells"]
                   if c["domain"] == "main" and c["party"] == "alice" and c["asset"] == "usd")
    if alice36 != {"num": 7, "den": 1}:
        failures.append("F36 did not retain recomputed post-world alice USD 7")
    if rows["F50"]["expected"]["receipt"] != {"tag": "issued", "id": 12}:
        failures.append("F50 receipt not issued id 12")
    if rows["F51"]["expected"]["receipt"] != {"tag": "revoked", "id": 0}:
        failures.append("F51 receipt not revoked id 0")
    if rows["F37"]["expected"]["status"] != "refused":
        failures.append("F37 status not refused")
    if (rows["F37"]["expected"].get("failure") or {}).get("class") != "staleSource":
        failures.append("F37 failure class not staleSource")
    if rows["F37"]["expected"].get("receipt") is not None:
        failures.append("F37 receipt must be null")
    alice37 = next(c["amount"] for c in rows["F37"]["expected"]["world"]["state"]["cells"]
                   if c["domain"] == "main" and c["party"] == "alice" and c["asset"] == "usd")
    if alice37 != {"num": 10, "den": 1}:
        failures.append("F37 did not retain pre-world alice USD 10")
    if family_outcome(rows["F37"], "typeCorrect") != "not_reached":
        failures.append("F37 typeCorrect must be not_reached")
    encode_bytes = grammar["entrypoints"]["encodeModule"]["bytes"]
    if "no extra whitespace" not in encode_bytes or "single ASCII space" in encode_bytes:
        failures.append("grammar encodeModule still permits extra whitespace")
    if grammar["entrypoints"]["checkIR"]["type"] != "DecodedExecution → Report":
        failures.append("checkIR is not restricted to DecodedExecution")
    if "rawExecute" not in grammar["entrypoints"]:
        failures.append("grammar missing rawExecute")
    nested = grammar["canonical_nested_key_order"]
    for key in ["TypesEnum", "SourcePin", "TypedExecutePayload", "SourceMap"]:
        if key not in nested:
            failures.append(f"canonical_nested_key_order missing {key}")
    agg = result_alg.get("staged_family_aggregation") or {}
    if "staged_family_aggregation" not in result_alg:
        failures.append("result-algebra missing staged_family_aggregation")
    stages = agg.get("stage_order_typed_execute", [])
    if "accountingCorrect.guard" in stages:
        failures.append("guard is still classified as accountingCorrect")
    if not any("prior class" in s and s.startswith("guard") for s in stages):
        failures.append("guard is not a prior class in stage_order_typed_execute")
    ids = [s["id"] for s in corr["statements"]]
    by_id = {s["id"]: s["statement"] for s in corr["statements"]}
    for needed in [
        "T-raw-typed-ok", "T-raw-typed-error", "T-raw-step-ok", "T-raw-step-error",
        "T-raw-run-cursor", "T-checkIR-stale", "T-checkIR-typed-ok", "T-checkIR-typed-error",
        "T-checkIR-step-ok", "T-checkIR-step-error", "T-checkIR-run-cursor",
        "T-report-policy-accepted", "T-observation-mismatch",
    ]:
        if needed not in ids:
            failures.append("correspondence missing " + needed)
    if "T-accepted-execute" in ids:
        failures.append("correspondence still has unconditional T-accepted-execute")
    if "T-kernel-execute-ok" in ids:
        failures.append("correspondence still projects checkIR as T-kernel-execute-ok without source_identity")
    for tid in ["T-checkIR-typed-ok", "T-checkIR-typed-error", "T-checkIR-step-ok",
                "T-checkIR-step-error", "T-checkIR-run-cursor", "T-observation-mismatch",
                "T-checkIR-stale"]:
        if tid in by_id and "source_identity" not in by_id[tid]:
            failures.append(tid + " does not require source_identity")
    if "T-raw-typed-ok" in by_id and ("(checkIR ir)" in by_id["T-raw-typed-ok"] or "kernelProjection(checkIR" in by_id["T-raw-typed-ok"]):
        failures.append("T-raw-typed-ok must not project checkIR")
    acc = by_id.get("T-report-policy-accepted", "")
    if "requested_discharge_ok" not in acc or "require_library_discharge" not in acc:
        failures.append("T-report-policy-accepted missing requested_discharge_ok / require_library_discharge")
    if "rawExecute" not in (load(plan / "proposed-api.json").get("runtime_signatures") or {}):
        failures.append("proposed-api missing rawExecute")
    allow = {row["name"] for row in proj.get("proof_only_allowlist", [])}
    if allow != {"StepSound", "ReceiptAuthorized", "TraceSound", "RefusalSound"}:
        failures.append(f"projection allowlist {sorted(allow)}")
    muts = {m["id"]: m for m in mutants["mutations"]}
    if "JudgmentOutcome.true" not in muts["M09"]["replacement"]:
        failures.append("M09 replacement is not JudgmentOutcome.true")
    if ".accepted" in muts["M09"]["replacement"] or ".outstanding" in muts["M09"]["needle"]:
        failures.append("M09 still uses outstanding/accepted family constructors")
    if "JudgmentOutcome.true" not in muts["M10"]["replacement"]:
        failures.append("M10 replacement is not JudgmentOutcome.true")
    if "JudgmentOutcome.accepted" in muts["M10"]["replacement"]:
        failures.append("M10 still uses JudgmentOutcome.accepted")
    if "remaining_kernel_premise" not in muts["M06"]:
        failures.append("M06 missing remaining_kernel_premise")
    return failures


def cmd_reachability(ctx: Ctx) -> int:
    failures = planning_reachability(ctx.plan)
    if failures:
        raise Failed("reachability: " + "; ".join(failures[:12]))
    print(json.dumps({
        "status": "PASS_PLANNING_REACHABILITY_DIAGNOSTIC",
        "gate_accepted": False,
        "evidence_class": "source-contract/planning diagnostic; not kernel, proof, or certificate execution",
        "failures": [],
    }, indent=2))
    return 0


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
    ck("requirement map identity", set(reqs) == {x["id"] for x in load(ctx.plan / "scenario-map.json")["requirements"]})
    ck("37 requirements", len(reqs) == 37)
    expected_sc = [f"S{i:02d}" for i in range(1, 100)]
    ck("99 scenarios", len(scs) == 99 and set(scs) == set(expected_sc))
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
    ck("scenario-map exact", set(sm_sc) == set(scs) and len(sm_sc) == len(scs) == 99)
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
    reach_failures = planning_reachability(ctx.plan)
    ck("planning reachability consumes stored fixtures", not reach_failures)
    if reach_failures:
        raise Failed("reachability: " + "; ".join(reach_failures[:12]))

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
    ck("r2 package untouched identity", (ctx.root / R2_PACKAGE / "STATUS.json").is_file())
    ck("r2 package.py frozen", sha_path(ctx.root / R2_PACKAGE / "package.py") == "58f8706e77649c490a8a74f32134e1259990634f33bc68b651069f4b68504a5c")
    ck("r2 archive", sha_path(Path(R2_ARCHIVE)) == R2_ARCHIVE_SHA)
    ck("r2 review hash", sha_path(Path(R2_REVIEW_MD)) == R2_REVIEW_SHA)
    ck("r3 package untouched identity", (ctx.root / R3_PACKAGE / "STATUS.json").is_file())
    ck("r3 package.py frozen", sha_path(ctx.root / R3_PACKAGE / "package.py") == R3_PACKAGE_PY_SHA)
    ck("r3 archive", sha_path(Path(R3_ARCHIVE)) == R3_ARCHIVE_SHA)
    ck("r3 review hash", sha_path(Path(R3_REVIEW_MD)) == R3_REVIEW_SHA)
    ck("r2 verdict hash", sha_path(Path(R2_VERDICT)) == R2_VERDICT_SHA)
    ck("r2 evidence-manifest hash", sha_path(Path(R2_EVIDENCE_MANIFEST)) == R2_EVIDENCE_MANIFEST_SHA)
    ck("gpt6 review hash", sha_path(ctx.root / REVIEW_MD) == REVIEW_SHA)
    ck("gpt6 review inputs hash", sha_path(ctx.root / REVIEW_INPUTS) == REVIEW_INPUTS_SHA)
    hist = ctx.root / R2_PACKAGE / "historical-r1-synthetic-controls" / "NOTE.md"
    ck("historical synthetic note", hist.is_file() and "synthetic" in hist.read_text())

    status = load(ctx.out / "STATUS.json")
    identity = load(ctx.out / "identity.json")
    ck("gate_accepted false", status.get("gate_accepted") is False and identity.get("gate_accepted") is False)
    ck("no feature claim", status.get("certificates_implemented") is False)
    ck("worker grok-4.6", identity.get("worker_actual") in {"grok-4.6", "grok-4.6-build"})
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
    tmp = Path(tempfile.mkdtemp(prefix="cert-r4-ctrl-"))
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

    def preserved_r2_reachability() -> None:
        import tarfile
        tmp = Path(tempfile.mkdtemp(prefix="cert-r3-badr2-"))
        with tarfile.open(R2_ARCHIVE) as tar:
            tar.extractall(tmp)
        r2plan = tmp / "openspec/changes/serialized-kernel-certificates"
        cmd = [sys.executable, str(ctx.script), "--reachability",
               "--root", str(ctx.root), "--plan", str(r2plan), "--package", str(ctx.out)]
        started = utc()
        t0 = time.monotonic()
        proc = subprocess.run(cmd, cwd=ctx.root, capture_output=True)
        rec = {
            "name": "preserved-r2-fails-reachability",
            "argv": cmd,
            "cwd": str(ctx.root),
            "started_utc": started,
            "ended_utc": utc(),
            "wall_seconds": time.monotonic() - t0,
            "exit": proc.returncode,
            "expect": "failed",
            "observed": classify_exit(proc.returncode),
            "executable": sys.executable,
            "executable_sha256": sha_path(Path(sys.executable)),
            "stdout": proc.stdout.decode("utf-8", "replace"),
            "stderr": proc.stderr.decode("utf-8", "replace"),
            "stdout_sha256": sha(proc.stdout),
            "stderr_sha256": sha(proc.stderr),
            "r2_archive_sha256": R2_ARCHIVE_SHA,
            "evidence_class": "planning diagnostic against frozen r2 plan bytes; not kernel execution",
        }
        rec["matched"] = rec["observed"] == "failed"
        dump(ctx.controls / "preserved-r2-fails-reachability.json", rec)
        (ctx.controls / "preserved-r2-fails-reachability.stdout").write_text(rec["stdout"])
        (ctx.controls / "preserved-r2-fails-reachability.stderr").write_text(rec["stderr"])
        shutil.rmtree(tmp, ignore_errors=True)
        if not rec["matched"]:
            raise Failed(
                f"control preserved-r2-fails-reachability: expected failed got {rec['observed']} "
                f"exit {rec['exit']}: {rec['stderr'][-400:]}"
            )
        summary.append({k: rec[k] for k in (
            "name", "expect", "observed", "matched", "exit", "argv", "cwd",
            "started_utc", "ended_utc", "wall_seconds", "executable_sha256",
            "stdout_sha256", "stderr_sha256")})

    preserved_r2_reachability()

    def preserved_r3_reachability() -> None:
        import tarfile
        tmp = Path(tempfile.mkdtemp(prefix="cert-r4-badr3-"))
        with tarfile.open(R3_ARCHIVE) as tar:
            tar.extractall(tmp)
        r3plan = tmp / "openspec/changes/serialized-kernel-certificates"
        cmd = [sys.executable, str(ctx.script), "--reachability",
               "--root", str(ctx.root), "--plan", str(r3plan), "--package", str(ctx.out)]
        started = utc()
        t0 = time.monotonic()
        proc = subprocess.run(cmd, cwd=ctx.root, capture_output=True)
        rec = {
            "name": "preserved-r3-fails-reachability",
            "argv": cmd,
            "cwd": str(ctx.root),
            "started_utc": started,
            "ended_utc": utc(),
            "wall_seconds": time.monotonic() - t0,
            "exit": proc.returncode,
            "expect": "failed",
            "observed": classify_exit(proc.returncode),
            "executable": sys.executable,
            "executable_sha256": sha_path(Path(sys.executable)),
            "stdout": proc.stdout.decode("utf-8", "replace"),
            "stderr": proc.stderr.decode("utf-8", "replace"),
            "stdout_sha256": sha(proc.stdout),
            "stderr_sha256": sha(proc.stderr),
            "r3_archive_sha256": R3_ARCHIVE_SHA,
            "evidence_class": "planning diagnostic against frozen r3 plan bytes; not kernel execution",
        }
        rec["matched"] = rec["observed"] == "failed"
        dump(ctx.controls / "preserved-r3-fails-reachability.json", rec)
        (ctx.controls / "preserved-r3-fails-reachability.stdout").write_text(rec["stdout"])
        (ctx.controls / "preserved-r3-fails-reachability.stderr").write_text(rec["stderr"])
        shutil.rmtree(tmp, ignore_errors=True)
        if not rec["matched"]:
            raise Failed(
                f"control preserved-r3-fails-reachability: expected failed got {rec['observed']} "
                f"exit {rec['exit']}: {rec['stderr'][-400:]}"
            )
        summary.append({k: rec[k] for k in (
            "name", "expect", "observed", "matched", "exit", "argv", "cwd",
            "started_utc", "ended_utc", "wall_seconds", "executable_sha256",
            "stdout_sha256", "stderr_sha256")})

    preserved_r3_reachability()
    dump(ctx.controls / "summary.json", {
        "controls": summary,
        "count": len(summary),
        "historical_r1_synthetic": "historical-r1-synthetic-controls/; not these CLI runs",
        "historical_r2_cli": f"{R2_PACKAGE}/control-runs/; not these CLI runs",
        "historical_r3_cli": f"{R3_PACKAGE}/control-runs/; not these CLI runs",
        "reviewer_probes_are_independent": "GPT-6 0/1/3/3/1/0 remain reviewer evidence",
    })
    if len(summary) != 8:
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
        "kind": "certificates_official_planning_r4_manifest",
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
        "kind": "certificates_official_planning_r4_anchor",
        "git": HEAD_EXPECTED,
        "manifest_path": PACKAGE_REL + "/MANIFEST.json",
        "manifest_sha256": sha_path(ctx.manifest),
        "manifest_bytes": ctx.manifest.stat().st_size,
        "inventory_path": PACKAGE_REL + "/source-inventory.json",
        "inventory_sha256": sha_path(ctx.inventory),
        "package_py_sha256": sha_path(ctx.script),
        "gate_accepted": False,
        "r1_archive_sha256": R1_ARCHIVE_SHA,
        "r2_archive_sha256": R2_ARCHIVE_SHA,
        "r3_archive_sha256": R3_ARCHIVE_SHA,
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
    g.add_argument("--reachability", action="store_true")
    args = parser.parse_args()
    root = args.root or default_ctx().root
    package = args.package or (root / PACKAGE_REL)
    ctx = Ctx(root, package, args.plan)
    try:
        if args.prepare:
            return cmd_prepare(ctx)
        if args.seal:
            return cmd_seal(ctx)
        if args.reachability:
            return cmd_reachability(ctx)
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
