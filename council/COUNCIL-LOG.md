# Council Review Log — Unified DeFi Element Table

**Bundle under review:** `unified-v0.1.md`
**Blinded bundle:** `BUNDLE-blinded.md`, 40,717 bytes
**Bundle sha256:** `f92c6aa1a6cd35b5b6fdc0e48cc253f1adbc64765d077d5e295027ef802acb22`
**Identity leak check:** clean (no author, vendor or model identity in the review input)
**Date:** 2026-08-04
**Status:** advisory — council does not own release authority

---

## 1. Run record

| Lane | Lens | Family | Terminal | Verdict | Findings |
|---|---|---|---|---|---|
| L1a | Protocol engineer / implementer | openai | **infrastructure failure** | — | — |
| L1b | Protocol engineer / implementer | xai | completed | `changes_requested` | 9 |
| L1c | Protocol engineer / implementer | openai (retry) | completed | `changes_requested` | 8 |
| L2a | Security auditor / risk engineer | openai | **infrastructure failure** | — | — |
| L2b | Security auditor / risk engineer | xai | completed | `changes_requested` | 8 |
| L2c | Security auditor / risk engineer | openai (retry) | completed | `changes_requested` | 8 |
| L3 | Market-microstructure economist | xai | completed | `changes_requested` | 6 |
| L4 | Taxonomy methodologist / epistemics | anthropic | completed | `changes_requested` | 22 |
| L5 | Institutional / RWA / compliance | anthropic | completed | `changes_requested` | 11 |
| L6 | Practitioner usability | anthropic | completed | `changes_requested` | 12 |

**Quorum:** met. Six distinct identity-bound completed substantive verdicts across
two independent failure domains at first close (xai, anthropic); a third domain
(openai) was restored on retry. Requirement is three across two.

**Infrastructure failures (L1a, L2a).** Both openai lanes terminated with
`ERROR: You've hit your usage limit ... try again at Aug 7th, 2026`. Under the
council protocol this is a transport failure, not an abstention, not a
dissent and not an approval. It was not counted in deliberation, and the retry
did not consume an architect rework round. Logged to the Foreman bug event log.

**Outcome:** every completed lane returned `changes_requested`. No lane approved.
No lane abstained. Under the council contract a single admissible
`changes_requested` forces a new implementation round; six of six force one
decisively. **v0.1 does not survive review. v1.0 is the required new round.**

---

## 2. Disposition summary

| Disposition | Count | Meaning |
|---|---|---|
| **Accepted** | 49 | Fixed in v1.0 |
| **Accepted in part** | 17 | Direction accepted, remedy modified — rationale given |
| **Deferred (registered)** | 14 | Real, cannot be fixed by editing — needs data collection or tooling; recorded in the open register with a gate |
| **Rejected** | 4 | Argued against, with reasons; dissent preserved |

84 findings across 8 completed lanes. Nothing was dropped silently.

---

## 3. Convergent findings — independently raised by two or more lenses

These carry the most weight because the lanes were blinded from each other.

