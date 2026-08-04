"""OP-LOG: a stratified propositional theory over the 58 mechanism atoms.

NORMAL FORM.  Every axiom is

    CLAUSE(sort, trigger, head)
      ==  sort-applies(S)  ->  ( OR_{t in trigger} AND(t) )  ->  ( OR head )

`head == []` means falsum (a pure exclusion).  Ignoring the sort guard this is
CNF over 58 atoms:

    AND_{t in trigger} ( OR_{a in t} ~a  OR  OR_{h in head} h )

so model-checking a given set S is one linear pass.  Nothing here is Horn --
heads are disjunctive -- and nothing needs to be: checking a *total* assignment
is linear for arbitrary CNF.  Horn-ness would only buy cheap completion, which
is a different problem and is NP-complete here.

The sort guard is the only non-monotone construct, and it is negation as
failure: a presentation is read as a MANDATE (sort Q) rather than a MECHANISM
(sort M) when it names a credit facility and implements none of the solvency
machinery that a facility must implement.  Sort-M axioms are then relieved,
because the facility is being *consumed*, not implemented.  Adding one element
(a liquidation, say) flips the sort and re-arms the axioms, so validity is
non-monotone by construction rather than by accident.

Strata:
  R  requirement        -- the atlas laws, repaired, forward direction
  C  completion         -- the converse (Clark completion) of the same rules
  W  well-formedness    -- presentation axioms
  X  hazards in requirement form (FINDINGS recommendation (b))
  V  vocabulary support -- elements with no witness in the 72-protocol census
"""
import itertools
import atlas as A

TRUTH = ["Ex", "Tp", "At", "Oa", "Pm", "Sv"]
TERM = ["Li", "Ad", "Sl", "Bs", "Tr", "Rd", "Ps"]
AUTH = ["Tg", "Gp", "Fz", "Aw", "Au"]
CLAIM = ["Sh", "Ix", "Rb"]
CURVE = ["Cp", "Cl", "St", "Wg", "Pm"]
POSITION = ["Pl", "Im", "Cd", "Uc", "Ft", "Pf", "Op", "Dp"]
PRODUCTIVE_GROUPS = {"G01", "G02", "G03", "G04", "G05", "G07",
                     "G12", "G13", "G15", "G16"}
UNWITNESSED = ["Cv", "Sb", "Sd", "Wg"]

# or-group cardinality, calibrated on the census maximum per G-group.
GROUP_CAP = {"G01": 3, "G02": 2, "G03": 3, "G04": 2, "G05": 3, "G06": 5,
             "G07": 2, "G08": 2, "G09": 2, "G10": 2, "G11": 4, "G12": 3,
             "G13": 2, "G14": 2, "G15": 1, "G16": 1}


def C(cid, trigger, head, note, sort="*"):
    return {"id": cid, "sort": sort, "trigger": [tuple(t) for t in trigger],
            "head": list(head), "note": note}


# --------------------------------------------------------------- the sort test
FACILITY = {"Pl", "Im"}
LOSSPATH = {"Li", "Ad", "Sl", "Bs"}


def is_mandate(S):
    """Sort Q. A presentation that names a pooled or isolated credit facility
    and a health test, but implements no terminal loss path, is a *policy over*
    someone else's facility -- Morpho curators, Steakhouse, a Yearn strategy --
    not the facility itself. The corpus VERDICT calls this the missing level;
    this is the membership-decidable surrogate for it."""
    S = set(S)
    return bool(S & FACILITY) and "Ct" in S and not (S & LOSSPATH)


