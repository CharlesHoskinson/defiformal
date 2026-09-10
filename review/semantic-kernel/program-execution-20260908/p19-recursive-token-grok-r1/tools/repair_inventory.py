#!/usr/bin/env python3
"""Regenerate 418/434 inventories and Probe.lean with dotted TreeJson names."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from record_cmd import OUT, sha256_file
from setup_private_lean import (
    AUTHOR_PRINT_RE,
    EXTRA_DEFS,
    R19_INVENTORY,
    SANDBOX,
    extract_decls,
    extract_top_defs,
    parse_author_names,
    write_json,
)

cj = extract_decls(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "CanonicalJson.lean")
co = extract_decls(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "Correspondence.lean")
named = cj + co
theorems = [d for d in named if d["kind"] == "theorem"]
lemmas = [d for d in named if d["kind"] == "lemma"]
current_names = [d["name"] for d in named]
r19_names = []
if R19_INVENTORY.exists():
    prev = json.loads(R19_INVENTORY.read_text())
    r19_names = prev.get("CanonicalJson_names", []) + prev.get("Correspondence_names", [])
missing_prev = [n for n in r19_names if n not in current_names]
new_theorems_lemmas = [n for n in current_names if n not in r19_names]
cj_defs = extract_top_defs(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "CanonicalJson.lean")
co_defs = extract_top_defs(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "Correspondence.lean")
all_top_defs = cj_defs + co_defs
extra_defs = []
extra_missing = []
for name in EXTRA_DEFS:
    hits = [d for d in all_top_defs if d["name"] == name]
    if hits:
        extra_defs.append(hits[0])
    else:
        extra_missing.append(name)
author_probe = (
    SANDBOX
    / "review/semantic-kernel/certificates/p19/implementation/agy-r20-proof/probes/named_axioms_434.lean"
)
root_author = SANDBOX / "root-context" / "p19-r20-root-scope" / "Author434.lean"
author_names = parse_author_names(author_probe)
root_names = parse_author_names(root_author)
named_plus_defs = current_names + [d["name"] for d in extra_defs]
inventory = {
    "CanonicalJson_theorems": len([d for d in cj if d["kind"] == "theorem"]),
    "CanonicalJson_lemmas": [d["name"] for d in cj if d["kind"] == "lemma"],
    "Correspondence_theorems": len([d for d in co if d["kind"] == "theorem"]),
    "Correspondence_lemmas": [d["name"] for d in co if d["kind"] == "lemma"],
    "named_total_418": len(named),
    "theorem_total": len(theorems),
    "lemma_total": len(lemmas),
    "CanonicalJson_names": [d["name"] for d in cj],
    "Correspondence_names": [d["name"] for d in co],
    "decls": named,
    "previous_r19_named": len(r19_names),
    "missing_previous_r19": missing_prev,
    "new_theorem_lemma_names": new_theorems_lemmas,
    "new_theorem_lemma_count": len(new_theorems_lemmas),
    "includes_exprDepth_pos": "exprDepth_pos" in current_names,
    "includes_TreeJson_size_pos": "TreeJson.size_pos" in current_names,
    "extra_defs": extra_defs,
    "extra_defs_count": len(extra_defs),
    "extra_defs_missing": extra_missing,
    "named_plus_16_defs_total": len(named_plus_defs),
    "unique_named_plus_16": len(set(named_plus_defs)),
    "author434_count": len(author_names),
    "root_author434_count": len(root_names),
    "author434_equals_root": author_names == root_names,
    "author434_set_equals_418_plus_16": set(author_names) == set(named_plus_defs),
    "author434_order_equals_source_418_plus_16": author_names == named_plus_defs,
    "author_minus_source": sorted(set(author_names) - set(named_plus_defs)),
    "source_minus_author": sorted(set(named_plus_defs) - set(author_names)),
    "first_order_mismatch": next(
        (
            {"index": i, "author": a, "source": s}
            for i, (a, s) in enumerate(zip(author_names, named_plus_defs))
            if a != s
        ),
        None,
    ),
    "note": "Independent source extraction of ^theorem|^lemma (418, including dotted TreeJson.*) plus explicit 16 defs.",
}
probe_dir = OUT / "probes" / "axioms434"
write_json(probe_dir / "inventory.json", inventory)
lines = [
    "import DefiKernel.Certificates.Correspondence",
    '#eval IO.println "PROBE_AXIOMS_START"',
]
for name in named_plus_defs:
    lines.append(f"#print axioms DefiKernel.Certificates.{name}")
lines.append('#eval IO.println "PROBE_AXIOMS_END"')
lines.append(f'#eval IO.println "NAMED_PLUS_DEFS={len(named_plus_defs)}"')
lines.append(f'#eval IO.println "THEOREMS_LEMMAS={len(named)}"')
(probe_dir / "Probe.lean").write_text("\n".join(lines) + "\n")
hashes = {
    "axioms434": {"sha256": sha256_file(probe_dir / "Probe.lean")},
    "Author434.copied": {"sha256": sha256_file(probe_dir / "Author434.copied.lean")},
    "author_named_axioms_434": {"sha256": sha256_file(author_probe)},
    "root_Author434": {"sha256": sha256_file(root_author)},
}
write_json(OUT / "logs" / "probe-source-hashes.json", hashes)
print(
    json.dumps(
        {
            "named_total_418": len(named),
            "lemmas": [d["name"] for d in lemmas],
            "new_theorem_lemma_count": len(new_theorems_lemmas),
            "extra_defs_count": len(extra_defs),
            "named_plus_16": len(named_plus_defs),
            "unique": len(set(named_plus_defs)),
            "author434_count": len(author_names),
            "set_equal": set(author_names) == set(named_plus_defs),
            "order_equal": author_names == named_plus_defs,
            "author_minus_source": sorted(set(author_names) - set(named_plus_defs)),
            "source_minus_author": sorted(set(named_plus_defs) - set(author_names)),
            "includes_TreeJson_size_pos": "TreeJson.size_pos" in current_names,
            "includes_exprDepth_pos": "exprDepth_pos" in current_names,
            "probe_sha256": hashes["axioms434"]["sha256"],
        },
        indent=2,
    )
)
