# Close proof review — ACCEPT_WITH_LIMITATIONS

Exact candidate: PROOF-FREEZE.json SHA256 `2022039341c9ba40ac7c4b5d1c683fa89c34c89ebcd17e8e1382b8728f578d17`, dependency delivery `63e827d5cb37cd834c2a2cfd24b7f8f2802baf06`, author detached `2af75ac4dbc192052f326e311ae1d13dc576c5d1`. All three source files and 222 evidence bindings verified. INPUTS.json and verdict.json preserve full hashes. Requested reviewer: gpt-6-astra, medium. Runtime provides no independent returned-model/effort attestation; both reported values are null. Review is advisory evidence.

## Substantive assessment

No required repair found. The implementation respects boundary r2. Liquidation admission is computed from signed funding/equity and applies even with ADL set. Full-close exception eligibility uses the actual initial position size. Separate actual funded base-PnL and positive-impact pool transfers precede Funding.run; neither marked valuation nor close PnL is fabricated pool cash. Preparation consumes summed actual pool resources and establishes funding for the second transfer from the first transfer's real poststate.

The actual ordered loop executes funding, negative PnL, fees (including zero fees), negative impact and positive impact difference as applicable. Positive source residual stops at the first failed stage, retaining its actual partial transfer and identifying skipped quotes. Ordinary/partial positions receive the qualified financial error; eligible full closes receive an exceptional prefix. The success decomposition, chain, prefix and financial theorems connect real calls and adjacent ledgers, not merely an abstract final-state predicate. Actual recipient balance differences ground paid value and both dust terms. Source residual zero is explicitly weaker than economic coverage.

Fee projections preserve pending owner claims and latest snapshots while clearing displayed fees on exceptions and on secondary fee payment even when residual is zero. Position/capability frames, physical asset conservation and owner-claim frames are separate proved properties. Holding collateral claims retain their distinct role; no caller snapshot/claim commit is implied.

The constructive_solvency theorem assumes concrete admission, raw bucket compatibility, summed pool funding, ceil-primary budgets and real execution rights. It constructs preparation, Funding.run and each remaining payment and derives actual whole-run success, complete status, Covered and financial properties. It does not assume run.ok, opaque Valid, successful preparation or poststate health. The concrete simple_constructive_witness proves these premises and invokes that theorem; runtime fixtures also exercise actual successful and refused paths. Sufficient rights and liquidity are not claimed necessary.

## Independent verification

The isolated review tree was compared with the accepted dependency revision before copying the frozen candidate. Scoped build, fresh 26/26 controls, fresh Close/CloseAudit axiom audit and both same-kernel replays passed. Close audits measured 186/207 and CloseAudit 41/34 theorem/supplemental declarations, forbidden=0. Named proofs use only the recorded standard Lean axioms (propext, Classical.choice, Quot.sound), not custom axioms, sorry or native_decide.

Thirteen mutation commands passed their expected outcomes: intact prefix 0; six actual runtime contradictions 1; six separate unchanged-proof compile rejections 1. They cover funding-equity sign, ADL guard bypass, fees before PnL, erased claim/snapshot projections, fictitious pool cash, and erasing economic shortfall when source residual is zero. Exact reconstructed mutation bytes match final r2 receipts; actual diagnostic assertions were checked. Runtime failures and proof rejection are distinct evidence.

The rebuilt root target and fresh imported-root audit passed: 9,437 theorem constants and 10,473 supplemental declarations, forbidden=0. This agrees with root's independently reported integration result, without substituting that result for this review.

Reviewer harness corrections are preserved: an initial mutation-file lookup selected older names and stopped before execution; corrected routing uses the final r2 receipt filenames. A bare root import produced no fresh audit output and failed the review harness's diagnostic assertion. A subsequent fresh audit imported a stale root olean (8,874/9,810) and receives no current-candidate root credit. Rebuilding the root target corrected the input. The first 18 checked execution receipts were recovered from observed assertions and retained raw logs after the final harness assertion prevented JSON emission; timings remain null. A confirming fresh-root run records a process exit after the previous final audit's exit receipt was unavailable at context compaction. No candidate source was changed for these corrections.

Author failed r1/r3 fixture probes remain historical noncredit. The r1 reconstructed source is explicitly a reconstruction, not an original preserved source file. Accepted conditional 23-call source-branch evidence is reused as previously reviewed; this review grants no new EVM campaign credit.

## Acceptance boundary

Accept these exact mathematical source bytes and their scoped runtime evidence. This is a conditional reference payment-prefix implementation, not whole-handler equivalence, caller collateral/output suffix execution, index-impact bookkeeping, universal EVM arithmetic refinement or deployed-system safety. Public delivery files, new observation pairs and compiled package delivery require their separate reviews. IV.3 remains open; no task box is changed. Historical measurement and outside reproduction requirements remain open.
