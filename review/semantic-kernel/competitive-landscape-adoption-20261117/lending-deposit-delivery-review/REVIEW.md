# Collateral deposit public delivery review

ACCEPT_WITH_LIMITATIONS. No required repair.

All six files match final announced FREEZE.json at2026-11-17T17:04:33.010021+00:00, baseline a9c46eb4c19130d7c7bec342b0d06fd295eb1c30. The three mathematical/integration files are identical to the separately accepted snapshot; its proof review is reused unchanged. INPUTS.json records full exact hashes and provenance.

The final runner is scripts/replay_lending_deposit_collateral.py. It checks nonempty/readable model, roles, support and controls, pinned installed toolchain/dependency, builds actual current DepositCollateral and freshly evaluates the current control source. Exact18 labels, all true comparisons and one completion record are required. Input/dependency/tool hashes are printed. It does not credit cached control execution or claim to repeat axiom/kernel proof verification.

Independent actual CLI runs passed: intact0 with18 controls, wrong expected free balance1, missing3, empty3, unreadable3, empty inventory3. The isolated baseline control source was restored. Author fixture model/roles/support/controls/runner bytes match the final candidate and its build directory is distinct; five author negative raw-log hashes/diagnostics match. Root's mistaken replay_lending_deposit.py invocation exited2 without executing the runner; its retained wrong-runner-path receipt/log hash matches and receives no execution credit. Acceptance uses the exact named runner and fresh independent runs.

Physical accounting is complete/disjoint and hash-bound for543 component lines: model284, controls86, runner113, guide60. Shared Support16 and one integration import are separate. Manual role classification includes comments, blanks and proof helpers and is not a semantic correctness measure. Shared wall time is explicitly not active effort/person-hours; historical and separate-component effort remain unavailable.

The guide correctly describes same-asset free-to-owner-custody transfer, zero supply, actual ownership and funding, all-asset conservation and other-cell frame. It preserves the distinction between generic insufficient-free non-success and a finite exact insufficientFunds case. It does not impose oracle or health restoration on deposit. Health preservation is conditional algebra at a supplied nonnegative illustrative price, not an authenticated observation or restoration result. Wrong-custody successful execution and separate full-proof rejection are accurately distinguished.

Withdrawal, five-operation coherence and IV.4 remain open. Compiled package/publication is separate. Framework authentication/registry and net-effect assumptions remain; no rollback, deployed refinement, outside reproduction, adoption or historical effort claim follows.

Requested reviewer: gpt-6-astra, medium. Actual provider-returned model/effort attestation is unavailable and not claimed.
