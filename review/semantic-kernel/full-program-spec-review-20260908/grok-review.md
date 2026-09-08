# Independent OpenSpec program review — reusable verification platform

**Verdict:** CHANGES REQUIRED

**Requested model:** native Grok 4.6 (`grok-4.6`)
**Actually reported model:** Grok 4.6 (this session identity: “Grok 4.6 released by xAI”). No separate native-CLI usage JSON was produced in this review-only turn.

**Reviewer role:** native Grok reviewer. Advisory review only. This is not proof acceptance, implementation acceptance, or a planning-gate close.

**Target:** `/home/charl/defiformal/review/semantic-kernel/full-program-spec-review-20260908/frozen-program` (snapshot of `openspec/changes/reusable-verification-platform-program`). Citations below use original-relative paths as if in that change directory.

**Input identity:** parent `input-manifest.json` at head `a12b7cac05a818cc8d35c2ca440b7170a2807e92`. All 15 frozen files hashed SHA-256-equal to the manifest (verified by recomputing hashes before reading for judgment). Prior `program_plan` acceptance labels were ignored.

| Frozen file | Manifest SHA-256 |
| --- | --- |
| `.openspec.yaml` | `d740e1358ca576cf30074fdb7ab8c63cd9fe497791bd812e5004864d124060ba` |
| `proposal.md` | `c50884c0712a2c04b12195a80ae198f3f2d3dcc8dcdbe8d2556061feae8220c0` |
| `design.md` | `466a40a03e37fe979f325cf81a350ce4b0c58299e909f30f01d71670680b692d` |
| `coverage.md` | `0f41a04838dae49969b9a609104624283d9921a7f60729cd2ebec9733fe21028` |
| `sprint-plan.md` | `8ab5757530a6e24e272c27a75d38680b9cfb38b5479cc5859da34f2f373d0a2d` |
| `tasks.md` | `c3f50d93f15200c54fd957e8e7bbbd84985f1415cdf0c6142af2453dd916a0f7` |
| `sprint-index.json` | `32e2e0a5b6be609916240ad6f332cf615e2a38b4f73133afc8eb1ff9751f41f0` |
| `legacy-task-disposition.json` | `a2a404d629abae42d1ace7553d5a5a7eafad3f11720f890a53164d3b0b6c063a` |
| `proof-obligation-dependency-matrix.json` | `fdb00948a93d39af41c061c83ce10ad121ea3df4918ceae684d421fba4d0b636` |
| `specs/reusable-platform-program/spec.md` | `f767856f0f4f4a07bb90093f347fd4e8b89db6e48c5ca923880d58c2578804f9` |
| `specs/minimum-reusable-contracts/spec.md` | `fde0d120524c5a6ae317cb9802ac249a382adb17d0786cadefef3ad6d5a74d2e` |
| `specs/remaining-metatheory-lifecycle/spec.md` | `c5cbd187580585f4861caf793a941f18d00cc668f129370e454f38069eeba02f` |
| `specs/corpus-historical-honest-reporting/spec.md` | `8e3bf458a6c2fea6ba56d43968993b063495137c1e9cc3355ee3ae668b78e0ed` |
| `specs/source-bound-library-families/spec.md` | `380956fbb2a3a9222650c3ffd0ac71c5f2703c484f430054d8245ee5a62af410` |
| `specs/certificates-adapters-evaluation-publication/spec.md` | `4e1defb63b4c209f9a8449932877c0a763065f1ddba4b4919f6407c857b9e206` |

---

## Why this is CHANGES REQUIRED

The program is a real remaining-agenda plan: 37 sprint IDs, six capability specs, a hard DAG that matches strategy-audit sequencing on M4→M5→M6, Uniswap-token0-first, P18-from-P16-only, certificates-not-prerequisite, Claims/capability off the M4 blanket, blocked-work-is-not-P37, and obligation-class split. Those are the right architectural choices.

They are not enough. The **machine index, coverage table, proof matrix, and executable checklist disagree with the specs on the exact predicates that prevent false completion**. In this repository that is the expensive class of defect. A later author can follow `tasks.md` and `successful_exit` strings, miss work the specs still require, and mark R-ids or P37 terminals done.

This is not an omitted pinned API. Deferred pins with `blocked_missing_source` / `blocked_unavailable` are present and mostly honest. The failures below are omitted executable obligations, overloaded success predicates, and source-line errors.

---

## Findings

### F1 — Platform resource gate is not the P17 success predicate (Important)

