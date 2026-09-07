# Atomic synchronization planning adjudication

Both independent GPT-6 and native Fable reviews **ACCEPT WITH LIMITATIONS** on
candidate `7a73b2d973ae704d5bb38fed9ea389f8ac8b7bff`, using the same 60-input bundle
`769ac255e7003145dc0a473a5edf723f2acdf6a1fddad71b1e5b8dee96271ec6`.
No material blocker or normative plan revision is required. [Gate](gate.json),
[GPT-6 report](r1-gpt6.md), [GPT-6 checks](r1-gpt6-checks.json), and
[native Fable report](r1-fable.md) retain exact identities and reviewed scope.

This gate covers the four specs,16 requirements,49 scenarios and40 tasks. Actual
Atomic implementation additionally waits for accepted Sprint 7 delivery/archive
metadata and its fresh baseline. No code existed during either planning review.

## Adopted implementation choices

- Append exactly one real existing interleaving attempt at each selected active
  token; inspect the entry at the previous attempt count. Prove its actual prefix
  correspondence, with admitted participant coverage and duplicate-free summation
  explicit in the cash/obligation induction.
- Expose named production committed-history and committed-supply functions on the
  diagnostic result, and make the public projection use them. Public observations
  can have common list/supply fields that are exactly empty/zero on every abort;
  the aborted outcome tag carries no committed inner event. This keeps the required
  publication mutants real and compiling while preserving the specified correct
  behavior. Tests must inspect public production observations, not synthetic helpers.
- Inspect diagnostic attempt counts to detect global continuation after abort.
  Public rollback alone could hide that mutation. Check exact signed residuals to
  detect the wrong-effect-sign mutation; abort-kind equality alone is insufficient.
- Define an attempt-derived outstanding fold and prove equality with the maintained
  atomic table. State the converse correspondence using actual successful
  interleaving attempts, their policy acceptance and fold clearance, avoiding a
  circular premise about the Atomic result itself.
- Restrict edits to Atomic runtime roots. Stale-world, peer-history, boundary-index
  and revoked-grant mutants are real pre-call rewrites in Atomic orchestration.
  Preserve imported Interleaving sources/proofs, and freeze concrete needles before
  production execution. Current historical wrong-world oracle overlap is disclosed.
- Use nonempty lane fixtures with a diagnostic exact nonzero intermediate entry.
  Multi-lane/participant omission fixtures must leave their only residual on a later
  key. Fund all counterpart balances and grants independently.
- Retain supplied schedules in the Atomic comparator for all outcome kinds.
  Use empty-lane batch mode or an appropriate funded multi-participant case for
  an order-sensitive commit-versus-abort example; do not count it as transient
  settlement evidence without a real nonzero configured lane obligation.
- Keep macro rely/guarantee instances as initialized ledger predicates that hold
  while obligations are nonzero. The cash-plus-obligation law is a separate Atomic
  induction; the existing rely/guarantee theorem does not automatically cover the
  new diagnostic table.

These choices resolve representation/oracle details already permitted by the
frozen behavior contract. They do not relax any requirement or add deployed
Balancer, hook, machine arithmetic, liveness, general associativity or provenance
claims. Fable's suggested lemma routes are advisory; actual declarations and proof
terms must be verified during implementation.

## Evidence limits

GPT-6 independently checked123 bindings/structural obligations and all 18 proposed
mutation families; no Atomic implementation was executed. Native Fable performed
source-only planning review without tools or hash recomputation. Requested native
model was `claude-fable-5-1[1m]`; reported usage includes `claude-fable-5-1` and its
auxiliary Haiku entry. No cross-provider opinion was supplied to either initial
review. Neither planning verdict is a mathematical proof or result acceptance.
