# -*- coding: utf-8 -*-
import json, re, collections

BASE = "/root/DefiElements/paper/kg-corpus/"
VOCF = BASE + "formal-01-the-instantiated-vocabulary-and-constraints.md"
VOC  = "kg_corpus_formal_01_the_instantiated_vocabulary_and_constraints"
ATLF = BASE + "atlas-37-validation.md"
ATL  = "kg_corpus_atlas_37_validation"
S13F = BASE + "supp-13-the-instantiated-vocabulary-and-constraints.md"
S13  = "kg_corpus_supp_13_the_instantiated_vocabulary_and_constraints"
S00F = BASE + "supp-00-preamble.md"
S00  = "kg_corpus_supp_00_preamble"

nodes = []
edges = []
seen_nodes = set()
seen_edges = set()

def N(nid, label, ftype, src, rationale=None):
    if nid in seen_nodes:
        return nid
    seen_nodes.add(nid)
    n = {"id": nid, "label": label, "file_type": ftype, "source_file": src,
         "source_location": None, "source_url": None, "captured_at": None,
         "author": None, "contributor": None}
    if rationale:
        n["rationale"] = rationale
    nodes.append(n)
    return nid

def E(s, t, rel, conf, score, src, w=1.0):
    k = (s, t, rel)
    if k in seen_edges or s == t:
        return
    seen_edges.add(k)
    edges.append({"source": s, "target": t, "relation": rel, "confidence": conf,
                  "confidence_score": score, "source_file": src,
                  "source_location": None, "weight": w})

# ---------------------------------------------------------------- elements
ELEMENTS = [
 ("Sh","Pro-rata share accounting","G01",0),
 ("Ix","Index-based accrual","G01",0),
 ("Rb","Rebasing accounting","G01",0),
 ("Cp","Constant-product invariant","G02",1),
 ("Wg","Weighted-geometric invariant","G02",1),
 ("St","Stable-hybrid invariant","G02",1),
 ("Cl","Concentrated liquidity","G02",1),
 ("Pm","Oracle-priced inventory curve","G02",1),
 ("Ob","On-chain order book","G03",1),
 ("Rf","Request for quote","G03",1),
 ("Ba","Batch-auction clearing","G03",2),
 ("In","Intent & solver execution","G03",4),
 ("Ag","Aggregation & routing","G04",1),
 ("Fl","Atomic flash liquidity","G04",1),
 ("Pl","Pooled lending","G05",3),
 ("Im","Isolated lending market","G05",3),
 ("Cd","Collateralized-debt minting","G05",3),
 ("Uc","Undercollateralized credit","G05",3),
 ("Ft","Fixed-term debt","G05",3),
 ("Ct","Collateral-threshold test","G06",3),
 ("Li","Incentivized liquidation","G06",3),
 ("Ad","Auto-deleveraging","G06",3),
 ("Sl","Socialized-loss allocation","G06",3),
 ("Bs","Staked backstop","G06",3),
 ("Pf","Perpetual funding transfer","G07",3),
 ("Op","Option payoff","G07",3),
 ("Tr","Tranche waterfall","G07",3),
 ("Cv","Mutual cover pool","G07",3),
 ("Py","Principal/yield separation","G07",3),
 ("Sv","Servicing & determination discretion","G07",3),
 ("Dp","Directional position & hedge maintenance","G07",3),
 ("Ex","External data oracle","G08",2),
 ("Tp","Time-weighted price","G08",2),
 ("Oa","Optimistic assertion oracle","G08",2),
 ("At","Reserve / NAV attestation","G08",2),
 ("Sr","Streaming accrual","G09",2),
 ("Ep","Epoch-gated transition","G09",2),
 ("Wq","Withdrawal queue","G09",2),
 ("Em","Protocol-funded emissions","G10",2),
 ("Fd","Surplus & fee distribution","G10",2),
 ("Tg","Delayed-governance execution","G11",4),
 ("Up","Mutable implementation proxy","G11",4),
 ("Gp","Guardian or pause","G11",4),
 ("Au","Delegated execution scope","G11",4),
 ("Gs","Sponsored-fee liability","G11",3),
 ("Xm","Cross-domain message verification","G12",4),
 ("Xf","Cross-domain asset transfer","G12",4),
 ("Rl","Resource lock / reservation","G12",4),
 ("Of","Optimistic fill & reimbursement","G12",4),
 ("Rd","Direct redemption right","G13",3),
 ("Ps","Peg-swap module","G13",3),
 ("As","Algorithmic supply adjustment","G13",3),
 ("Aw","Permission / identity gate","G14",2),
 ("Sb","Shielded-balance state","G14",2),
 ("Sd","Selective-disclosure proof","G14",2),
 ("Fz","Freeze / forced transfer","G14",2),
 ("Rs","Restaking / shared security","G15",4),
 ("Vl","Staking & validator lifecycle","G16",3),
]
assert len(ELEMENTS) == 58, len(ELEMENTS)

def eid(sym):
    return VOC + "_" + sym.lower()

groups = collections.OrderedDict()
for sym, name, grp, strat in ELEMENTS:
    groups.setdefault(grp, []).append(sym)

N(VOC + "_instantiated_vocabulary_tables",
  "The instantiated vocabulary and constraints (58 elements, 29 requirement rows, 27 warrant entries, 20 prohibition rows)",
  "concept", VOCF,
  "The authoritative tables the checking scripts read: 58 elements with group and stratum, 29 recorded requirement rows, the warrant consumer relation over 27 elements, and 20 listed prohibition rows. Reproduced verbatim so a witness can be checked without the repository.")

for grp, members in groups.items():
    N(VOC + "_" + grp.lower(), "Element group " + grp, "concept", VOCF,
      "group=" + grp + "; members=" + ",".join(members))
    E(VOC + "_" + grp.lower(), VOC + "_instantiated_vocabulary_tables",
      "references", "EXTRACTED", 1.0, VOCF)

for sym, name, grp, strat in ELEMENTS:
    N(eid(sym), sym + " - " + name, "concept", VOCF,
      "group=%s; stratum=%d" % (grp, strat))
    E(eid(sym), VOC + "_" + grp.lower(), "implements", "EXTRACTED", 1.0, VOCF)

