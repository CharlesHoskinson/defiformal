# Stage 1 research, round 2 — RWA / tokenised treasuries & private credit

**Category:** `09-rwa` · **Supplement to `01-research.md`, not a replacement.** All access dates **2026-08-04** unless stated; a few payload timestamps read 2026-08-05 UTC because the fetches straddled midnight UTC.

---

## WHAT ROUND ONE LEFT OPEN, AND WHAT THIS CLOSES

Round one's central negative was: *"not one offering memorandum, private placement memorandum, security agreement, control agreement, master loan agreement or LP agreement across all five applications was publicly reachable."* That statement **survives as to the instruments themselves** — I did not obtain a single offering document, subscription agreement or security agreement for any of the five. But it was **too pessimistic about the layer immediately above the instruments**, and this round reaches that layer through three routes round one did not use:

1. **Form ADV Schedule D, Section 7.B.(1)** — the sworn private-fund schedule an SEC-registered adviser must file for each fund it advises. It names the fund's auditor, prime broker, **every custodian**, administrator, and marketer. This closed the custody question for **OUSG** (five named custodians, a named auditor, a named administrator) and, by its **silences**, closed it for **BUIDL** in the opposite direction (no custodian record, no auditor record, no prime-broker record, no marketer record — the only service provider named is the administrator, and it is **SS&C**, not BNY).
2. **Securitize Corp.'s S-1** — Securitize became an SEC-reporting public company on 2026-07-01, so the keeper of BUIDL's register now describes that register under Securities Act liability. This produced the strongest register-of-record language in the whole category and a new fact round one could not have had: the register is maintained under a **terminable one-year contract**.
3. **Issuer-side legal pages and the BVI FSC's public register** — which named **Maple's obligor** (a segregated portfolio company, previously unnamed), confirmed **Anemoy's** regulatory status at the regulator rather than by web consensus, and confirmed **BUIDL is a recognised BVI Professional Fund**.

**Closed this round.** Obligor named for all five, with USDY's contradiction pinned to four live documents rather than two. Register of record completed for the two products round one lacked (OUSG, Maple). Custody and reserve composition resolved for OUSG and materially advanced for BUIDL. Bankruptcy-remoteness device identified for Maple (statutory ring-fencing) and confirmed at a regulator for Centrifuge/Anemoy. Perfection established as **not publicly verifiable by construction** in Delaware, with the gate cited.

**Still open.** No offering document for any of the five. USYC's administrator, custodian and auditor remain UNKNOWN — no SEC-registered adviser advises the fund, so the Form ADV route does not exist for it, and CIMA's register is reCAPTCHA-gated. BUIDL's custodian remains UNKNOWN in the strong sense that the one filing obliged to name it names none. Maple's SPC jurisdiction of incorporation is UNKNOWN (rate-limited out of the BVI register mid-query).

**One methodological note that bears on the paper.** Two of this round's sharpest findings are **contradictions between two sworn filings about the same fund**, and one is a **contradiction between an issuer's own two live pages**. In this category the primary sources do not merely omit the instrument; they disagree about it. A formalism that assumes a single well-defined obligor per instrument is assuming something the record does not supply.

---

## Ondo Finance (USDY + OUSG)

### CORRECTS ROUND ONE — OUSG's custody, administration and audit are fully named, and Ondo does not compute the NAV

Round one: *"Ondo computes NAV itself with **NAV Consulting** as administrator holding read-only account access"*, and left OUSG's custodian unnamed and its auditor unmentioned.

**Ondo Capital Management LLC is an SEC-registered investment adviser** — CRD **325197**, SEC file **801-134065**, principal office 500 West Putnam Avenue, Suite 400, Greenwich, Connecticut. Its Form ADV (Other-Than-Annual Amendment, **5/13/2026**) reports regulatory assets under management of **$952,507,376, discretionary, across exactly one account**. Schedule D, Section 7.B.(1) reports one private fund:

| Field | Value |
|---|---|
| Name | **ONDO I LP** |
| Private fund ID | **805-6065361819** |
| Organised | Delaware, United States |
| GP / Manager | **ONDO I GP LLC** |
| Exclusion | §3(c)(7) |
| Current gross asset value | **$952,507,376** |
| Minimum investment | $5,000 |
| Approximate beneficial owners | **30** |
| Owned by adviser and related persons | **0%** |
| Owned by non-United States persons | **98%** |
| Form D file number | 021-470288 |
| **Auditor** | **BPM LLP**, San Francisco, California — PCAOB-registered, PCAOB number **207** (1 record filed) |
| **Prime broker** | **No Information Filed** |
| **Custodians (5 records filed)** | **BitGo Trust Company, Inc.** (Sioux Falls, South Dakota; LEI 254900QXDWGM1T0HGF47) · **Circle Internet Financial LLC** (Boston, Massachusetts) · **Coinbase Trust Company, LLC** (New York; LEI 549300ZHW72BH3BM4Q58) · **JPMorgan Chase Bank, N.A.** (New York; LEI 7H6GLXDRUGQFU57RNE97) · **Silicon Valley Bank (a division of First Citizens Bank)** (Santa Clara, California; LEI L9VVX1KT5TFTKS0MLF66) |
| **Administrator** | **NAV Consulting, Inc.**, Oakbrook Terrace, Illinois (1 record filed) |
| **Q27 — % of fund assets valued by a person that is not a related person** | **100%** |
| Marketer | **Eden Communications, LLC**, New York |

Two things follow, and both correct round one.

**(i) The sworn filing says the administrator, not Ondo, determines the valuation.** Question 27 counts only assets where the non-related person "carried out the valuation procedure established for that asset" **and** where "the valuation used for purposes of investor subscriptions, redemptions or distributions, and fee calculations… was the valuation determined by such person." Ondo answered **100%**. Ondo's own product documentation says the opposite in substance — that Ondo pushes a "conservative estimate of the Net Income it expects to receive for the day" on-chain and trues it up the next business day, "because this is a manual process" (`https://docs.ondo.finance/qualified-access-products/ousg/yield.md`, 2026-08-04). **A sworn SEC filing and a live product page disagree about who determines the price at which a holder subscribes and redeems.** I do not resolve this; both are primary, and the reconciliation would be in the LP agreement, which is not public.

**(ia) The same two-sworn-filings divergence that afflicts BUIDL also afflicts OUSG, in the same direction.** The Form D/A of 2026-01-20 reports **84 investors** and cumulative `totalAmountSold` of **$1,857,726,909** (round one); the Form ADV of 2026-05-13 reports **30 beneficial owners** and a gross asset value of **$952,507,376**. Cumulative-versus-outstanding explains the money; it does not explain 84 against 30. Two sworn filings by the same sponsor, four months apart, disagree on how many people own the fund. **This is now the pattern rather than the exception: it recurs at OUSG and at BUIDL, and in both cases the Form D count is the higher one.**

**(ii) Custody is split five ways across two custodial species.** Two crypto trust companies (BitGo, Coinbase), one stablecoin issuer (Circle Internet Financial LLC — recorded as a *custodian*, which is notable in itself), one money-centre bank (JPMorgan), and one commercial bank (SVB/First Citizens). Round one measured a residual "SVB deposits 0.02%" line in the live portfolio and could not explain it; the ADV explains it — SVB is a filed custodian of record. **Round one's finding that OUSG holders sit two tokenisation layers from the Treasuries is unaffected, but the custody perimeter is now five entities in four regulatory regimes, and nothing in the vocabulary can say that.**

### CORRECTS ROUND ONE — the USDY obligor contradiction is three-way, not two-way, and the Delaware LLC is still a live legal person

Round one found two conflicting statements. There are **four live documents, and they support three different answers**:

