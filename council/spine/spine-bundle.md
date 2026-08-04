# Can the Lock-Up carry everything?

A previous council produced 28 concepts for a 3D treatment of a DeFi mechanism
atlas. One has been chosen as the **spine**: The Lock-Up. Your question is
whether the other strong concepts can be expressed *as states, modes, cameras
or gestures of that one object* — or whether some of them are genuinely
separate things that must stay separate.

**This is a synthesis problem, not a review and not a brainstorm.** Do not
propose new concepts. Take what exists and architect it.

---

## Part 1 — The data

**59 elements.** Each has a **family** (16, mutual substitutes — everything in
a family answers the same question), a **depth** S0–S4 (how much must already
exist before it can exist), a **status** (core / candidate / contested /
degenerate-limit), and an **asynchrony** property (native / repairable /
impossible — exactly one element is impossible).

**29 laws — a directed requirement graph with alternatives.**
`Pl → (Sh|Ix) + exit-liquidity`. The `+` is conjunction, the `|` is choice.
So the laws are a constraint system over choices, not a plain edge set.

**19 hazard rules** — combinations that are forbidden, elevated, or
unverifiable. Elements are individually fine; the danger is in the co-presence.
Colour in this product means hazard and nothing else.

**12 protocols**, each an element subset **in the order each part became
necessary**. Four are dead:
- one to a **reflexive loop** (collateral priced by a market its own output dominated)
- one to **own-token collateral**
- one to an **implementation bug with every element correct** — the table is
  deliberately blind to this class
- (a fourth structural death)

---

## Part 2 — The spine: The Lock-Up

Borrowed from letterpress. A protocol is composed like a line of type and
locked into a chase; if the composition is sound the whole forme lifts as one
rigid slab, and if it is not, it **pies** — falls apart in your hands.

**Compose.** The protocol's elements are set into a composing stick in the
recorded causal order 1..n.

**Lock up.** Quoins advance from both ends over ~480ms, sliding each tile until
it contacts its neighbour and its **sockets take the pegs** of the elements it
requires. Gaps close one at a time, visibly, **in dependency order rather than
left to right**.

**Lift.** The chase rotates to 30° over ~600ms. Three outcomes:
1. **Law closure complete** → lifts as one rigid slab. Drag-tilt it; nothing shifts.
2. **Closure incomplete** → it **pies**: unsupported tiles drop out through the
   gap they were never seated in, and *the hole left in the slab has the shape
   of the missing law's socket* — which is the answer to "what was missing".
3. **Reflexive death** → it lifts, holds, then **binds** (see dissent below).

**The payoff:** the protocol that died of an implementation bug locks up
perfectly and lifts solid, because the table cannot see that class of failure.

**Supporting mechanics already specified with it:**
- **Valence** — tiles have profiled bottom edges: one socket per `+` term, one
  multi-keyed socket per `(A|B|C)` group. Each tile has a peg on top whose
  profile is its **family** (families are substitutes, so their pegs must be
  interchangeable). S0 elements are flat-bottomed. Hazard pairs seat but the
  joint **will not close** — a permanent 3.5° misalignment, the only non-flat
  geometry in the system.
- **No Bottom Face** — the one async-impossible element cannot be put down;
  release it and it falls through. It can only be used if the lock-up closes
  around it in one continuous gesture.

---

## Part 3 — The other concepts that must be accommodated (or refused)

- **Photogram** — one hard shadow, ever. An element's silhouette falls on
  exactly the elements it requires: the outline is the **transitive closure**
  of the laws. At a `|` choice point the umbra **splits into two equal
  penumbras**. Two protocols' shadows composite; the darkest patch is their
  shared substrate.
- **Falls Through** — twelve protocol columns on a plate representing what the
  table can explain. Three dead ones stain and tip where a hazard fired; the
  fourth is spotless and **falls through the plate** into unlit space.
- **Weight** — tile size set by **in-degree over the laws**, 0.7×–2.1×, static.
  The most-required elements become the biggest.
- **The Descent** — camera falls through the depth strata stopping at each
  element of a protocol in causal order; the law that forced each step draws
  itself as a hairline; unchosen `|` branches are **stubs that stop short**.
- **Protocol Workbench** — the user drags elements onto a bench and builds;
  laws sprout empty sockets labelled with family alternatives; hazards flare
  as they arm.
- **Constraint Crystal** — derive the strata from the laws by topological rank,
  then reveal **where computed rank disagrees with the recorded S0–S4**.
- **Substitution Space** — the space of protocols satisfying the same laws as a
  lattice of legal alternatives, with slabs punched out by hazard rules.
- **The Denominator** — 19 sockets in a plate; most are empty holes; existing
  bars have **no bottom face** and dissolve, because the survivor count is
  unknown.
- **The Needle** — edge-notched card sort: push a needle through the deck and
  the matching cards fall out.

---

## Part 4 — What already exists and must survive

- A **flat 2D document** that is canonical, complete and keyboard-navigable. 3D
  is an enhancement over the same DOM nodes, never a replacement.
- Tiles are **real DOM** in CSS3DRenderer — crisp selectable text, working
  focus, a nine-field accessible name per tile.
- Colour means hazard. Lightness means depth. No shadows in the system
  (Photogram proposes to break this exactly once).
- Reduced-motion users must get an **equal** artifact, not a lesser one.
- Payload: 51 KB of a 150 KB budget used.

## Part 5 — Unresolved dissent you may settle

1. **The reflexive death**: accelerate (widening, speeding, never closing) vs
   **bind** (over-constrained linkage, user's own dragging is the destroying
   force) vs **stop dead** (motion halts, static broken link).
2. **Dimming non-members**: one lane argues it is wrong outright — *"withholding
   by not visiting is stronger than withholding by fading; dimming turns the
   rest of the vocabulary into background for one product."*

---

## Part 6 — What to deliver

- **The object model.** What is the one thing on screen, and what are its
  states? Name them.
- **The mapping.** For each concept in Part 3: is it a *state* of the chase, a
  *camera* on it, a *gesture*, a *separate surface*, or **cut**? Say which, and
  if cut, say why it cannot be reconciled.
- **The gesture set.** One coherent vocabulary of input, not nine.
- **The seams.** Where does the spine strain? Which concept is being forced?
- **A build order.** What is the smallest thing that is already worth shipping,
  and what comes next?