# ---------------------------------------------------------------- requirements
# term = (ext_flag, [alternatives])
REQS = {
 "L1": (["Pl","Im","Cd","Pf","Op"], [(0,["Ex","Tp","At"]),(0,["Ct"]),(0,["Li","Ad","Sl","Bs"])]),
 "L2": (["Pl"], [(0,["Sh","Ix"]),(1,[])]),
 "L3": (["Uc"], [(0,["Aw"]),(0,["At"]),(0,["Bs","Tr"]),(1,[])]),
 "L4": (["Pf"], [(0,["Ex"]),(0,["Ct"]),(0,["Li"]),(0,["Ad","Sl","Bs"])]),
 "L5": (["Py"], [(0,["Sh","Ix","Rb"]),(0,["Ep"]),(0,["Rd"])]),
 "L6": (["Tr"], [(1,["Sv"]),(1,[]),(1,[]),(1,[])]),
 "L7": (["Cd"], [(1,["Rd","Ps"])]),
 "L8": (["Xf"], [(1,["Xm"])]),
 "L9": (["Xf"], [(1,[])]),
 "L10": (["Sb"], [(1,[]),(1,[])]),
 "L11": (["Sd"], [(1,[]),(1,[]),(1,[])]),
 "L12": (["In"], [(1,[]),(1,[]),(1,[]),(1,[])]),
 "L13": (["Ex"], [(1,[])]),
 "L14": ([], [(1,["Wq"])]),
 "L15": (["Up"], [(1,["Tg"])]),
 "L16": (["Aw"], [(1,[])]),
 "L17": (["Au"], [(1,[]),(1,[]),(1,[]),(1,[])]),
 "L18": (["Xm"], [(1,[]),(1,[]),(1,[])]),
 "L19": (["Of"], [(0,["Xm"]),(0,["Xf"]),(0,["Bs","Sl"]),(1,[])]),
 "L20": (["Rl"], [(0,["Au"]),(1,[]),(1,[]),(1,[]),(1,[])]),
 "L21": (["Gs"], [(0,["Au"]),(1,[]),(1,[])]),
 "L22": (["Rs"], [(1,[]),(1,[]),(1,[])]),
 "L23": ([], [(0,["Xm"]),(1,[])]),
 "L24": (["In","Rf","Ba"], [(1,[])]),
 "L25": ([], [(1,[]),(1,[]),(1,[])]),
 "L26": ([], [(1,[]),(1,[]),(1,[])]),
 "L27": (["At"], [(1,[]),(1,[]),(1,[]),(1,[]),(1,[])]),
 "L28": (["Fz"], [(1,[]),(1,[]),(1,[]),(1,[])]),
 "L29": (["In","Ba","Rf","Of"], [(1,[])]),
}
assert len(REQS) == 29

fully_empty_rows = []
for rid in ["L%d" % i for i in range(1, 30)]:
    subs, terms = REQS[rid]
    n_terms = len(terms)
    empty = [i+1 for i,(x,alts) in enumerate(terms) if x == 1 and not alts]
    ext_with_el = [i+1 for i,(x,alts) in enumerate(terms) if x == 1 and alts]
    rat = "requirement row %s; subjects=%s; %d term(s). " % (
        rid, ",".join(subs) if subs else "NONE (no subject element recorded)", n_terms)
    if len(empty) == n_terms:
        rat += ("unformalized: %d of %d terms are [ext] () with no element alternatives - "
                "the whole row is external natural language and names no element in any term."
                % (len(empty), n_terms))
        fully_empty_rows.append(rid)
    elif empty:
        rat += ("unformalized: %d of %d terms are [ext] () with no element alternatives "
                "(terms %s are external natural language naming no element); the remaining "
                "terms do name elements." % (len(empty), n_terms, ",".join(map(str, empty))))
    else:
        rat += "every term names at least one element alternative; no empty [ext] term."
    if ext_with_el:
        rat += (" Terms %s are marked [ext] but still offer element alternatives."
                % ",".join(map(str, ext_with_el)))
    if not subs:
        rat += " The subject column is blank: the row is triggered by no named element."
    N(VOC + "_" + rid.lower(), "Requirement row " + rid, "concept", VOCF, rat)
    E(VOC + "_" + rid.lower(), VOC + "_instantiated_vocabulary_tables",
      "references", "EXTRACTED", 1.0, VOCF)
    for s in subs:
        E(VOC + "_" + rid.lower(), eid(s), "references", "EXTRACTED", 1.0, VOCF)
    for x, alts in terms:
        for a in alts:
            E(VOC + "_" + rid.lower(), eid(a), "references", "EXTRACTED", 1.0, VOCF)

# ---------------------------------------------------------------- warrants
WARRANTS = {
 "Ad": ["Ct","Pf","Ob"],
 "As": ["Ex","Tp","Oa","At"],
 "Bs": ["Pl","Im","Cd","Uc","Pf","Op","Rs","Vl","In","Of","Xm","Xf","Cv","Tr","Ob","Ct","Sl","Rl","Ba","Ft","Wq"],
 "Cd": ["Sh","Ix","Rb","Rd","Ps","As"],
 "Ct": ["Pl","Im","Cd","Uc","Ft","Pf","Op","Dp","Tr","Cv","Rs","Vl","Pm","Ob","Fl","Rd"],
 "Cv": ["Pl","Im","Cd","Uc","Bs","Sh"],
 "Ex": ["Ct","Li","Ad","Pf","Op","Pm","Cd","Pl","Im","Uc","Ft","As","Ps","Rd","Tr","Cv","Sl","Bs","Vl","Dp","Py","Sv","Rl","Oa","Rs","Sr","Cl","St","Wg","Cp","Ob","Of","In"],
 "Fl": ["Cp","Cl","St","Wg","Pm","Pl","Im","Cd","Ob","Ag","Sh","Ix"],
 "Ft": ["Sh","Ix","Rb","Py","Ep","At","Sv","Uc","Tr"],
 "Gs": ["Au","Ob","In","Rl","Aw"],
 "Im": ["Sh","Ix","Rb","Ct"],
 "Li": ["Ct"],
 "Of": ["Xf","In","Rl","Xm"],
 "Op": ["Ct","Ob","Ex","Sh","Rf","Pm","Cl"],
 "Pf": ["Ct","Ob","Pm","Ex"],
 "Pl": ["Sh","Ix","Rb"],
 "Ps": ["At","Cd","Rd","Xf","Fz","Aw","Ix","Sr"],
 "Py": ["Ix","Sh","Rb","Ft"],
 "Rb": ["Sh","Ix","Vl","Pl","Im","Cd","Ps","Rd"],
 "Rl": ["In","Xf","Xm","Of","Au","Ob","Rf"],
 "Sl": ["Pl","Im","Cd","Uc","Ft","Pf","Op","Tr","Cv","Rs","Vl","Ob","Dp","Bs","Ct","Xf","Xm"],
 "Sv": ["Tr","Pl","Im","Uc","Ft","Cv","Op","Cd","Rl","Sh","Ep","Wq"],
 "Tp": ["Cp","Cl","St","Wg","Pm","Ob"],
 "Tr": ["Pl","Im","Uc","Ft","Cd","Cv","Rs","Vl","Sh","Ix","Sv","Dp"],
 "Uc": ["Sh","Ix","Rb","Ft"],
 "Vl": ["Rs","Bs","Sl","Sh","Wq","Ep","Rb","Ix","Xf","Ob"],
 "Xm": ["Xf","Rs","In","Of","Rl","Vl","Ob","Sb","Up","Tg","Gp"],
}
assert len(WARRANTS) == 27

for sym, cons in WARRANTS.items():
    wid = VOC + "_warrant_" + sym.lower()
    N(wid, "Warrant entry: " + sym + " consumers", "concept", VOCF,
      "warrant/consumer entry for %s; consumers=%s; an element present with no consumer "
      "among these is unwarranted." % (sym, ",".join(cons)))
    E(wid, eid(sym), "references", "EXTRACTED", 1.0, VOCF)
    E(wid, VOC + "_instantiated_vocabulary_tables", "references", "EXTRACTED", 1.0, VOCF)
    for c in cons:
        E(eid(sym), eid(c), "shares_data_with", "EXTRACTED", 1.0, VOCF)

