# Brainstorm brief — a 3D treatment worth looking at

This is **not a review**. Nothing here needs approving. You are being asked to
invent. Bring concepts, not verdicts.

---

## Part 1 — The subject

A reference table of the recurring mechanisms in decentralized finance. Think of
it as a vocabulary: about sixty parts that recombine into every protocol ever
shipped. The product's thesis is that DeFi has a vocabulary problem rather than
an innovation problem — once you can name the parts, the industry stops looking
novel and starts looking legible.

## Part 2 — The data you have to play with

Far more structure exists here than has been used. Everything below is real and
already in the app.

**59 elements**, each with:
- a **family** (16 of them) — a set of mutual substitutes. Everything in a
  family answers the same question, so one can replace another.
- a **depth** S0–S4 — how much must already exist before this can exist at all.
  S0 needs nothing but the ledger. S4 needs other people to agree.
- a **status** — core / candidate / contested / degenerate-limit.
- an **asynchrony** property — native, repairable, or *impossible*. Exactly one
  element (atomic flash liquidity) is async-impossible.

**29 laws — and these are a directed graph nobody has drawn.**
Each law says one element *requires* others. For example:
- `Pl → (Sh|Ix) + exit-liquidity` — pooled lending requires a claim record
- `(Pl|Im|Cd|Pf|Op) → (Ex|Tp|At) + Ct + (Li|Ad|Sl|Bs)` — anything leveraged
  requires a truth source, a solvency test, and a terminal loss path
Note the `|` — these are *alternatives*, so the graph has choice points, not
just edges. Depth correlates with in-degree: deep elements demand more.

**19 hazard rules** — combinations that are forbidden, elevated-risk, or
unverifiable. They connect elements that are individually fine. Colour in this
product means hazard and nothing else.

**12 real protocols**, each a subset of elements *in the order each part became
necessary*: pooled lending forces a solvency test, which forces a price oracle,
which forces liquidation. Four of the twelve are dead, and for those we know
what broke:
- one died of a **reflexive loop** — its collateral was priced by a market its
  own output dominated, so defending the peg destroyed the peg
- one died because collateral was its own thin token
- one died of an implementation bug with every element correct — the table is
  blind to that entire class, deliberately

## Part 3 — What exists now, and why it is not good enough

The flat view works: five depth rows packed with labelled family blocks, dense
and scannable. Selecting a protocol dims non-members and numbers its members
1..n in causal order.

The 3D view is **a tilted stack of five planes with a fly-in**. Selecting a
protocol pulls its members forward into a grid near the camera. That is a
coordinate transform, not an idea. It is indistinguishable from any CSS3D demo
of the last decade, and the client's verdict is blunt: it shows no
understanding of what makes a good 3D animation.

**Already tried and rejected, with reasons — do not re-propose these:**
- ambient camera drift (unprompted perpetual motion in a reading tool)
- sphere / helix / cube layouts inherited from a well-known demo (they assert
  nothing about the data)
- depth-as-Z as a *standing encoding* (redundant with row position and a
  printed token, and it pushes the largest, most important stratum furthest
  away and smallest)
- a constant-velocity orbit for the reflexive loop (a smooth ring reads as
  equilibrium, the opposite of a runaway)

## Part 4 — Constraints that are real

- Tiles are **real DOM** (CSS3DRenderer), so text stays crisp and selectable
  and keyboard focus works. WebGL text quads would delete all of that. You may
  propose WebGL for *non-text* layers alongside the DOM.
- **Colour means hazard.** The palette is dark earth, near-achromatic; there
  are no shadows anywhere in the system; lightness already encodes depth. If
  your idea needs a new visual channel, say which and what it displaces.
- The flat 2D document stays canonical and complete. 3D is an enhancement.
- Payload has room: currently 51 KB gzipped of a 150 KB budget.
- Motion must settle. Reduced-motion users must get an equal artifact, not a
  lesser one.

## Part 5 — What to bring

**Three to five concrete concepts.** For each:
- a name, and the **signature moment** — the one thing someone would screenshot
- **why it belongs to this data specifically** and could not be lifted onto an
  unrelated dataset
- what the user *does*, and what they understand afterwards that they did not before
- roughly what it costs to build, and what it displaces
- the failure mode: how it looks when it goes wrong

Be specific enough to build. "Make it more dynamic" is not a concept.
At least one of your concepts should be genuinely risky.
