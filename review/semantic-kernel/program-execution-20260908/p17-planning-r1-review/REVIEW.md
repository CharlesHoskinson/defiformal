# Independent P17 planning review r1

**CHANGES_REQUIRED.** Three bounded planning repairs are required before this concrete source/domain slice can be accepted. Source acquisition is adequate for the selected development-source scope. Strict OpenSpec validity and the author's structural controls pass, but they do not establish source-entry acceptance, source execution, or P17 platform reuse.

Reviewer: independent nonauthor GPT-6, stock Codex subagent `/root/p17_plan_review`. Requested family: GPT-6. This agent's runtime instructions identify GPT-6; no exact model alias/build or separate provider-returned identity is exposed to this subagent. Do not substitute an invented exact identity. Native author recovery identifies `grok-4.6-build`, session `01a084ca-957c-7b00-815f-c15fd32816c3`, 35 turns and `end_turn`; the shell process exit was not recovered. No Foreman, extra agents, production edits, or historical-evidence edits were used.

Candidate: `p17-planning-candidate-r1.tar.gz`, SHA-256 `000d48b5664a18ac3f4378f48bb150a51cf32427ff63d36d1dcf28e9cf1d72f1`, author base `2ad464397cd207bca647768d77d57abb1f8e575c`. Safe extraction and all 42 candidate file hashes/lengths match the adjacent frozen manifest. Candidate bytes still match after checks. Review outputs and execution controls are confined to this owned review directory.

## Required repairs

### R1 — The mandatory no-credit negative uses the wrong kernel predicate (high)

`proof-obligations.json:83–85` says that a post-world with minted shares/supply and unchanged vault USDS is “not e.Valid for the deposit template.” The same claim occurs in `fixtures.json`'s `P17-NEG-MINT-NO-CREDIT` and design prose.

The delivered `Typed.Evaluated.Valid` in `lean/DefiKernel/Typed/Transition.lean:190–197` has inputs store, context, request, **pre-state**, and evaluated effects. It has no candidate post-state input. Given one valid deposit evaluation and fixed pre-state, replacing a proposed output world cannot change `e.Valid`. The post-state equality is a separate conjunct of `execute_ok_iff` at lines 219–235.

Nor does generic accounting prohibit all share minting without USDS credit. Effects `USDS=0`, `sUSDS receiver=+s`, and `sUSDS supply=+s` satisfy `accountingOK` for each asset. With appropriate invoke/supply authority, guards, footprints and nonnegative balances, such a different registered template need not be refused by the kernel. Cross-asset backing comes from the selected deposit template/financial relation and its source observation, not from the generic accounting check alone.

**Repair:** state the negative against an explicit deposit postcondition or observation correspondence, with positive assets and fixed honest deposit template. Derive the actual vault USDS post-balance from `execute_ok_iff`; prove an unchanged-credit candidate cannot equal that result. Keep `e.Valid` for the executor's real preconditions, and distinguish rejection of an incorrect proposed observation from an executor refusal. Include a correct-deposit positive witness under the same premises. Do not change the delivered theorem or add a desired-postcondition assumption.

Evidence: `checks.json` records the actual delivered predicate text, absence of a post argument, and a small per-asset arithmetic illustration. That illustration is diagnostic, not a new Lean theorem or source execution.

### R2 — Freeze executable stateful witnesses and independent controls (high)

The fixture table contains correct conversion literals, but several designated success/control rows are not yet full stateful witnesses. `P17-MINT-D0` and `P17-WD-D0` have no pre-state at all. D1 rows generally omit funding, supply and allowance values. There is no common default pre-state or inheritance rule. `P17-DEP-D0` uses the unresolved allowance choice `max_or_assets`.

These omissions can change success into refusal: D1 mint needs `10^18+1` USDS, whereas reusing the only fully funded deposit sender gives `10^18`. A withdrawal/redeem with unfunded vault USDS fails at the external transfer. `P17-RED-D1`, named as an unaffected production-mutant control, omits vault funding and totalSupply. The captured source initializes `chi=RAY`; no selected setup step makes D1's stored `chi=RAY+1` with `ssr=RAY` and unchanged time. Poking storage can be a legitimate development harness assumption, but that method and its lack of protocol-reachability credit must be explicit.

**Repair:** supply a deterministic fixture-construction contract (shared defaults plus explicit overrides are sufficient) for every scored source row and protected control. Fix caller/party identities and alias rules, balances, totalSupply, relevant finite/infinite allowances, time and initialized state; state the expected post-state or a complete common transition rule. Bind the D1 setup method and classify any storage seeding. Preserve independently funded redeem controls when mutating `_mint`; deriving control funding by invoking a mutated deposit would defeat the advertised unaffectedness. Validate that the chosen inputs actually satisfy each declared success/refusal partition before implementation scoring. No broad new campaign is requested.

### R3 — Complete the source observation projection (medium)