**IDs:** P17, P21–P29; `minimum-reusable-contracts` two-case reuse; strategy PLAN.md §4.

**Where:**
- `specs/minimum-reusable-contracts/spec.md:55–69` requires the stronger platform gate to be token0 kernel bridge plus both adapters on the same named executor result; arithmetic-only reuse MUST leave that gate open.
- `specs/source-bound-library-families/spec.md:39–41` and `:45`: `P21`–`P29` SHALL start only after the measured two-case reuse gate except source-readiness inspection.
- `sprint-index.json:142–160` `resource_gates.two_case_reuse.id` is `"P17"` with `gates: P21–P29`.
- `sprint-index.json:1077` P21 `"resource_gate": "P17"` while P21 `entry` at `:1092` says “P17 platform reuse … not arithmetic-only reuse”.
- `sprint-index.json:944` P17 `successful_exit` explicitly allows “Arithmetic-only reuse may be published while that stronger gate stays open”.

**Failure scenario:** P17 lands a vault pin, proves share/asset bounds, publishes arithmetic-only reuse, and records `successful_exit` without the token0 Typed wrapper. A mechanical runner sees `resource_gate: "P17"` satisfied and starts P21–P29. Breadth proceeds without the measured platform reuse the strategy required. P37 can still close because P17 and P21 are both terminals.

**Minimal remedy:** Give the resource gate its own machine predicate, e.g. `resource_gate: "P17.platform_reuse"` requiring the kernel bridge plus both adapters on one named executor result. Keep arithmetic-only P17 as `partial_delivery` or a distinct field. Do not treat P17 `successful_exit` as that gate.

---

### F2 — `successful_exit` strings include blocked alternatives (Important)

**IDs:** P31, P22–P25, P27–P28, P34; R34; whole-program DoD.

**Where:**
- `sprint-index.json:21` field contract: “Rejection or blocked status is not this field.”
- `specs/reusable-platform-program/spec.md:7–13` and `:103–109`: blocked/rejected dispositions MUST NOT be an alternative completion path; `successful_exit` is independently accepted delivery.
- `sprint-index.json:1454` P31 `successful_exit`: “or that adapter remains `blocked_unavailable`. Blocked adapters are not successful_exit…”
- Same pattern: P22 `:1146`, P23 `:1179`, P24 `:1211`, P25 `:1243`, P27 `:1307`, P28 `:1344`, P34 `:1561`.

**Failure scenario:** All four adapters lack verified interfaces. An author copies the first clause of P31 `successful_exit` (“or that adapter remains blocked_unavailable”) into a delivery record and ticks P31. P37 `dependencies` (`sprint-index.json:1654–` and `p37_required_terminals`) include P31. Whole-program completion then follows from unavailable third-party interfaces, which is exactly the completion-by-deferral the spec forbids.

**Minimal remedy:** Put only the delivered-success predicate in `successful_exit`. Move blocked/open language exclusively to `terminal_disposition` / `stop_repair`. P31 successful exit requires four actual implementation-or-verification results against pins, not four blocked records.

---

### F3 — Corpus original task 2.4 is not on the executable checklist or P10 exit (Important)

**IDs:** corpus-provenance-adjudication 2.4; P09, P10; R13.

**Where:**
- Original contract `openspec/changes/corpus-provenance-adjudication/tasks.md:12` (task 2.4): after 6.1, implement bounded `collect` with exact fixture counts (three requested-target slots, two attempts per target, five redirects, 30-second deadlines).
- `coverage.md:105` and `sprint-index.json:625–628,656–657` assign 2.4 to P10 after P09 6.1.
- `legacy-task-disposition.json` owner_sprint `P10` for task 2.4.
- `tasks.md` P10 section `:86–94` (program tasks 11.1–11.4) executes 5.4, 3.3, 4.1–4.3, 2.1–2.2, and review. **2.4 is absent.**
- `sprint-index.json:644,664` P10 `exit` / `successful_exit` name challenge, dependencies, residue, and reference recovery. They do not name collect.

**Failure scenario:** P10 closes after a Liquity-challenge decision and reference reconstruction. Original 2.4 never runs. `tasks.md` has no unchecked box left. Coverage and legacy still list 2.4 as remaining_work owned by a finished sprint.

This is an omitted requirement, not a deferred pin.

**Minimal remedy:** Add an explicit P10 (or P09-after-6.1) task that executes original 2.4, and add collect to P10 `exit` / `successful_exit`. Keep the “no invented collector runs” stop condition.

