#!/usr/bin/env python3
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from record_cmd import run_cmd

cmd_id = sys.argv[1]
source = sys.argv[2]
tool = sys.argv[3]
cwd = sys.argv[4]
timeout = int(sys.argv[5])
probe = sys.argv[6] if sys.argv[6] != "-" else None
argv = sys.argv[7:]
rec = run_cmd(
    cmd_id,
    argv,
    cwd,
    source=source,
    tool=tool,
    probe=probe,
    timeout=timeout if timeout > 0 else None,
    credit=True,
)
print(json.dumps({"id": rec["id"], "exit": rec["exit"], "start": rec["start"], "end": rec["end"], "stdout": rec["rawstdout_sha256"], "stderr": rec["rawstderr_sha256"]}))
raise SystemExit(rec["exit"])
