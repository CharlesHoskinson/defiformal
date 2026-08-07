#!/usr/bin/env python3
"""Fold census for Gate 0.2. Balanced .fold( ... ) extraction; no window bleed."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3] / "quint-models"
OUT = Path(__file__).resolve().parent / "GATE-0.2-FOLD-CENSUS.md"


def strip_comments(src: str) -> str:
    return re.sub(r"//[^\n]*", "", src)


def extract_folds(src: str) -> list[str]:
    """Return bodies of each `.fold(` including balanced parentheses."""
    out: list[str] = []
    i = 0
    while True:
        j = src.find(".fold(", i)
        if j < 0:
            break
        # start at '(' of fold(
        k = j + len(".fold")
        assert src[k] == "("
        depth = 0
        p = k
        while p < len(src):
            c = src[p]
            if c == "(":
                depth += 1
            elif c == ")":
                depth -= 1
                if depth == 0:
                    out.append(src[j : p + 1])
                    i = p + 1
                    break
            p += 1
        else:
            # unbalanced; stop
            break
    return out


def classify(fold_expr: str) -> str:
    """Classify a single balanced fold expression."""
    # sum: accumulator plus pattern in the lambda body
    if re.search(r"acc\s*\+", fold_expr):
        return "acc_plus"
    # identity / non-sum accumulator (e.g. if ... acc else acc)
    if re.search(r"\bacc\b", fold_expr):
        return "acc_neutral"
    return "other"


def main() -> None:
    counts = {"acc_plus": 0, "acc_neutral": 0, "other": 0}
    examples: dict[str, list[tuple[str, str]]] = {
        "acc_neutral": [],
        "other": [],
    }
    for path in sorted(ROOT.glob("L*/*.qnt")):
        src = strip_comments(path.read_text(encoding="utf-8", errors="replace"))
        for expr in extract_folds(src):
            kind = classify(expr)
            counts[kind] += 1
            if kind != "acc_plus" and len(examples[kind]) < 8:
                one_line = " ".join(expr.split())[:140]
                examples[kind].append((str(path.relative_to(ROOT.parent)), one_line))

    total = sum(counts.values())
    lines = [
        "# Gate 0.2 — fold census (corpus bridge artifact)",
        "",
        "Reproducible scan of balanced `.fold( ... )` expressions in",
        "`quint-models/L*/*.qnt` (line comments stripped). Matching is confined to each",
        "balanced fold; later folds cannot supply `acc +` for an earlier fold.",
        "",
        f"- **Total balanced `.fold(` expressions:** {total}",
        f"- **`acc + …` (sum folds):** {counts['acc_plus']}",
        f"- **Accumulator-preserving / non-sum (`acc` present, no `acc +`):** {counts['acc_neutral']}",
        f"- **Other:** {counts['other']}",
        "",
        "## Role for Gate 0.2",
        "",
        "Empirical motivation for the formal `SumLocalProg` / `SumAgg` class in",
        "`lean/Defialgebra/Extremal.lean`. This file is **not** a Lean theorem that every",
        "Quint program is a `LocalSel`. The Lean theorem proves extremal prefix fill is",
        "outside the sum-local **filter program** class (closed under conjunction).",
        "",
        "The sum-fold majority (and the absence of extremal/`min` folds) supports using",
        "a sum-aggregate observation interface. The single non-sum identity fold is",
        "sum-neutral (does not introduce population order statistics).",
        "",
        "## Regeneration",
        "",
        "```bash",
        "python3 research/positive-program/sigma/fold_census.py",
        "```",
        "",
    ]
    for kind in ("acc_neutral", "other"):
        if examples[kind]:
            lines += [f"## Examples: {kind}", ""]
            for name, w in examples[kind]:
                lines.append(f"- `{name}`: `{w}`")
            lines.append("")
    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(
        f"wrote {OUT} total={total} acc_plus={counts['acc_plus']} "
        f"acc_neutral={counts['acc_neutral']} other={counts['other']}"
    )


if __name__ == "__main__":
    main()
