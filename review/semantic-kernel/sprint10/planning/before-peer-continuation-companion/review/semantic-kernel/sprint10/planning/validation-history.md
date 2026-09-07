# Author validation history

The initial validation invocation stopped with exit1 because it attempted to bind
`scripts/test_atomic_mutation_runner.py` to financial source a52fb748. Read-only
Git comparison identified the accepted99e2e2c fix from `log_path` to
`lean_log_path` in the production-form runner control. The financial source
bindings matched. No control was executed and no acceptance was reported.

The validator now binds financial source/toolchain files to the inspected a52fb748
objects and the actual runner separately to its observed current revision. Final
`author-validation.json` records the successful bounded validation and exact
per-file revisions. This corrects evidence attribution, not financial semantics.

A second invocation reached the prose-consistency assertion and stopped because
the validator used case-sensitive `private-total` against sentence-initial
`Private-total`. The assertion now normalizes case. No normative draft change
was needed and this was not a failed financial test.
