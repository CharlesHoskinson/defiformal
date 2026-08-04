"""OP-LOG's propositional theory over the 58 mechanism atoms.

Every axiom has the single normal form

    CLAUSE(trigger, head)  ==  ( OR_{t in trigger} AND(t) )  ->  ( OR head )

with `head == []` meaning falsum (a pure exclusion).  In CNF that is

    AND_{t in trigger} ( OR_{a in t} ~a  OR  OR_{h in head} h )

so the whole theory is a finite CNF over 58 atoms and model checking a given
set S is one linear pass.  Nothing here is Horn (heads are disjunctive) and
nothing needs to be: *checking* a total assignment is linear for arbitrary CNF.
Horn-ness would only buy cheap *completion*, a different problem, NP-complete
here.

Five strata:
  R  requirement    -- the atlas laws, repaired, forward direction
  C  completion     -- the converse (Clark completion) of the same rules
  W  well-formedness
  X  hazards, rewritten in requirement form (FINDINGS recommendation (b))
  V  vocabulary support -- elements with no witness in the 72-protocol census
"""
import atlas as A

TRUTH = ["Ex", "Tp", "At", "Oa", "Pm", "Sv"]
TERM = ["Li", "Ad", "Sl", "Bs", "Tr", "Rd", "Ps"]
AUTH = ["Tg", "Gp", "Fz", "Aw", "Au"]
CLAIM = ["Sh", "Ix", "Rb"]
CURVE = ["Cp", "Cl", "St", "Wg", "Pm"]
POSITION = ["Pl", "Im", "Cd", "Uc", "Ft", "Pf", "Op", "Dp"]
PRODUCTIVE_GROUPS = {"G01", "G02", "G03", "G04", "G05", "G07",
                     "G12", "G13", "G15", "G16"}

# Elements with zero witnesses across the 72-protocol census (three lanes,
# twelve categories, ranked live). See the V stratum.
UNWITNESSED = ["Cv", "Sb", "Sd", "Wg"]


def C(cid, trigger, head, note):
    return {"id": cid, "trigger": [tuple(t) for t in trigger],
            "head": list(head), "note": note}


# =============================================================== R stratum
R = [
    C("R1", [("Pl",), ("Im",), ("Cd",)], TRUTH,
      "L1 term 1, widened. G08 has four members and the atlas term named three; "
      "Oa is a truth source, Pm carries a reference price, and Sv is the "
      "determination authority that stands in for an oracle in private credit."),
    C("R2", [("Im",), ("Cd",), ("Pf",)], ["Ct"],
      "L1/L4 term 2, narrowed. A margined facility needs the threshold test. "
      "Pl is dropped as a subject: Across's relayer pool is a Pl with no margin."),
    C("R3", [("Im",), ("Cd",), ("Pf",)], TERM,
      "L1/L4 term 3, widened. L4's `Ad|Sl|Bs` is refuted by Aster and Aevo, "
      "which terminate through Li; Rd and Ps are terminal for a CDP."),
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
      "TVL have no verifier at all because a company holds the asset, and what "
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
    # --- promoted from the SCREEN, not from the law list -------------------
    C("R24", [("Li",), ("Ad",)], ["Ct"],
      "Screen 3. A liquidation or a forced close is the *consequent* of a "
      "threshold test; without Ct there is no predicate to trigger on. Exact "
      "on the census: all 22 Li-bearing and all 3 Ad-bearing protocols have Ct."),
    C("R25", [("Uc",)], ["Pl", "Im", "Ft", "Sh", "Ix"],
      "Screen 2. An extension of credit has to be recorded as somebody's claim."),
    C("R26", [("Dp",)], ["Ex", "Pf", "Op", "Ct", "Pm", "Ob", "At"],
      "Screen 3. A maintained directional position needs a mark."),
    C("R27", [("Sv",)], ["Tr", "Uc", "Ft", "Pl", "Im", "Cd", "Op", "Cv",
                         "Sh", "Ix", "Rd", "Wq", "Ep"],
      "Discretion is discretion *over* something: a determination that alters "
      "no named claim is not an element of a protocol."),
    C("R28", [("Fl",)], CURVE + ["Pl", "Im", "Cd", "Ag", "Ob", "Ct"],
      "Screen 5. Atomic flash liquidity has to be borrowed from an inventory "
      "or a pool. Ct admitted for the consumer case (CIAN loops with flash "
      "liquidity sourced elsewhere)."),
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
]