| # | Finding | Raised by | Disposition |
|---|---|---|---|
| **C1** | The three "conservation laws" are accounting identities, not laws. The value equation cannot be violated because any gap is reabsorbed by the `realized allocated loss` term. | L3 F3, L4 F20 | **Accepted.** Section retitled *Accounting identities and design requirements*; each of the three is now typed analytic / normative / empirical. "Conservation law" language removed. |
| **C2** | Reflexivity is demoted to a hypothesis but is still the first, stop-the-line check — an epistemic demotion and an operational promotion at once. | L2 F6, L4 (F16 standard), L3 F4 | **Accepted.** Status split into *mechanism class: established* vs *table-level scored instrument: uncalibrated*. Moved out of first position; now a cheap non-gating parallel screen. |
| **C3** | The residue / coverage figure is in-sample: the same 24 incidents generated the forbidden-bond rules that then "explain" them. Reclassification is not predictive power. | L4 F16, L2 F3, L2 F8, L5 F7 | **Accepted.** The figure is now labelled *in-sample, by construction*, the number is no longer quotable as coverage, and an out-of-sample pre-registration protocol is specified. |
| **C4** | The corpus is never stated, so no quantitative claim is reproducible. | L4 F18, L2 F8, L5 F7 | **Accepted in part.** Corpus provenance appendix added, with an explicit statement of what is *not* recoverable from the source reports (12 of the 24 incidents are named; 12 are not). Honest gap rather than a fabricated list. |
| **C5** | Catalyst is a category error: three of four catalysts are also elements, so the class is not disjoint from Element and cannot be a peer construct. | L4 F14, L1 F5, L2 F7 | **Accepted.** Catalyst deleted from the construct table; `*` is now an occurrence annotation evaluated per formula, with a stated marking rule. |
| **C6** | The notation is not executable: no grammar, conflicting enums, three incompatible isotope syntaxes, undefined operators. | L1 F1, L1 F3, L1 F4, L1 F7, L6 F3, L6 F8 | **Accepted.** Formal grammar added; one canonical isotope syntax; `→` added to the operator table; `?` semantics defined against law satisfaction; trust_domain enums unified; provisional-symbol rule stated. |
| **C7** | The worked formulas violate the document's own mandatory rules (bare `Xm`, `Of` without timeout, `In`/`Rf` without `—n→`), and none shows the four-term schema. | L6 F1, L1 F8 | **Accepted.** All formulas re-derived and conformance-checked; three shown in full four-term form. |
| **C8** | No end-to-end worked example exists, in a document whose stated purpose is "how to use it". | L6 F2, L1 F6 | **Accepted.** Full worked appendix added: one protocol from raw description through four passes, seven screens, and a written verdict, plus a blank template. |
| **C9** | The X-rules report failures with no denominator — no survivor count, no false-positive rate — while the document applies exactly that standard to reflexivity. | L4 F17, L2 F4 | **Accepted in part.** `base_rate` column added and marked unknown; rows with many known survivors reclassified from *forbidden* to *elevated hazard*; the double standard is named explicitly. |
| **C10** | The seven-criterion test is asymmetrically applied — invoked to exclude (constant sum) and waived to include (`Rs`, `Of`, `Rl`, `Gs`). | L4 F1, F2, F3, F9, F10 | **Accepted.** See §4 — the largest structural change in v1.0. |

---

## 4. The structural change C10 forces

L4's finding is the most damaging in the review and it is correct. v0.1 declared
elementhood as an **iff** over seven conjunctive criteria, then admitted `Rs` to
core while its own open register said criterion R was unmet, and admitted `Of` on
two named instantiations when R demands three teams and two lineages — while
using that same criterion R as a "hard gate" to demote constant sum.

v1.0 resolves this rather than papering over it:

1. **Criterion R is split.** `R-struct` (the mechanism is separable in principle)
   is necessary for elementhood. `R-emp` (observed independent recurrence) becomes
   a graded confidence attribute, not a gate. This also removes the contradiction
   L4 F4 identified between R and the document's own admission that "a new
   primitive can ship next week" — under v0.1 a genuinely novel atom was
   constitutionally excluded until imitators arrived.
2. **Element status becomes graded and published:** `core` (R-emp ≥ 3 teams /
   2 lineages, evidenced) · `candidate` (R-struct met, R-emp short) ·
   `provisional` (a criterion genuinely contested).
3. **`Rs`, `Of`, `Rl`, `Gs` move from core to candidate** with their R-evidence
   cells shown as short. This is the honest reading of the evidence the sources
   supply.
4. **The headline count is now a range with its generating parameter:**
   49 core + 4 candidate + 12 provisional, and the count is reported *at* the
   3/2 threshold rather than as a fact, with a sensitivity note.
