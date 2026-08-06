# TODO — the positive program

Live task list. `ROADMAP.md` holds the phase structure and the gate table;
`GOAL.md` holds the goal and the current measured status. This file is what to
do next.

**The goal, unchanged:** exhibit a finite basis of primitive mechanisms and prove
every useful DeFi application is constructible from it. Completeness first, then
composition, then construction.

---

## Now — Phase 2, the honest corpus

- [ ] **2.2 — spec the unspecced applications. WORK-LIST NOW EXISTS:
      `sigma/GATE-2.2-WORKLIST.md` enumerates 19** (not 21 — measured 68 named /
      50 specced against `ROADMAP`'s 72/51; the discrepancy is reported, not
      reconciled, and **four named applications are unaccounted for**).
      Highlights: **`Steakhouse Financial` is on the list**, confirming
      independently that the refuter was never formalised; `CIAN Yield Layer`
      beside it is a second delegated-allocation instance; and **four of the 19
      are Intents**, the category `VERDICT.md` scores worst at ~25%.
      **Precondition 2 SETTLED — `sigma/GATE-2.2-AVAILABILITY.md`: 0 of 19 have
      contracts in `protocol-repos/`.** All 56 repos there correspond to
      already-specced protocols. 2.2's real cost is ~19 contract acquisitions,
      then 19 specs, plus an explicit declaration wherever the mechanism is not
      on-chain (Kalshi, BUIDL, USYC, the Binance products).
      **Steakhouse comes off the list:** the lane JSON's own `rank_basis` says
      the biggest vaults in DeFi are *curated Morpho vaults* — Steakhouse is a
      firm holding a role, not a protocol, which is why it never had a spec. Its
      mechanism is MetaMorpho and is now specced (`metamorpho.qnt`). Record a
      stated position, not a missing spec.
      Still open: adopt 6h before commissioning, or all inherit the defect
      blocking Phase 1. (72-vs-68 is now resolved — see the residue item below.)
  - [x] **Residue mined — `sigma/RESIDUE-MINED.md`, artifact
        `sigma/residue-index.json` (324 entries, 72 protocol entries, bucketed).**
        **72-vs-68 RESOLVED**: 72 raw entries, 4 of them the same application in
        two lanes, 68 distinct. 2.2 precondition 1 settled; the 19 stands.
        **authority/discretion is the largest classified bucket** — 69 entries
        across 40 of 72 applications. Narrowed to a party exercising discretion
        over assets it does not own: **4 distinct protocols across 4 categories**
        (Morpho, Liquity V2 batch managers, Steakhouse, Grove), and Liquity's own
        residue notes unprompted that it is "the same shape as Morpho's curator
        gap, appearing in a completely different category".
        **That makes the delegated mandate the only object in the corpus with
        genuinely INDEPENDENT multi-witness support** — 1.1a showed all 28 basis
        rows reaching >=2 did so via shared `common.qnt` reuse. The one thing the
        basis cannot express is better evidenced than anything it contains.
  - [x] **The unclassified 131 are a LONG TAIL — `sigma/RESIDUE-LONGTAIL.md`.**
        No dominant term (top is `price` at 12 of 131 = 9%, against
        authority/discretion's 69 across 40 of 72 applications). The two largest
        word-groups dissolve on reading: `price`/`oracle` is 17 entries naming 15
        different mechanisms, `claim` is 11 naming 11.
        **So the residue does NOT hide a second refuter-sized class.** The corpus
        has one structural gap with independent multi-protocol support and a long
        tail of protocol idiosyncrasy no basis was going to absorb.
        Two weak sub-themes named but not promoted: execution-quality attribution
        (~6, all DEX/intents) and claim transformation (~4).
        Limit recorded: a class whose members share no vocabulary would be
        invisible to both methods used. On the two read so far the
        hit rate is 3 for 3: Steakhouse's residue names the curator refuter *and*
        the owner/curator/allocator role split (convention 6h), and CIAN's names
        keeper-liveness — which is pair 4's autonomy law, identified by the corpus
        before Phase 1 ever tested it. The residue was filed as a post-mortem on
        the 58 symbols; it is actually a list of mechanisms that need caller
        identity to state.
      The corpus names 72; only 51 had specs. **Now the active gate** — Phase 1 is blocked behind it
      (`GATE-1.1B-PAIR4.md`).
      **CORRECTION to this item's own claim.** It read: Steakhouse Financial "is
      a known refuter (delegated allocation authority) and needs no further work
      to count against completeness." That was a refutation *asserted*, not
      exhibited, and `GOAL.md` demands a **statable object**. An unformalised
      protocol is not one. The reason it was never formalised is now known:
      stating the mechanism needs caller identity, and 0 of 17 gate-opening
      actions model it.
      **Now exhibited against source** — `sigma/REFUTER-DELEGATED-ALLOCATION.md`,
      from `metamorpho` rev `58e758b`. `reallocate` (`MetaMorpho.sol:366`,
      `onlyAllocatorRole`) redistributes depositors' assets on an allocator's
      arbitrary calldata vector, bounded only by caps (`:400`, `:402`) and exact
      conservation (`:414`). The property it violates is **owner-locality** — a
      transition changes only positions attributable to its caller — which every
      basis family satisfies. **Not yet a theorem:** owner-locality is verified
      for 7 families by hand not all of `P`, the closure argument under `⋈` is
      unwritten, and there is no Quint witness until 6h lands. Do **not** record
      completeness as refuted.
  - [x] **Quint witness DELIVERED — `quint-models-v2/metamorpho.qnt`.** The
        first spec in the corpus that models caller authority, written under
        convention 6h. Typechecks; **lint 0**; six invariants `[ok]`; four
        `wit_*` all `[violation]` as required.
        **The demonstration is machine-checked:** `inv_conservation`,
        `inv_sharesSum`, `inv_capsRespected` and `inv_nonNegative` all hold over
        20 steps x 3000 samples, while `wit_outsiderMovesDepositorAssets` is
        reachable — `mallory`, who holds no shares and never can, redistributes
        assets alice and bob deposited. **The corpus's entire invariant
        vocabulary is [ok] across the refuter.**
        Two bugs the harness caught, both worth keeping: `inv_T0` died with
        QNT507 because `alloc.get(who)` is evaluated even when a later disjunct
        would succeed, so a vector querying `"curator"` against
        `Map("mallory" -> ...)` crashes — exactly what T0 vectors are for. And
        `respec_lint` D2 flagged `curator` and `totalShares` as declared but
        never driven: both true positives, since the header cited
        `MetaMorpho.sol:186 setCurator` and no action wrote it. `setCurator` and
        `withdraw` added; lint went 2 -> 0.
  - [x] **CHARACTERISED — `sigma/CHARACTERISATION.md`, machine-checked
        (`inv_separation` `[ok]`, lint 0).** Owner-locality was the wrong
        property and `aave_v3.qnt:156` killed it: `liquidate` seizes the
        *borrower's* collateral, is called by someone else, and is a basis
        family. **Non-locality does not separate.**
        Corrected: factor `S ≅ P × R` (positions × role assignment). A transition
        is **permission-free** if its guard factors through `P`. Every basis
        family is (liquidation included — its guard reads the victim's *health*,
        and anyone may call). Permission-freedom is closed under `⋈` (`R` is a
        spectator coordinate for the whole closure). The mandate is not.
        **Therefore mandate ∉ closure(basis).**
        Constructive half: `act`'s effect is exactly `P1 · Led.move`
        (`BASIS.md:47`), so **`mandate = Perm ⋈ Led.move`** and the basis is
        incomplete **by exactly one primitive, `Perm`**. Five falsifiable laws
        given (monotone delegation, revocability, bounded discretion,
        conservation, position-blindness of the gate).
        Also proved: the discriminating observable is the pair
        `(caller, n ↦ Δpos(n))`. Conservation sees only `Σ pos` — machine-checked
        that two disjoint allocations share one value — and share accounting sees
        only the caller's column, which `reallocate` leaves fixed.
  - [x] **`Perm` confirmed against a second, independent witness —
        `sigma/PERM-CONFIRMED.md`.** Liquity V2 batch managers
        (`BorrowerOperations.sol:905`): same gate, **different gated operation**.
        `mandate_morpho = Perm ⋈ Led.move`; `mandate_liquity = Perm ⋈ Post(rate)`
        — the manager sets a rate governing accrual on other people's debt, and
        nothing is transferred. **`Perm` is the invariant factor and what it
        gates varies**, which is the outcome that distinguishes a
        characterisation from a curve fitted to one instance. The five laws
        survive with different instruments.
  - [x] **Gate 0.1's failure EXPLAINED.** `BASIS.md`:29-31 defines `Σ` as "may be
        overwritten by **an external writer**" — a permission predicate — and
        both cited witnesses model no writer (`applyPostPrice(old, p, t)`,
        `shockPrice(p)`). So `Q`/`Σ` is a distinction in `R` stated as one in `P`,
        and all four operationalisations were predicates on `P`. That is why
        `QSIGMA-VERDICT` §3's "no syntactic test on assignment form will separate
        provenance" is true: **provenance is the permission coordinate.**
        Corollary: `Post` (F6) is `Perm ⋈ assignment` with the gate deleted —
        deletion class 11 occurring in the basis itself — which is also why F6
        merged so readily into `Prop`.
  - [ ] Generation theorem for the extended basis `P ∪ {Perm}`. §8 of
        `CHARACTERISATION.md` is explicit that irreducibility of `Perm` says
        nothing about completeness once it is added.
  - [ ] **Re-derive F6 once `R` exists.** If `Post` is a decapitated `Perm`, the
        family list shortens again and for a principled reason rather than a
        lane-naming one.
        **Attempted and reformulated — `sigma/OWNER-LOCALITY.md`.** The
        `pure def`/`action` split is not a proxy for owner-locality: 83 `pure
        def`, 16 `type`, **6 `action`**, 4 `var`, 4 unresolved. All six actions
        read by hand and all are deterministic given their arguments — **but so
        is `reallocate`.** What separates them is who may supply the arguments,
        which no v1 spec records. **Blocked on 6h**, like everything else.
        `triggerDefault` ("Delegate triggers default") is plausibly a SECOND
        witness to the refuter rather than a counterexample — `VERDICT.md` §1
        names Maple pool delegates alongside Morpho curators.
- [ ] **2.3 — re-run generation against the honest corpus.** This is the payoff.
      Everything since the eight-family refutation has been building the ability
      to measure; this is the measurement. Compare against the v1 figure of
      743/820 definitions, 10 specs ungenerated, 57 of 183 lane primitives
      outside the basis — but note that figure was taken against specs with the
      difficulty deleted, so it is a floor, not a baseline.

### Carried into 2.2 / 2.3 from the re-spec

- [x] **Check W1's shipped curve domain against the K=8 truncation finding.**
      **CLOSED — neither remedy is required.** The finding reproduces exactly
      (`evidence/curve_k.py`: at a 10^6 cap the worst converging pair needs 12
      iterations, and 97 of 4900 converging pairs exceed K=8), but the shipped
      spec does not truncate them: `newtonDFull` carries a `done` flag and every
      action conjoins `st.done` / `sy.done` / `after.done`, so a pair whose break
      would not have fired within 8 iterations **disables the transition** rather
      than returning a wrong `D`. `inv_dConverged` asserts it at every reached
      state. Verified: `inv_all` `[ok]` over 20 steps x 2000 samples, with
      reached balances of 164272 / 241198 — i.e. the run does explore above 10^5,
      where the pathology lives. The cost is a declared (E<=) restriction, not
      unsoundness.
      **One correction fell out of this** — see the ambiguity note below.

- [ ] **Disambiguate `curve.qnt`'s declared refusal count.** Line 79 declares
      "36 of 4900 balance pairs never break". `evidence/curve_refused.py` counts
      the pairs the `done` guard actually refuses on `curve_k.py`'s uniform 10^6
      grid: **117 of 4900** (2.39%) — 20 that never converge plus 97 that
      converge but need more than 8 iterations. The two populations differ (the
      spec means its own reachable grid, generated by 8 enumerated deposit pairs
      and 4 exchange inputs; `curve_k.py` means a uniform sweep) and **both
      happen to have 4900 members**, which is exactly the collision that invites
      a reader to treat one number as the other. Either re-state line 79 with its
      population named, or report both. At a 10^5 cap the refusal count is 10.
- [ ] **Adopt the configuration-vector clause as convention 6b.** A T0 block
      written entirely in explicit arguments pins the *function*, not the
      *configuration* — `absorbHaircut(5000, 9000)` survives a mutation of
      `LIQUIDATION_FACTOR`. Every spec needs vectors evaluated at the market's
      own constants, not only at literals.
- [ ] **Adopt the arity-witness rule.** Value signatures cannot kill a
      selection-shaped deletion, and neither can the mechanism invariant. For any
      mechanism whose content is *which elements were selected together*, add a
      ghost recording the arity of the selection, justified against an on-chain
      observable.
- [ ] Correct `PILOT-NOTES` §7: apex's M3 agreement is 0/49, not 7/49.
- [ ] Correct `P2-CONTRACT` §A.10: the polymarket batch row is not economically
      realisable (implies a taker contribution of -30).
- [ ] Fold the three linter refinements the workers asked for: D4 should not fire
      when the action body re-derives the selection criterion from `var`s; D4
      matches `pure def` bodies as well as driver call sites; D4 cannot see
      through a nested call, so `batchLiquidate(List(u, v))` is silently exempt.

---

## Blocked — Phase 0/1, and deliberately visible

- [x] **0.1 — state the `Q`/`Sigma` invariant testably, or withdraw `|P| = 4`.**
      **RESOLVED — see `sigma/QSIGMA-VERDICT.md`. The invariant as stated is
      false; `|P| = 4` and the six-sort split are withdrawn.**
      The "three operationalisations" were two — `qsigma3.py` is a byte copy of
      `qsigma2.py` — and both returned the empty `Q` because they scanned `init`,
      whose literal assignments are replacements by construction. Excluding it
      (`qsigma4.py`) makes the partition non-trivial at once; resolving local
      `val` bindings too (`qsigma5.py`) gives **Q 334 / Sigma 54**, with 95.5% of
      balances never replaced. But only 36.5% of prices/rates ARE replaced,
      because accrual indices evolve multiplicatively from their own prior value
      — exogenous in provenance, endogenous in update form. And `BASIS.md`'s own
      cited witness refutes it: `usdt.qnt:157` overwrites `reserve` wholesale in
      `attestReserve`, an external writer, which the citation omits and the spec
      documents two lines below.
      **Follow-on for Phase 1:** the replacement/update partition survives as a
      statement about update form. If 1.1 wants it, it must earn its place as a
      law with witnesses like any other family. Do not attempt a sixth
      operationalisation to rescue the semantic reading.
- [ ] **0.2 — prove `F9` (extremal allocation) irreducible.** Settled
      empirically: every fold in all 57 v1 specs is a commutative sum, and there
      is not one extremal selection in the corpus. Needs the theorem — an
      invariant every composite preserves and extremal selection breaks.
- [ ] **1.1 — enumerate the ~16 families with signatures and laws.** Gate: every
      family has >= 2 corpus witnesses and a law that fails for its neighbours.
      **First scoring done — `sigma/GATE-1.1-WITNESSES.md`. The gate is not
      answerable on the current evidence base**, and splits into two:
  - [ ] **1.1a — recount witnesses corpus-wide.** *Attempted by identifier
        search and the method failed — `sigma/GATE-1.1A-RECOUNT.md`.*
        `layerzero` implements once-only delivery with its own `PacketStatus`
        machine and never calls `common.canDeliverOnce`, so search scores 0 where
        the ledger correctly counts 2. Identifier reuse is not mechanism
        instantiation.
        **What the attempt did establish: of the 28 rows reaching >= 2 witnesses,
        28 are shared-`common.qnt` reuse and 0 are independent
        re-implementations.** Condition 1 as measurable is a test of whether a
        definition sits in a common file.
        - [ ] **Restate condition 1 first:** two specs calling the same
              `common.qnt` definition are ONE witness. Otherwise the recount
              re-certifies shared helpers.
        - [ ] **Then recount by reading**, per row, against the 51 protocol
              specs. Do not quote 31/19/2 or 28/50 as evidence — both measure
              identifier provenance, not instantiation.
        - [ ] Still do **not** prune singletons: a row scoring 1 may have an
              independent second implementation no search will surface.
  - [ ] **1.1b — write one law per surviving family**, each failing for its
        nearest neighbour. **Condition 2 is unmet for all 52 rows.**
        **First pair tested and it returns a NEGATIVE —
        `sigma/GATE-1.1B-LAWS.md`.** Eight laws against `PRO_RATA_SHARES` vs
        `INDEX_ACCRUAL`; three appeared to separate and all three died under
        audit (an integer-flooring artifact, a signature difference dressed as a
        law, and one row asserted rather than measured whose measurement came
        back **reversed**: index call sites write a ratio component 100% of the
        time against pro-rata's 70%). **0 of 8 separate — they are one family**,
        which confirms `BASIS.md`'s F1/F6 merge on tested grounds.
        - [x] **Pairs 2 and 3 tested — `sigma/GATE-1.1B-PAIRS23.md`. Both
              collapse.** L3 `RateLimit` vs L6 `RateLimit` are extensionally
              identical on all 165 well-formed states (the 20 disagreements are
              guard clauses at `capacity<=0`/`slope<=0`). `isHealthy` vs
              `maintainsMargin`: 0 of 5 laws separate — P4 died to asymmetric
              test design, P5 to a domain that never crossed the health
              threshold. **Three pairs tested, three collapses, zero separating
              laws.**
        - [x] **Pair 4, the deferred-claim cluster — UNTESTABLE, and this is
              Phase 1's real blocker. `sigma/GATE-1.1B-PAIR4.md`.** The four rows
              differ only in what opens the gate (nothing / time / a posted
              price / an authority), so the separating law is **autonomy** — can
              the holder claim without another party's cooperation. **0 of 17
              gate-opening actions carry any caller guard**, so all four score
              autonomous and the law separates nothing. `wbtc.confirmMint` is the
              witness: comment "onlyCustodian", signature `(id: int)`.
        - [x] **Caller authority drafted as convention 6h —
              `phase2/CONVENTION-6H-AUTHORITY.md`.** Every state-changing action
              must either model its caller against modelled authority state, or
              carry an `AUTHORITY OMITTED` declaration naming the contract line.
              Branching cost is bounded (authority sets are small; two principals
              — one holding the role, one not — host every witness the autonomy
              law needs). D7a/D7b lint sketched, with the two false-positive
              traps recorded. **Not yet adopted into `P2-CONTRACT`** — that is a
              decision, not a drafting task, and it retrofits the ten existing
              v2 re-specs.
        - [x] **Deletion class 11 scanned and hand-audited —
              `sigma/DELETION-11.md`. 4 confirmed, in `coinbase`, `usdc` and
              `wbtc`, all outside `P2-SCOPE`'s ten.** The raw scan said 7; hand
              checking found `usdc.mint` models its minter via
              `canMintWithAllowance` (false positive), `coinbase.init` is an
              initialiser, and `wbtc.addMintRequest`'s single `MERCHANT` is a
              declared (E<=) restriction rather than a deletion.
              **The method's ceiling is the finding:** it only sees restrictions
              the author documented, and silent omission is the normal case. Nine
              documented claims across 51 specs is implausibly few. **Do not
              quote a size for this class** — 4 is a lower bound of unknown
              tightness, and closing the gap needs the contracts, not the specs.
        - [ ] **Re-order: 2.2 before the rest of 1.1b.** Remaining pairs will hit
              the same wall wherever their law depends on a deleted mechanism.
        - [ ] Check every future law against the five-class artifact taxonomy in
              `GATE-1.1B-PAIRS23.md` before reporting it.
        - [ ] Every proposed law ships with its audit: exact-arithmetic check,
              law-vs-signature statement, and a measurement against the 51 specs.
              Never report a separation count without the audit column — pass
              one's headline was "3 of 8", the true figure is 0.
- [ ] **1.2 — pairwise independence**, each with a separating trace, as `F7` got
      via the interest-only trace.
- [ ] **1.3 — sufficiency.** The failure list (<= 15 colour classes) gives only
      the *necessary* direction. Post's theorem is an *iff*.

---

## Later — Phases 3 and 4

- [ ] 3.1 Generation theorem. 3.2 Composition totality. 3.3 Construction plus a
      linear-time certificate. 3.4 Mechanise in Lean (the development exists,
      sorry-free, no custom axioms).
- [ ] 4 Write the paper.

---

## Standing discipline

Seven times now, a check has passed **because the stressing states were
removed** — in the v1 invariants, in the plan's parsimony step (mandated), in an
acceptance test that checked shape not value, in conformance vectors true when
the function never runs, in a <=200 domain that "proves" Curve converges, in a
domain bound validated on a smaller grid than it shipped against, and in T0
blocks that pin the function but not the configuration.

Assume an eighth exists in whatever is written next.

Two rules that follow, and are not negotiable:

1. **Never report a mutant killed without running it.** W3 asserted a value
   signature unreachable, built the mutant, and watched it reach that state at
   depth 3.
2. **Conservation never once detected a deleted mechanism** — across morpho,
   compound, gmx, liquity and derive, `inv_conservation` reported `[ok]` on every
   mutant. A spec whose only invariant is conservation has tested nothing.