- *"USDY (US Dollar Yield Token) is a tokenized note **formerly issued by Ondo USDY LLC**, which as of December 15, 2025 has been folded into the Ondo Stocks umbrella."* — `https://docs.ondo.finance/general-access-products/usdy/basics.md`, 2026-08-04.
- *"**USDY tokens are issued by Ondo Global Markets (BVI) Limited**, a British Virgin Islands business company. Ondo Finance Inc., a Delaware (USA) corporation, provides tokenization services to, and is an equity holder of, Ondo Global Markets (BVI) Limited."* — `https://docs.ondo.finance/general-access-products/usdy/important-notes.md`, 2026-08-04.
- Present tense, undated: *"**Ondo USDY LLC** (the 'USDY entity') **is structured** as a special purpose vehicle whose activities **are limited to** (1) borrowing funds from prospective lenders, (2) issuing USDY tokens to evidence the LLC's debt obligations to those lenders, (3) allocating the proceeds of borrowing to US Treasuries and US bank demand deposits, **(4) creating and perfecting a security interest in its assets**, and (5) related incidental activities."* — `https://docs.ondo.finance/trust-and-security.md`, 2026-08-04.
- **New, and decisive against the "novation is complete" reading.** Ondo's live Terms of Service define "Covered Entities" to include, as three separate live entities, *"(b) Ondo I LP (c) Ondo Global Markets (BVI) Limited (d) **Ondo USDY LLC**"*. The same document's all-caps preamble identifies issuers as *"ONDO I LP (**THE ISSUER OF OUSG TOKENS**) AND ONDO GLOBAL MARKETS (BVI) LIMITED (**THE ISSUER OF ONDO STOCKS**…)"* — and **conspicuously does not name an issuer of USDY at all.** — `https://docs.ondo.finance/legal/terms-of-service.md`, 2026-08-04.

So: one page says the Delaware LLC formerly issued USDY; one says the BVI company issues it; one describes the Delaware LLC in the present tense as the issuing SPV; and the Terms of Service keep the Delaware LLC alive as a distinct contracting party while assigning the BVI company a *different* product. **UNKNOWN — who owes a USDY holder today, and whether outstanding USDY was novated.** Round one's judgement stands and is now better evidenced: any decomposition naming a single USDY obligor asserts more than Ondo's published record supports.

Two further Ondo-side facts:

- **Governing law of the interface is Connecticut.** *"The interpretation and enforcement of these Terms… will be governed by and construed and enforced under the laws of the state of Connecticut"*, with the Federal Arbitration Act governing the arbitration provision (Terms of Service §15.8, 2026-08-04). Ondo Stocks notes are Swiss-law with Zurich arbitration (round one). **One product family, three governing laws — Connecticut for the interface, Swiss for the notes, Delaware for the LP — and a BVI issuer.**
- *"APY is set **monthly** by Ondo in accordance with the USDY governing documents"* (`https://ondo.finance/usdy`, footnote 1, stealth fetch 2026-08-04). This is a rate administered by the issuer against a document the holder cannot read, and it sits alongside the on-chain `RWADynamicOracle`'s range-compounding.

### CORRECTS ROUND ONE — the USDY collateral report is now geofenced and unreachable from the United States

Round one cited `https://ondo.finance/usdy` for the live reserve report (outstanding $2.14B, assets $2.16B, collateralisation ratio 104.20%, 99.21% US Treasuries, "Issuer Domicile: United States"). On a stealth fetch on **2026-08-04** the same URL returns only:

> **"Access Restricted — USDY — The content you are trying to access is not accessible in your jurisdiction.**  USDY tokens are not registered under the Securities Act of 1933, as amended… USDY tokens are not offered or sold in the U.S., to U.S. persons…"

**The only public reserve-composition disclosure for a $2.1B instrument is jurisdictionally gated, and the gate is on the disclosure, not merely on the product.** That is a documented absence of exactly the kind this category turns on: the reserve report is not private, it is private *to you*. Round one's figures should be cited with the note that they were obtained before the geofence closed on this host, and are not currently re-verifiable from it.

### Perfection — the negative result is structural, and here is the gate

`trust-and-security.md` states the SPV's purposes include *"creating and **perfecting** a security interest in its assets"* — an express statement of intent to perfect, which round one did not have. Round one then marked the UCC-1 filing UNKNOWN. **That UNKNOWN cannot be closed from public online sources, and the reason is a rule, not a search failure:**

> *"Effective December 1, 2001, all non 'Search to Reflect' UCC Searches will be performed by a **Delaware Authorized Searcher**."* — `https://corp.delaware.gov/uccsearch/`, 2026-08-04

Delaware maintains **no free public online index of UCC-1 financing statements searchable by debtor name**; a certified search must be ordered through an authorised searcher (registered agents, service companies and law firms). Probes of `https://icis.corp.delaware.gov/Ecorp/UccSearch/UccSearch.aspx` return HTTP 404 (2026-08-04). **So for a Delaware-organised issuer, the existence of the perfection instrument is not a public fact.** This is the cleanest illustration in the category of the paper's thesis: the wrapper is fully observable on-chain, and the step that makes the holder's claim good against third parties is observable only to whoever pays a searcher.

Separately, **Ondo Global Markets (BVI) Limited does not appear on the BVI Financial Services Commission's public register of regulated entities** (`https://www.bvifsc.vg/regulated-entities?combine=Ondo`, 2026-08-04 — 11 results returned, all false matches on "London"/"Fondo", none an Ondo entity). It is a BVI business company, not a recognised fund or approved manager. Consistent with issuing notes rather than fund shares; and it means **no BVI regulatory filing exists that would disclose the security agreement or its governing law.** Round one's "UNKNOWN — the governing law of the security agreement and the perfection regime for the BVI issuer" stands, now with both registries checked.

### Register of record for OUSG — answered, and the answer is that there is no transfer agent by design

Round one: *"OUSG — UNKNOWN, and this is the largest single gap in this section… no transfer agent is named for OUSG anywhere."*

The register of record for OUSG is **the limited partnership's own books, maintained by the General Partner with NAV Consulting, Inc. as administrator**. There is no transfer agent. *(Inference, flagged as such and not cited: none is required — Ondo I LP is a §3(c)(7) fund offered under Rule 506(c) whose interests are not registered under Exchange Act §12, and transfer-agent registration under §17A(c) attaches to agents for §12-registered securities. I did not locate a source stating this about OUSG specifically, so the paper should carry it as reasoning, not as a finding.)* Ondo's own statement of the structure is that *"Investors become limited partners in the Fund by acquiring OUSG tokens, each of which represents a unitized limited partnership interest"*, that the Fund is *"managed by its General Partner, Ondo I GP LLC"*, and that customer due diligence *"is administered by the General Partner"* (`https://docs.ondo.finance/trust-and-security.md`, 2026-08-04). The ADV records NAV Consulting as administrator and 100% third-party valuation. **No document states whether the LP register or the token ledger controls on a conflict, and that specific question remains UNKNOWN** — but the *identity* of the register and its keeper is now settled, which is what round one lacked.

**A finding that sharpens it, and it is odd.** There **is** an SEC-registered transfer agent in the Ondo orbit: **Oasis Pro TA LLC**, CIK 0001949682, TA file number **084-06872**, FINS 371864, of 1 Thorndal Circle, 3rd Floor, Darien, Connecticut, whose TA-1 names its parent as **Oasis Pro, Inc.** Its annual report on Form **TA-2/A for the period ended 2025-12-31** (filed 2026-03-23) reports, in every field: **0 items received for transfer, 0 master securityholder file filings, 0 individual accounts, 0 DRIP accounts, 0 DRS accounts, $0.00 of dividends and interest, 0 issues** — a registered transfer agent that transferred nothing. **UNKNOWN — whether Oasis Pro TA LLC is under Ondo's control.** No document I could reach at a primary source links Ondo to Oasis Pro; EDGAR's full-text index shows Oasis Pro Markets LLC (CIK 0001456250, broker-dealer, X-17A-5 filings through 2026-02-09) and Oasis Pro, Inc. (CIK 0001931792) with no Ondo reference. I record the entity and its zero return because if the link is real it is the sharpest fact available — a tokenised-securities group holding a dormant transfer-agent registration while its flagship fund keeps its register in a private book — but I decline to assert the link.

**Evidence added, Ondo**

