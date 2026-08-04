# Design Council Log — Atlas visualisation brief

**Bundle:** `design-bundle.md`
**sha256:** `1001ece560a715c80dc4a8c957f3e457cdc4e748daf32ce59454d2e069b24bf7`
**Identity leak check:** clean
**Date:** 2026-08-04
**Status:** advisory. The council decides the brief; it does not own the build.

---

## 1. Run record

| Lane | Lens | Family | Verdict | Findings |
|---|---|---|---|---|
| D1 | Information design / encoding | openai | `changes_requested` | 6 |
| D2 | Interaction & motion | xai | `changes_requested` | 6 |
| D3 | Art direction & visual identity | anthropic | `changes_requested` | 7 |
| D4 | Accessibility & inclusive design | anthropic | `changes_requested` | 10 |
| D5 | Scientific communication & metaphor | openai | `changes_requested` | 6 |
| D6 | Front-end architecture & performance | xai | `changes_requested` | 6 |

Six lanes, three independent failure domains, 41 findings. **No lane approved.**

---

## 2. Tension rulings

The brief asked the council to settle six tensions it could not settle itself.

| # | Tension | Rulings | Decision |
|---|---|---|---|
| 1 | SPHERE / HELIX / GRID | cut (D1, D2, D6); constrain (D4) | **CUT.** Unanimous among lanes that ruled. They assign visually salient positions with no data meaning, which invites false relational readings and trains the user that layout change is spectacle. |
| 2 | Ragged staircase | change (D1, D4) | **CUT.** Replaced by a fixed 16×5 group-by-stratum matrix whose cells visibly hold multiple elements. |
| 3 | Colour doing two jobs | change (D1, D3, D4) | **CHANGE.** Hue is removed from stratum entirely. Chroma is reserved for hazard class alone. |
| 4 | 3D at all | cut three.js (D6); demote to enhancement (D4); constrain camera (D2) | **CUT three.js.** With tension 1 cut, only TABLE and STRATA remain and both are 2D — a 3D engine with no 3D layouts is pure weight. |
| 5 | Provisional strip as lanthanide pull-out | change (D1, D3, D4, D5) | **CHANGE.** Retitled *Contested register*, separately framed, and position is never the encoding. |
| 6 | "Periodic table" in the interface | cut (D3, D5) | **CUT**, with one exception — see §5 dissent. |

---

## 3. The finding that carried the most weight

**Two lanes independently computed the same colour collision, from the brief's
own hex values, without seeing each other's work.**

- D3: hazard `#A8442E` sits at hue ≈11°, stratum-S4 rust `#A8523A` at ≈13° —
  2° apart, sharing an identical red channel (168/168).
- D4: the same pair computes to a 1.12:1 luminance ratio; under deuteranopia or
  protanopia the distinguishing red-green difference is gone and they become one
  swatch. The full five-step stratum ramp spans only 1.50:1, so adjacent strata
  are separated by ≈1.1:1 — not a perceivable step.

Consequence: *"this element sits at the deepest stratum"* and *"this combination
is forbidden"* would have rendered as the same colour. A reader scanning for
hazard would have read dependency depth as danger.

This is why colour is now reserved for exactly one meaning.

---

## 4. Convergent findings

| # | Finding | Raised by | Decision |
|---|---|---|---|
| C1 | Status must be a **text** channel first, not fill/border/colour — otherwise blind, low-vision and dichromatic users receive an atlas where all 69 entries look equally authoritative | D4 F1, D5 F4, D1 (keep) | **Accepted.** Plain-language status badge on every tile, status word in the accessible name, border style demoted to third redundant channel. |
| C2 | The hazard table has no denominator and must never be drawn as if it had one | D1 F5, D5 F3, D3 F7 | **Accepted.** Categorical membership only — no gradients, gauges, percentages, ranked bars, area encodings or likelihood language — plus a persistent case-only-evidence statement. |
| C3 | The 2D document view is not a fallback; it is layout zero and must be built first, feature-complete | D4 F4, D6 F1, D6 F5 | **Accepted.** `atlas-accessibility` is dissolved as a separate capability; its requirements become acceptance criteria inside the others, and what remains standalone is an automated conformance harness. |
| C4 | The trackball conflicts with clickable, focusable tiles; small drags eat clicks and tab order diverges from visible order | D2 F2, D4 F3, D6 F4 | **Accepted.** No camera. Tiles are ordinary buttons in explicit DOM order. |
| C5 | A ~1.5s staggered transition is a first-visit effect that becomes an obstacle on the tenth use | D2 F3, D4 F5 | **Accepted.** ≤300ms, no stagger by default. |
| C6 | Search must be the primary find path for 69 entries, not spatial browsing | D2 F5, D4 F10 | **Accepted.** |
| C7 | Laws and hazards are first-class data with no stated interaction — you cannot ask "who is in this hazard?" | D2 F6, D1 F4 | **Accepted.** Bidirectional selection between elements and rules. |

---

## 5. Preserved dissent

1. **The palette's register.** D3 argued the earth/mineral world is borrowed
   from chemistry and re-asserts in colour the scientific authority the prose
   disclaims, and directed a forensic/ledger register instead — *"delete
   'olive', 'rust' and 'iron-oxide' as palette names; naming the swatches after
   minerals is what locked the direction into geology."* **Overruled on taste:
   the client directed dark earth tones explicitly, and the client's words
   outrank the council's.** D3's *defect* findings — the hue collision, the
   heat-ramp implication, the three-family type system — are all accepted. What
   is rejected is only the change of register. Recorded because it is a real
   disagreement, not a misunderstanding.

2. **Whether "periodic table" may appear at all.** D5: nowhere, because the
   phrase activates the recurrence, atomic-order and closure claims the source
   rejects. D3: exactly once, inside the sentence that denies it. **Adopted
   D3's position** — a denial the reader never sees cannot do any work. D5's
   stricter reading stands unresolved.

3. **Whether three.js survives as a progressive enhancement.** D6: cut
   entirely. D4: keep, demoted, gated on reduced-motion and viewport.
   **Adopted D6's position**, because cutting tension 1 removed every layout
   that needed it. If a genuinely 3D layout is ever justified by the data, this
   decision should be revisited rather than assumed.

4. **Chromatic separation between strata.** D4 noted an accessibility lens
   might want *more* colour separation between strata, not less. The decision to
   strip hue entirely resolves the hazard collision but leaves stratum leaning
   on position, token and value. If that proves too weak in testing, the fix is
   more lightness separation — never more hue.

---

## 6. The one idea the council added that the brief did not have

D3 F7: the atlas's central editorial virtue — *the hazard table has no
denominator* — is currently handled as a caveat to be written down. But a
missing denominator is a **shape**. Direction adopted: every hazard indicator,
every candidate element and every contested entry renders as a visibly
incomplete form — a fraction rule with an empty space where the sample size
belongs. One consistent, unmistakable shape meaning *we do not know the
denominator*, used nowhere else.

It cannot be lifted to another subject, it cannot be read as decoration, and it
turns the brief's chief epistemic commitment into its signature graphic.
