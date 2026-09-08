# Current atlas visualisation contract (accessibility pass)

**Not a whole-package archive. Not a scientific-presentation or ontology
refresh.** This record reconciles the original OpenSpec package with later
client commits. Original plan bytes and council records stay historical.

## Override bindings

| Binding | Identity | Effect on original plan |
|---|---|---|
| Packed layout | commit `5b62605cc03d7902ac6c0bdcf61a6ddfd7c90396` (Git author Charles Hoskinson, 2026-08-04) | Replaces the 16×5 group-by-stratum cross-product and visible empty cells with five depth rows of labelled family blocks. “By family” replaces the old stratum-bands view. Empty intersections are omitted because they were structural emptiness, not a cosmetic gap. |
| Explicit 3D directive | commit `99d5f9af74a7e200f4d94eedbaf33c5f1895cbad` | Client directed 3D. Council 3D/three.js cut is a guardrail, not a veto. CSS3DRenderer only; same DOM nodes; focus drives camera; clamped orbit; reduced motion collapses interpolation. Conformance no longer bans `three`. |
| Interaction repair | commit `fe5a64392b92853d5fe755fe23045df00b88db36` | 3D tiles must remain pointer-interactive; mouse-click success does not close keyboard requirements. Historical `viz/test/e2e.py` was mouse/3D only and hardcoded `file:///root/DefiElements/viz/dist/index.html`. |

Council log `council/design/COUNCIL-DESIGN-LOG.md` remains advisory; all six
lanes returned `changes_requested`. It is not implementation acceptance.

## Current user-facing controls

- Arrangement: **By depth** / **By family** (packed successor of matrix / strata).
- Dimension: **Flat** / **3D** (client CSS3D).
- Reading order: **By group** / **By stratum** / **By ID**.

Declared reading-order contract (independent of `orderedElements()` in
`main.ts`):

- by group: group, then stratum, then ID
- by stratum: stratum, then group, then ID
- by ID: ID

Keyboard/roving tabindex and 3D CSS3D mount order must follow that contract
for every rendered table entry (59 `ELEMENTS` rows). Packed Flat **document
order** follows visual nesting (depth = stratum-major, family = group-major)
except where CSS3D remounts nodes in reading order.

## Unoverridden obligations this pass executed

- Every table entry reachable/activatable from the keyboard in all three
  reading orders, both arrangements, Flat and 3D.
- Arrow / Home / End / typeahead / Enter / Escape / focus restoration.
- Accessible names on every table tile contain the nine required fields.
- `prefers-reduced-motion: reduce` is emulated in the browser; positional
  interpolation, stagger and 3D tweening are observed, not grepped.
- Gzip budget 150 KiB on the actual new artifact.
- Per-element status sync against document §4, with a negative companion.
- Screenshot limits at specified viewports from actual UI, not generated art.
- README and atlas-document cross-links; three design questions re-registered.

## What this pass does not restore

The old 16×5 matrix, visible empty cells, 3D ban, and two-up comparison view
are not restored to force historical checkboxes. Two-up’s job (compare two
arrangements without relying on motion) is carried by the always-available
By depth / By family controls.
