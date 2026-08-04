## Why

The DeFi State-Transition Atlas exists only as a 1,366-line document. Its most
important structural claims — that groups and strata are *orthogonal*, that
status is graded rather than binary, that ten entries sit outside the table
body, that the hazard table has no denominator — are exactly what a reader loses
in linear prose.

The risk is equal and opposite. A periodic-table visualisation borrows the
credibility of chemistry's table, and the atlas explicitly disclaims the
periodic law, the atomic number and closure. A beautiful visualisation implying
Mendeleev-grade predictive power would misrepresent the work more badly than the
document ever could.

A six-lane blinded design council decided this brief. All six lanes returned
`changes_requested`. Their central instruction was not to disclaim the metaphor
more loudly but to **stop borrowing its form** — because a caveat placed beside
an attractive table cannot outrank the table.

## What Changes

- Add a browser-based visualisation of the atlas: 48 core + 10 candidate
  elements, 10 contested, 16 groups, 5 strata, 4 bond types, 29 laws, 19 hazard
  rules.
- Present the primary layout as an explicit **16×5 group-by-stratum matrix**
  whose cells visibly hold multiple elements and show an occupancy count — not a
  periodic-table silhouette. Losing unique (group, stratum) placement is a fact
  about this data and the layout must show it rather than hide it.
- Encode **stratum by row position and a printed S0–S4 token**. Remove hue from
  stratum entirely.
- Reserve **all chroma for hazard class**, which is categorical only — never a
  magnitude.
- Encode **status as text first**: a plain-language badge on the tile face and
  the status word in every tile's accessible name. Glyph and border style are
  redundant reinforcement, never the carrier.
- Make the **2D document-flow view layout zero** — built first, feature
  complete, canonical. Not a fallback.
- Replace the provisional strip with a separately titled **Contested register**
  whose separation means *note required*, not *displaced for convenience*.
- Give every hazard, candidate and contested entry a **visibly incomplete
  form** — the missing-denominator mark — as the product's signature graphic.
- **REMOVED**: three.js, CSS3DRenderer, the trackball camera, and the SPHERE,
  HELIX and GRID layouts. See `design.md`.
- **BREAKING** for the existing `viz/` prototype: the framer-motion grid and the
  three.js scene are both replaced.

## Capabilities

### New Capabilities

- `atlas-visual-language`: tile anatomy, palette, typography, status encoding,
  and the missing-denominator mark.
- `atlas-layouts`: layout zero, the group-by-stratum matrix, the stratum bands,
  the contested register, and the two-up comparison view.
- `atlas-interaction`: reading order, keyboard model, search, filtering,
  bidirectional element/rule selection, and the detail surface.
- `atlas-epistemic-honesty`: the interface-level requirements that stop the
  visualisation overclaiming — status as text, hazard as categorical, the
  denominator statement, and the mapping statement in every layout header.
- `atlas-conformance`: the automated harness — contrast, colour-vision
  simulation, reduced motion, keyboard traversal, and payload budget.

Note: an `atlas-accessibility` capability was proposed and **dissolved** on
council instruction. Scoped as a fifth capability it would have been built last
and shipped as a degraded stub. Its requirements are now acceptance criteria
inside the four capabilities above, and what remains standalone is the automated
harness.

### Modified Capabilities

None. This is the repository's first spec.

## Impact

- New: `viz/` application; built single-file HTML artifact, budget ≤150 KB
  gzipped.
- Dependencies: **removed** `three` and `framer-motion` as layout engines. Layout
  motion via FLIP or the View Transitions API.
- Data: a typed export of the atlas element, law and hazard tables becomes a
  second source of truth alongside `docs/UNIFIED-DEFI-ELEMENT-TABLE.md` and must
  be kept in sync.
- Risk: the visualisation is the most quotable artifact in the repository and
  will travel further than the document, so its limits must be legible in a
  screenshot — not merely present in the page.
