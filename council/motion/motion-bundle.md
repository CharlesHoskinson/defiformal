# Design brief under review — adding three.js motion to a working table

You are deciding **how**, not whether. The client has directed three.js. Your
job is to make that decision good, or to say precisely where it will do damage.

---

## Part 1 — What exists now, and what it cost to get here

A reference table of the recurring mechanisms in decentralized finance:
**48 core elements, 10 candidates, 10 contested**, in **16 substitutability
families** across **5 prerequisite depths (S0–S4)**.

### The layout was already rebuilt once

The first attempt was a 16×5 group-by-depth matrix. It failed badly: **61 of
80 cells were empty**, because family and depth are close to collinear in this
data — credit is entirely S3, pricing entirely S1, truth entirely S2. A
cross-product of two nearly-dependent axes cannot be filled. The client's
verdict on it was "unusable".

**The current form is packed:** five depth rows, each holding a run of labelled
family blocks. Only what exists is drawn. Row is exactly depth; block is
exactly family. Nothing is empty. Tiles became large enough to read because the
layout stopped spending space on nothing.

The shape now carries a finding on its own: **S0 holds 3 elements, S3 holds 22.**
Most of DeFi is machinery for owing, pricing and unwinding obligations.

### What else the interface does

- **Protocol projection.** Twelve real protocols (Aave, Uniswap v3, Maker,
  Lido, CoW, CCTP, Centrifuge; and four dead ones — Terra, Mango, Euler).
  Selecting one dims every non-member tile and numbers its members **1..n in
  the order each part became necessary**. Aave's ten parts land across four
  different depth rows.
- **Dead protocols** additionally show what broke, a reflexive cycle drawn as
  a loop, the loss, and the hazard rule naming the shape.
- Detail dialog per element, search, filters, laws and hazards views.

### Hard constraints carried from the previous council

These were decided by an earlier six-lane review and are not up for
re-litigation unless you have a specific, strong reason:

1. **Colour means hazard and nothing else.** Depth carries no hue — it is row
   position, a printed S-token, and a lightness ramp solved for contrast.
2. **Status is text first** — a badge on the tile face plus a nine-field
   accessible name. Glyph and border are redundant channels.
3. **The 2D document is layout zero**, feature-complete, canonical — not a
   fallback.
4. **No overclaiming.** This is explicitly not a periodic table: no periodic
   law, no atomic number, no closure.
5. Single self-contained file. Current payload **22.5 KB gzipped**; the budget
   is 150 KB. three.js will consume most of the remaining headroom.

### Why the previous council cut three.js

Unanimously, on these grounds: the only layouts that justified a scene graph
were non-semantic (sphere, helix, grid) and were themselves cut; a free
trackball camera puts tile text off-axis; camera drag conflicts with clickable,
focusable tiles; and ~68 permanently composited layers stress mobile
compositing.

**Two corrections to that record, which you should weigh rather than inherit.**
First, the claim that CSS3D makes text unreadable was overstated — the
reference demo is demonstrably legible face-on, and the defect belongs to free
rotation rather than to the renderer. Second, the client has seen that demo and
judged it legible. **Assume three.js is in. Decide what it should do.**

---

## Part 2 — The proposal you are reviewing

### Core idea: depth becomes literal

Map **stratum to the Z axis**. S0 sits nearest the viewer, S4 furthest back.
"How much must already exist underneath this" stops being a label and becomes
physical distance. The claim is that this is a semantic use of 3D rather than a
decorative one.

### Proposed motion

1. **Assembly.** Selecting a protocol flies its member tiles forward out of the
   depth planes and assembles them in reading order, 1..n, while non-members
   recede and desaturate. For Aave this is a climb from S0 up to S4.
2. **Depth parallax.** Slow, small camera drift so the separation between
   planes is perceivable without interaction.
3. **The reflexive loop.** For Terra, the three elements in the cycle orbit a
   closed path — the loop that killed it, drawn as an actual loop in space.
4. **Arrangement change.** Moving between *by depth* and *by family* re-forms
   the tiles through 3D rather than a 2D FLIP.

### Proposed technique

`CSS3DRenderer`, so tiles stay real DOM — selectable text, working focus,
existing accessible names — rather than WebGL quads. Camera constrained: no
free trackball, tiles always parallel to the view plane, movement limited to
dolly and small orbit.

---

## Part 3 — Tensions the brief has not resolved

Rule on the ones inside your lens.

1. **Does Z-as-depth actually teach anything**, or is it a literalisation of a
   metaphor that was already clear from row position and a printed token?
2. **Density and scanability are the packed layout's whole virtue.** Note the
   evidence here, because an earlier review overstated this: the well-known
   `CSS3DRenderer` periodic-table demo renders its tile text **perfectly
   crisply** in its default face-on state. CSS3D does not blur text as such.
   Degradation comes from *free rotation* and from non-integer scale, not from
   using a scene graph. So the honest question is narrower: at what camera
   angles and dolly distances does this specific table stop being scannable,
   and where should the constraint be set?
3. **Is the assembly animation teaching or theatre?** The numbered 1..n order
   already conveys sequence statically.
4. **CSS3D vs WebGL.** CSS3D preserves DOM and accessibility but blurs text
   under transforms and composites badly at scale. WebGL renders beautifully
   and throws away every accessibility property already built.
5. **What does a reduced-motion or non-3D user get?** They must not receive a
   lesser product — that was a binding ruling last time.
6. **Payload.** three.js will take most of the remaining budget for motion that
   may be decorative. Is that trade defensible?
7. **Does 3D fit this visual world at all** — a flat, dark, ledger-like
   interface whose entire discipline is that nothing is decorative?
