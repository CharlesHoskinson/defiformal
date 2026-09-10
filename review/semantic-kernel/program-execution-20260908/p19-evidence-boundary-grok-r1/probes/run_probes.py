#!/usr/bin/env python3
"""Bounded evidence-boundary probes against frozen R4 checker sources.

Writes all artifacts under the review directory. Does not modify the sandbox.
"""
from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path

OUT = Path("/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-evidence-boundary-grok-r1")
SANDBOX = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p19-evidence-boundary-grok-r1-sandbox")
LEAN = OUT / "probes" / "lean-tree"
WORKDIR = OUT / "probes" / "workdir"
LOGS = OUT / "logs"
INPUTS = OUT / "inputs"
ELAN = "/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin"

sys.path.insert(0, str(SANDBOX / "scripts"))
import run_certificate_fixtures as runner  # noqa: E402


def sha256_bytes(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


def sha256_file(p: Path) -> str:
    return sha256_bytes(p.read_bytes()) if p.exists() else ""


def write_json(path: Path, obj) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2) + "\n", encoding="utf-8")


def run_cmd(argv, cwd, env, timeout=180):
    t0 = time.monotonic()
    proc = subprocess.run(
        argv,
        cwd=str(cwd),
        env=env,
        capture_output=True,
        timeout=timeout,
    )
    elapsed = round(time.monotonic() - t0, 4)
    return {
        "argv": argv,
        "cwd": str(cwd),
        "exit": proc.returncode,
        "elapsed_seconds": elapsed,
        "stdout": proc.stdout.decode("utf-8", errors="replace"),
        "stderr": proc.stderr.decode("utf-8", errors="replace"),
        "stdout_sha256": sha256_bytes(proc.stdout),
        "stderr_sha256": sha256_bytes(proc.stderr),
        "stdout_len": len(proc.stdout),
        "stderr_len": len(proc.stderr),
    }


def parse_stdout_json(stdout: str):
    text = stdout.strip()
    # lake/lean may emit info lines before JSON
    lines = [ln for ln in text.splitlines() if ln.strip()]
    for i in range(len(lines)):
        chunk = "\n".join(lines[i:])
        try:
            return json.loads(chunk), chunk
        except Exception:
            continue
    try:
        return json.loads(text), text
    except Exception as e:
        return {"_parse_error": str(e), "_raw": text[:2000]}, text


def env_for_lean():
    e = os.environ.copy()
    e["ELAN_TOOLCHAIN"] = "leanprover/lean4:v4.33.0-rc2"
    e["PATH"] = ELAN + ":" + e.get("PATH", "")
    e["LEAN_ABORT_ON_PANIC"] = "1"
    return e


def lake_run(mode, files):
    argv = ["lake", "env", "lean", "--run", "DefiKernel/Certificates/RunFixtures.lean", mode] + [
        str(p) for p in files
    ]
    return run_cmd(argv, LEAN, env_for_lean())


def summarize_report(obj):
    if not isinstance(obj, dict):
        return {"type": type(obj).__name__}
    if "result" in obj and isinstance(obj["result"], dict):
        res = obj["result"]
        return {
            "wrapper_mode": obj.get("mode"),
            "status": res.get("status"),
            "failure": res.get("failure"),
            "ir": res.get("ir"),
            "prefixes": res.get("prefixes"),
            "claimed_covered": res.get("claimed_covered"),
            "raw_utf8_sha256": sha256_bytes(obj["raw_utf8"].encode()) if isinstance(obj.get("raw_utf8"), str) else None,
        }
    return {
        "status": obj.get("status"),
        "failure": obj.get("failure"),
        "outstanding": obj.get("outstanding"),
        "source_pin": obj.get("source_pin"),
        "judgments_sourceRefinement": next(
            (j for j in obj.get("judgments") or [] if j.get("family") == "sourceRefinement"),
            None,
        ),
        "world_alice_usd": next(
            (
                c.get("amount")
                for c in ((obj.get("world") or {}).get("state") or {}).get("cells") or []
                if c.get("domain") == "main" and c.get("party") == "alice" and c.get("asset") == "usd"
            ),
            None,
        ),
        "receipt": obj.get("receipt"),
    }