---

### F4 — P09 8.3 can archive the corpus package before P10 finishes (Important)

**IDs:** corpus 7.1–8.3; P09; P10.

**Where:**
- Original 8.3 (`openspec/changes/corpus-provenance-adjudication/tasks.md:51`) delivers/archives the package after 7.
- `tasks.md:87` and `sprint-index.json:569–586,596,614` put 7.1–8.3 in P09 successful_exit.
- P10 still owns original 2.1, 2.2, 2.4, 3.3, 4.1–4.3, 5.4.

**Failure scenario:** P09 10.4 marks 8.3 complete and archives `corpus-provenance-adjudication` while P10 collect, pins, and the Liquity challenge are still open. Historical checkbox/archive bytes then look like package completion.

**Minimal remedy:** Restrict P09 to 7.x tooling plus 8.1–8.2 on the P09 overlay. Move original 8.3 package archive to after P10, or state that P09 8.3 must not archive the original change while P10 tasks remain.

---

### F5 — R18 is closed on P19 while compatibility and library instantiation are P20 (Important)

**IDs:** R18; P19; P20; tasks 21.2–21.3.

**Where:**
- Roadmap R18: typing, footprints, authority, accounting, composition compatibility, library instantiation, assumptions.
- `coverage.md:27` maps all of R18 to P19, certificates 3–6.
- `sprint-index.json:1006–1011` P19 `roadmap_ids` include R18; P20 `:1050–1051` has only R19.
- `tasks.md:164` and `specs/certificates-adapters-evaluation-publication/spec.md:23–25`: R18 MUST NOT close without executable `Parallel.admit` / `checkCompatibility` on recomputed footprints and a Lean-checked library instantiation (P20 21.2–21.3).
- P19 `claim_boundary` (`sprint-index.json:1005`) correctly says library instantiation is not an executable pass, which contradicts putting R18 on P19.

**Failure scenario:** P19 checker is reviewed as an implementation candidate. A coverage/index reader ticks R18 because it lives only on P19. Composition compatibility and library instantiation remain `unsupportedForm` / theorem-name tags, which the original certificate candidate (`serialized-kernel-certificates` 6.1, 6.3) actually specified. The program’s own strengthening never becomes the R18 close condition.

**Minimal remedy:** Split R18: P19 owns typing/footprints/authority/accounting/sequential run; P20 owns composition-compatibility and library instantiation. Put R18 on both sprints, or move R18 off P19 until 21.2 and 21.3 succeed.

---

### F6 — Legacy liquidity 1.1–7.3 are labelled “token0 slice” (Important)

**IDs:** P16, P21; R22; unaccepted `concentrated-liquidity-library`.

**Where:**
- P16 claim boundary (`sprint-plan.md:189`, `sprint-index.json:890`, `specs/source-bound-library-families/spec.md:7–9`): standalone `getNextSqrtPriceFromAmount0RoundingUp` (SqrtPriceMath.sol 28–56), no fee parameter, not full traversal.
- Unaccepted liquidity `tasks.md` 2.1–6.5 implement FullMath, TickMath, amount0/amount1 deltas, `computeSwapStep` with fees, one-word bitmap, addDelta, and F01–F45.
- `legacy-task-disposition.json` assigns 1.1–7.3 to P16 with note “Token0 slice and oracle/control repair”; only 7.4 goes to P21.

**Failure scenario (either polarity):**
1. P16 follows the spec and ships only token0. Legacy still shows TickMath/SwapMath/bitmap as P16 remaining_work that is now “owned” by a closed sprint, so those original IDs disappear without a completing sprint.
2. P16 follows legacy and implements the whole first liquidity increment before the two-case reuse gate, violating reuse-before-breadth.

**Minimal remedy:** Re-own original liquidity tasks by actual P16/P21 scope: token0 + oracle/M09 repair on P16; TickMath, SwapMath, bitmap, multi-word traversal, and named remainders on P21 (or a named intermediate sprint). Do not call TickMath “token0 slice”.

---

### F7 — Source line citations for SwapMath cap and pool SPL are wrong (Important)

**IDs:** P21; R22; `source-bound-library-families`.