# =============================================================== R stratum
R = [
    C("R1", [("Pl",), ("Im",), ("Cd",)], TRUTH + ["Cl"],
      "L1 term 1, widened. G08 has four members and the atlas term named three; "
      "Oa is a truth source, Pm carries a reference price, Sv is the "
      "determination authority that stands in for an oracle in private credit, "
      "and Cl is the price source for a pool that is its own oracle (Panoptic).",
      sort="M"),
    C("R2", [("Im",), ("Cd",), ("Pf",)], ["Ct"],
      "L1/L4 term 2, narrowed. A margined facility needs the threshold test. "
      "Pl is dropped as a subject: Across's relayer pool is a Pl with no margin."),
    C("R3", [("Im",), ("Cd",), ("Pf",)], TERM,
      "L1/L4 term 3, widened. L4's `Ad|Sl|Bs` is refuted by Aster and Aevo, "
      "which terminate through Li; Rd and Ps are terminal for a CDP.", sort="M"),
    C("R4", [("Op",)], TRUTH + ["Cl"],
      "L1 restricted to Op: an option needs a price source. The solvency "
      "conjunct is dropped -- Op is *collateralized* contingent settlement, so "
      "its terminal path is internal (Hegic, Rysk)."),
    C("R5", [("Pl",), ("Im",), ("Py",), ("Tr",), ("Cv",)], CLAIM,
      "L2, extended to every element that pools third-party capital behind a "
      "fungible claim. Bond --i-->: G01 answers 'how is a proportional claim "
      "recorded' and these five cannot answer it themselves."),
    C("R6", [("Uc",)], ["Aw"],
      "L3 term 1: credit extended on identity requires the identity gate."),
    C("R7", [("Uc",)], ["At", "Sv", "Oa"],
      "L3 term 2: At{subject=borrower-financials} generalised to any named "
      "determination party."),
    C("R8", [("Uc",)], ["Bs", "Tr", "Sv", "Cv"],
      "L3 term 3, widened: first loss, seniority, or a servicer."),
    C("R9", [("Py",)], CLAIM, "L5 term 1."),
    C("R10", [("Py",)], ["Ep"], "L5 term 2: the maturity boundary."),
    C("R11", [("Py",)], ["Rd"], "L5 term 3: PT settles by redemption."),
    C("R12", [("Tr",)], ["Sv", "Sl", "Li", "Ad", "At", "Oa", "Ex", "Ct"],
      "L6, with `mechanical trigger` promoted to the on-chain determinations "
      "that can serve as one."),
    C("R13", [("Cd",)], ["Rd", "Ps", "Li", "Ad", "Sl", "Bs"],
      "L7, with `liquidation capacity` promoted to the G06 family."),
    C("R14", [("Xf",)], ["Xm", "At", "Ps", "Rd"],
      "L8, with `named custodian, plus a global claim ledger` promoted. The "
      "most load-bearing promotion in the model: the three largest bridges by "
      "TVL have no verifier at all, because a company holds the asset, and what "
      "they do have is an attestation and a redemption right."),
    C("R15", [("In",)], ["Ag", "Rf", "Ba", "Ob", "Of", "Rl"],
      "L12, with `(solver|fallback)` promoted: an intent needs a fill layer."),
    C("R16", [("Up",)], AUTH,
      "L15, with `bounded emergency process` promoted to the authority family. "
      "As written (`Up -> Tg`) L15 rejects 25 of 72 live protocols and cannot "
      "be an admissibility condition; FINDINGS reached the same verdict from "
      "the fact that Lido and Euler fail it identically."),
    C("R17", [("Of",)], ["Xm"], "L19 term 1."),
    C("R18", [("Of",)], ["Xf"], "L19 term 2."),
    C("R19", [("Of",)], ["Bs", "Sl", "Oa", "Rl"],
      "L19 term 3, widened: Across bonds relayers through an optimistic "
      "dispute game, not through Bs or Sl."),
    C("R20", [("Gs",)], ["Au"],
      "L21. Retained; it is also the atlas's sole stratum inversion."),
    C("R21", [("Rs",)], ["Bs", "Sl", "Vl"],
      "L22, with `attributed slash condition + loss waterfall` promoted."),
    C("R22", [("Aw", "Xf")], ["Fz", "Xm", "At"],
      "L26 and X19 unified. FINDINGS recommendation (b): a prohibition written "
      "as `Xf without destination Aw` becomes a requirement, which keeps the "
      "requirement stratum union-closed."),
    C("R23", [("Fz",)], ["Aw", "Up", "Gp", "At", "Au"],
      "L28, with `named authority` promoted."),
    # ---- promoted from the SCREEN and the BONDS, not from the law list ----
    C("R24", [("Li",), ("Ad",)], ["Ct"],
      "Screen 3. A liquidation or a forced close is the consequent of a "
      "threshold test; without Ct there is no predicate to fire on. Exact on "
      "the census: all 22 Li-bearing and all 3 Ad-bearing protocols carry Ct."),
    C("R25", [("Uc",)], ["Pl", "Im", "Ft", "Sh", "Ix"],
      "Screen 2. An extension of credit has to be recorded as somebody's claim."),
    C("R26", [("Dp",)], ["Ex", "Pf", "Op", "Ct", "Pm", "Ob", "At"],
      "Screen 3. A maintained directional position needs a mark."),
    C("R27", [("Sv",)], ["Tr", "Uc", "Ft", "Pl", "Im", "Cd", "Op", "Cv",
                         "Sh", "Ix", "Rd", "Wq", "Ep"],
      "Discretion is discretion *over* something: a determination that alters "
      "no named claim is not an element of a protocol."),
    C("R28", [("Fl",)], CURVE + ["Pl", "Im", "Cd", "Ag", "Ob", "Ct"],
      "Screen 5. Atomic flash liquidity has to be borrowed from an inventory or "
      "a pool. Ct is admitted for the consumer case: CIAN loops with flash "
      "liquidity sourced elsewhere."),
    C("R29", [(c,) for c in CURVE],
      CLAIM + ["Fd", "Em", "Ct", "Ag", "Fl", "Tp", "Ob", "Sr"],
      "Bond --e-->. A pricing invariant with no liquidity claim, no fee rule "
      "and no position it prices is a formula, not a mechanism."),
    C("R30", [("Ex",)], ["Ct", "Li", "Ad", "Sl", "Pf", "Op", "Cd", "Pl", "Im",
                         "Uc", "Ft", "Dp", "As", "Ps", "Rd", "Pm", "Tp", "Vl",
                         "Rs", "Sv", "Tr", "Cv", "Cl", "Fl", "Of", "In", "Wq",
                         "Ba", "Rf", "Ob", "Ag", "Sr", "Em"],
      "Truth enters a protocol *for* something. An imported off-chain value "
      "with no consumer is an oracle subscription, not a mechanism."),
    C("R31", [("Ct",)], ["Li", "Ad", "Sl", "Bs", "Rd", "Ps", "Tr", "Cv",
                         "Sv", "Op", "Wq", "Fz"],
      "Screen 3, second half: a threshold test with no consequence. Every "
      "solvency predicate must reach a terminal state -- close, socialise, "
      "redeem, queue, or a named discretion. Sort-M only: a curator's Ct is "
      "read off a facility it does not operate.", sort="M"),
    C("R32", [("Ob",)], CLAIM + ["Ct", "Ex", "Pf", "Op", "Fd", "Ag", "In",
                                 "Em", "Rd", "Bs", "Rf", "Ba"] + CURVE,
      "An order book matches orders against inventory or claims that some "
      "other element records."),
    C("R33", [("Im",), ("Cd",), ("Pf",)], ["Li", "Ad", "Sl", "Bs"],
      "L1 term 3 in the atlas's own unwidened form, kept alongside the widened "
      "R3 because it costs nothing on the census: every Im/Cd/Pf-bearing "
      "protocol carries a G06 terminal, so Rd and Ps in R3 were slack I did "
      "not need to spend.", sort="M"),
    C("R34", [("Rs",)], ["Vl"],
      "L22 sharpened: restaked capital is validator capital by definition; "
      "shared security reuses a stake that some element has to lifecycle."),
]