# ---------------------------------------------------------------- prohibitions
PROHIB = [
 ("X1","F","As + reflexive junior token, with no hard redemption or exogenous capital",["As"]),
 ("X2","H","Fl* + manipulable Cp/Cl price + Pl/Cd, where manipulation cost < position value",["Fl","Cp","Cl","Pl","Cd"]),
 ("X3","H","Protocol token as collateral AND oracle market AND backstop",[]),
 ("X4","F","Rb into a balance-invariant ledger with no adapter",["Rb"]),
 ("X5","H","Illiquid backing + uncapped instant par redemption",[]),
 ("X6","H","Borrowable voting power + immediate execution",[]),
 ("X7","H","Cross-domain mint whose verifier is present but unproven correct",[]),
 ("X8","H","Shared collateral across nominally isolated markets",[]),
 ("X9","H","Up with immediate single-key control",["Up"]),
 ("X10","H","Pm with a stale reference and unrestricted inventory",["Pm"]),
 ("X11a","F","Uc with no Aw, At, collateral or reputation",["Uc","Aw","At"]),
 ("X11b","H","Uc with all of them and weak underwriting",["Uc"]),
 ("X12","F","Lock-mint wrapped asset as canonical collateral whose value at risk exceeds the bridge's economic security",[]),
 ("X13","H","External-validator Xm securing value exceeding slashable stake",["Xm"]),
 ("X14","U","Exclusive market structure plus a price-improvement claim with no named benchmark",[]),
 ("X15","H","Rs securing a bridge mostly with assets issued by that bridge",["Rs"]),
 ("X16","H","Unbounded delegated authority, or unlimited token approvals",[]),
 ("X17","H","Passive protocol-token reserve backing protocol-token collateral",[]),
 ("X18","H","Oa as sole truth for high-frequency liquidation",["Oa"]),
 ("X19","F","Restricted claim bridged via Xf into a representation with no destination-side Aw",["Xf","Aw"]),
]
assert len(PROHIB) == 20
CONDITIONAL = ["X2","X18","X19","X21","X11a"]

for pid, cls, desc, els in PROHIB:
    rat = "prohibition row %s; class=%s; forbidden configuration: %s. " % (pid, cls, desc)
    if els:
        rat += "names element(s) %s in its forbidden configuration." % ",".join(els)
    else:
        rat += ("unformalized: this row is a prose description of a forbidden configuration and "
                "names no element symbol at all - nothing in it is stated in the vocabulary.")
    if pid in CONDITIONAL:
        rat += " Evaluated by the operational (conditional) predicate rather than as a listed row alone."
    N(VOC + "_" + pid.lower(), "Prohibition row " + pid, "concept", VOCF, rat)
    E(VOC + "_" + pid.lower(), VOC + "_instantiated_vocabulary_tables", "references", "EXTRACTED", 1.0, VOCF)
    for e_ in els:
        E(VOC + "_" + pid.lower(), eid(e_), "references", "EXTRACTED", 1.0, VOCF)

N(VOC + "_x21", "Prohibition row X21", "concept", VOCF,
  "prohibition row X21 is named as one of the conditional rows evaluated by the operational "
  "predicate, and is ARMED by the Uniswap witness (Fl carried with Xf), but it does not appear "
  "in the table of 20 listed prohibition rows (which runs X1..X19 with X11a/X11b split). "
  "unformalized/unlisted: its forbidden configuration is stated nowhere in the reproduced tables, "
  "so the row names no element here.")
E(VOC + "_x21", VOC + "_instantiated_vocabulary_tables", "references", "EXTRACTED", 1.0, VOCF)

# supp-13 restatement
N(S13 + "_restated_vocabulary_tables",
  "Supplement restatement of the instantiated vocabulary and constraints",
  "concept", S13F,
  "Section 13 of the supplement reproduces the formal-data tables verbatim: the same 58 elements "
  "with the same groups and strata, the same 29 requirement rows including every [ext] () empty "
  "term, the same 27 warrant entries and the same 20 prohibition rows. No row differs from "
  "formal-01; it is a duplicate printing so a reader can check a witness in place.")
E(S13 + "_restated_vocabulary_tables", VOC + "_instantiated_vocabulary_tables",
  "references", "EXTRACTED", 1.0, S13F)

N(S00 + "_sixty_protocol_profiles", "Sixty protocol profiles (supplement)", "concept", S00F,
  "For each of the sixty protocols the supplement records the construction exhibited for it, its "
  "canonical form ex(X), the verdict of the admissibility test, how many recorded obligations the "
  "construction discharges, and every obligation no element of the vocabulary names (the residue).")

# ---------------------------------------------------------------- protocols
SUPP = {
 1: ("kg_corpus_supp_01_spot_exchange", BASE + "supp-01-spot-exchange.md"),
 2: ("kg_corpus_supp_02_lending", BASE + "supp-02-lending.md"),
 3: ("kg_corpus_supp_03_collateraliseddebt_stablecoins", BASE + "supp-03-collateraliseddebt-stablecoins.md"),
 4: ("kg_corpus_supp_04_liquid_staking_and_restaking", BASE + "supp-04-liquid-staking-and-restaking.md"),
 5: ("kg_corpus_supp_05_perpetual_futures", BASE + "supp-05-perpetual-futures.md"),
 6: ("kg_corpus_supp_06_yield_vaults_and_aggregators", BASE + "supp-06-yield-vaults-and-aggregators.md"),
 7: ("kg_corpus_supp_07_bridges", BASE + "supp-07-bridges.md"),
 8: ("kg_corpus_supp_08_intents_and_aggregation", BASE + "supp-08-intents-and-aggregation.md"),
 9: ("kg_corpus_supp_09_tokenised_realworld_assets", BASE + "supp-09-tokenised-realworld-assets.md"),
 10: ("kg_corpus_supp_10_options_and_structured_products", BASE + "supp-10-options-and-structured-products.md"),
 11: ("kg_corpus_supp_11_reservebacked_stablecoins", BASE + "supp-11-reservebacked-stablecoins.md"),
 12: ("kg_corpus_supp_12_prediction_markets", BASE + "supp-12-prediction-markets.md"),
}

def slug(s):
    return re.sub(r"_+", "_", re.sub(r"[^a-z0-9]+", "_", s.lower())).strip("_")