def main():
    WORKDIR.mkdir(parents=True, exist_ok=True)
    LOGS.mkdir(parents=True, exist_ok=True)
    commands = []
    probes = []

    identical = (INPUTS / "F25_compact.json").read_bytes()
    assert sha256_bytes(identical) == "147d3f956a7c316338e151c11d679d953fb9b38aab30e08648c77d922c8c84c8"
    f13_raw = (INPUTS / "F13_raw.dat").read_bytes()
    assert f13_raw == identical

    # Named copies of IDENTICAL bytes
    names_check = [
        "neutral_in.json",
        "F25_in.json",
        "F43_in.json",
        "F13_in.json",
        "prefixF43suffix.json",
        "f43_lower.json",
        "not_the_fixture.json",
        "F430.json",
        "xxF13yy.json",
    ]
    names_decode = [
        "neutral_in.dat",
        "F13_in.dat",
        "F25_in.dat",
        "F43_in.dat",
        "prefixF13suffix.dat",
        "f13_lower.dat",
        "xxF13yy.dat",
    ]
    for n in names_check:
        p = WORKDIR / n
        p.write_bytes(identical)
        assert p.read_bytes() == identical
    for n in names_decode:
        p = WORKDIR / n
        p.write_bytes(identical)
        assert p.read_bytes() == identical

    # 1. decode-mode filename oracle
    for n in names_decode:
        rec = lake_run("decode", [WORKDIR / n])
        parsed, chunk = parse_stdout_json(rec["stdout"])
        item = {
            "probe": f"decode/{n}",
            "mode": "decode",
            "filename": n,
            "path_contains_F13": "F13" in str(WORKDIR / n),
            "input_sha256": sha256_bytes(identical),
            "command": rec,
            "parsed": parsed,
            "summary": summarize_report(parsed),
        }
        probes.append(item)
        commands.append(
            {
                "id": item["probe"],
                "argv": rec["argv"],
                "cwd": rec["cwd"],
                "exit": rec["exit"],
                "stdout_sha256": rec["stdout_sha256"],
                "stderr_sha256": rec["stderr_sha256"],
                "elapsed_seconds": rec["elapsed_seconds"],
            }
        )
        (LOGS / f"decode-{n}.stdout").write_text(rec["stdout"])
        (LOGS / f"decode-{n}.stderr").write_text(rec["stderr"])
        print(f"decode {n}: exit={rec['exit']} ir={item['summary'].get('ir')} status={item['summary'].get('status')}")

    # 2. check-mode filename oracle on identical execution bytes
    for n in names_check:
        rec = lake_run("check", [WORKDIR / n])
        parsed, chunk = parse_stdout_json(rec["stdout"])
        parsed_slim = parsed
        if isinstance(parsed, dict) and "_parse_error" not in parsed:
            parsed_slim = {k: parsed.get(k) for k in [
                "status", "failure", "outstanding", "source_pin", "receipt",
                "nextIndex", "unsupported", "assumptions", "judgments",
            ]}
        item = {
            "probe": f"check/{n}",
            "mode": "check",
            "filename": n,
            "path_contains_F43": "F43" in str(WORKDIR / n),
            "input_sha256": sha256_bytes(identical),
            "command": rec,
            "parsed": parsed_slim,
            "summary": summarize_report(parsed),
        }
        # keep full parsed separately for hashes
        (WORKDIR / f"out-{n}").write_text(json.dumps(parsed) + "\n")
        item["output_sha256"] = sha256_bytes((WORKDIR / f"out-{n}").read_bytes())
        probes.append(item)
        commands.append(
            {
                "id": item["probe"],
                "argv": rec["argv"],
                "cwd": rec["cwd"],
                "exit": rec["exit"],
                "stdout_sha256": rec["stdout_sha256"],
                "stderr_sha256": rec["stderr_sha256"],
                "elapsed_seconds": rec["elapsed_seconds"],
            }
        )
        (LOGS / f"check-{n}.stdout").write_text(rec["stdout"])
        (LOGS / f"check-{n}.stderr").write_text(rec["stderr"])
        print(
            f"check {n}: exit={rec['exit']} status={item['summary'].get('status')} outstanding={item['summary'].get('outstanding')}"
        )

    # 3. rawExecute on identical bytes (no filename oracle in raw mode)
    rec = lake_run("raw", [WORKDIR / "neutral_in.json"])
    parsed, _ = parse_stdout_json(rec["stdout"])
    probes.append(
        {
            "probe": "raw/neutral_in.json",
            "mode": "raw",
            "filename": "neutral_in.json",
            "input_sha256": sha256_bytes(identical),
            "command": rec,
            "parsed_keys": list(parsed) if isinstance(parsed, dict) else None,
            "kernelFailure": parsed.get("kernelFailure") if isinstance(parsed, dict) else None,
            "receipt": parsed.get("receipt") if isinstance(parsed, dict) else None,
        }
    )
    commands.append(
        {
            "id": "raw/neutral_in.json",
            "argv": rec["argv"],
            "cwd": rec["cwd"],
            "exit": rec["exit"],
            "stdout_sha256": rec["stdout_sha256"],
            "stderr_sha256": rec["stderr_sha256"],
            "elapsed_seconds": rec["elapsed_seconds"],
        }
    )
    (LOGS / "raw-neutral_in.json.stdout").write_text(rec["stdout"])
    (LOGS / "raw-neutral_in.json.stderr").write_text(rec["stderr"])
    print(f"raw neutral: exit={rec['exit']} receipt={parsed.get('receipt') if isinstance(parsed, dict) else None}")

    rec_f43raw = lake_run("raw", [WORKDIR / "F43_in.json"])
    parsed43, _ = parse_stdout_json(rec_f43raw["stdout"])
    probes.append(
        {
            "probe": "raw/F43_in.json",
            "mode": "raw",
            "filename": "F43_in.json",
            "input_sha256": sha256_bytes(identical),
            "command": rec_f43raw,
            "stdout_sha256": rec_f43raw["stdout_sha256"],
            "same_stdout_as_neutral_raw": rec_f43raw["stdout_sha256"] == rec["stdout_sha256"],
            "receipt": parsed43.get("receipt") if isinstance(parsed43, dict) else None,
        }
    )
    commands.append(
        {
            "id": "raw/F43_in.json",
            "argv": rec_f43raw["argv"],
            "cwd": rec_f43raw["cwd"],
            "exit": rec_f43raw["exit"],
            "stdout_sha256": rec_f43raw["stdout_sha256"],
            "stderr_sha256": rec_f43raw["stderr_sha256"],
            "elapsed_seconds": rec_f43raw["elapsed_seconds"],
        }
    )
    (LOGS / "raw-F43_in.json.stdout").write_text(rec_f43raw["stdout"])
    (LOGS / "raw-F43_in.json.stderr").write_text(rec_f43raw["stderr"])

    # 4. observation-pair: reports from same bytes under F25 vs F43 names
    # Use the already-produced check outputs as JSON files
    left = WORKDIR / "pair_left_F25.json"
    right = WORKDIR / "pair_right_F43.json"
    shutil.copyfile(WORKDIR / "out-F25_in.json", left)
    shutil.copyfile(WORKDIR / "out-F43_in.json", right)
    rec_pair = lake_run("observation-pair", [left, right])
    parsed_pair, _ = parse_stdout_json(rec_pair["stdout"])
    probes.append(
        {
            "probe": "observation-pair/F25-vs-F43-reports",
            "mode": "observation-pair",
            "command": rec_pair,
            "parsed": parsed_pair,
            "note": "reportEq of checker outputs from identical input bytes under F25 vs F43 filenames",
        }
    )
    commands.append(
        {
            "id": "observation-pair/F25-vs-F43-reports",
            "argv": rec_pair["argv"],
            "cwd": rec_pair["cwd"],
            "exit": rec_pair["exit"],
            "stdout_sha256": rec_pair["stdout_sha256"],
            "stderr_sha256": rec_pair["stderr_sha256"],
            "elapsed_seconds": rec_pair["elapsed_seconds"],
        }
    )
    (LOGS / "pair-F25-F43.stdout").write_text(rec_pair["stdout"])
    (LOGS / "pair-F25-F43.stderr").write_text(rec_pair["stderr"])
    print(f"observation-pair F25 vs F43 reports: {parsed_pair}")

    # 5. Audit-mode envelopes
    audit_cases = {
        "F44_prod": (INPUTS / "F44_compact.json").read_bytes(),
        "F45_prod": (INPUTS / "F45_compact.json").read_bytes(),
        "F46_prod": (INPUTS / "F46_compact.json").read_bytes(),
        "F44_renamed_neutral": (INPUTS / "F44_compact.json").read_bytes(),
        "fake_passed_nary_prefix": json.dumps(
            {
                "commands": [
                    "#audit_axioms DefiKernel.Nary",
                    "#audit_axioms DefiKernel.Claims",
                    "#audit_axioms DefiKernel.Arithmetic",
                ],
                "imported_theorems_min": 1,
            },
            separators=(",", ":"),
        ).encode(),
        "claimed_nonempty_without_compiler": json.dumps(
            {"imported_theorems": 999, "prefix": "DefiKernel.Certificates"},
            separators=(",", ":"),
        ).encode(),
        "claimed_one_without_compiler": json.dumps(
            {"imported_theorems": 1, "prefix": "DefiKernel.Certificates"},
            separators=(",", ":"),
        ).encode(),
        "empty_forbidden_only": json.dumps({"forbidden_claimed_roots": []}, separators=(",", ":")).encode(),
        "forbidden_nary_plus_commands": json.dumps(
            {
                "commands": ["#audit_axioms DefiKernel.Certificates"],
                "forbidden_claimed_roots": ["DefiKernel.Nary"],
            },
            separators=(",", ":"),
        ).encode(),
        "valid_looking_compiler_record": json.dumps(
            {
                "schema_version": 1,
                "mode": "audit",
                "commands": [
                    "#audit_axioms DefiKernel.Certificates",
                    "#audit_axioms DefiKernel.Typed",
                    "#audit_axioms DefiKernel.Composition",
                ],
                "imported_theorems": 996,
                "imported_theorems_min": 1,
                "source_pin": {
                    "git": "a12b7cac05a818cc8d35c2ca440b7170a2807e92",
                    "lean_toolchain": "leanprover/lean4:v4.33.0-rc2",
                    "mathlib_rev": "51e6992efd06126df61a496bebf8f49482a4e129",
                    "checker_candidate": "/nonexistent/candidate.lean",
                    "compiler_record": {
                        "executable": "/nonexistent/lean",
                        "exit": 0,
                        "theorems": 996,
                    },
                    "audit_record": {"passed": True},
                },
            },
            separators=(",", ":"),
        ).encode(),
        "missing_candidate_path": json.dumps(
            {
                "commands": ["#audit_axioms DefiKernel.Certificates"],
                "imported_theorems_min": 1,
            },
            separators=(",", ":"),
        ).encode(),
    }

    for name, blob in audit_cases.items():
        if name == "F44_renamed_neutral":
            fname = "audit_neutral.json"
        elif name.endswith("_prod"):
            fname = name.replace("_prod", "_in.json")
        else:
            fname = name + ".json"
        path = WORKDIR / fname
        path.write_bytes(blob)
        rec = lake_run("check", [path])
        parsed, _ = parse_stdout_json(rec["stdout"])
        item = {
            "probe": f"audit/{name}",
            "mode": "check",
            "filename": fname,
            "input_sha256": sha256_bytes(blob),
            "input_bytes": blob.decode("utf-8"),
            "command": rec,
            "parsed": parsed,
            "summary": summarize_report(parsed),
            "compiler_invoked": "AXIOM AUDIT" in rec["stdout"] or "AXIOM AUDIT" in rec["stderr"],
        }
        probes.append(item)
        commands.append(
            {
                "id": item["probe"],
                "argv": rec["argv"],
                "cwd": rec["cwd"],
                "exit": rec["exit"],
                "stdout_sha256": rec["stdout_sha256"],
                "stderr_sha256": rec["stderr_sha256"],
                "elapsed_seconds": rec["elapsed_seconds"],
            }
        )
        (LOGS / f"audit-{name}.stdout").write_text(rec["stdout"])
        (LOGS / f"audit-{name}.stderr").write_text(rec["stderr"])
        print(
            f"audit {name}: exit={rec['exit']} summary={item['summary']} compiler_invoked={item['compiler_invoked']}"
        )

    # 6. Global Verify.lean control (campaign-level, not per-certificate)
    verify_rec = run_cmd(
        ["lake", "env", "lean", "DefiKernel/Certificates/Verify.lean"],
        LEAN,
        env_for_lean(),
        timeout=300,
    )
    audit_log = verify_rec["stdout"] + verify_rec["stderr"]
    (LOGS / "verify-lean.stdout").write_text(verify_rec["stdout"])
    (LOGS / "verify-lean.stderr").write_text(verify_rec["stderr"])
    ok, msg, scopes = runner.parse_and_validate_audit(audit_log, verify_rec["exit"])
    probes.append(
        {
            "probe": "global/Verify.lean",
            "mode": "lake-env-lean-Verify",
            "command": verify_rec,
            "parser_ok": ok,
            "parser_msg": msg,
            "scopes": scopes,
            "log_sha256": sha256_bytes(audit_log.encode()),
            "note": "Campaign-level compiler axiom scan. Not an argument to checkAudit/F44-F46.",
        }
    )
    commands.append(
        {
            "id": "global/Verify.lean",
            "argv": verify_rec["argv"],
            "cwd": verify_rec["cwd"],
            "exit": verify_rec["exit"],
            "stdout_sha256": verify_rec["stdout_sha256"],
            "stderr_sha256": verify_rec["stderr_sha256"],
            "elapsed_seconds": verify_rec["elapsed_seconds"],
        }
    )
    print(f"Verify.lean exit={verify_rec['exit']} parser_ok={ok} msg={msg}")

    # 7. Python audit-parser controls (synthetic; not compiler)
    control_errors = []
    try:
        runner.run_audit_validation_controls()
        controls_ok = True
        controls_err = None
    except Exception as e:
        controls_ok = False
        controls_err = repr(e)
        control_errors.append(controls_err)
    probes.append(
        {
            "probe": "python/audit-parser-controls",
            "ok": controls_ok,
            "error": controls_err,
            "note": "Five synthetic-string controls of parse_and_validate_audit. They do not call Lean checkAudit.",
        }
    )

    # Parser vs untrusted envelope: feed F44 check stdout to parser
    f44_out = (LOGS / "audit-F44_prod.stdout").read_text()
    ok_f44, msg_f44, scopes_f44 = runner.parse_and_validate_audit(f44_out, 0)
    probes.append(
        {
            "probe": "python/parser-on-F44-check-stdout",
            "ok": ok_f44,
            "msg": msg_f44,
            "scopes": scopes_f44,
            "note": "Production F44 checker stdout is an audit JSON envelope, not an axiom-audit log.",
        }
    )
    print(f"parser on F44 check stdout: ok={ok_f44} msg={msg_f44}")

    # 8. deep_compare one-way demonstration
    f25_expected = json.loads((SANDBOX / "openspec/changes/serialized-kernel-certificates/fixtures.json").read_text())
    f25 = next(x for x in f25_expected["fixtures"] if x["id"] == "F25")
    f43 = next(x for x in f25_expected["fixtures"] if x["id"] == "F43")
    actual_f25 = json.loads((WORKDIR / "out-F25_in.json").read_text())
    actual_f43 = json.loads((WORKDIR / "out-F43_in.json").read_text())
    match_f25_vs_f25e, diff_f25 = runner.deep_compare(actual_f25, f25["expected"])
    match_f43_vs_f43e, diff_f43 = runner.deep_compare(actual_f43, f43["expected"])
    match_f25_vs_f43e, diff_25_as_43 = runner.deep_compare(actual_f25, f43["expected"])
    match_f43_vs_f25e, diff_43_as_25 = runner.deep_compare(actual_f43, f25["expected"])
    match_neutral, diff_neutral = runner.deep_compare(
        json.loads((WORKDIR / "out-neutral_in.json").read_text()), f25["expected"]
    )
    match_neutral_as_43, diff_neutral_43 = runner.deep_compare(
        json.loads((WORKDIR / "out-neutral_in.json").read_text()), f43["expected"]
    )
    extra = dict(actual_f25)
    extra["__extra_uncompared__"] = "ignored"
    match_extra, diff_extra = runner.deep_compare(extra, f25["expected"])
    probes.append(
        {
            "probe": "deep_compare/filename-oracle-cross",
            "F25_actual_vs_F25_expected": {"match": match_f25_vs_f25e, "diff": diff_f25},
            "F43_actual_vs_F43_expected": {"match": match_f43_vs_f43e, "diff": diff_f43},
            "F25_actual_vs_F43_expected": {"match": match_f25_vs_f43e, "diff": diff_25_as_43},
            "F43_actual_vs_F25_expected": {"match": match_f43_vs_f25e, "diff": diff_43_as_25},
            "neutral_actual_vs_F25_expected": {"match": match_neutral, "diff": diff_neutral},
            "neutral_actual_vs_F43_expected": {"match": match_neutral_as_43, "diff": diff_neutral_43},
            "extra_key_in_actual_still_matches_F25_expected": {"match": match_extra, "diff": diff_extra},
            "note": "deep_compare walks expected keys only; extra actual fields are ignored.",
        }
    )
    print("deep_compare cross", json.dumps({
        "f25_vs_f25e": match_f25_vs_f25e,
        "f43_vs_f43e": match_f43_vs_f43e,
        "f25_vs_f43e": match_f25_vs_f43e,
        "f43_vs_f25e": match_f43_vs_f25e,
        "neutral_vs_f25e": match_neutral,
        "neutral_vs_f43e": match_neutral_as_43,
        "extra": match_extra,
    }))

    # 9. Toolchain identity
    ver = run_cmd(["lean", "--version"], LEAN, env_for_lean())
    gh = run_cmd(["lean", "--githash"], LEAN, env_for_lean())
    which = run_cmd(["which", "lean"], LEAN, env_for_lean())
    probes.append(
        {
            "probe": "toolchain/identity",
            "lean_version_stdout": ver["stdout"].strip(),
            "lean_githash_stdout": gh["stdout"].strip(),
            "which_lean": which["stdout"].strip(),
            "expected_githash": "d8b18978322de05a8f3dba51ef03cf5461676c17",
            "githash_match": gh["stdout"].strip() == "d8b18978322de05a8f3dba51ef03cf5461676c17",
        }
    )
    commands.extend(
        [
            {"id": "toolchain/lean --version", "argv": ver["argv"], "cwd": ver["cwd"], "exit": ver["exit"], "stdout_sha256": ver["stdout_sha256"], "stderr_sha256": ver["stderr_sha256"], "elapsed_seconds": ver["elapsed_seconds"]},
            {"id": "toolchain/lean --githash", "argv": gh["argv"], "cwd": gh["cwd"], "exit": gh["exit"], "stdout_sha256": gh["stdout_sha256"], "stderr_sha256": gh["stderr_sha256"], "elapsed_seconds": gh["elapsed_seconds"]},
        ]
    )

    write_json(OUT / "probes" / "probe-results.json", probes)
    write_json(OUT / "probes" / "probe-commands.json", commands)
    print(f"wrote {len(probes)} probes, {len(commands)} commands")


if __name__ == "__main__":
    main()
