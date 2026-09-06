> **Superseded as an execution mandate on 2026-09-06.** The user approved
> the [semantic-kernel migration](../docs/superpowers/specs/2026-09-06-semantic-kernel-design.md).
> Preserve the record below as historical evidence. Its primitive-basis and
> publication-first instructions do not govern new work.

# defiformal — end-to-end DeFi model: run state

**Owner:** charles hoskinson (AFK). **Started:** 2026-08-04.
**This file is the contract.** Every loop firing re-reads it before acting.

---

## THE GOAL WAS SUPERSEDED (2026-08-05)

The staged run below is **complete**: twelve category sections, sixty
machine-checked constructions, the residue analysis, the knowledge graphs.
Merged to GitHub as PR #1, merge `c31bda5`, and pushed since.

**The standing instruction is now publication**, given while the run was in
flight: remove the scaffolding and hedging, refine to original work, audit under
Halmos and Gottlieb for three rounds, follow AMS conventions, merge findings.

Three rounds ran; findings were actioned after each; all three verdicts are
**"not yet"**. `review/REVIEW-{1,2,3}.md` hold them. Round 3's unresolved list is
the current work:

1. ~~**The environment system**~~ — **DONE 2026-08-05** (`611ee8e`, `0183a4e`).
   The 24 repeated per-category measurements became two tables; six validation
   measurements moved to an appendix; six pair-composition measurements became
   one. **Measurements 70 → 44, unreferenced 53 → 30.** What round 3 asked for
   under this heading is complete.
2. **The article/supplement boundary** — the four case studies and the category
   table are in; round 3 wants the repeated Footprint/Rejection/Composition
   triplets across the twelve sections folded into the table too.
3. ~~**Elementary editorial failures**~~ — **DONE 2026-08-05** (`73765df`).
   Eight lead-ins that still promised profiles the article no longer carries, a
   duplicated paragraph, the composition theorem's proof stranded below the cost
   proposition, a sentence stranded on a table, a fragment, and a draft-layer
   phrase.

2. ~~**The article/supplement boundary**~~ — **DONE 2026-08-05** (`278d422`).
   Supplement canonical and generated whole: twelve headings, sixty profiles,
   contents, sources. Article keeps four abbreviated cases, relabelled `case:`
   so the two documents no longer collide. Article 38 pages, supplement 116.

**Round 3's list is fully actioned.** The next action is a **fourth review
round**. It is owed, not optional: rounds 1, 2 and 3 each found defects the
previous round missed — including a false polarity classification that had
survived two rounds and inverted a headline result — so a clean verdict has not
been earned and must not be assumed. Run `bash /root/review-round.sh 4`.

Current state, all verified: article 38pp, supplement 116pp, 0 undefined
references, 44 measurements, 37 proved items; 109 category claims, 22 self-tests,
totals, emission (60/60 and 4/4), structure, extensions and smoke all green.

What has been fixed is in the git log. What has not is in `REVIEW-3.md`, and it
is not resolved by pretending otherwise.

## THE ORIGINAL GOAL (verbatim intent, do not drift)

One rigorous, complete DeFi model, delivered as one paper:

> our formalism, model, 12 sections for each defi category, 5 subsections for
> each of those, and all the constructions.

For each of the 12 categories, take the **top five applications**. For each:
research its design, find its repo, analyse it, then **construct from the
paper's formalism a composition that reproduces the application's
functionality**. Where the formalism cannot express it, improve the formalism.
Have external auditors (GPT-5.6 Sol via codex) attack the result. Fold what
survives into the paper.

**Definition of done:** `paper/atlas.tex` builds clean (`./paper/build.sh`, which
fails on undefined references) and contains 12 category sections, each with 5
application subsections, each subsection carrying a construction that has been
machine-checked against `formal/v2/tables.mjs` and audited.

---

## INVARIANTS (violating any of these is drift)

1. **No number enters the paper that was not computed.** Every figure comes from
   a script run against `corpus50/lanes` through `formal/v2/tables.mjs`. Scripts
   live in `formal/v3/` and are committed with the claim they support.
2. **Epistemic labels are load-bearing.** `theorem` = proved; `measurement` =
   computed, instance and bound stated; `conjecture` = believed, evidence named.
   A construction that is not verified is not a measurement.
3. **Residue is reported, never tidied away.** Where a construction cannot
   reproduce an application, that is the result.
4. **The paper is a result, not a changelog.** `build.sh` greps for changelog
   phrases and fails. Do not narrate revisions in the paper.
