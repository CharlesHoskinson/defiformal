#!/usr/bin/env python3
"""Targeted overlay/policy probes. Private probe tree only. No sandbox writes."""
from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import time
from copy import deepcopy
from pathlib import Path

REV = Path("/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-overlay-grok-r1")
SANDBOX = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p19-overlay-grok-r1-sandbox")
TREE = REV / "probes/lean-tree"
WORKDIR = REV / "probes/workdir"
LOGDIR = REV / "logs"
LEAN = "/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin/lean"
LAKE = "/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin/lake"
ENV = os.environ.copy()
ENV["PATH"] = "/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin:/home/charl/.elan/bin:" + ENV.get("PATH", "")


def sha256_bytes(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


def sha256_text(s: str) -> str:
    return sha256_bytes(s.encode("utf-8"))


def deep_compare(actual, expected, path=""):
    if actual is None and expected is None:
        return True, ""
    if actual is None or expected is None:
        return False, f"Mismatch at {path}: actual {actual!r} expected {expected!r}"
    if isinstance(expected, dict):
        if not isinstance(actual, dict):
            return False, f"Mismatch at {path}: type"
        for k, v in expected.items():
            sub = f"{path}.{k}" if path else k
            if k not in actual:
                return False, f"Missing key {sub}"
            ok, diff = deep_compare(actual[k], v, sub)
            if not ok:
                return False, diff
        for k in actual:
            if k not in expected:
                return False, f"Unexpected key {k}"
        return True, ""
    if isinstance(expected, list):
        if not isinstance(actual, list) or len(actual) != len(expected):
            return False, f"List mismatch at {path}"
        for i, (a, e) in enumerate(zip(actual, expected)):
            ok, diff = deep_compare(a, e, f"{path}[{i}]")
            if not ok:
                return False, diff
        return True, ""
    if actual != expected:
        return False, f"Value mismatch at {path}: {actual!r} != {expected!r}"
    return True, ""


def canonicalize_json(obj):
    if not isinstance(obj, dict):
        return obj
    envelope_keys = [
        "schema_version", "mode", "source_pin", "audit_roots", "types", "assumptions",
        "invariants", "libraries", "source_map", "payload", "claimed_judgments",
        "claimed_next_state", "require_library_discharge", "require_invariant_discharge",
    ]
    if "mode" in obj and "source_pin" in obj:
        res = {}
        for k in envelope_keys:
            if k in obj:
                v = obj[k]
                if k == "source_map" and isinstance(v, dict):
                    res[k] = dict(sorted(v.items()))
                else:
                    res[k] = v
        return res
    return obj


def run_cmd(argv, cwd, ident):
    t0 = time.monotonic()
    proc = subprocess.run(argv, cwd=cwd, env=ENV, capture_output=True, text=True)
    elapsed = round(time.monotonic() - t0, 4)
    stdout_b = proc.stdout.encode("utf-8")
    stderr_b = proc.stderr.encode("utf-8")
    rec = {
        "id": ident,
        "argv": argv,
        "cwd": str(cwd),
        "tool": argv[0],
        "exit": proc.returncode,
        "elapsed_seconds": elapsed,
        "stdout_sha256": sha256_bytes(stdout_b),
        "stderr_sha256": sha256_bytes(stderr_b),
        "stdout": proc.stdout,
        "stderr": proc.stderr,
    }
    (LOGDIR / f"{ident}.stdout").write_bytes(stdout_b)
    (LOGDIR / f"{ident}.stderr").write_bytes(stderr_b)
    return rec


def main():
    WORKDIR.mkdir(parents=True, exist_ok=True)
    LOGDIR.mkdir(parents=True, exist_ok=True)
    fixtures = {f["id"]: f for f in json.loads(
        (SANDBOX / "openspec/changes/serialized-kernel-certificates/fixtures.json").read_text()
    )["fixtures"]}
    overlay = json.loads(
        (SANDBOX / "review/semantic-kernel/certificates/p19/implementation/agy-r5/fixture-canonical-order-overlay.json").read_text()
    )

    f13_orig = fixtures["F13"]["inputs"]["raw_utf8"].encode("utf-8")
    f13_over = overlay["overlays"]["F13"]["inputs"]["raw_utf8"].encode("utf-8")
    f28_orig = fixtures["F28"]["inputs"]["raw_utf8"].encode("utf-8")
    f28_over = overlay["overlays"]["F28"]["inputs"]["raw_utf8"].encode("utf-8")
    f25_obj = fixtures["F25"]["inputs"]
    f43_obj = fixtures["F43"]["inputs"]
    assert f25_obj == f43_obj
    f25_compact = json.dumps(f25_obj, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
    f25_canon = json.dumps(canonicalize_json(f25_obj), separators=(",", ":"), ensure_ascii=False).encode("utf-8")

    files = {
        "F13_orig.dat": f13_orig,
        "F13_overlay.dat": f13_over,
        "neutral_overlay.dat": f13_over,
        "xxF13yy.dat": f13_over,
        "F28_orig.dat": f28_orig,
        "F28_overlay.dat": f28_over,
        "neutral_in.json": f25_canon,
        "F25_in.json": f25_canon,
        "F43_in.json": f25_canon,
        "prefixF43suffix.json": f25_canon,
        "F430.json": f25_canon,
        "f43_lower.json": f25_canon,
        "not_the_fixture.json": f25_canon,
        "F25_python_compact.json": f25_compact,  # unsorted source_map object serialization
        "F17_in.json": json.dumps(canonicalize_json(fixtures["F17"]["inputs"]), separators=(",", ":"), ensure_ascii=False).encode(),
        "F29_in.json": json.dumps(canonicalize_json(fixtures["F29"]["inputs"]), separators=(",", ":"), ensure_ascii=False).encode(),
        "F30_in.json": json.dumps(canonicalize_json(fixtures["F30"]["inputs"]), separators=(",", ":"), ensure_ascii=False).encode(),
        "F36_in.json": json.dumps(canonicalize_json(fixtures["F36"]["inputs"]), separators=(",", ":"), ensure_ascii=False).encode(),
        "F41_in.json": json.dumps(canonicalize_json(fixtures["F41"]["inputs"]), separators=(",", ":"), ensure_ascii=False).encode(),
        "F08_in.json": json.dumps(canonicalize_json(fixtures["F08"]["inputs"]), separators=(",", ":"), ensure_ascii=False).encode(),
        "F49_in.json": json.dumps(canonicalize_json(fixtures["F49"]["inputs"]), separators=(",", ":"), ensure_ascii=False).encode(),
        "F27_in.json": json.dumps(canonicalize_json(fixtures["F27"]["inputs"]), separators=(",", ":"), ensure_ascii=False).encode(),
        "F33_in.json": json.dumps(canonicalize_json(fixtures["F33"]["inputs"]), separators=(",", ":"), ensure_ascii=False).encode(),
    }
    for name, b in files.items():
        (WORKDIR / name).write_bytes(b)

    commands = []

    def lake_run(mode, path, ident):
        argv = [LAKE, "env", LEAN, "--run", "DefiKernel/Certificates/RunFixtures.lean", mode, str(path)]
        rec = run_cmd(argv, TREE, ident)
        commands.append(rec)
        return rec

    # decode originals vs overlay
    for ident, fname in [
        ("decode/F13_orig", "F13_orig.dat"),
        ("decode/F13_overlay", "F13_overlay.dat"),
        ("decode/neutral_overlay", "neutral_overlay.dat"),
        ("decode/xxF13yy", "xxF13yy.dat"),
        ("decode/F28_orig", "F28_orig.dat"),
        ("decode/F28_overlay", "F28_overlay.dat"),
        ("decode/F25_canon_as_dat", "F25_in.json"),
        ("decode/F25_python_compact", "F25_python_compact.json"),
    ]:
        rec = lake_run("decode", WORKDIR / fname, ident.replace("/", "_"))
        rec["file"] = fname
        rec["file_sha256"] = sha256_bytes(files[fname])

    # filename oracle controls on check
    for ident, fname in [
        ("check/neutral", "neutral_in.json"),
        ("check/F25", "F25_in.json"),
        ("check/F43", "F43_in.json"),
        ("check/prefixF43suffix", "prefixF43suffix.json"),
        ("check/F430", "F430.json"),
        ("check/f43_lower", "f43_lower.json"),
        ("check/not_the_fixture", "not_the_fixture.json"),
        ("check/F17", "F17_in.json"),
        ("check/F29", "F29_in.json"),
        ("check/F30", "F30_in.json"),
        ("check/F36", "F36_in.json"),
        ("check/F41", "F41_in.json"),
        ("check/F08", "F08_in.json"),
        ("check/F49", "F49_in.json"),
        ("check/F27", "F27_in.json"),
        ("check/F33", "F33_in.json"),
    ]:
        rec = lake_run("check", WORKDIR / fname, ident.replace("/", "_"))
        rec["file"] = fname

    # IR equality probe
    argv = [LAKE, "env", LEAN, "--run", "DefiKernel/Certificates/ProbeIREq.lean",
            str(WORKDIR / "F13_overlay.dat"), str(WORKDIR / "F25_in.json")]
    rec = run_cmd(argv, TREE, "ireq_F13overlay_vs_F25canon")
    commands.append(rec)

    argv = [LAKE, "env", LEAN, "--run", "DefiKernel/Certificates/ProbeIREq.lean",
            str(WORKDIR / "F13_orig.dat"), str(WORKDIR / "F25_python_compact.json")]
    rec = run_cmd(argv, TREE, "ireq_F13orig_vs_F25compact")
    commands.append(rec)

    argv = [LAKE, "env", LEAN, "--run", "DefiKernel/Certificates/ProbeIREq.lean",
            str(WORKDIR / "F13_overlay.dat"), str(WORKDIR / "F13_overlay.dat")]
    rec = run_cmd(argv, TREE, "ireq_F13overlay_self")
    commands.append(rec)

    # parse check/decode results and compare independent expecteds
    def parse_stdout(ident):
        rec = next(c for c in commands if c["id"] == ident)
        try:
            return json.loads(rec["stdout"].strip().splitlines()[-1])
        except Exception as e:
            return {"_parse_error": str(e), "raw": rec["stdout"][:500]}

    comparisons = []

    def add_cmp(name, actual, expected):
        ok, diff = deep_compare(actual, expected)
        comparisons.append({"name": name, "match": ok, "diff": diff if not ok else None})
        return ok

    f13_over_actual = parse_stdout("decode_F13_overlay")
    f13_orig_actual = parse_stdout("decode_F13_orig")
    f28_over_actual = parse_stdout("decode_F28_overlay")
    f28_orig_actual = parse_stdout("decode_F28_orig")
    f25_actual = parse_stdout("check_F25")
    f43_actual = parse_stdout("check_F43")
    neutral_actual = parse_stdout("check_neutral")
    prefix_actual = parse_stdout("check_prefixF43suffix")

    # Independent overlay expecteds
    add_cmp("F13_overlay_vs_overlay_expected", f13_over_actual, overlay["overlays"]["F13"]["expected"])
    add_cmp("F13_overlay_vs_original_ir_label", f13_over_actual, fixtures["F13"]["expected"])
    add_cmp("F13_orig_vs_regression_expected", f13_orig_actual, overlay["regressions"][0]["expected"])
    add_cmp("F13_orig_vs_original_ok_expected", f13_orig_actual, fixtures["F13"]["expected"])
    add_cmp("F28_overlay_vs_overlay_expected", f28_over_actual, overlay["overlays"]["F28"]["expected"])
    add_cmp("F28_orig_vs_regression_expected", f28_orig_actual, overlay["regressions"][1]["expected"])

    f25_over_exp = overlay["overlays"]["F25"]["expected"]
    f25_orig_exp = fixtures["F25"]["expected"]
    f43_orig_exp = fixtures["F43"]["expected"]
    add_cmp("F25_actual_vs_overlay_expected", f25_actual, f25_over_exp)
    add_cmp("F25_actual_vs_original_empty_outstanding", f25_actual, f25_orig_exp)
    add_cmp("F43_actual_vs_F43_expected", f43_actual, f43_orig_exp)
    add_cmp("F25_actual_vs_F43_expected", f25_actual, f43_orig_exp)
    add_cmp("neutral_vs_F25_actual_object", neutral_actual, f25_actual)
    add_cmp("F43_vs_F25_actual_object", f43_actual, f25_actual)
    add_cmp("prefixF43_vs_F25_actual_object", prefix_actual, f25_actual)
    add_cmp("decode_overlay_named_F13_vs_neutral", parse_stdout("decode_F13_overlay"), parse_stdout("decode_neutral_overlay"))
    add_cmp("decode_overlay_xxF13yy_vs_neutral", parse_stdout("decode_xxF13yy"), parse_stdout("decode_neutral_overlay"))

    # deliberately incorrect important values must fail
    wrong_status = deepcopy(f25_over_exp)
    wrong_status["status"] = "refused"
    add_cmp("deliberate_wrong_status_must_fail", f25_actual, wrong_status)
    wrong_out = deepcopy(f25_over_exp)
    wrong_out["outstanding"] = []
    add_cmp("deliberate_wrong_empty_outstanding_must_fail", f25_actual, wrong_out)
    wrong_ir = deepcopy(overlay["overlays"]["F13"]["expected"])
    wrong_ir["result"]["ir"] = "DecodedIR of F25 payload"
    add_cmp("deliberate_F13_ir_label_vs_null_driver", f13_over_actual, wrong_ir)
    wrong_world = deepcopy(f25_over_exp)
    # flip alice usd 7 -> 8
    for cell in wrong_world["world"]["state"]["cells"]:
        if cell["party"] == "alice" and cell["asset"] == "usd" and cell["domain"] == "main":
            cell["amount"]["num"] = 8
            break
    add_cmp("deliberate_wrong_alice_usd_must_fail", f25_actual, wrong_world)

    # affected refusals vs overlay expected
    for fid, ident in [("F17", "check_F17"), ("F29", "check_F29"), ("F30", "check_F30"),
                       ("F36", "check_F36"), ("F41", "check_F41"), ("F08", "check_F08"),
                       ("F49", "check_F49"), ("F27", "check_F27"), ("F33", "check_F33")]:
        actual = parse_stdout(ident)
        exp = overlay["overlays"][fid]["expected"]
        add_cmp(f"{fid}_actual_vs_overlay_expected", actual, exp)
        # status/failure vs original
        orig = fixtures[fid]["expected"]
        comparisons.append({
            "name": f"{fid}_status_failure_vs_original",
            "actual_status": actual.get("status"),
            "original_status": orig.get("status"),
            "overlay_status": exp.get("status"),
            "actual_failure": actual.get("failure"),
            "original_failure": orig.get("failure"),
            "status_preserved": actual.get("status") == orig.get("status"),
            "failure_preserved": actual.get("failure") == orig.get("failure"),
            "actual_outstanding": actual.get("outstanding"),
            "overlay_outstanding": exp.get("outstanding"),
        })

    # filename stdout hashes
    filename_hashes = {
        rec["id"]: {"exit": rec["exit"], "stdout_sha256": rec["stdout_sha256"]}
        for rec in commands if rec["id"].startswith("check_")
    }

    out = {
        "file_hashes": {k: sha256_bytes(v) for k, v in files.items()},
        "f13_orig_matches_root": sha256_bytes(f13_orig) == "147d3f956a7c316338e151c11d679d953fb9b38aab30e08648c77d922c8c84c8",
        "f28_orig_matches_root": sha256_bytes(f28_orig) == "c3f1e7f3215967056e398a92ff31dc21bf574207d7fb987abfb99bfbefeb4bd9",
        "f13_overlay_sha256": sha256_bytes(f13_over),
        "f28_overlay_sha256": sha256_bytes(f28_over),
        "f25_canon_equals_f13_overlay": f25_canon == f13_over,
        "f25_compact_equals_f13_orig": f25_compact == f13_orig,
        "comparisons": comparisons,
        "filename_hashes": filename_hashes,
        "decode_samples": {
            "F13_orig": f13_orig_actual,
            "F13_overlay": f13_over_actual,
            "F28_orig": f28_orig_actual,
            "F28_overlay": f28_over_actual,
        },
        "check_samples": {
            "F25_status": f25_actual.get("status"),
            "F25_outstanding": f25_actual.get("outstanding"),
            "F25_failure": f25_actual.get("failure"),
            "F25_alice_usd": [c for c in (f25_actual.get("world") or {}).get("state", {}).get("cells", [])
                              if c.get("party") == "alice" and c.get("asset") == "usd" and c.get("domain") == "main"],
            "F43_outstanding": f43_actual.get("outstanding"),
            "neutral_outstanding": neutral_actual.get("outstanding"),
        },
        "ireq_stdout": {
            c["id"]: {"exit": c["exit"], "stdout": c["stdout"].strip(), "stderr_sha256": c["stderr_sha256"]}
            for c in commands if c["id"].startswith("ireq_")
        },
        "commands_brief": [
            {"id": c["id"], "argv": c["argv"], "cwd": c["cwd"], "exit": c["exit"],
             "stdout_sha256": c["stdout_sha256"], "stderr_sha256": c["stderr_sha256"],
             "elapsed_seconds": c["elapsed_seconds"]}
            for c in commands
        ],
    }
    (REV / "probes/probe-results.json").write_text(json.dumps(out, indent=2) + "\n")
    (REV / "probes/commands-raw.json").write_text(json.dumps(out["commands_brief"], indent=2) + "\n")
    print("wrote probe-results")
    print("comparisons:")
    for c in comparisons:
        if "match" in c:
            print(" ", c["name"], "MATCH" if c["match"] else "FAIL", c.get("diff"))
        else:
            print(" ", c)
    print("ireq", out["ireq_stdout"])
    print("check_samples", json.dumps(out["check_samples"]))
    print("decode F13 orig", f13_orig_actual)
    print("decode F13 overlay ir", f13_over_actual.get("result", {}).get("ir") if isinstance(f13_over_actual, dict) else f13_over_actual)


if __name__ == "__main__":
    main()
