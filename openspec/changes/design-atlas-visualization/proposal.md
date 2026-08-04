## Why

The DeFi State-Transition Atlas exists only as a 1,366-line document. Its most
important structural claims — that groups and strata are *orthogonal* axes, that
status is graded rather than binary, that ten elements sit outside the table
body, that hazard rules have no measured denominator — are exactly the claims a
reader loses in linear prose. A periodic table is a visual instrument before it
is a text, and this one has never been drawn.

The risk of drawing it is equal and opposite: a periodic-table visualisation
borrows the credibility of chemistry's table, and the atlas explicitly disclaims
the periodic law, the atomic number and closure. A beautiful visualisation that
implies Mendeleev-grade predictive power would misrepresent the underlying work
more badly than the document ever could.

## What Changes

- Add a browser-based visualisation of the atlas: 48 core + 10 candidate
  elements, 10 provisional, 16 groups, 5 strata, 4 bond types, 29 laws, 19
  hazard rules.
- Encode the two orthogonal axes as two *layouts* the user can move between,
  rather than as one canonical arrangement. Movement between them is the primary
  interaction and the primary argument.
- Encode epistemic status (core / candidate / provisional / degenerate limit) in
  tile *treatment*, not only colour, so status survives greyscale and colour
  vision deficiency.
- Place the provisional register as a detached strip below the table body,
  mirroring how the lanthanide and actinide series are pulled out of a chemical
  periodic table — provisional elements are referenced by the table but are not
  in it.
- Carry the document's disclaimers into the interface itself, at equal visual
  weight to the table — not in a footer.
- **BREAKING** for the existing `viz/` prototype: replace the framer-motion grid
  with a three.js CSS3D scene.

## Capabilities

### New Capabilities

- `atlas-visual-language`: the tile anatomy, palette, typography and status
  encoding — the design system the visualisation is built from.
- `atlas-layouts`: the set of spatial arrangements, what each one asserts about
  the data, and the transition between them.
- `atlas-interaction`: selection, filtering, search, camera control, and the
  detail surface.
- `atlas-epistemic-honesty`: the interface-level requirements that keep the
  visualisation from overclaiming — how uncertainty, missing denominators and
  preserved dissent are surfaced.
- `atlas-accessibility`: keyboard, contrast, reduced motion, and non-3D fallback
  requirements.

### Modified Capabilities

None. This is the repository's first spec.

## Impact

- New: `viz/` React + three.js application; built single-file HTML artifact.
- Dependencies: `three` (CSS3DRenderer, TrackballControls) replaces
  `framer-motion` as the layout engine; framer-motion may remain for UI chrome.
- Data: a typed export of the atlas element/law/hazard tables, which becomes a
  second source of truth alongside `docs/UNIFIED-DEFI-ELEMENT-TABLE.md` and must
  be kept in sync.
- Risk: the visualisation is the most quotable artifact in the repository and
  will travel further than the document. Its disclaimers must therefore be more
  prominent, not less.