5. **Demotion gates are added** to the open register, mirroring the promotion
   gates. v0.1 could only grow.

---

## 5. Findings by lane

Severity as reported by the lane. Disposition is mine as architect.

### L1 — Protocol engineer (xai) · `changes_requested`

| ID | Sev | Finding | Disposition |
|---|---|---|---|
| F1 | high | Notation runs out on Ethena, Pendle v2 yield-space AMM, EigenLayer multi-AVS | **Accepted in part** — grammar + isotope registry added; multi-service `Rs` composition and delta-neutral backing recorded as named residue rather than invented elements |
| F2 | high | Element boundaries undecidable: `Sh`/`Ix`/`Rb`, `Pl`/`Im`, `In`/`Rf`/`Ag`/`Ba`, `Au`/`Gp`/`Up`, embedded vs standalone `Fl` | **Accepted** — decision rules + on-chain observables table added per contested family |
| F3 | high | Two incompatible `trust_domain` enums (§4 E041 vs §9); formulas encode it as free braces | **Accepted** — single closed enum; `Xm{trust_domain=...}` mandated |
| F4 | med | `—n→` naming clause is a trivial syntax check; content is unconstrained free text | **Accepted** — closed consequence catalog introduced |
| F5 | med | `Fl` dual citizenship breaks formula parsing; `Ag`/`Xm` are catalysts but written bare | **Accepted** — see C5; `*` marking rule stated |
| F6 | high | 17.1 does not terminate — no exit criteria, no stop condition on residue | **Accepted** — per-pass inputs/outputs and exit criteria added |
| F7 | high | No grammar, no valence table, no reference suite, no linter, no element→observable map | **Accepted in part** — grammar, valence derivation rule + worked table, and observables added in-document; a linter is out of scope for a specification and is registered as tooling work |
| F8 | med | §10 molecules are `+`-joined symbol bags, contradicting the §2 molecule definition | **Accepted** — see C7 |
| F9 | low | `layer` / `atom_dependency` have no formula syntax; no table→formula→table round-trip | **Accepted** — attribute syntax added |

### L2 — Security auditor (xai) · `changes_requested`

| ID | Sev | Finding | Disposition |
|---|---|---|---|
| F1 | high | 17.2 would have missed Euler, Nomad, Wormhole, Ronin, reentrancy, share-inflation — it is a design screen, not an exploit catcher | **Accepted** — "necessary but not sufficient" stated prominently; implementation-integrity and operational-security programs made mandatory companions |
| F2 | high | Screen order is wrong: puts an unproven hypothesis first and buries authority and conservation, which own the real loss | **Accepted** — screen reordered by loss severity |
| F3 | high | Count-majority framing is safety theatre given the document's own dollar admission | **Accepted** — v1.0 leads with the loss-weighted scope statement |
| F4 | high | X7, X13, X11, X2, X16, X6 loose enough that unsafe designs pass; X3/X14/X15 unfalsifiable adjectives | **Accepted** — rules restated as testable predicates; "verification presence ≠ verification correctness" made explicit |
| F5 | high | Entire missing failure class: control-flow safety (reentrancy, read-only reentrancy, CEI, callbacks), share inflation, rounding, storage collision | **Accepted** — implementation-integrity overlay added with its own rules |
| F6 | med | Reflexivity first + stop-the-line contradicts its hypothesis status | **Accepted** — see C2 |
| F7 | med | "A catalyst is never itself the vulnerability" is analytic and operationally dangerous | **Accepted** — restated as the definitional convention it is; catalyst re-pricing subcheck added |
| F8 | med | Residue is an unfalsifiable comfort metric; post-hoc relabelling ≠ preventive power | **Accepted** — see C3; pre-incident catch-rate separated from post-hoc classify-rate |

### L3 — Market-microstructure economist (xai) · `changes_requested`