# (section, name, slug, take-set, verdict-rationale, cause-list)
# cause entries: ("L","L1","Ex|Tp|At") open term, or ("X","X19","armed"), or ("W","Gs","unwarranted")
P = [
 (1,"Curve","curve","Ag,Em,Fd,Gp,Sh,St,Tg,Tp",
  "admissible: no requirement term open, every element warranted, arms no prohibition; discharges 8 of 22 recorded obligations, 14 residue; every element primitive in the canonical form.",[]),
 (1,"Fluid","fluid","Cl,Cp,Ct,Ex,Gp,Li,Pl,Sh,Tg,Tp,Up",
  "admissible; discharges 11 of 22 obligations, 11 residue; {Ct} derived rather than chosen; not minimal - {Cp} removable.",[]),
 (1,"PancakeSwap","pancakeswap","Cl,Cp,Em,Fl,Gp,Ix,Sh,St",
  "admissible; discharges 9 of 22 obligations, 13 residue; not minimal - {Cl} removable. Up dropped (core stated immutable), Gp added (one-directional PausableRole).",[]),
 (1,"Raydium","raydium","Cl,Cp,Em,Gp,Ix,Sh,Tp,Up",
  "admissible; discharges 8 of 22 obligations, 14 residue; not minimal - {Cl} removable. Fd dropped: value return is accumulation, not distribution to a claim class.",[]),
 (1,"Uniswap","uniswap","Cl,Cp,Fl,Ix,Sh,Tg,Tp,Xf",
  "NOT admissible: it arms X21 (Fl carried together with Xf); discharges 10 of 22 obligations, 12 residue. The flash path lives inside a pool settlement scope and the burn path on a bridge days later, and an element set cannot say the two never meet.",[("X","X21","armed")]),

 (2,"Aave V3","aave_v3","Aw,Ct,Ex,Fd,Fl,Gp,Ix,Li,Pl,Rb,Tg,Up,Xm",
  "admissible; discharges 12 of 23 obligations, 11 residue; {Ct} derived; not minimal - {Rb,Tg,Xm} removable. Bs, Cd, Em, Im, Sl dropped under cite-or-drop; Aw added for the address-keyed administrative gate.",[]),
 (2,"JustLend V1","justlend_v1","Aw,Ct,Ex,Gp,Ix,Li,Pl,Sh,Tg,Up",
  "admissible; discharges 10 of 18 obligations, 8 residue; {Ct} derived; not minimal - {Sh} removable. The control of its category: no bounded delegate anywhere in the tree.",[]),
 (2,"Maple","maple","Aw,Bs,Ct,Fd,Ft,Gp,Pl,Sh,Sl,Sv,Tg,Up,Wq",
  "NOT admissible: leaves the requirement term L1:Ex|Tp|At open - the pool manager holds no oracle and valuation is a human act performed off chain; discharges 10 of 23 obligations, 13 residue.",[("L","L1","Ex|Tp|At")]),
 (2,"Morpho","morpho","Aw,Ct,Ex,Fd,Gp,Im,Ix,Li,Pl,Sh,Sl,Tg",
  "admissible; discharges 11 of 24 obligations, 13 residue; {Ct} derived; not minimal - {Pl,Ix,Sl} removable. Em, Fl and Sv dropped; Sv would name a mechanism the protocol does not have.",[]),
 (2,"SparkLend","sparklend","Aw,Ct,Ex,Fl,Gp,Ix,Li,Pl,Rb,Tg,Up",
  "admissible; discharges 8 of 24 obligations, 16 residue; {Ct} derived; not minimal - {Pl,Rb,Up,Tg} removable. Price of credit is read live out of another protocol's accumulator.",[]),

 (3,"Ethena","ethena","At,Aw,Bs,Dp,Em,Fz,Gp,Ix,Rd,Rf,Sh,Sr,Tr,Wq,Xf",
  "admissible; discharges 13 of 22 obligations, 9 residue; not minimal - {Sh,Ix,Bs,Em} removable. A hedged synthetic dollar: no credit element, no collateral test, no liquidation path.",[]),
 (3,"Liquity","liquity","Bs,Cd,Ct,Em,Ep,Ex,Fd,Li,Rd,Sl",
  "admissible; discharges 9 of 22 obligations, 13 residue; {Ct} derived; not minimal - {Em,Fd} removable. L7's credit term satisfied by the redemption right alone; no peg-swap anywhere.",[]),
 (3,"Lista","lista","As,Cd,Ct,Em,Ex,Gp,Ix,Li,Ps,Sl,Wq",
  "admissible; discharges 12 of 20 obligations, 8 residue; {Ct} derived. The borrow rate is a closed-loop controller; no element names it.",[]),
 (3,"Sky","sky","Aw,Cd,Ct,Em,Ex,Fd,Gp,Ix,Li,Ps,Sh,Sl,Tg,Tr,Up,Xf",
  "NOT admissible: it arms X19* (conditional restricted-claim/cross-domain row); discharges 15 of 24 obligations, 9 residue; {Ct} derived. L7 satisfied through the peg-swap alone - the issuer grants no direct claim on collateral.",[("X","X19","armed as X19*"),("L","L7","satisfied by Ps alone")]),
 (3,"USDD","usdd","Cd,Ct,Ex,Gp,Ix,Li,Ps,Sh,Sl",
  "admissible; discharges 9 of 17 obligations, 8 residue; {Ct} derived; not minimal - {Sh} removable. The smallest CDP construction: five corpus elements dropped for want of a primary source, control plane UNKNOWN rather than absent.",[]),

 (4,"Babylon","babylon","Aw,Bs,Em,Ep,Fd,Ix,Rs,Sl,Xm",
  "admissible; discharges 11 of 22 obligations, 11 residue; not minimal - {Bs,Sl,Em,Fd} removable. The protocol holds nothing; Wq dropped because each delegation unbonds on its own Bitcoin timelock.",[]),
 (4,"Binance staked ETH","binance_staked_eth","Fz,Gp,Ix,Rd,Up,Wq",
  "admissible; discharges 7 of 16 obligations, 9 residue; not minimal - {Rd,Wq} removable. Vl inapplicable rather than approximate: no validator action of any kind occurs on chain. At deliberately not claimed - the unmet warrant is the finding.",[]),
 (4,"EigenLayer","eigenlayer","Aw,Bs,Ep,Fd,Gp,Rs,Sh,Sl,Up,Wq,Xm",
  "admissible; discharges 12 of 21 obligations, 9 residue; not minimal - {Bs,Sl,Wq,Fd,Up} removable. The conserved magnitude budget over slashability has no symbol.",[]),
 (4,"ether.fi","ether_fi","Aw,Ep,Ex,Fd,Fz,Gp,Ix,Rb,Rd,Rs,Sh,Sl,Tg,Up,Wq",
  "admissible; discharges 14 of 25 obligations, 11 residue; not minimal - {Ix,Ex,Ep,Rd,Sl,Tg,Up,Gp} removable. Tr and Bs dropped; the priced on-chain auction for the right to operate has no element.",[]),
 (4,"Lido","lido","Aw,Bs,Cd,Ct,Ep,Ex,Fd,Gp,Ix,Rb,Rd,Sh,Sl,Tg,Up,Wq",
  "admissible; discharges 16 of 24 obligations, 8 residue; {Ct} derived; not minimal - {Ix,Cd,Ep,Wq,Sl,Tg,Up,Gp} removable. Vl deliberately not used: it names the category rather than any mechanism.",[]),

 (5,"ApeX","apex","Ad,Au,Ct,Ex,Fd,Li,Ob,Pf,Sh,Xf,Xm",
  "admissible; discharges 12 of 22 obligations, 10 residue; {Ct,Ex,Li} derived; not minimal - {Xf,Xm} removable. Bs dropped: no insurance fund is documented anywhere.",[]),
 (5,"Aster","aster","Ad,Bs,Ct,Em,Ex,Li,Ob,Pf,Sb,Sd,Sh,Sv,Tp,Vl,Xf,Xm",
  "admissible; discharges 15 of 26 obligations, 11 residue; {Ct,Ex,Li} derived; not minimal - {Tp,Vl,Em,Xf,Xm} removable. The corpus rejection on the open loss-absorption term disappears; the departure is a correction of the record.",[]),
 (5,"edgeX","edgex","Ct,Ex,Li,Ob,Pf,Up,Xf",
  "NOT admissible: leaves the requirement term L4:Ad|Sl|Bs open - the venue documents no loss-absorption mechanism at all; discharges 9 of 18 obligations, 9 residue; {Ct,Ex,Li} derived. An undocumented mechanism and an absent one are different things the vocabulary cannot tell apart.",[("L","L4","Ad|Sl|Bs")]),
 (5,"Hyperliquid","hyperliquid","Ad,Ct,Ep,Ex,Gp,Li,Ob,Pf,Sh,Sl,Tp,Vl,Wq,Xf,Xm",
  "admissible; discharges 15 of 25 obligations, 10 residue; {Ct,Ex,Li} derived; not minimal - {Tp,Sl,Ep,Wq} removable. Bs dropped: HLP is unbonded, unslashable depositor capital, so Sl carries the loss-absorption term.",[]),
 (5,"Lighter","lighter","Ad,Aw,Ct,Em,Ex,Fd,Gp,Li,Ob,Pf,Rf,Sh,Sl,Tg,Tp,Up,Xf,Xm",
  "admissible; discharges 17 of 24 obligations, 7 residue; {Ct,Ex,Li} derived; not minimal - {Pf,Tp,Sl,Sh,Em,Fd,Tg,Up} removable. That the deployment can be checked against its source is invisible to every element.",[]),

 (6,"CIAN Yield Layer","cian_yield_layer","Aw,Ct,Ex,Fl,Gp,Ix,Sh,Up,Wq",
  "admissible; discharges 9 of 19 obligations, 10 residue. The strategy is not an element the vocabulary failed to name - it is not on the chain to be named. Em dropped, Aw added.",[]),
 (6,"Convex Finance","convex_finance","Em,Ep,Fd,Gp,Ix,Rd,Sh,Sr",
  "admissible; discharges 8 of 18 obligations, 10 residue; not minimal - {Sh,Rd} removable. The vocabulary can name mutability and cannot assert immutability.",[]),
 (6,"Huma Finance V2","huma_finance_v2","Aw,Bs,Ep,Fd,Ft,Gp,Sh,Sv,Tr,Uc,Wq",
  "NOT admissible: leaves the requirement term L3:At open AND arms X11a* - undercollateralised credit with no attestation to name; discharges 12 of 24 obligations, 12 residue; {Aw} derived.",[("L","L3","At"),("X","X11a","armed as X11a*")]),
 (6,"Pendle","pendle","Em,Ep,Fd,Ft,Gp,Ix,Py,Rd,Sh,Up,Wq",
  "admissible; discharges 11 of 21 obligations, 10 residue; {Ep,Rd} derived; not minimal - {Gp,Up} removable. The only application in the corpus carrying Py; residue is mechanism rather than discretion.",[]),
 (6,"Spark Savings","spark_savings","Aw,Ex,Gp,Ix,Ps,Rd,Sh,Sr,Tg,Up,Xf,Xm",
  "admissible; discharges 12 of 21 obligations, 9 residue; not minimal - {Sh,Ix,Sr,Ex} removable. The authority terms name the facilities, never the envelope.",[]),

 (7,"BTCB","btcb","Rd,Xf",
  "NOT admissible: it is ungrounded; discharges 2 of 15 obligations, 13 residue. The smallest construction in the category: issuance unbounded and unilateral from one externally-owned account, with no element weak enough to say so.",[]),
 (7,"Coinbase Bridge","coinbase_bridge","Aw,Fz,Gp,Rd,Up,Xf",
  "admissible; discharges 6 of 18 obligations, 12 residue. X9 (Up under immediate single-key control) cannot be evaluated because its antecedent - that the holder is a single key - is unstateable in the vocabulary.",[]),
 (7,"Hyperliquid Bridge","hyperliquid_bridge","Gp,Gs,Vl,Wq,Xf,Xm",
  "NOT admissible: leaves the requirement term L21:Au open AND {Gs} has no consumer present, i.e. it is unwarranted; discharges 7 of 19 obligations, 12 residue. The law behind Gs demands a user-granted delegation and the user grants nothing.",[("L","L21","Au"),("W","Gs","unwarranted")]),
 (7,"LayerZero V2","layerzero_v2","Au,Gs,Xf,Xm",
  "admissible; discharges 6 of 18 obligations, 12 residue; {Au} derived. Up, Gp and Tg all dropped on direct reads of the endpoint; verification is a per-application parameter the element cannot express.",[]),
 (7,"WBTC","wbtc","Aw,Gp,Rd,Xf",
  "NOT admissible: it arms X19*; discharges 4 of 19 obligations, 15 residue. The vocabulary has an element for delayed execution and none for authority that is shared but immediate.",[("X","X19","armed as X19*")]),

 (8,"Binance Wallet","binance_wallet","Ag,Aw,Up",
  "admissible; discharges 3 of 19 obligations, 16 residue. Rf and Gs both dropped for want of a primary source; the thinness is the evidence. The vocabulary has four symbols for how an order is matched and none for who owns the flow.",[]),
 (8,"Jupiter","jupiter","Ag,Aw,Gs,In",
  "NOT admissible: leaves the requirement term L21:Au open; discharges 4 of 20 obligations, 16 residue. That this venue routes to routers is a containment relation the carrier cannot state.",[("L","L21","Au")]),
 (8,"KyberSwap","kyberswap","Ag,Au,Ep,Fd,In,Rf,Xf",
  "admissible; discharges 6 of 20 obligations, 14 residue; not minimal - {Fd,Ep,Xf} removable. Exclusivity over a venue is not the same obligation as routing to one.",[]),
 (8,"LiquidMesh","liquidmesh","Ag,Au,Aw,Up",
  "admissible; discharges 6 of 20 obligations, 14 residue. Identical decomposition to another venue whose residue is disjoint - a sharper statement of non-identifiability than a collision on its own.",[]),
 (8,"OKX DEX","okx_dex","Ag,Au,Aw,Gs,In,Rf,Xf",
  "NOT admissible: it arms X19*; discharges 7 of 19 obligations, 12 residue; {Au} derived. Ba explicitly refused: many solvers bidding on one order is not a uniform price over a batch.",[("X","X19","armed as X19*")]),

 (9,"BlackRock BUIDL","blackrock_buidl","Aw,Fz,Gp,Rd,Sh,Up",
  "admissible; discharges 6 of 19 obligations, 13 residue. The smallest construction in the category; At, Ps and the cross-domain elements all removed. The witness arms a prohibition the corpus recorded as unarmed (single-key proxy owner).",[("X","X9","single-key upgrade path")]),
 (9,"Centrifuge","centrifuge","Au,Aw,Ep,Ex,Fz,Gp,Rd,Sh,Sv,Tg,Up,Xf,Xm",
  "admissible; discharges 11 of 22 obligations, 11 residue; not minimal - {Ex,Rd,Sv,Tg,Up} removable. Tr dropped: seniority, subordination and waterfall appear nowhere in the source.",[]),
 (9,"Circle USYC","circle_usyc","At,Aw,Ex,Fz,Gp,Ix,Rd,Sh,Sv,Up,Xf",
  "admissible; discharges 9 of 20 obligations, 11 residue; not minimal - {At,Ex,Fz,Gp,Sv} removable. Ps refused: an asymmetric NAV mint-and-redeem teller is the structural opposite of a par swap.",[]),
 (9,"Maple Finance","maple_finance","Aw,Ct,Fd,Ft,Gp,Pl,Sh,Sl,Sv,Tg,Up,Wq,Xf,Xm",
  "NOT admissible: leaves the requirement term L1:Ex|Tp|At open - the solvency test runs off chain against price feeds nothing on chain can see; discharges 10 of 22 obligations, 12 residue; {Ct} derived. The only member of the RWA category whose register of record is the token ledger.",[("L","L1","Ex|Tp|At")]),
 (9,"Ondo Finance","ondo_finance","At,Aw,Ex,Fz,Gp,Ix,Ps,Rb,Rd,Rf,Sh,Sv,Tg,Up,Xf,Xm",
  "admissible; discharges 13 of 23 obligations, 10 residue; not minimal - {Ex,Sv,Tg,Up,Xf,Xm} removable. Tr dropped: sponsor equity behind the whole issue is not a subordinated class of tokens.",[]),

 (10,"Aevo","aevo","Ad,Ct,Ex,Fd,Li,Ob,Op,Pf,Rf,Xf,Xm",
  "admissible; discharges 10 of 21 obligations, 11 residue; {Ct,Ex,Li} derived; not minimal - {Pf,Xf,Xm} removable. One of two rejections in the category that turn out to be decomposition artefacts: restoring Ct and Ad closes the term and the rejection disappears.",[]),
 (10,"Derive","derive","Ct,Em,Ex,Fd,Ix,Li,Ob,Op,Pf,Rf,Sl,Up,Xf,Xm",
  "admissible; discharges 12 of 22 obligations, 10 residue; {Ct,Ex,Li} derived; not minimal - {Fd,Ix,Pf,Xf,Xm} removable. Bs refused: a treasury that cannot be slashed does not answer to a bond, so Sl carries the term.",[]),
 (10,"Hegic","hegic","Bs,Ep,Ex,Fd,Gp,Op,Sh",
  "NOT admissible: leaves the requirement term L1:Ct open; discharges 7 of 15 obligations, 8 residue. A balance-sheet inequality checked at write time and a threshold test evaluated while a position is open are different mechanisms with the same purpose, and the vocabulary names only the second.",[("L","L1","Ct")]),
 (10,"Panoptic","panoptic","Cl,Ct,Fd,Gp,Ix,Li,Op,Pl,Sh,Sl,Sr,Tp",
  "admissible; discharges 13 of 23 obligations, 10 residue; {Ct} derived; not minimal - {Sh} removable. The second decomposition artefact: an on-chain time-weighted price is a price and a risk engine is a threshold test, and the rejection disappears with them.",[]),
 (10,"Rysk","rysk","At,Ep,Ex,Gp,Op,Rf,Sh,Sv,Up,Wq",
  "NOT admissible: leaves the requirement terms L1:Ct and L1:Li|Ad|Sl|Bs open; discharges 8 of 20 obligations, 12 residue. The sharpest case of a requirement discharged BY CONSTRUCTION - escrowing the maximum payoff makes those obligations unable to arise, and the constraint language reads that as unspecified. The repair is to the constraint language, not the vocabulary.",[("L","L1","Ct"),("L","L1","Li|Ad|Sl|Bs")]),

 (11,"Circle USDC","circle_usdc","At,Au,Aw,Fz,Gp,Rd,Up,Xf,Xm",
  "admissible; discharges 9 of 24 obligations, 15 residue; not minimal - {Xf,Xm} removable. Au added for signed transfer authorisations; Ps dropped. Disclosure quality does not change the decomposition.",[]),
 (11,"Global Dollar USDG","global_dollar_usdg","At,Au,Aw,Ep,Fd,Fz,Gp,Rd,Sh,Tg,Up",
  "admissible; discharges 10 of 23 obligations, 13 residue; not minimal - {Ep,Fd,Sh} removable. The vocabulary records that a timelock is present and that a freeze is present; it cannot record that they are the same single key and that the delay does not cover the freeze.",[]),
 (11,"PayPal USD","paypal_usd","At,Au,Aw,Fz,Gp,Rd,Up",
  "admissible; discharges 8 of 22 obligations, 14 residue; not minimal - {Rd} removable. Cross-domain elements removed for want of a primary source; shares its freeze key with another issuer in the same category.",[]),
 (11,"Tether USDT","tether_usdt","At,Aw,Fz,Gp,Rd,Up",
  "admissible; discharges 6 of 22 obligations, 16 residue; not minimal - {Aw} removable. Ps dropped: no on-chain module performs a par exchange. A power used constantly and a power never used are recorded identically.",[]),
 (11,"USD1","usd1","At,Au,Aw,Fz,Gp,Rd,Up,Xf,Xm",
  "admissible; discharges 9 of 23 obligations, 14 residue; not minimal - {Aw,Rd,Xf,Xm} removable. The two cross-domain elements added on a live canonical-issuance path break the corpus identity claim with Tether.",[]),

 (12,"Azuro","azuro","Au,Aw,Fd,Gp,Gs,Rd,Rl,Up",
  "admissible; discharges 7 of 19 obligations, 12 residue; {Au} derived; not minimal - {Gs,Gp} removable. The corpus carried Rl with no Au, making this the only protocol in the corpus rejected on a WARRANT - an element present that nothing consumes - rather than on a requirement alone; the witness repairs it with Au and Gs.",[("W","Rl","corpus carried Rl with no Au: rejected on a warrant"),("L","L20","Au")]),
 (12,"Grove Finance","grove_finance","At,Aw,Fd,Gp,Ix,Ps,Sh,Tg,Xf",
  "admissible; discharges 8 of 20 obligations, 12 residue; not minimal - {Sh,Ix} removable. Au declined; the linearly refilling per-key rate limit is the most load-bearing on-chain control and the vocabulary has no flow limiter at all.",[]),
 (12,"Kalshi","kalshi","Ad,Aw,Bs,Ct,Fd,Gp,Pf,Rd,Sl",
  "NOT admissible: leaves the requirement terms L1:Ex|Tp|At, L4:Ex and L4:Li open; discharges 9 of 22 obligations, 13 residue; {Ct} derived. Every element that could close the truth term requires a feed, a price series or an independent attester, and the truth source here is a committee. Nothing in the vocabulary is a counterparty-substitution (novation) operator.",[("L","L1","Ex|Tp|At"),("L","L4","Ex"),("L","L4","Li")]),
 (12,"Polymarket","polymarket","Au,Aw,Ct,Fd,Gp,Gs,Oa,Ob,Ps,Rd,Up",
  "admissible; discharges 12 of 20 obligations, 8 residue; {Au} derived. Oa kept although its shape fits badly; splitting collateral along the STATE space of a condition has no element, the only splitting element partitioning a claim along time.",[]),
 (12,"Steakhouse Financial","steakhouse_financial","Ct,Fd,Gp,Im,Rd,Sh,Tg",
  "NOT admissible: leaves the requirement terms L1:Ex|Tp|At and L1:Li|Ad|Sl|Bs open; discharges 7 of 17 obligations, 10 residue; {Ct} derived. The vault computes no price and absorbs no loss - both are properties of the markets underneath it - and the carrier has no way to record an obligation discharged one level down.",[("L","L1","Ex|Tp|At"),("L","L1","Li|Ad|Sl|Bs")]),
]
assert len(P) == 60, len(P)