# =============================================================== C stratum
COMPLETION = [
    C("C1", [("Ct",)], POSITION + ["Rs", "Vl", "Fl", "Rd", "Pm"],
      "Completion of R2/R4/R24: a collateral-threshold test with nothing to "
      "test is unfounded. Licensors are every element that can create a "
      "margined position, plus Fl (leverage looping, CIAN) and Rd/Pm, the two "
      "live cases whose margin is priced off a redemption or an inventory "
      "curve rather than off a debt element."),
    C("C2", [("Sl",)], ["Ct", "Pl", "Im", "Cd", "Pf", "Op", "Uc", "Ft",
                        "Rs", "Vl", "Bs", "Tr", "Dp", "Ps"],
      "Completion: socialized loss presupposes a loss-bearing claim class."),
    C("C4", [("Ep",)], CLAIM + ["Py", "Ft", "Vl", "Rs", "Wq", "Em", "Ba",
                                "Op", "Sv", "Tr", "Sr", "Oa"],
      "Completion: an epoch boundary with nothing to roll over."),
    C("C5", [("Xm",)], ["Xf", "Of", "Rl", "In", "At", "Vl", "Rs", "Ob",
                        "Pl", "Im", "Op", "Pf", "Tr", "Sh", "Ix", "Rb"],
      "Completion of L8/L19: a verifier with nothing crossing to verify."),
    C("C6", [("Rd",)], ["Cd", "Ps", "At", "Sh", "Ix", "Rb", "Vl", "Tr", "Op",
                        "Ft", "Py", "Xf", "Ct", "Rs", "Wq", "Rl", "Sv", "As",
                        "Oa", "Ob"],
      "Completion: a redemption right against no recorded backing or claim."),
    C("C7", [("Ps",)], ["Cd", "At", "Rd", "Sh", "Ix", "Rb", "Xf", "As", "Fz"],
      "Completion: a peg-swap module with no liability to swap."),
    C("C8", [("Tp",)], CURVE + ["Ob", "Ct", "Li", "Pl", "Im", "Cd", "Ag", "Ex"],
      "Completion: a cumulative-price accumulator with no inventory."),
    C("C9", [("Bs",)], ["Ct", "Pl", "Im", "Cd", "Uc", "Ft", "Pf", "Op", "Rs",
                        "Vl", "Sl", "Li", "Ad", "Tr", "Of", "In", "Xm", "Xf",
                        "Cv", "Dp", "Sv", "Ba", "Rf"],
      "Completion: slashable first-loss capital with nothing that can fail."),
    C("C10", [("Sr",)], CLAIM + ["Em", "Ct", "Op", "Pl", "Pm", "Rd", "Ft",
                                 "Py", "Sv", "Wq", "Xf", "Cl"],
      "Completion: a stream out of an escrow that is not recorded."),
    C("C11", [("Vl",)], CLAIM + ["Bs", "Sl", "Rs", "Wq", "Ep", "Xm", "Xf",
                                 "Rd", "Em", "Ct"],
      "Completion: a validator lifecycle with no claim on the staked capital."),
    C("C12", [("Fd",)], CLAIM + CURVE + ["Ob", "Rf", "Ba", "In", "Ag", "Pl",
                                         "Im", "Cd", "Pf", "Op", "Li", "Uc",
                                         "Ft", "Ps", "Rd", "Em", "Ct", "Sv",
                                         "Fl", "Xf"],
      "Completion: a residual-claimant rule with no surplus to allocate."),
    C("C14", [("Rb",)], CLAIM + ["Pl", "Im", "Cd", "Vl", "Rs", "Ps", "Rd",
                                 "Sr", "Ep", "Xf", "Wq", "Em", "Tr", "Ct"],
      "Completion: rebasing rescales a claim that some other element records."),
    C("C15", [("Ad",)], ["Li"],
      "Completion, and a same-group ordering: auto-deleveraging is the backstop "
      "to liquidation, not a substitute for it -- ADL fires when the "
      "liquidation engine cannot clear. Exact on the census: all three "
      "Ad-bearing protocols carry Li."),
    C("C16", [("Oa",)], ["Rd", "Ob", "Of", "In", "Tr", "Sv", "Ct", "Li",
                         "Op", "Pl", "Im", "Xm", "Xf", "Ep"],
      "Completion: an assert-then-dispute game needs an assertion someone is "
      "paid to care about."),
    C("C17", [("Ft",)], ["Ep", "Ix", "Sh", "Rb", "Rd", "Py", "Wq", "Sv",
                         "Uc", "Aw", "Pl", "Im", "At", "Ct", "Tr"],
      "Completion: a maturity-dated claim needs the accounting that discounts "
      "it and the boundary at which it matures."),
    C("C18", [("Au",)], ["Gs", "Rl", "In", "Of", "Up", "Ob", "Sv", "Aw", "Xf"],
      "Completion: a delegated execution scope with no delegate-facing "
      "mechanism to scope."),
    C("C19", [("Rl",)], ["Au", "In", "Of", "Xm", "Sv", "Ep", "Rd", "Ob", "Ba"],
      "Completion: a reservation with nothing to reserve against. Note L20 as "
      "written (`Rl -> Au + ...`) is refuted by Azuro, the only Rl witness in "
      "the census, which has Rl and no Au; the law is replaced by this weaker "
      "converse."),
    C("C20", [("Ba",)], CLAIM + ["Fd", "Ag", "In", "Rf", "Ob", "Em", "Bs",
                                 "Ex", "Ct", "Oa"],
      "Completion: uniform clearing over a batch of nothing."),
    C("C21", [("Rf",)], ["Ag", "In", "Ob", "Sh", "Ct", "Ex", "Fd", "Bs",
                         "Em", "Rl", "Of", "Aw", "Pm", "Ba"],
      "Completion: a signed maker quote is against inventory that some other "
      "element holds."),
    C("C22", [("Aw",)], ["Fz", "At", "Uc", "Ft", "Xf", "Rd", "Ps", "Tr", "Sv",
                         "Vl", "Rs", "Ob", "Rf", "In", "Ag", "Ct", "Pl", "Im"],
      "Completion: an eligibility gate must gate a claim class, a transfer, an "
      "obligor or a venue. A credential check over nothing but accounting and "
      "governance is not a mechanism. (Sharpened from the CLAIM-permissive "
      "form at zero cost on the census.)"),
    C("C23", [("At",)], ["Rd", "Ps", "Xf", "Cd", "Uc", "Ft", "Tr", "Sv",
                         "As", "Vl", "Rs", "Bs", "Aw", "Fz"],
      "Completion, sharpened form of C13: a reserve or NAV attestation names "
      "backing, an obligor, or a holder-restriction authority. An attestation "
      "over a bare share ledger with no backing claim is a marketing "
      "statement."),
    C("C24", [("Wq",)], CLAIM + ["Rd", "Vl", "Rs", "Ps", "Ep", "Ft", "Uc",
                                 "Pl", "Im", "Tr", "Op"],
      "Completion, sharpened form of C3: a withdrawal queue is against a "
      "*claim*, not against a bridge leg or a bond."),
]

