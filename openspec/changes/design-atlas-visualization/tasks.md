## 1. Teardown and data

- [ ] 1.1 Remove `three`, `@types/three` and the `atlas3d.ts` scene from `viz/`; remove `framer-motion` as a layout engine
- [ ] 1.2 Keep and extend `src/data.ts` as the typed export; add `lawCount` and `hazardIds` per element, derived at build time
- [ ] 1.3 Rename the `provisional` collection to `contested` throughout, and add prior-status/rationale fields for the five demotions and three additions
- [ ] 1.4 Write the sync check comparing the export against `docs/UNIFIED-DEFI-ELEMENT-TABLE.md`

## 2. Layout zero (build this first, feature complete)

- [ ] 2.1 Semantic markup: `<main>` → heading → outer list of groups (or strata) → inner list of element `<button>`s
- [ ] 2.2 Reading-order control (by group / by stratum / by ID) that rebuilds DOM order
- [ ] 2.3 Accessible-name template with all nine fields on every tile
- [ ] 2.4 Contested register as a separately titled, announced section
- [ ] 2.5 Detail surface as a focus-trapped dialog returning focus on close
- [ ] 2.6 Search over symbol, name and ID with results as a navigable list
- [ ] 2.7 Filters for group, stratum, status and asynchrony
- [ ] 2.8 Polite live region for layout, reading-order, filter and search announcements
- [ ] 2.9 Deep-linkable element URLs; verify find-in-page and print

## 3. Visual language

- [ ] 3.1 Rebuild palette: dark earth ground and neutrals; strip all hue from stratum; reserve chroma for the three hazard classes only
- [ ] 3.2 Stratum as printed `S0`–`S4` token plus monotonic lightness/inset depth
- [ ] 3.3 Status badge text, status glyph (≥14px, distinct silhouettes), border style as third redundant channel at ≥3px
- [ ] 3.4 Design and implement the missing-denominator mark; apply to hazards, candidates and contested entries only
- [ ] 3.5 Typography: monospace superfamily for all chrome and notation; serif reserved for human-authored assertion
- [ ] 3.6 Legend: stratum-is-not-risk copy, status key, hazard classes, and the meaning of the incomplete-form mark

## 4. Matrix and stratum layouts

- [ ] 4.1 Fixed 16×5 group-by-stratum matrix; cells as bounded containers with small-multiples grids
- [ ] 4.2 Per-cell occupancy count; empty cells rendered visibly empty
- [ ] 4.3 Non-semantic stack order within a cell stated in the interface
- [ ] 4.4 Stratum-band layout
- [ ] 4.5 Transform-only transitions via FLIP or View Transitions, ≤300ms, no stagger
- [ ] 4.6 Per-layout mapping statement in each header

## 5. Two-up comparison

- [ ] 5.1 Side-by-side matrix and stratum bands sharing one selection model
- [ ] 5.2 Static connector between an element's two positions
- [ ] 5.3 Make two-up the default layout-switch mechanism under reduced motion

## 6. Laws, hazards and bidirectional selection

- [ ] 6.1 Law and hazard list views as equal-sized non-quantitative cards
- [ ] 6.2 Persistent case-only-evidence statement in every hazard context
- [ ] 6.3 Select a rule → distinguish member and non-member elements, with the member list available as text
- [ ] 6.4 Select an element → list laws naming it, hazard memberships, required bonds
- [ ] 6.5 Law-participation count on the tile as a labelled integer, sortable, tile area held constant

## 7. Conformance harness

- [ ] 7.1 Deuteranopia and protanopia simulation over the swatch set; fail below 1.5:1 separation
- [ ] 7.2 Text contrast check at rendered sizes; fail below 4.5:1
- [ ] 7.3 Payload budget gate at 150 KB gzipped; fail on any scene-graph dependency
- [ ] 7.4 Keyboard traversal test across all reading orders
- [ ] 7.5 Reduced-motion assertion: no positional interpolation, no stagger, full feature parity
- [ ] 7.6 Accessible-name template assertion across all tiles
- [ ] 7.7 Wire the data/document sync check from 1.4 into the build

## 8. Close-out

- [ ] 8.1 Verify no chrome, nav item or layout label uses the phrase "periodic table"; verify the single permitted disavowal is present on the first screen
- [ ] 8.2 Screenshot test: limits legible without interaction
- [ ] 8.3 Update `README.md` and the atlas document to cross-reference the visualisation
- [ ] 8.4 Resolve or re-register the three open questions in `design.md`
