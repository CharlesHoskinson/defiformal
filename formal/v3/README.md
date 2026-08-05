# formal/v3 — the construction checker

Stage 3 of the atlas run asks one question of each application: **can the
algebra construct something that reproduces what the application does?** This
directory answers it mechanically. No construction enters the paper on
assertion.

```
node construct.mjs <dir-of-specs> [--json out.json]
node selftest.mjs                  # must pass before any construction is trusted
```

`selftest.mjs` reproduces the paper's published numbers from the checker's own
predicates — 72 protocols, 61 satisfying requirements and warrants, 29
compressing under `ex`, 1830 pairs, 185 failures, the `Uniswap ⊕ Aave` cover of
`X2`, the six-venue `{Ct,Ex,Li}` signature and Jupiter's exception. If it fails,
a table has changed and every downstream claim is suspect.

## The construction contract

A construction is a JSON object:

```json
{
  "app": "Aave v3",
  "category": "02-lending",
  "source": "C:\\defiformal-work\\02-lending\\01-research.md",
  "construction": ["Pl", "Ix", "Ct", "Ex", "Li", "Fl", "Bs", "Sl"],
  "functionalObligations": [
    { "id": "F1", "text": "a depositor holds a claim that accrues interest",
      "elements": ["Ix"], "evidence": "https://... (accessed 2026-08-04)" },
    { "id": "F7", "text": "the borrow rate rises with pool utilisation",
      "elements": [], "evidence": "https://..." }
  ]
}
```

**Obligations are the deliverable, not the element set.** Each is one thing the
application does, stated so that a reader can check it against the cited source,
together with the elements that discharge it. An obligation with `"elements":
[]` is residue: the vocabulary has no name for that behaviour. Residue is the
most valuable output of the stage and must never be forced onto a nearby symbol.

## What the checker reports

| field | meaning |
|---|---|
| `admissible` | the four failure modes, separately: open requirement terms, unwarranted elements, armed prohibitions, grounding |
| `canonicalForm` / `derived` | `ex(X)`, and which elements the construction derives rather than chooses |
| `obligationsUncovered` | residue — what the vocabulary cannot say about this application |
| `unjustifiedElements` | elements carried that discharge no stated obligation; a defect in the construction |
| `minimality` | elements whose removal keeps every obligation covered and `X` admissible |
| `composition` | exact decompositions `A ⊕ B (⊕ C)` over the 72 corpus protocols, and which elements no corpus protocol supplies |

`verdict` is one of `COMPLETE`, `PARTIAL` (admissible, some obligations are
residue), `ADMISSIBLE-REDUNDANT`, `INADMISSIBLE`, `VACUOUS`.

## Reading the verdicts

`INADMISSIBLE` is a result about the tables, not a criticism of the protocol:
the requirement table insists a live system name a mechanism it does not name.
`PARTIAL` is the expected outcome — the corpus measurement is that not one of
72 protocols was fully expressible — and the size and content of the residue is
what the paper reports. `COMPLETE` on a large application would be surprising
and should be attacked before it is believed.

The `composition` field is the sense of "construct from the paper" that
exercises Theorem *Composition on canonical forms* rather than set membership:
it asks whether the application is reachable as a composite of systems already
in the corpus. Exact hits are searched to `k = 3`; absence of a hit at `k ≤ 3`
is not absence of a decomposition, and is reported as such.
