# Council pass 2 — GPT-5.6 Sol on the sixty application subsections

Cold read, read-only sandbox, high reasoning. Auditor had node, quint, Lean 4 with
mathlib, python and git, the Quint and Lean skill kits, and an instruction to demand
evidence and to run rather than reason. Target: the sixty sub:cat:* blocks. Exit 0.

---

# Cold-read audit of the sixty application subsections

The subsections are not sound enough to publish.

## BLOCKING

### 1. The options block is not the emitter’s output

- **File/line:** [paper/atlas.tex:3357](/root/defiformal/paper/atlas.tex:3357)
- **Exact text:** “The five venues of the category are treated below… Every figure in the measurement environments is emitted from the checker output.”
- **Defect:** This eight-line paragraph is absent from `emit-tex.mjs` output and was inserted between the generated Aevo and Derive subsections. In LaTeX it therefore belongs to the Aevo subsection. Your rule says any emitter diff is BLOCKING.
- **Evidence:**

```text
$ diff -q <(node formal/v3/emit-tex.mjs expansion/10-options/specs \
    expansion/10-options/verdicts.json) \
    <(sed -n '3324,3491p' paper/atlas.tex)

10-options MISMATCH
```

The other eleven category ranges matched exactly. The mismatch is solely [lines 3357–3364](/root/defiformal/paper/atlas.tex:3357).

- **Fix:** Move the paragraph into the options section preamble, before the Aevo subsection, then require all twelve emitted ranges to diff cleanly.

## MAJOR

### 2. All twelve fixed-context residue summaries contradict the subsection totals

The generated subsection counts sum to the following, while the surrounding authored prose reports stale, much smaller figures:

| Paper line | Exact claim | Subsection total |
|---|---:|---:|
| [1391](/root/defiformal/paper/atlas.tex:1391) | “Twenty residue items” | 64 |
| [1617](/root/defiformal/paper/atlas.tex:1617) | “Twenty-six” | 61 |
| [1833](/root/defiformal/paper/atlas.tex:1833) | “Twenty-eight” | 47 |
| [2033](/root/defiformal/paper/atlas.tex:2033) | “Twenty-four” | 48 |
| [2243](/root/defiformal/paper/atlas.tex:2243) | “Twenty-nine” | 47 |
| [2448](/root/defiformal/paper/atlas.tex:2448) | “Thirty-three…the most” | 51; not most |
| [2662](/root/defiformal/paper/atlas.tex:2662) | “Twenty-five” | 61 |
| [2881](/root/defiformal/paper/atlas.tex:2881) | “Thirty-one” | 72 |
| [3100](/root/defiformal/paper/atlas.tex:3100) | “Thirty-five…highest density” | 57; not highest |
| [3313](/root/defiformal/paper/atlas.tex:3313) | “Twenty-three” | 51 |
| [3521](/root/defiformal/paper/atlas.tex:3521) | “Twenty-five” | 72 |
| [3763](/root/defiformal/paper/atlas.tex:3763) | “Twenty-five” | 55 |

The authored figures total 324; the sixty subsections contain 686 residue rows.

```text
$ node formal/v3/residue.mjs /root/defiformal/expansion

01 … 64
02 … 61
03 … 47
04 … 48
05 … 47
06 … 51
07 … 61
08 … 72
09 … 57
10 … 51
11 … 72
12 … 55
total: 1259 obligations, 573 covered, 686 residue
```

- **Fix:** Generate every category summary from verdicts. Delete the now-false “most” and “highest density” claims or recompute them.

### 3. Huma’s construction is knowingly the union of two different products and reproduces neither

- **File/line:** [paper/atlas.tex:2531](/root/defiformal/paper/atlas.tex:2531), [paper/atlas.tex:2534](/root/defiformal/paper/atlas.tex:2534)
- **Exact code:** `X = {Aw,Bs,Ep,Fd,Ft,Gp,Sh,Sv,Tr,Uc,Wq}` with `12/24` obligations discharged.
- **Defect:** The prose combines permissionless Huma 2.0 on Solana with the separate permissioned Huma Institutional product. The spec itself says:

> “The two must not be conflated: decomposing both under one name produces a construction that reproduces neither.”

That admission is at [huma-finance-v2.json:26](/root/defiformal/expansion/06-yield-vaults/specs/huma-finance-v2.json:26), yet the witness says it “carries both” at [line 218](/root/defiformal/expansion/06-yield-vaults/specs/huma-finance-v2.json:218).

- **Consequence:** The element set, admissibility, coverage, and residue are properties of no deployed object.
- **Fix:** Split the products into separate specs and verdicts. If the ranking is based on Huma 2.0 capital, the application subsection must measure Huma 2.0 alone.

### 4. Numerous “covered” assignments are refuted by their own notes

