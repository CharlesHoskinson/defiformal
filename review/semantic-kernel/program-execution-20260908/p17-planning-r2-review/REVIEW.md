# Independent P17 planning repair r2 review

**ACCEPT_WITH_LIMITATIONS for the concrete planning slice only.** R1–R3 are closed with the sparse-post interpretation below. This is independent planning advice for root adoption; it does not accept source execution, implementation, production mutations or substantive `P17.platform_reuse`. All candidate execution/reuse gates remain false.

The reviewed archive is `p17-planning-candidate-r2.tar.gz`, SHA-256 `fe36fb051a97aac8ca3f7cdfec037d4faf9351fa0447c909f2353504d921f0fe`. It contains 67 files: 19 planning files, 23 preserved r1 author-evidence files and 25 r2 author-evidence files. All 43 rows in the r2 author manifest matched before the independent freeze. All 67 copied files still match afterward. Original r1 archive `000d48b5664a18ac3f4378f48bb150a51cf32427ff63d36d1dcf28e9cf1d72f1` and every r1 author-evidence byte remain unchanged. Fifteen planning files changed; the pin, compiler plan, API binding and source-readiness spec are unchanged.

Independent reviewer: nonauthor GPT-6, stock Codex subagent `/root/p17_plan_review`, same reviewer as r1. Runtime instructions identify GPT-6; this subagent has no exposed exact alias/build or separate provider-returned model identity. No invented identity is reported. No Foreman or extra agents were used.

Native author: requested `grok-4.6`, high effort; terminal reports `grok-4.6-build`, session `01a084ca-957c-7b00-815f-c15fd32816c3`, request `c7fa43b2-17e1-433f-8c2c-82c88e901e43`, 22 turns. Root's process receipt records actual process exit 0 and `end_turn`, finished `2026-09-09T16:15:06.003396+00:00`. I waited for that receipt before inspecting or freezing r2. The native log hash matches its receipt.

## R1: corrected post-observation negative

`P17-TH-NEGATIVE` now fixes the honest deposit template, positive assets, and real preconditions; its post equality is derived from the delivered `Typed.execute_ok_iff`. The incorrect candidate with unchanged vault USDS is rejected as an observation mismatch, not as a failure of `Evaluated.Valid` or an executor refusal. The positive `P17-POS-DEPOSIT-CREDIT` has the same positive amount and effect map. The two assets' effect/supply arithmetic agrees.

The delivered predicate still takes only store, context, request, pre-state and effects; the candidate accurately distinguishes the theorem's separate post equality. Generic per-asset accounting is no longer claimed to prove cross-asset backing. This closes the mathematical planning error without changing the delivered theorem. Future Lean implementation must construct the real template and derive its evaluation, validity and post equation; the review's arithmetic inspection is not that proof.

## R2: deterministic stateful witnesses

All 16 scored source fixtures now contain common defaults, D0/D1 overlays, explicit overrides, and a stored pre-state that equals their merge. Fixed actor aliases are distinct valid addresses. Relevant balances, share and underlying supply, allowances, initialized state, chi, rho, ssr and time are bound. D1 mint has `10^18+1` USDS and matching finite allowance. Success-entry allowance is finite and consumed; the ambiguous allowance alternative is gone from fixture values.

D1 explicitly seeds chi after proxy initialization and claims no protocol reachability for that seed. Protected redeem/withdraw controls independently seed/fund the needed shares, totalSupply and vault USDS instead of invoking a mutated deposit. Each declared source success/refusal partition agrees with an independent inspection of the selected captured source and mock guards. The characteristic source mutation sites remain unchanged, and their protected controls remain independent of the edited operation.

**Required editorial interpretation for adoption:** the JSON `expected.post` dictionaries are sparse assertions, despite design prose calling them complete. The complete selected post-state is the fixed pre-state plus the source/mock changes: entry debits sender USDS, credits vault USDS, consumes finite allowance, credits receiver shares and increases share supply; exit debits owner shares/share supply, consumes finite share allowance when applicable, debits vault USDS and credits receiver USDS. All other observed cells are unchanged in this stable-time domain. This is the complete common transition rule used for this acceptance; it does not permit omitting observed cells from future comparison.

