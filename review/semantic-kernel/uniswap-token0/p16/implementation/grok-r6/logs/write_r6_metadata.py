#!/usr/bin/env python3
"""Assemble r6 commands, integrity, remaining-gates, scenario, and result JSON."""
from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path("/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908")
EV = ROOT / "review/semantic-kernel/uniswap-token0/p16/implementation/grok-r6"
PRIMARY = Path("/home/charl/defiformal/review/semantic-kernel/program-execution-20260908")


def sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main() -> int:
    scripts = {
        "p16_evm.py": ROOT / "scripts/token0_p16/p16_evm.py",
        "p16_common.py": ROOT / "scripts/token0_p16/p16_common.py",
        "source_campaign.py": ROOT / "scripts/token0_p16/source_campaign.py",
        "p16_compile.py": ROOT / "scripts/token0_p16/p16_compile.py",
        "p16_mutants.py": ROOT / "scripts/token0_p16/p16_mutants.py",
        "record_cmd.py": ROOT / "scripts/token0_p16/record_cmd.py",
        "Token0Probe.sol": ROOT / "scripts/token0_p16/Token0Probe.sol",
        "test_record_cmd.py": ROOT / "scripts/token0_p16/test_record_cmd.py",
        "timeout_descendant.py": ROOT / "scripts/token0_p16/timeout_descendant.py",
    }
    post = {k: {"sha256": sha(p), "bytes": p.stat().st_size} for k, p in scripts.items()}
    (EV / "snapshots" / "r6-consumer-hashes.json").write_text(
        json.dumps({"utc": datetime.now(timezone.utc).isoformat(), "files": post}, indent=2) + "\n"
    )
    pre = json.loads((EV / "snapshots" / "pre-repair-hashes.json").read_text())["files"]
    unchanged = {k: pre[k]["sha256"] == post[k]["sha256"] for k in pre if k != "p16_evm.py"}
    hist = {}
    for name in ("grok-r3", "grok-r4", "grok-r5"):
        p = ROOT / "review/semantic-kernel/uniswap-token0/p16/implementation" / name / "REPORT.md"
        hist[name] = {"path": str(p), "sha256": sha(p), "bytes": p.stat().st_size}

    r5_archive = PRIMARY / "p16-source-candidate-r5.tar.gz"
    r5_sha = sha(r5_archive) if r5_archive.is_file() else None
    tr = json.loads((EV / "logs" / "tool-rehash.json").read_text())

    commands = []
    skipped = []
    receipt_roots = [
        EV / "controls" / "recorder",
        EV / "logs" / "setup",
        EV / "evm" / "baseline",
        EV / "evm" / "mutants",
        EV / "lean",
    ]
    for base in receipt_roots:
        if not base.exists():
            continue
        for recp in sorted(base.rglob("receipt.json")):
            rel = recp.relative_to(EV)
            try:
                rec = json.loads(recp.read_text())
            except json.JSONDecodeError:
                skipped.append(str(rel))
                continue
            wrap = rec.get("_wrapper") or {}
            commands.append(
                {
                    "name": rec.get("name"),
                    "argv": rec.get("argv"),
                    "cwd": rec.get("cwd"),
                    "start_utc": rec.get("start_utc"),
                    "end_utc": rec.get("end_utc"),
                    "exit": rec.get("exit"),
                    "timeout": rec.get("timeout"),
                    "classification": rec.get("classification"),
                    "receipt": str(rel),
                    "stdout_sha256": rec.get("stdout_sha256"),
                    "stderr_sha256": rec.get("stderr_sha256"),
                    "wrapper_exit": wrap.get("wrapper_exit"),
                }
            )
    (EV / "commands.json").write_text(json.dumps({"commands": commands}, indent=2) + "\n")

    setup_start = json.loads((EV / "logs" / "setup" / "solc-version" / "receipt.json").read_text())["start_utc"]
    bind_end = json.loads((EV / "lean" / "bindings" / "receipt.json").read_text())["end_utc"]
    score = json.loads((EV / "campaign-score.json").read_text())
    (EV / "logs" / "intact-invocation.json").write_text(
        json.dumps(
            {
                "argv": [
                    "python3",
                    "-B",
                    "scripts/token0_p16/source_campaign.py",
                    "--mode",
                    "intact",
                    "--evidence",
                    str(EV),
                ],
                "cwd": str(ROOT),
                "start_utc": setup_start,
                "end_utc": bind_end,
                "exit": score.get("exit"),
                "score": "review/semantic-kernel/uniswap-token0/p16/implementation/grok-r6/campaign-score.json",
                "score_sha256": sha(EV / "campaign-score.json"),
            },
            indent=2,
        )
        + "\n"
    )

    mm = json.loads((EV / "controls" / "mismatch" / "result.json").read_text())
    first_cli = json.loads((EV / "logs" / "cli-driver.json").read_text())
    (EV / "controls" / "cli-summary.json").write_text(
        json.dumps(
            {
                "first_batch": [
                    {k: r[k] for k in ("mode", "actual_exit", "expected_exit", "ok", "seconds", "start_utc", "end_utc")}
                    for r in first_cli
                ],
                "mismatch_retry_after_intact": {
                    "actual_exit": mm.get("exit"),
                    "expected_exit": 1,
                    "ok": mm.get("exit") == 1,
                    "status": mm.get("status"),
                    "actual_uint160": mm.get("actual_uint160"),
                },
            },
            indent=2,
        )
        + "\n"
    )

    dup_inv = json.loads((EV / "controls" / "duplicate-empty-invalid" / "wrapper-receipt.json").read_text())
    dup_rev = json.loads((EV / "controls" / "duplicate-empty-revert" / "wrapper-receipt.json").read_text())
    dup_inv_b = json.loads((EV / "controls" / "duplicate-empty-invalid-before" / "wrapper-receipt.json").read_text())
    dup_rev_b = json.loads((EV / "controls" / "duplicate-empty-revert-before" / "wrapper-receipt.json").read_text())
    fault = json.loads((EV / "controls" / "fault-campaign-summary.json").read_text())
    (EV / "controls" / "summary.json").write_text(
        json.dumps(
            {
                "cli": {
                    "empty_selection_exit": 3,
                    "malformed_exit": 3,
                    "missing_tool_exit": 3,
                    "fixture_omission_exit": 3,
                    "fixture_type_error_exit": 3,
                    "fixture_extra_exit": 3,
                    "recorder_controls_exit": 0,
                    "lean_text_exit": 0,
                    "mismatch_exit_after_intact": 1,
                    "mismatch_exit_before_intact_failed_attempt": 3,
                },
                "real_campaigns": {
                    "compiler_nonzero_campaign_exit": 3,
                    "malformed_extra_campaign_exit": 3,
                    "runtime_extra_campaign_exit": 3,
                    "wrong_status_campaign_exit": 3,
                    "unknown_error_output_campaign_exit": 3,
                    "lean_false_campaign_exit": 1,
                    "duplicate_empty_invalid_before_exit": dup_inv_b["actual_exit"],
                    "duplicate_empty_revert_before_exit": dup_rev_b["actual_exit"],
                    "duplicate_empty_invalid_after_exit": dup_inv["actual_exit"],
                    "duplicate_empty_revert_after_exit": dup_rev["actual_exit"],
                },
                "intact_exit": score.get("exit"),
                "fault_all_ok": fault.get("all_ok"),
                "note": "mismatch first CLI batch blocked 3 because intact P16-ADD was not yet present; retry after intact fails 1 as required",
            },
            indent=2,
        )
        + "\n"
    )

    remaining = {
        "this_increment": "P16 r6 source-campaign repair of remaining sealed r5 R1 duplicate-empty payload cardinality",
        "gate_accepted": False,
        "independent_gpt6": "required_not_run_on_this_source_candidate",
        "self_accepted": False,
        "rejected_r5": {
            "archive": str(r5_archive),
            "sha256": r5_sha,
            "verdict": "CHANGES_REQUIRED",
            "review": str(PRIMARY / "p16-source-r5-review/REVIEW.md"),
            "required_repairs": ["R1"],
            "bytes_rewritten": False,
        },
        "rejected_r4": {
            "archive": str(PRIMARY / "p16-source-candidate-r4.tar.gz"),
            "sha256": "b5a344f2db9f73dfe4d6a0aa17e46985cdb49cc431740a6312274561c82c6221",
            "bytes_rewritten": False,
        },
        "rejected_r3": {
            "archive": str(PRIMARY / "p16-source-candidate-r3.tar.gz"),
            "sha256": "95051fd2f33381231740c49d151551d65be4177a72ddb228ca6874962379326c",
            "bytes_rewritten": False,
        },
        "proof_recorder_r2": {
            "archive": str(PRIMARY / "p16-proof-recorder-candidate-r2.tar.gz"),
            "sha256": "62a2b86a3148a38cc9db59658a6843723a81454d8732eae8b23344f2309a1ec8",
            "files": 197,
            "mismatches": (tr.get("frozen_candidate_files") or {}).get("mismatches"),
            "bytes_edited_this_batch": False,
        },
        "p16_implementation_open_until_independent_review": [
            "independent GPT-6 review of this r6 source/mutant repair candidate",
            "root integration of accepted exact bytes to semantic-kernel-pivot only",
        ],
        "named_remainders": {
            "P17": "Typed wrapper / platform-reuse; function reuse alone is insufficient. P17 substantive reuse gates wider families.",
            "P18": "packet/example publication follows accepted P16; not inverted into a publication prerequisite",
            "P21": [
                "original 2.1 signed/tick/fee/F45 residual",
                "token1/delta",
                "TickMath",
                "SwapMath including compiled M09",
                "bitmap/liquidity/factory",
                "original 45-fixture campaign remainder F10-F45 excluding FullMath F01-F09 substrate and token0 P16 fixtures",
                "compiled M01-M12",
                "original mixed liquidity 1.2 whole-task until residual planning review",
            ],
            "P30": "source/assembly refinement; a finite source comparison is not a universal refinement proof. Hardcoded replay paths are a known limit, not a request to widen into the P30 platform harness in this repair.",
            "G-FULLMATH-ASSEMBLY": "assembly mulmod/CRT not proved equal to Rounding.mulDiv",
            "G-UNSAFEMATH-ZERO": "source comment y=0 unspecified; distinct from public-helper fallback reachability",
            "G-UINT160-UNCHECKED-DOWNCAST": "add-path source bare uint160 truncates; no invented source refusal",
            "G-NO-DEPLOYMENT": "no chain/address/bytecode deployment claim",
        },
        "hardcoded_replay_limits": [
            "p16_common.ROOT is this worktree",
            "p16_common.PRIMARY is /home/charl/defiformal/review/semantic-kernel/program-execution-20260908",
            "p16_common.TOOLS is /home/charl/.cache/defiformal-program/program-execution-20260908/p16-tools",
            "p16_common.EVIDENCE default remains grok-r5; this r6 run passed --evidence grok-r6",
            "W16/private tool-cache and frozen r2 archive paths are replay-bound, not a request to widen P30",
        ],
        "must_not_claim": [
            "compiled M09 as P16",
            "Python as source execution",
            "whole original library acceptance",
            "P17.platform_reuse",
            "source refinement",
            "self-acceptance of this candidate",
            "operation credit before independent GPT-6 review",
            "compiler failure as semantic disagreement",
            "diagnostic output corruption as a production mutant",
        ],
    }
    (EV / "remaining-gates.json").write_text(json.dumps(remaining, indent=2) + "\n")

    scenario = {
        "status": "source_campaign_r6_repair_pending_independent_review",
        "scenarios": [
            {
                "spec": "token0-source-readiness",
                "scenario": "Archive hash matches CURRENT.json",
                "class": "diagnostic",
                "evidence": "setup tool-rehash; r5 rejected archive 235e9a0f preserved unreadited",
            },
            {
                "spec": "token0-next-price-observation",
                "scenario": "Planned add sibling",
                "class": "finite",
                "evidence": "P16-ADD source uint160 39614081257132168796771975168",
            },
            {
                "spec": "token0-next-price-observation",
                "scenario": "Removal denominator require",
                "class": "finite",
                "evidence": "intact P16-REQ evm_revert empty returndata 0x from pinned blank first line; model subUnderflow is not the payload",
            },
            {
                "spec": "token0-mutation-control-plan",
                "scenario": "Skip identity short-circuit mutant",
                "class": "mutation",
                "evidence": "T0-ID-SKIP designated P16-I-ADD INVALID; P16-ADD unaffected",
            },
            {
                "spec": "r1-duplicate-empty-payload",
                "scenario": "Duplicate explicit 0x before INVALID is blocked 3",
                "class": "finite",
                "evidence": "controls/duplicate-empty-invalid campaign exit 3; mutants 5 ok / 0 fail / 1 blocked; before-repair exit 0",
            },
            {
                "spec": "r1-duplicate-empty-payload",
                "scenario": "Duplicate explicit 0x before execution reverted is blocked 3",
                "class": "finite",
                "evidence": "controls/duplicate-empty-revert campaign exit 3; baseline 11 ok / 0 fail / 1 blocked; before-repair exit 0",
            },
            {
                "spec": "r1-duplicate-empty-payload",
                "scenario": "Pinned blank first returndata and one explicit empty remain recognized",
                "class": "finite",
                "evidence": "logs/grammar-boundaries-after.json revert/invalid blank-first and one-explicit-empty; genesis-smoke stop_smoke",
            },
            {
                "spec": "r1-successful-execution",
                "scenario": "Lean error after valid rows is blocked 3 not semantic 0",
                "class": "finite",
                "evidence": "controls/compiler-nonzero campaign exit 3; child 1 wrapper 1 classification failure",
            },
            {
                "spec": "r2-complete-protocol",
                "scenario": "Well-formed false Lean comparison fails 1; printed UInt32 is not the process exit",
                "class": "finite",
                "evidence": "controls/lean-false exit 1 wrapper 0 child 0 printed_uint32 1",
            },
            {
                "spec": "token0-planning-evidence",
                "scenario": "Author freeze is not self-acceptance",
                "class": "assumption",
                "evidence": "result.json pending independent GPT-6; gate_accepted false",
            },
        ],
    }
    (EV / "scenario-map.json").write_text(json.dumps(scenario, indent=2) + "\n")

    integrity = {
        "utc": datetime.now(timezone.utc).isoformat(),
        "p16_evm_changed": pre["p16_evm.py"]["sha256"] != post["p16_evm.py"]["sha256"],
        "p16_evm_before": pre["p16_evm.py"]["sha256"],
        "p16_evm_after": post["p16_evm.py"]["sha256"],
        "other_pre_repair_scripts_unchanged": unchanged,
        "historical_reports_untouched": hist,
        "r5_archive_path": str(r5_archive),
        "r5_archive_sha256": r5_sha,
        "r5_archive_expected": "235e9a0f0aaf18342bc3d99bcb1fa13723e6144dfcc47e8523fc11d8b0da4f7a",
        "r5_archive_match": r5_sha == "235e9a0f0aaf18342bc3d99bcb1fa13723e6144dfcc47e8523fc11d8b0da4f7a",
        "frozen_r2_files": tr.get("frozen_candidate_files"),
        "tool_rehash_ready": tr.get("ready"),
        "commands_count": len(commands),
        "skipped_nonjson_receipts": skipped,
    }
    (EV / "logs" / "integrity.json").write_text(json.dumps(integrity, indent=2) + "\n")
    print(json.dumps({k: integrity[k] for k in ("p16_evm_after", "other_pre_repair_scripts_unchanged", "r5_archive_match", "frozen_r2_files", "commands_count", "skipped_nonjson_receipts")}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