The checker validates only that a declared symbol exists in the 58 and is present in the construction. It never determines that the cited evidence supports the symbol. The record contains direct admissions of forced or false fits:

- Curve carries `Ag` at [paper/atlas.tex:1413](/root/defiformal/paper/atlas.tex:1413), while F13 says `Ag` is multi-venue and Curve’s router is single-venue; the mechanisms have “nothing in common but the word routing” ([curve.json:107](/root/defiformal/expansion/01-spot-exchange/specs/curve.json:107)).
- Raydium carries `Em` and `Up` at [paper/atlas.tex:1516](/root/defiformal/paper/atlas.tex:1516). Its notes say the emissions funder “could not be established at a primary source” ([raydium.json:154](/root/defiformal/expansion/01-spot-exchange/specs/raydium.json:154)), and that `Up` names a proxy although Raydium uses no delegatecall or implementation slot ([line 163](/root/defiformal/expansion/01-spot-exchange/specs/raydium.json:163)).
- Aster assigns `Bs` to fee-funded protocol reserves while admitting “the staking half is absent” ([aster.json:151](/root/defiformal/expansion/05-perpetuals/specs/aster.json:151)).
- edgeX assigns `Li` although the cited page documents only the trigger; payment to a third-party liquidator is unsupported ([edgex.json:135](/root/defiformal/expansion/05-perpetuals/specs/edgex.json:135)).
- Pendle assigns fixed-term debt `Ft` to a principal token while admitting that it is not debt and has no obligor ([pendle.json:38](/root/defiformal/expansion/06-yield-vaults/specs/pendle.json:38)).
- Polymarket carries on-chain order-book `Ob`, while its note says matching is off-chain and only settlement is on-chain ([polymarket.json:35](/root/defiformal/expansion/12-prediction/specs/polymarket.json:35)).
- Grove carries `Gp` for revoking a relayer role, despite its note and witness conceding that no system pause occurs ([grove-finance.json:56](/root/defiformal/expansion/12-prediction/specs/grove-finance.json:56), [paper/atlas.tex:3858](/root/defiformal/paper/atlas.tex:3858)).

A mechanical count found:

```text
assigned obligations:             573
explicitly labelled “approximate”: 151
```

The same symbol is also applied inconsistently. Curve says `Fd` “means…distribution to a claim class” ([paper/atlas.tex:1440](/root/defiformal/paper/atlas.tex:1440)); Kalshi adds it merely because a fee schedule exists ([paper/atlas.tex:3892](/root/defiformal/paper/atlas.tex:3892)); Polymarket’s note concedes that the fee destination is unknown ([polymarket.json:134](/root/defiformal/expansion/12-prediction/specs/polymarket.json:134)).

- **Fix:** Remove assignments whose defining condition is absent or unknown. Report exact, approximate, and forced assignments separately; only exact assignments may enter the headline coverage without a sensitivity analysis.

### 5. Three bridge subsections call self-published address lists independent attestations

BTCB, Coinbase Bridge, and WBTC all carry `At` and are declared fully warranted:

- [paper/atlas.tex:2683](/root/defiformal/paper/atlas.tex:2683)
- [paper/atlas.tex:2716](/root/defiformal/paper/atlas.tex:2716)
- [paper/atlas.tex:2815](/root/defiformal/paper/atlas.tex:2815)

But law `L27` requires a named attester, independence, assurance level, staleness bound, and recourse. Their notes concede:

- BTCB: “none of the five holds” ([binance-bitcoin-btcb.json:79](/root/defiformal/expansion/07-bridges/specs/binance-bitcoin-btcb.json:79)).
- Coinbase: issuer is not independent; no assurance level or recourse ([coinbase-bridge.json:62](/root/defiformal/expansion/07-bridges/specs/coinbase-bridge.json:62)).
- WBTC: no independence, assurance level, staleness bound, or recourse ([wbtc.json:76](/root/defiformal/expansion/07-bridges/specs/wbtc.json:76)).

- **Fix:** Treat these rows as residue, or introduce a separate “issuer-published reserve-address listing” element. They cannot honestly discharge `At`.

### 6. LayerZero’s admissibility is obtained by laundering an unrelated `Au` across obligations

- **File/line:** [paper/atlas.tex:2782](/root/defiformal/paper/atlas.tex:2782)
- **Exact code:** `X = {Au,Gs,Xf,Xm}`, followed by “every element is warranted” at [line 2784](/root/defiformal/paper/atlas.tex:2784).
- **Defect:** The `Gs` obligation says there is “no user-granted Au” ([layerzero-v2.json:52](/root/defiformal/expansion/07-bridges/specs/layerzero-v2.json:52)). The only `Au` evidence is an application owner delegating configuration administration, with no expiry or nonce discipline ([line 128](/root/defiformal/expansion/07-bridges/specs/layerzero-v2.json:128)).
- **Cause:** `construct.mjs` checks a global set. It does not require the `Au` satisfying the `Gs → Au` law to belong to the same authority relationship as the sponsored gas.
- **Fix:** Type requirement discharge by obligation or relation. Until then, LayerZero must leave the relevant `Au` term open.