prot_ids = {}
for sec, name, sl, take, verdict, causes in P:
    stem, sfile = SUPP[sec]
    pid = stem + "_" + sl
    cid = pid + "_construction"
    prot_ids[(sec, sl)] = pid
    N(pid, name, "concept", sfile, verdict)
    E(pid, S00 + "_sixty_protocol_profiles", "references", "EXTRACTED", 1.0, sfile)
    syms = take.split(",")
    N(cid, name + " exhibited construction", "concept", sfile,
      "exhibited construction X = {" + ", ".join(syms) + "}. " + verdict)
    E(pid, cid, "implements", "EXTRACTED", 1.0, sfile)
    for s in syms:
        E(cid, eid(s), "shares_data_with", "EXTRACTED", 1.0, sfile)
    for kind, ref, note in causes:
        if kind == "L":
            E(pid, VOC + "_" + ref.lower(), "conceptually_related_to", "EXTRACTED", 1.0, sfile)
        elif kind == "X":
            E(pid, VOC + "_" + ref.lower(), "conceptually_related_to", "EXTRACTED", 1.0, sfile)
        else:
            E(pid, VOC + "_warrant_" + ref.lower(), "conceptually_related_to", "EXTRACTED", 1.0, sfile)

# ---------------------------------------------------------------- named residue themes
THEMES = [
 (2, "bounded_delegated_mandate", "Bounded delegated mandate (the five-part mandate)",
  "The recurring residue shape across categories: an agent, an enumerated domain of parameters it may write, a magnitude bound per update, a cooldown or refilling budget, and a revocation. Only the agent slot is nameable, and only by stretching Aw, which names who may send a transaction rather than who may move a parameter. Named at Aave V3 (the steward), Sky (the rate facilitator), SparkLend (keeper + liquidity controller), Spark Savings, Maple Finance and Steakhouse Financial. Across every instance the domain, the magnitude cap and the revocation are residue without exception.",
  ["Aw","Au","Tg"]),
 (6, "refilling_rate_limit_budget", "Refilling rate-limit budget (flow limiter)",
  "A per-key capacity that regenerates continuously with elapsed time, bounding how much value a privileged actor may move per unit time rather than how often it acts. Recurs at SparkLend, Spark Savings, ether.fi, Grove Finance, Circle USDC (minter allowance) and USDG (SupplyControl RateLimit). The vocabulary has no flow limiter at all; a schema with a single rate-of-change field records a cooldown and a refilling budget as the same guarantee.",
  ["Au","Tg","Gp"]),
 (10, "discharged_by_construction", "Discharged by construction",
  "An obligation that cannot arise because the design forecloses it - Rysk escrows the maximum payoff so no position can become under-secured, and Hegic checks a balance-sheet inequality at write time. The requirement language admits only one way to satisfy a term, naming an element, so it reads an obligation that cannot arise as an obligation left unspecified. The repair is to the constraint language rather than to the vocabulary.",
  ["Ct","Li","Bs","Sl","Ad"]),
 (1, "hook_extension_point_residue", "Hook / extension-point residue",
  "Third-party code in the settlement path whose permission set is bound differently at every protocol - mined into the hook's address at Uniswap, carried in the pool's own key at PancakeSwap, named as a controller address at Fluid. A symbol for hooks would first have to decide whether the permissions belong to the code or to the pool. Shared across the category's largest members and named by none of them.",
  ["Cl","Cp","Fl"]),
 (9, "register_of_record", "Register of record (chain versus book)",
  "Whether the token ledger IS the register of ownership or a mirror of a transfer agent's book, and which is authoritative on a conflict. BUIDL's books are authoritative over the chain; Centrifuge's token is prima facie evidence under BVI law; USYC's tokens are digital twins the administrator moves the register to match; Ondo answers three different ways across three products; Maple Finance is the only member whose register is the token ledger. Nothing in the vocabulary reaches the register.",
  ["Sh","Rd","Aw"]),
 (8, "protocol_containment_relation", "Containment between protocols (a protocol consuming another as a component)",
  "Composition in the paper is union of element sets between peers; one protocol consuming another as a component is a containment relation the carrier cannot state. Exhibited by Jupiter routing to rival routers, by Morpho vaults that are depositors in markets they do not control, by Convex exercising governance inside four foreign protocols, and by Steakhouse allocating across isolated markets one level down.",
  ["Ag","In","Pl","Im"]),
 (4, "vl_five_sub_mechanisms", "Vl's five sub-mechanisms",
  "Vl (staking & validator lifecycle) names the category rather than any mechanism, and the profiles decompose it into key registration and vetting, stake allocation and scheduling, deposit front-running defence, exit signalling, and penalty attribution - kept in separate contracts under separate failure modes at Lido, absent entirely at Binance staked ETH, and answered negatively at Babylon. Lido adds a sixth absent from the corpus: validator sizing, top-up and consolidation.",
  ["Vl","Rs","Sl","Bs","Wq"]),
 (5, "cite_or_drop", "Cite-or-drop discipline",
  "An element is carried only when a mechanism answers to it at a primary source, and dropped otherwise; dropping an unsupported element is the same discipline as adding a supported one. Applied against the corpus at ApeX (Bs), edgeX (four elements), Binance Wallet (Rf, Gs), Tether (Ps), PayPal USD (cross-domain), USDD (five elements) and LayerZero V2 (Up, Gp, Tg). An absence of evidence is recorded as UNKNOWN rather than as absence.",
  ["Bs","Ps","Up","Tg"]),
 (12, "novation_and_default_waterfall", "Novation and the mutualised default waterfall",
  "Counterparty substitution by a clearing house extinguishes a bilateral obligation and replaces it with obligations against the clearing house; nothing in the vocabulary is a counterparty-substitution operator, and Rd names a right to be paid and carries no obligor. Kalshi's capped operator tranches and callable member assessments have no symbol either, so the vocabulary reconstructs the mutualised middle of the waterfall and neither end.",
  ["Rd","Bs","Sl","Ad"]),
 (3, "price_of_credit_residue", "The price of credit",
  "The level and shape of a borrow or savings rate: a two-slope curve and its write-time bounds at Aave, a per-block rate at JustLend, a bilateral contract term at Maple, a closed-loop controller at Lista and Morpho, a live read of another protocol's accumulator at SparkLend, a written number at Sky and Spark Savings, a borrower-chosen rate that doubles as redemption priority at Liquity. No element names a rate, so protocols with identical element sets differ in setter, bound, latency and controlling party.",
  ["Ix","Pl","Cd","Sr"]),
]
for sec, sl, label, rat, rel_syms in THEMES:
    stem, sfile = SUPP[sec]
    tid = stem + "_" + sl
    N(tid, label, "rationale", sfile, rat)
    E(tid, S00 + "_sixty_protocol_profiles", "references", "EXTRACTED", 1.0, sfile)
    for s in rel_syms:
        E(tid, eid(s), "conceptually_related_to", "INFERRED", 0.85, sfile)

