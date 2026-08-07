#!/usr/bin/env python3
"""IR deletion impact for gate 1.2 (heuristic keyword tags)."""
import json
from pathlib import Path
from collections import Counter

IR = Path("research/positive-program/sigma/gen-ir-v2ten")
RULES = {
    "Led": [
        "credit", "debit", "transfer", "mint", "burn", "balance", "supply",
        "move", "deposit", "withdraw", "reallocate", "shares", "collateral",
    ],
    "Prop": ["muldiv", "sharesfrom", "assetsfrom", "ceildiv", "geometric", "prorata"],
    "Cmp": [
        "healthy", "canliquidate", "require", "guard", "leq", "geq", "safe",
        "ishealthy", "invariant", "canborrow", "canwithdraw",
    ],
    "Post": [
        "price", "oracle", "shock", "post", "index", "phase", "status",
        "confirm", "approve", "attest",
    ],
}


def tag_name(name: str) -> str:
    n = name.lower()
    best, score = "OTHER", 0
    for fam, kws in RULES.items():
        s = sum(1 for k in kws if k.lower() in n)
        if s > score:
            best, score = fam, s
    return best if score else "OTHER"


def collect_names(d):
    names = []

    def walk(o):
        if isinstance(o, dict):
            if isinstance(o.get("name"), str):
                names.append(o["name"])
            for v in o.values():
                walk(v)
        elif isinstance(o, list):
            for i in o:
                walk(i)

    walk(d)
    return names


def main():
    all_tags = Counter()
    for fp in sorted(IR.glob("*.json")):
        for n in collect_names(json.loads(fp.read_text())):
            all_tags[tag_name(n)] += 1
    total = sum(all_tags.values())
    print("total", total)
    for k, v in all_tags.most_common():
        print(f"{k}: {v} ({100 * v / total:.1f}%)")
    for fam in ["Led", "Prop", "Cmp", "Post"]:
        rem = all_tags.get(fam, 0)
        print(f"delete {fam}: remove {rem}, residual {total - rem}")

    lines = [
        "# Gate 1.2 — IR deletion experiment (gen-ir-v2ten)\n\n",
        "**Status: MEASURED (heuristic)** 2026-08-07\n\n",
        "For each primitive P_i, count IR declaration names keyword-tagged to P_i.\n",
        "If those nodes are deleted, that fraction of the IR surface disappears.\n",
        "Coverage witness for non-definability option 2 in GATE-1.2-SKETCH —\n",
        "not a formal term-language proof.\n\n",
        f"Total named nodes walked: **{total}**\n\n",
        "Script: `gate12_deletion_ir.py`\n\n",
        "## Tag totals\n\n",
        "| tag | count | share |\n|---|---:|---:|\n",
    ]
    for k, v in all_tags.most_common():
        lines.append(f"| {k} | {v} | {100 * v / total:.1f}% |\n")
    lines.append("\n## Deletion impact\n\n")
    lines.append("| delete | nodes removed | residual |\n|---|---:|---:|\n")
    for fam in ["Led", "Prop", "Cmp", "Post"]:
        rem = all_tags.get(fam, 0)
        lines.append(f"| {fam} | {rem} | {total - rem} |\n")
    lines.append("\n## Interpretation\n\n")
    lines.append("- Led/Prop/Post each tag non-trivial IR mass.\n")
    lines.append("- Cmp under-counted (many guards unnamed).\n")
    lines.append("- OTHER dominates (KERNEL + untagged) — expected.\n")
    lines.append("- **1.2 not formally closed**; this is constructive corpus evidence only.\n")
    out = Path("research/positive-program/sigma/GATE-1.2-DELETION-IR.md")
    out.write_text("".join(lines))
    print("wrote", out)


if __name__ == "__main__":
    main()
