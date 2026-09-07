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

## Final candidate gate

Candidate `c0f6f0bcc19ab30e0146a2e1e8ff209f8ce8c1a7`; bundle
`73f4ff8c70b85e8468e33f4c63d784b37c8543c1ed068341ed120607d19942fa`.
GPT-6 returned **ACCEPT** in `r2-gpt6.md`. It independently verified 21 committed
bundle inputs, all 24 preserved context entries, all 47 scenario mappings, and
strict OpenSpec validation. B1 is closed, with no new blocking finding. This is
planning/source review, not a Lean build or execution of the future semantics.

Fable must still audit this same final candidate after provider access is restored.
Its unavailable R1 call is not a verdict on R2. The subsequent retries below also
produced no verdict. No substitute provider or prior Sprint 5 approval can discharge this gate. `gate.json` records
implementation as unauthorized by the unsatisfied conditional gate and not started.
`RESUME.md` gives the exact native review invocation. Both required passing verdicts
are necessary before any new Parallel implementation.


## Fable 5.1 retry after user reported readiness

Both native retries examined the unchanged R2 bundle. The requested model was
first `claude-fable-5-1`, then the exact locally configured selector
`claude-fable-5-1[1m]`. Both returned exit 1 with “out of usage credits”, empty
reported model usage and no audit verdict. See `r2-fable.*`, `r2-fable-1m.*` and
`fable51-diagnostic.json`. Claude Code 2.1.261 reports logged in through the
first-party claude.ai route with a Max subscription; no identifying account data
or credentials are stored in the diagnostic. That login status does not establish
available credits.

The user supplied changed-availability information, which justified retrying;
the local model selector justified the second attempt. Further identical retries
are deferred until provider availability changes. GPT-6's R2 acceptance remains
valid. Implementation is still gated and no Lean/kernel script bytes changed.
