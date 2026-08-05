# Agent prompts for each stage — use verbatim

Any loop firing, including one with no memory of how stage 1 was launched, can
run the pipeline from here. Substitute `NN-slug`, `CATEGORY` and the five
application names from `C:\defiformal-work\corpus\index.json`.

---

## STAGE 2 — deconstruction (one agent per category, `general-purpose`)

> You are the STAGE-2 DECONSTRUCTION lane for the "CATEGORY" category of the defiformal project. The user is AFK on a long staged run; work autonomously and completely.
>
> READ FIRST: `C:\defiformal-work\STATE.md` (the contract — obey the INVARIANTS), `C:\defiformal-work\NN-slug\01-research.md` (stage 1's design record for your five applications), `C:\defiformal-work\corpus\NN-slug.json` (the 2026-08-04 decomposition of each), `C:\defiformal-work\corpus\vocab.md` and `00-vocabulary.json` (the 58 elements and the constraint tables), and `C:\defiformal-work\corpus\decomp-contract.md` (the decomposition contract the original lanes worked under).
>
> TASK. For each of the five applications, write a construction spec: the list of FUNCTIONAL OBLIGATIONS the application discharges, each with the elements that discharge it, plus the element set you propose as the construction.
>
> An obligation is ONE thing the application does, stated so a reader can check it against the cited source — not a component, not a contract name. Aim for 10–20 obligations per application: enough that the set characterises the system, not so many that they restate the code.
>
> For each obligation give `elements`: every element of the 58 that would discharge it. If no element names it, `elements` is the EMPTY ARRAY. That is residue and it is the most valuable output of this stage. Never force a behaviour onto a nearby symbol; the project's standing rule is that a finding of FAILURE beats a forced fit. If you use a symbol approximately, say so in `note`.
>
> `construction` is the element set you propose. It should cover every non-residue obligation and carry nothing that discharges none of them. Start from the corpus decomposition in the JSON, and depart from it wherever stage 1's evidence says the corpus is wrong — recording the departure and the evidence in `note`.
>
> OUTPUT: one JSON file per application at `C:\defiformal-work\NN-slug\02-decomp\<app-slug>.json`, in exactly this shape:
> ```json
> { "app": "Aave v3", "category": "NN-slug",
>   "source": "C:\\defiformal-work\\NN-slug\\01-research.md",
>   "construction": ["Pl","Ix","Ct","Ex","Li"],
>   "functionalObligations": [
>     { "id": "F1", "text": "a depositor holds a claim whose value accrues by a global index",
>       "elements": ["Ix"], "evidence": "https://... (accessed 2026-08-04)", "note": "" }
>   ] }
> ```
> Every obligation needs an `evidence` URL with an access date, carried over from stage 1. A spec without one is rejected by the validator.
>
> Do NOT edit the paper, the repo, or the corpus. Do NOT run the checker — stage 3 does that, and it is a separate pair of eyes on purpose.
>
> Final message under 200 words: obligation counts and residue counts per application, and the one behaviour in your category the vocabulary most clearly cannot name.

---

## STAGE 3 — construction and machine check (orchestrator, not an agent)

Copy the specs into WSL and run the checker. Nothing enters the paper without a
verdict from it.

```bash
mkdir -p /root/defiformal/expansion/NN-slug
cp -r /mnt/c/defiformal-work/NN-slug/02-decomp/*.json /root/defiformal/expansion/NN-slug/
cd /root/defiformal/formal/v3
node validate.mjs /root/defiformal/expansion/NN-slug     # rejects malformed specs
node construct.mjs /root/defiformal/expansion/NN-slug --json /root/defiformal/expansion/NN-slug/verdicts.json
```

Read `formal/v3/README.md` for the verdict vocabulary. `PARTIAL` is the expected
outcome and its residue is the finding; `COMPLETE` on a large application should
be attacked before it is believed; `INADMISSIBLE` is a result about the tables,
not a criticism of the protocol, and the open term must be named in the paper.

---

## STAGE 4 — formalism improvements (orchestrator + `foreman-plan` agents)

Collect the residue across all 60 constructions. Group it. For each group,
state: what the vocabulary cannot express; whether the repair is a new element,
a new constraint form, or a new level above the protocol; and what it does to
the algebra — polarity, closure, the convex geometry, the compatibility graph.
A repair that destroys a theorem must say which. Output `algebra/EXTENSIONS.md`.

---

## STAGE 5 — council of auditing mathematicians (`codex-auditor`, GPT-5.6 Sol)

One auditor per category for the constructions, plus two on the extensions.
Launch with `/root/run-audit.sh` as the model: `export PATH=/root/.local/bin:/root/.elan/bin:$PATH`,
`codex exec --sandbox read-only -m gpt-5.6-sol -c model_reasoning_effort=high
"$(cat prompt)" < /dev/null`. **Every auditor prompt must carry the two clauses
below** — they are the user's standing instruction for the council.

**Two skill kits are installed for them** (cloned 2026-08-04, user's instruction):

| kit | where | what to read |
|---|---|---|
| `quint-co/quint-llm-kit` | `/root/skills/quint-llm-kit` | `agentic/guidelines/{verification,quint-constraints}.md`, `agentic/agents/{verifier,analyzer}.md`, and the three skills under `quint-llm-kit-plugin/skills/` (already installed as Claude skills: `quint-lang`, `quint-modeling`, `quint-execute-spec`) |
| `cameronfreer/lean4-skills` | `/root/skills/lean4-skills` | `plugins/lean4/skills/lean4/SKILL.md`, `GUARDRAILS.md`, `commands/{disprove,diagnose,review}.md`, `agents/axiom-eliminator.md`. Tier-1 installed to `C:\Users\charl\.claude\skills\lean4`, so Claude subagents reach it with the Skill tool |

`quint-constraints.md` matters beyond technique: if a claim in the paper cannot
be stated as a Quint invariant, *why not* is itself a finding. The `disprove`
workflow is the one to reach for when a claim smells false — state it, then hunt
the counterexample rather than the proof. `axiom-eliminator` is how the
no-custom-axioms claim gets checked properly rather than by reading prose.

For a full Claude Code plugin install rather than Tier 1, the user runs
`/plugin marketplace add cameronfreer/lean4-skills` then `/plugin install lean4`,
which also registers the `/lean4:*` commands and subagents.

**They can use Quint and Lean to think, not only to check.**

> You have tools; do not reason from the page alone.
> `quint` is at `/root/.local/bin/quint`, with existing models at `formal/atlas.qnt`, `formal/atlas_test.qnt`, `formal/v2/atlas2.qnt`. If a claim quantifies over all protocols, all subsets or all pairs, **write a small Quint model of the predicate and run it** rather than reasoning informally: `quint typecheck`, `quint run --invariant=… --max-samples=100000`, `quint verify --invariant=…`. A Quint counterexample is the strongest finding you can return; an invariant surviving a large random exploration is evidence for a claim, not proof of it, and you must say which you have.
> Lean 4 with mathlib is **built** in `lean/` — `export PATH=/root/.elan/bin:$PATH`, then `lake build`. Read `lean/Defialgebra/` and `lean/Axioms.lean`. If you want to test whether a claim is provable, state it in Lean and try. A Lean theorem whose statement is weaker than the prose describing it is a real finding.
> Also available: `node` for the harnesses and the checker (`formal/v3/claims.mjs -v` is the paper's arithmetic restated as code), `python3`, `git`.

**They demand evidence.**

> No claim is entitled to the benefit of the doubt. For each assertion ask what you would have to see to believe it, and whether it is there. If it is not, the finding is **NOT SHOWN**, at a severity. A number without a reproducible computation is not a measurement; a measurement whose universe is not stated is not one either. Where the text says a protocol does something, the evidence is a citation with an access date; where it says the algebra does something, the evidence is a computation or a proof, and neither substitutes for the other. If you cannot decide a point without running something, **run it** — "appears to" and "presumably" are not audit findings. Quote the command and its output for anything you verified or refuted.

Per-construction body:

> You are auditing a construction claimed to reproduce a named DeFi application from a finite algebra of mechanisms. You have the paper, the checker, the spec and the verdict. Is any obligation stated so loosely that any construction would satisfy it? Is any element assignment a forced fit the residue should have caught? Does the verdict follow from the checker's own predicates? Is any claim in the proposed paper text stronger than the verdict supports? Rank findings by severity with file and line. Do not implement.

Two operational notes: `codex exec` blocks forever on stdin unless given
`< /dev/null`; and it streams every file it reads, so the raw log is not the
report — extract the final message (`awk '/^codex$/{n=NR} …'`). Tell auditors
explicitly which directories are out of scope, or they will read the tooling
and quote it back.

Write each to `review/COUNCIL-NN-slug.md`, and record what was actioned in
`review/ACTIONS.md` alongside the existing referee record.

---

## STAGE 6 — paper expansion (orchestrator)

Five `\subsection` per category `\section`, in the paper's voice: the
application, its obligations, the construction exhibited with the reason for
that witness among the alternatives (Corollary "there is no *the* construction"),
the verdict, and the residue. Then `./paper/build.sh` — it fails on undefined
references and on changelog phrasing, both of which are the gate.
