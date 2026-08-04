module atlas {
  type Element =
    | Sh | Ix | Rb
    | Cp | Wg | St | Cl | Pm
    | Ob | Rf | Ba | In
    | Ag | Fl
    | Pl | Im | Cd | Uc | Ft
    | Ct | Li | Ad | Sl | Bs
    | Pf | Op | Tr | Cv | Py | Sv | Dp
    | Ex | Tp | Oa | At
    | Sr | Ep | Wq
    | Em | Fd
    | Tg | Up | Gp | Au | Gs
    | Xm | Xf | Rl | Of
    | Rd | Ps | As
    | Aw | Sb | Sd | Fz
    | Rs | Vl

  type Group =
    | G01 | G02 | G03 | G04 | G05 | G06 | G07 | G08
    | G09 | G10 | G11 | G12 | G13 | G14 | G15 | G16

  type Atom = AsyncNative | AsyncRepairable | AsyncImpossible
  type ElementStatus = Core | Candidate | Provisional

  type ElementAttributes = {
    id: str,
    name: str,
    group: Group,
    stratum: int,
    atom: Atom,
    status: ElementStatus,
    definition: str,
  }

  type Law = {
    id: str,
    raw: str,
    subjects: Set[Element],
    terms: Set[Set[Element]],
    externalTerms: int,
    mixedTerms: int,
    asyncRepairable: bool,
    unsupportedSubject: bool,
  }

  type HazardClass = Forbidden | Elevated | Unverifiable
  type HazardPolarity = ExternalQualified | MixedQualified | NegativeNamed

  type Hazard = {
    id: str,
    family: str,
    raw: str,
    elements: Set[Element],
    cls: HazardClass,
    polarity: HazardPolarity,
  }

  type ProtocolDefinition = {
    id: str,
    name: str,
    elements: Set[Element],
    dead: bool,
  }

  pure val allElements: Set[Element] = Set(
    Sh, Ix, Rb,
    Cp, Wg, St, Cl, Pm,
    Ob, Rf, Ba, In,
    Ag, Fl,
    Pl, Im, Cd, Uc, Ft,
    Ct, Li, Ad, Sl, Bs,
    Pf, Op, Tr, Cv, Py, Sv, Dp,
    Ex, Tp, Oa, At,
    Sr, Ep, Wq,
    Em, Fd,
    Tg, Up, Gp, Au, Gs,
    Xm, Xf, Rl, Of,
    Rd, Ps, As,
    Aw, Sb, Sd, Fz,
    Rs, Vl
  )

  pure val elementAttributes: Element -> ElementAttributes = Map(
    Sh -> { id: "E001", name: "Pro-rata share accounting", group: G01, stratum: 0, atom: AsyncRepairable, status: Core, definition: "Shares represent a proportional pool claim." },
    Ix -> { id: "E002", name: "Index-based accrual", group: G01, stratum: 0, atom: AsyncRepairable, status: Core, definition: "A global exchange-rate or debt index changes claim value." },
    Rb -> { id: "E003", name: "Rebasing accounting", group: G01, stratum: 0, atom: AsyncRepairable, status: Core, definition: "Nominal balances change through global scaling." },
    Cp -> { id: "E004", name: "Constant-product invariant", group: G02, stratum: 1, atom: AsyncRepairable, status: Core, definition: "x·y = k." },
    Wg -> { id: "E005", name: "Weighted-geometric invariant", group: G02, stratum: 1, atom: AsyncRepairable, status: Core, definition: "Multi-asset weighted pricing." },
    St -> { id: "E006", name: "Stable-hybrid invariant", group: G02, stratum: 1, atom: AsyncRepairable, status: Core, definition: "Constant-sum near parity, constant-product away from it." },
    Cl -> { id: "E007", name: "Concentrated liquidity", group: G02, stratum: 1, atom: AsyncRepairable, status: Core, definition: "Range-specific position state and tick activation." },
    Pm -> { id: "E008", name: "Oracle-priced inventory curve", group: G02, stratum: 1, atom: AsyncRepairable, status: Core, definition: "Proactive market making against an external reference." },
    Ob -> { id: "E009", name: "On-chain order book", group: G03, stratum: 1, atom: AsyncRepairable, status: Core, definition: "Limit orders, sequencing, cancellation, settlement." },
    Rf -> { id: "E010", name: "Request for quote", group: G03, stratum: 1, atom: AsyncNative, status: Core, definition: "Signed maker quote against inventory." },
    Ba -> { id: "E011", name: "Batch-auction clearing", group: G03, stratum: 2, atom: AsyncNative, status: Core, definition: "Uniform clearing over a batch." },
    In -> { id: "E012", name: "Intent & solver execution", group: G03, stratum: 4, atom: AsyncNative, status: Core, definition: "Signed outcome constraints delegated to competing solvers." },
    Ag -> { id: "E039", name: "Aggregation & routing", group: G04, stratum: 1, atom: AsyncRepairable, status: Core, definition: "Multi-venue route construction." },
    Fl -> { id: "E040", name: "Atomic flash liquidity", group: G04, stratum: 1, atom: AsyncImpossible, status: Core, definition: "Borrow and repay within one settlement scope or revert." },
    Pl -> { id: "E013", name: "Pooled lending", group: G05, stratum: 3, atom: AsyncRepairable, status: Core, definition: "Shared liquidity pool, many lenders and borrowers." },
    Im -> { id: "E014", name: "Isolated lending market", group: G05, stratum: 3, atom: AsyncRepairable, status: Core, definition: "Per-market risk isolation with its own oracle, LLTV and rate model." },
    Cd -> { id: "E015", name: "Collateralized-debt minting", group: G05, stratum: 3, atom: AsyncRepairable, status: Core, definition: "Mint a liability against locked collateral." },
    Uc -> { id: "E016", name: "Undercollateralized credit", group: G05, stratum: 3, atom: AsyncNative, status: Core, definition: "Credit extended on identity, underwriting and recourse." },
    Ft -> { id: "E017", name: "Fixed-term debt", group: G05, stratum: 3, atom: AsyncNative, status: Core, definition: "Maturity-dated claim with a discount factor." },
    Ct -> { id: "E018", name: "Collateral-threshold test", group: G06, stratum: 3, atom: AsyncRepairable, status: Core, definition: "The margin/LTV/health computation and its threshold." },
    Li -> { id: "E019", name: "Incentivized liquidation", group: G06, stratum: 3, atom: AsyncRepairable, status: Core, definition: "Third parties repay unhealthy debt for discounted collateral." },
    Ad -> { id: "E020", name: "Auto-deleveraging", group: G06, stratum: 3, atom: AsyncRepairable, status: Core, definition: "Rank-ordered forced close when buffers are exhausted." },
    Sl -> { id: "E021", name: "Socialized-loss allocation", group: G06, stratum: 3, atom: AsyncNative, status: Core, definition: "Losses assigned to an explicit claim class." },
    Bs -> { id: "E022", name: "Staked backstop", group: G06, stratum: 3, atom: AsyncRepairable, status: Core, definition: "Slashable first-loss capital." },
    Pf -> { id: "E023", name: "Perpetual funding transfer", group: G07, stratum: 3, atom: AsyncRepairable, status: Core, definition: "Periodic payment tethering a perp to an index." },
    Op -> { id: "E024", name: "Option payoff", group: G07, stratum: 3, atom: AsyncNative, status: Core, definition: "Strike, expiry, collateralized contingent settlement." },
    Tr -> { id: "E025", name: "Tranche waterfall", group: G07, stratum: 3, atom: AsyncNative, status: Core, definition: "Declared seniority over a determined loss event." },
    Cv -> { id: "E026", name: "Mutual cover pool", group: G07, stratum: 3, atom: AsyncNative, status: Core, definition: "Adjudicated claims against pooled premium capital." },
    Py -> { id: "E027", name: "Principal/yield separation", group: G07, stratum: 3, atom: AsyncNative, status: Core, definition: "Split a yield-bearing claim into PT and YT." },
    Sv -> { id: "E057", name: "Servicing & determination discretion", group: G07, stratum: 3, atom: AsyncNative, status: Candidate, definition: "A named party's discretionary determination of loss, valuation, cure, waiver or suspension that alters others' claims." },
    Dp -> { id: "E060", name: "Directional position & hedge maintenance", group: G07, stratum: 3, atom: AsyncNative, status: Candidate, definition: "A held directional exposure and the rebalancing that maintains it." },
    Ex -> { id: "E028", name: "External data oracle", group: G08, stratum: 2, atom: AsyncNative, status: Core, definition: "Imported off-chain value." },
    Tp -> { id: "E029", name: "Time-weighted price", group: G08, stratum: 2, atom: AsyncRepairable, status: Core, definition: "Cumulative-price accumulator over a window." },
    Oa -> { id: "E030", name: "Optimistic assertion oracle", group: G08, stratum: 2, atom: AsyncNative, status: Core, definition: "Assert-then-dispute escalation game." },
    At -> { id: "E031", name: "Reserve / NAV attestation", group: G08, stratum: 2, atom: AsyncNative, status: Core, definition: "A named party's statement about backing or value." },
    Sr -> { id: "E032", name: "Streaming accrual", group: G09, stratum: 2, atom: AsyncNative, status: Core, definition: "Continuous per-second transfer from escrow." },
    Ep -> { id: "E033", name: "Epoch-gated transition", group: G09, stratum: 2, atom: AsyncNative, status: Core, definition: "Snapshot, cutoff, rollover." },
    Wq -> { id: "E034", name: "Withdrawal queue", group: G09, stratum: 2, atom: AsyncNative, status: Core, definition: "Request now, claim later, against future asset availability." },
    Em -> { id: "E035", name: "Protocol-funded emissions", group: G10, stratum: 2, atom: AsyncNative, status: Core, definition: "Newly issued tokens paid for measured actions." },
    Fd -> { id: "E058", name: "Surplus & fee distribution", group: G10, stratum: 2, atom: AsyncNative, status: Candidate, definition: "The rule naming the residual claimant of fees, spread and surplus." },
    Tg -> { id: "E036", name: "Delayed-governance execution", group: G11, stratum: 4, atom: AsyncNative, status: Core, definition: "A timelock between authorization and executability." },
    Up -> { id: "E037", name: "Mutable implementation proxy", group: G11, stratum: 4, atom: AsyncNative, status: Core, definition: "Code replacement changes the reachable state machine." },
    Gp -> { id: "E038", name: "Guardian or pause", group: G11, stratum: 4, atom: AsyncNative, status: Core, definition: "Bounded suppression of reachable transitions." },
    Au -> { id: "E050", name: "Delegated execution scope", group: G11, stratum: 4, atom: AsyncNative, status: Core, definition: "Persistent policy bounding the calls, assets, destinations, values, chains and time windows a delegate may reach." },
    Gs -> { id: "E051", name: "Sponsored-fee liability", group: G11, stratum: 3, atom: AsyncNative, status: Candidate, definition: "A conditional fee liability with metering and reimbursement." },
    Xm -> { id: "E041", name: "Cross-domain message verification", group: G12, stratum: 4, atom: AsyncNative, status: Core, definition: "Decide whether a source-domain assertion is acceptable at the destination." },
    Xf -> { id: "E042", name: "Cross-domain asset transfer", group: G12, stratum: 4, atom: AsyncNative, status: Core, definition: "Create a destination claim against an explicit source debit." },
    Rl -> { id: "E053", name: "Resource lock / reservation", group: G12, stratum: 4, atom: AsyncNative, status: Candidate, definition: "Enforceable pre-commitment with exclusivity, expiry, fulfillment and release." },
    Of -> { id: "E054", name: "Optimistic fill & reimbursement", group: G12, stratum: 4, atom: AsyncNative, status: Candidate, definition: "A filler advances destination value before finality and holds a contingent reimbursement claim." },
    Rd -> { id: "E043", name: "Direct redemption right", group: G13, stratum: 3, atom: AsyncRepairable, status: Core, definition: "Redeem a liability against backing at a defined rate." },
    Ps -> { id: "E044", name: "Peg-swap module", group: G13, stratum: 3, atom: AsyncNative, status: Core, definition: "1:1 reserve-backed swap with mint/burn authority." },
    As -> { id: "E045", name: "Algorithmic supply adjustment", group: G13, stratum: 3, atom: AsyncNative, status: Core, definition: "Supply expansion/contraction driven by measured price." },
    Aw -> { id: "E046", name: "Permission / identity gate", group: G14, stratum: 2, atom: AsyncNative, status: Core, definition: "Credential-checked eligibility." },
    Sb -> { id: "E047", name: "Shielded-balance state", group: G14, stratum: 2, atom: AsyncRepairable, status: Core, definition: "Commitments and nullifiers hide ownership." },
    Sd -> { id: "E048", name: "Selective-disclosure proof", group: G14, stratum: 2, atom: AsyncNative, status: Candidate, definition: "Prove a policy predicate without revealing the underlying credential." },
    Fz -> { id: "E056", name: "Freeze / forced transfer", group: G14, stratum: 2, atom: AsyncNative, status: Candidate, definition: "Issuer- or authority-initiated immobilisation or reassignment of a holder claim without holder authorisation." },
    Rs -> { id: "E049", name: "Restaking / shared security", group: G15, stratum: 4, atom: AsyncNative, status: Candidate, definition: "Slashable capital reused to secure additional services." },
    Vl -> { id: "E059", name: "Staking & validator lifecycle", group: G16, stratum: 3, atom: AsyncNative, status: Candidate, definition: "Delegation, activation, exit, reward accrual and penalty attribution for consensus-securing capital." }
  )

  pure val laws: Set[Law] = Set(
    { id: "L1", raw: "(Pl|Im|Cd|Pf|Op) → (Ex|Tp|At) + Ct + (Li|Ad|Sl|Bs)", subjects: Set(Pl, Im, Cd, Pf, Op), terms: Set(Set(Ex, Tp, At), Set(Ct), Set(Li, Ad, Sl, Bs)), externalTerms: 0, mixedTerms: 0, asyncRepairable: false, unsupportedSubject: false },
    { id: "L2", raw: "Pl → (Sh|Ix) + exit-liquidity", subjects: Set(Pl), terms: Set(Set(Sh, Ix)), externalTerms: 1, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false },
    { id: "L3", raw: "Uc → Aw + At{subject=borrower-financials} + (Bs|Tr) + obligor", subjects: Set(Uc), terms: Set(Set(Aw), Set(At), Set(Bs, Tr)), externalTerms: 1, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false },
    { id: "L4", raw: "Pf → Ex + Ct + Li + (Ad|Sl|Bs)", subjects: Set(Pf), terms: Set(Set(Ex), Set(Ct), Set(Li), Set(Ad, Sl, Bs)), externalTerms: 0, mixedTerms: 0, asyncRepairable: false, unsupportedSubject: false },
    { id: "L5", raw: "Py → (Sh|Ix|Rb) + Ep + Rd", subjects: Set(Py), terms: Set(Set(Sh, Ix, Rb), Set(Ep), Set(Rd)), externalTerms: 0, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false },
    { id: "L6", raw: "Tr → (Sv | mechanical trigger) + declared seniority + dispute forum + recovery-timing assumption", subjects: Set(Tr), terms: Set(Set(Sv)), externalTerms: 3, mixedTerms: 1, asyncRepairable: false, unsupportedSubject: false },
    { id: "L7", raw: "Cd → Rd | Ps | liquidation capacity", subjects: Set(Cd), terms: Set(Set(Rd, Ps)), externalTerms: 0, mixedTerms: 1, asyncRepairable: true, unsupportedSubject: false },
    { id: "L8", raw: "Xf → Xm | named custodian, plus a global claim ledger", subjects: Set(Xf), terms: Set(Set(Xm)), externalTerms: 0, mixedTerms: 1, asyncRepairable: true, unsupportedSubject: false },
    { id: "L9", raw: "Xf → debit(source) = credit(destination)", subjects: Set(Xf), terms: Set(), externalTerms: 1, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false },
    { id: "L10", raw: "Sb → proof verifier + nullifier set", subjects: Set(Sb), terms: Set(), externalTerms: 2, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false },
    { id: "L11", raw: "Sd → credential source + verifier + revocation", subjects: Set(Sd), terms: Set(), externalTerms: 3, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false },
    { id: "L12", raw: "In → signed constraints + settlement verifier + (solver|fallback) + timeout", subjects: Set(In), terms: Set(), externalTerms: 4, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false },
    { id: "L13", raw: "Ex → freshness validation; Gp preferred for high-value obligations", subjects: Set(Ex), terms: Set(), externalTerms: 1, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false },
    { id: "L14", raw: "illiquid backing → Wq | bounded liquidity reserve", subjects: Set(), terms: Set(Set(Wq)), externalTerms: 0, mixedTerms: 1, asyncRepairable: true, unsupportedSubject: true },
    { id: "L15", raw: "Up → Tg | bounded emergency process", subjects: Set(Up), terms: Set(Set(Tg)), externalTerms: 0, mixedTerms: 1, asyncRepairable: true, unsupportedSubject: false },
    { id: "L16", raw: "Aw → transfer-time enforcement where eligibility follows the holder", subjects: Set(Aw), terms: Set(), externalTerms: 1, mixedTerms: 0, asyncRepairable: false, unsupportedSubject: false },
    { id: "L17", raw: "Au → bounded scope + revocation + expiry + nonce/domain separation", subjects: Set(Au), terms: Set(), externalTerms: 4, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false },
    { id: "L18", raw: "Xm → explicit finality + chain/domain binding + replay protection", subjects: Set(Xm), terms: Set(), externalTerms: 3, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false },
    { id: "L19", raw: "Of → Xm + Xf + (Bs|Sl) + timeout", subjects: Set(Of), terms: Set(Set(Xm), Set(Xf), Set(Bs, Sl)), externalTerms: 1, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false },
    { id: "L20", raw: "Rl → Au + single-spend + expiry + fulfillment proof + release", subjects: Set(Rl), terms: Set(Set(Au)), externalTerms: 4, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false },
    { id: "L21", raw: "Gs → Au + metering + fee settlement", subjects: Set(Gs), terms: Set(Set(Au)), externalTerms: 2, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false },
    { id: "L22", raw: "Rs → attributed slash condition + non-reflexive capital + loss waterfall", subjects: Set(Rs), terms: Set(), externalTerms: 3, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false },
    { id: "L23", raw: "Sq → Xm + independent settlement finality", subjects: Set(), terms: Set(Set(Xm)), externalTerms: 1, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: true },
    { id: "L24", raw: "(In|Rf|Ba) → an explicit informational edge with a catalog tag", subjects: Set(In, Rf, Ba), terms: Set(), externalTerms: 1, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false },
    { id: "L25", raw: "wrapped cross-domain collateral → haircut + cap + independent exit", subjects: Set(), terms: Set(), externalTerms: 3, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: true },
    { id: "L26", raw: "Aw + Xf → destination-enforced eligibility + revocation propagation + jurisdictional binding", subjects: Set(), terms: Set(), externalTerms: 3, mixedTerms: 0, asyncRepairable: false, unsupportedSubject: true },
    { id: "L27", raw: "At → named attester + independence + stated assurance + staleness bound + recourse", subjects: Set(At), terms: Set(), externalTerms: 5, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false },
    { id: "L28", raw: "Fz → named authority + enumerated triggers + appeal path + holder disclosure", subjects: Set(Fz), terms: Set(), externalTerms: 4, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false },
    { id: "L29", raw: "(In|Ba|Rf|Of) → a declared surplus-allocation rule naming the residual claimant", subjects: Set(In, Ba, Rf, Of), terms: Set(), externalTerms: 1, mixedTerms: 0, asyncRepairable: true, unsupportedSubject: false }
  )

  pure val protocols: Set[ProtocolDefinition] = Set(
    { id: "aave", name: "Aave v3", elements: Set(Pl, Ix, Ct, Ex, Li, Bs, Im, Up, Tg, Gp), dead: false },
    { id: "uniswapv3", name: "Uniswap v3", elements: Set(Sh, Cl, Tp, Fl), dead: false },
    { id: "maker", name: "Maker / Sky", elements: Set(Cd, Ix, Ct, Ex, Li, Ps, Sh, Up, Tg, Gp), dead: false },
    { id: "liquity", name: "Liquity v1", elements: Set(Cd, Ct, Ex, Li, Rd, Bs), dead: false },
    { id: "gmx", name: "GMX v2", elements: Set(Sh, Pm, Ex, Pf, Ct, Li, Bs, Sl), dead: false },
    { id: "lido", name: "Lido v2", elements: Set(Rb, Ex, Wq, Up, Gp), dead: false },
    { id: "cow", name: "CoW Protocol", elements: Set(In, Ba, Ag, Rf), dead: false },
    { id: "cctp", name: "CCTP v2 Fast", elements: Set(Au, Xm, Xf, Of), dead: false },
    { id: "centrifuge", name: "Centrifuge", elements: Set(Uc, Ft, Tr, Sh, At, Aw, Wq, Xm), dead: false },
    { id: "terra", name: "Terra / Anchor", elements: Set(As, Rd, Ex, Pl, Ix, Em), dead: true },
    { id: "mango", name: "Mango Markets", elements: Set(Ob, Pf, Pl, Ct, Ex, Li), dead: true },
    { id: "euler", name: "Euler v1", elements: Set(Pl, Ix, Ct, Ex, Li, Fl, Up), dead: true }
  )

  pure val hazards: Set[Hazard] = Set(
    { id: "X1", family: "X1", raw: "As + reflexive junior token, with no hard redemption or exogenous capital", elements: Set(As), cls: Forbidden, polarity: ExternalQualified },
    { id: "X2", family: "X2", raw: "Fl* + manipulable Cp/Cl price + Pl/Cd, where manipulation cost < position value", elements: Set(Fl, Cp, Cl, Pl, Cd), cls: Elevated, polarity: MixedQualified },
    { id: "X3", family: "X3", raw: "Protocol token as collateral AND oracle market AND backstop", elements: Set(), cls: Elevated, polarity: ExternalQualified },
    { id: "X4", family: "X4", raw: "Rb into a balance-invariant ledger with no adapter", elements: Set(Rb), cls: Forbidden, polarity: ExternalQualified },
    { id: "X5", family: "X5", raw: "Illiquid backing + uncapped instant par redemption", elements: Set(), cls: Elevated, polarity: ExternalQualified },
    { id: "X6", family: "X6", raw: "Borrowable voting power + immediate execution", elements: Set(), cls: Elevated, polarity: ExternalQualified },
    { id: "X7", family: "X7", raw: "Cross-domain mint whose verifier is present but unproven correct", elements: Set(), cls: Elevated, polarity: ExternalQualified },
    { id: "X8", family: "X8", raw: "Shared collateral across nominally isolated markets", elements: Set(), cls: Elevated, polarity: ExternalQualified },
    { id: "X9", family: "X9", raw: "Up with immediate single-key control", elements: Set(Up), cls: Elevated, polarity: ExternalQualified },
    { id: "X10", family: "X10", raw: "Pm with a stale reference and unrestricted inventory", elements: Set(Pm), cls: Elevated, polarity: ExternalQualified },
    { id: "X11a", family: "X11", raw: "Uc with no Aw, At, collateral or reputation", elements: Set(Uc, Aw, At), cls: Forbidden, polarity: NegativeNamed },
    { id: "X11b", family: "X11", raw: "Uc with all of them and weak underwriting", elements: Set(Uc), cls: Elevated, polarity: ExternalQualified },
    { id: "X12", family: "X12", raw: "Lock-mint wrapped asset as canonical collateral whose value at risk exceeds the bridge's economic security", elements: Set(), cls: Forbidden, polarity: ExternalQualified },
    { id: "X13", family: "X13", raw: "External-validator Xm securing value exceeding slashable stake", elements: Set(Xm), cls: Elevated, polarity: ExternalQualified },
    { id: "X14", family: "X14", raw: "Exclusive market structure plus a price-improvement claim with no named benchmark", elements: Set(), cls: Unverifiable, polarity: ExternalQualified },
    { id: "X15", family: "X15", raw: "Rs securing a bridge mostly with assets issued by that bridge", elements: Set(Rs), cls: Elevated, polarity: ExternalQualified },
    { id: "X16", family: "X16", raw: "Unbounded delegated authority, or unlimited token approvals", elements: Set(), cls: Elevated, polarity: ExternalQualified },
    { id: "X17", family: "X17", raw: "Passive protocol-token reserve backing protocol-token collateral", elements: Set(), cls: Elevated, polarity: ExternalQualified },
    { id: "X18", family: "X18", raw: "Oa as sole truth for high-frequency liquidation", elements: Set(Oa), cls: Elevated, polarity: ExternalQualified },
    { id: "X19", family: "X19", raw: "Restricted claim bridged via Xf into a representation with no destination-side Aw", elements: Set(Xf, Aw), cls: Forbidden, polarity: NegativeNamed }
  )

  pure val hazardFamilies: Set[str] = hazards.map(hazard => hazard.family)

  // This projection matches the TypeScript engine. It is not a semantic
  // interpretation of negative or externally qualified hazard prose.
  pure val projectedHazards: Set[Hazard] =
    hazards.filter(hazard => hazard.elements.size() >= 2)

  pure def projectedHazardArmed(hazard: Hazard, protocol: Set[Element]): bool =
    hazard.elements.subseteq(protocol)

  pure def hazardFree(protocol: Set[Element]): bool =
    projectedHazards.forall(hazard => not(projectedHazardArmed(hazard, protocol)))

  // X11a's element-only necessary condition, with source polarity restored.
  // Collateral and reputation remain outside the vocabulary.
  pure def x11aCoreFree(protocol: Set[Element]): bool =
    not(protocol.contains(Uc) and not(protocol.contains(Aw)) and not(protocol.contains(At)))

  pure val crossDomainElements: Set[Element] =
    allElements.filter(element => elementAttributes.get(element).group == G12)

  // HYPOTHESIS: a flat element set cannot scope Fl to one settlement domain.
  pure def atomicScopeConsistent(protocol: Set[Element]): bool =
    not(protocol.contains(Fl) and protocol.intersect(crossDomainElements).size() > 0)

  // HYPOTHESIS: a dependency should not have a deeper hand stratum than
  // the subject that requires it.
  pure def stratumMonotone(protocol: Set[Element]): bool =
    laws.forall(law =>
      law.subjects.intersect(protocol).forall(subject =>
        law.terms.forall(term =>
          term.intersect(protocol).exists(required =>
            elementAttributes.get(required).stratum <= elementAttributes.get(subject).stratum))))

  pure def lawFires(law: Law, protocol: Set[Element]): bool =
    law.subjects.intersect(protocol).size() > 0

  pure def lawSatisfied(law: Law, protocol: Set[Element]): bool =
    not(lawFires(law, protocol)) or
      law.terms.forall(term => term.intersect(protocol).size() > 0)

  pure def firedLaws(protocol: Set[Element]): Set[Law] =
    laws.filter(law => lawFires(law, protocol))

  pure def violatedLaws(protocol: Set[Element]): Set[Law] =
    laws.filter(law => lawFires(law, protocol) and not(lawSatisfied(law, protocol)))

  pure def satisfiesClosure(protocol: Set[Element]): bool =
    laws.forall(law => lawSatisfied(law, protocol))

  // Meta-safety: every fired requirement is expressible with element terms.
  // This does not claim that the resulting protocol is financially safe.
  pure def requirementsFullyExpressible(protocol: Set[Element]): bool =
    firedLaws(protocol).forall(law => law.externalTerms == 0 and law.mixedTerms == 0)
}

