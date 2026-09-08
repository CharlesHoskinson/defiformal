#!/usr/bin/env python3
"""Owned descendant for recorder timeout/liveness control. Writes grandchild PID then sleeps."""
from __future__ import annotations

import os
import sys
import time
from pathlib import Path


def main() -> int:
    if len(sys.argv) < 2:
        print("missing pid-path", file=sys.stderr)
        return 3
    pid_path = Path(sys.argv[1])
    pid_path.parent.mkdir(parents=True, exist_ok=True)
    child_pid = os.fork()
    if child_pid == 0:
        time.sleep(30)
        os._exit(0)
    pid_path.write_text(str(child_pid) + "\n")
    time.sleep(30)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