| Claim | URL | Accessed |
|---|---|---|
| Form ADV, Ondo Capital Management LLC: CRD 325197, 801-134065, filing 5/13/2026, RAUM $952,507,376 / 1 account; Section 7.B.(1) Ondo I LP 805-6065361819, GAV, 30 owners, 98% non-US; auditor BPM LLP (PCAOB 207); **no** prime broker; **5 custodians** BitGo / Circle Internet Financial / Coinbase Trust / JPMorgan Chase / SVB; administrator NAV Consulting; Q27 = 100%; marketer Eden Communications | `https://reports.adviserinfo.sec.gov/reports/ADV/325197/PDF/325197.pdf` | 2026-08-04 |
| "formerly issued by Ondo USDY LLC… folded into the Ondo Stocks umbrella" | `https://docs.ondo.finance/general-access-products/usdy/basics.md` | 2026-08-04 |
| "USDY tokens are issued by Ondo Global Markets (BVI) Limited" | `https://docs.ondo.finance/general-access-products/usdy/important-notes.md` | 2026-08-04 |
| Present-tense SPV purpose clause incl. "creating and **perfecting** a security interest"; Ondo I LP GP/IM structure; GP administers CDD | `https://docs.ondo.finance/trust-and-security.md` | 2026-08-04 |
| Covered Entities list naming **all three** issuers incl. Ondo USDY LLC; "ONDO I LP (THE ISSUER OF OUSG TOKENS) AND ONDO GLOBAL MARKETS (BVI) LIMITED (THE ISSUER OF ONDO STOCKS)"; §15.8 **Connecticut** governing law + FAA | `https://docs.ondo.finance/legal/terms-of-service.md` | 2026-08-04 |
| **"Access Restricted… not accessible in your jurisdiction"**; "APY is set monthly by Ondo in accordance with the USDY governing documents"; reference to "the Token offering documents" | `https://ondo.finance/usdy` (scrapling stealth fetch) | 2026-08-04 |
| **NEGATIVE:** Delaware provides no free public UCC-1 debtor search — "all non 'Search to Reflect' UCC Searches will be performed by a Delaware Authorized Searcher" | `https://corp.delaware.gov/uccsearch/` | 2026-08-04 |
| **NEGATIVE:** no Ondo entity on the BVI FSC register | `https://www.bvifsc.vg/regulated-entities?combine=Ondo` | 2026-08-04 |
| Oasis Pro TA LLC TA-2/A, period 2025-12-31: all activity fields zero | `https://www.sec.gov/Archives/edgar/data/1949682/000194968226000007/primary_doc.xml` | 2026-08-04 |
| Oasis Pro TA LLC TA-1: FINS 371864, parent Oasis Pro, Inc. | `https://www.sec.gov/Archives/edgar/data/1949682/000089914022000725/primary_doc.xml` | 2026-08-04 |

---

## Circle USYC (Hashnote International Short Duration Yield Fund Ltd.)

### CORRECTS ROUND ONE — Circle's own subsidiary exhibit lists the Fund as a Circle subsidiary

Round one established the issuer-agency split carefully: the economic obligor is SDYF (Cayman), CIBL is the Bermuda-regulated token administrator, and Circle's 10-K treats SDYF as an **unconsolidated VIE** to which Circle "provides no guarantees and has no other financial obligations", so *"holders have no recourse to Circle"*.

**Exhibit 21.1 to the same 10-K — "Subsidiaries of Circle Internet Group, Inc." — lists the Fund itself:**

> Hashnote Holdings LLC — Delaware
> **Hashnote Management LLC — Delaware**
> **Circle International Bermuda Limited — Bermuda**
> **Hashnote International Management LLC — Cayman Islands**
> Hashnote Associates LLC — Delaware
> **Hashnote International Short Duration Yield Fund Ltd. — Cayman Islands**

— `https://www.sec.gov/Archives/edgar/data/1876042/000187604226000062/exhibit211-listofsubsidiar.htm`, 2026-08-04.

Item 601(b)(21) requires a registrant to list its subsidiaries, "subsidiary" meaning an entity controlled by the registrant (Regulation S-X Rule 1-02(x)). **So in one exhibit Circle asserts control of the Fund, and in the notes to the financial statements in the same filing it reports the Fund as a VIE of which it is not the primary beneficiary.** Round one's phrase for the CIBL/SDYF issuer question — "not reconcilable on their face" — now applies to the consolidation question as well, and this one is inside a single document.

I do not treat this as refuting round one's segregation finding. Both readings can be true under different tests: Rule 1-02(x) control and ASC 810 primary-beneficiary are different questions, and a sponsor can control a fund's manager without absorbing its variability. **But the paper cannot say "the fund is off Circle's balance sheet" without also saying "and Circle lists it as a subsidiary."** The two statements are the entire content of the segregation claim, and they point in opposite directions.

**New entity facts.** The Cayman manager is **Hashnote International Management LLC (Cayman Islands)**; there is also **Hashnote Management LLC (Delaware)** and **Hashnote Associates LLC (Delaware)**. Round one had only "Hashnote Holdings LLC… the fund manager". The manager chain is at least three entities across two jurisdictions.

### Service providers — UNKNOWN, and here is exactly why the route that worked for the others does not exist here

For OUSG and BUIDL the custodian/administrator/auditor question was answered by Form ADV Schedule D. **That route does not exist for USYC**: an IAPD firm search for `hashnote` returns **0 results** (`https://api.adviserinfo.sec.gov/search/firm?query=hashnote&type=Firm`, 2026-08-04), so no SEC-registered or exempt-reporting adviser files a Section 7.B.(1) naming SDYF, and no sworn service-provider schedule exists in the United States.

The Cayman route is gated. CIMA's public register is served from a POST endpoint (`https://www.cima.ky/search-entities-cima/get_search_data`) carrying a CSRF token **and a reCAPTCHA field**; a token-authenticated POST with a maintained cookie jar returned an empty body (2026-08-04). **UNKNOWN — SDYF's administrator, custodian and auditor at a regulator's record.** What remains is round one's product-documentation set (prime broker **Marex**, bank **Customers Bank**, auditor **Cohen and Company**, administrator **NAV Consulting**, KYC **NAV Consulting / LMO Consulting**), which is issuer-published and unsworn.

Round one's negative — *"the strings 'prime broker' and 'Marex' do not appear anywhere in Circle's FY2025 10-K"* — is now stronger in context: the prime-brokerage relationship is absent from the 10-K, absent from any ADV because none exists, and unobtainable from CIMA. **For the single largest tokenised treasury product, no regulator's record of who holds the assets is publicly reachable at all.**

### Offering memorandum — NOT OBTAINABLE, unchanged

No new route. The Fund is not an EDGAR filer; the offering relies on an exemption; the press release remains the primary confirmation that the documents exist and are the operative instrument (*"An offer… is only made to eligible investors through the Fund's offering documents"*). Gating, suspension, side letters and wind-down stay UNKNOWN and must not be asserted.

**Evidence added, USYC**

| Claim | URL | Accessed |
|---|---|---|
| Circle FY2025 10-K Exhibit 21.1 listing **Hashnote International Short Duration Yield Fund Ltd. (Cayman Islands)**, Hashnote International Management LLC (Cayman), Hashnote Management LLC (DE), Hashnote Associates LLC (DE), Hashnote Holdings LLC (DE), Circle International Bermuda Limited (Bermuda) as subsidiaries of Circle Internet Group, Inc. | `https://www.sec.gov/Archives/edgar/data/1876042/000187604226000062/exhibit211-listofsubsidiar.htm` | 2026-08-04 |
| **NEGATIVE:** no SEC-registered or exempt-reporting adviser named "Hashnote" exists — 0 results | `https://api.adviserinfo.sec.gov/search/firm?query=hashnote&type=Firm` | 2026-08-04 |
| **NEGATIVE (gate cited):** CIMA entity register served over POST with CSRF token + reCAPTCHA; authenticated POST returned empty | `https://www.cima.ky/search-entities-cima/get_search_data` | 2026-08-04 |
| EDGAR full-text: "Hashnote" appears in 26 filings, all Circle's own or two unrelated Hashnote LP Form Ds (CIK 1968399, 2017717); SDYF is not an EDGAR filer | `https://efts.sec.gov/LATEST/search-index?q=%22Hashnote%22` | 2026-08-04 |

