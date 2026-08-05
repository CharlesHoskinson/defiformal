# defiformal — end-to-end DeFi model: run state

**Owner:** charles hoskinson (AFK). **Started:** 2026-08-04.
**This file is the contract.** Every loop firing re-reads it before acting.

---

## THE GOAL (verbatim intent, do not drift)

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
| 1 | Research: 12 agents × top-5 apps — design, repo, architecture, citations | `C:\defiformal-work\NN-slug\01-research.md` | **in progress**, 12 agents live |
| 2 | Deconstruction: each app → functional obligations + construction | `NN-slug\02-decomp\<app>.json` | pending, prompt ready in `PROMPTS.md` |
| 3 | Composition: machine-check every construction | `expansion/NN-slug/verdicts.json` | **machinery DONE** (`formal/v3`, commits `1fe4a46`…`00b89be`) |
| 4 | Formalism improvements: what the constructions could not express | `algebra/EXTENSIONS.md` + paper edits | aggregator ready (`formal/v3/residue.mjs`) |
| 5 | Council: GPT-5.6 Sol auditors attack constructions and extensions | `review/COUNCIL-*.md` | pass 1 running on stage 0 output |
| 6 | Paper expansion: 5 subsections per category section; build clean; commit | `paper/atlas.tex` | emitter ready (`formal/v3/emit-tex.mjs`) |

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
`expansion/<slug>/graphify-out/`, and the twelve merge into one cross-lane
graph. Built by `bash /root/kg.sh <slug>`, which runs two passes:

1. **AST pass** — `graphify update .`, deterministic, no LLM, always succeeds.
   This is what LOOP-3 gates on.
2. **Semantic pass** — `graphify extract . --backend ollama --model gemma4:26b`,
   which runs locally on the 5090 and adds cross-document edges. It may fail
   without losing the graph.

Neither pass costs API credit. Three facts the tooling does not advertise:
`graphify` runs from `/opt/conda/envs/graphify`, so the ollama backend needs
`openai` installed **in that env** (`/opt/conda/envs/graphify/bin/pip install
openai`) — installed 2026-08-04; `graph.json` calls its edges `links`, not
`edges`; and the semantic pass is GPU-bound, so lanes must be built one at a
time.

`bash /root/ingest.sh [slug…]` is the whole ingest step: copy the completed
research out of `C:\defiformal-work`, build the graph, and print a census of
all twelve. It is idempotent.

---

## LEDGER

Append one line per firing to `LEDGER.md`. Never rewrite history there.

## CURRENT NEXT ACTION

Seven lanes have research on disk (01, 04, 05, 06, 08, 10, 12); five are still
running (02, 03, 07, 09, 11). Stage 2 is launched for 05, 06, 08, 12 and should
be launched for 04 and 10 next, then for each remaining lane as it lands. Run
`bash /root/ingest.sh` after each completion — it is idempotent and builds the
knowledge graph.

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
