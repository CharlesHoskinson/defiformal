#!/usr/bin/env python3
"""Run one full source_campaign intact consumer with a duplicate-empty diagnostic relay.

Writes only under the supplied destination. Does not rewrite r3/r4/r5 evidence.
"""
from __future__ import annotations

import json
import os
import shutil
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path("/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908")
sys.path.insert(0, str(ROOT / "scripts/token0_p16"))
import p16_common as c  # noqa: E402
import source_campaign as s  # noqa: E402

CTRL = Path(__file__).resolve().parent
RELAY = CTRL / "duplicate_empty_relay.py"


def main() -> int:
    mode = sys.argv[1]
    dest = Path(sys.argv[2])
    if dest.exists():
        shutil.rmtree(dest)
    dest.mkdir(parents=True)
    saved = c.RECORDER
    os.environ["P16_R6_DUPLICATE_EMPTY"] = mode
    c.RECORDER = RELAY
    started = time.monotonic()
    start_utc = datetime.now(timezone.utc).isoformat()
    try:
        exit_code = s.mode_intact(dest)
    except Exception as exc:
        exit_code = 1
        (dest / "uncaught.txt").write_text(f"{type(exc).__name__}: {exc}\n")
    finally:
        c.RECORDER = saved
        os.environ.pop("P16_R6_DUPLICATE_EMPTY", None)
    seconds = time.monotonic() - started
    score_path = dest / "campaign-score.json"
    score = json.loads(score_path.read_text()) if score_path.is_file() else None
    wrapper = {
        "argv": [sys.executable, "-B", str(Path(__file__)), mode, str(dest)],
        "actual_exit": exit_code,
        "seconds": seconds,
        "start_utc": start_utc,
        "end_utc": datetime.now(timezone.utc).isoformat(),
        "mode": mode,
        "dest": str(dest),
        "relay": str(RELAY),
        "recorder_during_run": str(RELAY),
        "frozen_recorder": "/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908/scripts/token0_p16/record_cmd.py",
        "fault": (
            "Duplicate explicit empty 0x payload records before a recognized EVM error; "
            "genuine recorder/EVM invocation first, then receipt byte count/hash updated"
        ),
        "python_diagnostic_credit": False,
        "production_mutation": False,
        "score": score,
    }
    (dest / "wrapper-receipt.json").write_text(json.dumps(wrapper, indent=2) + "\n")
    print(json.dumps({"mode": mode, "actual_exit": exit_code, "score_exit": None if score is None else score.get("exit")}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