| ID | Sev | Finding | Disposition |
|---|---|---|---|
| F1 | high | X14 "impossible" is economically false — exclusivity removes live rivalry, not all competitive content | **Accepted** — reclassified to *unverifiable without a named benchmark or commitment device*; "impossible" reserved for logical contradictions |
| F2 | med | `—n→` is justified, but "irreducible to a priced externality" overclaims and the naming clause invites treating it as an annotation on `—e→` | **Accepted** — irreducibility rhetoric dropped; observation graph ≠ incentive graph stated instead |
| F3 | med | Value identity has no out-of-sample content | **Accepted** — see C1 |
| F4 | med | Reflexivity downgrade is right taxonomically but too weak economically — fire-sale and leverage-cycle mechanisms are standard | **Accepted** — status split (see C2) |
| F5 | high | Solver market structure is design-endogenous industrial organization, not weather; shelving it as a reaction condition buries market power outside the model | **Accepted** — promoted to required parameters on `In`/`Ba`/`Rf`/`Of` plus a surplus-allocation bond |
| F6 | high | No element or bond for fee/surplus distribution, cross-subsidy, principal-agent structure, or time preference | **Accepted in part** — surplus allocation added as a candidate element and an economic-bond requirement; agency alignment added to the laws; cross-subsidy added as a flag. Time preference judged already carried by `Ft`/`Pf`/`Ix` and recorded as a rejected sub-item with reasons |

### L4 — Taxonomy methodologist (anthropic) · `changes_requested`

22 findings. The five structural ones (F1–F5) are handled in §4. Remainder:

| ID | Sev | Finding | Disposition |
|---|---|---|---|
| F6 | high | `Fl` violates criterion P — its definition is a transaction-scope predicate and §13 makes that its headline property | **Accepted** — P restated over abstract atomic settlement scope; `Fl`'s pass explained explicitly |
| F7 | med | `Gs` is named after gas metering (an execution-model construct); `Au`/`Gs` are the 4337 family while §3 rejects standards | **Accepted** — renamed *sponsored-fee liability*, restated without metering; the standard-vs-mechanism rule stated generally and applied to 4337 |
| F8 | med | `Tg`/`Up`/`Gp` are defined over the reachable state machine, which is the same ground on which hooks are rejected | **Accepted** — criterion B given an explicit meta-transition clause, and the hook exclusion re-derived from it |
| F9 | med | `Sd` core vs `Zk` provisional applies a bespoke eighth criterion ("finance-specificity") | **Accepted** — gate applied symmetrically; `Sd` moved to candidate pending the same evidence |
| F10 | med | `Da`'s provisional gate is stricter than the published criteria | **Accepted** — all provisional gates restated strictly in terms of the seven criteria |
| F11 | high | D3 violates the isotope definition twice: an isotope must preserve the failure family, and the mandatory flag exists because it does not | **Accepted** — third status *degenerate limit* introduced; constant sum classified there, not as an isotope |
| F12 | high | D5's mandatory non-defaultable discriminator makes `Xm` un-instantiable — operationally identical to a six-way split reported as one; and X13 shows trust_domain values are not S-substitutable | **Accepted** — discriminator rule stated (mandatory iff distinct values select different forbidden-bond rows), count reported both ways, rule applied to `Ex`, `Xf`, `At` |
| F13 | med | The `—n→` naming clause concedes the parsimony objection; the settling condition puts an unbounded burden on challengers | **Accepted in part** — settling condition made symmetric and assigned to the proponent. Retention of the type itself upheld (L3 F2 concurs) |
| F14 | med | Catalyst category error | **Accepted** — see C5 |
| F15 | high | Retaining "periodic table" borrows authority the model has not earned, and it is spent in 17.4 | **Accepted in part** — primary name is now *The DeFi State-Transition Atlas*; "periodic table" demoted to a provenance note and nickname. 17.4 restated as combinatorial enumeration with expert-assigned verdicts. **Rejected**: deleting the nickname entirely — it is the term the reader arrives with |
| F16 | high | Residue cannot falsify: it is defined as a finding, never a defect, with no threshold | **Accepted** — see C3; refutation thresholds added |
| F17 | high | X-rows have no survivor denominator | **Accepted in part** — see C9 |
| F18 | high | Corpus never stated | **Accepted in part** — see C4 |
| F19 | med | 53 is precise and unearned; E052 unallocated | **Accepted** — count reported as a range with its threshold; ID gap explained |
| F20 | med | Conservation laws are analytic | **Accepted** — see C1 |
| F21 | med | Periods are not computed as DAG depth — `Ag` and `Fl` sit at P1 alongside the venues they presuppose | **Accepted in part** — period redefined as *dependency stratum assigned by category of prerequisite*, stated plainly, since the source reports do not supply a DAG to compute. Publishing a computed DAG is registered as v1.1 work |
| F22 | low | D10 and D2 resolved by appeal to an unpublished confidence scheme and to desired exclusions | **Accepted** — confidence scheme published (§4); D2 rebased on what B/P/O measure independently |

