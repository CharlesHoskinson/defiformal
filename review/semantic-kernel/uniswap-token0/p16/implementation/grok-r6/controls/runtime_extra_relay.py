#!/usr/bin/env python3
"""Append a malformed extra RuntimeAudit protocol row after a genuine lake run."""
from __future__ import annotations

import hashlib
import json
import subprocess
import sys
from pathlib import Path

args = sys.argv[1:]
name = args[args.index("--name") + 1]
original = "/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908/scripts/token0_p16/record_cmd.py"
result = subprocess.run([sys.executable, "-B", original, *args])
if name == "lake-runtime-r4" and result.returncode == 0:
    path = Path(args[args.index("--out") + 1])
    receipt = json.loads(path.read_text())
    stdout_path = Path(receipt["stdout_path"])
    stdout_path.write_bytes(stdout_path.read_bytes() + b"P16-ADD malformed extra protocol row\n")
    blob = stdout_path.read_bytes()
    receipt["stdout_sha256"] = hashlib.sha256(blob).hexdigest()
    receipt["stdout_bytes"] = len(blob)
    path.write_text(json.dumps(receipt, indent=2) + "\n")
sys.exit(result.returncode)
