# Sprint 8 independent GPT-6 planning audit

**VERDICT: ACCEPT WITH LIMITATIONS. No material blocker and no required planning revision.** This verdict accepts the bounded plan for implementation after its recorded gates; it is not a proof, runtime result, or permission to bypass Sprint 7 delivery.

Reviewed candidate: `7a73b2d973ae704d5bb38fed9ea389f8ac8b7bff`. Source context: `bea105ec72e633a2dd66c663b96d0b552e1814a8`. Bundle: `r1-bundle.md`, 546,935 bytes, SHA-256 `769ac255e7003145dc0a473a5edf723f2acdf6a1fddad71b1e5b8dee96271ec6`.

Reviewer: stock Codex agent `/root/sprint7_plan_gpt6`, requested `gpt-6-astra`; independent provider/build telemetry is unavailable. I did not author this plan or read the native Fable planning verdict. I previously implemented parts of its accepted Sprint 7 dependency. No Foreman, provider call, source/spec edit, or commit occurred in this audit.

## Checks actually performed

`r1-gpt6-checks.json` retains 123 passing identity/coverage checks, exact commands, UTC times, full command output, executable identity, and individual input bindings. All 60 embedded files match their hashes, lengths, candidate Git objects, and current bytes. All 49 implementation/context files selected from the accepted Sprint 7 base match that base. The four specs contain exactly 16 requirements and 49 unique scenarios; all 40 tasks are mapped, with nonempty planned evidence and no implementation claim. No Atomic Lean or Python implementation exists.

OpenSpec 1.10.0 strict validation and status commands returned exit zero. This establishes schema/coverage consistency, not financial correctness. I inspected the full proposal/design/four specs/tasks, coverage map, current execution/receipt/effect/preservation interfaces, relevant Interleaving trace/invariant rules, and the historical Interface/Nary scope. I also verified the 18 distinct mutation obligations and parsed all 52 existing CLI control definitions without executing them as Atomic controls. No new Lean theorem or financial execution is claimed.

## Semantic and proof assessment

The plan has a coherent operational boundary. `design.md:32–47` specifies exactly one existing `Interleaving.advance` per running token and reads the attempt appended at the previous attempt count. Existing `Machine.accept` and `Machine.refuse` append exactly one attempt, while skip appends none. An induction can therefore identify the speculative machine with `Interleaving.runPrefix` on the actual processed token prefix. Recording the first abort before further advancement makes global stop a direct fold law. Complete admission plus the existing active-index/count laws makes a complete un-aborted run exhaust both branches. There is no need to recompute execution or assume the desired prefix equality.

The clearing equation is supported by actual source interfaces. `Composition.StepSound.invoke` carries the real `applyEvaluated ... = .ok post` equation. `Typed.applyEvaluated_ok_iff` gives, for the exact vault cell, `post.balance = pre.balance + e.effect`; `Evaluated.effect` already sums every matching delta. Updating exactly the authenticated invoker's entry by subtracting that effect cancels the cash change once in the participant sum. Duplicate-free participants and admitted static-boundary coverage are the needed premises. Refusal/skip contributes no cash or debt change. Updating obligations before a successful-step supply abort correctly preserves this invariant even in that diagnostic state.

The settlement policy is deliberately stronger than aggregate cash conservation: exact zero is required at every configured lane/participant key. The under-return, over-return, cross-principal, cross-asset/domain and omitted-last-key scenarios exercise distinct ways aggregate tests can fail. Negative intermediate credit is coherent with the signed obligation table while cash remains nonnegative. Entire domain/asset signed supply comes from the actual receipt, so a nonvault mint cannot bypass a check that inspects only vault movement. This is a checked net-supply restriction, not a prohibition of all possible gross mint/burn components or a deployed transient-storage model.

Public rollback and speculative accounting are correctly separated. The noncommit constructors retain the initial full world and exclude committed inner data; diagnostics retain the real speculative movement. Commit accounting, authority, store and supported frames can be inherited through actual-prefix correspondence and admission's analyzed footprints. The converse Interleaving theorem explicitly retains policy and final-clearance premises. An underlying successful but unpaid draw supplies a concrete counterexample to dropping those premises.

The macro invariant rule has a noncircular route: use Sprint 7's own-invariant local obligations, independent initialization, guarantee/rely inclusion and peer stability on the actual speculative prefix; use entry-world identity on abort. Final zero obligations need not hold internally. Existing Interface conservation and Nary binding-agreement statements remain unchanged and are not promoted into operational atomicity or associativity claims.

## Eighteen production mutation obligations

All have feasible compiling production paths and independent observations under this plan. Actual source needles, complete inventories and protected positives must still be frozen and executed during implementation.