module rawAssembly {
  import atlas.*

  const UNIVERSE: Set[Element]
  var chosen: Set[Element]

  action init: bool = chosen' = Set()

  action addElement(element: Element): bool = all {
    UNIVERSE.contains(element),
    not(chosen.contains(element)),
    chosen' = chosen.union(Set(element)),
  }

  action addOne: bool = {
    nondet element = UNIVERSE.oneOf()
    addElement(element)
  }

  action step: bool = addOne

  val closure: bool = satisfiesClosure(chosen)
  val hazardFreeState: bool = hazardFree(chosen)
  val atomicScopeSafety: bool = atomicScopeConsistent(chosen)
  val stratumSafety: bool = stratumMonotone(chosen)
  val machineCheckableSafety: bool = requirementsFullyExpressible(chosen)
  val nonemptyAssembly: bool = chosen.size() > 0
}

module rawFull {
  import atlas.*
  import rawAssembly(UNIVERSE = allElements).*
}

module legalAssembly {
  import atlas.*

  const UNIVERSE: Set[Element]
  var chosen: Set[Element]

  action init: bool = chosen' = Set()

  action addLegal(element: Element): bool = {
    val candidate = chosen.union(Set(element))
    all {
      UNIVERSE.contains(element),
      not(chosen.contains(element)),
      satisfiesClosure(candidate),
      hazardFree(candidate),
      chosen' = candidate,
    }
  }