`source-witness-review.json` preserves independent complete post projections for all nine successful source fixtures under that interpretation, alongside the seven refusal classifications. Every literal post assertion in the candidate matches. There is no source behavior change or fixture exemption. Actual contract addresses, storage layout/seeding, deployment/setup receipts and genesis hashes still require binding before scoring. Implementation must keep bound vault/token addresses distinct from the fixed actors and zero, as the fixture identities intend.

## R3: logs and underlying allowance

The observation contract now binds full per-operation logs including the underlying USDS Transfer and an explicitly vault-emitter-filtered projection. All nine successful fixture log arrays match the captured mock and vault effects in complete order, including zero-valued transfer events. All USDS transfer amounts and emitter identities match independently derived expectations. Underlying finite allowances are observed before/after entry and consumed correctly.

Refused observations retain the supplied pre-state beside the revert and expressly do not claim experimental rollback verification. No fake post-world is produced. Unrelated logs remain retained and cannot be relabeled as vault events. This closes R3.

## Reuse and execution limits

The repaired design explicitly keeps the synthetic token0 register model-only. Its input register is bound to the input sqrtPX96; scale 1 is raw Q96 units; the output comes from the actual successful library word. The nonzero ordinary-add witness changes `2^96` to `2^95`. It proves no Uniswap source storage, reserve conservation, swap settlement or cashflow.

The same delivered rounding contracts and `Typed.execute_ok_iff` remain named for both token0 and the stateful two-asset vault adapter. Authority, funding, registry/context authenticity, finite universes and actual template evaluation remain real premises to instantiate or record. Future implementation must derive validity and post equations rather than assume desired outputs. No vacuous empty-effect witness, arbitrary quote, vault-only theorem, cloned dispatcher or case-specific checker exception earns reuse credit.

A common recorder is insufficient: one actual parameterized execution/scoring engine must run both source cases and preserve P16's accepted observations and repaired fail-closed behavior. Actual theorem instances, source campaigns, characteristic compiled mutations with unaffected controls, and measured case-two definitions/assumptions/interface changes/effort remain required. Arithmetic-only delivery cannot open the substantive reuse or wider-family spending gate. Composition remains unclaimed; no fabricated token0-to-vault sequence or new P30 prerequisite was added.

Compiler/genesis/dump-roundtrip readiness and actual initialized proxy execution are still implementation prerequisites. P16 source acceptance is separate. D0/D1, external mock behavior, unchecked-update bounds, source-model correspondence and absence of deployed identity remain explicit scope limits.

## Validation and preservation

Fresh OpenSpec 1.10.0 strict validation exits 0. Intact r2 diagnostics pass 199/199; the wrong-literal control exits 1 and names two D1 comparison failures; empty inventory exits 3; unavailable Transition input exits 3. There are 23 requirements, 34 scenarios, 23 unchecked tasks, 16 source fixtures, two model observations and two proposed mutants.

An independent planning checker recomputed all 16 source partitions and all successful selected post assertions/full log sequences from the pinned source's bounded rules: zero mismatches. Two separate comparison controls reject wrong USDS credit and a wrong transfer emitter. These controls return comparison failures inside the independent checker; they are not separate source executions or process-exit claims.

The author's 199 checks do not comprehensively validate post-state values or log contents, and some R1/reuse checks inspect declarations/text. They are planning diagnostics, not semantic proof. This review's complete post/log checks supply the additional bounded evidence; future acceptance still needs actual Lean/Solidity/EVM results. No Lean build, Solidity compilation, EVM campaign or production mutation was run in this review.

The r2 failed-attempt note admits one initial intact-diagnostic failure caused by treating the unaffected deposit sibling as a redeem control; it also admits that the failing JSON was overwritten. Its opening “No failed ... intact-diagnose attempt” sentence is therefore inaccurate. Interpret the later concrete failure record and retained native log as authoritative; the passing final JSON is not a preserved failed artifact. This bookkeeping issue is nonblocking for the planning repair and supplies no mutation credit.

The author worktree has no tracked modifications; its 67 untracked candidate files are exactly this planning/evidence package. Review execution copies and controls are owned scratch artifacts. Candidate, primary source inputs and historical r1 evidence were not modified. Nonrecursive input and evidence manifests bind the review. No commit, integration or publication was performed by this reviewer.
