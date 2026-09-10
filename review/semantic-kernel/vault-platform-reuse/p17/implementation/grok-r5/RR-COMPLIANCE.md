# RR-1..RR-5 current errata (Grok R5)

Frozen historical r2/agy-r1..r4 bytes are unchanged. This record is implementation-era.

## RR-1
Historical r2 intact diagnose exit 1 and overwritten failed JSON remain unavailable (not reconstructed). Current candidate uses unique evidence directories.

## RR-2
Success rows compare all 19 observed cells. Refusals retain supplied prestate plus the actual refusal; they do not invent a rollback postworld.

## RR-3
Zero-asset `transferFrom` enters the finite-allowance branch and consumes 0. See `P17-DEP-ZERO`.

## RR-4
Falsifying diagnostics (metadata, not compiled mutants) live in `rr4-metadata-diagnostics/`. Full-log falsifiers already existed in the protocol precheck.

**Negative theorem (Lean is correct; this prose is the repair):**
`Adapter.no_credit_is_observation` proves
`(evaluated wadQ sharesQ).Valid store ctx req (fundedState ...) ∧ ¬ ∀ c, noCreditCandidate.balance c = pre.balance c + effect c`.
`Evaluated.Valid` **holds**. The no-credit candidate violates `execute_ok_iff` observation/post equality, not Valid. Frozen planning `P17-TH-NEGATIVE.not_predicate = Evaluated.Valid` is inherited and is not rewritten; the delivered theorem is the authority.

## RR-5
`P17-RED-DELEGATED` is a scored success: owner O, caller P, finite share allowance decrement, independently funded prestate, 19 cells and full logs.

## Historical identities preserved
Grok r1 partial, AGY r1–r4, Opus review r1, and frozen planning files keep their original bytes and authorship.