### 7. Residue is inflated by compound rows whose own notes admit that an element fits part of the row

The paper says each listed obligation “has no element.” At least one row in each of the first six categories makes that sentence false:

| Category | Empty row | Existing fit admitted by note |
|---|---|---|
| Spot | PancakeSwap F19 | `Em` names the emission; only its direction is missing ([spec:160](/root/defiformal/expansion/01-spot-exchange/specs/pancakeswap.json:160)) |
| Lending | Maple F19 | `Gp` names the pause; revocation details are missing ([spec:168](/root/defiformal/expansion/02-lending/specs/maple.json:168)) |
| CDP | Liquity F13 | `Li` names the paid just-in-time liquidation; the ordered waterfall is missing ([spec:117](/root/defiformal/expansion/03-cdp-stablecoins/specs/liquity.json:117)) |
| Staking | Lido F10 | `Gp` names the unilateral pause; the attestation mechanism is missing ([spec:104](/root/defiformal/expansion/04-liquid-staking/specs/lido.json:104)) |
| Perpetuals | Aster F20 | `Ct` names the liquidation-price threshold; payoff deformation is missing ([spec:185](/root/defiformal/expansion/05-perpetuals/specs/aster.json:185)) |
| Yield | Pendle F6 | `Ix` names an accrual index; its ratchet/asymmetric-loss property is missing ([spec:66](/root/defiformal/expansion/06-yield-vaults/specs/pendle.json:66)) |

These are not arithmetic errors; they are atomisation errors. A covered mechanism and an uncovered refinement were written as one row and the whole row marked empty.

A second-half sample—Hyperliquid F4, KyberSwap F3, Centrifuge F16, Rysk F7, USDC F1, and Polymarket F1—did not produce a comparably definite false negative. Those sampled residues were defensible.

- **Fix:** Split base mechanism from refinement. Regenerate the central totals after atomic recoding; 686 is not presently an honest count of obligations to which “no element fits.”

### 8. The Maple conflict can be adjudicated only at code scope, not deployment scope

The lending subsection states:

> “A loss draws down the delegate’s own posted capital…”  
> “the agent here is bonded, the sanction is financial and automatic”

([paper/atlas.tex:1698](/root/defiformal/paper/atlas.tex:1698), [line 1723](/root/defiformal/paper/atlas.tex:1723)).

The RWA subsection states:

> “the first-loss module exists in the code and is deliberately empty”  
> “With the backstop gone…”

([paper/atlas.tex:3232](/root/defiformal/paper/atlas.tex:3232), [line 3247](/root/defiformal/paper/atlas.tex:3247)).

Recorded evidence establishes that `_handleCover` exists and that origination/withdrawal are gated by `minCoverAmount`. It does not establish any named live pool’s current minimum or balance. The lending note explicitly says the live balance may be zero and commands stage 6 not to say the delegate is bonded without a live figure ([maple.json:111](/root/defiformal/expansion/02-lending/specs/maple.json:111)). The RWA source says cover is unused because *most* pools are Maple Direct pools, which does not establish emptiness for every pool.

- **Adjudication:** An enforced code path exists. Whether a specified live pool is funded is **NOT SHOWN**.
- **Fix:** Scope both subsections to named pools and record `minCoverAmount`, cover balance, delegate identity, and block number. Until then, describe only a configurable code-level mechanism.

### 9. The 45.5% figure is not a protocol-coverage statistic

`construct.mjs` counts each authored JSON row once and declares the whole row covered whenever any listed element is present:

```js
if (!els.length) uncovered.push(o);
...
else covered.push({ id: o.id, by: present });
```

([formal/v3/construct.mjs:71](/root/defiformal/formal/v3/construct.mjs:71)).

The validator does not enforce atomicity; it merely checks that the text has at least twenty characters ([validate.mjs:30](/root/defiformal/formal/v3/validate.mjs:30)). Specs contain between 15 and 26 obligations, with compound rows such as those above.

Therefore:

- 45.5% supports only: **573 of 1,259 authored ledger rows were given at least one symbol**.
- It does not support comparisons of how much of two protocols is expressible.
- It does not support category rankings.
- It does not estimate a proportion of protocol behaviour, code paths, economic importance, or risk.
- Splitting one compound row into base mechanism plus refinement changes the denominator and numerator without changing the protocol.