# ---------------------------------------------------------------- validation measurements
MEAS = [
 ("clause_widths", "Measurement: clause widths",
  "In the CNF encoding of admissibility the widest clause has 34 literals and 20.4% of clauses are bijunctive; the system is therefore not preserved by the majority operation and is not median-closed, though the bijunctive fragment is.", []),
 ("exhaustive_to_size_three", "Measurement: exhaustive to size three",
  "Over all 172,431,735 pairs from R of size at most three, 0 fail intersection-closure and 0 fail union-closure. Intersection-closure nevertheless fails; the smallest witness has five elements: {Ct,Ex,Li,Pl,Sh} and {Ct,Li,Pl,Sh,Tp} both satisfy the law while their intersection {Ct,Li,Pl,Sh} leaves L1 unsatisfied. The exhaustive range is too small to exhibit the failure, not evidence against it.",
  ["Ct","Ex","Li","Pl","Sh","Tp"]),
 ("lattice_confluence", "Measurement: lattice confluence",
  "Over 175,230 pairs from R intersect W there are 0 union-closure violations. Meet is not intersection: about 44,000 pairs have X intersect Y outside R intersect W.", []),
 ("vacuous_iteration", "Measurement: vacuity of the iteration",
  "On synthetic operators of the present shape the iteration was sound 2000/2000 and exact 2000/2000 with zero slack. On the actual Gamma, Delta it is sound and VACUOUS: x_infinity = top on every seed at 10, 20 and 58 elements, exact in 0 of 18 seed-instances, slack 1-58. The synthetic operators admitted a Delta that removes at top; ours structurally cannot.", []),
 ("no_invariance", "Measurement: no invariance",
  "Exhaustively over the 224,025 members of R of size at most four, Delta leaves R on 116.", []),
 ("downward_closure", "Measurement: which prohibitions cost downward closure",
  "Over the 16,384 subsets of a 14-element universe containing every element occurring in a prohibition, 15,872 model the listed clutter and NONE has a subset that does not: H is downward closed, as a purely negative clause set requires. Under the full prohibition predicate (listed rows together with the conditional ones), 6,580 subsets are prohibition-free and 1,708 of them have a subset that is not. The smallest witness is {Oa,Li,Ex}, which arms X18 on the removal of Ex.",
  ["Oa","Li","Ex"]),
]
N(ATL + "_validation", "Validation (computational checks on the implementation)", "rationale", ATLF,
  "These computations confirm that the implementation behaves as the definitions require. None is a statement about the subject, and no result in the body depends on one except where it is cited.")
