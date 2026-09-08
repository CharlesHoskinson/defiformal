# Atlas accessibility/conformance candidate — Grok 4.6 r1

**Result: a bounded current-layout accessibility/conformance candidate is
ready for independent GPT-6 review. It is not a whole-package archive, not
program completion, and not a scientific-presentation or ontology refresh.**

Author: native Grok 4.6. Checker: independent GPT-6 next. No Foreman. No
commits, push, or archive in this pass. Root owns publication onto the
semantic-kernel-pivot delivery branch after review.

Worktree: `/home/charl/defiformal-wt-atlas-grok-gpt6-20260908`
Branch: `work/atlas-grok-gpt6-20260908`
Base: `a12b7cac05a818cc8d35c2ca440b7170a2807e92`

Residual recovery inputs (unchanged identities):
- `residual-presentation-readiness-gpt6-review.md` SHA-256 `6def219a8f6cbbe5f17b4a4a30a2bd362324c5bfc2c807e017429b47df08b2a5`
- inputs SHA-256 `02a28baa0c510a1b7ebe95dce766d1ee910b56e041cc98bd2d100ff16a84b637`

## What was executed

1. Environment first. Chromium is not on `PATH`. Playwright Python **1.60.0**
   expected `chromium-1223` (missing). Cached
   `/home/charl/.cache/ms-playwright/chromium-1228/chrome-linux64/chrome`
   launched: **Google Chrome for Testing 149.0.7827.55**, SHA-256
   `2d18db9d8608b052b6a552ee00ec1e830f93692e928b65ecc67d693bd33fe801`.
   No mass install/upgrade.
2. `npm ci --prefer-offline` in this worktree from `viz/package-lock.json`.
   Node v24.18.1, npm 11.16.0, registry `https://registry.npmjs.org/`.
   Installed pins: three **0.185.1**, vite **8.2.0**, typescript **7.0.2**,
   vite-plugin-singlefile **2.3.3**.
3. Exclusive `npx --no-install vite build` of frozen source reproduced the
   historical cached artifact bit-for-bit
   (`66fa8baca91af74332ce0eb8966030e5a53cb32b427e0d1631c3a2ff3d2b3ab6`,
   169101 bytes). That is reproducibility, not a new-build claim.
4. New keyboard/name/reduced-motion tests against that baseline went **red**
   (23 fails / 199 ok). Preserved in
   `logs/baseline-e2e.stdout.log`. Mouse/3D historical checks already passed;
   they do not close keyboard requirements.
5. Minimal source repairs in `viz/src/main.ts`, harness repairs in
   `viz/test/e2e.py` and `viz/scripts/conformance.mjs`. Independent expected
   order lives in `viz/test/atlas_contract.py` (does not copy `orderedElements`).
6. After-fix artifact is distinct:
   SHA-256 `a807f92d52dee0dd83edced788616288e3e9691776fed9245e427a333f2a058d`,
   169429 bytes, gzip **51721** (budget 150 KiB = 153600). URL bound to
   `file:///home/charl/defiformal-wt-atlas-grok-gpt6-20260908/viz/dist/index.html`.
7. After e2e: **238 ok / 0 fail**, exit 0, browser 149.0.7827.55.
   Keyboard: 12 combinations × 59 entries, focus sequence matched declared
   order in all. 3D DOM order matched declared order in all six 3D cells
   after mount-order repair. Names: 59/59 table tiles, zero missing fields.
   Reduced motion: `matchMedia` true, `getAnimations()==0`, no positional
   interpolation. Screenshots: actual UI at 1600×1000, 1920×1200, 1280×800,
   900×700; disavowal in first viewport; tile symbol font 20px; no overlaps.

## Baseline red that was a test oracle, versus real defects

| Observation | Disposition |
|---|---|
| `dialog.detail` still in DOM after Escape | Test oracle. Native dialog stays in the tree when `open===false`. Focus restoration already passed. Assertion now uses `dialog.open`. |
| `page.fill('#q')` leaves `activeElement` on INPUT | Test oracle for “user is typing”. Real contract is roving tabindex on remaining tiles. |
| Flat DOM order ≠ declared reading order when arrangement axis differs | Packed-layout override (`5b62605`). Completeness still required. Exact global match required for aligned Flat pairs and for all 3D mounts. |
| 3D tree order followed `ELEMENTS` insertion, not reading order | Real defect. `measure()` now inserts CSS3D boxes in declared reading order. |
| Search did not move tabindex off an excluded first tile | Real defect. Input handler now points tabindex at the nearest remaining entry. |
| `render()` while `state.three` disposed the scene without re-entering | Real defect. `render()` disposes and re-enters 3D. |

## Source facts preserved

- `viz/src/data.ts` SHA-256 still
  `4227433a8a965f9890a6c277991189f1c5087fab336a3ba146d9949026dfeb84`.
- Original `tasks.md` SHA-256 still
  `9e45305f0d36afbfafa8a42cb749814c190a8b7460384e1bb6be9a384db37301`
  with 7.4/8.2/8.3/8.4 unchecked.
- No Lean, corpus, paper, graph, or holdout/assessment reads for new claims.

## Remaining package obligations (accurate)

This candidate can be delivered independently of the old visualisation
archive. Remaining before any whole-package archive:

- Historical task checkboxes and council records stay as-is until root
  archival.
- Search-as-navigable-list / highlight-only residual.
- Visible badge full-wording residual (accessible names already full).
- 200% text, print, find-in-page not re-executed here.
- Two-up connector UI not implemented (superseded, not passed).
- Honest-gate-failure closeout is a different package.
- Operational ontology, graph redesign, and final scientific narrative wait
  on accepted stable results.

Independent GPT-6 should review this directory plus the listed viz/README/doc
diff. Do not treat worker authorship as acceptance.