# =============================================================== C stratum
COMPLETION = [
    C("C1", [("Ct",)], POSITION + ["Rs", "Vl", "Fl", "Rd", "Pm"],
      "Completion of R2/R4/R24: a collateral-threshold test with nothing to "
      "test is unfounded. Licensors are every element that can create a "
      "margined position, plus Fl (leverage looping, CIAN), Rd and Pm (the two "
      "live protocols whose margin is priced off a redemption or an inventory "
      "curve rather than off a debt element)."),
    C("C2", [("Sl",)], ["Ct", "Pl", "Im", "Cd", "Pf", "Op", "Uc", "Ft",
                        "Rs", "Vl", "Bs", "Tr", "Dp", "Ps"],
      "Completion: socialized loss presupposes a loss-bearing claim class."),
    C("C3", [("Wq",)], CLAIM + ["Rd", "Vl", "Rs", "Pl", "Im", "Uc", "Ft",
                                "Ep", "Ps", "Xf", "Op", "Tr", "Bs"],
      "Completion: a withdrawal queue with no queued claim."),
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
      "Completion: a cumulative-price accumulator with no inventory to "
      "accumulate over."),
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
    C("C13", [("Ag",)], CURVE + ["Ob", "Rf", "Ba", "In", "Fl", "Sh", "Ix",
                                 "Em", "Fd", "Tp", "St", "Pl", "Xf"],
      "Completion: routing with nothing to route across."),
    C("C14", [("At",)], ["Rd", "Ps", "Xf", "Cd", "Uc", "Ft", "Tr", "Sh", "Ix",
                         "Rb", "Sv", "Aw", "Pl", "Im", "As", "Fz", "Vl", "Rs",
                         "Bs", "Ct", "Wq", "Dp", "Ep", "Xm", "Oa"],
      "Completion: an attestation is always about a named subject."),
    C("C15", [("Rb",)], CLAIM + ["Pl", "Im", "Cd", "Vl", "Rs", "Ps", "Rd",
                                 "Sr", "Ep", "Xf", "Wq", "Em", "Tr", "Ct"],
      "Completion: rebasing rescales a claim that some other element records."),
]

# =============================================================== W stratum
W = [
    C("W1", [(s,) for s in A.SYMS],
      [s for s in A.SYMS if A.GROUP[s] in PRODUCTIVE_GROUPS],
      "Thesis axiom. A non-empty presentation must name at least one element "
      "outside the pure-adjunct groups (G06 solvency, G08 truth, G09 time, "
      "G10 incentives, G11 control, G14 access). A set of adjuncts is a "
      "governance wrapper around nothing."),
]

# =============================================================== X stratum
X = [
    C("X1p", [("As",)], ["Rd", "Ps", "At", "Bs", "Cv"],
      "X1 (Terra) in requirement form: algorithmic supply adjustment with no "
      "hard redemption and no exogenous reserve. The reflexive 2-cycle itself "
      "is not expressible over element types (FINDINGS Q13); this is its "
      "membership shadow."),
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
      "is not admitted into a presentation of a deployed protocol. It is the "
      "one axiom in the model justified by absence of evidence rather than by "
      "mechanism semantics, and it would reject a correct decomposition of "
      "Nexus Mutual (Cv) or Railgun (Sb)."),
]

POOL = R + COMPLETION + W + X + V


def fires(cl, S):
    return any(all(a in S for a in t) for t in cl["trigger"])


def violations(S, clauses=None):
    if clauses is None:
        clauses = POOL
    S = set(S)
    return [cl["id"] for cl in clauses
            if fires(cl, S) and not any(h in S for h in cl["head"])]


def valid(S, clauses=None):
    return not violations(S, clauses)