`observation-contract.json:20–22`, `design.md` section 6 and the D0 fixture event arrays promise events in source order but omit the underlying USDS `Transfer`. In the captured `UsdsMock.sol`, `transferFrom` emits that event at line 132, and `transfer` emits it at line 106. A successful deposit therefore has `sUSDS.Drip`, `USDS.Transfer`, `sUSDS.Deposit`, `sUSDS.Transfer` in the full EVM log sequence. A redeem has `sUSDS.Drip`, `USDS.Transfer`, `sUSDS.Transfer`, `sUSDS.Withdraw`. The three-event arrays are valid only as an explicitly emitter-filtered sUSDS projection, which is not specified.

The selected external transfer also consumes finite `USDS.allowance[sender][vault]` at mock lines 116–123. The observation contract lists only sUSDS allowance and USDS balances, so it cannot compare that selected external authorization state or distinguish the two choices currently written as `max_or_assets`.

**Repair:** explicitly freeze either all relevant EVM logs or an emitter-address-bound vault-only projection, with exact ordered expectations; retain unrelated logs without treating them as equivalent vault events. Include the underlying allowance in the selected pre/post observation or expressly justify and narrow its exclusion. Resolve the finite/infinite branch in the fixtures. Keep the accepted refusal shape (retained supplied pre-state beside revert, no fabricated post-world); do not claim that merely retaining the supplied pre-state experimentally checks rollback.

## Platform reuse assessment and limits

The proposed token0 bridge is a permissible **model-only design direction**, not an independently established platform result. P15 explicitly permits a quote-derived Typed wrapper; the accepted program allows noncomposing interface/library reuse. `Typed.execute_ok_iff` is a delivered named theorem, and the selected rounding theorems are real delivered APIs. FullMath's checked wrapper already connects its result to `Arithmetic.Rounding.mulDiv`; vault floor/ceil can use those same contracts when its checked-product and positive-denominator premises hold. This is shared directed-conversion reasoning, not a shared proof of the token0 wrap-fallback or vault external asset movement.

The quote-register witness is nonzero: raw Q96 register value changes from `2^96` to `2^95`. It can exercise actual debit, supply authority, accounting, funding and footprint checks through the existing executor. The two-asset vault template exercises USDS conservation and sUSDS issuance through that same theorem. The register is synthetic; it is neither a Uniswap reserve nor source pool storage. Register mint/burn accounting proves no cash conservation or swap settlement. No sequential token0-to-vault composition is needed or justified.

For implementation acceptance, both adapters must construct their registered templates from the actual successful library results, explicitly bind the token0 pre-register to the input sqrt price, choose and prove a positive scale (`scale=1` means raw Q96 units, not an unscaled economic price), and derive the effect/post equations. Authority, funding, registry/context authenticity and finite-universe assumptions must be instantiated or recorded. A theorem simply assuming `e.Valid` and the desired output equality, an arbitrary quote unrelated to the library, or a hardcoded lone example would not demonstrate that bridge. R1 must be repaired so generic accounting is not confused with deposit backing.

The common engine remains only proposed. Shared child recording alone does not suffice: both source cases must execute through the same parameterized compile/prestate/observation/scoring engine while preserving the accepted P16 observations and fail-closed rules. Actual unchanged theorem instantiations for both cases, nonempty source campaigns and characteristic compiled mutations with unaffected controls, and the measured case-two inventory remain mandatory. `P17.platform_reuse=false` and the wider-family spending gate stay unchanged. Arithmetic-only evidence cannot open them. This review adds no P30 dependency.

## Checked scope

Read latest AGENTS, the semantic-kernel migration/progress context, defi-footguns and gate register, the queued P17 brief, PLAN-ACCEPTANCE and its editorial interpretations, P15 contracts/acceptance, P16 proof-recorder acceptance, accepted tasks 18.1–18.7, actual Typed/Composition/Arithmetic interfaces, main/L2 SUsds, and the captured mock external boundaries.

The pinned main source and its ten-key import closure match; the three mock hashes and six API file bindings match. The source-selected invalid-address, transfer balance/allowance and share allowance refusals are real. D0/D1 correctly exclude the accrual branch, positive chi excludes zero denominators, all four D1 arithmetic literals are correct, and the deposit overflow literal is the first amount whose RAY product does not fit uint256. Explicit mint overflow and burn supply premises correctly avoid taking the source comments as proved invariants. Source mutation sites are unique and characteristic. The source pin is adequate development material; it establishes no deployed identity.

Fresh validation: OpenSpec 1.10.0 strict exits 0; intact author diagnostics are 37/37 with 17 fixtures, two proposed mutants, 20 requirements, 27 scenarios and 23 unchecked tasks; empty corpus returns 3. An actual review-copy wrong-D1-literal control returns 1 and names `independent_P17-DEP-D1`. Independent `check.py` records 15 successful bounded checks, including finding probes. These counts are not source or production-mutation coverage. No Solidity/EVM campaign, Lean build/proof, production mutation or mainnet verification was executed here. Exact command outputs are retained without hiding stderr.

The compiler's Shanghai/no-metadata freeze is distinct from the old IPFS smoke; state roundtrip and concrete genesis binding remain implementation prerequisites. P16 source acceptance remains separate. All required repairs are planning-only and can be made in one focused native Grok revision; retain this r1 package and report unchanged.
