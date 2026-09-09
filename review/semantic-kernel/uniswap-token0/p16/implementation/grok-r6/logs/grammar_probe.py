#!/usr/bin/env python3
"""Direct classify_evm_stdout grammar probe. New grok-r6 output paths only."""
from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path("/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908")
sys.path.insert(0, str(ROOT / "scripts/token0_p16"))
from p16_evm import classify_evm_stdout  # noqa: E402

SUCCESS = {
    "valid": True,
    "timeout": False,
    "cancelled": False,
    "classification": "ok",
    "exit": 0,
    "_wrapper": {"wrapper_exit": 0},
}

CASES = [
    ("success", "0x0000000000000000000000000000000000000000000000000000000000000001\n", "token0_probe"),
    ("revert_blank_first", "\n error: execution reverted\n", "token0_probe"),
    ("invalid_blank_first", "\n error: invalid opcode: INVALID\n", "token0_probe"),
    ("revert_one_explicit_empty", "0x\nerror: execution reverted\n", "token0_probe"),
    ("invalid_one_explicit_empty", "0x\nerror: invalid opcode: INVALID\n", "token0_probe"),
    ("unknown", "error: unrecognized diagnostic failure\n", "token0_probe"),
    ("duplicate_abi", "0x" + "0" * 64 + "\n0x" + "0" * 64 + "\n", "token0_probe"),
    ("duplicate_error", "error: execution reverted\nerror: execution reverted\n", "token0_probe"),
    ("extra_text", "0x\nerror: execution reverted\nextra\n", "token0_probe"),
    ("duplicate_empty_invalid", "0x\n0x\nerror: invalid opcode: INVALID\n", "token0_probe"),
    ("duplicate_empty_revert", "0x\n0x\nerror: execution reverted\n", "token0_probe"),
    ("stop_blank", "\n", "genesis_stop"),
    ("stop_one_explicit_empty", "0x\n", "genesis_stop"),
]


def main() -> int:
    label = sys.argv[1] if len(sys.argv) > 1 else "probe"
    out = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("-")
    rows = []
    for name, stdout, purpose in CASES:
        classification = classify_evm_stdout(stdout, 0, False, receipt=SUCCESS, purpose=purpose)
        rows.append(
            {
                "name": name,
                "stdout": stdout,
                "purpose": purpose,
                "classification": classification,
            }
        )
    report = {
        "utc": datetime.now(timezone.utc).isoformat(),
        "label": label,
        "p16_evm": str(ROOT / "scripts/token0_p16/p16_evm.py"),
        "rows": rows,
    }
    text = json.dumps(report, indent=2) + "\n"
    if str(out) != "-":
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(text)
    print(json.dumps({row["name"]: row["classification"].get("class") for row in rows}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