  action step: bool = {
    nondet element = UNIVERSE.oneOf()
    addLegal(element)
  }

  val closure: bool = satisfiesClosure(chosen)
  val hazardFreeState: bool = hazardFree(chosen)
  val legal: bool = closure and hazardFreeState
  val atomicScopeSafety: bool = atomicScopeConsistent(chosen)
  val stratumSafety: bool = stratumMonotone(chosen)
  val machineCheckableSafety: bool = requirementsFullyExpressible(chosen)
  val nonemptyAssembly: bool = chosen.size() > 0
  val undercollateralizedCreditReached: bool = chosen.contains(Uc)
}

module legalFull {
  import atlas.*
  import legalAssembly(UNIVERSE = allElements).*
}

// Small concrete instances make counterexample searches reproducible.
module rawPooledLending {
  import atlas.*
  import rawAssembly(UNIVERSE = Set(Pl)).*
}

module rawReversedX19 {
  import atlas.*
  import rawAssembly(UNIVERSE = Set(Xm, Xf, Aw)).*
}

module legalExpressibilityReduced {
  import atlas.*
  import legalAssembly(UNIVERSE = Set(Ex)).*
}

module legalAtomicityReduced {
  import atlas.*
  import legalAssembly(UNIVERSE = Set(Fl, Xm)).*
}

