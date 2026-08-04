## Context

The atlas is a reference instrument: 48 core + 10 candidate elements, 10
contested entries, 16 substitutability groups, 5 prerequisite strata, 4 bond
types, 29 required-bond laws, 19 hazard rules. It is read repeatedly by people
who already know roughly what they are looking for, and it is screenshotted by
people who do not.

Two facts about the data drive every decision below.

1. **Groups and strata are orthogonal.** Unlike a chemical periodic table, where
   (group, period) uniquely locates an element, up to seven atlas elements share
   a single (group, stratum) cell. There is no canonical arrangement.
2. **Status is graded and contested.** Five elements were demoted and three added
   during the atlas's own review. The hazard table reports failures and never
   survivors — it has no denominator, and the source document names this as an
   unfixed double standard.

A blinded six-lane design council decided this brief. Its rulings are binding on
this document; the full record is `council/design/COUNCIL-DESIGN-LOG.md`.

## Goals / Non-Goals

**Goals:**

- A reader can locate any element in under five seconds and understand what
  status it holds without reading a legend.
- The orthogonality of groups and strata is visible, not merely asserted.
- Nothing about the interface implies predictive power the atlas disclaims.
- Every semantic reaches a user who cannot see colour, cannot use a pointer, or
  cannot tolerate motion — at full fidelity, not in a reduced edition.

**Non-Goals:**

- Not a trading tool and not investment guidance.
- Not a replacement for the document; the atlas remains the source of truth.
- Not a graph/network explorer. Bond *networks* would be a different instrument
  (and D3-style force layout would be the right one); this is a table.
- Not a general-purpose taxonomy viewer.

## Decisions

### D1 — No 3D, no scene graph, no camera

**Decision:** Build ordinary 2D DOM. Remove `three`, `CSS3DRenderer` and the
trackball camera.

**Why:** The 3D engine existed to serve SPHERE, HELIX and GRID. Those layouts
assert nothing about the data, and every lane that ruled on them said cut. With
them gone, the surviving layouts are both planar, so a scene graph is weight
with no return. Three separate lanes independently identified the same
interaction defect: a trackball owns pointer drag, so small movements eat
clicks, touch users cannot distinguish orbit from activate, and tab order stays
in document order while the camera reorders what looks adjacent.

