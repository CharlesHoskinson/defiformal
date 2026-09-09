#!/usr/bin/env python3
"""R6 duplicate-empty diagnostic relay.

Genuine frozen-recorder EVM invocation first, then receipt-consistent replacement
of designated stdout with duplicate explicit empty 0x records before a known
error. Diagnostic input fault only; not a production mutant or tool authenticity
claim.
"""
from __future__ import annotations

import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

PAYLOADS = {
    "duplicate-empty-invalid": (
        "T0-ID-SKIP-designated-P16-I-ADD",
        "0x\n0x\nerror: invalid opcode: INVALID\n",
    ),
    "duplicate-empty-revert": (
        "baseline-P16-REQ",
        "0x\n0x\nerror: execution reverted\n",
    ),
}

args = sys.argv[1:]
name = args[args.index("--name") + 1]
mode = os.environ["P16_R6_DUPLICATE_EMPTY"]
original = "/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908/scripts/token0_p16/record_cmd.py"
result = subprocess.run([sys.executable, "-B", original, *args])
target, text = PAYLOADS[mode]
if name == target and result.returncode == 0:
    path = Path(args[args.index("--out") + 1])
    receipt = json.loads(path.read_text())
    stdout_path = Path(receipt["stdout_path"])
    stdout_path.write_text(text)
    blob = stdout_path.read_bytes()
    receipt["stdout_sha256"] = hashlib.sha256(blob).hexdigest()
    receipt["stdout_bytes"] = len(blob)
    path.write_text(json.dumps(receipt, indent=2) + "\n")
sys.exit(result.returncode)
