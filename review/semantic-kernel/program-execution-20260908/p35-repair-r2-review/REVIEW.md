P35 repair r2 independent review

**CHANGES_REQUIRED — two bounded repairs remain: AR4 (3D search geometry) and AR5 (3D printing and restoration).** Original AR1–AR3 are resolved on this candidate. The review does not authorize production integration or whole P35 closure. P36, obsolete matrix/3D restrictions, and unrelated work are outside scope.

The reviewer is the independent GPT-6 checker, requested identity `gpt-6-astra`; no separate provider attestation is assumed. Native author session `01a0831c-c63c-7571-bebe-9a92cde37a6e` ends normally after 58 turns with `grok-4.6-build` in the preserved native end event. Root reports actual shell 89193 exited 0; this reviewer did not observe that original process directly. Author 328 checks are evidence, not acceptance.

Inputs and exact scope

Archive SHA-256: `d165850a727a5bf28bfae1c92f91905e0cb7ccc2627e7d26d288acd588bb476f`. All 171 frozen member hashes were checked before and after review. The current page is 173,989 bytes, SHA-256 `2049b65f9f8b617d8ea2470ad3d73f22b1acee2c88f93c88fa5b7c2a722fa9e8`; an independent Vite build into this review directory is byte-identical. Only seven delivery files differ from the original r1 candidate: `viz/dist/index.html`, `viz/src/main.ts`, `packed.css`, `scene3d.ts`, `styles.css`, `three.css`, and `viz/test/e2e.py`. Source snapshots and the exact delivery overlay are in `source-overlay-manifest.json`. Historical r1 evidence remains unchanged and is referenced by hash, not recursively embedded.

I used the accepted P35 task 36.1–36.4 contract and the sealed prior review. All changes were confined to this new review directory. No author/source/plan evidence edits, commits, subagents, Foreman, Lean work, or network installations occurred. Browser processes and the reviewer-owned Xvfb instance were closed.

Required repairs

**AR4 — Search applies Flat slot measurements to the live 3D scene.** At `viz/src/main.ts:1022–1026`, every input calls `watchTileLayout`. That function (`:262–271`) finds the hidden `.depth/.families` layout and invokes `layoutTiles`, which assigns the zero-sized hidden slot dimensions to the actual CSS3D tile (`:238–255`). The 3D stylesheet deliberately hides those Flat containers.

Actual controls in `controls.json` cover both arrangements and all three reading orders. In every one of the six 3D combinations, E001 starts with inline width `131.188px`; searching `E001` changes width and height to `0px`; clearing the query leaves them at `0px`. The projected tile becomes a narrow strip (about 14 px wide in the broader probe) and text extends outside it. `3D-after-search.png` records the broken whole table after clearing. Switching to Flat restores `131.188px`, a useful positive control. The list and unique Enter selection work, but do not excuse corrupting the retained 3D view.

Keep Flat overlay measurement separate from CSS3D scene sizing. Preserve the results list, selected DOM order and filtering behavior. Recheck unique, multiple, empty and cleared queries in both dimensions and both arrangements, with all reading orders covered at least for the affected 3D geometry path. Require nonzero, readable tile boxes and restoration after clearing; option counts alone are insufficient. This is a new repair-candidate regression.

**AR5 — Printing from 3D omits table entries and fails to restore the scene.** Fresh `page.pdf` calls from Flat and 3D were made without synthesizing `beforeprint` or pre-setting print media. Instrumentation observed Chromium's real `beforeprint` and `afterprint` events in every run. Flat PDFs contain E001 and CSM and preserve screen geometry. Both frozen r1 and current r2 3D PDFs omit E001 and CSM: the required print behavior was already missing and remains open.

The new r2 handlers additionally damage the screen after printing: `main.ts:1106–1108` clears CSS3D inline dimensions, while `:1110–1112` restores only Flat placement. E001's rendered width changes from 131.342 to 179.346 px and height from 117.381 to 90.040 px; width, height and position styles remain empty. Frozen r1 preserves its pre-print screen box. This restoration failure is new. `controls.json`, `r1/r2-Flat/3D-fresh.pdf`, and extracted text retain the exact controls. A native Ctrl-P screenshot separately confirms the headed browser's real print preview; its first page is a bounded Flat visual observation.

Provide an ordinary printable document from the active 3D table and restore the exact active layout/dimension/order after print or cancellation. Recheck actual event-driven printing from both dimensions, printed IDs/content and a bounded visual inspection of the table pages, plus post-print geometry/focus. Do not turn the existing synthetic-event workaround into acceptance evidence. This repair combines an inherited unmet P35 print obligation with a new restoration regression.

Resolved findings and preserved contributions

