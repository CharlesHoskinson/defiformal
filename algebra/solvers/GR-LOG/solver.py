#!/usr/bin/env python3
import json, itertools, re

SYMS = [
 "Sh","Ix","Rb","Cp","Wg","St","Cl","Pm","Ob","Rf","Ba","In","Ag","Fl",
 "Pl","Im","Cd","Uc","Ft","Ct","Li","Ad","Sl","Bs","Pf","Op","Tr","Cv",
 "Py","Sv","Dp","Ex","Tp","Oa","At","Sr","Ep","Wq","Em","Fd","Tg","Up",
 "Gp","Au","Gs","Xm","Xf","Rl","Of","Rd","Ps","As","Aw","Sb","Sd","Fz",
 "Rs","Vl",
]
SYMSET = set(SYMS)
assert len(SYMS) == 58, len(SYMS)

def bare(s):
    s = re.sub(r"\{[^}]*\}", "", s)
    s = s.replace("(", "").replace(")", "")
    return s.strip()

LAWS_RAW = [
 ("L1",  "(Pl|Im|Cd|Pf|Op) -> (Ex|Tp|At) + Ct + (Li|Ad|Sl|Bs)"),
 ("L2",  "Pl -> (Sh|Ix) + exit-liquidity"),
 ("L3",  "Uc -> Aw + At + (Bs|Tr) + obligor"),
 ("L4",  "Pf -> Ex + Ct + Li + (Ad|Sl|Bs)"),
 ("L5",  "Py -> (Sh|Ix|Rb) + Ep + Rd"),
 ("L6",  "Tr -> (Sv|mechanical-trigger) + declared-seniority + dispute-forum + recovery-timing-assumption"),
 ("L7",  "Cd -> Rd|Ps|liquidation-capacity"),
 ("L8",  "Xf -> Xm|named-custodian + a-global-claim-ledger"),
 ("L9",  "Xf -> debit-source-equals-credit-destination"),
 ("L10", "Sb -> proof-verifier + nullifier-set"),
 ("L11", "Sd -> credential-source + verifier + revocation"),
 ("L12", "In -> signed-constraints + settlement-verifier + (solver|fallback) + timeout"),
 ("L13", "Ex -> freshness-validation"),
 ("L14", "illiquid-backing -> Wq|bounded-liquidity-reserve"),
 ("L15", "Up -> Tg|bounded-emergency-process"),
 ("L16", "Aw -> transfer-time-enforcement-where-eligibility-follows-holder"),
 ("L17", "Au -> bounded-scope + revocation + expiry + nonce-domain-separation"),
 ("L18", "Xm -> explicit-finality + chain-domain-binding + replay-protection"),
 ("L19", "Of -> Xm + Xf + (Bs|Sl) + timeout"),
 ("L20", "Rl -> Au + single-spend + expiry + fulfillment-proof + release"),
 ("L21", "Gs -> Au + metering + fee-settlement"),
 ("L22", "Rs -> attributed-slash-condition + non-reflexive-capital + loss-waterfall"),
 ("L23", "Sq -> Xm + independent-settlement-finality"),
 ("L24", "(In|Rf|Ba) -> an-explicit-informational-edge-with-a-catalog-tag"),
 ("L25", "wrapped-cross-domain-collateral -> haircut + cap + independent-exit"),
 ("L26", "Aw+Xf -> destination-enforced-eligibility + revocation-propagation + jurisdictional-binding"),
 ("L27", "At -> named-attester + independence + stated-assurance + staleness-bound + recourse"),
 ("L28", "Fz -> named-authority + enumerated-triggers + appeal-path + holder-disclosure"),
 ("L29", "(In|Ba|Rf|Of) -> a-declared-surplus-allocation-rule-naming-the-residual-claimant"),
]

def parse_law(rule):
    lhs, rhs = rule.split("->")
    subjects = [bare(s) for s in lhs.split("|")]
    subjects = [s for s in subjects if s in SYMSET]
    terms = []
    for chunk in rhs.split("+"):
        raw = chunk.strip()
        alts = [bare(a) for a in raw.split("|")]
        alts = [a for a in alts if a in SYMSET]
        terms.append({"alts": alts, "raw": raw, "external": len(alts) == 0})
    return {"subjects": subjects, "terms": terms}

LAWS = [(lid, parse_law(rule), rule) for lid, rule in LAWS_RAW]

FIREABLE_LAW_IDS = sorted(lid for lid, p, _ in LAWS if p["subjects"])
assert len(FIREABLE_LAW_IDS) == 25, (len(FIREABLE_LAW_IDS), FIREABLE_LAW_IDS)

def closes(present):
    S = set(present)
    open_terms = []
    for lid, p, rule in LAWS:
        if not any(s in S for s in p["subjects"]):
            continue
        for t in p["terms"]:
            if t["external"]:
                continue
            if not any(a in S for a in t["alts"]):
                open_terms.append((lid, t["raw"]))
    return len(open_terms) == 0, open_terms

def present_all(S, *xs): return all(x in S for x in xs)
def absent_all(S, *xs): return all(x not in S for x in xs)