- **Fix:** Call it “recorded-obligation-item coverage”; publish application- and category-macro sensitivity; establish and independently audit an atomic-obligation coding rule before using it as a resolution measure.

### 10. The subsections omit the information a hostile referee needs to identify and reproduce the measured object

No standardized scope record states product, version, chain, deployment addresses, block height, observation date, or whether the construction unions generations. Huma demonstrates the consequence; Curve, Fluid, Uniswap, Liquity, and Ondo also combine generations or distinct product families.

Nor does any measurement report the number of exact, approximate, forced, or unknown assignments, despite 151 assigned rows being expressly labelled approximate.

- **Fix:** Every subsection needs a scope header and coding ledger containing:

  - exact product/version/deployments and snapshot block;
  - obligation-to-source pinpoints;
  - exact/approximate/unknown assignment status;
  - atomisation rule and adjudicator;
  - sensitivity of verdict and coverage to disputed assignments.

Absent these, the empirical object and coding reliability are **NOT SHOWN**.

## MINOR

### 11. 104 evidence fields are future-dated relative to the audit date

All 98 Intents obligations and six CDP obligations say `accessed 2026-08-05`, while the corpus/audit date is 2026-08-04. Example: [binance-wallet.json:17](/root/defiformal/expansion/08-intents/specs/binance-wallet.json:17).

```text
futureDatedEvidence: 104
```

`validate.mjs` checks only for a date-shaped string, not whether it is valid ([validate.mjs:36](/root/defiformal/formal/v3/validate.mjs:36)).

- **Fix:** Correct the dates or state and substantiate a UTC-boundary convention.

### 12. BTCB turns a failed search into a global absence claim

- **File/line:** [paper/atlas.tex:2701](/root/defiformal/paper/atlas.tex:2701)
- **Exact text:** “No independent auditor attests to the BTCB collateral specifically; no such report was found.”
- **Defect:** The corresponding note labels the result `UNKNOWN` and says only that no report “could be located.” Binance’s own reserve page cannot prove that no independent report exists.
- **Fix:** Write: “No independent BTCB-specific report was located in the sources searched,” followed by the search scope.

### 13. All sixty `source` fields are broken provenance links

Every spec points to a non-workspace Windows path such as:

```json
"source": "C:\\defiformal-work\\01-spot-exchange\\01-research.md"
```

([curve.json:4](/root/defiformal/expansion/01-spot-exchange/specs/curve.json:4)).

```text
specs: 60
nonresolvingSourcePaths: 60
```

The validator checks only that `source` is nonempty ([validate.mjs:43](/root/defiformal/formal/v3/validate.mjs:43)).

- **Fix:** Use repository-relative paths and include the round-two record where relied upon.

### 14. Six inadmissibility clauses contain double-escaped mathematics

- **Example:** [paper/atlas.tex:1703](/root/defiformal/paper/atlas.tex:1703)

```tex
$L1:Ex\{\textbackslash\{\}mid\}Tp\{\textbackslash\{\}mid\}At$
```

`emit-tex.mjs` inserts `{\mid}` and then escapes its own TeX ([emit-tex.mjs:26](/root/defiformal/formal/v3/emit-tex.mjs:26)).

- **Fix:** `t.split("|").map(esc).join("{\\mid}")`.

## NIT

### 15. Eight emitted sentences say “1 corpus protocols are contained”

Examples occur at [paper/atlas.tex:1450](/root/defiformal/paper/atlas.tex:1450), [1518](/root/defiformal/paper/atlas.tex:1518), [1856](/root/defiformal/paper/atlas.tex:1856), and [3868](/root/defiformal/paper/atlas.tex:3868).

- **Fix:** Emit “1 corpus protocol is contained”; retain the plural branch otherwise.

## Verified, not findings

Fresh re-derivation reproduced every saved verdict:

```text
specs: 60
obligations: 1259
covered: 573
residue: 686
coveragePct: 45.5
verdicts: { PARTIAL: 47, INADMISSIBLE: 13 }
storedVerdictMismatches: 0
```

Thus the requested central arithmetic is exact: 60 constructions, 1,259 obligations, 573 tagged covered, 686 tagged residue, 45.5%, 47 PARTIAL, 13 INADMISSIBLE, and 0 COMPLETE. The defect is the authored coding, not arithmetic drift.

Additional fresh checks:

```text
node formal/v3/claims.mjs -v  -> 109 claims verified, 0 failed
node formal/v3/selftest.mjs   -> 22 passed, 0 failed
missing evidence URLs         -> 0
missing date-shaped markers   -> 0
```

## Verdict

The sixty subsections are not publishable. Their stored arithmetic is reproducible, but one target block violates the emission invariant; one construction knowingly describes no real product; numerous covered assignments are refuted by their own evidence notes; compound obligations create demonstrable false residue; and the headline percentage measures uncontrolled prose-row granularity rather than protocol coverage. Repair requires re-atomising and re-adjudicating the specs—not merely regenerating the TeX.
tokens used
267,764
# Cold-read audit of the sixty application subsections