**Where:**
- `specs/source-bound-library-families/spec.md:49,56` and `proof-obligation-dependency-matrix.json:46,47`: exact-output cap is `SwapMath.sol` lines 89–92; pool admission refusal is `UniswapV3Pool.swap` SPL guard lines 603–613.
- Actual pinned source (`review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/upstream/`):
  - Exact-output cap is `SwapMath.sol:87–89` (`if (!exactIn && amountOut > uint256(-amountRemaining)) amountOut = …`).
  - Lines 91–93 are the **exact-in remainder-as-fee** branch, a different observation class.
  - `'AS'` is line 603; `'LOK'` is 607; `'SPL'` is 608–613.

**Failure scenario:** P21 treats remainder-as-fee as the “exact-output cap success” fixture, or uses `'AS'` / `'LOK'` as the declared pool admission refusal because 603–613 is the cited range. Scoring then credits the wrong Solidity branch.

**Minimal remedy:** Cite cap as SwapMath.sol 87–89; cite SPL as UniswapV3Pool.sol 608–613. Keep `'AS'` and `'LOK'` as separately named guards if they are in scope.

Token0 numbers I did check against SqrtPriceMath.sol 28–56 are right: `(2^96,1,0,*)=2^96`; add `(2^96,1,1,true)=2^95`; remove `(2^96,1,1,false)` fails `numerator1 > product`. Parallel `checkCompatibility` / `admit` / `Compatible` / `checkCompatibility_ok_iff` at `lean/DefiKernel/Parallel/Compatibility.lean:66–95` match the P20 citation. H02/H12 figures in `formal/v3/VERIFICATION.md:54–58,89–95` match P11 (R-only 3,342 / 2,955 / 2,809 vs R∩W 50,223 / 50,611 / 50,276 and exhaustive 32,188,276 / 396,437). Those source bindings are sound.

---

### F8 — Coverage requirement/scenario counts do not match the specs (Important)

**IDs:** coverage map vs six specs.

**Where:** `coverage.md:84–92` vs actual `### Requirement:` / `#### Scenario:` headings:

| Capability | coverage.md | actual in spec.md |
| --- | --- | --- |
| reusable-platform-program | 9 req / 14 scen | 11 / 17 |
| minimum-reusable-contracts | 7 / 10 | 7 / 11 |
| remaining-metatheory-lifecycle | 6 / 8 | 6 / 9 |
| corpus-historical-honest-reporting | 7 / 10 | 7 / 10 |
| source-bound-library-families | 12 / 13 | 13 / 20 |
| certificates-adapters-evaluation-publication | 10 / 12 | 10 / 22 |

**Failure scenario:** A completeness gate treats the coverage table as the spec inventory and never reviews the added scenarios (blocked-adapter-is-not-completion, arithmetic-reuse-does-not-close-platform-gate, missing-pin-is-entry-freeze, per-environment execution, etc.). Those extra scenarios are exactly the anti-false-completion rules.

**Minimal remedy:** Recount from the spec files, or generate the table from headings. Do not ship a stale summary.

---

### F9 — Proof matrix adapter task IDs do not exist (Important)

**IDs:** P31; tasks 32.1–32.8.

**Where:**
- `proof-obligation-dependency-matrix.json:160–163`: implementation tasks `32.5a`, `32.5b`, `32.5c`, `32.5d`.
- `tasks.md:234–237`: Moriarty 32.5, Compact 32.6, ZKIR 32.7, PCT 32.8.

**Failure scenario:** A matrix-driven checker looks for 32.5a–d, finds nothing, and either blocks forever or treats 32.5 (Moriarty only) as covering Compact/ZKIR/PCT.

**Minimal remedy:** Point the matrix at 32.5–32.8.

---

### F10 — P22 matrix calls bound-exhaustion a “specified refusal” (Important)

**IDs:** P22; R23.

**Where:** `proof-obligation-dependency-matrix.json:57–60`. `conditional_property` says if the bound is hit, “the result is the specified refusal”. `exceptional_success_class` and `refusal_class` then say classify revert vs residual at source-entry and do not invent now. Spec `source-bound-library-families/spec.md:59–65` matches the later fields, not the conditional_property sentence.

**Failure scenario:** An implementer freezes “bound exhaustion ⇒ executor refusal” before the pin exists. A later Curve source that returns a residual is then forced into the refusal class, or the family is marked impossible.

**Minimal remedy:** Rewrite `conditional_property` to match the spec: classify at source-entry; do not emit a fabricated convergent output.