### L5 — Institutional / RWA / compliance (anthropic) · `changes_requested`

| ID | Sev | Finding | Disposition |
|---|---|---|---|
| F1 | high | No element or attribute names the **obligor**; a bankruptcy-remote SPV note and an unsecured IOU produce identical formulas, and 17.5 then affirmatively calls them the same kind of system | **Accepted** — mandatory `obligor` discriminator added on every element with off-chain backing; 17.5 scoped to isomerism *within* a fixed obligor and perfection assignment |
| F2 | high | Enforceability is given three incompatible homes (trust_domain value, reaction condition, residue) | **Accepted in part** — enforceability consolidated as a single named legal surface with one canonical element set. **A fifth `—l→` bond type is rejected** for now and registered as the review's principal open dissent (§7) |
| F3 | high | No element for freeze / forced transfer / clawback — the control every regulator asks about first; cannot distinguish a bearer token from a registered security | **Accepted** — `Fz` added as a candidate element with a mandatory `authority_source` discriminator, a bonding law and a forbidden bond |
| F4 | high | `Aw + Xf` silently launders a restricted security into an unrestricted bearer wrapper; L16 is marked async-safe and should not be | **Accepted** — L16 async-safe corrected to No; L26 added (destination-enforced eligibility, revocation propagation, jurisdictional binding); X19 added; eligibility preservation added as a fourth design requirement |
| F5 | high | `At` carries every backing claim in the table and has no bonding law at all, while the less consequential `Ex` has one; and it is overloaded across reserve, NAV and borrower financials | **Accepted** — `At` given a mandatory subject/assurance discriminator and a full bonding law; L3 corrected to require borrower-financials specifically |
| F6 | high | L6 encodes structured credit as it appears in the offering memorandum, not as it behaves in a workout; no element for servicer or trustee discretion | **Accepted** — `Sv` (servicing and determination discretion) added as a candidate element; L6 rewritten to require a named determination authority; async-safe corrected to No |
| F7 | med | The corpus is a hack corpus; the institutional loss distribution is different in kind and the exclusion list is incomplete | **Accepted** — fifth root category (e) counterparty/legal added; residue figure scoped to its corpus with an explicit non-transferability warning |
| F8 | med | Every priority construct is internal; the table cannot express perfection or bankruptcy remoteness | **Accepted** — `claim_perfection` attribute added with governing insolvency forum |
| F9 | med | No representation of register-of-record authority; `Sh` at P0 implicitly asserts the chain is the record | **Accepted** — `record_authority` discriminator added |
| F10 | low | Three non-identical enumerations of the legal surface, one of which ("RWA") is not a defined term | **Accepted** — one canonical legal-surface set defined and referenced from all three places |
| F11 | med | A formula conveys nothing a regulator asks for and §18 does not warn against that use | **Accepted** — explicit non-use added; RWA molecule profile defined |