The subsections are not sound enough to publish.

## BLOCKING

### 1. The options block is not the emitter’s output

- **File/line:** [paper/atlas.tex:3357](/root/defiformal/paper/atlas.tex:3357)
- **Exact text:** “The five venues of the category are treated below… Every figure in the measurement environments is emitted from the checker output.”
- **Defect:** This eight-line paragraph is absent from `emit-tex.mjs` output and was inserted between the generated Aevo and Derive subsections. In LaTeX it therefore belongs to the Aevo subsection. Your rule says any emitter diff is BLOCKING.
- **Evidence:**

```text
$ diff -q <(node formal/v3/emit-tex.mjs expansion/10-options/specs \
    expansion/10-options/verdicts.json) \
    <(sed -n '3324,3491p' paper/atlas.tex)

10-options MISMATCH
```

The other eleven category ranges matched exactly. The mismatch is solely [lines 3357–3364](/root/defiformal/paper/atlas.tex:3357).

- **Fix:** Move the paragraph into the options section preamble, before the Aevo subsection, then require all twelve emitted ranges to diff cleanly.

## MAJOR

### 2. All twelve fixed-context residue summaries contradict the subsection totals

The generated subsection counts sum to the following, while the surrounding authored prose reports stale, much smaller figures:

| Paper line | Exact claim | Subsection total |
|---|---:|---:|
| [1391](/root/defiformal/paper/atlas.tex:1391) | “Twenty residue items” | 64 |
| [1617](/root/defiformal/paper/atlas.tex:1617) | “Twenty-six” | 61 |
| [1833](/root/defiformal/paper/atlas.tex:1833) | “Twenty-eight” | 47 |
| [2033](/root/defiformal/paper/atlas.tex:2033) | “Twenty-four” | 48 |
| [2243](/root/defiformal/paper/atlas.tex:2243) | “Twenty-nine” | 47 |
| [2448](/root/defiformal/paper/atlas.tex:2448) | “Thirty-three…the most” | 51; not most |
| [2662](/root/defiformal/paper/atlas.tex:2662) | “Twenty-five” | 61 |
| [2881](/root/defiformal/paper/atlas.tex:2881) | “Thirty-one” | 72 |
| [3100](/root/defiformal/paper/atlas.tex:3100) | “Thirty-five…highest density” | 57; not highest |
| [3313](/root/defiformal/paper/atlas.tex:3313) | “Twenty-three” | 51 |
| [3521](/root/defiformal/paper/atlas.tex:3521) | “Twenty-five” | 72 |
| [3763](/root/defiformal/paper/atlas.tex:3763) | “Twenty-five” | 55 |

The authored figures total 324; the sixty subsections contain 686 residue rows.

```text
$ node formal/v3/residue.mjs /root/defiformal/expansion

01 … 64
02 … 61
03 … 47
04 … 48
05 … 47
06 … 51
07 … 61
08 … 72
09 … 57
10 … 51
11 … 72
12 … 55
total: 1259 obligations, 573 covered, 686 residue
```

- **Fix:** Generate every category summary from verdicts. Delete the now-false “most” and “highest density” claims or recompute them.

### 3. Huma’s construction is knowingly the union of two different products and reproduces neither

- **File/line:** [paper/atlas.tex:2531](/root/defiformal/paper/atlas.tex:2531), [paper/atlas.tex:2534](/root/defiformal/paper/atlas.tex:2534)
- **Exact code:** `X = {Aw,Bs,Ep,Fd,Ft,Gp,Sh,Sv,Tr,Uc,Wq}` with `12/24` obligations discharged.
- **Defect:** The prose combines permissionless Huma 2.0 on Solana with the separate permissioned Huma Institutional product. The spec itself says:

> “The two must not be conflated: decomposing both under one name produces a construction that reproduces neither.”

That admission is at [huma-finance-v2.json:26](/root/defiformal/expansion/06-yield-vaults/specs/huma-finance-v2.json:26), yet the witness says it “carries both” at [line 218](/root/defiformal/expansion/06-yield-vaults/specs/huma-finance-v2.json:218).

- **Consequence:** The element set, admissibility, coverage, and residue are properties of no deployed object.
- **Fix:** Split the products into separate specs and verdicts. If the ranking is based on Huma 2.0 capital, the application subsection must measure Huma 2.0 alone.

### 4. Numerous “covered” assignments are refuted by their own notes

The checker validates only that a declared symbol exists in the 58 and is present in the construction. It never determines that the cited evidence supports the symbol. The record contains direct admissions of forced or false fits:

- Curve carries `Ag` at [paper/atlas.tex:1413](/root/defiformal/paper/atlas.tex:1413), while F13 says `Ag` is multi-venue and Curve’s router is single-venue; the mechanisms have “nothing in common but the word routing” ([curve.json:107](/root/defiformal/expansion/01-spot-exchange/specs/curve.json:107)).
- Raydium carries `Em` and `Up` at [paper/atlas.tex:1516](/root/defiformal/paper/atlas.tex:1516). Its notes say the emissions funder “could not be established at a primary source” ([raydium.json:154](/root/defiformal/expansion/01-spot-exchange/specs/raydium.json:154)), and that `Up` names a proxy although Raydium uses no delegatecall or implementation slot ([line 163](/root/defiformal/expansion/01-spot-exchange/specs/raydium.json:163)).
- Aster assigns `Bs` to fee-funded protocol reserves while admitting “the staking half is absent” ([aster.json:151](/root/defiformal/expansion/05-perpetuals/specs/aster.json:151)).
- edgeX assigns `Li` although the cited page documents only the trigger; payment to a third-party liquidator is unsupported ([edgex.json:135](/root/defiformal/expansion/05-perpetuals/specs/edgex.json:135)).
- Pendle assigns fixed-term debt `Ft` to a principal token while admitting that it is not debt and has no obligor ([pendle.json:38](/root/defiformal/expansion/06-yield-vaults/specs/pendle.json:38)).
- Polymarket carries on-chain order-book `Ob`, while its note says matching is off-chain and only settlement is on-chain ([polymarket.json:35](/root/defiformal/expansion/12-prediction/specs/polymarket.json:35)).
- Grove carries `Gp` for revoking a relayer role, despite its note and witness conceding that no system pause occurs ([grove-finance.json:56](/root/defiformal/expansion/12-prediction/specs/grove-finance.json:56), [paper/atlas.tex:3858](/root/defiformal/paper/atlas.tex:3858)).

A mechanical count found:

```text
assigned obligations:             573
explicitly labelled “approximate”: 151
```

The same symbol is also applied inconsistently. Curve says `Fd` “means…distribution to a claim class” ([paper/atlas.tex:1440](/root/defiformal/paper/atlas.tex:1440)); Kalshi adds it merely because a fee schedule exists ([paper/atlas.tex:3892](/root/defiformal/paper/atlas.tex:3892)); Polymarket’s note concedes that the fee destination is unknown ([polymarket.json:134](/root/defiformal/expansion/12-prediction/specs/polymarket.json:134)).

- **Fix:** Remove assignments whose defining condition is absent or unknown. Report exact, approximate, and forced assignments separately; only exact assignments may enter the headline coverage without a sensitivity analysis.

### 5. Three bridge subsections call self-published address lists independent attestations

BTCB, Coinbase Bridge, and WBTC all carry `At` and are declared fully warranted:

- [paper/atlas.tex:2683](/root/defiformal/paper/atlas.tex:2683)
- [paper/atlas.tex:2716](/root/defiformal/paper/atlas.tex:2716)
- [paper/atlas.tex:2815](/root/defiformal/paper/atlas.tex:2815)

But law `L27` requires a named attester, independence, assurance level, staleness bound, and recourse. Their notes concede:

- BTCB: “none of the five holds” ([binance-bitcoin-btcb.json:79](/root/defiformal/expansion/07-bridges/specs/binance-bitcoin-btcb.json:79)).
- Coinbase: issuer is not independent; no assurance level or recourse ([coinbase-bridge.json:62](/root/defiformal/expansion/07-bridges/specs/coinbase-bridge.json:62)).
- WBTC: no independence, assurance level, staleness bound, or recourse ([wbtc.json:76](/root/defiformal/expansion/07-bridges/specs/wbtc.json:76)).

- **Fix:** Treat these rows as residue, or introduce a separate “issuer-published reserve-address listing” element. They cannot honestly discharge `At`.

### 6. LayerZero’s admissibility is obtained by laundering an unrelated `Au` across obligations

- **File/line:** [paper/atlas.tex:2782](/root/defiformal/paper/atlas.tex:2782)
- **Exact code:** `X = {Au,Gs,Xf,Xm}`, followed by “every element is warranted” at [line 2784](/root/defiformal/paper/atlas.tex:2784).
- **Defect:** The `Gs` obligation says there is “no user-granted Au” ([layerzero-v2.json:52](/root/defiformal/expansion/07-bridges/specs/layerzero-v2.json:52)). The only `Au` evidence is an application owner delegating configuration administration, with no expiry or nonce discipline ([line 128](/root/defiformal/expansion/07-bridges/specs/layerzero-v2.json:128)).
- **Cause:** `construct.mjs` checks a global set. It does not require the `Au` satisfying the `Gs → Au` law to belong to the same authority relationship as the sponsored gas.
- **Fix:** Type requirement discharge by obligation or relation. Until then, LayerZero must leave the relevant `Au` term open.

