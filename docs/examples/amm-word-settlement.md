# Checked Word AMM Typed settlement (2026-11-17)

[WordSettlement.run](../../lean/DefiKernel/AMM/WordSettlement.lean) first checks that
both supplied Word reserves equal the **actual pre-ledger pool cells**, cast to
exact rational raw units at scale1. It calls `Checked.swapPool` and feeds the
actual returned Word output to the shared registered settlement template on
that same pre-state. TraderX is debited by the full input; poolX receives it;
traderY receives the output; poolY pays it. Supply deltas are empty.

`funded_success` derives native success from the entire `Checked.Admissible`
domain and discharges actual Typed checks from compatibility, trader funding
and invoke/traderX-debit/poolY-debit rights. It assumes no successful native
result, output-fit premise or `Valid` certificate. Those three rights are
**sufficient**, not a minimal authorization iff. `run_ok_iff` preserves the exact
actual checks. If a positive input floors to zero output, settlement still
moves the full X input and can succeed without a poolY-debit right: no Y is
debited. Positive Y output requires that right. Zero-output reversal refusal
in the separate native round-trip operation does not undo this settlement.

`run_correspondence` proves actual input/output transfers, exact native Word
post-reserve casts, unchanged capabilities and conserved per-asset totals.
It invokes the same `Settlement.typed_conservation` lemma as the rational
interface. `actual_output_floor` proves the **actual trader Y gain** satisfies
`gain ≤ exact fee-aware rational quote < gain+1`. `ledger_product_nondecrease`
transfers the accepted native bound to actual ledger cells. Fee calculation
and widened intermediate widths remain those of the accepted Checked module;
there is no early fee rounding or EVM256-intermediate equivalence claim.

`matches_reads` binds compatibility to the same two pool quote cells declared
by the inherited template. Wrapper reads are explicit; Typed's constant
expression checker does not infer them. Refusal priority is reserve mismatch,
then the exact Checked refusal, then exact Typed refusal. Three iff theorems
separate those constructors. An error returns no post-world; rollback,
transaction atomicity and intermediate debit order are not established.

[WordSettlementAudit](../../lean/DefiKernel/AMM/WordSettlementAudit.lean) checks22
exact comparisons, including complete balances/capabilities, full-width values,
same-ratio/wrong-raw-unit mismatch, zero-output rights, native overflow/priority,
authority and funding. In a configured pinned Lean4.33.0-rc2 checkout:

```sh
python3 scripts/replay_amm_word_settlement.py --toolchain /absolute/lean-4.33.0-rc2
```

The CLI builds current proof source and freshly evaluates source controls,
requiring exactly22 unique nonempty labels and completion. Intact returns0;
a wrong expected balance returns1 with a false comparison. Missing, empty,
unreadable controls and empty inventory block with3. Mutation tests use actual
API prefixes without importing intact cached WordSettlement: bypassed binding
settles a mismatched ledger, and output+1 settles the wrong gain. Both produce
explicit wrong ledgers and comparison failure; unchanged full proofs reject
separately. The focused math audit checks34 theorem constants/23 supplemental
declarations, forbidden0; named axioms are standard. Model/control kernel replay
uses the same Lean kernel and trusts imports; compiled replay does not rerun controls.

The model has distinct trader/pool, X/Y and one domain. Only the **pool** is
Word-bounded; trader wallets remain nonnegative rational ledger quantities,
without256-bit wallet bounds. Authentication, registry truth and initial grants
remain framework assumptions. Native same-pool two-success round-trip bounds
are separate from these single-swap Typed conservation/floor proofs; there is
no proved Typed two-swap round-trip execution or market-wide arbitrage claim.
The [dated capability addendum](../research/competitive-landscape-2026-11/amm-library-addendum-2026-11-17.md)
keeps those scopes distinct and preserves the historical report.
[Accounting](../../benchmarks/component-accounting/amm-word-settlement.json)
records declared file ranges and shared wall time, not active/person-hours or
recovered historical effort. I.3, the II.1 effort scenario, outside reproduction
and corroborated adoption remain open.