for sl, label, rat, syms in MEAS:
    mid = ATL + "_" + sl
    N(mid, label, "rationale", ATLF, rat)
    E(mid, ATL + "_validation", "references", "EXTRACTED", 1.0, ATLF)
    for s in syms:
        E(mid, eid(s), "references", "EXTRACTED", 1.0, ATLF)
E(ATL + "_exhaustive_to_size_three", VOC + "_l1", "references", "EXTRACTED", 1.0, ATLF)
E(ATL + "_downward_closure", VOC + "_x18", "references", "EXTRACTED", 1.0, ATLF)

# ---------------------------------------------------------------- semantic similarity
SIM = [
 (VOC + "_l17", VOC + "_l20", 0.85, VOCF),
 (VOC + "_l17", VOC + "_l12", 0.75, VOCF),
 (VOC + "_l25", VOC + "_l26", 0.85, VOCF),
 (VOC + "_x11a", VOC + "_l3", 0.85, VOCF),
 (eid("Rd"), eid("Ps"), 0.75, VOCF),
 (eid("Bs"), eid("Sl"), 0.75, VOCF),
 (eid("Tg"), eid("Au"), 0.65, VOCF),
 (prot_ids[(2,"maple")], prot_ids[(9,"maple_finance")], 0.95, SUPP[9][1]),
 (prot_ids[(5,"hyperliquid")], prot_ids[(7,"hyperliquid_bridge")], 0.95, SUPP[7][1]),
 (prot_ids[(10,"aevo")], prot_ids[(10,"derive")], 0.85, SUPP[10][1]),
 (prot_ids[(2,"sparklend")], prot_ids[(6,"spark_savings")], 0.85, SUPP[6][1]),
 (prot_ids[(3,"sky")], prot_ids[(2,"sparklend")], 0.75, SUPP[2][1]),
 (prot_ids[(11,"circle_usdc")], prot_ids[(9,"circle_usyc")], 0.75, SUPP[9][1]),
 (prot_ids[(8,"liquidmesh")], prot_ids[(8,"kyberswap")], 0.75, SUPP[8][1]),
 (prot_ids[(6,"cian_yield_layer")], prot_ids[(12,"steakhouse_financial")], 0.85, SUPP[12][1]),
 (prot_ids[(4,"babylon")], prot_ids[(4,"eigenlayer")], 0.85, SUPP[4][1]),
]
for a, b, sc, sf in SIM:
    E(a, b, "semantically_similar_to", "INFERRED", sc, sf)