### L6 — Practitioner usability (anthropic) · `changes_requested`

| ID | Sev | Finding | Disposition |
|---|---|---|---|
| F1 | high | Worked formulas violate the document's own mandatory rules | **Accepted** — see C7 |
| F2 | high | None of 17.1–17.5 is ever executed; no artifact, no template, no verdict notation | **Accepted** — see C8 |
| F3 | high | Notation underspecified in eight distinct ways | **Accepted** — see C6 |
| F4 | high | `drain_regime` is mandatory and defined nowhere | **Accepted** — defined, valued, and tied to the degenerate-limit status from L4 F11 |
| F5 | med | `layer` is asserted on every element and carried by none; CAKE never expanded on first use | **Accepted** — CAKE expanded; `layer` given per-group defaults |
| F6 | med | Groups contradict their own substitutability definition (`Fl` in Execution, `Gs` in Control) | **Accepted** — role-boundary sentence and substitution example per group; `Fl`/`Ag` moved out of Execution into a Liquidity-catalysis group; `Gs` moved out of Control |
| F7 | med | Valence has no derivation rule and is never used again; `Ve` symbol collides with vote-escrow | **Accepted** — derivation rule, worked table, and a consuming step added; valence components renamed to avoid the `Ve` collision |
| F8 | med | No isotope register; three incompatible syntaxes; the "continuous parameter change" test contradicts sanctioned discrete instances | **Accepted** — isotope register published; test restated to cover discrete variants |
| F9 | med | Wrong order for a first-time reader — opens with a 12-row adjudication of sources the reader has not read | **Accepted** — quickstart and worked example moved to the front; adjudication moved to an appendix |
| F10 | med | 17.4 is combinatorially intractable as instructed, and introduces two verdict labels absent from its own list | **Accepted** — bounded substitution procedure; verdict vocabulary reconciled |
| F11 | low | "Nine constructs, everything else is one of these" is false; "residue" used in two senses; ID gap at E052 | **Accepted** — all three corrected |
| F12 | low | 17.5 has no example despite a ready-made pair seven sections earlier | **Accepted** — CCTP Standard vs Fast diff inlined |

---

## 6. Cross-vendor confirmation lanes (openai retry)

The engineering and security lenses were re-run on a third, independent provider
family after the quota reset. Both returned `changes_requested` independently of
their xAI counterparts. Where they converged with the xAI runs, that convergence
is itself evidence — the two families saw the same document blind and reached
the same conclusions about notation rigour and screen inadequacy.

**Independently confirmed** (already dispositioned in §5): notation lacks a
grammar (L1c F6 ≡ L1b F1/F7) · element boundaries not decidable from contracts
(L1c F2 ≡ L1b F2) · `trust_domain` enums conflict and isotope syntax is
inconsistent (L1c F3 ≡ L1b F3) · catalyst notation incoherent (L1c F4 ≡ L1b F5)
· decomposition does not terminate (L1c F5 ≡ L1b F6) · the screen misses
implementation and operational classes (L2c F1/F6 ≡ L2b F1/F5) · count-coverage
is not control-effectiveness (L2c F3 ≡ L2b F3/F8) · hazard rows are loose
(L2c F4/F5 ≡ L2b F4) · reflexivity ordering is unsafe (L2c F2/F8 ≡ L2b F2/F6).

**New, and not raised by any other lane:**