| Obligation | Independent evidence | Result |
|---|---|---|
| AR1 selected DOM reading order | All 12 arrangement/order/dimension combinations match a source-derived order of all 59 IDs; keyboard sequences also match. The Flat permutation exemption is removed. Reading-order messages survive render. | Resolved |
| AR2 executed reduced motion | 40 rendered-position samples after focus: Flat and reduced 3D have zero x/y/width/height change. Normal 3D moves 7.527 px vertically over the same sampling pattern. | Resolved; positive and negative controls distinguish actual motion |
| AR3 rule-view overlays | Flat/3D→Laws/Hazards renders zero table tiles; return restores 59. | Resolved |
| Keyboard traversal | All 12 current combinations traverse 59 entries and open/close a representative detail with restored focus. The prior independent 708 activation cycles are preserved; no unsupported claim that all 708 were rerun. | Passing bounded regression check |
| Nine-field names | All 59 current rendered names equal their independently validated r1 names; data and naming formula remain unchanged. | Preserved |
| Badges and dimension state | Full table badge phrases are rendered; all ten contested badges say `contested: note required`; 3D button immediately reports pressed while Flat reports false. | Repaired |
| Search list/Enter/zero results | Unique result produces one option and one unhidden tile, Enter opens detail; zero query matches produce zero tiles/options and explicit message; multiple results and clearing work in Flat. | Functional contribution passes; AR4 prevents whole search acceptance |
| Per-element correspondence | Fresh actual conformance and copied-fixture controls: positive/restored exit 0; count-preserving E001/E057 status swap and missing E001 document row each exit 1 with the relevant rows named. | Preserved, bounded status correspondence |
| Build and budget | TypeScript, conformance, installed-dependency inspection and isolated Vite build pass. Dist is byte-identical and below current harness budget with CSS3D retained. | Preserved |
| README, atlas cross-reference, open questions | Existing dispositions and cross-references remain unchanged from independently reviewed r1; proposed primary-preserving README merge checked separately below. | Documentation contribution preserved |

Actual browser zoom and find controls

Installed Xvfb and XTest were sufficient; xdotool was not required. `headed_probe.py` launches ordinary headed Chromium on a reviewer-owned display and sends native Control-plus events through X11. Device pixel ratio advances 1→1.1→1.25→1.5→1.75→2 and layout viewport width 1280→640. The browser bubble visibly says **200%** in `native-zoom200*.png`. This is actual browser zoom, not CDP page scale or a root-font proxy. The default Flat depth layout reflows without horizontal overflow (document 632 px within the 640 px viewport), and the inspected table remains readable. No additional zoom defect was established. Coverage is this browser/layout observation, not an exhaustive browser/viewport audit.

A separate root-font test after layout settlement also grows E001 from 131.188×105.594 to 262.391×211.188 px, with no detected child-bottom clipping or horizontal document overflow. Thus the author's “tile width stayed ~131px” observation does not establish a remaining product failure on a settled fresh page.

Native Control-F accepts a real element-name query and highlights Constant-product in the tile. The impossible query removes that highlight. Screenshots retain the actual browser UI; the recent zoom bubble obscures part of its match-count area, so I do not claim a precise count from those captures. The earlier uncertainty about whether native zoom and find UI could be exercised is closed for this environment. A real screen-reader session was not required by this bounded plan, and its absence is an honest limitation rather than a newly added gate.

Print content/visual restoration remains a genuine required task, as AR5 demonstrates; it is not reduced to a generic “visual quality unavailable” disclaimer. Full contrast, other browser implementations and every possible UI state were not audited. Existing screenshot/open-question limits remain documented without expanding into P36.

Provenance and integration cautions

Author `STATUS.json` contains `2026-09-08T16:45:00+00:00`, earlier than recorded preparation/execution metadata (for example the red-probe command metadata at 22:31 UTC). I retain those bytes and treat that field as stale author metadata, not an attested completion time. Review records use actual UTC, now 2026-09-09 while local Denver remains September 8.

The native command history confirms that the red probe JSON was overwritten by a green run and then re-executed from frozen r1 HTML. Final `logs/red-probe.json` is reconstructed failure evidence (14 fails/1 note), not the original pre-fix JSON bytes. Moreover `red-probe-restored.json` is still identical to `green-probe.json` and contains current-page success observations; its filename is misleading. `red-provenance-summary.json` and `red-provenance-commands.json` bind the distinction. Original stdout/meta and historical independent r1 failures remain separate. These recordkeeping errata do not invalidate fresh independent repair controls and do not justify inventing original bytes or dates.

The primary README has newer discovery edits. I checked root's proposed merge SHA-256 `30c56c7609c8caf5348d11396daee16237c959ff1026bd06e02781e8fbf16bb5`: it preserves the complete primary README (`72f4fd635e3e709077c052fa45d2908c0faa9fa01f2e4a5a5e598b593a059703`) and appends the exact Atlas suffix (`920731614c8ee48094c21db3d903cfa4d6d9d2bcf6924a387b784c1784b44c38`). It is a valid proposed document overlay, not authorization to integrate this rejected source candidate. Do not copy the old candidate README wholesale.

Next gate: a newly frozen native repair addressing AR4 and AR5, checked against the targeted controls above while preserving resolved AR1–AR3, names, badges, current source/status checks and the exact delivery overlay. P35 remains open until those repairs pass; no additional scientific feature or unplanned assistive-technology campaign is requested.
