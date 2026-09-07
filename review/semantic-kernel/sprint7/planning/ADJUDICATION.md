# Sprint 7 planning audit adjudication

Status: **planning gate passed** on candidate
`bf3fb509b211d7cd92eb68410fb49dc5f4e20e7d`, bundle SHA-256
`b8bd48445352214c3e2f09004c5cbe29928bf388adf256d01759b307fc952997`.
Both reviews independently accept with limitations, with no material blocker.
No new Interleaving code existed at either review or at this gate decision.

## Evidence and identities

- [GPT-6 report](r1-gpt6.md): stock Codex independent agent
  `/root/sprint7_plan_gpt6`, requested `gpt-6-astra`; separate provider/build
  telemetry unavailable. Verified all 39 frozen file/bundle bindings, 26 base
  context entries, 43 unique scenarios and 37 tasks, and strict OpenSpec validation.
- [Fable raw response](r1-fable.json) and [invocation](r1-fable.invocation.json):
  native `claude` requested `claude-fable-5-1[1m]`; reported main model
  `claude-fable-5-1` with auxiliary `claude-haiku-4-5-20251001`. Exit zero,
  substantive ACCEPT WITH LIMITATIONS final report. No independent execution.
- [Parent checks](r1-parent-checks.json): 43 identity/consistency checks, including
  seven local links, no new implementation and the completed baseline.
- [Baseline](baseline/verification.json): ten actual commands exit zero and all
  protected input bytes are unchanged. The exact source inventory, logs, command
  arrays and hashes are retained alongside it.
- [Gate](gate.json) binds exact candidate, report hashes and model identity limits.

These are advisory planning/source reviews, not mathematical proofs or results
from the future implementation. The current task/wiki status edits postdate the
frozen candidate; proposal/design/spec requirements remain byte-identical.

## Adopted nonblocking guidance

1. Supply aggregation will be an executable definition before the proof boundary,
   over actual successful global attempts. Both branches will have nonzero supply
   in its independent runtime oracle. This makes mutation 12 reach production code.
2. Before any attempted invocation, own consumed slots equal own successful index.
   Prove this invariant. Mutations 10/11 must use global schedule position or the
   peer counter; exchanging equal own counters would be a survivor, not detection.
3. Snapshot mutation 9 will rewrite selected own output history inside advancement
   by resolving its component/port cell in the trusted catalog and reading the
   current shared ledger. Correct production execution retains frozen values.
   No mutation of an unused helper or expected fixture is counted.
4. Define the canonical branch projection in the Interleaving namespace from its
   local state. Mutation 14 edits the actual function used by public comparison;
   a changed-failure negative and equal positive distinguish omission.
5. The replenishment/refusal fixture includes at least one later static slot in the
   failed branch, scheduled after peer replenishment. The correct result skips it
   and retains its first failure, even though later liquidity could fund a retry.
6. Formal recovery uses explicit full-ledger pointwise equality and complete-store
   equality plus exact branch observations, matching existing observational
   equivalence. If represented as record equality, derive it with extensionality
   and proof irrelevance. No weaker financial-field projection is substituted.
7. The total-USD instance exercises shared support and interference, but its local
   no-supply proof does not need the own-invariant antecedent. Record that scope
   in the final proof inventory rather than claiming every conditional premise is
   exercised by this one example.
8. Size compile timeouts from actual control execution; the new projection may
   retain larger imported proofs. Disjoint successful fixtures protect mutation 2.
   Report overlap between stale-world and isolated-world mutation oracles.

Fable could not execute strict validation; the parent and independent GPT-6 did.
Its wording note about an “invalid complete schedule” means a schedule failing the
specified complete-count predicate, not a second accepted schedule category.
No semantics or normative obligation changes are required. These guidance items
implement existing tasks 3.3–3.5, 4.2–4.3, 5.3–5.4 and 7.2–7.5. The initial round
therefore closes planning without a redundant rereview. Substantive implementation
and full native Grok/Fable result reviews remain mandatory.