HAZARDS = []
HAZARDS.append(("X1", "F", lambda S: present_all(S,"As") and absent_all(S,"Cd") and absent_all(S,"Bs")))
HAZARDS.append(("X2", "H", lambda S: present_all(S,"Fl") and (("Cp" in S) or ("Cl" in S)) and (("Pl" in S) or ("Cd" in S))))
HAZARDS.append(("X3", "H", lambda S: False))
HAZARDS.append(("X4", "F", lambda S: False))
HAZARDS.append(("X5", "H", lambda S: present_all(S,"Rd") and absent_all(S,"Wq") and (("Cd" in S) or ("Ft" in S))))
HAZARDS.append(("X6", "H", lambda S: (("Pl" in S) or ("Im" in S)) and absent_all(S,"Tg")))
HAZARDS.append(("X7", "H", lambda S: present_all(S,"Xm") and absent_all(S,"Rs")))
HAZARDS.append(("X8", "H", lambda S: False))
HAZARDS.append(("X9", "H", lambda S: present_all(S,"Up") and absent_all(S,"Tg") and absent_all(S,"Gp")))
HAZARDS.append(("X10", "H", lambda S: present_all(S,"Pm") and absent_all(S,"Ex")))
HAZARDS.append(("X11a", "F", lambda S: present_all(S,"Uc") and absent_all(S,"Aw") and absent_all(S,"At")))
HAZARDS.append(("X11b", "H", lambda S: False))
HAZARDS.append(("X12", "H", lambda S: False))
HAZARDS.append(("X13", "H", lambda S: present_all(S,"Xm") and absent_all(S,"Rs") and absent_all(S,"Bs")))
HAZARDS.append(("X14", "U", lambda S: False))
HAZARDS.append(("X15", "H", lambda S: present_all(S,"Rs") and present_all(S,"Xm") and absent_all(S,"Bs")))
HAZARDS.append(("X16", "H", lambda S: present_all(S,"Au") and absent_all(S,"Tg") and absent_all(S,"Gp")))
HAZARDS.append(("X17", "H", lambda S: False))
HAZARDS.append(("X18", "H", lambda S: present_all(S,"Oa") and present_all(S,"Li") and absent_all(S,"Ex")))
HAZARDS.append(("X19", "F", lambda S: present_all(S,"Xf") and present_all(S,"Fz") and absent_all(S,"Aw")))
HAZARDS.append(("X20", "F", lambda S: present_all(S,"Fl") and (("Xm" in S) or (present_all(S,"Au") and present_all(S,"Rl")))))

def hazard_report(S):
    return [(hid, cls) for hid, cls, fn in HAZARDS if fn(S)]

def admissible(present):
    S = set(present)
    ok, open_terms = closes(S)
    fired = hazard_report(S)
    blocking = [h for h in fired if h[1] == "F"]
    verdict = ok and not blocking
    return verdict, {
        "closes": ok,
        "open_terms": open_terms,
        "hazards_fired": fired,
        "blocking": blocking,
    }

if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["classify", "selfcheck", "redundancy"])
    ap.add_argument("--in", dest="infile")
    ap.add_argument("--out", dest="outfile")
    args = ap.parse_args()

    if args.cmd == "classify":
        data = json.load(open(args.infile, encoding="utf-8"))
        cases = data["cases"]
        verdicts = []
        for c in cases:
            v, detail = admissible(c["elements"])
            verdicts.append({"id": c["id"], "verdict": "ADMISSIBLE" if v else "INADMISSIBLE"})
        out = {"verdicts": verdicts}
        with open(args.outfile, "w", encoding="utf-8") as f:
            json.dump(out, f, indent=2)
        print("wrote " + str(len(verdicts)) + " verdicts to " + args.outfile)

    elif args.cmd == "selfcheck":
        import glob
        real = []
        for fn in glob.glob("/root/DefiElements/corpus50/lanes/*.json"):
            d = json.load(open(fn, encoding="utf-8"))
            for cat in d["categories"]:
                for p in cat["protocols"]:
                    real.append((p["name"], list(dict.fromkeys(p["elements"]))))
        neg = json.load(open("/root/DefiElements/algebra/negative-corpus.json", encoding="utf-8"))

        real_admit = sum(1 for _, syms in real if admissible(syms)[0])
        print("REAL: " + str(real_admit) + "/" + str(len(real)) + " admissible (" + str(round(100*real_admit/len(real),1)) + "%)")

        fam_stats = {}
        for c in neg["cases"]:
            v, _ = admissible(c["syms"])
            fam = c["family"]
            fam_stats.setdefault(fam, [0, 0])
            fam_stats[fam][0] += 1
            if v: fam_stats[fam][1] += 1
        tot_n = sum(v[0] for v in fam_stats.values())
        tot_admit = sum(v[1] for v in fam_stats.values())
        for fam, (n, a) in sorted(fam_stats.items()):
            print("  " + fam.ljust(10) + " n=" + str(n).rjust(3) + "  admitted=" + str(a).rjust(3) + " (" + str(round(100*a/n,1)) + "%)")
        print("NEGATIVE (all): " + str(tot_admit) + "/" + str(tot_n) + " admissible (" + str(round(100*tot_admit/tot_n,1)) + "%)")
        real_rate = real_admit/len(real)
        neg_rate = tot_admit/tot_n
        if neg_rate:
            print("discrimination ratio = " + str(round(real_rate/neg_rate,2)) + "x")
        else:
            print("neg_rate=0 -> ratio undefined (infinite)")

    elif args.cmd == "redundancy":
        occ = {s: set() for s in SYMS}
        for lid, p, rule in LAWS:
            for i, t in enumerate(p["terms"]):
                if len(t["alts"]) > 1:
                    key = (lid, i, tuple(sorted(t["alts"])))
                    for a in t["alts"]:
                        occ[a].add(("altgroup", key))
            for s in p["subjects"]:
                occ[s].add(("subject", lid))
        redundant = []
        for a, b in itertools.combinations(SYMS, 2):
            if occ[a] and occ[a] == occ[b]:
                redundant.append((a, b))
        print("symbols with identical clause-occurrence signature (candidates for merging):")
        print(redundant if redundant else "NONE")
