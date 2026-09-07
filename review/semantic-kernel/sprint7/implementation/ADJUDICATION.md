# Sprint 7 implementation adjudication

**Accepted with limitations.** Both required native providers accepted the Lean
implementation and final proof/evidence supplement. No material blocker remains.
Final Lean source: `bea105ec72e633a2dd66c663b96d0b552e1814a8`. Production runtime,
mutation and historical Python runs retain their actual revision
`6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c`. Delivery/archive actions are recorded
separately; this adjudication does not invent an already-completed push.

[Machine-readable review identities](review-summary.json) bind all four accepted
scope verdicts, exact requested/reported model identities, input/response hashes
and native invocation records. Original Lean scope: [Grok](lean-grok.md) and
[Fable](lean-fable.md). Final proof supplement and evidence:
[Grok](evidence-grok.md) and [Fable](evidence-fable.md).

## Findings and disposition

- Fable requested directly named admission-refusal and complete-exhaustion laws.
  Added three generic `Completion.lean` corollaries and its Verify import. Both
  providers accepted the supplement. It also documents that canonical refused
  comparison omits the supplied schedule while raw Result equality retains it.
- Every one of the25 runtime closure files and three driver/spec/harness files is
  exactly unchanged across the two source revisions. [The binding](proof-supplement-binding.json)
  preserves original execution identities. The only source additions are the
  proof module/import; the final twelve Lean commands were actually rerun.
- Final inventory:262 theorem constants and271 supplemental declarations, zero
  forbidden dependencies. Of127 explicit theorems,107 are generic (one uses finite
  fixture identity types),15 reference instances, three counterexample constructions
  and two counterexample corollaries;135 other theorem constants are generated.
  Literal elaborated types and source premises remain in the proof inventory.
- Runtime acceptance is116 unique comparisons. All 14 actual source mutants compile
  and trigger their designated false comparisons with nine protected positives.
  All 52 actual CLI controls pass: six accepted, four violated and42 blocked.
  All nine legacy Python suites and12 final Lean integration commands pass.
- Wrong-world detection overlaps: stale-initial and isolated-branch mutations share
  40 false labels, with two additional stale-only labels. Their designated oracles
  detect both; they are not advertised as fault-separating classifiers. One global
  equal-failure positive compares two equal projections under the same mutation;
  the independent changed-reason oracle still detects the omitted failure field.
- The current proof-boundary scanner does not recognize every possible Lean
  declaration spelling after its marker. All concrete accepted runtime modules
  have only proofs there. Broader attribute/macro/notation/deriving/axiom guards
  are saved as a later infrastructure follow-up, not claimed as implemented.
- Regenerated [final historical preservation](../preservation-final.json):1117 of
  1118 protected paths are identical, with only the authorized new root import.
  The earlier record remains bound to its actual earlier candidate.

## Review execution limits and incomplete attempts

Native Grok used its automatic large-prompt offload and read-only source/hash
inspection despite an empty tools option. It did not rerun Lean. Native Fable's
accepted final review performed no commands and assessed the supplied source and
parent execution artifacts. Neither review is a mathematical proof.

An initial evidence attempt was interrupted because the generated-declaration
pretty-printer expanded proof terms and changed four included artifact hashes.
[Its record](cancelled-evidence-r0/cancellation.json) and raw cancelled responses
remain, with no acceptance credit. The restarted frozen bundle is
`73ad1356e9951f57216743e4d24ff42e082826cea3891d39dea14fb4197de35c`.
Fable then returned only proposed tool markup, which could not execute and supplied
no verdict. [That open result](evidence-fable-no-verdict-status.json) was retained.
A format-only prefix requested an actual source-only verdict on the unchanged
payload; Fable returned ACCEPT WITH LIMITATIONS. Its exact wrapper hash is recorded
separately. No provider was substituted or unavailable review counted as approval.

Sprint 8 planning artifacts were committed while final review ran. They changed no
Sprint 7 source or reviewed payload; [the input check](input-freeze-check.json)
records that distinction. Required source/evidence scope is frozen at the revisions
above; review artifact files are not falsely labeled Git inputs at those revisions.

## Accepted boundary

Fixed trusted initial capability store, authenticated boundaries/configuration,
finite explicit schedules and exact rational arithmetic remain premises. Authority
is point-of-use, nonnegativity comes from State witnesses, supported frames require
support, and rely/guarantee composition requires initialization and independent
local/cross/stability obligations. Universal disjoint recovery requires actual
Parallel admission and complete schedules. Reference examples are development
fixtures. Atomic settlement, changing capability provenance, general behavioral
associativity, liveness and deployed fidelity remain separate roadmap work.
