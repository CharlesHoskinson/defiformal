# Independent ShareQuote prerequisite review

**ACCEPT_WITH_LIMITATIONS** for the fixed native conversion-to-quote proof. No required repair. It is a useful II.1 prerequisite, not completion of II.1 or any later task.

Exact baseline: `2387370cdc5ffaa0d6f4035e86b19d61b459cd15`. Candidate digest: `213d103790ec5e962ff449cbc7350c7385e7bbf89fd0dff3241c1217a5f1c259`. Independently verified both frozen hashes: new `lean/DefiKernel/Composition/ShareQuote.lean` (`4687e008245b4a6ca06f1859b954ab87ff7142463914a329d211c5edcab9e3c8`) and the root import file (`c9fc857e9fc191fc00cb5bc5cb8ad0dab27c64005ea56fbf39d7a5c070ab2c37`). The root change is one import. Compared 225 remaining tracked Lean/config inputs in author and isolated review checkout against baseline Git objects before execution; they match. Candidate hashes remain unchanged after execution.

Requested reviewer: `gpt-6-astra`, medium reasoning. No provider-returned model identifier or attested effort is exposed to this independent Codex subagent; actual identity remains unavailable. Review made no author/root source edits; the two candidate files were copied into the explicitly assigned isolated baseline checkout for checking.

## Mathematical/source assessment

`raw_share_conversion` proves the actual native vault `convertToShares` call on one raw asset unit at chi=RAY returns the one-unit word. It uses the existing successful-conversion characterization, positive denominator and product bound, then exact downward division of RAY by itself. The statement is fixed, and the proof does not introduce an axiom or change any historical statement.

`convertedShareQuote` uses an `Except` bind to pass the actual returned Word into the existing token0 `libraryWord` operation. Distinct sum tags retain vault versus quote failures in the definition. `converted_share_quote` applies the proved conversion result and existing ordinary-add quote theorem to obtain `postWord` (2^95) from sqrtP=2^96, L=1, amount=1, add=true.

`zero_share_quote_differs` establishes a concrete mismatch: substituting zero input gives the identity quote 2^96 rather than 2^95. This is a checked mathematical inequality/control, not an executed production-mutant campaign. It shows that the chosen link is not interchangeable with zero for this case; it does not prove injectivity, arbitrary mismatch rejection or a general refusal theorem.

The module expressly labels sUSDS-as-token0 hypothetical, raw-unit, fixed-rate and quote-only. It does not claim AMM settlement or full vault/source refinement. This accurately connects two existing library calculations as a prerequisite. It does not yet connect actual deposit ledger execution/receipt or the existing fixed-WAD deposit adapter to the quote register, instantiate one shared ComponentContract, prove initialized composed invariants, establish source-backed asset correspondence, or discharge the full II.1 unit/refusal/reuse obligations. Those unchanged task gates remain open.

## Independent execution

Used the assigned isolated `/private/tmp/defiformal-ci-baseline/lean` source/build state with the pinned existing cache. Independently ran:

1. `lake build DefiKernel.Composition.ShareQuote` — exit 0.
2. `lake env lean <review>/AuditShareQuote.lean` — exit 0, fresh audit: five theorem constants and one supplemental definition, forbidden=0.
3. `lake env leanchecker -v DefiKernel.Composition.ShareQuote` — exit 0, exactly one matching module replay marker.

The five audited theorem constants consist of the three named results plus generated `rayChi.eq_1` and `rayWord.eq_1` constants; they are not five new mathematical claims. Allowed dependencies are only `propext`, `Classical.choice`, `Quot.sound`. Logs, command/tool identities and hashes are saved in execution.json and the adjacent log files.

Tool: Lean 4.33.0-rc2, arm64-apple-darwin24.6.0, commit `d8b18978322de05a8f3dba51ef03cf5461676c17`; compiler SHA-256 `1b370cfcbf44e80d1b004ab1b1ab9a4c73951f9f7c242140bcff9bc577576554`. Dependencies were reused from the explicit pinned cache, not independently rebuilt. Leanchecker uses the same kernel implementation and trusts imports. This is focused module verification; root entrypoint/full hosted integration remains a separate delivery check.

The author's three successful command records and original raw logs are consistent with the independent results. Their wall-clock intervals and reported prospective author-session start are process evidence, not human person-hours or recovery of missing historical authoring effort. No broader campaign is required to accept this narrow theorem increment, and no broader result is credited.

Disposition: accept exact candidate for integration with these limits. I.3/I.4 and II.1 remain open; no checkbox change or task-completion credit is supplied by this review.
