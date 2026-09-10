#!/usr/bin/env python3
"""Parse #print axioms stdout against independent source inventory."""
from __future__ import annotations

import json
import re
from pathlib import Path

OUT = Path("/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-treejson-inverse-grok-r1")
INV = json.loads((OUT / "probes" / "axioms343" / "inventory.json").read_text())
STDOUT = (OUT / "logs" / "probe-axioms343" / "stdout").read_text()
STANDARD = {"propext", "Classical.choice", "Quot.sound"}
DECL_RE = re.compile(
    r"^'DefiKernel\.Certificates\.([A-Za-z0-9_?']+)' (?:depends on axioms: \[([^\]]*)\]|does not depend on any axioms)$"
)

expected = INV["CanonicalJson_names"] + INV["Correspondence_names"]
pairs = []
current = None
axioms: list[str] = []
lines = STDOUT.splitlines()
i = 0
while i < len(lines):
    line = lines[i]
    m_closed = re.match(
        r"^'DefiKernel\.Certificates\.([A-Za-z0-9_?']+)' depends on axioms: \[(.*)\]\s*$",
        line,
    )
    m_open = re.match(
        r"^'DefiKernel\.Certificates\.([A-Za-z0-9_?']+)' depends on axioms: \[(.*)$",
        line,
    )
    m_none = re.match(
        r"^'DefiKernel\.Certificates\.([A-Za-z0-9_?']+)' does not depend on any axioms$",
        line,
    )
    if m_closed:
        name = m_closed.group(1)
        rest = m_closed.group(2).strip()
        ax = [x.strip() for x in rest.split(",") if x.strip()]
        pairs.append({"name": name, "axioms": ax})
    elif m_open:
        name = m_open.group(1)
        rest = m_open.group(2).strip().rstrip(",")
        ax = [x.strip() for x in rest.split(",") if x.strip()]
        while i + 1 < len(lines):
            i += 1
            extra = lines[i].strip()
            closed = extra.endswith("]")
            extra = extra.rstrip("]").rstrip(",").strip()
            if extra:
                ax.extend(x.strip() for x in extra.split(",") if x.strip())
            if closed:
                break
        pairs.append({"name": name, "axioms": ax})
    elif m_none:
        pairs.append({"name": m_none.group(1), "axioms": []})
    i += 1

printed = [p["name"] for p in pairs]
forbidden = []
standard = 0
none = 0
nonstandard = []
for p in pairs:
    s = set(p["axioms"])
    if not s:
        none += 1
        continue
    if s <= STANDARD:
        standard += 1
        continue
    extra = sorted(s - STANDARD)
    forbidden.append({"name": p["name"], "extra": extra, "axioms": p["axioms"]})
    nonstandard.append(p["name"])

result = {
    "printed_count": len(pairs),
    "expected_count": len(expected),
    "names_equal": printed == expected,
    "printed_set_equal": set(printed) == set(expected),
    "missing": [n for n in expected if n not in printed],
    "extra": [n for n in printed if n not in expected],
    "order_mismatch_first": next((i for i, (a, b) in enumerate(zip(printed, expected)) if a != b), None)
    if printed != expected
    else None,
    "standard": standard,
    "none": none,
    "forbidden": len(forbidden),
    "forbidden_detail": forbidden,
    "zero_axiom_names": [p["name"] for p in pairs if not p["axioms"]],
    "includes_exprDepth_pos": "exprDepth_pos" in printed,
    "pairs": pairs,
}
(OUT / "probes" / "axioms343" / "parsed.json").write_text(json.dumps(result, indent=2) + "\n")
summary = {k: v for k, v in result.items() if k != "pairs"}
print(json.dumps(summary, indent=2))
