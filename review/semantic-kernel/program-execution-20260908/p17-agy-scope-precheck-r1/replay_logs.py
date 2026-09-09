"""Root protocol falsifiers; no Solidity mutant or source-agreement credit."""
import gzip
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE / "engine"))
from vault_exec import parse_logs_from_trace, compare_logs

trace = gzip.decompress((HERE / "actual-deposit-trace.stderr.gz").read_bytes()).decode()
addresses = json.loads((HERE / "addresses.json").read_text())
fixtures = json.loads((HERE / "fixtures.json").read_text())["fixtures"]
expected = next(f["expected"]["full_logs"] for f in fixtures if f["id"] == "P17-DEP-D0")

extra = json.dumps({"pc": 0, "op": 160, "opName": "LOG0", "stack": ["0x0", "0x0"],
                    "depth": 2, "memory": "0x", "memSize": 0}, separators=(",", ":"))
lines = trace.splitlines()
shortened = list(lines)
for i, line in enumerate(shortened):
    if '"opName":"LOG1"' in line:
        event = json.loads(line)
        offset = int(event["stack"][-1], 16)
        size = int(event["stack"][-2], 16)
        assert size == 64
        memory = event["memory"].removeprefix("0x")
        event["memory"] = "0x" + memory[:(offset + 32) * 2]
        shortened[i] = json.dumps(event, separators=(",", ":"))
        break
else:
    raise AssertionError("actual trace lacks Drip LOG1")

results = []
for name, raw, should_pass in [
    ("actual-intact-deposit", trace, True),
    ("extra-LOG0-record", "\n".join(lines[:-1] + [extra] + lines[-1:]), False),
    ("truncated-Drip-memory", "\n".join(shortened), False),
]:
    try:
        decoded = parse_logs_from_trace(raw, addresses)
        comparison = compare_logs(decoded, expected)
        passed = comparison.get("gate") == "ok"
    except Exception as exc:
        decoded, comparison, passed = None, {"exception": str(exc)}, False
    results.append({"id": name, "expected_acceptance": should_pass,
                    "actual_comparison": comparison, "actual_logs": decoded,
                    "matches_required_behavior": passed == should_pass})

report = {"scope": "Partial parser diagnostic only; altered protocol records are not compiled source mutants",
          "results": results,
          "failed_ids": [r["id"] for r in results if not r["matches_required_behavior"]]}
(HERE / "log-falsifiers.json").write_text(json.dumps(report, indent=2) + "\n")
print(json.dumps({"checks": len(results), "failed_ids": report["failed_ids"]}))
raise SystemExit(1 if report["failed_ids"] else 0)