Related: P23 `refusal_class` (`proof-obligation-dependency-matrix.json:73`) and P25 `:96` invent current refusals (“empty redeemable set”, “hook revert”) while `pin_status` is `not_established`, against the same spec’s named-proofs rule (`spec.md:129`). For P23 the family requirement also says empty-set refusal MUST be observed (`spec.md:69`). Treat those as **planned expectations to rebind at source-entry**, not as exported current APIs. Same remedy as P22.

---

### F11 — P36 has no machine dependency on a stable schema (Moderate)

**IDs:** P36; R42.

**Where:** `specs/certificates-adapters-evaluation-publication/spec.md:117` MUST depend on accepted residual Atlas work **and** a stable schema from accepted platform results. `sprint-index.json:1631–1632,1649` say that in entry/exit prose. `dependencies` are only `["P35"]` (`sprint-plan.md` DAG and index). `conditional_dependencies` is `{}`.

**Failure scenario:** P35 accessibility lands, P15/P18 schema is still unfrozen, P36 updates the ontology visualization against a moving contract, then P37 consumes P36 as a required terminal.

**Minimal remedy:** Add a hard or conditional dependency on the freeze/increment that actually publishes the evaluated schema (P15 and/or P18, possibly P33 if evaluation schema is the intended one). Name which schema hash P36 binds.

---

### F12 — P12 evidence class is `data_repair` for a Lean proof sprint (Moderate)

**IDs:** P12; R35–R36; standing gate 1.2.

**Where:** `sprint-index.json:742` `evidence_class: "data_repair"`. Original historical tasks 3.1–3.7 are DefiHistorical Convex Lean proofs, saturation, instances, counterexamples. `tasks.md:1.2` says `data_repair` requires CLI/data controls, while `implementation_proof` requires proof/execution/mutation evidence.

**Failure scenario:** P12 is accepted on ledger/CLI controls without complete theorem/axiom inventories, because 1.4 is read as applying only when the sprint class is `implementation_proof`.

**Minimal remedy:** Set P12 to `mixed_behavior` and name which proof vs data gates apply.

---

### F13 — Atlas 7.3 scene-graph fail is not superseded, only “confirmed” (Moderate)

**IDs:** P35; original atlas 1.1, 4.1, 7.3.

**Where:** Original `design-atlas-visualization/tasks.md:1,31,57`: remove three.js; 16×5 matrix; payload gate **fails on any scene-graph dependency**. The program correctly refuses to revive that 3D ban (`specs/certificates-adapters-evaluation-publication/spec.md:101,110–112`) given later Flat/3D authorization. `legacy-task-disposition.json` for 7.3 only says “confirm against current layout”. Confirming 7.3 as written against current `viz/` Scene3D would fail.

**Failure scenario:** P35 rebind runs original 7.3, three.js is present, the sprint is blocked; or 7.3 is ticked by historical checkbox without recording the supersession.

**Minimal remedy:** Explicitly retire or replace 7.3’s scene-graph prohibition with a current-layout budget/conformance rule, and record that original 1.1/4.1/7.3 are superseded rather than confirmed.

---

## What is sound and should be kept

These are not findings. They are the parts a repair must not weaken.

- Hard DAG matches strategy: P01→P02→P03→P04; Claims P06→P07; corpus P08→P09/P10; historical P11→P12; certificates P19→P20; token0 P15→P16 then P17/P18/P21/P30; async P26→P29; freeze P18→P33→P34 with P32; Atlas P35→P36; P37 joins the listed terminals. No cycle. P18 depends only on P16. Capability/Claims/source work are not blanket M4 dependents. Certificates are not a P16 prerequisite.
- Obligation classes are separated: model proof, bounded source execution, representation correspondence, source refinement, external assumptions. Codec cannot discharge P30. P18 may ship with refinement open; P30 remains a P37 terminal.
- Token0 first case is pinned to a real helper, forbids excluding denominator-sum overflow, forbids Python-as-source, repairs M09/F28, and uses actual add/remove/zero observations that match SqrtPriceMath.sol 28–56.
- Vault is not a second AMM; missing pin is `blocked_missing_source`, not success. Fabricated composition is forbidden.
- Empty inventories are blocked (exit 3). Compile-failed mutants are blocked. Author exit is not GPT-6 acceptance. Delivery is `semantic-kernel-pivot` only. Cleanup needs consumer/root/build/CLI evidence.
- Hash bindings that use CURRENT.json `candidate.sha256` match that file (M4, capability, claims, corpus, historical, certificates, liquidity, atlas, reporting_gate). P03 correctly binds M5 `archive_sha256` / `r2_review_sha256` rather than inventing a missing `candidate.sha256`.
- `legacy-task-disposition.json` has 339 rows and 1-1 task-ID coverage of the nine primary-tree packages plus the two sibling unaccepted plans. Original IDs are not relabelled delivered.
- Evaluation freeze, development-75-remain-development, do-not-read-held-payloads, and per-environment nonempty success/refusal are the right evaluation policy.
- Parallel.Compatible-as-Prop vs executable `admit`/`checkCompatibility` is the right certificate composition rule.

