# Sprint10 independent planning review

Candidate: 2b1957b8be01c7435bd5b1928c20e92e6c598be6

Scope:4 capabilities,17 requirements,57 scenarios,34 unchecked tasks,20 fixture IDs including the F07 group companion,14 planned mutations,65 inherited controls. This is planning, not implemented Interface evidence. Both nonauthor GPT-6 and native Fable5.1 medium receive this identical bundle. Fable request claude-fable-5-1[1m], --effort medium; record actual returned model.

Review exact actual-receipt accounting, initialized noncircular local obligations, arbitrary-entry group induction, query precedence/types/global edge scope, independent funded oracles and executable mutation/control feasibility. No arbitrary shared-state commutation, deployed fidelity or inferred certificate claim. Classify concrete collaborator risks and exact fixes; reviewer advice is not proof.

All selected source/text files below are verbatim. JSON files preserve every key/value using compact serialization; original and rendered hashes are recorded independently. Large retained execution logs and full mechanical checks are reference-bound by dependency-review.json, not expanded in this planning prompt. External library sources are bound through the accepted toolchain/package manifest; they are not reproduced.


## FILE .claude/skills/defi-footguns/SKILL.md

Original SHA256: 5090b32ab6ff62df0a21d945bd85174eb0dfbb76639dda1e3489add8365470df; bytes: 8995; rendered SHA256: 5090b32ab6ff62df0a21d945bd85174eb0dfbb76639dda1e3489add8365470df

---
name: defi-footguns
description: Use when touching anything in this repo that verifies, checks, gates, or reports a result - paper/build.sh, formal/v3/*gate*, totalgate.mjs, negtest-*.sh, the sigma gates, or any script that compares a figure against paper/atlas.tex. Also use when a checker reports success, when adding an assertion, or when deciding how many review rounds a change needs.
---

# DeFi footguns

Traps that have actually fired in this repository, with the evidence. Every
entry below was measured, not predicted.

**Core principle: this repo's gates exist to stop a confident wrong answer.
Every trap here is a gate that produced one — usually about something it had
not measured.**

Read `formal/v3/GATE-REGISTER.md` alongside this: it records, per gate, whether
it has ever been *observed* failing. Two gates are marked `CANNOT FAIL` and are
still cited as verification commands in `AGENDA-COMPLETE.md`.

## Quick reference

| Symptom | Cause | Fix |
|---|---|---|
| `BUILD FAILED: a headline total disagrees with the verdicts`, but the PDFs rendered and the totals are right | `paper/build.sh` discarded the gate's stderr with `>/dev/null 2>&1` and mapped **every** nonzero exit onto one editorial sentence | Branch on the exit code: `0` holds, `1` the property is false, `3` the check could not run. Never merge those |
| A gate reports `PASS` / `ok` / `agree` after examining nothing | Empty glob, empty directory, zero-iteration loop. `verify_final.py` printed `X21-armed pairs: 0 of 0` and exited 0 on every tree but the author's | A zero denominator is a **blocked** check, exit 3. Print the denominator in the result line |
| Running the verification suite leaves the repo dirty | Gate scripts write their result JSON back into the tree, so *verifying* and *regenerating* are the same action and a gate can never disagree with its own record | Snapshot `git status --porcelain -uall` before and after. If a gate rewrites its evidence, diff it — reproducing bit-for-bit except a recorded absolute path is genuine |
| `quint typecheck` cited as verification | It checks types and effects. It never evaluates `init`, never steps, never reads an invariant. **0 of 92 `.qnt` files declare an `invariant`, `temporal` or `run`** — `quint test` is an empty suite everywhere | Name the property: `quint run <f> --invariant=inv_all`. Expect `usd1.qnt` to go red — it ships violating `inv_supply` |
| A gate shell reports `FAIL 61 of 72` about a corpus it never read | Unguarded `cd`, or a harness truncated with `head`/`tail` **before** being judged, discarding the EACCES that marks a blocked run | `cd "$(dirname "$0")/../.." \|\| exit 3`, plus a sentinel checking real content. Capture output in full; truncate only for display |
| A `cd` guard is present and the script still lies | `cd` into a directory that merely **exists** succeeds. Landing in `/tmp` is not a failure | Sentinel on content: `corpus50/lanes/*.json` present, `begin{measurement}` in `atlas.tex` |
| A count of blocked checks is off by one | `grep -c 'BLOCKED'` also matches the `GATE RESULT: BLOCKED` summary line | Anchor: `grep -cE '^  BLOCKED'`. This is the repo's own canonical example — `grep -q "violation"` matches Quint's success string `[ok] No violation found` |
| A figure "agrees" with the paper but the paper is wrong | `has()` was `tex.includes()` over a 151 KB document. Strip the approx markers and `strict` becomes `45.3`, satisfied by the **coverage** literal eleven lines above | Anchor each figure to the block *and* the sentence that asserts it, and require every site that states it to agree |
| An anchored claim search finds the wrong text | A `\label` sits wherever the author put it — near the top of a `measurement`, but inside the **caption** of a `table`, *below* the tabular body. Slicing forward from the label misses the numbers | Bound the block by `\begin{env}`…`\end{env}`, not by the label's position |
| A comment or an unused macro satisfies a claim | A LaTeX comment is never typeset; nor is an uninvoked `\newcommand` body, nor the untaken branch of a conditional | Strip comments (see parity below). For conditionals, **refuse rather than resolve** — see the wiki. There is no complete fix short of reading the typeset PDF |
| Comment stripping misses `\\%` | LaTeX comment semantics are backslash **parity**: `\%` is a literal percent, `\\%` is a line break followed by a **live** comment. A single-preceding-character test keeps the second | `replace(/(^\|[^\\])((?:\\\\)*)%.*$/gm, "$1$2")` — consume the pairs |
| A conditional check blocks a correct paper | `\iff` (the math operator) matches a naive `\\if[a-zA-Z]*` | Match the real primitives: `ifnum ifdim ifodd ifx iftrue iffalse ifcase ifdefined ifcsname else fi` |
| Every fix is defeated by the symmetric case one step away | Four consecutive rounds closed a pole and left its dual: whole-document → block-scoped missing a second site; comment stripped → wrong parity; `\iffalse` stripped → `\iftrue` untouched | When a fix is about *which* form, ask what the other polarity is **before** shipping. Better: make the check refuse ambiguity rather than resolve it |
| A "guard" passes on an arithmetically impossible input | The total row `total & --- & 1259 & 570 & 689 & 15` was checked by testing each number occurred *somewhere* in the table. Permuting to `1259 & 689 & 570 & 15` passed | Cells carry meaning by **position**. Read the row as a row |
| A count-based guard misses a partial corpus | Zero-file guards say nothing about four files of five, and "is an array" says nothing about `[]` | Count what you visited and refuse to compare an incomplete corpus. Better: make two independent sources check **each other** — `tot` from verdicts vs obligation items from specs; `cov` vs `assigned` |

## The assertion traps — the most expensive class here

Four distinct ways an assertion stayed green against reverted code, all observed
in this repo:

1. **It tests a copy.** The probe re-implemented `want()` / `blocked_out()` in a
   heredoc, so reverting the real hunk left it exercising a private copy that
   still had the fix. Lift the function from source with a **bounded** extractor.
2. **It greps source instead of running behaviour.** A check for
   `case "$brc" in` passed against a block that was dead code after an `exit`.
3. **A parent guard already returns the same code.** The per-verdict
   `Number.isFinite` check sat under an existing `tot === 0` guard, so the
   fixture returned 3 either way. Lock by the specific **message**.
4. **The fixture is degenerate.** A one-slug corpus can't exhibit a
   silent-skip: the `tot === 0` guard fires first. **Two slugs minimum** for
   anything about a partial walk.

**Every guard needs a positive control** proving it fires on a defeating input,
**and** a negative one proving it isn't always-on. A dot-terminated sentence
window shipped that failed the *intact* corpus — its control was the only reason
it didn't ship red.

## A bounded function lift

`awk '/^fn\(\) \{/,/^\}/'` runs on to the **next** function's closing brace when
the definition is one-lined, so `tail -1 == "}"` passes on swallowed script body
(measured: 40 lines, 5 of them body, lift returned 0). Require: non-empty, ends
`}`, contains exactly one `^name() {`, and no line matching `^(echo|one |want "|===== )`.

## How many review rounds

**State the threat model in the brief.** This repo ran 21 adversarial rounds.
Rounds 1–11 found real defects — the published lie in four places, a silent
PASS, gates that could not fail. Rounds 12–21 found manuscript mutations that
require an adversary with **write access to `atlas.tex`**, which is not the
threat: the real risk is a collaborator regenerating one figure and missing
another.

- Budget rounds up front. Extension is an explicit decision, not a default.
- Tell reviewers to rank by **realistic likelihood**, not constructibility.
- **You** decide what blocks shipping. A finding needing adversarial write
  access to the artifact under test is a note, not a blocker.
- Tripwire: N consecutive rounds touching the same files → stop and reassess.
  Here, ten consecutive commits touched the same two files.

## Common mistakes

- **Trusting a gate's summary line.** `all headline totals agree with the
  verdicts` was printed while two of the four cells in the row it named were
  never compared.
- **Believing a stated limitation.** A limitation is a claim like any other.
  `GATE-REGISTER.md` overstated its own bound twice and a reviewer caught it
  both times.
- **Reading only the last line.** `one()` judged on `tail -1`, discarding the
  evidence that marks a blocked run — in a file whose own header says every
  check greps the whole output.

## Adding entries

Append only footguns that actually fired, symptom first — that is what a future
reader searches for. Keep the quick-reference table the primary surface. Record
the measurement, not the intuition.

## END FILE

## FILE AGENTS.md

Original SHA256: 60c7989fce2d680d68ac18bb970a79de65380aef9a44e70aa7205180c2d15a34; bytes: 3171; rendered SHA256: 60c7989fce2d680d68ac18bb970a79de65380aef9a44e70aa7205180c2d15a34

# Working instructions

The user approved the semantic-kernel pivot on 2026-09-06. Read
`docs/superpowers/specs/2026-09-06-semantic-kernel-design.md` and
`docs/research/semantic-kernel-progress.md` before continuing work.

- The new migration supersedes the old publication-first runstate and the
  positive-program primitive-basis mandate. Historical documents remain
  evidence, not instructions to pursue a withdrawn objective.
- Use GPT-6 for implementation through the stock Codex harness. Have Grok and
  Fable independently check substantive results. Invoke their native CLIs
  directly from Codex. Do not use Foreman. Never substitute a GPT reviewer and
  label its response Grok or Fable.
- Record the exact reviewed revision, requested/reported model identity,
  result, findings, and fixes. An unavailable reviewer is an open review, not
  an approval. Review is advisory evidence, not a mathematical proof.
- Preserve existing proofs and negative results. Put new kernel work in a
  separate namespace. Do not change a historical theorem statement to make a
  new claim pass.
- Read `.claude/skills/defi-footguns/SKILL.md` and
  `formal/v3/GATE-REGISTER.md` when editing or reporting verification behavior.
  Empty checks are blocked. Keep proof, bounded execution, measurement and
  unchecked assumptions distinct, with exact input and tool identities.
- Lean is the mathematical authority. Any executable IR or Quint abstraction
  needs explicit correspondence. No `sorry`, custom axioms or `native_decide`
  in accepted kernel proofs.
- Preserve the original corpus and versioned source evidence. Do not silently
  relabel development examples as untouched holdouts.
- User authorization to execute this migration is already present. Resolve
  routine implementation details without repeatedly requesting approval.

## Reviewer change, 2026-09-07

The user explicitly replaced Fable with Opus for future external reviews. Use
native Grok plus native Claude Opus for substantive implementation/evidence
reviews, and nonauthor GPT-6 plus native Opus for new OpenSpec planning gates.
Request the native `opus` model alias and record the actual returned model.
Existing Fable reports and accepted historical plan bytes retain their original
identity. References to future Fable reviews in older plans are superseded by
this instruction; freeze updated reviewer bindings before new review execution.
GPT-6 implementation, stock Codex harness, and the no-Foreman rule remain in force.

## Latest reviewer change, 2026-09-07

The user subsequently instructed: "fable is back online use 5.1 medium effort".
This supersedes the earlier Opus selection for upcoming reviews. Use nonauthor
GPT-6 plus native Fable 5.1 for new planning gates, and native Grok plus Fable 5.1
for substantive implementation and evidence reviews. Invoke Claude with model
`claude-fable-5-1[1m]` and `--effort medium`, recording the actual returned model.
Preserve completed Opus and historical Fable reports with their original
identities; they are not relabelled as new Fable reviews. GPT-6 stock-harness
implementation, no Foreman, and existing execution authorization remain unchanged.

## END FILE

## FILE docs/superpowers/specs/2026-09-06-semantic-kernel-design.md

Original SHA256: 9549bec37f76a16b42c8d2ad2c4305fd5f9568ffb1413cd79e218a978f99613a; bytes: 6389; rendered SHA256: 9549bec37f76a16b42c8d2ad2c4305fd5f9568ffb1413cd79e218a978f99613a

# DeFi semantic kernel: approved migration design

Approved by Charles Hoskinson on 2026-09-06: save the assessed plan and begin
execution, using GPT-6 implementation and Grok/Fable review through the stock
GPT harness. Do not use Foreman. Base: local commit `8ae0bbf`, 22 commits ahead
of the observed GitHub main `25a13c6`. Preserve those local commits.

## Objective

Establish conditional preservation of financial properties under composition.
Separate the empirical ontology, verified financial libraries, typed open
transition semantics, and chain/runtime adapters. Environment assumptions cross
all layers. A primitive count is not the research objective.

The supplied proposal is preserved verbatim in
`../../research/2026-09-06-defi-source-plan.md`. Its external citation tokens and
two sandbox attachment links are unresolved source material, not verified
references. The assessment below refines that proposal and governs execution.

## Seven work packages

1. **Research mandate and claims.** Supersede both the positive-program roadmap
   and the August AFT roadmap. Update the README and working instructions.
   Preserve historical claims with explicit corrections: withdraw the Q/Sigma
   semantic split and four-primitive objective; distinguish syntactic
   independence from semantic minimality; correct Delta terminology and the
   unsupported inference from clause polarity to absence of a lattice. Audit
   the paper's claim sites before changing published theorem statements.
2. **Kernel specification.** Define typed identities, dimensioned quantities,
   exact arithmetic, transitions, guards/refusals, observations, footprints,
   capabilities, claims, and assumptions. Define operational composition modes
   separately. Lean is the mathematical authority. Executable IR and any Quint
   abstractions must have stated correspondence to it.
3. **Corpus normalization.** Preserve all historical rows. Introduce
   organization/product/version/deployment identities, source revisions,
   chain identity, faceted labels, graph relationships, ambiguity, and residue.
   Split bundled products and versions. Independent annotations and their
   adjudication rules are required. Recover or reconstruct the proposal's
   missing CSV and JSON Schema; recover its external references.
4. **Verification path.** Replace keyword certification with checks of typed
   semantics, footprints, authority, accounting, interfaces, library proof
   instantiation, assumptions, and source correspondence. Bind evidence to
   exact inputs and tool versions. Distinguish proved, bounded, measured,
   refuted, and unchecked obligations. Retain useful existing failure-reporting
   and fidelity infrastructure, including refused behavior.
5. **Metatheory.** Prove initialization and preservation for typing, asset
   accounting, authority and locality; then composition, claim lifecycle and
   conservative extension. Generalize Interface.lean and Nary.lean without
   broadening their historical claims. Assume-guarantee rules need causal or
   inductive premises and initialization, not circular implication alone.
   Frame predicates must depend only on the protected footprint.
6. **Financial libraries and fidelity.** Port exact arithmetic, concentrated
   liquidity, Curve iteration, ordered redemption, loss allocation, transient
   accounting, asynchronous messages, margin/funding, and conditional claims.
   Pin reference implementations and observations. Use differential execution,
   characteristic mutations, and selected concrete refinement proofs.
7. **Generalization and publication.** Freeze the kernel before evaluating
   untouched holdouts. Cases already used to design the kernel are development
   challenges, not untouched holdouts. Track new kernel concepts separately
   from new libraries, coverage, assumptions, and verification effort. Rewrite
   the paper around demonstrated results; adapt visualization after the schema
   settles. Moriarty, Compact, ZKIR and runtime proofs remain adapter work until
   verified interfaces exist.

## First executable increment

Build a deliberately scoped Lean pilot, not the complete future IR. Use one
generic transition representation for a transfer, a fixed-rate vault
deposit/withdrawal, and an oracle-dependent collateralized borrow. These are
reference examples, not assertions of ERC-20/ERC-4626/deployed credit fidelity.

The core records actor, state updates, asset-indexed effects, authority checks,
and declared environment input. Financial formulas and protocol guards live in
example definitions. Require successful and refused examples, generic
accounting/locality results, and negative cases that actually violate the
proposed checks. A proof of an implication must not be advertised as automatic
inference of its hypotheses. Ordinary Lean proof terms are the pilot evidence;
no serialized third-party certificate checker is claimed in this increment.

Pilot numeric domain is explicit exact mathematical arithmetic, with
nonnegative balances and guarded debits. Machine-width arithmetic and chain
rounding require later refinement. No market truth, generic solvency, liveness,
deployed-contract correspondence, or full composition theorem is claimed.

## Acceptance and execution

- Preserve source proposal and this design; save a milestone ledger.
- Build the existing Lean baseline before edits.
- Add the pilot in a fresh namespace and Lake target without altering old proofs.
- Check proofs with Lean, with no `sorry`, custom axioms, or `native_decide`.
- Include live positive/negative examples: unauthorized debit, insufficient
  funds, unbalanced effects, wrong-asset accounting, and rejected credit inputs.
- Independently review the exact candidate with Grok and Fable; record model,
  input identity, raw result, findings, and remediation. Use direct native CLI
  processes launched by Codex, not Foreman. Initial review plus one targeted
  re-review; additional review requires a concrete unresolved finding.
- Keep the remaining seven-package work visible. Completing this increment
  does not complete the full migration or its first three-example fidelity gate.

The first useful milestone is three executable models, checked initial
preservation proofs, and broken variants rejected by the appropriate check.
Calendar estimates are provisional; acceptance conditions govern progress.

## END FILE

## FILE formal/v3/GATE-REGISTER.md

Original SHA256: 3f25f57b1c051ae245adda4b05058c944dfc486cf25be09d4914ef087edc35b7; bytes: 20306; rendered SHA256: 3f25f57b1c051ae245adda4b05058c944dfc486cf25be09d4914ef087edc35b7

# Gate register

**See also:** `docs/wiki/` for why these rules exist, and
`.claude/skills/defi-footguns/SKILL.md` for the symptom-first version that fires
while you work.

Every gate, what it claims, and whether it has been *observed* failing on a
known-bad input. A checker never seen to fail is not evidence, and a row marked
`CANNOT FAIL` contributes none to any claim in the paper.

Verdicts:

| Verdict | Meaning |
|---|---|
| `DISCRIMINATES` | Made to fail on bad **content**, and to pass on good content. Both polarities observed. |
| `CANNOT FAIL` | No perturbation of input content produces a failure verdict. |
| `VACUOUS` | Passes over an empty corpus, or a conjunct that is constant by construction. |
| `BLOCKED` | Cannot run in this tree; no verdict either way. |

Exit-code contract: `0` property holds over a non-empty corpus · `1` property is
false · `3` check could not be performed. Exit 3 follows the pre-existing
`negtest-*.sh` convention (`PERTURBATION DID NOT APPLY`, `sys.exit(3)`).

## Registered gates

| Gate | Claims | Observed failure | Perturbation | Verdict |
|---|---|---|---|---|
| `formal/v3/totalgate.mjs` | Headline totals in `atlas.tex` equal the verdict sums; four stale round-2 values absent | Yes, both polarities | `$1{,}259$` → `$1{,}260$` in a fixture tex (exit 1); `chmod 000` expansion root (exit 3); empty root (exit 3) | `DISCRIMINATES` |
| `paper/build.sh` totals branch | Distinguishes a false total from a gate that could not run | Yes, both polarities | Fixture tex perturbation vs real `EACCES` | `DISCRIMINATES` |
| `formal/v3/gate.sh` | LOOP-2 integrity over build, harnesses, claims, graphs | Yes | Run from a directory that is not a defiformal tree — now exits 3 instead of printing `FAIL 61 of 72` | `DISCRIMINATES` |
| `research/positive-program/sigma/gate33_cert_check.py` | Keyword certificate over `gen-ir-v2ten`: every file has ≥1 tagged name; tags ⊆ {Led,Prop,Cmp,Post,OTHER} | Partial | Empty-of-names JSON → `FAIL: empty file`, exit 1. Empty IR → exit 3 (was `PASS 0 files`) | `DISCRIMINATES` emptiness only — the **tag-subset invariant CANNOT FAIL**: `tag_name` returns only members of `allowed` by construction, so `FAIL: bad tag` is unreachable |
| `research/positive-program/sigma/verify_final.py` | X21-armed pair counts over expansion specs | Yes | Empty corpus → exit 3. **Before this change the glob matched zero files on any tree but the author's and printed `X21-armed pairs (60-app basis): 0 of 0`, exit 0** — a live pass on an empty denominator. It now measures 60 specs | `DISCRIMINATES` |
| `research/positive-program/sigma/gate12_deletion_ir.py` | "IR deletion": how much of the IR surface disappears if a family is deleted | **No** — no failure path exists. Empty and missing IR both exit 0 and still write `MEASURED` | — | `CANNOT FAIL`. The residual counts are a rewrite of tag base rates (Post/Cmp = 3279/39 = 84.08×); nothing is actually deleted |
| `research/positive-program/sigma/gate11a_census_v1.py` | Independent-witness census; N3 printed `indep=0 shared=6` | **No** — no failure path; empty corpus still exits 0 and writes `MEASURED` | Classification does change on constructed input, but the script cannot report failure | `CANNOT FAIL`. N3 `indep=0` is `VACUOUS` — the local-def markers match zero definitions in the tree. The maple `SHARED` hit matches a **comment**, not a call |
| `formal/v3/claims.mjs` | 109 category claims recomputed from the corpus | **Yes, in-tree** | Control: `109 claims verified, 0 failed`. Drop one protocol from `corpus50/lanes`: `93 claims verified, 16 failed`, exit 1, naming `FAIL [intent] CoW 23, DFlow 1, rest 0` | `DISCRIMINATES` the corpus. **Still CANNOT FAIL on `atlas.tex` errors — it never opens the paper** |
| `formal/v3/selftest.mjs` | 22 self-tests of `construct.mjs`, incl. an inadmissible X2 fixture | **Yes, in-tree** | Control: `22 passed, 0 failed`. Same mutation: `FAIL corpus size: got 71 want 72`, `17 passed, 5 failed`, exit 1 | `DISCRIMINATES` its frozen goldens |
| `formal/v3/verify-measurements.mjs` | `meas:pairs` / `meas:whereitfails` numerals must appear | Not in-tree | Copy: `$147$`→`$148$` VIOLATED. **`Twenty of the`→`Nineteen of the` still VERIFIED** | `BLOCKED` in-tree; `CANNOT FAIL` on the duplicate word-form |
| `formal/v3/verify-graphs.py` | GRAPHS.md figures vs the merged/domain/lane graphs | **Yes, in-tree** | Control: `GRAPH CLAIMS VERIFIED`. 777→9999 in GRAPHS.md: `GRAPH CLAIMS VIOLATED`, exit 1 | `DISCRIMINATES` |
| `formal/v3/validate.mjs` | Rejects malformed construction specs | Yes, both polarities | Real spec dir → exit 0; empty dir → exit 3. Unblocked by the `formal/v2` root fix; the guard the previous change could only *record* is now demonstrated | `DISCRIMINATES` |
| `research/positive-program/basis/denominators.py` | Ten-protocol generation rate (`v2 119/716 = 16.6%`) | Yes | Missing IR → exit 1; `UNGEN_V1/V2` mismatch → exit 1 | `DISCRIMINATES` those two. **The 16.6% figure itself is not a threshold** — any rate prints and exits 0 |

| `formal/v3/evidence.mjs` | cited by loop2gate §4 as a citation check | **No** — it is the supplement *emitter*, not a checker: no `process.exit`, no `throw`, and its stderr always contains the string a needle would match | — | `CANNOT FAIL` |
| `formal/v3/cites.mjs` | cited by loop2gate §4 as a citation check | **No** — no failure path; prints `<-- invariant 5 violation` and still exits 0. Never emits the needle it was matched on | — | `CANNOT FAIL` |

## The gate path runs

`formal/v3/construct.mjs:59` and `formal/v3/verify-graphs.py:10` were the last
two hardcoded roots on the integrity-gate path. With those resolved from their
own file locations, `formal/v3/gate.sh` reports **PASS** — ten checks, none
blocked, exit 0 — for the first time in this clone, and `smoke.sh` reports
`SMOKE OK`.

Three gates recorded above as `BLOCKED` are now recorded as `DISCRIMINATES`,
each with a control proving it is not always-red. Note what that means and does
not: they discriminate the **corpus**. `claims.mjs` still never opens
`paper/atlas.tex`, so it cannot fail on a manuscript error.

About 170 files elsewhere still carry a dead `/root/...` root. None is on the
gate path.

## Rows that carry no evidence

`gate12_deletion_ir.py` and `gate11a_census_v1.py` are `CANNOT FAIL`. Both write
a document headed `MEASURED` regardless of input, including empty input. Neither
supports a claim, and `AGENDA-COMPLETE.md` lists both among its verification
commands. Gate 1.1a is cited as MEASURED for the basis census and gate 1.2 for
the deletion experiment; those citations rest on scripts with no failure path.

## Not addressed by this change

`totalgate.mjs`'s content checks remain unanchored `String.includes` tests over
the whole `.tex`, so a dummy file containing the four tokens also passes. It
computes `inad` (15) and `assigned` (570) and checks neither. The stale-value
blacklist is a frozen round-2 fossil rather than a derived invariant. Widening a
check and fixing how failure is reported are separate changes and were kept
apart deliberately; this is the candidate for the next one.

`formal/v2/tables.mjs`'s root is **fixed** — it now resolves from
`import.meta.url`, and the six `formal/v2` scripts that re-read `corpus50/lanes`
by absolute path use the exported `ROOT`. All three README reproduce commands
run and all seven published figures reproduce (61/72, 1830, 185, 29/72, 20/61,
15 arcs, 0 violations). `gate.sh` went from **ten blocked checks to three**, with
seven now `ok`.

An earlier revision of this file said "four". That count came from an unanchored
`grep -c 'BLOCKED'` which also matched the `GATE RESULT: BLOCKED` summary line —
the same defect this register exists to catch, committed by its own author. Both
independent reviewers caught it. Anchored: `grep -cE '^  BLOCKED'` = 3, `^  ok `
= 7, and 7 + 3 = 10 reconciles.

The three that remain do **not** share one cause:

| Blocked check | Actual blocker |
|---|---|
| 109-claim checker (`claims.mjs`) | `formal/v3/construct.mjs:59`, `loadCorpus(root = "/root/DefiElements")` |
| smoke (via `selftest.mjs`) | the same line |
| graph claims (`verify-graphs.py`) | its **own** `ROOT = "/root/defiformal/expansion"` — not `construct.mjs` |

Fifty-two `formal/v3` scripts also still import by absolute ESM specifier.

## Adversarial review of this register's own change

Two independent reviewers (grok-4.6 at xhigh, claude-fable-5) were given the
diff and told to attack it. Confirmed findings, all now fixed:

- **The exit contract stopped at `readdir`.** Every `readFileSync` / `JSON.parse`
  of a verdict or spec was unguarded, so an `EACCES` or malformed JSON one
  directory deeper threw, node exited 1, and `build.sh` reported a totals
  disagreement — the original defect, alive, one syscall further in. Now every
  read and parse in the corpus walk is a blocked-check candidate.
- **The callers never learned the contract.** `gate.sh` and `loop2gate.sh` grepped
  `build.sh`'s stdout for `OK`, so a blocked build read as a failure at the
  integration layer. Both now branch on the exit code.
- **`blocked_out` was over-broad** — a bare `Traceback` or the word `BLOCKED` in
  ordinary output would reclassify a genuine content failure as blocked, hiding a
  real defect behind a reassuring word. Patterns narrowed, and the ordering
  inverted so that a harness which produced the expected answer is never called
  blocked however noisy its stderr.
- **The repo sentinel was a name check.** Three empty files of the right name
  walked past it. It now requires `corpus50/lanes/*.json` and a `measurement`
  environment in `atlas.tex`.
- **The harness locked one `chmod` and the editorial sentence**, but never
  asserted exit 3 *through* `build.sh`, never exercised `tot === 0`, and
  truncated the orphan `gate.sh` case with `head -20`. All three now asserted.
- Counting and attribution errors, above.

`negtest-reporting.sh` went from 25 assertions to **43**, all passing. The five
new sections exist because a reviewer found the gap, not because the author
predicted it.

## Second adversarial review — what the first round of fixes still got wrong

Commit `6f9786b` claimed to close every finding of the first review. A second
pass by the same two reviewers found it had not, and found a false statement in
its own commit message. Recorded here rather than quietly amended, because a
register that hides its author's errors is worth nothing.

- **`6f9786b`'s message says "Both now branch on the exit code."** That was false.
  The entire change to `loop2gate.sh` was a `printf`; the verdict still came from
  `case "$b" in *"OK"*)` and it still exited 1 on a blocked build. Only `gate.sh`
  had been fixed. Both reviewers caught it independently and claude rated it the
  most severe finding — not because the code was worst, but because the
  accounting asserted something untrue.
- **The contract stopped at the parse, not the type.** A verdict, spec or
  obligation that is valid JSON `null` is not a parse failure, so `readJson`
  returned it and the next property access threw a `TypeError` — exit 1, and
  `build.sh` announced a totals disagreement without comparing a total.
- **An unreadable slug directory was silently skipped**, because `existsSync`
  returns false on `EACCES`. Its obligations vanished from the totals and the
  short total was then reported as a real disagreement.
- **The `blocked_out` ordering inversion reached `chk()` only.** The three inline
  sites — `claims`, `smoke`, `graph claims` — still tested the classifier first,
  and those are the only checks actually blocked today.
- Two fixes shipped with **no assertion behind them**, and the identical
  stale-root hazard sat note-free in `tables.mjs`, which feeds all seven figures.

A third defect was introduced while fixing the first: the new `loop2gate.sh`
result block was appended *after* the script's existing `exit`, so it was dead
code, and the assertion written to cover it was a source grep that passed anyway.
Replaced with a behavioural test.

`loop2gate.sh`'s other twenty checks had the same defect its build step did —
`brief-fresh.sh: cd: /root/defiformal: Permission denied` produced
`FAIL section briefs are stale`. Ten of them also truncated with `tail -1`
*before* judging, discarding the evidence of a blocked run, in a file whose own
header says every check greps the whole output. All now route through one
blocked-aware helper. `loop2gate.sh` reports **BLOCKED, fail=0** instead of ten
content verdicts about a corpus nothing read.

`negtest-reporting.sh`: 25 → 43 → **65** assertions.

## What this gate still cannot detect

Twelve rounds of adversarial review closed the skipped-walk class and the
needle-collision class. Both reviewers independently identified one that
remains, and it is recorded here rather than left implicit.

**Coordinated, sum-preserving corpus edits are invisible.** `totalgate.mjs`
aggregates without identity: it never joins a verdict record to the spec file
describing the same application, and never reads `app` or `category`. Two
consequences:

- **Correction.** An earlier version of this section said that deleting an app's
  verdict record and its spec file "is reported as agreement". That is false, and
  both reviewers caught it: the pair-delete is caught by `specFiles 59 != 60`,
  exit 3, and would be exit 1 even without the hardcoded constants. Recorded
  rather than silently amended, because a register that overstates a hole
  mis-sizes a reader's trust exactly as surely as one that hides it.
- What IS invisible is the **cardinality-preserving** variant: delete an app and
  duplicate another to keep the counts whole, or swap two applications with
  identical statistics. Those preserve every equality the gate checks and every
  count, and are reported as agreement with one application double-counted and
  another unmeasured.
- A coordinated edit that preserves the sums but changes what they describe is
  reported as `a headline total disagrees` — a corpus defect routed through the
  manuscript-is-wrong exit code, which is precisely the failure this branch
  exists to prevent, surviving in the one shape the cross-source check cannot
  see.

Closing it requires joining the two sources by application identity, which is a
larger change than this branch's contract and is not attempted here. Anyone
relying on this gate should know that its guarantee is *one-sided*: a short or
inconsistent walk is caught; a self-consistent but wrong corpus is not.

`EXPECT_CATEGORIES = 12` and `EXPECT_SPEC_FILES = 60` are hardcoded. A corpus
that legitimately grows will produce a false BLOCKED whose message asserts the
opposite ("the corpus is incomplete" on 13 categories). That is the safe
failure direction, but it is a maintenance obligation, not a check.

## Why the manuscript comparison cannot be finished this way

Seventeen rounds of adversarial review closed the corpus walk completely. The
manuscript comparison is not closed and, on the current design, cannot be.

Every headline figure is located by pattern-matching a number out of prose.
Rounds 13, 15 and 17 each found a claim site that hand enumeration had missed,
and round 17's fix was itself prompted by counting occurrences mechanically
rather than by reading. That count is the argument:

| figure | visible sites | lines |
|---|---:|---|
| obligations total 1259 | 3 | 217, 1297, 1536 |
| covered 570 | 2 | 1303, 1536 |
| residue 689 | 2 | 1536, 2334 |
| coverage 45.3% | 1 | 1297 |
| strict 29.0% | 2 | 1306, 1314 |
| **inadmissible 15** | **6** | 957, 1029, 1157, 1536, 1970, 2692 |

**Correction, one round later.** The paragraph below generalised from `inad`
to "the method cannot be finished", and a reviewer showed that is false.
`$205$`, `$36.0\%$` and `$16.3$` each occur exactly ONCE in visible text, so
the every-site rule applies to them cleanly; they were unregistered, not
unregisterable. Two of the three are now checked. This is the second time this
register has overstated a limitation, and both times a reviewer caught it --
recorded rather than amended, for the same reason as before.

What remains true is narrower: `inad` alone cannot be located by this method.
The last row is the one that shows why. The digits `15` occur six times and most
are unrelated counts, so the rule that fixed every other figure — *every site
stating this number must agree* — would fail on a correct paper. Pattern
matching cannot separate a claim about a quantity from an unrelated number that
happens to equal it, and no further enumeration changes that. The gate checks
`inad` at its table cell only, and that is the honest bound.

**The structural answer, not attempted here.** Emit the figures into the
manuscript from one source — `\newcommand{\obligationsTotal}{1259}` generated by
the gate, with the prose using the macro — so every figure has exactly one
definition site by construction and the comparison becomes an identity rather
than a search. That changes how the paper is authored and is the author's call,
not a gate change. It is the same recommendation the reviewer made in round 12.

Until then: a figure that drifts at a registered site is caught; one that drifts
at an unregistered site is not, and `inad` has five unregistered sites by
necessity.

## The real bound on the manuscript comparison

Twenty-one rounds. The corpus walk is closed. The manuscript comparison is not,
and this section states why with the evidence, replacing two earlier attempts
that were each wrong in a different direction.

**What was tried.** Rounds 12-21 located each headline figure by matching a
number out of the LaTeX source, and every round found a new way to make the
source say one thing and the typeset paper another: a whole-document search, a
second claim site, a comment, a comment behind the wrong backslash parity, an
`\iffalse` block, an `\iftrue \else` dual, and finally -- from both reviewers
independently -- a conditional WRAPPING the claim region and a conditional whose
`\else` sits outside the inspected window. Each fix was correct about the shape
in front of it. None generalised.

**Why it cannot generalise.** A conditional can be defeated by position as
easily as by form, and conditionals are not the only gap: a
`\newcommand{\x}{... $689$ ...}` that is never invoked carries the claim phrase
in text TeX never typesets, with no conditional token anywhere. Deciding what
TeX typesets requires running TeX. A source-text gate cannot bound it, and every
further round of this shape buys one more position rather than the class.

**Two remedies, both feasible, both the author's call.**

1. *Compare against the typeset output.* `paper/build.sh` already produces
   `atlas.pdf` before running the gate, and `pdftotext` is installed. Measured:
   `pdftotext -layout` preserves the total row as a row --
   `total  —  1259  570  689  15` -- so the cell-identity guarantee of round 18
   survives the move, and four of the five claim phrases appear verbatim in the
   typeset text. The fifth (`Pooling all`) does not, almost certainly line
   wrapping or hyphenation, which is the new failure class this approach would
   have to shake out. It closes conditionals of every form and position,
   uninvoked macro bodies, and comments at once, because it reads what the
   reader reads.

2. *Emit the figures from one source.* `\newcommand{\obligationsTotal}{1259}`
   generated by the gate, with the prose using the macro. Every figure then has
   exactly one definition site by construction, the comparison becomes an
   identity rather than a search, and the `inad` collision problem disappears
   because the gate never has to find `15` in prose again. This is the stronger
   remedy and the one a reviewer recommended in round 12.

**Until one is adopted**, the gate's "all headline totals agree with the
verdicts" means: *the figures agree at the claim sites the gate knows about, in
the LaTeX source, assuming those sites are macro- and conditional-transparent.*
That is a real and useful guarantee. It is not the same sentence as "the paper
the reader sees is consistent with the corpus", and the difference is this
section.

## END FILE

## FILE lean/DefiKernel/Atomic/Examples.lean

Original SHA256: 771ce6a4de4a24082bcc75c842ac2db3ac072cc63586cd24aecc86c72b097af4; bytes: 11971; rendered SHA256: 771ce6a4de4a24082bcc75c842ac2db3ac072cc63586cd24aecc86c72b097af4

import DefiKernel.Atomic.Policy
import DefiKernel.Parallel.Examples

/-! Independent exact-rational Atomic fixture data. Expected worlds, receipts and outputs never
select an Atomic or Interleaving execution result. These are development examples, not fidelity. -/
namespace DefiKernel.Atomic.Examples
open Typed Composition Parallel Typed.Examples
open Parallel.Examples (C W I B Evt Obs cells cellRef packed output event transferEvent observed)

abbrev P := Party
abbrev A := Asset
abbrev D := Domain

def usdVault : C := (.main, .vault, .usd)
def usdAlice : C := (.main, .alice, .usd)
def usdBob : C := (.main, .bob, .usd)
def shareVault : C := (.main, .vault, .share)
def shareAlice : C := (.main, .alice, .share)
def otherVault : C := (.other, .vault, .usd)
def otherAlice : C := (.other, .alice, .usd)
def collateral : C := (.main, .alice, .collateral)
def refAt (d : D) (a : A) (p : PartyRef P) : CellRef P A D a := ⟨d, p⟩
def packedAt (d : D) (a : A) (p : PartyRef P) : PackedCellRef P A D := ⟨a, refAt d a p⟩

def transferAt (d : D) (a : A) (sender recipient : PartyRef P) : Op where
  signature := [.amount a]
  domain := d
  partyArity := 0
  guard := nonnegative a (.arg .here)
  deltas := [⟨a, refAt d a sender, negate a (.arg .here)⟩,
    ⟨a, refAt d a recipient, .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedAt d a sender, packedAt d a recipient]

def drawTemplate := transferAt .main .usd (.literal .vault) .caller
def repayTemplate := transferAt .main .usd .caller (.literal .vault)
def drawShareTemplate := transferAt .main .share (.literal .vault) .caller
def repayShareTemplate := transferAt .main .share .caller (.literal .vault)
def drawOtherTemplate := transferAt .other .usd (.literal .vault) .caller
def repayOtherTemplate := transferAt .other .usd .caller (.literal .vault)
def noopTemplate : Op := { drawTemplate with deltas := [], writes := [] }
def repeatedTemplate : Op := { drawTemplate with
  deltas := [⟨.usd, refAt .main .usd (.literal .vault), negate .usd (.arg .here)⟩,
    ⟨.usd, refAt .main .usd (.literal .vault), negate .usd (.arg .here)⟩,
    ⟨.usd, refAt .main .usd .caller,
      .binary (.add (.amount Asset.usd)) (.arg .here) (.arg .here)⟩] }
def mintAt (a : A) : Op where
  signature := [.amount a]
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := [⟨a, refAt .main a .caller, .arg .here⟩]
  supplyDeltas := [⟨.main, a, .arg .here⟩]
  stateReads := []
  envReads := []
  writes := [packedAt .main a .caller]
def timedDrawTemplate : Op where
  signature := [.amount .usd, .scalar]
  domain := .main
  partyArity := 0
  guard := .binary (.eq .scalar) .now (.arg (.there .here))
  deltas := [⟨.usd, refAt .main .usd (.literal .vault), negate .usd (.arg .here)⟩,
    ⟨.usd, refAt .main .usd .caller, .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := [.currentTime]
  writes := [packedAt .main .usd (.literal .vault), packedAt .main .usd .caller]
def liveDrawTemplate : Op := { drawTemplate with
  deltas := [⟨.usd, cellRef usdVault,
    .binary (.scale (.amount Asset.usd)) (.lit (-1 / 2 : ℚ)) (.balance (cellRef usdVault))⟩,
    ⟨.usd, refAt .main .usd .caller,
      .binary (.scale (.amount Asset.usd)) (.lit (1 / 2 : ℚ)) (.balance (cellRef usdVault))⟩]
  stateReads := [packed usdVault] }

structure FixtureOp where
  id : Nat
  template : Op
  output : C

def operations : List FixtureOp := [
  ⟨100, drawTemplate, usdVault⟩, ⟨101, repayTemplate, usdVault⟩,
  ⟨102, drawShareTemplate, shareVault⟩, ⟨103, repayShareTemplate, shareVault⟩,
  ⟨104, drawOtherTemplate, otherVault⟩, ⟨105, repayOtherTemplate, otherVault⟩,
  ⟨106, noopTemplate, usdVault⟩, ⟨107, repeatedTemplate, usdVault⟩,
  ⟨108, mintAt .usd, usdAlice⟩, ⟨109, mintAt .share, shareAlice⟩,
  ⟨110, timedDrawTemplate, usdVault⟩, ⟨111, liveDrawTemplate, usdVault⟩]

def fixtureComponent (op : FixtureOp) : Component P A D :=
  ⟨⟨op.id⟩, [], [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨⟨999⟩, ⟨n⟩⟩, c, true⟩),
    [⟨⟨op.id⟩, op.template.signature.zipIdx.map (fun (u, n) ↦ ⟨⟨10 + n⟩, u⟩),
      [⟨⟨0⟩, op.output⟩]⟩]⟩
def atomCfg : Config P A D where
  registry id := (operations.find? (fun op ↦ id = ⟨op.id⟩)).map FixtureOp.template
  domainAdmin := domainAdmin
  catalog := operations.map fixtureComponent ++
    [⟨⟨999⟩, [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c, true⟩), [], []⟩]

/-- Exact grants for funded Alice/Bob controls. First entry authorizes Alice's USD draw. -/
def atomStore : Store := ⟨operations.flatMap fun op ↦
  [Party.alice, .bob].flatMap fun actor ↦
    ([Right.invoke, .debit (op.template.domain, .alice, op.output.2.2),
      .debit (op.template.domain, .bob, op.output.2.2),
      .debit (op.template.domain, .vault, op.output.2.2),
      .changeSupply op.template.domain op.output.2.2]).map fun right ↦
        ⟨⟨actor, op.template.domain, ⟨op.id⟩, right⟩, true⟩⟩
def atomCaps : List CapabilityId := (List.range 120).map CapabilityId.mk
def revokedStore : Store := ⟨atomStore.entries.set 0
  ⟨⟨.alice, .main, ⟨100⟩, .invoke⟩, false⟩⟩

/-- Complete tables retain protected collateral9 and set every unlisted cell to zero. -/
def balanceTable (alice bob vault ash vsh oa ov : ℚ) : C → ℚ := fun c ↦
  if c = usdAlice then alice else if c = usdBob then bob else if c = usdVault then vault
  else if c = shareAlice then ash else if c = shareVault then vsh
  else if c = otherAlice then oa else if c = otherVault then ov
  else if c = collateral then 9 else 0

def atomWorld (alice bob vault ash vsh oa ov : Nat) (store : Store := atomStore) : W :=
  ⟨⟨balanceTable alice bob vault ash vsh oa ov, by
    intro c
    simp only [balanceTable]
    repeat' split
    all_goals positivity⟩, store⟩
def atomInitial := atomWorld 1 7 10 8 10 8 10
def afterDraw := atomWorld 8 7 3 8 10 8 10
def afterUnder := atomWorld 2 7 9 8 10 8 10
def afterOver := atomWorld 0 7 11 8 10 8 10
def afterPeerReturn := atomWorld 8 0 10 8 10 8 10
def afterAssetReturn := atomWorld 8 7 3 1 17 8 10
def afterDomainReturn := atomWorld 8 7 3 8 10 1 17
def afterLastLane := atomWorld 1 7 10 9 9 8 10
def afterLastParticipant := atomWorld 1 14 3 8 10 8 10
def afterLaneMint := atomWorld 4 7 10 8 10 8 10
def afterNonlaneMint := atomWorld 1 7 10 11 10 8 10
def afterDrawNonlaneMint := atomWorld 8 7 3 11 10 8 10
def revokedInitial := atomWorld 1 7 10 8 10 8 10 revokedStore

def atomBoundary (_ : BranchId) (_ : Nat) : Boundary P A D :=
  ⟨⟨.alice, .main⟩, fresh, 100⟩
def peerBoundary (branch : BranchId) (_ : Nat) : Boundary P A D :=
  ⟨⟨if branch = .left then .alice else .bob, .main⟩, fresh, 100⟩
def otherBoundary (branch : BranchId) (_ : Nat) : Boundary P A D :=
  ⟨⟨.alice, if branch = .left then .main else .other⟩, fresh, 100⟩
def localBoundary (branch : BranchId) (index : Nat) : Boundary P A D :=
  ⟨⟨if branch = .right then .bob else .alice, .main⟩, fresh,
    (if branch = .left then 100 else 200) + index⟩

def invocation (op : Nat) (a : A) (q : ℚ) : I :=
  ⟨⟨op⟩, ⟨op⟩, [], [.literal ⟨.amount a, q⟩], atomCaps, none⟩
def draw (q : ℚ) := invocation 100 .usd q
def repay (q : ℚ) := invocation 101 .usd q
def drawShare (q : ℚ) := invocation 102 .share q
def repayShare (q : ℚ) := invocation 103 .share q
def drawOther (q : ℚ) := invocation 104 .usd q
def repayOther (q : ℚ) := invocation 105 .usd q
def noop := invocation 106 .usd 0
def repeatedDraw := invocation 107 .usd (7 / 2)
def mintUSD := invocation 108 .usd 3
def mintShare := invocation 109 .share 3
def timedDraw (q time : ℚ) : I :=
  ⟨⟨110⟩, ⟨110⟩, [], [.literal ⟨.amount .usd, q⟩, .literal ⟨.scalar, time⟩], atomCaps, none⟩
def liveDraw := invocation 111 .usd 0

def drawReturnLeft : B := [draw 7, repay 7]
def underLeft : B := [draw 7, repay 6]
def overLeft : B := [draw 7, repay 8]
def creditLeft : B := [draw 7, repay 8, draw 1]
def noOpLeft : B := [draw 7, noop]
def nonlaneLeft : B := [draw 7, mintShare, repay 7]

def expectedTransfer (index : Nat) (inv : I) (sender recipient : C) (q cash : ℚ) : Evt :=
  transferEvent index inv sender recipient q [output index inv.component.value sender.2.2 cash]
def drawEvent (index : Nat := 0) (actor : P := .alice) : Evt :=
  expectedTransfer index (draw 7) usdVault (.main, actor, .usd) 7 3
def repayEvent (index : Nat) (q cash : ℚ) (actor : P := .alice) : Evt :=
  expectedTransfer index (repay q) (.main, actor, .usd) usdVault q cash
def drawReturnEvents : List Evt := [drawEvent, repayEvent 1 7 10]
def underEvents : List Evt := [drawEvent, repayEvent 1 6 9]
def overEvents : List Evt := [drawEvent, repayEvent 1 8 11]
def creditEvents : List Evt := overEvents ++
  [expectedTransfer 2 (draw 1) usdVault usdAlice 1 10]
def peerReturnEvents : List Evt := [drawEvent, repayEvent 0 7 10 .bob]
def assetReturnEvents : List Evt := [drawEvent,
  expectedTransfer 0 (repayShare 7) shareAlice shareVault 7 17]
def domainReturnEvents : List Evt := [drawEvent,
  expectedTransfer 0 (repayOther 7) otherAlice otherVault 7 17]
def lastLaneEvents : List Evt := [expectedTransfer 0 (drawShare 1) shareVault shareAlice 1 9]
def lastParticipantEvents : List Evt := [drawEvent 0 .bob]
def noOpEvent : Evt := event 1 noop [⟨.amount .usd, 0⟩]
  ⟨true, [], [], [], [], [], [], []⟩ [output 1 106 .usd 3]
def repeatedEvent : Evt := event 0 repeatedDraw [⟨.amount .usd, 7 / 2⟩]
  ⟨true, [(usdVault, -7 / 2), (usdVault, -7 / 2), (usdAlice, 7)],
    [], [], [], [], [], [usdVault, usdAlice]⟩ [output 0 107 .usd 3]
def mintEvent (index : Nat) (inv : I) (cell : C) (amount post : ℚ) : Evt :=
  event index inv [⟨.amount cell.2.2, amount⟩]
    ⟨true, [(cell, amount)], [((cell.1, cell.2.2), amount)], [], [], [], [], [cell]⟩
    [output index inv.component.value cell.2.2 post]
def laneMintEvent := mintEvent 0 mintUSD usdAlice 3 4
def nonlaneMintEvent := mintEvent 1 mintShare shareAlice 3 11
def nonlaneEvents : List Evt := [drawEvent, nonlaneMintEvent, repayEvent 2 7 10]


def usdLane : Lane P A D := ⟨.main, .usd, .vault⟩
def shareLane : Lane P A D := ⟨.main, .share, .vault⟩
def otherLane : Lane P A D := ⟨.other, .usd, .vault⟩
def basePolicy : Policy P A D := ⟨[usdLane], [.alice]⟩
def multiLanePolicy : Policy P A D := ⟨[usdLane, shareLane], [.alice]⟩
def domainPolicy : Policy P A D := ⟨[usdLane, otherLane], [.alice]⟩
def multiParticipantPolicy : Policy P A D := ⟨[usdLane], [.alice, .bob]⟩
def batchPolicy : Policy P A D := ⟨[], [.alice, .bob]⟩
def duplicateLanePolicy : Policy P A D := ⟨[usdLane, ⟨.main, .usd, .pool⟩], [.alice]⟩
def duplicateParticipantPolicy : Policy P A D := ⟨[usdLane], [.alice, .bob, .alice]⟩

def drawResiduals : List (Residual P A D) := [⟨usdLane, .alice, 7⟩]
def underResiduals : List (Residual P A D) := [⟨usdLane, .alice, 1⟩]
def overResiduals : List (Residual P A D) := [⟨usdLane, .alice, -1⟩]
def peerResiduals : List (Residual P A D) := [⟨usdLane, .alice, 7⟩, ⟨usdLane, .bob, -7⟩]
def assetResiduals : List (Residual P A D) :=
  [⟨usdLane, .alice, 7⟩, ⟨shareLane, .alice, -7⟩]
def domainResiduals : List (Residual P A D) :=
  [⟨usdLane, .alice, 7⟩, ⟨otherLane, .alice, -7⟩]
def lastLaneResiduals : List (Residual P A D) := [⟨shareLane, .alice, 1⟩]
def lastParticipantResiduals : List (Residual P A D) := [⟨usdLane, .bob, 7⟩]

/-- A direct finite expected table, independent of production update and residual enumeration. -/
def expectedOutstanding (entries : List (Residual P A D)) : Outstanding P A D :=
  fun lane principal ↦ match entries.find? (fun entry ↦
      decide (entry.lane = lane ∧ entry.principal = principal)) with
    | some entry => entry.amount
    | none => 0

-- BEGIN PROOFS

end DefiKernel.Atomic.Examples

## END FILE

## FILE lean/DefiKernel/Atomic/Execution.lean

Original SHA256: c9cee888746a2795ae2ddae59d9ffb27ed73339ed5a7ca0737be922af6d96b55; bytes: 7650; rendered SHA256: c9cee888746a2795ae2ddae59d9ffb27ed73339ed5a7ca0737be922af6d96b55

import DefiKernel.Atomic.Policy
import DefiKernel.Interleaving.Execution

/-! A single atomic publication boundary around actual interleaving steps. Diagnostic
receipts describe speculation; only a committed result publishes them. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

inductive AdmissionFailure (P A D : Type) where
  | configuration
  | structural (branch : BranchId) (failure : Parallel.LocalFailure)
  | policy (failure : PolicyFailure P A D)
  | schedule (mismatch : ScheduleMismatch)
  deriving DecidableEq

inductive AbortReason (P A D : Type) where
  | kernel (branch : BranchId) (index position : Nat)
      (invocation : Invocation P A D) (reason : Composition.Failure)
  | laneSupply (branch : BranchId) (index position : Nat)
      (invocation : Invocation P A D) (lane : Lane P A D) (amount : ℚ)
  | unsettled (residual : List (Residual P A D))
  deriving DecidableEq

structure Machine (P A D : Type) where
  entryWorld : World P A D
  speculative : Interleaving.Machine P A D
  outstanding : Outstanding P A D
  position : Nat := 0
  abort : Option (AbortReason P A D) := none

inductive Result (P A D : Type) where
  | refused (label : Nat) (schedule : Schedule) (reason : AdmissionFailure P A D)
      (entry : World P A D)
  | aborted (label : Nat) (schedule : Schedule) (reason : AbortReason P A D)
      (machine : Machine P A D)
  | committed (label : Nat) (schedule : Schedule) (machine : Machine P A D)

structure InnerObservation (P A D : Type) where
  branch : BranchId
  index : Nat
  invocation : Invocation P A D
  receipt : Receipt P A D
  outputs : List (OutputObservation A)
  deriving DecidableEq

/-- One event is published even when the admitted atomic request contains no calls. -/
structure EventObservation (P A D : Type) where
  label : Nat
  schedule : Schedule
  inner : List (InnerObservation P A D)
  deriving DecidableEq

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def admit (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (schedule : Schedule) :
    Except (AdmissionFailure P A D) (Footprint P A D × Footprint P A D) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  let lf ← (analyzeBranch cfg (boundaries .left) left).mapError (.structural .left)
  let rf ← (analyzeBranch cfg (boundaries .right) right).mapError (.structural .right)
  let _ ← (checkPolicy policy boundaries left right).mapError .policy
  let _ ← (checkSchedule left.length right.length schedule).mapError .schedule
  return (lf, rf)

def start (initial : World P A D) : Machine P A D :=
  ⟨initial, Interleaving.start initial, zeroOutstanding, 0, none⟩

def observeAttempt (attempt : Attempt P A D) : Option (InnerObservation P A D) :=
  match attempt.outcome with
  | .error _ => none
  | .ok result => some ⟨attempt.branch, attempt.index, attempt.invocation,
      result.receipt, result.outputs⟩

def diagnosticEvent (label : Nat) (schedule : Schedule) (m : Machine P A D) :
    EventObservation P A D :=
  ⟨label, schedule, m.speculative.attempts.filterMap observeAttempt⟩

def Result.publicWorld : Result P A D → World P A D
  | .refused _ _ _ entry => entry
  | .aborted _ _ _ m => m.entryWorld
  | .committed _ _ m => m.speculative.world

/-- This production accessor is consumed by the public projection. -/
def committedHistory : Result P A D → List (EventObservation P A D)
  | .refused _ _ _ _ => []
  | .aborted _ _ _ _ => []
  | .committed label schedule m => [diagnosticEvent label schedule m]

variable [Fintype P] [Fintype A] [Fintype D]

/-- Supply is the actual committed receipt sum, never the tentative aborted sum. -/
def committedSupply : Result P A D → D → A → ℚ
  | .refused _ _ _ _ => fun _ _ => 0
  | .aborted _ _ _ _ => fun _ _ => 0
  | .committed _ _ m => m.speculative.supply

def advance (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId) : Machine P A D :=
  match m.abort with
  | some _ => m
  | none =>
    let next := Interleaving.advance cfg boundaries left right m.speculative branch
    let running := { m with speculative := next, position := m.position + 1 }
    match next.attempts[m.speculative.attempts.length]? with
    | none => running
    | some attempt =>
      match attempt.outcome with
      | .error reason =>
        { running with abort := some (.kernel attempt.branch attempt.index m.position
            attempt.invocation reason) }
      | .ok result =>
        let owed := updateOutstanding policy m.outstanding
          (boundaries attempt.branch attempt.index).ctx.principal result.receipt
        let accepted := { running with outstanding := owed }
        match checkSupply policy result.receipt with
        | none => accepted
        | some (lane, amount) =>
          { accepted with abort := some (.laneSupply attempt.branch attempt.index m.position
              attempt.invocation lane amount) }

def continueRun (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (schedule : Schedule) : Machine P A D :=
  schedule.foldl (advance cfg boundaries policy left right) m

def runPrefix (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (initial : World P A D) (left right : Branch P A D)
    (schedule : Schedule) : Machine P A D :=
  continueRun cfg boundaries policy left right (start initial) schedule

def finish (label : Nat) (schedule : Schedule) (policy : Policy P A D)
    (m : Machine P A D) : Result P A D :=
  match m.abort with
  | some reason => .aborted label schedule reason m
  | none =>
    match residuals policy m.outstanding with
    | [] => .committed label schedule m
    | remaining => .aborted label schedule (.unsettled remaining) m

def runAtomic (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (label : Nat) (policy : Policy P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) : Result P A D :=
  match Atomic.admit cfg boundaries policy left right schedule with
  | .error reason => .refused label schedule reason initial
  | .ok _ => finish label schedule policy
      (runPrefix cfg boundaries policy initial left right schedule)

-- BEGIN PROOFS

theorem advance_aborted (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId) (reason : AbortReason P A D) (h : m.abort = some reason) :
    advance cfg boundaries policy left right m branch = m := by
  simp [advance, h]

theorem continueRun_append (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (s t : Schedule) :
    continueRun cfg boundaries policy left right m (s ++ t) =
      continueRun cfg boundaries policy left right
        (continueRun cfg boundaries policy left right m s) t := List.foldl_append

theorem continueRun_aborted (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (s : Schedule) (reason : AbortReason P A D) (h : m.abort = some reason) :
    continueRun cfg boundaries policy left right m s = m := by
  induction s with
  | nil => rfl
  | cons b s ih => simpa only [continueRun, List.foldl_cons,
      advance_aborted cfg boundaries policy left right m b reason h] using ih

end DefiKernel.Atomic

## END FILE

## FILE lean/DefiKernel/Atomic/Observation.lean

Original SHA256: 3e0ab8f53d0bcddc86543207cce4ae832293836e9a301204b090b23d6ccd0cc5; bytes: 4428; rendered SHA256: 3e0ab8f53d0bcddc86543207cce4ae832293836e9a301204b090b23d6ccd0cc5

import DefiKernel.Atomic.Execution

/-! Public equality retains the atomic event label, schedule, exact refusal, full
world and every committed receipt/output/supply field. Diagnostics are separate. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

inductive Outcome (P A D : Type) where
  | refused (reason : AdmissionFailure P A D)
  | aborted (reason : AbortReason P A D)
  | committed
  deriving DecidableEq

structure Observation (P A D : Type) where
  label : Nat
  schedule : Schedule
  outcome : Outcome P A D
  world : World P A D
  events : List (EventObservation P A D)
  supply : D → A → ℚ

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def observe (result : Result P A D) : Observation P A D :=
  let (label, schedule, outcome) := match result with
    | .refused label schedule reason _ => (label, schedule, Outcome.refused reason)
    | .aborted label schedule reason _ => (label, schedule, Outcome.aborted reason)
    | .committed label schedule _ => (label, schedule, Outcome.committed)
  ⟨label, schedule, outcome, result.publicWorld,
    committedHistory result, committedSupply result⟩

def Observation.Equivalent (left right : Observation P A D) : Prop :=
  left.label = right.label ∧ left.schedule = right.schedule ∧
    left.outcome = right.outcome ∧ WorldEquivalent left.world right.world ∧
    left.events = right.events ∧ ∀ d a, left.supply d a = right.supply d a

def observationEq (left right : Observation P A D) : Bool :=
  decide (left.label = right.label) && decide (left.schedule = right.schedule) &&
    decide (left.outcome = right.outcome) && worldEq left.world right.world &&
    decide (left.events = right.events) && decide (∀ d a, left.supply d a = right.supply d a)

def observationsEqual (left right : Result P A D) : Bool :=
  observationEq (observe left) (observe right)

-- BEGIN PROOFS

theorem observationEq_iff (left right : Observation P A D) :
    observationEq left right = true ↔ left.Equivalent right := by
  simp [observationEq, Observation.Equivalent, worldEq, WorldEquivalent, and_assoc]

theorem observationsEqual_iff (left right : Result P A D) :
    observationsEqual left right = true ↔ (observe left).Equivalent (observe right) :=
  observationEq_iff _ _

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_aborted_world (label : Nat) (schedule : Schedule)
    (reason : AbortReason P A D) (m : Machine P A D) :
    (observe (.aborted label schedule reason m)).world = m.entryWorld := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_aborted_history (label : Nat) (schedule : Schedule)
    (reason : AbortReason P A D) (m : Machine P A D) :
    (observe (.aborted label schedule reason m)).events = [] := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_aborted_supply (label : Nat) (schedule : Schedule)
    (reason : AbortReason P A D) (m : Machine P A D) (d : D) (a : A) :
    (observe (.aborted label schedule reason m)).supply d a = 0 := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_refused_world (label : Nat) (schedule : Schedule)
    (reason : AdmissionFailure P A D) (entry : World P A D) :
    (observe (.refused label schedule reason entry)).world = entry := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_refused_history (label : Nat) (schedule : Schedule)
    (reason : AdmissionFailure P A D) (entry : World P A D) :
    (observe (.refused label schedule reason entry)).events = [] := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_refused_supply (label : Nat) (schedule : Schedule)
    (reason : AdmissionFailure P A D) (entry : World P A D) (d : D) (a : A) :
    (observe (.refused label schedule reason entry)).supply d a = 0 := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_commit_one_event (label : Nat) (schedule : Schedule) (m : Machine P A D) :
    (observe (.committed label schedule m)).events = [diagnosticEvent label schedule m] := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_commit_world (label : Nat) (schedule : Schedule) (m : Machine P A D) :
    (observe (.committed label schedule m)).world = m.speculative.world := rfl

end DefiKernel.Atomic

## END FILE

## FILE lean/DefiKernel/Atomic/Policy.lean

Original SHA256: 5b643cbb1b1263ffacb20892afe3f9ec1067191e733f08c3f4040bbe17fa2612; bytes: 3951; rendered SHA256: 5b643cbb1b1263ffacb20892afe3f9ec1067191e733f08c3f4040bbe17fa2612

import DefiKernel.Interleaving.Execution

/-! Typed clearing policy and receipt-derived signed obligations. Lane uniqueness uses the
entire domain/asset key, so changing the vault does not remove an ambiguity. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

structure Lane (P A D : Type) where
  domain : D
  asset : A
  vault : P
  deriving DecidableEq, Repr

def Lane.cell {P A D : Type} (lane : Lane P A D) : Cell P A D :=
  (lane.domain, lane.vault, lane.asset)

structure Policy (P A D : Type) where
  lanes : List (Lane P A D)
  participants : List P

abbrev Outstanding (P A D : Type) := Lane P A D → P → ℚ

structure Residual (P A D : Type) where
  lane : Lane P A D
  principal : P
  amount : ℚ
  deriving DecidableEq, Repr

inductive PolicyFailure (P A D : Type) where
  | duplicateLane (firstIndex secondIndex : Nat) (first second : Lane P A D)
  | duplicateParticipant (firstIndex secondIndex : Nat) (principal : P)
  | uncoveredParticipant (branch : BranchId) (index : Nat) (principal : P)
  deriving DecidableEq, Repr

/-- Search in first-index then second-index order, retaining both original values. -/
def firstDuplicate {X K : Type} [DecidableEq K] (key : X → K) (index : Nat) :
    List X → Option (Nat × Nat × X × X)
  | [] => none
  | x :: xs =>
    match (xs.zipIdx (index + 1)).find? (fun item ↦ key x == key item.1) with
    | some (y, j) => some (index, j, x, y)
    | none => firstDuplicate key (index + 1) xs

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

/-- Coverage visits every static invocation, including suffixes that might never execute. -/
def uncoveredFrom (participants : List P) (branch : BranchId)
    (boundary : Nat → Boundary P A D) (index : Nat) :
    Branch P A D → Option (PolicyFailure P A D)
  | [] => none
  | _ :: xs =>
    if (boundary index).ctx.principal ∈ participants then
      uncoveredFrom participants branch boundary (index + 1) xs
    else some (.uncoveredParticipant branch index (boundary index).ctx.principal)

def checkPolicy (policy : Policy P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) : Except (PolicyFailure P A D) (PUnit : Type) := do
  match firstDuplicate (fun lane ↦ (lane.domain, lane.asset)) 0 policy.lanes with
  | some (i, j, first, second) => throw (.duplicateLane i j first second)
  | none => pure ()
  match firstDuplicate id 0 policy.participants with
  | some (i, j, principal, _) => throw (.duplicateParticipant i j principal)
  | none => pure ()
  match uncoveredFrom policy.participants .left (boundaries .left) 0 left with
  | some failure => throw failure
  | none => pure ()
  match uncoveredFrom policy.participants .right (boundaries .right) 0 right with
  | some failure => throw failure
  | none => pure ()
  return ⟨⟩

def receiptEffect (receipt : Receipt P A D) (cell : Cell P A D) : ℚ :=
  match receipt with
  | .invoked _ e => e.effect cell
  | _ => 0

def zeroOutstanding : Outstanding P A D := fun _ _ ↦ 0

def updateOutstanding (policy : Policy P A D) (owed : Outstanding P A D)
    (principal : P) (receipt : Receipt P A D) : Outstanding P A D :=
  fun lane p ↦ if lane ∈ policy.lanes ∧ p = principal then
    owed lane p - receiptEffect receipt lane.cell else owed lane p

/-- Canonical lane-major, participant-minor enumeration of every nonzero table entry. -/
def residuals (policy : Policy P A D) (owed : Outstanding P A D) : List (Residual P A D) :=
  policy.lanes.flatMap fun lane ↦ policy.participants.filterMap fun principal ↦
    if owed lane principal = 0 then none else some ⟨lane, principal, owed lane principal⟩

def checkSupply (policy : Policy P A D) (receipt : Receipt P A D) : Option (Lane P A D × ℚ) :=
  (policy.lanes.find? (fun lane ↦ receipt.supply lane.domain lane.asset != 0)).map
    (fun lane ↦ (lane, receipt.supply lane.domain lane.asset))

-- BEGIN PROOFS

end DefiKernel.Atomic

## END FILE

## FILE lean/DefiKernel/Atomic/PolicyProofs.lean

Original SHA256: 9eb5f5fe51692a44860fc27abb2ac2e7196ceb63ba61bb9a416af2cede544ab6; bytes: 12488; rendered SHA256: 9eb5f5fe51692a44860fc27abb2ac2e7196ceb63ba61bb9a416af2cede544ab6

import DefiKernel.Atomic.Policy
import Mathlib.Data.List.Nodup

/-! Policy admission is equivalent to complete typed uniqueness and static coverage.
Residual observations enumerate exactly the configured nonzero keys. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

-- BEGIN PROOFS

private theorem find_key_none {X K : Type} [DecidableEq K] (key : X → K)
    (x : X) (xs : List X) (index : Nat) :
    (xs.zipIdx index).find? (fun item ↦ key x == key item.1) = none ↔
      key x ∉ xs.map key := by
  rw [List.find?_eq_none]
  constructor
  · intro h hm
    rcases List.mem_map.mp hm with ⟨y, hy, heq⟩
    have hm' : y ∈ (xs.zipIdx index).map Prod.fst := by
      simpa only [List.zipIdx_map_fst] using hy
    rcases List.mem_map.mp hm' with ⟨pair, hp, hpy⟩
    have := h pair hp
    simp [hpy, heq] at this
  · intro h pair hp heq
    apply h
    exact List.mem_map.mpr ⟨pair.1, List.fst_mem_of_mem_zipIdx hp,
      (beq_iff_eq.mp heq).symm⟩

theorem firstDuplicate_none_iff {X K : Type} [DecidableEq K] (key : X → K)
    (index : Nat) (xs : List X) :
    firstDuplicate key index xs = none ↔ (xs.map key).Nodup := by
  induction xs generalizing index with
  | nil => simp [firstDuplicate]
  | cons x xs ih =>
    rw [firstDuplicate]
    cases h : (xs.zipIdx (index + 1)).find? (fun item ↦ key x == key item.1) with
    | none =>
      have hn := (find_key_none key x xs (index + 1)).mp h
      simp [ih, hn]
    | some pair =>
      have hn : ¬ key x ∉ xs.map key := by
        intro hx
        have := (find_key_none key x xs (index + 1)).mpr hx
        rw [h] at this
        contradiction
      simp only [Option.some_ne_none, List.map_cons, List.nodup_cons, false_iff]
      exact fun hnodup ↦ hn hnodup.1

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

omit [DecidableEq A] [DecidableEq D] in
theorem uncoveredFrom_none_iff (participants : List P) (b : BranchId)
    (boundary : Nat → Boundary P A D) (index : Nat) (xs : Branch P A D) :
    uncoveredFrom participants b boundary index xs = none ↔
      ∀ j, j < xs.length → (boundary (index + j)).ctx.principal ∈ participants := by
  induction xs generalizing index with
  | nil => simp [uncoveredFrom]
  | cons x xs ih =>
    simp only [uncoveredFrom]
    by_cases h : (boundary index).ctx.principal ∈ participants
    · simp only [h, ↓reduceIte, ih]
      constructor
      · intro hall j hj
        cases j with
        | zero => simpa using h
        | succ j =>
          have := hall j (by simpa using hj)
          simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using this
      · intro hall j hj
        have := hall (j + 1) (by simpa using Nat.succ_lt_succ hj)
        simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using this
    · simp only [h, ↓reduceIte, Option.some_ne_none, false_iff]
      intro hall
      exact h (by simpa using hall 0 (by simp))

/-- All four policy phases characterize acceptance, including unreachable static suffixes. -/
theorem checkPolicy_ok_iff (policy : Policy P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) :
    checkPolicy policy boundaries left right = .ok ⟨⟩ ↔
      (policy.lanes.map (fun lane ↦ (lane.domain, lane.asset))).Nodup ∧
      policy.participants.Nodup ∧
      (∀ i, i < left.length → (boundaries .left i).ctx.principal ∈ policy.participants) ∧
      (∀ i, i < right.length → (boundaries .right i).ctx.principal ∈ policy.participants) := by
  have hl := firstDuplicate_none_iff (fun lane : Lane P A D ↦
    (lane.domain, lane.asset)) 0 policy.lanes
  have hp := firstDuplicate_none_iff id 0 policy.participants
  have hleft := uncoveredFrom_none_iff policy.participants .left (boundaries .left) 0 left
  have hright := uncoveredFrom_none_iff policy.participants .right (boundaries .right) 0 right
  simp only [List.map_id, Nat.zero_add] at hp hleft hright
  rw [← hl, ← hp, ← hleft, ← hright]
  unfold checkPolicy
  cases firstDuplicate (fun lane ↦ (lane.domain, lane.asset)) 0 policy.lanes <;>
    cases firstDuplicate id 0 policy.participants <;>
    cases uncoveredFrom policy.participants .left (boundaries .left) 0 left <;>
    cases uncoveredFrom policy.participants .right (boundaries .right) 0 right <;>
    simp [pure, Except.pure, bind, Except.bind, throw]

theorem checkPolicy_participants_nodup (policy : Policy P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (h : checkPolicy policy boundaries left right = .ok ⟨⟩) :
    policy.participants.Nodup := (checkPolicy_ok_iff policy boundaries left right).mp h |>.2.1

theorem checkPolicy_covers (policy : Policy P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (h : checkPolicy policy boundaries left right = .ok ⟨⟩)
    (b : BranchId) (i : Nat) (hi : i < (Interleaving.selectBranch left right b).length) :
    (boundaries b i).ctx.principal ∈ policy.participants := by
  have hc := (checkPolicy_ok_iff policy boundaries left right).mp h
  cases b with
  | left => exact hc.2.2.1 i hi
  | right => exact hc.2.2.2 i hi

@[simp] theorem receiptEffect_invoked (request : Request P A D) (e : Evaluated P A D)
    (cell : Cell P A D) : receiptEffect (.invoked request e) cell = e.effect cell := rfl

@[simp] theorem receiptEffect_issued (id : CapabilityId) (cell : Cell P A D) :
    receiptEffect (.issued id) cell = 0 := rfl

@[simp] theorem receiptEffect_revoked (id : CapabilityId) (cell : Cell P A D) :
    receiptEffect (.revoked id) cell = 0 := rfl

theorem updateOutstanding_own (policy : Policy P A D) (owed : Outstanding P A D)
    (principal : P) (receipt : Receipt P A D) (lane : Lane P A D)
    (hlane : lane ∈ policy.lanes) :
    updateOutstanding policy owed principal receipt lane principal =
      owed lane principal - receiptEffect receipt lane.cell := by
  simp [updateOutstanding, hlane]

theorem updateOutstanding_other (policy : Policy P A D) (owed : Outstanding P A D)
    (principal p : P) (receipt : Receipt P A D) (lane : Lane P A D) (hp : p ≠ principal) :
    updateOutstanding policy owed principal receipt lane p = owed lane p := by
  simp [updateOutstanding, hp]

theorem updateOutstanding_unconfigured (policy : Policy P A D) (owed : Outstanding P A D)
    (principal p : P) (receipt : Receipt P A D) (lane : Lane P A D)
    (hlane : lane ∉ policy.lanes) :
    updateOutstanding policy owed principal receipt lane p = owed lane p := by
  simp [updateOutstanding, hlane]

theorem updateOutstanding_zero_effect (policy : Policy P A D) (owed : Outstanding P A D)
    (principal p : P) (receipt : Receipt P A D) (lane : Lane P A D)
    (hzero : receiptEffect receipt lane.cell = 0) :
    updateOutstanding policy owed principal receipt lane p = owed lane p := by
  simp [updateOutstanding, hzero]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
/-- Exact residual membership includes all three key qualifications and the signed value. -/
theorem mem_residuals_iff (policy : Policy P A D) (owed : Outstanding P A D)
    (r : Residual P A D) :
    r ∈ residuals policy owed ↔ r.lane ∈ policy.lanes ∧
      r.principal ∈ policy.participants ∧ r.amount = owed r.lane r.principal ∧ r.amount ≠ 0 := by
  rcases r with ⟨lane, principal, amount⟩
  simp only [residuals, List.mem_flatMap, List.mem_filterMap]
  constructor
  · rintro ⟨l, hl, p, hp, heq⟩
    split at heq
    · contradiction
    · cases Option.some.inj heq
      exact ⟨hl, hp, rfl, by assumption⟩
  · rintro ⟨hl, hp, heq, hne⟩
    refine ⟨lane, hl, principal, hp, ?_⟩
    simp [← heq, hne]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
/-- Clearance is pointwise over the entire configured rectangle, not a global net sum. -/
theorem residuals_eq_nil_iff (policy : Policy P A D) (owed : Outstanding P A D) :
    residuals policy owed = [] ↔
      ∀ lane ∈ policy.lanes, ∀ p ∈ policy.participants, owed lane p = 0 := by
  constructor
  · intro h lane hl p hp
    by_contra hn
    have hm := (mem_residuals_iff policy owed ⟨lane, p, owed lane p⟩).mpr
      ⟨hl, hp, rfl, hn⟩
    simp [h] at hm
  · intro h
    apply List.eq_nil_iff_forall_not_mem.mpr
    intro r hr
    have hm := (mem_residuals_iff policy owed r).mp hr
    exact hm.2.2.2 (hm.2.2.1.trans (h r.lane hm.1 r.principal hm.2.1))

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
@[simp] theorem residuals_zero (policy : Policy P A D) :
    residuals policy zeroOutstanding = [] := by
  apply (residuals_eq_nil_iff policy zeroOutstanding).mpr
  intros
  rfl

omit [DecidableEq P] in
theorem checkSupply_none_iff (policy : Policy P A D) (receipt : Receipt P A D) :
    checkSupply policy receipt = none ↔
      ∀ lane ∈ policy.lanes, receipt.supply lane.domain lane.asset = 0 := by
  simp [checkSupply]

theorem checkPolicy_lanes_nodup (policy : Policy P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (h : checkPolicy policy boundaries left right = .ok ⟨⟩) : policy.lanes.Nodup :=
  List.Nodup.of_map _ ((checkPolicy_ok_iff policy boundaries left right).mp h).1

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem residuals_eq_filterMap_product (policy : Policy P A D) (owed : Outstanding P A D) :
    residuals policy owed = (policy.lanes.product policy.participants).filterMap
      (fun key ↦ if owed key.1 key.2 = 0 then none
        else some ⟨key.1, key.2, owed key.1 key.2⟩) := by
  simp [residuals, List.product, List.filterMap_flatMap, List.filterMap_map]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem residuals_keys (policy : Policy P A D) (owed : Outstanding P A D) :
    (residuals policy owed).map (fun r ↦ (r.lane, r.principal)) =
      (policy.lanes.product policy.participants).filter (fun key ↦ owed key.1 key.2 != 0) := by
  rw [residuals_eq_filterMap_product, List.map_filterMap]
  simp only [← List.filterMap_eq_filter]
  congr 1
  funext key
  by_cases h : owed key.1 key.2 = 0 <;> simp [h, Option.guard]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
/-- Every nonzero lane/principal key appears exactly once under admitted uniqueness. -/
theorem residuals_keys_nodup (policy : Policy P A D) (owed : Outstanding P A D)
    (hl : policy.lanes.Nodup) (hp : policy.participants.Nodup) :
    ((residuals policy owed).map (fun r ↦ (r.lane, r.principal))).Nodup := by
  rw [residuals_keys]
  exact (hl.product hp).filter _

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem residuals_nodup (policy : Policy P A D) (owed : Outstanding P A D)
    (hl : policy.lanes.Nodup) (hp : policy.participants.Nodup) :
    (residuals policy owed).Nodup :=
  List.Nodup.of_map _ (residuals_keys_nodup policy owed hl hp)

private theorem sum_sub_at (participants : List P) (principal : P) (f : P → ℚ) (delta : ℚ)
    (hn : participants.Nodup) (hm : principal ∈ participants) :
    (participants.map (fun p ↦ if p = principal then f p - delta else f p)).sum =
      (participants.map f).sum - delta := by
  induction participants with
  | nil => simp at hm
  | cons p ps ih =>
    rcases List.nodup_cons.mp hn with ⟨hnot, htail⟩
    by_cases heq : p = principal
    · subst p
      have hmap : ps.map (fun p ↦ if p = principal then f p - delta else f p) = ps.map f := by
        apply List.map_congr_left
        intro q hq
        have hne : q ≠ principal := by intro h; subst q; exact hnot hq
        simp [hne]
      simp [hmap, sub_add_eq_add_sub]
    · have hmem : principal ∈ ps := (List.mem_cons.mp hm).resolve_left (Ne.symm heq)
      simp only [List.map_cons, List.sum_cons, heq, ↓reduceIte, ih htail hmem]
      exact (add_sub_assoc _ _ _).symm

/-- Complete duplicate-free participant sums decrease by precisely the lane receipt effect. -/
theorem updateOutstanding_sum (policy : Policy P A D) (owed : Outstanding P A D)
    (principal : P) (receipt : Receipt P A D) (lane : Lane P A D)
    (hlane : lane ∈ policy.lanes) (hn : policy.participants.Nodup)
    (hm : principal ∈ policy.participants) :
    (policy.participants.map (updateOutstanding policy owed principal receipt lane)).sum =
      (policy.participants.map (owed lane)).sum - receiptEffect receipt lane.cell := by
  unfold updateOutstanding
  simpa only [hlane, true_and] using
    sum_sub_at policy.participants principal (owed lane) (receiptEffect receipt lane.cell) hn hm

end DefiKernel.Atomic

## END FILE

## FILE lean/DefiKernel/Atomic/Settlement.lean

Original SHA256: c27cf9eebfce49357e14c963ab2c0ec4a920b3e26d700f85ad8d51cbb6315ca5; bytes: 10199; rendered SHA256: c27cf9eebfce49357e14c963ab2c0ec4a920b3e26d700f85ad8d51cbb6315ca5

import DefiKernel.Atomic.PolicyProofs
import DefiKernel.Atomic.Soundness
import DefiKernel.Interleaving.LocalOrder

/-! Receipt-derived obligations are an independent fold of actual attempts. Every reachable
prefix conserves each lane's cash plus the complete signed participant sum, including the
successful step that triggers a lane-supply abort. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def attemptOutstanding (policy : Policy P A D) (boundaries : ParallelBoundary P A D)
    (owed : Outstanding P A D) (attempt : Attempt P A D) : Outstanding P A D :=
  match attempt.outcome with
  | .error _ => owed
  | .ok result => updateOutstanding policy owed
      (boundaries attempt.branch attempt.index).ctx.principal result.receipt

def outstandingFromAttempts (policy : Policy P A D) (boundaries : ParallelBoundary P A D)
    (attempts : List (Attempt P A D)) : Outstanding P A D :=
  attempts.foldl (attemptOutstanding policy boundaries) zeroOutstanding

variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

/-- The same evaluated receipt used by execution gives the exact change at every cell. -/
theorem step_receipt_balance {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history step pre result) (cell : Cell P A D) :
    result.world.state.balance cell =
      pre.state.balance cell + receiptEffect result.receipt cell := by
  cases h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    exact ((applyEvaluated_ok_iff _ _ _ _ _ _).mp applied).2.2 cell
  | issue => simp [receiptEffect]
  | revoke => simp [receiptEffect]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem outstandingFromAttempts_append (policy : Policy P A D)
    (boundaries : ParallelBoundary P A D) (xs ys : List (Attempt P A D)) :
    outstandingFromAttempts policy boundaries (xs ++ ys) =
      ys.foldl (attemptOutstanding policy boundaries)
        (outstandingFromAttempts policy boundaries xs) := List.foldl_append

/-- Supply rejection retains the just-updated diagnostic table. -/
theorem advance_outstanding (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (b : BranchId) (active : m.abort = none) :
    (advance cfg boundaries policy left right m b).outstanding =
      match (Interleaving.advance cfg boundaries left right m.speculative b).attempts[
          m.speculative.attempts.length]? with
      | none => m.outstanding
      | some attempt => attemptOutstanding policy boundaries m.outstanding attempt := by
  cases hg : (Interleaving.advance cfg boundaries left right m.speculative b).attempts[
      m.speculative.attempts.length]? with
  | none => simp [advance, active, hg]
  | some attempt =>
    cases he : attempt.outcome with
    | error reason => simp [advance, active, hg, attemptOutstanding, he]
    | ok result =>
      simp only [advance, active, hg, attemptOutstanding, he]
      split <;> rfl

/-- Actual attempts, including the final successful supply-violating receipt, determine debt. -/
theorem advance_outstanding_fold (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (policy : Policy P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId)
    (old : m.outstanding = outstandingFromAttempts policy boundaries m.speculative.attempts) :
    (advance cfg boundaries policy left right m b).outstanding =
      outstandingFromAttempts policy boundaries
        (advance cfg boundaries policy left right m b).speculative.attempts := by
  cases ha : m.abort with
  | some reason => simpa only [advance_aborted _ _ _ _ _ _ _ reason ha] using old
  | none =>
    rw [advance_outstanding _ _ _ _ _ _ _ ha, advance_speculative _ _ _ _ _ _ _ ha]
    cases hf : (m.speculative.local b).failure with
    | some failure =>
      simp only [Interleaving.advance, hf]
      cases b <;> simpa [Interleaving.Machine.skip, Interleaving.Machine.setLocal] using old
    | none =>
      cases hs : (selectBranch left right b)[(m.speculative.local b).consumed]? with
      | none =>
        simp only [Interleaving.advance, hf, hs]
        cases b <;> simpa [Interleaving.Machine.skip, Interleaving.Machine.setLocal] using old
      | some inv =>
        rw [interleaving_advance_appended _ _ _ _ _ _ _ hf hs]
        simp [outstandingFromAttempts_append, old]

theorem Reachable.outstanding_fold {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {policy : Policy P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries policy left right initial m) :
    m.outstanding = outstandingFromAttempts policy boundaries m.speculative.attempts := by
  induction h with
  | start => rfl
  | next b previous ih => exact advance_outstanding_fold _ _ _ _ _ _ _ ih

/-- A real accepted invocation preserves lane cash plus all qualified outstanding entries. -/
theorem accepted_cash_owed {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {inv : Invocation P A D}
    {pre : World P A D} {result : StepResult P A D}
    (executed : executeStep cfg boundary index history (.invoke inv) pre = .ok result)
    (policy : Policy P A D) (owed : Outstanding P A D) (lane : Lane P A D)
    (hlane : lane ∈ policy.lanes) (hn : policy.participants.Nodup)
    (hp : boundary.ctx.principal ∈ policy.participants) :
    result.world.state.balance lane.cell +
      (policy.participants.map
        (updateOutstanding policy owed boundary.ctx.principal result.receipt lane)).sum =
      pre.state.balance lane.cell + (policy.participants.map (owed lane)).sum := by
  rw [step_receipt_balance (executeStep_sound _ _ _ _ _ _ _ executed),
    updateOutstanding_sum _ _ _ _ _ hlane hn hp]
  rw [add_assoc, ← add_sub_assoc, add_sub_cancel_left]

/-- Every reachable diagnostic prefix conserves lane cash plus signed participant obligations. -/
theorem Reachable.cash_owed {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {policy : Policy P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries policy left right initial m)
    (admitted : checkPolicy policy boundaries left right = .ok ⟨⟩)
    (lane : Lane P A D) (hlane : lane ∈ policy.lanes) :
    m.speculative.world.state.balance lane.cell +
      (policy.participants.map (m.outstanding lane)).sum = initial.state.balance lane.cell := by
  induction h with
  | start =>
    change initial.state.balance lane.cell +
      (policy.participants.map (fun _ ↦ (0 : ℚ))).sum = initial.state.balance lane.cell
    simp
  | @next m b previous ih =>
    cases ha : m.abort with
    | some reason => simpa only [advance_aborted _ _ _ _ _ _ _ reason ha] using ih
    | none =>
      have hf := previous.no_failures ha b
      rw [advance_outstanding _ _ _ _ _ _ _ ha, advance_speculative _ _ _ _ _ _ _ ha]
      cases hs : (selectBranch left right b)[(m.speculative.local b).consumed]? with
      | none =>
        simp only [Interleaving.advance, hf, hs]
        cases b <;> simpa [Interleaving.Machine.skip, Interleaving.Machine.setLocal] using ih
      | some inv =>
        have hidx := previous.interleaving.attempt_index b hf inv hs
        have hp := checkPolicy_covers policy boundaries left right admitted b
          (m.speculative.local b).nextIndex (by
            rw [hidx]
            exact (List.getElem?_eq_some_iff.mp hs).1)
        have hg := interleaving_advance_attempt cfg boundaries left right m.speculative b inv hf hs
        rw [hg]
        cases he : executeStep cfg (boundaries b (m.speculative.local b).nextIndex)
            (m.speculative.local b).nextIndex (m.speculative.local b).outputs
            (.invoke inv) m.speculative.world with
        | error reason =>
          simp only [he, attemptOutstanding, Interleaving.advance, hf, hs]
          cases b <;> simpa [Interleaving.Machine.refuse, Interleaving.Machine.setLocal] using ih
        | ok result =>
          simp only [he, attemptOutstanding, Interleaving.advance, hf, hs]
          have hstep := accepted_cash_owed he policy m.outstanding lane hlane
            (checkPolicy_participants_nodup _ _ _ _ admitted) hp
          cases b <;>
            simpa [Interleaving.Machine.accept, Interleaving.Machine.setLocal] using hstep.trans ih

theorem runPrefix_cash_owed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (initial : World P A D) (left right : Branch P A D)
    (schedule : Schedule) (admitted : checkPolicy policy boundaries left right = .ok ⟨⟩)
    (lane : Lane P A D) (hlane : lane ∈ policy.lanes) :
    (runPrefix cfg boundaries policy initial left right schedule).speculative.world.state.balance
      lane.cell + (policy.participants.map
        ((runPrefix cfg boundaries policy initial left right schedule).outstanding lane)).sum =
      initial.state.balance lane.cell :=
  (runPrefix_reachable _ _ _ _ _ _ _).cash_owed admitted lane hlane

/-- Full pointwise clearance restores each configured vault cell exactly. -/
theorem Reachable.cleared_cash {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {policy : Policy P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries policy left right initial m)
    (admitted : checkPolicy policy boundaries left right = .ok ⟨⟩)
    (cleared : residuals policy m.outstanding = [])
    (lane : Lane P A D) (hlane : lane ∈ policy.lanes) :
    m.speculative.world.state.balance lane.cell = initial.state.balance lane.cell := by
  have hall := (residuals_eq_nil_iff policy m.outstanding).mp cleared lane hlane
  have hs : (policy.participants.map (m.outstanding lane)).sum = 0 :=
    List.sum_eq_zero (by intro p hp; rcases List.mem_map.mp hp with ⟨q, hq, rfl⟩; exact hall q hq)
  simpa [hs] using h.cash_owed admitted lane hlane

end DefiKernel.Atomic

## END FILE

## FILE lean/DefiKernel/Atomic/Soundness.lean

Original SHA256: 4f47288077a5a12ac51efa428ea1e39fa145a3bcffa0f3d04906cc030dc2bb1d; bytes: 11062; rendered SHA256: 4f47288077a5a12ac51efa428ea1e39fa145a3bcffa0f3d04906cc030dc2bb1d

import DefiKernel.Atomic.Execution
import DefiKernel.Interleaving.Soundness

/-! Actual atomic steps either preserve a halted machine or take one existing
interleaving step. Every diagnostic machine is an actual interleaving prefix. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

inductive Reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (initial : World P A D) :
    Machine P A D → Prop
  | start : Reachable cfg boundaries policy left right initial (Atomic.start initial)
  | next {m : Machine P A D} (branch : BranchId)
      (previous : Reachable cfg boundaries policy left right initial m) :
      Reachable cfg boundaries policy left right initial
        (advance cfg boundaries policy left right m branch)

-- BEGIN PROOFS

/-- Selection of an active real call appends exactly one attempt with the actual result. -/
theorem interleaving_advance_appended (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (m : Interleaving.Machine P A D) (branch : BranchId) (inv : Invocation P A D)
    (active : (m.local branch).failure = none)
    (selected : (selectBranch left right branch)[(m.local branch).consumed]? = some inv) :
    (Interleaving.advance cfg boundaries left right m branch).attempts =
      m.attempts ++ [⟨branch, (m.local branch).nextIndex, inv, m.world,
        executeStep cfg (boundaries branch (m.local branch).nextIndex)
          (m.local branch).nextIndex (m.local branch).outputs (.invoke inv) m.world⟩] := by
  simp only [Interleaving.advance, active, selected]
  cases he : executeStep cfg (boundaries branch (m.local branch).nextIndex)
      (m.local branch).nextIndex (m.local branch).outputs (.invoke inv) m.world <;> rfl

theorem interleaving_advance_attempt (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (m : Interleaving.Machine P A D) (branch : BranchId) (inv : Invocation P A D)
    (active : (m.local branch).failure = none)
    (selected : (selectBranch left right branch)[(m.local branch).consumed]? = some inv) :
    (Interleaving.advance cfg boundaries left right m branch).attempts[m.attempts.length]? =
      some ⟨branch, (m.local branch).nextIndex, inv, m.world,
        executeStep cfg (boundaries branch (m.local branch).nextIndex)
          (m.local branch).nextIndex (m.local branch).outputs (.invoke inv) m.world⟩ := by
  rw [interleaving_advance_appended _ _ _ _ _ _ _ active selected]
  simp

theorem advance_entry (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId) :
    (advance cfg boundaries policy left right m branch).entryWorld = m.entryWorld := by
  unfold advance
  split
  · rfl
  · dsimp only
    split
    · rfl
    · split
      · rfl
      · split <;> rfl

theorem advance_speculative (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId) (active : m.abort = none) :
    (advance cfg boundaries policy left right m branch).speculative =
      Interleaving.advance cfg boundaries left right m.speculative branch := by
  unfold advance
  rw [active]
  dsimp only
  split
  · rfl
  · split
    · rfl
    · split <;> rfl

theorem advance_position (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId) (active : m.abort = none) :
    (advance cfg boundaries policy left right m branch).position = m.position + 1 := by
  unfold advance
  rw [active]
  dsimp only
  split
  · rfl
  · split
    · rfl
    · split <;> rfl

theorem advance_none_before (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId)
    (active : (advance cfg boundaries policy left right m branch).abort = none) :
    m.abort = none := by
  cases h : m.abort with
  | none => rfl
  | some reason => simp [advance_aborted _ _ _ _ _ _ _ reason h, h] at active

theorem advance_no_failures (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId)
    (old : ∀ b, (m.speculative.local b).failure = none)
    (active : (advance cfg boundaries policy left right m branch).abort = none) :
    ∀ b, ((advance cfg boundaries policy left right m branch).speculative.local b).failure =
      none := by
  have ha := advance_none_before _ _ _ _ _ _ _ active
  have hl : m.speculative.left.failure = none := old .left
  have hr : m.speculative.right.failure = none := old .right
  intro b
  rw [advance_speculative _ _ _ _ _ _ _ ha]
  cases hs : (selectBranch left right branch)[(m.speculative.local branch).consumed]? with
  | none =>
    simp only [Interleaving.advance, old branch, hs]
    cases branch <;> cases b <;>
      simp [Interleaving.Machine.skip, Interleaving.Machine.setLocal,
        Interleaving.Machine.local, hl, hr]
  | some inv =>
    have hg := interleaving_advance_attempt cfg boundaries left right m.speculative
      branch inv (old branch) hs
    cases he : executeStep cfg (boundaries branch (m.speculative.local branch).nextIndex)
        (m.speculative.local branch).nextIndex (m.speculative.local branch).outputs
        (.invoke inv) m.speculative.world with
    | error reason =>
      rw [he] at hg
      simp only [advance, ha, hg] at active
      contradiction
    | ok result =>
      simp only [Interleaving.advance, old branch, hs, he]
      cases branch <;> cases b <;>
        simp [Interleaving.Machine.accept, Interleaving.Machine.setLocal,
          Interleaving.Machine.local, hl, hr]

theorem Reachable.entry {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {policy : Policy P A D} {left right : Branch P A D} {initial : World P A D}
    {m : Machine P A D} (h : Reachable cfg boundaries policy left right initial m) :
    m.entryWorld = initial := by
  induction h with
  | start => rfl
  | next branch previous ih => exact (advance_entry _ _ _ _ _ _ _).trans ih

theorem Reachable.interleaving {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {policy : Policy P A D} {left right : Branch P A D} {initial : World P A D}
    {m : Machine P A D} (h : Reachable cfg boundaries policy left right initial m) :
    Interleaving.Reachable cfg boundaries left right initial m.speculative := by
  induction h with
  | start => exact .start
  | @next m branch previous ih =>
    cases ha : m.abort with
    | none =>
      rw [advance_speculative _ _ _ _ _ _ _ ha]
      exact .next branch ih (Interleaving.advance_sound _ _ _ _ _ _)
    | some reason =>
      rw [advance_aborted _ _ _ _ _ _ _ reason ha]
      exact ih

theorem Reachable.no_failures {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {policy : Policy P A D} {left right : Branch P A D} {initial : World P A D}
    {m : Machine P A D} (h : Reachable cfg boundaries policy left right initial m)
    (active : m.abort = none) : ∀ b, (m.speculative.local b).failure = none := by
  induction h with
  | start => intro b; cases b <;> rfl
  | next branch previous ih =>
    exact advance_no_failures _ _ _ _ _ _ _
      (ih (advance_none_before _ _ _ _ _ _ _ active)) active

theorem continueRun_reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (initial : World P A D)
    (m : Machine P A D) (h : Reachable cfg boundaries policy left right initial m)
    (schedule : Schedule) : Reachable cfg boundaries policy left right initial
      (continueRun cfg boundaries policy left right m schedule) := by
  induction schedule generalizing m with
  | nil => exact h
  | cons b tail ih => exact ih _ (.next b h)

theorem runPrefix_reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (initial : World P A D) (left right : Branch P A D)
    (schedule : Schedule) : Reachable cfg boundaries policy left right initial
      (runPrefix cfg boundaries policy initial left right schedule) :=
  continueRun_reachable _ _ _ _ _ _ _ .start _

/-- A witness is a literal prefix of the supplied schedule, not a reordered trace. -/
theorem continueRun_prefix (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (schedule : Schedule) :
    ∃ preTokens suffix, schedule = preTokens ++ suffix ∧
      (continueRun cfg boundaries policy left right m schedule).speculative =
        Interleaving.continueRun cfg boundaries left right m.speculative preTokens ∧
      (continueRun cfg boundaries policy left right m schedule).position =
        m.position + preTokens.length ∧
      ((continueRun cfg boundaries policy left right m schedule).abort = none →
        suffix = []) := by
  induction schedule generalizing m with
  | nil => exact ⟨[], [], rfl, rfl, (Nat.add_zero _).symm, fun _ => rfl⟩
  | cons b tail ih =>
    cases ha : m.abort with
    | some reason =>
      rw [continueRun_aborted _ _ _ _ _ _ _ reason ha]
      exact ⟨[], b :: tail, rfl, rfl, (Nat.add_zero _).symm, by simp [ha]⟩
    | none =>
      let next := advance cfg boundaries policy left right m b
      obtain ⟨preTokens, suffix, hs, hw, hp, hf⟩ := ih next
      refine ⟨b :: preTokens, suffix, by simp [hs], ?_, ?_, hf⟩
      · change (continueRun cfg boundaries policy left right next tail).speculative = _
        rw [hw]
        rw [show next.speculative = Interleaving.advance cfg boundaries left right
          m.speculative b from advance_speculative _ _ _ _ _ _ _ ha]
        rfl
      · change (continueRun cfg boundaries policy left right next tail).position = _
        rw [hp, show next.position = m.position + 1 from advance_position _ _ _ _ _ _ _ ha]
        simp [Nat.add_comm, Nat.add_left_comm]

theorem runPrefix_prefix (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (initial : World P A D) (left right : Branch P A D)
    (schedule : Schedule) :
    ∃ preTokens suffix, schedule = preTokens ++ suffix ∧
      (runPrefix cfg boundaries policy initial left right schedule).speculative =
        Interleaving.runPrefix cfg boundaries initial left right preTokens ∧
      (runPrefix cfg boundaries policy initial left right schedule).position =
        preTokens.length ∧
      ((runPrefix cfg boundaries policy initial left right schedule).abort = none →
        suffix = []) := by
  simpa only [runPrefix, Interleaving.runPrefix, Atomic.start, Nat.zero_add] using
    continueRun_prefix cfg boundaries policy left right (Atomic.start initial) schedule

end DefiKernel.Atomic

## END FILE

## FILE lean/DefiKernel/AxiomAudit.lean

Original SHA256: 4a8e330d42e7cd1c46df96ee201923ba2f5d17f37a74b2cb262c318193e72524; bytes: 4374; rendered SHA256: 4a8e330d42e7cd1c46df96ee201923ba2f5d17f37a74b2cb262c318193e72524

import Lean.Elab.Command
import Lean.Util.CollectAxioms

/-!
Audit theorem constants and supplemental definitions, opaque constants, and axioms in
imported modules whose names extend a given module prefix.
Discovery uses elaborated constant kinds and module provenance, never declaration source text.
Files outside the import closure and declarations in the current module are outside this scope.
-/

namespace DefiKernel.AxiomAudit

open Lean Elab Command

/-- The only permitted transitive axioms for the pilot's inspected declarations. -/
def allowedAxioms : Array Name := #[``propext, ``Classical.choice, ``Quot.sound]

/-- Discover all imported theorem constants with module provenance under `modulePrefix`. -/
def importedTheorems (env : Environment) (modulePrefix : Name) : Array (Name × Name) :=
  (env.constants.fold (init := #[]) fun found name info =>
    match info with
    | .thmInfo _ =>
      match env.getModuleIdxFor? name with
      | some idx =>
        let moduleName := env.header.moduleNames[idx.toNat]!
        if modulePrefix.isPrefixOf moduleName then found.push (name, moduleName) else found
      | none => found
    | _ => found).qsort fun a b => Name.lt a.1 b.1

/-- Discover imported definitions, opaque constants, and axioms under `modulePrefix`. -/
def importedSupplemental (env : Environment) (modulePrefix : Name) : Array (Name × Name × String) :=
  (env.constants.fold (init := #[]) fun found name info =>
    let kind := match info with
      | .defnInfo _ => "definition"
      | .opaqueInfo _ => "opaque"
      | .axiomInfo _ => "axiom"
      | _ => "other"
    if kind == "other" then found else
    match env.getModuleIdxFor? name with
    | some idx =>
      let moduleName := env.header.moduleNames[idx.toNat]!
      if modulePrefix.isPrefixOf moduleName then found.push (name, moduleName, kind) else found
    | none => found).qsort fun a b => Name.lt a.1 b.1

/--
Report every discovered theorem with its module and exact transitive axiom set.
Also inspect definitions, opaque constants, and axiom declarations, even if no theorem uses them.
Reject empty imported theorem scope and every dependency outside the standard allowlist.
For example, `#audit_axioms DefiKernel` audits loaded `DefiKernel.*` modules.
-/
elab "#audit_axioms " modulePrefix:ident : command => do
  let scopePrefix := modulePrefix.getId
  let env ← getEnv
  let modules := env.header.moduleNames.filter (scopePrefix.isPrefixOf ·)
  let theorems := importedTheorems env scopePrefix
  logInfo m!"AXIOM AUDIT scope: imported module prefix {scopePrefix}; modules={modules}"
  if theorems.isEmpty then
    throwError "AXIOM AUDIT BLOCKED: empty theorem scope for imported module prefix {scopePrefix}; theorems=0"
  let mut rejected : Nat := 0
  for (name, moduleName) in theorems do
    let axioms ← collectAxioms name
    logInfo m!"AXIOM AUDIT theorem: {name}; module={moduleName}; axioms={axioms}"
    let forbidden := axioms.filter fun ax => !allowedAxioms.contains ax
    unless forbidden.isEmpty do
      rejected := rejected + 1
      logError m!"AXIOM AUDIT FORBIDDEN: {name}; axioms={forbidden}"
  let supplemental := importedSupplemental env scopePrefix
  let mut supplementalRejected : Nat := 0
  for (name, moduleName, kind) in supplemental do
    let axioms ← collectAxioms name
    logInfo m!"AXIOM AUDIT declaration: {name}; module={moduleName}; kind={kind}; axioms={axioms}"
    let forbidden := axioms.filter fun ax => !allowedAxioms.contains ax
    unless forbidden.isEmpty do
      supplementalRejected := supplementalRejected + 1
      logError m!"AXIOM AUDIT DECLARATION FORBIDDEN: {name}; kind={kind}; axioms={forbidden}"
  if rejected > 0 then
    throwError "AXIOM AUDIT FAILED: {rejected}/{theorems.size} theorems use forbidden axioms"
  if supplementalRejected > 0 then
    throwError (m!"AXIOM AUDIT DECLARATIONS FAILED: {supplementalRejected}/{supplemental.size} " ++
      m!"supplemental declarations use forbidden axioms")
  if supplemental.isEmpty then
    logInfo "AXIOM AUDIT DECLARATIONS: supplemental declarations=0; theorem audit remains required"
  else
    logInfo <| m!"AXIOM AUDIT DECLARATIONS PASSED: {supplemental.size}/{supplemental.size} " ++
      m!"supplemental declarations; forbidden=0"
  logInfo m!"AXIOM AUDIT PASSED: {theorems.size}/{theorems.size} theorems; forbidden=0"

end DefiKernel.AxiomAudit

## END FILE

## FILE lean/DefiKernel/Composition/Contracts.lean

Original SHA256: d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c; bytes: 3446; rendered SHA256: d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c

import DefiKernel.Typed.Transition

/-! Proof-level contracts and ledger support. These predicates are not executable certificates;
initialization, environment truth, and local guarantees require separate proof premises. -/
namespace DefiKernel.Composition

open Typed

abbrev World (Party Asset Domain : Type) := ExecutionResult Party Asset Domain

/-- Semantic obligations are separate from finite interface validation. -/
structure ComponentContract (Party Asset Domain Boundary : Type) where
  initial : World Party Asset Domain → Prop
  assumes : Boundary → World Party Asset Domain → Prop
  invariant : World Party Asset Domain → Prop
  guarantees : Boundary → World Party Asset Domain → World Party Asset Domain → Prop

variable {Party Asset Domain Boundary : Type}

/-- Initialization and the inductive rule must actually be proved by a contract instance. -/
structure ContractObligations
    (contract : ComponentContract Party Asset Domain Boundary) : Prop where
  initialized : ∀ w, contract.initial w → contract.invariant w
  preserved : ∀ b pre post, contract.invariant pre → contract.assumes b pre →
    contract.guarantees b pre post → contract.invariant post

def Initial (contracts : List (ComponentContract Party Asset Domain Boundary))
    (world : World Party Asset Domain) : Prop :=
  ∀ contract ∈ contracts, contract.initial world

def AgreeOn (region : Set (Cell Party Asset Domain))
    (pre post : State Party Asset Domain) : Prop :=
  ∀ cell ∈ region, pre.balance cell = post.balance cell

/-- Only ledger predicates are framed; this definition does not cover capability-store reads. -/
def Supports (region : Set (Cell Party Asset Domain))
    (predicate : State Party Asset Domain → Prop) : Prop :=
  ∀ pre post, AgreeOn region pre post → (predicate pre ↔ predicate post)

-- BEGIN PROOFS

theorem AgreeOn.refl (region : Set (Cell Party Asset Domain))
    (state : State Party Asset Domain) : AgreeOn region state state := by
  intro cell hc
  rfl

theorem AgreeOn.symm {region : Set (Cell Party Asset Domain)}
    {s t : State Party Asset Domain} (h : AgreeOn region s t) : AgreeOn region t s := by
  intro cell hc
  exact (h cell hc).symm

theorem AgreeOn.trans {region : Set (Cell Party Asset Domain)}
    {s t u : State Party Asset Domain} (hst : AgreeOn region s t)
    (htu : AgreeOn region t u) : AgreeOn region s u := by
  intro cell hc
  exact (hst cell hc).trans (htu cell hc)

theorem supported_frame {region : Set (Cell Party Asset Domain)}
    {predicate : State Party Asset Domain → Prop} (support : Supports region predicate)
    {pre post : State Party Asset Domain} (unchanged : AgreeOn region pre post) :
    predicate pre ↔ predicate post := support pre post unchanged

theorem supports_balance (cell : Cell Party Asset Domain) (predicate : ℚ → Prop) :
    Supports {cell} (fun state ↦ predicate (state.balance cell)) := by
  intro pre post h
  change predicate (pre.balance cell) ↔ predicate (post.balance cell)
  rw [h cell (Set.mem_singleton cell)]

theorem initialized_invariants
    (contracts : List (ComponentContract Party Asset Domain Boundary))
    (obligations : ∀ c ∈ contracts, ContractObligations c)
    (world : World Party Asset Domain) (initial : Initial contracts world) :
    ∀ c ∈ contracts, c.invariant world := by
  intro c hc
  exact (obligations c hc).initialized world (initial c hc)

end DefiKernel.Composition

## END FILE

## FILE lean/DefiKernel/Composition/Execution.lean

Original SHA256: 34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602; bytes: 21579; rendered SHA256: 34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602

import DefiKernel.Composition.Interfaces
import DefiKernel.Composition.Contracts

/-! Single-step adaptation of registered execution. Receipts are re-evaluated against the
same pre-state, and are returned only after both execution and extraction succeed. -/
namespace DefiKernel.Composition
open Typed

structure Boundary (Party Asset Domain : Type) where
  ctx : InvocationContext Party Domain
  env : Environment Asset Domain
  now : Nat

structure Config (Party Asset Domain : Type) where
  registry : Registry Party Asset Domain
  domainAdmin : Domain → Party
  catalog : Catalog Party Asset Domain

structure Invocation (Party Asset Domain : Type) where
  component : ComponentId
  operation : OperationId
  parties : List Party
  inputs : List (InputSource Asset)
  capabilityIds : List CapabilityId
  claimedActor : Option Party := none

inductive Step (Party Asset Domain : Type) where
  | invoke (invocation : Invocation Party Asset Domain)
  | issue (grant : Grant Party Asset Domain)
  | revoke (id : CapabilityId)

inductive Failure where
  | configuration
  | interface (reason : InterfaceFailure)
  | kernel (reason : Typed.Refusal)
  | authority (reason : AuthorityFailure)
  | internalReceipt
  deriving DecidableEq, Repr

inductive Receipt (Party Asset Domain : Type) where
  | invoked (request : Request Party Asset Domain) (evaluated : Evaluated Party Asset Domain)
  | issued (id : CapabilityId)
  | revoked (id : CapabilityId)

structure StepResult (Party Asset Domain : Type) where
  world : World Party Asset Domain
  receipt : Receipt Party Asset Domain
  outputs : List (OutputObservation Asset)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def Config.authority (cfg : Config P A D) := registryAuthorityConfig cfg.registry cfg.domainAdmin

def Receipt.supply (receipt : Receipt P A D) (d : D) (a : A) : ℚ :=
  match receipt with
  | .invoked _ e => e.supply d a
  | _ => 0

def Receipt.writes (receipt : Receipt P A D) : List (Cell P A D) :=
  match receipt with
  | .invoked _ e => e.writes
  | _ => []

def prepareInvocation (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (inv : Invocation P A D) :
    Except Failure (OperationInterface P A D × Request P A D) := do
  let (component, iface) ← match lookupOperation cfg.catalog inv.component inv.operation with
    | none => .error (.interface .unknownOperation)
    | some pair => .ok pair
  let arguments ← (resolveInputs index history iface inv.inputs).mapError Failure.interface
  let template ← match cfg.registry inv.operation with
    | none => .error (.kernel .unknownOperation)
    | some template => .ok template
  let _ ← (checkAccess component template boundary.ctx inv.parties).mapError Failure.interface
  return (iface, ⟨inv.operation, inv.parties, arguments, inv.capabilityIds, inv.claimedActor⟩)

def extractReceipt (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (pre : World P A D) : Except Failure (Evaluated P A D) := do
  let template ← match cfg.registry request.operation with
    | none => .error .internalReceipt
    | some template => .ok template
  let args ← (Args.check template.signature request.arguments).mapError (fun _ ↦ .internalReceipt)
  (template.evaluate ⟨pre.state, boundary.env, boundary.ctx.principal,
    request.parties, args, boundary.now⟩).mapError (fun _ ↦ .internalReceipt)

def executeStep (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (step : Step P A D) (pre : World P A D) :
    Except Failure (StepResult P A D) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  match step with
  | .invoke inv =>
    let (iface, request) ← prepareInvocation cfg boundary index history inv
    let post ← (Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state).mapError Failure.kernel
    let e ← extractReceipt cfg boundary request pre
    return ⟨post, .invoked request e, snapshots index inv.component iface post.state⟩
  | .issue grant =>
    let (id, store) ← (issueCapability cfg.authority boundary.ctx pre.capabilities grant)
      |>.mapError Failure.authority
    return ⟨⟨pre.state, store⟩, .issued id, []⟩
  | .revoke id =>
    let store ← (revokeCapability cfg.authority boundary.ctx pre.capabilities id)
      |>.mapError Failure.authority
    return ⟨⟨pre.state, store⟩, .revoked id, []⟩

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
/-- The emitted write footprint is exactly the template's resolved declared footprint. -/
theorem evaluated_writes (template : Template P A D)
    (context : EvalContext P A D template.signature) (e : Evaluated P A D)
    (h : template.evaluate context = .ok e) :
    resolveRefs context.caller context.parties template.writes = .ok e.writes := by
  unfold Template.evaluate at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  have hp := Except.ok.inj h
  rw [← hp]
  assumption

omit [Fintype P] [Fintype A] [Fintype D] in
/-- The component and access check are selected from the trusted catalog and registry. -/
theorem prepareInvocation_access (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (iface : OperationInterface P A D) (request : Request P A D)
    (h : prepareInvocation cfg boundary index history inv = .ok (iface, request)) :
    ∃ component template, lookupOperation cfg.catalog inv.component inv.operation =
      some (component, iface) ∧ cfg.registry request.operation = some template ∧
      checkAccess component template boundary.ctx request.parties = .ok PUnit.unit := by
  cases hl : lookupOperation cfg.catalog inv.component inv.operation with
  | none => simp [prepareInvocation, hl, bind, Except.bind] at h
  | some pair =>
    rcases pair with ⟨component, selected⟩
    cases ha : resolveInputs index history selected inv.inputs with
    | error reason => simp [prepareInvocation, hl, ha, bind, Except.bind, Except.mapError] at h
    | ok arguments =>
      cases ht : cfg.registry inv.operation with
      | none => simp [prepareInvocation, hl, ha, ht, bind, Except.bind, Except.mapError] at h
      | some template =>
        cases hc : checkAccess component template boundary.ctx inv.parties with
        | error reason =>
          simp [prepareInvocation, hl, ha, ht, hc, bind, Except.bind, Except.mapError] at h
        | ok token =>
          cases token
          simp only [prepareInvocation, hl, ha, ht, hc, bind, Except.bind, Except.mapError,
            pure, Except.pure, Except.ok.injEq, Prod.mk.injEq] at h
          obtain ⟨rfl, rfl⟩ := h
          exact ⟨component, template, rfl, ht, hc⟩

theorem extractReceipt_total (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (pre post : World P A D)
    (h : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state = .ok post) :
    ∃ e, extractReceipt cfg boundary request pre = .ok e ∧
      applyEvaluated pre.capabilities boundary.ctx request pre.state e = .ok post := by
  obtain ⟨t, ht, args, ha, e, he, happly⟩ := execute_evaluated _ _ _ _ _ _ _ _ h
  exact ⟨e, by simp [extractReceipt, ht, ha, he, Except.mapError, bind, Except.bind], happly⟩

theorem extractReceipt_correspondence (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (pre post : World P A D) (e : Evaluated P A D)
    (h : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state = .ok post) (he : extractReceipt cfg boundary request pre = .ok e) :
    applyEvaluated pre.capabilities boundary.ctx request pre.state e = .ok post := by
  obtain ⟨e', he', happly⟩ := extractReceipt_total cfg boundary request pre post h
  rw [he] at he'
  cases he'
  exact happly

inductive StepSound (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) : Step P A D → World P A D → StepResult P A D → Prop
  | invoke (inv : Invocation P A D) (pre post : World P A D)
      (iface : OperationInterface P A D) (request : Request P A D) (e : Evaluated P A D)
      (prepared : prepareInvocation cfg boundary index history inv = .ok (iface, request))
      (executed : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
        request pre.state = .ok post)
      (extracted : extractReceipt cfg boundary request pre = .ok e)
      (applied : applyEvaluated pre.capabilities boundary.ctx request pre.state e = .ok post) :
      StepSound cfg boundary index history (.invoke inv) pre
        ⟨post, .invoked request e, snapshots index inv.component iface post.state⟩
  | issue (grant : Grant P A D) (pre : World P A D) (id : CapabilityId)
      (store : CapabilityStore P A D)
      (issued : issueCapability cfg.authority boundary.ctx pre.capabilities grant =
        .ok (id, store)) :
      StepSound cfg boundary index history (.issue grant) pre ⟨⟨pre.state, store⟩, .issued id, []⟩
  | revoke (id : CapabilityId) (pre : World P A D) (store : CapabilityStore P A D)
      (revoked : revokeCapability cfg.authority boundary.ctx pre.capabilities id = .ok store) :
      StepSound cfg boundary index history (.revoke id) pre ⟨⟨pre.state, store⟩, .revoked id, []⟩

theorem executeStep_sound (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (step : Step P A D) (pre : World P A D)
    (result : StepResult P A D) (h : executeStep cfg boundary index history step pre = .ok result) :
    StepSound cfg boundary index history step pre result := by
  cases hv : validateCatalog cfg.registry cfg.catalog with
  | false => cases step <;> simp [executeStep, hv, throw, throwThe, bind, Except.bind] at h
  | true =>
    cases step with
    | invoke inv =>
      simp only [executeStep, hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte,
        bind, Except.bind, pure, Except.pure] at h
      cases hp : prepareInvocation cfg boundary index history inv with
      | error err => simp [hp] at h
      | ok pair =>
        rcases pair with ⟨iface, request⟩
        simp only [hp] at h
        cases hx : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env
            boundary.now
            request pre.state with
        | error err => simp [hx, Except.mapError] at h
        | ok post =>
          simp only [hx, Except.mapError] at h
          cases he : extractReceipt cfg boundary request pre with
          | error err => simp [he] at h
          | ok e =>
            simp only [he, Except.ok.injEq] at h
            subst result
            exact .invoke inv pre post iface request e hp hx he
              (extractReceipt_correspondence cfg boundary request pre post e hx he)
    | issue grant =>
      simp only [executeStep, hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte,
        bind, Except.bind, pure, Except.pure] at h
      cases hi : issueCapability cfg.authority boundary.ctx pre.capabilities grant with
      | error err => simp [hi, Except.mapError] at h
      | ok pair =>
        rcases pair with ⟨id, store⟩
        simp only [hi, Except.mapError, Except.ok.injEq] at h
        subst result
        exact .issue grant pre id store hi
    | revoke id =>
      simp only [executeStep, hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte,
        bind, Except.bind, pure, Except.pure] at h
      cases hr : revokeCapability cfg.authority boundary.ctx pre.capabilities id with
      | error err => simp [hr, Except.mapError] at h
      | ok store =>
        simp only [hr, Except.mapError, Except.ok.injEq] at h
        subst result
        exact .revoke id pre store hr

theorem StepSound.accounting {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {step : Step P A D} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history step pre result)
    (d : D) (a : A) :
    total result.world.state d a = total pre.state d a + result.receipt.supply d a := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    exact applyEvaluated_accounting _ _ _ _ _ _ ha d a
  | issue => simp [Receipt.supply]
  | revoke => simp [Receipt.supply]

theorem StepSound.locality {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {step : Step P A D} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history step pre result)
    (c : Cell P A D) (hc : c ∉ result.receipt.writes) :
    result.world.state.balance c = pre.state.balance c := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    exact applyEvaluated_locality _ _ _ _ _ _ ha c hc
  | issue => rfl
  | revoke => rfl

/-- Every declared receipt write is allowed by the selected component interface. -/
theorem StepSound.component_writes {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {inv : Invocation P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.invoke inv) pre result) :
    ∃ component iface, lookupOperation cfg.catalog inv.component inv.operation =
      some (component, iface) ∧ ∀ cell ∈ result.receipt.writes, component.canWrite cell = true := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    obtain ⟨component, template, hl, ht, hc⟩ := prepareInvocation_access _ _ _ _ _ _ _ hp
    obtain ⟨selected, hs, args, hargs, actual, evaluated, applied⟩ :=
      execute_evaluated _ _ _ _ _ _ _ _ hx
    rw [ht] at hs
    cases hs
    have extracted : extractReceipt cfg boundary request pre = .ok actual := by
      simp [extractReceipt, ht, hargs, evaluated, bind, Except.bind, Except.mapError]
    rw [he] at extracted
    cases extracted
    have writes := evaluated_writes _ _ _ evaluated
    have allowed := checkAccess_declaredWrites component template boundary.ctx
      request.parties e.writes hc writes
    exact ⟨component, iface, hl, by simpa [Receipt.writes] using List.all_eq_true.mp allowed⟩

theorem StepSound.component_locality {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {inv : Invocation P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.invoke inv) pre result) :
    ∃ component iface, lookupOperation cfg.catalog inv.component inv.operation =
      some (component, iface) ∧ ∀ cell, component.canWrite cell = false →
        result.world.state.balance cell = pre.state.balance cell := by
  obtain ⟨component, iface, selected, writes⟩ := h.component_writes
  refine ⟨component, iface, selected, ?_⟩
  intro cell denied
  apply h.locality cell
  intro member
  have allowed := writes cell member
  rw [denied] at allowed
  contradiction

theorem StepSound.invoke_preserves_capabilities {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {inv : Invocation P A D} {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.invoke inv) pre result) :
    result.world.capabilities = pre.capabilities := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    exact execute_preserves_capabilities _ _ _ _ _ _ _ _ hx

theorem StepSound.issue_preserves_ledger {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {grant : Grant P A D} {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.issue grant) pre result) :
    result.world.state = pre.state := by cases h; rfl

theorem StepSound.revoke_preserves_ledger {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {id : CapabilityId} {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.revoke id) pre result) :
    result.world.state = pre.state := by cases h; rfl

def ReceiptAuthorized (pre : World P A D) (boundary : Boundary P A D)
    (receipt : Receipt P A D) : Prop :=
  match receipt with
  | .invoked request e =>
    hasAuthority pre.capabilities request.capabilityIds boundary.ctx
      request.operation .invoke = true ∧
    (∀ c, e.effect c < 0 → hasAuthority pre.capabilities request.capabilityIds boundary.ctx
      request.operation (.debit c) = true) ∧
    (∀ d a, e.supply d a ≠ 0 → hasAuthority pre.capabilities request.capabilityIds boundary.ctx
      request.operation (.changeSupply d a) = true)
  | _ => True

theorem StepSound.issue_admin {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {grant : Grant P A D} {pre : World P A D}
    {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.issue grant) pre result) :
    boundary.ctx.domain = grant.domain ∧
      boundary.ctx.principal = cfg.domainAdmin grant.domain := by
  cases h with
  | issue grant pre id store hi => exact issueCapability_admin _ _ _ _ _ _ hi

theorem StepSound.revoke_admin {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {id : CapabilityId} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history (.revoke id) pre result) :
    ∃ cap, pre.capabilities.lookup id = some cap ∧ boundary.ctx.domain = cap.domain ∧
      boundary.ctx.principal = cfg.domainAdmin cap.domain := by
  cases h with
  | revoke id pre store hr => exact revokeCapability_admin _ _ _ _ _ hr

theorem StepSound.authorized {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {step : Step P A D} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history step pre result) :
    ReceiptAuthorized pre boundary result.receipt := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    obtain ⟨_, _, _, _, _, _, _, hi, _⟩ := (execute_ok_iff ..).mp hx
    obtain ⟨hv, _, _⟩ := (applyEvaluated_ok_iff ..).mp ha
    exact ⟨hi, of_decide_eq_true hv.2.2.2.2.1, of_decide_eq_true hv.2.2.2.2.2.1⟩
  | issue => trivial
  | revoke => trivial

theorem StepSound.domain {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {inv : Invocation P A D} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history (.invoke inv) pre result)
    (c : Cell P A D) (hc : result.world.state.balance c ≠ pre.state.balance c) :
    c.1 = boundary.ctx.domain := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    obtain ⟨_, _, _, _, _, _, _, _, _, hdom⟩ := execute_reads_and_domain _ _ _ _ _ _ _ _ hx
    exact hdom c hc

theorem executeStep_configuration (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (step : Step P A D) (pre : World P A D)
    (h : validateCatalog cfg.registry cfg.catalog = false) :
    executeStep cfg boundary index history step pre = .error .configuration := by
  cases step <;> simp [executeStep, h, throw, throwThe, bind, Except.bind] <;> rfl

theorem executeStep_delegated_refusal (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (pre : World P A D) (iface : OperationInterface P A D) (request : Request P A D)
    (reason : Typed.Refusal) (hv : validateCatalog cfg.registry cfg.catalog = true)
    (hp : prepareInvocation cfg boundary index history inv = .ok (iface, request))
    (hx : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state = .error reason) :
    executeStep cfg boundary index history (.invoke inv) pre = .error (.kernel reason) := by
  simp [executeStep, hv, hp, hx, Except.mapError, bind, Except.bind]

theorem executeStep_delegated_success (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (pre post : World P A D) (iface : OperationInterface P A D) (request : Request P A D)
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (hp : prepareInvocation cfg boundary index history inv = .ok (iface, request))
    (hx : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state = .ok post) :
    ∃ e, extractReceipt cfg boundary request pre = .ok e ∧
      executeStep cfg boundary index history (.invoke inv) pre =
        .ok ⟨post, .invoked request e, snapshots index inv.component iface post.state⟩ := by
  obtain ⟨e, he, _⟩ := extractReceipt_total cfg boundary request pre post hx
  exact ⟨e, he, by
    simp [executeStep, hv, hp, hx, he, Except.mapError, bind, Except.bind, pure, Except.pure]⟩

end DefiKernel.Composition

## END FILE

## FILE lean/DefiKernel/Composition/Interfaces.lean

Original SHA256: 4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe; bytes: 12415; rendered SHA256: 4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe

import DefiKernel.Typed.Transition

/-! Finite component declarations, concrete access checks and immutable value snapshots.
Catalog validation is structural; it does not discharge semantic contracts or kernel authority. -/
namespace DefiKernel.Composition
open Typed

structure ComponentId where
  value : Nat
  deriving DecidableEq, Repr

structure PortId where
  value : Nat
  deriving DecidableEq, Repr

structure QualifiedPort where
  component : ComponentId
  port : PortId
  deriving DecidableEq, Repr

structure InputPort (Asset : Type) where
  id : PortId
  unit : Typed.Unit Asset
  deriving DecidableEq, Repr

structure OutputPort (Party Asset Domain : Type) where
  id : PortId
  cell : Cell Party Asset Domain
  deriving DecidableEq, Repr

structure ResourcePort (Party Asset Domain : Type) where
  id : PortId
  cell : Cell Party Asset Domain
  writable : Bool
  deriving DecidableEq, Repr

structure ResourceImport (Party Asset Domain : Type) where
  source : QualifiedPort
  cell : Cell Party Asset Domain
  writable : Bool
  deriving DecidableEq, Repr

structure OperationInterface (Party Asset Domain : Type) where
  operation : OperationId
  inputs : List (InputPort Asset)
  outputs : List (OutputPort Party Asset Domain)
  deriving DecidableEq, Repr

structure Component (Party Asset Domain : Type) where
  id : ComponentId
  privateCells : List (Cell Party Asset Domain)
  exports : List (ResourcePort Party Asset Domain)
  imports : List (ResourceImport Party Asset Domain)
  operations : List (OperationInterface Party Asset Domain)
  deriving DecidableEq, Repr

abbrev Catalog (Party Asset Domain : Type) := List (Component Party Asset Domain)

inductive InterfaceFailure where
  | unknownOperation
  | resolution (reason : EvalFailure)
  | readAccess
  | writeAccess
  | inputCount
  | inputUnit
  | unavailableOutput
  deriving DecidableEq, Repr

inductive InputSource (Asset : Type) where
  | literal (value : PackedValue Asset)
  | priorOutput (step : Nat) (port : QualifiedPort)

structure OutputObservation (Asset : Type) where
  step : Nat
  port : QualifiedPort
  value : PackedValue Asset

variable {Party Asset Domain : Type}
variable [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain]

def Component.canRead (component : Component Party Asset Domain)
    (cell : Cell Party Asset Domain) : Bool :=
  decide (cell ∈ component.privateCells) ||
    component.exports.any (fun p ↦ decide (p.cell = cell)) ||
    component.imports.any (fun p ↦ decide (p.cell = cell))

def Component.canWrite (component : Component Party Asset Domain)
    (cell : Cell Party Asset Domain) : Bool :=
  decide (cell ∈ component.privateCells) ||
    component.exports.any (fun p ↦ decide (p.cell = cell) && p.writable) ||
    component.imports.any (fun p ↦ decide (p.cell = cell) && p.writable)

def lookupOperation (catalog : Catalog Party Asset Domain) (componentId : ComponentId)
    (operationId : OperationId) :
    Option (Component Party Asset Domain × OperationInterface Party Asset Domain) := do
  let component ← catalog.find? (fun c ↦ decide (c.id = componentId))
  let interface ← component.operations.find? (fun i ↦ decide (i.operation = operationId))
  return (component, interface)

def Component.portIds (component : Component Party Asset Domain) : List PortId :=
  component.exports.map ResourcePort.id ++ component.operations.flatMap
    (fun i ↦ i.inputs.map InputPort.id ++ i.outputs.map OutputPort.id)

/-- Private ownership excludes all shared ports, including the owner's own exports.
An import may reduce write access, but cannot grant more rights than its exact export. -/
def validateCatalog (registry : Registry Party Asset Domain)
    (catalog : Catalog Party Asset Domain) : Bool :=
  decide ((catalog.map Component.id).Nodup) &&
  decide ((catalog.flatMap (fun c ↦ c.operations.map OperationInterface.operation)).Nodup) &&
  decide ((catalog.flatMap Component.privateCells).Nodup) &&
  decide ((catalog.flatMap (fun c ↦ c.exports.map ResourcePort.cell)).Nodup) &&
  catalog.all (fun c ↦
    decide (c.portIds.Nodup) && decide ((c.imports.map ResourceImport.source).Nodup) &&
    c.exports.all (fun p ↦
      !(catalog.any (fun owner ↦ decide (p.cell ∈ owner.privateCells)))) &&
    c.imports.all (fun p ↦
      !(c.exports.any (fun e ↦ decide (e.cell = p.cell))) &&
      !(catalog.any (fun owner ↦ decide (p.cell ∈ owner.privateCells))) &&
      catalog.any (fun source ↦ decide (source.id = p.source.component) &&
        source.exports.any (fun e ↦ decide (e.id = p.source.port) &&
          decide (e.cell = p.cell) && (!p.writable || e.writable)))) &&
    c.operations.all (fun i ↦
      (match registry i.operation with
       | none => false
       | some template => decide (i.inputs.map InputPort.unit = template.signature) &&
         i.outputs.all (fun o ↦ decide (o.cell.1 = template.domain))) &&
      i.outputs.all (fun o ↦ c.canRead o.cell)))

/-- Resolve references without evaluating financial expressions. Both expression branches,
supply/guard reads, declared reads, declared writes and every delta target are checked. -/
def checkAccess (component : Component Party Asset Domain)
    (template : Template Party Asset Domain) (ctx : InvocationContext Party Domain)
    (parties : List Party) : Except InterfaceFailure PUnit := do
  let reads ← (resolveRefs ctx.principal parties
    (template.requiredStateReads ++ template.stateReads)).mapError .resolution
  let writes ← (resolveRefs ctx.principal parties
    (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩))).mapError .resolution
  if !(reads.all component.canRead) then throw .readAccess
  if !(writes.all component.canWrite) then throw .writeAccess
  return ⟨⟩

/-- Earlier absolute positions are necessary even if an untrusted history contains a future key.
The runner additionally ensures history contains only actual successful snapshots. -/
def resolveSource (index : Nat) (history : List (OutputObservation Asset)) :
    InputSource Asset → Except InterfaceFailure (PackedValue Asset)
  | .literal value => .ok value
  | .priorOutput step port =>
    if step < index then
      match history.find? (fun o ↦ decide (o.step = step ∧ o.port = port)) with
      | some output => .ok output.value
      | none => .error .unavailableOutput
    else .error .unavailableOutput

def resolveInputs (index : Nat) (history : List (OutputObservation Asset))
    (interface : OperationInterface Party Asset Domain) (sources : List (InputSource Asset)) :
    Except InterfaceFailure (List (PackedValue Asset)) := do
  if sources.length != interface.inputs.length then throw .inputCount
  let values ← sources.mapM (resolveSource index history)
  if values.map Sigma.fst != interface.inputs.map InputPort.unit then throw .inputUnit
  return values

/-- Output units are intrinsic to the selected cell and balances are copied after commitment. -/
def snapshots (index : Nat) (component : ComponentId)
    (interface : OperationInterface Party Asset Domain) (state : State Party Asset Domain) :
    List (OutputObservation Asset) :=
  interface.outputs.map (fun o ↦
    ⟨index, ⟨component, o.id⟩, ⟨.amount o.cell.2.2, state.balance o.cell⟩⟩)

-- BEGIN PROOFS

/-- Successful prechecks resolve the complete conservative reference inventories and
accept every concrete read and write; no financial expression evaluation is assumed. -/
theorem checkAccess_ok_iff (component : Component Party Asset Domain)
    (template : Template Party Asset Domain) (ctx : InvocationContext Party Domain)
    (parties : List Party) :
    checkAccess component template ctx parties = .ok PUnit.unit ↔
      ∃ reads writes,
        resolveRefs ctx.principal parties
          (template.requiredStateReads ++ template.stateReads) = .ok reads ∧
        resolveRefs ctx.principal parties
          (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩)) = .ok writes ∧
        reads.all component.canRead = true ∧ writes.all component.canWrite = true := by
  unfold checkAccess
  cases hr : resolveRefs ctx.principal parties
    (template.requiredStateReads ++ template.stateReads) with
  | error e => simp [Except.mapError, bind, Except.bind]
  | ok reads =>
    cases hw : resolveRefs ctx.principal parties
      (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩)) with
    | error e => simp [Except.mapError, bind, Except.bind]
    | ok writes =>
      simp only [Except.mapError, bind, Except.bind]
      by_cases r : reads.all component.canRead = true <;>
        by_cases w : writes.all component.canWrite = true <;>
        simp [r, w, -List.all_eq_true, throw, throwThe, pure, Except.pure]


/-- In particular every resolved declared write accepted by the precheck is writable. -/
theorem checkAccess_declaredWrites (component : Component Party Asset Domain)
    (template : Template Party Asset Domain) (ctx : InvocationContext Party Domain)
    (parties : List Party) (writes : List (Cell Party Asset Domain))
    (accepted : checkAccess component template ctx parties = .ok PUnit.unit)
    (resolved : resolveRefs ctx.principal parties template.writes = .ok writes) :
    writes.all component.canWrite = true := by
  obtain ⟨reads, allWrites, _, hw, _, allowed⟩ :=
    (checkAccess_ok_iff component template ctx parties).mp accepted
  simp only [resolveRefs, List.mapM_append] at hw
  change (template.writes.mapM (fun ref ↦ ref.2.resolve ctx.principal parties)) =
    .ok writes at resolved
  rw [resolved] at hw
  cases ht : (template.deltas.map
      (fun d ↦ (⟨d.asset, d.target⟩ : PackedCellRef Party Asset Domain))).mapM
      (fun ref ↦ ref.2.resolve ctx.principal parties) with
  | error e => simp [ht, bind, Except.bind] at hw
  | ok targets =>
    simp only [ht, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at hw
    subst allWrites
    simp only [List.all_append, Bool.and_eq_true] at allowed
    exact allowed.1

/-- A validated catalog keeps every export away from every private owner. -/
theorem validateCatalog_export_not_private (registry : Registry Party Asset Domain)
    (catalog : Catalog Party Asset Domain) (valid : validateCatalog registry catalog = true)
    (component owner : Component Party Asset Domain) (hc : component ∈ catalog)
    (ho : owner ∈ catalog) (port : ResourcePort Party Asset Domain)
    (hp : port ∈ component.exports) : port.cell ∉ owner.privateCells := by
  simp only [validateCatalog, Bool.and_eq_true] at valid
  have componentValid := List.all_eq_true.mp valid.2 component hc
  simp only [Bool.and_eq_true] at componentValid
  have exportValid := List.all_eq_true.mp componentValid.1.1.2 port hp
  simpa using (show ¬port.cell ∈ owner.privateCells from by
    intro h
    have : catalog.any (fun c ↦ decide (port.cell ∈ c.privateCells)) = true :=
      List.any_eq_true.mpr ⟨owner, ho, by simpa using h⟩
    simp [this] at exportValid)

omit [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain] in
theorem snapshots_length (index : Nat) (component : ComponentId)
    (interface : OperationInterface Party Asset Domain) (state : State Party Asset Domain) :
    (snapshots index component interface state).length = interface.outputs.length := by
  simp [snapshots]

omit [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain] in
theorem snapshot_of_selected (index : Nat) (component : ComponentId)
    (interface : OperationInterface Party Asset Domain) (state : State Party Asset Domain)
    (output : OutputPort Party Asset Domain) (h : output ∈ interface.outputs) :
    (⟨index, ⟨component, output.id⟩,
      ⟨.amount output.cell.2.2, state.balance output.cell⟩⟩ : OutputObservation Asset) ∈
      snapshots index component interface state := by
  exact List.mem_map.mpr ⟨output, h, rfl⟩

omit [DecidableEq Asset] in
theorem resolveSource_literal (index : Nat) (history : List (OutputObservation Asset))
    (value : PackedValue Asset) : resolveSource index history (.literal value) = .ok value := rfl

omit [DecidableEq Asset] in
theorem resolveSource_not_prior (index step : Nat) (history : List (OutputObservation Asset))
    (port : QualifiedPort) (h : ¬step < index) :
    resolveSource index history (.priorOutput step port) = .error .unavailableOutput := by
  simp [resolveSource, h]

end DefiKernel.Composition

## END FILE

## FILE lean/DefiKernel/Composition/Sequence.lean

Original SHA256: 32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729; bytes: 10173; rendered SHA256: 32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729

import DefiKernel.Composition.Execution

/-! Finite ordered execution. A refusal commits no new event, preserves the successful prefix,
and makes every continuation inert. Trusted boundary positions are absolute. -/
namespace DefiKernel.Composition
open Typed

structure Event (Party Asset Domain : Type) where
  index : Nat
  step : Step Party Asset Domain
  before : World Party Asset Domain
  result : StepResult Party Asset Domain

structure LocatedFailure (Party Asset Domain : Type) where
  index : Nat
  step : Option (Step Party Asset Domain)
  reason : Failure

structure Cursor (Party Asset Domain : Type) where
  world : World Party Asset Domain
  events : List (Event Party Asset Domain)
  outputs : List (OutputObservation Asset)
  nextIndex : Nat
  failure : Option (LocatedFailure Party Asset Domain)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def startCursor (cfg : Config P A D) (world : World P A D) : Cursor P A D :=
  ⟨world, [], [], 0, if validateCatalog cfg.registry cfg.catalog then none
    else some ⟨0, none, .configuration⟩⟩

def advance (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (step : Step P A D) : Cursor P A D :=
  match cursor.failure with
  | some _ => cursor
  | none =>
    match executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
        step cursor.world with
    | .error reason => { cursor with failure := some ⟨cursor.nextIndex, some step, reason⟩ }
    | .ok result =>
      ⟨result.world, cursor.events ++ [⟨cursor.nextIndex, step, cursor.world, result⟩],
        cursor.outputs ++ result.outputs, cursor.nextIndex + 1, none⟩

def continueRun (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (steps : List (Step P A D)) : Cursor P A D :=
  steps.foldl (advance cfg boundaries) cursor

def run (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (world : World P A D) (steps : List (Step P A D)) : Cursor P A D :=
  continueRun cfg boundaries (startCursor cfg world) steps

-- BEGIN PROOFS

/-- The trace relates actual step evidence at each preceding world and output history. -/
inductive TraceSound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) :
    List (Event P A D) → World P A D → List (OutputObservation A) → Nat → Prop
  | nil : TraceSound cfg boundaries initial [] initial [] 0
  | snoc {events : List (Event P A D)} {pre : World P A D}
      {history : List (OutputObservation A)} {index : Nat}
      (previous : TraceSound cfg boundaries initial events pre history index)
      (step : Step P A D) (result : StepResult P A D)
      (accepted : StepSound cfg (boundaries index) index history step pre result) :
      TraceSound cfg boundaries initial (events ++ [⟨index, step, pre, result⟩])
        result.world (history ++ result.outputs) (index + 1)

def RefusalSound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) : Prop :=
  ∀ failure, cursor.failure = some failure → failure.index = cursor.nextIndex ∧
    match failure.step with
    | none => failure.reason = .configuration ∧ validateCatalog cfg.registry cfg.catalog = false
    | some step => executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex
        cursor.outputs step cursor.world = .error failure.reason

theorem continueRun_nil (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) : continueRun cfg boundaries cursor [] = cursor := rfl

theorem continueRun_append (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (firstSteps suffix : List (Step P A D)) :
    continueRun cfg boundaries cursor (firstSteps ++ suffix) =
      continueRun cfg boundaries (continueRun cfg boundaries cursor firstSteps) suffix := by
  exact List.foldl_append

theorem continueRun_failed (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (failure : LocatedFailure P A D)
    (failed : cursor.failure = some failure) (steps : List (Step P A D)) :
    continueRun cfg boundaries cursor steps = cursor := by
  induction steps with
  | nil => rfl
  | cons step steps ih =>
    simpa [continueRun, List.foldl_cons, advance, failed] using ih

/-- Recorded invocations/admin steps are an ordered prefix of the submitted list. -/
theorem continueRun_order (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (steps : List (Step P A D)) :
    ∃ accepted remaining, steps = accepted ++ remaining ∧
      (continueRun cfg boundaries cursor steps).events.map Event.step =
        cursor.events.map Event.step ++ accepted := by
  induction steps generalizing cursor with
  | nil => exact ⟨[], [], rfl, by simp [continueRun]⟩
  | cons step steps ih =>
    cases hf : cursor.failure with
    | some failure =>
      exact ⟨[], step :: steps, rfl, by rw [continueRun_failed _ _ _ _ hf]; simp⟩
    | none =>
      cases he : executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
          step cursor.world with
      | error reason =>
        have ha : (advance cfg boundaries cursor step).failure =
            some ⟨cursor.nextIndex, some step, reason⟩ := by simp [advance, hf, he]
        refine ⟨[], step :: steps, rfl, ?_⟩
        change (continueRun cfg boundaries (advance cfg boundaries cursor step) steps).events.map
          Event.step = cursor.events.map Event.step ++ []
        rw [continueRun_failed _ _ _ _ ha]
        simp [advance, hf, he]
      | ok result =>
        obtain ⟨accepted, remaining, hs, hout⟩ := ih (advance cfg boundaries cursor step)
        refine ⟨step :: accepted, remaining, by simp [hs], ?_⟩
        change (continueRun cfg boundaries (advance cfg boundaries cursor step) steps).events.map
          Event.step = cursor.events.map Event.step ++ step :: accepted
        rw [hout]
        simp [advance, hf, he, List.map_append, List.append_assoc]

theorem run_order (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) :
    ∃ accepted remaining, steps = accepted ++ remaining ∧
      (run cfg boundaries initial steps).events.map Event.step = accepted := by
  simpa [run, startCursor] using continueRun_order cfg boundaries (startCursor cfg initial) steps

theorem advance_trace_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (cursor : Cursor P A D) (step : Step P A D)
    (h : TraceSound cfg boundaries initial cursor.events cursor.world
      cursor.outputs cursor.nextIndex) :
    TraceSound cfg boundaries initial (advance cfg boundaries cursor step).events
      (advance cfg boundaries cursor step).world (advance cfg boundaries cursor step).outputs
      (advance cfg boundaries cursor step).nextIndex := by
  cases hf : cursor.failure with
  | some failure => simpa [advance, hf] using h
  | none =>
    cases he : executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
        step cursor.world with
    | error reason => simpa [advance, hf, he] using h
    | ok result =>
      simpa [advance, hf, he] using h.snoc step result (executeStep_sound _ _ _ _ _ _ _ he)

theorem continueRun_trace_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (cursor : Cursor P A D) (steps : List (Step P A D))
    (h : TraceSound cfg boundaries initial cursor.events cursor.world
      cursor.outputs cursor.nextIndex) :
    TraceSound cfg boundaries initial (continueRun cfg boundaries cursor steps).events
      (continueRun cfg boundaries cursor steps).world
      (continueRun cfg boundaries cursor steps).outputs
      (continueRun cfg boundaries cursor steps).nextIndex := by
  induction steps generalizing cursor with
  | nil => exact h
  | cons step steps ih =>
    exact ih (advance cfg boundaries cursor step)
      (advance_trace_sound cfg boundaries initial cursor step h)

theorem run_trace_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) :
    TraceSound cfg boundaries initial (run cfg boundaries initial steps).events
      (run cfg boundaries initial steps).world (run cfg boundaries initial steps).outputs
      (run cfg boundaries initial steps).nextIndex := by
  apply continueRun_trace_sound
  exact .nil

theorem advance_refusal_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (step : Step P A D) (h : RefusalSound cfg boundaries cursor) :
    RefusalSound cfg boundaries (advance cfg boundaries cursor step) := by
  cases hf : cursor.failure with
  | some failure => simpa [advance, hf] using h
  | none =>
    cases he : executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
        step cursor.world with
    | error reason =>
      intro failure hh
      simp only [advance, hf, he, Option.some.injEq] at hh
      subst failure
      simp [advance, hf, he]
    | ok result =>
      intro failure hh
      simp [advance, hf, he] at hh

theorem continueRun_refusal_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (steps : List (Step P A D)) (h : RefusalSound cfg boundaries cursor) :
    RefusalSound cfg boundaries (continueRun cfg boundaries cursor steps) := by
  induction steps generalizing cursor with
  | nil => exact h
  | cons step steps ih =>
    exact ih (advance cfg boundaries cursor step)
      (advance_refusal_sound cfg boundaries cursor step h)

theorem run_refusal_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) :
    RefusalSound cfg boundaries (run cfg boundaries initial steps) := by
  apply continueRun_refusal_sound
  intro failure h
  simp only [startCursor] at h ⊢
  split at h
  · contradiction
  · simp only [Option.some.injEq] at h
    subst failure
    rename_i hv
    exact ⟨rfl, rfl, by simpa using hv⟩

end DefiKernel.Composition

## END FILE

## FILE lean/DefiKernel/Interleaving/Execution.lean

Original SHA256: 8a39ccbaf6cf03479a5b16a156c52a2b6f5bd97a9198b633be27be3b1b899d21; bytes: 7949; rendered SHA256: 8a39ccbaf6cf03479a5b16a156c52a2b6f5bd97a9198b633be27be3b1b899d21

import DefiKernel.Interleaving.Schedule
import DefiKernel.Parallel.Observation
import DefiKernel.Parallel.Execution

/-! Finite replay over one evolving world. Local histories and permanent refusals stay separate;
consumed static slots advance even when a failed suffix produces no further attempt. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

structure LocalState (P A D : Type) where
  consumed : Nat := 0
  events : List (Event P A D) := []
  outputs : List (OutputObservation A) := []
  nextIndex : Nat := 0
  failure : Option (LocatedFailure P A D) := none

structure Attempt (P A D : Type) where
  branch : BranchId
  index : Nat
  invocation : Invocation P A D
  before : World P A D
  outcome : Except Composition.Failure (StepResult P A D)

structure Machine (P A D : Type) where
  world : World P A D
  left : LocalState P A D := {}
  right : LocalState P A D := {}
  attempts : List (Attempt P A D) := []

inductive Result (P A D : Type) where
  | refused (reason : Interleaving.AdmissionFailure P A D) (world : World P A D)
      (schedule : Schedule)
  | executed (schedule : Schedule) (machine : Machine P A D)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def Machine.local (m : Machine P A D) : BranchId → LocalState P A D
  | .left => m.left
  | .right => m.right

def Machine.setLocal (m : Machine P A D) (b : BranchId)
    (localState : LocalState P A D) : Machine P A D :=
  match b with
  | .left => { m with left := localState }
  | .right => { m with right := localState }

def selectBranch (left right : Branch P A D) : BranchId → Branch P A D
  | .left => left
  | .right => right

def start (initial : World P A D) : Machine P A D := ⟨initial, {}, {}, []⟩

/-- The new public projection owns every preserved field, including exact located failure. -/
def LocalState.observe (localState : LocalState P A D) : BranchObservation P A D :=
  ⟨localState.events.map observeEvent, localState.outputs,
    localState.nextIndex, localState.failure⟩

def LocalState.toCursor (localState : LocalState P A D) (world : World P A D) : Cursor P A D :=
  ⟨world, localState.events, localState.outputs, localState.nextIndex, localState.failure⟩

def Attempt.supply (attempt : Attempt P A D) (d : D) (a : A) : ℚ :=
  match attempt.outcome with
  | .error _ => 0
  | .ok result => result.receipt.supply d a

/-- Executable aggregation of actual successful attempts; refusals contribute zero. -/
def Machine.supply (m : Machine P A D) (d : D) (a : A) : ℚ :=
  (m.attempts.map (fun attempt ↦ attempt.supply d a)).sum

def Attempt.writes (attempt : Attempt P A D) : List (Cell P A D) :=
  match attempt.outcome with
  | .error _ => []
  | .ok result => result.receipt.writes

def Machine.writes (m : Machine P A D) : List (Cell P A D) :=
  m.attempts.flatMap Attempt.writes

def Machine.skip (m : Machine P A D) (b : BranchId) : Machine P A D :=
  m.setLocal b { m.local b with consumed := (m.local b).consumed + 1 }

def Machine.refuse (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (reason : Composition.Failure) : Machine P A D :=
  let own := m.local b
  let stopped : LocalState P A D := { own with
    consumed := own.consumed + 1
    failure := some ⟨own.nextIndex, some (.invoke inv), reason⟩ }
  let updated := m.setLocal b stopped
  { updated with attempts := m.attempts ++
      [⟨b, own.nextIndex, inv, m.world, .error reason⟩] }

def Machine.accept (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (result : StepResult P A D) : Machine P A D :=
  let own := m.local b
  let advanced : LocalState P A D := ⟨own.consumed + 1,
    own.events ++ [⟨own.nextIndex, .invoke inv, m.world, result⟩],
    own.outputs ++ result.outputs, own.nextIndex + 1, none⟩
  let updated := m.setLocal b advanced
  { updated with world := result.world, attempts := m.attempts ++
      [⟨b, own.nextIndex, inv, m.world, .ok result⟩] }

variable [Fintype P] [Fintype A] [Fintype D]

/-- Advance exactly one static branch slot, preserving the peer's local state. -/
def advance (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) : Machine P A D :=
  let own := m.local b
  match own.failure with
  | some _ => m.skip b
  | none =>
    match (selectBranch left right b)[own.consumed]? with
    | none => m.skip b
    | some inv =>
      let outcome := executeStep cfg (boundaries b own.nextIndex) own.nextIndex own.outputs
        (.invoke inv) m.world
      match outcome with
      | .error reason => m.refuse b inv reason
      | .ok result => m.accept b inv result

def continueRun (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (schedule : Schedule) : Machine P A D :=
  schedule.foldl (advance cfg boundaries left right) m

def runPrefix (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) : Machine P A D :=
  continueRun cfg boundaries left right (start initial) schedule

def runInterleaving (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) :
    Interleaving.Result P A D :=
  match Interleaving.admit cfg boundaries left right schedule with
  | .error reason => .refused reason initial schedule
  | .ok _ => .executed schedule (runPrefix cfg boundaries initial left right schedule)

/-- Exact financial fields, without raw foreign event worlds or global scheduling order. -/
def ProjectedEquivalent (m : Machine P A D) (joined : Parallel.Joined P A D) : Prop :=
  Parallel.WorldEquivalent m.world joined.world ∧
    m.left.observe = observeBranch joined.left ∧ m.right.observe = observeBranch joined.right

def observationsEqual (left right : Interleaving.Result P A D) : Bool :=
  match left, right with
  | .refused lr lw _, .refused rr rw _ => decide (lr = rr) && Parallel.worldEq lw rw
  | .executed _ l, .executed _ r => Parallel.worldEq l.world r.world &&
      decide (l.left.observe = r.left.observe) && decide (l.right.observe = r.right.observe)
  | _, _ => false

def matchesParallel (result : Interleaving.Result P A D) (parallel : Parallel.Result P A D) :
    Bool :=
  match result, parallel with
  | .executed _ m, .executed joined => Parallel.worldEq m.world joined.world &&
      decide (m.left.observe = observeBranch joined.left) &&
      decide (m.right.observe = observeBranch joined.right)
  | _, _ => false

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem local_setLocal (m : Machine P A D) (b : BranchId) (l : LocalState P A D) :
    (m.setLocal b l).local b = l := by cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem setLocal_world (m : Machine P A D) (b : BranchId) (l : LocalState P A D) :
    (m.setLocal b l).world = m.world := by cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_toCursor (l : LocalState P A D) (w : World P A D) :
    observeBranch (l.toCursor w) = l.observe := rfl

theorem continueRun_append (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (s t : Schedule) :
    continueRun cfg boundaries left right m (s ++ t) =
      continueRun cfg boundaries left right (continueRun cfg boundaries left right m s) t :=
  List.foldl_append

theorem matchesParallel_iff (schedule : Schedule) (m : Machine P A D)
    (joined : Parallel.Joined P A D) :
    matchesParallel (.executed schedule m) (.executed joined) = true ↔
      ProjectedEquivalent m joined := by
  simp [matchesParallel, ProjectedEquivalent, Parallel.worldEq, Parallel.WorldEquivalent, and_assoc]

end DefiKernel.Interleaving

## END FILE

## FILE lean/DefiKernel/Interleaving/Interference.lean

Original SHA256: e6bc0a1ffbceebb27973d547f2d3b808bc15d6c857e03644c9fa5eeb54ecef90; bytes: 4623; rendered SHA256: e6bc0a1ffbceebb27973d547f2d3b808bc15d6c857e03644c9fa5eeb54ecef90

import DefiKernel.Interleaving.LocalOrder

/-! Initialized rely/guarantee reasoning over actual shared-world executions. Local obligations
quantify over arbitrary histories and worlds; they never assume the peer invariant or run result. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

abbrev LedgerPredicate (P A D : Type) := State P A D → Prop
abbrev LedgerRelation (P A D : Type) := State P A D → State P A D → Prop

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Each branch proves its own invariant and guarantee from its own invariant alone. -/
def LocalObligation (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (invariant : BranchId → LedgerPredicate P A D)
    (guarantee : BranchId → LedgerRelation P A D) : Prop :=
  ∀ b index inv, (selectBranch left right b)[index]? = some inv →
    ∀ history pre result, invariant b pre.state →
      StepSound cfg (boundaries b index) index history (.invoke inv) pre result →
      invariant b result.world.state ∧ guarantee b pre.state result.world.state

def CrossInclusion (guarantee rely : BranchId → LedgerRelation P A D) : Prop :=
  ∀ b peer, b ≠ peer → ∀ pre post, guarantee b pre post → rely peer pre post

def Stable (invariant : BranchId → LedgerPredicate P A D)
    (rely : BranchId → LedgerRelation P A D) : Prop :=
  ∀ b pre post, invariant b pre → rely b pre post → invariant b post

-- BEGIN PROOFS

theorem Reachable.two_invariants {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m)
    (invariant : BranchId → LedgerPredicate P A D)
    (guarantee rely : BranchId → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries left right invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) :
    ∀ b, invariant b m.world.state := by
  induction h with
  | start => exact initialized
  | next b previous step ih =>
    cases step with
    | halted => simpa only [skip_world] using ih
    | exhausted => simpa only [skip_world] using ih
    | refused => simpa only [refuse_world] using ih
    | accepted inv result active selected executed =>
      have index := previous.attempt_index b active inv selected
      have selected' : (selectBranch left right b)[_]? = some inv := selected
      rw [← index] at selected'
      have own := localObligation b _ inv selected' _ _ _ (ih b)
        (executeStep_sound _ _ _ _ _ _ _ executed)
      intro other
      change invariant other result.world.state
      by_cases same : b = other
      · subst other
        exact own.1
      · exact stable other _ _ (ih other) (cross b other same _ _ own.2)

theorem runPrefix_two_invariants (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule)
    (invariant : BranchId → LedgerPredicate P A D)
    (guarantee rely : BranchId → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries left right invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) :
    ∀ b, invariant b (runPrefix cfg boundaries initial left right schedule).world.state :=
  (runPrefix_reachable cfg boundaries initial left right schedule).two_invariants
    invariant guarantee rely initialized localObligation cross stable

/-- Any supplied finite prefix retains both initialized invariants, including stopped branches. -/
theorem every_prefix_two_invariants (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule)
    (invariant : BranchId → LedgerPredicate P A D)
    (guarantee rely : BranchId → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries left right invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) (length : Nat) :
    ∀ b, invariant b
      (runPrefix cfg boundaries initial left right (schedule.take length)).world.state :=
  runPrefix_two_invariants cfg boundaries initial left right (schedule.take length)
    invariant guarantee rely initialized localObligation cross stable

end DefiKernel.Interleaving

## END FILE

## FILE lean/DefiKernel/Interleaving/LocalOrder.lean

Original SHA256: e81054de5ae998516bf0f9a3b9a0ce30ae24a41626b4f3b2c279571f663223be; bytes: 3045; rendered SHA256: e81054de5ae998516bf0f9a3b9a0ce30ae24a41626b4f3b2c279571f663223be

import DefiKernel.Interleaving.Soundness

/-! Active local indices count successful static slots. Exhausted internal tokens consume slots
without increasing the successful index; before any real attempt the two indices agree. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem AdvanceSound.active_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {m post : Machine P A D} {b : BranchId}
    (step : AdvanceSound cfg boundaries left right m b post)
    (previous : ∀ own, (m.local own).failure = none →
      (m.local own).nextIndex = min (m.local own).consumed
        (selectBranch left right own).length) :
    ∀ own, (post.local own).failure = none →
      (post.local own).nextIndex = min (post.local own).consumed
        (selectBranch left right own).length := by
  intro own active
  have hl := previous .left
  have hr := previous .right
  cases step with
  | halted failure failed =>
    cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.setLocal, Machine.local, selectBranch]
  | exhausted oldActive absent =>
    have hb := List.getElem?_eq_none_iff.mp absent
    cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.setLocal, Machine.local, selectBranch] <;> omega
  | refused inv reason oldActive selected rejected =>
    cases b <;> cases own <;>
      simp_all [Machine.refuse, Machine.setLocal, Machine.local, selectBranch]
  | accepted inv result oldActive selected executed =>
    obtain ⟨hb, _⟩ := List.getElem?_eq_some_iff.mp selected
    cases b <;> cases own <;>
      dsimp [Machine.accept, Machine.setLocal, Machine.local, selectBranch] at * <;>
      simp_all <;>
      have hb' := hb <;>
      simp only [Machine.local, selectBranch] at hb' <;> omega

theorem Reachable.active_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).failure = none →
      (m.local b).nextIndex = min (m.local b).consumed (selectBranch left right b).length := by
  induction h with
  | start => intro b; cases b <;> simp [Interleaving.start, Machine.local]
  | next b previous step ih => exact step.active_index ih

theorem Reachable.attempt_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (b : BranchId)
    (active : (m.local b).failure = none) (inv : Invocation P A D)
    (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv) :
    (m.local b).nextIndex = (m.local b).consumed := by
  obtain ⟨hb, _⟩ := List.getElem?_eq_some_iff.mp selected
  rw [h.active_index b active, min_eq_left (Nat.le_of_lt hb)]

end DefiKernel.Interleaving

## END FILE

## FILE lean/DefiKernel/Interleaving/Schedule.lean

Original SHA256: a531621726138ef20d1b45edf8c680869a4e35bee4697cfc93d80c250e2b6ad9; bytes: 8919; rendered SHA256: a531621726138ef20d1b45edf8c680869a4e35bee4697cfc93d80c250e2b6ad9

import DefiKernel.Parallel.Compatibility

/-! Complete finite schedules and ordered structural admission. Overlapping footprints are
admitted here; compatibility remains a separate premise for disjoint recovery. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

abbrev Schedule := List BranchId

structure ScheduleMismatch where
  expectedLeft : Nat
  observedLeft : Nat
  expectedRight : Nat
  observedRight : Nat
  deriving DecidableEq, Repr

def checkSchedule (leftLength rightLength : Nat) (schedule : Schedule) :
    Except ScheduleMismatch (PUnit : Type) :=
  if schedule.count .left = leftLength ∧ schedule.count .right = rightLength then .ok ⟨⟩
  else .error ⟨leftLength, schedule.count .left, rightLength, schedule.count .right⟩

def Complete {P A D : Type} (left right : Branch P A D) (schedule : Schedule) : Prop :=
  schedule.count .left = left.length ∧ schedule.count .right = right.length

inductive AdmissionFailure (P A D : Type) where
  | configuration
  | structural (branch : BranchId) (failure : Parallel.LocalFailure)
  | schedule (mismatch : ScheduleMismatch)
  deriving DecidableEq, Repr

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def admit (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) :
    Except (AdmissionFailure P A D) (Footprint P A D × Footprint P A D) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  let lf ← (analyzeBranch cfg (boundaries .left) left).mapError (.structural .left)
  let rf ← (analyzeBranch cfg (boundaries .right) right).mapError (.structural .right)
  let _ ← (checkSchedule left.length right.length schedule).mapError .schedule
  return (lf, rf)

-- BEGIN PROOFS

theorem checkSchedule_ok_iff (leftLength rightLength : Nat) (schedule : Schedule) :
    checkSchedule leftLength rightLength schedule = .ok ⟨⟩ ↔
      schedule.count .left = leftLength ∧ schedule.count .right = rightLength := by
  simp [checkSchedule]

theorem checkSchedule_error_iff (leftLength rightLength : Nat) (schedule : Schedule)
    (mismatch : ScheduleMismatch) :
    checkSchedule leftLength rightLength schedule = .error mismatch ↔
      ¬ (schedule.count .left = leftLength ∧ schedule.count .right = rightLength) ∧
      mismatch = ⟨leftLength, schedule.count .left, rightLength, schedule.count .right⟩ := by
  by_cases h : schedule.count .left = leftLength ∧ schedule.count .right = rightLength
  · simp [checkSchedule, h]
  · simp only [checkSchedule, h, if_false, Except.error.injEq, not_false_eq_true, true_and]
    exact eq_comm

theorem count_sum_length (schedule : Schedule) :
    schedule.count .left + schedule.count .right = schedule.length := by
  induction schedule with
  | nil => rfl
  | cons branch schedule ih =>
    cases branch <;> simp at * <;> omega

theorem count_append (branch : BranchId) (first second : Schedule) :
    (first ++ second).count branch = first.count branch + second.count branch :=
  List.count_append

theorem count_left_cons (schedule : Schedule) :
    (BranchId.left :: schedule).count .left = schedule.count .left + 1 := by simp

theorem count_right_cons (schedule : Schedule) :
    (BranchId.right :: schedule).count .right = schedule.count .right + 1 := by simp

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.length {left right : Branch P A D} {schedule : Schedule}
    (h : Complete left right schedule) : schedule.length = left.length + right.length := by
  rw [← count_sum_length, h.1, h.2]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem complete_empty_iff (schedule : Schedule) :
    Complete ([] : Branch P A D) [] schedule ↔ schedule = [] := by
  constructor
  · intro h
    exact List.length_eq_zero_iff.mp h.length
  · rintro rfl
    exact ⟨rfl, rfl⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem complete_left_cons_iff (inv : Invocation P A D) (left right : Branch P A D)
    (schedule : Schedule) :
    Complete (inv :: left) right (.left :: schedule) ↔ Complete left right schedule := by
  simp [Complete]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem complete_right_cons_iff (inv : Invocation P A D) (left right : Branch P A D)
    (schedule : Schedule) :
    Complete left (inv :: right) (.right :: schedule) ↔ Complete left right schedule := by
  simp [Complete]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.prefix_counts {left right : Branch P A D} {preTokens suffix : Schedule}
    (h : Complete left right (preTokens ++ suffix)) :
    preTokens.count .left ≤ left.length ∧ preTokens.count .right ≤ right.length := by
  obtain ⟨hl, hr⟩ := h
  simp only [List.count_append] at hl hr
  omega

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.left_slot {left right : Branch P A D} {preTokens suffix : Schedule}
    (h : Complete left right (preTokens ++ .left :: suffix)) :
    preTokens.count .left < left.length := by
  have hl := h.1
  simp only [List.count_append, List.count_cons_self] at hl
  omega

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.right_slot {left right : Branch P A D} {preTokens suffix : Schedule}
    (h : Complete left right (preTokens ++ .right :: suffix)) :
    preTokens.count .right < right.length := by
  have hr := h.2
  simp only [List.count_append, List.count_cons_self] at hr
  omega

theorem admit_ok (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right schedule = .ok (lf, rf)) :
    validateCatalog cfg.registry cfg.catalog = true ∧
    analyzeBranch cfg (boundaries .left) left = .ok lf ∧
    analyzeBranch cfg (boundaries .right) right = .ok rf ∧ Complete left right schedule := by
  unfold admit at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · simp [throw, throwThe] at h
  rename_i hv
  split at h
  · contradiction
  rename_i l hl
  split at h
  · contradiction
  rename_i r hr
  split at h
  · contradiction
  rename_i token hc
  cases token
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Except.ok.inj h)
  have unmap {E F X : Type} (f : E → F) (x : Except E X) (v : X)
      (hx : x.mapError f = .ok v) : x = .ok v := by
    cases x <;> simp_all [Except.mapError]
  exact ⟨by simpa using hv, unmap _ _ _ hl, unmap _ _ _ hr,
    (checkSchedule_ok_iff _ _ _).mp (unmap _ _ _ hc)⟩

theorem admit_of_checks (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (hs : Complete left right schedule) :
    admit cfg boundaries left right schedule = .ok (lf, rf) := by
  simp [admit, hv, hl, hr, checkSchedule, hs.1, hs.2, Except.mapError,
    bind, Except.bind, pure, Except.pure]

theorem admit_of_parallel (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf))
    (hs : Complete left right schedule) :
    admit cfg boundaries left right schedule = .ok (lf, rf) := by
  obtain ⟨hv, hl, hr, _⟩ := Parallel.admit_ok cfg boundaries left right lf rf hp
  exact admit_of_checks cfg boundaries left right schedule lf rf hv hl hr hs

theorem admit_left_member (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right schedule = .ok (lf, rf))
    (n : Nat) (inv : Invocation P A D) (hi : left[n]? = some inv) :
    ∃ part, analyzeInvocation cfg (boundaries .left n) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ lf.reads) ∧ (∀ c ∈ part.writes, c ∈ lf.writes) := by
  have hl := (admit_ok cfg boundaries left right schedule lf rf h).2.1
  simpa using analyzeBranchFrom_member cfg (boundaries .left) 0 left lf hl n inv hi

theorem admit_right_member (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right schedule = .ok (lf, rf))
    (n : Nat) (inv : Invocation P A D) (hi : right[n]? = some inv) :
    ∃ part, analyzeInvocation cfg (boundaries .right n) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ rf.reads) ∧ (∀ c ∈ part.writes, c ∈ rf.writes) := by
  have hr := (admit_ok cfg boundaries left right schedule lf rf h).2.2.1
  simpa using analyzeBranchFrom_member cfg (boundaries .right) 0 right rf hr n inv hi

end DefiKernel.Interleaving

## END FILE

## FILE lean/DefiKernel/Interleaving/Soundness.lean

Original SHA256: f696f995190cd7a6729e536efe1cc7875239625de1070d830c0649061e432337; bytes: 10494; rendered SHA256: f696f995190cd7a6729e536efe1cc7875239625de1070d830c0649061e432337

import DefiKernel.Interleaving.Execution

/-! Reachability witnesses for actual attempts, including refused calls at their original
pre-world. The final world may subsequently change through successful peer invocations. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

inductive AdvanceSound (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) : Machine P A D → Prop
  | halted (failure : LocatedFailure P A D) (failed : (m.local b).failure = some failure) :
      AdvanceSound cfg boundaries left right m b (m.skip b)
  | exhausted (active : (m.local b).failure = none)
      (absent : (selectBranch left right b)[(m.local b).consumed]? = none) :
      AdvanceSound cfg boundaries left right m b (m.skip b)
  | refused (inv : Invocation P A D) (reason : Composition.Failure)
      (active : (m.local b).failure = none)
      (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv)
      (rejected : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
        (m.local b).outputs (.invoke inv) m.world = .error reason) :
      AdvanceSound cfg boundaries left right m b (m.refuse b inv reason)
  | accepted (inv : Invocation P A D) (result : StepResult P A D)
      (active : (m.local b).failure = none)
      (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv)
      (executed : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
        (m.local b).outputs (.invoke inv) m.world = .ok result) :
      AdvanceSound cfg boundaries left right m b (m.accept b inv result)

inductive Reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (initial : World P A D) : Machine P A D → Prop
  | start : Reachable cfg boundaries left right initial (Interleaving.start initial)
  | next {pre post : Machine P A D} (b : BranchId)
      (previous : Reachable cfg boundaries left right initial pre)
      (step : AdvanceSound cfg boundaries left right pre b post) :
      Reachable cfg boundaries left right initial post

def AttemptSound (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (attempt : Attempt P A D) : Prop :=
  ∃ history, executeStep cfg (boundaries attempt.branch attempt.index) attempt.index history
    (.invoke attempt.invocation) attempt.before = attempt.outcome

-- BEGIN PROOFS

theorem advance_sound (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) :
    AdvanceSound cfg boundaries left right m b (advance cfg boundaries left right m b) := by
  cases hf : (m.local b).failure with
  | some failure =>
    simpa [advance, hf] using AdvanceSound.halted (cfg := cfg) (boundaries := boundaries)
      (left := left) (right := right) (m := m) (b := b) failure hf
  | none =>
    cases hs : (selectBranch left right b)[(m.local b).consumed]? with
    | none =>
      simpa [advance, hf, hs] using AdvanceSound.exhausted (cfg := cfg)
        (boundaries := boundaries) (left := left) (right := right) (m := m) (b := b) hf hs
    | some inv =>
      cases he : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
          (m.local b).outputs (.invoke inv) m.world with
      | error reason =>
        simpa [advance, hf, hs, he] using AdvanceSound.refused (cfg := cfg)
          (boundaries := boundaries) (left := left) (right := right) (m := m) (b := b)
          inv reason hf hs he
      | ok result =>
        simpa [advance, hf, hs, he] using AdvanceSound.accepted (cfg := cfg)
          (boundaries := boundaries) (left := left) (right := right) (m := m) (b := b)
          inv result hf hs he

theorem continueRun_reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (initial : World P A D) (m : Machine P A D)
    (h : Reachable cfg boundaries left right initial m) (schedule : Schedule) :
    Reachable cfg boundaries left right initial
      (continueRun cfg boundaries left right m schedule) := by
  induction schedule generalizing m with
  | nil => exact h
  | cons b tail ih =>
    exact ih _ (.next b h (advance_sound cfg boundaries left right m b))

theorem runPrefix_reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) :
    Reachable cfg boundaries left right initial
      (runPrefix cfg boundaries initial left right schedule) :=
  continueRun_reachable cfg boundaries left right initial (start initial) .start schedule

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem skip_world (m : Machine P A D) (b : BranchId) : (m.skip b).world = m.world := by
  cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem refuse_world (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (reason : Composition.Failure) : (m.refuse b inv reason).world = m.world := by
  cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem accept_world (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (result : StepResult P A D) : (m.accept b inv result).world = result.world := rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem skip_attempts (m : Machine P A D) (b : BranchId) :
    (m.skip b).attempts = m.attempts := by cases b <;> rfl

theorem AdvanceSound.store {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) :
    post.world.capabilities = m.world.capabilities := by
  cases h with
  | halted => rw [skip_world]
  | exhausted => rw [skip_world]
  | refused => rw [refuse_world]
  | accepted inv result active selected executed =>
    exact (executeStep_sound _ _ _ _ _ _ _ executed).invoke_preserves_capabilities

theorem Reachable.store {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    m.world.capabilities = initial.capabilities := by
  induction h with
  | start => rfl
  | next b previous step ih => exact step.store.trans ih

theorem AdvanceSound.attempts {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post)
    (previous : ∀ attempt ∈ m.attempts, AttemptSound cfg boundaries attempt) :
    ∀ attempt ∈ post.attempts, AttemptSound cfg boundaries attempt := by
  cases h with
  | halted => simpa [skip_attempts] using previous
  | exhausted => simpa [skip_attempts] using previous
  | refused inv reason active selected rejected =>
    intro attempt member
    simp only [Machine.refuse, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact ⟨_, rejected⟩
  | accepted inv result active selected executed =>
    intro attempt member
    simp only [Machine.accept, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact ⟨_, executed⟩

theorem Reachable.attempts {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ attempt ∈ m.attempts, AttemptSound cfg boundaries attempt := by
  induction h with
  | start => simp [Interleaving.start]
  | next b previous step ih => exact step.attempts ih

theorem AdvanceSound.consumed {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) (own : BranchId) :
    (post.local own).consumed =
      (m.local own).consumed + if b = own then 1 else 0 := by
  cases h <;> cases b <;> cases own <;>
    simp [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem advance_consumed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b own : BranchId) :
    ((advance cfg boundaries left right m b).local own).consumed =
      (m.local own).consumed + if b = own then 1 else 0 :=
  (advance_sound cfg boundaries left right m b).consumed own

theorem continueRun_consumed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (schedule : Schedule) (b : BranchId) :
    ((continueRun cfg boundaries left right m schedule).local b).consumed =
      (m.local b).consumed + schedule.count b := by
  induction schedule generalizing m with
  | nil => simp [continueRun]
  | cons next tail ih =>
    rw [show continueRun cfg boundaries left right m (next :: tail) =
      continueRun cfg boundaries left right
        (advance cfg boundaries left right m next) tail from rfl]
    rw [ih, advance_consumed]
    by_cases h : next = b <;> simp [h, Nat.add_assoc, Nat.add_comm]

theorem runPrefix_consumed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) (b : BranchId) :
    ((runPrefix cfg boundaries initial left right schedule).local b).consumed =
      schedule.count b := by
  rw [runPrefix, continueRun_consumed]
  cases b <;> simp [Interleaving.start, Machine.local]

theorem runPrefix_complete_counts (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (h : Complete left right schedule) :
    (runPrefix cfg boundaries initial left right schedule).left.consumed = left.length ∧
    (runPrefix cfg boundaries initial left right schedule).right.consumed = right.length := by
  exact ⟨(runPrefix_consumed cfg boundaries initial left right schedule .left).trans h.1,
    (runPrefix_consumed cfg boundaries initial left right schedule .right).trans h.2⟩

end DefiKernel.Interleaving

## END FILE

## FILE lean/DefiKernel/Metatheory/Audit.lean

Original SHA256: e9a7907a2e9f85427f15d22559a87322f31a5646c8b79d2148944f313aeb8d7a; bytes: 636; rendered SHA256: e9a7907a2e9f85427f15d22559a87322f31a5646c8b79d2148944f313aeb8d7a

import DefiKernel.Metatheory.Tests

namespace DefiKernel.Metatheory.Audit

def main : IO Unit := do
  let checks := Tests.runtimeChecks
  if checks.isEmpty then throw (IO.userError "Metatheory runtime comparisons empty")
  if !(checks.map Prod.fst).Nodup then
    throw (IO.userError "Metatheory runtime comparison names are duplicated")
  for (name, passed) in checks do IO.println s!"{name}: {passed}"
  let failures := checks.filter (!·.2) |>.map Prod.fst
  if !failures.isEmpty then
    throw (IO.userError s!"Metatheory runtime comparisons failed: {failures.length}")

#eval main

-- BEGIN PROOFS

end DefiKernel.Metatheory.Audit

## END FILE

## FILE lean/DefiKernel/Metatheory/Configuration.lean

Original SHA256: d5bc155b46922606f765b2e9cd80b5d33d4b542b8cd6a39a3cb790f87776dce5; bytes: 12353; rendered SHA256: d5bc155b46922606f765b2e9cd80b5d33d4b542b8cd6a39a3cb790f87776dce5

import DefiKernel.Composition.Sequence
import DefiKernel.Parallel.Dependency.Adapter

/-! Explicit sufficient configuration premises for exact execution. Types and instances are shared
binders; support is a proposition, not a certificate checker. No execution equality is assumed. -/
namespace DefiKernel.Metatheory
open Typed Composition Parallel

structure ReferenceSet where
  calls : Set (ComponentId × OperationId)
  operations : Set OperationId

def ReferenceSet.union (a b : ReferenceSet) : ReferenceSet :=
  ⟨a.calls ∪ b.calls, a.operations ∪ b.operations⟩

def SupportedStep {P A D : Type} (refs : ReferenceSet) : Step P A D → Prop
  | .invoke inv => (inv.component, inv.operation) ∈ refs.calls ∧ inv.operation ∈ refs.operations
  | .issue grant => grant.operation ∈ refs.operations
  | .revoke _ => True

def SupportedList {P A D : Type} (refs : ReferenceSet) (steps : List (Step P A D)) : Prop :=
  ∀ step ∈ steps, SupportedStep refs step

def SupportedBranch {P A D : Type} (refs : ReferenceSet) (branch : Branch P A D) : Prop :=
  ∀ inv ∈ branch, SupportedStep refs (.invoke inv)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

structure ConfigAgreement (old new : Config P A D) (refs : ReferenceSet) : Prop where
  old_valid : validateCatalog old.registry old.catalog = true
  new_valid : validateCatalog new.registry new.catalog = true
  registry : ∀ op ∈ refs.operations, old.registry op = new.registry op
  lookup : ∀ component op, (component, op) ∈ refs.calls →
    lookupOperation old.catalog component op = lookupOperation new.catalog component op
  domainAdmin : ∀ domain, old.domainAdmin domain = new.domainAdmin domain

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
@[simp] theorem supportedList_nil (refs : ReferenceSet) :
    SupportedList (P := P) (A := A) (D := D) refs [] := by simp [SupportedList]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
@[simp] theorem supportedList_cons (refs : ReferenceSet) (step : Step P A D) (steps) :
    SupportedList refs (step :: steps) ↔ SupportedStep refs step ∧ SupportedList refs steps := by
  simp [SupportedList]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
@[simp] theorem supportedList_append (refs : ReferenceSet) (a b : List (Step P A D)) :
    SupportedList refs (a ++ b) ↔ SupportedList refs a ∧ SupportedList refs b := by
  simp [SupportedList, or_imp, forall_and]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
@[simp] theorem supportedBranch_nil (refs : ReferenceSet) :
    SupportedBranch (P := P) (A := A) (D := D) refs [] := by simp [SupportedBranch]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
@[simp] theorem supportedBranch_cons (refs : ReferenceSet) (inv : Invocation P A D) (tail) :
    SupportedBranch refs (inv :: tail) ↔
      SupportedStep refs (.invoke inv) ∧ SupportedBranch refs tail := by
  simp [SupportedBranch]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
@[simp] theorem supportedBranch_map (refs : ReferenceSet) (branch : Branch P A D) :
    SupportedList refs (branch.map Step.invoke) ↔ SupportedBranch refs branch := by
  simp [SupportedList, SupportedBranch]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem SupportedStep.union_left {refs other : ReferenceSet} {step : Step P A D}
    (h : SupportedStep refs step) : SupportedStep (refs.union other) step := by
  cases step with
  | invoke inv => exact ⟨Or.inl h.1, Or.inl h.2⟩
  | issue grant => exact Or.inl h
  | revoke id => trivial

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem SupportedStep.union_right {refs other : ReferenceSet} {step : Step P A D}
    (h : SupportedStep other step) : SupportedStep (refs.union other) step := by
  cases step with
  | invoke inv => exact ⟨Or.inr h.1, Or.inr h.2⟩
  | issue grant => exact Or.inr h
  | revoke id => trivial

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem SupportedList.union_left {refs other : ReferenceSet} {steps : List (Step P A D)}
    (h : SupportedList refs steps) : SupportedList (refs.union other) steps :=
  fun step hs ↦ (h step hs).union_left

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem SupportedList.union_right {refs other : ReferenceSet} {steps : List (Step P A D)}
    (h : SupportedList other steps) : SupportedList (refs.union other) steps :=
  fun step hs ↦ (h step hs).union_right

theorem ConfigAgreement.refl (cfg : Config P A D) (refs : ReferenceSet)
    (valid : validateCatalog cfg.registry cfg.catalog = true) : ConfigAgreement cfg cfg refs :=
  ⟨valid, valid, fun _ _ ↦ rfl, fun _ _ _ ↦ rfl, fun _ ↦ rfl⟩

theorem ConfigAgreement.symm {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) : ConfigAgreement new old refs :=
  ⟨h.new_valid, h.old_valid, fun op ho ↦ (h.registry op ho).symm,
    fun c op ho ↦ (h.lookup c op ho).symm, fun d ↦ (h.domainAdmin d).symm⟩

theorem ConfigAgreement.trans {a b c : Config P A D} {refs : ReferenceSet}
    (hab : ConfigAgreement a b refs) (hbc : ConfigAgreement b c refs) :
    ConfigAgreement a c refs :=
  ⟨hab.old_valid, hbc.new_valid, fun op ho ↦ (hab.registry op ho).trans (hbc.registry op ho),
    fun c op ho ↦ (hab.lookup c op ho).trans (hbc.lookup c op ho),
    fun d ↦ (hab.domainAdmin d).trans (hbc.domainAdmin d)⟩

theorem ConfigAgreement.union {old new : Config P A D} {a b : ReferenceSet}
    (ha : ConfigAgreement old new a) (hb : ConfigAgreement old new b) :
    ConfigAgreement old new (a.union b) := by
  refine ⟨ha.old_valid, ha.new_valid, ?_, ?_, ha.domainAdmin⟩
  · intro op ho
    exact ho.elim (ha.registry op) (hb.registry op)
  · intro c op ho
    exact ho.elim (ha.lookup c op) (hb.lookup c op)

theorem ConfigAgreement.restrict {old new : Config P A D} {a b : ReferenceSet}
    (h : ConfigAgreement old new b) (calls : a.calls ⊆ b.calls)
    (operations : a.operations ⊆ b.operations) : ConfigAgreement old new a :=
  ⟨h.old_valid, h.new_valid, fun op ho ↦ h.registry op (operations ho),
    fun c op ho ↦ h.lookup c op (calls ho), h.domainAdmin⟩

theorem prepareInvocation_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (inv : Invocation P A D)
    (supported : SupportedStep refs (.invoke inv)) :
    prepareInvocation old boundary index history inv =
      prepareInvocation new boundary index history inv := by
  unfold prepareInvocation
  rw [h.lookup inv.component inv.operation supported.1, h.registry inv.operation supported.2]

theorem issueCapability_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (ctx : InvocationContext P D)
    (store : CapabilityStore P A D) (grant : Grant P A D)
    (supported : SupportedStep refs (.issue grant)) :
    issueCapability old.authority ctx store grant =
      issueCapability new.authority ctx store grant := by
  simp only [issueCapability, isDomainAdmin, Config.authority, registryAuthorityConfig,
    h.domainAdmin, h.registry grant.operation supported]
  rfl

theorem revokeCapability_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (ctx : InvocationContext P D)
    (store : CapabilityStore P A D) (id : CapabilityId) :
    revokeCapability old.authority ctx store id = revokeCapability new.authority ctx store id := by
  simp only [revokeCapability, isDomainAdmin, Config.authority, registryAuthorityConfig,
    h.domainAdmin]
  rfl

variable [Fintype P] [Fintype A] [Fintype D]

theorem typed_execute_registry_eq (old new : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat) (request : Request P A D)
    (state : State P A D) (h : old request.operation = new request.operation) :
    Typed.execute old store ctx env now request state =
      Typed.execute new store ctx env now request state := by
  unfold Typed.execute
  rw [h]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem extractReceipt_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundary : Boundary P A D)
    (request : Request P A D) (pre : World P A D)
    (supported : request.operation ∈ refs.operations) :
    extractReceipt old boundary request pre = extractReceipt new boundary request pre := by
  unfold extractReceipt
  rw [h.registry request.operation supported]

/-- Equality follows every actual branch, including preparation, extraction and admin refusals. -/
theorem executeStep_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (step : Step P A D) (pre : World P A D)
    (supported : SupportedStep refs step) :
    executeStep old boundary index history step pre =
      executeStep new boundary index history step pre := by
  cases step with
  | invoke inv =>
    simp only [executeStep, h.old_valid, h.new_valid, Bool.not_true, Bool.false_eq_true,
      ↓reduceIte, bind, Except.bind]
    rw [prepareInvocation_config_eq h boundary index history inv supported]
    cases hp : prepareInvocation new boundary index history inv with
    | error reason => rfl
    | ok pair =>
      rcases pair with ⟨iface, request⟩
      have hop :=
        (Parallel.prepareInvocation_shape new boundary index history inv iface request hp).1
      have hs : request.operation ∈ refs.operations := hop ▸ supported.2
      simp only []
      rw [typed_execute_registry_eq old.registry new.registry pre.capabilities boundary.ctx
        boundary.env boundary.now request pre.state (h.registry request.operation hs)]
      rw [extractReceipt_config_eq h boundary request pre hs]
  | issue grant =>
    simp only [executeStep, h.old_valid, h.new_valid, Bool.not_true, Bool.false_eq_true,
      ↓reduceIte, bind, Except.bind, issueCapability_config_eq h boundary.ctx pre.capabilities grant
        supported]
  | revoke id =>
    simp only [executeStep, h.old_valid, h.new_valid, Bool.not_true, Bool.false_eq_true,
      ↓reduceIte, bind, Except.bind, revokeCapability_config_eq h boundary.ctx pre.capabilities id]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem startCursor_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (world : World P A D) :
    startCursor old world = startCursor new world := by
  simp only [startCursor, h.old_valid, h.new_valid]

theorem advance_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (step : Step P A D) (supported : SupportedStep refs step) :
    Composition.advance old boundaries cursor step =
      Composition.advance new boundaries cursor step := by
  unfold Composition.advance
  rw [executeStep_config_eq h (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
    step cursor.world supported]

theorem continueRun_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (steps : List (Step P A D)) (supported : SupportedList refs steps) :
    Composition.continueRun old boundaries cursor steps =
      Composition.continueRun new boundaries cursor steps := by
  induction steps generalizing cursor with
  | nil => rfl
  | cons step steps ih =>
    obtain ⟨head, tail⟩ := (supportedList_cons refs step steps).mp supported
    simpa only [Composition.continueRun, List.foldl_cons,
      advance_config_eq h boundaries cursor step head] using
        ih (Composition.advance new boundaries cursor step) tail

theorem run_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : Nat → Boundary P A D)
    (world : World P A D) (steps : List (Step P A D)) (supported : SupportedList refs steps) :
    Composition.run old boundaries world steps = Composition.run new boundaries world steps := by
  unfold Composition.run
  rw [startCursor_config_eq h, continueRun_config_eq h boundaries _ steps supported]

end DefiKernel.Metatheory

## END FILE

## FILE lean/DefiKernel/Metatheory/ConfigurationFixtures.lean

Original SHA256: 27c90bf498c63ebae4f583c2ba7f90b1221d6e3bc2b572fef8cd97d827b2a52e; bytes: 9816; rendered SHA256: 27c90bf498c63ebae4f583c2ba7f90b1221d6e3bc2b572fef8cd97d827b2a52e

import DefiKernel.Metatheory.ConfigurationGroups
import DefiKernel.Metatheory.OperatorLifting
import DefiKernel.Metatheory.Examples
import DefiKernel.Metatheory.OperatorFixtures

/-! Concrete extension witnesses. This proof-only module is excluded from runtime test imports.
The operator witnesses retain arbitrary boundaries, schedules and atomic policy; they do not
assert that every such input is admitted or succeeds. -/
namespace DefiKernel.Metatheory.ConfigurationFixtures
open Typed Composition Parallel
open DefiKernel.Metatheory.Examples

def references : ReferenceSet := ⟨{(⟨0⟩, ⟨10⟩)}, {⟨10⟩}⟩
def mainGroup : SeqGroup P A D :=
  .seq (.step (.invoke draw7)) (.seq (.step (.invoke consume3)) (.step (.invoke return1)))
def administrationGroup : SeqGroup P A D :=
  .seq (.step (.issue grantInvoke))
    (.seq (.step (.invoke adminMove))
      (.seq (.step (.revoke ⟨1⟩)) (.step (.invoke adminMove))))
def leftBranch : Branch P A D := [draw7, refuse6]
def rightBranch : Branch P A D := [return1]
def atomicReferences : ReferenceSet :=
  ⟨{(⟨100⟩, ⟨100⟩), (⟨101⟩, ⟨101⟩), (⟨108⟩, ⟨108⟩)}, {⟨100⟩, ⟨101⟩, ⟨108⟩}⟩

-- BEGIN PROOFS

/-- Changing the output declaration keeps the complete registry, not just one lookup. -/
theorem changedOutput_registry_remaining : cfg.registry = changedOutput.registry := rfl

theorem changedAdmin_registry_remaining : cfg.registry = changedAdmin.registry := rfl

theorem grantOnly_catalog_remaining : grantOnlyCfg.catalog = grantOnlyChanged.catalog := rfl

/-- The grant-only domain change preserves the invoked operation; operation 77 differs. -/
theorem grantOnly_invoked_registry_remaining :
    grantOnlyCfg.registry ⟨10⟩ = grantOnlyChanged.registry ⟨10⟩ := rfl

theorem changedRegistry_admins_remaining (domain : D) :
    cfg.domainAdmin domain = changedRegistry.domainAdmin domain := rfl

theorem changedOutput_admins_remaining (domain : D) :
    cfg.domainAdmin domain = changedOutput.domainAdmin domain := rfl

theorem grantOnly_admins_remaining (domain : D) :
    grantOnlyCfg.domainAdmin domain = grantOnlyChanged.domainAdmin domain := rfl

theorem atomic_extension_agreement :
    ConfigAgreement Atomic.Examples.atomCfg OperatorFixtures.extendedAtomic atomicReferences := by
  refine ⟨by decide, by decide, ?_, ?_, fun _ ↦ rfl⟩
  · intro op hop
    simp only [atomicReferences, Set.mem_insert_iff, Set.mem_singleton_iff] at hop
    rcases hop with rfl | rfl | rfl <;> rfl
  · intro component op hop
    simp only [atomicReferences, Set.mem_insert_iff, Set.mem_singleton_iff] at hop
    rcases hop with h | h | h <;> cases h <;> rfl

theorem atomic_draw_supported (q : ℚ) :
    SupportedStep atomicReferences (.invoke (Atomic.Examples.draw q)) := by
  exact ⟨Or.inl rfl, Or.inl rfl⟩

theorem atomic_repay_supported (q : ℚ) :
    SupportedStep atomicReferences (.invoke (Atomic.Examples.repay q)) := by
  exact ⟨Or.inr (Or.inl rfl), Or.inr (Or.inl rfl)⟩

theorem atomic_mint_supported :
    SupportedStep atomicReferences (.invoke Atomic.Examples.mintUSD) := by
  exact ⟨Or.inr (Or.inr rfl), Or.inr (Or.inr rfl)⟩

theorem atomic_settlement_branch_supported (q : ℚ) :
    SupportedBranch atomicReferences [Atomic.Examples.draw 7, Atomic.Examples.repay q] := by
  simp only [supportedBranch_cons, supportedBranch_nil, and_true]
  exact ⟨atomic_draw_supported _, atomic_repay_supported _⟩

theorem atomic_supply_branch_supported :
    SupportedBranch atomicReferences [Atomic.Examples.mintUSD] := by
  simp only [supportedBranch_cons, supportedBranch_nil, and_true]
  exact atomic_mint_supported

/-- Both exact repayment and the residual-bearing underpayment fixture use this agreement. -/
theorem atomic_settlement_extension (under : Bool) :
    OperatorFixtures.settleRun Atomic.Examples.atomCfg under =
      OperatorFixtures.settleRun OperatorFixtures.extendedAtomic under :=
  runAtomic_config_eq atomic_extension_agreement Atomic.Examples.atomBoundary 74
    Atomic.Examples.basePolicy Atomic.Examples.atomInitial _ [] [.left, .left]
    (atomic_settlement_branch_supported _) (supportedBranch_nil _)

/-- The actual supply-aborting input has an instantiated sufficient configuration premise. -/
theorem atomic_supply_extension :
    Atomic.runAtomic Atomic.Examples.atomCfg Atomic.Examples.atomBoundary 75
        Atomic.Examples.basePolicy Atomic.Examples.atomInitial
        [Atomic.Examples.mintUSD] [] [.left] =
      Atomic.runAtomic OperatorFixtures.extendedAtomic Atomic.Examples.atomBoundary 75
        Atomic.Examples.basePolicy Atomic.Examples.atomInitial
        [Atomic.Examples.mintUSD] [] [.left] :=
  runAtomic_config_eq atomic_extension_agreement Atomic.Examples.atomBoundary 75
    Atomic.Examples.basePolicy Atomic.Examples.atomInitial _ [] [.left]
    atomic_supply_branch_supported (supportedBranch_nil _)

theorem extension_agreement : ConfigAgreement cfg extendedCfg references := by
  refine ⟨by decide, by decide, ?_, ?_, fun _ ↦ rfl⟩
  · intro op hop
    have heq : op = ⟨10⟩ := hop
    subst op
    rfl
  · intro component op hop
    have heq : (component, op) = (⟨0⟩, ⟨10⟩) := hop
    cases heq
    rfl

theorem movement_supported (q : ℚ) (recipient : P) (ids : List CapabilityId) :
    SupportedStep references (.invoke (movement q recipient ids)) := by
  exact ⟨rfl, rfl⟩

theorem draw7_supported : SupportedStep references (.invoke draw7) := by
  exact ⟨rfl, rfl⟩

theorem consume3_supported : SupportedStep references (.invoke consume3) := by
  exact ⟨rfl, rfl⟩

theorem return1_supported : SupportedStep references (.invoke return1) := by
  exact ⟨rfl, rfl⟩

theorem refuse6_supported : SupportedStep references (.invoke refuse6) := by
  exact ⟨rfl, rfl⟩

theorem adminMove_supported : SupportedStep references (.invoke adminMove) := by
  exact ⟨rfl, rfl⟩

theorem grantInvoke_supported : SupportedStep references (.issue grantInvoke) := by rfl

theorem revoke_supported (id : CapabilityId) :
    SupportedStep (P := P) (A := A) (D := D) references (.revoke id) := by trivial

theorem mainGroup_supported : SupportedGroup references mainGroup := by
  simp only [mainGroup, supportedGroup_seq, supportedGroup_step]
  exact ⟨draw7_supported, consume3_supported, return1_supported⟩

theorem administrationGroup_supported : SupportedGroup references administrationGroup := by
  simp only [administrationGroup, supportedGroup_seq, supportedGroup_step]
  exact ⟨grantInvoke_supported, adminMove_supported, revoke_supported _, adminMove_supported⟩

theorem leftBranch_supported : SupportedBranch references leftBranch := by
  simp only [leftBranch, supportedBranch_cons, supportedBranch_nil, and_true]
  exact ⟨draw7_supported, refuse6_supported⟩

theorem rightBranch_supported : SupportedBranch references rightBranch := by
  simp only [rightBranch, supportedBranch_cons, supportedBranch_nil, and_true]
  exact return1_supported

/-- A nonempty output-consuming group preserves the entire actual cursor across extension. -/
theorem main_group_extension :
    runGroup cfg mainBoundary initial mainGroup =
      runGroup extendedCfg mainBoundary initial mainGroup :=
  runGroup_config_eq extension_agreement mainBoundary initial mainGroup mainGroup_supported

/-- The input cursor has history and index five; issuance, use and revocation continue it. -/
theorem administration_group_extension :
    runGroup cfg adminBoundary adminInitial administrationGroup =
      runGroup extendedCfg adminBoundary adminInitial administrationGroup :=
  runGroup_config_eq extension_agreement adminBoundary adminInitial administrationGroup
    administrationGroup_supported

theorem parallel_extension (boundaries : ParallelBoundary P A D) :
    runParallel cfg boundaries initial.world leftBranch rightBranch =
      runParallel extendedCfg boundaries initial.world leftBranch rightBranch :=
  runParallel_config_eq extension_agreement boundaries initial.world leftBranch rightBranch
    leftBranch_supported rightBranch_supported

theorem serialLR_extension (boundaries : ParallelBoundary P A D) :
    runSerialLR cfg boundaries initial.world leftBranch rightBranch =
      runSerialLR extendedCfg boundaries initial.world leftBranch rightBranch :=
  runSerialLR_config_eq extension_agreement boundaries initial.world leftBranch rightBranch
    leftBranch_supported rightBranch_supported

theorem serialRL_extension (boundaries : ParallelBoundary P A D) :
    runSerialRL cfg boundaries initial.world leftBranch rightBranch =
      runSerialRL extendedCfg boundaries initial.world leftBranch rightBranch :=
  runSerialRL_config_eq extension_agreement boundaries initial.world leftBranch rightBranch
    leftBranch_supported rightBranch_supported

theorem interleaving_extension (boundaries : ParallelBoundary P A D)
    (schedule : Interleaving.Schedule) :
    Interleaving.runInterleaving cfg boundaries initial.world leftBranch rightBranch schedule =
      Interleaving.runInterleaving extendedCfg boundaries initial.world
        leftBranch rightBranch schedule :=
  runInterleaving_config_eq extension_agreement boundaries initial.world leftBranch rightBranch
    schedule leftBranch_supported rightBranch_supported

theorem atomic_extension (boundaries : ParallelBoundary P A D) (label : Nat)
    (policy : Atomic.Policy P A D) (schedule : Interleaving.Schedule) :
    Atomic.runAtomic cfg boundaries label policy initial.world leftBranch rightBranch schedule =
      Atomic.runAtomic extendedCfg boundaries label policy initial.world
        leftBranch rightBranch schedule :=
  runAtomic_config_eq extension_agreement boundaries label policy initial.world leftBranch
    rightBranch schedule leftBranch_supported rightBranch_supported

end DefiKernel.Metatheory.ConfigurationFixtures

## END FILE

## FILE lean/DefiKernel/Metatheory/ConfigurationGroups.lean

Original SHA256: 04b7f23b0b74b30f0010d59e716f3aead7884f2d8ac9b9885a5143be0fe4fe31; bytes: 2338; rendered SHA256: 04b7f23b0b74b30f0010d59e716f3aead7884f2d8ac9b9885a5143be0fe4fe31

import DefiKernel.Metatheory.Configuration
import DefiKernel.Metatheory.SequentialGroups

/-! Full static group support and configuration lifting through actual recursive simulation. -/
namespace DefiKernel.Metatheory
open Typed Composition

def SupportedGroup {P A D : Type} (refs : ReferenceSet) (group : SeqGroup P A D) : Prop :=
  SupportedList refs (flatten group)

-- BEGIN PROOFS

variable {P A D : Type}

@[simp] theorem supportedGroup_empty (refs : ReferenceSet) :
    SupportedGroup (P := P) (A := A) (D := D) refs .empty := by
  simp [SupportedGroup, flatten]

@[simp] theorem supportedGroup_step (refs : ReferenceSet) (action : Step P A D) :
    SupportedGroup refs (.step action) ↔ SupportedStep refs action := by
  simp [SupportedGroup, flatten]

@[simp] theorem supportedGroup_seq (refs : ReferenceSet) (a b : SeqGroup P A D) :
    SupportedGroup refs (.seq a b) ↔ SupportedGroup refs a ∧ SupportedGroup refs b := by
  simp [SupportedGroup, flatten]

theorem SupportedGroup.union_left {refs other : ReferenceSet} {group : SeqGroup P A D}
    (h : SupportedGroup refs group) : SupportedGroup (refs.union other) group :=
  SupportedList.union_left h

theorem SupportedGroup.union_right {refs other : ReferenceSet} {group : SeqGroup P A D}
    (h : SupportedGroup other group) : SupportedGroup (refs.union other) group :=
  SupportedList.union_right h

theorem supportedGroup_union_seq {a b : ReferenceSet} {first second : SeqGroup P A D}
    (ha : SupportedGroup a first) (hb : SupportedGroup b second) :
    SupportedGroup (a.union b) (.seq first second) :=
  (supportedGroup_seq _ _ _).mpr ⟨ha.union_left, hb.union_right⟩

variable [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Both sides use the separately implemented recursive interpreter, not a new flat wrapper. -/
theorem runGroup_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (group : SeqGroup P A D) (supported : SupportedGroup refs group) :
    runGroup old boundaries cursor group = runGroup new boundaries cursor group := by
  rw [runGroup_eq_continueRun, runGroup_eq_continueRun]
  exact continueRun_config_eq h boundaries cursor (flatten group) supported

end DefiKernel.Metatheory

## END FILE

## FILE lean/DefiKernel/Metatheory/Contexts.lean

Original SHA256: 6c0539645086ffe51e3668621ca7fa08d7937b6d590c3d9b3c6c649c79eac743; bytes: 4009; rendered SHA256: 6c0539645086ffe51e3668621ca7fa08d7937b6d590c3d9b3c6c649c79eac743

import DefiKernel.Metatheory.Observation

/-! One-hole sequential contexts have fixed surrounding groups and cannot inspect diagnostics,
reset cursors, change configuration, add peers or insert atomic commit boundaries. -/
namespace DefiKernel.Metatheory
open Typed Composition

inductive SeqContext (P A D : Type) where
  | hole
  | before (fixed : SeqGroup P A D) (context : SeqContext P A D)
  | after (context : SeqContext P A D) (fixed : SeqGroup P A D)

def fill {P A D : Type} (context : SeqContext P A D) (group : SeqGroup P A D) :
    SeqGroup P A D :=
  match context with
  | .hole => group
  | .before fixed context => .seq fixed (fill context group)
  | .after context fixed => .seq (fill context group) fixed

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Equivalence quantifies over every pair of equivalent input cursors, including arbitrary
histories and existing failures. It is not equality at one particular entry state. -/
def GroupEquivalent (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (first second : SeqGroup P A D) : Prop :=
  ∀ left right, CursorEquivalent left right →
    CursorEquivalent (runGroup cfg boundaries left first) (runGroup cfg boundaries right second)

-- BEGIN PROOFS

theorem GroupEquivalent.refl (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (group : SeqGroup P A D) : GroupEquivalent cfg boundaries group group := by
  intro left right h
  exact runGroup_preserves cfg boundaries left right group h

theorem GroupEquivalent.symm {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {first second : SeqGroup P A D} (h : GroupEquivalent cfg boundaries first second) :
    GroupEquivalent cfg boundaries second first := by
  intro left right equivalent
  exact (h right left equivalent.symm).symm

theorem GroupEquivalent.trans {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {first middle last : SeqGroup P A D} (h : GroupEquivalent cfg boundaries first middle)
    (g : GroupEquivalent cfg boundaries middle last) :
    GroupEquivalent cfg boundaries first last := by
  intro left right equivalent
  exact (h left right equivalent).trans (g right right (CursorEquivalent.refl right))

/-- A fixed prefix uses universal-input equivalence at the actual returned prefix cursors;
a fixed suffix uses preservation after the substituted groups have run. -/
theorem GroupEquivalent.fill {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {first second : SeqGroup P A D} (h : GroupEquivalent cfg boundaries first second)
    (context : SeqContext P A D) :
    GroupEquivalent cfg boundaries (fill context first) (fill context second) := by
  induction context with
  | hole => exact h
  | before fixed context ih =>
    intro left right equivalent
    exact ih _ _ (runGroup_preserves cfg boundaries left right fixed equivalent)
  | after context fixed ih =>
    intro left right equivalent
    exact runGroup_preserves cfg boundaries _ _ fixed (ih left right equivalent)

theorem groupEquivalent_empty_left (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (group : SeqGroup P A D) : GroupEquivalent cfg boundaries (.seq .empty group) group := by
  intro left right h
  exact runGroup_preserves cfg boundaries left right group h

theorem groupEquivalent_empty_right (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (group : SeqGroup P A D) : GroupEquivalent cfg boundaries (.seq group .empty) group := by
  intro left right h
  exact runGroup_preserves cfg boundaries left right group h

theorem groupEquivalent_assoc (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (first second third : SeqGroup P A D) :
    GroupEquivalent cfg boundaries (.seq (.seq first second) third)
      (.seq first (.seq second third)) := by
  intro left right h
  rw [runGroup_assoc]
  exact runGroup_preserves cfg boundaries left right (.seq first (.seq second third)) h

end DefiKernel.Metatheory

## END FILE

## FILE lean/DefiKernel/Metatheory/Examples.lean

Original SHA256: 9474fefb56e4120ae8537d137a94a1bd6518612e654874794b27c1a8c770a8a9; bytes: 12780; rendered SHA256: 9474fefb56e4120ae8537d137a94a1bd6518612e654874794b27c1a8c770a8a9

import DefiKernel.Atomic.Examples

/-! Exact development fixtures. Carol is the opaque existing `pool` identity. Every expected
world, raw event and cursor below is constructed without invoking any execution or observer. -/
namespace DefiKernel.Metatheory.Examples
open Typed Composition Typed.Examples
open Parallel.Examples (cells cellRef packed evaluatedTransfer output)

abbrev P := Party
abbrev A := Asset
abbrev D := Domain
abbrev W := World P A D
abbrev C := Cell P A D
abbrev Cur := Cursor P A D
abbrev Inv := Invocation P A D
abbrev Action := Step P A D
abbrev RawEvent := Event P A D

/-- Fixture-only name: the pre-existing opaque pool ID denotes Carol here. -/
def carol : P := .pool
def aliceCell : C := (.main, .alice, .usd)
def bobCell : C := (.main, .bob, .usd)
def carolCell : C := (.main, carol, .usd)
def vaultCell : C := (.main, .vault, .usd)
def collateralCell : C := (.main, .alice, .collateral)
def aliceDebit : Capability P A D := ⟨⟨.alice, .main, ⟨10⟩, .debit aliceCell⟩, true⟩
def aliceInvoke : Capability P A D := ⟨⟨.alice, .main, ⟨10⟩, .invoke⟩, true⟩
def bobDebit : Capability P A D := ⟨⟨.bob, .main, ⟨10⟩, .debit bobCell⟩, true⟩
def bobInvoke : Capability P A D := ⟨⟨.bob, .main, ⟨10⟩, .invoke⟩, true⟩
def mainStore : Store := ⟨[aliceDebit, aliceInvoke, bobDebit, bobInvoke]⟩
def mainCaps : List CapabilityId := [⟨0⟩, ⟨1⟩, ⟨2⟩, ⟨3⟩]
def balances (alice bob carolAmount vault : Nat) : C → ℚ := fun c ↦
  if c = aliceCell then alice else if c = bobCell then bob
  else if c = carolCell then carolAmount else if c = vaultCell then vault
  else if c = collateralCell then 9 else 0

def world (alice bob carolAmount : Nat) (store : Store := mainStore)
    (vault : Nat := 0) : W :=
  ⟨⟨balances alice bob carolAmount vault, by
    intro c
    simp only [balances]
    repeat' split
    all_goals positivity⟩, store⟩

def cfg : Config P A D :=
  Parallel.Examples.config Typed.Examples.transfer Parallel.Examples.noOp [aliceCell] []
def constantBoundary (_ : Nat) : Boundary P A D := ⟨aliceContext, fresh, 100⟩
def mainBoundary (index : Nat) : Boundary P A D :=
  ⟨⟨if index = 2 then .bob else .alice, .main⟩, fresh, 100 + index⟩
def movement (q : ℚ) (recipient : P) (ids : List CapabilityId := mainCaps) : Inv :=
  ⟨⟨0⟩, ⟨10⟩, [recipient], [.literal ⟨.amount .usd, q⟩], ids, none⟩
def draw7 : Inv := movement 7 .bob
def consume3 : Inv := { movement 3 carol with inputs := [.priorOutput 0 ⟨⟨0⟩, ⟨0⟩⟩] }
def return1 : Inv := movement 1 .alice
def refuse6 : Inv := movement 6 carol

def rawTransfer (index : Nat) (inv : Inv) (sender recipient : C) (amount : ℚ)
    (pre post : W) (snapshot : ℚ) : RawEvent :=
  ⟨index, .invoke inv, pre,
    ⟨post, .invoked ⟨inv.operation, inv.parties, [⟨.amount .usd, amount⟩],
      inv.capabilityIds, inv.claimedActor⟩ (evaluatedTransfer sender recipient amount),
      [output index 0 .usd snapshot]⟩⟩
def cursor (w : W) (events : List RawEvent) (history : List (OutputObservation A))
    (index : Nat) (failure : Option (LocatedFailure P A D) := none) : Cur :=
  ⟨w, events, history, index, failure⟩
def initial : Cur := cursor (world 10 0 0) [] [] 0
def firstEvent := rawTransfer 0 draw7 aliceCell bobCell 7 (world 10 0 0) (world 3 7 0) 3
def secondEvent := rawTransfer 1 consume3 aliceCell carolCell 3 (world 3 7 0) (world 0 7 3) 0
def thirdEvent := rawTransfer 2 return1 bobCell aliceCell 1 (world 0 7 3) (world 1 6 3) 1
def afterFirst : Cur := cursor (world 3 7 0) [firstEvent] [output 0 0 .usd 3] 1
def afterSecond : Cur := cursor (world 0 7 3) [firstEvent, secondEvent]
  [output 0 0 .usd 3, output 1 0 .usd 0] 2
def afterThird : Cur := cursor (world 1 6 3) [firstEvent, secondEvent, thirdEvent]
  [output 0 0 .usd 3, output 1 0 .usd 0, output 2 0 .usd 1] 3
def middleRefusal : Cur := { afterFirst with
  failure := some ⟨1, some (.invoke refuse6), .kernel .insufficientFunds⟩ }

/-- Independent full data comparator includes raw before and post worlds omitted by cursorEq. -/
def worldMatches (a b : W) : Bool :=
  decide ((∀ cell, a.state.balance cell = b.state.balance cell) ∧
    a.capabilities = b.capabilities)
def eventMatches (a b : RawEvent) : Bool :=
  worldMatches a.before b.before && worldMatches a.result.world b.result.world &&
    decide (a.index = b.index ∧ a.step = b.step ∧ a.result.receipt = b.result.receipt ∧
      a.result.outputs = b.result.outputs)
def fullCursorEq (a b : Cur) : Bool :=
  worldMatches a.world b.world && decide (a.events.length = b.events.length) &&
    (a.events.zip b.events).all (fun (x, y) ↦ eventMatches x y) &&
    decide (a.outputs = b.outputs ∧ a.nextIndex = b.nextIndex ∧ a.failure = b.failure)


def grantInvoke : Grant P A D := ⟨.alice, .main, ⟨10⟩, .invoke⟩
def adminStore : Store := ⟨[aliceDebit]⟩
def issuedStore : Store := ⟨[aliceDebit, aliceInvoke]⟩
def deadStore : Store := ⟨[aliceDebit, { aliceInvoke with live := false }]⟩
def adminMove : Inv := movement 1 .bob [⟨0⟩, ⟨1⟩]
def adminBoundary (index : Nat) : Boundary P A D :=
  ⟨if index = 5 ∨ index = 7 then adminContext else aliceContext, fresh, 100 + index⟩
def adminPrefix : RawEvent := ⟨4, .issue ⟨.alice, .main, ⟨10⟩, .debit aliceCell⟩,
  world 3 7 0 ⟨[]⟩,
  ⟨world 3 7 0 adminStore, .issued ⟨0⟩, []⟩⟩
def adminInitial : Cur := cursor (world 3 7 0 adminStore) [adminPrefix]
  [] 5
def issueEvent : RawEvent := ⟨5, .issue grantInvoke, world 3 7 0 adminStore,
  ⟨world 3 7 0 issuedStore, .issued ⟨1⟩, []⟩⟩
def adminUseEvent : RawEvent := rawTransfer 6 adminMove aliceCell bobCell 1
  (world 3 7 0 issuedStore) (world 2 8 0 issuedStore) 2
def revokeEvent : RawEvent := ⟨7, .revoke ⟨1⟩, world 2 8 0 issuedStore,
  ⟨world 2 8 0 deadStore, .revoked ⟨1⟩, []⟩⟩
def adminIssued : Cur := cursor (world 3 7 0 issuedStore) [adminPrefix, issueEvent]
  [] 6
def adminUsed : Cur := cursor (world 2 8 0 issuedStore)
  [adminPrefix, issueEvent, adminUseEvent] [output 6 0 .usd 2] 7
def adminRevoked : Cur := cursor (world 2 8 0 deadStore)
  [adminPrefix, issueEvent, adminUseEvent, revokeEvent]
  [output 6 0 .usd 2] 8
def adminDenied : Cur := { adminRevoked with
  failure := some ⟨8, some (.invoke adminMove), .kernel .unauthorizedInvoke⟩ }

def timedCfg : Config P A D := Parallel.Examples.config
  (Parallel.Examples.timedTemplate .usd) Parallel.Examples.noOp [aliceCell] []
def timedBoundary (index : Nat) : Boundary P A D :=
  ⟨⟨if index = 5 then .bob else .alice, .main⟩, fresh, 100 + index⟩
def timedMove (amount time : ℚ) (recipient : P) : Inv :=
  { movement amount recipient with
    inputs := [.literal ⟨.amount .usd, amount⟩, .literal ⟨.scalar, time⟩] }
def timedFirst := timedMove 3 104 .bob
def timedSecond := timedMove 1 105 .alice
def timedRaw (index : Nat) (inv : Inv) (sender recipient : C) (amount time : ℚ)
    (pre post : W) (snapshot : ℚ) : RawEvent :=
  ⟨index, .invoke inv, pre, ⟨post,
    .invoked ⟨inv.operation, inv.parties, [⟨.amount .usd, amount⟩, ⟨.scalar, time⟩],
      inv.capabilityIds, inv.claimedActor⟩
      { evaluatedTransfer sender recipient amount with
        requiredEnvReads := [.currentTime], declaredEnvReads := [.currentTime] },
    [output index 0 .usd snapshot]⟩⟩
def timedInitial : Cur := cursor (world 10 0 0) [] [] 4
def timedEvent1 := timedRaw 4 timedFirst aliceCell bobCell 3 104 (world 10 0 0) (world 7 3 0) 7
def timedEvent2 := timedRaw 5 timedSecond bobCell aliceCell 1 105 (world 7 3 0) (world 8 2 0) 8
def timedExpected : Cur := cursor (world 8 2 0) [timedEvent1, timedEvent2]
  [output 4 0 .usd 7, output 5 0 .usd 8] 6


/-- Literal continuation distinguishes current-world threading from history threading. -/
def worldChainCall : Inv := movement 1 carol
def worldChainEvent := rawTransfer 1 worldChainCall aliceCell carolCell 1
  (world 3 7 0) (world 2 7 1) 2
def worldChainExpected : Cur := cursor (world 2 7 1) [firstEvent, worldChainEvent]
  [output 0 0 .usd 3, output 1 0 .usd 2] 2

/-- The zero-dollar producer preserves the entry ledger but publishes a nonzero snapshot. -/
def historyChainProducer : Inv := movement 0 .bob
def historyChainConsumer : Inv :=
  { movement 10 carol with inputs := [.priorOutput 0 ⟨⟨0⟩, ⟨0⟩⟩] }
def historyProducerEvent := rawTransfer 0 historyChainProducer aliceCell bobCell 0
  (world 10 0 0) (world 10 0 0) 10
def historyConsumerEvent := rawTransfer 1 historyChainConsumer aliceCell carolCell 10
  (world 10 0 0) (world 0 0 10) 0
def historyChainExpected : Cur := cursor (world 0 0 10)
  [historyProducerEvent, historyConsumerEvent] [output 0 0 .usd 10, output 1 0 .usd 0] 2

/-- Literal inputs and index-selected times exercise position without a prior-output read. -/
def indexChainBoundary (index : Nat) : Boundary P A D :=
  ⟨aliceContext, fresh, 200 + index⟩
def indexChainInitial : Cur := cursor (world 10 0 0) [] [] 9
def indexChainFirst : Inv := timedMove 2 209 .bob
def indexChainSecond : Inv := timedMove 1 210 carol
def indexChainEvent1 := timedRaw 9 indexChainFirst aliceCell bobCell 2 209
  (world 10 0 0) (world 8 2 0) 8
def indexChainEvent2 := timedRaw 10 indexChainSecond aliceCell carolCell 1 210
  (world 8 2 0) (world 7 2 1) 7
def indexChainExpected : Cur := cursor (world 7 2 1) [indexChainEvent1, indexChainEvent2]
  [output 9 0 .usd 8, output 10 0 .usd 7] 11

/-- A funded second leaf after an empty first child needs no changed intermediate cursor. -/
def childExecutionCall : Inv := movement 2 .bob
def childExecutionEvent := rawTransfer 0 childExecutionCall aliceCell bobCell 2
  (world 10 0 0) (world 8 2 0) 8
def childExecutionExpected : Cur := cursor (world 8 2 0) [childExecutionEvent]
  [output 0 0 .usd 8] 1

def extendedCfg : Config P A D := { cfg with
  registry := fun op ↦ if op = ⟨99⟩ then some Parallel.Examples.noOp else cfg.registry op
  catalog := cfg.catalog ++ [⟨⟨99⟩, [], [], [], [⟨⟨99⟩, [], []⟩]⟩] }
def changedRegistry : Config P A D := { cfg with
  registry := fun op ↦
    if op = ⟨10⟩ then some { Typed.Examples.transfer with guard := .lit false }
    else cfg.registry op }
def changedOutput : Config P A D := Parallel.Examples.config
  Typed.Examples.transfer Parallel.Examples.noOp [bobCell] []
def invalidAdded : Config P A D := { cfg with catalog := cfg.catalog ++ cfg.catalog }
def changedAdmin : Config P A D := { cfg with domainAdmin := fun _ ↦ .bob }
def grantOnlyCfg : Config P A D := { cfg with
  registry := fun op ↦
    if op = ⟨77⟩ then some Parallel.Examples.noOp else cfg.registry op }
def grantOnlyChanged : Config P A D := { cfg with
  registry := fun op ↦
    if op = ⟨77⟩ then some { Parallel.Examples.noOp with domain := .other }
    else cfg.registry op }
def grantOnly : Grant P A D := ⟨.alice, .main, ⟨77⟩, .invoke⟩
def issueBoundary : Boundary P A D := ⟨adminContext, fresh, 100⟩
def grantOnlyStore : Store := ⟨mainStore.entries ++ [⟨grantOnly, true⟩]⟩
def changedOutputExpected : Cur := { afterFirst with
  events := [{ firstEvent with result := { firstEvent.result with
    outputs := [output 0 0 .usd 7] } }]
  outputs := [output 0 0 .usd 7] }
def failedInitial (action : Action) (reason : Composition.Failure) : Cur :=
  { initial with failure := some ⟨0, some action, reason⟩ }

/-- Exact one-entry counterexample: the funded prefix moves one dollar from Carol to Alice. -/
def fundingStore : Store := ⟨mainStore.entries ++
  [⟨⟨.alice, .main, ⟨11⟩, .invoke⟩, true⟩,
   ⟨⟨.alice, .main, ⟨11⟩, .debit carolCell⟩, true⟩]⟩
def fundingCaps : List CapabilityId := [⟨0⟩, ⟨1⟩, ⟨2⟩, ⟨3⟩, ⟨4⟩, ⟨5⟩]
def fundingInitial : Cur := cursor (world 0 0 2 fundingStore) [] [] 0
def fundingCfg : Config P A D := Parallel.Examples.config Typed.Examples.transfer
  (Parallel.Examples.transferTemplate .usd (.literal carol) (.literal .alice)) [aliceCell] []
def fundingBoundary : Nat → Boundary P A D := constantBoundary
def fundingCall : Inv := ⟨⟨1⟩, ⟨11⟩, [], [.literal ⟨.amount .usd, 1⟩], fundingCaps, none⟩
def firstHidden : Inv := movement 1 .bob fundingCaps
def fundingEvent : RawEvent := ⟨0, .invoke fundingCall, world 0 0 2 fundingStore,
  ⟨world 1 0 1 fundingStore,
    .invoked ⟨⟨11⟩, [], [⟨.amount .usd, 1⟩], fundingCaps, none⟩
      (evaluatedTransfer carolCell aliceCell 1), []⟩⟩
def exposedEvent := rawTransfer 1 firstHidden aliceCell bobCell 1
  (world 1 0 1 fundingStore) (world 0 1 1 fundingStore) 0
def fundingExposed : Cur := cursor (world 0 1 1 fundingStore) [fundingEvent, exposedEvent]
  [output 1 0 .usd 0] 2

-- BEGIN PROOFS

end DefiKernel.Metatheory.Examples

## END FILE

## FILE lean/DefiKernel/Metatheory/Observation.lean

Original SHA256: 6ceedf99d806d8510fb609c94b2be2d8250c7453e12453d4ed11756d6238553b; bytes: 7070; rendered SHA256: 6ceedf99d806d8510fb609c94b2be2d8250c7453e12453d4ed11756d6238553b

import DefiKernel.Metatheory.SequentialGroups
import DefiKernel.Parallel.Observation

/-! Continuation observations retain every computational input and every observed event field.
Only past raw event worlds are omitted. Local comparison sites admit independent omission tests. -/
namespace DefiKernel.Metatheory
open Typed Composition Parallel

structure CursorObservation (P A D : Type) where
  world : World P A D
  branch : BranchObservation P A D

def observeCursor {P A D : Type} (cursor : Cursor P A D) : CursorObservation P A D :=
  ⟨cursor.world, observeBranch cursor⟩

def CursorEquivalent {P A D : Type} (left right : Cursor P A D) : Prop :=
  (∀ cell, left.world.state.balance cell = right.world.state.balance cell) ∧
    left.world.capabilities = right.world.capabilities ∧
    observeBranch left = observeBranch right

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def eventEq (left right : EventObservation P A D) : Bool :=
  decide (left.index = right.index) && decide (left.step = right.step) &&
    decide (left.receipt = right.receipt) && decide (left.outputs = right.outputs)

def eventsEq : List (EventObservation P A D) → List (EventObservation P A D) → Bool
  | [], [] => true
  | left :: lefts, right :: rights => eventEq left right && eventsEq lefts rights
  | _, _ => false

def observationEq (left right : CursorObservation P A D) : Bool :=
  decide (∀ cell, left.world.state.balance cell = right.world.state.balance cell) &&
    decide (left.world.capabilities = right.world.capabilities) &&
    eventsEq left.branch.events right.branch.events &&
    decide (left.branch.outputs = right.branch.outputs) &&
    decide (left.branch.nextIndex = right.branch.nextIndex) &&
    decide (left.branch.failure = right.branch.failure)

def cursorEq (left right : Cursor P A D) : Bool :=
  observationEq (observeCursor left) (observeCursor right)

-- BEGIN PROOFS

omit [Fintype P] [Fintype A] [Fintype D] in
theorem eventEq_iff (left right : EventObservation P A D) :
    eventEq left right = true ↔ left = right := by
  cases left
  cases right
  simp [eventEq, EventObservation.mk.injEq, and_assoc]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem eventsEq_iff (left right : List (EventObservation P A D)) :
    eventsEq left right = true ↔ left = right := by
  induction left generalizing right with
  | nil => cases right <;> simp [eventsEq]
  | cons head tail ih =>
    cases right with
    | nil => simp [eventsEq]
    | cons other rest => simp [eventsEq, eventEq_iff, ih]

theorem cursorEq_iff (left right : Cursor P A D) :
    cursorEq left right = true ↔ CursorEquivalent left right := by
  simp only [cursorEq, observationEq, observeCursor, Bool.and_eq_true,
    eventsEq_iff, CursorEquivalent, observeBranch, BranchObservation.mk.injEq, and_assoc]
  constructor
  · rintro ⟨hb, hs, he, ho, hi, hf⟩
    exact ⟨of_decide_eq_true hb, of_decide_eq_true hs, he,
      of_decide_eq_true ho, of_decide_eq_true hi, of_decide_eq_true hf⟩
  · rintro ⟨hb, hs, he, ho, hi, hf⟩
    exact ⟨decide_eq_true hb, decide_eq_true hs, he,
      decide_eq_true ho, decide_eq_true hi, decide_eq_true hf⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem world_eq_of_fields (left right : World P A D)
    (balance : ∀ cell, left.state.balance cell = right.state.balance cell)
    (store : left.capabilities = right.capabilities) : left = right := by
  rcases left with ⟨⟨lb, ln⟩, lc⟩
  rcases right with ⟨⟨rb, rn⟩, rc⟩
  have hb : lb = rb := funext balance
  cases hb
  cases store
  rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem CursorEquivalent.world {left right : Cursor P A D}
    (h : CursorEquivalent left right) : left.world = right.world :=
  world_eq_of_fields _ _ h.1 h.2.1

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem CursorEquivalent.refl (cursor : Cursor P A D) : CursorEquivalent cursor cursor :=
  ⟨fun _ ↦ rfl, rfl, rfl⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem CursorEquivalent.symm {left right : Cursor P A D} (h : CursorEquivalent left right) :
    CursorEquivalent right left := ⟨fun cell ↦ (h.1 cell).symm, h.2.1.symm, h.2.2.symm⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem CursorEquivalent.trans {first middle last : Cursor P A D}
    (h : CursorEquivalent first middle) (g : CursorEquivalent middle last) :
    CursorEquivalent first last :=
  ⟨fun cell ↦ (h.1 cell).trans (g.1 cell), h.2.1.trans g.2.1, h.2.2.trans g.2.2⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem cursorEquivalent_iff_fields (left right : Cursor P A D) :
    CursorEquivalent left right ↔
      left.world = right.world ∧
      left.events.map observeEvent = right.events.map observeEvent ∧
      left.outputs = right.outputs ∧ left.nextIndex = right.nextIndex ∧
      left.failure = right.failure := by
  constructor
  · intro h
    refine ⟨h.world, ?_⟩
    simpa only [observeBranch, BranchObservation.mk.injEq] using h.2.2
  · rintro ⟨hw, he, ho, hi, hf⟩
    exact ⟨fun cell ↦ congrArg (fun w ↦ w.state.balance cell) hw,
      congrArg (fun w ↦ w.capabilities) hw, by simp only [observeBranch, he, ho, hi, hf]⟩

/-- Every actual invocation, issue and revoke preserves the chosen observation equivalence. -/
theorem advance_preserves (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (left right : Cursor P A D) (action : Step P A D) (h : CursorEquivalent left right) :
    CursorEquivalent (Composition.advance cfg boundaries left action)
      (Composition.advance cfg boundaries right action) := by
  obtain ⟨hw, he, ho, hi, hf⟩ := (cursorEquivalent_iff_fields left right).mp h
  apply (cursorEquivalent_iff_fields _ _).mpr
  rcases left with ⟨lw, le, lo, li, lf⟩
  rcases right with ⟨rw, re, ro, ri, rf⟩
  dsimp only at hw he ho hi hf
  cases hw
  cases ho
  cases hi
  cases hf
  cases lf with
  | some failure =>
    simp [Composition.advance, he]
  | none =>
    cases hx : Composition.executeStep cfg (boundaries li) li lo action lw with
    | error reason => simp [Composition.advance, hx, he]
    | ok result => simp [Composition.advance, hx, List.map_append, he]

theorem runGroup_preserves (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (left right : Cursor P A D) (group : SeqGroup P A D) (h : CursorEquivalent left right) :
    CursorEquivalent (runGroup cfg boundaries left group)
      (runGroup cfg boundaries right group) := by
  induction group generalizing left right with
  | empty => exact h
  | step action => exact advance_preserves cfg boundaries left right action h
  | seq first second firstIH secondIH =>
    exact secondIH _ _ (firstIH left right h)

end DefiKernel.Metatheory

## END FILE

## FILE lean/DefiKernel/Metatheory/OperatorFixtures.lean

Original SHA256: 69456da74dca26781a1c399702cdec205dbe5001844885b98b046dbe5260d51d; bytes: 13878; rendered SHA256: 69456da74dca26781a1c399702cdec205dbe5001844885b98b046dbe5260d51d

import DefiKernel.Metatheory.Examples
import DefiKernel.Atomic.Observation

/-! Nonempty old/new configuration executions through the actual existing operators.
Independent full raw cursors and attempts supplement each production public observation. -/
namespace DefiKernel.Metatheory.OperatorFixtures
open Typed Composition Typed.Examples Examples
open Parallel (BranchId)
open Parallel.Examples (output)

abbrev B := Parallel.Branch P A D
abbrev IM := Interleaving.Machine P A D
def boundary (_ : BranchId) : Nat → Boundary P A D := constantBoundary
def unknown : Inv := { draw7 with component := ⟨88⟩, operation := ⟨88⟩ }
def badSuffix : B := [movement 11 .bob, unknown]
def stepResultMatches (a b : StepResult P A D) : Bool :=
  worldMatches a.world b.world && decide (a.receipt = b.receipt ∧ a.outputs = b.outputs)
def outcomeMatches (a b : Except Composition.Failure (StepResult P A D)) : Bool :=
  match a, b with
  | .ok x, .ok y => stepResultMatches x y
  | .error x, .error y => decide (x = y)
  | _, _ => false
def attemptMatches (a b : Interleaving.Attempt P A D) : Bool :=
  decide (a.branch = b.branch ∧ a.index = b.index ∧ a.invocation = b.invocation) &&
    worldMatches a.before b.before && outcomeMatches a.outcome b.outcome
def localMatches (a b : Interleaving.LocalState P A D) (w : W) : Bool :=
  decide (a.consumed = b.consumed) &&
    fullCursorEq (a.toCursor w) (b.toCursor w)
def machineMatches (a b : IM) : Bool :=
  worldMatches a.world b.world && localMatches a.left b.left a.world &&
    localMatches a.right b.right a.world && decide (a.attempts.length = b.attempts.length) &&
    (a.attempts.zip b.attempts).all (fun (x, y) ↦ attemptMatches x y)
def firstAttempt : Interleaving.Attempt P A D :=
  ⟨.left, 0, draw7, world 10 0 0, .ok firstEvent.result⟩
def firstMachine : IM := ⟨world 3 7 0,
  ⟨1, [firstEvent], [output 0 0 .usd 3], 1, none⟩, {}, [firstAttempt]⟩
def failureMachine : IM := ⟨world 3 7 0,
  ⟨2, [firstEvent], [output 0 0 .usd 3], 1, middleRefusal.failure⟩, {},
  [firstAttempt, ⟨.left, 1, refuse6, world 3 7 0, .error (.kernel .insufficientFunds)⟩]⟩
def parallelMatches (actual : Parallel.Result P A D) (w : W) (left right : Cur) : Bool :=
  match actual with
  | .refused _ _ => false
  | .executed joined => worldMatches joined.world w && fullCursorEq joined.left left &&
      fullCursorEq joined.right right
def parallelRefused (actual : Parallel.Result P A D) : Bool :=
  match actual with
  | .refused reason w => worldMatches w initial.world &&
      decide (reason = .structural .left ⟨1, .interface .unknownOperation⟩)
  | _ => false
def interMatches (actual : Interleaving.Result P A D) (schedule : Interleaving.Schedule)
    (expected : IM) : Bool :=
  match actual with
  | .executed actualSchedule m => decide (actualSchedule = schedule) && machineMatches m expected
  | _ => false
def interRefused (actual : Interleaving.Result P A D) : Bool :=
  match actual with
  | .refused reason w schedule => worldMatches w initial.world &&
      decide (schedule = [.left, .left] ∧
        reason = .structural .left ⟨1, .interface .unknownOperation⟩)
  | _ => false

def batchPolicy : Atomic.Policy P A D := ⟨[], [.alice]⟩
def zero : D → A → ℚ := fun _ _ ↦ 0
def firstInner : Atomic.InnerObservation P A D :=
  ⟨.left, 0, draw7, firstEvent.result.receipt, [output 0 0 .usd 3]⟩
def batchObservation : Atomic.Observation P A D :=
  ⟨73, [.left], .committed, world 3 7 0, [⟨73, [.left], [firstInner]⟩], zero⟩
def batchAbortReason : Atomic.AbortReason P A D :=
  .kernel .left 1 1 refuse6 (.kernel .insufficientFunds)
def batchAbortObservation : Atomic.Observation P A D :=
  ⟨73, [.left, .left], .aborted batchAbortReason, world 10 0 0, [], zero⟩
def batchRefusedObservation : Atomic.Observation P A D :=
  ⟨73, [.left, .left], .refused (.structural .left ⟨1, .interface .unknownOperation⟩),
    world 10 0 0, [], zero⟩
def tableMatches (a : Atomic.Outstanding P A D) (owed : List (Atomic.Residual P A D)) : Bool :=
  decide (∀ d asset vaultParty principal,
    a ⟨d, asset, vaultParty⟩ principal = Atomic.Examples.expectedOutstanding owed
      ⟨d, asset, vaultParty⟩ principal)
def atomicDiagnostics (actual : Atomic.Result P A D) (entry : W) (expected : IM)
    (position : Nat) (abort : Option (Atomic.AbortReason P A D))
    (owed : List (Atomic.Residual P A D)) : Bool :=
  match actual with
  | .refused _ _ _ _ => false
  | .committed _ _ m | .aborted _ _ _ m =>
      worldMatches m.entryWorld entry && machineMatches m.speculative expected &&
        decide (m.position = position ∧ m.abort = abort) && tableMatches m.outstanding owed

def batchRun (config : Config P A D) (left : B) : Atomic.Result P A D :=
  Atomic.runAtomic config boundary 73 batchPolicy initial.world left []
    (left.map (fun _ ↦ BranchId.left))
def atomicMatches (actual : Atomic.Result P A D) (expected : Atomic.Observation P A D) : Bool :=
  Atomic.observationEq (Atomic.observe actual) expected

def extendedAtomic : Config P A D := { Atomic.Examples.atomCfg with
  registry := fun op ↦ if op = ⟨998⟩ then some Parallel.Examples.noOp
    else Atomic.Examples.atomCfg.registry op
  catalog := Atomic.Examples.atomCfg.catalog ++ [⟨⟨998⟩, [], [], [], [⟨⟨998⟩, [], []⟩]⟩] }
/-- Reconstruct raw expected events from predeclared expected receipt data and literal worlds. -/
def raw (e : Parallel.EventObservation P A D) (pre post : W) : RawEvent :=
  ⟨e.index, e.step, pre, ⟨post, e.receipt, e.outputs⟩⟩
def settleDraw : RawEvent := raw Atomic.Examples.drawEvent
  Atomic.Examples.atomInitial Atomic.Examples.afterDraw
def settleReturn (under : Bool) : RawEvent :=
  raw (Atomic.Examples.repayEvent 1 (if under then 6 else 7) (if under then 9 else 10))
    Atomic.Examples.afterDraw
    (if under then Atomic.Examples.afterUnder else Atomic.Examples.atomInitial)
def settleMachine (under : Bool) : IM :=
  let last := settleReturn under
  ⟨last.result.world, ⟨2, [settleDraw, last],
    [output 0 100 .usd 3, output 1 101 .usd (if under then 9 else 10)], 2, none⟩, {},
    [⟨.left, 0, Atomic.Examples.draw 7, Atomic.Examples.atomInitial, .ok settleDraw.result⟩,
      ⟨.left, 1, Atomic.Examples.repay (if under then 6 else 7), Atomic.Examples.afterDraw,
        .ok last.result⟩]⟩
def settleObservation (under : Bool) : Atomic.Observation P A D :=
  if under then
    ⟨74, [.left, .left], .aborted (.unsettled Atomic.Examples.underResiduals),
      Atomic.Examples.atomInitial, [], zero⟩
  else ⟨74, [.left, .left], .committed, Atomic.Examples.atomInitial,
    [⟨74, [.left, .left],
      [⟨.left, 0, Atomic.Examples.draw 7, settleDraw.result.receipt, settleDraw.result.outputs⟩,
        ⟨.left, 1, Atomic.Examples.repay 7, (settleReturn false).result.receipt,
          (settleReturn false).result.outputs⟩]⟩], zero⟩
def settleRun (config : Config P A D) (under : Bool) : Atomic.Result P A D :=
  Atomic.runAtomic config Atomic.Examples.atomBoundary 74 Atomic.Examples.basePolicy
    Atomic.Examples.atomInitial
    [Atomic.Examples.draw 7, Atomic.Examples.repay (if under then 6 else 7)] [] [.left, .left]
def settlementCheck (config : Config P A D) (under : Bool) : Bool :=
  let actual := settleRun config under
  atomicMatches actual (settleObservation under) &&
    atomicDiagnostics actual Atomic.Examples.atomInitial (settleMachine under) 2 none
      (if under then Atomic.Examples.underResiduals else [])

def checks : List (String × Bool) := [
  ("metatheory.operator.parallel.old", parallelMatches
    (Parallel.runParallel cfg boundary initial.world [draw7] []) (world 3 7 0) afterFirst initial),
  ("metatheory.operator.parallel.extended", parallelMatches
    (Parallel.runParallel extendedCfg boundary initial.world [draw7] [])
    (world 3 7 0) afterFirst initial),
  ("metatheory.operator.parallel.failure.old", parallelMatches
    (Parallel.runParallel cfg boundary initial.world [draw7, refuse6] [])
    (world 3 7 0) middleRefusal initial),
  ("metatheory.operator.parallel.failure.extended", parallelMatches
    (Parallel.runParallel extendedCfg boundary initial.world [draw7, refuse6] [])
    (world 3 7 0) middleRefusal initial),
  ("metatheory.operator.parallel.admission.old", parallelRefused
    (Parallel.runParallel cfg boundary initial.world badSuffix [])),
  ("metatheory.operator.parallel.admission.extended", parallelRefused
    (Parallel.runParallel extendedCfg boundary initial.world badSuffix [])),
  ("metatheory.operator.interleaving.old", interMatches
    (Interleaving.runInterleaving cfg boundary initial.world [draw7] [] [.left])
    [.left] firstMachine),
  ("metatheory.operator.interleaving.extended", interMatches
    (Interleaving.runInterleaving extendedCfg boundary initial.world [draw7] [] [.left])
    [.left] firstMachine),
  ("metatheory.operator.interleaving.failure.old", interMatches
    (Interleaving.runInterleaving cfg boundary initial.world [draw7, refuse6] [] [.left, .left])
    [.left, .left] failureMachine),
  ("metatheory.operator.interleaving.failure.extended", interMatches
    (Interleaving.runInterleaving extendedCfg boundary initial.world
      [draw7, refuse6] [] [.left, .left])
    [.left, .left] failureMachine),
  ("metatheory.operator.interleaving.admission.old", interRefused
    (Interleaving.runInterleaving cfg boundary initial.world badSuffix [] [.left, .left])),
  ("metatheory.operator.interleaving.admission.extended", interRefused
    (Interleaving.runInterleaving extendedCfg boundary initial.world badSuffix [] [.left, .left])),
  ("metatheory.operator.atomic.batch.old", atomicMatches (batchRun cfg [draw7]) batchObservation &&
    atomicDiagnostics (batchRun cfg [draw7]) initial.world firstMachine 1 none []),
  ("metatheory.operator.atomic.batch.extended", atomicMatches
    (batchRun extendedCfg [draw7]) batchObservation &&
    atomicDiagnostics (batchRun extendedCfg [draw7]) initial.world firstMachine 1 none []),
  ("metatheory.operator.atomic.kernel.old", atomicMatches
    (batchRun cfg [draw7, refuse6]) batchAbortObservation &&
    atomicDiagnostics (batchRun cfg [draw7, refuse6]) initial.world failureMachine 2
      (some batchAbortReason) []),
  ("metatheory.operator.atomic.kernel.extended", atomicMatches
    (batchRun extendedCfg [draw7, refuse6]) batchAbortObservation &&
    atomicDiagnostics (batchRun extendedCfg [draw7, refuse6]) initial.world failureMachine 2
      (some batchAbortReason) []),
  ("metatheory.operator.atomic.admission.old", atomicMatches
    (batchRun cfg badSuffix) batchRefusedObservation),
  ("metatheory.operator.atomic.admission.extended", atomicMatches
    (batchRun extendedCfg badSuffix) batchRefusedObservation),
  ("metatheory.operator.atomic.settlement.old", settlementCheck Atomic.Examples.atomCfg false),
  ("metatheory.operator.atomic.settlement.extended", settlementCheck extendedAtomic false),
  ("metatheory.operator.atomic.unsettled.old", settlementCheck Atomic.Examples.atomCfg true),
  ("metatheory.operator.atomic.unsettled.extended", settlementCheck extendedAtomic true),
  ("metatheory.operator.atomic.extended.valid", validateCatalog extendedAtomic.registry
    extendedAtomic.catalog)
]


/-- Moving a commit boundary changes which successful prefix remains publicly visible. -/
def splitFirst : Atomic.Result P A D := batchRun cfg [draw7]
def splitSecond : Atomic.Result P A D :=
  Atomic.runAtomic cfg boundary 74 batchPolicy splitFirst.publicWorld [refuse6] [] [.left]
def splitReason : Atomic.AbortReason P A D :=
  .kernel .left 0 0 refuse6 (.kernel .insufficientFunds)
def splitExpected : Atomic.Observation P A D :=
  ⟨74, [.left], .aborted splitReason, world 3 7 0, [], zero⟩
def splitMachine : IM := ⟨world 3 7 0,
  ⟨1, [], [], 0, some ⟨0, some (.invoke refuse6), .kernel .insufficientFunds⟩⟩, {},
  [⟨.left, 0, refuse6, world 3 7 0, .error (.kernel .insufficientFunds)⟩]⟩
def laneMintRaw : RawEvent := raw Atomic.Examples.laneMintEvent
  Atomic.Examples.atomInitial Atomic.Examples.afterLaneMint
def laneMintMachine : IM := ⟨Atomic.Examples.afterLaneMint,
  ⟨1, [laneMintRaw], [output 0 108 .usd 4], 1, none⟩, {},
  [⟨.left, 0, Atomic.Examples.mintUSD, Atomic.Examples.atomInitial, .ok laneMintRaw.result⟩]⟩
def laneMintReason : Atomic.AbortReason P A D :=
  .laneSupply .left 0 0 Atomic.Examples.mintUSD Atomic.Examples.usdLane 3
def laneMintExpected : Atomic.Observation P A D :=
  ⟨75, [.left], .aborted laneMintReason, Atomic.Examples.atomInitial, [], zero⟩
def laneMintCheck (config : Config P A D) : Bool :=
  let actual := Atomic.runAtomic config Atomic.Examples.atomBoundary 75 Atomic.Examples.basePolicy
    Atomic.Examples.atomInitial [Atomic.Examples.mintUSD] [] [.left]
  atomicMatches actual laneMintExpected && atomicDiagnostics actual Atomic.Examples.atomInitial
    laneMintMachine 1 (some laneMintReason) []
def boundaryChecks : List (String × Bool) := [
  ("metatheory.boundary.combined", atomicMatches
    (batchRun cfg [draw7, refuse6]) batchAbortObservation &&
    atomicDiagnostics (batchRun cfg [draw7, refuse6]) initial.world failureMachine 2
      (some batchAbortReason) []),
  ("metatheory.boundary.split.first", atomicMatches splitFirst batchObservation &&
    atomicDiagnostics splitFirst initial.world firstMachine 1 none []),
  ("metatheory.boundary.split.second", atomicMatches splitSecond splitExpected &&
    atomicDiagnostics splitSecond (world 3 7 0) splitMachine 1 (some splitReason) []),
  ("metatheory.boundary.material", !worldMatches
    (batchRun cfg [draw7, refuse6]).publicWorld splitSecond.publicWorld),
  ("metatheory.operator.atomic.supply.old", laneMintCheck Atomic.Examples.atomCfg),
  ("metatheory.operator.atomic.supply.extended", laneMintCheck extendedAtomic)
]

-- BEGIN PROOFS

end DefiKernel.Metatheory.OperatorFixtures

## END FILE

## FILE lean/DefiKernel/Metatheory/OperatorLifting.lean

Original SHA256: 5def40dbdc48471166e921e987845b425f5a739cc7dc883422e2b13e535e2dee; bytes: 12068; rendered SHA256: 5def40dbdc48471166e921e987845b425f5a739cc7dc883422e2b13e535e2dee

import DefiKernel.Metatheory.Configuration
import DefiKernel.Parallel.Execution
import DefiKernel.Interleaving.Execution
import DefiKernel.Atomic.Execution

/-! Exact configuration congruence through the unchanged invocation-only operators. Equality keeps
all machine data, attempts, admission errors and Atomic outcomes; schedules are not reordered. -/
namespace DefiKernel.Metatheory
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

-- BEGIN PROOFS

theorem analyzeInvocation_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundary : Boundary P A D) (inv : Invocation P A D)
    (supported : SupportedStep refs (.invoke inv)) :
    analyzeInvocation old boundary inv = analyzeInvocation new boundary inv := by
  unfold analyzeInvocation
  rw [h.lookup inv.component inv.operation supported.1, h.registry inv.operation supported.2]

theorem analyzeBranchFrom_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundary : Nat → Boundary P A D) (index : Nat)
    (branch : Branch P A D) (supported : SupportedBranch refs branch) :
    analyzeBranchFrom old boundary index branch = analyzeBranchFrom new boundary index branch := by
  induction branch generalizing index with
  | nil => rfl
  | cons inv tail ih =>
    obtain ⟨head, rest⟩ := (supportedBranch_cons refs inv tail).mp supported
    simp only [analyzeBranchFrom, analyzeInvocation_config_eq h (boundary index) inv head,
      ih (index + 1) rest]

theorem analyzeBranch_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) (supported : SupportedBranch refs branch) :
    analyzeBranch old boundary branch = analyzeBranch new boundary branch :=
  analyzeBranchFrom_config_eq h boundary 0 branch supported

theorem parallel_admit_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Parallel.admit old boundaries left right = Parallel.admit new boundaries left right := by
  simp only [Parallel.admit, h.old_valid, h.new_valid,
    analyzeBranch_config_eq h (boundaries .left) left hl,
    analyzeBranch_config_eq h (boundaries .right) right hr]

theorem interleaving_admit_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Interleaving.Schedule)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Interleaving.admit old boundaries left right schedule =
      Interleaving.admit new boundaries left right schedule := by
  simp only [Interleaving.admit, h.old_valid, h.new_valid,
    analyzeBranch_config_eq h (boundaries .left) left hl,
    analyzeBranch_config_eq h (boundaries .right) right hr]

theorem atomic_admit_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (policy : Atomic.Policy P A D) (left right : Branch P A D) (schedule : Interleaving.Schedule)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Atomic.admit old boundaries policy left right schedule =
      Atomic.admit new boundaries policy left right schedule := by
  simp only [Atomic.admit, h.old_valid, h.new_valid,
    analyzeBranch_config_eq h (boundaries .left) left hl,
    analyzeBranch_config_eq h (boundaries .right) right hr]

variable [Fintype P] [Fintype A] [Fintype D]

theorem runBranch_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (supported : SupportedBranch refs branch) :
    runBranch old boundaries initial branch = runBranch new boundaries initial branch :=
  run_config_eq h boundaries initial (branch.map Step.invoke)
    ((supportedBranch_map refs branch).mpr supported)

theorem runParallel_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    runParallel old boundaries initial left right =
      runParallel new boundaries initial left right := by
  simp only [runParallel, parallel_admit_config_eq h boundaries left right hl hr,
    runBranch_config_eq h (boundaries .left) initial left hl,
    runBranch_config_eq h (boundaries .right) initial right hr]

theorem runSerialLR_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    runSerialLR old boundaries initial left right =
      runSerialLR new boundaries initial left right := by
  simp only [runSerialLR, parallel_admit_config_eq h boundaries left right hl hr,
    runBranch_config_eq h (boundaries .left) initial left hl,
    runBranch_config_eq h (boundaries .right) _ right hr]

theorem runSerialRL_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    runSerialRL old boundaries initial left right =
      runSerialRL new boundaries initial left right := by
  simp only [runSerialRL, parallel_admit_config_eq h boundaries left right hl hr,
    runBranch_config_eq h (boundaries .right) initial right hr,
    runBranch_config_eq h (boundaries .left) _ left hl]

/-- Arbitrary common machines need no reachability or success premise for configuration equality. -/
theorem interleaving_advance_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Interleaving.Machine P A D) (branch : BranchId)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Interleaving.advance old boundaries left right m branch =
      Interleaving.advance new boundaries left right m branch := by
  have hs : SupportedBranch refs (Interleaving.selectBranch left right branch) := by
    cases branch with
    | left => exact hl
    | right => exact hr
  unfold Interleaving.advance
  simp only []
  cases hf : (m.local branch).failure with
  | some failure => rfl
  | none =>
    cases hi : (Interleaving.selectBranch left right branch)[(m.local branch).consumed]? with
    | none => rfl
    | some inv =>
      have hm := List.mem_of_getElem? hi
      simp only []
      rw [executeStep_config_eq h (boundaries branch (m.local branch).nextIndex)
        (m.local branch).nextIndex (m.local branch).outputs (.invoke inv) m.world (hs inv hm)]

theorem interleaving_continueRun_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Interleaving.Machine P A D) (schedule : Interleaving.Schedule)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Interleaving.continueRun old boundaries left right m schedule =
      Interleaving.continueRun new boundaries left right m schedule := by
  induction schedule generalizing m with
  | nil => rfl
  | cons branch tail ih =>
    simpa only [Interleaving.continueRun, List.foldl_cons,
      interleaving_advance_config_eq h boundaries left right m branch hl hr] using
        ih (Interleaving.advance new boundaries left right m branch)

theorem interleaving_runPrefix_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Interleaving.Schedule)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Interleaving.runPrefix old boundaries initial left right schedule =
      Interleaving.runPrefix new boundaries initial left right schedule :=
  interleaving_continueRun_config_eq h boundaries left right
    (Interleaving.start initial) schedule hl hr

theorem runInterleaving_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Interleaving.Schedule)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Interleaving.runInterleaving old boundaries initial left right schedule =
      Interleaving.runInterleaving new boundaries initial left right schedule := by
  simp only [Interleaving.runInterleaving,
    interleaving_admit_config_eq h boundaries left right schedule hl hr,
    interleaving_runPrefix_config_eq h boundaries initial left right schedule hl hr]

theorem atomic_advance_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (policy : Atomic.Policy P A D) (left right : Branch P A D) (m : Atomic.Machine P A D)
    (branch : BranchId) (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Atomic.advance old boundaries policy left right m branch =
      Atomic.advance new boundaries policy left right m branch := by
  unfold Atomic.advance
  rw [interleaving_advance_config_eq h boundaries left right m.speculative branch hl hr]

theorem atomic_continueRun_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (policy : Atomic.Policy P A D) (left right : Branch P A D) (m : Atomic.Machine P A D)
    (schedule : Interleaving.Schedule) (hl : SupportedBranch refs left)
    (hr : SupportedBranch refs right) :
    Atomic.continueRun old boundaries policy left right m schedule =
      Atomic.continueRun new boundaries policy left right m schedule := by
  induction schedule generalizing m with
  | nil => rfl
  | cons branch tail ih =>
    simpa only [Atomic.continueRun, List.foldl_cons,
      atomic_advance_config_eq h boundaries policy left right m branch hl hr] using
        ih (Atomic.advance new boundaries policy left right m branch)

theorem atomic_runPrefix_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (policy : Atomic.Policy P A D) (initial : World P A D)
    (left right : Branch P A D)
    (schedule : Interleaving.Schedule) (hl : SupportedBranch refs left)
    (hr : SupportedBranch refs right) :
    Atomic.runPrefix old boundaries policy initial left right schedule =
      Atomic.runPrefix new boundaries policy initial left right schedule :=
  atomic_continueRun_config_eq h boundaries policy left right
    (Atomic.start initial) schedule hl hr

/-- Preserves admission refusal, kernel/supply abort, unsettled residuals and committed data. -/
theorem runAtomic_config_eq {old new : Config P A D} {refs : ReferenceSet}
    (h : ConfigAgreement old new refs) (boundaries : ParallelBoundary P A D)
    (label : Nat) (policy : Atomic.Policy P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Interleaving.Schedule)
    (hl : SupportedBranch refs left) (hr : SupportedBranch refs right) :
    Atomic.runAtomic old boundaries label policy initial left right schedule =
      Atomic.runAtomic new boundaries label policy initial left right schedule := by
  simp only [Atomic.runAtomic, atomic_admit_config_eq h boundaries policy left right schedule hl hr,
    atomic_runPrefix_config_eq h boundaries policy initial left right schedule hl hr]

end DefiKernel.Metatheory

## END FILE

## FILE lean/DefiKernel/Metatheory/SequentialGroups.lean

Original SHA256: 935174d28f898520f6f81f1643a9b5c8ed708f3b32c10d620febe173d015fea7; bytes: 3419; rendered SHA256: 935174d28f898520f6f81f1643a9b5c8ed708f3b32c10d620febe173d015fea7

import DefiKernel.Composition.Sequence

/-! Recursive ordered groups continue the complete actual cursor. `SupportedGroup` deliberately
uses `flatten` only as a Prop-valued specification of static support. The recursive `runGroup`
interpreter never delegates execution to the list executor. -/
namespace DefiKernel.Metatheory
open Typed Composition

inductive SeqGroup (P A D : Type) where
  | empty
  | step (action : Step P A D)
  | seq (first second : SeqGroup P A D)

def flatten {P A D : Type} : SeqGroup P A D → List (Step P A D)
  | .empty => []
  | .step action => [action]
  | .seq first second => flatten first ++ flatten second

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def runGroup (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) : SeqGroup P A D → Cursor P A D
  | .empty => cursor
  | .step action => Composition.advance cfg boundaries cursor action
  | .seq first second =>
    let middle := runGroup cfg boundaries cursor first
    runGroup cfg boundaries middle second

-- BEGIN PROOFS

/-- Simulation includes all raw event worlds, administrative stores, absolute positions and
existing failures; there is no successful-only or initial-cursor premise. -/
theorem runGroup_eq_continueRun (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (group : SeqGroup P A D) :
    runGroup cfg boundaries cursor group =
      Composition.continueRun cfg boundaries cursor (flatten group) := by
  induction group generalizing cursor with
  | empty => rfl
  | step action => rfl
  | seq first second firstIH secondIH =>
    simp only [runGroup, flatten, Composition.continueRun_append, firstIH, secondIH]

theorem runGroup_empty (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) : runGroup cfg boundaries cursor .empty = cursor := rfl

theorem runGroup_empty_left (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (group : SeqGroup P A D) :
    runGroup cfg boundaries cursor (.seq .empty group) =
      runGroup cfg boundaries cursor group := rfl

theorem runGroup_empty_right (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (group : SeqGroup P A D) :
    runGroup cfg boundaries cursor (.seq group .empty) =
      runGroup cfg boundaries cursor group := rfl

/-- A previously located refusal makes every submitted recursive group inert. -/
theorem runGroup_failed (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (failure : LocatedFailure P A D)
    (failed : cursor.failure = some failure) (group : SeqGroup P A D) :
    runGroup cfg boundaries cursor group = cursor := by
  rw [runGroup_eq_continueRun]
  exact Composition.continueRun_failed cfg boundaries cursor failure failed (flatten group)

/-- Regrouping three ordered sequential groups preserves the entire returned cursor. -/
theorem runGroup_assoc (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (first second third : SeqGroup P A D) :
    runGroup cfg boundaries cursor (.seq (.seq first second) third) =
      runGroup cfg boundaries cursor (.seq first (.seq second third)) := by
  rw [runGroup_eq_continueRun, runGroup_eq_continueRun]
  simp only [flatten, List.append_assoc]

end DefiKernel.Metatheory

## END FILE

## FILE lean/DefiKernel/Metatheory/Tests.lean

Original SHA256: 60b1890c1858ca68e4da3c74f6261facee639ca5c230b522dbd0a6f241f1b730; bytes: 22752; rendered SHA256: 60b1890c1858ca68e4da3c74f6261facee639ca5c230b522dbd0a6f241f1b730

import DefiKernel.Metatheory.Examples
import DefiKernel.Metatheory.Observation
import DefiKernel.Metatheory.Contexts
import DefiKernel.Metatheory.OperatorFixtures

/-! Named runtime checks use independently constructed complete cursors. Synthetic observer
pairs are explicitly distinguished from actual execution counterexamples. -/
namespace DefiKernel.Metatheory.Tests
open Typed Composition Typed.Examples Examples
open Parallel.Examples (output evaluatedTransfer)

abbrev G := SeqGroup P A D
def leaf (inv : Inv) : G := .step (.invoke inv)
def first : G := leaf draw7
def second : G := leaf consume3
def third : G := leaf return1
def pair : G := .seq first second
def leftGrouped : G := .seq pair third
def rightGrouped : G := .seq first (.seq second third)
def refusing : G := .seq (.seq first (leaf refuse6)) (leaf (movement 1 carol))
def issueGroup : G := .step (.issue grantInvoke)
def useGroup : G := leaf adminMove
def revokeGroup : G := .step (.revoke ⟨1⟩)
def administration : G := .seq (.seq issueGroup useGroup)
  (.seq revokeGroup (.seq useGroup (leaf (movement 1 carol))))
def run (group : G) (entry : Cur := initial) : Cur := runGroup cfg mainBoundary entry group

def reverseEvent := rawTransfer 0 refuse6 aliceCell carolCell 6
  (world 10 0 0) (world 4 0 6) 4
def reverseExpected : Cur := cursor (world 4 0 6) [reverseEvent] [output 0 0 .usd 4] 1
  (some ⟨1, some (.invoke draw7), .kernel .insufficientFunds⟩)
def suffixEvent := rawTransfer 1 (movement 1 carol) aliceCell carolCell 1
  (world 3 7 0) (world 2 7 1) 2
def suffixExpected : Cur := cursor (world 2 7 1) [firstEvent, suffixEvent]
  [output 0 0 .usd 3, output 1 0 .usd 2] 2
/-- Separately written nonempty equal control, without projecting an actual run. -/
def equalFirst : Cur :=
  ⟨world 3 7 0,
    [⟨0, .invoke draw7, world 10 0 0,
      ⟨world 3 7 0, .invoked ⟨⟨10⟩, [.bob], [⟨.amount .usd, 7⟩], mainCaps, none⟩
        (evaluatedTransfer aliceCell bobCell 7), [output 0 0 .usd 3]⟩⟩],
    [output 0 0 .usd 3], 1, none⟩

def groupChecks : List (String × Bool) := [
  ("metatheory.fixture.catalog", validateCatalog cfg.registry cfg.catalog),
  ("metatheory.positive.single-leaf", fullCursorEq
    (runGroup cfg constantBoundary initial first) afterFirst),
  ("metatheory.positive.equal-observation", cursorEq afterFirst equalFirst),
  ("metatheory.group.world-chain", fullCursorEq
    (runGroup cfg constantBoundary initial (.seq first (leaf worldChainCall))) worldChainExpected),
  ("metatheory.group.store-chain", fullCursorEq
    (runGroup cfg adminBoundary adminInitial (.seq issueGroup useGroup)) adminUsed),
  ("metatheory.group.history-chain", fullCursorEq
    (runGroup cfg constantBoundary initial
      (.seq (leaf historyChainProducer) (leaf historyChainConsumer))) historyChainExpected),
  ("metatheory.group.index-chain", fullCursorEq
    (runGroup timedCfg indexChainBoundary indexChainInitial
      (.seq (leaf indexChainFirst) (leaf indexChainSecond))) indexChainExpected),
  ("metatheory.group.refusal-absorption", fullCursorEq (run refusing) middleRefusal),
  ("metatheory.group.child-executed", fullCursorEq
    (runGroup cfg constantBoundary initial (.seq .empty (leaf childExecutionCall)))
    childExecutionExpected),
  ("metatheory.group.ordered", fullCursorEq (run rightGrouped) afterThird),
  ("metatheory.group.boundary-index", fullCursorEq
    (runGroup timedCfg timedBoundary timedInitial (.seq (leaf timedFirst) (leaf timedSecond)))
    timedExpected),
  ("metatheory.group.empty", fullCursorEq (run .empty afterFirst) afterFirst),
  ("metatheory.group.empty.left", fullCursorEq (run (.seq .empty first)) afterFirst),
  ("metatheory.group.empty.right", fullCursorEq (run (.seq first .empty)) afterFirst),
  ("metatheory.group.failed-entry", fullCursorEq (run leftGrouped middleRefusal) middleRefusal),
  ("metatheory.group.funded-suffix", fullCursorEq
    (run (leaf (movement 1 carol)) afterFirst) suffixExpected),
  ("metatheory.group.reverse-refusal", fullCursorEq
    (run (.seq (leaf refuse6) first)) reverseExpected),
  ("metatheory.group.forward-refusal", fullCursorEq
    (run (.seq first (leaf refuse6))) middleRefusal),
  ("metatheory.group.admin.issue", fullCursorEq
    (runGroup cfg adminBoundary adminInitial issueGroup) adminIssued),
  ("metatheory.group.admin.revoke", fullCursorEq
    (runGroup cfg adminBoundary adminInitial (.seq (.seq issueGroup useGroup) revokeGroup))
    adminRevoked),
  ("metatheory.group.admin.denied", fullCursorEq
    (runGroup cfg adminBoundary adminInitial administration) adminDenied),
  ("metatheory.group.flat.success", fullCursorEq
    (Composition.continueRun cfg mainBoundary initial
      [.invoke draw7, .invoke consume3, .invoke return1]) afterThird),
  ("metatheory.group.flat.admin", fullCursorEq
    (Composition.continueRun cfg adminBoundary adminInitial
      [.issue grantInvoke, .invoke adminMove, .revoke ⟨1⟩, .invoke adminMove,
        .invoke (movement 1 carol)]) adminDenied),
  ("metatheory.group.assoc.failure.left", fullCursorEq
    (run (.seq (.seq first (leaf refuse6)) third)) middleRefusal),
  ("metatheory.group.assoc.failure.right", fullCursorEq
    (run (.seq first (.seq (leaf refuse6) third))) middleRefusal),
  ("metatheory.group.continuation", fullCursorEq (run (.seq second third) afterFirst) afterThird)
]

/-- All changed pairs below are synthetic observer inputs, not two reachable executions. -/
def different (changed : Cur) : Bool := !cursorEq afterFirst changed
def alteredEvent (event : RawEvent) : Cur := { afterFirst with events := [event] }
def alteredReceipt (receipt : Receipt P A D) : Cur := alteredEvent
  { firstEvent with result := { firstEvent.result with receipt := receipt } }
def receiptChanged : Receipt P A D := .invoked
  ⟨⟨10⟩, [.bob], [⟨.amount .usd, 6⟩], mainCaps, none⟩
  (evaluatedTransfer aliceCell bobCell 7)
def evaluatedChanged : Receipt P A D := .invoked
  ⟨⟨10⟩, [.bob], [⟨.amount .usd, 7⟩], mainCaps, none⟩
  (evaluatedTransfer aliceCell bobCell 6)
def evaluatedReadChanged : Receipt P A D := .invoked
  ⟨⟨10⟩, [.bob], [⟨.amount .usd, 7⟩], mainCaps, none⟩
  { evaluatedTransfer aliceCell bobCell 7 with declaredStateReads := [collateralCell] }
def failureChanged (failure : LocatedFailure P A D) : Bool :=
  !cursorEq middleRefusal { middleRefusal with failure := some failure }
def changedCollateral : W :=
  ⟨⟨fun c ↦ if c = collateralCell then 10 else (world 3 7 0).state.balance c,
    fun c ↦ by
      split
      · norm_num
      · exact (world 3 7 0).state.nonneg c⟩, mainStore⟩
def observationChecks : List (String × Bool) := [
  ("metatheory.observe.world-diff", different { afterFirst with world := changedCollateral }),
  ("metatheory.observe.store-diff", different
    { afterFirst with world := world 3 7 0 ⟨[aliceDebit]⟩ }),
  ("metatheory.observe.output-diff", different
    { afterFirst with outputs := [output 0 0 .usd 2] }),
  ("metatheory.observe.failure-diff", different
    { afterFirst with failure := some ⟨1, some (.invoke refuse6), .kernel .insufficientFunds⟩ }),
  ("metatheory.observe.receipt-diff", different (alteredReceipt evaluatedChanged)),
  ("metatheory.observe.request.arguments", different (alteredReceipt receiptChanged)),
  ("metatheory.observe.next-index-diff", different { afterFirst with nextIndex := 2 }),
  ("metatheory.observe.output.unit", different
    { afterFirst with outputs := [output 0 0 .share 3] }),
  ("metatheory.observe.output.producer", different
    { afterFirst with outputs := [output 1 0 .usd 3] }),
  ("metatheory.observe.output.component", different
    { afterFirst with outputs := [output 0 1 .usd 3] }),
  ("metatheory.observe.output.port", different { afterFirst with
    outputs := [⟨0, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .usd, 3⟩⟩] }),
  ("metatheory.observe.output.order", !cursorEq afterSecond
    { afterSecond with outputs := [output 1 0 .usd 0, output 0 0 .usd 3] }),
  ("metatheory.observe.store.tombstone", different { afterFirst with
    world := world 3 7 0 ⟨[aliceDebit, { aliceInvoke with live := false }, bobDebit, bobInvoke]⟩ }),
  ("metatheory.observe.event.index", different (alteredEvent { firstEvent with index := 1 })),
  ("metatheory.observe.event.action", different
    (alteredEvent { firstEvent with step := .invoke refuse6 })),
  ("metatheory.observe.event.output", different (alteredEvent
    { firstEvent with result := { firstEvent.result with outputs := [output 0 0 .usd 2] } })),
  ("metatheory.observe.event.evaluated", different (alteredReceipt evaluatedReadChanged)),
  ("metatheory.observe.event.length", different { afterFirst with events := [] }),
  ("metatheory.observe.event.order", !cursorEq afterSecond
    { afterSecond with events := [secondEvent, firstEvent] }),
  ("metatheory.observe.event.issue-id", !cursorEq adminIssued { adminIssued with
    events := [adminPrefix, { issueEvent with result := { issueEvent.result with
      receipt := .issued ⟨2⟩ } }] }),
  ("metatheory.observe.event.revoke-id", !cursorEq adminRevoked { adminRevoked with
    events := [adminPrefix, issueEvent, adminUseEvent,
      { revokeEvent with result := { revokeEvent.result with receipt := .revoked ⟨0⟩ } }] }),
  ("metatheory.observe.failure.reason", failureChanged
    ⟨1, some (.invoke refuse6), .kernel .guard⟩),
  ("metatheory.observe.failure.position", failureChanged
    ⟨2, some (.invoke refuse6), .kernel .insufficientFunds⟩),
  ("metatheory.observe.failure.action", failureChanged
    ⟨1, some (.invoke draw7), .kernel .insufficientFunds⟩),
  ("metatheory.observe.failure.absent-action", failureChanged
    ⟨1, none, .kernel .insufficientFunds⟩),
  ("metatheory.observe.raw-before.omitted", cursorEq afterFirst
    (alteredEvent { firstEvent with before := world 99 0 0 })),
  ("metatheory.observe.raw-post.omitted", cursorEq afterFirst
    (alteredEvent { firstEvent with result := { firstEvent.result with world := world 99 0 0 } }))
]

def historyOther : Cur := { afterFirst with outputs := [output 0 0 .usd 2] }
def historyOtherEvent := rawTransfer 1 consume3 aliceCell carolCell 2
  (world 3 7 0) (world 1 7 2) 1
def historyOtherExpected : Cur := cursor (world 1 7 2) [firstEvent, historyOtherEvent]
  [output 0 0 .usd 2, output 1 0 .usd 1] 2
def originalHidden : Cur := { fundingInitial with
  failure := some ⟨0, some (.invoke firstHidden), .kernel .insufficientFunds⟩ }
def hiddenSuffix := movement 1 carol fundingCaps
def fundingDifference : Cur := { fundingExposed with
  failure := some ⟨2, some (.invoke hiddenSuffix), .kernel .insufficientFunds⟩ }
def hiddenGroup : G := leaf firstHidden
def hiddenLong : G := .seq hiddenGroup (leaf hiddenSuffix)
def contextChecks : List (String × Bool) := [
  ("metatheory.context.history.original", fullCursorEq (run second afterFirst) afterSecond),
  ("metatheory.context.history.changed", fullCursorEq
    (run second historyOther) historyOtherExpected),
  ("metatheory.context.history.material", !cursorEq
    (run second afterFirst) (run second historyOther)),
  ("metatheory.context.index.original", fullCursorEq
    (runGroup timedCfg timedBoundary timedInitial (leaf timedFirst))
    (cursor (world 7 3 0) [timedEvent1] [output 4 0 .usd 7] 5)),
  ("metatheory.context.index.changed", fullCursorEq
    (runGroup timedCfg timedBoundary { timedInitial with nextIndex := 5 } (leaf timedFirst))
    (cursor (world 10 0 0) [] [] 5 (some ⟨5, some (.invoke timedFirst), .kernel .guard⟩))),
  ("metatheory.context.one-entry.short", fullCursorEq
    (runGroup fundingCfg fundingBoundary fundingInitial hiddenGroup) originalHidden),
  ("metatheory.context.one-entry.long", fullCursorEq
    (runGroup fundingCfg fundingBoundary fundingInitial hiddenLong) originalHidden),
  ("metatheory.context.funded.short", fullCursorEq
    (runGroup fundingCfg fundingBoundary fundingInitial (.seq (leaf fundingCall) hiddenGroup))
    fundingExposed),
  ("metatheory.context.funded.long", fullCursorEq
    (runGroup fundingCfg fundingBoundary fundingInitial (.seq (leaf fundingCall) hiddenLong))
    fundingDifference),
  ("metatheory.context.prefix-suffix.left", fullCursorEq (run leftGrouped) afterThird),
  ("metatheory.context.prefix-suffix.right", fullCursorEq (run rightGrouped) afterThird)
]


def oneStep (config : Config P A D) (boundary : Boundary P A D) (entry : Cur)
    (action : Action) : Cur := runGroup config (fun _ ↦ boundary) entry (.step action)
def appendedGrant : Store := ⟨mainStore.entries ++ [⟨grantInvoke, true⟩]⟩
def issueMainEvent : RawEvent := ⟨0, .issue grantInvoke, world 10 0 0,
  ⟨world 10 0 0 appendedGrant, .issued ⟨4⟩, []⟩⟩
def issueMainExpected : Cur := cursor (world 10 0 0 appendedGrant) [issueMainEvent] [] 1
def emptyStoreInitial : Cur := cursor (world 10 0 0 ⟨[]⟩) [] [] 0
def issueEmptyEvent : RawEvent := ⟨0, .issue grantInvoke, world 10 0 0 ⟨[]⟩,
  ⟨world 10 0 0 ⟨[aliceInvoke]⟩, .issued ⟨0⟩, []⟩⟩
def issueEmptyExpected : Cur := cursor (world 10 0 0 ⟨[aliceInvoke]⟩) [issueEmptyEvent] [] 1
def grantOnlyEvent : RawEvent := ⟨0, .issue grantOnly, world 10 0 0,
  ⟨world 10 0 0 grantOnlyStore, .issued ⟨4⟩, []⟩⟩
def grantOnlyExpected : Cur := cursor (world 10 0 0 grantOnlyStore) [grantOnlyEvent] [] 1
def missingCall : Inv := { draw7 with component := ⟨88⟩, operation := ⟨88⟩ }
def deniedRevoke := failedInitial (.revoke ⟨0⟩) (.authority .unauthorizedAdmin)
def missingRevoke := failedInitial (.revoke ⟨80⟩) (.authority .unknownCapability)
def configurationChecks : List (String × Bool) := [
  ("metatheory.config.extended.valid", validateCatalog extendedCfg.registry extendedCfg.catalog),
  ("metatheory.config.extended.group", fullCursorEq
    (runGroup extendedCfg mainBoundary initial leftGrouped) afterThird),
  ("metatheory.config.extended.refusal", fullCursorEq
    (runGroup extendedCfg mainBoundary initial refusing) middleRefusal),
  ("metatheory.config.extended.admin", fullCursorEq
    (runGroup extendedCfg adminBoundary adminInitial administration) adminDenied),
  ("metatheory.config.extended.step", fullCursorEq
    (oneStep extendedCfg (constantBoundary 0) initial (.invoke draw7)) afterFirst),
  ("metatheory.config.registry.valid",
    validateCatalog changedRegistry.registry changedRegistry.catalog),
  ("metatheory.config.registry.changed", fullCursorEq
    (oneStep changedRegistry (constantBoundary 0) initial (.invoke draw7))
    (failedInitial (.invoke draw7) (.kernel .guard))),
  ("metatheory.config.lookup.valid", validateCatalog changedOutput.registry changedOutput.catalog),
  ("metatheory.config.lookup.changed", fullCursorEq
    (oneStep changedOutput (constantBoundary 0) initial (.invoke draw7)) changedOutputExpected),
  ("metatheory.config.invalid.catalog",
    !validateCatalog invalidAdded.registry invalidAdded.catalog),
  ("metatheory.config.invalid.lookup-unchanged", decide
    (lookupOperation cfg.catalog ⟨0⟩ ⟨10⟩ = lookupOperation invalidAdded.catalog ⟨0⟩ ⟨10⟩)),
  ("metatheory.config.invalid.refusal", fullCursorEq
    (oneStep invalidAdded (constantBoundary 0) initial (.invoke draw7))
    (failedInitial (.invoke draw7) .configuration)),
  ("metatheory.config.issue.original", fullCursorEq
    (oneStep cfg issueBoundary initial (.issue grantInvoke)) issueMainExpected),
  ("metatheory.config.issue.extended", fullCursorEq
    (oneStep extendedCfg issueBoundary initial (.issue grantInvoke)) issueMainExpected),
  ("metatheory.config.issue.empty-store", fullCursorEq
    (oneStep cfg issueBoundary emptyStoreInitial (.issue grantInvoke)) issueEmptyExpected),
  ("metatheory.config.admin.changed", fullCursorEq
    (oneStep changedAdmin issueBoundary initial (.issue grantInvoke))
    (failedInitial (.issue grantInvoke) (.authority .unauthorizedAdmin))),
  ("metatheory.config.grant-only.old-valid",
    validateCatalog grantOnlyCfg.registry grantOnlyCfg.catalog),
  ("metatheory.config.grant-only.new-valid",
    validateCatalog grantOnlyChanged.registry grantOnlyChanged.catalog),
  ("metatheory.config.grant-only.uncataloged", decide
    (lookupOperation grantOnlyCfg.catalog ⟨77⟩ ⟨77⟩ = none ∧
      lookupOperation grantOnlyChanged.catalog ⟨77⟩ ⟨77⟩ = none)),
  ("metatheory.config.grant-only.issue", fullCursorEq
    (oneStep grantOnlyCfg issueBoundary initial (.issue grantOnly)) grantOnlyExpected),
  ("metatheory.config.grant-only.domain", fullCursorEq
    (oneStep grantOnlyChanged issueBoundary initial (.issue grantOnly))
    (failedInitial (.issue grantOnly) (.authority .operationDomain))),
  ("metatheory.config.lookup.absent.old", fullCursorEq
    (oneStep cfg (constantBoundary 0) initial (.invoke missingCall))
    (failedInitial (.invoke missingCall) (.interface .unknownOperation))),
  ("metatheory.config.lookup.absent.new", fullCursorEq
    (oneStep extendedCfg (constantBoundary 0) initial (.invoke missingCall))
    (failedInitial (.invoke missingCall) (.interface .unknownOperation))),
  ("metatheory.config.revoke.denied.old", fullCursorEq
    (oneStep cfg (constantBoundary 0) initial (.revoke ⟨0⟩)) deniedRevoke),
  ("metatheory.config.revoke.denied.new", fullCursorEq
    (oneStep extendedCfg (constantBoundary 0) initial (.revoke ⟨0⟩)) deniedRevoke),
  ("metatheory.config.revoke.missing.old", fullCursorEq
    (oneStep cfg issueBoundary initial (.revoke ⟨80⟩)) missingRevoke),
  ("metatheory.config.revoke.missing.new", fullCursorEq
    (oneStep extendedCfg issueBoundary initial (.revoke ⟨80⟩)) missingRevoke)
]


def requestReceipt (request : Request P A D) : Receipt P A D :=
  .invoked request (evaluatedTransfer aliceCell bobCell 7)
def baseRequest : Request P A D := ⟨⟨10⟩, [.bob], [⟨.amount .usd, 7⟩], mainCaps, none⟩
def detailChecks : List (String × Bool) := [
  ("metatheory.observe.request.operation", different (alteredReceipt
    (requestReceipt { baseRequest with operation := ⟨11⟩ }))),
  ("metatheory.observe.request.parties", different (alteredReceipt
    (requestReceipt { baseRequest with parties := [carol] }))),
  ("metatheory.observe.request.capabilities", different (alteredReceipt
    (requestReceipt { baseRequest with capabilityIds := [⟨0⟩] }))),
  ("metatheory.observe.request.claimed-actor", different (alteredReceipt
    (requestReceipt { baseRequest with claimedActor := some .alice }))),
  ("metatheory.observe.receipt.supply", different (alteredReceipt
    (.invoked baseRequest { evaluatedTransfer aliceCell bobCell 7 with
      supplies := [((.main, .usd), 1)] }))),
  ("metatheory.observe.receipt.writes", different (alteredReceipt
    (.invoked baseRequest { evaluatedTransfer aliceCell bobCell 7 with writes := [] }))),
  ("metatheory.observe.receipt.guard", different (alteredReceipt
    (.invoked baseRequest { evaluatedTransfer aliceCell bobCell 7 with guard := false }))),
  ("metatheory.observe.receipt.state-read", different (alteredReceipt
    (.invoked baseRequest { evaluatedTransfer aliceCell bobCell 7 with
      requiredStateReads := [aliceCell] }))),
  ("metatheory.observe.receipt.env-read", different (alteredReceipt
    (.invoked baseRequest { evaluatedTransfer aliceCell bobCell 7 with
      requiredEnvReads := [.currentTime] }))),
  ("metatheory.observe.receipt.declared-state-read", different (alteredReceipt
    (.invoked baseRequest { evaluatedTransfer aliceCell bobCell 7 with
      declaredStateReads := [aliceCell] }))),
  ("metatheory.observe.receipt.declared-env-read", different (alteredReceipt
    (.invoked baseRequest { evaluatedTransfer aliceCell bobCell 7 with
      declaredEnvReads := [.currentTime] }))),
  ("metatheory.config.registry.remaining", decide
    (cfg.catalog = changedRegistry.catalog ∧
      cfg.domainAdmin .main = changedRegistry.domainAdmin .main)),
  ("metatheory.config.lookup.remaining", decide
    (cfg.domainAdmin .main = changedOutput.domainAdmin .main)),
  ("metatheory.config.grant-only.remaining", decide
    (grantOnlyCfg.catalog = grantOnlyChanged.catalog ∧
      grantOnlyCfg.domainAdmin .main = grantOnlyChanged.domainAdmin .main)),
  ("metatheory.config.admin.remaining", decide
    (cfg.catalog = changedAdmin.catalog)),
  ("metatheory.context.store.material", !cursorEq
    (oneStep cfg issueBoundary initial (.issue grantInvoke))
    (oneStep cfg issueBoundary emptyStoreInitial (.issue grantInvoke)))
]


/-- The selected observer omits old raw worlds even after an actual snapshot-consuming suffix. -/
def rawBeforeOther : Cur := alteredEvent { firstEvent with before := world 99 0 0 }
def rawPostOther : Cur := alteredEvent
  { firstEvent with result := { firstEvent.result with world := world 99 0 0 } }
def surrounding : SeqContext P A D := .after (.before first .hole) third
def failedSurrounding : SeqContext P A D :=
  .after (.before first .hole) (leaf (movement 1 carol))
def closureChecks : List (String × Bool) := [
  ("metatheory.config.admin.valid", validateCatalog changedAdmin.registry changedAdmin.catalog),
  ("metatheory.config.registry.all-admins", decide
    (∀ d, cfg.domainAdmin d = changedRegistry.domainAdmin d)),
  ("metatheory.config.lookup.all-admins", decide
    (∀ d, cfg.domainAdmin d = changedOutput.domainAdmin d)),
  ("metatheory.config.grant-only.all-admins", decide
    (∀ d, grantOnlyCfg.domainAdmin d = grantOnlyChanged.domainAdmin d)),
  ("metatheory.context.raw-before.expected", fullCursorEq (run second rawBeforeOther)
    { afterSecond with events := [{ firstEvent with before := world 99 0 0 }, secondEvent] }),
  ("metatheory.context.raw-post.expected", fullCursorEq (run second rawPostOther)
    { afterSecond with events := [{ firstEvent with result :=
      { firstEvent.result with world := world 99 0 0 } }, secondEvent] }),
  ("metatheory.context.raw-before.equivalent", cursorEq
    (run second afterFirst) (run second rawBeforeOther)),
  ("metatheory.context.raw-post.equivalent", cursorEq
    (run second afterFirst) (run second rawPostOther)),
  ("metatheory.context.fill.original", fullCursorEq (run (fill surrounding second)) afterThird),
  ("metatheory.context.fill.replacement", fullCursorEq
    (run (fill surrounding (.seq .empty second))) afterThird),
  ("metatheory.context.fill.failed.original", fullCursorEq
    (run (fill failedSurrounding (leaf refuse6))) middleRefusal),
  ("metatheory.context.fill.failed.replacement", fullCursorEq
    (run (fill failedSurrounding (.seq .empty (leaf refuse6)))) middleRefusal)
]

def runtimeChecks : List (String × Bool) :=
  groupChecks ++ observationChecks ++ contextChecks ++ configurationChecks ++
    OperatorFixtures.checks ++ OperatorFixtures.boundaryChecks ++ detailChecks ++ closureChecks

-- BEGIN PROOFS

end DefiKernel.Metatheory.Tests

## END FILE

## FILE lean/DefiKernel/Metatheory/Verify.lean

Original SHA256: 9b692dc6b08b796676d38e6f12799995c13aeef55d5106c6b31145b4f0c030fb; bytes: 508; rendered SHA256: 9b692dc6b08b796676d38e6f12799995c13aeef55d5106c6b31145b4f0c030fb

import DefiKernel.Metatheory.Audit
import DefiKernel.Metatheory.Contexts
import DefiKernel.Metatheory.Configuration
import DefiKernel.Metatheory.ConfigurationGroups
import DefiKernel.Metatheory.OperatorLifting
import DefiKernel.Metatheory.ConfigurationFixtures
import DefiKernel.AxiomAudit

/-! Audit all imported Metatheory declarations by module provenance. Generic laws, concrete
instances, and executable comparisons have distinct scopes in the evidence inventory. -/
#audit_axioms DefiKernel.Metatheory

## END FILE

## FILE lean/DefiKernel/Parallel/Compatibility.lean

Original SHA256: 4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243; bytes: 14677; rendered SHA256: 4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243

import DefiKernel.Composition.Execution

/-! Conservative admission for invocation-only branches. Lists preserve deterministic witnesses. -/
namespace DefiKernel.Parallel
open Typed Composition

inductive BranchId where
  | left
  | right
  deriving DecidableEq, Repr
abbrev Branch (P A D : Type) := List (Invocation P A D)
abbrev ParallelBoundary (P A D : Type) := BranchId → Nat → Boundary P A D
structure Footprint (P A D : Type) where
  reads : List (Cell P A D)
  writes : List (Cell P A D)
  deriving DecidableEq, Repr
structure LocalFailure where
  index : Nat
  reason : Composition.Failure
  deriving DecidableEq, Repr
inductive ConflictKind where
  | writeWrite
  | leftWriteRightRead
  | rightWriteLeftRead
  deriving DecidableEq, Repr
inductive AdmissionFailure (P A D : Type) where
  | configuration
  | structural (branch : BranchId) (failure : LocalFailure)
  | conflict (kind : ConflictKind) (cell : Cell P A D)
  deriving DecidableEq, Repr
variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
def Footprint.empty : Footprint P A D := ⟨[], []⟩
def Footprint.append (a b : Footprint P A D) : Footprint P A D :=
  ⟨a.reads ++ b.reads, a.writes ++ b.writes⟩
/-- Lookup, read resolution, write/target resolution, then access checks.
No financial values are evaluated. -/
def analyzeInvocation (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) : Except Composition.Failure (Footprint P A D) := do
  let (component, iface) ← match lookupOperation cfg.catalog inv.component inv.operation with
    | none => .error (.interface .unknownOperation)
    | some pair => .ok pair
  let template ← match cfg.registry inv.operation with
    | none => .error (.kernel .unknownOperation)
    | some template => .ok template
  let reads ← (resolveRefs boundary.ctx.principal inv.parties
    (template.requiredStateReads ++ template.stateReads)).mapError
      (fun e ↦ .interface (.resolution e))
  let writes ← (resolveRefs boundary.ctx.principal inv.parties
    (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩))).mapError
      (fun e ↦ .interface (.resolution e))
  let _ ← (checkAccess component template boundary.ctx inv.parties).mapError .interface
  return ⟨reads ++ writes ++ iface.outputs.map OutputPort.cell, writes⟩
/-- Structural analysis covers the entire suffix even when a financial prefix would refuse. -/
def analyzeBranchFrom (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) : Branch P A D → Except LocalFailure (Footprint P A D)
  | [] => .ok .empty
  | inv :: tail => do
    let head ← (analyzeInvocation cfg (boundary index) inv).mapError (⟨index, ·⟩)
    let rest ← analyzeBranchFrom cfg boundary (index + 1) tail
    return head.append rest
def analyzeBranch (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) : Except LocalFailure (Footprint P A D) :=
  analyzeBranchFrom cfg boundary 0 branch
def firstOverlap (xs ys : List (Cell P A D)) : Option (Cell P A D) :=
  xs.find? (fun c ↦ decide (c ∈ ys))
def checkCompatibility (left right : Footprint P A D) :
    Except (AdmissionFailure P A D) PUnit :=
  match firstOverlap left.writes right.writes with
  | some c => .error (.conflict .writeWrite c)
  | none => match firstOverlap left.writes right.reads with
    | some c => .error (.conflict .leftWriteRightRead c)
    | none => match firstOverlap right.writes left.reads with
      | some c => .error (.conflict .rightWriteLeftRead c)
      | none => .ok ⟨⟩
def admit (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) : Except (AdmissionFailure P A D)
      (Footprint P A D × Footprint P A D) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  let lf ← (analyzeBranch cfg (boundaries .left) left).mapError (.structural .left)
  let rf ← (analyzeBranch cfg (boundaries .right) right).mapError (.structural .right)
  let _ ← checkCompatibility lf rf
  return (lf, rf)

-- BEGIN PROOFS

def Compatible (left right : Footprint P A D) : Prop :=
  (∀ c ∈ left.writes, c ∉ right.writes) ∧
  (∀ c ∈ left.writes, c ∉ right.reads) ∧
  (∀ c ∈ right.writes, c ∉ left.reads)
theorem firstOverlap_none_iff (xs ys : List (Cell P A D)) :
    firstOverlap xs ys = none ↔ ∀ c ∈ xs, c ∉ ys := by
  simp [firstOverlap, List.find?_eq_none]
theorem checkCompatibility_ok_iff (left right : Footprint P A D) :
    checkCompatibility left right = .ok PUnit.unit ↔ Compatible left right := by
  unfold Compatible
  simp only [← firstOverlap_none_iff]
  unfold checkCompatibility
  cases hww : firstOverlap left.writes right.writes <;>
    cases hlr : firstOverlap left.writes right.reads <;>
    cases hrl : firstOverlap right.writes left.reads <;>
    simp_all
omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem compatible_symm {left right : Footprint P A D} (h : Compatible left right) :
    Compatible right left := by
  exact ⟨fun c hr hl ↦ h.1 c hl hr, h.2.2, h.2.1⟩
theorem analyzeInvocation_ok (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∃ component iface template reads writes,
      lookupOperation cfg.catalog inv.component inv.operation = some (component, iface) ∧
      cfg.registry inv.operation = some template ∧
      resolveRefs boundary.ctx.principal inv.parties
        (template.requiredStateReads ++ template.stateReads) = .ok reads ∧
      resolveRefs boundary.ctx.principal inv.parties
        (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩)) = .ok writes ∧
      checkAccess component template boundary.ctx inv.parties = .ok PUnit.unit ∧
      fp = ⟨reads ++ writes ++ iface.outputs.map OutputPort.cell, writes⟩ := by
  unfold analyzeInvocation at h
  simp only [bind, Except.bind, Except.mapError, pure, Except.pure] at h
  split at h
  · contradiction
  rename_i pair hl
  rcases pair with ⟨component, iface⟩
  split at h
  · contradiction
  rename_i template ht
  split at h
  · contradiction
  rename_i reads hr
  split at h
  · contradiction
  rename_i writes hw
  split at h
  · contradiction
  rename_i token hc
  cases token
  have unmap {E F X : Type} (f : E → F) (x : Except E X) (v : X)
      (hx : x.mapError f = .ok v) : x = .ok v := by
    cases x <;> simp_all [Except.mapError]
  exact ⟨component, iface, template, reads, writes, hl, ht,
    unmap _ _ _ hr, unmap _ _ _ hw, unmap _ _ _ hc, (Except.ok.inj h).symm⟩
omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_member (caller : P) (parties : List P)
    (refs : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties refs = .ok cells)
    (ref : PackedCellRef P A D) (hr : ref ∈ refs) :
    ∃ cell ∈ cells, ref.2.resolve caller parties = .ok cell := by
  induction refs generalizing cells with
  | nil => simp at hr
  | cons head tail ih =>
    simp only [resolveRefs, List.mapM_cons, bind, Except.bind] at h
    cases hh : head.2.resolve caller parties with
    | error e => simp [hh] at h
    | ok cell =>
      cases ht : resolveRefs caller parties tail with
      | error e =>
        simp only [resolveRefs] at ht
        simp [hh, ht] at h
      | ok rest =>
        have htt := ht
        simp only [resolveRefs] at ht
        simp only [hh, ht, pure, Except.pure,
          Except.ok.injEq] at h
        subst cells
        rcases List.mem_cons.mp hr with he | hm
        · subst ref; exact ⟨cell, by simp, hh⟩
        · obtain ⟨c, hc, resolved⟩ := ih rest htt hm
          exact ⟨c, List.mem_cons_of_mem _ hc, resolved⟩
theorem analyzeBranchFrom_cons (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) (inv : Invocation P A D) (tail : Branch P A D) (fp : Footprint P A D)
    (h : analyzeBranchFrom cfg boundary index (inv :: tail) = .ok fp) :
    ∃ head rest, analyzeInvocation cfg (boundary index) inv = .ok head ∧
      analyzeBranchFrom cfg boundary (index + 1) tail = .ok rest ∧ fp = head.append rest := by
  unfold analyzeBranchFrom at h
  cases hh : analyzeInvocation cfg (boundary index) inv with
  | error e => simp [hh, Except.mapError, bind, Except.bind] at h
  | ok head =>
    cases ht : analyzeBranchFrom cfg boundary (index + 1) tail with
    | error e => simp [hh, ht, Except.mapError, bind, Except.bind] at h
    | ok rest =>
      simp only [hh, ht, Except.mapError, bind, Except.bind, pure, Except.pure,
        Except.ok.injEq] at h
      exact ⟨head, rest, rfl, rfl, h.symm⟩
theorem admit_ok (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right = .ok (lf, rf)) :
    validateCatalog cfg.registry cfg.catalog = true ∧
    analyzeBranch cfg (boundaries .left) left = .ok lf ∧
    analyzeBranch cfg (boundaries .right) right = .ok rf ∧ Compatible lf rf := by
  unfold admit at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · simp [throw, throwThe] at h
  rename_i hv
  split at h
  · contradiction
  rename_i l hl
  split at h
  · contradiction
  rename_i r hr
  split at h
  · contradiction
  rename_i token hc
  cases token
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Except.ok.inj h)
  have unmap {E F X : Type} (f : E → F) (x : Except E X) (v : X)
      (hx : x.mapError f = .ok v) : x = .ok v := by
    cases x <;> simp_all [Except.mapError]
  exact ⟨by simpa using hv, unmap _ _ _ hl, unmap _ _ _ hr,
    (checkCompatibility_ok_iff _ _).mp hc⟩

theorem admit_compatible (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right = .ok (lf, rf)) : Compatible lf rf :=
  (admit_ok cfg boundaries left right lf rf h).2.2.2

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_mem_of_resolve (caller : P) (parties : List P)
    (refs : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties refs = .ok cells)
    (ref : PackedCellRef P A D) (hr : ref ∈ refs) (cell : Cell P A D)
    (resolved : ref.2.resolve caller parties = .ok cell) : cell ∈ cells := by
  obtain ⟨c, hc, he⟩ := resolveRefs_member caller parties refs cells h ref hr
  rw [resolved] at he
  cases he
  exact hc

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_append_ok (caller : P) (parties : List P)
    (xs ys : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties (xs ++ ys) = .ok cells) :
    ∃ left right, resolveRefs caller parties xs = .ok left ∧
      resolveRefs caller parties ys = .ok right ∧ cells = left ++ right := by
  simp only [resolveRefs, List.mapM_append] at h
  change ((resolveRefs caller parties xs).bind fun left ↦
    (resolveRefs caller parties ys).bind fun right ↦ .ok (left ++ right)) = .ok cells at h
  cases hx : resolveRefs caller parties xs with
  | error e => simp [hx, Except.bind] at h
  | ok left =>
    cases hy : resolveRefs caller parties ys with
    | error e => simp [hx, hy, Except.bind] at h
    | ok right =>
      simp only [hx, hy, Except.bind, Except.ok.injEq] at h
      exact ⟨left, right, rfl, rfl, h.symm⟩

/-- Accepted analysis covers every syntactic/declared read, every potential write and target,
and every output, regardless of whether the invocation would execute successfully. -/
theorem analyzeInvocation_coverage (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∃ component iface template,
      lookupOperation cfg.catalog inv.component inv.operation = some (component, iface) ∧
      cfg.registry inv.operation = some template ∧
      (∀ ref ∈ template.requiredStateReads ++ template.stateReads,
        ∃ c ∈ fp.reads, ref.2.resolve boundary.ctx.principal inv.parties = .ok c) ∧
      (∀ ref ∈ template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩),
        ∃ c ∈ fp.writes, ref.2.resolve boundary.ctx.principal inv.parties = .ok c) ∧
      (∀ output ∈ iface.outputs, output.cell ∈ fp.reads) ∧
      (∀ c ∈ fp.writes, c ∈ fp.reads) := by
  obtain ⟨component, iface, template, reads, writes, hl, ht, hr, hw, _, rfl⟩ :=
    analyzeInvocation_ok cfg boundary inv fp h
  refine ⟨component, iface, template, hl, ht, ?_, ?_, ?_, ?_⟩
  · intro ref hm
    obtain ⟨c, hc, he⟩ := resolveRefs_member _ _ _ _ hr ref hm
    exact ⟨c, by simp [hc], he⟩
  · intro ref hm
    exact resolveRefs_member _ _ _ _ hw ref hm
  · intro output hm
    simp only [List.mem_append, List.mem_map]
    exact Or.inr ⟨output, hm, rfl⟩
  · intro c hc
    simp [hc]

theorem analyzeInvocation_writes_read (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∀ c ∈ fp.writes, c ∈ fp.reads := by
  obtain ⟨_, _, _, _, _, _, _, _, hw⟩ := analyzeInvocation_coverage cfg boundary inv fp h
  exact hw

/-- Every local invocation has its own analyzed footprint contained in the whole branch. -/
theorem analyzeBranchFrom_member (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) (branch : Branch P A D) (fp : Footprint P A D)
    (h : analyzeBranchFrom cfg boundary index branch = .ok fp)
    (n : Nat) (inv : Invocation P A D) (atIndex : branch[n]? = some inv) :
    ∃ part, analyzeInvocation cfg (boundary (index + n)) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ fp.reads) ∧ (∀ c ∈ part.writes, c ∈ fp.writes) := by
  induction branch generalizing index fp n with
  | nil => simp at atIndex
  | cons head tail ih =>
    obtain ⟨hf, tf, hh, ht, rfl⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ h
    cases n with
    | zero =>
      simp only [List.getElem?_cons_zero, Option.some.injEq] at atIndex
      subst inv
      exact ⟨hf, by simpa using hh,
        fun c hc ↦ List.mem_append_left _ hc, fun c hc ↦ List.mem_append_left _ hc⟩
    | succ n =>
      simp only [List.getElem?_cons_succ] at atIndex
      obtain ⟨part, hl, hr, hw⟩ := ih (index + 1) tf ht n atIndex
      refine ⟨part, ?_, fun c hc ↦ List.mem_append_right _ (hr c hc),
        fun c hc ↦ List.mem_append_right _ (hw c hc)⟩
      simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using hl

end DefiKernel.Parallel

## END FILE

## FILE lean/DefiKernel/Parallel/Dependency.lean

Original SHA256: 72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245; bytes: 13489; rendered SHA256: 72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245

import DefiKernel.Composition.Contracts

/-! Complete evaluation and execution dependence on resolved reads and potential delta targets.
No successful footprint check is assumed in the refusal proofs. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def ResolvedReadsAgree (template : Template P A D) (caller : P) (parties : List P)
    (left right : State P A D) : Prop :=
  ∀ ref ∈ template.requiredStateReads, ∀ c,
    ref.2.resolve caller parties = .ok c → left.balance c = right.balance c

def TargetsWithin (template : Template P A D) (caller : P) (parties : List P)
    (region : Set (Cell P A D)) : Prop :=
  ∀ d ∈ template.deltas, ∀ c, d.target.resolve caller parties = .ok c → c ∈ region

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq D] in
/-- Complete expression results agree on a resolved syntactic read region. -/
theorem expression_congr_of_region {signature : List (Unit A)} {u : Unit A}
    (expression : Expr P A D signature u) (left right : State P A D)
    (env : Environment A D) (caller : P) (parties : List P) (args : Args signature) (now : Nat)
    (region : Set (Cell P A D)) (ha : AgreeOn region left right)
    (hr : ∀ ref ∈ expression.stateReads, ∀ c,
      ref.2.resolve caller parties = .ok c → c ∈ region) :
    expression.eval ⟨left, env, caller, parties, args, now⟩ =
      expression.eval ⟨right, env, caller, parties, args, now⟩ := by
  apply expression.eval_congr_of_resolved
    ⟨left, env, caller, parties, args, now⟩
    ⟨right, env, caller, parties, args, now⟩ rfl rfl rfl
  · intro ref hm c hc
    exact ha c (hr ref hm c hc)
  · intro key hk
    cases key <;> rfl

theorem mapM_congr_on {α β ε : Type} (xs : List α) (f g : α → Except ε β)
    (h : ∀ x ∈ xs, f x = g x) : xs.mapM f = xs.mapM g := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    simp only [List.mapM_cons, h x (by simp), ih (fun y hy ↦ h y (by simp [hy]))]

theorem mapM_ok_mem {α β ε : Type} (xs : List α) (f : α → Except ε β)
    (ys : List β) (h : xs.mapM f = .ok ys) :
    ∀ y ∈ ys, ∃ x ∈ xs, f x = .ok y := by
  induction xs generalizing ys with
  | nil =>
    have hy : ys = [] := (Except.ok.inj h).symm
    subst ys
    simp
  | cons x xs ih =>
    rw [List.mapM_cons] at h
    cases hx : f x <;> simp only [hx, bind, Except.bind] at h
    · contradiction
    rename_i z
    cases ht : xs.mapM f <;> simp only [ht, bind, Except.bind, pure, Except.pure] at h
    · contradiction
    cases h
    intro y hy
    rcases List.mem_cons.mp hy with rfl | hy
    · exact ⟨x, by simp, hx⟩
    · obtain ⟨a, ha, hf⟩ := ih _ ht y hy
      exact ⟨a, by simp [ha], hf⟩

theorem evaluate_congr (template : Template P A D) (left right : State P A D)
    (env : Environment A D) (caller : P) (parties : List P)
    (args : Args template.signature) (now : Nat)
    (h : ResolvedReadsAgree template caller parties left right) :
    template.evaluate ⟨left, env, caller, parties, args, now⟩ =
      template.evaluate ⟨right, env, caller, parties, args, now⟩ := by
  have expr {u : Unit A} (e : Expr P A D template.signature u)
      (he : ∀ ref ∈ e.stateReads, ref ∈ template.requiredStateReads) :
      e.eval ⟨left, env, caller, parties, args, now⟩ =
        e.eval ⟨right, env, caller, parties, args, now⟩ := by
    apply e.eval_congr_of_resolved
      ⟨left, env, caller, parties, args, now⟩
      ⟨right, env, caller, parties, args, now⟩ rfl rfl rfl
    · intro ref hr c hc
      exact h ref (he ref hr) c hc
    · intro key hk
      cases key <;> rfl
  have hg := expr template.guard (by intros; simp_all [Template.requiredStateReads])
  have hd := mapM_congr_on template.deltas
    (fun d ↦ do
      let c ← d.target.resolve caller parties
      let a ← d.amount.eval ⟨left, env, caller, parties, args, now⟩
      pure (c, a))
    (fun d ↦ do
      let c ← d.target.resolve caller parties
      let a ← d.amount.eval ⟨right, env, caller, parties, args, now⟩
      pure (c, a)) (by
        intro d hd
        rw [expr d.amount (by
          intro ref hr
          simp only [Template.requiredStateReads, List.mem_append, List.mem_flatMap]
          exact Or.inl (Or.inr ⟨d, hd, hr⟩))])
  have hs := mapM_congr_on template.supplyDeltas
    (fun d ↦ do
      let a ← d.amount.eval ⟨left, env, caller, parties, args, now⟩
      pure ((d.domain, d.asset), a))
    (fun d ↦ do
      let a ← d.amount.eval ⟨right, env, caller, parties, args, now⟩
      pure ((d.domain, d.asset), a)) (by
        intro d hd
        rw [expr d.amount (by
          intro ref hr
          simp only [Template.requiredStateReads, List.mem_append, List.mem_flatMap]
          exact Or.inr ⟨d, hd, hr⟩)])
  unfold Template.evaluate
  rw [hg, hd, hs]

theorem evaluated_targets (template : Template P A D)
    (ctx : EvalContext P A D template.signature) (e : Evaluated P A D)
    (h : template.evaluate ctx = .ok e) :
    ∀ entry ∈ e.deltas, ∃ d ∈ template.deltas,
      d.target.resolve ctx.caller ctx.parties = .ok entry.1 := by
  unfold Template.evaluate at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  rename_i deltas hd
  split at h
  · contradiction
  cases h
  intro entry he
  obtain ⟨d, hm, hv⟩ := mapM_ok_mem _ _ _ hd entry he
  refine ⟨d, hm, ?_⟩
  cases hc : d.target.resolve ctx.caller ctx.parties <;>
    simp only [hc, bind, Except.bind] at hv
  · contradiction
  cases ha : d.amount.eval ctx <;> simp only [ha, bind, Except.bind] at hv
  · contradiction
  cases hv
  rfl

theorem evaluated_effect_zero_outside (template : Template P A D)
    (ctx : EvalContext P A D template.signature) (e : Evaluated P A D)
    (h : template.evaluate ctx = .ok e) (region : Set (Cell P A D))
    (ht : TargetsWithin template ctx.caller ctx.parties region)
    (c : Cell P A D) (hc : c ∉ region) : e.effect c = 0 := by
  apply List.sum_eq_zero
  intro v hv
  obtain ⟨entry, he, rfl⟩ := List.mem_map.mp hv
  have hn : entry.1 ≠ c := by
    intro eq
    obtain ⟨d, hd, hr⟩ := evaluated_targets template ctx e h entry he
    exact hc (eq ▸ ht d hd entry.1 hr)
  simp [hn]

variable [Fintype P] [Fintype A] [Fintype D]

/-- Equality on potential targets suffices even if accounting or writes later refuse. -/
theorem funds_iff (left right : State P A D) (e : Evaluated P A D)
    (region : Set (Cell P A D)) (ha : AgreeOn region left right)
    (hz : ∀ c, c ∉ region → e.effect c = 0) :
    (∀ c, 0 ≤ left.balance c + e.effect c) ↔
      (∀ c, 0 ≤ right.balance c + e.effect c) := by
  constructor
  · intro h c
    by_cases hc : c ∈ region
    · rw [← ha c hc]
      exact h c
    · simpa [hz c hc] using right.nonneg c
  · intro h c
    by_cases hc : c ∈ region
    · rw [ha c hc]
      exact h c
    · simpa [hz c hc] using left.nonneg c

/-- Success compares the protected region and fixed store; errors compare exact constructors. -/
def ExecutionAgrees (region : Set (Cell P A D)) :
    Except Typed.Refusal (ExecutionResult P A D) →
    Except Typed.Refusal (ExecutionResult P A D) → Prop
  | .error a, .error b => a = b
  | .ok a, .ok b => AgreeOn region a.state b.state ∧ a.capabilities = b.capabilities
  | _, _ => False

theorem applyEvaluated_congr (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (request : Request P A D)
    (left right : State P A D) (e : Evaluated P A D)
    (region : Set (Cell P A D)) (ha : AgreeOn region left right)
    (hz : ∀ c, c ∉ region → e.effect c = 0) :
    ExecutionAgrees region (applyEvaluated store ctx request left e)
      (applyEvaluated store ctx request right e) := by
  have hf := funds_iff left right e region ha hz
  by_cases hl : ∀ c, 0 ≤ left.balance c + e.effect c
  · have hr := hf.mp hl
    unfold applyEvaluated
    simp only [dif_pos hl, dif_pos hr]
    split_ifs <;> try rfl
    exact ⟨fun c hc ↦ congrArg (fun q ↦ q + e.effect c) (ha c hc), rfl⟩
  · have hr : ¬ ∀ c, 0 ≤ right.balance c + e.effect c := fun h ↦ hl (hf.mpr h)
    unfold applyEvaluated
    simp only [dif_neg hl, dif_neg hr]
    split_ifs <;> rfl

/-- Complete registered execution dependence, including every exact refusal. -/
theorem execute_congr (registry : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (request : Request P A D) (left right : State P A D) (region : Set (Cell P A D))
    (ha : AgreeOn region left right)
    (hr : ∀ template, registry request.operation = some template →
      ResolvedReadsAgree template ctx.principal request.parties left right)
    (ht : ∀ template, registry request.operation = some template →
      TargetsWithin template ctx.principal request.parties region) :
    ExecutionAgrees region (Typed.execute registry store ctx env now request left)
      (Typed.execute registry store ctx env now request right) := by
  unfold Typed.execute
  cases hs : registry request.operation with
  | none => rfl
  | some template =>
    simp only [bind, Except.bind]
    split_ifs <;> (try simp only [throw, throwThe, bind, Except.bind])
    all_goals try rfl
    all_goals
      cases argsOk : Args.check template.signature request.arguments <;>
        simp only [Except.mapError, bind, Except.bind]
    all_goals try rfl
    rename_i args
    have he := evaluate_congr template left right env ctx.principal request.parties args now
      (hr template hs)
    rw [← he]
    cases ev : template.evaluate ⟨left, env, ctx.principal, request.parties, args, now⟩ with
    | error reason => rfl
    | ok e =>
      simp only [Except.mapError, bind, Except.bind]
      exact applyEvaluated_congr store ctx request left right e region ha
        (evaluated_effect_zero_outside template _ e ev region (ht template hs))

theorem execute_refusal_iff (registry : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (request : Request P A D) (left right : State P A D) (region : Set (Cell P A D))
    (ha : AgreeOn region left right)
    (hr : ∀ template, registry request.operation = some template →
      ResolvedReadsAgree template ctx.principal request.parties left right)
    (ht : ∀ template, registry request.operation = some template →
      TargetsWithin template ctx.principal request.parties region) (reason : Typed.Refusal) :
    Typed.execute registry store ctx env now request left = .error reason ↔
      Typed.execute registry store ctx env now request right = .error reason := by
  have h := execute_congr registry store ctx env now request left right region ha hr ht
  cases hl : Typed.execute registry store ctx env now request left <;>
    cases hh : Typed.execute registry store ctx env now request right <;>
    simp_all [ExecutionAgrees]

theorem execute_success_congr (registry : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (request : Request P A D) (left right : State P A D) (region : Set (Cell P A D))
    (ha : AgreeOn region left right)
    (hr : ∀ template, registry request.operation = some template →
      ResolvedReadsAgree template ctx.principal request.parties left right)
    (ht : ∀ template, registry request.operation = some template →
      TargetsWithin template ctx.principal request.parties region)
    (post : ExecutionResult P A D)
    (hx : Typed.execute registry store ctx env now request left = .ok post) :
    ∃ other, Typed.execute registry store ctx env now request right = .ok other ∧
      AgreeOn region post.state other.state ∧ post.capabilities = store ∧
      other.capabilities = store := by
  have h := execute_congr registry store ctx env now request left right region ha hr ht
  rw [hx] at h
  cases hh : Typed.execute registry store ctx env now request right with
  | error reason => simp [hh, ExecutionAgrees] at h
  | ok other =>
    rw [hh] at h
    have hp := execute_preserves_capabilities registry store ctx env now request left post hx
    have ho := execute_preserves_capabilities registry store ctx env now request right other hh
    exact ⟨other, rfl, h.1, hp, ho⟩

/-- Each success frames its own input outside potential targets, regardless of foreign balances. -/
theorem execute_target_frame (registry : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (request : Request P A D) (pre : State P A D) (post : ExecutionResult P A D)
    (region : Set (Cell P A D))
    (ht : ∀ template, registry request.operation = some template →
      TargetsWithin template ctx.principal request.parties region)
    (hx : Typed.execute registry store ctx env now request pre = .ok post) :
    ∀ c, c ∉ region → post.state.balance c = pre.balance c := by
  obtain ⟨template, hs, args, _, e, he, happly⟩ :=
    execute_evaluated registry store ctx env now request pre post hx
  have hp := (applyEvaluated_ok_iff store ctx request pre e post).mp happly
  intro c hc
  rw [hp.2.2 c, evaluated_effect_zero_outside template _ e he region (ht template hs) c hc]
  exact add_zero _

end DefiKernel.Parallel

## END FILE

## FILE lean/DefiKernel/Parallel/Dependency/Adapter.lean

Original SHA256: 10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c; bytes: 9887; rendered SHA256: 10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c

import DefiKernel.Parallel.Dependency
import DefiKernel.Parallel.Compatibility

/-! State dependence for the existing composition adapter, with same-prestate receipts and
selected post-state snapshots. Boundaries and local histories are identical inputs. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem prepareInvocation_shape (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (iface : OperationInterface P A D) (request : Request P A D)
    (h : prepareInvocation cfg boundary index history inv = .ok (iface, request)) :
    request.operation = inv.operation ∧ request.parties = inv.parties ∧
      ∃ component, lookupOperation cfg.catalog inv.component inv.operation =
        some (component, iface) := by
  unfold prepareInvocation at h
  simp only [bind, Except.bind, Except.mapError, pure, Except.pure] at h
  split at h
  · contradiction
  rename_i pair hl
  rcases pair with ⟨component, selected⟩
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  cases h
  exact ⟨rfl, rfl, component, hl⟩

theorem analyzed_dependencies (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (template : Template P A D) (hs : cfg.registry inv.operation = some template) :
    (∀ ref ∈ template.requiredStateReads, ∀ c,
      ref.2.resolve boundary.ctx.principal inv.parties = .ok c → c ∈ fp.reads) ∧
    TargetsWithin template boundary.ctx.principal inv.parties {c | c ∈ fp.writes} ∧
    (∀ c ∈ fp.writes, c ∈ fp.reads) := by
  obtain ⟨component, iface, selected, reads, writes, hl, ht, hr, hw, hc, rfl⟩ :=
    analyzeInvocation_ok cfg boundary inv fp hf
  rw [hs] at ht
  cases ht
  refine ⟨?_, ?_, ?_⟩
  · intro ref hm c hres
    obtain ⟨cell, hm', hres'⟩ := resolveRefs_member _ _ _ _ hr ref (by simp [hm])
    rw [hres] at hres'
    cases hres'
    simp [hm']
  · intro d hd c hres
    obtain ⟨cell, hm', hres'⟩ := resolveRefs_member _ _ _ _ hw ⟨d.asset, d.target⟩
      (List.mem_append_right _ (List.mem_map.mpr ⟨d, hd, rfl⟩))
    rw [hres] at hres'
    cases hres'
    exact hm'
  · intros
    simp_all

theorem analyzed_outputs (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (component : Component P A D) (iface : OperationInterface P A D)
    (hl : lookupOperation cfg.catalog inv.component inv.operation = some (component, iface)) :
    ∀ output ∈ iface.outputs, output.cell ∈ fp.reads := by
  obtain ⟨selected, si, template, reads, writes, hs, _, _, _, _, rfl⟩ :=
    analyzeInvocation_ok cfg boundary inv fp hf
  rw [hl] at hs
  cases hs
  intro output ho
  simp only [List.mem_append, List.mem_map]
  exact Or.inr ⟨output, ho, rfl⟩

theorem snapshots_congr (index : Nat) (component : ComponentId)
    (iface : OperationInterface P A D) (left right : State P A D)
    (h : ∀ output ∈ iface.outputs, left.balance output.cell = right.balance output.cell) :
    snapshots index component iface left = snapshots index component iface right := by
  unfold snapshots
  apply List.map_congr_left
  intro output ho
  simp only [h output ho]

theorem extractReceipt_congr (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (left right : World P A D)
    (hr : ∀ template, cfg.registry request.operation = some template →
      ResolvedReadsAgree template boundary.ctx.principal request.parties left.state right.state) :
    extractReceipt cfg boundary request left = extractReceipt cfg boundary request right := by
  unfold extractReceipt
  cases hs : cfg.registry request.operation with
  | none => rfl
  | some template =>
    simp only [bind, Except.bind]
    cases ha : Args.check template.signature request.arguments with
    | error reason => rfl
    | ok args =>
      simp only [Except.mapError, bind, Except.bind]
      rw [evaluate_congr template left.state right.state boundary.env boundary.ctx.principal
        request.parties args boundary.now (hr template hs)]

def StepAgrees (region : Set (Cell P A D)) :
    Except Failure (StepResult P A D) → Except Failure (StepResult P A D) → Prop
  | .error a, .error b => a = b
  | .ok a, .ok b => AgreeOn region a.world.state b.world.state ∧
      a.world.capabilities = b.world.capabilities ∧ a.receipt = b.receipt ∧ a.outputs = b.outputs
  | _, _ => False

theorem executeStep_congr (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (left right : World P A D) (fp : Footprint P A D) (region : Set (Cell P A D))
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (hin : ∀ c ∈ fp.reads, c ∈ region) (ha : AgreeOn region left.state right.state)
    (hcap : left.capabilities = right.capabilities) :
    StepAgrees region (executeStep cfg boundary index history (.invoke inv) left)
      (executeStep cfg boundary index history (.invoke inv) right) := by
  unfold executeStep
  by_cases hv : validateCatalog cfg.registry cfg.catalog = true
  · simp only [hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte, bind, Except.bind]
    cases hp : prepareInvocation cfg boundary index history inv with
    | error reason => rfl
    | ok pair =>
      rcases pair with ⟨iface, request⟩
      simp only [bind, Except.bind]
      obtain ⟨hop, hparties, component, hlookup⟩ := prepareInvocation_shape _ _ _ _ _ _ _ hp
      have hr : ∀ template, cfg.registry request.operation = some template →
          ResolvedReadsAgree template boundary.ctx.principal request.parties
            left.state right.state := by
        intro template hs ref href c hc
        rw [hop] at hs
        rw [hparties] at hc
        exact ha c (hin c ((analyzed_dependencies _ _ _ _ hf template hs).1 ref href c hc))
      have ht : ∀ template, cfg.registry request.operation = some template →
          TargetsWithin template boundary.ctx.principal request.parties region := by
        intro template hs d hd c hc
        rw [hop] at hs
        rw [hparties] at hc
        have dep := analyzed_dependencies _ _ _ _ hf template hs
        exact hin c (dep.2.2 c (dep.2.1 d hd c hc))
      have he := extractReceipt_congr cfg boundary request left right hr
      have hx := execute_congr cfg.registry left.capabilities boundary.ctx boundary.env boundary.now
        request left.state right.state region ha hr ht
      rw [← hcap]
      cases hleft : Typed.execute cfg.registry left.capabilities boundary.ctx boundary.env
          boundary.now request left.state <;>
        cases hright : Typed.execute cfg.registry left.capabilities boundary.ctx boundary.env
          boundary.now request right.state <;>
        simp only [hleft, hright, ExecutionAgrees] at hx
      · cases hx
        rfl
      · rename_i post other
        simp only [Except.mapError, bind, Except.bind]
        rw [← he]
        cases hrp : extractReceipt cfg boundary request left with
        | error reason => rfl
        | ok e =>
          exact ⟨hx.1, hx.2, rfl, snapshots_congr index inv.component iface _ _
            (fun output ho ↦ hx.1 output.cell
              (hin _ (analyzed_outputs _ _ _ _ hf _ _ hlookup output ho)))⟩
  · have hfalse : validateCatalog cfg.registry cfg.catalog = false := Bool.eq_false_iff.mpr hv
    simp only [hfalse, Bool.not_false, ↓reduceIte, bind, Except.bind]
    rfl

/-- Successful adapter execution changes only the analyzed write region. -/
theorem executeStep_target_frame (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (pre : World P A D) (result : StepResult P A D) (fp : Footprint P A D)
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (hx : executeStep cfg boundary index history (.invoke inv) pre = .ok result) :
    (∀ c, c ∉ fp.writes → result.world.state.balance c = pre.state.balance c) ∧
      result.world.capabilities = pre.capabilities := by
  have sound := executeStep_sound cfg boundary index history (.invoke inv) pre result hx
  cases sound with
  | invoke inv pre post iface request e hp he hex happly =>
    obtain ⟨hop, hparties, _⟩ := prepareInvocation_shape _ _ _ _ _ _ _ hp
    refine ⟨?_, execute_preserves_capabilities _ _ _ _ _ _ _ _ he⟩
    apply execute_target_frame cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state post {c | c ∈ fp.writes} _ he
    intro template hs
    rw [hop] at hs
    rw [hparties]
    exact (analyzed_dependencies _ _ _ _ hf template hs).2.1

theorem executeStep_refusal_iff (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (left right : World P A D) (fp : Footprint P A D) (region : Set (Cell P A D))
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (hin : ∀ c ∈ fp.reads, c ∈ region) (ha : AgreeOn region left.state right.state)
    (hcap : left.capabilities = right.capabilities) (reason : Failure) :
    executeStep cfg boundary index history (.invoke inv) left = .error reason ↔
      executeStep cfg boundary index history (.invoke inv) right = .error reason := by
  have h := executeStep_congr cfg boundary index history inv left right fp region hf hin ha hcap
  cases hl : executeStep cfg boundary index history (.invoke inv) left <;>
    cases hr : executeStep cfg boundary index history (.invoke inv) right <;>
    simp_all [StepAgrees]

end DefiKernel.Parallel

## END FILE

## FILE lean/DefiKernel/Parallel/Examples.lean

Original SHA256: d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd; bytes: 12560; rendered SHA256: d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd

import DefiKernel.Parallel.Execution
import DefiKernel.Typed.Examples

/-! Independent financial fixtures for binary parallel composition. Expected receipts and complete
ledger tables are written directly, without evaluating templates or selecting executor results. -/
namespace DefiKernel.Parallel.Examples
open Typed Composition Typed.Examples
abbrev C := Cell Party Asset Domain
abbrev W := World Party Asset Domain
abbrev I := Invocation Party Asset Domain
abbrev B := Branch Party Asset Domain
abbrev Evt := EventObservation Party Asset Domain
abbrev Obs := BranchObservation Party Asset Domain
abbrev R := Parallel.Result Party Asset Domain

def aliceUSD : C := (.main, .alice, .usd)
def bobUSD : C := (.main, .bob, .usd)
def vaultUSD : C := (.main, .vault, .usd)
def poolUSD : C := (.main, .pool, .usd)
def vaultShare : C := (.main, .vault, .share)
def aliceShare : C := (.main, .alice, .share)
def protectedCell : C := (.main, .alice, .collateral)
def cells : List C := [Domain.main, .other].flatMap fun d ↦
  [Party.alice, .bob, .vault, .pool].flatMap fun p ↦
    [Asset.usd, .share, .collateral, .debt].map fun a ↦ (d, p, a)
def cellRef (c : C) : CellRef Party Asset Domain c.2.2 := ⟨c.1, .literal c.2.1⟩
def packed (c : C) : PackedCellRef Party Asset Domain := ⟨c.2.2, cellRef c⟩

/-- Both numerical ports are zero, but their components differ. The provider grants exact
access to every cell so access checks cannot mask the intended compatibility controls. -/
def config (lt rt : Op) (lo ro : List C := []) : Config Party Asset Domain where
  registry id := if id = ⟨10⟩ then some lt else if id = ⟨11⟩ then some rt else none
  domainAdmin := domainAdmin
  catalog := [
    ⟨⟨0⟩, [], [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨⟨2⟩, ⟨n⟩⟩, c, true⟩),
      [⟨⟨10⟩, lt.signature.zipIdx.map (fun (u, n) ↦ ⟨⟨n + 10⟩, u⟩),
        lo.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c⟩)⟩]⟩,
    ⟨⟨1⟩, [], [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨⟨2⟩, ⟨n⟩⟩, c, true⟩),
      [⟨⟨11⟩, rt.signature.zipIdx.map (fun (u, n) ↦ ⟨⟨n + 10⟩, u⟩),
        ro.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c⟩)⟩]⟩,
    ⟨⟨2⟩, [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c, true⟩), [], []⟩]

def transferTemplate (a : Asset) (sender recipient : PartyRef Party) : Op where
  signature := [.amount a]
  domain := .main
  partyArity := 0
  guard := nonnegative a (.arg .here)
  deltas := [⟨a, ref a sender, negate a (.arg .here)⟩,
    ⟨a, ref a recipient, .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedRef a sender, packedRef a recipient]
def usdTransfer := transferTemplate .usd (.literal .alice) (.literal .bob)
def shareTransfer := transferTemplate .share (.literal .vault) (.literal .alice)
def peerUSDTransfer := transferTemplate .usd (.literal .vault) (.literal .pool)
def cfg := config usdTransfer shareTransfer [bobUSD] [aliceShare]
def sameAssetCfg := config usdTransfer peerUSDTransfer [bobUSD] [poolUSD]

def store : Store := ⟨[
  ⟨⟨.alice, .main, ⟨10⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨10⟩, .debit aliceUSD⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .debit vaultShare⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .debit vaultUSD⟩, true⟩,
  ⟨⟨.alice, .main, ⟨10⟩, .changeSupply .main .usd⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .changeSupply .main .share⟩, true⟩,
  ⟨⟨.bob, .main, ⟨10⟩, .invoke⟩, true⟩,
  ⟨⟨.bob, .main, ⟨10⟩, .debit bobUSD⟩, true⟩,
  ⟨⟨.vault, .main, ⟨11⟩, .invoke⟩, true⟩,
  ⟨⟨.vault, .main, ⟨11⟩, .debit vaultShare⟩, true⟩,
  ⟨⟨.alice, .main, ⟨10⟩, .debit vaultUSD⟩, true⟩]⟩
def caps : List CapabilityId := (List.range 12).map CapabilityId.mk

def balanceTable (au bu vs ash : ℚ) (vu : ℚ := 20) (pu : ℚ := 1) : C → ℚ := fun c ↦
  if c = aliceUSD then au else if c = bobUSD then bu else if c = vaultShare then vs
  else if c = aliceShare then ash else if c = vaultUSD then vu else if c = poolUSD then pu
  else if c = protectedCell then 9 else 0

def initial : W := ⟨⟨balanceTable 10 0 20 0, by
  intro c
  simp only [balanceTable]
  repeat' split
  all_goals decide⟩, store⟩
def boundaries (_ : BranchId) (_ : Nat) : Boundary Party Asset Domain :=
  ⟨aliceContext, fresh, 100⟩

def invoke (component op : Nat) (a : Asset) (q : ℚ) : I :=
  ⟨⟨component⟩, ⟨op⟩, [], [.literal ⟨.amount a, q⟩], caps, none⟩
def usd (q : ℚ) := invoke 0 10 .usd q
def shares (q : ℚ) := invoke 1 11 .share q
def peerUSD (q : ℚ) := invoke 1 11 .usd q

def source (inv : I) (component : Nat) : I :=
  { inv with inputs := [.priorOutput 0 ⟨⟨component⟩, ⟨0⟩⟩] }

def output (index component : Nat) (a : Asset) (q : ℚ) : OutputObservation Asset :=
  ⟨index, ⟨⟨component⟩, ⟨0⟩⟩, ⟨.amount a, q⟩⟩

def evaluatedTransfer (sender recipient : C) (q : ℚ) : Evaluated Party Asset Domain :=
  ⟨true, [(sender, -q), (recipient, q)], [], [], [], [], [], [sender, recipient]⟩
def event (index : Nat) (inv : I) (args : List (PackedValue Asset))
    (evaluated : Evaluated Party Asset Domain) (outputs : List (OutputObservation Asset)) : Evt :=
  ⟨index, .invoke inv,
    .invoked ⟨inv.operation, inv.parties, args, inv.capabilityIds, inv.claimedActor⟩ evaluated,
    outputs⟩
def transferEvent (index : Nat) (inv : I) (sender recipient : C) (q : ℚ)
    (outputs : List (OutputObservation Asset)) : Evt :=
  event index inv [⟨.amount sender.2.2, q⟩] (evaluatedTransfer sender recipient q) outputs

def observed (events : List Evt)
    (failure : Option (LocatedFailure Party Asset Domain) := none) : Obs :=
  ⟨events, events.flatMap EventObservation.outputs, events.length, failure⟩
def failure (index : Nat) (inv : I) (reason : Composition.Failure) :
    Option (LocatedFailure Party Asset Domain) := some ⟨index, some (.invoke inv), reason⟩
def leftEvent (index : Nat) (q after : ℚ) : Evt :=
  transferEvent index (usd q) aliceUSD bobUSD q [output index 0 .usd after]
def rightEvent (index : Nat) (q after : ℚ) : Evt :=
  transferEvent index (shares q) vaultShare aliceShare q [output index 1 .share after]
def peerEvent (index : Nat) (q after : ℚ) : Evt :=
  transferEvent index (peerUSD q) vaultUSD poolUSD q [output index 1 .usd after]

def matchesExpected (actual : R) (balance : C → ℚ) (expectedLeft expectedRight : Obs)
    (expectedStore : Store := store) : Bool :=
  match actual with
  | .refused _ _ => false
  | .executed result =>
    decide ((∀ c, result.world.state.balance c = balance c) ∧
      result.world.capabilities = expectedStore ∧
      result.left.world.capabilities = expectedStore ∧
      result.right.world.capabilities = expectedStore ∧
      observeBranch result.left = expectedLeft ∧ observeBranch result.right = expectedRight)

def basicLeft : Obs := observed [leftEvent 0 3 3]
def basicRight : Obs := observed [rightEvent 0 4 4]

def supplyTemplate (a : Asset) (owner : Party) : Op where
  signature := [.amount a]
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := [⟨a, ref a (.literal owner), .arg .here⟩]
  supplyDeltas := [⟨.main, a, .arg .here⟩]
  stateReads := []
  envReads := []
  writes := [packedRef a (.literal owner)]
def supplyCfg := config (supplyTemplate .usd .alice) (supplyTemplate .share .vault)
  [aliceUSD] [vaultShare]
def supplyEvent (index : Nat) (inv : I) (cell : C) (q post : ℚ) : Evt :=
  event index inv [⟨.amount cell.2.2, q⟩]
    ⟨true, [(cell, q)], [((cell.1, cell.2.2), q)], [], [], [], [], [cell]⟩
    [output index inv.component.value cell.2.2 post]

def statefulTransfer : Op := { usdTransfer with
  guard := .binary (.le (.amount .usd)) (.lit 4) (.balance (cellRef aliceUSD))
  deltas := [⟨.usd, cellRef aliceUSD, .binary (.scale (.amount Asset.usd))
    (.lit (-1 / 2 : ℚ)) (.balance (cellRef aliceUSD))⟩,
    ⟨.usd, cellRef bobUSD, .binary (.scale (.amount Asset.usd))
      (.lit (1 / 2 : ℚ)) (.balance (cellRef aliceUSD))⟩]
  stateReads := [packed aliceUSD] }
def statefulCfg := config statefulTransfer shareTransfer [bobUSD] [aliceShare]
def statefulEvent (index : Nat) (amount post : ℚ) : Evt :=
  event index (usd 0) [⟨.amount .usd, 0⟩]
    { evaluatedTransfer aliceUSD bobUSD amount with
      requiredStateReads := [aliceUSD, aliceUSD, aliceUSD]
      declaredStateReads := [aliceUSD] }
    [output index 0 .usd post]

/-- State-dependent mint amount appears independently in both delta and supply evaluation. -/
def statefulSupply : Op := { supplyTemplate .share .vault with
  deltas := [⟨.share, cellRef vaultShare,
    .binary (.scale (.amount Asset.share)) (.lit (1 / 2 : ℚ)) (.balance (cellRef vaultShare))⟩]
  supplyDeltas := [⟨.main, .share,
    .binary (.scale (.amount Asset.share)) (.lit (1 / 2 : ℚ)) (.balance (cellRef vaultShare))⟩]
  stateReads := [packed vaultShare] }
def statefulSupplyEvent (index : Nat) (amount post : ℚ) : Evt :=
  event index (shares 0) [⟨.amount .share, 0⟩]
    ⟨true, [(vaultShare, amount)], [((.main, .share), amount)],
      [vaultShare, vaultShare], [], [vaultShare], [], [vaultShare]⟩
    [output index 1 .share post]

/-- Temporal values constrain the trusted invocation boundary; they do not set a price. -/
def timedTemplate (a : Asset) : Op where
  signature := [.amount a, .scalar]
  domain := .main
  partyArity := 1
  guard := .binary (.eq .scalar) .now (.arg (.there .here))
  deltas := [⟨a, ref a .caller, negate a (.arg .here)⟩,
    ⟨a, ref a (.argument 0), .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := [.currentTime]
  writes := [packedRef a .caller, packedRef a (.argument 0)]
def timedCfg := config (timedTemplate .usd) (timedTemplate .share) [bobUSD] [aliceShare]
def timedBoundaries (branch : BranchId) (index : Nat) : Boundary Party Asset Domain :=
  match branch with
  | .left => ⟨⟨if index = 0 then .alice else .bob, .main⟩, fresh, 100 + index⟩
  | .right => ⟨⟨.vault, .main⟩, fresh, 200 + index⟩
def timedInvocation (component op : Nat) (a : Asset) (q time : ℚ) (recipient : Party) : I :=
  ⟨⟨component⟩, ⟨op⟩, [recipient],
    [.literal ⟨.amount a, q⟩, .literal ⟨.scalar, time⟩], caps, none⟩
def timedLeft : B := [timedInvocation 0 10 .usd 3 100 .bob,
  timedInvocation 0 10 .usd 1 101 .alice]
def timedRight : B := [timedInvocation 1 11 .share 4 200 .alice,
  timedInvocation 1 11 .share 2 201 .alice]
def timedEvent (index : Nat) (inv : I) (sender recipient : C) (q time post : ℚ) : Evt :=
  event index inv [⟨.amount sender.2.2, q⟩, ⟨.scalar, time⟩]
    { evaluatedTransfer sender recipient q with
      requiredEnvReads := [.currentTime], declaredEnvReads := [.currentTime] }
    [output index inv.component.value sender.2.2 post]
def timedExpectedLeft := observed [
  timedEvent 0 (timedInvocation 0 10 .usd 3 100 .bob) aliceUSD bobUSD 3 100 3,
  timedEvent 1 (timedInvocation 0 10 .usd 1 101 .alice) bobUSD aliceUSD 1 101 2]
def timedExpectedRight := observed [
  timedEvent 0 (timedInvocation 1 11 .share 4 200 .alice) vaultShare aliceShare 4 200 4,
  timedEvent 1 (timedInvocation 1 11 .share 2 201 .alice) vaultShare aliceShare 2 201 6]


def noOp : Op where
  signature := []
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := []
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := []
def noOpInvocation : I := { usd 0 with inputs := [] }
def noOpEvaluated : Evaluated Party Asset Domain := ⟨true, [], [], [], [], [], [], []⟩
def sharedReadCfg := config noOp noOp [protectedCell] []
def sharedReadExpected := observed [event 0 noOpInvocation [] noOpEvaluated
  [output 0 0 .collateral 9]]
def paramTemplate : Op := { transferTemplate .usd (.argument 0) (.argument 1) with
  partyArity := 2 }
def reusableCfg := config paramTemplate shareTransfer

def revokedStore : Store := ⟨store.entries.set 2 ⟨⟨.alice, .main, ⟨11⟩, .invoke⟩, false⟩⟩
def revokedInitial : W := ⟨initial.state, revokedStore⟩

def cancelling : Op := { noOp with
  deltas := [⟨.usd, cellRef aliceUSD, .lit 1⟩, ⟨.usd, cellRef aliceUSD, .lit (-1)⟩] }
def cancellingInvocation : I := { shares 0 with inputs := [] }
def cancellingExpected : Obs := observed [event 0 cancellingInvocation []
  ⟨true, [(aliceUSD, 1), (aliceUSD, -1)], [], [], [], [], [], []⟩ []]

end DefiKernel.Parallel.Examples

## END FILE

## FILE lean/DefiKernel/Parallel/Execution.lean

Original SHA256: a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089; bytes: 7916; rendered SHA256: a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089

import DefiKernel.Parallel.Compatibility
import DefiKernel.Parallel.Observation

/-! Binary fork/join over invocation-only branches. Each branch retains its own successful
prefix and refusal. Serial references rerun the existing executor with fresh local histories. -/
namespace DefiKernel.Parallel
open Typed Composition

structure Joined (P A D : Type) where
  world : World P A D
  left : Cursor P A D
  right : Cursor P A D

inductive Result (P A D : Type) where
  | refused (reason : AdmissionFailure P A D) (world : World P A D)
  | executed (joined : Joined P A D)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- An admitted region chooses one complete balance, never a sum of branch base balances. -/
def mergeWorld (leftFootprint rightFootprint : Footprint P A D)
    (initial left right : World P A D) : World P A D :=
  ⟨⟨fun c ↦ if c ∈ leftFootprint.writes then left.state.balance c
      else if c ∈ rightFootprint.writes then right.state.balance c
      else initial.state.balance c,
    fun c ↦ by
      split
      · exact left.state.nonneg c
      · split
        · exact right.state.nonneg c
        · exact initial.state.nonneg c⟩,
    initial.capabilities⟩

def runBranch (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) : Cursor P A D :=
  Composition.run cfg boundary initial (branch.map Step.invoke)

def runParallel (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) : Result P A D :=
  match admit cfg boundaries left right with
  | .error reason => .refused reason initial
  | .ok (leftFootprint, rightFootprint) =>
    let l := runBranch cfg (boundaries .left) initial left
    let r := runBranch cfg (boundaries .right) initial right
    .executed ⟨mergeWorld leftFootprint rightFootprint initial l.world r.world, l, r⟩

/-- Right always runs after left's retained prefix, including when left has refused. -/
def runSerialLR (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) : Result P A D :=
  match admit cfg boundaries left right with
  | .error reason => .refused reason initial
  | .ok _ =>
    let l := runBranch cfg (boundaries .left) initial left
    let r := runBranch cfg (boundaries .right) l.world right
    .executed ⟨r.world, l, r⟩

/-- Evaluation order changes; branch labels, local history and trusted positions do not. -/
def runSerialRL (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) : Result P A D :=
  match admit cfg boundaries left right with
  | .error reason => .refused reason initial
  | .ok _ =>
    let r := runBranch cfg (boundaries .right) initial right
    let l := runBranch cfg (boundaries .left) r.world left
    .executed ⟨l.world, l, r⟩

/-- Pointwise full-ledger equality plus exact capability-store equality. -/
def WorldEquivalent (left right : World P A D) : Prop :=
  (∀ c, left.state.balance c = right.state.balance c) ∧
    left.capabilities = right.capabilities

/-- Raw event worlds are omitted, but every financial and local refusal observation is kept. -/
def ObservationallyEquivalent (left right : Result P A D) : Prop :=
  match left, right with
  | .refused le lw, .refused re rw => le = re ∧ WorldEquivalent lw rw
  | .executed l, .executed r => WorldEquivalent l.world r.world ∧
      observeBranch l.left = observeBranch r.left ∧
      observeBranch l.right = observeBranch r.right
  | _, _ => False

def worldEq (left right : World P A D) : Bool :=
  decide ((∀ c, left.state.balance c = right.state.balance c) ∧
    left.capabilities = right.capabilities)

def observationsEqual (left right : Result P A D) : Bool :=
  match left, right with
  | .refused le lw, .refused re rw => decide (le = re) && worldEq lw rw
  | .executed l, .executed r => worldEq l.world r.world &&
      decide (observeBranch l.left = observeBranch r.left) &&
      decide (observeBranch l.right = observeBranch r.right)
  | _, _ => false

-- BEGIN PROOFS

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_store (lf rf : Footprint P A D) (initial left right : World P A D) :
    (mergeWorld lf rf initial left right).capabilities = initial.capabilities := rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_nonnegative (lf rf : Footprint P A D)
    (initial left right : World P A D) (c : Cell P A D) :
    0 ≤ (mergeWorld lf rf initial left right).state.balance c :=
  (mergeWorld lf rf initial left right).state.nonneg c

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_outside (lf rf : Footprint P A D) (initial left right : World P A D)
    (c : Cell P A D) (hl : c ∉ lf.writes) (hr : c ∉ rf.writes) :
    (mergeWorld lf rf initial left right).state.balance c = initial.state.balance c := by
  simp [mergeWorld, hl, hr]

theorem worldEq_iff (left right : World P A D) :
    worldEq left right = true ↔ WorldEquivalent left right := by simp [worldEq, WorldEquivalent]

theorem observationsEqual_iff (left right : Result P A D) :
    observationsEqual left right = true ↔ ObservationallyEquivalent left right := by
  cases left <;> cases right <;>
    simp [observationsEqual, ObservationallyEquivalent, worldEq, WorldEquivalent, and_assoc]

theorem runParallel_refuses (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (reason : AdmissionFailure P A D)
    (h : admit cfg boundaries left right = .error reason) :
    runParallel cfg boundaries initial left right = .refused reason initial := by
  simp [runParallel, h]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem WorldEquivalent.refl (world : World P A D) : WorldEquivalent world world :=
  ⟨fun _ ↦ rfl, rfl⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem WorldEquivalent.symm {left right : World P A D} (h : WorldEquivalent left right) :
    WorldEquivalent right left := ⟨fun c ↦ (h.1 c).symm, h.2.symm⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem WorldEquivalent.trans {first middle last : World P A D}
    (h : WorldEquivalent first middle) (g : WorldEquivalent middle last) :
    WorldEquivalent first last := ⟨fun c ↦ (h.1 c).trans (g.1 c), h.2.trans g.2⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem ObservationallyEquivalent.refl (result : Result P A D) :
    ObservationallyEquivalent result result := by
  cases result with
  | refused reason world => exact ⟨rfl, .refl world⟩
  | executed joined => exact ⟨.refl joined.world, rfl, rfl⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem ObservationallyEquivalent.symm {left right : Result P A D}
    (h : ObservationallyEquivalent left right) : ObservationallyEquivalent right left := by
  cases left <;> cases right
  · exact ⟨h.1.symm, h.2.symm⟩
  · exact h.elim
  · exact h.elim
  · exact ⟨h.1.symm, h.2.1.symm, h.2.2.symm⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem ObservationallyEquivalent.trans {first middle last : Result P A D}
    (h : ObservationallyEquivalent first middle) (g : ObservationallyEquivalent middle last) :
    ObservationallyEquivalent first last := by
  cases first <;> cases middle <;> cases last
  · exact ⟨h.1.trans g.1, h.2.trans g.2⟩
  · exact g.elim
  · exact h.elim
  · exact h.elim
  · exact h.elim
  · exact h.elim
  · exact g.elim
  · exact ⟨h.1.trans g.1, h.2.1.trans g.2.1, h.2.2.trans g.2.2⟩

end DefiKernel.Parallel

## END FILE

## FILE lean/DefiKernel/Parallel/Observation.lean

Original SHA256: 38018fbcfb37c08181fbce37b75050077c3dc19d8bee6c0975b7898447ccb84f; bytes: 2156; rendered SHA256: 38018fbcfb37c08181fbce37b75050077c3dc19d8bee6c0975b7898447ccb84f

import DefiKernel.Composition.Sequence

/-! Branch observations retain every request, receipt, output, and refusal field.
Raw event worlds belong to execution evidence and are deliberately not equated across orders. -/
namespace DefiKernel.Parallel
open Typed Composition

-- These computational equality instances do not alter the existing execution definitions.
deriving instance DecidableEq for Composition.InputSource
deriving instance DecidableEq for Composition.Invocation
deriving instance DecidableEq for Composition.Step
deriving instance DecidableEq for Typed.Request
deriving instance DecidableEq for Typed.Evaluated
deriving instance DecidableEq for Composition.Receipt
deriving instance DecidableEq for Composition.OutputObservation
deriving instance DecidableEq for Composition.LocatedFailure

structure EventObservation (P A D : Type) where
  index : Nat
  step : Step P A D
  receipt : Receipt P A D
  outputs : List (OutputObservation A)
  deriving DecidableEq

structure BranchObservation (P A D : Type) where
  events : List (EventObservation P A D)
  outputs : List (OutputObservation A)
  nextIndex : Nat
  failure : Option (LocatedFailure P A D)
  deriving DecidableEq

def observeEvent {P A D : Type} (event : Event P A D) : EventObservation P A D :=
  ⟨event.index, event.step, event.result.receipt, event.result.outputs⟩

def observeBranch {P A D : Type} (cursor : Cursor P A D) : BranchObservation P A D :=
  ⟨cursor.events.map observeEvent, cursor.outputs, cursor.nextIndex, cursor.failure⟩

-- BEGIN PROOFS

/-- Equality of canonical branch observations includes the exact failure location and step. -/
theorem observeBranch_failure {P A D : Type} {left right : Cursor P A D}
    (h : observeBranch left = observeBranch right) : left.failure = right.failure :=
  congrArg BranchObservation.failure h

/-- Histories are compared as ordered, typed snapshots, not as an unqualified value multiset. -/
theorem observeBranch_outputs {P A D : Type} {left right : Cursor P A D}
    (h : observeBranch left = observeBranch right) : left.outputs = right.outputs :=
  congrArg BranchObservation.outputs h

end DefiKernel.Parallel

## END FILE

## FILE lean/DefiKernel/Typed/Authority.lean

Original SHA256: dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb; bytes: 13533; rendered SHA256: dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb

import DefiKernel.Typed.Types

/-! Nondelegating capability administration under a trusted actor, domain administrator and
operation-domain lookup. List positions are permanent IDs: revoked entries remain as tombstones.
Authentication, registry truth, allowances and replay prevention are outside this model. -/
namespace DefiKernel.Typed

inductive Right (Party Asset Domain : Type) where
  | invoke
  | debit (cell : Cell Party Asset Domain)
  | changeSupply (domain : Domain) (asset : Asset)
  deriving DecidableEq, Repr

def Right.inDomain {Party Asset Domain : Type} [DecidableEq Domain]
    (right : Right Party Asset Domain) (domain : Domain) : Bool :=
  match right with
  | .invoke => true
  | .debit cell => decide (cell.1 = domain)
  | .changeSupply d _ => decide (d = domain)

structure Grant (Party Asset Domain : Type) where
  holder : Party
  domain : Domain
  operation : OperationId
  right : Right Party Asset Domain
  deriving DecidableEq, Repr

structure Capability (Party Asset Domain : Type) extends Grant Party Asset Domain where
  live : Bool
  deriving DecidableEq, Repr

/-- The adapter supplies this immutable configuration, separately from caller requests. -/
structure AuthorityConfig (Party Domain : Type) where
  domainAdmin : Domain → Party
  operationDomain : OperationId → Option Domain

/-- No entry is removed; length is the next fresh ID, so no separate counter invariant is needed. -/
structure CapabilityStore (Party Asset Domain : Type) where
  entries : List (Capability Party Asset Domain)
  deriving DecidableEq, Repr

def CapabilityStore.empty {Party Asset Domain : Type} : CapabilityStore Party Asset Domain := ⟨[]⟩

def CapabilityStore.nextId {Party Asset Domain : Type}
    (store : CapabilityStore Party Asset Domain) : CapabilityId := ⟨store.entries.length⟩

def CapabilityStore.lookup {Party Asset Domain : Type}
    (store : CapabilityStore Party Asset Domain) (id : CapabilityId) := store.entries[id.value]?

inductive AuthorityFailure where
  | unauthorizedAdmin
  | operationDomain
  | resourceDomain
  | unknownCapability
  deriving DecidableEq, Repr

variable {Party Asset Domain : Type}
variable [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain]

def isDomainAdmin (config : AuthorityConfig Party Domain) (ctx : InvocationContext Party Domain)
    (domain : Domain) : Bool :=
  decide (ctx.domain = domain ∧ ctx.principal = config.domainAdmin domain)

/-- A grant cannot choose its ID or reactivate an existing entry. -/
def issueCapability (config : AuthorityConfig Party Domain) (ctx : InvocationContext Party Domain)
    (store : CapabilityStore Party Asset Domain) (grant : Grant Party Asset Domain) :
    Except AuthorityFailure (CapabilityId × CapabilityStore Party Asset Domain) :=
  if isDomainAdmin config ctx grant.domain then
    if config.operationDomain grant.operation = some grant.domain then
      if grant.right.inDomain grant.domain then
        .ok (store.nextId, ⟨store.entries ++ [⟨grant, true⟩]⟩)
      else .error .resourceDomain
    else .error .operationDomain
  else .error .unauthorizedAdmin

/-- Revocation is idempotent and retains the ID permanently, including its original scope. -/
def revokeCapability (config : AuthorityConfig Party Domain) (ctx : InvocationContext Party Domain)
    (store : CapabilityStore Party Asset Domain) (id : CapabilityId) :
    Except AuthorityFailure (CapabilityStore Party Asset Domain) :=
  match store.lookup id with
  | none => .error .unknownCapability
  | some cap =>
    if isDomainAdmin config ctx cap.domain then
      .ok ⟨store.entries.set id.value { cap with live := false }⟩
    else .error .unauthorizedAdmin

/-- Each supplied ID must itself pass all scope checks to contribute an exact right. -/
def authorizesId (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (operation : OperationId)
    (right : Right Party Asset Domain) (id : CapabilityId) : Bool :=
  match store.lookup id with
  | none => false
  | some cap => decide (cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = operation ∧ cap.right = right ∧
      right.inDomain ctx.domain = true)

/-- Existential use means duplicate request IDs confer no additional rights. -/
def hasAuthority (store : CapabilityStore Party Asset Domain)
    (ids : List CapabilityId) (ctx : InvocationContext Party Domain)
    (operation : OperationId) (right : Right Party Asset Domain) : Bool :=
  ids.any (authorizesId store ctx operation right)

-- BEGIN PROOFS

omit [DecidableEq Asset] in
theorem issueCapability_ok_iff (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id : CapabilityId)
    (post : CapabilityStore Party Asset Domain) :
    issueCapability config ctx store grant = .ok (id, post) ↔
      isDomainAdmin config ctx grant.domain = true ∧
      config.operationDomain grant.operation = some grant.domain ∧
      grant.right.inDomain grant.domain = true ∧
      id = store.nextId ∧ post = ⟨store.entries ++ [⟨grant, true⟩]⟩ := by
  unfold issueCapability
  split <;> simp_all
  split <;> simp_all
  split <;> simp_all
  aesop

omit [DecidableEq Asset] in
theorem issueCapability_admin (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id : CapabilityId)
    (post : CapabilityStore Party Asset Domain)
    (h : issueCapability config ctx store grant = .ok (id, post)) :
    ctx.domain = grant.domain ∧ ctx.principal = config.domainAdmin grant.domain := by
  simpa [isDomainAdmin] using (issueCapability_ok_iff ..).mp h |>.1

omit [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain] in
theorem lookup_nextId (store : CapabilityStore Party Asset Domain) :
    store.lookup store.nextId = none := by simp [CapabilityStore.lookup, CapabilityStore.nextId]

omit [DecidableEq Asset] in
theorem issueCapability_fresh (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id : CapabilityId)
    (post : CapabilityStore Party Asset Domain)
    (h : issueCapability config ctx store grant = .ok (id, post)) :
    store.lookup id = none ∧ post.lookup id = some ⟨grant, true⟩ ∧
      post.nextId.value = store.nextId.value + 1 := by
  obtain ⟨_, _, _, rfl, rfl⟩ := (issueCapability_ok_iff ..).mp h
  simp [CapabilityStore.lookup, CapabilityStore.nextId]

omit [DecidableEq Asset] in
theorem issueCapability_preserves_other (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id other : CapabilityId)
    (post : CapabilityStore Party Asset Domain)
    (h : issueCapability config ctx store grant = .ok (id, post)) (hne : other ≠ id) :
    post.lookup other = store.lookup other := by
  obtain ⟨_, _, _, rfl, rfl⟩ := (issueCapability_ok_iff ..).mp h
  have hn : other.value ≠ store.entries.length := by
    intro he
    apply hne
    cases other
    simp_all [CapabilityStore.nextId]
  simp only [CapabilityStore.lookup, List.getElem?_append]
  split
  · rfl
  · rename_i hge
    have ht : store.entries.length < other.value := by omega
    have hz : other.value - store.entries.length ≠ 0 := by omega
    simp [List.getElem?_eq_none (by omega : store.entries.length ≤ other.value), hz]

omit [DecidableEq Asset] in
theorem issueCapability_ne_existing (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id old : CapabilityId)
    (post : CapabilityStore Party Asset Domain) (cap : Capability Party Asset Domain)
    (h : issueCapability config ctx store grant = .ok (id, post))
    (hold : store.lookup old = some cap) : id ≠ old := by
  intro he
  have hf := (issueCapability_fresh config ctx store grant id post h).1
  rw [he, hold] at hf
  contradiction

omit [DecidableEq Asset] in
theorem revokeCapability_ok_iff (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id : CapabilityId) (post : CapabilityStore Party Asset Domain) :
    revokeCapability config ctx store id = .ok post ↔
      ∃ cap, store.lookup id = some cap ∧ isDomainAdmin config ctx cap.domain = true ∧
        post = ⟨store.entries.set id.value { cap with live := false }⟩ := by
  unfold revokeCapability
  split <;> simp_all
  split <;> simp_all
  aesop

omit [DecidableEq Asset] in
theorem revokeCapability_admin (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id : CapabilityId) (post : CapabilityStore Party Asset Domain)
    (h : revokeCapability config ctx store id = .ok post) :
    ∃ cap, store.lookup id = some cap ∧ ctx.domain = cap.domain ∧
      ctx.principal = config.domainAdmin cap.domain := by
  obtain ⟨cap, hc, ha, _⟩ := (revokeCapability_ok_iff ..).mp h
  exact ⟨cap, hc, by simpa [isDomainAdmin] using ha⟩

omit [DecidableEq Asset] in
theorem revokeCapability_tombstone (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id : CapabilityId) (post : CapabilityStore Party Asset Domain)
    (h : revokeCapability config ctx store id = .ok post) :
    ∃ cap, store.lookup id = some cap ∧
      post.lookup id = some { cap with live := false } ∧ post.nextId = store.nextId := by
  obtain ⟨cap, hc, _, rfl⟩ := (revokeCapability_ok_iff ..).mp h
  have hi : id.value < store.entries.length := by
    by_contra hn
    have hn' : store.entries.length ≤ id.value := by omega
    simp [CapabilityStore.lookup, List.getElem?_eq_none hn'] at hc
  exact ⟨cap, hc, by simp [CapabilityStore.lookup, hi], by simp [CapabilityStore.nextId]⟩

omit [DecidableEq Asset] in
theorem revokeCapability_preserves_other (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id other : CapabilityId) (post : CapabilityStore Party Asset Domain)
    (h : revokeCapability config ctx store id = .ok post) (hne : other ≠ id) :
    post.lookup other = store.lookup other := by
  obtain ⟨cap, _, _, rfl⟩ := (revokeCapability_ok_iff ..).mp h
  have hn : id.value ≠ other.value := by
    intro he
    apply hne
    cases id
    cases other
    simp_all
  simp [CapabilityStore.lookup, List.getElem?_set_ne hn]

theorem authorizesId_iff (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (operation : OperationId)
    (right : Right Party Asset Domain) (id : CapabilityId) :
    authorizesId store ctx operation right id = true ↔
      ∃ cap, store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
        cap.domain = ctx.domain ∧ cap.operation = operation ∧ cap.right = right ∧
        right.inDomain ctx.domain = true := by
  unfold authorizesId
  split <;> simp_all

theorem hasAuthority_iff (store : CapabilityStore Party Asset Domain) (ids : List CapabilityId)
    (ctx : InvocationContext Party Domain) (operation : OperationId)
    (right : Right Party Asset Domain) :
    hasAuthority store ids ctx operation right = true ↔
      ∃ id ∈ ids, authorizesId store ctx operation right id = true := by
  simp [hasAuthority]

theorem hasAuthority_duplicate (store : CapabilityStore Party Asset Domain)
    (ids : List CapabilityId) (id : CapabilityId) (ctx : InvocationContext Party Domain)
    (operation : OperationId) (right : Right Party Asset Domain) :
    hasAuthority store (id :: id :: ids) ctx operation right =
      hasAuthority store (id :: ids) ctx operation right := by
  simp [hasAuthority]

theorem revokeCapability_cannot_use (config : AuthorityConfig Party Domain)
    (adminCtx ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id : CapabilityId) (post : CapabilityStore Party Asset Domain)
    (operation : OperationId) (right : Right Party Asset Domain)
    (h : revokeCapability config adminCtx store id = .ok post) :
    authorizesId post ctx operation right id = false := by
  obtain ⟨cap, _, hc, _⟩ := revokeCapability_tombstone config adminCtx store id post h
  simp [authorizesId, hc]

/-- Reissuing authority leaves every existing revoked ID unusable. -/
theorem issueCapability_keeps_revoked (config : AuthorityConfig Party Domain)
    (adminCtx ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id old : CapabilityId)
    (post : CapabilityStore Party Asset Domain) (cap : Capability Party Asset Domain)
    (operation : OperationId) (right : Right Party Asset Domain)
    (h : issueCapability config adminCtx store grant = .ok (id, post))
    (hold : store.lookup old = some cap) (hdead : cap.live = false) :
    authorizesId post ctx operation right old = false := by
  have hne := issueCapability_ne_existing config adminCtx store grant id old post cap h hold
  have hp := issueCapability_preserves_other config adminCtx store grant id old post h hne.symm
  simp [authorizesId, hp, hold, hdead]

end DefiKernel.Typed

## END FILE

## FILE lean/DefiKernel/Typed/Examples.lean

Original SHA256: 640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41; bytes: 10774; rendered SHA256: 640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41

import DefiKernel.Typed.Transition

/-! Registered reference financial libraries. Exact rates and declared locked collateral are
model assumptions, not deployed-contract fidelity or market-solvency claims. -/
namespace DefiKernel.Typed
namespace Examples

inductive Party where
  | alice | bob | vault | pool
  deriving DecidableEq, Repr

inductive Asset where
  | usd | share | collateral | debt
  deriving DecidableEq, Repr

inductive Domain where
  | main | other
  deriving DecidableEq, Repr

instance : Fintype Party := ⟨{.alice, .bob, .vault, .pool}, by
  intro p; cases p <;> simp⟩
instance : Fintype Asset := ⟨{.usd, .share, .collateral, .debt}, by
  intro a; cases a <;> simp⟩
instance : Fintype Domain := ⟨{.main, .other}, by intro d; cases d <;> simp⟩

abbrev Ledger := State Party Asset Domain
abbrev Store := CapabilityStore Party Asset Domain
abbrev Op := Template Party Asset Domain
abbrev Call := Request Party Asset Domain
abbrev Result := ExecutionResult Party Asset Domain
abbrev E (signature : List (Unit Asset)) := Expr Party Asset Domain signature

/-- Original reference balances on main; every other-domain balance is zero. -/
def initial : Ledger where
  balance c := match c with
    | (.main, .alice, .usd) => 10
    | (.main, .alice, .share) => 4
    | (.main, .alice, .collateral) => 10
    | (.main, .alice, .debt) => 2
    | (.main, .vault, .usd) => 20
    | (.main, .pool, .usd) => 100
    | _ => 0
  nonneg c := by
    rcases c with ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> decide

def ref (a : Asset) (owner : PartyRef Party) : CellRef Party Asset Domain a :=
  ⟨.main, owner⟩

def packedRef (a : Asset) (owner : PartyRef Party) : PackedCellRef Party Asset Domain :=
  ⟨a, ref a owner⟩

def allGuards {signature : List (Unit Asset)} : List (E signature .bool) → E signature .bool
  | [] => .lit true
  | g :: gs => .binary .and g (allGuards gs)

def nonnegative {signature : List (Unit Asset)} (a : Asset)
    (q : E signature (.amount a)) : E signature .bool :=
  .binary (.le (.amount a)) (.lit 0) q

def negate {signature : List (Unit Asset)} (a : Asset)
    (q : E signature (.amount a)) : E signature (.amount a) :=
  .unary (.neg (.amount a)) q

def usdSignature : List (Unit Asset) := [.amount .usd]
def shareSignature : List (Unit Asset) := [.amount .share]
def usdQuantity : E usdSignature (.amount .usd) := .arg .here
def shareQuantity : E shareSignature (.amount .share) := .arg .here

/-- Registered USD movement; zero and self transfer retain net-effect semantics. -/
def transfer : Op where
  signature := usdSignature
  domain := .main
  partyArity := 1
  guard := nonnegative .usd usdQuantity
  deltas := [⟨.usd, ref .usd .caller, negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd (.argument 0), usdQuantity⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedRef .usd .caller, packedRef .usd (.argument 0)]

/-- Two USD per share is a dimensioned library price, not a unit-changing scalar. -/
def mintedShares : E usdSignature (.amount .share) :=
  .binary (.unconvert Asset.share Asset.usd) usdQuantity (.lit 2)

def deposit : Op where
  signature := usdSignature
  domain := .main
  partyArity := 0
  guard := nonnegative .usd usdQuantity
  deltas := [⟨.usd, ref .usd .caller, negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd (.literal .vault), usdQuantity⟩,
    ⟨.share, ref .share .caller, mintedShares⟩]
  supplyDeltas := [⟨.main, .share, mintedShares⟩]
  stateReads := []
  envReads := []
  writes := [packedRef .usd .caller, packedRef .usd (.literal .vault), packedRef .share .caller]

def redeemedUsd : E shareSignature (.amount .usd) :=
  .binary (.convert Asset.share Asset.usd) shareQuantity (.lit 2)

def withdraw : Op where
  signature := shareSignature
  domain := .main
  partyArity := 0
  guard := nonnegative .share shareQuantity
  deltas := [⟨.usd, ref .usd (.literal .vault), negate .usd redeemedUsd⟩,
    ⟨.usd, ref .usd .caller, redeemedUsd⟩,
    ⟨.share, ref .share .caller, negate .share shareQuantity⟩]
  supplyDeltas := [⟨.main, .share, negate .share shareQuantity⟩]
  stateReads := []
  envReads := []
  writes := [packedRef .usd (.literal .vault), packedRef .usd .caller, packedRef .share .caller]

def priceKey : ObservationKey Domain := ⟨.main, ⟨7⟩⟩
def collateralPrice : E usdSignature (.price .collateral .usd) := .observe ⟨priceKey⟩

/-- One USD per debt token is the reference denomination, explicitly dimensioned. -/
def mintedDebt : E usdSignature (.amount .debt) :=
  .binary (.unconvert Asset.debt Asset.usd) usdQuantity (.lit 1)

def debtValue : E usdSignature (.amount .usd) :=
  .binary (.convert Asset.debt Asset.usd)
    (.binary (.add (.amount Asset.debt)) (.balance (ref .debt .caller)) mintedDebt) (.lit 1)

def collateralValue : E usdSignature (.amount .usd) :=
  .binary (.convert Asset.collateral Asset.usd) (.balance (ref .collateral .caller)) collateralPrice

def borrowGuard : E usdSignature .bool := allGuards [
  nonnegative .usd usdQuantity,
  .binary (.lt (.price Asset.collateral Asset.usd)) (.lit 0) collateralPrice,
  .binary (.le .scalar) (.timestamp priceKey) .now,
  .binary (.le .scalar) .now (.binary (.add .scalar) (.timestamp priceKey) (.lit 5)),
  .binary (.le (.amount Asset.usd))
    (.binary (.scale (.amount Asset.usd)) (.lit 2) debtValue) collateralValue]

def borrow : Op where
  signature := usdSignature
  domain := .main
  partyArity := 0
  guard := borrowGuard
  deltas := [⟨.usd, ref .usd (.literal .pool), negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd .caller, usdQuantity⟩,
    ⟨.debt, ref .debt .caller, mintedDebt⟩]
  supplyDeltas := [⟨.main, .debt, mintedDebt⟩]
  stateReads := [packedRef .debt .caller, packedRef .collateral .caller]
  envReads := [.observation priceKey, .currentTime]
  writes := [packedRef .usd (.literal .pool), packedRef .usd .caller, packedRef .debt .caller]

def transferId : OperationId := ⟨0⟩
def depositId : OperationId := ⟨1⟩
def withdrawId : OperationId := ⟨2⟩
def borrowId : OperationId := ⟨3⟩

def registry : Registry Party Asset Domain := fun id ↦ match id.value with
  | 0 => some transfer
  | 1 => some deposit
  | 2 => some withdraw
  | 3 => some borrow
  | _ => none

/-- Vault is the fixture's administrative principal; this does not move ledger balances. -/
def domainAdmin : Domain → Party := fun _ ↦ .vault
def authorityConfig : AuthorityConfig Party Domain := registryAuthorityConfig registry domainAdmin
def adminContext : InvocationContext Party Domain := ⟨.vault, .main⟩
def aliceContext : InvocationContext Party Domain := ⟨.alice, .main⟩
def bobContext : InvocationContext Party Domain := ⟨.bob, .main⟩

def grant (operation : OperationId) (right : Right Party Asset Domain) : Grant Party Asset Domain :=
  ⟨.alice, .main, operation, right⟩

/-- Every operation has its own invocation and exact resource grants. -/
def grants : List (Grant Party Asset Domain) := [
  grant transferId .invoke, grant transferId (.debit (.main, .alice, .usd)),
  grant depositId .invoke, grant depositId (.debit (.main, .alice, .usd)),
  grant depositId (.changeSupply .main .share),
  grant withdrawId .invoke, grant withdrawId (.debit (.main, .vault, .usd)),
  grant withdrawId (.debit (.main, .alice, .share)), grant withdrawId (.changeSupply .main .share),
  grant borrowId .invoke, grant borrowId (.debit (.main, .pool, .usd)),
  grant borrowId (.changeSupply .main .debt)]

def issueGrants (store : Store) : List (Grant Party Asset Domain) → Except AuthorityFailure Store
  | [] => .ok store
  | g :: gs => do
    let (_, next) ← issueCapability authorityConfig adminContext store g
    issueGrants next gs

/-- Provisioning failure is propagated; execution never substitutes a fabricated store. -/
def provisioned : Except AuthorityFailure Store := issueGrants .empty grants
def allCapabilityIds : List CapabilityId := (List.range grants.length).map CapabilityId.mk

def transferRequest (q : ℚ) (recipient : Party := .bob) : Call :=
  ⟨transferId, [recipient], [⟨.amount .usd, q⟩], allCapabilityIds, none⟩
def depositRequest (q : ℚ) : Call :=
  ⟨depositId, [], [⟨.amount .usd, q⟩], allCapabilityIds, none⟩
def withdrawRequest (q : ℚ) : Call :=
  ⟨withdrawId, [], [⟨.amount .share, q⟩], allCapabilityIds, none⟩
def borrowRequest (q : ℚ) : Call :=
  ⟨borrowId, [], [⟨.amount .usd, q⟩], allCapabilityIds, none⟩

/-- Supplying a different feed creates a different key; it cannot replace feed seven. -/
def oracle (feed : Nat) (price : ℚ) (observedAt : Nat) : Environment Asset Domain := fun key ↦
  if key = ⟨.main, ⟨feed⟩⟩ then some ⟨⟨.price .collateral .usd, price⟩, observedAt⟩ else none

def fresh : Environment Asset Domain := oracle 7 2 98

inductive ReferenceFailure where
  | authority (reason : AuthorityFailure)
  | execution (reason : Refusal)
  deriving DecidableEq, Repr

def runWith (store : Store) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Call) (state : Ledger := initial) :
    Except ReferenceFailure Result :=
  (execute registry store ctx env now request state).mapError .execution

def run (request : Call) : Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store aliceContext fresh 100 request

def runOracle (env : Environment Asset Domain) (now : Nat) (request : Call) :
    Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store aliceContext env now request

def runContext (ctx : InvocationContext Party Domain) (request : Call) :
    Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store ctx fresh 100 request

def runRevoked (id : CapabilityId) (request : Call) : Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  let revoked ← (revokeCapability authorityConfig adminContext store id).mapError .authority
  runWith revoked aliceContext fresh 100 request

def allCells : List (Cell Party Asset Domain) :=
  [Domain.main, .other].flatMap fun d ↦ [Party.alice, .bob, .vault, .pool].flatMap fun p ↦
    [Asset.usd, .share, .collateral, .debt].map fun a ↦ (d, p, a)

def observe (result : Except ReferenceFailure Result) : Except ReferenceFailure (List ℚ) :=
  result.map fun post ↦ allCells.map post.state.balance

end Examples

-- BEGIN PROOFS

namespace Examples

theorem allCells_complete (cell : Cell Party Asset Domain) : cell ∈ allCells := by
  rcases cell with ⟨d, p, a⟩
  cases d <;> cases p <;> cases a <;> decide

theorem allCells_nodup : allCells.Nodup := by decide

end Examples
end DefiKernel.Typed

## END FILE

## FILE lean/DefiKernel/Typed/Expr.lean

Original SHA256: 1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed; bytes: 12466; rendered SHA256: 1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed

import DefiKernel.Typed.Types

/-! A closed dimensioned expression language. All arithmetic is exact rational arithmetic.
Read sets conservatively include both conditional branches. Environment truth is assumed. -/
namespace DefiKernel.Typed

inductive Var {Asset : Type} : List (Unit Asset) → Unit Asset → Type where
  | here {u : Unit Asset} {signature : List (Unit Asset)} : Var (u :: signature) u
  | there {u v : Unit Asset} {signature : List (Unit Asset)} :
      Var signature u → Var (v :: signature) u

inductive Args {Asset : Type} : List (Unit Asset) → Type where
  | nil : Args []
  | cons {u : Unit Asset} {signature : List (Unit Asset)} :
      Value u → Args signature → Args (u :: signature)

def Args.get {Asset : Type} {signature : List (Unit Asset)} {u : Unit Asset} :
    Args signature → Var signature u → Value u
  | .cons value _, .here => value
  | .cons _ rest, .there v => rest.get v

/-- Check arity and every delivered unit before exposing typed arguments to evaluation. -/
def Args.check {Asset : Type} [DecidableEq Asset] (signature : List (Unit Asset))
    (values : List (PackedValue Asset)) : Except EvalFailure (Args signature) :=
  match signature, values with
  | [], [] => .ok .nil
  | u :: us, ⟨v, value⟩ :: vs =>
    if h : v = u then do
      let rest ← Args.check us vs
      return .cons (h ▸ value) rest
    else .error .argumentUnit
  | _, _ => .error .argumentCount

inductive UnaryOp (Asset : Type) : Unit Asset → Unit Asset → Type where
  | neg (u : NumericUnit Asset) : UnaryOp Asset u.toUnit u.toUnit
  | not : UnaryOp Asset .bool .bool

inductive BinaryOp (Asset : Type) : Unit Asset → Unit Asset → Unit Asset → Type where
  | add (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit u.toUnit
  | sub (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit u.toUnit
  | scale (u : NumericUnit Asset) : BinaryOp Asset .scalar u.toUnit u.toUnit
  | divide (u : NumericUnit Asset) : BinaryOp Asset u.toUnit .scalar u.toUnit
  | ratio (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit .scalar
  | convert (base quote : Asset) : BinaryOp Asset (.amount base) (.price base quote) (.amount quote)
  | unconvert (base quote : Asset) :
      BinaryOp Asset (.amount quote) (.price base quote) (.amount base)
  | le (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit .bool
  | lt (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit .bool
  | eq (u : Unit Asset) : BinaryOp Asset u u .bool
  | and : BinaryOp Asset .bool .bool .bool
  | or : BinaryOp Asset .bool .bool .bool

def UnaryOp.eval {Asset : Type} {u v : Unit Asset} :
    UnaryOp Asset u v → Value u → Value v
  | .neg n, x => numericValue n (- numericRat n x)
  | .not, x => !x

/-- Division checks its denominator explicitly; rational division is otherwise total at zero. -/
def BinaryOp.eval {Asset : Type} {u v w : Unit Asset} :
    BinaryOp Asset u v w → Value u → Value v → Except EvalFailure (Value w)
  | .add n, x, y => .ok (numericValue n (numericRat n x + numericRat n y))
  | .sub n, x, y => .ok (numericValue n (numericRat n x - numericRat n y))
  | .scale n, x, y => .ok (numericValue n (x * numericRat n y))
  | .divide n, x, y =>
    if y = 0 then .error .divisionByZero else .ok (numericValue n (numericRat n x / y))
  | .ratio n, x, y =>
    if numericRat n y = 0 then .error .divisionByZero
    else .ok (numericRat n x / numericRat n y)
  | .convert _ _, x, y => .ok (x * y)
  | .unconvert _ _, x, y =>
    if y = 0 then .error .divisionByZero else .ok (x / y)
  | .le n, x, y => .ok (decide (numericRat n x ≤ numericRat n y))
  | .lt n, x, y => .ok (decide (numericRat n x < numericRat n y))
  | .eq _, x, y => .ok (decide (x = y))
  | .and, x, y => .ok (x && y)
  | .or, x, y => .ok (x || y)

inductive Expr (Party Asset Domain : Type) (signature : List (Unit Asset)) :
    Unit Asset → Type where
  | lit {u} (value : Value u) : Expr Party Asset Domain signature u
  | arg {u} (v : Var signature u) : Expr Party Asset Domain signature u
  | balance {a} (cell : CellRef Party Asset Domain a) :
      Expr Party Asset Domain signature (.amount a)
  | observe {u} (key : ObservationRef Asset Domain u) : Expr Party Asset Domain signature u
  | timestamp (key : ObservationKey Domain) : Expr Party Asset Domain signature .scalar
  | now : Expr Party Asset Domain signature .scalar
  | unary {u v} (op : UnaryOp Asset u v) (x : Expr Party Asset Domain signature u) :
      Expr Party Asset Domain signature v
  | binary {u v w} (op : BinaryOp Asset u v w)
      (x : Expr Party Asset Domain signature u) (y : Expr Party Asset Domain signature v) :
      Expr Party Asset Domain signature w
  | ite {u} (condition : Expr Party Asset Domain signature .bool)
      (yes no : Expr Party Asset Domain signature u) : Expr Party Asset Domain signature u

abbrev PackedCellRef (Party Asset Domain : Type) :=
  (asset : Asset) × CellRef Party Asset Domain asset

inductive EnvRead (Domain : Type) where
  | observation (key : ObservationKey Domain)
  | currentTime
  deriving DecidableEq, Repr

structure EvalContext (Party Asset Domain : Type) (signature : List (Unit Asset)) where
  state : State Party Asset Domain
  env : Environment Asset Domain
  caller : Party
  parties : List Party
  args : Args signature
  now : Nat

def readBalance {Party Asset Domain : Type} {signature : List (Unit Asset)}
    (ctx : EvalContext Party Asset Domain signature) (ref : PackedCellRef Party Asset Domain) :
    Except EvalFailure ℚ := do
  let c ← ref.2.resolve ctx.caller ctx.parties
  return ctx.state.balance c

def readObservation {Asset Domain : Type} [DecidableEq Asset] {u : Unit Asset}
    (env : Environment Asset Domain) (ref : ObservationRef Asset Domain u) :
    Except EvalFailure (Value u) :=
  match env ref.key with
  | none => .error .missingObservation
  | some observation =>
    if h : observation.value.1 = u then .ok (h ▸ observation.value.2)
    else .error .observationUnit

/-- Binary operators, including boolean and/or, evaluate both operands. Only `ite`
selects a branch lazily. Read inventories conservatively include every branch. -/
def Expr.eval {Party Asset Domain : Type} [DecidableEq Asset]
    {signature : List (Unit Asset)} {u : Unit Asset}
    (ctx : EvalContext Party Asset Domain signature) :
    Expr Party Asset Domain signature u → Except EvalFailure (Value u)
  | .lit value => .ok value
  | .arg v => .ok (ctx.args.get v)
  | .balance ref => readBalance ctx ⟨_, ref⟩
  | .observe ref => readObservation ctx.env ref
  | .timestamp key => match ctx.env key with
    | none => .error .missingObservation
    | some observation => .ok observation.timestamp
  | .now => .ok ctx.now
  | .unary op x => do return op.eval (← x.eval ctx)
  | .binary op x y => do op.eval (← x.eval ctx) (← y.eval ctx)
  | .ite condition yes no => do
    if ← condition.eval ctx then yes.eval ctx else no.eval ctx

/-- Syntactic reads include inactive branches and all expression children. -/
def Expr.stateReads {Party Asset Domain : Type} {signature : List (Unit Asset)} {u : Unit Asset} :
    Expr Party Asset Domain signature u → List (PackedCellRef Party Asset Domain)
  | .balance ref => [⟨_, ref⟩]
  | .unary _ x => x.stateReads
  | .binary _ x y => x.stateReads ++ y.stateReads
  | .ite condition yes no => condition.stateReads ++ yes.stateReads ++ no.stateReads
  | .lit _ | .arg _ | .observe _ | .timestamp _ | .now => []

def Expr.envReads {Party Asset Domain : Type} {signature : List (Unit Asset)} {u : Unit Asset} :
    Expr Party Asset Domain signature u → List (EnvRead Domain)
  | .observe ref => [.observation ref.key]
  | .timestamp key => [.observation key]
  | .now => [.currentTime]
  | .unary _ x => x.envReads
  | .binary _ x y => x.envReads ++ y.envReads
  | .ite condition yes no => condition.envReads ++ yes.envReads ++ no.envReads
  | .lit _ | .arg _ | .balance _ => []

def Expr.resolveStateReads {Party Asset Domain : Type} {signature : List (Unit Asset)}
    {u : Unit Asset} (caller : Party) (parties : List Party)
    (expression : Expr Party Asset Domain signature u) :
    Except EvalFailure (List (Cell Party Asset Domain)) :=
  expression.stateReads.mapM (fun ref ↦ ref.2.resolve caller parties)

def EnvRead.Agree {Party Asset Domain : Type} {signature : List (Unit Asset)}
    (left right : EvalContext Party Asset Domain signature) : EnvRead Domain → Prop
  | .observation key => left.env key = right.env key
  | .currentTime => left.now = right.now

-- BEGIN PROOFS

/-- Equality on all recorded reads and typed arguments preserves the entire evaluation result,
including missing-input, wrong-unit and zero-division refusal behavior. -/
theorem Expr.eval_congr {Party Asset Domain : Type} [DecidableEq Asset]
    {signature : List (Unit Asset)} {u : Unit Asset}
    (expression : Expr Party Asset Domain signature u)
    (left right : EvalContext Party Asset Domain signature)
    (ha : left.args = right.args)
    (hs : ∀ ref ∈ expression.stateReads, readBalance left ref = readBalance right ref)
    (he : ∀ key ∈ expression.envReads, EnvRead.Agree left right key) :
    expression.eval left = expression.eval right := by
  induction expression with
  | lit value => rfl
  | arg v => simp only [Expr.eval, ha]
  | balance ref => exact hs ⟨_, ref⟩ (by simp [Expr.stateReads])
  | observe ref =>
    have h := he (.observation ref.key) (by simp [Expr.envReads])
    simp only [EnvRead.Agree] at h
    simp only [Expr.eval, readObservation, h]
  | timestamp key =>
    have h := he (.observation key) (by simp [Expr.envReads])
    simp only [EnvRead.Agree] at h
    simp only [Expr.eval, h]
  | now =>
    have h := he .currentTime (by simp [Expr.envReads])
    simp only [EnvRead.Agree] at h
    simp only [Expr.eval, h]
  | unary op x ih =>
    have hx := ih hs he
    simp only [Expr.eval, hx]
  | binary op x y ihx ihy =>
    have hx := ihx
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    have hy := ihy
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    simp only [Expr.eval, hx, hy]
  | ite condition yes no ihc ihy ihn =>
    have hc := ihc
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    have hy := ihy
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    have hn := ihn
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    simp only [Expr.eval, hc, hy, hn]

/-- Equal caller/party inputs and equal balances at successfully resolved references suffice
for state-read agreement. Invalid party indices produce the same refusal on both sides. -/
theorem readBalance_congr {Party Asset Domain : Type} {signature : List (Unit Asset)}
    (left right : EvalContext Party Asset Domain signature) (ref : PackedCellRef Party Asset Domain)
    (hc : left.caller = right.caller) (hp : left.parties = right.parties)
    (hs : ∀ c, ref.2.resolve left.caller left.parties = .ok c →
      left.state.balance c = right.state.balance c) :
    readBalance left ref = readBalance right ref := by
  simp only [readBalance, ← hc, ← hp]
  cases h : ref.2.resolve left.caller left.parties with
  | error reason => rfl
  | ok c => simp [hs c h]

/-- A concrete ledger formulation of read dependence. Only successfully resolved cells need
equal balances; the same caller and party arguments also preserve resolution failures. -/
theorem Expr.eval_congr_of_resolved {Party Asset Domain : Type} [DecidableEq Asset]
    {signature : List (Unit Asset)} {u : Unit Asset}
    (expression : Expr Party Asset Domain signature u)
    (left right : EvalContext Party Asset Domain signature)
    (ha : left.args = right.args) (hc : left.caller = right.caller)
    (hp : left.parties = right.parties)
    (hs : ∀ ref ∈ expression.stateReads, ∀ c,
      ref.2.resolve left.caller left.parties = .ok c →
        left.state.balance c = right.state.balance c)
    (he : ∀ key ∈ expression.envReads, EnvRead.Agree left right key) :
    expression.eval left = expression.eval right := by
  apply expression.eval_congr left right ha _ he
  intro ref href
  exact readBalance_congr left right ref hc hp (hs ref href)

end DefiKernel.Typed

## END FILE

## FILE lean/DefiKernel/Typed/Transition.lean

Original SHA256: 73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2; bytes: 21986; rendered SHA256: 73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2

import DefiKernel.Typed.Expr
import DefiKernel.Typed.Authority
import Mathlib.Tactic.Linarith

/-! Registered first-order transitions. Checks concern aggregate net effects; they do not model
intermediate debit order, consumable allowances, replay prevention, or observation truth. -/
namespace DefiKernel.Typed

structure CellDelta (Party Asset Domain : Type) (signature : List (Unit Asset)) where
  asset : Asset
  target : CellRef Party Asset Domain asset
  amount : Expr Party Asset Domain signature (.amount asset)

structure SupplyDelta (Party Asset Domain : Type) (signature : List (Unit Asset)) where
  domain : Domain
  asset : Asset
  amount : Expr Party Asset Domain signature (.amount asset)

structure Template (Party Asset Domain : Type) where
  signature : List (Unit Asset)
  domain : Domain
  partyArity : Nat
  guard : Expr Party Asset Domain signature .bool
  deltas : List (CellDelta Party Asset Domain signature)
  supplyDeltas : List (SupplyDelta Party Asset Domain signature)
  stateReads : List (PackedCellRef Party Asset Domain)
  envReads : List (EnvRead Domain)
  writes : List (PackedCellRef Party Asset Domain)

abbrev Registry (Party Asset Domain : Type) := OperationId → Option (Template Party Asset Domain)

/-- Issuance and execution use the same trusted registry to determine the operation domain. -/
def registryAuthorityConfig {Party Asset Domain : Type} (registry : Registry Party Asset Domain)
    (domainAdmin : Domain → Party) : AuthorityConfig Party Domain :=
  ⟨domainAdmin, fun operation ↦ (registry operation).map Template.domain⟩

structure Request (Party Asset Domain : Type) where
  operation : OperationId
  parties : List Party
  arguments : List (PackedValue Asset)
  capabilityIds : List CapabilityId
  claimedActor : Option Party := none

inductive Refusal where
  | unknownOperation
  | actorMismatch
  | domainMismatch
  | partyArity
  | evaluation (reason : EvalFailure)
  | unauthorizedInvoke
  | guard
  | stateReadFootprint
  | envReadFootprint
  | crossDomain
  | unauthorizedDebit
  | unauthorizedSupply
  | insufficientFunds
  | accounting
  | writeFootprint
  deriving DecidableEq, Repr

/-- Internal evaluated data; caller requests cannot supply this record to `execute`. -/
structure Evaluated (Party Asset Domain : Type) where
  guard : Bool
  deltas : List (Cell Party Asset Domain × ℚ)
  supplies : List ((Domain × Asset) × ℚ)
  requiredStateReads : List (Cell Party Asset Domain)
  requiredEnvReads : List (EnvRead Domain)
  declaredStateReads : List (Cell Party Asset Domain)
  declaredEnvReads : List (EnvRead Domain)
  writes : List (Cell Party Asset Domain)

structure ExecutionResult (Party Asset Domain : Type) where
  state : State Party Asset Domain
  capabilities : CapabilityStore Party Asset Domain

variable {Party Asset Domain : Type}
variable [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain]

def Template.requiredStateReads (template : Template Party Asset Domain) :=
  template.guard.stateReads ++ template.deltas.flatMap (fun d ↦ d.amount.stateReads) ++
    template.supplyDeltas.flatMap (fun d ↦ d.amount.stateReads)

def Template.requiredEnvReads (template : Template Party Asset Domain) :=
  template.guard.envReads ++ template.deltas.flatMap (fun d ↦ d.amount.envReads) ++
    template.supplyDeltas.flatMap (fun d ↦ d.amount.envReads)

def resolveRefs (caller : Party) (parties : List Party)
    (refs : List (PackedCellRef Party Asset Domain)) :
    Except EvalFailure (List (Cell Party Asset Domain)) :=
  refs.mapM (fun ref ↦ ref.2.resolve caller parties)

def Template.evaluate (template : Template Party Asset Domain)
    (ctx : EvalContext Party Asset Domain template.signature) :
    Except EvalFailure (Evaluated Party Asset Domain) := do
  let required ← resolveRefs ctx.caller ctx.parties template.requiredStateReads
  let declared ← resolveRefs ctx.caller ctx.parties template.stateReads
  let writes ← resolveRefs ctx.caller ctx.parties template.writes
  let guard ← template.guard.eval ctx
  let deltas ← template.deltas.mapM fun d ↦ do
    let cell ← d.target.resolve ctx.caller ctx.parties
    let amount ← d.amount.eval ctx
    return (cell, amount)
  let supplies ← template.supplyDeltas.mapM fun d ↦ do
    let amount ← d.amount.eval ctx
    return ((d.domain, d.asset), amount)
  return ⟨guard, deltas, supplies, required, template.requiredEnvReads, declared,
    template.envReads, writes⟩

/-- Every repeated entry contributes by addition, including repeated supply changes. -/
def Evaluated.effect (evaluated : Evaluated Party Asset Domain)
    (cell : Cell Party Asset Domain) : ℚ :=
  (evaluated.deltas.map (fun d ↦ if d.1 = cell then d.2 else 0)).sum

def Evaluated.supply (evaluated : Evaluated Party Asset Domain)
    (domain : Domain) (asset : Asset) : ℚ :=
  (evaluated.supplies.map (fun d ↦ if d.1 = (domain, asset) then d.2 else 0)).sum

variable [Fintype Party] [Fintype Asset] [Fintype Domain]

def Evaluated.stateReadsOK (e : Evaluated Party Asset Domain) : Bool :=
  e.requiredStateReads.all (fun c ↦ decide (c ∈ e.declaredStateReads))

def Evaluated.envReadsOK (e : Evaluated Party Asset Domain) : Bool :=
  e.requiredEnvReads.all (fun k ↦ decide (k ∈ e.declaredEnvReads))

/-- Required state reads and actual net movement stay within the invocation domain.
Environment observations may explicitly refer to other domains; their truth is adapter supplied. -/
def Evaluated.domainOK (e : Evaluated Party Asset Domain) (domain : Domain) : Bool :=
  decide ((∀ c ∈ e.requiredStateReads, c.1 = domain) ∧
    (∀ c, e.effect c ≠ 0 → c.1 = domain) ∧ ∀ d a, e.supply d a ≠ 0 → d = domain)

def Evaluated.debitsOK (e : Evaluated Party Asset Domain)
    (store : CapabilityStore Party Asset Domain) (request : Request Party Asset Domain)
    (ctx : InvocationContext Party Domain) : Bool :=
  decide (∀ c, e.effect c < 0 →
    hasAuthority store request.capabilityIds ctx request.operation (.debit c) = true)

def Evaluated.suppliesOK (e : Evaluated Party Asset Domain)
    (store : CapabilityStore Party Asset Domain) (request : Request Party Asset Domain)
    (ctx : InvocationContext Party Domain) : Bool :=
  decide (∀ d a, e.supply d a ≠ 0 →
    hasAuthority store request.capabilityIds ctx request.operation (.changeSupply d a) = true)

def Evaluated.accountingOK (e : Evaluated Party Asset Domain) : Bool :=
  decide (∀ d a, ∑ p, e.effect (d, p, a) = e.supply d a)

def Evaluated.writesOK (e : Evaluated Party Asset Domain) : Bool :=
  decide (∀ c, c ∉ e.writes → e.effect c = 0)

/-- All branches are computational. Only the nonnegativity witness enters the state value. -/
def applyEvaluated (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain) :
    Except Refusal (ExecutionResult Party Asset Domain) :=
  if !e.guard then .error .guard
  else if !e.stateReadsOK then .error .stateReadFootprint
  else if !e.envReadsOK then .error .envReadFootprint
  else if !e.domainOK ctx.domain then .error .crossDomain
  else if !e.debitsOK store request ctx then .error .unauthorizedDebit
  else if !e.suppliesOK store request ctx then .error .unauthorizedSupply
  else if hn : ∀ c, 0 ≤ state.balance c + e.effect c then
    if !e.accountingOK then .error .accounting
    else if !e.writesOK then .error .writeFootprint
    else .ok ⟨⟨fun c ↦ state.balance c + e.effect c, hn⟩, store⟩
  else .error .insufficientFunds

/-- Registry selection and actor/domain binding precede `Args.check`, which precedes invoke
checking. Template evaluation (including effect/supply expressions) precedes guard and footprint
checks. Successful read/domain conditions are not refused-path confidentiality guarantees. -/
def execute (registry : Registry Party Asset Domain)
    (store : CapabilityStore Party Asset Domain) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) : Except Refusal (ExecutionResult Party Asset Domain) := do
  let template ← match registry request.operation with
    | none => .error .unknownOperation
    | some template => .ok template
  if request.claimedActor.isSome && request.claimedActor != some ctx.principal then
    throw .actorMismatch
  if ctx.domain != template.domain then throw .domainMismatch
  if request.parties.length != template.partyArity then throw .partyArity
  let args ← (Args.check template.signature request.arguments).mapError Refusal.evaluation
  if !hasAuthority store request.capabilityIds ctx request.operation .invoke then
    throw .unauthorizedInvoke
  let evaluated ← (template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩)
    |>.mapError Refusal.evaluation
  applyEvaluated store ctx request state evaluated

/-- Logical view of the actual checks; this does not construct executable states. -/
def Evaluated.Valid (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain) : Prop :=
  e.guard = true ∧ e.stateReadsOK = true ∧ e.envReadsOK = true ∧
  e.domainOK ctx.domain = true ∧ e.debitsOK store request ctx = true ∧
  e.suppliesOK store request ctx = true ∧ (∀ c, 0 ≤ state.balance c + e.effect c) ∧
  e.accountingOK = true ∧ e.writesOK = true

variable (registry : Registry Party Asset Domain) (store : CapabilityStore Party Asset Domain)
variable (ctx : InvocationContext Party Domain) (env : Environment Asset Domain) (now : Nat)
variable (request : Request Party Asset Domain) (state : State Party Asset Domain)
variable (post : ExecutionResult Party Asset Domain)

-- BEGIN PROOFS

theorem applyEvaluated_ok_iff (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain) :
    applyEvaluated store ctx request state e = .ok post ↔
      e.Valid store ctx request state ∧ post.capabilities = store ∧
      ∀ c, post.state.balance c = state.balance c + e.effect c := by
  rcases post with ⟨⟨balance, nonneg⟩, capabilities⟩
  unfold applyEvaluated
  split_ifs <;> simp_all [Evaluated.Valid, funext_iff]
  aesop

/-- Success binds the selected template, typed arguments and actual evaluation result to all
checks and the exact post-state. No caller-supplied validity certificate occurs here. -/
theorem execute_ok_iff (registry : Registry Party Asset Domain)
    (store : CapabilityStore Party Asset Domain) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (post : ExecutionResult Party Asset Domain) :
    execute registry store ctx env now request state = .ok post ↔
      ∃ template, registry request.operation = some template ∧
      (request.claimedActor = none ∨ request.claimedActor = some ctx.principal) ∧
      ctx.domain = template.domain ∧ request.parties.length = template.partyArity ∧
      ∃ args, Args.check template.signature request.arguments = .ok args ∧
      hasAuthority store request.capabilityIds ctx request.operation .invoke = true ∧
      ∃ e, template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ = .ok e ∧
      e.Valid store ctx request state ∧ post.capabilities = store ∧
      ∀ c, post.state.balance c = state.balance c + e.effect c := by
  unfold execute
  cases hr : registry request.operation with
  | none => simp [bind, Except.bind]
  | some template =>
    simp only [bind, Except.bind, Option.some.injEq, exists_eq_left']
    cases hc : request.claimedActor <;>
      simp only [Option.isSome, Bool.false_and, Bool.true_and] <;>
      split_ifs <;> simp_all [throw, throwThe]
    all_goals
      cases ha : Args.check template.signature request.arguments <;>
        simp_all [Except.mapError]
    all_goals
      rename_i args
      cases he : template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ <;>
        simp_all [applyEvaluated_ok_iff]

theorem applyEvaluated_accounting (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain)
    (h : applyEvaluated store ctx request state e = .ok post) (d : Domain) (a : Asset) :
    total post.state d a = total state d a + e.supply d a := by
  obtain ⟨hv, _, hu⟩ := (applyEvaluated_ok_iff ..).mp h
  have ha : ∀ d a, ∑ p, e.effect (d, p, a) = e.supply d a :=
    of_decide_eq_true hv.2.2.2.2.2.2.2.1
  simp only [total, hu, Finset.sum_add_distrib, ha]

theorem applyEvaluated_locality (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain)
    (h : applyEvaluated store ctx request state e = .ok post)
    (c : Cell Party Asset Domain) (hc : c ∉ e.writes) :
    post.state.balance c = state.balance c := by
  obtain ⟨hv, _, hu⟩ := (applyEvaluated_ok_iff ..).mp h
  have hw : ∀ c, c ∉ e.writes → e.effect c = 0 :=
    of_decide_eq_true hv.2.2.2.2.2.2.2.2
  simp [hu, hw c hc]

theorem applyEvaluated_debit_authority (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain)
    (h : applyEvaluated store ctx request state e = .ok post)
    (c : Cell Party Asset Domain) (hc : post.state.balance c < state.balance c) :
    hasAuthority store request.capabilityIds ctx request.operation (.debit c) = true := by
  obtain ⟨hv, _, hu⟩ := (applyEvaluated_ok_iff ..).mp h
  have hd : ∀ c, e.effect c < 0 →
      hasAuthority store request.capabilityIds ctx request.operation (.debit c) = true :=
    of_decide_eq_true hv.2.2.2.2.1
  apply hd c
  rw [hu] at hc
  linarith

theorem applyEvaluated_supply_authority (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain)
    (h : applyEvaluated store ctx request state e = .ok post) (d : Domain) (a : Asset)
    (hc : total post.state d a ≠ total state d a) :
    hasAuthority store request.capabilityIds ctx request.operation (.changeSupply d a) = true := by
  obtain ⟨hv, _, _⟩ := (applyEvaluated_ok_iff ..).mp h
  have hs : ∀ d a, e.supply d a ≠ 0 →
      hasAuthority store request.capabilityIds ctx request.operation (.changeSupply d a) = true :=
    of_decide_eq_true hv.2.2.2.2.2.1
  apply hs d a
  intro hz
  exact hc (by simpa [hz] using applyEvaluated_accounting store ctx request state e post h d a)

/-- Every successful execution has a selected registered template and a checked evaluation
whose concrete application produced the post-state. -/
theorem execute_evaluated
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ template, registry request.operation = some template ∧
      ∃ args, Args.check template.signature request.arguments = .ok args ∧
      ∃ e, template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ = .ok e ∧
        applyEvaluated store ctx request state e = .ok post := by
  obtain ⟨t, ht, _, _, _, args, ha, _, e, he, hv, hcap, hu⟩ := (execute_ok_iff ..).mp h
  exact ⟨t, ht, args, ha, e, he, (applyEvaluated_ok_iff ..).mpr ⟨hv, hcap, hu⟩⟩

theorem execute_preserves_capabilities
    (h : execute registry store ctx env now request state = .ok post) :
    post.capabilities = store := by
  obtain ⟨_, _, _, _, _, _, _, _, _, _, _, hcap, _⟩ := (execute_ok_iff ..).mp h
  exact hcap

theorem execute_nonnegative
    (h : execute registry store ctx env now request state = .ok post) :
    ∀ c, 0 ≤ post.state.balance c := by
  obtain ⟨_, _, _, _, _, _, _, _, e, _, hv, _, hu⟩ := (execute_ok_iff ..).mp h
  intro c
  rw [hu]
  exact hv.2.2.2.2.2.2.1 c

theorem execute_invocation_authority
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ id ∈ request.capabilityIds, ∃ cap,
      store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = request.operation ∧ cap.right = .invoke := by
  obtain ⟨_, _, _, _, _, _, _, hi, _⟩ := (execute_ok_iff ..).mp h
  obtain ⟨id, hid, hi⟩ := (hasAuthority_iff ..).mp hi
  obtain ⟨cap, hcap, hl, hh, hd, ho, hr, _⟩ := (authorizesId_iff ..).mp hi
  exact ⟨id, hid, cap, hcap, hl, hh, hd, ho, hr⟩

theorem execute_debit_authority
    (h : execute registry store ctx env now request state = .ok post)
    (c : Cell Party Asset Domain) (hc : post.state.balance c < state.balance c) :
    ∃ id ∈ request.capabilityIds, ∃ cap,
      store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = request.operation ∧ cap.right = .debit c := by
  obtain ⟨_, _, _, _, e, _, he⟩ := execute_evaluated registry store ctx env now request state post h
  have hi := applyEvaluated_debit_authority store ctx request state e post he c hc
  obtain ⟨id, hid, hi⟩ := (hasAuthority_iff ..).mp hi
  obtain ⟨cap, hcap, hl, hh, hd, ho, hr, _⟩ := (authorizesId_iff ..).mp hi
  exact ⟨id, hid, cap, hcap, hl, hh, hd, ho, hr⟩

theorem execute_supply_authority
    (h : execute registry store ctx env now request state = .ok post) (d : Domain) (a : Asset)
    (hc : total post.state d a ≠ total state d a) :
    ∃ id ∈ request.capabilityIds, ∃ cap,
      store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = request.operation ∧
      cap.right = .changeSupply d a := by
  obtain ⟨_, _, _, _, e, _, he⟩ := execute_evaluated registry store ctx env now request state post h
  have hi := applyEvaluated_supply_authority store ctx request state e post he d a hc
  obtain ⟨id, hid, hi⟩ := (hasAuthority_iff ..).mp hi
  obtain ⟨cap, hcap, hl, hh, hd, ho, hr, _⟩ := (authorizesId_iff ..).mp hi
  exact ⟨id, hid, cap, hcap, hl, hh, hd, ho, hr⟩

theorem execute_accounting_and_locality
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ template, registry request.operation = some template ∧
      ∃ args, Args.check template.signature request.arguments = .ok args ∧
      ∃ e, template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ = .ok e ∧
        (∀ d a, total post.state d a = total state d a + e.supply d a) ∧
        (∀ c, c ∉ e.writes → post.state.balance c = state.balance c) := by
  obtain ⟨t, ht, args, ha, e, he, happly⟩ :=
    execute_evaluated registry store ctx env now request state post h
  exact ⟨t, ht, args, ha, e, he,
    applyEvaluated_accounting store ctx request state e post happly,
    applyEvaluated_locality store ctx request state e post happly⟩

/-- Successfully recorded reads are declared and domain-local, and all changed balances stay
in the authenticated invocation domain. -/
theorem execute_reads_and_domain
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ template, registry request.operation = some template ∧
      ctx.domain = template.domain ∧
      ∃ args, Args.check template.signature request.arguments = .ok args ∧
      ∃ e, template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ = .ok e ∧
        (∀ c ∈ e.requiredStateReads, c ∈ e.declaredStateReads ∧ c.1 = ctx.domain) ∧
        (∀ k ∈ e.requiredEnvReads, k ∈ e.declaredEnvReads) ∧
        (∀ c, post.state.balance c ≠ state.balance c → c.1 = ctx.domain) := by
  obtain ⟨t, ht, _, hd, _, args, ha, _, e, he, hv, _, hu⟩ := (execute_ok_iff ..).mp h
  have hs : ∀ c ∈ e.requiredStateReads, c ∈ e.declaredStateReads := by
    simpa [Evaluated.stateReadsOK] using hv.2.1
  have hen : ∀ k ∈ e.requiredEnvReads, k ∈ e.declaredEnvReads := by
    simpa [Evaluated.envReadsOK] using hv.2.2.1
  have hdom : (∀ c ∈ e.requiredStateReads, c.1 = ctx.domain) ∧
      (∀ c, e.effect c ≠ 0 → c.1 = ctx.domain) ∧
      ∀ d a, e.supply d a ≠ 0 → d = ctx.domain := of_decide_eq_true hv.2.2.2.1
  refine ⟨t, ht, hd, args, ha, e, he, ?_, hen, ?_⟩
  · exact fun c hc ↦ ⟨hs c hc, hdom.1 c hc⟩
  · intro c hc
    apply hdom.2.1 c
    intro hz
    exact hc (by simp [hu, hz])

omit [Fintype Party] [Fintype Asset] [Fintype Domain] in
theorem Evaluated.effect_cons (e : Evaluated Party Asset Domain)
    (entry : Cell Party Asset Domain × ℚ) (c : Cell Party Asset Domain) :
    ({ e with deltas := entry :: e.deltas } : Evaluated Party Asset Domain).effect c =
      (if entry.1 = c then entry.2 else 0) + e.effect c := by
  simp [Evaluated.effect]

omit [DecidableEq Party] [Fintype Party] [Fintype Asset] [Fintype Domain] in
theorem Evaluated.supply_cons (e : Evaluated Party Asset Domain)
    (entry : (Domain × Asset) × ℚ) (d : Domain) (a : Asset) :
    ({ e with supplies := entry :: e.supplies } : Evaluated Party Asset Domain).supply d a =
      (if entry.1 = (d, a) then entry.2 else 0) + e.supply d a := by
  simp [Evaluated.supply]

end DefiKernel.Typed

## END FILE

## FILE lean/DefiKernel/Typed/Types.lean

Original SHA256: 5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82; bytes: 4499; rendered SHA256: 5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82

import Mathlib.Data.Rat.Defs
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Fintype.Prod

/-! Reusable finite-ledger identities and dimensioned values. Identity authentication,
observation truth and the finite deployment universe are external assumptions. -/
namespace DefiKernel.Typed

structure ClaimId where
  value : Nat
  deriving DecidableEq, Repr

structure CapabilityId where
  value : Nat
  deriving DecidableEq, Repr

structure OperationId where
  value : Nat
  deriving DecidableEq, Repr

structure ObservationId where
  value : Nat
  deriving DecidableEq, Repr

abbrev Cell (Party Asset Domain : Type) := Domain × Party × Asset

/-- Amount expressions can be signed; a quantity is explicitly nonnegative. -/
structure Quantity {Asset : Type} (asset : Asset) where
  amount : ℚ
  nonneg : 0 ≤ amount

structure State (Party Asset Domain : Type) where
  balance : Cell Party Asset Domain → ℚ
  nonneg : ∀ c, 0 ≤ balance c

def total {Party Asset Domain : Type} [Fintype Party]
    (s : State Party Asset Domain) (domain : Domain) (asset : Asset) : ℚ :=
  ∑ party, s.balance (domain, party, asset)

/-- A price is quote-asset units per one base-asset unit. -/
inductive Unit (Asset : Type) where
  | amount (asset : Asset)
  | price (base quote : Asset)
  | scalar
  | bool
  deriving DecidableEq, Repr

/-- Numeric dimensions exclude booleans without a user-supplied typeclass. -/
inductive NumericUnit (Asset : Type) where
  | amount (asset : Asset)
  | price (base quote : Asset)
  | scalar
  deriving DecidableEq, Repr

abbrev NumericUnit.toUnit {Asset : Type} : NumericUnit Asset → Unit Asset
  | .amount a => .amount a
  | .price a b => .price a b
  | .scalar => .scalar

abbrev Value {Asset : Type} : Unit Asset → Type
  | .bool => Bool
  | .amount _ | .price _ _ | .scalar => ℚ

instance {Asset : Type} (u : Unit Asset) : DecidableEq (Value u) := by
  cases u <;> exact inferInstance

instance {Asset : Type} (u : Unit Asset) : Repr (Value u) := by
  cases u <;> exact inferInstance

def numericValue {Asset : Type} (u : NumericUnit Asset) (q : ℚ) : Value u.toUnit :=
  match u with
  | .amount _ | .price _ _ | .scalar => q

def numericRat {Asset : Type} (u : NumericUnit Asset) (v : Value u.toUnit) : ℚ :=
  match u with
  | .amount _ | .price _ _ | .scalar => v

abbrev PackedValue (Asset : Type) := (u : Unit Asset) × Value u

inductive EvalFailure where
  | argumentCount
  | argumentUnit
  | partyArgument
  | missingObservation
  | observationUnit
  | divisionByZero
  deriving DecidableEq, Repr

inductive PartyRef (Party : Type) where
  | caller
  | literal (party : Party)
  | argument (index : Nat)
  deriving DecidableEq, Repr

def PartyRef.resolve {Party : Type} (caller : Party) (parties : List Party) :
    PartyRef Party → Except EvalFailure Party
  | .caller => .ok caller
  | .literal p => .ok p
  | .argument n => match parties[n]? with
    | some p => .ok p
    | none => .error .partyArgument

structure CellRef (Party Asset Domain : Type) (asset : Asset) where
  domain : Domain
  owner : PartyRef Party
  deriving DecidableEq, Repr

def CellRef.resolve {Party Asset Domain : Type} {asset : Asset}
    (caller : Party) (parties : List Party) (c : CellRef Party Asset Domain asset) :
    Except EvalFailure (Cell Party Asset Domain) := do
  let party ← c.owner.resolve caller parties
  return (c.domain, party, asset)

structure ObservationKey (Domain : Type) where
  domain : Domain
  id : ObservationId
  deriving DecidableEq, Repr

/-- Expected unit is intrinsic; the environment's delivered unit is checked at lookup. -/
structure ObservationRef (Asset Domain : Type) (unit : Unit Asset) where
  key : ObservationKey Domain
  deriving DecidableEq, Repr

structure Observation (Asset : Type) where
  value : PackedValue Asset
  timestamp : Nat

abbrev Environment (Asset Domain : Type) := ObservationKey Domain → Option (Observation Asset)

/-- Adapter-supplied identity. Constructing this value is not signature verification. -/
structure InvocationContext (Party Domain : Type) where
  principal : Party
  domain : Domain
  deriving DecidableEq, Repr

-- BEGIN PROOFS

theorem numericRat_numericValue {Asset : Type} (u : NumericUnit Asset) (q : ℚ) :
    numericRat u (numericValue u q) = q := by cases u <;> rfl

theorem numericValue_numericRat {Asset : Type} (u : NumericUnit Asset) (v : Value u.toUnit) :
    numericValue u (numericRat u v) = v := by cases u <;> rfl

end DefiKernel.Typed

## END FILE

## FILE lean/Defialgebra/Interface.lean

Original SHA256: e77ab27a5f9c2bf065805bab5a38fcfc8aa46e32ff1979dd8c2682fcb4331bd8; bytes: 7391; rendered SHA256: e77ab27a5f9c2bf065805bab5a38fcfc8aa46e32ff1979dd8c2682fcb4331bd8

/-
Copyright (c) 2026 Charles Hoskinson. All rights reserved.

# The interface discipline for `⋈`

`BASIS.md` §5 composes constructions along a coupling `κ` that "identifies only
carriers of the same sort". `P1 · Led` has carrier `(N ⇀ Q) × Q` — a balance map and
a declared total — with the law `‖bal‖ = sup`. But `sup` is merely sort `Q`, so `κ`
may glue it to an unrelated `Q` of the partner, whose transitions then write it while
the balance map is untouched. **Conservation dies under plain interleaving, with no
fusion involved**, and the invariant induction §5 relies on has no proof.

Four independent designs (`sigma/INTERFACE-COUNCIL.md`) converged on one fix:
*the declared total is not a shareable thing*. This file is the Lean statement of it.

* `Ledger.sup_not_port` — the discipline, carried as a well-formedness field rather
  than proved. This is the whole fix.
* `cons_of_portConfined` — a foreign transition confined to a ledger's ports, and
  `Q`-neutral on the ports it shares, preserves `‖bal‖ = sup`.
* `cons_broken_if_sup_is_port` — **the negative companion.** Drop `sup ∉ ports` and
  the same theorem is false, by explicit counterexample. Without this the result
  could hold vacuously, which is the failure mode this programme keeps finding.

SCOPE, stated plainly. Sorts are not modelled: state here is `Idx → ℤ`, because
conservation quantifies over `Q` alone and the sort discipline is a separate
concern. Fusion, polarity of `Q` flows, and associativity are M2/M3 and are absent.
What is proved is exactly the milestone: the coupling defect is real, and
`sup ∉ ports` closes it.
-/
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.Ring.Int

namespace Defialgebra.Interface

variable {Idx : Type*} [DecidableEq Idx]

/-- The state of a construction, restricted to its `Q` carriers. -/
def St (Idx : Type*) : Type _ := Idx → ℤ

/-- A `Led` block: the balance indices, the declared total, and the ports it
exposes to a coupling.

`bal : N ⇀ Q` is modelled as `N`-many `Q`-carriers rather than one map carrier.
That is faithful to §5's "`S` a finite product of carriers", and it is what makes
the defect *sayable*: `sup` is a different index from every balance, so a port list
can contain the balances and exclude the total. -/
structure Ledger (Idx : Type*) where
  /-- The indices holding individual balances. -/
  bals : Finset Idx
  /-- The index holding the declared total. -/
  sup : Idx
  /-- The indices a coupling is permitted to bind. -/
  ports : Finset Idx
  /-- The total is not one of the balances. -/
  sup_not_bal : sup ∉ bals
  /-- **THE INTERFACE DISCIPLINE.** The declared total is never a port, so no
  coupling can bind it and no foreign transition can write it. Carried as a
  well-formedness condition, not derived. -/
  sup_not_port : sup ∉ ports

/-- `P1 · Led`'s law: `‖bal‖ = sup`. -/
def Cons (L : Ledger Idx) (s : St Idx) : Prop :=
  ∑ i ∈ L.bals, s i = s L.sup

/-- `f` touches nothing outside `P` — what a coupling confines a partner to. -/
def WritesWithin (P : Finset Idx) (f : St Idx → St Idx) : Prop :=
  ∀ s i, i ∉ P → f s i = s i

/-- `f` moves no net quantity across the ports it shares with `L`. A transfer that
debits one shared balance and credits another satisfies this; a mint into a shared
balance does not. -/
def QNeutralOn (P : Finset Idx) (L : Ledger Idx) (f : St Idx → St Idx) : Prop :=
  ∀ s, ∑ i ∈ L.bals.filter (· ∈ P), f s i
        = ∑ i ∈ L.bals.filter (· ∈ P), s i

/-- **The milestone.** A foreign transition confined to `L`'s ports and `Q`-neutral
on the shared balances preserves conservation.

The proof is three lines and every one of them is the discipline doing work: the
total is untouched *because it is not a port*; the private balances are untouched
*because the transition is confined to ports*; the shared balances net to zero *by
hypothesis*. Remove `sup_not_port` and the first line fails — see
`cons_broken_if_sup_is_port`. -/
theorem cons_of_portConfined (L : Ledger Idx) (f : St Idx → St Idx)
    (hw : WritesWithin L.ports f) (hq : QNeutralOn L.ports L f)
    (s : St Idx) (h : Cons L s) : Cons L (f s) := by
  have hsup : f s L.sup = s L.sup := hw s L.sup L.sup_not_port
  have hsum : ∑ i ∈ L.bals, f s i = ∑ i ∈ L.bals, s i := by
    rw [← Finset.sum_filter_add_sum_filter_not L.bals (· ∈ L.ports) (f s),
        ← Finset.sum_filter_add_sum_filter_not L.bals (· ∈ L.ports) s, hq s]
    congr 1
    refine Finset.sum_congr rfl ?_
    intro i hi
    exact hw s i (by simpa using (Finset.mem_filter.mp hi).2)
  unfold Cons at h ⊢
  rw [hsum, hsup, h]

omit [DecidableEq Idx] in
/-- The frame case: a transition touching none of a ledger's carriers preserves
conservation. Immediate, and worth stating because it is what makes composition
with an unrelated machine free. -/
theorem cons_of_disjoint (L : Ledger Idx) (f : St Idx → St Idx)
    (P : Finset Idx) (hw : WritesWithin P f)
    (hb : ∀ i ∈ L.bals, i ∉ P) (hs : L.sup ∉ P)
    (s : St Idx) (h : Cons L s) : Cons L (f s) := by
  have hsum : ∑ i ∈ L.bals, f s i = ∑ i ∈ L.bals, s i :=
    Finset.sum_congr rfl fun i hi => hw s i (hb i hi)
  unfold Cons at h ⊢
  rw [hsum, hw s L.sup hs, h]

/-- **The negative companion, and the point of the whole file.**

Drop `sup ∉ ports` and `cons_of_portConfined` is false. Here is the witness: one
balance, one total, and a partner permitted to bind the total. The partner writes
only its permitted index and is `Q`-neutral on the shared balances — vacuously, since
it shares none — yet conservation breaks.

This is exactly the coupling `BASIS.md` §5 admits, since `sup` is merely sort `Q`
and `κ` identifies same-sort carriers. -/
theorem cons_broken_if_sup_is_port :
    ∃ (bals : Finset Bool) (sup : Bool) (ports : Finset Bool)
      (f : St Bool → St Bool) (s : St Bool),
      sup ∉ bals ∧
      sup ∈ ports ∧                                    -- the discipline VIOLATED
      WritesWithin ports f ∧                           -- confined to its ports
      (∀ t, ∑ i ∈ bals.filter (· ∈ ports), f t i
            = ∑ i ∈ bals.filter (· ∈ ports), t i) ∧     -- Q-neutral on shared bals
      (∑ i ∈ bals, s i) = s sup ∧                      -- conservation HOLDS
      (∑ i ∈ bals, f s i) ≠ f s sup := by              -- and FAILS after
  -- No `classical`: `Bool` already has `DecidableEq`, and introducing
  -- `Classical.dec` makes the two `∅`s carry different instances, so
  -- `Finset.sum_empty` rewrites one side and not the other.
  refine ⟨{false}, true, {true},
          fun t i => if i = true then t i + 1 else t i,
          fun _ => 0, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · decide
  · decide
  · intro t i hi
    have : i ≠ true := by
      intro h; exact hi (by simp [h])
    simp [this]
  · -- The two sums are equal POINTWISE on an empty index set. Computing both to
    -- `0` via `Finset.sum_empty` rewrites only one side here; congruence avoids
    -- the question entirely.
    intro t
    refine Finset.sum_congr rfl ?_
    intro i hi
    have hfil : ({false} : Finset Bool).filter (· ∈ ({true} : Finset Bool)) = ∅ := by
      decide
    rw [hfil] at hi
    exact absurd hi (Finset.notMem_empty i)
  · simp
  · simp

end Defialgebra.Interface

## END FILE

## FILE lean/Defialgebra/Nary.lean

Original SHA256: 31b42f37aa3b357554c33f0563a0042a94dd618a63d5771c02aa310cab919680; bytes: 6238; rendered SHA256: 31b42f37aa3b357554c33f0563a0042a94dd618a63d5771c02aa310cab919680

/-
Copyright (c) 2026 Charles Hoskinson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Charles Hoskinson
-/
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Fintype.Basic
import Mathlib.Tactic.Linarith

/-!
# M3 — n-ary binding and bracket-independent agreement

`INTERFACE-COUNCIL.md` §2: pair-local `κ` makes associativity *unstatable*, because
`κ` is attached to a pair, not to an object. The remedy is **stable port names**
plus **n-ary composition over a global binding set**.

## What is proved

* `Binding` — a finite set of port-pairs (global names).
* `Agrees` — state agreement on every bound pair.
* `agrees_iff_agrees_sym` — agreement depends only on the symmetric closure
  (pair orientation does not matter).
* `agrees_union`, `union_assoc`, `agrees_union_assoc` — multi-party composition
  is constraint-union; union is associative, so bracketing does not change
  agreement.
* `agrees_of_same_symClosure` — **two-binding reindex:** if two bindings have
  equal symmetric closures, they induce the same agreement predicate (listing
  order / pair orientation / redundant reverse edges do not matter).
* `pairLocal_excludes_skip` — **negative companion.** Pair-local edges on a
  binary cut cannot include a skip edge with both ends on the same side.
* `skip_not_pairLocal_witness` — concrete three-port witness.

## What is not proved

* Operational transition systems / reachability.
* Lifting M1 conservation through transitions.
* Corpus adequacy (M4).
-/

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false

namespace Defialgebra.Nary

variable {Idx : Type*} [DecidableEq Idx]

/-- A construction exposes a finite set of globally named ports. -/
structure Machine (Idx : Type*) where
  ports : Finset Idx

/-- Global binding: port-pairs that must carry equal state. -/
structure Binding (Idx : Type*) where
  pairs : Finset (Idx × Idx)

def St (Idx : Type*) : Type _ := Idx → ℤ

def PairAgrees (s : St Idx) (p : Idx × Idx) : Prop :=
  s p.1 = s p.2

def Agrees (B : Binding Idx) (s : St Idx) : Prop :=
  ∀ p ∈ B.pairs, PairAgrees s p

def symClosure (P : Finset (Idx × Idx)) : Finset (Idx × Idx) :=
  P ∪ P.image (fun p => (p.2, p.1))

theorem agrees_iff_agrees_sym (B : Binding Idx) (s : St Idx) :
    Agrees B s ↔ (∀ p ∈ symClosure B.pairs, PairAgrees s p) := by
  constructor
  · intro h p hp
    simp only [symClosure, Finset.mem_union, Finset.mem_image] at hp
    rcases hp with hp | ⟨q, hq, rfl⟩
    · exact h p hp
    · exact (h q hq).symm
  · intro h p hp
    exact h p (by
      simp only [symClosure, Finset.mem_union]
      exact Or.inl hp)

def Binding.union (B₁ B₂ : Binding Idx) : Binding Idx where
  pairs := B₁.pairs ∪ B₂.pairs

theorem agrees_union (B₁ B₂ : Binding Idx) (s : St Idx) :
    Agrees (B₁.union B₂) s ↔ Agrees B₁ s ∧ Agrees B₂ s := by
  constructor
  · intro h
    exact ⟨fun p hp => h p (Finset.mem_union_left _ hp),
           fun p hp => h p (Finset.mem_union_right _ hp)⟩
  · rintro ⟨h₁, h₂⟩ p hp
    cases Finset.mem_union.1 hp with
    | inl hp => exact h₁ p hp
    | inr hp => exact h₂ p hp

theorem union_assoc (B₁ B₂ B₃ : Binding Idx) :
    (B₁.union B₂).union B₃ = B₁.union (B₂.union B₃) := by
  cases B₁; cases B₂; cases B₃
  simp [Binding.union, Finset.union_assoc]

theorem union_comm (B₁ B₂ : Binding Idx) :
    B₁.union B₂ = B₂.union B₁ := by
  cases B₁; cases B₂
  simp [Binding.union, Finset.union_comm]

/-- **Bracket independence.** Agreement under `((B₁ ∪ B₂) ∪ B₃)` iff under
`(B₁ ∪ (B₂ ∪ B₃))`. -/
theorem agrees_union_assoc (B₁ B₂ B₃ : Binding Idx) (s : St Idx) :
    Agrees ((B₁.union B₂).union B₃) s ↔ Agrees (B₁.union (B₂.union B₃)) s := by
  rw [union_assoc]

/-- **Two-binding reindex (M3-DESIGN item 4).** Bindings with the same symmetric
closure of pairs induce the same agreement predicate. Parenthesization of n-ary
composition is already ; this covers reordering and
re-orienting the declared pair list. -/
theorem agrees_of_same_symClosure (B₁ B₂ : Binding Idx) (s : St Idx)
    (h : symClosure B₁.pairs = symClosure B₂.pairs) :
    Agrees B₁ s ↔ Agrees B₂ s := by
  rw [agrees_iff_agrees_sym, agrees_iff_agrees_sym, h]

structure BinaryCut (Idx : Type*) where
  left : Finset Idx
  right : Finset Idx
  disjoint : Disjoint left right

/-- Pair-local κ: every edge spans the cut. -/
def PairLocal (C : BinaryCut Idx) (P : Finset (Idx × Idx)) : Prop :=
  ∀ p ∈ P,
    (p.1 ∈ C.left ∧ p.2 ∈ C.right) ∨ (p.1 ∈ C.right ∧ p.2 ∈ C.left)

/-- Skip edge: both ends on the left side (cannot be stated by pair-local κ). -/
def SkipEdge (C : BinaryCut Idx) (p : Idx × Idx) : Prop :=
  p.1 ∈ C.left ∧ p.2 ∈ C.left ∧ p.1 ≠ p.2

/-- **Negative companion.** Pair-local edge sets exclude skip edges. -/
theorem pairLocal_excludes_skip (C : BinaryCut Idx) (P : Finset (Idx × Idx))
    (hPL : PairLocal C P) {p : Idx × Idx} (hp : p ∈ P) (hS : SkipEdge C p) :
    False := by
  rcases hPL p hp with ⟨_, hR⟩ | ⟨hR, _⟩
  · exact Finset.disjoint_left.1 C.disjoint hS.2.1 hR
  · exact Finset.disjoint_left.1 C.disjoint hS.1 hR

private theorem cut02_1_disjoint :
    Disjoint ({(0 : Fin 3), 2} : Finset (Fin 3)) {1} := by
  decide

private def cut02_1 : BinaryCut (Fin 3) :=
  ⟨{0, 2}, {1}, cut02_1_disjoint⟩

private theorem skip02 : SkipEdge cut02_1 ((0 : Fin 3), 2) := by
  unfold SkipEdge cut02_1
  refine ⟨?_, ?_, ?_⟩
  · exact Finset.mem_insert_self (0 : Fin 3) {2}
  · exact Finset.mem_insert_of_mem (Finset.mem_singleton_self (2 : Fin 3))
  · exact by decide

/-- Concrete three-port witness: cut `{0,2} | {1}`, skip `(0,2)` is not pair-local
for any edge set containing it. -/
theorem skip_not_pairLocal_witness :
    ∃ (C : BinaryCut (Fin 3)) (p : Fin 3 × Fin 3),
      SkipEdge C p ∧
      ∀ P : Finset (Fin 3 × Fin 3), p ∈ P → ¬ PairLocal C P := by
  refine ⟨cut02_1, (0, 2), skip02, ?_⟩
  intro P hp hPL
  exact pairLocal_excludes_skip cut02_1 P hPL hp skip02

end Defialgebra.Nary

## END FILE

## FILE lean/lake-manifest.json

Original SHA256: 8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002; bytes: 3153; rendered SHA256: 2317de07b45391e17cb591feb02b1b51cb80ba2781c52b2d8402d26f83dcfa26

{"fixedToolchain":false,"lakeDir":".lake","name":"defialgebra","packages":[{"configFile":"lakefile.lean","inherited":false,"inputRev":"v4.33.0-rc2","manifestFile":"lake-manifest.json","name":"mathlib","rev":"51e6992efd06126df61a496bebf8f49482a4e129","scope":"leanprover-community","subDir":null,"type":"git","url":"https://github.com/leanprover-community/mathlib4"},{"configFile":"lakefile.toml","inherited":true,"inputRev":"main","manifestFile":"lake-manifest.json","name":"plausible","rev":"123d15766ba49356c02ebad2a4462dfe12d79899","scope":"leanprover-community","subDir":null,"type":"git","url":"https://github.com/leanprover-community/plausible"},{"configFile":"lakefile.toml","inherited":true,"inputRev":"main","manifestFile":"lake-manifest.json","name":"LeanSearchClient","rev":"f5c090429dff3cf66cb65562526c9ea6e8edfbcb","scope":"leanprover-community","subDir":null,"type":"git","url":"https://github.com/leanprover-community/LeanSearchClient"},{"configFile":"lakefile.toml","inherited":true,"inputRev":"main","manifestFile":"lake-manifest.json","name":"importGraph","rev":"bb3469a87774349fe01898d8bf2fc6a1ce6411ca","scope":"leanprover-community","subDir":null,"type":"git","url":"https://github.com/leanprover-community/import-graph"},{"configFile":"lakefile.lean","inherited":true,"inputRev":"main","manifestFile":"lake-manifest.json","name":"proofwidgets","rev":"222c58dad7706a6e7cae46c0edd65ea881d3ee27","scope":"leanprover-community","subDir":null,"type":"git","url":"https://github.com/leanprover-community/ProofWidgets4"},{"configFile":"lakefile.toml","inherited":true,"inputRev":"master","manifestFile":"lake-manifest.json","name":"aesop","rev":"7db8190085343afde2f5d2cdcc9bac719b6ec02c","scope":"leanprover-community","subDir":null,"type":"git","url":"https://github.com/leanprover-community/aesop"},{"configFile":"lakefile.toml","inherited":true,"inputRev":"master","manifestFile":"lake-manifest.json","name":"Qq","rev":"ef42f8944eaf5b6cbfbe75d1917d824c7dd6cf33","scope":"leanprover-community","subDir":null,"type":"git","url":"https://github.com/leanprover-community/quote4"},{"configFile":"lakefile.toml","inherited":true,"inputRev":"main","manifestFile":"lake-manifest.json","name":"batteries","rev":"76e1c118b0700b4ceafe99532e887d6431625e1a","scope":"leanprover-community","subDir":null,"type":"git","url":"https://github.com/leanprover-community/batteries"},{"configFile":"lakefile.toml","inherited":true,"inputRev":"v4.33.0-rc2","manifestFile":"lake-manifest.json","name":"Cli","rev":"1319485273bf87833fa472afbcefdedecb16b45f","scope":"leanprover","subDir":null,"type":"git","url":"https://github.com/leanprover/lean4-cli"}],"packagesDir":".lake/packages","version":"1.2.0"}

## END FILE

## FILE lean/lakefile.toml

Original SHA256: 4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86; bytes: 414; rendered SHA256: 4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86

name = "defialgebra"
version = "0.1.0"
keywords = ["math"]
defaultTargets = ["Defialgebra", "DefiKernel"]

[leanOptions]
pp.unicode.fun = true # pretty-prints `fun a ↦ b`
relaxedAutoImplicit = false
weak.linter.mathlibStandardSet = true
maxSynthPendingDepth = 3

[[require]]
name = "mathlib"
scope = "leanprover-community"
rev = "v4.33.0-rc2"

[[lean_lib]]
name = "Defialgebra"

[[lean_lib]]
name = "DefiKernel"

## END FILE

## FILE lean/lean-toolchain

Original SHA256: 0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6; bytes: 29; rendered SHA256: 0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6

leanprover/lean4:v4.33.0-rc2

## END FILE

## FILE mutations/metatheory.json

Original SHA256: bd5f6269777ac4bd7d6a3192d82dffd386ca5bfc135dd662b3076f26860a42fc; bytes: 5619; rendered SHA256: ccd3ff6ea68d02e2cdfb10b7ab4d4b2fe8d0baf8de1a00f94766de9e8904d3d9

{"modules":["DefiKernel.Metatheory.SequentialGroups","DefiKernel.Metatheory.Observation","DefiKernel.Metatheory.Examples","DefiKernel.Metatheory.Tests","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.SequentialGroups","name":"entry-world-at-seq","needle":"    let middle := runGroup cfg boundaries cursor first\n    runGroup cfg boundaries middle second","replacement":"    let middle := runGroup cfg boundaries cursor first\n    runGroup cfg boundaries\n      { middle with world := cursor.world } second","required_false":["metatheory.group.world-chain"]},{"module":"DefiKernel.Metatheory.SequentialGroups","name":"entry-store-at-seq","needle":"    let middle := runGroup cfg boundaries cursor first\n    runGroup cfg boundaries middle second","replacement":"    let middle := runGroup cfg boundaries cursor first\n    runGroup cfg boundaries\n      { middle with world := { middle.world with capabilities := cursor.world.capabilities } } second","required_false":["metatheory.group.store-chain"]},{"module":"DefiKernel.Metatheory.SequentialGroups","name":"reset-history-at-seq","needle":"    let middle := runGroup cfg boundaries cursor first\n    runGroup cfg boundaries middle second","replacement":"    let middle := runGroup cfg boundaries cursor first\n    runGroup cfg boundaries\n      { middle with outputs := cursor.outputs } second","required_false":["metatheory.group.history-chain"]},{"module":"DefiKernel.Metatheory.SequentialGroups","name":"reset-index-at-seq","needle":"    let middle := runGroup cfg boundaries cursor first\n    runGroup cfg boundaries middle second","replacement":"    let middle := runGroup cfg boundaries cursor first\n    runGroup cfg boundaries\n      { middle with nextIndex := cursor.nextIndex } second","required_false":["metatheory.group.index-chain"]},{"module":"DefiKernel.Metatheory.SequentialGroups","name":"clear-failure-at-seq","needle":"    let middle := runGroup cfg boundaries cursor first\n    runGroup cfg boundaries middle second","replacement":"    let middle := runGroup cfg boundaries cursor first\n    runGroup cfg boundaries\n      { middle with failure := none } second","required_false":["metatheory.group.refusal-absorption"]},{"module":"DefiKernel.Metatheory.SequentialGroups","name":"skip-second-child","needle":"    let middle := runGroup cfg boundaries cursor first\n    runGroup cfg boundaries middle second","replacement":"    let middle := runGroup cfg boundaries cursor first\n    middle","required_false":["metatheory.group.child-executed"]},{"module":"DefiKernel.Metatheory.SequentialGroups","name":"reverse-child-order","needle":"    let middle := runGroup cfg boundaries cursor first\n    runGroup cfg boundaries middle second","replacement":"    let middle := runGroup cfg boundaries cursor second\n    runGroup cfg boundaries middle first","required_false":["metatheory.group.ordered"]},{"module":"DefiKernel.Metatheory.SequentialGroups","name":"zero-boundary-index","needle":"  | .step action => Composition.advance cfg boundaries cursor action","replacement":"  | .step action => Composition.advance cfg (fun _ ↦ boundaries 0) cursor action","required_false":["metatheory.group.boundary-index"]},{"module":"DefiKernel.Metatheory.Observation","name":"omit-observed-ledger","needle":"decide (∀ cell, left.world.state.balance cell = right.world.state.balance cell)","replacement":"true","required_false":["metatheory.observe.world-diff"]},{"module":"DefiKernel.Metatheory.Observation","name":"omit-observed-store","needle":"decide (left.world.capabilities = right.world.capabilities)","replacement":"true","required_false":["metatheory.observe.store-diff"]},{"module":"DefiKernel.Metatheory.Observation","name":"omit-observed-history","needle":"decide (left.branch.outputs = right.branch.outputs)","replacement":"true","required_false":["metatheory.observe.output-diff"]},{"module":"DefiKernel.Metatheory.Observation","name":"omit-observed-failure","needle":"decide (left.branch.failure = right.branch.failure)","replacement":"true","required_false":["metatheory.observe.failure-diff"]},{"module":"DefiKernel.Metatheory.Observation","name":"omit-observed-receipt","needle":"decide (left.receipt = right.receipt)","replacement":"true","required_false":["metatheory.observe.receipt-diff"]},{"module":"DefiKernel.Metatheory.Observation","name":"omit-observed-index","needle":"decide (left.branch.nextIndex = right.branch.nextIndex)","replacement":"true","required_false":["metatheory.observe.next-index-diff"]}],"positive_checks":["metatheory.positive.single-leaf","metatheory.positive.equal-observation"],"schema_version":1}

## END FILE

## FILE openspec/changes/operational-interface-binding-preservation/design.md

Original SHA256: d51cec12dfc85bb99817659072cfc88cb32cd362491a3f397adcfcd6eb201495; bytes: 36125; rendered SHA256: d51cec12dfc85bb99817659072cfc88cb32cd362491a3f397adcfcd6eb201495

## Context

This is the M2 planning candidate, awaiting independent planning acceptance before implementation. Sprint9 is accepted and delivered: Lean source `eec499d613688137a341f3556cd80ca461dd2ee9`, source/evidence commit `ec9ed80457d7a9c4064d26ab193591579027abae`, and archive/verified remote commit `9908d9b56be2d5ed2b58a16fa8d28b23f33733ff` on `semantic-kernel-pivot` (no main merge). Exact records are `review/semantic-kernel/sprint9/archive-delivery.json` and `acceptance/final-acceptance.json`; the accepted API/baseline binding is `review/semantic-kernel/sprint10/planning/official-preparation/dependency-baseline.json`. Relevant source bytes remain equal through delivery. The accepted M1 source supplies `DefiKernel.Metatheory.SeqGroup.empty/step/seq`, `flatten`, `runGroup cfg boundaries cursor group` and `runGroup_eq_continueRun`. S10 implementation remains gated on same-candidate nonauthor GPT-6/native Fable5.1 medium planning acceptance. Material dependency changes require rechecking the bindings and revising the plan before that gate.

The current kernel has exact rational typed balances, actual evaluated receipts, permanent capability IDs, global catalog validation and binary shared execution. `Composition.executeStep_sound` converts an actual successful executeStep equality into `StepSound`; `Atomic.step_receipt_balance` consumes that soundness premise to give the exact cell-effect equation. `Composition.validateCatalog` forbids duplicate exported cells globally and validates imports against the exact exported cell. A live balance resource and a frozen invocation output are different objects. No historical Interface/Nary file changes are permitted.

## Goals / Non-Goals

**Goals:** finite typed receipt accounting; conditional initialized interface totals; exact executable global binding queries; actual-step and every-prefix preservation; algebraic constraint transport; independent nonzero financial witnesses and source mutation evidence.

**Non-Goals:** a new financial transition or storage alias model; inferred semantic certificates; solvency, liveness or machine arithmetic; finite-participant execution, causal monitor rules, routing trees, active extension, capability provenance or Atomic boundary regrouping. Three qualified names are a constraint example, not a three-party executor. No unconditional preservation from equal entry balances or from asset-supply neutrality.

## Decisions

### 1. Modules and stable mathematical interfaces

New namespace `DefiKernel.Interface`, files `Regions.lean`, `Accounting.lean`, `Bindings.lean`, `Preservation.lean`, `Examples.lean`, `Tests.lean`, `Audit.lean`, `Verify.lean`. Proof helpers may split into adjacent new modules without changing contracts. Runtime declarations, including executable predicates and private helpers, precede `-- BEGIN PROOFS`. Root integration is `lean/DefiKernel.lean`; there is no `DefiKernel.Verify` target. All Lake commands run with working directory `lean/` and its pinned toolchain.

Use existing type parameters P/A/D, decidable equality, and the finite instances required by actual execution. Define:

```text
Region P A D := { domain : D, asset : A, cells : Finset (Cell P A D) }
Region.WellFormed L := ∀ c ∈ L.cells, c.1 = L.domain ∧ c.2.2 = L.asset
balanceSum L s := sum over L.cells of s.balance c
receiptCellEffect receipt c :=
  invoked _ e => (e.deltas.map (fun d => if d.1 = c then d.2 else 0)).sum
  issued _ | revoked _ => 0
receiptDelta L receipt := sum over L.cells of receiptCellEffect receipt c
ValueSupports S f := ∀ s t, AgreeOn S s t → f s = f t
```

The inspected `State.balance` accessor has exactly this cell-to-rational type. Its accepted M1 source binding is captured in the dependency manifest; do not introduce a second ledger. Finset sums are executable; a computational `region.cells.toList` fold is allowed with proved equality to the finite sum. Region declarations use set semantics. WellFormed is an explicit proof premise, not an additional admission checker. Exact sum accounting holds even for mixed regions, but dimensioned interface contracts require WellFormed. The empty sum is zero. Repeated receipt targets are all summed. Define and prove `receiptCellEffect = Atomic.receiptEffect` before reusing the existing exact-cell bridge. This small computational facade supplies auditable query code, not an alternative executor.

Alternative rejected: whole-asset supply as region delta. It loses transfers across the region boundary. Another rejected alternative is a caller-supplied effect table in the accounting theorem.

### 2. Actual receipt accounting and noncircular total preservation

For arbitrary cfg, boundary, index, history, step, pre and r, prove:

```text
executeStep cfg boundary index history step pre = .ok r
  → balanceSum L r.world.state = balanceSum L pre.state + receiptDelta L r.receipt
```

Apply `Composition.executeStep_sound` to the actual success equality, then `Atomic.step_receipt_balance` to its `StepSound` witness, the new receipt-effect facade equality, and a finite-sum identity. Invocation, issue and revoke are covered; administration preserves balances while stores change. The receipt fold over newly appended actual successful events telescopes from the supplied entry state to every sequential prefix. For continuation from an existing cursor, exclude its preexisting event prefix from that fold and retain its old events/outputs unchanged; no claim reconstructs an arbitrary supplied cursor from genesis. For an arbitrary supplied cursor, prove the continuation result directly by induction over actual `Composition.advance`/`Composition.continueRun`, or define a suffix trace indexed by the complete entry cursor. Prove the old-event append decomposition before summing the new suffix (equivalently `result.events.drop entry.events.length`). `Composition.TraceSound.nil` starts at empty events/history and index0, and `continueRun_trace_sound` only preserves an existing TraceSound premise; neither supplies one for F16. No premise may require the arbitrary entry cursor to be genesis-reachable. Actual refusals append no successful receipt and retain the reached state. Shared-run folds use the actual global accepted attempts, not isolated branch re-execution or duplicate receipt collection.

For a shared finite cell set `Q : Finset (Cell P A D)` and support `S : Set (Cell P A D)`, define `WritesWithin Q receipt := ∀ c ∈ receipt.writes, c ∈ Q` and `NeutralOn L Q receipt := sum c ∈ L.cells ∩ Q of receiptCellEffect receipt c = 0`. Prove actual write locality makes effects outside Q zero. These premises yield unchanged region total even when shared effects are individually nonzero.

For `balanceSum L s = f s`, assume initialization, ValueSupports S f and disjointness of every actual receipt write from S, together with confinement and neutrality. State a generic local obligation over **every** current pre-world, history, absolute index, boundary and permitted step, with actual success equality. Lift by actual trace induction. Concretely, for `Allowed : Step P A D → Prop`, local preservation has shape `∀ boundary index history step pre r, Allowed step → I pre.state → executeStep cfg boundary index history step pre = .ok r → I r.world.state`. The prefix theorem assumes initialization of I and static membership of every program step in Allowed; binary invocation branches use Allowed (.invoke inv). This is an explicit conditional theorem, not automatic inference of Allowed. Do not premise the final invariant, an already successful completed run, or equality of the desired post-total. The fixed ghost q specialization uses constant f and empty support. A private support cell is one sufficient instance; arbitrary state-dependent f requires its explicit value support proof.

### 3. Exact binding query and failure precedence

Define `Binding := QualifiedPort × QualifiedPort` and use an ordered `List Binding` for query input. Repetition is permitted and logically idempotent. Define `resolveExport catalog name : Except EndpointFailure Cell`; lookup first the exact component ID, then the exact resource-export port ID. `EndpointFailure` distinguishes `missingComponent(name)` and `missingPort(name)`. Input/output port IDs and import source names are not independently declared resource exports. Catalog validation is not a proof of balance equality.

Define the production API `checkBindings cfg edges state : Except BindingFailure PUnit` and `bindingsHold cfg edges state : Bool` as its success projection. Failures are:

```text
configuration
endpoint(edgeIndex : Nat, side : left | right, reason : EndpointFailure)
domainMismatch(edgeIndex, leftCell, rightCell)
assetMismatch(edgeIndex, leftCell, rightCell)
unequal(edgeIndex, leftName, rightName, leftAmount : ℚ, rightAmount : ℚ)
```

First call existing `validateCatalog cfg.registry cfg.catalog`, including when edges is empty. On failure return configuration. Then traverse edges in original list order with zero-based positions. For each edge resolve left, resolve right, compare domain, compare asset, compare balances, in that exact order. Return its first failure or continue. Success is `.ok ()`. Earlier inequality wins over later missing endpoint; left missing endpoint wins over right; domain mismatch wins over asset mismatch. Never sort or deduplicate the query list before diagnostics. No input world/store mutation occurs.

`Agrees catalog edges s` is the proposition that each listed edge resolves both endpoints and their domain, asset and current balances agree. Prove:

```text
checkBindings cfg edges s = .ok ()
  ↔ validateCatalog cfg.registry cfg.catalog = true ∧ Agrees cfg.catalog edges s
bindingsHold cfg edges s = true ↔ the same conjunction
```

Also expose exact first-failure characterization and resolution uniqueness under valid catalogs. This is a concrete query, not a complete equivalence checker. Valid duplicate-free catalog lookup is fixed throughout a preservation theorem. Invalid catalogs still have deterministic query failure, with no financial inference from rejection.

Existing imports reference an export's exact cell. Prove this from catalog validity and instantiate after a real write. A self-binding `(p,p)` is automatically balance-equal when p resolves. Two distinct exported names in a valid catalog cannot alias one cell; equality of their balances needs a separate invariant.

### 4. Initialized binding preservation and constraint algebra

A sufficient local condition for a resolved edge (c,d) is equality of **actual** receipt effects at c and d. Initial balance equality plus the exact-cell bridge establishes post equality. Frame and self-edge cases are corollaries. For every permitted actual successful step require this paired-effect condition for each global edge; alternatively allow a separately proved local invariant-preservation obligation. Quantification includes arbitrary current history/index/boundary and pre-world, and may use the current invariant as an inductive antecedent. It must not assume the desired entire run or future peer result.

Prove initialization plus these local obligations entails Agrees at every actual sequential prefix and existing binary Interleaving prefix. Explicitly handle failed/absorbed cursors and failed/exhausted branch skips by actual world identity. Administrative steps have zero balance effects, without claiming store identity. Lift the sequential theorem through accepted M1 recursive-group full-cursor simulation, including a nonzero starting index and arbitrary supplied history. Use exactly:

```lean
DefiKernel.Metatheory.runGroup_eq_continueRun cfg boundaries cursor group :
  DefiKernel.Metatheory.runGroup cfg boundaries cursor group =
    Composition.continueRun cfg boundaries cursor (DefiKernel.Metatheory.flatten group)
```

The theorem shares P/A/D DecidableEq and Fintype binders and has no success-only or entry-trace premise. `CursorEquivalent` omits old raw worlds and is not a replacement for this full-cursor equality. A checked correspondence to actual execution is required; defining the group theorem to run a newly flattened list is insufficient.

Use list append as conjunction: `Agrees (E ++ F) ↔ Agrees E ∧ Agrees F`. Prove reversal of every edge, duplicate idempotence, append associativity and permutation invariance at the proposition/success level. Transfer initialization and step obligations across these laws to get prefix corollaries. Exact diagnostic payloads need not be equal after reordering or reversal.

Let `symClosure E` be the finite set of listed ordered pairs and their reverses. Equal symmetric closures imply equivalent Agrees predicates, including resolution/dimension constraints. This criterion is sufficient, not necessary. With a valid catalog of three same-dimension exported cells, E=[A=B,B=C] and F=E++[A=C] have equal predicates for every state, by transitivity, but unequal symmetric closures. Do not generalize to a complete semantic-equivalence decision. Preserve all global edges; no binary cut is an argument to the query and no cut-local query mode is added.

### 5. Independent fixture contract

Use a fresh finite fixture universe P={alice,bob,carol,total,admin}, A={usd,eur}, D={home,away}; every unspecified cell balance is exactly zero. Compare the entire 20-cell ledger and full store, with independent literal expected data. No expected balance, receipt or failure may be obtained by calling a production Interface query or executor. Helpers constructing literal expected records are permitted. Capabilities are an explicit fixed live-entry list, holder alice, domain home, exact operation IDs and exact debit/changeSupply rights as needed; no blanket authorization. The initial store is exactly17 live entries ordered as follows (holder alice, domain home throughout): ID0=(op100,invoke),1=(op100,debit Alice),2=(op101,invoke),3=(op101,changeSupply home/usd),4=(op102,invoke),5=(op102,debit Alice),6=(op102,debit Bob),7=(op103,invoke),8=(op103,debit Alice),9=(op104,invoke),10=(op104,debit Alice),11=(op105,invoke),12=(op105,changeSupply home/usd),13=(op106,invoke),14=(op106,debit Alice),15=(op107,invoke),16=(op107,debit Bob). Every invocation supplies exactly its listed IDs in that order. All debit cells above mean home/USD at that party. Each request has parties=[] and claimedActor=none; arguments=[] except the F16 op107 USD4 argument. F18 issues a new op100 invoke grant to Bob at ID17, then revokes17; its final appended entry alone is tombstoned. The refused admin companion uses principal alice against trusted admin. Administration uses authenticated admin. All environments are empty, time0, and no claimedActor unless specified.

Freeze these operations: ID100 transfer2 (alice −2,bob +2); ID101 mint3 (bob +3,supply home/usd +3); ID102 paired debit (alice −1,bob −1,carol +2); ID103 one-sided debit (alice −1,carol +1); ID104 repeated targets (alice −1,alice −2,bob +3); ID105 total increment (total +1,supply home/usd +1); ID106 transfer7 (alice −7,carol +7). Each template has no arguments/parties, literal true guard, exactly the ordered deltas above, exactly the indicated supply list (otherwise []), no state/environment reads and a duplicate-free declared write list in first-target order. Reads, guard, supplied IDs, request, writes and repeated delta list are compared explicitly, not only net results. Output-free core fixtures emit []; a separate grouped fixture emits an actual post-balance USD snapshot and consumes it as described below; its expected snapshot is independently written literal data. The canonical valid catalog has C0 export A=Alice, C1 export B=Bob, C2 export C=Carol, C3 export U=Alice/home/EUR, C4 export V=Alice/away/USD and C5 export W=Alice/away/EUR, all local resource port0 and writable. C0 contains the unique interfaces for op100–107 and imports B/C; the exposed-total variant adds C6's writable home/total/USD export port0 and C0's matching import, while the private-total variant has C6 own that cell privately and no import. C7 imports A for F14. All unmentioned private cells/imports/outputs are empty. Interface op107 alone has input port11 of USD amount; core interfaces emit no outputs. F16's separate valid interface variant adds to op100 output port10 at Alice/home/USD, with no other interface change. Every interface/template signature matches and all catalogs are checked by actual validation. Private-total and deliberately exposed-total variants are separate valid catalogs.

| Fixture ID | Actual execution or query | Independently required observation |
|---|---|---|
| F01 | Region home/usd {alice,bob}, balances6,4; op100 | Final4,6; region10→10; delta0; effects −2,+2; unchanged full store; exact invoked receipt |
| F02 | Same actual op100, singleton {alice} | 6→4; delta−2; whole home/usd supply0 |
| F03 | Same entry6,4; op101 | 6,7; region10→13; delta+3; supplies[(home,usd),+3] |
| F04 | Entry6,4; op104 | Final3,7; singleton delta−3; ordered repeated receipt targets retained |
| F05 | F01 plus private total cell10, f reads it | Region10 and f10 after transfer; support {home,total,usd} framed |
| F06 | Entry Alice6/Bob4/total10; separate valid catalog exposes total as writable; op105 | Accepted total10→11, region remains10, region flow0, whole supply+1; total relation false |
| F07 | Entry alice=bob=5,carol0; op102, plus a recursive M1 seq of two op102 leaves | Original one-receipt case stays4/4/2; grouped companion has independent full expected cursors5/5/0 →4/4/2 →3/3/4 and A=B query success at both actual prefixes |
| F08 | Same entry; op103 | Accepted4,5,1; binding A=B false with exact unequal payload |
| F09 | Three names A,B,C; global edge A=C and cut {A,C}|{B} | Query on balances4,5,5 rejects A=C; the explicitly constructed empty cut-extracted edge list accepts; no participant execution claim |
| F10 | Catalog A=(component0,port0) alice/home/usd; B=(component1,port0) bob/home/usd; C=(component2,port0) carol/home/usd; E=(A,B),(B,C) | Equal5,5,5 succeeds; E vs E+(A,C) equivalent with unequal symmetric closures; independent edge (A,B) fails at4,5,5 |
| F11 | Entry A=U=V=W=5, all other cells0; additional valid exports U=(component3,port0) alice/home/eur; V=(component4,port0) alice/away/usd; W=(component5,port0) alice/away/eur; each balance5 | A=U assetMismatch; A=V domainMismatch; A=W domainMismatch takes precedence, all printed amounts5 |
| F12 | Entry Alice4/Bob5/Carol5; unknown X=(component99,port0), Y=(component0,port99) | Exact endpoint missingComponent vs missingPort with original edge index and side; all combinations and earlier inequality/later missing covered |
| F13 | Zero ledger; invalid catalog repeats C0, including empty edges; valid catalog empty edges and self-edge | Invalid configuration error; valid empty/self success; input state/store unchanged |
| F14 | Entry Alice6/Bob4; import source A in a distinct component, exact cell A, writable authorization preserved | After op100, import and canonical export observe Alice4; no second export of the same cell |
| F15 | Region home/USD {Alice,Bob,Carol}; F07 followed by actual op106 insufficientFunds and a skipped op101 suffix | World4,4,2, one successful receipt; failure kernel.insufficientFunds at absolute index1; no mint/suffix history; binding retained |
| F16 | Entry Alice6/Bob4, region {Alice,Bob}; accepted M1 group, entry index2 and one independently initialized prior output (index1,component0/port12,USD9); leaves op100 and snapshot-driven return2 Bob→Alice | First emits Alice4 at absolute index2; second reads that exact output and divides by literal2 to move2; final6,4, indices2/3 and nextIndex4, old history preserved, region10; capabilities include exact return-operation rights |
| F17 | Region home/USD {Alice,Bob,Carol}; binary admitted schedule [left,right,left], left=[op102,op106], right=[op102], initial alice=bob=5 | Complete actual run: left paired→4,4,2; right paired→3,3,4; left op106 refuses; actual attempt fold has two receipts; binding A=B and total10 persist |
| F18 | Entry Alice6/Bob4, region singleton Alice; authorized issue then revoke starting from explicit store length n=17 | Receipts issued n/revoked n; appended capability then tombstone; balances unchanged and region delta0; include rejected non-admin case with unchanged store |
| F19 | F17 entry/region/branches, schedule [left,left,right] | Left paired→4/4/2, left op106 refuses at local index1 leaving4/4/2, then right paired→3/3/4; left refusal retained, two successful receipts and one failed attempt in actual global order |
| F20 | F19 with left=[op102,op106,op101], right=[op102], schedule [left,left,left,right] | Third token skips the failed left mint suffix, preserving4/4/2 without an attempt/receipt/supply; peer then reaches3/3/4; exact left refusal and store retained |

F19 and F20 are bounded companions added after the provisional constructibility
check; original F17 remains required. Their independent global attempt sequence
is left/index0/op102 at5/5/0 → ok4/4/2, left/index1/op106 at4/4/2 →
error(kernel.insufficientFunds), right/index0/op102 at4/4/2 → ok3/3/4.
The full17-entry store remains unchanged. Left has one successful event at index0,
nextIndex1 and failure(index1,Some invoke op106,kernel.insufficientFunds); right
has one successful event at index0, nextIndex1 and no failure. Both output
histories are[], and each raw event retains the just-specified before/result world.
Left consumed is2 for F19 and3 for F20; right consumed is1 in both. F20's skipped
third left token changes only consumed and adds no global attempt. All20 ledger
cells are checked; region Alice/Bob/Carol totals10 at every prefix and A=B changes
5→4→3. These schedules directly exercise peer continuation after refusal, which
F17's refusal-last order does not. Failed and exhausted selection remain separate
identity cases in the generic prefix proofs; F20 is the explicit failed-suffix
runtime witness. These M2 fixtures remain unexecuted; their required behavior is stated against the inspected M1 API, with accepted Sprint9 delivery bound separately from these unexecuted M2 cases.

F12 uses query [(A,Y)] for the right missingPort oracle, [(X,A)] for left missingComponent, [(A,X)] for right missingComponent, [(X,Y)] for left-before-right precedence, and [(A,B),(A,X)] for earlier inequality0 versus missing endpoint1. F11 queries exactly [(A,U)], [(A,V)] and [(A,W)]. Also query valid C0 input-only port11 and, in the F16 catalog, output-only port10: each is missingPort for live resource resolution.

F07 retains its original one-step witness and adds a companion within the same fixture
ID. From a valid-catalog start cursor at index0, empty events/output history and
the fixed 17-entry store, execute actual
`Metatheory.SeqGroup.seq (.step op102) (.step op102)` using `runGroup`; here
`op102` denotes the fully specified invocation with IDs[4,5,6], empty arguments
and parties, principal Alice and no claimed actor. The first-leaf cursor and the
whole-group cursor are each compared to separately constructed expected records,
not to a flattened execution or a production Interface result. Their complete
20-cell ledgers are respectively4/4/2 and3/3/4 at home/USD Alice/Bob/Carol, all
other balances0. Both retain the exact initial17-entry store, outputs=[], and
failure=none; nextIndex is1 then2. The first event is at index0 with literal
pre-world5/5/0 and post-world4/4/2; the second is at index1 with literal
pre-world4/4/2 and post-world3/3/4. Expected receipts retain the full invoked
request/evaluated template, ordered effects[Alice−1,Bob−1,Carol+2], supply=[],
declared writes[Alice,Bob,Carol], empty reads and output list, and literal true
guard. Compare events=[first] then[first,second], with the exact result worlds.
The actual global query on[(A,B)] must return success at entry and at both
actual prefixes. This is a concrete initialized group-binding witness; its
nonzero equal endpoint effects discharge the generic local premise. The generic
group-binding theorem still covers arbitrary groups and supplied initialized
cursors under its stated obligations.

F16 starts and ends at Alice6/Bob4, so it is a total/history/full-cursor group
fixture, **not an initialized A=B witness**. No binding-equality premise is
inferred for it or added to its arbitrary continuation data.

F16's supplied old output at index1/component0/port12 is arbitrary continuation data, not a claim of prior reachability in this catalog. No prior event is fabricated to justify that entry. F16's snapshot/return template uses a new operation ID107, literal divisor2, input USD amount4, Bob−2/Alice+2; independent expected request arguments=[USD4]. It needs no causal preservation claim beyond these actual fixture checks. The finite fixture comparison count is discovered from actual tests, never inferred from this table. Additional access/admin controls are allowed but cannot replace a listed case.

### 6. Fourteen actual production mutations and protected expectations

Implement `scripts/run_interface_mutations.py` and `scripts/test_interface_mutation_runner.py` from the final accepted predecessor harness. Each variant changes one new runtime definition before the proof marker in a copied actual source closure, removes proof suffixes only under the established verified procedure, compiles the complete mutated runtime dependency closure, executes the real Audit entry point and records explicit false comparisons. Compilation alone is never financial detection. Every named designated comparison below must be true for control, false for its compiled mutant; its protected sibling remains true. Bind the actual replacement bytes, source path, counts, closure and independent expected data before production execution.

| ID | Real new runtime mutation | Designated comparison | Protected sibling |
|---|---|---|---|
| M01 | balanceSum folds over region.cells.toList.dropLast | F01 sum10 | Empty region sum0 |
| M02 | Negate receiptDelta's final signed sum | F02 delta−2 | F01 neutral delta0 |
| M03 | receiptCellEffect uses first matching target instead of sum | F04 singleton delta−3 | F02 one-target delta−2 |
| M04 | receiptDelta returns0 if receipt has nonzero supply for region dimension | F03 delta+3 | F01 delta0 |
| M05 | receiptDelta returns whole dimension supply | F02 delta−2 | F03 delta+3 |
| M06 | checkBindings drops final edge before traversal | F08 one-edge unequal result | F07 equal edge success |
| M07 | Query compares left balance with itself | F08 exact unequal result | F07 equal edge success |
| M08 | Query omits asset comparison | F11 A=U assetMismatch | F07 same-asset equality |
| M09 | Query omits domain comparison | F11 A=V domainMismatch | F07 same-domain equality |
| M10 | resolveExport searches port ID globally, ignoring component | F08 resolves B to Bob5 and rejects | F13 self-edge success |
| M11 | Missing port lookup falls back to first export of selected component | F12 missingPort at component0/port99 | F10 existing-port success |
| M12 | Traverse tail before checking current edge, preserving original indices | F12 first unequal index0 before missing index1 | F10 all valid equal edges |
| M13 | checkBindings bypasses catalog validation | F13 invalid-catalog empty-edge configuration | F13 valid empty success |
| M14 | receiptCellEffect for issued receipt returns1 rather than0 | F18 issued delta0 for singleton region | F01 invoked neutral delta0 |

M01's omission is order-independent for the designated nonempty region because both balances are positive. M10 deliberately uses colliding local port IDs in distinct valid components. M12 targets deterministic diagnostics rather than a financial theorem. M08/M09 target typed binding validation; M11/M13 target structural validation; distinguish these categories from M01–M07/M14 accounting/balance checks. Cut omission, writable total and false symmetric-closure completeness are actual semantic counterexamples, not invented runtime mutation flags or theorem-premise edits.

The immediate accepted predecessor is `scripts/check_metatheory_mutations.py`, `scripts/test_metatheory_mutation_runner.py`, `mutations/metatheory.json` and `DefiKernel.Metatheory.Audit` at eec499d. It exposes65 named real-CLI control contracts: 52 inherited cases (including the base proof-boundary case), 11 additional proof-tail/parser cases, and 2 production `#eval`/`IO.userError` forms. `review/semantic-kernel/sprint10/planning/official-preparation/runner-adaptation.json` freezes every old/new control name, complete fixture payload, expected exit/message, namespace, root, proof regex and production-error string. The adaptation contract itself does not execute new Interface controls. The bound predecessor Metatheory control run completed65/65 at eec499d; its summary and source identities are recorded in runner-adaptation.json, with accepted source/evidence/delivery status recorded in dependency-baseline.json. Retain every accepted control and recheck the binding if those inputs change. Historical Atomic runner inputs remain historical evidence.

The exact driver rename is `scripts/check_metatheory_mutations.py` → `scripts/run_interface_mutations.py`; the harness is `scripts/test_metatheory_mutation_runner.py` → `scripts/test_interface_mutation_runner.py`; manifest `mutations/metatheory.json` → `mutations/interface.json`; namespace/path `DefiKernel.Metatheory`/`lean/DefiKernel/Metatheory` → `DefiKernel.Interface`/`lean/DefiKernel/Interface`; Audit and RunnerInput/SplitComputation roots follow that same map. Rename `discovered-metatheory-dependency` → `discovered-interface-dependency`. Preserve the imported `DefiKernel.Interleaving.RunnerDependency` fixture and its theorem untouched: it remains an imported dependency whose proof tail must survive. The scoped-module regex and exact end-namespace regex substitute only Metatheory→Interface; the forbidden proof-tail token regex and proof marker remain byte-identical. Map exact `Metatheory runtime comparisons empty`, `Metatheory runtime comparison names are duplicated`, and `Metatheory runtime comparisons failed: {count}` to their Interface counterparts, preserving numeric failure counts in both run_cmd and actual production #eval forms. Control helper functions `runnerAllows`, `runnerIncludeSensitivity`, `runner_positive` and `runner_sensitivity` stay unchanged. Runtime financial imports include only the required new runtime modules and existing execution/example definitions; do not import prior Tests/Audit or new proof-only fixture helpers into production mutation roots.

Keep schema_version1 and its one global `positive_checks` list. Freeze two global checks: `interface.positive.transfer` checks an actual F01 transfer's independent entire world/store/request/receipt and neutral actual region receipt delta, without calling balanceSum or checkBindings; `interface.positive.empty-query` checks valid F13 empty-edge acceptance. Both must survive all14 mutants. Each table row's additional protected sibling is enforced by a separate source-bound per-mutant assertion matrix over actual saved Audit output, following the M1 pattern; these row-specific requirements are not silently inserted into or claimed enforced by the global schema. Missing/false required observations reject that mutant. All actual financial comparisons execute in control; a compiler refusal earns no detection credit.

Preserve the runner's explicit `--timeout-seconds 600` default and pass that argument in each production invocation. The outer harness bounds each runner process at1500 seconds. Record UTC and measured wall time, requested bounds, partial stdout/stderr and accepted/failed/blocked result; a timed-out command is blocked, not detected, and no successful-completion timing is invented. Preserve the inherited limitation that a subprocess timeout can prevent the inner runner from emitting its normal per-command record; the outer recorder must retain the timeout classification and partial output. Empty/missing inputs, source drift, malformed evidence, failed required positives, invalid proof trimming and missing/false production observations use the actual exit contract (0 accepted,1 detection/expectation failure,3 blocked).

### 7. Proof and acceptance evidence

Discover the actual imported Interface environment, full elaborated statements and axiom dependencies, including unused axioms, generated declarations and private helper name mappings. Classify explicit generic results, concrete reference instances, counterexamples and generated constants separately. No predetermined theorem count, forbidden custom axiom, sorry or native_decide. Runtime evidence includes exact full expected observations; mutation/control evidence has actual commands, UTC, exit status, stdout/stderr, source/tool/executable hashes, before/after byte bindings and artifact manifests. Preserve any nested Git metadata as archives, not embedded repositories.

The initial missing-feature check honestly precedes implementation after the gate. Then targeted LSP, pinned builds, fresh Audit/Verify, full integrated Lean build and all accepted Python regressions. Regression carries require exact relevant source/tool dependency equivalence and honest original run identity; do not relabel an older run as fresh. Run all new14 production mutants and the complete inherited control catalog at the frozen candidate. Native Grok and Fable5.1 medium review both source and final evidence; planning review is nonauthor GPT-6 plus native Fable5.1 medium, request `claude-fable-5-1[1m]` with `--effort medium`, record the actual returned model. Unavailable/cancelled reviewers remain open. Correct material findings without an inferred revision-count cap. Review opinions and finite fixtures are not Lean proofs.

## Risks / Trade-offs

- [Dependency evidence drifts] → Recheck exact accepted source/API and delivery bindings before review or implementation; acceptance of a different source does not transfer automatically.
- [A local condition merely assumes the desired run] → Quantify actual-step obligations over arbitrary current inputs and use initialization plus trace induction; prove nonzero paired-effect/support instances.
- [Logical constraint equivalence hides changed diagnostics] → State query-success equivalence separately from exact first-error behavior; retain original indices.
- [A mutation only fails elaboration] → No detection credit; require compiled runtime, named false oracle and protected true sibling; revise a nondiscriminating site before freeze.
- [Total observations are secretly writable] → Prove ValueSupports and write exclusion, plus an actually accepted violating counterexample with a separate valid exposed-total catalog.
- [New proofs get mistaken for historical/general n-ary closure] → Preserve historical files and explicitly leave M3–M6 execution obligations open.

## Migration Plan

1. Finalize these planning inputs, accepted dependency/baseline bindings, coverage map and strict OpenSpec validation. No M2 implementation or planning acceptance is inferred.
2. Freeze this complete planning bundle with exact source/API/control closure and actual baseline run identities or verified source-equivalent carries. Obtain nonauthor GPT-6/native Fable5.1 medium verdicts on the same bytes. Resolve blockers before implementation; rerun affected baseline checks if relevant inputs change.
3. Implement the new namespace and isolated tests with stock GPT-6/LSP-first checks; preserve old source/corpus identities and existing semantic behavior.
4. Freeze a source candidate, execute all required evidence, correct findings and obtain native Grok/Fable5.1-medium source/evidence acceptance on exact bytes.
5. Archive only when every task/evidence obligation is complete and verify authorized branch delivery. No merge to main. Reversible integration rollback removes only new imports/modules and leaves historical evidence intact.

## END FILE

## FILE openspec/changes/operational-interface-binding-preservation/proposal.md

Original SHA256: 86511aac24c8a04ec5ffc1c78f7003ec48beed25ef6f47d5e87f22f5430730d8; bytes: 3138; rendered SHA256: 86511aac24c8a04ec5ffc1c78f7003ec48beed25ef6f47d5e87f22f5430730d8

## Why

The typed kernel executes exact receipts and validates resource access, but it does not yet connect actual execution to finite interface totals and global balance-binding invariants. Historical Interface and Nary algebra does not establish those operational statements. This bounded M2 increment supplies the conditional bridge while keeping finite-participant execution and causal assumptions separate.

## What Changes

- Define finite typed regions, complete signed actual-receipt effects and exact region accounting, including transfers across a region boundary and nonzero issuance.
- Prove interface-total preservation from initialized totals, actual write confinement, neutral shared-region flow and explicit value-valued support for state-dependent declared totals.
- Resolve globally qualified resource exports and implement an exact concrete binding query with deterministic catalog, endpoint, dimension and inequality failures; prove its relation to global equality constraints.
- Prove initialized binding preservation under actual accepted steps and all sequential/shared prefixes, with recursive sequential-group corollaries through accepted M1 simulation. Prove global union/reorientation laws without changing participant execution.
- Add independent funded examples, genuine accepted-step counterexamples, fourteen planned production mutations, inherited defensive runner controls, complete proof inventory and source-bound native acceptance evidence.

## Capabilities

### New Capabilities

- `typed-region-accounting`: Exact finite region sums and full signed effects of actual successful receipts.
- `interface-total-preservation`: Conditional operational conservation and supported declared-total invariants.
- `global-binding-preservation`: Deterministic typed binding queries and initialized global constraint preservation.
- `interface-binding-regression-evidence`: Independent expected observations, actual mutations, complete imported audits and acceptance gates.

### Modified Capabilities

None. Historical statements and existing operator semantics remain unchanged.

## Impact

Planning candidate; implementation has not begun. Sprint9 dependency is accepted and delivered: source `eec499d613688137a341f3556cd80ca461dd2ee9`, source/evidence `ec9ed80457d7a9c4064d26ab193591579027abae`, archive/verified remote `9908d9b56be2d5ed2b58a16fa8d28b23f33733ff` on `semantic-kernel-pivot`. The exact accepted API and retained baseline bindings are in `review/semantic-kernel/sprint10/planning/official-preparation/dependency-baseline.json`. New code belongs in `lean/DefiKernel/Interface/`, with the actual root `lean/DefiKernel.lean` and dedicated runner integration. No toolchain change is planned. Nonauthor stock GPT-6 and native Fable5.1 medium must accept the same frozen S10 plan before implementation. Request `claude-fable-5-1[1m]` with `--effort medium` and record the returned model. Substantive implementation/evidence review uses native Grok and Fable5.1 medium; stock GPT-6 implements. No Foreman, M2 planning approval, implemented theorem or accepted M2 result is claimed by author preparation.

## END FILE

## FILE openspec/changes/operational-interface-binding-preservation/specs/global-binding-preservation/spec.md

Original SHA256: b2c21cd551383b88cbd9ff807be8902ef7c71047d064bf015c6ac09fd0c36902; bytes: 7289; rendered SHA256: b2c21cd551383b88cbd9ff807be8902ef7c71047d064bf015c6ac09fd0c36902

## Purpose

Resolve stable globally qualified balance resources and preserve initialized typed equality constraints over actual execution prefixes.

## ADDED Requirements

### Requirement: Exact typed global binding query

The system SHALL resolve endpoints through their exact component and resource-export IDs, validate the actual catalog first, and then process input edges in original order. Per edge it MUST check left resolution, right resolution, domain, asset and balance in that order, returning the exact first failure with zero-based index and relevant names, cells or amounts. A Boolean success projection MUST agree with the exact query.

#### Scenario: GB01 Exact qualified identity
- **WHEN** two valid components both export local port0 but their USD balances are4 and5
- **THEN** the query compares distinct actual cells and reports unequal at the original edge index with amounts4,5

#### Scenario: GB02 Missing endpoint kind and side
- **WHEN** an edge refers to absent component99 or absent port99 in existing component0
- **THEN** the query distinguishes missingComponent from missingPort and records the exact left/right endpoint and edge index

#### Scenario: GB03 Dimensional mismatch
- **WHEN** equal numeric balances are linked across USD/EUR or home/away
- **THEN** assetMismatch or domainMismatch is returned; domainMismatch wins when both differ

#### Scenario: GB04 Failure precedence
- **WHEN** edge0 has unequal resolved balances and edge1 has a missing endpoint
- **THEN** edge0 unequal is returned; within an edge missing left wins over missing right

#### Scenario: GB05 Catalog precedes emptiness
- **WHEN** a duplicate-component catalog is queried with an empty edge list
- **THEN** configuration failure is returned; the same empty list succeeds for a valid catalog

#### Scenario: GB06 Outputs are not live resources
- **WHEN** a qualified ID names only a historical output/input port, not a resource export
- **THEN** resource resolution returns missingPort even if a history value exists

### Requirement: Binding meaning and actual alias distinction

The system SHALL define agreement as successful typed resolution plus equality for every global edge and prove query acceptance equivalent to catalog validity and that proposition. Existing imports MUST retain exact export-cell identity; distinct exported cells MUST NOT be treated as aliases merely because balances match.

#### Scenario: GB07 Positive distinct-cell equality
- **WHEN** A and B resolve to distinct USD cells both containing5
- **THEN** agreement holds at entry, with no implied future write discipline

#### Scenario: GB08 One-sided accepted write
- **WHEN** actual one-sided debit1 changes A5 to4 while B remains5
- **THEN** agreement becomes false after successful execution

#### Scenario: GB09 Existing resource alias
- **WHEN** a valid import references canonical export A and actual transfer changes its cell6 to4
- **THEN** both views read the same exact cell4 without declaring a duplicate export

#### Scenario: GB10 Self binding
- **WHEN** a self-edge references a resolving resource in a valid catalog
- **THEN** it succeeds in every state; an unresolved self-edge still reports its endpoint error

### Requirement: Initialized actual binding preservation

The system SHALL derive edge preservation from initialized equality and equal actual receipt effects, then prove all global bindings at every sequential and binary shared prefix from initialization and locally quantified actual-step obligations. Refusal/skip identity and administrative balance identity MUST be included; group lifting MUST use accepted actual M1 simulation. Arbitrary-entry sequential/group preservation MUST retain supplied prefix data and use actual continuation/suffix induction plus Metatheory.runGroup_eq_continueRun, without inventing a TraceSound genesis witness.

#### Scenario: GB11 Nonzero paired effects
- **WHEN** F07 executes one paired-debit receipt from A5/B5/Carol0 and its companion executes an actual M1 seq of two op102 leaves from the same entry
- **THEN** the original case reaches4/4/2; the group prefixes reach4/4/2 then3/3/4 with independently expected full cursors, exact receipts and successful A=B queries at both prefixes, instantiating initialized group-binding preservation

#### Scenario: GB12 Sequential refusal retained
- **WHEN** the paired step is followed by actual insufficient-funds refusal and stopped suffix
- **THEN** the binding remains4=4 with exact successful prefix and first refusal

#### Scenario: GB13 Shared peer progression
- **WHEN** F17 runs under left,right,left and companion F19 runs under left,left,right
- **THEN** A=B=3 in both final states; F19 retains the exact left refusal at4/4/2 before the right peer progresses, with both actual histories and the unchanged store

#### Scenario: GB14 Administrative or skipped step
- **WHEN** an actual administrative transition or failed/exhausted-stream identity occurs
- **THEN** balance bindings remain true while actual capability-store effects are retained

### Requirement: Global constraint algebra and scope

The system SHALL prove agreement over list concatenation is conjunction, and prove edge-reorientation, duplicate idempotence, permutation and associativity laws at proposition/query-success level. It MUST transfer initialization and step obligations to prefix invariants while preserving the complete global edge set. It MUST NOT claim identical first-error diagnostics after reordering or participant regrouping from these algebraic laws.

#### Scenario: GB15 Union and orientation
- **WHEN** global edge lists are concatenated, reassociated, duplicated or each edge reversed
- **THEN** agreement has the corresponding conjunction/equivalence law and initialized prefix obligations transport

#### Scenario: GB16 Global skip edge
- **WHEN** A=C is wholly inside one side of the cut {A,C}|{B}, with amounts4 and5
- **THEN** the actual global query rejects it; the deliberately empty cut-extracted list succeeds and therefore does not represent the same constraint

#### Scenario: GB17 Diagnostic distinction
- **WHEN** two failing edges are reordered or a failing edge is reversed
- **THEN** success equivalence holds but exact first index/side/amount payloads may change as specified

### Requirement: Symmetric closure is sufficient only

The system SHALL prove equal symmetric closures imply equivalent global agreement predicates, and provide a typed valid-catalog counterexample to necessity using transitive equality. It MUST NOT advertise symmetric-closure equality as a complete semantic equivalence checker.

#### Scenario: GB18 Sufficient closure criterion
- **WHEN** two global edge sets have equal symmetric closures
- **THEN** their agreement predicates are equivalent for every state under the same catalog

#### Scenario: GB19 Redundant transitive edge
- **WHEN** E=[A=B,B=C] and F=E+[A=C] use three resolving same-dimension resources
- **THEN** agreement predicates are equivalent for every state although symmetric closures differ

#### Scenario: GB20 Independent omitted edge
- **WHEN** an independently constraining A=B edge is omitted at balances4,5,5
- **THEN** the query can change from failure to success; redundancy is not inferred from omission alone

## END FILE

## FILE openspec/changes/operational-interface-binding-preservation/specs/interface-binding-regression-evidence/spec.md

Original SHA256: 392a50b4cfd7e88763f1e57dc354afaec2b15a6a7abd09d035ff844d85462463; bytes: 5968; rendered SHA256: 392a50b4cfd7e88763f1e57dc354afaec2b15a6a7abd09d035ff844d85462463

## Purpose

Bind operational interface claims to independent expected observations, genuine compiled source mutations, complete proof inventories and explicit acceptance gates.

## ADDED Requirements

### Requirement: Independent funded observations and negative companions

The implementation SHALL exercise all F01–F20 design fixtures with independent complete expected ledgers, stores, receipts, histories, positions, query payloads and failures relevant to each case. Nonzero neutral flows and actual successful invariant violations MUST be distinguished from refused calls and compiler controls.

#### Scenario: RE01 Independent expected data
- **WHEN** a financial or binding comparison is registered
- **THEN** its expected data are literal/reference construction independent of the production query/executor; full unspecified ledger cells are explicitly zero

#### Scenario: RE02 Broken premise succeeds operationally
- **WHEN** the writable-total or one-sided-binding negative is exercised
- **THEN** actual execution succeeds with the specified violating post-state; an access or typing refusal cannot replace it

#### Scenario: RE03 Nonempty audit
- **WHEN** the new runtime Audit is run
- **THEN** all unique registered comparisons execute, counts and names match their manifest, and absent/empty output is blocked

### Requirement: Actual mutation and defensive control evidence

The implementation SHALL execute all fourteen M01–M14 design mutations against copied actual new runtime source. Each accepted detection MUST compile, flip its designated comparison and preserve its specified positive sibling. It MUST execute every inherited accepted predecessor control, including all65 accepted predecessor cases, with the exact complete Metatheory-to-Interface name/source/fixture/expected-exit map and proof/production regex-string bindings. The global positive_checks schema MUST stay distinct from the source-bound per-mutant sibling matrix. Command/outer timeouts MUST remain600/1500 seconds with actual measured wall time and blocked timeout classification; accepted S9 result bindings MUST be verified at official freeze and rechecked after relevant changes.

#### Scenario: RE04 Compiled discriminating mutation
- **WHEN** a planned mutation is counted as detected
- **THEN** the full actual runtime closure compiles, its named oracle is false, protected sibling true and real Audit output/exit are saved

#### Scenario: RE05 Compiler failure gets no credit
- **WHEN** a mutation fails compilation or emits no designated observation
- **THEN** it is blocked or failed evidence, never a financial detection

#### Scenario: RE06 Production and proof-tail controls
- **WHEN** the inherited parser and real production #eval/IO.userError cases are adapted
- **THEN** all expected accepted/failed/blocked exits and source-bound production outputs are checked; display warnings cannot hide results

#### Scenario: RE07 Drift or missing inputs
- **WHEN** a source, manifest, required positive or runtime observation is missing or changes during a run
- **THEN** the harness refuses acceptance and preserves exact before/after identities

### Requirement: Complete proof and regression evidence

The implementation SHALL capture all imported Interface theorem/supplemental declarations, full elaborated statements, private mappings, source/module identities and actual axiom dependencies. It MUST separate explicit generic results, reference instances, counterexamples and generated constants, and prohibit sorry, custom axioms and native_decide. All accepted prior regression obligations MUST remain discharged with honest run identity.

#### Scenario: RE08 Imported proof discovery
- **WHEN** Verify elaborates the imported Interface environment
- **THEN** automatic inventory includes private/generated/unused declarations and full statement/axiom information without a hardcoded theorem count

#### Scenario: RE09 Exact regression identity
- **WHEN** old regression evidence is carried or a suite rerun
- **THEN** actual run revision and relevant dependency equivalence are recorded; old runs are never relabeled fresh

#### Scenario: RE10 Protected source preservation
- **WHEN** new modules and root import integrate
- **THEN** historical theorem/corpus bytes and required old sources remain preserved, with exact allowed integration changes recorded

### Requirement: Dependency and independent acceptance gates

The change SHALL require exact accepted Sprint9 source/evidence/delivery bindings and actual M1 API/control identity, followed by nonauthor GPT-6 and native Fable5.1 medium acceptance of the same frozen S10 plan before implementation. The accepted dependency is source eec499d, source/evidence ec9ed804 and archive/verified remote9908d9b, with full revisions in dependency-baseline.json. Stock GPT-6 implementation MUST then receive native Grok/Fable5.1-medium source/evidence review, requesting `claude-fable-5-1[1m]` with `--effort medium` and recording its actual returned model. No Foreman or independent approval, implementation or completed proof SHALL be inferred from author validation or a planning freeze.

#### Scenario: RE11 Accepted dependency binding
- **WHEN** accepted Sprint9 source/delivery/API evidence is missing or differs from the planning binding
- **THEN** the dependency check blocks the planning gate and implementation until reconciled; author validation is not independent approval

#### Scenario: RE12 Reviewer identity
- **WHEN** new planning or implementation reviews are executed
- **THEN** requested/reported models and exact reviewed bytes are recorded; unavailable/cancelled providers remain open reviews

#### Scenario: RE13 Material finding and delivery
- **WHEN** a native finding remains or a required evidence obligation is incomplete
- **THEN** targeted corrections continue without an inferred revision cap; archive/delivery waits for all obligations and verified authorized branch delivery

## END FILE

## FILE openspec/changes/operational-interface-binding-preservation/specs/interface-total-preservation/spec.md

Original SHA256: acd8f5bb6720cd7cad04dd2fb73335386d87a8349b5692450cfa95692e2526aa; bytes: 4457; rendered SHA256: acd8f5bb6720cd7cad04dd2fb73335386d87a8349b5692450cfa95692e2526aa

## Purpose

Establish initialized interface-total invariants from actual write confinement, shared-flow neutrality and explicit support for declared observations.

## ADDED Requirements

### Requirement: Conditional port-confined conservation

The system SHALL prove unchanged region sum from actual successful receipt writes confined to a declared shared set and zero summed effect over the region intersection with that set. Actual write locality MUST justify the complementary frame; catalog validity or whole-asset supply neutrality alone MUST NOT imply region neutrality.

#### Scenario: IT01 Nonvacuous shared cancellation
- **WHEN** Alice−2/Bob+2 are actual nonzero effects inside the region and shared set
- **THEN** the neutral intersection sum and actual confinement establish unchanged total10

#### Scenario: IT02 Supply neutrality is insufficient
- **WHEN** actual transfer2 leaves the singleton Alice region with whole-asset supply0
- **THEN** the region total drops by2 and the missing region-neutrality premise is explicit

#### Scenario: IT03 Complement framed
- **WHEN** an actual accepted receipt writes only inside Q
- **THEN** every region cell outside Q is unchanged by actual locality

### Requirement: Supported declared total

The system SHALL distinguish a fixed initialized ghost quantity from a state-dependent declared total. For the latter it MUST require value-valued support, actual writes excluding that support and neutral region flow, and MUST prove preservation of the initialized equality.

#### Scenario: IT04 Fixed declared quantity
- **WHEN** initial region sum is10 and each actual permitted step has neutral confined region flow
- **THEN** the fixed declared quantity10 remains equal to the region sum at every prefix

#### Scenario: IT05 Private total support
- **WHEN** a private home/USD total cell10 supports the declared quantity and actual transfer2 avoids it
- **THEN** both declared quantity and region sum remain10

#### Scenario: IT06 Missing initialization
- **WHEN** a constant declared quantity11 is compared to entry region sum10 under only neutral later actions
- **THEN** preservation does not establish equality at entry or later; initialization remains required

### Requirement: Actual writable-total counterexample

The system SHALL provide a separately valid catalog and an authorized successful transition that changes a writable declared-total observation while leaving the region sum unchanged. A denied access attempt MUST NOT stand in for this counterexample.

#### Scenario: IT07 Exposed total changes
- **WHEN** the separately exported writable total cell10 receives authorized +1 outside region Alice/Bob
- **THEN** execution succeeds, region stays10, declared total becomes11 and the equality is false

#### Scenario: IT08 Exact missing premise
- **WHEN** the same accepted write is within shared Q and has zero region flow
- **THEN** the violated support-exclusion premise is identified; the example does not refute the theorem with all premises

### Requirement: Initialized operational total lifting

The system SHALL lift local actual-step total obligations through every sequential prefix, accepted recursive sequential-group simulation and existing binary shared prefixes. Local obligations MUST quantify over arbitrary current execution inputs and permitted successful steps, without assuming the desired completed run. The arbitrary-entry group result MUST follow actual advance/continueRun induction or an entry-indexed suffix trace and then actual Metatheory.runGroup_eq_continueRun; it MUST NOT require a genesis trace for F16.

#### Scenario: IT09 Nonzero-index group
- **WHEN** a group starts at index2 with retained history and executes transfer2 followed by the specified snapshot-driven return2
- **THEN** the total stays10 through actual steps at indices2 and3, with nextIndex4 and retained old history

#### Scenario: IT10 Shared total invariant
- **WHEN** initialized Alice/Bob/Carol region total10 is preserved by each actually selected paired debit and peer refusal
- **THEN** every shared prefix retains total10, including F19 peer continuation after retained4/4/2 refusal and F20 failed-suffix skip before final3/3/4

#### Scenario: IT11 Absorbed failure
- **WHEN** a sequential cursor has already refused or a selected shared stream is failed or exhausted
- **THEN** the identity transition preserves the reached total without a fabricated successful receipt

## END FILE

## FILE openspec/changes/operational-interface-binding-preservation/specs/typed-region-accounting/spec.md

Original SHA256: 229a0e7a2a89e4b1a4d312f24c7eecc6d113cef87327e0532ef60ce61e2ceb80; bytes: 4688; rendered SHA256: 229a0e7a2a89e4b1a4d312f24c7eecc6d113cef87327e0532ef60ce61e2ceb80

## Purpose

Connect finite typed balance regions to the exact signed effects of actual accepted execution receipts, including boundary transfers and issuance.

## ADDED Requirements

### Requirement: Finite typed region observations

The system SHALL expose finite region sums with set membership, exact domain/asset well-formedness and zero for an empty region. Repeated region declarations MUST NOT duplicate balances; typed interface results MUST state region well-formedness.

#### Scenario: RA01 Empty region
- **WHEN** an empty region is observed in any state
- **THEN** the balance sum and receipt delta are both zero

#### Scenario: RA02 Duplicate declarations
- **WHEN** the same home/USD Alice cell is inserted twice into a region with Alice6 and Bob4
- **THEN** the region sum is10, not16, and membership remains set-valued

#### Scenario: RA03 Typed membership
- **WHEN** a region declared home/USD contains an away or EUR cell
- **THEN** the region well-formedness proposition is false; dimensioned preservation cannot omit that premise

### Requirement: Exact signed actual receipt accounting

For every actual successful invocation or administrative step, the system SHALL prove post-region sum equals pre-region sum plus the complete signed effect of that actual result receipt. The theorem MUST NOT assume this equation or accept a replacement receipt as its premise.

#### Scenario: RA04 Neutral nonzero transfer
- **WHEN** actual authorized transfer2 moves Alice6/Bob4 to4/6
- **THEN** the two-cell sum remains10 with effects −2,+2 and net region delta0

#### Scenario: RA05 Boundary-crossing transfer
- **WHEN** the same actual transfer is observed in singleton Alice region
- **THEN** the sum changes6 to4 and delta is−2 even though whole home/USD supply is0

#### Scenario: RA06 Nonzero issuance
- **WHEN** actual authorized mint3 credits Bob from4 to7 in the two-cell region
- **THEN** the sum changes10 to13 and receipt delta is+3; no neutral-flow conclusion is inferred

#### Scenario: RA07 Repeated targets
- **WHEN** the actual receipt contains Alice−1,Alice−2,Bob+3 in that order
- **THEN** the singleton Alice delta is−3, final Alice3/Bob7, and all original receipt entries are retained

### Requirement: Administrative balance identity

The system SHALL derive zero region effect for successful issue/revoke receipts and unchanged balances on actual administrative refusal, while retaining exact capability-store changes and refusal reasons.

#### Scenario: RA08 Issue and revoke
- **WHEN** an authenticated administrator issues a capability at fresh ID n then revokes n
- **THEN** all balances stay unchanged, both region deltas are0, and the store appends then tombstones that exact entry

#### Scenario: RA09 Refused administration
- **WHEN** a non-administrator attempts the same issue
- **THEN** the actual authority refusal retains the input world/store and produces no successful receipt

### Requirement: Actual successful prefix accounting

The system SHALL prove telescoping region accounting over actual successful sequential events and global shared-run attempts at every prefix. Refused, skipped and unreachable suffix actions MUST NOT contribute a receipt. The sequential receipt fold MUST begin at the complete supplied entry cursor and include only newly appended successful events, proved by actual continuation/suffix induction; it MUST NOT infer genesis TraceSound for arbitrary nonzero-index/history entries.

#### Scenario: RA10 Successful prefix followed by refusal
- **WHEN** paired debit succeeds from5/5/0 then transfer7 refuses and mint3 is a stopped suffix
- **THEN** the reached ledger is4/4/2, exactly one successful receipt is summed, and failure occurs at absolute index1

#### Scenario: RA11 Shared global receipt fold
- **WHEN** complete schedule left,right,left executes two paired debits then a left insufficient-funds refusal in region Alice/Bob/Carol
- **THEN** the reached ledger is3/3/4 and exactly the two actual global successful receipts contribute

#### Scenario: RA12 Peer continues after refusal
- **WHEN** the same F17 branches run under left,left,right from5/5/0
- **THEN** the first paired debit reaches4/4/2, left refusal at local index1 retains4/4/2, then the peer reaches3/3/4 with two actual successful receipts, exact retained left failure and unchanged full store

#### Scenario: RA13 Failed suffix skip before peer
- **WHEN** left=[op102,op106,op101] and right=[op102] run under left,left,left,right
- **THEN** the failed left mint suffix adds no attempt, receipt or supply; left consumed becomes3 with nextIndex1, and the right peer still reaches3/3/4 with the exact earlier failure retained

## END FILE

## FILE openspec/changes/operational-interface-binding-preservation/tasks.md

Original SHA256: 571a0832a85f7d0060a0863adf3a149506f95ce137db040fde9dc37bd9be0069; bytes: 10914; rendered SHA256: 571a0832a85f7d0060a0863adf3a149506f95ce137db040fde9dc37bd9be0069

## 1. Dependency, independent planning and baseline

- [ ] 1.1 Verify the bound accepted Sprint9 source eec499d, source/evidence ec9ed804 and archive/remote9908d9b against exact actual M1 APIs, recursive-group simulation and inherited controls; reconcile dependency-baseline.json before planning freeze and preserve historical input bytes.
- [ ] 1.2 Freeze the refreshed proposal/design/four specs/tasks/scenario and mutation map with strict OpenSpec validation, obtain nonauthor GPT-6 and native Fable5.1 medium planning verdicts on those exact bytes, request `claude-fable-5-1[1m]` with `--effort medium` and record the returned model, and resolve material findings before source work; verify saved native records and adjudication without treating author coverage as review.
- [ ] 1.3 Capture the accepted-source baseline with exact tool/executable/source identities and preserved old corpus/proof manifest before adding Interface code; verify all16 predecessor Lean checks,14 Metatheory detections,65 controls and13 legacy suites by actual records and relevant-source equivalence, rerun any affected check after input changes, and never relabel a carried run.

## 2. Computational regions, actual accounting and binding query

- [ ] 2.1 Add `lean/DefiKernel/Interface/Regions.lean` finite typed regions, set-valued balance sums and well-formedness; first record the honest missing-feature check, then verify empty, duplicate and mixed-dimension cases RA01–RA03 with LSP and a pinned targeted build from `lean/`.
- [ ] 2.2 Add complete signed `receiptCellEffect` and `receiptDelta` before the proof marker and prove agreement with the accepted actual receipt-effect bridge; verify F01–F04 exact effects, repeated targets and nonzero supply without computing expected data from production queries.
- [ ] 2.3 Add `Accounting.lean` generic actual successful-step region accounting and issue/revoke balance corollaries; verify the theorem quantifies actual executeStep equality and F18 retains the exact appended/tombstoned store while all region effects are zero.
- [ ] 2.4 Prove actual successful-event receipt-fold telescoping by arbitrary-entry continuation/suffix induction and over actual shared global attempts; verify F15/F17/F19/F20 count only accepted prefix receipts, with refused/skipped/suffix cases explicitly absent from the fold.
- [ ] 2.5 Add `Bindings.lean` real qualified export resolution, exact failure types and ordered production query plus Boolean success projection; verify catalog-first, left/right, domain/asset/balance and original-index precedence using F08/F10–F13, with all runtime helpers before the proof marker.
- [ ] 2.6 Prove query acceptance iff catalog validity and global agreement, resolution uniqueness under valid catalogs, and exact first-failure characterization; verify F07–F14 cover unresolved self-edges, outputs excluded from resource lookup, colliding local port IDs and deterministic failure payloads.

## 3. Conditional interface-total preservation

- [ ] 3.1 Prove actual write confinement plus neutral shared-region flow preserves the region total using locality outside the shared set; verify F01's nonzero cancellation and F02's zero-supply boundary counterexample both compile and execute.
- [ ] 3.2 Define value-valued support and prove supported declared-total preservation with explicit write exclusion; derive the fixed ghost-quantity specialization, and verify F05 plus the missing-initialization IT06 companion without inventing a ledger supply field.
- [ ] 3.3 Construct the valid private-total and exposed-total fixture catalogs and prove/execute the actual authorized writable-total counterexample F06; verify total10→11, region10 unchanged and failure of support exclusion, with actual successful receipt and exact supply+1.
- [ ] 3.4 State initialized local total obligations over arbitrary current pre-world/history/index/boundary and permitted actual successful steps; verify Lean accepts the generic preservation proof without whole-run equality or future-peer assumptions and with explicit failure/skip cases.

## 4. Operational binding lifting and algebra

- [ ] 4.1 Add `Preservation.lean` actual sequential-prefix total and binding preservation from initialized local obligations; verify actual step induction, exact successful-prefix failure behavior and F07/F15 rather than merely final-state tests.
- [ ] 4.2 Prove existing binary shared-prefix total, binding and receipt-fold corollaries from actual Interleaving reachability; verify original F17 left/right/left and F19 left/left/right with explicit4/4/2 retained refusal then peer3/3/4; verify F20 failed-suffix skip, exact histories/indices/store, and separate failed/exhausted identity proof cases, without assuming disjointness or schedule independence.
- [ ] 4.3 Lift total and binding invariants through the accepted M1 actual recursive-group simulation; verify F16 starts at absolute index2, retains history, consumes the actual snapshot and reaches nextIndex4, using actual runGroup_eq_continueRun and entry-indexed suffix induction, without a genesis TraceSound premise; also verify the F07 two-op102 group companion5/5/0 →4/4/2 →3/3/4 against independent full cursors and successful A=B queries at both prefixes, retaining F16 as total/history evidence rather than initialized binding equality.
- [ ] 4.4 Prove initialized edge preservation from equal actual endpoint receipt effects and derive frame, self-edge, administrative and existing import/export identity corollaries; verify nonzero F07, breaking F08 and actual alias F14/F18.
- [ ] 4.5 Prove global append/conjunction, edge reversal, duplicate idempotence, permutation and associativity laws and transport initialized local obligations to prefixes; verify F09/F10 and explicitly distinguish successful-query equivalence from changed exact first-failure diagnostics.
- [ ] 4.6 Prove equal symmetric closure is sufficient for predicate equivalence and prove the valid typed transitive counterexample to necessity; verify F10 has three distinct named resources, unequal closures and equal predicates for every state, alongside an independently omitted edge that changes query acceptance.

## 5. Independent examples and runtime observations

- [ ] 5.1 Add `Examples.lean` and `Tests.lean` literal finite universes, catalog/store/operation definitions and full expected observations for F01–F04; verify all20 ledger cells, request and ordered receipt fields, exact capabilities and independent amounts, including empty/set-duplicate controls.
- [ ] 5.2 Add F05/F06 and initialization/support/neutrality negative companions; verify the successful private-total case, actually accepted exposed-total violation and zero-supply crossing separately from access refusals.
- [ ] 5.3 Add F07–F14 exact query, typed/global-binding and algebra examples; verify all endpoint/precedence payloads, the original F07 and its two-leaf group companion with both prefix queries, valid colliding local names, real canonical import alias and global edge counterexample without a three-participant execution claim.
- [ ] 5.4 Add F15–F20 actual refusal, nonzero-index group, binary shared and administrative scenarios; verify full worlds/stores, outputs, histories, absolute positions and successful receipt counts against literal expected observations.
- [ ] 5.5 Add nonempty `Audit.lean`, automatic `Verify.lean` and root `lean/DefiKernel.lean` integration; verify unique comparison names, complete dynamic test/proof manifests, honest counts and fresh `lake build DefiKernel.Interface.Verify DefiKernel` plus direct Audit/Verify runs from `lean/`.

## 6. Actual mutations and defensive controls

- [ ] 6.1 Add `scripts/run_interface_mutations.py` against actual new runtime roots using the accepted predecessor harness; verify exact source replacements for M01–M14, copied dependency closure/proof-tail policy, independent oracle names, both global positives, the separate per-mutant sibling matrix, 600-second explicit command timeout and control-source binding before running variants.
- [ ] 6.2 Add `scripts/test_interface_mutation_runner.py` and adapt every final accepted predecessor CLI control with exact old/new name and expected-exit mapping, retaining all65 accepted Metatheory cases and the frozen full adaptation map; verify actual real-CLI executions include proof-tail/parser and both production #eval/IO.userError forms and the1500-second outer bound with measured wall-time/blocked timeout records.
- [ ] 6.3 Execute all fourteen real production mutants at the frozen source candidate; verify each compiles, emits its explicit designated false comparison and protected true sibling, with nonempty complete counts and actual commands/stdout/stderr/exit/UTC metadata.
- [ ] 6.4 Independently verify mutation/control source and artifact manifests, before/after source bytes, tool/executable hashes and exact accepted/failed/blocked classification; verify compiler refusals receive no financial detection credit and nested Git metadata is archived without embedded repositories.

## 7. Full verification and independent results

- [ ] 7.1 Mechanically emit all actual imported Interface theorem and supplemental statements/axioms with source/module/Git identities, private-name mapping and explicit/generic/reference/counterexample/generated classification; verify discovery agrees with fresh Verify and no sorry/custom axiom/native_decide is accepted.
- [ ] 7.2 Run the complete accepted Lean and Python regression obligations after integration, including the new production mutations/controls; verify nonempty all-pass evidence with exact actual run revisions or explicit relevant dependency equivalence for any carried old evidence.
- [ ] 7.3 Complete source-to-requirement/scenario/task/proof/runtime/mutation coverage and final artifact integrity checks; verify all protected historical source/corpus bytes and allowed root/import changes, with no provisional proof claims or unchecked implementation gaps.
- [ ] 7.4 Obtain native Grok and Fable5.1 medium substantive source/evidence reviews on exact final candidate bytes, record requested/reported model identities and raw outputs, fix material findings and rerun affected checks until resolved; verify cancelled/unavailable reviews stay open and no inferred revision budget terminates the authorized goal.

## 8. Archive and delivery

- [ ] 8.1 Adjudicate independent verdicts and finalize limitations for conditional totals, global constraints and still-open M3–M6 work; verify every implementation/evidence task is complete before marking any normative requirement delivered.
- [ ] 8.2 Archive the accepted OpenSpec change and verify authorized branch source/evidence delivery and remote readback; verify no historical theorem changes or merge to main and update the Sprint10 wiki/progress with exact accepted identities only after completion.

## END FILE

## FILE review/semantic-kernel/sprint10/planning/official-preparation/READINESS.md

Original SHA256: 4d4c797150c9a4af0e9e0d23d1441e8828559383bac892546c0dba93a6618a3f; bytes: 3235; rendered SHA256: 4d4c797150c9a4af0e9e0d23d1441e8828559383bac892546c0dba93a6618a3f

# Sprint10 planning input readiness

The accepted Sprint9 dependency is bound: source eec499d613688137a341f3556cd80ca461dd2ee9,
source/evidence ec9ed80457d7a9c4064d26ab193591579027abae, archive/verified remote
9908d9b56be2d5ed2b58a16fa8d28b23f33733ff. Later checkpoint c168329 records delivery
metadata; it does not replace those identities. The exact root-owned remote
readback is retained separately. No pending Sprint9 acceptance claim remains in
these current S10 planning inputs.

The plan/wiki now agree on4 capabilities,17 requirements,57 scenarios,34 unchecked
tasks,20 fixture contracts,14 planned source mutations and65 inherited controls.
F07 includes the initialized two-op102 recursive-group companion with independent
5/5/0 →4/4/2 →3/3/4 cursors and prefix queries; F16 remains arbitrary-entry total/
history evidence, not initialized A=B. F19/F20 peer continuation and failed-suffix
skip remain explicit. All expected cases remain planned, not executed M2 results.

Fresh strict OpenSpec and author validation pass. The dependency checker passes
359 checks:116 integrated source files equal the accepted source, archive and
current checkpoint;16 actual Lean commands,14 mutations and65 controls retain
eec execution identity. Thirteen historical suites retain c880 identity, with
independently checked declared source/tool closure equality and actual log hashes.
No suite is relabelled as freshly run. Scope and caveats survive in the complete
`dependency-baseline.json`; `dependency-review.json` omits mechanical check labels
and repeated invocation metadata while preserving commands/results/closures/tools
and hashes of all referenced originals. Historical test limitations remain.

The predecessor runner enforces two global positives. Its14 per-mutant siblings
were separately measured in execution-evidence reconciliation. The planned S10
contract requires each sibling to remain true and keeps those obligations distinct
from the schema-level global positives. The65-case adaptation lists are unexecuted
S10 contracts; their actual S9 predecessor executions are completed and bound.

`build-planning-bundle.py --plan` checks the input list and strict1.4MB size limit
without an official freeze. After root commits the inputs, run it with
`--candidate FULL_SHA --label r1`. The builder requires every input to equal that
commit, expands all repository-local imports of selected relevant source roots,
retains every source verbatim, compacts JSON with separate original/rendered hashes,
checks repeat rendering equality and source stability, and refuses to overwrite a
prior bundle. Large retained baseline logs and mechanical assertion labels remain
exactly reference-bound rather than duplicated in the planning prompt.

The next gate is nonauthor stock GPT-6 plus native Fable5.1 medium on that same
candidate/bundle. Request `claude-fable-5-1[1m]` with `--effort medium`, recording the
actual returned model. This author preparation performs no native review, M2
implementation, source mutation, commit or delivery. Root alone freezes/commits.
Earlier provisional reports/wiki bytes are retained under `before/` and their
separate prior refresh directories; those historical statuses are not current gates.

## END FILE

## FILE review/semantic-kernel/sprint10/planning/official-preparation/author-coverage.json

Original SHA256: d0130bf54ad91d0096aeee2da70ab964fdbb67c1a4a8fc1e08a7307ee86a28ed; bytes: 56265; rendered SHA256: 39c37843b10779e1a7c60173b09a6b61a631f714831adb2b25a1d8f90bdde800

{"bounded_constructibility_review":"provisional-constructibility-gpt6.md; not official acceptance","counts":{"capabilities":4,"checked_tasks":0,"planned_mutants":14,"requirements":17,"scenarios":57,"tasks":34},"dependency":"accepted_delivered_Sprint9_eec_source_ec9_evidence_9908_archive_remote","implementation_performed":false,"independent_planning_gate_performed":false,"input_manifest":[{"bytes":36125,"path":"openspec/changes/operational-interface-binding-preservation/design.md","sha256":"d51cec12dfc85bb99817659072cfc88cb32cd362491a3f397adcfcd6eb201495"},{"bytes":3138,"path":"openspec/changes/operational-interface-binding-preservation/proposal.md","sha256":"86511aac24c8a04ec5ffc1c78f7003ec48beed25ef6f47d5e87f22f5430730d8"},{"bytes":7289,"path":"openspec/changes/operational-interface-binding-preservation/specs/global-binding-preservation/spec.md","sha256":"b2c21cd551383b88cbd9ff807be8902ef7c71047d064bf015c6ac09fd0c36902"},{"bytes":5968,"path":"openspec/changes/operational-interface-binding-preservation/specs/interface-binding-regression-evidence/spec.md","sha256":"392a50b4cfd7e88763f1e57dc354afaec2b15a6a7abd09d035ff844d85462463"},{"bytes":4457,"path":"openspec/changes/operational-interface-binding-preservation/specs/interface-total-preservation/spec.md","sha256":"acd8f5bb6720cd7cad04dd2fb73335386d87a8349b5692450cfa95692e2526aa"},{"bytes":4688,"path":"openspec/changes/operational-interface-binding-preservation/specs/typed-region-accounting/spec.md","sha256":"229a0e7a2a89e4b1a4d312f24c7eecc6d113cef87327e0532ef60ce61e2ceb80"},{"bytes":10914,"path":"openspec/changes/operational-interface-binding-preservation/tasks.md","sha256":"571a0832a85f7d0060a0863adf3a149506f95ce137db040fde9dc37bd9be0069"},{"bytes":7629,"path":"wiki-llm/sprint-10-operational-interface-bindings-outline.md","sha256":"9cc671a2e54d57b7f295aad65d9028e22851bc655c7fb07082a8444376a073f9"},{"bytes":25722,"path":"review/semantic-kernel/sprint10/planning/official-preparation/build-author-evidence.py","sha256":"270860284df94760935dcb06f2d4f1f778899d6a38211a0e3d8ec5e5e0646188"}],"inspected_financial_source":"eec499d613688137a341f3556cd80ca461dd2ee9","observed_head":"c16832941c18229e51fade7c496b16146bb810bd","official_freeze":false,"requirements":[{"capability":"typed-region-accounting","evidence":["balanceSum_set","region_wellformed","F01","M01"],"normative_text":"The system SHALL expose finite region sums with set membership, exact domain/asset well-formedness and zero for an empty region. Repeated region declarations MUST NOT duplicate balances; typed interface results MUST state region well-formedness.","requirement":"Finite typed region observations","tasks":["2.1","5.1"]},{"capability":"typed-region-accounting","evidence":["actual_region_accounting","receiptCellEffect_eq","F01","F02","F03","F04","M02","M03","M04","M05"],"normative_text":"For every actual successful invocation or administrative step, the system SHALL prove post-region sum equals pre-region sum plus the complete signed effect of that actual result receipt. The theorem MUST NOT assume this equation or accept a replacement receipt as its premise.","requirement":"Exact signed actual receipt accounting","tasks":["2.2","2.3","5.1"]},{"capability":"typed-region-accounting","evidence":["administrative_region_identity","F18","M14"],"normative_text":"The system SHALL derive zero region effect for successful issue/revoke receipts and unchanged balances on actual administrative refusal, while retaining exact capability-store changes and refusal reasons.","requirement":"Administrative balance identity","tasks":["2.3","5.4"]},{"capability":"typed-region-accounting","evidence":["sequential_receipt_fold","shared_receipt_fold","F15","F17","F19","F20"],"normative_text":"The system SHALL prove telescoping region accounting over actual successful sequential events and global shared-run attempts at every prefix. Refused, skipped and unreachable suffix actions MUST NOT contribute a receipt. The sequential receipt fold MUST begin at the complete supplied entry cursor and include only newly appended successful events, proved by actual continuation/suffix induction; it MUST NOT infer genesis TraceSound for arbitrary nonzero-index/history entries.","requirement":"Actual successful prefix accounting","tasks":["2.4","4.1","4.2","5.4"]},{"capability":"interface-total-preservation","evidence":["confined_neutral_preserves","F01","F02"],"normative_text":"The system SHALL prove unchanged region sum from actual successful receipt writes confined to a declared shared set and zero summed effect over the region intersection with that set. Actual write locality MUST justify the complementary frame; catalog validity or whole-asset supply neutrality alone MUST NOT imply region neutrality.","requirement":"Conditional port-confined conservation","tasks":["3.1","5.2"]},{"capability":"interface-total-preservation","evidence":["ValueSupports","supported_total_preserves","ghost_total_preserves","F05"],"normative_text":"The system SHALL distinguish a fixed initialized ghost quantity from a state-dependent declared total. For the latter it MUST require value-valued support, actual writes excluding that support and neutral region flow, and MUST prove preservation of the initialized equality.","requirement":"Supported declared total","tasks":["3.2","3.3","5.2"]},{"capability":"interface-total-preservation","evidence":["writable_total_counterexample","F06"],"normative_text":"The system SHALL provide a separately valid catalog and an authorized successful transition that changes a writable declared-total observation while leaving the region sum unchanged. A denied access attempt MUST NOT stand in for this counterexample.","requirement":"Actual writable-total counterexample","tasks":["3.3","5.2"]},{"capability":"interface-total-preservation","evidence":["total_prefix_preservation","total_group_preservation","total_shared_preservation","F16","F17","F19","F20"],"normative_text":"The system SHALL lift local actual-step total obligations through every sequential prefix, accepted recursive sequential-group simulation and existing binary shared prefixes. Local obligations MUST quantify over arbitrary current execution inputs and permitted successful steps, without assuming the desired completed run. The arbitrary-entry group result MUST follow actual advance/continueRun induction or an entry-indexed suffix trace and then actual Metatheory.runGroup_eq_continueRun; it MUST NOT require a genesis trace for F16.","requirement":"Initialized operational total lifting","tasks":["3.4","4.1","4.2","4.3","5.4"]},{"capability":"global-binding-preservation","evidence":["checkBindings_ok_iff","binding_failure_first","F08","F10","F11","F12","F13","M06","M07","M08","M09","M10","M11","M12","M13"],"normative_text":"The system SHALL resolve endpoints through their exact component and resource-export IDs, validate the actual catalog first, and then process input edges in original order. Per edge it MUST check left resolution, right resolution, domain, asset and balance in that order, returning the exact first failure with zero-based index and relevant names, cells or amounts. A Boolean success projection MUST agree with the exact query.","requirement":"Exact typed global binding query","tasks":["2.5","2.6","5.3"]},{"capability":"global-binding-preservation","evidence":["Agrees","query_agreement","import_export_identity","F07","F08","F13","F14"],"normative_text":"The system SHALL define agreement as successful typed resolution plus equality for every global edge and prove query acceptance equivalent to catalog validity and that proposition. Existing imports MUST retain exact export-cell identity; distinct exported cells MUST NOT be treated as aliases merely because balances match.","requirement":"Binding meaning and actual alias distinction","tasks":["2.6","4.4","5.3"]},{"capability":"global-binding-preservation","evidence":["paired_effect_preserves","binding_prefix_preservation","binding_group_preservation","binding_shared_preservation","F07","F15","F17","F18","F19","F20"],"normative_text":"The system SHALL derive edge preservation from initialized equality and equal actual receipt effects, then prove all global bindings at every sequential and binary shared prefix from initialization and locally quantified actual-step obligations. Refusal/skip identity and administrative balance identity MUST be included; group lifting MUST use accepted actual M1 simulation. Arbitrary-entry sequential/group preservation MUST retain supplied prefix data and use actual continuation/suffix induction plus Metatheory.runGroup_eq_continueRun, without inventing a TraceSound genesis witness.","requirement":"Initialized actual binding preservation","tasks":["4.1","4.2","4.3","4.4","5.3","5.4"]},{"capability":"global-binding-preservation","evidence":["agrees_append","agrees_reverse","agrees_idempotent","agrees_assoc","agrees_permutation","binding_law_prefix","F09","F10"],"normative_text":"The system SHALL prove agreement over list concatenation is conjunction, and prove edge-reorientation, duplicate idempotence, permutation and associativity laws at proposition/query-success level. It MUST transfer initialization and step obligations to prefix invariants while preserving the complete global edge set. It MUST NOT claim identical first-error diagnostics after reordering or participant regrouping from these algebraic laws.","requirement":"Global constraint algebra and scope","tasks":["4.5","5.3"]},{"capability":"global-binding-preservation","evidence":["same_symClosure_sufficient","symClosure_not_necessary","F10"],"normative_text":"The system SHALL prove equal symmetric closures imply equivalent global agreement predicates, and provide a typed valid-catalog counterexample to necessity using transitive equality. It MUST NOT advertise symmetric-closure equality as a complete semantic equivalence checker.","requirement":"Symmetric closure is sufficient only","tasks":["4.6","5.3"]},{"capability":"interface-binding-regression-evidence","evidence":["F01-F20","fixture-manifest","runtime-manifest"],"normative_text":"The implementation SHALL exercise all F01–F20 design fixtures with independent complete expected ledgers, stores, receipts, histories, positions, query payloads and failures relevant to each case. Nonzero neutral flows and actual successful invariant violations MUST be distinguished from refused calls and compiler controls.","requirement":"Independent funded observations and negative companions","tasks":["5.1","5.2","5.3","5.4","5.5"]},{"capability":"interface-binding-regression-evidence","evidence":["M01-M14","inherited-controls","mutation-report","runner-controls"],"normative_text":"The implementation SHALL execute all fourteen M01–M14 design mutations against copied actual new runtime source. Each accepted detection MUST compile, flip its designated comparison and preserve its specified positive sibling. It MUST execute every inherited accepted predecessor control, including all65 accepted predecessor cases, with the exact complete Metatheory-to-Interface name/source/fixture/expected-exit map and proof/production regex-string bindings. The global positive_checks schema MUST stay distinct from the source-bound per-mutant sibling matrix. Command/outer timeouts MUST remain600/1500 seconds with actual measured wall time and blocked timeout classification; accepted S9 result bindings MUST be verified at official freeze and rechecked after relevant changes.","requirement":"Actual mutation and defensive control evidence","tasks":["6.1","6.2","6.3","6.4"]},{"capability":"interface-binding-regression-evidence","evidence":["proof-inventory","baseline","integration","legacy-regressions"],"normative_text":"The implementation SHALL capture all imported Interface theorem/supplemental declarations, full elaborated statements, private mappings, source/module identities and actual axiom dependencies. It MUST separate explicit generic results, reference instances, counterexamples and generated constants, and prohibit sorry, custom axioms and native_decide. All accepted prior regression obligations MUST remain discharged with honest run identity.","requirement":"Complete proof and regression evidence","tasks":["1.3","5.5","7.1","7.2","7.3"]},{"capability":"interface-binding-regression-evidence","evidence":["dependency-gate","planning-audits","native-results","delivery"],"normative_text":"The change SHALL require exact accepted Sprint9 source/evidence/delivery bindings and actual M1 API/control identity, followed by nonauthor GPT-6 and native Fable5.1 medium acceptance of the same frozen S10 plan before implementation. The accepted dependency is source eec499d, source/evidence ec9ed804 and archive/verified remote9908d9b, with full revisions in dependency-baseline.json. Stock GPT-6 implementation MUST then receive native Grok/Fable5.1-medium source/evidence review, requesting `claude-fable-5-1[1m]` with `--effort medium` and recording its actual returned model. No Foreman or independent approval, implementation or completed proof SHALL be inferred from author validation or a planning freeze.","requirement":"Dependency and independent acceptance gates","tasks":["1.1","1.2","7.4","8.1","8.2"]}],"scenarios":[{"capability":"typed-region-accounting","planned_evidence":["balanceSum_set","region_wellformed","F01","M01"],"requirement":"Finite typed region observations","scenario":"RA01 Empty region","status":"planned_unimplemented","tasks":["2.1","5.1"]},{"capability":"typed-region-accounting","planned_evidence":["balanceSum_set","region_wellformed","F01","M01"],"requirement":"Finite typed region observations","scenario":"RA02 Duplicate declarations","status":"planned_unimplemented","tasks":["2.1","5.1"]},{"capability":"typed-region-accounting","planned_evidence":["balanceSum_set","region_wellformed","F01","M01"],"requirement":"Finite typed region observations","scenario":"RA03 Typed membership","status":"planned_unimplemented","tasks":["2.1","5.1"]},{"capability":"typed-region-accounting","planned_evidence":["actual_region_accounting","receiptCellEffect_eq","F01","F02","F03","F04","M02","M03","M04","M05"],"requirement":"Exact signed actual receipt accounting","scenario":"RA04 Neutral nonzero transfer","status":"planned_unimplemented","tasks":["2.2","2.3","5.1"]},{"capability":"typed-region-accounting","planned_evidence":["actual_region_accounting","receiptCellEffect_eq","F01","F02","F03","F04","M02","M03","M04","M05"],"requirement":"Exact signed actual receipt accounting","scenario":"RA05 Boundary-crossing transfer","status":"planned_unimplemented","tasks":["2.2","2.3","5.1"]},{"capability":"typed-region-accounting","planned_evidence":["actual_region_accounting","receiptCellEffect_eq","F01","F02","F03","F04","M02","M03","M04","M05"],"requirement":"Exact signed actual receipt accounting","scenario":"RA06 Nonzero issuance","status":"planned_unimplemented","tasks":["2.2","2.3","5.1"]},{"capability":"typed-region-accounting","planned_evidence":["actual_region_accounting","receiptCellEffect_eq","F01","F02","F03","F04","M02","M03","M04","M05"],"requirement":"Exact signed actual receipt accounting","scenario":"RA07 Repeated targets","status":"planned_unimplemented","tasks":["2.2","2.3","5.1"]},{"capability":"typed-region-accounting","planned_evidence":["administrative_region_identity","F18","M14"],"requirement":"Administrative balance identity","scenario":"RA08 Issue and revoke","status":"planned_unimplemented","tasks":["2.3","5.4"]},{"capability":"typed-region-accounting","planned_evidence":["administrative_region_identity","F18","M14"],"requirement":"Administrative balance identity","scenario":"RA09 Refused administration","status":"planned_unimplemented","tasks":["2.3","5.4"]},{"capability":"typed-region-accounting","planned_evidence":["sequential_receipt_fold","shared_receipt_fold","F15","F17","F19","F20"],"requirement":"Actual successful prefix accounting","scenario":"RA10 Successful prefix followed by refusal","status":"planned_unimplemented","tasks":["2.4","4.1","4.2","5.4"]},{"capability":"typed-region-accounting","planned_evidence":["sequential_receipt_fold","shared_receipt_fold","F15","F17","F19","F20"],"requirement":"Actual successful prefix accounting","scenario":"RA11 Shared global receipt fold","status":"planned_unimplemented","tasks":["2.4","4.1","4.2","5.4"]},{"capability":"typed-region-accounting","planned_evidence":["sequential_receipt_fold","shared_receipt_fold","F15","F17","F19","F20"],"requirement":"Actual successful prefix accounting","scenario":"RA12 Peer continues after refusal","status":"planned_unimplemented","tasks":["2.4","4.1","4.2","5.4"]},{"capability":"typed-region-accounting","planned_evidence":["sequential_receipt_fold","shared_receipt_fold","F15","F17","F19","F20"],"requirement":"Actual successful prefix accounting","scenario":"RA13 Failed suffix skip before peer","status":"planned_unimplemented","tasks":["2.4","4.1","4.2","5.4"]},{"capability":"interface-total-preservation","planned_evidence":["confined_neutral_preserves","F01","F02"],"requirement":"Conditional port-confined conservation","scenario":"IT01 Nonvacuous shared cancellation","status":"planned_unimplemented","tasks":["3.1","5.2"]},{"capability":"interface-total-preservation","planned_evidence":["confined_neutral_preserves","F01","F02"],"requirement":"Conditional port-confined conservation","scenario":"IT02 Supply neutrality is insufficient","status":"planned_unimplemented","tasks":["3.1","5.2"]},{"capability":"interface-total-preservation","planned_evidence":["confined_neutral_preserves","F01","F02"],"requirement":"Conditional port-confined conservation","scenario":"IT03 Complement framed","status":"planned_unimplemented","tasks":["3.1","5.2"]},{"capability":"interface-total-preservation","planned_evidence":["ValueSupports","supported_total_preserves","ghost_total_preserves","F05"],"requirement":"Supported declared total","scenario":"IT04 Fixed declared quantity","status":"planned_unimplemented","tasks":["3.2","3.3","5.2"]},{"capability":"interface-total-preservation","planned_evidence":["ValueSupports","supported_total_preserves","ghost_total_preserves","F05"],"requirement":"Supported declared total","scenario":"IT05 Private total support","status":"planned_unimplemented","tasks":["3.2","3.3","5.2"]},{"capability":"interface-total-preservation","planned_evidence":["ValueSupports","supported_total_preserves","ghost_total_preserves","F05"],"requirement":"Supported declared total","scenario":"IT06 Missing initialization","status":"planned_unimplemented","tasks":["3.2","3.3","5.2"]},{"capability":"interface-total-preservation","planned_evidence":["writable_total_counterexample","F06"],"requirement":"Actual writable-total counterexample","scenario":"IT07 Exposed total changes","status":"planned_unimplemented","tasks":["3.3","5.2"]},{"capability":"interface-total-preservation","planned_evidence":["writable_total_counterexample","F06"],"requirement":"Actual writable-total counterexample","scenario":"IT08 Exact missing premise","status":"planned_unimplemented","tasks":["3.3","5.2"]},{"capability":"interface-total-preservation","planned_evidence":["total_prefix_preservation","total_group_preservation","total_shared_preservation","F16","F17","F19","F20"],"requirement":"Initialized operational total lifting","scenario":"IT09 Nonzero-index group","status":"planned_unimplemented","tasks":["3.4","4.1","4.2","4.3","5.4"]},{"capability":"interface-total-preservation","planned_evidence":["total_prefix_preservation","total_group_preservation","total_shared_preservation","F16","F17","F19","F20"],"requirement":"Initialized operational total lifting","scenario":"IT10 Shared total invariant","status":"planned_unimplemented","tasks":["3.4","4.1","4.2","4.3","5.4"]},{"capability":"interface-total-preservation","planned_evidence":["total_prefix_preservation","total_group_preservation","total_shared_preservation","F16","F17","F19","F20"],"requirement":"Initialized operational total lifting","scenario":"IT11 Absorbed failure","status":"planned_unimplemented","tasks":["3.4","4.1","4.2","4.3","5.4"]},{"capability":"global-binding-preservation","planned_evidence":["checkBindings_ok_iff","binding_failure_first","F08","F10","F11","F12","F13","M06","M07","M08","M09","M10","M11","M12","M13"],"requirement":"Exact typed global binding query","scenario":"GB01 Exact qualified identity","status":"planned_unimplemented","tasks":["2.5","2.6","5.3"]},{"capability":"global-binding-preservation","planned_evidence":["checkBindings_ok_iff","binding_failure_first","F08","F10","F11","F12","F13","M06","M07","M08","M09","M10","M11","M12","M13"],"requirement":"Exact typed global binding query","scenario":"GB02 Missing endpoint kind and side","status":"planned_unimplemented","tasks":["2.5","2.6","5.3"]},{"capability":"global-binding-preservation","planned_evidence":["checkBindings_ok_iff","binding_failure_first","F08","F10","F11","F12","F13","M06","M07","M08","M09","M10","M11","M12","M13"],"requirement":"Exact typed global binding query","scenario":"GB03 Dimensional mismatch","status":"planned_unimplemented","tasks":["2.5","2.6","5.3"]},{"capability":"global-binding-preservation","planned_evidence":["checkBindings_ok_iff","binding_failure_first","F08","F10","F11","F12","F13","M06","M07","M08","M09","M10","M11","M12","M13"],"requirement":"Exact typed global binding query","scenario":"GB04 Failure precedence","status":"planned_unimplemented","tasks":["2.5","2.6","5.3"]},{"capability":"global-binding-preservation","planned_evidence":["checkBindings_ok_iff","binding_failure_first","F08","F10","F11","F12","F13","M06","M07","M08","M09","M10","M11","M12","M13"],"requirement":"Exact typed global binding query","scenario":"GB05 Catalog precedes emptiness","status":"planned_unimplemented","tasks":["2.5","2.6","5.3"]},{"capability":"global-binding-preservation","planned_evidence":["checkBindings_ok_iff","binding_failure_first","F08","F10","F11","F12","F13","M06","M07","M08","M09","M10","M11","M12","M13"],"requirement":"Exact typed global binding query","scenario":"GB06 Outputs are not live resources","status":"planned_unimplemented","tasks":["2.5","2.6","5.3"]},{"capability":"global-binding-preservation","planned_evidence":["Agrees","query_agreement","import_export_identity","F07","F08","F13","F14"],"requirement":"Binding meaning and actual alias distinction","scenario":"GB07 Positive distinct-cell equality","status":"planned_unimplemented","tasks":["2.6","4.4","5.3"]},{"capability":"global-binding-preservation","planned_evidence":["Agrees","query_agreement","import_export_identity","F07","F08","F13","F14"],"requirement":"Binding meaning and actual alias distinction","scenario":"GB08 One-sided accepted write","status":"planned_unimplemented","tasks":["2.6","4.4","5.3"]},{"capability":"global-binding-preservation","planned_evidence":["Agrees","query_agreement","import_export_identity","F07","F08","F13","F14"],"requirement":"Binding meaning and actual alias distinction","scenario":"GB09 Existing resource alias","status":"planned_unimplemented","tasks":["2.6","4.4","5.3"]},{"capability":"global-binding-preservation","planned_evidence":["Agrees","query_agreement","import_export_identity","F07","F08","F13","F14"],"requirement":"Binding meaning and actual alias distinction","scenario":"GB10 Self binding","status":"planned_unimplemented","tasks":["2.6","4.4","5.3"]},{"capability":"global-binding-preservation","planned_evidence":["paired_effect_preserves","binding_prefix_preservation","binding_group_preservation","binding_shared_preservation","F07","F15","F17","F18","F19","F20"],"requirement":"Initialized actual binding preservation","scenario":"GB11 Nonzero paired effects","status":"planned_unimplemented","tasks":["4.1","4.2","4.3","4.4","5.3","5.4"]},{"capability":"global-binding-preservation","planned_evidence":["paired_effect_preserves","binding_prefix_preservation","binding_group_preservation","binding_shared_preservation","F07","F15","F17","F18","F19","F20"],"requirement":"Initialized actual binding preservation","scenario":"GB12 Sequential refusal retained","status":"planned_unimplemented","tasks":["4.1","4.2","4.3","4.4","5.3","5.4"]},{"capability":"global-binding-preservation","planned_evidence":["paired_effect_preserves","binding_prefix_preservation","binding_group_preservation","binding_shared_preservation","F07","F15","F17","F18","F19","F20"],"requirement":"Initialized actual binding preservation","scenario":"GB13 Shared peer progression","status":"planned_unimplemented","tasks":["4.1","4.2","4.3","4.4","5.3","5.4"]},{"capability":"global-binding-preservation","planned_evidence":["paired_effect_preserves","binding_prefix_preservation","binding_group_preservation","binding_shared_preservation","F07","F15","F17","F18","F19","F20"],"requirement":"Initialized actual binding preservation","scenario":"GB14 Administrative or skipped step","status":"planned_unimplemented","tasks":["4.1","4.2","4.3","4.4","5.3","5.4"]},{"capability":"global-binding-preservation","planned_evidence":["agrees_append","agrees_reverse","agrees_idempotent","agrees_assoc","agrees_permutation","binding_law_prefix","F09","F10"],"requirement":"Global constraint algebra and scope","scenario":"GB15 Union and orientation","status":"planned_unimplemented","tasks":["4.5","5.3"]},{"capability":"global-binding-preservation","planned_evidence":["agrees_append","agrees_reverse","agrees_idempotent","agrees_assoc","agrees_permutation","binding_law_prefix","F09","F10"],"requirement":"Global constraint algebra and scope","scenario":"GB16 Global skip edge","status":"planned_unimplemented","tasks":["4.5","5.3"]},{"capability":"global-binding-preservation","planned_evidence":["agrees_append","agrees_reverse","agrees_idempotent","agrees_assoc","agrees_permutation","binding_law_prefix","F09","F10"],"requirement":"Global constraint algebra and scope","scenario":"GB17 Diagnostic distinction","status":"planned_unimplemented","tasks":["4.5","5.3"]},{"capability":"global-binding-preservation","planned_evidence":["same_symClosure_sufficient","symClosure_not_necessary","F10"],"requirement":"Symmetric closure is sufficient only","scenario":"GB18 Sufficient closure criterion","status":"planned_unimplemented","tasks":["4.6","5.3"]},{"capability":"global-binding-preservation","planned_evidence":["same_symClosure_sufficient","symClosure_not_necessary","F10"],"requirement":"Symmetric closure is sufficient only","scenario":"GB19 Redundant transitive edge","status":"planned_unimplemented","tasks":["4.6","5.3"]},{"capability":"global-binding-preservation","planned_evidence":["same_symClosure_sufficient","symClosure_not_necessary","F10"],"requirement":"Symmetric closure is sufficient only","scenario":"GB20 Independent omitted edge","status":"planned_unimplemented","tasks":["4.6","5.3"]},{"capability":"interface-binding-regression-evidence","planned_evidence":["F01-F20","fixture-manifest","runtime-manifest"],"requirement":"Independent funded observations and negative companions","scenario":"RE01 Independent expected data","status":"planned_unimplemented","tasks":["5.1","5.2","5.3","5.4","5.5"]},{"capability":"interface-binding-regression-evidence","planned_evidence":["F01-F20","fixture-manifest","runtime-manifest"],"requirement":"Independent funded observations and negative companions","scenario":"RE02 Broken premise succeeds operationally","status":"planned_unimplemented","tasks":["5.1","5.2","5.3","5.4","5.5"]},{"capability":"interface-binding-regression-evidence","planned_evidence":["F01-F20","fixture-manifest","runtime-manifest"],"requirement":"Independent funded observations and negative companions","scenario":"RE03 Nonempty audit","status":"planned_unimplemented","tasks":["5.1","5.2","5.3","5.4","5.5"]},{"capability":"interface-binding-regression-evidence","planned_evidence":["M01-M14","inherited-controls","mutation-report","runner-controls"],"requirement":"Actual mutation and defensive control evidence","scenario":"RE04 Compiled discriminating mutation","status":"planned_unimplemented","tasks":["6.1","6.2","6.3","6.4"]},{"capability":"interface-binding-regression-evidence","planned_evidence":["M01-M14","inherited-controls","mutation-report","runner-controls"],"requirement":"Actual mutation and defensive control evidence","scenario":"RE05 Compiler failure gets no credit","status":"planned_unimplemented","tasks":["6.1","6.2","6.3","6.4"]},{"capability":"interface-binding-regression-evidence","planned_evidence":["M01-M14","inherited-controls","mutation-report","runner-controls"],"requirement":"Actual mutation and defensive control evidence","scenario":"RE06 Production and proof-tail controls","status":"planned_unimplemented","tasks":["6.1","6.2","6.3","6.4"]},{"capability":"interface-binding-regression-evidence","planned_evidence":["M01-M14","inherited-controls","mutation-report","runner-controls"],"requirement":"Actual mutation and defensive control evidence","scenario":"RE07 Drift or missing inputs","status":"planned_unimplemented","tasks":["6.1","6.2","6.3","6.4"]},{"capability":"interface-binding-regression-evidence","planned_evidence":["proof-inventory","baseline","integration","legacy-regressions"],"requirement":"Complete proof and regression evidence","scenario":"RE08 Imported proof discovery","status":"planned_unimplemented","tasks":["1.3","5.5","7.1","7.2","7.3"]},{"capability":"interface-binding-regression-evidence","planned_evidence":["proof-inventory","baseline","integration","legacy-regressions"],"requirement":"Complete proof and regression evidence","scenario":"RE09 Exact regression identity","status":"planned_unimplemented","tasks":["1.3","5.5","7.1","7.2","7.3"]},{"capability":"interface-binding-regression-evidence","planned_evidence":["proof-inventory","baseline","integration","legacy-regressions"],"requirement":"Complete proof and regression evidence","scenario":"RE10 Protected source preservation","status":"planned_unimplemented","tasks":["1.3","5.5","7.1","7.2","7.3"]},{"capability":"interface-binding-regression-evidence","planned_evidence":["dependency-gate","planning-audits","native-results","delivery"],"requirement":"Dependency and independent acceptance gates","scenario":"RE11 Accepted dependency binding","status":"planned_unimplemented","tasks":["1.1","1.2","7.4","8.1","8.2"]},{"capability":"interface-binding-regression-evidence","planned_evidence":["dependency-gate","planning-audits","native-results","delivery"],"requirement":"Dependency and independent acceptance gates","scenario":"RE12 Reviewer identity","status":"planned_unimplemented","tasks":["1.1","1.2","7.4","8.1","8.2"]},{"capability":"interface-binding-regression-evidence","planned_evidence":["dependency-gate","planning-audits","native-results","delivery"],"requirement":"Dependency and independent acceptance gates","scenario":"RE13 Material finding and delivery","status":"planned_unimplemented","tasks":["1.1","1.2","7.4","8.1","8.2"]}],"status":"planning_author_consistency_only","tasks":[{"description":"Verify the bound accepted Sprint9 source eec499d, source/evidence ec9ed804 and archive/remote9908d9b against exact actual M1 APIs, recursive-group simulation and inherited controls; reconcile dependency-baseline.json before planning freeze and preserve historical input bytes.","id":"1.1","status":"unchecked"},{"description":"Freeze the refreshed proposal/design/four specs/tasks/scenario and mutation map with strict OpenSpec validation, obtain nonauthor GPT-6 and native Fable5.1 medium planning verdicts on those exact bytes, request `claude-fable-5-1[1m]` with `--effort medium` and record the returned model, and resolve material findings before source work; verify saved native records and adjudication without treating author coverage as review.","id":"1.2","status":"unchecked"},{"description":"Capture the accepted-source baseline with exact tool/executable/source identities and preserved old corpus/proof manifest before adding Interface code; verify all16 predecessor Lean checks,14 Metatheory detections,65 controls and13 legacy suites by actual records and relevant-source equivalence, rerun any affected check after input changes, and never relabel a carried run.","id":"1.3","status":"unchecked"},{"description":"Add `lean/DefiKernel/Interface/Regions.lean` finite typed regions, set-valued balance sums and well-formedness; first record the honest missing-feature check, then verify empty, duplicate and mixed-dimension cases RA01–RA03 with LSP and a pinned targeted build from `lean/`.","id":"2.1","status":"unchecked"},{"description":"Add complete signed `receiptCellEffect` and `receiptDelta` before the proof marker and prove agreement with the accepted actual receipt-effect bridge; verify F01–F04 exact effects, repeated targets and nonzero supply without computing expected data from production queries.","id":"2.2","status":"unchecked"},{"description":"Add `Accounting.lean` generic actual successful-step region accounting and issue/revoke balance corollaries; verify the theorem quantifies actual executeStep equality and F18 retains the exact appended/tombstoned store while all region effects are zero.","id":"2.3","status":"unchecked"},{"description":"Prove actual successful-event receipt-fold telescoping by arbitrary-entry continuation/suffix induction and over actual shared global attempts; verify F15/F17/F19/F20 count only accepted prefix receipts, with refused/skipped/suffix cases explicitly absent from the fold.","id":"2.4","status":"unchecked"},{"description":"Add `Bindings.lean` real qualified export resolution, exact failure types and ordered production query plus Boolean success projection; verify catalog-first, left/right, domain/asset/balance and original-index precedence using F08/F10–F13, with all runtime helpers before the proof marker.","id":"2.5","status":"unchecked"},{"description":"Prove query acceptance iff catalog validity and global agreement, resolution uniqueness under valid catalogs, and exact first-failure characterization; verify F07–F14 cover unresolved self-edges, outputs excluded from resource lookup, colliding local port IDs and deterministic failure payloads.","id":"2.6","status":"unchecked"},{"description":"Prove actual write confinement plus neutral shared-region flow preserves the region total using locality outside the shared set; verify F01's nonzero cancellation and F02's zero-supply boundary counterexample both compile and execute.","id":"3.1","status":"unchecked"},{"description":"Define value-valued support and prove supported declared-total preservation with explicit write exclusion; derive the fixed ghost-quantity specialization, and verify F05 plus the missing-initialization IT06 companion without inventing a ledger supply field.","id":"3.2","status":"unchecked"},{"description":"Construct the valid private-total and exposed-total fixture catalogs and prove/execute the actual authorized writable-total counterexample F06; verify total10→11, region10 unchanged and failure of support exclusion, with actual successful receipt and exact supply+1.","id":"3.3","status":"unchecked"},{"description":"State initialized local total obligations over arbitrary current pre-world/history/index/boundary and permitted actual successful steps; verify Lean accepts the generic preservation proof without whole-run equality or future-peer assumptions and with explicit failure/skip cases.","id":"3.4","status":"unchecked"},{"description":"Add `Preservation.lean` actual sequential-prefix total and binding preservation from initialized local obligations; verify actual step induction, exact successful-prefix failure behavior and F07/F15 rather than merely final-state tests.","id":"4.1","status":"unchecked"},{"description":"Prove existing binary shared-prefix total, binding and receipt-fold corollaries from actual Interleaving reachability; verify original F17 left/right/left and F19 left/left/right with explicit4/4/2 retained refusal then peer3/3/4; verify F20 failed-suffix skip, exact histories/indices/store, and separate failed/exhausted identity proof cases, without assuming disjointness or schedule independence.","id":"4.2","status":"unchecked"},{"description":"Lift total and binding invariants through the accepted M1 actual recursive-group simulation; verify F16 starts at absolute index2, retains history, consumes the actual snapshot and reaches nextIndex4, using actual runGroup_eq_continueRun and entry-indexed suffix induction, without a genesis TraceSound premise; also verify the F07 two-op102 group companion5/5/0 →4/4/2 →3/3/4 against independent full cursors and successful A=B queries at both prefixes, retaining F16 as total/history evidence rather than initialized binding equality.","id":"4.3","status":"unchecked"},{"description":"Prove initialized edge preservation from equal actual endpoint receipt effects and derive frame, self-edge, administrative and existing import/export identity corollaries; verify nonzero F07, breaking F08 and actual alias F14/F18.","id":"4.4","status":"unchecked"},{"description":"Prove global append/conjunction, edge reversal, duplicate idempotence, permutation and associativity laws and transport initialized local obligations to prefixes; verify F09/F10 and explicitly distinguish successful-query equivalence from changed exact first-failure diagnostics.","id":"4.5","status":"unchecked"},{"description":"Prove equal symmetric closure is sufficient for predicate equivalence and prove the valid typed transitive counterexample to necessity; verify F10 has three distinct named resources, unequal closures and equal predicates for every state, alongside an independently omitted edge that changes query acceptance.","id":"4.6","status":"unchecked"},{"description":"Add `Examples.lean` and `Tests.lean` literal finite universes, catalog/store/operation definitions and full expected observations for F01–F04; verify all20 ledger cells, request and ordered receipt fields, exact capabilities and independent amounts, including empty/set-duplicate controls.","id":"5.1","status":"unchecked"},{"description":"Add F05/F06 and initialization/support/neutrality negative companions; verify the successful private-total case, actually accepted exposed-total violation and zero-supply crossing separately from access refusals.","id":"5.2","status":"unchecked"},{"description":"Add F07–F14 exact query, typed/global-binding and algebra examples; verify all endpoint/precedence payloads, the original F07 and its two-leaf group companion with both prefix queries, valid colliding local names, real canonical import alias and global edge counterexample without a three-participant execution claim.","id":"5.3","status":"unchecked"},{"description":"Add F15–F20 actual refusal, nonzero-index group, binary shared and administrative scenarios; verify full worlds/stores, outputs, histories, absolute positions and successful receipt counts against literal expected observations.","id":"5.4","status":"unchecked"},{"description":"Add nonempty `Audit.lean`, automatic `Verify.lean` and root `lean/DefiKernel.lean` integration; verify unique comparison names, complete dynamic test/proof manifests, honest counts and fresh `lake build DefiKernel.Interface.Verify DefiKernel` plus direct Audit/Verify runs from `lean/`.","id":"5.5","status":"unchecked"},{"description":"Add `scripts/run_interface_mutations.py` against actual new runtime roots using the accepted predecessor harness; verify exact source replacements for M01–M14, copied dependency closure/proof-tail policy, independent oracle names, both global positives, the separate per-mutant sibling matrix, 600-second explicit command timeout and control-source binding before running variants.","id":"6.1","status":"unchecked"},{"description":"Add `scripts/test_interface_mutation_runner.py` and adapt every final accepted predecessor CLI control with exact old/new name and expected-exit mapping, retaining all65 accepted Metatheory cases and the frozen full adaptation map; verify actual real-CLI executions include proof-tail/parser and both production #eval/IO.userError forms and the1500-second outer bound with measured wall-time/blocked timeout records.","id":"6.2","status":"unchecked"},{"description":"Execute all fourteen real production mutants at the frozen source candidate; verify each compiles, emits its explicit designated false comparison and protected true sibling, with nonempty complete counts and actual commands/stdout/stderr/exit/UTC metadata.","id":"6.3","status":"unchecked"},{"description":"Independently verify mutation/control source and artifact manifests, before/after source bytes, tool/executable hashes and exact accepted/failed/blocked classification; verify compiler refusals receive no financial detection credit and nested Git metadata is archived without embedded repositories.","id":"6.4","status":"unchecked"},{"description":"Mechanically emit all actual imported Interface theorem and supplemental statements/axioms with source/module/Git identities, private-name mapping and explicit/generic/reference/counterexample/generated classification; verify discovery agrees with fresh Verify and no sorry/custom axiom/native_decide is accepted.","id":"7.1","status":"unchecked"},{"description":"Run the complete accepted Lean and Python regression obligations after integration, including the new production mutations/controls; verify nonempty all-pass evidence with exact actual run revisions or explicit relevant dependency equivalence for any carried old evidence.","id":"7.2","status":"unchecked"},{"description":"Complete source-to-requirement/scenario/task/proof/runtime/mutation coverage and final artifact integrity checks; verify all protected historical source/corpus bytes and allowed root/import changes, with no provisional proof claims or unchecked implementation gaps.","id":"7.3","status":"unchecked"},{"description":"Obtain native Grok and Fable5.1 medium substantive source/evidence reviews on exact final candidate bytes, record requested/reported model identities and raw outputs, fix material findings and rerun affected checks until resolved; verify cancelled/unavailable reviews stay open and no inferred revision budget terminates the authorized goal.","id":"7.4","status":"unchecked"},{"description":"Adjudicate independent verdicts and finalize limitations for conditional totals, global constraints and still-open M3–M6 work; verify every implementation/evidence task is complete before marking any normative requirement delivered.","id":"8.1","status":"unchecked"},{"description":"Archive the accepted OpenSpec change and verify authorized branch source/evidence delivery and remote readback; verify no historical theorem changes or merge to main and update the Sprint10 wiki/progress with exact accepted identities only after completion.","id":"8.2","status":"unchecked"}],"utc":"2026-09-07T19:22:54.135136+00:00"}

## END FILE

## FILE review/semantic-kernel/sprint10/planning/official-preparation/author-validation.json

Original SHA256: fe454980f0b07eded8e111ec670783525ce10c275cc563e86348710da6a5f6a4; bytes: 8829; rendered SHA256: 6f6d9ff42984f93c430781b8f2791ce0bb0735bb8006dc5367e439f64a66c4df

{"author_only":true,"checks":{"Interface_source_absent":true,"accepted_Sprint9_dependency_bound_recheck_required":true,"actual_control_catalog65_inspected_not_run":true,"all_requirements_and_scenarios_mapped":true,"all_tasks_covered":true,"all_tasks_unchecked":true,"arithmetic_consistency_only":true,"concrete_mutation_pairs14":true,"fixture_contracts20":true,"no_implementation_performed":true,"no_native_review_performed":true,"official_freeze_not_performed":true,"plan_inputs_unchanged_during_validation":true,"real_root_target":true,"selected_sources_match_inspected_git_before_after":true,"strict_openspec_passed":true},"commands":[{"argv":["/usr/bin/python3","/home/charl/defiformal/review/semantic-kernel/sprint10/planning/official-preparation/build-author-evidence.py"],"cwd":"/home/charl/defiformal","exit":0,"finished_utc":"2026-09-07T19:22:54.142193+00:00","started_utc":"2026-09-07T19:22:54.113098+00:00","stderr":{"bytes":0,"path":"review/semantic-kernel/sprint10/planning/official-preparation/coverage.stderr","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":113,"path":"review/semantic-kernel/sprint10/planning/official-preparation/coverage.stdout","sha256":"3c2b6f26f5c359024a9e645d7674b6cd7723538376cb2a8ab4ec5424cb3279af"}},{"argv":["/home/charl/.local/lib/node_modules/@fission-ai/openspec/bin/openspec.js","--version"],"cwd":"/home/charl/defiformal","exit":0,"finished_utc":"2026-09-07T19:22:54.349166+00:00","started_utc":"2026-09-07T19:22:54.142429+00:00","stderr":{"bytes":0,"path":"review/semantic-kernel/sprint10/planning/official-preparation/openspec-version.stderr","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":7,"path":"review/semantic-kernel/sprint10/planning/official-preparation/openspec-version.stdout","sha256":"4f5ba6a3e380bf810cc968b58d30a8d7163eafe9e2fb1ad19bdc6d9d64a1e549"}},{"argv":["/home/charl/.local/lib/node_modules/@fission-ai/openspec/bin/openspec.js","validate","operational-interface-binding-preservation","--strict"],"cwd":"/home/charl/defiformal","exit":0,"finished_utc":"2026-09-07T19:22:55.044557+00:00","started_utc":"2026-09-07T19:22:54.349290+00:00","stderr":{"bytes":0,"path":"review/semantic-kernel/sprint10/planning/official-preparation/strict-validation.stderr","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":61,"path":"review/semantic-kernel/sprint10/planning/official-preparation/strict-validation.stdout","sha256":"8a71cb05d4f26b39137f15e10d45d755cf4179c1682cdd33d1633339850a9681"}},{"argv":["/home/charl/.local/lib/node_modules/@fission-ai/openspec/bin/openspec.js","status","--change","operational-interface-binding-preservation","--json"],"cwd":"/home/charl/defiformal","exit":0,"finished_utc":"2026-09-07T19:22:55.735893+00:00","started_utc":"2026-09-07T19:22:55.044685+00:00","stderr":{"bytes":0,"path":"review/semantic-kernel/sprint10/planning/official-preparation/status.stderr","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":3511,"path":"review/semantic-kernel/sprint10/planning/official-preparation/status.stdout","sha256":"7ba62c6afaeedf370c984a451a593c9bd221f913975324a236647ed2a738a230"}}],"counts":{"capabilities":4,"checked_tasks":0,"fixture_contracts":20,"inspected_controls":65,"planned_mutants":14,"requirements":17,"scenarios":57,"tasks":34},"finished_utc":"2026-09-07T19:22:55.865570+00:00","observed_head":"c16832941c18229e51fade7c496b16146bb810bd","plan_bindings":{"openspec/changes/operational-interface-binding-preservation/.openspec.yaml":{"bytes":40,"path":"openspec/changes/operational-interface-binding-preservation/.openspec.yaml","sha256":"809ac3c46e63d1b130c6bdbabf9d3028c43db36239b37b690705030f453a9ea6"},"openspec/changes/operational-interface-binding-preservation/design.md":{"bytes":36125,"path":"openspec/changes/operational-interface-binding-preservation/design.md","sha256":"d51cec12dfc85bb99817659072cfc88cb32cd362491a3f397adcfcd6eb201495"},"openspec/changes/operational-interface-binding-preservation/proposal.md":{"bytes":3138,"path":"openspec/changes/operational-interface-binding-preservation/proposal.md","sha256":"86511aac24c8a04ec5ffc1c78f7003ec48beed25ef6f47d5e87f22f5430730d8"},"openspec/changes/operational-interface-binding-preservation/specs/global-binding-preservation/spec.md":{"bytes":7289,"path":"openspec/changes/operational-interface-binding-preservation/specs/global-binding-preservation/spec.md","sha256":"b2c21cd551383b88cbd9ff807be8902ef7c71047d064bf015c6ac09fd0c36902"},"openspec/changes/operational-interface-binding-preservation/specs/interface-binding-regression-evidence/spec.md":{"bytes":5968,"path":"openspec/changes/operational-interface-binding-preservation/specs/interface-binding-regression-evidence/spec.md","sha256":"392a50b4cfd7e88763f1e57dc354afaec2b15a6a7abd09d035ff844d85462463"},"openspec/changes/operational-interface-binding-preservation/specs/interface-total-preservation/spec.md":{"bytes":4457,"path":"openspec/changes/operational-interface-binding-preservation/specs/interface-total-preservation/spec.md","sha256":"acd8f5bb6720cd7cad04dd2fb73335386d87a8349b5692450cfa95692e2526aa"},"openspec/changes/operational-interface-binding-preservation/specs/typed-region-accounting/spec.md":{"bytes":4688,"path":"openspec/changes/operational-interface-binding-preservation/specs/typed-region-accounting/spec.md","sha256":"229a0e7a2a89e4b1a4d312f24c7eecc6d113cef87327e0532ef60ce61e2ceb80"},"openspec/changes/operational-interface-binding-preservation/tasks.md":{"bytes":10914,"path":"openspec/changes/operational-interface-binding-preservation/tasks.md","sha256":"571a0832a85f7d0060a0863adf3a149506f95ce137db040fde9dc37bd9be0069"},"review/semantic-kernel/sprint10/planning/official-preparation/build-author-evidence.py":{"bytes":25722,"path":"review/semantic-kernel/sprint10/planning/official-preparation/build-author-evidence.py","sha256":"270860284df94760935dcb06f2d4f1f778899d6a38211a0e3d8ec5e5e0646188"},"review/semantic-kernel/sprint10/planning/official-preparation/validate-author.py":{"bytes":7913,"path":"review/semantic-kernel/sprint10/planning/official-preparation/validate-author.py","sha256":"01d3ec98f5897b9e244e3839a2eca3d3925f95ae7bd79021e000e0d299187a86"},"wiki-llm/sprint-10-operational-interface-bindings-outline.md":{"bytes":7629,"path":"wiki-llm/sprint-10-operational-interface-bindings-outline.md","sha256":"9cc671a2e54d57b7f295aad65d9028e22851bc655c7fb07082a8444376a073f9"}},"remaining_gates":["revalidate accepted S9 source/delivery binding","same-candidate S10 planning acceptance","official planning bundle freeze","nonauthor GPT-6 and native Fable5.1 medium planning acceptance","implementation and all proof/runtime/mutation/regression evidence","native Grok/Fable5.1-medium source/evidence acceptance","archive and verified delivery"],"source_context":"source-context.json","started_utc":"2026-09-07T19:22:54.110243+00:00","status":"planning_author_validation_passed_independent_gate_not_performed","tools":{"openspec_path":"/home/charl/.local/lib/node_modules/@fission-ai/openspec/bin/openspec.js","openspec_sha256":"ca136f0e9fd4951dcf93d8ed729ebc97b2d97d3980cd9dc9d42fc80e32e797c6","openspec_version":"1.10.0","python_path":"/usr/bin/python3.14","python_sha256":"b8d8288faefdd300201f43fcf00f6f539a27218eeed3a3dff5ab10b9c4c99700","python_version":"3.14.4 (main, Jun 18 2026, 14:25:02) [GCC 15.2.0]"}}

## END FILE

## FILE review/semantic-kernel/sprint10/planning/official-preparation/bind-dependency.py

Original SHA256: 14955b08030696b29e3bb0084da922e53d36bd31d8c3bcd57bbf71257ad8b184; bytes: 7836; rendered SHA256: 14955b08030696b29e3bb0084da922e53d36bd31d8c3bcd57bbf71257ad8b184

#!/usr/bin/env python3
"""Reconcile accepted predecessor evidence; does not rerun or relabel prior executions."""
from pathlib import Path
import datetime,hashlib,json,subprocess
R=Path(__file__).resolve().parents[5];E=Path(__file__).resolve().parent;S=R/'review/semantic-kernel/sprint9'
SRC='eec499d613688137a341f3556cd80ca461dd2ee9';LEG='c880acf62944746ff9a376afc0c0050702f037f7';ARCH='9908d9b56be2d5ed2b58a16fa8d28b23f33733ff'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
load=lambda p:json.loads(p.read_text())
checks=[];refs={}
def ck(n,v):checks.append({'label':n,'passed':bool(v)});assert v,n
def artifact(p):
 rel=str(p.relative_to(R));refs[rel]={'sha256':sha(p),'bytes':p.stat().st_size};return refs[rel]
def read(p):artifact(p);return load(p)
def gbytes(rev,p):return subprocess.check_output(['git','show',rev+':'+p],cwd=R)
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip()
delivery=read(S/'archive-delivery.json');accept=read(S/'acceptance/final-acceptance.json');read(S/'acceptance/final-scenarios.json');checkpoint=read(R/'review/semantic-kernel/sprint10/planning/sprint9-checkpoint-remote.json')
ck('accepted source and delivered archive identities',delivery['source_candidate']==SRC and delivery['archive_commit']==ARCH and delivery['remote_matches']and accept['substantive_source_and_evidence_accepted']and accept['delivery_complete'])
for v in accept['reviews']:
 ck('accepted review candidate/'+v['provider'],v['candidate']==SRC and v['verdict']=='ACCEPT WITH LIMITATIONS')
 for p,h in [(v['report'],v['report_sha256']),(v['invocation'],v['invocation_sha256'])]:ck('accepted review hash/'+p,sha(R/p)==h);artifact(R/p)
# Full predecessor Lean package baseline binding, source-equal through accepted delivery/current tree.
lean=read(S/'integration-final-r2/lean-runs.json');valid=read(S/'integration-final-r2/verification.json');pre=read(S/'integration-final-r2/source-before.json');post=read(S/'integration-final-r2/source-after.json')
ck('16 actual Lean commands at eec all passed',lean['candidate']==SRC and len(lean['runs'])==16 and all(x['exit_code']==0 for x in lean['runs'])and valid['all_commands_passed'])
ck('original before/after source inventories equal',pre==post)
source=[]
for p,v in pre.items():
 b=(R/p).read_bytes();ck('integrated source/'+p,hashlib.sha256(b).hexdigest()==v['sha256']and b==gbytes(SRC,p)==gbytes(ARCH,p)==gbytes(head,p));source.append({'path':p,'sha256':sha(R/p),'bytes':len(b),'git_blob':subprocess.check_output(['git','rev-parse',SRC+':'+p],cwd=R,text=True).strip(),'equal_at':[SRC,ARCH,head]})
for run in lean['runs']:
 for v in run['logs'].values():p=S/'integration-final-r2'/v['path'];ck('Lean log/'+str(p.relative_to(R)),sha(p)==v['sha256']);artifact(p)
# Actual14 mutations, and actual65 controls; preserve all raw observations in originals.
prod=read(S/'mutations-r2/results.json');summary=read(S/'mutations-r2/summary.json');pm=read(S/'mutations-r2/final-manifest.json');siblings=read(S/'mutations-r2/sibling-matrix.json');control=read(S/'implementation/runner-controls-r2/summary.json')
ck('14 production cases at accepted source',pm['candidate']==SRC and summary['candidate']==SRC and len(summary['mutants'])==14 and len(prod['results'])==15)
mutation_rows=[]
for row in summary['mutants']:
 actual=prod['results'][row['name']];ck('actual designated mutation/'+row['name'],all(actual['checks'][n]=='false'for n in row['required_false']));mutation_rows.append({'name':row['name'],'required_false':row['required_false'],'actual_exit':actual['exit'],'observed':{n:actual['checks'][n]for n in row['required_false']}})
ck('65 actual CLI cases at accepted source',control['git_head']==SRC and len(control['cases'])==control['total']==control['passed']==65 and all(x['passed']and x['actual_exit']==x['expected_exit']for x in control['cases']))
for p,v in pm['invocation']['input_bindings'].items():ck('production input/'+p,sha(R/p)==v['sha256']and(R/p).read_bytes()==gbytes(SRC,p)==gbytes(ARCH,p));source.append({'path':p,**v,'equal_at':[SRC,ARCH,head]})
for p,h in [(control['runner_source'],control['runner_sha256']),(control['harness_source'],control['harness_sha256'])]:
 path=Path(p)if Path(p).is_absolute()else R/p;ck('control source/'+p,sha(path)==h)
# Actual c880 legacy executions; independently recheck each declared closure, preserving its scope.
legacy=read(S/'regressions/regression-runs.json');outcomes=read(S/'regressions/verified-outcomes.json');eq=read(S/'implementation/legacy-dependency-equivalence.json');ck('13 recorded legacy suites at c880',legacy['source_revision']==LEG and len(legacy['runs'])==13 and all(x['exit']==0 for x in legacy['runs'])and outcomes['all_passed'])
legacy_rows=[];legacydeps={}
for suite in eq['suites']:
 for p,v in suite['source_closure'].items():
  if p not in legacydeps:
   b=(R/p).read_bytes();ck('legacy dependency/'+p,b==gbytes(LEG,p)==gbytes(SRC,p)==gbytes(ARCH,p)and sha(R/p)==v['original']['sha256']);legacydeps[p]=sha(R/p)
 for p,h in suite.get('evidence_inputs',{}).items():
  # Retain author-scoped auxiliary evidence; reconcile shape without extending source closure.
  artifact(R/p)
 row=next(x for x in legacy['runs']if x['label']==suite['label'])
 for k,hk in [('stdout_log','stdout_sha256'),('stderr_log','stderr_sha256'),('log','log_sha256')]:p=S/'regressions'/row[k];ck('legacy log/'+row[k],sha(p)==row[hk]);artifact(p)
 legacy_rows.append({'label':suite['label'],'actual_execution_candidate':LEG,'command':row['command'],'cwd':row['cwd'],'started_utc':row['started_utc'],'finished_utc':row['finished_utc'],'elapsed_seconds':row['elapsed_seconds'],'exit':row['exit'],'outcome':outcomes['outcomes'][suite['label']],'closure_basis':suite['closure_basis'],'dependency_paths':sorted(suite['source_closure'])})
for name,v in eq['tools'].items():ck('recorded tool unchanged/'+name,sha(Path(v['path']))==v['sha256'])
for x in load(E/'before-manifest.json'):ck('prior author evidence unchanged/'+x['path'],sha(R/x['path'])==x['sha256'])
ck('new Interface implementation absent',not(R/'lean/DefiKernel/Interface').exists())
record={'status':'ACCEPTED_DEPENDENCY_BOUND_S10_PLANNING_GATE_PENDING','captured_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'observed_head':head,'authoritative_delivery':delivery,'later_checkpoint_remote':checkpoint,'source_bindings':source,'source_equivalence_note':'Accepted source bytes equal archive/current bytes; metadata revisions do not create new executions.','actual_Lean':{'candidate':SRC,'commands':lean['runs'],'tools':lean['tools'],'source_count':len(pre)},'actual_mutations':{'candidate':SRC,'count':len(mutation_rows),'cases':mutation_rows,'command':pm['invocation']['command'],'invocation':pm['invocation'],'siblings_scope':'Per-mutant siblings were measured separately; only two global positives are production runner-enforced. See accepted final-acceptance finding R2 and sibling-matrix.json.'},'actual_controls':{'candidate':SRC,'total':65,'passed':65,'cases':[{'name':x['name'],'expected_exit':x['expected_exit'],'actual_exit':x['actual_exit'],'passed':x['passed'],'elapsed_seconds':x['elapsed_seconds']}for x in control['cases']]},'actual_legacy':{'candidate':LEG,'suites':legacy_rows,'unique_dependency_hashes':legacydeps,'equivalence_source':str((S/'implementation/legacy-dependency-equivalence.json').relative_to(R)),'scope':'Rechecked declared repository/tool closures. No new legacy execution or deployment/financial truth claim; original suite limitations remain.'},'reference_artifacts':refs,'checks':checks,'all_checks_passed':all(x['passed']for x in checks),'no_M2_implementation_or_native_review':True}
(E/'dependency-baseline.json').write_text(json.dumps(record,indent=2)+'\n');print('PASS accepted dependency:',len(checks),'checks;16Lean/14mutations/65controls/13legacy; source unchanged through',head)

## END FILE

## FILE review/semantic-kernel/sprint10/planning/official-preparation/build-author-evidence.py

Original SHA256: 270860284df94760935dcb06f2d4f1f778899d6a38211a0e3d8ec5e5e0646188; bytes: 25722; rendered SHA256: 270860284df94760935dcb06f2d4f1f778899d6a38211a0e3d8ec5e5e0646188

#!/usr/bin/env python3
"""Author-generated M2 planning contracts and mechanical coverage; no proof/audit claims."""
import hashlib, json, re, subprocess, sys
from pathlib import Path
from datetime import datetime, timezone
ROOT=Path(__file__).resolve().parents[5]
CHANGE=ROOT/'openspec/changes/operational-interface-binding-preservation'
OUT=Path(__file__).resolve().parent
specs=[]
def capability(name,purpose,requirements): specs.append((name,purpose,requirements))
def req(title,text,tasks,evidence,scenarios): return dict(title=title,text=text,tasks=tasks,evidence=evidence,scenarios=scenarios)
capability('typed-region-accounting','Connect finite typed balance regions to the exact signed effects of actual accepted execution receipts, including boundary transfers and issuance.',[
req('Finite typed region observations','The system SHALL expose finite region sums with set membership, exact domain/asset well-formedness and zero for an empty region. Repeated region declarations MUST NOT duplicate balances; typed interface results MUST state region well-formedness.', ['2.1','5.1'], ['balanceSum_set','region_wellformed','F01','M01'],[
('RA01 Empty region','an empty region is observed in any state','the balance sum and receipt delta are both zero'),
('RA02 Duplicate declarations','the same home/USD Alice cell is inserted twice into a region with Alice6 and Bob4','the region sum is10, not16, and membership remains set-valued'),
('RA03 Typed membership','a region declared home/USD contains an away or EUR cell','the region well-formedness proposition is false; dimensioned preservation cannot omit that premise')]),
req('Exact signed actual receipt accounting','For every actual successful invocation or administrative step, the system SHALL prove post-region sum equals pre-region sum plus the complete signed effect of that actual result receipt. The theorem MUST NOT assume this equation or accept a replacement receipt as its premise.', ['2.2','2.3','5.1'], ['actual_region_accounting','receiptCellEffect_eq','F01','F02','F03','F04','M02','M03','M04','M05'],[
('RA04 Neutral nonzero transfer','actual authorized transfer2 moves Alice6/Bob4 to4/6','the two-cell sum remains10 with effects −2,+2 and net region delta0'),
('RA05 Boundary-crossing transfer','the same actual transfer is observed in singleton Alice region','the sum changes6 to4 and delta is−2 even though whole home/USD supply is0'),
('RA06 Nonzero issuance','actual authorized mint3 credits Bob from4 to7 in the two-cell region','the sum changes10 to13 and receipt delta is+3; no neutral-flow conclusion is inferred'),
('RA07 Repeated targets','the actual receipt contains Alice−1,Alice−2,Bob+3 in that order','the singleton Alice delta is−3, final Alice3/Bob7, and all original receipt entries are retained')]),
req('Administrative balance identity','The system SHALL derive zero region effect for successful issue/revoke receipts and unchanged balances on actual administrative refusal, while retaining exact capability-store changes and refusal reasons.', ['2.3','5.4'], ['administrative_region_identity','F18','M14'],[
('RA08 Issue and revoke','an authenticated administrator issues a capability at fresh ID n then revokes n','all balances stay unchanged, both region deltas are0, and the store appends then tombstones that exact entry'),
('RA09 Refused administration','a non-administrator attempts the same issue','the actual authority refusal retains the input world/store and produces no successful receipt')]),
req('Actual successful prefix accounting','The system SHALL prove telescoping region accounting over actual successful sequential events and global shared-run attempts at every prefix. Refused, skipped and unreachable suffix actions MUST NOT contribute a receipt.', ['2.4','4.1','4.2','5.4'], ['sequential_receipt_fold','shared_receipt_fold','F15','F17','F19','F20'],[
('RA10 Successful prefix followed by refusal','paired debit succeeds from5/5/0 then transfer7 refuses and mint3 is a stopped suffix','the reached ledger is4/4/2, exactly one successful receipt is summed, and failure occurs at absolute index1'),
('RA11 Shared global receipt fold','complete schedule left,right,left executes two paired debits then a left insufficient-funds refusal in region Alice/Bob/Carol','the reached ledger is3/3/4 and exactly the two actual global successful receipts contribute'),
('RA12 Peer continues after refusal','the same F17 branches run under left,left,right from5/5/0','the first paired debit reaches4/4/2, left refusal at local index1 retains4/4/2, then the peer reaches3/3/4 with two actual successful receipts, exact retained left failure and unchanged full store'),
('RA13 Failed suffix skip before peer','left=[op102,op106,op101] and right=[op102] run under left,left,left,right','the failed left mint suffix adds no attempt, receipt or supply; left consumed becomes3 with nextIndex1, and the right peer still reaches3/3/4 with the exact earlier failure retained')])])
capability('interface-total-preservation','Establish initialized interface-total invariants from actual write confinement, shared-flow neutrality and explicit support for declared observations.',[
req('Conditional port-confined conservation','The system SHALL prove unchanged region sum from actual successful receipt writes confined to a declared shared set and zero summed effect over the region intersection with that set. Actual write locality MUST justify the complementary frame; catalog validity or whole-asset supply neutrality alone MUST NOT imply region neutrality.', ['3.1','5.2'], ['confined_neutral_preserves','F01','F02'],[
('IT01 Nonvacuous shared cancellation','Alice−2/Bob+2 are actual nonzero effects inside the region and shared set','the neutral intersection sum and actual confinement establish unchanged total10'),
('IT02 Supply neutrality is insufficient','actual transfer2 leaves the singleton Alice region with whole-asset supply0','the region total drops by2 and the missing region-neutrality premise is explicit'),
('IT03 Complement framed','an actual accepted receipt writes only inside Q','every region cell outside Q is unchanged by actual locality')]),
req('Supported declared total','The system SHALL distinguish a fixed initialized ghost quantity from a state-dependent declared total. For the latter it MUST require value-valued support, actual writes excluding that support and neutral region flow, and MUST prove preservation of the initialized equality.', ['3.2','3.3','5.2'], ['ValueSupports','supported_total_preserves','ghost_total_preserves','F05'],[
('IT04 Fixed declared quantity','initial region sum is10 and each actual permitted step has neutral confined region flow','the fixed declared quantity10 remains equal to the region sum at every prefix'),
('IT05 Private total support','a private home/USD total cell10 supports the declared quantity and actual transfer2 avoids it','both declared quantity and region sum remain10'),
('IT06 Missing initialization','a constant declared quantity11 is compared to entry region sum10 under only neutral later actions','preservation does not establish equality at entry or later; initialization remains required')]),
req('Actual writable-total counterexample','The system SHALL provide a separately valid catalog and an authorized successful transition that changes a writable declared-total observation while leaving the region sum unchanged. A denied access attempt MUST NOT stand in for this counterexample.', ['3.3','5.2'], ['writable_total_counterexample','F06'],[
('IT07 Exposed total changes','the separately exported writable total cell10 receives authorized +1 outside region Alice/Bob','execution succeeds, region stays10, declared total becomes11 and the equality is false'),
('IT08 Exact missing premise','the same accepted write is within shared Q and has zero region flow','the violated support-exclusion premise is identified; the example does not refute the theorem with all premises')]),
req('Initialized operational total lifting','The system SHALL lift local actual-step total obligations through every sequential prefix, accepted recursive sequential-group simulation and existing binary shared prefixes. Local obligations MUST quantify over arbitrary current execution inputs and permitted successful steps, without assuming the desired completed run.', ['3.4','4.1','4.2','4.3','5.4'], ['total_prefix_preservation','total_group_preservation','total_shared_preservation','F16','F17','F19','F20'],[
('IT09 Nonzero-index group','a group starts at index2 with retained history and executes transfer2 followed by the specified snapshot-driven return2','the total stays10 through actual steps at indices2 and3, with nextIndex4 and retained old history'),
('IT10 Shared total invariant','initialized Alice/Bob/Carol region total10 is preserved by each actually selected paired debit and peer refusal','every shared prefix retains total10, including F19 peer continuation after retained4/4/2 refusal and F20 failed-suffix skip before final3/3/4'),
('IT11 Absorbed failure','a sequential cursor has already refused or a selected shared stream is failed or exhausted','the identity transition preserves the reached total without a fabricated successful receipt')])])
capability('global-binding-preservation','Resolve stable globally qualified balance resources and preserve initialized typed equality constraints over actual execution prefixes.',[
req('Exact typed global binding query','The system SHALL resolve endpoints through their exact component and resource-export IDs, validate the actual catalog first, and then process input edges in original order. Per edge it MUST check left resolution, right resolution, domain, asset and balance in that order, returning the exact first failure with zero-based index and relevant names, cells or amounts. A Boolean success projection MUST agree with the exact query.', ['2.5','2.6','5.3'], ['checkBindings_ok_iff','binding_failure_first','F08','F10','F11','F12','F13','M06','M07','M08','M09','M10','M11','M12','M13'],[
('GB01 Exact qualified identity','two valid components both export local port0 but their USD balances are4 and5','the query compares distinct actual cells and reports unequal at the original edge index with amounts4,5'),
('GB02 Missing endpoint kind and side','an edge refers to absent component99 or absent port99 in existing component0','the query distinguishes missingComponent from missingPort and records the exact left/right endpoint and edge index'),
('GB03 Dimensional mismatch','equal numeric balances are linked across USD/EUR or home/away','assetMismatch or domainMismatch is returned; domainMismatch wins when both differ'),
('GB04 Failure precedence','edge0 has unequal resolved balances and edge1 has a missing endpoint','edge0 unequal is returned; within an edge missing left wins over missing right'),
('GB05 Catalog precedes emptiness','a duplicate-component catalog is queried with an empty edge list','configuration failure is returned; the same empty list succeeds for a valid catalog'),
('GB06 Outputs are not live resources','a qualified ID names only a historical output/input port, not a resource export','resource resolution returns missingPort even if a history value exists')]),
req('Binding meaning and actual alias distinction','The system SHALL define agreement as successful typed resolution plus equality for every global edge and prove query acceptance equivalent to catalog validity and that proposition. Existing imports MUST retain exact export-cell identity; distinct exported cells MUST NOT be treated as aliases merely because balances match.', ['2.6','4.4','5.3'], ['Agrees','query_agreement','import_export_identity','F07','F08','F13','F14'],[
('GB07 Positive distinct-cell equality','A and B resolve to distinct USD cells both containing5','agreement holds at entry, with no implied future write discipline'),
('GB08 One-sided accepted write','actual one-sided debit1 changes A5 to4 while B remains5','agreement becomes false after successful execution'),
('GB09 Existing resource alias','a valid import references canonical export A and actual transfer changes its cell6 to4','both views read the same exact cell4 without declaring a duplicate export'),
('GB10 Self binding','a self-edge references a resolving resource in a valid catalog','it succeeds in every state; an unresolved self-edge still reports its endpoint error')]),
req('Initialized actual binding preservation','The system SHALL derive edge preservation from initialized equality and equal actual receipt effects, then prove all global bindings at every sequential and binary shared prefix from initialization and locally quantified actual-step obligations. Refusal/skip identity and administrative balance identity MUST be included; group lifting MUST use accepted actual M1 simulation.', ['4.1','4.2','4.3','4.4','5.3','5.4'], ['paired_effect_preserves','binding_prefix_preservation','binding_group_preservation','binding_shared_preservation','F07','F15','F17','F18','F19','F20'],[
('GB11 Nonzero paired effects','F07 executes one paired-debit receipt from A5/B5/Carol0 and its companion executes an actual M1 seq of two op102 leaves from the same entry','the original case reaches4/4/2; the group prefixes reach4/4/2 then3/3/4 with independently expected full cursors, exact receipts and successful A=B queries at both prefixes, instantiating initialized group-binding preservation'),
('GB12 Sequential refusal retained','the paired step is followed by actual insufficient-funds refusal and stopped suffix','the binding remains4=4 with exact successful prefix and first refusal'),
('GB13 Shared peer progression','F17 runs under left,right,left and companion F19 runs under left,left,right','A=B=3 in both final states; F19 retains the exact left refusal at4/4/2 before the right peer progresses, with both actual histories and the unchanged store'),
('GB14 Administrative or skipped step','an actual administrative transition or failed/exhausted-stream identity occurs','balance bindings remain true while actual capability-store effects are retained')]),
req('Global constraint algebra and scope','The system SHALL prove agreement over list concatenation is conjunction, and prove edge-reorientation, duplicate idempotence, permutation and associativity laws at proposition/query-success level. It MUST transfer initialization and step obligations to prefix invariants while preserving the complete global edge set. It MUST NOT claim identical first-error diagnostics after reordering or participant regrouping from these algebraic laws.', ['4.5','5.3'], ['agrees_append','agrees_reverse','agrees_idempotent','agrees_assoc','agrees_permutation','binding_law_prefix','F09','F10'],[
('GB15 Union and orientation','global edge lists are concatenated, reassociated, duplicated or each edge reversed','agreement has the corresponding conjunction/equivalence law and initialized prefix obligations transport'),
('GB16 Global skip edge','A=C is wholly inside one side of the cut {A,C}|{B}, with amounts4 and5','the actual global query rejects it; the deliberately empty cut-extracted list succeeds and therefore does not represent the same constraint'),
('GB17 Diagnostic distinction','two failing edges are reordered or a failing edge is reversed','success equivalence holds but exact first index/side/amount payloads may change as specified')]),
req('Symmetric closure is sufficient only','The system SHALL prove equal symmetric closures imply equivalent global agreement predicates, and provide a typed valid-catalog counterexample to necessity using transitive equality. It MUST NOT advertise symmetric-closure equality as a complete semantic equivalence checker.', ['4.6','5.3'], ['same_symClosure_sufficient','symClosure_not_necessary','F10'],[
('GB18 Sufficient closure criterion','two global edge sets have equal symmetric closures','their agreement predicates are equivalent for every state under the same catalog'),
('GB19 Redundant transitive edge','E=[A=B,B=C] and F=E+[A=C] use three resolving same-dimension resources','agreement predicates are equivalent for every state although symmetric closures differ'),
('GB20 Independent omitted edge','an independently constraining A=B edge is omitted at balances4,5,5','the query can change from failure to success; redundancy is not inferred from omission alone')])])
capability('interface-binding-regression-evidence','Bind operational interface claims to independent expected observations, genuine compiled source mutations, complete proof inventories and explicit acceptance gates.',[
req('Independent funded observations and negative companions','The implementation SHALL exercise all F01–F20 design fixtures with independent complete expected ledgers, stores, receipts, histories, positions, query payloads and failures relevant to each case. Nonzero neutral flows and actual successful invariant violations MUST be distinguished from refused calls and compiler controls.', ['5.1','5.2','5.3','5.4','5.5'], ['F01-F20','fixture-manifest','runtime-manifest'],[
('RE01 Independent expected data','a financial or binding comparison is registered','its expected data are literal/reference construction independent of the production query/executor; full unspecified ledger cells are explicitly zero'),
('RE02 Broken premise succeeds operationally','the writable-total or one-sided-binding negative is exercised','actual execution succeeds with the specified violating post-state; an access or typing refusal cannot replace it'),
('RE03 Nonempty audit','the new runtime Audit is run','all unique registered comparisons execute, counts and names match their manifest, and absent/empty output is blocked')]),
req('Actual mutation and defensive control evidence','The implementation SHALL execute all fourteen M01–M14 design mutations against copied actual new runtime source. Each accepted detection MUST compile, flip its designated comparison and preserve its specified positive sibling. It MUST execute every inherited accepted predecessor control, including all65 currently inspected cases, with an exact name/source/expected-exit map refreshed before official freeze.', ['6.1','6.2','6.3','6.4'], ['M01-M14','inherited-controls','mutation-report','runner-controls'],[
('RE04 Compiled discriminating mutation','a planned mutation is counted as detected','the full actual runtime closure compiles, its named oracle is false, protected sibling true and real Audit output/exit are saved'),
('RE05 Compiler failure gets no credit','a mutation fails compilation or emits no designated observation','it is blocked or failed evidence, never a financial detection'),
('RE06 Production and proof-tail controls','the inherited parser and real production #eval/IO.userError cases are adapted','all expected accepted/failed/blocked exits and source-bound production outputs are checked; display warnings cannot hide results'),
('RE07 Drift or missing inputs','a source, manifest, required positive or runtime observation is missing or changes during a run','the harness refuses acceptance and preserves exact before/after identities')]),
req('Complete proof and regression evidence','The implementation SHALL capture all imported Interface theorem/supplemental declarations, full elaborated statements, private mappings, source/module identities and actual axiom dependencies. It MUST separate explicit generic results, reference instances, counterexamples and generated constants, and prohibit sorry, custom axioms and native_decide. All accepted prior regression obligations MUST remain discharged with honest run identity.', ['1.3','5.5','7.1','7.2','7.3'], ['proof-inventory','baseline','integration','legacy-regressions'],[
('RE08 Imported proof discovery','Verify elaborates the imported Interface environment','automatic inventory includes private/generated/unused declarations and full statement/axiom information without a hardcoded theorem count'),
('RE09 Exact regression identity','old regression evidence is carried or a suite rerun','actual run revision and relevant dependency equivalence are recorded; old runs are never relabeled fresh'),
('RE10 Protected source preservation','new modules and root import integrate','historical theorem/corpus bytes and required old sources remain preserved, with exact allowed integration changes recorded')]),
req('Dependency and independent acceptance gates','The change SHALL require exact accepted Sprint9 source/evidence/delivery bindings and actual M1 API/control identity, followed by nonauthor GPT-6 and native Fable5.1 medium acceptance of the same frozen S10 plan before implementation. The accepted dependency is source eec499d, source/evidence ec9ed804 and archive/verified remote9908d9b, with full revisions in dependency-baseline.json. Stock GPT-6 implementation MUST then receive native Grok/Fable5.1-medium source/evidence review, requesting `claude-fable-5-1[1m]` with `--effort medium` and recording its actual returned model. No Foreman or independent approval, implementation or completed proof SHALL be inferred from author validation or a planning freeze.', ['1.1','1.2','7.4','8.1','8.2'], ['dependency-gate','planning-audits','native-results','delivery'],[
('RE11 Accepted dependency binding','accepted Sprint9 source/delivery/API evidence is missing or differs from the planning binding','the dependency check blocks the planning gate and implementation until reconciled; author validation is not independent approval'),
('RE12 Reviewer identity','new planning or implementation reviews are executed','requested/reported models and exact reviewed bytes are recorded; unavailable/cancelled providers remain open reviews'),
('RE13 Material finding and delivery','a native finding remains or a required evidence obligation is incomplete','targeted corrections continue without an inferred revision cap; archive/delivery waits for all obligations and verified authorized branch delivery')])])

if __name__=='__main__':
    mode=sys.argv[1] if len(sys.argv)>1 else 'evidence'
    if mode=='specs':
        for name,purpose,requirements in specs:
            p=CHANGE/'specs'/name/'spec.md';p.parent.mkdir(parents=True,exist_ok=True)
            body=f'## Purpose\n\n{purpose}\n\n## ADDED Requirements\n'
            for r in requirements:
                body+=f"\n### Requirement: {r['title']}\n\n{r['text']}\n"
                for name,when,then in r['scenarios']:
                    body+=f'\n#### Scenario: {name}\n- **WHEN** {when}\n- **THEN** {then}\n'
            p.write_text(body)
        sys.exit()
    tasktext=(CHANGE/'tasks.md').read_text()
    tasks=re.findall(r'^- \[([ x])\] (\d+\.\d+) (.+)$',tasktext,re.M)
    ids={t[1] for t in tasks}; assert len(ids)==len(tasks) and all(t[0]==' ' for t in tasks)
    rows=[];actual_requirements=[]
    for name,_,requirements in specs:
        text=(CHANGE/'specs'/name/'spec.md').read_text()
        assert re.findall(r'^### Requirement: (.+)$',text,re.M)==[r['title'] for r in requirements]
        assert re.findall(r'^#### Scenario: (.+)$',text,re.M)==[s[0] for r in requirements for s in r['scenarios']]
        for r in requirements:
            actual_body=text.split('### Requirement: '+r['title']+'\n\n',1)[1].split('\n\n#### Scenario:',1)[0]
            r['text']=actual_body
            assert set(r['tasks'])<=ids
            actual_requirements.append(dict(capability=name,requirement=r['title'],normative_text=r['text'],tasks=r['tasks'],evidence=r['evidence']))
            for title,when,then in r['scenarios']:
                assert f'- **WHEN** {when}\n- **THEN** {then}' in text
                rows.append(dict(capability=name,requirement=r['title'],scenario=title,tasks=r['tasks'],planned_evidence=r['evidence'],status='planned_unimplemented'))
    used={t for r in rows for t in r['tasks']}; assert used==ids,(ids-used,used-ids)
    assert len({r['scenario'] for r in rows})==len(rows)
    sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
    inputs=[*sorted(CHANGE.rglob('*.md')),ROOT/'wiki-llm/sprint-10-operational-interface-bindings-outline.md',Path(__file__)]
    manifest=[dict(path=str(p.relative_to(ROOT)),sha256=sha(p),bytes=p.stat().st_size) for p in inputs]
    result=dict(status='planning_author_consistency_only',utc=datetime.now(timezone.utc).isoformat(),observed_head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),inspected_financial_source='eec499d613688137a341f3556cd80ca461dd2ee9',official_freeze=False,independent_planning_gate_performed=False,bounded_constructibility_review='provisional-constructibility-gpt6.md; not official acceptance',implementation_performed=False,dependency='accepted_delivered_Sprint9_eec_source_ec9_evidence_9908_archive_remote',counts=dict(capabilities=len(specs),requirements=len(actual_requirements),scenarios=len(rows),tasks=len(tasks),checked_tasks=0,planned_mutants=14),requirements=actual_requirements,scenarios=rows,tasks=[dict(id=t[1],description=t[2],status='unchecked') for t in tasks],input_manifest=manifest)
    (OUT/'author-coverage.json').write_text(json.dumps(result,indent=2)+'\n')
    lines=['# Planning author coverage','',f"{len(specs)} capabilities; {len(actual_requirements)} requirements; {len(rows)} scenarios; {len(tasks)} unchecked tasks; 14 planned mutations. No implementation or independent approval.",'','| Scenario | Requirement | Tasks | Planned evidence |','|---|---|---|---|']
    for r in rows:lines.append('| '+r['scenario']+' | '+r['requirement']+' | '+', '.join(r['tasks'])+' | '+', '.join(r['planned_evidence'])+' |')
    (OUT/'author-coverage.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps(result['counts'],sort_keys=True))

## END FILE

## FILE review/semantic-kernel/sprint10/planning/official-preparation/build-planning-bundle.py

Original SHA256: 719137ae86863e94d5980e6060e910cce2295ce955b29e58cd297266b0d6d791; bytes: 6708; rendered SHA256: 719137ae86863e94d5980e6060e910cce2295ce955b29e58cd297266b0d6d791

#!/usr/bin/env python3
"""Deterministic same-candidate S10 review bundle. --plan estimates only; --candidate freezes committed bytes."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess
R=Path(__file__).resolve().parents[5];E=Path(__file__).resolve().parent;OUT=E.parent
P=R/'openspec/changes/operational-interface-binding-preservation';PREFIX=str(E.relative_to(R))
ROOTS=['DefiKernel.Metatheory.Verify','DefiKernel.Interleaving.Interference','DefiKernel.Atomic.Settlement','Defialgebra.Interface','Defialgebra.Nary']
sha=lambda b:hashlib.sha256(b).hexdigest()
def inputs():
 paths={str(p.relative_to(R))for p in P.rglob('*.md')}
 paths.update(['AGENTS.md','.claude/skills/defi-footguns/SKILL.md','formal/v3/GATE-REGISTER.md','docs/superpowers/specs/2026-09-06-semantic-kernel-design.md','wiki-llm/operational-metatheory-planning-draft.md','wiki-llm/sprint-10-operational-interface-bindings-outline.md','lean/lean-toolchain','lean/lakefile.toml','lean/lake-manifest.json','scripts/check_metatheory_mutations.py','scripts/test_metatheory_mutation_runner.py','mutations/metatheory.json','review/semantic-kernel/sprint9/archive-delivery.json','review/semantic-kernel/sprint9/acceptance/final-acceptance.json','review/semantic-kernel/sprint10/planning/sprint9-checkpoint-remote.json'])
 paths.update(PREFIX+'/'+x for x in ['READINESS.md','author-coverage.json','author-validation.json','source-context.json','dependency-review.json','runner-adaptation.json','inherited-controls.json','planned-mutations.json','build-author-evidence.py','validate-author.py','bind-dependency.py','build-planning-bundle.py','strict-validation.stdout','strict-validation.stderr'])
 # Expand every repository-local import of the selected complete source roots.
 todo=ROOTS[:];seen=set();external=set()
 while todo:
  name=todo.pop()
  if name in seen:continue
  seen.add(name);p=R/'lean'/Path(name.replace('.','/')).with_suffix('.lean')
  if not p.is_file():external.add(name);continue
  paths.add(str(p.relative_to(R)))
  for line in p.read_text().splitlines():
   if line.startswith('import '):todo.extend(line[7:].split())
 return sorted(paths),sorted(external)
def build(candidate,require_git):
 paths,external=inputs();rows=[];parts=[f'# Sprint10 independent planning review\n\nCandidate: {candidate}\n\nScope:4 capabilities,17 requirements,57 scenarios,34 unchecked tasks,20 fixture IDs including the F07 group companion,14 planned mutations,65 inherited controls. This is planning, not implemented Interface evidence. Both nonauthor GPT-6 and native Fable5.1 medium receive this identical bundle. Fable request claude-fable-5-1[1m], --effort medium; record actual returned model.\n\nReview exact actual-receipt accounting, initialized noncircular local obligations, arbitrary-entry group induction, query precedence/types/global edge scope, independent funded oracles and executable mutation/control feasibility. No arbitrary shared-state commutation, deployed fidelity or inferred certificate claim. Classify concrete collaborator risks and exact fixes; reviewer advice is not proof.\n\nAll selected source/text files below are verbatim. JSON files preserve every key/value using compact serialization; original and rendered hashes are recorded independently. Large retained execution logs and full mechanical checks are reference-bound by dependency-review.json, not expanded in this planning prompt. External library sources are bound through the accepted toolchain/package manifest; they are not reproduced.\n\n'.encode()]
 for rel in paths:
  p=R/rel;raw=p.read_bytes();rendered=raw
  if p.suffix=='.json':rendered=(json.dumps(json.loads(raw),sort_keys=True,separators=(',',':'),ensure_ascii=False)+'\n').encode()
  proc=subprocess.run(['git','rev-parse',candidate+':'+rel],cwd=R,capture_output=True,text=True)
  blob=proc.stdout.strip()if proc.returncode==0 else None
  matches=blob is not None and subprocess.check_output(['git','show',candidate+':'+rel],cwd=R)==raw
  if require_git:assert matches,'uncommitted or changed review input: '+rel
  rows.append({'path':rel,'bytes':len(raw),'sha256':sha(raw),'git_blob':blob,'matches_candidate':matches,'rendering':'complete_compact_JSON'if p.suffix=='.json'else'verbatim','rendered_bytes':len(rendered),'rendered_sha256':sha(rendered)})
  parts.append(f'\n## FILE {rel}\n\nOriginal SHA256: {sha(raw)}; bytes: {len(raw)}; rendered SHA256: {sha(rendered)}\n\n'.encode()+rendered+b'\n## END FILE\n')
 data=b''.join(parts);assert len(data)<1_400_000,('bundle exceeds1400000bytes',len(data))
 meta={'kind':'same-candidate-independent-planning-review','candidate':candidate,'input_count':len(rows),'inputs':rows,'bundle_sha256':sha(data),'bundle_bytes':len(data),'source_roots':ROOTS,'external_imports_not_expanded':external,'source_rendering':'all repository-local imports of selected roots included verbatim','JSON_rendering':'complete values compacted; original and rendered hashes separately bound','omitted_expansions':'Complete retained execution logs and mechanical assertion labels are reference-bound in dependency-review.json, not included as full text; no original data deleted.','planning_reviews_performed_by_builder':False}
 return data,meta
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--plan',action='store_true');ap.add_argument('--candidate');ap.add_argument('--label',default='r1');a=ap.parse_args();head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip()
 assert re.fullmatch(r'r[1-9][0-9]*',a.label)
 if a.plan:
  assert a.candidate is None;data,meta=build(head,False);meta['status']='size/input preparation only; not official freeze';(E/'bundle-plan.json').write_text(json.dumps(meta,indent=2)+'\n');print(json.dumps({'status':meta['status'],'input_count':meta['input_count'],'bundle_bytes':meta['bundle_bytes']}));raise SystemExit
 assert a.candidate and a.candidate==head,'freeze requires explicit current committed candidate'
 data,meta=build(a.candidate,True);again,againmeta=build(a.candidate,True);assert data==again and meta==againmeta
 bp=OUT/(a.label+'-bundle.md');mp=OUT/(a.label+'-candidate.json');assert not bp.exists()and not mp.exists(),'preserve existing freeze; choose a new revision label'
 bp.write_bytes(data);mp.write_text(json.dumps(meta,indent=2)+'\n');assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip()==head
 for row in meta['inputs']:assert sha((R/row['path']).read_bytes())==row['sha256']
 print(json.dumps({'candidate':head,'bundle':str(bp.relative_to(R)),'manifest':str(mp.relative_to(R)),'inputs':len(meta['inputs']),'bytes':len(data),'sha256':meta['bundle_sha256'],'repeated_rendering_equal':True,'inputs_unchanged':True}))

## END FILE

## FILE review/semantic-kernel/sprint10/planning/official-preparation/dependency-review.json

Original SHA256: 7a308edb3e4aad6477c07165f1f46337f3758818d088f9db6df5963ffe080b13; bytes: 102722; rendered SHA256: cd6d00bf104aa1167e1e773ce9791903aaad77c0d3dc7a44ebfa76910049f6d4

{"actual_Lean":{"candidate":"eec499d613688137a341f3556cd80ca461dd2ee9","commands":[{"argv":["lake","build"],"cwd":"/home/charl/defiformal/lean","elapsed_seconds":9.123,"exit_code":0,"finished_utc":"2026-09-07T18:47:43.200463+00:00","logs":{"stderr":{"bytes":0,"path":"00.stderr.log","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":1200208,"path":"00.stdout.log","sha256":"7beeb11f55a98e2f31660b14d79867c733c186c69acd915247c30833134cb7af"}},"started_utc":"2026-09-07T18:47:34.077377+00:00"},{"argv":["lake","env","lean","DefiKernel/Metatheory/Audit.lean"],"cwd":"/home/charl/defiformal/lean","elapsed_seconds":1.803,"exit_code":0,"finished_utc":"2026-09-07T18:47:45.003906+00:00","logs":{"stderr":{"bytes":0,"path":"01.stderr.log","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":6169,"path":"01.stdout.log","sha256":"5b2cb282ffbeb2831c212fb1c9d4b6a6a0d850497b3f7db006e61f51cfb87b03"}},"started_utc":"2026-09-07T18:47:43.200591+00:00"},{"argv":["lake","env","lean","DefiKernel/Metatheory/Verify.lean"],"cwd":"/home/charl/defiformal/lean","elapsed_seconds":4.384,"exit_code":0,"finished_utc":"2026-09-07T18:47:49.388022+00:00","logs":{"stderr":{"bytes":0,"path":"02.stderr.log","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":91441,"path":"02.stdout.log","sha256":"7d14a32dcc532fef650ab3ceada4baee53845b0f34787215fd0cf556d83f5dce"}},"started_utc":"2026-09-07T18:47:45.004064+00:00"},{"argv":["lake","env","lean","DefiKernel/Atomic/Audit.lean"],"cwd":"/home/charl/defiformal/lean","elapsed_seconds":2.121,"exit_code":0,"finished_utc":"2026-09-07T18:47:51.508917+00:00","logs":{"stderr":{"bytes":0,"path":"03.stderr.log","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":5340,"path":"03.stdout.log","sha256":"e144b01f594a113d995580ba2f1ba9e7c68a0ca05ba0d3d0a22a9fcb20f6f721"}},"started_utc":"2026-09-07T18:47:49.388200+00:00"},{"argv":["lake","env","lean","DefiKernel/Atomic/Verify.lean"],"cwd":"/home/charl/defiformal/lean","elapsed_seconds":4.307,"exit_code":0,"finished_utc":"2026-09-07T18:47:55.816420+00:00","logs":{"stderr":{"bytes":0,"path":"04.stderr.log","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":121449,"path":"04.stdout.log","sha256":"85ae2e946af04330a2140084e5c3789d90ce57ef51c04bb3b6fed46f44a6dfbf"}},"started_utc":"2026-09-07T18:47:51.509096+00:00"},{"argv":["lake","env","lean","DefiKernel/Interleaving/Audit.lean"],"cwd":"/home/charl/defiformal/lean","elapsed_seconds":1.704,"exit_code":0,"finished_utc":"2026-09-07T18:47:57.521030+00:00","logs":{"stderr":{"bytes":0,"path":"05.stderr.log","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":5200,"path":"05.stdout.log","sha256":"025d6cc19c57eb8432a029cf9e4f4d273b838b7d4094063b89b3248dd425a472"}},"started_utc":"2026-09-07T18:47:55.816632+00:00"},{"argv":["lake","env","lean","DefiKernel/Interleaving/Verify.lean"],"cwd":"/home/charl/defiformal/lean","elapsed_seconds":4.16,"exit_code":0,"finished_utc":"2026-09-07T18:48:01.680957+00:00","logs":{"stderr":{"bytes":0,"path":"06.stderr.log","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":85266,"path":"06.stdout.log","sha256":"47ae28207e443b7c948ead9f6e9dffd188d2d25deea8798bc3c8ccdf262216c1"}},"started_utc":"2026-09-07T18:47:57.521208+00:00"},{"argv":["lake","env","lean","DefiKernel/Parallel/Audit.lean"],"cwd":"/home/charl/defiformal/lean","elapsed_seconds":2.045,"exit_code":0,"finished_utc":"2026-09-07T18:48:03.726229+00:00","logs":{"stderr":{"bytes":0,"path":"07.stderr.log","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":5375,"path":"07.stdout.log","sha256":"b8d41e3bab4a6ae65dd3632d85c514421076d6fc6d6f1d5c3a7989965b0368e9"}},"started_utc":"2026-09-07T18:48:01.681239+00:00"},{"argv":["lake","env","lean","DefiKernel/Parallel/Verify.lean"],"cwd":"/home/charl/defiformal/lean","elapsed_seconds":4.929,"exit_code":0,"finished_utc":"2026-09-07T18:48:08.654935+00:00","logs":{"stderr":{"bytes":0,"path":"08.stderr.log","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":120587,"path":"08.stdout.log","sha256":"82e4c2c957323dde95640e783c7306a124e9627f96a97a1785ccc9c1fe2c9eaf"}},"started_utc":"2026-09-07T18:48:03.726441+00:00"},{"argv":["lake","env","lean","DefiKernel/Composition/Audit.lean"],"cwd":"/home/charl/defiformal/lean","elapsed_seconds":1.914,"exit_code":0,"finished_utc":"2026-09-07T18:48:10.569709+00:00","logs":{"stderr":{"bytes":0,"path":"09.stderr.log","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":3010,"path":"09.stdout.log","sha256":"9173b87109f8c6c3f6afae01958f1480d84a8ec42cd34429f56aa077b1a89368"}},"started_utc":"2026-09-07T18:48:08.655502+00:00"},{"argv":["lake","env","lean","DefiKernel/Composition/Verify.lean"],"cwd":"/home/charl/defiformal/lean","elapsed_seconds":5.566,"exit_code":0,"finished_utc":"2026-09-07T18:48:16.135799+00:00","logs":{"stderr":{"bytes":0,"path":"10.stderr.log","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":132450,"path":"10.stdout.log","sha256":"56e39dbb1623f32c71599b0a70c3a9b7752319ccacadac71b2ac95565ef31fe0"}},"started_utc":"2026-09-07T18:48:10.570102+00:00"},{"argv":["lake","env","lean","DefiKernel/Typed/Audit.lean"],"cwd":"/home/charl/defiformal/lean","elapsed_seconds":1.751,"exit_code":0,"finished_utc":"2026-09-07T18:48:17.887538+00:00","logs":{"stderr":{"bytes":0,"path":"11.stderr.log","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":6957,"path":"11.stdout.log","sha256":"19ecc53feba3fbe993b6f2fed294efb170716f6b5a555a4d34bd1bad7f05af1e"}},"started_utc":"2026-09-07T18:48:16.136380+00:00"},{"argv":["lake","env","lean","DefiKernel/Typed/Verify.lean"],"cwd":"/home/charl/defiformal/lean","elapsed_seconds":5.642,"exit_code":0,"finished_utc":"2026-09-07T18:48:23.530065+00:00","logs":{"stderr":{"bytes":0,"path":"12.stderr.log","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":193632,"path":"12.stdout.log","sha256":"0fd188b353c6f014bebb5baaf53447f2660a07619fe2236eca91e9eaa5d24790"}},"started_utc":"2026-09-07T18:48:17.887743+00:00"},{"argv":["lake","env","lean","DefiKernel/Audit.lean"],"cwd":"/home/charl/defiformal/lean","elapsed_seconds":1.983,"exit_code":0,"finished_utc":"2026-09-07T18:48:25.512906+00:00","logs":{"stderr":{"bytes":0,"path":"13.stderr.log","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":5822,"path":"13.stdout.log","sha256":"61819efaae5d9062231e6dd3e126b3ce93cfb225cdbbdc8498d630f568cbbe63"}},"started_utc":"2026-09-07T18:48:23.530306+00:00"},{"argv":["lake","env","lean","DefiKernel/ContractAudit.lean"],"cwd":"/home/charl/defiformal/lean","elapsed_seconds":2.211,"exit_code":0,"finished_utc":"2026-09-07T18:48:27.724275+00:00","logs":{"stderr":{"bytes":0,"path":"14.stderr.log","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":1364,"path":"14.stdout.log","sha256":"660f556e96037016023e457e37f692acf9e3ff0f16072fcc271511537494e438"}},"started_utc":"2026-09-07T18:48:25.513263+00:00"},{"argv":["lake","env","lean","DefiKernel/VerifyAxioms.lean"],"cwd":"/home/charl/defiformal/lean","elapsed_seconds":5.279,"exit_code":0,"finished_utc":"2026-09-07T18:48:33.003835+00:00","logs":{"stderr":{"bytes":0,"path":"15.stderr.log","sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"stdout":{"bytes":69846,"path":"15.stdout.log","sha256":"4fe1669dcec9ff26f7626f3a2125aea61719fe3b8c25e8eff385457b54553c8f"}},"started_utc":"2026-09-07T18:48:27.724521+00:00"}],"source_count":116,"tools":{"lake":{"path":"/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin/lake","sha256":"60330ab6f07dce20f3fa9ebb08e8b984ea9549eac172afeb15d9d2227060e2b3","version":"Lake version 5.0.0-src+d8b1897 (Lean version 4.33.0-rc2)"},"lean":{"path":"/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin/lean","sha256":"e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550","version":"Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)"}}},"actual_check_count":359,"actual_controls":{"candidate":"eec499d613688137a341f3556cd80ca461dd2ee9","cases":[{"actual_exit":0,"elapsed_seconds":5.434829,"expected_exit":0,"name":"production-eval-discriminating-mutant","passed":true},{"actual_exit":1,"elapsed_seconds":4.50156,"expected_exit":1,"name":"production-eval-required-stays-true","passed":true},{"actual_exit":0,"elapsed_seconds":4.175903,"expected_exit":0,"name":"live-discriminating-mutant","passed":true},{"actual_exit":0,"elapsed_seconds":4.258346,"expected_exit":0,"name":"dotted-comparisons","passed":true},{"actual_exit":0,"elapsed_seconds":4.371352,"expected_exit":0,"name":"hyphenated-dotted-comparisons","passed":true},{"actual_exit":3,"elapsed_seconds":0.057291,"expected_exit":3,"name":"empty-dot-segment-spec","passed":true},{"actual_exit":3,"elapsed_seconds":0.059595,"expected_exit":3,"name":"trailing-dot-spec","passed":true},{"actual_exit":3,"elapsed_seconds":2.832568,"expected_exit":3,"name":"leading-dot-observation","passed":true},{"actual_exit":3,"elapsed_seconds":2.967949,"expected_exit":3,"name":"empty-dot-segment-observation","passed":true},{"actual_exit":0,"elapsed_seconds":4.504605,"expected_exit":0,"name":"unused-variable-warning","passed":true},{"actual_exit":3,"elapsed_seconds":3.113577,"expected_exit":3,"name":"uppercase-observation","passed":true},{"actual_exit":3,"elapsed_seconds":4.111194,"expected_exit":3,"name":"unknown-mutant-observation","passed":true},{"actual_exit":1,"elapsed_seconds":4.269997,"expected_exit":1,"name":"all-true-mutant","passed":true},{"actual_exit":1,"elapsed_seconds":4.06551,"expected_exit":1,"name":"required-observation-stays-true","passed":true},{"actual_exit":1,"elapsed_seconds":4.163255,"expected_exit":1,"name":"positive-control-flipped","passed":true},{"actual_exit":3,"elapsed_seconds":4.184289,"expected_exit":3,"name":"compilation-only-failure","passed":true},{"actual_exit":3,"elapsed_seconds":3.886305,"expected_exit":3,"name":"compiler-error-with-runtime-failure","passed":true},{"actual_exit":3,"elapsed_seconds":2.637237,"expected_exit":3,"name":"empty-observations","passed":true},{"actual_exit":3,"elapsed_seconds":2.824608,"expected_exit":3,"name":"duplicate-observations","passed":true},{"actual_exit":3,"elapsed_seconds":2.869288,"expected_exit":3,"name":"missing-positive-observation","passed":true},{"actual_exit":3,"elapsed_seconds":2.677319,"expected_exit":3,"name":"missing-required-observation","passed":true},{"actual_exit":3,"elapsed_seconds":3.819471,"expected_exit":3,"name":"partial-mutant-observations","passed":true},{"actual_exit":3,"elapsed_seconds":0.052288,"expected_exit":3,"name":"no-op-mutation","passed":true},{"actual_exit":3,"elapsed_seconds":0.051255,"expected_exit":3,"name":"missing-mutation-needle","passed":true},{"actual_exit":3,"elapsed_seconds":0.065894,"expected_exit":3,"name":"missing-source-setup","passed":true},{"actual_exit":3,"elapsed_seconds":0.052473,"expected_exit":3,"name":"missing-manifest-setup","passed":true},{"actual_exit":3,"elapsed_seconds":0.050691,"expected_exit":3,"name":"existing-output-setup","passed":true},{"actual_exit":3,"elapsed_seconds":0.050115,"expected_exit":3,"name":"reserved-mutation-name","passed":true},{"actual_exit":3,"elapsed_seconds":0.046037,"expected_exit":3,"name":"empty-module-inventory","passed":true},{"actual_exit":3,"elapsed_seconds":0.047761,"expected_exit":3,"name":"empty-positive-inventory","passed":true},{"actual_exit":3,"elapsed_seconds":0.045297,"expected_exit":3,"name":"duplicate-module-inventory","passed":true},{"actual_exit":3,"elapsed_seconds":0.047194,"expected_exit":3,"name":"duplicate-mutation-inventory","passed":true},{"actual_exit":3,"elapsed_seconds":0.044228,"expected_exit":3,"name":"duplicate-positive-check","passed":true},{"actual_exit":3,"elapsed_seconds":0.047851,"expected_exit":3,"name":"duplicate-required-check","passed":true},{"actual_exit":3,"elapsed_seconds":0.051186,"expected_exit":3,"name":"nonunique-mutation-needle","passed":true},{"actual_exit":3,"elapsed_seconds":2.752469,"expected_exit":3,"name":"malformed-observation","passed":true},{"actual_exit":3,"elapsed_seconds":0.057373,"expected_exit":3,"name":"malformed-json","passed":true},{"actual_exit":3,"elapsed_seconds":0.05663,"expected_exit":3,"name":"duplicate-json-key","passed":true},{"actual_exit":3,"elapsed_seconds":0.058745,"expected_exit":3,"name":"output-inside-repository","passed":true},{"actual_exit":3,"elapsed_seconds":0.070591,"expected_exit":3,"name":"output-symlink","passed":true},{"actual_exit":0,"elapsed_seconds":3.75492,"expected_exit":0,"name":"discovered-metatheory-dependency","passed":true},{"actual_exit":3,"elapsed_seconds":2.688492,"expected_exit":3,"name":"fresh-dependency-source-failure","passed":true},{"actual_exit":3,"elapsed_seconds":0.065768,"expected_exit":3,"name":"missing-audit-root","passed":true},{"actual_exit":3,"elapsed_seconds":0.069324,"expected_exit":3,"name":"foreign-module-root","passed":true},{"actual_exit":3,"elapsed_seconds":0.069136,"expected_exit":3,"name":"mutation-module-outside-inventory","passed":true},{"actual_exit":1,"elapsed_seconds":2.977483,"expected_exit":1,"name":"unchanged-control-failed","passed":true},{"actual_exit":0,"elapsed_seconds":4.002469,"expected_exit":0,"name":"nonkernel-local-dependency","passed":true},{"actual_exit":3,"elapsed_seconds":1.446875,"expected_exit":3,"name":"dirty-source-before-run","passed":true},{"actual_exit":3,"elapsed_seconds":1.372814,"expected_exit":3,"name":"staged-source-before-run","passed":true},{"actual_exit":3,"elapsed_seconds":2.633149,"expected_exit":3,"name":"source-drift-during-run","passed":true},{"actual_exit":3,"elapsed_seconds":3.908102,"expected_exit":3,"name":"source-drift-during-mutant","passed":true},{"actual_exit":3,"elapsed_seconds":3.112537,"expected_exit":3,"name":"specification-drift-during-run","passed":true},{"actual_exit":3,"elapsed_seconds":0.060286,"expected_exit":3,"name":"runtime-definition-after-proof-boundary","passed":true},{"actual_exit":3,"elapsed_seconds":0.054255,"expected_exit":3,"name":"attributed-runtime-after-proof-boundary","passed":true},{"actual_exit":3,"elapsed_seconds":0.054026,"expected_exit":3,"name":"comment-prefixed-runtime-after-proof-boundary","passed":true},{"actual_exit":3,"elapsed_seconds":0.050894,"expected_exit":3,"name":"macro-after-proof-boundary","passed":true},{"actual_exit":3,"elapsed_seconds":0.050541,"expected_exit":3,"name":"macro-rules-after-proof-boundary","passed":true},{"actual_exit":3,"elapsed_seconds":0.074942,"expected_exit":3,"name":"syntax-after-proof-boundary","passed":true},{"actual_exit":3,"elapsed_seconds":0.058882,"expected_exit":3,"name":"initialize-after-proof-boundary","passed":true},{"actual_exit":0,"elapsed_seconds":4.1834,"expected_exit":0,"name":"proof-comment-keywords-sibling","passed":true},{"actual_exit":0,"elapsed_seconds":4.404341,"expected_exit":0,"name":"proof-string-keywords-sibling","passed":true},{"actual_exit":3,"elapsed_seconds":0.054526,"expected_exit":3,"name":"raw-string-before-attributed-runtime","passed":true},{"actual_exit":3,"elapsed_seconds":0.052846,"expected_exit":3,"name":"character-before-attributed-runtime","passed":true},{"actual_exit":0,"elapsed_seconds":3.996681,"expected_exit":0,"name":"proof-raw-string-character-sibling","passed":true},{"actual_exit":3,"elapsed_seconds":0.059795,"expected_exit":3,"name":"empty-mutation-inventory","passed":true}],"passed":65,"total":65},"actual_legacy":{"candidate":"c880acf62944746ff9a376afc0c0050702f037f7","equivalence_source":"review/semantic-kernel/sprint9/implementation/legacy-dependency-equivalence.json","scope":"Rechecked declared repository/tool closures. No new legacy execution or deployment/financial truth claim; original suite limitations remain.","suites":[{"actual_execution_candidate":"c880acf62944746ff9a376afc0c0050702f037f7","closure_basis":"Actual runner source-manifest transitive Lean closure, runner, specification and pinned Lake configuration.","command":["/usr/bin/python3","scripts/check_interleaving_mutations.py","--repo","/home/charl/defiformal","--spec","review/semantic-kernel/sprint7/mutation-spec.json","--out","/tmp/defiformal-sprint9-regressions-p9r8vwrk/interleaving-mutations"],"cwd":"/home/charl/defiformal","dependency_paths":["lean/DefiKernel/Composition/Contracts.lean","lean/DefiKernel/Composition/Examples.lean","lean/DefiKernel/Composition/Execution.lean","lean/DefiKernel/Composition/Interfaces.lean","lean/DefiKernel/Composition/Preservation.lean","lean/DefiKernel/Composition/Sequence.lean","lean/DefiKernel/Interleaving/Audit.lean","lean/DefiKernel/Interleaving/Examples.lean","lean/DefiKernel/Interleaving/Execution.lean","lean/DefiKernel/Interleaving/Schedule.lean","lean/DefiKernel/Interleaving/ScheduleTests.lean","lean/DefiKernel/Interleaving/Tests.lean","lean/DefiKernel/Parallel/Compatibility.lean","lean/DefiKernel/Parallel/Examples.lean","lean/DefiKernel/Parallel/Execution.lean","lean/DefiKernel/Parallel/Observation.lean","lean/DefiKernel/Parallel/ObservationTests.lean","lean/DefiKernel/Typed/Authority.lean","lean/DefiKernel/Typed/Examples.lean","lean/DefiKernel/Typed/Expr.lean","lean/DefiKernel/Typed/Transition.lean","lean/DefiKernel/Typed/Types.lean","lean/lake-manifest.json","lean/lakefile.toml","lean/lean-toolchain","review/semantic-kernel/sprint7/mutation-spec.json","scripts/check_interleaving_mutations.py"],"elapsed_seconds":604.104,"exit":0,"finished_utc":"2026-09-07T18:33:25.404876+00:00","label":"interleaving-mutations","outcome":{"comparisons_each":116,"mutants_detected":14,"protected_positives_each":9},"started_utc":"2026-09-07T18:23:21.296579+00:00"},{"actual_execution_candidate":"c880acf62944746ff9a376afc0c0050702f037f7","closure_basis":"Actual runner source-manifest transitive Lean closure, runner, specification and pinned Lake configuration.","command":["/usr/bin/python3","scripts/check_atomic_mutations.py","--repo","/home/charl/defiformal","--spec","review/semantic-kernel/sprint8/mutation-spec.json","--out","/tmp/defiformal-sprint9-regressions-p9r8vwrk/atomic-mutations"],"cwd":"/home/charl/defiformal","dependency_paths":["lean/DefiKernel/Atomic/Audit.lean","lean/DefiKernel/Atomic/Examples.lean","lean/DefiKernel/Atomic/Execution.lean","lean/DefiKernel/Atomic/Observation.lean","lean/DefiKernel/Atomic/Policy.lean","lean/DefiKernel/Atomic/Tests.lean","lean/DefiKernel/Composition/Contracts.lean","lean/DefiKernel/Composition/Examples.lean","lean/DefiKernel/Composition/Execution.lean","lean/DefiKernel/Composition/Interfaces.lean","lean/DefiKernel/Composition/Preservation.lean","lean/DefiKernel/Composition/Sequence.lean","lean/DefiKernel/Interleaving/Examples.lean","lean/DefiKernel/Interleaving/Execution.lean","lean/DefiKernel/Interleaving/Schedule.lean","lean/DefiKernel/Parallel/Compatibility.lean","lean/DefiKernel/Parallel/Examples.lean","lean/DefiKernel/Parallel/Execution.lean","lean/DefiKernel/Parallel/Observation.lean","lean/DefiKernel/Parallel/ObservationTests.lean","lean/DefiKernel/Typed/Authority.lean","lean/DefiKernel/Typed/Examples.lean","lean/DefiKernel/Typed/Expr.lean","lean/DefiKernel/Typed/Transition.lean","lean/DefiKernel/Typed/Types.lean","lean/lake-manifest.json","lean/lakefile.toml","lean/lean-toolchain","review/semantic-kernel/sprint8/mutation-spec.json","scripts/check_atomic_mutations.py"],"elapsed_seconds":831.965,"exit":0,"finished_utc":"2026-09-07T18:37:13.290833+00:00","label":"atomic-mutations","outcome":{"comparisons_each":135,"mutants_detected":18,"protected_positives_each":6},"started_utc":"2026-09-07T18:23:21.321844+00:00"},{"actual_execution_candidate":"c880acf62944746ff9a376afc0c0050702f037f7","closure_basis":"Runner and fixture-generating harness, plus the three copied Lake configuration files; Lean fixture sources are generated by that unchanged harness in isolated repositories.","command":["/usr/bin/python3","scripts/test_atomic_mutation_runner.py","--repo","/home/charl/defiformal","--out","/tmp/defiformal-sprint9-regressions-p9r8vwrk/atomic-runner-controls"],"cwd":"/home/charl/defiformal","dependency_paths":["lean/lake-manifest.json","lean/lakefile.toml","lean/lean-toolchain","scripts/check_atomic_mutations.py","scripts/test_atomic_mutation_runner.py"],"elapsed_seconds":243.003,"exit":0,"finished_utc":"2026-09-07T18:27:24.368583+00:00","label":"atomic-runner-controls","outcome":{"kind":"actual CLI classifications","passed":65,"total":65},"started_utc":"2026-09-07T18:23:21.356316+00:00"},{"actual_execution_candidate":"c880acf62944746ff9a376afc0c0050702f037f7","closure_basis":"Actual runner source-manifest transitive Lean closure, runner, specification and pinned Lake configuration.","command":["/usr/bin/python3","scripts/check_typed_kernel_mutations.py","--repo","/home/charl/defiformal","--spec","review/semantic-kernel/sprint4/mutation-spec.json","--out","/tmp/defiformal-sprint9-regressions-p9r8vwrk/typed-mutations"],"cwd":"/home/charl/defiformal","dependency_paths":["lean/DefiKernel/Typed/Acceptance.lean","lean/DefiKernel/Typed/Audit.lean","lean/DefiKernel/Typed/Authority.lean","lean/DefiKernel/Typed/AuthorityTests.lean","lean/DefiKernel/Typed/Examples.lean","lean/DefiKernel/Typed/Expr.lean","lean/DefiKernel/Typed/ExprTests.lean","lean/DefiKernel/Typed/Transition.lean","lean/DefiKernel/Typed/TransitionTests.lean","lean/DefiKernel/Typed/Types.lean","lean/lake-manifest.json","lean/lakefile.toml","lean/lean-toolchain","review/semantic-kernel/sprint4/mutation-spec.json","scripts/check_typed_kernel_mutations.py"],"elapsed_seconds":274.752,"exit":0,"finished_utc":"2026-09-07T18:31:59.772467+00:00","label":"typed-mutations","outcome":{"comparisons_each":189,"mutants_detected":24,"protected_positives_each":3},"started_utc":"2026-09-07T18:27:25.010510+00:00"},{"actual_execution_candidate":"c880acf62944746ff9a376afc0c0050702f037f7","closure_basis":"Actual runner source-manifest transitive Lean closure, runner, specification and pinned Lake configuration.","command":["/usr/bin/python3","scripts/check_composition_mutations.py","--repo","/home/charl/defiformal","--spec","review/semantic-kernel/sprint5/mutation-spec.json","--out","/tmp/defiformal-sprint9-regressions-p9r8vwrk/composition-mutations"],"cwd":"/home/charl/defiformal","dependency_paths":["lean/DefiKernel/Composition/Audit.lean","lean/DefiKernel/Composition/Contracts.lean","lean/DefiKernel/Composition/Examples.lean","lean/DefiKernel/Composition/Execution.lean","lean/DefiKernel/Composition/ExecutionTests.lean","lean/DefiKernel/Composition/InterfaceTests.lean","lean/DefiKernel/Composition/Interfaces.lean","lean/DefiKernel/Composition/Preservation.lean","lean/DefiKernel/Composition/Sequence.lean","lean/DefiKernel/Composition/Tests.lean","lean/DefiKernel/Typed/Authority.lean","lean/DefiKernel/Typed/Examples.lean","lean/DefiKernel/Typed/Expr.lean","lean/DefiKernel/Typed/Transition.lean","lean/DefiKernel/Typed/Types.lean","lean/lake-manifest.json","lean/lakefile.toml","lean/lean-toolchain","review/semantic-kernel/sprint5/mutation-spec.json","scripts/check_composition_mutations.py"],"elapsed_seconds":284.698,"exit":0,"finished_utc":"2026-09-07T18:36:44.589339+00:00","label":"composition-mutations","outcome":{"comparisons_each":93,"mutants_detected":12,"protected_positives_each":6},"started_utc":"2026-09-07T18:31:59.887416+00:00"},{"actual_execution_candidate":"c880acf62944746ff9a376afc0c0050702f037f7","closure_basis":"Actual runner source-manifest transitive Lean closure, runner, specification and pinned Lake configuration.","command":["/usr/bin/python3","scripts/check_parallel_mutations.py","--repo","/home/charl/defiformal","--spec","review/semantic-kernel/sprint6/mutation-spec.json","--out","/tmp/defiformal-sprint9-regressions-p9r8vwrk/parallel-mutations"],"cwd":"/home/charl/defiformal","dependency_paths":["lean/DefiKernel/Composition/Contracts.lean","lean/DefiKernel/Composition/Examples.lean","lean/DefiKernel/Composition/Execution.lean","lean/DefiKernel/Composition/Interfaces.lean","lean/DefiKernel/Composition/Preservation.lean","lean/DefiKernel/Composition/Sequence.lean","lean/DefiKernel/Parallel/Audit.lean","lean/DefiKernel/Parallel/Commutation.lean","lean/DefiKernel/Parallel/Compatibility.lean","lean/DefiKernel/Parallel/CompatibilityTests.lean","lean/DefiKernel/Parallel/Dependency.lean","lean/DefiKernel/Parallel/Dependency/Adapter.lean","lean/DefiKernel/Parallel/Examples.lean","lean/DefiKernel/Parallel/Execution.lean","lean/DefiKernel/Parallel/ExecutionTests.lean","lean/DefiKernel/Parallel/Observation.lean","lean/DefiKernel/Parallel/ObservationTests.lean","lean/DefiKernel/Parallel/Preservation.lean","lean/DefiKernel/Parallel/Tests.lean","lean/DefiKernel/Typed/Authority.lean","lean/DefiKernel/Typed/Examples.lean","lean/DefiKernel/Typed/Expr.lean","lean/DefiKernel/Typed/Transition.lean","lean/DefiKernel/Typed/Types.lean","lean/lake-manifest.json","lean/lakefile.toml","lean/lean-toolchain","review/semantic-kernel/sprint6/mutation-spec.json","scripts/check_parallel_mutations.py"],"elapsed_seconds":338.887,"exit":0,"finished_utc":"2026-09-07T18:39:04.366834+00:00","label":"parallel-mutations","outcome":{"comparisons_each":131,"mutants_detected":14,"protected_positives_each":5},"started_utc":"2026-09-07T18:33:25.477561+00:00"},{"actual_execution_candidate":"c880acf62944746ff9a376afc0c0050702f037f7","closure_basis":"Runner and fixture-generating harness, plus the three copied Lake configuration files; Lean fixture sources are generated by that unchanged harness in isolated repositories.","command":["/usr/bin/python3","scripts/test_composition_mutation_runner.py","--repo","/home/charl/defiformal","--out","/tmp/defiformal-sprint9-regressions-p9r8vwrk/composition-runner-controls"],"cwd":"/home/charl/defiformal","dependency_paths":["lean/lake-manifest.json","lean/lakefile.toml","lean/lean-toolchain","scripts/check_composition_mutations.py","scripts/test_composition_mutation_runner.py"],"elapsed_seconds":62.305,"exit":0,"finished_utc":"2026-09-07T18:37:46.978575+00:00","label":"composition-runner-controls","outcome":{"kind":"actual CLI classifications","passed":36,"total":36},"started_utc":"2026-09-07T18:36:44.671082+00:00"},{"actual_execution_candidate":"c880acf62944746ff9a376afc0c0050702f037f7","closure_basis":"Runner and fixture-generating harness, plus the three copied Lake configuration files; Lean fixture sources are generated by that unchanged harness in isolated repositories.","command":["/usr/bin/python3","scripts/test_typed_kernel_mutation_runner.py","--repo","/home/charl/defiformal","--out","/tmp/defiformal-sprint9-regressions-p9r8vwrk/typed-runner-controls"],"cwd":"/home/charl/defiformal","dependency_paths":["lean/lake-manifest.json","lean/lakefile.toml","lean/lean-toolchain","scripts/check_typed_kernel_mutations.py","scripts/test_typed_kernel_mutation_runner.py"],"elapsed_seconds":43.111,"exit":0,"finished_utc":"2026-09-07T18:37:56.482905+00:00","label":"typed-runner-controls","outcome":{"kind":"actual CLI classifications","passed":17,"total":17},"started_utc":"2026-09-07T18:37:13.370358+00:00"},{"actual_execution_candidate":"c880acf62944746ff9a376afc0c0050702f037f7","closure_basis":"Runner and fixture-generating harness, plus the three copied Lake configuration files; Lean fixture sources are generated by that unchanged harness in isolated repositories.","command":["/usr/bin/python3","scripts/test_parallel_mutation_runner.py","--repo","/home/charl/defiformal","--out","/tmp/defiformal-sprint9-regressions-p9r8vwrk/parallel-runner-controls"],"cwd":"/home/charl/defiformal","dependency_paths":["lean/lake-manifest.json","lean/lakefile.toml","lean/lean-toolchain","scripts/check_parallel_mutations.py","scripts/test_parallel_mutation_runner.py"],"elapsed_seconds":81.03,"exit":0,"finished_utc":"2026-09-07T18:39:08.134239+00:00","label":"parallel-runner-controls","outcome":{"kind":"actual CLI classifications","passed":45,"total":45},"started_utc":"2026-09-07T18:37:47.101578+00:00"},{"actual_execution_candidate":"c880acf62944746ff9a376afc0c0050702f037f7","closure_basis":"Runner and fixture-generating harness, plus the three copied Lake configuration files; Lean fixture sources are generated by that unchanged harness in isolated repositories.","command":["/usr/bin/python3","scripts/test_interleaving_mutation_runner.py","--repo","/home/charl/defiformal","--out","/tmp/defiformal-sprint9-regressions-p9r8vwrk/interleaving-runner-controls"],"cwd":"/home/charl/defiformal","dependency_paths":["lean/lake-manifest.json","lean/lakefile.toml","lean/lean-toolchain","scripts/check_interleaving_mutations.py","scripts/test_interleaving_mutation_runner.py"],"elapsed_seconds":95.426,"exit":0,"finished_utc":"2026-09-07T18:39:32.025956+00:00","label":"interleaving-runner-controls","outcome":{"kind":"actual CLI classifications","passed":52,"total":52},"started_utc":"2026-09-07T18:37:56.598206+00:00"},{"actual_execution_candidate":"c880acf62944746ff9a376afc0c0050702f037f7","closure_basis":"Driver copies only AxiomAudit into a synthetic fixture project; generated probes and imported dependency fixtures are defined by this unchanged driver. Lake configuration included conservatively.","command":["/usr/bin/python3","scripts/test_kernel_axiom_audit.py","--output","/tmp/defiformal-sprint9-regressions-p9r8vwrk/axiom-controls"],"cwd":"/home/charl/defiformal","dependency_paths":["lean/DefiKernel/AxiomAudit.lean","lean/lake-manifest.json","lean/lakefile.toml","lean/lean-toolchain","scripts/test_kernel_axiom_audit.py"],"elapsed_seconds":14.075,"exit":0,"finished_utc":"2026-09-07T18:39:18.517240+00:00","label":"axiom-controls","outcome":{"kind":"audit behavioral controls","passed":99,"total":99},"started_utc":"2026-09-07T18:39:04.440124+00:00"},{"actual_execution_candidate":"c880acf62944746ff9a376afc0c0050702f037f7","closure_basis":"Recorded Types/Expr source inputs, typing driver and pinned Lake configuration. No root or Atomic Audit import.","command":["/usr/bin/python3","scripts/check_typed_kernel_typing.py","--repo","/home/charl/defiformal","--out","/tmp/defiformal-sprint9-regressions-p9r8vwrk/typing-controls"],"cwd":"/home/charl/defiformal","dependency_paths":["lean/DefiKernel/Typed/Expr.lean","lean/DefiKernel/Typed/Types.lean","lean/lake-manifest.json","lean/lakefile.toml","lean/lean-toolchain","scripts/check_typed_kernel_typing.py"],"elapsed_seconds":7.137,"exit":0,"finished_utc":"2026-09-07T18:39:15.401255+00:00","label":"typing-controls","outcome":{"executed_positive":1,"expected_compiler_type_errors":3,"financial_counterexamples":0},"started_utc":"2026-09-07T18:39:08.261580+00:00"},{"actual_execution_candidate":"c880acf62944746ff9a376afc0c0050702f037f7","closure_basis":"CLI/test driver plus all copied lane and normalized-input files, schema and research source plan; synthetic annotations are generated by the unchanged test driver.","command":["/usr/bin/python3","scripts/test_corpus_normalize.py"],"cwd":"/home/charl/defiformal","dependency_paths":["corpus/normalized/corpus.schema.json","corpus/normalized/inputs/annotation-input.json","corpus/normalized/inputs/identity-map.json","corpus/normalized/inputs/source-manifest.json","corpus/normalized/inputs/taxonomy.json","corpus50/lanes/lane1-dex-lending-cdp-lsd.json","corpus50/lanes/lane2-perps-yield-bridges-intents.json","corpus50/lanes/lane3-rwa-options-stables-prediction.json","docs/research/2026-09-06-defi-source-plan.md","scripts/corpus_normalize.py","scripts/test_corpus_normalize.py"],"elapsed_seconds":16.54,"exit":0,"finished_utc":"2026-09-07T18:39:32.028723+00:00","label":"corpus-controls","outcome":{"observed_cli_invocations":76,"tests_passed":20},"started_utc":"2026-09-07T18:39:15.485687+00:00"}],"unique_dependency_hashes":{"corpus/normalized/corpus.schema.json":"2b7e2fb94db8247293bb974465204ba9ed7d8359560238c26ce3ca0dbd860fab","corpus/normalized/inputs/annotation-input.json":"dc36166d26447203ba5af7f12db14f53d4ab1865dcace85955b58e026f3ef8e2","corpus/normalized/inputs/identity-map.json":"6cda8464f7b2effbec57cd6c1a88bb25b9d32a236a38d86707b5518f1e2eecb0","corpus/normalized/inputs/source-manifest.json":"2d9b70729adf7743f0376893220afdc78277f08611f08fa2c2e3170a0b7d3c48","corpus/normalized/inputs/taxonomy.json":"8f854470619216917fef489bb93c62afa8e56da6d1cfc8dd68afc7a46beed681","corpus50/lanes/lane1-dex-lending-cdp-lsd.json":"afaf18d717dbd0ccc4e2909c146943e37ed3dff3c982bcfbc9b4f71f26c23369","corpus50/lanes/lane2-perps-yield-bridges-intents.json":"cca6b4cccd9e75cf70a1e4dcb291562810a7ab22b52071295ce2479af03364f6","corpus50/lanes/lane3-rwa-options-stables-prediction.json":"94195e7144eb707a7cbe34e4adcbaeeb234a572d7ac485e89ed2636059452820","docs/research/2026-09-06-defi-source-plan.md":"c458c6c9e32675afe6a6aa44e6f1a6767d3963accb6d291ec24e6212ecac9975","lean/DefiKernel/Atomic/Audit.lean":"73e592571182e95006db5a57f914ca8f7cbe8de51983ada3cac0de0d046141ff","lean/DefiKernel/Atomic/Examples.lean":"771ce6a4de4a24082bcc75c842ac2db3ac072cc63586cd24aecc86c72b097af4","lean/DefiKernel/Atomic/Execution.lean":"c9cee888746a2795ae2ddae59d9ffb27ed73339ed5a7ca0737be922af6d96b55","lean/DefiKernel/Atomic/Observation.lean":"3e0ab8f53d0bcddc86543207cce4ae832293836e9a301204b090b23d6ccd0cc5","lean/DefiKernel/Atomic/Policy.lean":"5b643cbb1b1263ffacb20892afe3f9ec1067191e733f08c3f4040bbe17fa2612","lean/DefiKernel/Atomic/Tests.lean":"e42ec7aab417fcd03c492fdc19b1d78f5dfdd91df95adbaf33cf8ea05145e5ad","lean/DefiKernel/AxiomAudit.lean":"4a8e330d42e7cd1c46df96ee201923ba2f5d17f37a74b2cb262c318193e72524","lean/DefiKernel/Composition/Audit.lean":"fdd761877de99d376843b96571bfc3e4753a5f357e1ea802acb882c0917720a2","lean/DefiKernel/Composition/Contracts.lean":"d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c","lean/DefiKernel/Composition/Examples.lean":"55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064","lean/DefiKernel/Composition/Execution.lean":"34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602","lean/DefiKernel/Composition/ExecutionTests.lean":"68cd7423cafbb63dfcca0e319381eeac9cf31ee4e9c3fd8459f2ab5f4b98a0c5","lean/DefiKernel/Composition/InterfaceTests.lean":"710777f2112979bbb4cd70624939901a7f1f25756d5cc08027722ca942ae51b3","lean/DefiKernel/Composition/Interfaces.lean":"4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe","lean/DefiKernel/Composition/Preservation.lean":"7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709","lean/DefiKernel/Composition/Sequence.lean":"32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729","lean/DefiKernel/Composition/Tests.lean":"4596621611ffd8aa92d782f4d8688c601bec438414efba45b5335684d2670980","lean/DefiKernel/Interleaving/Audit.lean":"b013810cbbdcc291fcd7c3bb066c71d23eb10b513f126eadc9ef777f53265dde","lean/DefiKernel/Interleaving/Examples.lean":"944421f563bdb3b81a6cf102e72f36396b1cd193b7a1be47b4ced18baff8bb8b","lean/DefiKernel/Interleaving/Execution.lean":"8a39ccbaf6cf03479a5b16a156c52a2b6f5bd97a9198b633be27be3b1b899d21","lean/DefiKernel/Interleaving/Schedule.lean":"a531621726138ef20d1b45edf8c680869a4e35bee4697cfc93d80c250e2b6ad9","lean/DefiKernel/Interleaving/ScheduleTests.lean":"e67ad6d37c49db6ef8f4f19fc805e56f1085b51751763d193556a4eef9286164","lean/DefiKernel/Interleaving/Tests.lean":"b4da589aec6eaf237c8531e6617e39589269af126fefae5e3f1bf560dabe0ec1","lean/DefiKernel/Parallel/Audit.lean":"d6cb7e1c7b948b4404007a50ca30bf5bcf5883bd77c6ce700b229884d4e094b9","lean/DefiKernel/Parallel/Commutation.lean":"c85f69f1bfad39700096c95dbd1450e65eb5f102d4b08a80054f45edf96c52ef","lean/DefiKernel/Parallel/Compatibility.lean":"4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243","lean/DefiKernel/Parallel/CompatibilityTests.lean":"d3a90763fc468c09f8474e18ba95ae0ac6f6750d38d88f4b49d9b72beafc1379","lean/DefiKernel/Parallel/Dependency.lean":"72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245","lean/DefiKernel/Parallel/Dependency/Adapter.lean":"10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c","lean/DefiKernel/Parallel/Examples.lean":"d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd","lean/DefiKernel/Parallel/Execution.lean":"a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089","lean/DefiKernel/Parallel/ExecutionTests.lean":"4b88467004d0392fba8aff169544bbebf586a06c74ca5426a2ca6ab7676ded99","lean/DefiKernel/Parallel/Observation.lean":"38018fbcfb37c08181fbce37b75050077c3dc19d8bee6c0975b7898447ccb84f","lean/DefiKernel/Parallel/ObservationTests.lean":"227c4e8e63bfaa66394e8e5946cea5650787651ed2ea6a42cf63a1edada5864e","lean/DefiKernel/Parallel/Preservation.lean":"faa047bf614306b00cafc7c4b9278df070b9edb9b26f4d655e68af11a182fa10","lean/DefiKernel/Parallel/Tests.lean":"626dadde5519715fc8d92324ac483c8d00c049001313f1257103a004b284f725","lean/DefiKernel/Typed/Acceptance.lean":"4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1","lean/DefiKernel/Typed/Audit.lean":"20ffa1753cf50ef5b60dec0d8bb6950c2b9f623011df23c7c0d8a542aeaeb3c4","lean/DefiKernel/Typed/Authority.lean":"dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb","lean/DefiKernel/Typed/AuthorityTests.lean":"02c7028ade18e53815d436f57fc3c80cd79c06dc585a3e985b1be8dab544ae77","lean/DefiKernel/Typed/Examples.lean":"640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41","lean/DefiKernel/Typed/Expr.lean":"1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed","lean/DefiKernel/Typed/ExprTests.lean":"8fd89353f21e5f3f94f1ed56ae6d1e28d375952b5720ed9e29c177e4a4e88e29","lean/DefiKernel/Typed/Transition.lean":"73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2","lean/DefiKernel/Typed/TransitionTests.lean":"e9d3af4f0d81c9ab76ab20e0440228c30c6dcf54f5e80ccd32117f4c961561bc","lean/DefiKernel/Typed/Types.lean":"5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82","lean/lake-manifest.json":"8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002","lean/lakefile.toml":"4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86","lean/lean-toolchain":"0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6","review/semantic-kernel/sprint4/mutation-spec.json":"be5083e3292646426cc7a4ebd556421e363fd43aa856ddea5263c9d534c4c8eb","review/semantic-kernel/sprint5/mutation-spec.json":"b91a3e491bbd2ddeb3e0e72ee23622a3923db33aa0db5952b14e2831f78d5cb1","review/semantic-kernel/sprint6/mutation-spec.json":"5c5fc372c1547271ea8baaedf7fc60bc79efd10c62458bc8934a3a3554426a35","review/semantic-kernel/sprint7/mutation-spec.json":"c3ad55915dc34be2bf7ad62d8ed34dde2862de4b7b29505cb761623960ec549b","review/semantic-kernel/sprint8/mutation-spec.json":"91b1c2acddcb3542bb377a878177118125735d40d3845b59b0f6f55051a1a4fc","scripts/check_atomic_mutations.py":"ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007","scripts/check_composition_mutations.py":"0c03c093df36cdf64e907ead230a73a25190bc50eccf6670d7259c6fbd64a031","scripts/check_interleaving_mutations.py":"73033e6ee85a7d31255568489076c9ce044967022e40ce07cf8ecae7aa983c14","scripts/check_parallel_mutations.py":"415a92033788a8cfe2e397a3722457c9597610b5001eac0e18ada3d0809dd5d0","scripts/check_typed_kernel_mutations.py":"f988c2a1c10dce1b3b0c13caf92e9de0138c4985fa2fce7f1538ab1ca758dc50","scripts/check_typed_kernel_typing.py":"f85c32ae261c19fe6f7c2253328f7ea4689e942fc8fd91c79e63d2e9bebe7fb6","scripts/corpus_normalize.py":"f7f00d7c80ba11ef80d268910066a47896538c223511f5588009487ecf3f9ecc","scripts/test_atomic_mutation_runner.py":"dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662","scripts/test_composition_mutation_runner.py":"c1a873d376eac77bc0f2c8e4cf2b512c34333fa3c9a674780e70ab996c49e706","scripts/test_corpus_normalize.py":"0c3ef8580a44b81b9d55cd2e9cd03d74580d2ee722d5acd57609f0a94faf278f","scripts/test_interleaving_mutation_runner.py":"74e8e7b7316d4fb5f3614fb0324d2ab62fde0f5d4f6dcc30942aaf4f8fb0d56d","scripts/test_kernel_axiom_audit.py":"b40c73684a40e0cadabf45c29e55e19861614a4e6ba975cacbf8f18d81966c5b","scripts/test_parallel_mutation_runner.py":"14d807f04c36ad61e3de854ab693f29417201e531942bf012e0c5a84b1f9bb79","scripts/test_typed_kernel_mutation_runner.py":"921457f86eba3e0f8e6fec1250a1a0745fd56fb717074d6db61b2bb1cfa8dd93"}},"actual_mutations":{"candidate":"eec499d613688137a341f3556cd80ca461dd2ee9","cases":[{"actual_exit":1,"name":"entry-world-at-seq","observed":{"metatheory.group.world-chain":"false"},"required_false":["metatheory.group.world-chain"]},{"actual_exit":1,"name":"entry-store-at-seq","observed":{"metatheory.group.store-chain":"false"},"required_false":["metatheory.group.store-chain"]},{"actual_exit":1,"name":"reset-history-at-seq","observed":{"metatheory.group.history-chain":"false"},"required_false":["metatheory.group.history-chain"]},{"actual_exit":1,"name":"reset-index-at-seq","observed":{"metatheory.group.index-chain":"false"},"required_false":["metatheory.group.index-chain"]},{"actual_exit":1,"name":"clear-failure-at-seq","observed":{"metatheory.group.refusal-absorption":"false"},"required_false":["metatheory.group.refusal-absorption"]},{"actual_exit":1,"name":"skip-second-child","observed":{"metatheory.group.child-executed":"false"},"required_false":["metatheory.group.child-executed"]},{"actual_exit":1,"name":"reverse-child-order","observed":{"metatheory.group.ordered":"false"},"required_false":["metatheory.group.ordered"]},{"actual_exit":1,"name":"zero-boundary-index","observed":{"metatheory.group.boundary-index":"false"},"required_false":["metatheory.group.boundary-index"]},{"actual_exit":1,"name":"omit-observed-ledger","observed":{"metatheory.observe.world-diff":"false"},"required_false":["metatheory.observe.world-diff"]},{"actual_exit":1,"name":"omit-observed-store","observed":{"metatheory.observe.store-diff":"false"},"required_false":["metatheory.observe.store-diff"]},{"actual_exit":1,"name":"omit-observed-history","observed":{"metatheory.observe.output-diff":"false"},"required_false":["metatheory.observe.output-diff"]},{"actual_exit":1,"name":"omit-observed-failure","observed":{"metatheory.observe.failure-diff":"false"},"required_false":["metatheory.observe.failure-diff"]},{"actual_exit":1,"name":"omit-observed-receipt","observed":{"metatheory.observe.receipt-diff":"false"},"required_false":["metatheory.observe.receipt-diff"]},{"actual_exit":1,"name":"omit-observed-index","observed":{"metatheory.observe.next-index-diff":"false"},"required_false":["metatheory.observe.next-index-diff"]}],"command":["/usr/bin/python3","scripts/check_metatheory_mutations.py","--repo","/home/charl/defiformal","--spec","/home/charl/defiformal/mutations/metatheory.json","--out","/tmp/sprint9-official-production-r2/run","--timeout-seconds","600"],"count":14,"invocation_timing":{"elapsed_seconds":338.473624,"finished_utc":"2026-09-07T18:53:40.709861+00:00","started_utc":"2026-09-07T18:48:02.235989+00:00","status":"FINISHED"},"siblings_scope":"Per-mutant siblings were measured separately; only two global positives are production runner-enforced. See accepted final-acceptance finding R2 and sibling-matrix.json."},"all_checks_passed":true,"authoritative_delivery":{"archive":"openspec/changes/archive/2026-09-07-operational-continuation-congruence","archive_commit":"9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","branch":"semantic-kernel-pivot","main_merged":false,"remote_head":"9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","remote_matches":true,"requirements_preserved":17,"scenarios_preserved":55,"source_candidate":"eec499d613688137a341f3556cd80ca461dd2ee9","source_evidence_commit":"ec9ed80457d7a9c4064d26ab193591579027abae","substantive_reviews":"Native Grok and Fable5.1 medium ACCEPT WITH LIMITATIONS","tasks_complete":35,"verified_utc":"2026-09-07T19:12:22.751477+00:00"},"captured_utc":"2026-09-07T19:18:39.496716+00:00","complete_original":{"bytes":176749,"path":"review/semantic-kernel/sprint10/planning/official-preparation/dependency-baseline.json","sha256":"dc2c5af90e0b4f01a81551de4f9cad61f6658057103a3b3cbddb77e7384f17e1"},"later_checkpoint_remote":{"archive":"9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","head":"c16832941c18229e51fade7c496b16146bb810bd","matches":true,"remote":"c16832941c18229e51fade7c496b16146bb810bd","source":"eec499d613688137a341f3556cd80ca461dd2ee9","verified_utc":"2026-09-07T19:15:30.544093+00:00"},"no_M2_implementation_or_native_review":true,"observed_head":"c16832941c18229e51fade7c496b16146bb810bd","projection":"Mechanical check labels and repeated invocation input metadata omitted; all baseline commands, scope, source/dependency hashes, results and original artifact bindings retained.","reference_artifacts":{"review/semantic-kernel/sprint10/planning/sprint9-checkpoint-remote.json":{"bytes":299,"sha256":"5887d7e91f7c475738751df42e7c65ec0c10160c010b454e6ecf809b6c5c5cb4"},"review/semantic-kernel/sprint9/acceptance/final-acceptance.json":{"bytes":5416,"sha256":"78f0b65492a0936c0fbd5f08daf06ae5ed3d3669654d8796a17cea9623af3bf9"},"review/semantic-kernel/sprint9/acceptance/final-scenarios.json":{"bytes":242986,"sha256":"a3ebd857a6020f4ba7fdcc4d7a4334a0aaa5a82ec91779133534e995207a3745"},"review/semantic-kernel/sprint9/archive-delivery.json":{"bytes":664,"sha256":"66fff02477ab51d4a3f28c1553ee52938dd6f73a8ffebf9929f1c04a06a5a0d8"},"review/semantic-kernel/sprint9/implementation/legacy-dependency-equivalence.json":{"bytes":247833,"sha256":"cd65980e7dad132dad247214e3c65ff650af004308ceb042857fe2a3c01d1027"},"review/semantic-kernel/sprint9/implementation/runner-controls-r2/summary.json":{"bytes":240749,"sha256":"c5020eb52e30abc554fcae9b0899820ce6504fd46c088a69f9461c2f5cb9a6db"},"review/semantic-kernel/sprint9/integration-final-r2/00.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/integration-final-r2/00.stdout.log":{"bytes":1200208,"sha256":"7beeb11f55a98e2f31660b14d79867c733c186c69acd915247c30833134cb7af"},"review/semantic-kernel/sprint9/integration-final-r2/01.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/integration-final-r2/01.stdout.log":{"bytes":6169,"sha256":"5b2cb282ffbeb2831c212fb1c9d4b6a6a0d850497b3f7db006e61f51cfb87b03"},"review/semantic-kernel/sprint9/integration-final-r2/02.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/integration-final-r2/02.stdout.log":{"bytes":91441,"sha256":"7d14a32dcc532fef650ab3ceada4baee53845b0f34787215fd0cf556d83f5dce"},"review/semantic-kernel/sprint9/integration-final-r2/03.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/integration-final-r2/03.stdout.log":{"bytes":5340,"sha256":"e144b01f594a113d995580ba2f1ba9e7c68a0ca05ba0d3d0a22a9fcb20f6f721"},"review/semantic-kernel/sprint9/integration-final-r2/04.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/integration-final-r2/04.stdout.log":{"bytes":121449,"sha256":"85ae2e946af04330a2140084e5c3789d90ce57ef51c04bb3b6fed46f44a6dfbf"},"review/semantic-kernel/sprint9/integration-final-r2/05.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/integration-final-r2/05.stdout.log":{"bytes":5200,"sha256":"025d6cc19c57eb8432a029cf9e4f4d273b838b7d4094063b89b3248dd425a472"},"review/semantic-kernel/sprint9/integration-final-r2/06.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/integration-final-r2/06.stdout.log":{"bytes":85266,"sha256":"47ae28207e443b7c948ead9f6e9dffd188d2d25deea8798bc3c8ccdf262216c1"},"review/semantic-kernel/sprint9/integration-final-r2/07.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/integration-final-r2/07.stdout.log":{"bytes":5375,"sha256":"b8d41e3bab4a6ae65dd3632d85c514421076d6fc6d6f1d5c3a7989965b0368e9"},"review/semantic-kernel/sprint9/integration-final-r2/08.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/integration-final-r2/08.stdout.log":{"bytes":120587,"sha256":"82e4c2c957323dde95640e783c7306a124e9627f96a97a1785ccc9c1fe2c9eaf"},"review/semantic-kernel/sprint9/integration-final-r2/09.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/integration-final-r2/09.stdout.log":{"bytes":3010,"sha256":"9173b87109f8c6c3f6afae01958f1480d84a8ec42cd34429f56aa077b1a89368"},"review/semantic-kernel/sprint9/integration-final-r2/10.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/integration-final-r2/10.stdout.log":{"bytes":132450,"sha256":"56e39dbb1623f32c71599b0a70c3a9b7752319ccacadac71b2ac95565ef31fe0"},"review/semantic-kernel/sprint9/integration-final-r2/11.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/integration-final-r2/11.stdout.log":{"bytes":6957,"sha256":"19ecc53feba3fbe993b6f2fed294efb170716f6b5a555a4d34bd1bad7f05af1e"},"review/semantic-kernel/sprint9/integration-final-r2/12.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/integration-final-r2/12.stdout.log":{"bytes":193632,"sha256":"0fd188b353c6f014bebb5baaf53447f2660a07619fe2236eca91e9eaa5d24790"},"review/semantic-kernel/sprint9/integration-final-r2/13.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/integration-final-r2/13.stdout.log":{"bytes":5822,"sha256":"61819efaae5d9062231e6dd3e126b3ce93cfb225cdbbdc8498d630f568cbbe63"},"review/semantic-kernel/sprint9/integration-final-r2/14.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/integration-final-r2/14.stdout.log":{"bytes":1364,"sha256":"660f556e96037016023e457e37f692acf9e3ff0f16072fcc271511537494e438"},"review/semantic-kernel/sprint9/integration-final-r2/15.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/integration-final-r2/15.stdout.log":{"bytes":69846,"sha256":"4fe1669dcec9ff26f7626f3a2125aea61719fe3b8c25e8eff385457b54553c8f"},"review/semantic-kernel/sprint9/integration-final-r2/lean-runs.json":{"bytes":12083,"sha256":"96a2330ac1638cb0c4d80fa2448ea5b2c84f35a86832ea973df81caaea3722e3"},"review/semantic-kernel/sprint9/integration-final-r2/source-after.json":{"bytes":17493,"sha256":"3183c7d268875e43e13f9a6ebb18f78f5081e806feacd614475e5d319c197713"},"review/semantic-kernel/sprint9/integration-final-r2/source-before.json":{"bytes":17493,"sha256":"3183c7d268875e43e13f9a6ebb18f78f5081e806feacd614475e5d319c197713"},"review/semantic-kernel/sprint9/integration-final-r2/verification.json":{"bytes":1794,"sha256":"2c0b3b252ea9585c63230b3bff53387299d3f664c3f72886965a063296dcaaae"},"review/semantic-kernel/sprint9/mutations-r2/final-manifest.json":{"bytes":21642,"sha256":"a588753b7d23d727b518091f59f97838836cd988552d88037d0c5d833b00965b"},"review/semantic-kernel/sprint9/mutations-r2/results.json":{"bytes":142198,"sha256":"8376edfad2c531812e13ff75db8da125ea273b326edf0c43bd27e30e5ef28805"},"review/semantic-kernel/sprint9/mutations-r2/sibling-matrix.json":{"bytes":5125,"sha256":"fff461cd8284dbb8003d27f6ba4f2cb62c543e94ba7a86ca3c8c2e2ce745b0bc"},"review/semantic-kernel/sprint9/mutations-r2/summary.json":{"bytes":42783,"sha256":"33df1ba7a4fcbb22927c686b9950f23a3bf2ab306b6a07d4a1ca9142e7128289"},"review/semantic-kernel/sprint9/native-review-r2-compact/final-fable.invocation.json":{"bytes":1370,"sha256":"fcf45a4008b85c8efdc6d7f5b6a61271b37bc9cbcb008f4679f570b5cf770991"},"review/semantic-kernel/sprint9/native-review-r2-compact/final-fable.md":{"bytes":6896,"sha256":"0c3ee50c4dc39ecdaf6ed3a11e013288a9dcb726f98da5f76a4b9d01aaaf00b1"},"review/semantic-kernel/sprint9/native-review-r2/final-grok.invocation.json":{"bytes":1310,"sha256":"c9db7c8d280654ec4d673713960ccfdaf1bf23239f03038b7b87bfb750135d7b"},"review/semantic-kernel/sprint9/native-review-r2/final-grok.md":{"bytes":12764,"sha256":"c6000606de401b3d4200789f082fc660492e8c4e4063ae9b757d79572b6761f7"},"review/semantic-kernel/sprint9/regressions/atomic-mutations.log":{"bytes":8326,"sha256":"f186ca6290e96f0a95a7181970861bfe4500679079f8ce321c6ca6f621fe6db0"},"review/semantic-kernel/sprint9/regressions/atomic-mutations.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/regressions/atomic-mutations.stdout.log":{"bytes":8326,"sha256":"f186ca6290e96f0a95a7181970861bfe4500679079f8ce321c6ca6f621fe6db0"},"review/semantic-kernel/sprint9/regressions/atomic-mutations/source-manifest.json":{"bytes":27153,"sha256":"cccbb020e471d92db405bd807ebacad3a8a0e93cb0c7aef2feb8c442016eda8c"},"review/semantic-kernel/sprint9/regressions/atomic-runner-controls.log":{"bytes":3584,"sha256":"883dd904598dfad051c0d84505e94fed2b6d399c99996c213814e9c03dff4c75"},"review/semantic-kernel/sprint9/regressions/atomic-runner-controls.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/regressions/atomic-runner-controls.stdout.log":{"bytes":3584,"sha256":"883dd904598dfad051c0d84505e94fed2b6d399c99996c213814e9c03dff4c75"},"review/semantic-kernel/sprint9/regressions/atomic-runner-controls/summary.json":{"bytes":260458,"sha256":"755d2aa455319851390bd843cc6d5ad329f02b8bd71803506f0d0754a48b8664"},"review/semantic-kernel/sprint9/regressions/axiom-controls.log":{"bytes":92,"sha256":"7cc0e3212cd6c0e02831c72c0d8799054778772758abaf079a62a2084cc984af"},"review/semantic-kernel/sprint9/regressions/axiom-controls.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/regressions/axiom-controls.stdout.log":{"bytes":92,"sha256":"7cc0e3212cd6c0e02831c72c0d8799054778772758abaf079a62a2084cc984af"},"review/semantic-kernel/sprint9/regressions/composition-mutations.log":{"bytes":3830,"sha256":"6fa309f13e98c7abe744ac6277949144edbf5bad002feeba52330501c27dfc52"},"review/semantic-kernel/sprint9/regressions/composition-mutations.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/regressions/composition-mutations.stdout.log":{"bytes":3830,"sha256":"6fa309f13e98c7abe744ac6277949144edbf5bad002feeba52330501c27dfc52"},"review/semantic-kernel/sprint9/regressions/composition-mutations/source-manifest.json":{"bytes":5351,"sha256":"19bd91ef8b9dcf80ecaec21c3ca6f9cbf8a4cc0ea11bd2e22b0fc74fce74d577"},"review/semantic-kernel/sprint9/regressions/composition-runner-controls.log":{"bytes":1893,"sha256":"b44578903f555fd4ee6aac4c653c74b754e6ab3beae1f2a4b93853794a78c91a"},"review/semantic-kernel/sprint9/regressions/composition-runner-controls.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/regressions/composition-runner-controls.stdout.log":{"bytes":1893,"sha256":"b44578903f555fd4ee6aac4c653c74b754e6ab3beae1f2a4b93853794a78c91a"},"review/semantic-kernel/sprint9/regressions/composition-runner-controls/summary.json":{"bytes":101372,"sha256":"c4bde1a928521f2416907b9ec991481df73f703f3771d758fd82844d9857b6b4"},"review/semantic-kernel/sprint9/regressions/corpus-controls.log":{"bytes":13444,"sha256":"32c1ba390e6b43778f1be1687bc4a250080e38c69ce92676116a5ad3dc252900"},"review/semantic-kernel/sprint9/regressions/corpus-controls.stderr.log":{"bytes":2142,"sha256":"2a5343c5606c74ed83ab643c506adfe2cf5a48454ccf26121c30a1a01c9f8e5e"},"review/semantic-kernel/sprint9/regressions/corpus-controls.stdout.log":{"bytes":11302,"sha256":"5181afa0fefaf1a14295fe2db17a30dba5fc2ea48bf35d7c4af0e2b0577f5049"},"review/semantic-kernel/sprint9/regressions/interleaving-mutations.log":{"bytes":11293,"sha256":"a05562b72ea0556baf3f321a3f89390571d5d0c05d2a88ad2dec903d5a1d5956"},"review/semantic-kernel/sprint9/regressions/interleaving-mutations.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/regressions/interleaving-mutations.stdout.log":{"bytes":11293,"sha256":"a05562b72ea0556baf3f321a3f89390571d5d0c05d2a88ad2dec903d5a1d5956"},"review/semantic-kernel/sprint9/regressions/interleaving-mutations/source-manifest.json":{"bytes":24434,"sha256":"1e3974ebf395dd13f3540e35d02db984facf225b8bd4ba4c5aa90c63e2f97179"},"review/semantic-kernel/sprint9/regressions/interleaving-runner-controls.log":{"bytes":2777,"sha256":"2a3f50ec6d07a1a2e2aa266932322484ff1b456d0ace5b89e5a70fccac8c6ea3"},"review/semantic-kernel/sprint9/regressions/interleaving-runner-controls.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/regressions/interleaving-runner-controls.stdout.log":{"bytes":2777,"sha256":"2a3f50ec6d07a1a2e2aa266932322484ff1b456d0ace5b89e5a70fccac8c6ea3"},"review/semantic-kernel/sprint9/regressions/interleaving-runner-controls/summary.json":{"bytes":215428,"sha256":"11b595c8452b88f37d850d375e0ab737e52c3802dafca0113c30c8a02881033c"},"review/semantic-kernel/sprint9/regressions/parallel-mutations.log":{"bytes":6769,"sha256":"bf64f0ef129c6c012aee0da0243ff00bdd1feab3b308d489353e66cf696332e2"},"review/semantic-kernel/sprint9/regressions/parallel-mutations.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/regressions/parallel-mutations.stdout.log":{"bytes":6769,"sha256":"bf64f0ef129c6c012aee0da0243ff00bdd1feab3b308d489353e66cf696332e2"},"review/semantic-kernel/sprint9/regressions/parallel-mutations/source-manifest.json":{"bytes":8203,"sha256":"caa657d85bb06d9aa80a27c01933b0b0d827ba0caca7ec86ba9345e69c248f89"},"review/semantic-kernel/sprint9/regressions/parallel-runner-controls.log":{"bytes":2379,"sha256":"128b5b71589f962178c5ecef2e7abb16faa01d35eaf4e41d7b92d5b0531b1088"},"review/semantic-kernel/sprint9/regressions/parallel-runner-controls.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/regressions/parallel-runner-controls.stdout.log":{"bytes":2379,"sha256":"128b5b71589f962178c5ecef2e7abb16faa01d35eaf4e41d7b92d5b0531b1088"},"review/semantic-kernel/sprint9/regressions/parallel-runner-controls/summary.json":{"bytes":133959,"sha256":"c6b3fc02e446ba8655bfa39b8df834c54ab4e5c207ece883f07e8515fbec0e76"},"review/semantic-kernel/sprint9/regressions/regression-runs.json":{"bytes":23378,"sha256":"7ab2e8bce60cafdbf8e5cd3af7d437048d56e7859a2a000c95c5e323f8e34fdd"},"review/semantic-kernel/sprint9/regressions/typed-mutations.log":{"bytes":6330,"sha256":"2d56d604d6d4df57392c00a8cd6535667055f5c7c35d7975eb66f40f94f5835d"},"review/semantic-kernel/sprint9/regressions/typed-mutations.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/regressions/typed-mutations.stdout.log":{"bytes":6330,"sha256":"2d56d604d6d4df57392c00a8cd6535667055f5c7c35d7975eb66f40f94f5835d"},"review/semantic-kernel/sprint9/regressions/typed-mutations/source-manifest.json":{"bytes":3462,"sha256":"1ccd1728d2db06d23ac6e0c8c32ee736ffb247fa188071963ea0d5786e890906"},"review/semantic-kernel/sprint9/regressions/typed-runner-controls.log":{"bytes":918,"sha256":"a4530380c6358f479458f4ffe7ddfd8397bb71467ea15d738d5473012318951e"},"review/semantic-kernel/sprint9/regressions/typed-runner-controls.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/regressions/typed-runner-controls.stdout.log":{"bytes":918,"sha256":"a4530380c6358f479458f4ffe7ddfd8397bb71467ea15d738d5473012318951e"},"review/semantic-kernel/sprint9/regressions/typed-runner-controls/summary.json":{"bytes":47575,"sha256":"04b484de7edd7a7abb9141e13e7a2a46acc93de7152cea96c5d79c031f4e485b"},"review/semantic-kernel/sprint9/regressions/typing-controls.log":{"bytes":206,"sha256":"2027d5c02b996a23b761513b8878236da2d276437870bc5b15f84fb1f1dbc02e"},"review/semantic-kernel/sprint9/regressions/typing-controls.stderr.log":{"bytes":0,"sha256":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"},"review/semantic-kernel/sprint9/regressions/typing-controls.stdout.log":{"bytes":206,"sha256":"2027d5c02b996a23b761513b8878236da2d276437870bc5b15f84fb1f1dbc02e"},"review/semantic-kernel/sprint9/regressions/typing-controls/results.json":{"bytes":2640,"sha256":"2d1df2f7564e2db922a80d74c9af59a13927c826d399d69fa49de1f45efa4b6d"},"review/semantic-kernel/sprint9/regressions/verified-outcomes.json":{"bytes":439157,"sha256":"164f664c3662504308088154869dc85eb46e2d92e7ea185b8d325858ee2a988a"}},"source_bindings":[{"bytes":427,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"6dacf77ca24a1a2a99dc974d16c53408e8b32058","path":"lean/.github/workflows/create-release.yml","sha256":"491f1c02bb31774c3f711155a4cc24da5923dc8ba7016e9aaff13969e2ea49ca"},{"bytes":487,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"db09247d95896bc768f71e39b47b2e2f192c5cdd","path":"lean/.github/workflows/lean_action_ci.yml","sha256":"3b0d49449c2e6d4ee04ce6e57c23dde1a836314b502351f1f6203477e2aafe8f"},{"bytes":1950,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"96b7622a72a1c6d92e3927a2f494656c0797fc00","path":"lean/.github/workflows/update.yml","sha256":"608304be502130030682762aa4a9bbec3e127d6b1eb2acf054818b84b6c81a4f"},{"bytes":7,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"bfb30ec8c762cc74d4ee1593ab48fc091d04ca4c","path":"lean/.gitignore","sha256":"b3ad09fc93f83fdbd0bee771258dd4a58d3798fd7e6048611dde5a804bb43f1e"},{"bytes":2206,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"e31c78aa4279eef5cd7dac3e79322f0bfdb0a280","path":"lean/Axioms.lean","sha256":"9760f52b1b2ce51df70abd6010b30cf1be6c761ffcdb5192b6eacdb810c02b52"},{"bytes":327,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"6970b74249eee4d677d9f867bf59cdc6f471c3e3","path":"lean/DefiKernel.lean","sha256":"cab319466baac88539dbc31f29465cee64a828176399981fd56fab8b3d72732b"},{"bytes":6596,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"978ef09075c68a44c1ccbc06c3634372e0dfbbf4","path":"lean/DefiKernel/Acceptance.lean","sha256":"9635558b7bb16a66375358a4936ec73d7ea4b07ee959bf3d2583197584e7ff11"},{"bytes":2782,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"0e9d70118d15ac584aa03d2b4f9df26152f9214e","path":"lean/DefiKernel/Atomic/Admission.lean","sha256":"e41a34eee617720bbb443253189eafa7934ef6e1603fb197aee6961d84535360"},{"bytes":612,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"abb576deb7e2c7976bbf34c82a997ec65dd83c95","path":"lean/DefiKernel/Atomic/Audit.lean","sha256":"73e592571182e95006db5a57f914ca8f7cbe8de51983ada3cac0de0d046141ff"},{"bytes":5174,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"d67a0f51eebb70fbbe7e0f22bb5f18bc2b664815","path":"lean/DefiKernel/Atomic/Completion.lean","sha256":"4118076759416087e20ff9093fbe47c7342e72cf7648828cfd492166bcf07646"},{"bytes":11135,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"a4e0680cdc1840703bcc2531f50666c8b650f843","path":"lean/DefiKernel/Atomic/Correspondence.lean","sha256":"8464d1eb548fa8e028144118579db317d0f667ae3761cf4c40fad393503c46f2"},{"bytes":11971,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"4aeb223c62e3ac8b695492294956cd32f51d651c","path":"lean/DefiKernel/Atomic/Examples.lean","sha256":"771ce6a4de4a24082bcc75c842ac2db3ac072cc63586cd24aecc86c72b097af4"},{"bytes":7650,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"63fbf541b26b660ac5e7daeb96c296ce952287a5","path":"lean/DefiKernel/Atomic/Execution.lean","sha256":"c9cee888746a2795ae2ddae59d9ffb27ed73339ed5a7ca0737be922af6d96b55"},{"bytes":6103,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"4d36fede7f566665a4f3e780cf54c18f246a5e15","path":"lean/DefiKernel/Atomic/InvariantFixtures.lean","sha256":"616b1bdb47670b8049f5495287be9c694f71d765c2408091a7e11977430e1b0a"},{"bytes":4428,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"f6f5ed78b2a3f01da5a22ddcae2d4eaadc8fd67b","path":"lean/DefiKernel/Atomic/Observation.lean","sha256":"3e0ab8f53d0bcddc86543207cce4ae832293836e9a301204b090b23d6ccd0cc5"},{"bytes":3951,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"b036e4b4845de910f98d6cb4cb76d9911e78fcec","path":"lean/DefiKernel/Atomic/Policy.lean","sha256":"5b643cbb1b1263ffacb20892afe3f9ec1067191e733f08c3f4040bbe17fa2612"},{"bytes":12488,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"757d3ea5e8589161aa8e242c5473c1cbd0bcbbc2","path":"lean/DefiKernel/Atomic/PolicyProofs.lean","sha256":"9eb5f5fe51692a44860fc27abb2ac2e7196ceb63ba61bb9a416af2cede544ab6"},{"bytes":10622,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"c82f6a8300ae3c6594da2f3d38e1bd74b6e1e7e8","path":"lean/DefiKernel/Atomic/Preservation.lean","sha256":"1ac0a654964cb11c7c810651831e16d253bb0e875c1f693b4bdb2f735d2b9a6c"},{"bytes":10199,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"774b02bd2f5b958bd8175b6e486ef66a4cbfd2de","path":"lean/DefiKernel/Atomic/Settlement.lean","sha256":"c27cf9eebfce49357e14c963ab2c0ec4a920b3e26d700f85ad8d51cbb6315ca5"},{"bytes":11062,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"a4686f325f18d834b71b0992f72df6b05246b1b0","path":"lean/DefiKernel/Atomic/Soundness.lean","sha256":"4f47288077a5a12ac51efa428ea1e39fa145a3bcffa0f3d04906cc030dc2bb1d"},{"bytes":33785,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"552d2067597569ff7a0a1ff76f20eda30b572485","path":"lean/DefiKernel/Atomic/Tests.lean","sha256":"e42ec7aab417fcd03c492fdc19b1d78f5dfdd91df95adbaf33cf8ea05145e5ad"},{"bytes":579,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"d4e968f9f477290f4600da03d2c3d414e785968a","path":"lean/DefiKernel/Atomic/Verify.lean","sha256":"f933cff484cbc18d92c463acb717c24f9f82ce960cf3c210a97448abe8548cf4"},{"bytes":7359,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"bff33183a90008697f35dd1636ccaa8382c35004","path":"lean/DefiKernel/Audit.lean","sha256":"7843c62e722e2c218e44c532d0f850f66c7ab7eed18715bc5a03dc773b17d400"},{"bytes":4374,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"32032f9638d0f934ebfa9b4b6de6c475d8b4237d","path":"lean/DefiKernel/AxiomAudit.lean","sha256":"4a8e330d42e7cd1c46df96ee201923ba2f5d17f37a74b2cb262c318193e72524"},{"bytes":970,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"7f350e3b451bda3bb0ed5b1daafb02cd727318fe","path":"lean/DefiKernel/Composition/Audit.lean","sha256":"fdd761877de99d376843b96571bfc3e4753a5f357e1ea802acb882c0917720a2"},{"bytes":3446,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"a1f8cf7753180fdea9ae0f8095fae1e0d2ec792e","path":"lean/DefiKernel/Composition/Contracts.lean","sha256":"d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c"},{"bytes":7884,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"4b4cefb9a7cd81d906d668d69ef63501715abe65","path":"lean/DefiKernel/Composition/Examples.lean","sha256":"55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064"},{"bytes":21579,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"f94f22503551dc7cbc965459626a33435ac512cc","path":"lean/DefiKernel/Composition/Execution.lean","sha256":"34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602"},{"bytes":4174,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"7b0110bfc51e21d232cf5fe0f2e7512a7cd2447e","path":"lean/DefiKernel/Composition/ExecutionTests.lean","sha256":"68cd7423cafbb63dfcca0e319381eeac9cf31ee4e9c3fd8459f2ab5f4b98a0c5"},{"bytes":9444,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"1e0965bb3e7c1f72274fba529cc93bec5cb770e5","path":"lean/DefiKernel/Composition/InterfaceTests.lean","sha256":"710777f2112979bbb4cd70624939901a7f1f25756d5cc08027722ca942ae51b3"},{"bytes":12415,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"a45abc9035cd5882f58814c089ce151f0f2bbc51","path":"lean/DefiKernel/Composition/Interfaces.lean","sha256":"4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe"},{"bytes":10344,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"21eb3370867603b6d58c247f78840984dca0dbc6","path":"lean/DefiKernel/Composition/Preservation.lean","sha256":"7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709"},{"bytes":10173,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"ffdfd5b29d8123c2f49cc2262fc199100794074f","path":"lean/DefiKernel/Composition/Sequence.lean","sha256":"32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729"},{"bytes":15733,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"4eb52aa5c35b8c721c4794dd0a1fef468dd8d337","path":"lean/DefiKernel/Composition/Tests.lean","sha256":"4596621611ffd8aa92d782f4d8688c601bec438414efba45b5335684d2670980"},{"bytes":286,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"ec4088ec49455959ad1e2604467f226e69e25998","path":"lean/DefiKernel/Composition/Verify.lean","sha256":"0510c92489398990f07a614f5d8d9228db05220fcf66297afe8a20cb078a4fdb"},{"bytes":9188,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"43f6c23dd54e31ec1b5d9507e602925a47f9f495","path":"lean/DefiKernel/ContractAcceptance.lean","sha256":"a9dfe9006ea32d590f021fa4b3d1c76411ecc872ee524c40ccf2c1406779828f"},{"bytes":9188,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"6e5dea522b2ccb085224c97c28a9d69bccb384fc","path":"lean/DefiKernel/ContractAudit.lean","sha256":"600761fd4f41f112218ea3ab9b74062369c28ef9cf483627b57589b8be7159d9"},{"bytes":6946,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"ff27352bdc1474f7011eaed4a3e42d6510417a6d","path":"lean/DefiKernel/ContractExamples.lean","sha256":"4423c79ae828489f07d5e1a2db93285a6c30b56912b467df40767026f2e0e51b"},{"bytes":4211,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"34b7ee3c5947b497803cc5e1e1b3898c4f33ace0","path":"lean/DefiKernel/Contracts.lean","sha256":"22ec064df455f9472d7c48b956d27f700fc54862f1d7f0bb0acb1051b84e84b2"},{"bytes":8188,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"c3d3c6d6e4ef9c24416e47928088a1889cf66e76","path":"lean/DefiKernel/Core.lean","sha256":"767395925f09eeb65929c323182900c4cb962d0c117d0bb6e5871dfb39fc024d"},{"bytes":8657,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"6e9aa73f63e9b360e322a2760cdabbc2689e74d2","path":"lean/DefiKernel/Examples.lean","sha256":"3a3eaf5e43e5a98cb179785789e850d333652a60f112cba9b0df5ce80bf26d28"},{"bytes":852,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"ffc8191ed93942b2cb8f5d97e52795b8fb5df9ed","path":"lean/DefiKernel/Interleaving/Audit.lean","sha256":"b013810cbbdcc291fcd7c3bb066c71d23eb10b513f126eadc9ef777f53265dde"},{"bytes":3305,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"8253da122fa308728ca47287120dfde02d5865bf","path":"lean/DefiKernel/Interleaving/Completion.lean","sha256":"5b3974e55b1893af07a967319f6f3ef680c9e15ed59bd06508817be756382321"},{"bytes":7462,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"a19a9be20b4517ec7711e9197bbe74cb6e51c6bf","path":"lean/DefiKernel/Interleaving/Examples.lean","sha256":"944421f563bdb3b81a6cf102e72f36396b1cd193b7a1be47b4ced18baff8bb8b"},{"bytes":7949,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"3b37ded4a3fd02b4283ed7d0a9ad7e9ccbde81c3","path":"lean/DefiKernel/Interleaving/Execution.lean","sha256":"8a39ccbaf6cf03479a5b16a156c52a2b6f5bd97a9198b633be27be3b1b899d21"},{"bytes":4623,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"b88923fb3c99e71389b64f7648edcd78b5f18d1a","path":"lean/DefiKernel/Interleaving/Interference.lean","sha256":"e6bc0a1ffbceebb27973d547f2d3b808bc15d6c857e03644c9fa5eeb54ecef90"},{"bytes":9362,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"f27f2448c4a2067348952ca345a3c2f1000f1255","path":"lean/DefiKernel/Interleaving/InterferenceFixtures.lean","sha256":"1a08de17a3632aec84ae079f8b9e8145683c009d22b5217695a788b3c7dcfbd0"},{"bytes":3045,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"2048bc81a0efdff2cde2820f4f76176926322b13","path":"lean/DefiKernel/Interleaving/LocalOrder.lean","sha256":"e81054de5ae998516bf0f9a3b9a0ce30ae24a41626b4f3b2c279571f663223be"},{"bytes":11820,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"3491a9f3cd4afecfd247bf85ecfcad932c70c4c1","path":"lean/DefiKernel/Interleaving/Preservation.lean","sha256":"21199129e97d64bfcdb75c9a860d2263e069f71f59989299c5f8feca62233b2c"},{"bytes":9658,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"640bfa190c3e1b43bf7a35c2f56f18102aa76441","path":"lean/DefiKernel/Interleaving/Recovery.lean","sha256":"1136c80fe5eb6cb3f5c6092472fba811d41b4d9e958304af7d15ae710ae6001a"},{"bytes":3902,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"a546f9e7fc8437955e05c86989049291d2f301b8","path":"lean/DefiKernel/Interleaving/Recovery/Reference.lean","sha256":"a304f76bcf0d9b232078aa83fa37c4ee4d646e1973595a0b13a439b3502c330d"},{"bytes":6199,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"a4f31743111a39dc37f49269d7ce36890da27573","path":"lean/DefiKernel/Interleaving/Recovery/Simulation.lean","sha256":"a9f07c49ecb3dff4535f7c08d5f9c7f125985e92bb71b128527bcb351433a5cf"},{"bytes":6461,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"70b741206d9ea8f3d27d7bc1f4fca3173708b345","path":"lean/DefiKernel/Interleaving/Recovery/Step.lean","sha256":"2af63b55017f8211339d85972e27b0052609028c3519f3b4da90a530a9271081"},{"bytes":8919,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"a8ceaef13afa02392c5a04fc8a05bfa818a49ed3","path":"lean/DefiKernel/Interleaving/Schedule.lean","sha256":"a531621726138ef20d1b45edf8c680869a4e35bee4697cfc93d80c250e2b6ad9"},{"bytes":4175,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"4facbb47ed8afaeb2785e134415b7781cc58c48a","path":"lean/DefiKernel/Interleaving/ScheduleTests.lean","sha256":"e67ad6d37c49db6ef8f4f19fc805e56f1085b51751763d193556a4eef9286164"},{"bytes":10494,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"8b77292fef0f3c0a1d127099151b8eff01573ec9","path":"lean/DefiKernel/Interleaving/Soundness.lean","sha256":"f696f995190cd7a6729e536efe1cc7875239625de1070d830c0649061e432337"},{"bytes":12986,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"2686464c8344b7f23e495f50d28b64cbf19c3fb6","path":"lean/DefiKernel/Interleaving/Tests.lean","sha256":"b4da589aec6eaf237c8531e6617e39589269af126fefae5e3f1bf560dabe0ec1"},{"bytes":8404,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"ce296fb1ea423be233e1b0ff402d2d067cb988df","path":"lean/DefiKernel/Interleaving/Trace.lean","sha256":"566c89b6b0b9b203daa6458d4a3caeaea998d3ffbddfc63c22f72153320d9ac5"},{"bytes":537,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"1454d72af623986d07a5d1eb862b59707b51178e","path":"lean/DefiKernel/Interleaving/Verify.lean","sha256":"515bf03510ac00f2f3515f712e56b2159b287c8692eceab62a1d6a9f3eaf0164"},{"bytes":636,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"aeec524ea302e7af5d93b3ecfc49101b80ea32c1","path":"lean/DefiKernel/Metatheory/Audit.lean","sha256":"e9a7907a2e9f85427f15d22559a87322f31a5646c8b79d2148944f313aeb8d7a"},{"bytes":12353,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"22f604bb3358d5ca6ee9a121fd5204381ab2c0bb","path":"lean/DefiKernel/Metatheory/Configuration.lean","sha256":"d5bc155b46922606f765b2e9cd80b5d33d4b542b8cd6a39a3cb790f87776dce5"},{"bytes":9816,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"6f2d6c78ed9866d07391672829a9f2181afd56f3","path":"lean/DefiKernel/Metatheory/ConfigurationFixtures.lean","sha256":"27c90bf498c63ebae4f583c2ba7f90b1221d6e3bc2b572fef8cd97d827b2a52e"},{"bytes":2338,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"f71b88fc77199692f310d9aa3d3fbbc06852d43e","path":"lean/DefiKernel/Metatheory/ConfigurationGroups.lean","sha256":"04b7f23b0b74b30f0010d59e716f3aead7884f2d8ac9b9885a5143be0fe4fe31"},{"bytes":4009,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"9d1da108d26dbadc8a60a1f86e08aff55f4fa05a","path":"lean/DefiKernel/Metatheory/Contexts.lean","sha256":"6c0539645086ffe51e3668621ca7fa08d7937b6d590c3d9b3c6c649c79eac743"},{"bytes":12780,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"b27e943da58e9121a25278eee5e5b95f8a89b3a3","path":"lean/DefiKernel/Metatheory/Examples.lean","sha256":"9474fefb56e4120ae8537d137a94a1bd6518612e654874794b27c1a8c770a8a9"},{"bytes":7070,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"b8e1120d87dbf83a93fe157b495a51d48718d3ea","path":"lean/DefiKernel/Metatheory/Observation.lean","sha256":"6ceedf99d806d8510fb609c94b2be2d8250c7453e12453d4ed11756d6238553b"},{"bytes":13878,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"1135755d2fa9b6321e4ae70f56c45f6766bf9ca1","path":"lean/DefiKernel/Metatheory/OperatorFixtures.lean","sha256":"69456da74dca26781a1c399702cdec205dbe5001844885b98b046dbe5260d51d"},{"bytes":12068,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"924c01901471ac9bbb37f69b2bdd6df64f2b200c","path":"lean/DefiKernel/Metatheory/OperatorLifting.lean","sha256":"5def40dbdc48471166e921e987845b425f5a739cc7dc883422e2b13e535e2dee"},{"bytes":3419,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"e4f8fb88a1dbc394c6ab33f9e5971cd33b17865d","path":"lean/DefiKernel/Metatheory/SequentialGroups.lean","sha256":"935174d28f898520f6f81f1643a9b5c8ed708f3b32c10d620febe173d015fea7"},{"bytes":22752,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"fc66fdd58f04ef400af0093e9394de83670e2abb","path":"lean/DefiKernel/Metatheory/Tests.lean","sha256":"60b1890c1858ca68e4da3c74f6261facee639ca5c230b522dbd0a6f241f1b730"},{"bytes":508,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"ceabcbaa7495f42ae632220b55dbc8eb62409501","path":"lean/DefiKernel/Metatheory/Verify.lean","sha256":"9b692dc6b08b796676d38e6f12799995c13aeef55d5106c6b31145b4f0c030fb"},{"bytes":943,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"80aa6163078b0e09428e58defd550c0caad3354e","path":"lean/DefiKernel/Parallel/Audit.lean","sha256":"d6cb7e1c7b948b4404007a50ca30bf5bcf5883bd77c6ce700b229884d4e094b9"},{"bytes":17707,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"515d2bfcb0e68d260400e4fde3b25e6d31c09bea","path":"lean/DefiKernel/Parallel/Commutation.lean","sha256":"c85f69f1bfad39700096c95dbd1450e65eb5f102d4b08a80054f45edf96c52ef"},{"bytes":14677,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"db305a859e7cf155b991f20915051f41e289a2fc","path":"lean/DefiKernel/Parallel/Compatibility.lean","sha256":"4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243"},{"bytes":11226,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"df6ee4ee99d81efaad2746d4eaf4570653020f98","path":"lean/DefiKernel/Parallel/CompatibilityTests.lean","sha256":"d3a90763fc468c09f8474e18ba95ae0ac6f6750d38d88f4b49d9b72beafc1379"},{"bytes":13489,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"c913104b1cee20f63fa347a7c53e234e7271df4b","path":"lean/DefiKernel/Parallel/Dependency.lean","sha256":"72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245"},{"bytes":9887,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"d82321a5b05e3a7a6dcc9249a990b636ccd1bc6d","path":"lean/DefiKernel/Parallel/Dependency/Adapter.lean","sha256":"10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c"},{"bytes":6108,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"e3f985049d367769d135cb4b03afa2632a09bc15","path":"lean/DefiKernel/Parallel/Dependency/Fixtures.lean","sha256":"14bac7bfdc273c9de0d416e4489f6d16eb9d02e5e01f082ef0aeb194ef17de45"},{"bytes":12560,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"93ad131ab148ede868ba9f56fd73b3c073552895","path":"lean/DefiKernel/Parallel/Examples.lean","sha256":"d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd"},{"bytes":7916,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"0ae8a088d63ff32b788df65b8d50717662528dfc","path":"lean/DefiKernel/Parallel/Execution.lean","sha256":"a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089"},{"bytes":2075,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"d1fc9c96e9707f33e8fc6c787c1115f3a151a76f","path":"lean/DefiKernel/Parallel/ExecutionTests.lean","sha256":"4b88467004d0392fba8aff169544bbebf586a06c74ca5426a2ca6ab7676ded99"},{"bytes":2156,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"015857c7ac8c13af445adbc5145e0ab7f932b4fb","path":"lean/DefiKernel/Parallel/Observation.lean","sha256":"38018fbcfb37c08181fbce37b75050077c3dc19d8bee6c0975b7898447ccb84f"},{"bytes":4350,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"442558ad9e474da0a2ec08112a44595c5a9f1e66","path":"lean/DefiKernel/Parallel/ObservationTests.lean","sha256":"227c4e8e63bfaa66394e8e5946cea5650787651ed2ea6a42cf63a1edada5864e"},{"bytes":19323,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"23c60c62f05c7ff24b0073ce24e78165f375219d","path":"lean/DefiKernel/Parallel/Preservation.lean","sha256":"faa047bf614306b00cafc7c4b9278df070b9edb9b26f4d655e68af11a182fa10"},{"bytes":9146,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"e763240a95c7630de32250b1d69b7f39f01cf39a","path":"lean/DefiKernel/Parallel/PreservationFixtures.lean","sha256":"0b04488e2d75cbbc4997217aae288692f35571cbcbdec40420254b59948ba9e7"},{"bytes":12209,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"93c8f51468943b77e47dc063192e1ec078bbf386","path":"lean/DefiKernel/Parallel/Tests.lean","sha256":"626dadde5519715fc8d92324ac483c8d00c049001313f1257103a004b284f725"},{"bytes":388,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"6ecd693d75c241fe8ca2239917f67de87f07f636","path":"lean/DefiKernel/Parallel/Verify.lean","sha256":"ff25ad430ff36275ecaf7ccfab8a55f2e853cbd9381a739163f81bd3d7bbd3ab"},{"bytes":17113,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"6215aed9b4efb5354af401504e4bf9d7ba39cd2a","path":"lean/DefiKernel/Typed/Acceptance.lean","sha256":"4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1"},{"bytes":1050,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"c9e2a259936ed139599b35d4ed1467a54f67e460","path":"lean/DefiKernel/Typed/Audit.lean","sha256":"20ffa1753cf50ef5b60dec0d8bb6950c2b9f623011df23c7c0d8a542aeaeb3c4"},{"bytes":13533,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"f7fb9de0cb97cc9e003bf487d742ec902250efc9","path":"lean/DefiKernel/Typed/Authority.lean","sha256":"dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb"},{"bytes":6578,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"0565fc81a0625e064ee560613408356bac7c4cda","path":"lean/DefiKernel/Typed/AuthorityTests.lean","sha256":"02c7028ade18e53815d436f57fc3c80cd79c06dc585a3e985b1be8dab544ae77"},{"bytes":10774,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"5094c617948dc2955e6662009fe621b47edc6417","path":"lean/DefiKernel/Typed/Examples.lean","sha256":"640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41"},{"bytes":12466,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"4142a771422ee0d74aad24f5c9f7101db0d27195","path":"lean/DefiKernel/Typed/Expr.lean","sha256":"1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed"},{"bytes":8960,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"f101da3b78d9cdf473377b406cac58bc836a4588","path":"lean/DefiKernel/Typed/ExprTests.lean","sha256":"8fd89353f21e5f3f94f1ed56ae6d1e28d375952b5720ed9e29c177e4a4e88e29"},{"bytes":21986,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"344109d8e783c2b80f1385fa39f0a4b923b0d07c","path":"lean/DefiKernel/Typed/Transition.lean","sha256":"73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2"},{"bytes":12731,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"09ecdc3ee7b659eb08be15701a76595ec3c8b18d","path":"lean/DefiKernel/Typed/TransitionTests.lean","sha256":"e9d3af4f0d81c9ab76ab20e0440228c30c6dcf54f5e80ccd32117f4c961561bc"},{"bytes":4499,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"fd5c617ee1c7b7ff56092218e55b0c3ce2ac1da8","path":"lean/DefiKernel/Typed/Types.lean","sha256":"5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82"},{"bytes":322,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"c0bc41f3703eb6e26ef62c9da6b0282166e19504","path":"lean/DefiKernel/Typed/Verify.lean","sha256":"2f8fc6cb7202a70d2438dad6d665edcccc3fec47add99087284b03b9b30f8d8d"},{"bytes":367,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"8f0820b4953382bcaf3f7eb67b212d99ea31caa2","path":"lean/DefiKernel/VerifyAxioms.lean","sha256":"da8c2b3fd23780417c717a39b3eacbc06e611dfa6b76a576c9f6bd0b0398482e"},{"bytes":324,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"aa8771436ccb388bac15701ede0ab2e3ae496c34","path":"lean/Defialgebra.lean","sha256":"4f59f8498127bc11294f4af6846ba11cd5b51ac9be14ef38d130e58943383f8c"},{"bytes":21,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"99415d9d9fc72e540b7fc4f2e1242b9cfd06814d","path":"lean/Defialgebra/Basic.lean","sha256":"a88fef4d3efa63c9f9f5c948dd5ba1de3ea09d828ce8388ee83fa3d039e734a4"},{"bytes":26100,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"e78cd3a9e86aa5afc8ce9d4cb04f670070e160a1","path":"lean/Defialgebra/ConvexGeometry.lean","sha256":"3b301a6b0179c36b9936c923805a37938a0127f17121a4140929c980819fbca4"},{"bytes":6785,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"97a5e426932e06a9165f10ab938ddfcc52e3bcb4","path":"lean/Defialgebra/Discharge.lean","sha256":"405d38c11a64aebe6964793140f2a7ca557b77e6592975f3e561953d545aa963"},{"bytes":9772,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"36c1f63265b432a7460238cbb15b71b38fb69679","path":"lean/Defialgebra/Extremal.lean","sha256":"971391a3f4e733f935d5cba957a41c1c9e5db63748dd64db444267481e47b163"},{"bytes":5521,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"b6331d8b302e8b5a5fc9427386badb612b181e6a","path":"lean/Defialgebra/FlowPolarity.lean","sha256":"50903678a5684b4d10af3be3233356447574b964cbbb5e3d969fc7d6d56db7c6"},{"bytes":7817,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"c61d9ef57575a22b4bf39a8d19c9a5c76beadd05","path":"lean/Defialgebra/Independence.lean","sha256":"831c297df2df0fe71220014ae9bc169e283834c6574c95b5d3fafa615d45e67c"},{"bytes":7391,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"9e929cba38ef372286b54b2c3fb3fd538e8a23bc","path":"lean/Defialgebra/Interface.lean","sha256":"e77ab27a5f9c2bf065805bab5a38fcfc8aa46e32ff1979dd8c2682fcb4331bd8"},{"bytes":7800,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"f1b7c97fbf4236e502d5c3aedce4b55e6222df7b","path":"lean/Defialgebra/Lattice.lean","sha256":"97f6dcda33de19f12f5971798e5745ace09ca66ee91f9c43c1d18030e6122eb4"},{"bytes":6238,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"cddfae4195564e9cfca9b26a8b407b89fc89e4b5","path":"lean/Defialgebra/Nary.lean","sha256":"31b42f37aa3b357554c33f0563a0042a94dd618a63d5771c02aa310cab919680"},{"bytes":3515,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"a856ddc9ae3027f4ea23fec14d4cb263aa8a17a3","path":"lean/Defialgebra/Obstruction.lean","sha256":"095c3c21c905985676fdd3fefaf23f2a8d2bb72f29b4dd874cd5c7ed3726375d"},{"bytes":6745,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"3aa6d490c89e6a3e46594b6ac3adf8715d9c57da","path":"lean/Defialgebra/Permission.lean","sha256":"cde935d39e0b9f4dfa92eaa7907096face5fb5403d8b1e53b80b3982283b7ed6"},{"bytes":11293,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"832cea5767c712e034071e348a5876623e9578db","path":"lean/Defialgebra/Polarity.lean","sha256":"3c0d18247d5df39c1f37f6a2adfb50cd304ecb3f6c7543da1f23bb8b53f203d3"},{"bytes":4585,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"d07426c593fecbac17b30496532190ad287b20b7","path":"lean/README.md","sha256":"e0385ee6346564bda844f47f58c99fbbbed97038ccc7bcaa693fda8a99250670"},{"bytes":3153,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"51fea05cf51f6ff04ca93c5a8d8d40c12d4334b1","path":"lean/lake-manifest.json","sha256":"8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002"},{"bytes":414,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"3bf93ee79697e086fda3a57b2fb7df069c25eb3c","path":"lean/lakefile.toml","sha256":"4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86"},{"bytes":29,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"c084c7fbe586b0276863b66f16d2955a43bc3fc6","path":"lean/lean-toolchain","sha256":"0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6"},{"bytes":20703,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"00b616f29f99832fa0d805cd7ef48625bfa48ea8","git_bytes_equal":true,"path":"scripts/check_metatheory_mutations.py","sha256":"d08707060c875b6834beaa5cc17e780f97f39b755962ed3a26ca176a94e4314a"},{"bytes":32771,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"31d311b5527b7ee180f8746c1314f5b373274242","git_bytes_equal":true,"path":"scripts/test_metatheory_mutation_runner.py","sha256":"19d234039a5d37f2eacd2dc328d17ddd66f57879833a24ff27de9d686bcf1e26"},{"bytes":5619,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"20aa05c3cca55860f43ab22e21b2fd51307df304","git_bytes_equal":true,"path":"mutations/metatheory.json","sha256":"bd5f6269777ac4bd7d6a3192d82dffd386ca5bfc135dd662b3076f26860a42fc"},{"bytes":29,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"c084c7fbe586b0276863b66f16d2955a43bc3fc6","git_bytes_equal":true,"path":"lean/lean-toolchain","sha256":"0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6"},{"bytes":3153,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"51fea05cf51f6ff04ca93c5a8d8d40c12d4334b1","git_bytes_equal":true,"path":"lean/lake-manifest.json","sha256":"8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002"},{"bytes":414,"equal_at":["eec499d613688137a341f3556cd80ca461dd2ee9","9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","c16832941c18229e51fade7c496b16146bb810bd"],"git_blob":"3bf93ee79697e086fda3a57b2fb7df069c25eb3c","git_bytes_equal":true,"path":"lean/lakefile.toml","sha256":"4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86"}],"source_equivalence_note":"Accepted source bytes equal archive/current bytes; metadata revisions do not create new executions.","status":"ACCEPTED_DEPENDENCY_BOUND_S10_PLANNING_GATE_PENDING"}

## END FILE

## FILE review/semantic-kernel/sprint10/planning/official-preparation/inherited-controls.json

Original SHA256: d06b25089fd2f807842721180c06b3db27d28c984783d914e0505fd7475916f1; bytes: 15450; rendered SHA256: e1f137139452a5b3601bedff7d0824cb3463524ef054c2e958436691f78f558c

{"cases":[{"expected_exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","old_name":"production-eval-discriminating-mutant","planned_new_name":"production-eval-discriminating-mutant","production_form":true},{"expected_exit":1,"message":"required mutation not detected","old_name":"production-eval-required-stays-true","planned_new_name":"production-eval-required-stays-true","production_form":true},{"expected_exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","old_name":"live-discriminating-mutant","planned_new_name":"live-discriminating-mutant","production_form":false},{"expected_exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","old_name":"dotted-comparisons","planned_new_name":"dotted-comparisons","production_form":false},{"expected_exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","old_name":"hyphenated-dotted-comparisons","planned_new_name":"hyphenated-dotted-comparisons","production_form":false},{"expected_exit":3,"message":"invalid required check name","old_name":"empty-dot-segment-spec","planned_new_name":"empty-dot-segment-spec","production_form":false},{"expected_exit":3,"message":"invalid positive check name","old_name":"trailing-dot-spec","planned_new_name":"trailing-dot-spec","production_form":false},{"expected_exit":3,"message":"malformed observation","old_name":"leading-dot-observation","planned_new_name":"leading-dot-observation","production_form":false},{"expected_exit":3,"message":"malformed observation","old_name":"empty-dot-segment-observation","planned_new_name":"empty-dot-segment-observation","production_form":false},{"expected_exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","old_name":"unused-variable-warning","planned_new_name":"unused-variable-warning","production_form":false},{"expected_exit":3,"message":"malformed observation","old_name":"uppercase-observation","planned_new_name":"uppercase-observation","production_form":false},{"expected_exit":3,"message":"probe: partial execution","old_name":"unknown-mutant-observation","planned_new_name":"unknown-mutant-observation","production_form":false},{"expected_exit":1,"message":"all comparisons still pass under mutation","old_name":"all-true-mutant","planned_new_name":"all-true-mutant","production_form":false},{"expected_exit":1,"message":"required mutation not detected","old_name":"required-observation-stays-true","planned_new_name":"required-observation-stays-true","production_form":false},{"expected_exit":1,"message":"positive control failed","old_name":"positive-control-flipped","planned_new_name":"positive-control-flipped","production_form":false},{"expected_exit":3,"message":"failure is not solely the expected runtime comparison failure","old_name":"compilation-only-failure","planned_new_name":"compilation-only-failure","production_form":false},{"expected_exit":3,"message":"failure is not solely the expected runtime comparison failure","old_name":"compiler-error-with-runtime-failure","planned_new_name":"compiler-error-with-runtime-failure","production_form":false},{"expected_exit":3,"message":"control: empty/duplicate observations","old_name":"empty-observations","planned_new_name":"empty-observations","production_form":false},{"expected_exit":3,"message":"control: empty/duplicate observations","old_name":"duplicate-observations","planned_new_name":"duplicate-observations","production_form":false},{"expected_exit":3,"message":"control: missing positive controls","old_name":"missing-positive-observation","planned_new_name":"missing-positive-observation","production_form":false},{"expected_exit":3,"message":"probe: missing required observation in control","old_name":"missing-required-observation","planned_new_name":"missing-required-observation","production_form":false},{"expected_exit":3,"message":"probe: partial execution","old_name":"partial-mutant-observations","planned_new_name":"partial-mutant-observations","production_form":false},{"expected_exit":3,"message":"mutation must actually change the source","old_name":"no-op-mutation","planned_new_name":"no-op-mutation","production_form":false},{"expected_exit":3,"message":"mutation did not apply exactly once","old_name":"missing-mutation-needle","planned_new_name":"missing-mutation-needle","production_form":false},{"expected_exit":3,"message":"FileNotFoundError","old_name":"missing-source-setup","planned_new_name":"missing-source-setup","production_form":false},{"expected_exit":3,"message":"FileNotFoundError","old_name":"missing-manifest-setup","planned_new_name":"missing-manifest-setup","production_form":false},{"expected_exit":3,"message":"output already exists","old_name":"existing-output-setup","planned_new_name":"existing-output-setup","production_form":false},{"expected_exit":3,"message":"reserved variant name","old_name":"reserved-mutation-name","planned_new_name":"reserved-mutation-name","production_form":false},{"expected_exit":3,"message":"empty module inventory","old_name":"empty-module-inventory","planned_new_name":"empty-module-inventory","production_form":false},{"expected_exit":3,"message":"empty positive-control inventory","old_name":"empty-positive-inventory","planned_new_name":"empty-positive-inventory","production_form":false},{"expected_exit":3,"message":"duplicate source module","old_name":"duplicate-module-inventory","planned_new_name":"duplicate-module-inventory","production_form":false},{"expected_exit":3,"message":"duplicate mutation name","old_name":"duplicate-mutation-inventory","planned_new_name":"duplicate-mutation-inventory","production_form":false},{"expected_exit":3,"message":"duplicate positive control","old_name":"duplicate-positive-check","planned_new_name":"duplicate-positive-check","production_form":false},{"expected_exit":3,"message":"duplicate required check","old_name":"duplicate-required-check","planned_new_name":"duplicate-required-check","production_form":false},{"expected_exit":3,"message":"mutation did not apply exactly once","old_name":"nonunique-mutation-needle","planned_new_name":"nonunique-mutation-needle","production_form":false},{"expected_exit":3,"message":"malformed observation","old_name":"malformed-observation","planned_new_name":"malformed-observation","production_form":false},{"expected_exit":3,"message":"JSONDecodeError","old_name":"malformed-json","planned_new_name":"malformed-json","production_form":false},{"expected_exit":3,"message":"duplicate JSON key","old_name":"duplicate-json-key","planned_new_name":"duplicate-json-key","production_form":false},{"expected_exit":3,"message":"evidence output must be outside the repository","old_name":"output-inside-repository","planned_new_name":"output-inside-repository","production_form":false},{"expected_exit":3,"message":"output already exists","old_name":"output-symlink","planned_new_name":"output-symlink","production_form":false},{"expected_exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","old_name":"discovered-metatheory-dependency","planned_new_name":"discovered-interface-dependency","production_form":false},{"expected_exit":3,"message":"control compilation/execution failed","old_name":"fresh-dependency-source-failure","planned_new_name":"fresh-dependency-source-failure","production_form":false},{"expected_exit":3,"message":"missing Metatheory audit root","old_name":"missing-audit-root","planned_new_name":"missing-audit-root","production_form":false},{"expected_exit":3,"message":"invalid scoped module","old_name":"foreign-module-root","planned_new_name":"foreign-module-root","production_form":false},{"expected_exit":3,"message":"mutation module outside inventory","old_name":"mutation-module-outside-inventory","planned_new_name":"mutation-module-outside-inventory","production_form":false},{"expected_exit":1,"message":"unchanged control has failing comparisons","old_name":"unchanged-control-failed","planned_new_name":"unchanged-control-failed","production_form":false},{"expected_exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","old_name":"nonkernel-local-dependency","planned_new_name":"nonkernel-local-dependency","production_form":false},{"expected_exit":3,"message":"input differs from frozen Git revision","old_name":"dirty-source-before-run","planned_new_name":"dirty-source-before-run","production_form":false},{"expected_exit":3,"message":"input differs from frozen Git revision","old_name":"staged-source-before-run","planned_new_name":"staged-source-before-run","production_form":false},{"expected_exit":3,"message":"input sources changed during replay","old_name":"source-drift-during-run","planned_new_name":"source-drift-during-run","production_form":false},{"expected_exit":3,"message":"input sources changed during replay","old_name":"source-drift-during-mutant","planned_new_name":"source-drift-during-mutant","production_form":false},{"expected_exit":3,"message":"specification changed during replay","old_name":"specification-drift-during-run","planned_new_name":"specification-drift-during-run","production_form":false},{"expected_exit":3,"message":"runtime declaration after proof boundary","old_name":"runtime-definition-after-proof-boundary","planned_new_name":"runtime-definition-after-proof-boundary","production_form":false},{"expected_exit":3,"message":"runtime declaration after proof boundary","old_name":"attributed-runtime-after-proof-boundary","planned_new_name":"attributed-runtime-after-proof-boundary","production_form":false},{"expected_exit":3,"message":"runtime declaration after proof boundary","old_name":"comment-prefixed-runtime-after-proof-boundary","planned_new_name":"comment-prefixed-runtime-after-proof-boundary","production_form":false},{"expected_exit":3,"message":"runtime declaration after proof boundary","old_name":"macro-after-proof-boundary","planned_new_name":"macro-after-proof-boundary","production_form":false},{"expected_exit":3,"message":"runtime declaration after proof boundary","old_name":"macro-rules-after-proof-boundary","planned_new_name":"macro-rules-after-proof-boundary","production_form":false},{"expected_exit":3,"message":"runtime declaration after proof boundary","old_name":"syntax-after-proof-boundary","planned_new_name":"syntax-after-proof-boundary","production_form":false},{"expected_exit":3,"message":"runtime declaration after proof boundary","old_name":"initialize-after-proof-boundary","planned_new_name":"initialize-after-proof-boundary","production_form":false},{"expected_exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","old_name":"proof-comment-keywords-sibling","planned_new_name":"proof-comment-keywords-sibling","production_form":false},{"expected_exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","old_name":"proof-string-keywords-sibling","planned_new_name":"proof-string-keywords-sibling","production_form":false},{"expected_exit":3,"message":"runtime declaration after proof boundary","old_name":"raw-string-before-attributed-runtime","planned_new_name":"raw-string-before-attributed-runtime","production_form":false},{"expected_exit":3,"message":"runtime declaration after proof boundary","old_name":"character-before-attributed-runtime","planned_new_name":"character-before-attributed-runtime","production_form":false},{"expected_exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","old_name":"proof-raw-string-character-sibling","planned_new_name":"proof-raw-string-character-sibling","production_form":false},{"expected_exit":3,"message":"empty mutation inventory","old_name":"empty-mutation-inventory","planned_new_name":"empty-mutation-inventory","production_form":false}],"refresh":"Accepted S9 source/evidence/delivery and actual65 executions are bound in dependency-baseline.json; these adapted S10 cases remain unexecuted. Recheck if source changes","source":{"bytes":32771,"path":"scripts/test_metatheory_mutation_runner.py","sha256":"19d234039a5d37f2eacd2dc328d17ddd66f57879833a24ff27de9d686bcf1e26"},"status":"S10_adaptation_catalog_not_executed_S9_predecessor65_completed"}

## END FILE

## FILE review/semantic-kernel/sprint10/planning/official-preparation/planned-mutations.json

Original SHA256: f046fba3bf7704ec68c67237fd2b47caadb290e179294989bf73905c2dd08c48; bytes: 3716; rendered SHA256: afeb60ef5356fcaa6130570d33b3b0b96a5a44045a8ddb5fc46e5949e401899a

{"mutants":[{"designated_comparison":"F01 sum10","id":"M01","planned_site":"balanceSum folds over region.cells.toList.dropLast","protected_sibling":"Empty region sum0","status":"planned_not_executed"},{"designated_comparison":"F02 delta−2","id":"M02","planned_site":"Negate receiptDelta's final signed sum","protected_sibling":"F01 neutral delta0","status":"planned_not_executed"},{"designated_comparison":"F04 singleton delta−3","id":"M03","planned_site":"receiptCellEffect uses first matching target instead of sum","protected_sibling":"F02 one-target delta−2","status":"planned_not_executed"},{"designated_comparison":"F03 delta+3","id":"M04","planned_site":"receiptDelta returns0 if receipt has nonzero supply for region dimension","protected_sibling":"F01 delta0","status":"planned_not_executed"},{"designated_comparison":"F02 delta−2","id":"M05","planned_site":"receiptDelta returns whole dimension supply","protected_sibling":"F03 delta+3","status":"planned_not_executed"},{"designated_comparison":"F08 one-edge unequal result","id":"M06","planned_site":"checkBindings drops final edge before traversal","protected_sibling":"F07 equal edge success","status":"planned_not_executed"},{"designated_comparison":"F08 exact unequal result","id":"M07","planned_site":"Query compares left balance with itself","protected_sibling":"F07 equal edge success","status":"planned_not_executed"},{"designated_comparison":"F11 A=U assetMismatch","id":"M08","planned_site":"Query omits asset comparison","protected_sibling":"F07 same-asset equality","status":"planned_not_executed"},{"designated_comparison":"F11 A=V domainMismatch","id":"M09","planned_site":"Query omits domain comparison","protected_sibling":"F07 same-domain equality","status":"planned_not_executed"},{"designated_comparison":"F08 resolves B to Bob5 and rejects","id":"M10","planned_site":"resolveExport searches port ID globally, ignoring component","protected_sibling":"F13 self-edge success","status":"planned_not_executed"},{"designated_comparison":"F12 missingPort at component0/port99","id":"M11","planned_site":"Missing port lookup falls back to first export of selected component","protected_sibling":"F10 existing-port success","status":"planned_not_executed"},{"designated_comparison":"F12 first unequal index0 before missing index1","id":"M12","planned_site":"Traverse tail before checking current edge, preserving original indices","protected_sibling":"F10 all valid equal edges","status":"planned_not_executed"},{"designated_comparison":"F13 invalid-catalog empty-edge configuration","id":"M13","planned_site":"checkBindings bypasses catalog validation","protected_sibling":"F13 valid empty success","status":"planned_not_executed"},{"designated_comparison":"F18 issued delta0 for singleton region","id":"M14","planned_site":"receiptCellEffect for issued receipt returns1 rather than0","protected_sibling":"F01 invoked neutral delta0","status":"planned_not_executed"}],"status":"design_only_no_detection_claim"}

## END FILE

## FILE review/semantic-kernel/sprint10/planning/official-preparation/runner-adaptation.json

Original SHA256: 04b0fe2bcd1d4990761a2b771d59e196562c4c7c61f0cdc6199da70c58662c35; bytes: 75883; rendered SHA256: 4bbe59c0f1f97d468dcbd0e414cb4e72d0b0bcd7eff69c337a0a0ba27da85ddd

{"accepted_dependency":{"archive_remote":"9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","source":"eec499d613688137a341f3556cd80ca461dd2ee9","source_evidence":"ec9ed80457d7a9c4064d26ab193591579027abae"},"control_count":65,"controls":[{"expected_exit":0,"new_case":{"exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"production-eval-discriminating-mutant","production_audit":true},"new_name":"production-eval-discriminating-mutant","old_case":{"exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"production-eval-discriminating-mutant","production_audit":true},"old_name":"production-eval-discriminating-mutant"},{"expected_exit":1,"new_case":{"exit":1,"message":"required mutation not detected","name":"production-eval-required-stays-true","production_audit":true,"spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_positive"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"production-eval-required-stays-true","old_case":{"exit":1,"message":"required mutation not detected","name":"production-eval-required-stays-true","production_audit":true,"spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_positive"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"production-eval-required-stays-true"},{"expected_exit":0,"new_case":{"exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"live-discriminating-mutant"},"new_name":"live-discriminating-mutant","old_case":{"exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"live-discriminating-mutant"},"old_name":"live-discriminating-mutant"},{"expected_exit":0,"new_case":{"checks":"if runnerIncludeSensitivity then\n    [(\"runner.positive\", runnerAllows 0), (\"runner.sensitivity\", !runnerAllows 5)]\n    else [(\"runner.positive\", runnerAllows 0)]","exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"dotted-comparisons","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner.sensitivity"]}],"positive_checks":["runner.positive"],"schema_version":1}},"new_name":"dotted-comparisons","old_case":{"checks":"if runnerIncludeSensitivity then\n    [(\"runner.positive\", runnerAllows 0), (\"runner.sensitivity\", !runnerAllows 5)]\n    else [(\"runner.positive\", runnerAllows 0)]","exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"dotted-comparisons","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner.sensitivity"]}],"positive_checks":["runner.positive"],"schema_version":1}},"old_name":"dotted-comparisons"},{"expected_exit":0,"new_case":{"checks":"if runnerIncludeSensitivity then\n    [(\"runner.permitted-sibling\", runnerAllows 0), (\"runner.expected-failure\", !runnerAllows 5)]\n    else [(\"runner.permitted-sibling\", runnerAllows 0)]","exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"hyphenated-dotted-comparisons","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner.expected-failure"]}],"positive_checks":["runner.permitted-sibling"],"schema_version":1}},"new_name":"hyphenated-dotted-comparisons","old_case":{"checks":"if runnerIncludeSensitivity then\n    [(\"runner.permitted-sibling\", runnerAllows 0), (\"runner.expected-failure\", !runnerAllows 5)]\n    else [(\"runner.permitted-sibling\", runnerAllows 0)]","exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"hyphenated-dotted-comparisons","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner.expected-failure"]}],"positive_checks":["runner.permitted-sibling"],"schema_version":1}},"old_name":"hyphenated-dotted-comparisons"},{"expected_exit":3,"new_case":{"exit":3,"message":"invalid required check name","name":"empty-dot-segment-spec","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner..sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"empty-dot-segment-spec","old_case":{"exit":3,"message":"invalid required check name","name":"empty-dot-segment-spec","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner..sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"empty-dot-segment-spec"},{"expected_exit":3,"new_case":{"exit":3,"message":"invalid positive check name","name":"trailing-dot-spec","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner."],"schema_version":1}},"new_name":"trailing-dot-spec","old_case":{"exit":3,"message":"invalid positive check name","name":"trailing-dot-spec","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner."],"schema_version":1}},"old_name":"trailing-dot-spec"},{"expected_exit":3,"new_case":{"exit":3,"extra_audit":"  liftIO <| IO.println \".runner_bad: true\"\n","message":"malformed observation","name":"leading-dot-observation"},"new_name":"leading-dot-observation","old_case":{"exit":3,"extra_audit":"  liftIO <| IO.println \".runner_bad: true\"\n","message":"malformed observation","name":"leading-dot-observation"},"old_name":"leading-dot-observation"},{"expected_exit":3,"new_case":{"exit":3,"extra_audit":"  liftIO <| IO.println \"runner..bad: true\"\n","message":"malformed observation","name":"empty-dot-segment-observation"},"new_name":"empty-dot-segment-observation","old_case":{"exit":3,"extra_audit":"  liftIO <| IO.println \"runner..bad: true\"\n","message":"malformed observation","name":"empty-dot-segment-observation"},"old_name":"empty-dot-segment-observation"},{"expected_exit":0,"new_case":{"exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"unused-variable-warning","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"true","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"unused-variable-warning","old_case":{"exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"unused-variable-warning","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"true","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"unused-variable-warning"},{"expected_exit":3,"new_case":{"exit":3,"extra_audit":"  liftIO <| IO.println \"Runner_bad: true\"\n","message":"malformed observation","name":"uppercase-observation"},"new_name":"uppercase-observation","old_case":{"exit":3,"extra_audit":"  liftIO <| IO.println \"Runner_bad: true\"\n","message":"malformed observation","name":"uppercase-observation"},"old_name":"uppercase-observation"},{"expected_exit":3,"new_case":{"exit":3,"extra_audit":"  if runnerAllows 5 then\n    liftIO <| IO.println \"runner_unknown: true\"\n","message":"probe: partial execution","name":"unknown-mutant-observation"},"new_name":"unknown-mutant-observation","old_case":{"exit":3,"extra_audit":"  if runnerAllows 5 then\n    liftIO <| IO.println \"runner_unknown: true\"\n","message":"probe: partial execution","name":"unknown-mutant-observation"},"old_name":"unknown-mutant-observation"},{"expected_exit":1,"new_case":{"exit":1,"message":"all comparisons still pass under mutation","name":"all-true-mutant","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 3","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"all-true-mutant","old_case":{"exit":1,"message":"all comparisons still pass under mutation","name":"all-true-mutant","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 3","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"all-true-mutant"},{"expected_exit":1,"new_case":{"exit":1,"message":"required mutation not detected","name":"required-observation-stays-true","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_positive"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"required-observation-stays-true","old_case":{"exit":1,"message":"required mutation not detected","name":"required-observation-stays-true","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_positive"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"required-observation-stays-true"},{"expected_exit":1,"new_case":{"exit":1,"message":"positive control failed","name":"positive-control-flipped","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n == 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"positive-control-flipped","old_case":{"exit":1,"message":"positive control failed","name":"positive-control-flipped","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n == 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"positive-control-flipped"},{"expected_exit":3,"new_case":{"exit":3,"message":"failure is not solely the expected runtime comparison failure","name":"compilation-only-failure","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"-- compiler-control","replacement":"#check runnerUndefinedConstant","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"compilation-only-failure","old_case":{"exit":3,"message":"failure is not solely the expected runtime comparison failure","name":"compilation-only-failure","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"-- compiler-control","replacement":"#check runnerUndefinedConstant","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"compilation-only-failure"},{"expected_exit":3,"new_case":{"exit":3,"message":"failure is not solely the expected runtime comparison failure","name":"compiler-error-with-runtime-failure","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4\ndef runnerIncludeSensitivity : Bool := true","replacement":"n ≤ 5\n#check runnerUndefinedConstant\ndef runnerIncludeSensitivity : Bool := true","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"compiler-error-with-runtime-failure","old_case":{"exit":3,"message":"failure is not solely the expected runtime comparison failure","name":"compiler-error-with-runtime-failure","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4\ndef runnerIncludeSensitivity : Bool := true","replacement":"n ≤ 5\n#check runnerUndefinedConstant\ndef runnerIncludeSensitivity : Bool := true","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"compiler-error-with-runtime-failure"},{"expected_exit":3,"new_case":{"checks":"[]","exit":3,"message":"control: empty/duplicate observations","name":"empty-observations"},"new_name":"empty-observations","old_case":{"checks":"[]","exit":3,"message":"control: empty/duplicate observations","name":"empty-observations"},"old_name":"empty-observations"},{"expected_exit":3,"new_case":{"checks":"[(\"runner_positive\", true), (\"runner_positive\", true), (\"runner_sensitivity\", !runnerAllows 5)]","exit":3,"message":"control: empty/duplicate observations","name":"duplicate-observations"},"new_name":"duplicate-observations","old_case":{"checks":"[(\"runner_positive\", true), (\"runner_positive\", true), (\"runner_sensitivity\", !runnerAllows 5)]","exit":3,"message":"control: empty/duplicate observations","name":"duplicate-observations"},"old_name":"duplicate-observations"},{"expected_exit":3,"new_case":{"checks":"[(\"runner_sensitivity\", !runnerAllows 5)]","exit":3,"message":"control: missing positive controls","name":"missing-positive-observation"},"new_name":"missing-positive-observation","old_case":{"checks":"[(\"runner_sensitivity\", !runnerAllows 5)]","exit":3,"message":"control: missing positive controls","name":"missing-positive-observation"},"old_name":"missing-positive-observation"},{"expected_exit":3,"new_case":{"exit":3,"message":"probe: missing required observation in control","name":"missing-required-observation","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_absent"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"missing-required-observation","old_case":{"exit":3,"message":"probe: missing required observation in control","name":"missing-required-observation","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_absent"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"missing-required-observation"},{"expected_exit":3,"new_case":{"exit":3,"message":"probe: partial execution","name":"partial-mutant-observations","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"runnerIncludeSensitivity : Bool := true","replacement":"runnerIncludeSensitivity : Bool := false","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"partial-mutant-observations","old_case":{"exit":3,"message":"probe: partial execution","name":"partial-mutant-observations","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"runnerIncludeSensitivity : Bool := true","replacement":"runnerIncludeSensitivity : Bool := false","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"partial-mutant-observations"},{"expected_exit":3,"new_case":{"exit":3,"message":"mutation must actually change the source","name":"no-op-mutation","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 4","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"no-op-mutation","old_case":{"exit":3,"message":"mutation must actually change the source","name":"no-op-mutation","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 4","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"no-op-mutation"},{"expected_exit":3,"new_case":{"exit":3,"message":"mutation did not apply exactly once","name":"missing-mutation-needle","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"runnerNeedleDoesNotExist","replacement":"false","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"missing-mutation-needle","old_case":{"exit":3,"message":"mutation did not apply exactly once","name":"missing-mutation-needle","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"runnerNeedleDoesNotExist","replacement":"false","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"missing-mutation-needle"},{"expected_exit":3,"new_case":{"exit":3,"message":"FileNotFoundError","missing_source":true,"name":"missing-source-setup"},"new_name":"missing-source-setup","old_case":{"exit":3,"message":"FileNotFoundError","missing_source":true,"name":"missing-source-setup"},"old_name":"missing-source-setup"},{"expected_exit":3,"new_case":{"exit":3,"message":"FileNotFoundError","missing_manifest":true,"name":"missing-manifest-setup"},"new_name":"missing-manifest-setup","old_case":{"exit":3,"message":"FileNotFoundError","missing_manifest":true,"name":"missing-manifest-setup"},"old_name":"missing-manifest-setup"},{"expected_exit":3,"new_case":{"existing_output":true,"exit":3,"message":"output already exists","name":"existing-output-setup"},"new_name":"existing-output-setup","old_case":{"existing_output":true,"exit":3,"message":"output already exists","name":"existing-output-setup"},"old_name":"existing-output-setup"},{"expected_exit":3,"new_case":{"exit":3,"message":"reserved variant name","name":"reserved-mutation-name","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"lean-version","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"reserved-mutation-name","old_case":{"exit":3,"message":"reserved variant name","name":"reserved-mutation-name","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"lean-version","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"reserved-mutation-name"},{"expected_exit":3,"new_case":{"exit":3,"message":"empty module inventory","name":"empty-module-inventory","spec":{"modules":[],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"empty-module-inventory","old_case":{"exit":3,"message":"empty module inventory","name":"empty-module-inventory","spec":{"modules":[],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"empty-module-inventory"},{"expected_exit":3,"new_case":{"exit":3,"message":"empty positive-control inventory","name":"empty-positive-inventory","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":[],"schema_version":1}},"new_name":"empty-positive-inventory","old_case":{"exit":3,"message":"empty positive-control inventory","name":"empty-positive-inventory","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":[],"schema_version":1}},"old_name":"empty-positive-inventory"},{"expected_exit":3,"new_case":{"exit":3,"message":"duplicate source module","name":"duplicate-module-inventory","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"duplicate-module-inventory","old_case":{"exit":3,"message":"duplicate source module","name":"duplicate-module-inventory","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"duplicate-module-inventory"},{"expected_exit":3,"new_case":{"exit":3,"message":"duplicate mutation name","name":"duplicate-mutation-inventory","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]},{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"duplicate-mutation-inventory","old_case":{"exit":3,"message":"duplicate mutation name","name":"duplicate-mutation-inventory","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]},{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"duplicate-mutation-inventory"},{"expected_exit":3,"new_case":{"exit":3,"message":"duplicate positive control","name":"duplicate-positive-check","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive","runner_positive"],"schema_version":1}},"new_name":"duplicate-positive-check","old_case":{"exit":3,"message":"duplicate positive control","name":"duplicate-positive-check","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive","runner_positive"],"schema_version":1}},"old_name":"duplicate-positive-check"},{"expected_exit":3,"new_case":{"exit":3,"message":"duplicate required check","name":"duplicate-required-check","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity","runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"duplicate-required-check","old_case":{"exit":3,"message":"duplicate required check","name":"duplicate-required-check","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity","runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"duplicate-required-check"},{"expected_exit":3,"new_case":{"exit":3,"message":"mutation did not apply exactly once","name":"nonunique-mutation-needle","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"def ","replacement":"private def ","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"nonunique-mutation-needle","old_case":{"exit":3,"message":"mutation did not apply exactly once","name":"nonunique-mutation-needle","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"def ","replacement":"private def ","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"nonunique-mutation-needle"},{"expected_exit":3,"new_case":{"exit":3,"extra_audit":"  liftIO <| IO.println \"runner_bad: truth\"\n","message":"malformed observation","name":"malformed-observation"},"new_name":"malformed-observation","old_case":{"exit":3,"extra_audit":"  liftIO <| IO.println \"runner_bad: truth\"\n","message":"malformed observation","name":"malformed-observation"},"old_name":"malformed-observation"},{"expected_exit":3,"new_case":{"exit":3,"message":"JSONDecodeError","name":"malformed-json","raw_spec":"{"},"new_name":"malformed-json","old_case":{"exit":3,"message":"JSONDecodeError","name":"malformed-json","raw_spec":"{"},"old_name":"malformed-json"},{"expected_exit":3,"new_case":{"exit":3,"message":"duplicate JSON key","name":"duplicate-json-key","raw_spec":"{\"schema_version\": 1, \"schema_version\": 1}"},"new_name":"duplicate-json-key","old_case":{"exit":3,"message":"duplicate JSON key","name":"duplicate-json-key","raw_spec":"{\"schema_version\": 1, \"schema_version\": 1}"},"old_name":"duplicate-json-key"},{"expected_exit":3,"new_case":{"exit":3,"inside_output":true,"message":"evidence output must be outside the repository","name":"output-inside-repository"},"new_name":"output-inside-repository","old_case":{"exit":3,"inside_output":true,"message":"evidence output must be outside the repository","name":"output-inside-repository"},"old_name":"output-inside-repository"},{"expected_exit":3,"new_case":{"exit":3,"message":"output already exists","name":"output-symlink","symlink_output":true},"new_name":"output-symlink","old_case":{"exit":3,"message":"output already exists","name":"output-symlink","symlink_output":true},"old_name":"output-symlink"},{"expected_exit":0,"new_case":{"exit":0,"extra_dependency":true,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"discovered-interface-dependency"},"new_name":"discovered-interface-dependency","old_case":{"exit":0,"extra_dependency":true,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"discovered-metatheory-dependency"},"old_name":"discovered-metatheory-dependency"},{"expected_exit":3,"new_case":{"changed_dependency":true,"exit":3,"message":"control compilation/execution failed","name":"fresh-dependency-source-failure"},"new_name":"fresh-dependency-source-failure","old_case":{"changed_dependency":true,"exit":3,"message":"control compilation/execution failed","name":"fresh-dependency-source-failure"},"old_name":"fresh-dependency-source-failure"},{"expected_exit":3,"new_case":{"exit":3,"message":"missing Interface audit root","name":"missing-audit-root","spec":{"modules":["DefiKernel.Interface.RunnerInput"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"missing-audit-root","old_case":{"exit":3,"message":"missing Metatheory audit root","name":"missing-audit-root","spec":{"modules":["DefiKernel.Metatheory.RunnerInput"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"missing-audit-root"},{"expected_exit":3,"new_case":{"exit":3,"message":"invalid scoped module","name":"foreign-module-root","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit","DefiKernel.Composition.RunnerInput"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"foreign-module-root","old_case":{"exit":3,"message":"invalid scoped module","name":"foreign-module-root","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit","DefiKernel.Composition.RunnerInput"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"foreign-module-root"},{"expected_exit":3,"new_case":{"exit":3,"message":"mutation module outside inventory","name":"mutation-module-outside-inventory","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.Absent","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"mutation-module-outside-inventory","old_case":{"exit":3,"message":"mutation module outside inventory","name":"mutation-module-outside-inventory","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.Absent","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"mutation-module-outside-inventory"},{"expected_exit":1,"new_case":{"checks":"[(\"runner_positive\", true), (\"runner_sensitivity\", false)]","exit":1,"message":"unchanged control has failing comparisons","name":"unchanged-control-failed"},"new_name":"unchanged-control-failed","old_case":{"checks":"[(\"runner_positive\", true), (\"runner_sensitivity\", false)]","exit":1,"message":"unchanged control has failing comparisons","name":"unchanged-control-failed"},"old_name":"unchanged-control-failed"},{"expected_exit":0,"new_case":{"exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"nonkernel-local-dependency","nonkernel_dependency":true},"new_name":"nonkernel-local-dependency","old_case":{"exit":0,"message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"nonkernel-local-dependency","nonkernel_dependency":true},"old_name":"nonkernel-local-dependency"},{"expected_exit":3,"new_case":{"dirty_source":true,"exit":3,"message":"input differs from frozen Git revision","name":"dirty-source-before-run"},"new_name":"dirty-source-before-run","old_case":{"dirty_source":true,"exit":3,"message":"input differs from frozen Git revision","name":"dirty-source-before-run"},"old_name":"dirty-source-before-run"},{"expected_exit":3,"new_case":{"exit":3,"message":"input differs from frozen Git revision","name":"staged-source-before-run","staged_source":true},"new_name":"staged-source-before-run","old_case":{"exit":3,"message":"input differs from frozen Git revision","name":"staged-source-before-run","staged_source":true},"old_name":"staged-source-before-run"},{"expected_exit":3,"new_case":{"exit":3,"message":"input sources changed during replay","name":"source-drift-during-run","source_drift":true},"new_name":"source-drift-during-run","old_case":{"exit":3,"message":"input sources changed during replay","name":"source-drift-during-run","source_drift":true},"old_name":"source-drift-during-run"},{"expected_exit":3,"new_case":{"exit":3,"message":"input sources changed during replay","mutant_only_drift":true,"name":"source-drift-during-mutant","source_drift":true},"new_name":"source-drift-during-mutant","old_case":{"exit":3,"message":"input sources changed during replay","mutant_only_drift":true,"name":"source-drift-during-mutant","source_drift":true},"old_name":"source-drift-during-mutant"},{"expected_exit":3,"new_case":{"exit":3,"message":"specification changed during replay","name":"specification-drift-during-run","spec_drift":true},"new_name":"specification-drift-during-run","old_case":{"exit":3,"message":"specification changed during replay","name":"specification-drift-during-run","spec_drift":true},"old_name":"specification-drift-during-run"},{"expected_exit":3,"new_case":{"exit":3,"late_runtime":true,"message":"runtime declaration after proof boundary","name":"runtime-definition-after-proof-boundary"},"new_name":"runtime-definition-after-proof-boundary","old_case":{"exit":3,"late_runtime":true,"message":"runtime declaration after proof boundary","name":"runtime-definition-after-proof-boundary"},"old_name":"runtime-definition-after-proof-boundary"},{"expected_exit":3,"new_case":{"exit":3,"late_runtime":"@[inline] def hiddenRuntime : Bool := true","message":"runtime declaration after proof boundary","name":"attributed-runtime-after-proof-boundary"},"new_name":"attributed-runtime-after-proof-boundary","old_case":{"exit":3,"late_runtime":"@[inline] def hiddenRuntime : Bool := true","message":"runtime declaration after proof boundary","name":"attributed-runtime-after-proof-boundary"},"old_name":"attributed-runtime-after-proof-boundary"},{"expected_exit":3,"new_case":{"exit":3,"late_runtime":"/- retained documentation -/ def hiddenRuntime : Bool := true","message":"runtime declaration after proof boundary","name":"comment-prefixed-runtime-after-proof-boundary"},"new_name":"comment-prefixed-runtime-after-proof-boundary","old_case":{"exit":3,"late_runtime":"/- retained documentation -/ def hiddenRuntime : Bool := true","message":"runtime declaration after proof boundary","name":"comment-prefixed-runtime-after-proof-boundary"},"old_name":"comment-prefixed-runtime-after-proof-boundary"},{"expected_exit":3,"new_case":{"exit":3,"late_runtime":"macro \"lateRuntime\" : command => `(def hiddenRuntime : Bool := true)","message":"runtime declaration after proof boundary","name":"macro-after-proof-boundary"},"new_name":"macro-after-proof-boundary","old_case":{"exit":3,"late_runtime":"macro \"lateRuntime\" : command => `(def hiddenRuntime : Bool := true)","message":"runtime declaration after proof boundary","name":"macro-after-proof-boundary"},"old_name":"macro-after-proof-boundary"},{"expected_exit":3,"new_case":{"exit":3,"late_runtime":"macro_rules | `(lateRuntime) => `(def hiddenRuntime : Bool := true)","message":"runtime declaration after proof boundary","name":"macro-rules-after-proof-boundary"},"new_name":"macro-rules-after-proof-boundary","old_case":{"exit":3,"late_runtime":"macro_rules | `(lateRuntime) => `(def hiddenRuntime : Bool := true)","message":"runtime declaration after proof boundary","name":"macro-rules-after-proof-boundary"},"old_name":"macro-rules-after-proof-boundary"},{"expected_exit":3,"new_case":{"exit":3,"late_runtime":"syntax \"lateRuntime\" : command","message":"runtime declaration after proof boundary","name":"syntax-after-proof-boundary"},"new_name":"syntax-after-proof-boundary","old_case":{"exit":3,"late_runtime":"syntax \"lateRuntime\" : command","message":"runtime declaration after proof boundary","name":"syntax-after-proof-boundary"},"old_name":"syntax-after-proof-boundary"},{"expected_exit":3,"new_case":{"exit":3,"late_runtime":"initialize hiddenRuntime : IO.Ref Nat ← IO.mkRef 4","message":"runtime declaration after proof boundary","name":"initialize-after-proof-boundary"},"new_name":"initialize-after-proof-boundary","old_case":{"exit":3,"late_runtime":"initialize hiddenRuntime : IO.Ref Nat ← IO.mkRef 4","message":"runtime declaration after proof boundary","name":"initialize-after-proof-boundary"},"old_name":"initialize-after-proof-boundary"},{"expected_exit":0,"new_case":{"exit":0,"late_runtime":"/- def outer /- macro inner -/ initialize outer -/\n-- syntax class","message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"proof-comment-keywords-sibling"},"new_name":"proof-comment-keywords-sibling","old_case":{"exit":0,"late_runtime":"/- def outer /- macro inner -/ initialize outer -/\n-- syntax class","message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"proof-comment-keywords-sibling"},"old_name":"proof-comment-keywords-sibling"},{"expected_exit":0,"new_case":{"exit":0,"late_runtime":"theorem runtimeWords : \"def macro initialize\" = \"def macro initialize\" := rfl","message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"proof-string-keywords-sibling"},"new_name":"proof-string-keywords-sibling","old_case":{"exit":0,"late_runtime":"theorem runtimeWords : \"def macro initialize\" = \"def macro initialize\" := rfl","message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"proof-string-keywords-sibling"},"old_name":"proof-string-keywords-sibling"},{"expected_exit":3,"new_case":{"exit":3,"late_runtime":"theorem rawWords : r#\"def \"macro\"\"# = r#\"def \"macro\"\"# := rfl\n@[inline] def hiddenRuntime : Bool := true","message":"runtime declaration after proof boundary","name":"raw-string-before-attributed-runtime"},"new_name":"raw-string-before-attributed-runtime","old_case":{"exit":3,"late_runtime":"theorem rawWords : r#\"def \"macro\"\"# = r#\"def \"macro\"\"# := rfl\n@[inline] def hiddenRuntime : Bool := true","message":"runtime declaration after proof boundary","name":"raw-string-before-attributed-runtime"},"old_name":"raw-string-before-attributed-runtime"},{"expected_exit":3,"new_case":{"exit":3,"late_runtime":"theorem quoteChar : '\"' = '\"' := rfl\n@[inline] def hiddenRuntime : Bool := true","message":"runtime declaration after proof boundary","name":"character-before-attributed-runtime"},"new_name":"character-before-attributed-runtime","old_case":{"exit":3,"late_runtime":"theorem quoteChar : '\"' = '\"' := rfl\n@[inline] def hiddenRuntime : Bool := true","message":"runtime declaration after proof boundary","name":"character-before-attributed-runtime"},"old_name":"character-before-attributed-runtime"},{"expected_exit":0,"new_case":{"exit":0,"late_runtime":"theorem rawWords : r#\"def \"macro\"\"# = r#\"def \"macro\"\"# := rfl\ntheorem quoteChar : '\"' = '\"' := rfl","message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"proof-raw-string-character-sibling"},"new_name":"proof-raw-string-character-sibling","old_case":{"exit":0,"late_runtime":"theorem rawWords : r#\"def \"macro\"\"# = r#\"def \"macro\"\"# := rfl\ntheorem quoteChar : '\"' = '\"' := rfl","message":"DISCRIMINATES: 1 mutants and one nonempty unchanged control","name":"proof-raw-string-character-sibling"},"old_name":"proof-raw-string-character-sibling"},{"expected_exit":3,"new_case":{"exit":3,"message":"empty mutation inventory","name":"empty-mutation-inventory","spec":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[],"positive_checks":["runner_positive"],"schema_version":1}},"new_name":"empty-mutation-inventory","old_case":{"exit":3,"message":"empty mutation inventory","name":"empty-mutation-inventory","spec":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[],"positive_checks":["runner_positive"],"schema_version":1}},"old_name":"empty-mutation-inventory"}],"default_spec":{"new":{"modules":["DefiKernel.Interface.RunnerInput","DefiKernel.Interface.Audit"],"mutations":[{"module":"DefiKernel.Interface.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1},"old":{"modules":["DefiKernel.Metatheory.RunnerInput","DefiKernel.Metatheory.Audit"],"mutations":[{"module":"DefiKernel.Metatheory.RunnerInput","name":"probe","needle":"n ≤ 4","replacement":"n ≤ 5","required_false":["runner_sensitivity"]}],"positive_checks":["runner_positive"],"schema_version":1}},"executed_predecessor":{"candidate":"eec499d613688137a341f3556cd80ca461dd2ee9","new_Interface_controls_executed":false,"note":"Actual Metatheory control run is bound without relabeling; accepted Sprint9 delivery remains pending.","passed":65,"summary_path":"review/semantic-kernel/sprint9/implementation/runner-controls-r2/summary.json","summary_sha256":"c5020eb52e30abc554fcae9b0899820ce6504fd46c088a69f9461c2f5cb9a6db","total":65},"financial_detection_claim":false,"fixture_templates":{"AUDIT":{"new":"import DefiKernel.Interface.RunnerInput\n\nnamespace DefiKernel.Interface\n\nopen Lean Elab Command in\nrun_cmd do\n  let checks : List (String × Bool) := CHECKS\n  for (name, value) in checks do\n    liftIO <| IO.println s!\"{name}: {value}\"\n  let failures := (checks.filter (fun pair => !pair.2)).length\n  if failures > 0 then\n    throwError \"Interface runtime comparisons failed: {failures}\"\n\nend DefiKernel.Interface\n","old":"import DefiKernel.Metatheory.RunnerInput\n\nnamespace DefiKernel.Metatheory\n\nopen Lean Elab Command in\nrun_cmd do\n  let checks : List (String × Bool) := CHECKS\n  for (name, value) in checks do\n    liftIO <| IO.println s!\"{name}: {value}\"\n  let failures := (checks.filter (fun pair => !pair.2)).length\n  if failures > 0 then\n    throwError \"Metatheory runtime comparisons failed: {failures}\"\n\nend DefiKernel.Metatheory\n"},"AUDIT_MODULE":{"new":"DefiKernel.Interface.Audit","old":"DefiKernel.Metatheory.Audit"},"CHECKS":{"new":"if runnerIncludeSensitivity then\n    [(\"runner_positive\", runnerAllows 0), (\"runner_sensitivity\", !runnerAllows 5)]\n    else [(\"runner_positive\", runnerAllows 0)]","old":"if runnerIncludeSensitivity then\n    [(\"runner_positive\", runnerAllows 0), (\"runner_sensitivity\", !runnerAllows 5)]\n    else [(\"runner_positive\", runnerAllows 0)]"},"DEPENDENCY":{"new":"import Mathlib.Data.Nat.Basic\nnamespace DefiKernel.Interleaving\ndef runnerDependency : Nat := 4\n-- BEGIN PROOFS\ntheorem runnerDependency_value : runnerDependency = 4 := rfl\nend DefiKernel.Interleaving\n","old":"import Mathlib.Data.Nat.Basic\nnamespace DefiKernel.Interleaving\ndef runnerDependency : Nat := 4\n-- BEGIN PROOFS\ntheorem runnerDependency_value : runnerDependency = 4 := rfl\nend DefiKernel.Interleaving\n"},"INPUT":{"new":"import DefiKernel.Interleaving.RunnerDependency\n\nnamespace DefiKernel.Interface\n\nexample : DefiKernel.Interleaving.runnerDependency = 4 := DefiKernel.Interleaving.runnerDependency_value\n\ndef runnerAllows (n : Nat) : Bool := n ≤ 4\ndef runnerIncludeSensitivity : Bool := true\n-- compiler-control\n\n-- BEGIN PROOFS\n\ntheorem runnerAllows_zero : runnerAllows 0 = true := by decide\n\nend DefiKernel.Interface\n","old":"import DefiKernel.Interleaving.RunnerDependency\n\nnamespace DefiKernel.Metatheory\n\nexample : DefiKernel.Interleaving.runnerDependency = 4 := DefiKernel.Interleaving.runnerDependency_value\n\ndef runnerAllows (n : Nat) : Bool := n ≤ 4\ndef runnerIncludeSensitivity : Bool := true\n-- compiler-control\n\n-- BEGIN PROOFS\n\ntheorem runnerAllows_zero : runnerAllows 0 = true := by decide\n\nend DefiKernel.Metatheory\n"},"INPUT_MODULE":{"new":"DefiKernel.Interface.RunnerInput","old":"DefiKernel.Metatheory.RunnerInput"},"PRODUCTION_AUDIT":{"new":"import DefiKernel.Interface.RunnerInput\nnamespace DefiKernel.Interface.Audit\ndef main : IO Unit := do\n  let checks : List (String × Bool) := CHECKS\n  if checks.isEmpty then throw (IO.userError \"Interface runtime comparisons empty\")\n  if !(checks.map Prod.fst).Nodup then\n    throw (IO.userError \"Interface runtime comparison names are duplicated\")\n  for (name, passed) in checks do IO.println s!\"{name}: {passed}\"\n  let failures := checks.filter (!·.2) |>.map Prod.fst\n  if !failures.isEmpty then\n    throw (IO.userError s!\"Interface runtime comparisons failed: {failures.length}\")\n#eval main\n\n-- BEGIN PROOFS\n\nend DefiKernel.Interface.Audit\n","old":"import DefiKernel.Metatheory.RunnerInput\nnamespace DefiKernel.Metatheory.Audit\ndef main : IO Unit := do\n  let checks : List (String × Bool) := CHECKS\n  if checks.isEmpty then throw (IO.userError \"Metatheory runtime comparisons empty\")\n  if !(checks.map Prod.fst).Nodup then\n    throw (IO.userError \"Metatheory runtime comparison names are duplicated\")\n  for (name, passed) in checks do IO.println s!\"{name}: {passed}\"\n  let failures := checks.filter (!·.2) |>.map Prod.fst\n  if !failures.isEmpty then\n    throw (IO.userError s!\"Metatheory runtime comparisons failed: {failures.length}\")\n#eval main\n\n-- BEGIN PROOFS\n\nend DefiKernel.Metatheory.Audit\n"}},"global_positive_checks":["interface.positive.transfer","interface.positive.empty-query"],"inspected_candidate":"eec499d613688137a341f3556cd80ca461dd2ee9","path_map":{"lean/DefiKernel/Metatheory":"lean/DefiKernel/Interface","mutations/metatheory.json":"mutations/interface.json","scripts/check_metatheory_mutations.py":"scripts/run_interface_mutations.py","scripts/test_metatheory_mutation_runner.py":"scripts/test_interface_mutation_runner.py"},"patterns":[{"new_value":"DefiKernel\\.Interface(?:\\.[A-Za-z][A-Za-z0-9]*)+","old":"module","value":"DefiKernel\\.Metatheory(?:\\.[A-Za-z][A-Za-z0-9]*)+"},{"new_value":"\\n(end DefiKernel\\.Interface(?:\\.[A-Za-z][A-Za-z0-9]*)*)\\s*$","old":"end_namespace","value":"\\n(end DefiKernel\\.Metatheory(?:\\.[A-Za-z][A-Za-z0-9]*)*)\\s*$"},{"new_value":"\n-- BEGIN PROOFS\n","old":"proof_marker","value":"\n-- BEGIN PROOFS\n"},{"new_value":"DefiKernel.Interface.","old":"scope_prefix","value":"DefiKernel.Metatheory."},{"new_value":"error: Interface runtime comparisons failed: {count}","old":"failed_count","value":"error: Metatheory runtime comparisons failed: {count}"},{"new_value":"Interface runtime comparisons empty","old":"empty","value":"Metatheory runtime comparisons empty"},{"new_value":"Interface runtime comparison names are duplicated","old":"duplicate","value":"Metatheory runtime comparison names are duplicated"},{"new_value":"missing Interface audit root","old":"missing_root","value":"missing Metatheory audit root"},{"new_value":"            forbidden = re.search(\n                r'\\b(?:def|abbrev|opaque|instance|structure|inductive|class|axiom|constant|'\n                r'macro|macro_rules|syntax|declare_syntax_cat|elab|elab_rules|'\n                r'initialize|builtin_initialize|run_cmd|attribute|notation|infix|infixl|'\n                r'infixr|prefix|postfix)\\b|#(?:eval|reduce|run)\\b', tail_code)\n","old":"forbidden_tail_source","value":"            forbidden = re.search(\n                r'\\b(?:def|abbrev|opaque|instance|structure|inductive|class|axiom|constant|'\n                r'macro|macro_rules|syntax|declare_syntax_cat|elab|elab_rules|'\n                r'initialize|builtin_initialize|run_cmd|attribute|notation|infix|infixl|'\n                r'infixr|prefix|postfix)\\b|#(?:eval|reduce|run)\\b', tail_code)\n"}],"per_mutant_siblings":"planned-mutations.json records all14 row-specific contracts; separate assertion matrix checks actual saved output, schema global positives unchanged","prior_adaptation_sha256":"37da620f356562e385239f559835cbae97208714e700d485cf7d3150c16f23e4","source_hashes":{"mutations/metatheory.json":"bd5f6269777ac4bd7d6a3192d82dffd386ca5bfc135dd662b3076f26860a42fc","scripts/check_metatheory_mutations.py":"d08707060c875b6834beaa5cc17e780f97f39b755962ed3a26ca176a94e4314a","scripts/test_metatheory_mutation_runner.py":"19d234039a5d37f2eacd2dc328d17ddd66f57879833a24ff27de9d686bcf1e26"},"status":"accepted_predecessor_exact_adaptation_contract_not_new_execution","timeouts":{"outer_harness_seconds":1500,"runner_argument":["--timeout-seconds","600"],"timeout_result":"blocked; preserve partial outer output and honest absence of normal inner command completion record"},"utc":"2026-09-07T18:54:01.968260+00:00"}

## END FILE

## FILE review/semantic-kernel/sprint10/planning/official-preparation/source-context.json

Original SHA256: b4d8b1d3752e69030981b1975b7529969f88ff27866927a38564da598623acca; bytes: 8652; rendered SHA256: 896401e7d7564273155f7853a4ae0ebba941fe59c356f6c783f20b15d26d3e16

{"bindings":[{"bytes":4499,"git_blob":"fd5c617ee1c7b7ff56092218e55b0c3ce2ac1da8","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Typed/Types.lean","sha256":"5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82"},{"bytes":13533,"git_blob":"f7fb9de0cb97cc9e003bf487d742ec902250efc9","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Typed/Authority.lean","sha256":"dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb"},{"bytes":21986,"git_blob":"344109d8e783c2b80f1385fa39f0a4b923b0d07c","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Typed/Transition.lean","sha256":"73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2"},{"bytes":12415,"git_blob":"a45abc9035cd5882f58814c089ce151f0f2bbc51","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Composition/Interfaces.lean","sha256":"4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe"},{"bytes":21579,"git_blob":"f94f22503551dc7cbc965459626a33435ac512cc","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Composition/Execution.lean","sha256":"34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602"},{"bytes":10173,"git_blob":"ffdfd5b29d8123c2f49cc2262fc199100794074f","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Composition/Sequence.lean","sha256":"32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729"},{"bytes":3446,"git_blob":"a1f8cf7753180fdea9ae0f8095fae1e0d2ec792e","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Composition/Contracts.lean","sha256":"d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c"},{"bytes":10344,"git_blob":"21eb3370867603b6d58c247f78840984dca0dbc6","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Composition/Preservation.lean","sha256":"7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709"},{"bytes":3951,"git_blob":"b036e4b4845de910f98d6cb4cb76d9911e78fcec","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Atomic/Policy.lean","sha256":"5b643cbb1b1263ffacb20892afe3f9ec1067191e733f08c3f4040bbe17fa2612"},{"bytes":10199,"git_blob":"774b02bd2f5b958bd8175b6e486ef66a4cbfd2de","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Atomic/Settlement.lean","sha256":"c27cf9eebfce49357e14c963ab2c0ec4a920b3e26d700f85ad8d51cbb6315ca5"},{"bytes":10494,"git_blob":"8b77292fef0f3c0a1d127099151b8eff01573ec9","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Interleaving/Soundness.lean","sha256":"f696f995190cd7a6729e536efe1cc7875239625de1070d830c0649061e432337"},{"bytes":4623,"git_blob":"b88923fb3c99e71389b64f7648edcd78b5f18d1a","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Interleaving/Interference.lean","sha256":"e6bc0a1ffbceebb27973d547f2d3b808bc15d6c857e03644c9fa5eeb54ecef90"},{"bytes":7391,"git_blob":"9e929cba38ef372286b54b2c3fb3fd538e8a23bc","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/Defialgebra/Interface.lean","sha256":"e77ab27a5f9c2bf065805bab5a38fcfc8aa46e32ff1979dd8c2682fcb4331bd8"},{"bytes":6238,"git_blob":"cddfae4195564e9cfca9b26a8b407b89fc89e4b5","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/Defialgebra/Nary.lean","sha256":"31b42f37aa3b357554c33f0563a0042a94dd618a63d5771c02aa310cab919680"},{"bytes":29,"git_blob":"c084c7fbe586b0276863b66f16d2955a43bc3fc6","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/lean-toolchain","sha256":"0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6"},{"bytes":414,"git_blob":"3bf93ee79697e086fda3a57b2fb7df069c25eb3c","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/lakefile.toml","sha256":"4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86"},{"bytes":32771,"git_blob":"31d311b5527b7ee180f8746c1314f5b373274242","git_revision":"c16832941c18229e51fade7c496b16146bb810bd","matches_git_bytes":true,"path":"scripts/test_metatheory_mutation_runner.py","sha256":"19d234039a5d37f2eacd2dc328d17ddd66f57879833a24ff27de9d686bcf1e26"},{"bytes":3419,"git_blob":"e4f8fb88a1dbc394c6ab33f9e5971cd33b17865d","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Metatheory/SequentialGroups.lean","sha256":"935174d28f898520f6f81f1643a9b5c8ed708f3b32c10d620febe173d015fea7"},{"bytes":7070,"git_blob":"b8e1120d87dbf83a93fe157b495a51d48718d3ea","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Metatheory/Observation.lean","sha256":"6ceedf99d806d8510fb609c94b2be2d8250c7453e12453d4ed11756d6238553b"},{"bytes":4009,"git_blob":"9d1da108d26dbadc8a60a1f86e08aff55f4fa05a","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Metatheory/Contexts.lean","sha256":"6c0539645086ffe51e3668621ca7fa08d7937b6d590c3d9b3c6c649c79eac743"},{"bytes":12353,"git_blob":"22f604bb3358d5ca6ee9a121fd5204381ab2c0bb","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Metatheory/Configuration.lean","sha256":"d5bc155b46922606f765b2e9cd80b5d33d4b542b8cd6a39a3cb790f87776dce5"},{"bytes":2338,"git_blob":"f71b88fc77199692f310d9aa3d3fbbc06852d43e","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Metatheory/ConfigurationGroups.lean","sha256":"04b7f23b0b74b30f0010d59e716f3aead7884f2d8ac9b9885a5143be0fe4fe31"},{"bytes":12068,"git_blob":"924c01901471ac9bbb37f69b2bdd6df64f2b200c","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"lean/DefiKernel/Metatheory/OperatorLifting.lean","sha256":"5def40dbdc48471166e921e987845b425f5a739cc7dc883422e2b13e535e2dee"},{"bytes":20703,"git_blob":"00b616f29f99832fa0d805cd7ef48625bfa48ea8","git_revision":"c16832941c18229e51fade7c496b16146bb810bd","matches_git_bytes":true,"path":"scripts/check_metatheory_mutations.py","sha256":"d08707060c875b6834beaa5cc17e780f97f39b755962ed3a26ca176a94e4314a"},{"bytes":5619,"git_blob":"20aa05c3cca55860f43ab22e21b2fd51307df304","git_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","matches_git_bytes":true,"path":"mutations/metatheory.json","sha256":"bd5f6269777ac4bd7d6a3192d82dffd386ca5bfc135dd662b3076f26860a42fc"}],"inspected_revision":"eec499d613688137a341f3556cd80ca461dd2ee9","observed_head":"c16832941c18229e51fade7c496b16146bb810bd","required_refresh":"recheck actual group-simulation/API/control closure if inputs change","status":"accepted_delivered_M1_source"}

## END FILE

## FILE review/semantic-kernel/sprint10/planning/official-preparation/strict-validation.stderr

Original SHA256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855; bytes: 0; rendered SHA256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855


## END FILE

## FILE review/semantic-kernel/sprint10/planning/official-preparation/strict-validation.stdout

Original SHA256: 8a71cb05d4f26b39137f15e10d45d755cf4179c1682cdd33d1633339850a9681; bytes: 61; rendered SHA256: 8a71cb05d4f26b39137f15e10d45d755cf4179c1682cdd33d1633339850a9681

Change 'operational-interface-binding-preservation' is valid

## END FILE

## FILE review/semantic-kernel/sprint10/planning/official-preparation/validate-author.py

Original SHA256: 01d3ec98f5897b9e244e3839a2eca3d3925f95ae7bd79021e000e0d299187a86; bytes: 7913; rendered SHA256: 01d3ec98f5897b9e244e3839a2eca3d3925f95ae7bd79021e000e0d299187a86

#!/usr/bin/env python3
"""Bounded planning author validation. Does not run Lean, mutations or native reviews."""
import hashlib, json, re, runpy, shutil, subprocess, sys
from pathlib import Path
from datetime import datetime,timezone
ROOT=Path(__file__).resolve().parents[5]; OUT=Path(__file__).resolve().parent
CHANGE=ROOT/'openspec/changes/operational-interface-binding-preservation'
now=lambda:datetime.now(timezone.utc).isoformat()
sha=lambda b:hashlib.sha256(b).hexdigest()
record=lambda p:dict(path=str(p.relative_to(ROOT)),bytes=p.stat().st_size,sha256=sha(p.read_bytes()))
started=now();head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
planfiles=[*sorted(CHANGE.rglob('*')),ROOT/'wiki-llm/sprint-10-operational-interface-bindings-outline.md',OUT/'build-author-evidence.py',Path(__file__)]
planfiles=[p for p in planfiles if p.is_file()]
before={str(p.relative_to(ROOT)):record(p) for p in planfiles}
commands=[]
def command(argv,name):
    begin=now();r=subprocess.run(argv,cwd=ROOT,text=True,capture_output=True)
    for kind,value in [('stdout',r.stdout),('stderr',r.stderr)]: (OUT/f'{name}.{kind}').write_text(value)
    commands.append(dict(argv=argv,cwd=str(ROOT),started_utc=begin,finished_utc=now(),exit=r.returncode,stdout=record(OUT/f'{name}.stdout'),stderr=record(OUT/f'{name}.stderr')))
    assert r.returncode==0,(name,r.stderr)
    return r.stdout
command([sys.executable,str(OUT/'build-author-evidence.py')],'coverage')
exe=Path(shutil.which('openspec')).resolve()
version=command([str(exe),'--version'],'openspec-version').strip()
command([str(exe),'validate','operational-interface-binding-preservation','--strict'],'strict-validation')
status=json.loads(command([str(exe),'status','--change','operational-interface-binding-preservation','--json'],'status'))
runner=ROOT/'scripts/test_metatheory_mutation_runner.py'
ns=runpy.run_path(str(runner),run_name='m2_planning_control_inspection')
cases=ns['cases'](); names=[c['name'] for c in cases]
assert len(names)==len(set(names)) and len(names)==65
controls=dict(status='S10_adaptation_catalog_not_executed_S9_predecessor65_completed',source=record(runner),refresh='Accepted S9 source/evidence/delivery and actual65 executions are bound in dependency-baseline.json; these adapted S10 cases remain unexecuted. Recheck if source changes',cases=[dict(old_name=c['name'],planned_new_name=c['name'].replace('metatheory','interface'),expected_exit=c['exit'],message=c.get('message'),production_form=bool(c.get('production_audit'))) for c in cases])
(OUT/'inherited-controls.json').write_text(json.dumps(controls,indent=2)+'\n')
source_paths=['lean/DefiKernel/Typed/Types.lean','lean/DefiKernel/Typed/Authority.lean','lean/DefiKernel/Typed/Transition.lean','lean/DefiKernel/Composition/Interfaces.lean','lean/DefiKernel/Composition/Execution.lean','lean/DefiKernel/Composition/Sequence.lean','lean/DefiKernel/Composition/Contracts.lean','lean/DefiKernel/Composition/Preservation.lean','lean/DefiKernel/Atomic/Policy.lean','lean/DefiKernel/Atomic/Settlement.lean','lean/DefiKernel/Interleaving/Soundness.lean','lean/DefiKernel/Interleaving/Interference.lean','lean/Defialgebra/Interface.lean','lean/Defialgebra/Nary.lean','lean/lean-toolchain','lean/lakefile.toml','scripts/test_metatheory_mutation_runner.py']
source_paths += ['lean/DefiKernel/Metatheory/SequentialGroups.lean','lean/DefiKernel/Metatheory/Observation.lean','lean/DefiKernel/Metatheory/Contexts.lean','lean/DefiKernel/Metatheory/Configuration.lean','lean/DefiKernel/Metatheory/ConfigurationGroups.lean','lean/DefiKernel/Metatheory/OperatorLifting.lean','scripts/check_metatheory_mutations.py','mutations/metatheory.json']
source=[];base='eec499d613688137a341f3556cd80ca461dd2ee9'
for rel in source_paths:
    p=ROOT/rel
    if not p.exists() and rel=='lean/lakefile.toml': rel='lean/lakefile.lean';p=ROOT/rel
    revision=head if rel.startswith('scripts/') else base
    data=p.read_bytes();git=subprocess.check_output(['git','show',f'{revision}:{rel}'],cwd=ROOT)
    assert data==git,rel
    source.append({**record(p),'git_revision':revision,'git_blob':subprocess.check_output(['git','rev-parse',f'{revision}:{rel}'],cwd=ROOT,text=True).strip(),'matches_git_bytes':True})
(OUT/'source-context.json').write_text(json.dumps(dict(status='accepted_delivered_M1_source',observed_head=head,inspected_revision=base,bindings=source,required_refresh='recheck actual group-simulation/API/control closure if inputs change'),indent=2)+'\n')
design=(CHANGE/'design.md').read_text()
mutants=[]
for line in design.splitlines():
    if re.match(r'^\| M\d\d \|',line):
        _,mid,site,oracle,positive,_=[s.strip() for s in line.split('|')]
        mutants.append(dict(id=mid,planned_site=site,designated_comparison=oracle,protected_sibling=positive,status='planned_not_executed'))
assert [m['id'] for m in mutants]==[f'M{i:02}' for i in range(1,15)]
(OUT/'planned-mutations.json').write_text(json.dumps(dict(status='design_only_no_detection_claim',mutants=mutants),indent=2)+'\n')
coverage=json.loads((OUT/'author-coverage.json').read_text())
assert coverage['counts']['checked_tasks']==0
assert not (ROOT/'lean/DefiKernel/Interface').exists()
assert not (ROOT/'lean/DefiKernel/Verify.lean').exists()
assert all('TODO' not in p.read_text() and 'TBD' not in p.read_text() for p in CHANGE.rglob('*.md'))
assert 'Opus' not in ''.join(p.read_text() for p in CHANGE.rglob('*.md'))
assert 'private-total and deliberately exposed-total variants are separate valid catalogs' in design.lower()
assert 'Region home/USD {Alice,Bob,Carol}' in design
assert len(re.findall(r'^\| F\d\d \|',design,re.M))==20
# Independent arithmetic consistency only; these are not executed kernel fixtures.
assert [6-2,4+2]==[4,6] and (4+6)==10
assert [6-1-2,4+3]==[3,7] and -1-2==-3
assert [5-1,5-1,0+2]==[4,4,2] and sum([4,4,2])==10
assert [5-2,5-2,0+4]==[3,3,4] and sum([3,3,4])==10
assert 10+1==11 and 6+4==10
assert 4+4/2==6 and 6-4/2==4
assert 4-7<0 and 3-7<0
assert all((ROOT/r['path']).read_bytes()==subprocess.check_output(['git','show',f"{r['git_revision']}:{r['path']}"],cwd=ROOT) for r in source)
after={str(p.relative_to(ROOT)):record(p) for p in planfiles}; assert before==after
checks=dict(strict_openspec_passed=True,all_tasks_unchecked=True,all_requirements_and_scenarios_mapped=True,all_tasks_covered=True,concrete_mutation_pairs14=True,fixture_contracts20=True,actual_control_catalog65_inspected_not_run=True,arithmetic_consistency_only=True,selected_sources_match_inspected_git_before_after=True,plan_inputs_unchanged_during_validation=True,Interface_source_absent=True,real_root_target=True,no_native_review_performed=True,no_implementation_performed=True,official_freeze_not_performed=True,accepted_Sprint9_dependency_bound_recheck_required=True)
result=dict(status='planning_author_validation_passed_independent_gate_not_performed',started_utc=started,finished_utc=now(),observed_head=head,counts={**coverage['counts'],'fixture_contracts':20,'inspected_controls':len(cases)},checks=checks,commands=commands,tools=dict(openspec_path=str(exe),openspec_sha256=sha(exe.read_bytes()),openspec_version=version,python_path=str(Path(sys.executable).resolve()),python_sha256=sha(Path(sys.executable).resolve().read_bytes()),python_version=sys.version),plan_bindings=before,source_context='source-context.json',author_only=True,remaining_gates=['revalidate accepted S9 source/delivery binding','same-candidate S10 planning acceptance','official planning bundle freeze','nonauthor GPT-6 and native Fable5.1 medium planning acceptance','implementation and all proof/runtime/mutation/regression evidence','native Grok/Fable5.1-medium source/evidence acceptance','archive and verified delivery'])
(OUT/'author-validation.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(status=result['status'],counts=result['counts'],checks=len(checks)),sort_keys=True))

## END FILE

## FILE review/semantic-kernel/sprint10/planning/sprint9-checkpoint-remote.json

Original SHA256: 5887d7e91f7c475738751df42e7c65ec0c10160c010b454e6ecf809b6c5c5cb4; bytes: 299; rendered SHA256: db4568602563beda9724018ad95d3ac425e69b0294d8eb2bf68cfe156b1554b1

{"archive":"9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","head":"c16832941c18229e51fade7c496b16146bb810bd","matches":true,"remote":"c16832941c18229e51fade7c496b16146bb810bd","source":"eec499d613688137a341f3556cd80ca461dd2ee9","verified_utc":"2026-09-07T19:15:30.544093+00:00"}

## END FILE

## FILE review/semantic-kernel/sprint9/acceptance/final-acceptance.json

Original SHA256: 78f0b65492a0936c0fbd5f08daf06ae5ed3d3669654d8796a17cea9623af3bf9; bytes: 5416; rendered SHA256: 67b5648252d55c7884915edce568f136eeeb86574d17c21c89a1f4d98ecf87bc

{"accepted_utc":"2026-09-07T19:06:05.609457+00:00","actual_execution_identities":{"Lean_integration_proof_mutations_controls":"eec499d613688137a341f3556cd80ca461dd2ee9","legacy13":"c880acf62944746ff9a376afc0c0050702f037f7; exact relevant-source/tool equivalence to successor"},"candidate":"eec499d613688137a341f3556cd80ca461dd2ee9","closed_final_findings":[{"id":"Fable-R1","resolution":"Current scenario status excludes historical development pending prose; original frozen records preserved, historical prose explicitly scoped separately in accepted-scenarios.json. Final archived/delivered scenario overlay is final-scenarios.json."},{"id":"Fable-R2","resolution":"Only two global positives are enforced by the production runner. Fourteen per-mutant siblings are separately measured and checked in postexecution evidence reconciliation, not runner-protected controls."},{"id":"Fable-R3","resolution":"EVIDENCE.md displays actual world/history matrix T/T,F/T,F/F. Explanation of literal continuation after history reset is source reasoning, not an additional measured oracle or diagonal classifier."}],"delivery":{"archive":"openspec/changes/archive/2026-09-07-operational-continuation-congruence","archive_commit":"9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","branch":"semantic-kernel-pivot","main_merged":false,"remote_head":"9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","remote_matches":true,"requirements_preserved":17,"scenarios_preserved":55,"source_candidate":"eec499d613688137a341f3556cd80ca461dd2ee9","source_evidence_commit":"ec9ed80457d7a9c4064d26ab193591579027abae","substantive_reviews":"Native Grok and Fable5.1 medium ACCEPT WITH LIMITATIONS","tasks_complete":35,"verified_utc":"2026-09-07T19:12:22.751477+00:00"},"delivery_complete":true,"limits":["No final candidate acceptance, official production detections, final regressions, final imported inventory or native verdict is inferred from these development passes.","Configuration agreement is a universal strong premise over one shared identity universe; it is not a checker, arbitrary extension or deployed fidelity.","Full cursor observation intentionally omits old raw worlds. Synthetic observer pairs are not claims of two reachable traces.","Named executed counterexamples are runtime evidence, not newly certified counterexample theorems.","Generic simulation/associativity proofs preserve actual full cursor and leaf order; no boundary movement or shared commutation follows.","No old execution is relabelled as a new run. All attached actual execution records retain their measured candidate and commands."],"original_scenario_projection":{"path":"review/semantic-kernel/sprint9/final-review-r2/scenario-map-review.json","sha256":"f2d77c054f1067a659b9656067a84e59a4f0c0ccd9a641569a4b7b7382664c30"},"presentation":"Grok accepted the complete canonical bundle739723; Fable initial same-bundle attempt exceeded1M context and gave no verdict. Fable accepted projection831494 of identical underlying source/evidence, retaining every source verbatim and exact complete runtime outcomes. Presentation rules and canonical3683-input bindings retained. No source or execution substitution.","prior_acceptance_record":{"path":"review/semantic-kernel/sprint9/acceptance/acceptance.json","sha256":"9a613a299da79575893cbc42f9aa347909d5174f78aad07fb71e179b184c5c49"},"reviews":[{"bundle_sha256":"739723649ae7b420d9c0c21c1554af0a1eaff9ce13a5a1563c26c05264660d5b","candidate":"eec499d613688137a341f3556cd80ca461dd2ee9","effort":"medium","invocation":"review/semantic-kernel/sprint9/native-review-r2/final-grok.invocation.json","invocation_sha256":"c9db7c8d280654ec4d673713960ccfdaf1bf23239f03038b7b87bfb750135d7b","provider":"grok","report":"review/semantic-kernel/sprint9/native-review-r2/final-grok.md","report_sha256":"c6000606de401b3d4200789f082fc660492e8c4e4063ae9b757d79572b6761f7","reported_models":["grok-4.6-build"],"requested_model":"grok-4.6","scope":"corrected source and completed execution evidence; advisory inspection, no independent execution","verdict":"ACCEPT WITH LIMITATIONS"},{"bundle_sha256":"83149453256bf8629586d2e666bfba60d3d28a8bed91f6be7de2f897d745981a","candidate":"eec499d613688137a341f3556cd80ca461dd2ee9","effort":"medium","invocation":"review/semantic-kernel/sprint9/native-review-r2-compact/final-fable.invocation.json","invocation_sha256":"fcf45a4008b85c8efdc6d7f5b6a61271b37bc9cbcb008f4679f570b5cf770991","provider":"fable","report":"review/semantic-kernel/sprint9/native-review-r2-compact/final-fable.md","report_sha256":"0c3ee50c4dc39ecdaf6ed3a11e013288a9dcb726f98da5f76a4b9d01aaaf00b1","reported_models":["claude-fable-5-1"],"requested_model":"claude-fable-5-1[1m]","scope":"corrected source and completed execution evidence; advisory inspection, no independent execution","verdict":"ACCEPT WITH LIMITATIONS"}],"scenario_count":55,"substantive_source_and_evidence_accepted":true}

## END FILE

## FILE review/semantic-kernel/sprint9/archive-delivery.json

Original SHA256: 66fff02477ab51d4a3f28c1553ee52938dd6f73a8ffebf9929f1c04a06a5a0d8; bytes: 664; rendered SHA256: fdc888247c447be30383899bce3d8dd79ca1a4d34315c1478d21914731024f4b

{"archive":"openspec/changes/archive/2026-09-07-operational-continuation-congruence","archive_commit":"9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","branch":"semantic-kernel-pivot","main_merged":false,"remote_head":"9908d9b56be2d5ed2b58a16fa8d28b23f33733ff","remote_matches":true,"requirements_preserved":17,"scenarios_preserved":55,"source_candidate":"eec499d613688137a341f3556cd80ca461dd2ee9","source_evidence_commit":"ec9ed80457d7a9c4064d26ab193591579027abae","substantive_reviews":"Native Grok and Fable5.1 medium ACCEPT WITH LIMITATIONS","tasks_complete":35,"verified_utc":"2026-09-07T19:12:22.751477+00:00"}

## END FILE

## FILE scripts/check_metatheory_mutations.py

Original SHA256: d08707060c875b6834beaa5cc17e780f97f39b755962ed3a26ca176a94e4314a; bytes: 20703; rendered SHA256: d08707060c875b6834beaa5cc17e780f97f39b755962ed3a26ca176a94e4314a

#!/usr/bin/env python3
"""Replay the actual metatheory Lean implementation under explicit source mutations.

The specification names an ordered, nonempty list of source modules, mutation
sites, required false observations and protected positive controls. Proof-only
suffixes are excluded from temporary execution copies, never from accepted files.
Exit 0: nonempty control and all sensitivity assertions pass; 1: failed assertion;
3: unavailable evidence, malformed specification or compilation/setup failure.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import time
from datetime import datetime, timezone


CHECK_NAME = r'[a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*'


class Blocked(Exception):
    pass


def require(value, message):
    if not value:
        raise Blocked(message)


def check(value, message):
    if not value:
        raise AssertionError(message)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def read(path):
    raw = path.read_bytes()
    require(raw.strip(), f'empty required input: {path}')
    return raw


def parse(raw):
    def pairs(items):
        value = {}
        for key, item in items:
            require(key not in value, f'duplicate JSON key: {key}')
            value[key] = item
        return value
    return json.loads(raw, object_pairs_hook=pairs)


def proof_tail_code(source, module):
    """Mask comments and literals for a conservative, bounded command-token guard.

    This is not Lean parsing or macro expansion. In particular an invocation of
    an arbitrary command macro defined before the marker needs source review.
    Masking preserves newlines and cannot join separate tokens accidentally.
    """
    masked = list(source)
    raw_pattern = re.compile(r'r(#+)?"')
    char_pattern = re.compile(r"'(?:\\(?:x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4}|.)|[^'\\\n])'")
    index = 0
    while index < len(source):
        start = index
        if source.startswith('--', index):
            end = source.find('\n', index)
            index = len(source) if end < 0 else end
        elif source.startswith('/-', index):
            depth = 1
            index += 2
            while index < len(source) and depth:
                if source.startswith('/-', index):
                    depth += 1
                    index += 2
                elif source.startswith('-/', index):
                    depth -= 1
                    index += 2
                else:
                    index += 1
            require(depth == 0, f'{module}: unterminated proof-tail comment')
        else:
            raw = raw_pattern.match(source, index) if (
                index == 0 or not (source[index - 1].isalnum() or source[index - 1] == '_')) else None
            char = char_pattern.match(source, index)
            if raw:
                closing = '"' + (raw.group(1) or '')
                end = source.find(closing, raw.end())
                require(end >= 0, f'{module}: unterminated proof-tail raw string')
                index = end + len(closing)
            elif char:
                index = char.end()
            elif source[index] == '"':
                index += 1
                while index < len(source) and source[index] != '"':
                    index += 2 if source[index] == '\\' else 1
                require(index < len(source), f'{module}: unterminated proof-tail string')
                index += 1
            else:
                index += 1
                continue
        masked[start:index] = ['\n' if c == '\n' else ' ' for c in source[start:index]]
    return ''.join(masked)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--spec', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--timeout-seconds', type=int, default=600,
                        help='Per Lean/Git command timeout (default: 600 seconds)')
    args = parser.parse_args()
    require(args.timeout_seconds > 0, 'timeout must be positive')
    started = datetime.now(timezone.utc).isoformat()
    repo, out = args.repo.resolve(), args.out.resolve()
    require(not out.is_relative_to(repo), 'evidence output must be outside the repository')
    require(not args.out.exists() and not args.out.is_symlink(), 'output already exists')
    spec_raw = read(args.spec)
    spec = parse(spec_raw)
    require(isinstance(spec, dict) and set(spec) ==
            {'schema_version', 'modules', 'mutations', 'positive_checks'},
            'invalid mutation specification fields')
    require(type(spec['schema_version']) is int and spec['schema_version'] == 1,
            'unsupported mutation specification version')
    modules, mutations, positives = spec['modules'], spec['mutations'], spec['positive_checks']
    require(isinstance(modules, list) and modules, 'empty module inventory')
    require(isinstance(mutations, list) and mutations, 'empty mutation inventory')
    require(isinstance(positives, list) and positives, 'empty positive-control inventory')
    require(len(set(modules)) == len(modules), 'duplicate source module')
    require(len(set(positives)) == len(positives), 'duplicate positive control')
    require(all(isinstance(name, str) and re.fullmatch(CHECK_NAME, name)
                for name in positives), 'invalid positive check name')
    require('DefiKernel.Metatheory.Audit' in modules, 'missing Metatheory audit root')
    names = [m['name'] for m in mutations]
    require(len(set(names)) == len(names), 'duplicate mutation name')
    for m in mutations:
        require(isinstance(m, dict) and set(m) ==
                {'name', 'module', 'needle', 'replacement', 'required_false'},
                'invalid mutation fields')
        require(re.fullmatch(r'[a-z][a-z0-9-]*', m['name']), 'invalid mutation name')
        require(m['name'] not in {'control', 'lean-version', 'lean-path', 'git-head',
                                  'git-root-input-status'}, 'reserved variant name')
        require(m['module'] in modules, 'mutation module outside inventory')
        require(isinstance(m['needle'], str) and m['needle'], 'empty mutation needle')
        require(isinstance(m['replacement'], str) and m['replacement'] != m['needle'],
                'mutation must actually change the source')
        require(isinstance(m['required_false'], list) and m['required_false'],
                'mutation has no required false observations')
        require(all(isinstance(name, str) and re.fullmatch(CHECK_NAME, name)
                    for name in m['required_false']), 'invalid required check name')
        require(len(set(m['required_false'])) == len(m['required_false']),
                'duplicate required check')
    # Discover and inline every local import, including split Metatheory modules
    # absent from the mutation-site inventory; never load local cached oleans.
    blobs, ordered, visiting = {}, [], set()
    def capture(module):
        require(re.fullmatch(r'[A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9]*)*', module),
                f'invalid scoped module: {module}')
        require(module not in visiting, f'cyclic local dependency: {module}')
        if module in ordered:
            return
        visiting.add(module)
        relative = 'lean/' + module.replace('.', '/') + '.lean'
        path = (repo / relative).resolve()
        require(path.is_relative_to(repo), f'source path escape: {relative}')
        raw = read(path)
        blobs[relative] = raw
        for line in raw.decode().splitlines():
            if line.startswith('import '):
                imported = line.removeprefix('import ').strip()
                require(re.fullmatch(r'[A-Za-z][A-Za-z0-9_.]*', imported),
                        f'{module}: unsupported import syntax')
                local_path = repo / 'lean' / (imported.replace('.', '/') + '.lean')
                if imported.startswith('DefiKernel.') or local_path.exists():
                    capture(imported)
        visiting.remove(module)
        ordered.append(module)
    for module in modules:
        require(isinstance(module, str) and re.fullmatch(
            r'DefiKernel\.Metatheory(?:\.[A-Za-z][A-Za-z0-9]*)+', module),
            f'invalid scoped module: {module}')
        capture(module)
    for relative in ('lean/lean-toolchain', 'lean/lake-manifest.json', 'lean/lakefile.toml'):
        blobs[relative] = read(repo / relative)
    sources = {name: sha(raw) for name, raw in blobs.items()}
    script_sha256 = sha(read(Path(__file__)))
    imports, prefixes = [], {}
    for module in ordered:
        source = blobs['lean/' + module.replace('.', '/') + '.lean'].decode()
        marker = '\n-- BEGIN PROOFS\n'
        require(source.count(marker) <= 1, f'{module}: duplicate proof boundary')
        if marker in source and module.startswith('DefiKernel.Metatheory.'):
            source, suffix = source.split(marker)
            # This bounded projection removes theorem tails only. Silently
            # dropping a late runtime declaration would change the computation.
            tail_code = proof_tail_code(suffix, module)
            # Token matching catches same-line attributes/comments and command
            # declarations. Imported namespaces are deliberately not stripped.
            forbidden = re.search(
                r'\b(?:def|abbrev|opaque|instance|structure|inductive|class|axiom|constant|'
                r'macro|macro_rules|syntax|declare_syntax_cat|elab|elab_rules|'
                r'initialize|builtin_initialize|run_cmd|attribute|notation|infix|infixl|'
                r'infixr|prefix|postfix)\b|#(?:eval|reduce|run)\b', tail_code)
            require(not forbidden,
                    f'{module}: runtime declaration after proof boundary')
            closure = re.search(r'\n(end DefiKernel\.Metatheory(?:\.[A-Za-z][A-Za-z0-9]*)*)\s*$', suffix)
            require(closure, f'{module}: proof suffix lacks exact namespace closure')
            namespace = closure.group(1)[4:]
            require(f'namespace {namespace}\n' in source, f'{module}: unmatched namespace')
            source += '\n\n' + closure.group(1) + '\n'
        lines = []
        for line in source.splitlines():
            if line.startswith('import '):
                imported = line.removeprefix('import ').strip()
                require(re.fullmatch(r'[A-Za-z][A-Za-z0-9_.]*', imported),
                        f'{module}: unsupported import syntax')
                if imported not in ordered and line not in imports:
                    require(not imported.startswith('DefiKernel.'),
                            f'{module}: omitted internal dependency {imported}')
                    imports.append(line)
            else:
                lines.append(line)
        prefixes[module] = '\n'.join(lines) + '\n'
    require(imports, 'no external dependency imports captured')
    variants = {'control': dict(prefixes)}
    for m in mutations:
        source = prefixes[m['module']]
        require(source.count(m['needle']) == 1, f'{m["name"]}: mutation did not apply exactly once')
        variants[m['name']] = {**prefixes, m['module']: source.replace(m['needle'], m['replacement'], 1)}
    out.mkdir(parents=True, exist_ok=False)
    records, results = [], {}

    def run(label, command):
        tick = time.monotonic()
        proc = subprocess.run(command, cwd=repo / 'lean', capture_output=True, text=True,
                              timeout=args.timeout_seconds)
        log = proc.stdout + proc.stderr
        (out / (label + '.log')).write_text(log)
        records.append({'label': label, 'command': command, 'cwd': str(repo / 'lean'),
                        'exit': proc.returncode, 'log_sha256': sha(log.encode()),
                        'elapsed_seconds': round(time.monotonic() - tick, 6),
                        'timeout_seconds': args.timeout_seconds})
        (out / 'results.json').write_text(json.dumps({'runs': records, 'results': results}, indent=2) + '\n')
        return proc.returncode, log

    status, version = run('lean-version', ['lake', 'env', 'lean', '--version'])
    require(status == 0, 'Lean tool identity unavailable')
    status, executable = run('lean-path', ['lake', 'env', 'which', 'lean'])
    require(status == 0, 'Lean executable path unavailable')
    executable_sha = sha(read(Path(executable.strip())))
    status, head = run('git-head', ['git', 'rev-parse', 'HEAD'])
    require(status == 0, 'Git revision unavailable')
    status, dirty = run('git-root-input-status', ['git', '-C', str(repo), 'status', '--porcelain',
                                                '--untracked-files=all', '--', *blobs])
    require(status == 0, 'Git source status unavailable')
    git_bindings = {}
    for relative, raw in blobs.items():
        command = ['git', '-C', str(repo), 'rev-parse', f'{head.strip()}:{relative}']
        identity = subprocess.run(command, capture_output=True, timeout=args.timeout_seconds)
        require(identity.returncode == 0, f'input absent from frozen Git revision: {relative}')
        object_id = identity.stdout.decode().strip()
        blob_command = ['git', '-C', str(repo), 'cat-file', 'blob', object_id]
        committed = subprocess.run(blob_command, capture_output=True, timeout=args.timeout_seconds)
        require(committed.returncode == 0, f'Git input object unavailable: {relative}')
        require(committed.stdout == raw, f'input differs from frozen Git revision: {relative}')
        git_bindings[relative] = {'git_object': object_id, 'sha256': sha(committed.stdout),
                                  'identity_command': command, 'blob_command': blob_command,
                                  'identity_exit': identity.returncode, 'blob_exit': committed.returncode}
    manifest = {'sources': sources, 'script_sha256': script_sha256,
                'spec_sha256': sha(spec_raw), 'git_head': head.strip(), 'input_status': dirty,
                'git_input_bindings': git_bindings, 'started_utc': started,
                'timeout_seconds_per_command': args.timeout_seconds,
                'binding_scope': 'Captured Lean/config inputs equal HEAD Git objects; external spec/driver '
                                 'are byte-hashed and checked for drift, with production freeze binding separate.',
                'lean_version': version.strip(), 'lean_executable_sha256': executable_sha,
                'scope': 'Fresh local dependency source closure; Metatheory proof tails excluded; unchanged dependency proofs retained. Accepted files unchanged.',
                'proof_tail_guard': 'Conservative declaration/command token guard outside nested comments and '
                                    'ordinary/raw strings and character literals; not arbitrary command-macro expansion.',
                'projection_order': ordered, 'module_roots': modules,
                'audit_root': 'DefiKernel.Metatheory.Audit', 'python_version': sys.version}
    (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (out / 'mutation-spec.json').write_bytes(spec_raw)
    for relative, raw in blobs.items():
        target = out / 'inputs' / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    def verify_inputs():
        # Clear the prior variant's success flags before any read can fail.
        manifest.update(input_sources_unchanged=False, specification_unchanged=False,
                        runner_unchanged=False, git_head_unchanged=False)
        (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
        manifest['sources_after'] = {p: sha(read(repo / p)) for p in blobs}
        manifest['spec_sha256_after'] = sha(read(args.spec))
        manifest['script_sha256_after'] = sha(read(Path(__file__)))
        current_head = subprocess.run(['git', '-C', str(repo), 'rev-parse', 'HEAD'],
                                      capture_output=True, text=True, timeout=args.timeout_seconds)
        manifest['git_head_after'] = current_head.stdout.strip()
        manifest['input_sources_unchanged'] = manifest['sources_after'] == sources
        manifest['specification_unchanged'] = manifest['spec_sha256_after'] == sha(spec_raw)
        manifest['runner_unchanged'] = manifest['script_sha256_after'] == script_sha256
        manifest['git_head_unchanged'] = (current_head.returncode == 0 and
                                          manifest['git_head_after'] == head.strip())
        (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
        require(manifest['input_sources_unchanged'], 'input sources changed during replay')
        require(manifest['specification_unchanged'], 'specification changed during replay')
        require(manifest['runner_unchanged'], 'runner changed during replay')
        require(manifest['git_head_unchanged'], 'Git revision changed during replay')

    for label, parts in variants.items():
        source = '\n'.join(imports) + '\n\n' + '\n'.join(parts[m] for m in ordered)
        fixture = out / (label + '.lean')
        fixture.write_text(source)
        code, log = run(label, ['lake', 'env', 'lean', str(fixture)])
        verify_inputs()
        observations = re.findall(rf'^({CHECK_NAME}): (true|false)$', log, re.MULTILINE)
        # Lean's unused-variable diagnostics contain standalone Hint:/Note:
        # continuation lines. These exact diagnostic prefixes are not observations.
        diagnostic_prefixes = ('Hint: The binding can be removed (if unused) or named ',
                               'Note: This linter can be disabled with ')
        candidates = [line for line in log.splitlines()
                      if re.match(r'^[A-Za-z0-9_.-]+:', line)
                      and not line.startswith(diagnostic_prefixes)]
        require(len(candidates) == len(observations), f'{label}: malformed observation')
        checks = dict(observations)
        require(checks and len(checks) == len(observations), f'{label}: empty/duplicate observations')
        require(set(positives) <= checks.keys(), f'{label}: missing positive controls')
        false = sorted(name for name, value in checks.items() if value == 'false')
        errors = [line for line in log.splitlines()
                  if re.search(r': error(?:\([^)]*\))?:', line)]
        if label == 'control':
            expected_error = f'error: Metatheory runtime comparisons failed: {len(false)}'
            require(not errors or (false and len(errors) == 1 and errors[0].endswith(expected_error)),
                    'control compilation/execution failed')
            check(code == 0 and not false, 'unchanged control has failing comparisons')
            for mutation in mutations:
                require(set(mutation['required_false']) <= checks.keys(),
                        f'{mutation["name"]}: missing required observation in control')
        else:
            require(checks.keys() == results['control']['checks'].keys(), f'{label}: partial execution')
            check(code != 0 or false, f'{label}: all comparisons still pass under mutation')
            expected_error = f'error: Metatheory runtime comparisons failed: {len(false)}'
            require(len(errors) == 1 and errors[0].endswith(expected_error),
                    f'{label}: failure is not solely the expected runtime comparison failure')
            required = next(m['required_false'] for m in mutations if m['name'] == label)
            check(code != 0 and set(required) <= set(false), f'{label}: required mutation not detected')
        check(all(checks[name] == 'true' for name in positives), f'{label}: positive control failed')
        results[label] = {'exit': code, 'fixture_sha256': sha(source.encode()),
                          'checks': checks, 'false_comparisons': false}
        (out / 'results.json').write_text(json.dumps({'runs': records, 'results': results}, indent=2) + '\n')
        print(f'{label}: exit={code}; comparisons={len(checks)}; false={false}', flush=True)
    verify_inputs()
    manifest['finished_utc'] = datetime.now(timezone.utc).isoformat()
    (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(f'DISCRIMINATES: {len(mutations)} mutants and one nonempty unchanged control')


if __name__ == '__main__':
    try:
        main()
    except AssertionError as exc:
        print(f'FAIL: {exc}', file=sys.stderr)
        sys.exit(1)
    except Exception as exc:
        print(f'BLOCKED: {type(exc).__name__}: {exc}', file=sys.stderr)
        sys.exit(3)

## END FILE

## FILE scripts/test_metatheory_mutation_runner.py

Original SHA256: 19d234039a5d37f2eacd2dc328d17ddd66f57879833a24ff27de9d686bcf1e26; bytes: 32771; rendered SHA256: 19d234039a5d37f2eacd2dc328d17ddd66f57879833a24ff27de9d686bcf1e26

#!/usr/bin/env python3
"""Exercise the mutation runner's CLI against real temporary Lean computations.

No subprocess is mocked. The temporary repository links installed dependency packages
and has its own isolated git metadata. All fixtures/logs stay outside the
source repository. Exit 0 means every nonempty control has the expected classification;
exit 1 means an observed classification differs; exit 3 means the harness could not run.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time


INPUT_MODULE = 'DefiKernel.Metatheory.RunnerInput'
AUDIT_MODULE = 'DefiKernel.Metatheory.Audit'
DEPENDENCY = '''import Mathlib.Data.Nat.Basic
namespace DefiKernel.Interleaving
def runnerDependency : Nat := 4
-- BEGIN PROOFS
theorem runnerDependency_value : runnerDependency = 4 := rfl
end DefiKernel.Interleaving
'''
INPUT = '''import DefiKernel.Interleaving.RunnerDependency

namespace DefiKernel.Metatheory

example : DefiKernel.Interleaving.runnerDependency = 4 := DefiKernel.Interleaving.runnerDependency_value

def runnerAllows (n : Nat) : Bool := n ≤ 4
def runnerIncludeSensitivity : Bool := true
-- compiler-control

-- BEGIN PROOFS

theorem runnerAllows_zero : runnerAllows 0 = true := by decide

end DefiKernel.Metatheory
'''
AUDIT = '''import DefiKernel.Metatheory.RunnerInput

namespace DefiKernel.Metatheory

open Lean Elab Command in
run_cmd do
  let checks : List (String × Bool) := CHECKS
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Metatheory runtime comparisons failed: {failures}"

end DefiKernel.Metatheory
'''
PRODUCTION_AUDIT = '''import DefiKernel.Metatheory.RunnerInput
namespace DefiKernel.Metatheory.Audit
def main : IO Unit := do
  let checks : List (String × Bool) := CHECKS
  if checks.isEmpty then throw (IO.userError "Metatheory runtime comparisons empty")
  if !(checks.map Prod.fst).Nodup then
    throw (IO.userError "Metatheory runtime comparison names are duplicated")
  for (name, passed) in checks do IO.println s!"{name}: {passed}"
  let failures := checks.filter (!·.2) |>.map Prod.fst
  if !failures.isEmpty then
    throw (IO.userError s!"Metatheory runtime comparisons failed: {failures.length}")
#eval main

-- BEGIN PROOFS

end DefiKernel.Metatheory.Audit
'''

CHECKS = '''if runnerIncludeSensitivity then
    [("runner_positive", runnerAllows 0), ("runner_sensitivity", !runnerAllows 5)]
    else [("runner_positive", runnerAllows 0)]'''


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def require(value, message):
    if not value:
        raise RuntimeError(message)


def mutation(needle='n ≤ 4', replacement='n ≤ 5', required=None):
    return {'name': 'probe', 'module': INPUT_MODULE, 'needle': needle,
            'replacement': replacement,
            'required_false': ['runner_sensitivity'] if required is None else required}


def specification(change=None):
    return {'schema_version': 1, 'modules': [INPUT_MODULE, AUDIT_MODULE],
            'mutations': [mutation() if change is None else change],
            'positive_checks': ['runner_positive']}


def cases():
    """Expected classifications are fixed independently of the runner implementation."""
    return [
        {'name': 'production-eval-discriminating-mutant', 'exit': 0, 'production_audit': True,
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'production-eval-required-stays-true', 'exit': 1, 'production_audit': True,
         'spec': specification(mutation(required=['runner_positive'])),
         'message': 'required mutation not detected'},
        {'name': 'live-discriminating-mutant', 'exit': 0,
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'dotted-comparisons', 'exit': 0,
         'spec': {**specification(mutation(required=['runner.sensitivity'])),
                  'positive_checks': ['runner.positive']},
         'checks': CHECKS.replace('runner_positive', 'runner.positive').replace(
             'runner_sensitivity', 'runner.sensitivity'),
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'hyphenated-dotted-comparisons', 'exit': 0,
         'spec': {**specification(mutation(required=['runner.expected-failure'])),
                  'positive_checks': ['runner.permitted-sibling']},
         'checks': CHECKS.replace('runner_positive', 'runner.permitted-sibling').replace(
             'runner_sensitivity', 'runner.expected-failure'),
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'empty-dot-segment-spec', 'exit': 3,
         'spec': specification(mutation(required=['runner..sensitivity'])),
         'message': 'invalid required check name'},
        {'name': 'trailing-dot-spec', 'exit': 3,
         'spec': {**specification(), 'positive_checks': ['runner.']},
         'message': 'invalid positive check name'},
        {'name': 'leading-dot-observation', 'exit': 3,
         'extra_audit': '  liftIO <| IO.println ".runner_bad: true"\n',
         'message': 'malformed observation'},
        {'name': 'empty-dot-segment-observation', 'exit': 3,
         'extra_audit': '  liftIO <| IO.println "runner..bad: true"\n',
         'message': 'malformed observation'},
        {'name': 'unused-variable-warning', 'exit': 0,
         'spec': specification(mutation(replacement='true')),
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'uppercase-observation', 'exit': 3,
         'extra_audit': '  liftIO <| IO.println "Runner_bad: true"\n',
         'message': 'malformed observation'},
        {'name': 'unknown-mutant-observation', 'exit': 3,
         'extra_audit': '  if runnerAllows 5 then\n'
                        '    liftIO <| IO.println "runner_unknown: true"\n',
         'message': 'probe: partial execution'},
        {'name': 'all-true-mutant', 'exit': 1, 'spec': specification(mutation(replacement='n ≤ 3')),
         'message': 'all comparisons still pass under mutation'},
        {'name': 'required-observation-stays-true', 'exit': 1,
         'spec': specification(mutation(required=['runner_positive'])),
         'message': 'required mutation not detected'},
        {'name': 'positive-control-flipped', 'exit': 1,
         'spec': specification(mutation(replacement='n == 5')),
         'message': 'positive control failed'},
        {'name': 'compilation-only-failure', 'exit': 3,
         'spec': specification(mutation('-- compiler-control', '#check runnerUndefinedConstant')),
         'message': 'failure is not solely the expected runtime comparison failure'},
        {'name': 'compiler-error-with-runtime-failure', 'exit': 3,
         'spec': specification(mutation('n ≤ 4\ndef runnerIncludeSensitivity : Bool := true',
                                        'n ≤ 5\n#check runnerUndefinedConstant\n'
                                        'def runnerIncludeSensitivity : Bool := true')),
         'message': 'failure is not solely the expected runtime comparison failure'},
        {'name': 'empty-observations', 'exit': 3, 'checks': '[]',
         'message': 'control: empty/duplicate observations'},
        {'name': 'duplicate-observations', 'exit': 3,
         'checks': '[("runner_positive", true), ("runner_positive", true), '
                   '("runner_sensitivity", !runnerAllows 5)]',
         'message': 'control: empty/duplicate observations'},
        {'name': 'missing-positive-observation', 'exit': 3,
         'checks': '[("runner_sensitivity", !runnerAllows 5)]',
         'message': 'control: missing positive controls'},
        {'name': 'missing-required-observation', 'exit': 3,
         'spec': specification(mutation(required=['runner_absent'])),
         'message': 'probe: missing required observation in control'},
        {'name': 'partial-mutant-observations', 'exit': 3,
         'spec': specification(mutation('runnerIncludeSensitivity : Bool := true',
                                        'runnerIncludeSensitivity : Bool := false')),
         'message': 'probe: partial execution'},
        {'name': 'no-op-mutation', 'exit': 3,
         'spec': specification(mutation(replacement='n ≤ 4')),
         'message': 'mutation must actually change the source'},
        {'name': 'missing-mutation-needle', 'exit': 3,
         'spec': specification(mutation('runnerNeedleDoesNotExist', 'false')),
         'message': 'mutation did not apply exactly once'},
        {'name': 'missing-source-setup', 'exit': 3, 'missing_source': True,
         'message': 'FileNotFoundError'},
        {'name': 'missing-manifest-setup', 'exit': 3, 'missing_manifest': True,
         'message': 'FileNotFoundError'},
        {'name': 'existing-output-setup', 'exit': 3, 'existing_output': True,
         'message': 'output already exists'},
        {'name': 'reserved-mutation-name', 'exit': 3,
         'spec': specification({**mutation(), 'name': 'lean-version'}),
         'message': 'reserved variant name'},
        {'name': 'empty-module-inventory', 'exit': 3,
         'spec': {**specification(), 'modules': []}, 'message': 'empty module inventory'},
        {'name': 'empty-positive-inventory', 'exit': 3,
         'spec': {**specification(), 'positive_checks': []}, 'message': 'empty positive-control inventory'},
        {'name': 'duplicate-module-inventory', 'exit': 3,
         'spec': {**specification(), 'modules': [INPUT_MODULE, INPUT_MODULE, AUDIT_MODULE]},
         'message': 'duplicate source module'},
        {'name': 'duplicate-mutation-inventory', 'exit': 3,
         'spec': {**specification(), 'mutations': [mutation(), mutation()]}, 'message': 'duplicate mutation name'},
        {'name': 'duplicate-positive-check', 'exit': 3,
         'spec': {**specification(), 'positive_checks': ['runner_positive', 'runner_positive']},
         'message': 'duplicate positive control'},
        {'name': 'duplicate-required-check', 'exit': 3,
         'spec': specification(mutation(required=['runner_sensitivity', 'runner_sensitivity'])),
         'message': 'duplicate required check'},
        {'name': 'nonunique-mutation-needle', 'exit': 3,
         'spec': specification(mutation('def ', 'private def ')), 'message': 'mutation did not apply exactly once'},
        {'name': 'malformed-observation', 'exit': 3,
         'extra_audit': '  liftIO <| IO.println "runner_bad: truth"\n', 'message': 'malformed observation'},
        {'name': 'malformed-json', 'exit': 3, 'raw_spec': '{', 'message': 'JSONDecodeError'},
        {'name': 'duplicate-json-key', 'exit': 3,
         'raw_spec': '{"schema_version": 1, "schema_version": 1}', 'message': 'duplicate JSON key'},
        {'name': 'output-inside-repository', 'exit': 3, 'inside_output': True,
         'message': 'evidence output must be outside the repository'},
        {'name': 'output-symlink', 'exit': 3, 'symlink_output': True, 'message': 'output already exists'},
        {'name': 'discovered-metatheory-dependency', 'exit': 0, 'extra_dependency': True,
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'fresh-dependency-source-failure', 'exit': 3, 'changed_dependency': True,
         'message': 'control compilation/execution failed'},
        {'name': 'missing-audit-root', 'exit': 3,
         'spec': {**specification(), 'modules': [INPUT_MODULE]},
         'message': 'missing Metatheory audit root'},
        {'name': 'foreign-module-root', 'exit': 3,
         'spec': {**specification(), 'modules': [INPUT_MODULE, AUDIT_MODULE,
                                              'DefiKernel.Composition.RunnerInput']},
         'message': 'invalid scoped module'},
        {'name': 'mutation-module-outside-inventory', 'exit': 3,
         'spec': specification({**mutation(), 'module': 'DefiKernel.Metatheory.Absent'}),
         'message': 'mutation module outside inventory'},
        {'name': 'unchanged-control-failed', 'exit': 1,
         'checks': '[("runner_positive", true), ("runner_sensitivity", false)]',
         'message': 'unchanged control has failing comparisons'},
        {'name': 'nonkernel-local-dependency', 'exit': 0, 'nonkernel_dependency': True,
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'dirty-source-before-run', 'exit': 3, 'dirty_source': True,
         'message': 'input differs from frozen Git revision'},
        {'name': 'staged-source-before-run', 'exit': 3, 'staged_source': True,
         'message': 'input differs from frozen Git revision'},
        {'name': 'source-drift-during-run', 'exit': 3, 'source_drift': True,
         'message': 'input sources changed during replay'},
        {'name': 'source-drift-during-mutant', 'exit': 3, 'source_drift': True,
         'mutant_only_drift': True, 'message': 'input sources changed during replay'},
        {'name': 'specification-drift-during-run', 'exit': 3, 'spec_drift': True,
         'message': 'specification changed during replay'},
        {'name': 'runtime-definition-after-proof-boundary', 'exit': 3, 'late_runtime': True,
         'message': 'runtime declaration after proof boundary'},
        {'name': 'attributed-runtime-after-proof-boundary', 'exit': 3,
         'late_runtime': '@[inline] def hiddenRuntime : Bool := true',
         'message': 'runtime declaration after proof boundary'},
        {'name': 'comment-prefixed-runtime-after-proof-boundary', 'exit': 3,
         'late_runtime': '/- retained documentation -/ def hiddenRuntime : Bool := true',
         'message': 'runtime declaration after proof boundary'},
        {'name': 'macro-after-proof-boundary', 'exit': 3,
         'late_runtime': 'macro "lateRuntime" : command => `(def hiddenRuntime : Bool := true)',
         'message': 'runtime declaration after proof boundary'},
        {'name': 'macro-rules-after-proof-boundary', 'exit': 3,
         'late_runtime': 'macro_rules | `(lateRuntime) => `(def hiddenRuntime : Bool := true)',
         'message': 'runtime declaration after proof boundary'},
        {'name': 'syntax-after-proof-boundary', 'exit': 3,
         'late_runtime': 'syntax "lateRuntime" : command',
         'message': 'runtime declaration after proof boundary'},
        {'name': 'initialize-after-proof-boundary', 'exit': 3,
         'late_runtime': 'initialize hiddenRuntime : IO.Ref Nat ← IO.mkRef 4',
         'message': 'runtime declaration after proof boundary'},
        {'name': 'proof-comment-keywords-sibling', 'exit': 0,
         'late_runtime': '/- def outer /- macro inner -/ initialize outer -/\n-- syntax class',
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'proof-string-keywords-sibling', 'exit': 0,
         'late_runtime': 'theorem runtimeWords : "def macro initialize" = "def macro initialize" := rfl',
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'raw-string-before-attributed-runtime', 'exit': 3,
         'late_runtime': 'theorem rawWords : r#"def "macro""# = r#"def "macro""# := rfl\n@[inline] def hiddenRuntime : Bool := true',
         'message': 'runtime declaration after proof boundary'},
        {'name': 'character-before-attributed-runtime', 'exit': 3,
         'late_runtime': 'theorem quoteChar : \'"\' = \'"\' := rfl\n@[inline] def hiddenRuntime : Bool := true',
         'message': 'runtime declaration after proof boundary'},
        {'name': 'proof-raw-string-character-sibling', 'exit': 0,
         'late_runtime': 'theorem rawWords : r#"def "macro""# = r#"def "macro""# := rfl\ntheorem quoteChar : \'"\' = \'"\' := rfl',
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'empty-mutation-inventory', 'exit': 3,
         'spec': {**specification(), 'mutations': []}, 'message': 'empty mutation inventory'},
    ]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--runner', type=Path)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--case', action='append', help='Run only these named controls')
    args = parser.parse_args()
    repo, out = args.repo.resolve(), args.out.resolve()
    runner = (args.runner or repo / 'scripts/check_metatheory_mutations.py').resolve()
    require(not out.is_relative_to(repo), 'harness output must be outside source repository')
    require(not args.out.exists() and not args.out.is_symlink(), 'harness output already exists')
    require(runner.is_file(), 'runner source unavailable')
    require((repo / 'lean/.lake/packages').is_dir(), 'installed dependency packages unavailable')
    out.mkdir(parents=True)
    before = sha(runner.read_bytes())
    harness_before = sha(Path(__file__).read_bytes())
    started = datetime.now(timezone.utc).isoformat()
    identity = []

    def identify(label, command):
        proc = subprocess.run(command, cwd=repo / 'lean', text=True, capture_output=True, timeout=60)
        log = proc.stdout + proc.stderr
        (out / (label + '.log')).write_text(log)
        identity.append({'label': label, 'command': command, 'cwd': str(repo / 'lean'),
                         'exit': proc.returncode, 'log_sha256': sha(log.encode())})
        require(proc.returncode == 0, f'{label} unavailable: {log}')
        return proc.stdout.strip()

    lean_version = identify('lean-version', ['lake', 'env', 'lean', '--version'])
    lean_path = Path(identify('lean-path', ['lake', 'env', 'which', 'lean']))
    git_head = identify('git-head', ['git', 'rev-parse', 'HEAD'])
    fake = out / 'fixture-repo'
    lean = fake / 'lean'
    typed = lean / 'DefiKernel/Metatheory'
    typed.mkdir(parents=True)
    dependency = lean / 'DefiKernel/Interleaving/RunnerDependency.lean'
    dependency.parent.mkdir(parents=True)
    dependency.write_text(DEPENDENCY)
    # Independent metadata prevents even optional index refreshes in the source repo.
    for command in [
        ['git', 'init', '--quiet', str(fake)],
        ['git', '-C', str(fake), '-c', 'user.name=DeFiFormal fixture',
         '-c', 'user.email=fixture@invalid', 'commit', '--allow-empty', '--quiet',
         '-m', 'Initialize isolated mutation-runner fixture'],
    ]:
        proc = subprocess.run(command, text=True, capture_output=True, timeout=60)
        require(proc.returncode == 0, f'isolated fixture git setup failed: {proc.stderr}')
    (lean / '.lake').mkdir()
    # Reuse dependency packages, never the source project's .lake/build directory.
    (lean / '.lake/packages').symlink_to(repo / 'lean/.lake/packages', target_is_directory=True)
    for name in ('lean-toolchain', 'lake-manifest.json', 'lakefile.toml'):
        shutil.copyfile(repo / 'lean' / name, lean / name)
    manifest = (lean / 'lake-manifest.json').read_bytes()
    records = []
    selected = [case for case in cases() if not args.case or case['name'] in args.case]
    require(selected and (not args.case or set(args.case) <= {c['name'] for c in selected}),
            'unknown or empty control selection')
    for case in selected:
        dependency.write_text(DEPENDENCY)
        (lean / 'lake-manifest.json').write_bytes(manifest)
        setup_records = []
        (typed / 'RunnerInput.lean').write_text(INPUT)
        if case.get('nonkernel_dependency'):
            external = lean / 'SharedFixture/RunnerDependency.lean'
            external.parent.mkdir(parents=True, exist_ok=True)
            external.write_text(DEPENDENCY.replace('DefiKernel.Interleaving', 'SharedFixture'))
            (typed / 'RunnerInput.lean').write_text(INPUT.replace(
                'DefiKernel.Interleaving', 'SharedFixture'))
        if case.get('extra_dependency'):
            extra = typed / 'SplitComputation.lean'
            extra.write_text('import DefiKernel.Interleaving.RunnerDependency\n'
                             'namespace DefiKernel.Metatheory\n'
                             'def splitLimit : Nat := 4\n'
                             '-- BEGIN PROOFS\n'
                             'theorem splitLimit_value : splitLimit = 4 := rfl\n'
                             'end DefiKernel.Metatheory\n')
            (typed / 'RunnerInput.lean').write_text(INPUT.replace(
                'import DefiKernel.Interleaving.RunnerDependency',
                'import DefiKernel.Metatheory.SplitComputation').replace(
                    'n ≤ 4', 'n ≤ 4 + (splitLimit - 4)'))
        if case.get('changed_dependency'):
            # Compile the old source, then change only the .lean file. A fresh
            # source projection must see 5 and fail the importing = 4 example.
            olean = lean / '.lake/build/lib/lean/DefiKernel/Interleaving/RunnerDependency.olean'
            olean.parent.mkdir(parents=True, exist_ok=True)
            setup_command = ['lake', 'env', 'lean', '-o', str(olean), str(dependency)]
            setup = subprocess.run(setup_command, cwd=lean, text=True, capture_output=True, timeout=240)
            setup_log = setup.stdout + setup.stderr
            (out / 'stale-dependency-setup.log').write_text(setup_log)
            require(setup.returncode == 0 and olean.is_file(), 'stale dependency control setup failed')
            setup_records.append({'command': setup_command, 'cwd': str(lean),
                                  'exit': setup.returncode, 'log_sha256': sha(setup_log.encode()),
                                  'source_sha256': sha(dependency.read_bytes()),
                                  'olean_sha256': sha(olean.read_bytes())})
            dependency.write_text(DEPENDENCY.replace(':= 4', ':= 5').replace('= 4', '= 5'))
        audit_template = PRODUCTION_AUDIT if case.get('production_audit') else AUDIT
        (typed / 'Audit.lean').write_text(audit_template.replace('CHECKS', case.get('checks', CHECKS)).replace(
            '  let failures :=', case.get('extra_audit', '') + '  let failures :='))
        (lean / 'lake-manifest.json').write_bytes(manifest)
        if case.get('late_runtime'):
            source = typed / 'RunnerInput.lean'
            source.write_text(source.read_text().replace('-- BEGIN PROOFS',
                              '-- BEGIN PROOFS\n' + (case['late_runtime'] if isinstance(case['late_runtime'], str)
                              else 'def hiddenRuntime : Bool := true')))
        if case.get('missing_source'):
            (typed / 'RunnerInput.lean').unlink()
        if case.get('missing_manifest'):
            (lean / 'lake-manifest.json').unlink()
        spec = case.get('spec', specification())
        spec_path = out / (case['name'] + '-spec.json')
        spec_path.write_text(case.get('raw_spec', json.dumps(spec, indent=2) + '\n'))
        result_path = out / 'runs' / case['name']
        if case.get('inside_output'):
            result_path = fake / 'forbidden-output'
        if case.get('symlink_output'):
            result_path.parent.mkdir(parents=True, exist_ok=True)
            result_path.symlink_to(out / 'nonexistent-output', target_is_directory=True)
        if case.get('existing_output'):
            result_path.mkdir(parents=True)
        command = [sys.executable, str(runner), '--repo', str(fake), '--spec', str(spec_path),
                   '--out', str(result_path)]
        if case.get('source_drift') or case.get('spec_drift'):
            drift_path = typed / 'RunnerInput.lean' if case.get('source_drift') else spec_path
            audit = typed / 'Audit.lean'
            drift_statement = 'liftIO <| IO.FS.writeFile ' + json.dumps(str(drift_path)) + \
                ' "-- drifted during actual Lean audit\\n"\n'
            if case.get('mutant_only_drift'):
                drift_statement = 'if runnerAllows 5 then\n    ' + drift_statement
            audit.write_text(audit.read_text().replace('  let checks :',
                '  ' + drift_statement + '  let checks :'))
        for setup_command in [
            ['git', '-C', str(fake), 'add', '-A', '--', 'lean', ':!lean/.lake'],
            ['git', '-C', str(fake), '-c', 'user.name=DeFiFormal fixture',
             '-c', 'user.email=fixture@invalid', 'commit', '--quiet', '--allow-empty',
             '-m', 'Freeze ' + case['name']],
        ]:
            setup = subprocess.run(setup_command, text=True, capture_output=True, timeout=60)
            require(setup.returncode == 0, f'fixture freeze failed: {setup.stderr}')
            setup_records.append({'command': setup_command, 'exit': setup.returncode})
        if case.get('dirty_source') or case.get('staged_source'):
            source = typed / 'RunnerInput.lean'
            source.write_text(source.read_text().replace('-- compiler-control', '-- uncommitted input drift'))
            if case.get('staged_source'):
                setup = subprocess.run(['git', '-C', str(fake), 'add', str(source)],
                                       text=True, capture_output=True, timeout=60)
                require(setup.returncode == 0, 'fixture stage failed')
        tick = time.monotonic()
        proc = subprocess.run(command, cwd=repo, text=True, capture_output=True, timeout=1500)
        elapsed = time.monotonic() - tick
        log = proc.stdout + proc.stderr
        log_path = out / (case['name'] + '.log')
        log_path.write_text(log)
        matched = proc.returncode == case['exit'] and case['message'] in log
        runtime = {}
        results_file = result_path / 'results.json'
        if results_file.exists():
            runtime = json.loads(results_file.read_text())
        # Accepted discrimination additionally requires exact real Lean observations.
        if case['name'] in ('production-eval-discriminating-mutant', 'live-discriminating-mutant', 'dotted-comparisons', 'hyphenated-dotted-comparisons', 'discovered-metatheory-dependency', 'unused-variable-warning', 'nonkernel-local-dependency', 'proof-comment-keywords-sibling', 'proof-string-keywords-sibling', 'proof-raw-string-character-sibling'):
            measured = runtime.get('results', {})
            separator = '.' if case['name'] == 'dotted-comparisons' else '_'
            expected_positive = 'runner' + separator + 'positive'
            expected_sensitivity = 'runner' + separator + 'sensitivity'
            if case['name'] == 'hyphenated-dotted-comparisons':
                expected_positive, expected_sensitivity = 'runner.permitted-sibling', 'runner.expected-failure'
            matched = matched and measured.get('control', {}).get('checks') == {
                expected_positive: 'true', expected_sensitivity: 'true'}
            matched = matched and measured.get('probe', {}).get('checks') == {
                expected_positive: 'true', expected_sensitivity: 'false'}
        if case.get('production_audit'):
            # Assertion failures intentionally do not publish accepted result entries.
            # Check actual Lean output for both production-form paths.
            for label, expected in [('control', 'true'), ('probe', 'false')]:
                lean_log_path = result_path / (label + '.log')
                actual_log = lean_log_path.read_text() if lean_log_path.exists() else ''
                matched = matched and re.findall(
                    r'^(runner_positive|runner_sensitivity): (true|false)$',
                    actual_log, re.MULTILINE) == [
                        ('runner_positive', 'true'), ('runner_sensitivity', expected)]
                if label == 'probe':
                    matched = matched and actual_log.count(
                        'error: Metatheory runtime comparisons failed: 1') == 1
        if case['name'] == 'unused-variable-warning':
            warning_log = result_path / 'probe.log'
            warning = warning_log.read_text() if warning_log.exists() else ''
            matched = matched and 'warning: Variable name `n` is not explicitly referenced.' in warning
            matched = matched and 'Hint: The binding can be removed' in warning
            matched = matched and 'Note: This linter can be disabled with ' in warning
        source_manifest = result_path / 'source-manifest.json'
        if case.get('extra_dependency'):
            captured = json.loads(source_manifest.read_text()) if source_manifest.exists() else {}
            matched = matched and 'DefiKernel.Metatheory.SplitComputation' in captured.get('projection_order', [])
            matched = matched and captured.get('sources', {}).get(
                'lean/DefiKernel/Metatheory/SplitComputation.lean') == sha(extra.read_bytes())
            matched = matched and captured.get('input_sources_unchanged') is True
        if case.get('mutant_only_drift'):
            captured = json.loads(source_manifest.read_text()) if source_manifest.exists() else {}
            matched = matched and captured.get('input_sources_unchanged') is False
            matched = matched and runtime.get('results', {}).get('control', {}).get('exit') == 0
        if case.get('nonkernel_dependency'):
            captured = json.loads(source_manifest.read_text()) if source_manifest.exists() else {}
            matched = matched and 'SharedFixture.RunnerDependency' in captured.get('projection_order', [])
            matched = matched and captured.get('sources', {}).get(
                'lean/SharedFixture/RunnerDependency.lean') == sha(external.read_bytes())
        observations = {}
        for variant in ('control', 'probe'):
            variant_log = result_path / (variant + '.log')
            if variant_log.exists():
                raw = variant_log.read_text()
                observations[variant] = {
                    'lines': re.findall(r'^([a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*): (true|false)$', raw, re.MULTILINE),
                    'errors': [line for line in raw.splitlines() if re.search(r': error(?:\([^)]*\))?:', line)],
                    'log_sha256': sha(raw.encode())}
        record = {'name': case['name'], 'command': command, 'cwd': str(repo),
                  'expected_exit': case['exit'], 'actual_exit': proc.returncode,
                  'expected_message': case['message'], 'passed': matched,
                  'elapsed_seconds': round(elapsed, 6), 'log': str(log_path),
                  'log_sha256': sha(log.encode()), 'cli_output': log,
                  'spec_sha256': sha(spec_path.read_bytes()), 'setup_records': setup_records,
                  'lean_observations': observations, 'runner_records': runtime.get('runs', [])}
        records.append(record)
        print(f'{case["name"]}: expected={case["exit"]}; actual={proc.returncode}; '
              f'{"PASS" if matched else "FAIL"}', flush=True)
        (out / 'cases.json').write_text(json.dumps(records, indent=2) + '\n')
    require(records, 'zero controls executed')
    require(before == sha(runner.read_bytes()), 'runner changed during controls; rerun final bytes')
    require(harness_before == sha(Path(__file__).read_bytes()), 'harness changed during controls')
    summary = {'schema_version': 1, 'kind': 'executed-cli-runner-controls',
               'started_utc': started, 'finished_utc': datetime.now(timezone.utc).isoformat(),
               'source_repo': str(repo), 'git_head': git_head,
               'runner_source': str(runner), 'runner_sha256': before,
               'harness_source': str(Path(__file__).resolve()),
               'harness_sha256': harness_before,
               'lean_version': lean_version, 'lean_executable_sha256': sha(lean_path.read_bytes()),
               'python_version': sys.version, 'tool_identity_commands': identity,
               'fixture_scope': 'Synthetic development Lean computations; actual CLI and installed '
                                'Lean/mathlib. No subprocess mocks; no production theorem claim.',
               'fixture_dependency_sha256': sha(DEPENDENCY.encode()),
               'fixture_input_sha256': sha(INPUT.encode()),
               'fixture_audit_template_sha256': sha(AUDIT.encode()),
               'total': len(records), 'passed': sum(r['passed'] for r in records),
               'cases': records}
    (out / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(f'CONTROLS: {summary["passed"]}/{summary["total"]} passed', flush=True)
    return 0 if all(r['passed'] for r in records) else 1


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception as exc:
        print(f'BLOCKED: {type(exc).__name__}: {exc}', file=sys.stderr)
        sys.exit(3)

## END FILE

## FILE wiki-llm/operational-metatheory-planning-draft.md

Original SHA256: 9140d371503d1f65c77e4bb991a889a8aff70f48520b7ee9d56d0e86f977ae17; bytes: 29849; rendered SHA256: 9140d371503d1f65c77e4bb991a889a8aff70f48520b7ee9d56d0e86f977ae17

# Operational composition metatheory planning draft

Planning research only, 2026-09-07. Source inspected at
`bea105ec72e633a2dd66c663b96d0b552e1814a8`. This note proposes independently
reviewable increments after atomic synchronization. It is not an approved OpenSpec
change, an implementation, or proof evidence. Each increment needs its own frozen
GPT-6/native Opus planning gate and native Grok/Opus result review through the
stock Codex harness. No Foreman. Routine scope choices follow the user's AFK
execution authorization; no source, historical theorem or existing evidence is
changed by this draft.

The [approved design](../docs/superpowers/specs/2026-09-06-semantic-kernel-design.md)
and [roadmap](../roadmap.md) require operational interface and n-ary composition,
behavioral associativity, initialized causal assume-guarantee rules, observational
equivalence and conservative extension. The
[original proposal](../docs/research/2026-09-06-defi-source-plan.md) is motivation,
not an already verified implementation. The
[atomic draft](sprint-8-atomic-synchronization-draft.md) supplies the proposed
transaction boundary. Its eventual accepted OpenSpec and implementation must
replace draft assumptions before atomic metatheorems are frozen.

## Current foundation and actual gaps

| Source and symbols | What can be reused | What is still required |
| --- | --- | --- |
| [Historical Interface](../lean/Defialgebra/Interface.lean), `Ledger`, `Cons`, `WritesWithin`, `QNeutralOn`, `cons_of_portConfined`, `cons_broken_if_sup_is_port` | An explicit conservation discipline and its negative witness | Typed asset/domain-indexed actual-step and reachable-prefix instances; no automatic inference of neutrality |
| [Historical Nary](../lean/Defialgebra/Nary.lean), `Binding`, `Agrees`, `agrees_union_assoc`, `agrees_of_same_symClosure`, `skip_not_pairLocal_witness` | Stable global names and conjunction of binding constraints | A running multi-participant machine and proof that regrouping preserves its steps, histories, boundaries and failures |
| [Composition interfaces](../lean/DefiKernel/Composition/Interfaces.lean), `QualifiedPort`, `ResourcePort`, `ResourceImport`, `validateCatalog`, `resolveSource` | Exact-cell resource sharing, globally qualified output names, input units and absolute prior-output positions | Global operational binding preservation and supported interface contracts; a valid catalog is not such a proof |
| [Composition execution](../lean/DefiKernel/Composition/Execution.lean), `executeStep`, `StepSound`, `extractReceipt_correspondence` | Actual invocation/admin outcomes and receipt evaluation at the same pre-world | Congruence under a changed but compatible configuration; no invented receipt-level semantics |
| [Sequence](../lean/DefiKernel/Composition/Sequence.lean), `Cursor`, `continueRun_append`, `continueRun_failed`, `TraceSound` | Full cursor propagation and refusal absorption | A separately defined group executor and a correspondence theorem; list append alone does not cover grouping |
| [Contracts](../lean/DefiKernel/Composition/Contracts.lean), `ComponentContract`, `ContractObligations`, `Supports`; [preservation](../lean/DefiKernel/Composition/Preservation.lean), `run_contract` | Initialized conditional contracts and supported ledger frames | Discharge of local assumptions from actual earlier events and current trusted environment premises |
| [Dependency adapter](../lean/DefiKernel/Parallel/Dependency/Adapter.lean), `StepAgrees`, `executeStep_congr`, `executeStep_refusal_iff`; [commutation](../lean/DefiKernel/Parallel/Commutation.lean), `CursorAgrees`, `continueRun_congr`, `runParallel_serialLR`, `runParallel_serialRL` | Full success/refusal dependence on analyzed reads, output cells and equal capabilities, for the same configuration/boundary/history | Configuration extension and many-participant simulations; equality of final balances alone is weaker |
| [Interleaving interference](../lean/DefiKernel/Interleaving/Interference.lean), `LocalObligation`, `CrossInclusion`, `Stable`, `Reachable.two_invariants` | An actual initialized binary induction, with no circular whole-run premise | Finite-index generalization and useful causal assumptions that local proofs truly need |
| [Interleaving recovery](../lean/DefiKernel/Interleaving/Recovery.lean), `runInterleaving_recovers`, `runInterleaving_matchesParallel` | All complete binary schedules recover actual disjoint parallel observations under actual admission | Many-participant recovery and group execution correspondence; arbitrary overlapping runs need not commute |
| [Typed authority](../lean/DefiKernel/Typed/Authority.lean), `CapabilityStore.nextId`, `issueCapability`, `revokeCapability`, `authorizesId` | Existing administration and exact point-of-use permission predicates | Provenance from an initialized administrative trace, and later concurrent allocation/revocation semantics |

The existing repository graph is bound to historical commit `f559c474…` and
contains an `M3_nary_binding` concept at `research/positive-program/AGENDA.md`.
It does not index the current Interleaving source. Current claims above come from
direct source inspection; the historical graph was not regenerated.

Three possible approaches are materially different:

1. Add laws about list flattening and binding union. This is small and useful as
   helper algebra, but leaves the operational roadmap open.
2. Introduce a finite participant machine with stable identities, then a recursive
   group machine related to it by a step simulation. This is recommended: it makes
   failure, histories, boundaries and grouping independently testable.
3. Introduce a general process calculus with dynamic participants, name generation,
   nested transactions and asynchronous contexts. This would combine several open
   dependencies and obscure whether the present finite laws are proved.

Use the second approach, preserving each existing operator's semantics and the
historical statements. Do not turn a sequential group, an interleaving group and
an atomic boundary into three spellings of one operator.

## Shared notation and observation contract

The formulas below are proposed theorem statements, not declarations that already
exist. Fix finite `P`, `A`, `D`, a trusted `Composition.Config`, a complete initial
`World`, and trusted boundaries. Introduce a finite participant type `B` with a
fixed duplicate-free enumeration, a branch family `branches : B → List Invocation`,
and `boundaries : B → Nat → Boundary`. A participant identifies an execution
stream, not necessarily a component: several streams may invoke the same
`ComponentId`. Reparenting must preserve these stream identities.

For invocation-only parallel/interleaving execution, capabilities are fixed.
Sequential composition may contain `issue` and `revoke` and must propagate the
whole store; this distinction is retained. Environment truth and authentication
are assumptions. No theorem derives oracle truth or grants consent from a ledger
frame.

Define explicit observation projections before equivalence laws. A sequential
cursor observation contains its final world, ordered event observations, ordered
output snapshots, next index and exact located failure. A multi-participant
observation contains the final world and those local observations indexed by
stable participant. Global attempt order is a separate trace observation. Atomic
public observations preserve committed versus aborted kind, transaction identity,
exact committed state/store, failures and committed receipts/outputs according to
the accepted Atomic API. Aborted diagnostics are a different observation type.

Use existing `Parallel.EventObservation` and `BranchObservation` fields wherever
possible. They deliberately omit raw intermediate event worlds, which can differ
under independent scheduling. Keep exact request, receipt, output and failure
fields. A theorem equating canonical outcomes is not a theorem equating attempt
orders. Prove reflexivity, symmetry and transitivity, plus correspondence with any
public executable comparison. Prove contextual substitution only for an explicitly
restricted context grammar and state its visible projection.

For extension, define a second observation `Obs(S, K)` projecting ledger cells to
protected set `S` and participant observations to old participants `K`. Initially
compare the entire capability store, since it is unchanged in invocation-only
runs. Full-world equality is inappropriate when a new component legitimately
changes its own unrelated cells. Diagnostic traces and newly introduced stream
identities are not silently quotiented in the old full observation.

## Increment M1: continuation, configuration extension and observations

Proposed files under a new `DefiKernel.Metatheory` namespace:
`Observation.lean`, `Configuration.lean`, `SequentialGroups.lean`, dedicated
`Examples.lean`, `Tests.lean` and `Verify.lean`. Freeze only this increment's scope
in its initial OpenSpec; later files are separate changes.

First define a recursive sequential group syntax with empty, single-step and
sequence nodes. Its executor must call `Composition.advance` for a leaf and pass
the complete returned cursor to the next child. It must not call `run` at each
child, reset a local index or reconstruct a history from live state. Prove

```text
runSeqGroup cfg boundary cursor group
  = continueRun cfg boundary cursor (leaves group).
```

Then derive actual cursor equality for `(g₁ ; g₂) ; g₃` and
`g₁ ; (g₂ ; g₃)`, including prior-output requests, failed cursors and administrative
steps. This is a genuine but narrowly scoped sequential grouping theorem because
the recursive executor correspondence is proved. It says nothing about parallel
regrouping, new atomic boundaries or a binary wrapper that restarts children.

Next define `ConfigExtendsOn old new U`: both catalogs validate; old operation and
component lookups used by request set `U` return identical templates/interfaces;
old component access declarations remain identical; trusted domain administrators
agree where administrative steps are admitted. Use one fixed identity universe
initially. Configuration extension does not enlarge `P`, `A` or `D`.

Prove exact `executeStep` equality for every old step, same full world, same
boundary/index/history, and the stated lookup preservation. Include errors, not
just successful results. Derive `continueRun` equality for old programs whose
invocations/administrative operation references lie in `U`, and then old parallel
and interleaving admission/execution correspondence. Lift reference-set membership
through every submitted suffix, including unreachable operations. Extending an
invalid catalog is not covered by a premise that both catalogs validate.

Acceptance examples: three sequential groups with producer/consumer snapshots;
revoke in group one and denied invocation in group two; middle refusal with inert
suffix; boundary index-dependent actor/time; unrelated valid catalog extension;
invalid added component causes `.configuration`; changed old registry lookup
breaks equality. For the invalid case, record the exact failure rather than
claiming the extension theorem applies.

## Increment M2: operational interface and binding preservation

Proposed files: `Interface/Accounting.lean`, `Interface/Bindings.lean` and fixtures.
Keep the historical integer `Interface.St` and its theorem unchanged.

For finite same-asset/domain balance region `L`, define
`BalanceSum L state = ∑ c ∈ L, state.balance c`. Define `ReceiptDelta L receipt`
from actual evaluated deltas at those cells, with repeated targets summed. Prove
for actual successful invocation outcomes:

```text
BalanceSum L post.state = BalanceSum L pre.state + ReceiptDelta L receipt.
```

Derive the no-net-port-flow rule under explicit confinement and
`ReceiptDelta L receipt = 0`, and lift it over accepted events of actual runners.
For an invariant `BalanceSum L state = declaredTotal state`, require explicit
support for `declaredTotal` and no writes to that support. A ghost fixed parameter
is a simpler separate specialization. `Typed.State` has a derived asset total;
it does not contain the historical independent `sup` field. Do not introduce a
shareable bookkeeping balance and pretend it is automatically protected. Allow
nonzero authorized supply through the receipt accounting law; neutrality remains
an additional property, not a consequence of typing or interface validity.

The existing resource model identifies an imported resource with an exact exported
cell. A global binding predicate may state equal typed observations at two named
ports, but an equality assertion does not make two distinct cells aliases.
Initially restrict runtime resource sharing to existing exact-cell imports;
additional bindings are invariants to preserve. Bindings connect matching units
and domains and carry global names independent of a binary cut. State explicitly
whether an edge denotes identity of one cell or a demanded equality between two
cells. Implementing quotient storage or alias rewriting is outside this increment.

For a finite global binding set `E`, prove initialization and actual-step
preservation imply `∀ prefix, Agrees E reachedState`. Derive global constraint
union/reorientation laws at the predicate level; lift them to preservation
obligations by explicit pointwise implications. The original symmetric-closure
criterion is sufficient, not necessary: transitive equalities may make different
edge sets logically equivalent. Do not advertise a complete semantic equivalence
decider from symmetric closure equality.

Acceptance examples: a nonzero quantity-neutral transfer through two shared ports;
a private total/support region preserved despite live shared writes; a supply or
cross-boundary transfer that breaks neutrality; the writable-total negative
companion in the new typed setting; a three-participant skip binding retained
across a binary cut; equal-at-entry distinct cells broken by a one-sided write.
Use an actual accepted receipt for the breaking transition. A rejected access
attempt cannot witness violation of a preservation law.

## Increment M3: finite participant execution and causal interference

Proposed files: `Nary/Schedule.lean`, `Nary/Execution.lean`, `Nary/Soundness.lean`,
`Nary/Interference.lean`. Use invocation-only branches, fixed capabilities and
explicit finite schedules. Admission validates the catalog once, analyzes every
branch in the fixed participant enumeration, then checks complete occurrence
counts. Preserve exact first failure precedence. Each token consumes a static
slot; a refused stream is inert while peers continue, as in Sprint 7.

Define a machine with one shared world, local state indexed by `B`, and a global
attempt trace. Prove token-by-token soundness, branch histories from own accepted
receipts, local index/consumed-slot correspondence, exact refusal stability,
accounting and supported frames. Embed the existing binary `BranchId` and prove
an actual binary-runner correspondence, including admission errors and all stored
fields after the agreed identity projection. A list of independently executed
worlds is not this shared execution semantics.

Generalize the existing initialized rely/guarantee theorem to `B`. For invariant
`Iᵢ`, guarantees `Gᵢ` and relies `Rᵢ`, require initialization, local obligations for
actual selected invocations, `Gᵢ ⊆ Rⱼ` for every distinct pair, and stability of
`Iⱼ` under `Rⱼ`. Prove all initialized invariants at every actual finite prefix.
The local proof uses its own invariant, not a premise that all peer invariants
hold at the end. Failure/skip steps preserve the ledger by identity. A finite
participant induction establishes the vector invariant, not pairwise whole-run
circular implication.

Add a separate causal rule rather than weakening that theorem invisibly. Introduce
an explicitly defined monitor `q` of the actual finite execution prefix. Its update
uses the current selected boundary and actual outcome only; it cannot read future
schedule outcomes. A joint induction invariant `K(q, machine)` must prove:

1. `K` holds at the initialized machine/monitor, and implies each desired `Iᵢ`.
2. For the next selected invocation, `K` plus a stated *current* external premise
   entails its local assumption `Aᵢ(q, pre, boundary)`.
3. The local semantic obligation uses `Iᵢ`, that assumption and actual `StepSound`
   to derive own preservation and `Gᵢ`.
4. `Gᵢ`, peer relies/stability, and the concrete monitor update establish `K` at the
   next machine. Refusal and skip monitor updates have their own identity cases.

Environment facts not implied by prior kernel execution remain visible external
premises. State a separate success/enabledness obligation if success is claimed:
`StepSound` conditions only successful outcomes and does not prove progress. A
schedule may make a causal assumption false; a runtime check can then refuse, or
the theorem must explicitly restrict admissible schedules. Never assume the
future successful run as the way to establish its assumptions.

Acceptance requires a funded causal producer/consumer example in which the local
proof genuinely needs the established bound, unlike the USD-total instance whose
local invariant antecedent is unnecessary. Demonstrate that dropping the causal
assumption admits an actual violating state/step. Include missing initialization,
missing peer stability, and circular `A₁ iff G₂`, `A₂ iff G₁` with both facts false.
A concrete causal instance can protect a USD4 reserve in a vault initially holding
USD10. A producer exposes a typed budget snapshot6; the consumer transfers that
snapshot amount with the ordinary sufficient-balance guard. The local reserve
proof additionally requires `amount ≤ currentVaultBalance - 4`. A monitor records
the actual budget fact, while peer stability restricts intervening vault changes
to deposits or proves an updated bound. The correct transfer leaves4. Without
the causal bound, an otherwise authorized transfer7 succeeds and leaves3: an
actual invariant violation, not merely an unavailable-history refusal. The
producer's budget correctness and its preservation until consumption are explicit
proof obligations; printing a snapshot does not itself establish either.

For trace-dependent monitors, include a refused producer that emits no usable
fact and a successful producer from the wrong stream. These are separate from
compiler errors and finite positive controls.

## Increment M4: operational regrouping and disjoint schedule independence

Proposed files: `Nary/Groups.lean`, `Nary/GroupSimulation.lean`,
`Nary/DisjointRecovery.lean`. This depends on M3; interface well-formedness from M2
provides the globally named binding context.

A group tree partitions the same finite participant set into disjoint leaf sets.
Each leaf appears exactly once; empty groups are explicit. Configuration, binding
set, participant enumeration and boundaries are global immutable parameters, not
rebuilt at internal nodes. A group machine keeps tree-shaped local states and one
shared world. Its token dispatcher recursively finds the named leaf, passes the
current world to that leaf, and returns the changed world and only that leaf's
updated local state. Dispatch routing is implemented independently of flattening.

Define a representation relation between this tree machine and M3's flat machine:
world/store agreement; pointwise local state/history/index/failure agreement under
leaf identity; equal global attempts and static consumption. Prove initialization,
one-token simulation in both directions, and continuation simulation. Admission
uses the same global canonical ordering; a group-local validation order would
change which malformed suffix is reported.

Derive, for two well-formed groupings `T` and `T'` with the same named leaves and
same schedule `s`:

```text
Obs(runGroup T cfg boundaries initial s)
  = Obs(runGroup T' cfg boundaries initial s).
```

This is representation independence of actual shared execution for a fixed
schedule, and can hold even with shared writes. It neither reorders tokens nor
allows a parent group to halt because one child refused. A group that runs a whole
subtree atomically is a different operator and is not covered.

For pairwise compatible analyzed footprints, prove a second, stronger law:
all complete schedules have the same canonical per-participant observation and
final world, and match a separately defined disjoint executor. That executor runs
leaves independently from the same entry world and merges only their disjoint
write regions; define and prove recursive group-merge correspondence. Do not
compare raw intermediate event worlds or global attempt sequences across orders.
Prove pairwise compatibility implies compatibility of each subgroup's footprint
union; this connects binding/group algebra with the actual dependency proof.

Acceptance: three nonempty streams with two invocations each; several groupings
and all 90 complete schedules for this bounded fixture; successful and refused
streams; snapshots sharing a qualified key in distinct histories; index-dependent
boundaries; an empty group; duplicate/missing leaf rejection; three-party global
skip binding; and the shared USD10 competition showing schedule independence is
false without compatibility. Full expected observations must be independently
constructed for selected financial cases, not all obtained by calling the flat
executor being proved equivalent.

## Increment M5: conservative execution extension and contextual substitution

Proposed files: `Extension/Projection.lean`, `Extension/Execution.lean`,
`Extension/Contexts.lean`. It depends on M1 and M3/M4.

Separate adding declarations from executing additional participants. M1 handles
declarations. For active additions, retain a fixed identity universe, valid
catalog extension and stable lookups; old boundaries, branch histories and
capabilities agree. Let protected set `S` contain all old analyzed reads, writes
and snapshot cells. Every added stream's analyzed writes avoid `S`. Stronger
pairwise compatibility may be used for the first theorem, but state it as stronger
than one-way preservation of old behavior.

For an admitted extended schedule `s`, let `restrict K s` delete tokens of new
participants. Prove after every prefix, old local observations and ledger on `S`
match the old runner on `restrict K prefix`. The simulation treats a new step as
stuttering only under this projection; the new step may change its own state and
may refuse. Prove restricted complete schedules are complete. Include exact old
failure reasons, successful-prefix receipts and frozen outputs, not just final
invariants. The theorem imposes no success condition on new peers in ordinary
interleaving because a peer's refusal does not halt the old streams.

Contextual equivalence is quantified over a declared grammar of contexts that
preserve these hypotheses. First admit sequential continuations that consume the
same projected cursor interface and compatible interleaving peers. A context that
reads an omitted ledger cell, directly inspects omitted diagnostic worlds, changes
an old capability, or adds a transaction-wide abort boundary is excluded. Prove
congruence for each constructor from actual executor correspondence. Do not call
one endpoint equality a general full-abstraction theorem.

Acceptance: new participant changes unrelated collateral and may refuse while old
observations remain exact; new participant writes an old snapshot cell and breaks
equivalence; initial protected balances differ and break a guard; malformed added
catalog entry blocks admission; additional capability entry changes the next
issued ID. The last case establishes why administrative extension needs a distinct
identity-renaming/provenance theory, not a ledger-only disjointness argument.

## Increment M6: atomic boundaries and metatheory transfer

This increment depends on the accepted Atomic implementation and M1–M5 as needed.
Inspect its real APIs before freezing file names or theorem statements. Transfer
the finite participant/group simulation to atomic speculation only if transaction
identity, policy, participant table, schedule, global failure position and the
single outer commit boundary are unchanged. The monitor of clearing obligations
must correspond after every accepted speculative receipt, with the same principal
partition and asset/domain lane admission. Prove equality of the final commit or
abort projection; do not infer it only from equal final balances.

Regrouping routing within one transaction may preserve behavior. Moving a commit
boundary generally does not: with entry Alice USD10, an authorized transfer7 to
Bob followed by a refused transfer6 to Carol rolls back Alice to10 inside one
atomic event; two separately committed events retain Alice3/Bob7 before the second
aborts. Reassociation of transaction boundaries needs an explicit restricted law
or remains a negative result. Transient draw/return pairs can similarly settle
within a whole event yet fail if an inner boundary demands early settlement.

Atomic conservative extension is stricter than interleaving extension. A disjoint
added participant that refuses aborts the entire event. To preserve old committed
behavior, the first theorem must require added operations to succeed along the
relevant executions, preserve protected reads, and satisfy the accepted settlement
policy at the same boundary. Prove these success/settlement premises independently
in a concrete instance. If old observations retain the supplied global schedule or
participant list, use an explicitly restricted old-observation projection; raw
atomic observations cannot be equal after adding new identities or receipts.

No automatic cross-transaction export of aborted snapshots, committed mint count
from tentative receipts, or empty-lane witness of meaningful transient accounting
is allowed. Nested savepoints, callbacks and arbitrary multi-vault settlement stay
outside these laws unless given their own operational semantics and gate.

## Dependencies, counterexamples and evidence obligations

M1 and M2 can be planned independently after the shared source is accepted. M3
reuses their observation/interface decisions; M4 requires actual M3 execution;
M5 requires M1 configuration correspondence and M3 prefix simulations. M6 waits
for the actual Atomic contract. The initialized basic n-ary rule and richer causal
monitor rule may be separate OpenSpec changes if the latter's financial instance
expands the scope. No increment is accepted by checking off a later roadmap item.

Keep these false stronger laws as named negative companions:

| False claim | Defeating case |
| --- | --- |
| Every grouping is behaviorally interchangeable | Restarted child loses a prior output or uses boundary index zero; nested commit changes rollback |
| Disjoint writes suffice for commutation | One stream writes a cell read by another's guard or output snapshot |
| Arbitrary shared schedules agree | USD10 vault, competing withdrawals7 and6 |
| Same-type ports imply safe sharing | Foreign write changes the independent declared total; quantity neutrality omitted |
| Binding equality at entry persists automatically | Distinct equal cells, accepted one-sided write |
| Symmetric closure equality completely decides constraint equivalence | Transitive equality makes an extra edge redundant despite unequal symmetric closures |
| Circular assumptions discharge themselves | Both promised facts false, each conditional implication still true |
| Unrelated catalog entries cannot affect old execution | Global catalog validation rejects a new duplicate/invalid component |
| Disjoint administration preserves exact receipts | Appending a capability changes `nextId`; revocation changes point-of-use permission |
| A disjoint new atomic participant cannot affect old behavior | New participant refuses, causing transaction-wide rollback |

Dynamic capability provenance is a separate dependency. A future theorem should
relate every live/revoked entry to an authorized actual issue event or explicitly
trusted initialized entry, preserve tombstones and non-reuse, and establish use
against the current store. It needs actual administrative trace induction and a
policy for concurrent fresh IDs, revocation and atomic rollback. Ledger-only
frames and today's fixed-store parallel theorem cannot supply it. Component
information-flow isolation additionally needs an observation/read support policy;
`canWrite` denial alone is not noninterference.

For each implemented increment, require: actual Lean theorem inventory with full
premises and module provenance; no `sorry`, custom axioms or `native_decide`;
nonempty named runtime checks; separately proved or executed negative companions;
real production mutations for world/store/history/index routing, exact refusal,
configuration lookup and observation fields; positive controls that remain true;
and prior accepted regression suites. Enumerating 90 schedules is bounded
execution, not the generic theorem. Mutation detection is evidence that tests
exercise the changed semantics, not a proof of the theorem. Compiler typing
refusals, arithmetic reference models and deployed fidelity remain separate.

Before implementation, each frozen plan must identify its concrete source files,
exact theorem statements, independent financial oracles, mutation expectations,
accepted baseline revision and source-preservation manifest. Future names in this
note are proposals. The current findings support a bounded metatheory program;
none close the roadmap before the corresponding executor/proofs and native gates
are complete.

## END FILE

## FILE wiki-llm/sprint-10-operational-interface-bindings-outline.md

Original SHA256: 9cc671a2e54d57b7f295aad65d9028e22851bc655c7fb07082a8444376a073f9; bytes: 7629; rendered SHA256: 9cc671a2e54d57b7f295aad65d9028e22851bc655c7fb07082a8444376a073f9

# Sprint 10: operational interface and binding preservation

The [OpenSpec planning candidate](../openspec/changes/operational-interface-binding-preservation/proposal.md)
fixes increment M2: exact finite-region accounting, conditional declared-total
preservation, and initialized global balance bindings over actual execution.
It has four capabilities,17 requirements,57 scenarios,34 unchecked tasks,
20 fixture contracts,14 planned source mutations and65 inherited CLI controls.
No M2 implementation or planning acceptance is claimed.

Sprint9 is accepted and delivered. Its authoritative identities are:

- Lean source `eec499d613688137a341f3556cd80ca461dd2ee9`.
- Source/evidence delivery `ec9ed80457d7a9c4064d26ab193591579027abae`.
- Archive and verified remote `9908d9b56be2d5ed2b58a16fa8d28b23f33733ff` on
  `semantic-kernel-pivot`, without a main merge.

[Archive delivery](../review/semantic-kernel/sprint9/archive-delivery.json) and
[final acceptance](../review/semantic-kernel/sprint9/acceptance/final-acceptance.json)
retain exact review and delivery identities. The
[M2 dependency/baseline binding](../review/semantic-kernel/sprint10/planning/official-preparation/dependency-baseline.json)
checks relevant source equality through delivery and preserves original execution
identities:16 Lean commands,14 Metatheory detections and65 controls at eec499d;
13 historical suites at c880acf with scoped dependency equivalence. These are
accepted predecessor evidence, not executions of new Interface code.

Implementation waits for the same frozen S10 candidate to receive nonauthor stock
GPT-6 and native Fable5.1 medium planning acceptance. Request
`claude-fable-5-1[1m]` with `--effort medium`, recording the actual returned model.
Substantive implementation/evidence reviews use native Grok and Fable5.1 medium.
Stock GPT-6 implements through the Codex harness. No Foreman.

## Mathematical and runtime scope

Use the existing typed state, actual evaluated receipts, static component resource
ports, sequential cursors and binary Interleaving. Introduce no new storage alias,
financial primitive, participant scheduler or transaction operator. Preserve the
historical `Defialgebra.Interface` and `Defialgebra.Nary` statements.

New modules belong in `lean/DefiKernel/Interface/`. `Regions.lean` supplies finite
set-valued regions, `balanceSum`, actual `receiptDelta`, and an explicit same-domain/
asset well-formedness premise. `Accounting.lean` lifts the actual exact-cell
receipt equation to finite sums, including administrative identity and signed
mint/burn or boundary-crossing deltas. The bridge starts from actual executeStep
success and `Composition.executeStep_sound`, then `Atomic.step_receipt_balance`;
it cannot assume the desired accounting equation or substitute a chosen receipt.

`Bindings.lean` resolves globally qualified resource exports and queries exact
same-domain/asset balance equalities. Live resource names are distinct from
historical output observations. Actual imports identify the same exported cell;
a binding between different cells demands an initialized invariant. The query
has catalog-first and exact left/right/type/balance precedence as fixed in the
[design](../openspec/changes/operational-interface-binding-preservation/design.md).
It is a concrete query, not an inferred semantic certificate.

`Preservation.lean` derives every-prefix invariants from initialization and locally
quantified actual-step obligations. Region conservation needs actual write
confinement and neutrality over the region's shared portion. A state-dependent
declared total additionally needs value-valued support and writes excluding that
support. Equal initial balances alone, catalog validity and whole-asset supply
neutrality do not establish those premises. Equal actual endpoint receipt effects
preserve initialized edge equality; refusal and skip identities preserve balances
while administrative store changes remain observable.

The accepted M1 equation `Metatheory.runGroup_eq_continueRun cfg boundaries cursor group`
relates the actual recursive group executor to continuation on its flattening.
Use its full cursor equality. Arbitrary supplied cursors require actual advance/
continuation induction or an entry-indexed suffix trace: existing genesis
`TraceSound.nil` cannot justify arbitrary old history or a nonzero entry index.
Count only new successful event receipts after the supplied entry-event prefix.

Global edge-list concatenation, reorientation, duplicate/permutation and
associativity laws concern agreement or query success, not identical first-error
payloads or participant regrouping. Equal symmetric closures are sufficient for
agreement equivalence, not necessary: transitive equalities give the explicit
counterexample. No finite-participant executor is introduced by three port names.

## Concrete witnesses and evidence

The design specifies the complete finite universe,20-cell ledgers,17-entry initial
store, operation templates, exact permissions, receipts, outputs and failures.
Expected observations must be constructed independently of production queries and
executors. Nonzero transfer, boundary loss, minting, repeated receipt targets,
private/exposed total support, aliasing and deliberately broken initialized
bindings provide distinct successful and refused cases.

F07 retains its single paired-debit witness and adds an actual M1 seq of two
op102 leaves from5/5/0:4/4/2 then3/3/4. Each prefix has an independent full expected
cursor and successful A=B query. This witnesses initialized group-binding
preservation. F16 starts at6/4, absolute index2 and supplied old output history;
its snapshot-driven group returns to6/4 at nextIndex4. It tests total/history/full
cursor preservation and is explicitly not an initialized A=B witness.

F17 executes paired debit, peer paired debit and refusal. F19 orders left success,
left refusal, then peer success; F20 also skips a failed left suffix before that
peer. Expected4/4/2 refusal retention and later3/3/4 peer state, exact stores,
histories, local indices and actual successful receipt counts are mandatory.

All14 planned mutants must compile, flip their designated independent comparison
and preserve their specified sibling. Two schema-level global positives and the
per-mutant sibling matrix remain distinct; neither may silently stand in for the
other. The full65-case predecessor adaptation binds payloads, names, root/namespace,
proof/error patterns and expected exits. Command/harness timeouts are600/1500
seconds with actual wall time; blocked or compile-only outcomes get no financial
detection credit. Complete proof inventories retain full statements, actual axioms,
private/generated names and generic/instance/counterexample distinctions.

## Remaining gate and roadmap

The [author preparation](../review/semantic-kernel/sprint10/planning/official-preparation/READINESS.md)
will support an exact committed planning bundle. It does not replace independent
planning review, implementation evidence, native source/evidence acceptance or
verified delivery. New runtime definitions precede `-- BEGIN PROOFS`; Lean checks
run from `lean/` with the pinned toolchain and no sorry/custom axioms/native_decide.

M3 remains finite-participant execution and initialized causal induction. M4–M6
retain tree simulation, compatible schedules, active extension and stronger Atomic
conditions. Claims/liabilities/asynchrony, capability provenance, serialized
certificates, corpus provenance, untouched evaluation, machine arithmetic,
financial libraries and deployed fidelity remain separate roadmap obligations.

## END FILE
