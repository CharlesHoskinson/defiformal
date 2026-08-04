# DefiElements

A unified, typed vocabulary for describing what DeFi protocols mechanically do —
elements, groups, strata, typed bonds, composition laws, hazard rules and an
honest statement of what the model cannot explain.

## The deliverable

**[`docs/UNIFIED-DEFI-ELEMENT-TABLE.md`](docs/UNIFIED-DEFI-ELEMENT-TABLE.md)** —
The DeFi State-Transition Atlas, v1.0. Start at §1 (Quickstart); the complete
worked example is Appendix A.

48 core elements · 10 candidates · 10 provisional · 16 groups · 5 strata ·
4 bond types · 29 required-bond laws · 19 hazard rules.

## The visualisation

`viz/` — a browser view of the atlas. Build it with:

```bash
cd viz && npm install && npm run build
```

The result is a single self-contained `dist/index.html` — **16.3 KB gzipped**
against a 150 KB budget, with no external requests.

`npm run check` runs the conformance harness that gates the build: colour-vision
simulation across both themes, text contrast, payload budget, banned
dependencies, accessible-name template, and a data/document sync check. It
caught four real defects during development.

Its design brief was **decided by a six-lane blinded design council**, not by the
implementer. See `openspec/changes/design-atlas-visualization/` for the proposal,
ten design decisions with rationale, five capability specs and the task list; and
[`council/design/COUNCIL-DESIGN-LOG.md`](council/design/COUNCIL-DESIGN-LOG.md)
for the 41 findings, the six tension rulings and four preserved dissents.

The council cut an earlier three.js direction: with the non-semantic layouts
gone, both surviving arrangements are planar, so a scene graph was weight with no
return. It also removed hue from the stratum ramp after two lanes independently
computed that the hazard red and the deepest stratum collapsed to one swatch
under deuteranopia.

## How it was built

1. **Four source reports** (`corpus/`) — two independent "periodic table of
   DeFi" derivations and two independent CAKE unifications of them.
2. **Knowledge graph** (`graphify-out/`) — 421 nodes, 1029 edges, 19
   communities. `graph.html` is interactive; `GRAPH_REPORT.md` is the audit
   trail. Its most useful structure is 16 explicit *dispute* hyperedges linking
   the positions each source took on a contested question.
3. **Reconciliation** → `docs/unified-v0.1.md`.
4. **Blinded council review** (`council/`) — six expert lenses across three
   provider families, author identity sealed. All eight completed lanes returned
   `changes_requested`; 84 findings.
5. **Iteration** → v1.0. Every finding dispositioned in
   [`council/COUNCIL-LOG.md`](council/COUNCIL-LOG.md); the change itself is
   `docs/v0.1-to-v1.0.patch`.
6. **Design council** → the visualisation brief, then the build.

## Layout

```
corpus/                     the four source reports
graphify-out/               knowledge graph (html, json, report)
council/
  BUNDLE-blinded.md         exactly what reviewers saw
  BUNDLE.sha256             bundle identity
  REVIEW-BRIEF.md           the review contract
  reports/                  raw per-lane verdicts (JSON)
  COUNCIL-LOG.md            findings register, dispositions, preserved dissent
  design/                   the design council: bundle, verdicts, decision log
viz/
  src/data.ts               typed export, kept in sync with the document
  src/main.ts               the application
  scripts/conformance.mjs   the build gate
openspec/changes/design-atlas-visualization/
                            the decided design brief
docs/
  UNIFIED-DEFI-ELEMENT-TABLE.md   <- v1.0, the deliverable
  unified-v0.1.md                  pre-council draft
  v0.1-to-v1.0.patch               the iteration, as a diff
```

## Reading the council logs first

If you only want to know whether to trust any of this: read
`council/COUNCIL-LOG.md` §7 (preserved dissent), the atlas's §20.3 (what is
unmeasured and owed), and `council/design/COUNCIL-DESIGN-LOG.md` §5. All three
are deliberately unflattering.
