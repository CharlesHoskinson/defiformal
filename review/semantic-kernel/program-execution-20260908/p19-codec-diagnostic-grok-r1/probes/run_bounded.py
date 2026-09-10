#!/usr/bin/env python3
from pathlib import Path
import subprocess, time, os, signal, json, sys, datetime, hashlib

r = Path(__file__).parent.parent / "logs"
r.mkdir(parents=True, exist_ok=True)
cwd = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p19-codec-diagnostic-grok-r1-sandbox/lean")
name = sys.argv[1]
limit = float(sys.argv[2])
argv = sys.argv[3:]
t = time.monotonic()
p = subprocess.Popen(
    argv,
    cwd=cwd,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    start_new_session=True,
    env={**os.environ, "LEAN_ABORT_ON_PANIC": "1"},
)
expired = False
try:
    o, e = p.communicate(timeout=limit)
except subprocess.TimeoutExpired:
    expired = True
    os.killpg(p.pid, signal.SIGKILL)
    o, e = p.communicate()
(r / (name + ".stdout")).write_bytes(o)
(r / (name + ".stderr")).write_bytes(e)
d = {
    "utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "name": name,
    "argv": argv,
    "cwd": str(cwd),
    "timeout_limit": limit,
    "timeout": expired,
    "exit": p.returncode,
    "seconds": time.monotonic() - t,
    "process_group_killed_on_timeout": expired,
    "stdout_sha256": hashlib.sha256(o).hexdigest(),
    "stderr_sha256": hashlib.sha256(e).hexdigest(),
    "stdout_bytes": len(o),
    "stderr_bytes": len(e),
}
(r / (name + ".json")).write_text(json.dumps(d, indent=2) + "\n")
print(json.dumps(d, indent=2))
print("---stdout tail---")
print(o.decode(errors="replace")[-8000:])
print("---stderr tail---")
print(e.decode(errors="replace")[-4000:])
sys.exit(0)