---

## BlackRock BUIDL (via Securitize)

### CORRECTS ROUND ONE — BNY Mellon is not confirmed, and the filing that must name a custodian names none

Round one: *"**(f) BNY Mellon — UNKNOWN.** I could not confirm the custodian/administrator role split at a primary source… Press asserts BNY Mellon is custodian; that is Tier-4 and I decline to rely on it."*

That caution was right, and the position is now stronger than "unconfirmed". **BlackRock Financial Management, Inc.** (CRD **107105**) reports BUIDL in Schedule D, Section 7.B.(1) of its Form ADV (Other-Than-Annual Amendment, **7/24/2026**):

| Field | Value |
|---|---|
| Name | **BLACKROCK USD INSTITUTIONAL DIGITAL LIQUIDITY FUND LTD.** |
| Private fund ID | **805-1443872669** |
| Organised | Virgin Islands |
| Current gross asset value | **$1,752,332,283** |
| Minimum investment commitment | **$250,000,000** |
| Approximate beneficial owners | **3** |
| Owned by adviser and related persons | **3%** |
| Owned by non-United States persons | **0%** |
| **Auditors** | **No Information Filed** |
| **Prime broker** | **No Information Filed** |
| **Custodian** | **No Information Filed** |
| **Administrator** | **SS&C TECHNOLOGIES, INC.**, Evansville, Indiana (1 record filed) |
| Q27 — % valued by a non-related person | **100%** |
| **Marketers** | **No Information Filed** |
| Form D file number | **No Information Filed** |

Four observations, in descending order of importance.

**(i) The administrator is SS&C, not BNY.** This is the first primary-source identification of any BUIDL service provider other than the transfer agent. It also means the entity that computes the $1.00 NAV is a named third party, and that BlackRock swears 100% of the fund's assets were valued by a non-related person.

**(ii) No custodian is reported.** Item 25(a) asks whether the fund uses any custodians "including the prime brokers listed above" to hold some or all of its assets; the schedule carries no custodian record. Ondo's ADV, by contrast, filed five. I cannot read the Yes/No checkbox from the PDF's text layer, so **UNKNOWN — whether BlackRock answered "no" or answered "yes" and filed nothing**; what is certain is that **the one filing in which a custodian must be named names none.** Any paper claim that BUIDL employs a named qualified custodian is unsupported at primary sources, and the press attribution to BNY Mellon should be dropped rather than hedged.

**(iii) No auditor is reported either.** Ondo filed one (BPM LLP, PCAOB 207). BUIDL's schedule carries no auditor record. For a fund seeking a stable $1.00 NAV this is worth stating plainly as a documented absence.

**(iv) Two sworn filings about the same fund disagree on almost every countable fact.**

| | Form D/A (2026-07-27, signed 2026-07-23) | Form ADV (7/24/2026) | Securitize product page |
|---|---|---|---|
| Minimum investment | **$100,000** | **$250,000,000** | **$5,000,000** (Ethereum class) |
| Investors / beneficial owners | **28** | **3** | — |
| Placement agent / marketer | **Securitize Markets, LLC**, CRD 283256, $525,000 sales commissions | **No Information Filed** | Securitize |
| Size | `totalAmountSold` **$5,135,523,412** cumulative | GAV **$1,752,332,283** | — |
| Non-US ownership | not reported | **0%** | — |

Round one recorded the $100,000-versus-$5M tension and called it "a contradiction between two primary sources". It is a **three-way** contradiction spanning **three orders of magnitude**, and the outlier is the sworn adviser filing. The investor count is worse: 28 against 3, four days apart. Round one's warning that *"no single number is 'BUIDL's AUM' without naming which chain, which class, and whether the figure is outstanding or cumulative"* now extends to the investor base and the minimum ticket. **A vocabulary term for "minimum subscription" would have three primary values to choose from and no rule for choosing.**

### NEW — BUIDL is a recognised BVI Professional Fund

The BVI Financial Services Commission's public register returns exactly one match for "BlackRock":

> **BlackRock USD Institutional Digital Liquidity Fund Ltd. — Category: Professional Funds**

— `https://www.bvifsc.vg/regulated-entities?combine=BlackRock`, 2026-08-04.

Round one had the fund's BVI incorporation from the Form D but not its regulatory status. This matters for the offering-document question: a BVI Professional Fund is a *recognised* fund under the Securities and Investment Business Act, and recognition requires the fund to submit its **offering document** (or a written statement of why none is issued) to the Commission. **So an offering document for BUIDL is on file with a regulator; the register publishes its existence and not its contents.** That converts round one's "not obtainable" into the sharper "filed with a regulator, withheld from the public" — which is the better form of the finding for the paper.

### CORRECTS ROUND ONE'S FRAMING — the register of record is real, singular across chains, and held on a terminable one-year contract

Securitize Corp. became an SEC-reporting company on **2026-07-01** (Cantor Equity Partners II business combination) and filed an S-1 on **2026-07-31**. Its description of its own recordkeeping is the strongest in the category:

> *"While tokenized securities may exist across multiple blockchains through authorized multichain issuance, such deployments are managed and reconciled through the **same control book and master securityholder file** to ensure that total outstanding units remain consistent and singular across chains… In the event of such a fork, **Securitize would determine which chain constitutes the valid and authoritative record** for purposes of ownership, recordkeeping, and the exercise of holder rights such as voting, redemptions, and distributions. Tokens existing on other forked chains would not be recognized as valid representations of the securities."*

> *"Securitize has manual safeguards in place which help **retain the appropriate records of ownership should the automated blockchain systems fail** which it controls in its capacity as transfer agent, adding an extra layer of security over these tokenized funds."*

— `https://www.sec.gov/Archives/edgar/data/2094496/000162828026051182/secz-20260731.htm`, 2026-08-04.

This **corrects round one on one point and confirms it on another**. Round one wrote that BUIDL's multi-chain design means *"one obligor, N tokens, one register"* and that the vocabulary has no symbol for it — **confirmed, in the issuer's own words** ("the same control book and master securityholder file… consistent and singular across chains"). But round one also read the chain as "an instruction channel that the transfer agent reads". The fork paragraph shows the relation is stronger than that: **the transfer agent does not merely read the chain, it decides which chain counts.** The authoritative record is not a ledger at all; it is a *determination* by a named company, exercised over ledgers.

**And the new fact round one could not have had:**

> *"our platform services and **transfer agent agreement** that governs our relationship with BlackRock had an initial term of two years and now **automatically renews for one year terms, with the right for BlackRock to terminate with written notice to us 90 days prior to the end of a renewal term**, and our placement agent agreement with BlackRock can be **terminated by BlackRock at any time** with prior written notice."*

**The authoritative ownership register of a multi-billion-dollar fund is maintained under a one-year rolling contract terminable on 90 days' notice.** Round one's residue #5 for BUIDL — "the transfer agent's own outsourcing" — is real, and this is the layer above it: the register keeper is itself revocable. The vocabulary has no symbol for the register, so it necessarily has none for the register's *tenure*.

Corroborating scale, from the transfer agent's own sworn annual report — **Securitize Transfer Agent, LLC**, TA-2 for the period ended 2025-12-31 (filed 2026-03-31): **3,582 items received for transfer**; **18,337 individual accounts** and **18,337 master securityholder file filings**; 642 dividend-reinvestment accounts; 2,806 Direct Registration System accounts; issues for which it maintains the master file: **23 equity + 16 limited partnership + 15 other = 54**; **dividends and interest paid on 5 issues totalling $90,684,962.47**; account mix 97.37% equity, 1.96% limited partnership, 0.67% other; engaged service company in both directions: **Pacific Stock Transfer Co** (084-01145). Signed by Piero Falcone, Senior Director of Operations.