module legalStratumReduced {
  import atlas.*
  import legalAssembly(UNIVERSE = Set(Au, Gs)).*
}

module legalCreditProjectionReduced {
  import atlas.*
  import legalAssembly(UNIVERSE = Set(Bs, Uc, Aw, At)).*
}

module reflexiveLoop {
  const HAS_EXOGENOUS_CAPITAL: bool

  type PegPhase = Healthy | Depegged | Spiraling | Collapsed | Recovered
  type ReflexiveState = {
    phase: PegPhase,
    supply: int,
    backing: int,
  }

  var reflexiveState: ReflexiveState

  action init: bool =
    reflexiveState' = { phase: Healthy, supply: 1, backing: 2 }

  action shock: bool = all {
    reflexiveState.phase == Healthy,
    reflexiveState' = { ...reflexiveState, phase: Depegged },
  }

  action endogenousDefense: bool = all {
    reflexiveState.phase == Depegged or reflexiveState.phase == Spiraling,
    reflexiveState' = if (reflexiveState.phase == Depegged)
      { phase: Spiraling, supply: reflexiveState.supply + 1, backing: reflexiveState.backing - 1 }
    else
      { phase: Collapsed, supply: reflexiveState.supply + 1, backing: reflexiveState.backing - 1 },
  }