### 7. Residue is inflated by compound rows whose own notes admit that an element fits part of the row

The paper says each listed obligation “has no element.” At least one row in each of the first six categories makes that sentence false:

| Category | Empty row | Existing fit admitted by note |
|---|---|---|
| Spot | PancakeSwap F19 | `Em` names the emission; only its direction is missing ([spec:160](/root/defiformal/expansion/01-spot-exchange/specs/pancakeswap.json:160)) |
| Lending | Maple F19 | `Gp` names the pause; revocation details are missing ([spec:168](/root/defiformal/expansion/02-lending/specs/maple.json:168)) |
| CDP | Liquity F13 | `Li` names the paid just-in-time liquidation; the ordered waterfall is missing ([spec:117](/root/defiformal/expansion/03-cdp-stablecoins/specs/liquity.json:117)) |
| Staking | Lido F10 | `Gp` names the unilateral pause; the attestation mechanism is missing ([spec:104](/root/defiformal/expansion/04-liquid-staking/specs/lido.json:104)) |
| Perpetuals | Aster F20 | `Ct` names the liquidation-price threshold; payoff deformation is missing ([spec:185](/root/defiformal/expansion/05-perpetuals/specs/aster.json:185)) |
| Yield | Pendle F6 | `Ix` names an accrual index; its ratchet/asymmetric-loss property is missing ([spec:66](/root/defiformal/expansion/06-yield-vaults/specs/pendle.json:66)) |

These are not arithmetic errors; they are atomisation errors. A covered mechanism and an uncovered refinement were written as one row and the whole row marked empty.

A second-half sample—Hyperliquid F4, KyberSwap F3, Centrifuge F16, Rysk F7, USDC F1, and Polymarket F1—did not produce a comparably definite false negative. Those sampled residues were defensible.

- **Fix:** Split base mechanism from refinement. Regenerate the central totals after atomic recoding; 686 is not presently an honest count of obligations to which “no element fits.”

### 8. The Maple conflict can be adjudicated only at code scope, not deployment scope

The lending subsection states:

> “A loss draws down the delegate’s own posted capital…”  
> “the agent here is bonded, the sanction is financial and automatic”

([paper/atlas.tex:1698](/root/defiformal/paper/atlas.tex:1698), [line 1723](/root/defiformal/paper/atlas.tex:1723)).

The RWA subsection states:

> “the first-loss module exists in the code and is deliberately empty”  
> “With the backstop gone…”

([paper/atlas.tex:3232](/root/defiformal/paper/atlas.tex:3232), [line 3247](/root/defiformal/paper/atlas.tex:3247)).

Recorded evidence establishes that `_handleCover` exists and that origination/withdrawal are gated by `minCoverAmount`. It does not establish any named live pool’s current minimum or balance. The lending note explicitly says the live balance may be zero and commands stage 6 not to say the delegate is bonded without a live figure ([maple.json:111](/root/defiformal/expansion/02-lending/specs/maple.json:111)). The RWA source says cover is unused because *most* pools are Maple Direct pools, which does not establish emptiness for every pool.

- **Adjudication:** An enforced code path exists. Whether a specified live pool is funded is **NOT SHOWN**.
- **Fix:** Scope both subsections to named pools and record `minCoverAmount`, cover balance, delegate identity, and block number. Until then, describe only a configurable code-level mechanism.

### 9. The 45.5% figure is not a protocol-coverage statistic

`construct.mjs` counts each authored JSON row once and declares the whole row covered whenever any listed element is present:

```js
if (!els.length) uncovered.push(o);
...
else covered.push({ id: o.id, by: present });
```

([formal/v3/construct.mjs:71](/root/defiformal/formal/v3/construct.mjs:71)).

The validator does not enforce atomicity; it merely checks that the text has at least twenty characters ([validate.mjs:30](/root/defiformal/formal/v3/validate.mjs:30)). Specs contain between 15 and 26 obligations, with compound rows such as those above.

Therefore:

- 45.5% supports only: **573 of 1,259 authored ledger rows were given at least one symbol**.
- It does not support comparisons of how much of two protocols is expressible.
- It does not support category rankings.
- It does not estimate a proportion of protocol behaviour, code paths, economic importance, or risk.
- Splitting one compound row into base mechanism plus refinement changes the denominator and numerator without changing the protocol.

- **Fix:** Call it “recorded-obligation-item coverage”; publish application- and category-macro sensitivity; establish and independently audit an atomic-obligation coding rule before using it as a resolution measure.

### 10. The subsections omit the information a hostile referee needs to identify and reproduce the measured object