Also from the S-1: *"BUIDL… represented **more than 60% of Securitize's tokenized assets under management** as of September 30, 2025"*; *"As of December 31, 2025, Securitize had more than **$3.1 billion** in tokenized assets under management"*; and Securitize acquired **MG Stover**, a digital-asset fund administrator, on 2025-04-15 for $21.1 million net of cash. **The register keeper, the placement agent, the ATS and now the fund administrator are one group** — vertical integration that round one saw only as "SEC-registered entities across a transfer agent, broker-dealer, ATS, investor advisor and fund administration" and that the vocabulary cannot express as a concentration at all.

### Offering documents — the gate, cited

The BUIDL product page (stealth fetch, 2026-08-04) states: *"**Subscription documents must be completed, in good order, and funding received by the following dates**, to be included in a monthly fund close."* The subscription route is `https://id.securitize.io/primary-market/opportunities/399`, behind Securitize ID login and accreditation. Ethereum class: **Investor Eligibility Qualified Purchaser · Investment Min. $5M · Subsequent Investment Min. $250k**. **The offering document set for BUIDL is the subscription documents, and they are reachable only after identity verification** — the gate is cited, the documents are not obtainable.

Round one flagged the monthly-close calendar as possibly a generic Securitize template and marked BUIDL's authoritative subscription calendar UNKNOWN. The stealth fetch confirms the calendar is rendered **on BUIDL's own page** with dated rows pairing "Investor Subscription Deadlines" against "NAV / Valuation Date" roughly two months apart, while the *same page* states daily dividend accrual to the holder of record at 3:00pm ET and same-business-day redemption. **These cannot both describe the same fund's primary market.** Round one's UNKNOWN stands; the contradiction is now located on a single page rather than inferred.

One custody statement does appear, and it is about the *token*, not the fund: *"Your keys, your token. **Custody BUIDL at your preferred custodian or self custody.**"* **Share custody is the investor's problem; asset custody is unnamed.** That asymmetry is the whole of BUIDL's public custody disclosure.

**Evidence added, BUIDL**

| Claim | URL | Accessed |
|---|---|---|
| Form ADV, BlackRock Financial Management, Inc., CRD 107105, filing 7/24/2026, Section 7.B.(1) for BUIDL: fund ID 805-1443872669, Virgin Islands, GAV $1,752,332,283, minimum $250,000,000, 3 beneficial owners, 3% related-person ownership, 0% non-US; **no auditor / no prime broker / no custodian / no marketer records**; administrator **SS&C Technologies, Inc.**, Evansville, Indiana; Q27 = 100% | `https://reports.adviserinfo.sec.gov/reports/ADV/107105/PDF/107105.pdf` | 2026-08-04 |
| **BVI FSC register: "BlackRock USD Institutional Digital Liquidity Fund Ltd. — Category: Professional Funds"** | `https://www.bvifsc.vg/regulated-entities?combine=BlackRock` | 2026-08-04 |
| Securitize Corp. S-1: control book / master securityholder file singular across chains; Securitize determines the authoritative chain on a fork; manual off-chain safeguards it controls as transfer agent; **BlackRock transfer-agent agreement renews annually, terminable on 90 days' notice**; placement agent agreement terminable at any time; BUIDL >60% of tokenized AUM at 2025-09-30; >$3.1B tokenized AUM at 2025-12-31; MG Stover acquisition | `https://www.sec.gov/Archives/edgar/data/2094496/000162828026051182/secz-20260731.htm` | 2026-08-04 |
| Securitize Transfer Agent, LLC TA-2, period 2025-12-31: 3,582 transfers, 18,337 accounts, 54 issues, $90,684,962.47 dividends/interest on 5 issues, Pacific Stock Transfer as service company both directions | `https://www.sec.gov/Archives/edgar/data/1782266/000190359626000113/primary_doc.xml` | 2026-08-04 |
| BUIDL product page: "Subscription documents must be completed, in good order…monthly fund close"; NAV/valuation date table; Qualified Purchaser / $5M / $250k; "Custody BUIDL at your preferred custodian or self custody"; books-and-records redemption paragraph | `https://securitize.io/blackrock/buidl` (scrapling stealth fetch) | 2026-08-04 |
| Form D/A, BUIDL: $100,000 minimum, 28 investors, Securitize Markets LLC with $525,000 estimated sales commissions, `totalAmountSold` $5,135,523,412 | `https://www.sec.gov/Archives/edgar/data/2013810/000201381026000002/primary_doc.xml` | 2026-08-04 |

---

## Maple Finance (syrupUSDC / syrupUSDT / syrupUSDG)

### CORRECTS ROUND ONE — the obligor is named, and it is a segregated portfolio company

Round one: *"**Who owes the money is a two-step chain and only the first step is on-chain:** the lender holds a claim on the Pool contract; the Pool holds `MapleLoan` contracts."* True on-chain, but there **is** a named legal obligor, published, and round one did not reach it:

> *"The syrupUSDC token is a product developed, **issued, and managed exclusively by Maple International Operations SPC acting on behalf of and for the account of Secured Loan Segregated Portfolio 1**."*
> — `https://docs.maple.finance/legal/syrupusdc-product-disclosures-and-disclaimers.md`, 2026-08-04

> *"the 'syrupUSDC Issuer' refers to **Maple International Operations SPC acting on behalf of and for the account of Secured Loan Segregated Portfolio 1**, the 'syrupUSDT Issuer' refers to Maple International Operations SPC acting on behalf of and for the account of **Maple USDT Segregated Portfolio 1** and the 'syrupUSDG Issuer' refers to Maple International Operations SPC acting on behalf of and for the account of **Maple USDG Segregated Portfolio 1**. **Syrup Ltd acts solely as Interface Operator for all products and is not the issuer of the products.**"*
> — `https://docs.maple.finance/legal/interface-terms-of-use-syrupusdc-and-syrupusdt.md`, 2026-08-04

So the answer to "who owes the syrupUSDC holder" is: **one company, three portfolios, three legally distinct obligors**, with the interface operator (**Syrup Ltd**) and the software provider (**Maple Labs Pty Ltd**, an Australian proprietary company, named as a third-party beneficiary of the terms) both expressly disclaiming issuer status.

### NEW — bankruptcy remoteness for Maple is statutory ring-fencing, not contract

The task asked whether a segregated portfolio company structure appears. It does, and Maple states its effect:

> *"…each operating independently as **legally distinct entities**. The assets and liabilities of each entity are **ring-fenced by statute**. **Lender claims are exclusively against the assets of the segregated portfolio in which they have deposited**, and the assets of one segregated portfolio cannot be used to satisfy the liabilities of another. This structure is designed to protect lenders from cross-portfolio contagion, but it also means that **your recourse in the event of a loss is limited to the assets within the relevant portfolio**."*
> — `https://docs.maple.finance/legal/syrupusdc-and-syrupusdt-risks.md` §6.3, 2026-08-04

This is the same legal device round one identified for Centrifuge's Anemoy Capital SPC Limited and called *"a legal firewall between claim classes that looks superficially like `Im` (isolated market) but is created by statute, not by contract deployment, and survives insolvency — which `Im` does not claim to do."* **It now appears at two of the five, in two different categories of product (a private-credit pool and a treasury fund), and in both cases it is the entire bankruptcy-remoteness story.** That is a much better-evidenced residue than a single sighting.

**UNKNOWN — the jurisdiction of incorporation of Maple International Operations SPC.** The segregated portfolio company is a Cayman and BVI form; Maple's own documentation never states which. The Interface Terms specify **BVI law and BVI arbitration** (below), which is suggestive but not dispositive — governing law of a website's terms is not an issuer's place of incorporation. My BVI FSC register query for "Maple" was cut off by Cloudflare rate limiting (error 1015, Ray ID a262d9176987f4b9, 2026-08-05 03:52 UTC) after three successful queries; I did not retry to avoid a longer ban.

### NEW — governing law, and a live legal document with unfilled template placeholders

