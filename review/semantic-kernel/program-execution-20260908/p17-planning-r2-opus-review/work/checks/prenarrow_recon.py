#!/usr/bin/env python3
"""Reviewer reconstruction of the OVERWRITTEN pre-narrowing r2 intact check.

failed-attempts/README.md says the first intact run exited 1 on
`mutant_V-DEP-CEIL_unaffected_not_from_deposit` because the check demanded
independent funding of EVERY unaffected control, including the D0 deposit
sibling. The failing JSON was overwritten. This reconstructs both the
un-narrowed and the shipped narrowed predicate against the FROZEN r2 bytes
and reports what each would say, plus whether the D0 control is in fact
initialized by invoking a deposit.
"""
import json, sys

fx = json.load(open(sys.argv[1]))
mu = json.load(open(sys.argv[2]))
by_id = {f["id"]: f for f in fx["fixtures"]}

out = {"unnarrowed": [], "shipped_narrowed": [], "substance": []}
for m in mu["vault_production_mutants"]:
    for key in ("unaffected_positive", "additional_unaffected",
                "additional_unaffected_authorization"):
        cid = m.get(key)
        if not cid:
            continue
        f = by_id.get(cid, {})
        indep = f.get("funding") == "independent_prestate_not_mutated_deposit"
        # (a) un-narrowed: EVERY unaffected control must be independently funded
        out["unnarrowed"].append(
            {"mutant": m["id"], "control": cid, "op": f.get("operation"),
             "funding": f.get("funding"), "ok": indep})
        # (b) shipped: only redeem/withdraw controls carry that requirement
        if f.get("operation") in ("redeem", "withdraw"):
            out["shipped_narrowed"].append(
                {"mutant": m["id"], "control": cid, "op": f.get("operation"), "ok": indep})
        # (c) substance: is the control's prestate reachable only via a deposit call?
        #     A control is deposit-derived iff its funded cells are NOT set directly
        #     in its own pre_overrides.
        ov = f.get("pre_overrides") or {}
        funded_directly = {k: v for k, v in ov.items() if int(v) > 0}
        out["substance"].append(
            {"mutant": m["id"], "control": cid, "op": f.get("operation"),
             "cells_funded_directly_in_prestate": sorted(funded_directly),
             "requires_invoking_deposit": len(funded_directly) == 0
                                          and f.get("operation") in ("redeem", "withdraw")})

unnarrowed_fail = [r for r in out["unnarrowed"] if not r["ok"]]
narrowed_fail = [r for r in out["shipped_narrowed"] if not r["ok"]]
subst_fail = [r for r in out["substance"] if r["requires_invoking_deposit"]]
print(json.dumps({
    "unnarrowed_predicate_failures": unnarrowed_fail,
    "unnarrowed_would_exit": 1 if unnarrowed_fail else 0,
    "shipped_narrowed_failures": narrowed_fail,
    "shipped_would_exit": 1 if narrowed_fail else 0,
    "controls_actually_requiring_a_deposit_call": subst_fail,
    "substantive_r1_requirement_violated": bool(subst_fail),
    "detail": out}, indent=2))
sys.exit(0)
