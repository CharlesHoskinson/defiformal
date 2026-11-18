# Capability grade corrections — 2026-11-18

**Accepted corrections — 2026-11-18.** Owner approval and independent acceptance
of the exact candidate are recorded in the [acceptance transition](../../../review/semantic-kernel/competitive-landscape-corrections-20261118/ACCEPTANCE.json).

This record corrects the scoped grades stated for DeFiFormal after the
[historical report](defiformal-competition-tech-strategy.html). Its HTML, original
cell statuses and measurements remain unchanged. The
[AMM addendum](amm-library-addendum-2026-11-17.md) and the
[liquidation addendum](liquidation-library-addendum-2026-11-17.md) keep their
bytes; this accepted record supersedes only their named statements. Status, review identity and
exact hash bindings are in the
[correction record](../../../review/semantic-kernel/competitive-landscape-corrections-20261118/CORRECTIONS.json).
Run `python3 scripts/check_capability_corrections.py` to check inventory,
byte bindings, citations and counts, and `python3 scripts/test_capability_corrections.py`
to run the regression controls. Passing these checks is not independent acceptance
of the grades or proof claims.

Each grade below uses the report's labels and the report's own grading of
comparable peer findings. No Lean source or theorem statement changes.

| Cell | Report (2026-11-06) | Stated 2026-11-17 | Effective grade |
| --- | --- | --- | --- |
| `cell:amm:conservation` | unknown | evidence, no grade | **supported**, single-swap scope |
| `cell:amm:no_arbitrage` | unknown | evidence, no grade | **partial** |
| `primitive:amm` | partial | evidence, no grade | partial (not regraded) |
| `cell:liquidation:liquidation_correctness` | unknown | supported | **partial** |
| `cell:liquidation:solvency` | unknown | supported | **partial** |
| `primitive:liquidation` | unknown | supported | **partial** |

## AMM

**Conservation.** `Settlement.run_correspondence` and
`WordSettlement.run_correspondence` prove, for every successful single swap, the
actual pool post-reserves, the trader deltas and unchanged per-asset ledger
totals. The scope is one swap between two parties in two assets, with no
liquidity provision and no Typed two-swap execution. The report grades the
scoped conservation results of Lean-AMM and MEV-formal supported.

**No-arbitrage.** `Rational.round_trip_nonprofit` and
`CheckedRoundTrip.two_success_no_profit` bound one immediate full-output
reversal against the same pool's actual post-state. They do not cover partial
reversals, other strategies, external prices or multi-pool sequences. The report
grades Lean-AMM's comparable same-state reverse-swap result partial.

## Liquidation

The Lean proves the source liquidatable guard (`Close.healthy_refusal`) and the
selected admission, preparation and payment prefix. The accepted grades are partial for
these reasons:

- **No liquidator.** Every `Close.run` step executes with the fixed owner
  context (`Margin.ownerContext`). With an empty capability store, a liquidatable
  position is refused with `unauthorizedInvoke` (`CloseAudit`, lines 130–131),
  so liquidation needs the owner's own capabilities. There is no liquidator
  incentive or penalty and no collateral transfer to a liquidator.
- **No position removal.** `Close.run_accounting` proves the position record
  unchanged after the run.
- **Correctness covers the prefix only.** In `Close.liquidation_correct` the
  admission conjunct `Admitted` is trivially true for an ordinary close.
- **Solvency is conditional.** `Close.constructive_solvency` assumes
  `SolventBudget`: the costs fit within the output, collateral and preparation
  budgets, and the pool covers preparation. Bankrupt positions are outside it.
  Nothing is stated about assets against liabilities after liquidation or about
  pool solvency.
- **Nonnegative custody is not derived.** That conclusion of the solvency
  theorem is the ledger invariant `State.nonneg`, which every ledger satisfies.

The report grades comparable or stronger peer findings partial. Verity's
conditional solvency theorem shows that full repayment seizes at most the
collateral and leaves the position healthy. Maude-LP and Verity have scoped
correctness findings. CFF models a trigger, debt clearing and a collateral
transfer to the liquidator.

## Effect on the change

IV.1 and IV.3 stay complete: their criteria require these cells to
leave unknown, and the accepted grades meet that requirement. The lending grade
is unchanged.
Broader liquidation coverage would address third-party liquidator authority,
collateral seizure and position removal. A stronger solvency result should state
what happens to liabilities after liquidation or how bad debt is handled, under
explicit assumptions. It need not be unconditional; payment-cost coverage alone
does not establish those properties.