| ID | Sev | Finding | Disposition |
|---|---|---|---|
| L1c F1 | high | Decomposing Lido, Ethena and Pendle v2 leaves **central** residue: no element for staking/validator lifecycle, none for a directional derivative position and hedge maintenance, none for time-dependent AMM pricing | **Accepted** — `Vl` and `Dp` added as candidates; `Tw`'s provisional gate restated. This is the sharpest substantive gap the review found, and no other lane caught it |
| L1c F7 | high | Symbols name element *classes*, not deployed *instances*: no instance IDs, no cardinality, no deployment anchors. Two formulas can compare equal while requiring incompatible integrations | **Accepted** — instance model added (§12.2); the near-isomer claim scoped to the granularity written |
| L1c F8 | high | No machine-readable package: no schema, units, defaults, requiredness, serialization, fixtures or conformance tests | **Deferred, registered** (open register item 9) — a specification cannot ship its own toolchain in the same revision, but "ill-formed" is unenforceable until it exists |
| L1c F5 | high | Recursive counterpart expansion has no system boundary or cycle rule | **Accepted** — scope, expansion policy, externalization rule and cycle rule now declared before pass 1 |
| L2c F5 | high | Issuer anointing treated as curative in X12; endorsement cannot secure a bridge | **Accepted** — removed; X12 now tests value at risk against economic security plus independent exit |
| L2c F6 | high | Compiler and build provenance absent from the integrity overlay | **Accepted** — compiler pinning, known-defect checks, reproducible build and bytecode-matches-source added |
| L2c F7 | high | Presenting §17.2 as a pre-audit checklist invites standalone adoption | **Accepted** — renamed *financial-architecture pre-screen*; mandatory companion reviews enumerated; cannot support launch or risk acceptance alone |
| L2c F2 | high | The reflexivity short-circuit lets a redesign look remediated while independent defects go unrecorded | **Accepted** — every row now mandatory and non-short-circuiting; whole screen re-run after redesign; framing step added for assets, trust boundaries and maximum loss |
| L2c F1 | high | Publish an incident-by-incident validation matrix | **Deferred, registered** (open register item 7) |

*(Raw verdicts: `L1-engineer-oai.json`, `L2-security-oai.json`.)*

---

## 7. Preserved dissent

The council contract requires dissent to survive rather than be averaged away.
Four disagreements are unresolved and are recorded, not closed.

1. **A fifth bond type for legal enforceability (`—l→`).** L5 F2 argues that the
   parsimony argument which killed the fifth type is in fact the argument for
   keeping it, because legal recourse is the audit item institutional capital
   actually checks. L3 and L4 push the other way on parsimony grounds. v1.0
   declines to add `—l→` and instead makes the legal surface explicit through
   discriminators and attributes. **L5's dissent stands and is not resolved.**
   L5's own framing of the stake is preserved verbatim in the open register:
   *"a table that publishes a Centrifuge molecule and an `At` element has already
   opted in, and half-opting-in is the unsafe position."*

2. **Whether `—n→` should exist at all.** L3 defends it as a first-class object
   (information structure is not the incentive graph); L4 F13 argues the naming
   clause concedes that it is parasitic on the economic bond. v1.0 retains it,
   drops the irreducibility claim, and assigns the settling test to the
   proponent rather than the challenger. Both positions are recorded.

3. **Whether the name "periodic table" should survive at all.** L4 F15 wants it
   deleted; v1.0 demotes it to a nickname and provenance note but keeps it,
   on the ground that it is the term readers arrive with. This is a partial
   rejection of a high-severity finding and is flagged as such.

4. **Whether notation and worked examples are primary or cosmetic.** L6's own
   dissent note anticipates that ontology lenses will call its findings
   cosmetic; L4's anticipates that practitioner lenses will call its findings
   academic. v1.0 treats both as primary. Recorded because the weighting is a
   judgment, not a derivation.

---

## 8. What the council did not review

- The four source reports themselves. Reviewers saw only v0.1.
- Any claim about token counts, dollar figures or citation accuracy — several
  lanes explicitly marked such items `unverified`, and v1.0 carries those marks
  forward rather than laundering them into confidence.
- Whether the underlying reconciliation of the four sources was itself correct.
  That was assumed, and it is the largest unexamined surface in this exercise.