5. **Cite or drop.** Every design claim about a live protocol carries a URL and
   an access date. No claim from memory.
6. **The WSL repo is the only source of truth** for the paper. `C:\defiformal-work`
   holds agent outputs and staging only; nothing is authored twice.
7. **Never end a turn with a summary while work remains.** Commit, then continue.

---

## ENVIRONMENT

| | |
|---|---|
| repo | `/root/defiformal` in WSL (Ubuntu-26.04), branch `paper/defi-category-atlas` |
| symlink | `/root/DefiElements -> /root/defiformal` (101 files hard-code the old path) |
| paper | `/root/defiformal/paper/atlas.tex`, build with `./paper/build.sh` |
| harness | `node /root/defiformal/formal/v2/{pairs,canonical,safe,antiexchange}.mjs` |
| lean | built, 734 jobs, mathlib cache restored (7.8 GB) |
| staging | `C:\defiformal-work\` — `corpus/` (per-category extracts), `NN-slug/` (agent output) |
| auditors | `codex` 0.145.0 at `/root/.local/bin/codex`, auth.json present → GPT-5.6 Sol |
| scraping | `scrapling` 0.4.12 on Windows + the `scrapling` skill |
| **pixelRAG** | **NOT INSTALLED** on Windows or WSL. Searching uses scrapling + WebSearch/WebFetch until it is available. Flag for the user. |

Windows tools cannot read `\\wsl.localhost\...` (EPERM). Agents write to
`C:\defiformal-work\`; the orchestrator copies into the repo and commits.

**Three traps that have already cost time on this run:**
1. The Bash-tool wrapper eats `$VAR`, `$(...)` **and `${...}`**. A patch
   containing template literals applied with the interpolations silently
   removed, twice, once landing in a commit. Stage every script and patch as a
   file, `tr -d "\r"` it across `/mnt/c`, and run the file.
2. `codex exec` reads stdin for additional input **even when given a prompt
   argument**, and blocks forever with no error. Always `< /dev/null`.
3. Under `set -o pipefail`, piping a tool that exits non-zero *by design*
   (a validator rejecting input) into `grep` reports the intended failure as a
   test failure. Capture output, then match.

---

## STAGES

| # | Stage | Output | Status |
|---|---|---|---|
| 0 | 12 category sections in `atlas.tex` | commit `ff196be`, then `05162ed` added §Constructions; 31 pages, 33 proved, 61 measurements | **DONE** |
| 1 | Research: 12 agents × top-5 apps — design, repo, architecture, citations | `expansion/<slug>/01-research.md`, all 12 committed | **DONE** |
| 2 | Deconstruction: each app → functional obligations + construction | `expansion/<slug>/specs/*.json`, 60 specs | **DONE** |
| 3 | Composition: machine-check every construction | `expansion/<slug>/verdicts.json`, 60 verdicts | **DONE** — 45 PARTIAL, 15 INADMISSIBLE, 0 COMPLETE |
| 4 | Formalism improvements: what the constructions could not express | `algebra/EXTENSIONS.md` + paper edits | **DONE**, priced; folded into the paper |
| 5 | Council: GPT-5.6 Sol auditors attack constructions and extensions | `review/COUNCIL-*.md` | two passes done; **pass 2 found a false polarity claim** — 4 findings remain open |
| 6 | Paper expansion: 5 subsections per category section; build clean; commit | `paper/atlas.tex` + `paper/supplement.tex` | **DONE**, all 60 emitted |

**Stage-3 toolchain, all committed and smoke-tested** (`bash formal/v3/smoke.sh`
→ `SMOKE OK`): `validate.mjs` rejects malformed specs; `construct.mjs` returns
the verdict; `emit-tex.mjs` generates the subsection *from the verdict*, so a
paper figure cannot drift from its computation; `residue.mjs` aggregates what
could not be named; `selftest.mjs` reproduces every published number from the
checker's own predicates (22 assertions).

**Auditor path verified 2026-08-04**: `codex exec -m gpt-5.6-sol` runs
read-only against the repo and independently counted the 12 category sections.

Stages are per-category, not global: a category may be at stage 3 while another
is at stage 1. Do not hold a barrier unless a stage genuinely needs all inputs.

---

## LOOPS

**LOOP-1 — drift check and advance. Every 15 minutes.**
Re-read this file. Answer in the ledger, in one line each:
(a) which stage each category is at; (b) did anything complete since the last
firing; (c) is the next action still the shortest path to the goal above;
(d) what is blocked and why. Then take the next action. If everything is
running, verify one completed artefact against the invariants instead of idling.

**LOOP-3 — knowledge-graph completeness. Every 30 minutes at :09 and :39.**
Every ingested lane must carry a graphify knowledge graph. Check
`/root/defiformal/expansion/<slug>/graphify-out/graph.json` for all twelve
slugs, run `bash /root/kg.sh <slug>` for any that are missing, and when all
ingested lanes have graphs, merge them into one cross-lane graph. A lane whose
research has not landed is PENDING, not FAILED.

**LOOP-2 — integrity gate. Hourly at :07.**
Rebuild the paper. Re-run the four harnesses. Confirm every new numeric claim in
`atlas.tex` is reproducible from a committed script. Confirm no uncited protocol
claim entered the paper. Commit if clean; if not, fix before advancing.

---

## KNOWLEDGE GRAPH

Every ingested lane carries its own graphify graph at
`expansion/<slug>/graphify-out/`. Built by `bash /root/kg.sh <slug>`, which runs two passes and **keeps
whichever produced more nodes**:

1. **AST pass** — `graphify update .`, deterministic, no LLM, always succeeds.
   Snapshotted before the second pass runs.
2. **Semantic pass** — `graphify extract . --backend ollama --model gemma4:26b`,
   local on the 5090.

Neither pass costs API credit. **Measured on this corpus 2026-08-04:** the AST
pass returns roughly one node per structural element (37 on a 485-line file),
while the local 26B semantic pass returns 11–25 *regardless of document size*
and **replaces** the graph rather than adding to it — so running it second
silently destroyed the better graph on three lanes before the guard was added.
Both counts are reported per lane; "the semantic pass lost" is a fact worth
recording, not hiding. If graphs stay thin, the next lever is a stronger local
model (`qwen3.6:27b`) or accepting AST-only, not more passes. Three facts the tooling does not advertise:
`graphify` runs from `/opt/conda/envs/graphify`, so the ollama backend needs
`openai` installed **in that env** (`/opt/conda/envs/graphify/bin/pip install
openai`) — installed 2026-08-04; `graph.json` calls its edges `links`, not
`edges`; and the semantic pass is GPU-bound, so lanes must be built one at a
time.

**The merged graph is not a cross-lane graph.** `graphify merge-graphs` is a
union merge: it namespaces every node by its lane, so `merged-graph.json`
(777 nodes / 684 links, the exact sums of the parts) contains **zero cross-lane
links** and splits into 102 components, each lying inside a single lane. The real
cross-category artefact is `expansion/graphify-out/domain-graph.json`
(1389/2601), built from `verdicts.json` rather than from prose: there all 66
category pairs share at least one element and no pair shares nothing, and the
six highest-degree nodes are all elements, not protocols. Both files are
described in `expansion/graphify-out/GRAPHS.md`, and every figure in that
document is re-derived by `python3 formal/v3/verify-graphs.py` (40 checks),
which `gate.sh` runs.

`bash /root/ingest.sh [slug…]` is the whole ingest step: copy the completed
research out of `C:\defiformal-work`, build the graph, and print a census of
all twelve. It is idempotent.

---

## WHERE EVERY LANE'S RESULT PERSISTS

Nothing this run produces is allowed to live only in a context window. Per lane,
under `/root/defiformal/expansion/<slug>/` and committed:

| file | what it is | who writes it |
|---|---|---|
| `01-research.md` | round-one design record, every claim with a URL and access date | stage-1 lane |
| `01-research-round2.md` | targeted second pass where round one was thin | round-two lane |
| `specs/*.json` | one construction spec per application: obligations, elements, evidence | stage-2 lane |
| `verdicts.json` | the checker's output per application | `construct.mjs` |
| `SECTION-NOTES.md` | the lane's judgement findings — what is *not* arithmetic | orchestrator, from lane returns |
| `SECTION-BRIEF.md` | **the input for writing the paper section**, generated | `section-brief.mjs` |
| `graphify-out/` | the lane knowledge graph | `kg.sh` |

`SECTION-BRIEF.md` is regenerated by `node formal/v3/section-brief.mjs
/root/defiformal/expansion` and merges the two: every figure computed from the
corpus, the specs and the verdicts, then `SECTION-NOTES.md` appended verbatim.
Stage 6 writes each `\section` from its brief and nothing else.

Corpus-wide: `FINDINGS-STAGE1.md` (formalism-bearing lane findings and the
cross-lane convergence table), `FINDINGS-STAGE3.md` (what the checker
established), `RESIDUE.json` / `RESIDUE.txt` (every unnameable obligation),
`EXTENSIONS.md` (stage 4).

**Audited 2026-08-04 against disk, not memory:** 11 of 12 research documents
present and tracked, 35 obligation specs, 7 verdict sets, 120 files under
`expansion/`. Only `02-lending` has no research document; its first agent ran
for hours without writing, and its replacement is briefed to write the file in
its first third of effort and improve it in place.

---

## LEDGER

Append one line per firing to `LEDGER.md`. Never rewrite history there.

## WHERE EACH CATEGORY IS (2026-08-05)

**All twelve categories are through every stage.** Each has research, five
specs, five machine-checked verdicts, a section brief, a lane knowledge graph,
and a written section in the article with its five profiles in the supplement.
There is no per-category work outstanding and no lane is behind another.

Corpus totals, from `node formal/v3/residue.mjs expansion`: **60 constructions,
1,259 obligations, 570 discharged, 689 residue, 45.3% coverage; 45 PARTIAL,
15 INADMISSIBLE, 0 COMPLETE.** The six
corpus invariants reproduce exactly — 61/72 protocols, 1830 pairs, 185 failures,
20/61 universally composable, 15 definite arcs, 0 anti-exchange violations.

What remains is not per-category. It is the review of the whole.

### The stale snapshot below is kept as history, not as status


**All twelve lanes have research.** Eleven are through stage 2 and stage 3;
`02-lending` landed last at 203 lines — the thinnest of the twelve, 16 citations,
49-node graph — and is still being improved in place by its agent, so re-ingest
rather than relaunch. Stage-3 running total: **55 constructions, 1,147
obligations, 522 discharged, 625 residue, 45.5%; 43 PARTIAL, 12 INADMISSIBLE,
0 COMPLETE.** Stage 4 is running on the 625 residue items. Council pass 1
returned 1 BLOCKING, 8 MAJOR, 3 MINOR; four are actioned (the unnamed predicate,
the false ranking, the overclaimed lead-in, the Lean fragment) and eight remain
in `review/ACTIONS-COUNCIL-1.md`. Three round-two research lanes are running on
perpetuals, RWA and fiat stablecoins.

### Earlier snapshot (after LOOP-1 #2)

| lane | research | stage 2 | stage 3 |
|---|---|---|---|
| 01-spot-exchange | done, 1508 lines | running | |
| 02-lending | **still running** | | |
| 03-cdp-stablecoins | done | running | |
| 04-liquid-staking | done | running (3 of 5 specs) | |
| 05-perpetuals | done | done | **done** |
| 06-yield-vaults | done | done | **done** |
| 07-bridges | done | done | **done** |
| 08-intents | done | done | **done** |
| 09-rwa | done | running | |
| 10-options | done | running (3 of 5 specs) | |
| 11-fiat-stablecoins | done | running | |
| 12-prediction | done | done | **done** |

**Stage-3 running total: 25 constructions, 503 obligations, 217 covered, 286
residue, 43.1% coverage; 18 PARTIAL, 7 INADMISSIBLE, 0 COMPLETE.**

## THE DEFINITION OF DONE IS MET (2026-08-04, commit be279b2)

> `paper/atlas.tex` builds clean and contains 12 category sections, each with 5
> application subsections, each carrying a construction machine-checked against
> `formal/v2/tables.mjs` and audited.

Verified by counting, not asserting — `python3 formal/v3/verify-structure.py`
reports twelve category sections, sixty application subsections, five under
each, no duplicate labels, and 60/60 carrying a Construction measurement whose
figures are emitted from `verdicts.json`.

| | |
|---|---|
| paper | article 38 pages + supplement 116; 44 measurements, 37 proved items, 3 conjectures, **0 undefined references** |
| corpus | 60 constructions, 1,259 obligations, 570 discharged, **689 residue**, 45.3% |
| verdicts | 45 PARTIAL, 15 INADMISSIBLE, **0 COMPLETE** |
| checks | 109 category claims, 22 checker self-tests, toolchain smoke — all green |
| graphs | 12 lane graphs, merged 709/618 (0 cross-lane links); domain graph 1,389/2,601 |

**What remains, in priority order:**

1. **Seven council findings** in `review/ACTIONS-COUNCIL-1.md` (2, 3, 4, 5, 6, 8,
   12). Findings 4, 5 and 6 touch the two new propositions and are the
   highest-value: whether `prop:neither`'s inference overreaches, whether the
   clutter/model-class parenthetical is sloppy, and whether `cor:notthe` should
   be scoped to its instance or demoted to a conjecture.
2. **A second council pass over the sixty subsections**, which no auditor has
   seen. Use `/root/run-audit.sh` as the model — Quint and Lean on PATH, stdin
   closed, out-of-scope directories named, final message extracted.
3. **Fold stage 4 into the paper.** `algebra/EXTENSIONS.md` is finished and
   priced; the three recommended repairs each need a paper statement with its
   cost named, and `Discharge.lean` already builds in the development.
4. **One unreconciled conflict**: lending found a pool delegate's cover blocks
   origination below a floor; RWA found the same cover documented as unused.
   Both are stated where they belong. It needs adjudication, not smoothing.

## TWO THINGS THE NEXT FIRING MUST NOT UNDO

**Coverage is a band, not a point.** `node formal/v3/fitgrade.mjs expansion` grades
every assignment by the specs' own capitalised markers. Of 570 assigned rows,
**193 carry a self-declared qualification** — 117 APPROXIMATE, 49 UNKNOWN,
38 FORCED, 5 ABSENT, 3 PARTIAL, against 2 EXACT. So coverage is **29.9% to
45.3%**: the upper end takes every assignment at face value, the lower keeps only
unqualified ones. Widest where the work was hardest (intents 13.3–26.5, bridges
18.0–28.1), narrowest where it was clean (yield vaults 41.7–50.5). This answers
council findings 4 and 9 and **has not yet entered the paper**, which still quotes
the point figure. It must, and the paper must call it recorded-obligation-row
coverage rather than protocol coverage.

**A check that cannot fail is not a check.** The emission invariant passed
vacuously for two commits: relabelling the article's cases left the checker
searching for labels that no longer existed, so it verified nothing and said
HOLDS. Every checker under `formal/v3/` that counts things must fail on a count
of zero, and `formal/v3/negtest-emission.sh` is the pattern: perturb the input,
require the checker to complain, restore. **Before trusting any green check,
ask what it printed as its denominator.**

---

## TWO SESSIONS ARE LIVE ON THIS REPO

The owner is working `/root/defiformal` from a second session. Before anything
else, every firing must:

1. `git fetch origin` and read `git log --oneline HEAD..origin/main`. As of
   `fdc3d09` we are in sync, no upstream commits, tree clean.
2. **Not launch a review round while the other session may be editing.** Codex
   reads the repository read-only for roughly fifty minutes; a manuscript edited
   mid-read makes the review worthless. Round 6 is deferred for this reason, not
   because it is unnecessary.
3. Prefer **additive** work — new checkers under `formal/v3/`, new generated
   artefacts — over edits to `paper/atlas.tex`, which is where a conflict would
   actually hurt.

---

## CURRENT NEXT ACTION

**ALL SEVEN ROUND-5 BLOCKERS ARE CLOSED.** Merged and pushed to
`github.com/CharlesHoskinson/defiformal`, branch `main`, head `2d503eb`.
Working tree clean.

**Article 39 pages, supplement 120 pages — 159 total.** Build OK, 0 undefined
references, 44 measurements, 37 proved items, 3 conjectures. **22 gate checks
green.**

| # | blocker | closed by |
|---|---|---|
| 1 | **a proof's `H` witness was FALSE** (both sets arm prohibitions) | `4f6c0c3` |
| 1b | `Adm₀` conflation, third site | `4f6c0c3` |
| 2 | AFT theorem not about an AFT approximator | `67ac453` — retitled *consistent bounding pairs*, AFT disclaimed in the theorem, abstract and introduction rescoped |
| 3 | bilattice prose overclaim; `\Delta` overloaded | `67ac453` — scoped to the family `C`; diagonal renamed `Diag` |
| 4 | residual "narrower/between" — relations are **incomparable** | `e50658e` |
| 5 | `lem:cm` a false biconditional | `98884f8` — sufficient direction only, converse scoped |
| 6 | instantiated tables absent | `c5d34e6` — supplement appendix: 58 elements, 29 requirements, 27 warrants, 20 prohibitions, generated from the tables the scripts read |
| 7 | **gates did not fail on the errors they claim to detect** | `4f6c0c3` + `2d503eb` |

### Blocker 7 is the one that matters for anyone continuing

`claims.mjs` — the "109 claims" quoted as evidence throughout — **never opens the
paper.** It guards the *corpus* against drift, which is what its header says.
Perturbing a table cell, the obligation total or a coverage figure leaves it
reporting "109 verified, 0 failed". **Do not cite it as evidence about the
manuscript.**

Two paper-facing checks now exist, each with a negative control that is run, not
assumed:

- `verify-setclaims.mjs` — every *"{A,B,C} … lie in ⟨class⟩"* decided against the
  algebra. This is what would have caught the false `H` witness.
- `verify-cattable.mjs` — the category table parsed out of `atlas.tex` and
  checked **cell by cell**, 64 cells. `negtest-cattable.sh` puts one perturbation
  to both checkers: bridges 25→26 gives `CATEGORY TABLE VIOLATED` against
  `109 claims verified, 0 failed`.

**Location-checking, where it now stands.** **All three summary tables** are
checked where their numbers are written, **148 cells** in total:
`verify-cattable.mjs` (64, against the expansion verdicts),
`verify-footprints.mjs` (36, against the corpus decompositions) and
`verify-composition.mjs` (48, using `pairs.mjs`'s own predicates rather than a
second definition of composability). Each has a negative control that asserts
its perturbation landed before believing the verdict.

**What is still NOT location-checked:** the measurement environments in the
body, outside the three tables. They remain corpus-checked only — the state
`claims.mjs` was found in. That is the next piece of work.

**A caution earned three times in one firing:** when a paper-facing checker
reports a failure, suspect the checker first. `verify-footprints.mjs` was wrong
three times — an unanchored row label that read the wrong table, a fuzzy category
matcher, and counting the symbol `Ve` which is not one of the 58 elements — and
the paper was right on every one. Each negative control must assert its
perturbation actually landed; one silently did not and reported VERIFIED.

### What round 5 confirmed sound

The repaired `thm:noncong`, the positive lattice argument and join/meet witness,
the restated `meas:closureprops`, the 22-element free family under exhaustive
verification, and all sixty supplement profiles matching their emitted blocks.

### The next action

**Round 6.** Five rounds have run, all "not yet"; round 5 said what remains after
its blockers is *"substantial editing rather than a new research programme"*.
Rewrite the prompt for the current manuscript first — the round-5 prompt is
already stale (it describes 39pp/116pp before the appendix, `Diag`, the
consistent-bounding-pair theorem and the two new checkers). **Do not report the
paper as publishable until a round says so.**

## THE STAGE-6 PROCEDURE (complete; kept because it documents how sections were written)



**Stage 6, category by category.** Perpetuals is done and is the template
(commit `7c85354`). For each remaining category:

1. Author a `paper` object on each of its five specs — `title`, `label`,
   `blurb`, `witnessReason`, `residueNote`. **Put no numbers in the prose**; the
   emitter supplies them. `witnessReason` must say why *this* construction among
   the alternatives the disjunctive terms leave open, per `cor:notthe`.
2. Re-run `construct.mjs` (specs changed) then
   `node emit-tex.mjs <specs-dir> <verdicts.json> > /root/<slug>-subs.tex`.
3. `python3 /root/splice-subs.py /root/<slug>-subs.tex "\section{<next section>}" "$(cat lead.txt)"`.
4. `./paper/build.sh`, then `node formal/v3/claims.mjs`, then commit.

Order by strength of finding: options next (two rejections that are artefacts
and two that are a defect in the language), then intents (26.5% coverage, the
disjoint residue behind an identity claim), then RWA and bridges (the party-sort
evidence), then the rest.

**Then fold stage 4 in.** `algebra/EXTENSIONS.md` is finished and priced. The
three recommended repairs — the party sort, the bounded delegate mandate at
presence granularity, discharge by construction — each need a paper statement
with its cost named, and `Discharge.lean` is already in the Lean development and
builds. The mandate now has four independent sightings and is the run's
best-evidenced finding.

`FINDINGS-STAGE1.md` holds the per-lane findings that bear on the formalism, as
they arrive. It is stage 4's input and the reason the lane summaries are not
lost when a context window turns over. Two entries in it are already
formalism-level rather than vocabulary-level:

- **the requirement language admits only one way to discharge a term** — name a
  satisfying element — and needs a second, *discharge by construction*, where
  the obligation cannot arise (options lane);
- **containment between protocols is inexpressible** — a meta-aggregator that
  routes to routers, and a curator who allocates over other protocols, are both
  relations the carrier has no way to state (intents and yield lanes).
