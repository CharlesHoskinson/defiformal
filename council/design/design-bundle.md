# Design brief under review — DeFi State-Transition Atlas visualisation

You are reviewing a **draft design brief**, not finished code. Your job is to
decide whether this brief is the right brief.

---

## Part 1 — What is being visualised

A reference table of the recurring financial mechanisms in decentralized
finance. It is deliberately *not* claimed to be a periodic table in the
scientific sense. The underlying document is emphatic on this point:

> There is no periodic law. Properties do not recur down a group. There is no
> natural atomic number. IDs are stable identifiers. It is not closed by nature —
> elements are designed, not discovered.

**The data:**

- **48 core elements** — each a recurring financial state-transition mechanism
  with a distinct failure signature.
- **10 candidate elements** — structurally sound, but empirical recurrence
  evidence is short. Usable, flagged.
- **10 provisional entries** — a necessary criterion is genuinely contested.
  Not usable in a formula without a note.
- **1 "degenerate limit"** — a boundary case of another element whose failure
  family differs, so it is neither an element nor a variant of one.
- **16 groups** — substitutability families. A group answers "what else could
  sit at this role boundary?"
- **5 strata (S0–S4)** — the *category of prerequisite* an element needs to
  exist at all. S0 needs nothing outside the ledger; S4 needs coordination
  across parties or trust boundaries.
- **4 bond types** — interface, economic, trust, informational. Each must be
  satisfied separately.
- **29 required-bond laws**, e.g. `Pl → (Sh|Ix) + exit-liquidity`.
- **19 hazard rules**, classed forbidden / elevated-hazard / unverifiable.
- Per element: an asynchrony property (async-native / repairable / impossible)
  and, for some, a **mandatory discriminator** — an annotation without which a
  formula is ill-formed.

**Two things about this data that matter for the design:**

1. **Groups and strata are orthogonal.** An element has both. Neither is
   subordinate. There is no single canonical arrangement, unlike a chemical
   periodic table where (group, period) uniquely locates an element. Multiple
   elements share the same (group, stratum) cell — up to seven of them.
2. **Status is graded and contested.** Five elements were demoted from core
   during review; three were added. The provisional register may not be used
   without a note. The hazard table has **no denominator** — it reports failures
   and never survivors, and the source document names this as a double standard
   it has not fixed.

---

## Part 2 — The draft brief

### Why

The atlas exists only as a 1,366-line document. Its most important structural
claims — that groups and strata are orthogonal, that status is graded, that ten
entries sit outside the table body, that hazard rules have no measured
denominator — are exactly what a reader loses in linear prose.

The risk is equal and opposite: a periodic-table visualisation borrows the
credibility of chemistry's table. A beautiful visualisation implying
Mendeleev-grade predictive power would misrepresent the work more badly than the
document ever could.

### Proposed capabilities

- `atlas-visual-language` — tile anatomy, palette, typography, status encoding.
- `atlas-layouts` — the spatial arrangements, what each asserts, and the
  transitions between them.
- `atlas-interaction` — selection, filtering, search, camera, detail surface.
- `atlas-epistemic-honesty` — interface-level requirements that stop the
  visualisation overclaiming.
- `atlas-accessibility` — keyboard, contrast, reduced motion, non-3D fallback.

### Proposed technical direction

A **three.js CSS3D** scene: element tiles are real DOM elements positioned in 3D
space, with a trackball camera, moving between five layouts —

- **TABLE** — 16 group columns; each column *starts* at its shallowest stratum,
  producing a ragged staircase silhouette that encodes dependency depth.
- **STRATA** — five horizontal bands, one per stratum.
- **SPHERE**, **HELIX**, **GRID** — non-semantic arrangements inherited from the
  well-known three.js periodic-table demo.

Transitions use an exponential in-out ease with a per-tile stagger.

The **provisional register** is placed as a detached strip below the table body,
mirroring how lanthanides and actinides are pulled out of a chemical periodic
table.

### Proposed visual direction

A dark earth palette — deep umber ground `#17130F`, bone ink `#EDE4D6`,
burnt-ochre accent `#C8813C`, iron-oxide hazard `#A8442E`. Stratum depth runs as
a heat ramp from deep olive `#4A5340` (S0) to rust `#A8523A` (S4). Heavy
grotesque headings, monospace for symbols and formulas, humanist serif for
definitions. Status encoded in tile treatment — solid fill for core, dashed
border for candidate, dotted for degenerate limit — so it survives greyscale.

### Stated non-goals

- Not a trading tool, not investment guidance.
- Not a substitute for the document.

---

## Part 3 — Known tensions the brief has not resolved

These are given to you deliberately. The brief may be wrong about any of them.

1. **SPHERE / HELIX / GRID assert nothing about the data.** They are inherited
   from a demo. Are they delightful, or are they decoration that undermines a
   document whose central virtue is epistemic restraint?
2. **The ragged staircase** encodes each group's *minimum* stratum. But an
   element's own row within its column is then just an ordinal, not a stratum.
   Two tiles at the same height may sit in different strata. Is that
   acceptable, or actively misleading?
3. **Colour is doing two jobs** — the stratum heat ramp, and the hazard/semantic
   reds. They may collide.
4. **3D at all.** A trackball camera makes text non-parallel to the screen and
   can make tiles unreadable. The reference demo is 12 years old.
5. **The provisional strip** mirrors lanthanides — but lanthanides are pulled
   out for *layout convenience*, not because they are epistemically inferior.
   The metaphor may import a meaning nobody intended.
6. **Whether "periodic table" should appear in the interface at all.**