| # | Mutation | Discriminating witness |
| --- | --- | --- |
| 1 | Retain prefix on abort | Success then refusal; full public entry-world equality fails. |
| 2 | Continue peer after failure | Immediate refusal followed by valid peer; diagnostic attempt count/state changes. |
| 3 | Publish aborted outputs | Snapshot-producing prefix then refusal; committed output list must be empty. |
| 4 | Count aborted supply | Nonlane mint then refusal; public supply must be zero despite diagnostic mint. |
| 5 | Stale entry-world call | Peer movement before a live read; actual receipt differs from independent current-state value. |
| 6 | Peer-history leakage | Peer-only qualified output becomes improperly usable beside a funded own-history success. |
| 7 | Global boundary index | Distinct global/local positions select different principal/time and authority outcomes. |
| 8 | Erase debt without receipt effect | Draw followed by accepted zero-effect operation; debt must persist. |
| 9 | Opposite vault-effect sign | Draw/under-return gives residual +1, not −1; intermediate debt also has exact sign. |
| 10 | Global-sum clearance | Same-lane +7/−7 across principals still requires two residuals and abort. |
| 11 | Collapse principal keys | Those opposite entries must remain independently attributed. |
| 12 | Collapse asset/domain keys | Numerically opposite entries in different assets, and separately domains, remain uncleared. |
| 13 | Omit final lane | Earlier lane clears; only a later real lane remains indebted. |
| 14 | Omit final participant | Earlier participant clears; only the later participant remains indebted. |
| 15 | Accept lane supply | Nonvault lane-asset mint aborts; authorized nonlane supply with a cleared lane commits. |
| 16 | Resurrect revoked grants | Funded revoked invocation refuses while its live sibling succeeds. |
| 17 | Omit exact abort field | Equal public abort pair passes; pair differing only in position/reason fails comparison. |
| 18 | Omit exact residual field | Equal residual pair passes; changed quantity or qualified key fails comparison. |

Mutations 10/11 and some rollback/publication cases can share observations; the plan explicitly requires that overlap to be disclosed. Under/over-return and peer credits need actual independent funding so the intended settlement outcome is reached instead of an earlier insufficient-funds refusal. Omitted-key tests should execute nontrivial earlier-key activity that clears before leaving the later key nonzero. Empty batch mode is a useful control but cannot satisfy the transient-evidence requirement.

## Ranked implementation watchpoints; no planning blockers

1. **Actual append witness and accepted policy premises** — `design.md:32–47,145–157`, tasks 2.4/4.1/4.4. Prove the previous-count lookup is the new actual attempt; do not fall back to the old last attempt on a skip. Carry participant coverage and uniqueness from admission into reachability. State clearance over the complete admitted key domain, or additionally prove outside-domain table entries remain zero. These are already specified obligations, not new conditions on a financial theorem.
2. **Mutation observability and compilation** — `design.md:187–205`, tasks 7.2–7.6. Mutant 2 must be detected through stopped diagnostics: unchanged public rollback alone cannot reveal extra peer work. Mutants 3/4 must alter a real executable publication/accessor path while remaining well typed despite separated constructors; a constructor type error earns no credit. Fix the concrete mutation sites and protected controls before claiming their completion.
3. **Atomic observation boundary** — `design.md:77–80`, task 3.5. Implement the new comparison explicitly. Existing `Interleaving.observationsEqual` intentionally omits the schedule, while Atomic must retain label, full schedule, outcome kind and all committed fields. Changed-field pairs must invoke the production comparator.
4. **Dependency gate and authoritative design** — task 1.2 and the migration section require accepted Sprint 7 delivery and a fresh accepted baseline in addition to both same-candidate planning verdicts. The earlier investigation draft's alternative direct-step route is historical exploration; the frozen design selects reuse of `Interleaving.advance`. The wiki's brief authorization summary should be read with these explicit gates, not as overriding them.

The 52 existing defensive CLI cases are a realistic adaptation target, including source closure, proof-boundary placement, malformed/empty/partial output, compile-only failure, survivor, unsafe output and drift controls. They must run against the actual Atomic paths; the existing logs are context only.

Limits remain material: finite binary supplied schedules, fixed capability store, exact rational/proof-carrying cash, trusted configuration/boundaries/authority provenance, explicit frame support and invariant premises, and a restricted loan/return clearing policy. No automatic premise inference, general negative spendable balances, arbitrary schedule equivalence, full Balancer fidelity, reentrancy, distributed atomicity, liveness or broader associativity is established. Both planning verdicts, the Sprint 7 delivery dependency, and a fresh baseline must pass before Atomic implementation begins.
