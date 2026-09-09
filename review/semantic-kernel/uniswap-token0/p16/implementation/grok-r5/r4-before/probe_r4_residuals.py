#!/usr/bin/env python3
"""Parser/scorer residual probe against the live consumer.

This is not a production recorder. It records whether the sealed r4 R1/R2
inputs currently score as the required blocked 3 / fail 1 outcomes.
"""
from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path("/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908")
sys.path.insert(0, str(ROOT / "scripts/token0_p16"))
import p16_common as c
import p16_evm as e
import source_campaign as s

HERE = Path(__file__).resolve().parent
R4_RUNTIME = (
    ROOT
    / "review/semantic-kernel/uniswap-token0/p16/implementation/grok-r4/lean/runtime/stdout.bin"
)
R4_BIND = (
    ROOT
    / "review/semantic-kernel/uniswap-token0/p16/implementation/grok-r4/lean/bindings/stdout.bin"
)
CN_STDOUT = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/"
    "p16-source-r4-review/faults2/compiler-nonzero/lean/bindings/stdout.bin"
)
ME_STDOUT = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/"
    "p16-source-r4-review/faults2/malformed-extra/lean/bindings/stdout.bin"
)


def ok_receipt(*, classification="ok", exit_code=0, wrapper_exit=0) -> dict:
    return {
        "valid": True,
        "timeout": False,
        "cancelled": False,
        "classification": classification,
        "exit": exit_code,
        "_wrapper": {"wrapper_exit": wrapper_exit},
    }


def record(name: str, got: int, want: int, extra: dict | None = None) -> dict:
    return {
        "name": name,
        "got_exit": got,
        "want_exit": want,
        "discriminates_r4": got != want,
        "matches_required": got == want,
        **(extra or {}),
    }


