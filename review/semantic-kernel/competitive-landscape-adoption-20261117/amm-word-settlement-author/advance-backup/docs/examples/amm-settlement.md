# Rational AMM Typed settlement (2026-11-17)

[Settlement.run](../../lean/DefiKernel/AMM/Settlement.lean) reads the actual pre-ledger
pool X/Y balances, calls `Rational.swapPool`, and feeds its returned output to a
registered `Typed.execute` transition on that **same pre-state**. It debits traderX
by the full input, credits poolX by that input, credits traderY by the quote, and
debits poolY by the quote. There are no supply deltas. X/Y and trader/pool are
distinct constructors; quantities are exact rational raw units at scale1.

`funded_success` proves actual execution for positive pool reserves/input, fee
`0 ≤ f < 1`, trader funding and actual invoke/traderX-debit/poolY-debit rights.
It derives native output positivity and liquidity, then discharges all actual
Typed validity checks. It assumes neither a successful quote nor `Evaluated.Valid`.
`fullStore` is an explicit initial capability fixture, not a proof of issuance or
ownership. Generic statements quantify over the supplied store and pre-ledger.

`run_correspondence` proves that every successful run has the actual native quote,
native post-reserves in the ledger, unchanged capabilities and conserved totals
for each asset. `supply_zero` and `typed_conservation` concern the executed four
deltas, not just a reserve formula. `ledger_product_nondecrease` transfers the
accepted rational product bound to those actual ledger cells. Fees stay in the
full input reserve; no fee is rounded or removed from accounting.

The wrapper's `quoteReads` are exactly the two pool cells. `quote_pool_reads`
proves agreement there determines the native quote pool. They are declared in
the registered template's footprint. The constant transfer expressions have no
syntactic balance reads; Typed's expression-read checker does not infer the
wrapper's pure reads. Funding checks still examine the pre-ledger net effects.
`quote_refusal_iff` preserves native errors (`Sum.inl`) before Typed execution;
`typed_refusal_iff` binds each `Sum.inr` refusal to a successful actual quote.
An error returns no post-world; no rollback or transactional atomicity is inferred.

[SettlementAudit](../../lean/DefiKernel/AMM/SettlementAudit.lean) checks15 exact
observations: all four balances/capabilities under retained and zero fees, exact
funding, native refusal priorities, missing/revoked rights and insufficient funds.
With pinned Lean4.33.0-rc2 and dependencies installed:

```sh
python3 scripts/replay_amm_settlement.py --toolchain /absolute/lean-4.33.0-rc2
```

The CLI builds current proof source, then freshly evaluates the source controls
and requires exactly15 unique nonempty labels and a completion record. Exit0 is
success; wrong expected balance gives an actual false comparison and exit1;
missing, empty, unreadable controls and empty inventory block with exit3. CLI
controls use a separate fixture with byte-identical runner/model and isolated
project build artifacts, preserving the source under review. Installed dependency
artifacts are shared. The production
AMM Verify import runs the controls and combined nonempty axiom audit on rebuild.

Actual API-prefix mutations put output in the wrong asset or swap the quote
reserve roles. Both still execute to explicit incorrect ledgers and fail the
comparison; unchanged full proofs reject them separately. The focused math
audit checks45 theorem constants/65 supplemental declarations, forbidden0,
with standard named axioms only. Both model/control modules pass default kernel
replay, which uses the same kernel and trusts imports; it does not rerun `#eval`.

The universe is two parties, two assets and one domain. Authentication, registry
truth and initial grants remain explicit framework assumptions. Typed checks
aggregate net effects, not intermediate debit order, allowances or reentrancy.
This slice does not yet settle the checked Word interface or complete IV.1.
Same-pool immediate full-output no-profit theorems remain the separately accepted
arithmetic results; no market-wide arbitrage or deployed-source claim is made.
[Accounting](../../benchmarks/component-accounting/amm-settlement.json) covers
only declared new files and a shared wall interval, with an unrelated repair
interruption. Active/person-hours and historical per-component effort remain
unknown; I.3 and the II.1 effort scenario are not closed. Outside reproduction
and corroborated adoption remain open. Historical source/report bytes are unchanged.
