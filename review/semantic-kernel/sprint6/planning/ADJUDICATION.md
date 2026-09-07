# Sprint 6 planning audit adjudication

Status: **implementation gated**. The user requires independent Fable and GPT-6
planning passes before implementation. No new Parallel module or mutation runner
has been written. Existing Lean and Python implementation bytes remain unchanged.

## Initial candidate

Commit `a3b2dec486de281080a84ae5f7cfc0da39d066a9`, bundle
`e96a1e761257bfc3b43e845f0a9f48951a66363ae1980574dec3caf94a66a814`.

- GPT-6: REQUEST CHANGES, one blocker B1. Requested `gpt-6-astra` through the stock
  Codex independent subagent; exact observed identity limits and byte checks are
  in `r1-gpt6.md`. No independent Lean execution is claimed.
- Fable: unavailable, native CLI exit 1, “out of usage credits”; requested
  `claude-fable-5-1`, no reported model usage and no verdict. Raw response and full
  invocation/hash metadata are retained in `r1-fable.*`. This is not approval.

## Revision

B1 required different-valued snapshots at an identical fully qualified local
output key. Static output cells plus whole-branch compatibility make that
impossible: any write to the selected cell conflicts with the peer output read.
The revised spec/design/tasks use distinct component-qualified keys for distinct
values, equal-valued common read-only keys for branch-label preservation, and an
explicit peer-only-history negative with a funded correct-unit successful sibling.
History leakage is discriminated by that negative, not by equal-value key swapping.

Optional review guidance was adopted: reuse existing expression congruence proofs,
spell out redundant declared-read/write handling for mutation collectors, and use
zero/cancelling undeclared targets where a valid successful underlying control is
needed. All exact executor/refusal, serial correspondence and preservation proof
obligations remain mandatory. The author independently identified B1; that record
is preserved as author analysis and never labeled an independent review.

A final GPT-6 audit of the committed revision is pending. Fable must audit the same
final candidate after provider access is restored. No substitute provider, retry
without changed availability, or prior Sprint 5 approval can discharge this gate.