# ---------------------------------------------------------------- hyperedges
hyper = [
 {"id": "unformalized_external_requirement_rows",
  "label": "Requirement rows whose every term is [ext] () - external natural language naming no element",
  "nodes": [VOC + "_" + r.lower() for r in fully_empty_rows] + [VOC + "_instantiated_vocabulary_tables"],
  "relation": "form", "confidence": "EXTRACTED", "confidence_score": 1.0, "source_file": VOCF},
 {"id": "prose_only_prohibition_rows",
  "label": "Prohibition rows that are prose descriptions naming no element symbol",
  "nodes": [VOC + "_" + p.lower() for p in ["X3","X5","X6","X7","X8","X12","X14","X16","X17"]],
  "relation": "form", "confidence": "EXTRACTED", "confidence_score": 1.0, "source_file": VOCF},
 {"id": "l1_credit_solvency_triad",
  "label": "L1: truth source, collateral test and loss absorption for pooled credit and derivatives",
  "nodes": [VOC + "_l1", eid("Ex"), eid("Tp"), eid("At"), eid("Ct"), eid("Li"), eid("Ad"), eid("Sl"), eid("Bs"),
            eid("Pl"), eid("Im"), eid("Cd"), eid("Pf"), eid("Op")],
  "relation": "participate_in", "confidence": "EXTRACTED", "confidence_score": 1.0, "source_file": VOCF},
]

out = {"nodes": nodes, "edges": edges, "hyperedges": hyper,
       "input_tokens": 0, "output_tokens": 0}

path = r"C:\Users\charl\AppData\Local\Temp\claude\C--Users-charl\18d5fad3-3a32-41fe-a407-e0314fe4d324\scratchpad\chunk_03.json"
with open(path, "w", encoding="utf-8") as f:
    json.dump(out, f, ensure_ascii=False, indent=1)

ids = set(n["id"] for n in nodes)
missing = set()
for e in edges:
    if e["source"] not in ids: missing.add(e["source"])
    if e["target"] not in ids: missing.add(e["target"])
for h in hyper:
    for n_ in h["nodes"]:
        if n_ not in ids: missing.add(n_)
print("nodes", len(nodes), "edges", len(edges), "hyperedges", len(hyper))
print("fully empty requirement rows:", fully_empty_rows, len(fully_empty_rows))
print("missing node refs:", sorted(missing))
