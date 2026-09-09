#!/usr/bin/env python3
"""Reviewer positive controls on the CANDIDATE's own diagnose.py gate.

Each probe applies one defeating mutation to an owned copy of the frozen plan
bytes and records diagnose.py's actual exit and named failures. A probe that
does not exit 1 with the expected named check means that check cannot fail.
Each probe runs in a FRESH copy, so no probe can contaminate another.
"""
import json, os, shutil, subprocess, sys, tempfile

CAND = os.path.abspath("candidate")
CH = "openspec/changes/vault-platform-reuse-p17"
EV = "review/semantic-kernel/vault-platform-reuse/p17/planning/grok-r2"
LEAN = "/home/charl/defiformal/lean"
PROG = "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908"


def fresh_root(tmp):
    root = os.path.join(tmp, "root")
    os.makedirs(os.path.join(root, "review/semantic-kernel"))
    shutil.copytree(os.path.join(CAND, "openspec"), os.path.join(root, "openspec"))
    shutil.copytree(os.path.join(CAND, EV.rsplit("/p17/", 1)[0]),
                    os.path.join(root, EV.rsplit("/p17/", 1)[0]))
    os.symlink(LEAN, os.path.join(root, "lean"))
    os.symlink(PROG, os.path.join(root, "review/semantic-kernel/program-execution-20260908"))
    return root


def edit(root, rel, fn):
    p = os.path.join(root, CH, rel)
    d = json.load(open(p))
    fn(d)
    json.dump(d, open(p, "w"), indent=2)


def fx(d, i):
    return [x for x in d["fixtures"] if x["id"] == i][0]


def drop_usds_log(d):
    f = fx(d, "P17-DEP-D0")
    f["expected"]["full_logs"] = [e for e in f["expected"]["full_logs"] if e["emitter"] != "usds"]

def allowance_not_consumed(d):
    fx(d, "P17-DEP-D0")["expected"]["post"]["usds.allowance.S.vault"] = "1000000000000000000"

def obs_flag_flip(d):
    d["vault_stateful"]["usds_transfer_in_full_logs"] = False

def merge_broken(d):
    fx(d, "P17-RED-D0")["pre"]["usds.balance.vault"] = "2000000000000000000"

def mint_underfunded(d):
    f = fx(d, "P17-MINT-D1")
    for k in ("usds.totalSupply", "usds.balance.S", "usds.allowance.S.vault"):
        f["pre_overrides"][k] = "1000000000000000000"
        f["pre"][k] = "1000000000000000000"

def d1_claimed_reachable(d):
    d["construction"]["domain_overlay"]["D1"]["chi_setup_protocol_reachable"] = True
    for f in d["fixtures"]:
        if f.get("domain") == "D1" and "pre" in f:
            f["pre"]["chi_setup_protocol_reachable"] = True

def funding_relabelled(d):
    fx(d, "P17-RED-D1")["funding"] = "derived_from_deposit"

def neg_reverts_to_valid(d):
    [o for o in d["obligations"] if o["id"] == "P17-TH-NEGATIVE"][0]["predicate"] = "Evaluated.Valid"

def neg_assumes_post(d):
    [o for o in d["obligations"] if o["id"] == "P17-TH-NEGATIVE"][0]["desired_postcondition_assumed"] = True

def drop_positive(d):
    d["fixtures"] = [x for x in d["fixtures"] if x["id"] != "P17-POS-DEPOSIT-CREDIT"]

def gate_true(d):
    d["p17_platform_reuse"] = True

def model_only_false(d):
    d["token0_library_to_kernel_bridge"]["model_only"] = False


PROBES = [
    ("P-01-R3-drop-usds-log",           "fixtures.json",             drop_usds_log),
    ("P-02-R3-allowance-not-consumed",  "fixtures.json",             allowance_not_consumed),
    ("P-03-R3-obs-flag-flip",           "observation-contract.json", obs_flag_flip),
    ("P-04-R2-merge-rule-broken",       "fixtures.json",             merge_broken),
    ("P-05-R2-mint-d1-underfunded",     "fixtures.json",             mint_underfunded),
    ("P-06-R2-d1-claimed-reachable",    "fixtures.json",             d1_claimed_reachable),
    ("P-07-R2-funding-relabelled",      "fixtures.json",             funding_relabelled),
    ("P-08-R1-neg-reverts-to-Valid",    "proof-obligations.json",    neg_reverts_to_valid),
    ("P-09-R1-neg-assumes-desired-post","proof-obligations.json",    neg_assumes_post),
    ("P-10-R1-drop-positive-witness",   "fixtures.json",             drop_positive),
    ("P-11-GATE-platform-reuse-true",   "remaining-gates.json",      gate_true),
    ("P-12-REUSE-model-only-false",     "reuse-design.json",         model_only_false),
    ("P-00-BASELINE-intact",            None,                        None),
]

results = []
outdir = os.path.abspath("work/logs/probes")
for name, rel, fn in PROBES:
    with tempfile.TemporaryDirectory() as tmp:
        root = fresh_root(tmp)
        if fn:
            edit(root, rel, fn)
        out = os.path.join(outdir, name + ".json")
        p = subprocess.run(
            [sys.executable, os.path.join(root, EV, "diagnose.py"), "--out", out],
            capture_output=True, text=True)
        try:
            failures = json.load(open(out))["failures"]
        except Exception:
            failures = None
        results.append({"probe": name, "mutated_file": rel, "exit": p.returncode,
                        "failures": failures, "stderr": p.stderr.strip()})
        print(f"{name:36} exit={p.returncode} failures={failures}")

json.dump({"schema": "opus-review-candidate-gate-probes/v1", "probes": results},
          open(os.path.join(outdir, "SUMMARY.json"), "w"), indent=2)
bad = [r for r in results if (r["probe"].startswith("P-00") and r["exit"] != 0)
       or (not r["probe"].startswith("P-00") and r["exit"] != 1)]
print("probes not behaving as required:", [r["probe"] for r in bad])
sys.exit(1 if bad else 0)
