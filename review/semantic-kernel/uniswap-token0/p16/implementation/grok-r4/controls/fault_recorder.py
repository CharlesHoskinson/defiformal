#!/usr/bin/env python3
"""Diagnostic shim for grok-r4 R1 fault controls. Not a production recorder."""
import os
import shutil
import sys
from pathlib import Path

args = sys.argv[1:]
name = args[args.index("--name") + 1]
mode = os.environ["P16_R4_FAULT"]
target = "T0-ID-SKIP-designated-P16-I-ADD"
original = "/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908/scripts/token0_p16/record_cmd.py"
stale_src = Path(
    "/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908/"
    "review/semantic-kernel/uniswap-token0/p16/implementation/grok-r3/"
    "evm/mutants/T0-ID-SKIP/designated/P16-I-ADD/record"
)
if name == target:
    if mode == "missing-receipt":
        sys.exit(1)
    if mode == "malformed-receipt":
        Path(args[args.index("--out") + 1]).write_text("{bad json")
        sys.exit(1)
    if mode == "stale-receipt":
        for flag, filename in [
            ("--out", "receipt.json"),
            ("--stdout-path", "stdout.bin"),
            ("--stderr-path", "stderr.bin"),
        ]:
            shutil.copyfile(stale_src / filename, args[args.index(flag) + 1])
        sys.exit(1)
    if mode == "timeout":
        args[args.index("--timeout") + 1] = "0.05"
        args = args[: args.index("--") + 1] + [sys.executable, "-c", "import time; time.sleep(5)"]
    if mode in ["unknown-stdout", "crash-partial"]:
        code = (
            "print('unrecognized output')"
            if mode == "unknown-stdout"
            else "import os,signal;print('0x',flush=True);print('error: execution reverted',flush=True);os.kill(os.getpid(),signal.SIGKILL)"
        )
        args = args[: args.index("--") + 1] + [sys.executable, "-c", code]
os.execv(sys.executable, [sys.executable, "-B", original, *args])