> *"The Services are operated by us in the **\[place]**. Those who choose to access the Services from other jurisdictions do so at their own initiative… These Terms are governed by the laws of the **\[British Virgin Islands]**, without regard to conflict of laws rules, and the proper venue for any disputes arising out of or relating to any of the same will be the courts in **\[British Virgin Islands]**."*
> — `https://docs.maple.finance/legal/interface-terms-of-use-syrupusdc-and-syrupusdt.md`, 2026-08-04

The square brackets are in the published text. **The governing-law and venue clause of the live terms of use for a billion-dollar product retains its drafting placeholders, and one of them — the place of operation — was never filled in at all.** I record this as observed, verbatim, without inferring what it means for enforceability.

Arbitration is real and specific: *"any Claim… shall be settled by arbitration under the Rules of the **British Virgin Islands International Arbitration Centre (BVI IAC)** or the **Chartered Institute of Arbitrators (CIArb)**… by **three arbitrators**… The language of arbitration will be English… **class arbitrations and class actions are not permitted**"*, with a 30-day opt-out to support@syrup.fi. Prohibited Jurisdictions include **the United States and Australia** — the latter notable given Maple Labs Pty Ltd is Australian.

### CORRECTS ROUND ONE — the Master Loan Agreement is described at a primary source, and its waterfall contradicts the technical docs

Round one: *"**UNKNOWN — the governing law, and no agreement template is published.** I searched the docs tree and the public repos and found no loan agreement, term sheet, or choice-of-law clause."*

Maple publishes a **Borrower MLA** page. It does **not** publish the agreement — so round one's "no template is published" stands — but it states the agreement's operative terms:

> *"Prior to the disbursement of any funds, all prospective borrowers sign a legal agreement (the 'Agreement')… The Agreement incorporates a **forum selection clause and arbitration provision**. Further, as a condition precedent to receiving funds, borrowers are required to execute an **irrevocable waiver of all and any obligations to forum**.*
> *In the event of default, the distribution of such recovered amounts is allocated as follows:*
> *i) All reasonable and documented **costs incurred by Maple**…*
> *ii) The outstanding **principal balance owed to Lenders**, to be distributed on a pro-rata basis calculated as of the date of default;*
> *iii) Any and all accrued **interest owed to Lenders**, similarly pro-rata…*
> *iv) Any **fees owed to Maple**, as expressly stipulated in the Agreement."*
> — `https://docs.maple.finance/legal/borrower-mla.md`, 2026-08-04

**This corrects round one's residue #4 for Maple.** Round one recorded *"a default waterfall that pays protocol fees first"*, quoting `defaults.md`: *"All liquidated collateral and cover first goes towards recovering fees owed to the protocol, after which all funds are returned to the Pool."* The legal page says the opposite ordering for fees: Maple's **costs** rank first, but Maple's **fees** rank **last**, behind lender principal and lender interest. **Maple's technical documentation and Maple's legal documentation state incompatible recovery waterfalls for the same event.** The correct statement for the paper is that the recovery ordering is contested between two of the issuer's own pages, and that the *legal* page — describing the agreement that actually governs recovery — subordinates the protocol's fees to the lenders.

**The governing law of the loan agreement remains UNKNOWN**, and now for a documented reason: Maple discloses that a forum selection clause and an arbitration provision exist, and declines to name the forum or the law. Round one's instruction not to assert "NY/English law" is confirmed.

### NEW — Maple is not only a loan book, and the discretion is wider than round one recorded

> *"The yield… is generated from two primary sources: 1. **Overcollateralized Lending**… governed by **Master Lending Agreements** with posted collateral. 2. **Supporting Yield Strategies.** Capital may also be allocated to supporting yield strategies, including but not limited to **futures basis trading, other delta-neutral or market-neutral approaches, and liquidity provision in decentralized finance protocols**."*

with disclosed risks including *"the risk that a centralized exchange or trading counterparty becomes insolvent, restricts withdrawals, or experiences operational failures"*, *"Basis Spread Compression or Inversion"*, and *"Forced Liquidation… by exchanges or protocols"*. — same URL, §1.3 and §3.

Round one characterised syrupUSDC purely as a claim on a pool of overcollateralised institutional loans. **It is a claim on a pool that also runs a basis trade and provides DeFi liquidity, with capital on centralised exchanges.** That materially changes the risk description and, for stage 2, the set of obligations a construction must reproduce: the pool has *venue* exposure and *strategy* exposure the on-chain loan accounting does not represent. Maple's only stated bound is disclosure: *"Trading strategy allocations are subject to the same governance, monitoring, and disclosure standards applicable to primary lending operations. Current allocations are transparently visible in the Liquidity section of the… Details page."* **No cap, no venue whitelist, no leverage limit is published.**

One internal tension worth recording: §7.3 states *"neither the applicable Issuer nor the Interface Operator brokers trading orders on your behalf, matches orders, or **offers any financial products for sale or distribution**"* — in a document whose §1.1 and §6.3 describe the Issuer as issuing the product and the holder as having a claim against the Issuer's segregated portfolio.

### Register of record for Maple — answered, and it is the only one of the five where the chain is the register

There is no transfer agent, no share registry, no administrator and no off-chain book anywhere in Maple's documentation. The holder's claim is an ERC-4626 share of a pool, and the claim runs directly against the assets of a named segregated portfolio. **The token ledger is the register of record.** Round one's on-chain measurements (`totalSupply` 932,261,251.64, `totalAssets` 1,097,084,773.24, `convertToAssets(1e6)` = 1,176,799) are therefore measurements *of the register*, not of a mirror — which is not true of any of the other four. This is the sharpest structural contrast in the category and it should be stated positively: **four of the five place the chain below an off-chain book; Maple does not, and pays for it with a claim that is limited by statute to one portfolio's assets.**

**Evidence added, Maple**

| Claim | URL | Accessed |
|---|---|---|
| Issuer = **Maple International Operations SPC** for Secured Loan Segregated Portfolio 1; "not sponsored… by Circle"; yield from lending **and** supporting strategies | `https://docs.maple.finance/legal/syrupusdc-product-disclosures-and-disclaimers.md` | 2026-08-04 |
| Three issuers / three segregated portfolios; **Syrup Ltd** interface operator "not the issuer"; **Maple Labs Pty Ltd** third-party beneficiary; **"\[British Virgin Islands]"** governing law and venue with literal brackets; "operated by us in the \[place]"; BVI IAC / CIArb, three arbitrators, class waiver, 30-day opt-out; Prohibited Jurisdictions incl. US and Australia | `https://docs.maple.finance/legal/interface-terms-of-use-syrupusdc-and-syrupusdt.md` | 2026-08-04 |
| §1.3 yield sources incl. **futures basis trading** and DeFi LP; §2.2 impairment as anti-run mechanism with permanent loss to withdrawers; §3 trading-strategy risks; §6.2 restricted jurisdictions; **§6.3 statutory ring-fencing and portfolio-limited recourse**; §7.3 "offers no financial products for sale or distribution" | `https://docs.maple.finance/legal/syrupusdc-and-syrupusdt-risks.md` | 2026-08-04 |
| Borrower MLA: signed pre-disbursement; forum selection + arbitration; **irrevocable waiver of obligations to forum**; four-step default waterfall with **Maple's fees last** | `https://docs.maple.finance/legal/borrower-mla.md` | 2026-08-04 |
| **NEGATIVE:** MiCA Whitepaper page exists in the legal index but renders empty in both markdown and HTML; no PDF link found | `https://docs.maple.finance/legal/mica-whitepaper.md` | 2026-08-04 |
| **NEGATIVE (gate cited):** BVI FSC register query for "Maple" blocked — Cloudflare error 1015 rate limit | `https://www.bvifsc.vg/regulated-entities?combine=Maple` | 2026-08-04 |

---

## Centrifuge (Protocol V3 / JTRSY via Anemoy)

### CORRECTS ROUND ONE — the Anemoy entity facts are now primary, not aggregator

Round one recorded the Anemoy entity chain with an explicit warning: *"web search consensus, **not independently fetched at a primary source** … **[AGGREGATOR — treat entity details as UNCONFIRMED except BVI regulation]**."*

The BVI Financial Services Commission's own register returns:

