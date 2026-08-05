# Graph Report - 09-rwa  (2026-08-04)

## Corpus Check
- 3 files · ~37,765 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 121 nodes · 118 edges · 13 communities
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `6c07d92e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- 2. DESIGN
- 2. DESIGN
- Ondo Finance — USDY, OUSG, Ondo Global Markets (Ondo Stocks)
- USYC — Circle / Hashnote International Short Duration Yield Fund Ltd.
- Ondo Finance (USDY + OUSG + Ondo Global Markets)
- 5. RESIDUE CHECK
- 5. RESIDUE CHECK
- 4. EVIDENCE
- Circle USYC (Hashnote International Short Duration Yield Fund Ltd.)
- BlackRock BUIDL (BlackRock USD Institutional Digital Liquidity Fund Ltd., via Securitize)
- Maple Finance (syrupUSDC / syrupUSDT / syrupUSDG + institutional pools)
- Centrifuge (Centrifuge Protocol V3)
- 4. EVIDENCE

## God Nodes (most connected - your core abstractions)
1. `2. DESIGN` - 15 edges
2. `2. DESIGN` - 14 edges
3. `5. RESIDUE CHECK` - 9 edges
4. `5. RESIDUE CHECK` - 9 edges
5. `4. EVIDENCE` - 8 edges
6. `Ondo Finance (USDY + OUSG + Ondo Global Markets)` - 7 edges
7. `Circle USYC (Hashnote International Short Duration Yield Fund Ltd.)` - 7 edges
8. `BlackRock BUIDL (BlackRock USD Institutional Digital Liquidity Fund Ltd., via Securitize)` - 7 edges
9. `Maple Finance (syrupUSDC / syrupUSDT / syrupUSDG + institutional pools)` - 7 edges
10. `Centrifuge (Centrifuge Protocol V3)` - 7 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (13 total, 0 thin omitted)

### Community 0 - "2. DESIGN"
Cohesion: 0.13
Nodes (15): 2.10 Cross-chain — [ON-CHAIN] with a federated trust assumption, 2.11 Peg-swap module — [ON-CHAIN]. Ondo names it exactly., 2.12 Fund / SPV structure and jurisdiction, 2.13 Ondo Chain — **CANCELLED. Replaced by "Ondo Network" on 2026-07-27.**, 2.14 Flux Finance — **no longer Ondo-operated**, but the entity name persists, 2.1 Token contracts and transfer restrictions, 2.2 Freeze / forced transfer, 2.3 Pause / guardian — [ON-CHAIN] (+7 more)

### Community 1 - "2. DESIGN"
Cohesion: 0.14
Nodes (14): 2. DESIGN, Allowlist / KYC regime — [ON-CHAIN] enforcement over a [LEGAL] determination, Chains and how USYC gets there — [ON-CHAIN], Control plane — [ON-CHAIN], Fees — [LEGAL], Freeze / pause / burn powers — [ON-CHAIN], holder identified, NAV / price feed — [ON-CHAIN] publication of an [LEGAL]/off-chain determination, Register of record — [LEGAL] register, [ON-CHAIN] twin (+6 more)

### Community 2 - "Ondo Finance — USDY, OUSG, Ondo Global Markets (Ondo Stocks)"
Cohesion: 0.17
Nodes (11): 1.1 USDY, 1.2 OUSG, 1.3 Ondo Global Markets / Ondo Stocks (OGM), 1. WHAT IT DOES, 3.1 GitHub, 3.2 Do deployed contracts match the repo?, 3.3 Live on-chain magnitudes (Ethereum mainnet, `totalSupply()`, 2026-08-04), 3.4 Audits (+3 more)

### Community 3 - "USYC — Circle / Hashnote International Short Duration Yield Fund Ltd."
Cohesion: 0.20
Nodes (9): 1. WHAT IT DOES, 3. REPO, 6. NOTES FOR THE DELTA SECTION, Bottom line for the delta, Rank basis at 2026-08-04, Symbols the corpus omitted that the DESIGN arguably supports, The prior record is internally inconsistent before any evidence is considered, USYC — Circle / Hashnote International Short Duration Yield Fund Ltd. (+1 more)

### Community 4 - "Ondo Finance (USDY + OUSG + Ondo Global Markets)"
Cohesion: 0.22
Nodes (8): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, Ondo Finance (USDY + OUSG + Ondo Global Markets), Stage 1 research — RWA / tokenised treasuries & private credit

### Community 5 - "5. RESIDUE CHECK"
Cohesion: 0.22
Nodes (9): 5. RESIDUE CHECK, (a) "USDY is a secured note — a debt obligation of Ondo USDY LLC. Nothing in the vocabulary names the OBLIGOR or recourse.", (b) Security interest, collateral agent identity, perfection mechanism, (c) Bankruptcy remoteness — is it claimed, and by what structure?, (d) REGISTER OF RECORD — is the chain authoritative, or a mirror? **[the load-bearing question]**, (e) OUSG as a feeder routing into BUIDL and other MMFs — **CONFIRMED, with live allocations**, (f) The 40–50 day transfer lockup and its legal basis — **CONFIRMED HISTORICALLY, APPEARS SUPERSEDED**, (g) Off-chain cut-offs and T+n versus the atomic on-chain appearance — **CONFIRMED, and it is a genuine two-tier system** (+1 more)

### Community 6 - "5. RESIDUE CHECK"
Cohesion: 0.22
Nodes (9): 5. RESIDUE CHECK, (a) Teller → prime broker → T-bills + reverse repo; prime broker identity; reserve composition; repo counterparty exposure — **CONFIRMED, with one part UNKNOWN**, Anything else USYC does that the vocabulary has no name for, (b) REGISTER OF RECORD — **CONFIRMED, and the direction of the sentence is the finding**, (c) The obligor — **CONFIRMED as SDYF (Cayman); entity NOT renamed; creditor ranking effectively moot at FY2025**, (d) Instant-redemption capacity — **`Rd` as an unconditional right is REFUTED for USYC**, (e) The offering memorandum / subscription agreement — **NOT OBTAINABLE**, (f) Qualified custody and segregation from Circle's balance sheet — **SEGREGATION CONFIRMED; "QUALIFIED CUSTODY" REFUTED as a term** (+1 more)

### Community 7 - "4. EVIDENCE"
Cohesion: 0.25
Nodes (8): 4. EVIDENCE, Aggregators, GitHub (accessed 2026-08-04), On-chain, Ethereum mainnet (all reads 2026-08-04), Ondo archived documentation — Wayback Machine (snapshot 2025-10-13, accessed 2026-08-04), Ondo corporate site (accessed 2026-08-04), Ondo documentation — `docs.ondo.finance` (all accessed 2026-08-04), SEC EDGAR (accessed 2026-08-04)

### Community 8 - "Circle USYC (Hashnote International Short Duration Yield Fund Ltd.)"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, Circle USYC (Hashnote International Short Duration Yield Fund Ltd.)

### Community 9 - "BlackRock BUIDL (BlackRock USD Institutional Digital Liquidity Fund Ltd., via Securitize)"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, BlackRock BUIDL (BlackRock USD Institutional Digital Liquidity Fund Ltd., via Securitize)

### Community 10 - "Maple Finance (syrupUSDC / syrupUSDT / syrupUSDG + institutional pools)"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, Maple Finance (syrupUSDC / syrupUSDT / syrupUSDG + institutional pools)

### Community 11 - "Centrifuge (Centrifuge Protocol V3)"
Cohesion: 0.29
Nodes (7): 1. WHAT IT DOES, 2. DESIGN, 3. REPO, 4. EVIDENCE, 5. WHAT LOOKS UNNAMEABLE, 6. DELTA, Centrifuge (Centrifuge Protocol V3)

### Community 12 - "4. EVIDENCE"
Cohesion: 0.29
Nodes (7): 4. EVIDENCE, Group A — USYC documentation (`usyc.docs.hashnote.com`), raw Markdown, accessed 2026-08-04, Group B — Circle developer documentation, accessed 2026-08-04, Group C — SEC EDGAR, Circle Internet Group, Inc. (CIK 0001876042), accessed 2026-08-04, Group D — Circle pressroom, accessed 2026-08-04 (retrieved via stealth fetch; `www.circle.com` returns 403 to plain fetch), Group E — Live APIs and on-chain state, accessed 2026-08-04, Group F — Aggregator, used only where no primary source exists

## Knowledge Gaps
- **101 isolated node(s):** `1. WHAT IT DOES`, `2. DESIGN`, `3. REPO`, `4. EVIDENCE`, `5. WHAT LOOKS UNNAMEABLE` (+96 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Ondo Finance — USDY, OUSG, Ondo Global Markets (Ondo Stocks)` connect `Ondo Finance — USDY, OUSG, Ondo Global Markets (Ondo Stocks)` to `2. DESIGN`, `5. RESIDUE CHECK`, `4. EVIDENCE`?**
  _High betweenness centrality (0.101) - this node is a cross-community bridge._
- **Why does `USYC — Circle / Hashnote International Short Duration Yield Fund Ltd.` connect `USYC — Circle / Hashnote International Short Duration Yield Fund Ltd.` to `2. DESIGN`, `4. EVIDENCE`, `5. RESIDUE CHECK`?**
  _High betweenness centrality (0.081) - this node is a cross-community bridge._
- **Why does `Stage 1 research — RWA / tokenised treasuries & private credit` connect `Ondo Finance (USDY + OUSG + Ondo Global Markets)` to `Circle USYC (Hashnote International Short Duration Yield Fund Ltd.)`, `BlackRock BUIDL (BlackRock USD Institutional Digital Liquidity Fund Ltd., via Securitize)`, `Maple Finance (syrupUSDC / syrupUSDT / syrupUSDG + institutional pools)`, `Centrifuge (Centrifuge Protocol V3)`?**
  _High betweenness centrality (0.074) - this node is a cross-community bridge._
- **What connects `1. WHAT IT DOES`, `2. DESIGN`, `3. REPO` to the rest of the system?**
  _101 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `2. DESIGN` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `2. DESIGN` be split into smaller, more focused modules?**
  _Cohesion score 0.14285714285714285 - nodes in this community are weakly interconnected._