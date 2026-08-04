# Brainstorm Council — a 3D treatment worth looking at

Six lanes, three provider families, generative rather than adversarial.
Lenses: motion direction · form-finding · interaction & play · physical
instrument · contrarian · cinematic staging. **28 concepts.**

---

## 1. The unanimous diagnosis

Each lane was asked, blind, what the *others* would get wrong. Five of six
described the current build without having seen it:

- **motion:** *"They will decorate space — camera, layout, Z — instead of directing force and time."*
- **instrument:** *"They will animate the law graph instead of building with it. That describes relationships rather than enforcing them, so nothing in the scene can ever fail."*
- **contrarian:** *"They will treat the 29 laws as edges and draw them. It isn't an edge set — the `|` makes it a constraint system over choices."*
- **staging:** *"Everyone will reach for continuous, smooth, always-moving treatments."*
- **form-finding:** *"They will map S0–S4 onto Z and call that data-driven."*

That is exactly what I built: S0–S4 mapped to Z, a camera tilt, and a fly-in.
**The fly-in is dead in all six lanes.** Every lane replaced it.

The second convergence matters more: three lanes independently warned against
the *obvious* replacement — drawing the law graph as a 3D node-link diagram —
on the grounds that it produces a hairball that describes relationships without
enforcing them.

---

## 2. The four strongest concepts

### Photogram — *contrarian lane*
The system has no shadows. Introduce exactly one, ever, and give it a job.
A single fixed light at the S4 end; selecting an element makes it cast a
**hard, zero-blur silhouette whose outline is the transitive closure of the
laws beneath it** — the shadow lands precisely on the elements it requires.
Where a law offers alternatives (`Sh|Ix`), the umbra **splits into two equal
penumbral bands**: a divided shadow means the requirement can be met two ways
and neither has been chosen. Select two protocols and their shadows composite
multiplicatively — *the darkest patch on screen is the substrate both were
built on, and it is larger than either protocol's own footprint.*

No camera move. Not a fade — a straight edge sweeps across the plate in 340ms
like a contact print developing. The reduced-motion artifact is the finished
photogram, pixel-identical.

*Why it can't be lifted elsewhere:* the outline **is** the closure of a
directed, stratified graph with choice points. On other data, a shadow is a
shadow.

### The Lock-Up — *instrument lane*
Laws become **fasteners**. A protocol composes like type in a chase, in its
recorded causal order; quoins advance and close the gaps **in dependency order,
not left to right**; then the whole chase lifts to 30°.

Three outcomes. Closure complete → it lifts as **one rigid slab**; drag-tilt it
and nothing shifts. Closure incomplete → it **pies**: unsupported tiles drop
out through the gap they were never seated in, and *the hole left behind has
the shape of the missing law's socket*, which is the answer to "what was
missing." Reflexive death → it lifts, holds, and **binds**.

And the payoff the lane called the best fact in the brief: **the protocol that
died of an implementation bug locks up perfectly and lifts solid**, because the
table is deliberately blind to that class. A passing test that is also a death.

### Falls Through — *contrarian lane*
Twelve protocol columns stand on a single plate representing everything the
table can explain. Press one button. Each column self-audits 180ms apart; the
tile where a hazard fired takes hazard colour and the column tips 8° and
settles. Three deaths get accounted for. Then the fourth — every element
correct, no rule violated — **falls**. 620ms of accelerating ease, no bounce,
straight down through a hole exactly its own footprint, landing in unlit space
below. Nothing else moves. The plate seals behind it.

*One button, one fall, one claim about the tool's own scope.*

### Weight — *staging lane*
Tile size in 3D is set by **in-degree across the laws** — how many elements
require it — from 0.7× to 2.1×, static, never animated. Because tiles are DOM,
larger tiles are simply larger *type*.

This is the fix for the depth-as-Z inversion from the opposite direction: the
most-required elements become the **biggest on screen instead of the furthest
and smallest**. A protocol's chain then reads as a walk from massive to slight.

---

## 3. Also strong, not top four

- **The Descent** (staging) — camera path read off the causal order, holding at
  each element while the law that forced it draws itself as a hairline;
  unchosen `|` branches drawn as **stubs that stop short and never connect**.
- **Protocol Workbench** (play) — drag elements onto a bench; laws sprout empty
  sockets labelled by family alternatives; hazard edges flare as they arm. The
  user builds under the rules instead of watching.
- **Constraint Crystal** (form) — derive the strata from the laws by
  topological rank, *then* show the recorded S0–S4 rulers and reveal **where
  computed rank disagrees with the atlas's own assignment**. A finding
  generator, not just a layout.
- **Substitution Space** (contrarian) — the laws are a satisfaction problem, so
  render the *space of protocols that satisfy them*: a lattice of a few hundred
  legal alternatives with the shipped one lit, and whole slabs **punched out by
  hazard rules**.
- **The Denominator** (contrarian) — 19 sockets in a plate; most are empty
  holes you can see through; the bars that exist have **no bottom face** and
  dissolve, because the survivor count is unknown and cannot be shown.
- **No Bottom Face** (instrument) — the one async-impossible element is the one
  tile that *cannot be put down*; release it and it falls through. Atomicity
  enforced by physics rather than a badge.

---

## 4. Preserved dissent — the reflexive death

Three lanes gave three incompatible answers, and this is the sharpest
disagreement in the council.

| Lane | Answer | Argument |
|---|---|---|
| motion, contrarian | **Accelerate** — laps widen, speed up, and the trace never closes | Gain > 1 is the recorded outcome, so acceleration is data, not styling |
| instrument | **Bind** — an over-constrained linkage that stops turning while the user keeps dragging, shivers, then shears | Reflexivity does not spin faster, it *removes degrees of freedom* — and the user's own input is the destroying force |
| staging | **Stop** — motion halts, a static doubled-back link, held permanently | *"The collapse lands harder as a full stop."* A moving loop is still a loop that works |

Unresolved. The instrument answer is the most mechanically honest; the staging
answer is the most restrained.

**Second dissent:** staging holds that dimming non-members is wrong —
*"withholding by not visiting is stronger than withholding by fading, and
dimming turns the rest of the vocabulary into background for one product."*
The current build dims. Three other lanes assume dimming.

---

## 5. The channel audit

Colour is spent on hazard; lightness on depth. The lanes identified the
channels actually left, and each proposal names which it claims:

| Channel | Claimed by | Cost |
|---|---|---|
| **Hard shadow** (once, ever) | Photogram | breaks the no-shadow rule deliberately, for one meaning |
| **Edge profile** (sockets, keys, pegs) | Valence, Lock-Up, No Bottom Face | ~6px of tile padding |
| **Strain** (deformation, misalignment, shear) | The Bind, hazard joints | used at exactly three intensities |
| **Size** | Weight | forecloses size ever meaning status or family |
| **Contact / gap** | The Needle | the flat grid's gutter currently means nothing |

Nobody proposed glow, particles, bloom or a second hue — which was the trap.
