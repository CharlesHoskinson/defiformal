# Graph Report - /root/DefiElements/corpus  (2026-08-04)

## Corpus Check
- Corpus is ~31,832 words - fits in a single context window. You may not need a graph.

## Summary
- 421 nodes · 1029 edges · 19 communities (17 shown, 2 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 90 edges (avg confidence: 0.91)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Table B Core Element Set
- Table A Elements and Molecules
- Atomicity, Catalysts and Pricing Isotopes
- Failure Overlay and Operational Residue
- Cross-Domain Settlement and Amendments
- Reflexivity and Toxic Bonds
- Conservation Law and the Trilemma
- CAKE Designs and the Solver Layer
- Authority and Delegated Execution
- Resource Locks and Unified Balances
- Optimistic Fill and Token-Anointed Bridges
- Bond Typology and Interface Standards
- Provisional and Uncertain Elements
- Reconciliation Ledgers
- Restaking and Shared Security
- Shared Sequencing
- Epistemic Status of the Table
- Everclear Netting Molecule
- Wormhole Bridge Molecule

## God Nodes (most connected - your core abstractions)
1. `Periodic Table of DeFi (Table B, 48 core elements)` - 105 edges
2. `Periodic Table of DeFi (Table A, ~46 elements)` - 80 edges
3. `CAKE + Periodic Table unification (GPT)` - 45 edges
4. `CAKE + Periodic Table unification (Claude)` - 44 edges
5. `Molecule - deployed protocol as element formula` - 31 edges
6. `Ex - external data oracle` - 21 edges
7. `P3 - contingent obligation, solvency, risk transfer` - 19 edges
8. `Sh - pro-rata share accounting` - 19 edges
9. `Ct - collateral-threshold solvency test` - 18 edges
10. `AMM - spot-AMM invariant` - 16 edges

## Surprising Connections (you probably didn't know these)
- `Periodic Table of DeFi (Table A, ~46 elements)` --semantically_similar_to--> `Periodic Table of DeFi (Table B, 48 core elements)`  [INFERRED] [semantically similar]
  elementsdefi.md → elementsdefiGPT.md
- `Trust-surface period ordering` --semantically_similar_to--> `Minimum dependency depth (period axis)`  [INFERRED] [semantically similar]
  elementsdefi.md → elementsdefiGPT.md
- `Molecule - deployed protocol as element formula` --semantically_similar_to--> `Near-isomers and discriminative tests`  [INFERRED] [semantically similar]
  elementsdefi.md → elementsdefiGPT.md
- `Eight flagged-uncertain elements` --semantically_similar_to--> `Eight provisional candidates outside closure`  [INFERRED] [semantically similar]
  elementsdefi.md → elementsdefiGPT.md
- `AMM - spot-AMM invariant` --semantically_similar_to--> `Cp - constant-product invariant`  [INFERRED] [semantically similar]
  elementsdefi.md → elementsdefiGPT.md

## Hyperedges (group relationships)
- **DISPUTE: period axis - trust surface vs dependency depth** — elementsdefi_trust_surface_ordering, elementsdefigpt_minimum_dependency_depth, cakeclaude_reconciliation_ledger_24_rows, cakegpt_reconciliation_ledger_23_rows [EXTRACTED 1.00]
- **DISPUTE: is informational a fourth bond type?** — cakeclaude_informational_bond_rejected, cakegpt_informational_bond_accepted, cakeclaude_layer_solver [EXTRACTED 1.00]
- **DISPUTE: should Xm split by trust domain?** — cakeclaude_xm_split_three_ways, cakegpt_xm_should_not_split_yet, elementsdefigpt_element_xm [EXTRACTED 1.00]
- **DISPUTE: is constant sum an element or an isotope?** — elementsdefi_element_csm, elementsdefigpt_demotion_constant_sum, cakeclaude_element_csm [EXTRACTED 1.00]
- **DISPUTE: how many new elements does CAKE contribute (4 vs 6)?** — cakeclaude_element_dx, cakeclaude_element_sk, cakegpt_element_au, cakegpt_element_ua, cakegpt_element_sq, cakegpt_element_of [EXTRACTED 1.00]
- **DISPUTE: is atomic composability a catalyst, condition, or spectrum?** — elementsdefi_element_atom, elementsdefigpt_atomic_composability_environmental, cakeclaude_atomicity_spectrum, cakegpt_atomicity_spectrum [EXTRACTED 1.00]
- **DISPUTE: does DeFi have a conservation law?** — elementsdefi_no_conservation_law, elementsdefigpt_conservation_law_xf, cakeclaude_topology_h7_conservation_law, cakegpt_conservation_value_invariant [EXTRACTED 1.00]
- **DISPUTE: is reflexivity a master predictor or a hypothesis?** — elementsdefi_reflexivity_master_predictor, elementsdefigpt_reflexivity_hypothesis, cakeclaude_cross_domain_reflexivity_hypothesis, cakegpt_trust_domain_cycle [EXTRACTED 1.00]
- **DISPUTE: is concentrated liquidity an element or an isotope?** — elementsdefi_element_amm, elementsdefigpt_element_cl [EXTRACTED 1.00]
- **DISPUTE: is health factor an element or a derived observation?** — elementsdefi_element_hf, elementsdefigpt_demotion_health_factor, elementsdefigpt_element_ct [EXTRACTED 1.00]
- **DISPUTE: are Wormhole and Nomad residue or Xm defects?** — elementsdefi_failure_cat_d_outside_table, elementsdefigpt_failure_cat_a_defective_instance, elementsdefigpt_incident_wormhole, elementsdefigpt_incident_nomad, elementsdefi_incident_wormhole_hack [EXTRACTED 1.00]
- **DISPUTE: how big is the post-unification residue?** — elementsdefi_residue_one_third, cakeclaude_residue_inverts_by_dollar, cakegpt_residue_zero_to_four_of_24 [EXTRACTED 1.00]
- **DISPUTE: is restaking a novel element?** — elementsdefi_element_rs, cakeclaude_element_rs, cakegpt_element_rs [EXTRACTED 1.00]
- **DISPUTE: how many elements are there (46 / 48 / 52 / 55)?** — elementsdefi_periodic_table_a, elementsdefigpt_periodic_table_b, cakeclaude_unification_claude, cakegpt_unification_gpt [EXTRACTED 1.00]
- **DISPUTE: is the cross-chain trilemma a law?** — cakeclaude_trilemma_soft_tradeoff, cakegpt_topology_h7_invariant, cakeclaude_zamyatin_impossibility [EXTRACTED 1.00]
- **DISPUTE: does the object still deserve the name periodic table?** — elementsdefi_periodic_law_does_not_hold, elementsdefigpt_empirical_closure_claim, cakeclaude_unification_claude, cakegpt_unification_gpt [EXTRACTED 1.00]
- **Authority/Permission cluster contributed by CAKE** — cakeclaude_element_dx, cakeclaude_element_gs, cakeclaude_element_rl, cakeclaude_element_sk, cakegpt_element_au, cakegpt_element_gs, cakegpt_element_rl, cakegpt_element_ua [INFERRED 0.85]
- **Reflexivity evidence chain across all four documents** — elementsdefi_reflexivity_master_predictor, elementsdefi_forbidden_f1_endogenous_collateral, elementsdefi_incident_terra_collapse, elementsdefi_incident_mango_exploit, elementsdefigpt_reflexivity_hypothesis, cakeclaude_cross_domain_reflexivity_hypothesis, cakegpt_trust_domain_cycle [EXTRACTED 1.00]

## Communities (19 total, 2 thin omitted)

### Community 0 - "Table B Core Element Set"
Cohesion: 0.06
Nodes (96): DISPUTE: is health factor an element or a derived observation?, OrO - optimistic oracle, PoR - proof of reserve, STR - streaming/dripping, Application-stack layer rejected as row axis, Supply-conservation rule: debit(source) = credit(destination), Corpus of 101 protocol-version units, Health factor demoted to derived observation of Ct (+88 more)

### Community 1 - "Table A Elements and Molecules"
Cohesion: 0.05
Nodes (94): Five-criterion atomicity test, Dependency depth rejected as period axis, ADL - auto-deleverage/socialized loss, AMM - spot-AMM invariant, CDP - collateralized debt position, EMI - emissions, HF - solvency-ratio check, IDA - index-based debt accrual (+86 more)

### Community 2 - "Atomicity, Catalysts and Pricing Isotopes"
Cohesion: 0.07
Nodes (45): Graduated atomicity spectrum (atom_dependency), DISPUTE: is atomic composability a catalyst, condition, or spectrum?, DISPUTE: is concentrated liquidity an element or an isotope?, DISPUTE: is constant sum an element or an isotope?, CSM - constant-sum market maker (restored from A), R1' - cross-domain leverage requires a finality assumption, Atomicity spectrum (six levels), Fl is the only async-impossible element (+37 more)

### Community 3 - "Failure Overlay and Operational Residue"
Cohesion: 0.08
Nodes (31): Bybit $1.5B signing/opsec failure (Feb 2025), DISPUTE: are Wormhole and Nomad residue or Xm defects?, DISPUTE: how big is the post-unification residue?, Hacken 2025: ~$2.12B / 54% access-control failures, Residue shrinks by count but inverts by dollar to opsec, TRM Labs 2026: $2.2B / 76% infrastructure attacks, Post-unification residue: 0-4 of 24 incidents, Category (a) defective element instance (+23 more)

### Community 4 - "Cross-Domain Settlement and Amendments"
Cohesion: 0.09
Nodes (24): Amendment register (10 changes), DISPUTE: how many elements are there (46 / 48 / 52 / 55)?, DISPUTE: should Xm split by trust domain?, Xm-ev - external-validator message verification, Xm-lc - light-client message verification, 14 empty cells with verdicts, CAKE Settlement layer, F2 - algorithmic stablecoin x reflexive collateral = radioactive (+16 more)

### Community 5 - "Reflexivity and Toxic Bonds"
Cohesion: 0.16
Nodes (21): Cross-domain reflexivity analogue (hypothesis), DISPUTE: is reflexivity a master predictor or a hypothesis?, Trust-domain cycle (cross-domain reflexivity), BC - bonding curve, PAB - peg-arbitrage mint/burn, Category (b) invalid bond between valid elements, F1 - endogenous collateral x peg mint/burn = TOXIC, F2 - spot AMM as oracle x leverage = UNSTABLE (+13 more)

### Community 6 - "Conservation Law and the Trilemma"
Cohesion: 0.16
Nodes (19): DISPUTE: does DeFi have a conservation law?, DISPUTE: is the cross-chain trilemma a law?, H7 - conservation law (winner, organizing principle), Cross-chain trilemma is a soft tradeoff, not a law, Zamyatin et al. - trustless CCC impossible without TTP, Executed authority is a subset of valid delegated scope, Provenance and meaning must not be silently mutated, Destination credit = verified debit + underwritten advance - fees - loss (+11 more)

### Community 7 - "CAKE Designs and the Solver Layer"
Cohesion: 0.14
Nodes (15): CAKE framework (Chiplunkar & Gosselin, Feb 2024), Ecosystem-aligned bridge (IBC Eureka, AggLayer), Exclusive batch auction (no pure production example), Solver price competition (UniswapX, Bungee), Solver speed competition (Across, Orbiter), Wallet-coordinated messaging (NEAR, Avocado), DISPUTE: is informational a fourth bond type?, ERC-7683 cross-chain intent standard (+7 more)

### Community 8 - "Authority and Delegated Execution"
Cohesion: 0.20
Nodes (12): Authority is a bond property, not a row, DISPUTE: how many new elements does CAKE contribute (4 vs 6)?, EIP-7702 set-code transaction (Pectra, May 2025), Dx - delegated execution scope (provisional, low), Sk - solver bonding / slashing (provisional, medium), CAKE Permission layer, R4 - delegated authority requires bounded scope, Key possession fails; enforceable transition policy passes (+4 more)

### Community 9 - "Resource Locks and Unified Balances"
Cohesion: 0.20
Nodes (12): Gs - gas sponsorship / paymaster (provisional, low-medium), Rl - resource lock / credible commitment (provisional, medium), CAKE neutrality discount (authors founded OneBalance), 55 elements = 48 from B + 1 restored + 6 from CAKE, E051 Gs - gas sponsorship obligation (high), E053 Rl - resource lock or reservation (medium-high), E052 Ua - enforceable unified-balance ledger (medium), ERC-7683 filler market (+4 more)

### Community 10 - "Optimistic Fill and Token-Anointed Bridges"
Cohesion: 0.24
Nodes (10): CCTP v2 fast transfer + hooks, Token-anointed bridge (CCTP v2, xERC20), E054 Of - optimistic fill and reimbursement (high), Liquidity bridge is Of+Xf, not an Xf isotope, Across, CCTP v2 Fast, CCTP v2 Standard, deBridge DLN (+2 more)

### Community 11 - "Bond Typology and Interface Standards"
Cohesion: 0.24
Nodes (10): Chemistry metaphor audit (40% load-bearing), Economic bond (incentive alignment), ERC-4626 tokenized vault standard (interface bond), ERC-7540 asynchronous redemption standard, Interface bond (ABI/call compatibility), Trust bond (shared assumptions), Economic bond, Interface bond (+2 more)

### Community 12 - "Provisional and Uncertain Elements"
Cohesion: 0.20
Nodes (10): Eight flagged-uncertain elements, Bc - bonding-curve issuance (provisional), Eight provisional candidates outside closure, Cg - credit delegation (provisional), Da - Dutch-auction descent (provisional), Ir - insurance reserve fund (provisional), Kg - credential-gated transfer (provisional), Tw - time-weighted AMM execution (provisional) (+2 more)

### Community 13 - "Reconciliation Ledgers"
Cohesion: 0.33
Nodes (7): DISPUTE: period axis - trust surface vs dependency depth, 13 genuine contradictions, 11 naming/convention differences, Reconciliation ledger (24 rows), 13 genuine contradictions, 9 modeling/naming conventions, Reconciliation ledger (23 rows)

### Community 14 - "Restaking and Shared Security"
Cohesion: 0.47
Nodes (6): DISPUTE: is restaking a novel element?, EigenLayer slashing live (Apr 2025, ELIP-002), RS - restaking / shared security (restored from A), E049 Rs - restaking / security reuse (medium), Rs requires attributed slash condition + non-reflexive capital, RS - restaking/rehypothecation

### Community 15 - "Shared Sequencing"
Cohesion: 0.50
Nodes (4): Xm-ss - shared-sequencer ordering (low confidence), E055 Sq - shared ordering commitment (medium), AggLayer, Sq requires Xm + independent settlement finality

### Community 16 - "Epistemic Status of the Table"
Cohesion: 0.67
Nodes (3): DISPUTE: does the object still deserve the name periodic table?, The periodic law does not hold, Closure is empirical against a stated corpus, not universal

## Knowledge Gaps
- **20 isolated node(s):** `FIBO financial industry business ontology`, `ISO 20022 message standard`, `Xu et al. SoK: DEX with AMM protocols`, `Bybit compromise ($1.5B)`, `FIBO ontology` (+15 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Periodic Table of DeFi (Table B, 48 core elements)` connect `Table B Core Element Set` to `Table A Elements and Molecules`, `Atomicity, Catalysts and Pricing Isotopes`, `Failure Overlay and Operational Residue`, `Cross-Domain Settlement and Amendments`, `Reflexivity and Toxic Bonds`, `Bond Typology and Interface Standards`, `Provisional and Uncertain Elements`, `Epistemic Status of the Table`?**
  _High betweenness centrality (0.498) - this node is a cross-community bridge._
- **Why does `Periodic Table of DeFi (Table A, ~46 elements)` connect `Table A Elements and Molecules` to `Table B Core Element Set`, `Atomicity, Catalysts and Pricing Isotopes`, `Failure Overlay and Operational Residue`, `Cross-Domain Settlement and Amendments`, `Reflexivity and Toxic Bonds`, `Conservation Law and the Trilemma`, `Bond Typology and Interface Standards`, `Provisional and Uncertain Elements`, `Restaking and Shared Security`, `Epistemic Status of the Table`?**
  _High betweenness centrality (0.404) - this node is a cross-community bridge._
- **Why does `DISPUTE: how many elements are there (46 / 48 / 52 / 55)?` connect `Cross-Domain Settlement and Amendments` to `Table B Core Element Set`, `Table A Elements and Molecules`, `Conservation Law and the Trilemma`?**
  _High betweenness centrality (0.342) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `Molecule - deployed protocol as element formula` (e.g. with `Near-isomers and discriminative tests` and `Money legos framing (open-ended, no closure)`) actually correct?**
  _`Molecule - deployed protocol as element formula` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `FIBO financial industry business ontology`, `ISO 20022 message standard`, `Xu et al. SoK: DEX with AMM protocols` to the rest of the system?**
  _20 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Table B Core Element Set` be split into smaller, more focused modules?**
  _Cohesion score 0.06337719298245614 - nodes in this community are weakly interconnected._
- **Should `Table A Elements and Molecules` be split into smaller, more focused modules?**
  _Cohesion score 0.05170441546556852 - nodes in this community are weakly interconnected._