> **Anemoy Asset Management Limited — Category: Approved Managers**
> **Anemoy Capital SPC Limited — Category: Professional Funds**
> *Results: 1 - 2 of 2*

— `https://www.bvifsc.vg/regulated-entities?combine=Anemoy`, 2026-08-04.

**Both entities are confirmed at the regulator**, with their regulatory categories: the fund is a **recognised BVI Professional Fund** and the manager is an **Approved Manager** under the BVI Approved Investment Manager regime. Round one's inference that the "SPC" in the name is a segregated portfolio company is supported by the fund's recognition category and by Anemoy's own bankruptcy-remoteness language. The aggregator caveat can be removed from these two facts. **The Janus Henderson sub-investment-management role remains aggregator-sourced and stays UNCONFIRMED.**

As with BUIDL, the Professional Fund recognition means **an offering document is on file with the BVI FSC**; the register publishes the recognition and not the document.

### Offering documents and service providers — the gate, cited, and the roles-without-entities pattern

A direct fetch of Anemoy's own JTRSY page (2026-08-04) yields: the fund is *"approved and regulated by the BVI Financial Services Commission"*, is a *"Bankruptcy remote SPV"*, works *"with an independent prime broker, custodian, tokenization and issuance and fund admin service providers"*, and the token *"represents an ownership share in the Fund. It is prima facie evidence of ownership under BVI law in the same way as a share certificate would be."* **No prospectus, private placement memorandum, subscription document, factsheet or annual report is linked; the page directs the reader to "Contact us to get access."**

**Round one's UNKNOWNs are confirmed by direct fetch, and the pattern is worth naming: Anemoy discloses the *roles* — prime broker, custodian, fund administrator — and names no *entity* for any of them.** That is not an omission of detail; it is a disclosure design in which the reader learns that a custodian exists and never learns who it is. No administrator, custodian, prime broker, auditor, transfer agent or security trustee is named anywhere public. The Form ADV route does not exist here either: an IAPD firm search for `anemoy` returns **0 results** (2026-08-04), so no SEC-registered adviser files a Section 7.B.(1) for the fund.

Round one's register-of-record answer — the token is *prima facie evidence* of ownership under BVI law, i.e. rebuttable evidence of an entry in a book kept elsewhere — is unchanged and remains the correct reading. **The book it evidences is kept by an unnamed fund administrator.**

**Evidence added, Centrifuge**

| Claim | URL | Accessed |
|---|---|---|
| **BVI FSC register: "Anemoy Asset Management Limited — Approved Managers"; "Anemoy Capital SPC Limited — Professional Funds"** | `https://www.bvifsc.vg/regulated-entities?combine=Anemoy` | 2026-08-04 |
| Anemoy JTRSY: BVI FSC regulated; "Bankruptcy remote SPV"; service providers named **by role only**; "prima facie evidence of ownership under BVI law"; **no offering documents published — "Contact us to get access"** | `https://www.anemoy.io/funds/jtrsy` | 2026-08-04 |
| **NEGATIVE:** no SEC-registered or exempt-reporting adviser named "Anemoy" — 0 results | `https://api.adviserinfo.sec.gov/search/firm?query=anemoy&type=Firm` | 2026-08-04 |

---

## DOES THE BOUNDED DELEGATE MANDATE APPEAR HERE, IN LEGAL FORM?

The cross-lane schema from lanes 06 and 03 is: **named agent → domain whitelist → magnitude cap → rate-of-change limit or delay → revocation.** Tested against the legal layer of all five:

| | named agent | domain restriction | magnitude cap | rate-of-change limit | revocation | parts present |
|---|---|---|---|---|---|---|
| **Ondo OUSG** | **yes** — Ondo Capital Management LLC, SEC 801-134065, discretionary over 1 account | partial — "invested by the Investment Manager into US Treasuries products"; "may, in the future, include other US Treasury funds and/or direct investments" | **no** — no target allocation, band or concentration limit published | **no** | held by the GP, an affiliate of the manager — **not by holders** | 2½ |
| **Ondo USDY** | yes — Ondo, as administrator of the rate and the collateral | **yes** — the SPV restricted-purpose clause, five enumerated activities | **yes** — the 3% first-loss floor ("if we issue $100 of USDY, it will always be secured by at least $103"), tested at quarter-end | **no** | none for holders; enforcement is gated on a tokenholder vote through Ankura | 3 |
| **BUIDL** | **yes** — BlackRock Financial Management, Inc. (Form ADV) | marketing only — "core investments of overnight repo and 3-month Treasuries" | **no** | **no** | fund board may terminate the manager; holders have none | 1½ |
| **USYC** | yes — Hashnote International Management LLC (Cayman) | "primarily reverse repurchase agreements backed by U.S. government securities" | **no** — no counterparty or concentration limit published | **no** | **UNKNOWN** — in the offering documents | 1½ |
| **Maple** | **yes** — Pool Delegate (an on-chain address) and Maple's credit team | yes — borrower allowlist, `addStrategy` strategy list, and now trading venues | partial — `liquidityCap()` caps the **pool**, not exposure to any borrower, venue or strategy | **defective** — `MapleGlobals.scheduleCall` two-week delay, *retroactively shortenable by the Governor* | **yes** — Governor override, asymmetric | 4 of 5, two defective |
| **Centrifuge** | yes — Anemoy Asset Management Limited, BVI **Approved Manager**; on-chain, the `MerkleProofManager` strategist | on-chain: target contract + selector + parameter values. Legal: none published | **no** | **no** | on-chain: replace the merkle root. Legal: by contract | on-chain 5, legal 2 |

**The answer is yes, but truncated, and the truncation is the finding.**

The legal layer reliably supplies **parts 1, 2 and 5** — a named agent (in three of five, named in a sworn regulatory filing), a domain restriction (in the SPV purpose clause, the fund's stated strategy, or the manager's licence category), and a revocation right (by termination of an appointment). It **essentially never supplies parts 3 and 4** — the magnitude cap and the rate-of-change limit. Across five products with roughly $9B of claims, I found exactly **one** published quantitative bound on a discretionary agent: **USDY's 3% overcollateralisation floor**, and even that is a floor on the *sponsor's* credit support rather than a ceiling on the *manager's* discretion, and it is tested only at quarter-end so intra-quarter breach is contemplated.

That is a **third independent sighting of the schema**, and it is worth a great deal precisely because it fails in a patterned way. Lanes 06 and 03 found the five-part shape *complete and on-chain*, bounding leverage and bounding a rate. Lane 09 finds the same shape *incomplete and legal*, and the two parts that go missing are the two that a formal language would actually have to check — the ones that are quantitative and time-indexed. The natural reading is that **the schema is real and the on-chain instances are the ones that had to make it total**: a smart contract cannot leave a bound unstated, and a contract between parties can, because a court can supply a standard of reasonableness that a checker cannot.

Two further observations for stage 4. First, **in none of the five is the revocation right held by the holder** — it is held by an affiliate of the agent (Ondo), the fund's board (BlackRock), the DAO's Governor (Maple), or the manager's own contract counterparty. The schema's fifth part exists but is held by the wrong party, and the vocabulary — which has no party sort, per the bridges lane — cannot record that. Second, the one crisp, dated, quantified revocation right I found anywhere in this category attaches not to an investment mandate but to the **register of record**: BlackRock may terminate Securitize's transfer-agent agreement on **90 days' notice before the end of a one-year renewal term**. **A named agent, a bounded domain, and a revocation with a notice period — over the ledger rather than over the portfolio.**

---

## THE INSTRUMENT UNDERNEATH, SIDE BY SIDE

Every cell is a primary-source finding or an explicit UNKNOWN. Where two primary sources conflict, both are shown.

