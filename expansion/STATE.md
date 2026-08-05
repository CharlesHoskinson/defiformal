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
The Bash-tool wrapper eats `$VAR` and `$(...)`: stage scripts as files and
`tr -d "\r"` them across `/mnt/c`.

---

## STAGES

| # | Stage | Output | Status |
|---|---|---|---|
| 0 | 12 category sections in `atlas.tex` | commit `ff196be`, 29 pages, 60 measurements | **DONE** |
| 1 | Research: 12 agents × top-5 apps — design, repo, architecture, citations | `C:\defiformal-work\NN-slug\01-research.md` | in progress |
| 2 | Deconstruction: each app → element set + residue, against `decomp-contract.md` | `NN-slug\02-decomp.json` | pending |
| 3 | Composition: construct each app from the formalism; machine-check | `NN-slug\03-construction.md` + `formal/v3/` | pending |
| 4 | Formalism improvements: what the constructions could not express | `algebra/EXTENSIONS.md` + paper edits | pending |
| 5 | Council: GPT-5.6 Sol auditors attack constructions and extensions | `review/COUNCIL-*.md` | pending |
| 6 | Paper expansion: 5 subsections per category section; build clean; commit | `paper/atlas.tex` | pending |

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

**LOOP-2 — integrity gate. Hourly at :07.**
Rebuild the paper. Re-run the four harnesses. Confirm every new numeric claim in
`atlas.tex` is reproducible from a committed script. Confirm no uncited protocol
claim entered the paper. Commit if clean; if not, fix before advancing.

---

## LEDGER

Append one line per firing to `LEDGER.md`. Never rewrite history there.

## CURRENT NEXT ACTION

Stage 1 for all 12 categories, running as background agents.
