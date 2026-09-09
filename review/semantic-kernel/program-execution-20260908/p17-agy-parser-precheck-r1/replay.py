"""Root parser diagnostic against immutable inputs, not P17 acceptance."""
import hashlib
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / "inputs/platform_engine"))
from evm import classify_evm_stdout

rows = []

def check(name, stdout, expected_status, expected_error=None):
    got = classify_evm_stdout(stdout, 0, False)
    ok = got["status"] == expected_status
    if expected_error is not None:
        ok = ok and got.get("decoded_error") == expected_error
    rows.append({"id": name, "stdout": stdout,
                 "stdout_sha256": hashlib.sha256(stdout.encode()).hexdigest(),
                 "expected_status": expected_status, "expected_error": expected_error,
                 "actual": got, "matches": ok})

for row in json.loads((ROOT / "inputs/expected-refusals.json").read_text())["rows"]:
    raw = (ROOT / "inputs/raw" / row["id"] / "stdout.bin").read_bytes()
    assert hashlib.sha256(raw).hexdigest() == row["stdout_sha256"]
    check(row["id"], raw.decode(), "revert", row["expected_error"])

error = rows[0]["stdout"].splitlines()[0]
panic = rows[6]["stdout"].splitlines()[0]
word = "0x" + "0" * 63 + "1"
revert = "error: execution reverted"
invalid = "error: invalid opcode: invalid"
controls = [
    ("word-success", word, "ok"),
    ("empty-call", "0x", "blocked"),
    ("duplicate-empty-revert", "0x\n0x\n" + revert, "blocked"),
    ("duplicate-empty-invalid", "0x\n0x\n" + invalid, "blocked"),
    ("duplicate-word", word + "\n" + word, "blocked"),
    ("duplicate-structured", error + "\n" + error + "\n" + revert, "blocked"),
    ("mixed-word-structured", word + "\n" + error + "\n" + revert, "blocked"),
    ("mixed-empty-structured", "0x\n" + error + "\n" + revert, "blocked"),
    ("duplicate-errors", error + "\n" + revert + "\n" + revert, "blocked"),
    ("unknown-error", error + "\nerror: made up", "blocked"),
    ("structured-without-error", error, "blocked"),
    ("odd-hex", "0x123\n" + revert, "blocked"),
    ("nonhex", "0xgg\n" + revert, "blocked"),
    ("truncated-panic", panic[:-2] + "\n" + revert, "blocked"),
    ("trailing-panic", panic + "00\n" + revert, "blocked"),
    ("truncated-error", error[:-2] + "\n" + revert, "blocked"),
    ("nonzero-error-padding", error[:-2] + "01\n" + revert, "blocked"),
    ("unknown-short-revert", "0x1234\n" + revert, "blocked"),
    ("unknown-short-invalid", "0x1234\n" + invalid, "blocked"),
    ("malformed-panic-invalid", panic[:-2] + "\n" + invalid, "blocked"),
    ("empty-revert", "0x\n" + revert, "revert"),
    ("empty-invalid", "0x\n" + invalid, "exception"),
    ("word-revert-preserved", word + "\n" + revert, "revert"),
]
for name, raw, expected in controls:
    check(name, raw, expected)

failures = [row["id"] for row in rows if not row["matches"]]
result = {"scope": "Frozen partial AGY parser diagnostic only; no source campaign or P17 acceptance",
          "real_refusal_rows": 7, "grammar_controls": len(controls),
          "total": len(rows), "matched": len(rows) - len(failures),
          "failed_ids": failures, "exit": 1 if failures else 0, "rows": rows}
(ROOT / "result.json").write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps({k: v for k, v in result.items() if k != "rows"}))
raise SystemExit(result["exit"])
