#!/usr/bin/env python3
"""Parse #print axioms stdout against independent 418/434 inventories."""
from __future__ import annotations

import json
import re
from pathlib import Path

OUT = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-recursive-token-grok-r1"
)
INV = json.loads((OUT / "probes" / "axioms434" / "inventory.json").read_text())
STDOUT = (OUT / "logs" / "probe-axioms434" / "stdout").read_text()
STANDARD = {"propext", "Classical.choice", "Quot.sound"}
NAME = r"([A-Za-z0-9_?'.]+)"
EXTRA = INV["extra_defs"]
EXTRA_NAMES = [d["name"] for d in EXTRA]
expected_418 = INV["CanonicalJson_names"] + INV["Correspondence_names"]
expected_434 = expected_418 + EXTRA_NAMES

pairs = []
lines = STDOUT.splitlines()
i = 0
while i < len(lines):
    line = lines[i]
    m_closed = re.match(
        rf"^'DefiKernel\.Certificates\.{NAME}' depends on axioms: \[(.*)\]\s*$",
        line,
    )
    m_open = re.match(
        rf"^'DefiKernel\.Certificates\.{NAME}' depends on axioms: \[(.*)$",
        line,
    )
    m_none = re.match(
        rf"^'DefiKernel\.Certificates\.{NAME}' does not depend on any axioms$",
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
printed_418 = [n for n in printed if n in expected_418]
printed_defs = [n for n in printed if n in EXTRA_NAMES]
forbidden = []
standard = 0
none = 0
standard_418 = 0
none_418 = 0
standard_defs = 0
none_defs = 0
for p in pairs:
    s = set(p["axioms"])
    is_def = p["name"] in EXTRA_NAMES
    if not s:
        none += 1
        if is_def:
            none_defs += 1
        elif p["name"] in expected_418:
            none_418 += 1
        continue
    if s <= STANDARD:
        standard += 1
        if is_def:
            standard_defs += 1
        elif p["name"] in expected_418:
            standard_418 += 1
        continue
    extra = sorted(s - STANDARD)
    forbidden.append({"name": p["name"], "extra": extra, "axioms": p["axioms"]})

result = {
    "printed_count": len(pairs),
    "expected_418": len(expected_418),
    "expected_434": len(expected_434),
    "printed_set_equals_434": set(printed) == set(expected_434),
    "printed_order_equals_source_434": printed == expected_434,
    "printed_set_equals_418_plus_16": set(printed) == set(expected_434),
    "missing": [n for n in expected_434 if n not in printed],
    "extra": [n for n in printed if n not in expected_434],
    "includes_exprDepth_pos": "exprDepth_pos" in printed,
    "includes_TreeJson_size_pos": "TreeJson.size_pos" in printed,
    "includes_16_defs": all(n in printed for n in EXTRA_NAMES),
    "standard_434": standard,
    "none_434": none,
    "standard_418": standard_418,
    "none_418": none_418,
    "standard_defs": standard_defs,
    "none_defs": none_defs,
    "forbidden": len(forbidden),
    "forbidden_detail": forbidden,
    "zero_axiom_names": [p["name"] for p in pairs if not p["axioms"]],
    "pairs": pairs,
}
(OUT / "probes" / "axioms434" / "parsed.json").write_text(json.dumps(result, indent=2) + "\n")
summary = {k: v for k, v in result.items() if k != "pairs"}
print(json.dumps(summary, indent=2))