---

## Completeness vs original agenda

R01–R47 all appear on at least one sprint in `sprint-index.json`. All 17 CURRENT.json lanes appear. Source-plan environments (line 1116) and Moriarty/Compact/ZKIR/PCT adapter boundaries (lines 1140–1142) have named sprints. M5/M6 are retained despite lacking dedicated unchecked R-ids.

Gaps that are **not** missing R-ids but still leave original work without an honest closer: F3 (corpus 2.4), F6 (liquidity TickMath/SwapMath/bitmap), F5 (R18 split). Those are completeness failures against original contracts, not against the R-table.

Vault, Curve, Morpho, Balancer, margin, and insurance pins are correctly **deferred** via source-entry gates. That is allowed.

---

## Delivery feasibility (not a blocker, a limit)

P37 requires P17, P21–P25, P27–P29, P31, and P34. If no vault pin, no Curve pin, or no Solana/Move toolchain exists, the **whole program stays open**. Specs say that is honest. P18 is the supported-domain interim. Do not add a silent “supported-domain P37”. Do record that calendar completion of P37 is not implied by 37 units.

Uncertainty: I did not inspect worktree archive bytes behind CURRENT hashes, so I cannot confirm those archives contain the theorems the P01/P05/P13/P16 notes attribute to them. Missing artifacts at sprint entry are setup failure, as the plan says.

---

## Dissent and uncertainty

- **F1 vs prose:** P21 `entry` already names “platform reuse, not arithmetic-only”. A reader who treats prose as the contract may call F1 a documentation nit. I dissent from that: `sprint-index.json` says machine-readable fields live in that file, and `resource_gate` is the field a runner will use.
- **P23 empty-set refusal:** I am uncertain whether Liquity ordered redemption’s empty-set behavior is stable enough to pre-declare as the refusal class. The spec both forbids inventing current refusals and requires observing empty-set refusal. Rebind at pin time.
- **Atlas 3D override:** I accept the later Flat/3D authorization as the current contract, against the original OpenSpec 3D ban. I do not accept leaving original 7.3 as “confirm” without supersession (F13).
- **Certificate strengthening vs original 6.1/6.3:** Making library instantiation and compatibility executable in P20 is a deliberate upgrade of the unaccepted candidate. Keep it; just stop mapping R18 as done at P19.
- Coverage R20 lists P13+P19 (`coverage.md:28`) while the index puts R20 only on P19. Tracing noise; R43/R44 on P13 still cover the honest-gate residual of that box.

I did not read other reviewer reports or `review/semantic-kernel/full-program-openspec-20260908/` verdicts.

---

## Scope and validation limits

- Review only. No source edits, commits, push, or implementation.
- No full proof-portfolio build. No `lake build` of the kernel.
- No web. No held payloads, including `/tmp/historical-discovery-r2/discovery.json` and historical held assessment contents.
- Did not unpack CURRENT.json worktree archives; hashes were compared to CURRENT.json fields only.
- Original OpenSpec packages and sibling unaccepted certificate/liquidity `tasks.md` were consulted as historical contracts.
- Local source contracts checked: SqrtPriceMath.sol 28–56, SwapMath.sol 80–97, UniswapV3Pool.sol 595–613, Parallel/Compatibility.lean 66–105, `formal/v3/VERIFICATION.md` measurement table, GATE-REGISTER.md exit-code contract, strategy PLAN.md / CURRENT.json, semantic-kernel design, source plan 1110–1142, roadmap R01–R47.
- An advisory review is not mathematical proof, not independent GPT-6 checking of this report, and not authorization to lift the dispatch hold.

**Required to change the verdict:** repair F1–F10 in the frozen program bytes (machine index, tasks.md, coverage.md, proof matrix, and the two source-line citations) so that successful_exit, resource gates, R-id mapping, and the executable checklist cannot complete work the specs still require. F11–F13 may ship as documented limitations only if F1–F10 are fixed.
