#!/usr/bin/env python3
"""R5 receipt-fault relay. Provenance: sealed r4 review probes/receipt_fault_relay.py.

Performs a genuine frozen-recorder run, then applies one post-record mutation.
This tests consumer parsing and classification/exit consistency, not tool authenticity.
"""
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

args = sys.argv[1:]
name = args[args.index("--name") + 1]
mode = os.environ["P16_R5_RECEIPT_FAULT"]
original = "/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908/scripts/token0_p16/record_cmd.py"
result = subprocess.run([sys.executable, "-B", original, *args])
if name == "T0-ID-SKIP-designated-P16-I-ADD" and result.returncode == 0:
    path = Path(args[args.index("--out") + 1])
    receipt = json.loads(path.read_text())
    if mode == "unknown-error-output":
        stdout_path = Path(receipt["stdout_path"])
        stdout_path.write_text("error: unrecognized diagnostic failure\n")
        blob = stdout_path.read_bytes()
        receipt["stdout_sha256"] = hashlib.sha256(blob).hexdigest()
        receipt["stdout_bytes"] = len(blob)
    elif mode == "wrong-status":
        receipt["classification"] = "failure"
    elif mode == "wrong-argv":
        receipt["argv"] = ["wrong"]
    elif mode == "wrong-cwd":
        receipt["cwd"] = "/wrong"
    elif mode == "wrong-type":
        receipt["exit"] = False
    elif mode == "wrong-hash":
        receipt["stdout_sha256"] = "0" * 64
    path.write_text(json.dumps(receipt, indent=2) + "\n")
sys.exit(result.returncode)