# =============================================================== W stratum
_cap_triggers = []
for _g, _k in GROUP_CAP.items():
    _members = [s for s in A.SYMS if A.GROUP[s] == _g]
    if len(_members) > _k:
        _cap_triggers += [tuple(c) for c in itertools.combinations(_members, _k + 1)]

W = [
    C("W1", [(s,) for s in A.SYMS],
      [s for s in A.SYMS if A.GROUP[s] in PRODUCTIVE_GROUPS],
      "Thesis axiom. A non-empty presentation must name at least one element "
      "outside the pure-adjunct groups (G06 solvency, G08 truth, G09 time, "
      "G10 incentives, G11 control, G14 access). A set of adjuncts is a "
      "governance wrapper around nothing."),
    C("W2", _cap_triggers, [],
      "Or-group cardinality. Each G-group is a boundary question ('how is a "
      "price derived from inventory?') and a protocol answers each one a "
      "bounded number of times. Caps are the census maximum per group and this "
      "is a CHOICE: it is calibrated, not derived. Expanded to CNF it is "
      f"{len(_cap_triggers)} exclusion triggers."),
]

# =============================================================== X stratum
X = [
    C("X1p", [("As",)], ["Rd", "Ps", "At", "Bs", "Cd", "Li"],
      "X1 (Terra) in requirement form: algorithmic supply adjustment with no "
      "hard redemption, no reserve and no collateral. The reflexive 2-cycle "
      "itself is not expressible over element types (FINDINGS Q13); this is "
      "only its membership shadow, and it does not catch Terra, which had Rd."),
    C("X11p", [("Uc",)], ["Ct", "Bs", "Tr", "Sv", "At"],
      "X11a with the polarity restored as a requirement rather than a "
      "prohibition. This repair is what makes Uc realizable again: under the "
      "reversed-polarity membership projection Uc had zero hazard-free "
      "completion, which was a bug in the table, not a fact about "
      "undercollateralized credit."),
    C("X2p", [("Fl", "Cp", "Pl"), ("Fl", "Cp", "Cd"),
              ("Fl", "Cl", "Pl"), ("Fl", "Cl", "Cd")], ["Tp", "Ex", "Oa", "At"],
      "X2 in requirement form: flash liquidity plus a manipulable spot curve "
      "plus a debt facility requires a manipulation-resistant price."),
]

# =============================================================== V stratum
V = [
    C("V1", [(s,) for s in UNWITNESSED], [],
      "Vocabulary support. Cv, Sb, Sd and Wg have zero witnesses across a "
      "72-protocol census that took the live top of twelve categories. This is "
      "a CHOICE and it is stated as one: an element the census never realizes "
      "is not admitted into a presentation of a *deployed* protocol. It is the "
      "one axiom justified by absence of evidence rather than by mechanism "
      "semantics, and it would reject a correct decomposition of Nexus Mutual "
      "(Cv) or Railgun (Sb)."),
]

POOL = R + COMPLETION + W + X + V


def fires(cl, S):
    return any(all(a in S for a in t) for t in cl["trigger"])


def applies(cl, S):
    if cl["sort"] == "M":
        return not is_mandate(S)
    if cl["sort"] == "Q":
        return is_mandate(S)
    return True


def violations(S, clauses=None):
    if clauses is None:
        clauses = POOL
    S = set(s for s in S if s in A.SYMSET)
    return [cl["id"] for cl in clauses
            if applies(cl, S) and fires(cl, S) and not any(h in S for h in cl["head"])]


def valid(S, clauses=None):
    return not violations(S, clauses)