def main() -> int:
    fixtures = c.load_fixtures()
    rows = []
    runtime_text = R4_RUNTIME.read_text(errors="replace")
    bind_text = R4_BIND.read_text(errors="replace")
    cn_text = CN_STDOUT.read_text(errors="replace")
    me_text = ME_STDOUT.read_text(errors="replace")

    rt_ok = s.parse_runtime_audit(runtime_text)
    rows.append(record("runtime-intact-lake-output", rt_ok.get("exit", 3), 0, {"status": rt_ok.get("status")}))

    rt_extra = s.parse_runtime_audit(runtime_text + "P16-ADD malformed extra protocol row\n")
    rows.append(
        record(
            "runtime-malformed-extra-row",
            rt_extra.get("exit", 3),
            3,
            {"status": rt_extra.get("status"), "reason": rt_extra.get("reason")},
        )
    )

    bind_ok = s.parse_lean_bindings(bind_text, fixtures)
    rows.append(record("bindings-intact", bind_ok.get("exit", 3), 0, {"status": bind_ok.get("status")}))

    bind_extra = s.parse_lean_bindings(me_text, fixtures)
    rows.append(
        record(
            "bindings-malformed-extra-row",
            bind_extra.get("exit", 3),
            3,
            {"status": bind_extra.get("status"), "reason": bind_extra.get("reason")},
        )
    )

    parsed_cn = s.parse_lean_bindings(cn_text, fixtures)
    scored_cn = s.score_lean_execution(
        ok_receipt(classification="failure", exit_code=1, wrapper_exit=1),
        parsed_cn,
    )
    rows.append(
        record(
            "score-lean-compiler-nonzero-after-valid-rows",
            scored_cn.get("exit", 3),
            3,
            {
                "status": scored_cn.get("status"),
                "parsed_status": parsed_cn.get("status"),
                "child_exit": scored_cn.get("child_exit"),
                "wrapper_exit": scored_cn.get("wrapper_exit"),
                "reason": scored_cn.get("reason"),
            },
        )
    )

    false_text = bind_text.replace(
        "P16-ADD sqrtP=79228162514264337593543950336 L=1 amount=1 add=true model=ok:39614081257132168796771975168 match=true",
        "P16-ADD sqrtP=79228162514264337593543950336 L=1 amount=1 add=true model=ok:39614081257132168796771975168 match=false",
        1,
    ).replace("P16 source-binding comparisons: 12 of 12\n0\n", "P16 source-binding comparison failed\n1\n")
    parsed_false = s.parse_lean_bindings(false_text, fixtures)
    scored_false = s.score_lean_execution(ok_receipt(), parsed_false)
    rows.append(
        record(
            "score-lean-semantic-false-compiler-0",
            scored_false.get("exit", 3),
            1,
            {
                "status": scored_false.get("status"),
                "printed_uint32": parsed_false.get("printed_uint32"),
            },
        )
    )

    unknown = e.classify_evm_stdout(
        "error: unrecognized diagnostic failure\n",
        0,
        False,
        receipt=ok_receipt(),
        purpose="token0_probe",
    )
    unknown_exit = 3 if unknown.get("status") == "blocked" else (0 if unknown.get("class") == "evm_exception" else 1)
    rows.append(
        record(
            "evm-unknown-error-output",
            unknown_exit,
            3,
            {"class": unknown.get("class"), "status": unknown.get("status"), "returndata": unknown.get("returndata")},
        )
    )

    revert = e.classify_evm_stdout(
        "\n error: execution reverted\n",
        0,
        False,
        receipt=ok_receipt(),
        purpose="token0_probe",
    )
    revert_exit = 0 if revert.get("class") == "evm_revert" else 3
    rows.append(record("evm-execution-reverted", revert_exit, 0, {"class": revert.get("class")}))

    invalid = e.classify_evm_stdout(
        "\n error: invalid opcode: INVALID\n",
        0,
        False,
        receipt=ok_receipt(),
        purpose="token0_probe",
    )
    invalid_exit = 0 if invalid.get("class") == "evm_exception" else 3
    rows.append(record("evm-invalid-opcode", invalid_exit, 0, {"class": invalid.get("class")}))

    stop = e.classify_evm_stdout("\n", 0, False, receipt=ok_receipt(), purpose="genesis_stop")
    stop_exit = 0 if stop.get("class") == "stop_smoke" else 3
    rows.append(record("evm-stop-smoke", stop_exit, 0, {"class": stop.get("class")}))

    wrong_status = e.classify_evm_stdout(
        "\n error: invalid opcode: INVALID\n",
        0,
        False,
        receipt=ok_receipt(classification="failure", exit_code=0, wrapper_exit=0),
        purpose="token0_probe",
    )
    ws_exit = 3 if wrong_status.get("status") == "blocked" else 0
    rows.append(
        record(
            "evm-wrong-status-failure-with-child-0",
            ws_exit,
            3,
            {"class": wrong_status.get("class"), "status": wrong_status.get("status")},
        )
    )

    complete_nonzero = c.invocation_is_complete(ok_receipt(classification="failure", exit_code=1, wrapper_exit=1))
    success_nonzero = hasattr(c, "invocation_is_successful") and c.invocation_is_successful(
        ok_receipt(classification="failure", exit_code=1, wrapper_exit=1)
    )
    rows.append(
        record(
            "complete-nonzero-is-not-success",
            0 if (complete_nonzero and not success_nonzero) else 1,
            0,
            {"invocation_is_complete": complete_nonzero, "invocation_is_successful": success_nonzero},
        )
    )

    report = {
        "utc": datetime.now(timezone.utc).isoformat(),
        "consumer": "live scripts/token0_p16 at probe time",
        "rows": rows,
        "required_all_match": all(r["matches_required"] for r in rows),
        "r4_residuals_still_present": any(r["discriminates_r4"] for r in rows),
    }
    (HERE / "parser-scorer-probe.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({"required_all_match": report["required_all_match"], "rows": [
        {"name": r["name"], "got": r["got_exit"], "want": r["want_exit"], "ok": r["matches_required"]} for r in rows
    ]}, indent=2))
    return 0 if report["required_all_match"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
