# FundedCausal r2: bounded structural recheck

Reviewer: independent GPT-6 checker. This is a read-only review of a live native-author draft, not final theorem acceptance. No Lean command, build, or cache write was performed by this reviewer. The source and failing author log inspected here are retained beside this report; later live edits are outside this review.

Reviewed FundedCausal SHA-256: `621b318836e31445cdcb88b6bd3723cd4c3669e0fc29daa4ed5602d836a20764`.
Reviewed author build-log SHA-256: `279f0a8ad736fe4ce0d3b906640cef158e6ed5f2b27bdcc9e217f501868d4d70`.
The log contains 24 errors. This report makes no claim that the module elaborates or that its remaining proof obligations are closed.

## Structural outcome

Both previously identified impossible premises have been repaired. `fundedBalances` now records donor2 as `3 - 2*n2`, matching the actual two-unit debit. Each donor assumption is conditional on its own index being zero. Consequently donor2 can finish with balance one without falsifying assumption derivation at later initialized prefixes. Producer/consumer output provenance and phase remain tied to the producer's own successful index; the consumer's funding assumption is required exactly at index one.

No new false mathematical goal was identified in the inspected draft and error log. This is bounded structural confidence, not an exhaustive proof audit. The current failure set does not justify weakening the assumptions, exact receipts, or output provenance.

`f10_selected_success` uses actual selection, an actual successful `executeStep`, current invariant, and current assumption. It does not assume K or a future successful call. Its producer, consumer, and donor cases derive post-state bounds from actual receipt effects. The consumer receives the present vault bound and its own singleton producer output history; donors receive the conditional funding premise at their selected index zero.

`f10_success_update` reconstructs successful indices, exact tracked balances, capability store, phase, and own outputs from the actual result and the current K. Its use of actual producer exports and the full consumer receipt is substantively necessary: the monitor checks these fields. Keeping these exact statements is feasible. The unused post-invariant/guarantee inputs in this reconstruction do not introduce circularity.

## Remaining structural obligations and accurate claims

1. **Actual enabledness and complete-schedule success remain open.** The initialized safety theorem permits refusal and skip. It cannot by itself imply that all complete schedules actually execute producer, consumer, and both deposits successfully. Prove current selected-call enabledness from K, actual store/catalog/bounds/history, and current funding; then prove absence of recorded failure and derive success counts 2/1/1 for a complete schedule. These must be conclusions of actual execution, not future-success assumptions added to K or `fundedExternal`.
2. **Describe the actual rely truthfully.** `fundedRely` is the post-state invariant; cross-inclusion and stability are projections. The selected-success proof supplies the substantive justification, so this is not circular. However, the tail's comments call the separate `depositOnlyRely` the rely used by the funded instance. That claim is false of these definitions. Actual deposit preservation of Ready and F12's authorized withdrawal counterexample are separate substantive obligations. Root has assigned these companions to the other native author; do not duplicate that work or relabel the auxiliary relation as the main instance's rely.
3. **Keep completion and equality scopes explicit.** Current K gives exact values at the six tracked cells and the capability store. Any later full-world or final-machine equality also needs framing for all other cells and the required local failure/consumed/receipt/output fields. Such equality does not follow solely from the six balance equations. Public admission/run wrappers and completion claims still need their own connections.

## Why the logged failures appear repairable

These are proof-shape diagnoses against the saved source, not compiled repair instructions.

- Donor assumption failures at lines 334/340 contain cast-zero arithmetic. The goals are true at index zero; normalize the casts and zero products before arithmetic.
- `f10_selected_cases` leaves branch hypotheses indexed by noncanonical `Fin` constructor terms while goals use numeral participants. Normalize the participant equality/index before using arithmetic; otherwise the tactic treats definitionally equal local indices as unrelated atoms.
- The consumer helper calls at lines 636/956 retain an explicitly unspecialized type for `hstep`. Normalize or explicitly state the equation at index one and singleton own history before passing it to the helper. A simplification inside the proof of an unspecialized annotation does not specialize that annotation.
- Donor cell calculations retain `if` branches testing distinct named cells. Normalize the known cell inequalities before linear arithmetic. The desired +1/+2 vault and -1/-2 donor equations agree with the actual operations.
- The producer-output proof's final goal is the post budget cell equality already obtained from actual execution, expressed using an alias. Reuse that equality after unfolding the cell alias instead of expecting reflexivity.
- The full consumer receipt proof must normalize the evaluated record and use the actual successful guard fact. The remaining guard/argument/environment expressions do not make the exact receipt goal false. Preserve the full receipt conclusion because the monitor depends on it.
- Producer monitor/index and peer/refusal phase goals require index rewriting or handling all phase constructors. They do not require an extra temporal premise. The refusal proof must close every phase case, not only the first case reached after a tactic sequence.

The bounded next step is to repair these elaboration obligations without changing the mathematical interface, then establish the separate enabledness/completion bridge. Final acceptance requires frozen source, a successful author build, retained complete theorem statements and axioms, and independent review of those exact bytes.