| | **Ondo USDY** | **Ondo OUSG** | **Circle USYC** | **BlackRock BUIDL** | **Maple syrupUSDC** | **Centrifuge JTRSY** |
|---|---|---|---|---|---|---|
| **Obligor** | **CONTESTED across four live Ondo documents** — Ondo USDY LLC (present tense, and a live "Covered Entity" in the Terms of Service) vs Ondo Global Markets (BVI) Limited (important-notes) vs "formerly issued by Ondo USDY LLC" (basics); the Terms of Service name no USDY issuer at all | **Ondo I LP** (fund ID 805-6065361819), GP Ondo I GP LLC | **Hashnote International Short Duration Yield Fund Ltd.** — but Circle's 10-K Exhibit 21.1 lists it as a **subsidiary of Circle**, while the same 10-K reports it as an unconsolidated VIE | **BlackRock USD Institutional Digital Liquidity Fund Ltd.** (fund ID 805-1443872669) | **Maple International Operations SPC**, for the account of **Secured Loan Segregated Portfolio 1** | **Anemoy Capital SPC Limited** |
| **Jurisdiction** | Delaware **and/or** British Virgin Islands — unresolved; interface terms are **Connecticut** law; Ondo Stocks notes are **Swiss** law, Zurich arbitration | Delaware, United States | Cayman Islands (fund); Bermuda (CIBL, token administrator); Cayman + Delaware (manager chain) | **British Virgin Islands** — confirmed on the BVI FSC register as a **Professional Fund** | **UNKNOWN** — SPC is a Cayman/BVI form and Maple never states which; terms specify **BVI** law, BVI IAC arbitration (with literal `[brackets]` in the clause); register query rate-limited | **British Virgin Islands** — confirmed on the BVI FSC register as a **Professional Fund** |
| **Register of record** | The chain, for issued tokens (bearer instrument; no off-chain recovery) | **The limited partnership's own books**, kept by the GP with NAV Consulting as administrator. Whether the LP register or the token ledger controls on conflict: **UNKNOWN** | **The transfer agent's share registry** — the token is an explicit "digital twin"; the registry moves *to reflect* the token, but the registry is the record | **The "control book and master securityholder file"**, singular across chains; on a fork **Securitize determines which chain is the authoritative record** | **The token ledger.** The only one of the five with no off-chain book — the ERC-4626 share *is* the claim | An off-chain share register; the token is **"prima facie evidence of ownership under BVI law in the same way as a share certificate"** |
| **Transfer agent** | **None** | **None**, and none is required (§3(c)(7)/506(c) interests are not §12-registered). *Adjacent and unexplained:* **Oasis Pro TA LLC** (084-06872) is a registered TA reporting **zero accounts and zero transfers** for FY2025; **UNKNOWN — whether it is Ondo's** | Unnamed **fund administrator** performs the registry function; **no transfer agent is named** (round one; "Transfer Agent" appears as a role, never as an entity) | **Securitize Transfer Agent, LLC** (084-06638), which itself engages **Pacific Stock Transfer Co** (084-01145). FY2025: 18,337 accounts, 3,582 transfers, 54 issues. **Held on a one-year rolling contract terminable by BlackRock on 90 days' notice** | **None** | **None named** — the fund admin role is disclosed without an entity |
| **Perfection instrument** | **Intent stated, instrument not public.** SPV purposes include "creating and **perfecting** a security interest in its assets"; **control agreements** with Ankura Trust and each bank/custodian are confirmed (archived). **UCC-1: NOT PUBLICLY VERIFIABLE** — Delaware has no free public debtor-name UCC index; searches must go through a Delaware Authorized Searcher. BVI perfection regime for the BVI issuer: **UNKNOWN** | **None** — LPs hold an unsecured pro-rata claim; no collateral agent, no pledge, no overcollateralisation documented | **None** — shareholders of a fund, not secured creditors. Total liabilities reported as **$—** at 2025-12-31 | **None** — shareholders of a fund | **Statutory ring-fencing of the segregated portfolio** — "assets and liabilities… ring-fenced by statute"; lender claims "exclusively against the assets of the segregated portfolio". Borrower-side security exists under an unpublished MLA | **Statutory ring-fencing of the segregated portfolio (SPC)**. **Security trustee: UNKNOWN** — none named anywhere |
| **Custodian** | Two US banks (archived, unnamed); collateral/security agent **Ankura Trust Company** | **Five, named in a sworn filing:** BitGo Trust Company · Circle Internet Financial LLC · Coinbase Trust Company · JPMorgan Chase Bank N.A. · Silicon Valley Bank (First Citizens). Auditor **BPM LLP**; administrator **NAV Consulting, Inc.** | **UNKNOWN.** "Assets are protected through segregated custodial accounts at our prime broker" (**Marex**); no separate custodian; the phrase "qualified custodian" appears nowhere. No ADV route exists (no SEC-registered adviser); CIMA register reCAPTCHA-gated | **UNKNOWN, and pointedly so** — BlackRock's Form ADV files **no custodian record, no prime-broker record and no auditor record**. Administrator: **SS&C Technologies, Inc.** BNY Mellon is **not confirmed at any primary source**. Share custody is the investor's: "Custody BUIDL at your preferred custodian or self custody" | **UNKNOWN** — no custodian named; collateral is held on-chain in the loan contracts, but strategy capital sits with centralised exchanges and DeFi protocols that are not named | **UNKNOWN** — "an independent prime broker, custodian… service providers", no entity named |
| **Discretion holder** | Ondo — sets the accrual rate ("APY is set **monthly** by Ondo in accordance with the USDY governing documents") and the collateral mix, within a **3% first-loss floor tested at quarter-end** | **Ondo Capital Management LLC** (SEC 801-134065), discretionary, one account, $952,507,376. No target allocation, band or concentration limit published. *Contested:* Ondo's docs say Ondo pushes its own estimated NAV; its ADV swears **100%** of assets were valued by a non-related person | **Hashnote International Management LLC** (Cayman) via **Marex** as prime broker. No counterparty limit, no concentration limit, no holdings feed | **BlackRock Financial Management, Inc.** Mandate published only as marketing — "core investments of overnight repo and 3-month Treasuries". No covenant, no oracle, no holdings feed | **Pool Delegate** + Maple's credit team — and the mandate is **wider than lending**: "futures basis trading, other delta-neutral or market-neutral approaches, and liquidity provision in decentralized finance protocols". No cap, no venue whitelist, no leverage limit published | **Anemoy Asset Management Limited**, BVI **Approved Manager**; on-chain the NAV setter is `_isManager(poolId)` alone, with a caller-supplied `computedAt` |
| **Offering document** | **Not obtainable.** Referenced on the product page as "the Token offering documents"; the product page itself is now **geofenced** from the US | **Not obtainable.** Form D 021-470288 exists; the LP agreement and subscription documents are KYC-gated | **Not obtainable.** "An offer… is only made to eligible investors through the Fund's offering documents"; the Fund is not an EDGAR filer | **Not obtainable, but its existence is now established at a regulator** — a BVI Professional Fund must file its offering document with the FSC. Publicly, the route is "**Subscription documents must be completed, in good order**" behind `id.securitize.io` login | **Not obtainable.** A **MiCA white paper page exists but renders empty**; the Borrower MLA is described, not published. What *is* published is a formal **Risk Disclosures** document and product disclosures naming the issuer | **Not obtainable, existence established at a regulator** (BVI Professional Fund). Anemoy's own page: "**Contact us to get access**" |

**How to read the blanks.** Nine cells say UNKNOWN and four more record a contradiction between primary sources. They are not evenly distributed: the UNKNOWNs cluster in **custodian** (four of six) and **perfection** (two of six), and the contradictions cluster on **obligor** (two of six). Those are precisely the three facts that determine what a holder owns and what they can do about it if the wrapper fails. The columns that are *complete* for all six — register of record, discretion holder — are complete only because this round went looking in regulatory filings that the products themselves never point at.

**And the asymmetry that makes the paper's point.** For every one of the six, the on-chain wrapper is fully specified: contract addresses, role censuses, upgrade paths, supplies and prices, all readable by anyone with an RPC endpoint. For four of the six, the identity of the party holding the assets is not public. **The vocabulary can express the wrapper exactly and the wrapped not at all, and this table is the measurement of that gap: 58 symbols on the left of the boundary, nine UNKNOWNs and four contradictions on the right.**