**Alternatives considered:** keep three.js as a progressive enhancement gated on
viewport and reduced-motion (one lane's position). Rejected because it preserves
the cost and the failure modes to serve layouts that were cut. Revisit only if a
genuinely 3D layout is ever justified by the data.

### D2 — The primary layout is a matrix, not a silhouette

**Decision:** A fixed 16×5 group-by-stratum matrix. Every intersection is a
bounded container holding a small-multiples grid of its elements with an
explicit occupancy count. Empty cells stay empty and visible.

**Why:** The earlier proposal offset each group column to start at its
shallowest stratum, producing a ragged staircase. That silhouette is the single
most recognisable thing about a chemical periodic table, and it would have been
carrying a lie: a tile's row was an ordinal within its column, so two tiles at
the same height could sit in different strata. The strongest positional cue in
the design would have contradicted the data. A matrix that shows multi-occupancy
directly is the honest form, and the occupancy count turns the loss of unique
placement from a hidden defect into visible information.

### D3 — Colour means exactly one thing: hazard

**Decision:** Remove hue from the stratum ramp. Stratum is carried by row
position, a printed `S0`–`S4` token on every tile, and a monotonic
lightness/inset depth cue. All chroma in the product is reserved for the three
hazard classes.

**Why:** Two lanes independently computed the same collision from the brief's
own values. Hazard `#A8442E` and stratum-S4 `#A8523A` sit 2° apart in hue and
share an identical red channel; they compute to a 1.12:1 luminance ratio and
become one swatch under deuteranopia and protanopia. The full five-step ramp
spanned 1.50:1, so adjacent strata differed by ≈1.1:1 — not a perceivable step
for anyone. "Deepest stratum" and "forbidden" would have looked the same.

A second reason: cool-to-hot is the most over-learned ramp in data display and
reads as safe-to-dangerous before it reads as anything. A stratum is a *category
of prerequisite*, not a risk score. Depth is the honest cue for "needs more
underneath it"; heat is not.

### D4 — Status is text first

**Decision:** Every tile carries a plain-language status badge on its face —
`core`, `candidate: recurrence evidence short`, `contested: note required`,
`degenerate limit: not an element`. Every tile's accessible name follows a fixed
template: symbol, name, ID, group, stratum token, status word, asynchrony,
hazard class, discriminator requirement. Glyph silhouette and border style are
redundant reinforcement.

**Why:** The prior brief encoded status only in fill, border style and colour.
A blind, low-vision or dichromatic user would have received an atlas in which
all 69 entries appear equally authoritative — which is precisely the
overclaiming this project exists to prevent. The accessibility failure and the
epistemic failure were the same failure. Border style additionally degrades at
small sizes: dashed and dotted are the least separable pair in the set.

### D5 — Layout zero is the document

**Decision:** The 2D document-flow view is layout zero: built first, feature
complete, canonical. Nested lists — groups (or strata) as an outer list,
elements as `<button>` children. Layout changes move transforms only and never
reorder the DOM.

**Why:** A non-3D view scoped as the fifth item of the fifth capability gets
built last and ships as a stub. It is also the only view in which browser zoom
magnifies, Ctrl+F finds, a URL deep-links, the page prints, and a screen reader
gets a stable document.

**Consequence:** because neither axis is canonical, DOM order cannot be inferred.
The user picks it — a **reading order** control (by group / by stratum / by ID).
That control is itself the most honest available expression of orthogonality.

### D6 — The argument is identity, not animation

**Decision:** Layout transitions run ≤300ms with no stagger. The orthogonality
argument is carried by a first-class **two-up comparison view** — matrix and
strata side by side, the selected element highlighted in both, a static
connector between its two positions. Under `prefers-reduced-motion` the two-up
view becomes the default way to move between layouts.

**Why:** The prior brief made a ~1.5s staggered transition "the primary
argument". That is a first-visit effect which becomes an obstacle by the tenth
use, and a large-amplitude staggered rearrangement of 69 tiles is close to a
worst case for vestibular disorders. But disabling it would leave the
reduced-motion user without the argument. The resolution is that the argument
was never the animation — it is *identity preservation*: the same objects, two
equally valid arrangements, neither canonical. That can be shown statically, and
shown better.

### D7 — The missing denominator is the signature graphic

**Decision:** Every hazard indicator, candidate element and contested entry
renders as a visibly incomplete form — a fraction rule with a vacant space where
the sample size belongs. One shape, used nowhere else, meaning *we do not know
the denominator*.

**Why:** The atlas's chief editorial virtue is that it names what it has not
measured. Handled as a caveat, that virtue is invisible in a screenshot. Handled
as a shape, it is the first thing a reader notices and the last thing they can
mistake for decoration. It also cannot be lifted to any other subject, which is
the test the rest of the visual system has to pass.

### D8 — Hazards are categorical, never quantitative

**Decision:** Encode hazard-rule membership and class only. Prohibited:
gradients, gauges, percentages, ranked bars, area encodings, severity ordering
and likelihood language. A persistent statement sits beside the legend and in
the hazard view: *case-only evidence; exposure and survivors not collected;
probability not estimated.*

### D9 — Typography: two families, each with a job

**Decision:** Cut the grotesque. Monospace becomes the superfamily across
weights for all chrome, headings, symbols, formulas and labels. The serif is
reserved strictly for human-authored assertion — definitions, demotion notes,
the denominator caveat.

**Why:** Notation like `Pl → (Sh|Ix) + exit-liquidity` is literal and needs
glyph alignment, so mono is non-negotiable. The grotesque carried the least text
and earned nothing but the default look of a serious tool. The surviving split
is epistemic rather than decorative: **mono means the system recorded this,
serif means a person claimed it.** Nothing may be set in serif that is not
somebody's judgement.

### D10 — Palette register

**Decision:** Keep the dark earth ground the client directed. Apply D3's
encoding rules on top of it: the ground and its neutrals carry the earth
character; stratum is achromatic value and depth; the single alarm chroma is
hazard.

**Why:** One lane argued the earth/mineral register is itself borrowed from
chemistry and directed a forensic/ledger world instead. That is a taste
judgement and the client's direction outranks it. Its *defect* findings — the
hue collision, the heat-ramp implication, the three-family type system — are all
accepted above. The register is the only thing rejected, and the rejection is
recorded as open dissent.

## Risks / Trade-offs

- **Stratum now leans on position, token and lightness alone.** → If testing
  shows the distinction is too weak, add lightness separation, never hue. Hue is
  spent.
- **A matrix is less striking than a periodic-table silhouette.** → Accepted
  deliberately. The silhouette's recognisability *is* the mechanism that imports
  the false claim; that is the trade the council directed.
- **Two-up comparison doubles the layout work.** → Mitigated by layout zero
  being shared markup with transform-only differences.
- **Losing the demo aesthetic may read as less ambitious.** → The compensating
  ambition is D7: a signature graphic derived from the subject's own epistemics
  rather than from a 12-year-old WebGL example.
- **The data export becomes a second source of truth.** → A sync check against
  `docs/UNIFIED-DEFI-ELEMENT-TABLE.md` runs in the conformance harness; counts
  and status values must match or the build fails.

## Open Questions

1. Whether the phrase "periodic table" may appear once inside the disavowal
   sentence (adopted) or nowhere at all (one lane's stricter position).
2. Whether the contested register should also project its entries' group and
   stratum into the matrix as ghosted placeholders, or stay wholly separate.
3. Whether the classification change log (five demotions, three additions) is
   surfaced globally or only per element.