  action recover: bool = all {
    HAS_EXOGENOUS_CAPITAL,
    reflexiveState.phase != Healthy,
    reflexiveState.phase != Recovered,
    reflexiveState' = { phase: Recovered, supply: reflexiveState.supply, backing: 2 },
  }

  action stayTerminal: bool = all {
    reflexiveState.phase == Collapsed or reflexiveState.phase == Recovered,
    reflexiveState' = reflexiveState,
  }

  action step: bool = any {
    shock,
    endogenousDefense,
    recover,
    stayTerminal,
  }

  val depegReached: bool = reflexiveState.phase != Healthy
  val distressed: bool =
    reflexiveState.phase == Depegged or
    reflexiveState.phase == Spiraling or
    reflexiveState.phase == Collapsed
  val collapseReached: bool = reflexiveState.phase == Collapsed
  val recovered: bool = reflexiveState.phase == Recovered
  val backingNonnegative: bool = reflexiveState.backing >= 0

  temporal eventualRecovery: bool =
    always(distressed.implies(eventually(recovered)))

  temporal eventualRecoveryUnderFairness: bool =
    recover.weakFair(Set(reflexiveState)).implies(eventualRecovery)

  temporal reflexiveNoRecovery: bool =
    always(distressed.implies(not(eventually(recovered))))
}

module reflexiveClosed {
  import reflexiveLoop(HAS_EXOGENOUS_CAPITAL = false).*
}

module reflexiveCapitalized {
  import reflexiveLoop(HAS_EXOGENOUS_CAPITAL = true).*
}