No standardized scope record states product, version, chain, deployment addresses, block height, observation date, or whether the construction unions generations. Huma demonstrates the consequence; Curve, Fluid, Uniswap, Liquity, and Ondo also combine generations or distinct product families.

Nor does any measurement report the number of exact, approximate, forced, or unknown assignments, despite 151 assigned rows being expressly labelled approximate.

- **Fix:** Every subsection needs a scope header and coding ledger containing:

  - exact product/version/deployments and snapshot block;
  - obligation-to-source pinpoints;
  - exact/approximate/unknown assignment status;
  - atomisation rule and adjudicator;
  - sensitivity of verdict and coverage to disputed assignments.

Absent these, the empirical object and coding reliability are **NOT SHOWN**.

## MINOR

### 11. 104 evidence fields are future-dated relative to the audit date

All 98 Intents obligations and six CDP obligations say `accessed 2026-08-05`, while the corpus/audit date is 2026-08-04. Example: [binance-wallet.json:17](/root/defiformal/expansion/08-intents/specs/binance-wallet.json:17).

```text
futureDatedEvidence: 104
```

`validate.mjs` checks only for a date-shaped string, not whether it is valid ([validate.mjs:36](/root/defiformal/formal/v3/validate.mjs:36)).

- **Fix:** Correct the dates or state and substantiate a UTC-boundary convention.

### 12. BTCB turns a failed search into a global absence claim

- **File/line:** [paper/atlas.tex:2701](/root/defiformal/paper/atlas.tex:2701)
- **Exact text:** “No independent auditor attests to the BTCB collateral specifically; no such report was found.”
- **Defect:** The corresponding note labels the result `UNKNOWN` and says only that no report “could be located.” Binance’s own reserve page cannot prove that no independent report exists.
- **Fix:** Write: “No independent BTCB-specific report was located in the sources searched,” followed by the search scope.

### 13. All sixty `source` fields are broken provenance links

Every spec points to a non-workspace Windows path such as:

```json
"source": "C:\\defiformal-work\\01-spot-exchange\\01-research.md"
```

([curve.json:4](/root/defiformal/expansion/01-spot-exchange/specs/curve.json:4)).

```text
specs: 60
nonresolvingSourcePaths: 60
```

The validator checks only that `source` is nonempty ([validate.mjs:43](/root/defiformal/formal/v3/validate.mjs:43)).

- **Fix:** Use repository-relative paths and include the round-two record where relied upon.

### 14. Six inadmissibility clauses contain double-escaped mathematics

- **Example:** [paper/atlas.tex:1703](/root/defiformal/paper/atlas.tex:1703)

```tex
$L1:Ex\{\textbackslash\{\}mid\}Tp\{\textbackslash\{\}mid\}At$
```

`emit-tex.mjs` inserts `{\mid}` and then escapes its own TeX ([emit-tex.mjs:26](/root/defiformal/formal/v3/emit-tex.mjs:26)).

- **Fix:** `t.split("|").map(esc).join("{\\mid}")`.

## NIT

### 15. Eight emitted sentences say “1 corpus protocols are contained”

Examples occur at [paper/atlas.tex:1450](/root/defiformal/paper/atlas.tex:1450), [1518](/root/defiformal/paper/atlas.tex:1518), [1856](/root/defiformal/paper/atlas.tex:1856), and [3868](/root/defiformal/paper/atlas.tex:3868).

- **Fix:** Emit “1 corpus protocol is contained”; retain the plural branch otherwise.

## Verified, not findings

Fresh re-derivation reproduced every saved verdict:

```text
specs: 60
obligations: 1259
covered: 573
residue: 686
coveragePct: 45.5
verdicts: { PARTIAL: 47, INADMISSIBLE: 13 }
storedVerdictMismatches: 0
```

Thus the requested central arithmetic is exact: 60 constructions, 1,259 obligations, 573 tagged covered, 686 tagged residue, 45.5%, 47 PARTIAL, 13 INADMISSIBLE, and 0 COMPLETE. The defect is the authored coding, not arithmetic drift.

Additional fresh checks:

```text
node formal/v3/claims.mjs -v  -> 109 claims verified, 0 failed
node formal/v3/selftest.mjs   -> 22 passed, 0 failed
missing evidence URLs         -> 0
missing date-shaped markers   -> 0
```

## Verdict

The sixty subsections are not publishable. Their stored arithmetic is reproducible, but one target block violates the emission invariant; one construction knowingly describes no real product; numerous covered assignments are refuted by their own evidence notes; compound obligations create demonstrable false residue; and the headline percentage measures uncontrolled prose-row granularity rather than protocol coverage. Repair requires re-atomising and re-adjudicating the specs—not merely regenerating the TeX.
