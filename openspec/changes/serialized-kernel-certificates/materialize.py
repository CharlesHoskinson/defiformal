#!/usr/bin/env python3
"""Author planning literals only. Does not call Lean, execute, or the candidate checker."""
from __future__ import annotations
import copy, json
from pathlib import Path

PARTIES = ["alice", "bob", "vault", "pool"]
ASSETS = ["usd", "share", "collateral", "debt"]
DOMAINS = ["main", "other"]
D = "a12b7cac05a818cc8d35c2ca440b7170a2807e92"
SIX = [
    "registry-trust", "administrator-trust", "context-authenticity",
    "observation-truth", "environment-authenticity", "replay-prevention-outside-model",
]
FAMILIES = [
    "typeCorrect", "footprintCorrect", "authorityCorrect", "accountingCorrect",
    "compositionCompatible", "assumptionsDeclared", "libraryTheoremsInstantiated",
    "sourceRefinement",
]


def rat(n, d=1):
    return {"num": n, "den": d}


def cell(dom, party, asset):
    return {"domain": dom, "party": party, "asset": asset}


def unit_amount(a):
    return {"tag": "amount", "asset": a}


def lit_amt(a, n, d=1):
    return {"tag": "lit", "unit": unit_amount(a), "value": rat(n, d)}


def arg0_usd():
    return {"tag": "arg", "index": 0, "unit": unit_amount("usd")}


def arg0_share():
    return {"tag": "arg", "index": 0, "unit": unit_amount("share")}


def pref(tag, **kw):
    o = {"tag": tag}
    o.update(kw)
    return o


def packed_ref(asset, owner):
    return {"asset": asset, "cell": {"domain": "main", "owner": owner}}


def initial_amounts():
    spec = {
        ("main", "alice", "usd"): rat(10),
        ("main", "alice", "share"): rat(4),
        ("main", "alice", "collateral"): rat(10),
        ("main", "alice", "debt"): rat(2),
        ("main", "vault", "usd"): rat(20),
        ("main", "pool", "usd"): rat(100),
    }
    cells = []
    for d in DOMAINS:
        for p in PARTIES:
            for a in ASSETS:
                cells.append({
                    "domain": d, "party": p, "asset": a,
                    "amount": spec.get((d, p, a), rat(0)),
                })
    assert len(cells) == 32
    return cells


def set_amt(cells, d, p, a, r):
    out = copy.deepcopy(cells)
    for row in out:
        if row["domain"] == d and row["party"] == p and row["asset"] == a:
            row["amount"] = r
            return out
    raise KeyError((d, p, a))


def store12():
    # Independent table bound to Composition.Examples.expectedStore at D, not issueGrants.
    alice_usd = cell("main", "alice", "usd")
    vault_usd = cell("main", "vault", "usd")
    alice_share = cell("main", "alice", "share")
    pool_usd = cell("main", "pool", "usd")
    return {"entries": [
        {"holder": "alice", "domain": "main", "operation": 0, "right": {"tag": "invoke"}, "live": True},
        {"holder": "alice", "domain": "main", "operation": 0, "right": {"tag": "debit", "cell": alice_usd}, "live": True},
        {"holder": "alice", "domain": "main", "operation": 1, "right": {"tag": "invoke"}, "live": True},
        {"holder": "alice", "domain": "main", "operation": 1, "right": {"tag": "debit", "cell": alice_usd}, "live": True},
        {"holder": "alice", "domain": "main", "operation": 1, "right": {"tag": "changeSupply", "domain": "main", "asset": "share"}, "live": True},
        {"holder": "alice", "domain": "main", "operation": 2, "right": {"tag": "invoke"}, "live": True},
        {"holder": "alice", "domain": "main", "operation": 2, "right": {"tag": "debit", "cell": vault_usd}, "live": True},
        {"holder": "alice", "domain": "main", "operation": 2, "right": {"tag": "debit", "cell": alice_share}, "live": True},
        {"holder": "alice", "domain": "main", "operation": 2, "right": {"tag": "changeSupply", "domain": "main", "asset": "share"}, "live": True},
        {"holder": "alice", "domain": "main", "operation": 3, "right": {"tag": "invoke"}, "live": True},
        {"holder": "alice", "domain": "main", "operation": 3, "right": {"tag": "debit", "cell": pool_usd}, "live": True},
        {"holder": "alice", "domain": "main", "operation": 3, "right": {"tag": "changeSupply", "domain": "main", "asset": "debt"}, "live": True},
    ]}


def grant_invoke(op):
    return {"holder": "alice", "domain": "main", "operation": op, "right": {"tag": "invoke"}, "live": True}


def grant_debit_alice_usd(op):
    return {
        "holder": "alice", "domain": "main", "operation": op,
        "right": {"tag": "debit", "cell": cell("main", "alice", "usd")}, "live": True,
    }


def with_grants(store, grants):
    out = copy.deepcopy(store)
    out["entries"].extend(copy.deepcopy(grants))
    return out


def scoped_caps(extra):
    return list(range(12)) + list(range(12, 12 + extra))


def env_amount_obs(n=3):
    # Unit-matching observation so template.evaluate can succeed and later envReadsOK can fail.
    return {"entries": [{
        "key": {"domain": "main", "id": 7},
        "observation": {
            "value": {"unit": unit_amount("usd"), "value": rat(n)},
            "timestamp": 98,
        },
    }]}


def transfer_template():
    # Bound to Typed.Examples.transfer at D.
    guard = {
        "tag": "binary",
        "op": {"tag": "le", "numeric": {"tag": "amount", "asset": "usd"}},
        "x": lit_amt("usd", 0),
        "y": arg0_usd(),
    }
    debit = {
        "tag": "unary",
        "op": {"tag": "neg", "numeric": {"tag": "amount", "asset": "usd"}},
        "x": arg0_usd(),
    }
    return {
        "signature": [unit_amount("usd")],
        "domain": "main",
        "partyArity": 1,
        "guard": guard,
        "deltas": [
            {"asset": "usd", "target": {"domain": "main", "owner": pref("caller")}, "amount": debit},
            {"asset": "usd", "target": {"domain": "main", "owner": pref("argument", index=0)}, "amount": arg0_usd()},
        ],
        "supplyDeltas": [],
        "stateReads": [],
        "envReads": [],
        "writes": [
            packed_ref("usd", pref("caller")),
            packed_ref("usd", pref("argument", index=0)),
        ],
    }


def vault_guarded_transfer():
    t = transfer_template()
    vault_bal = {"tag": "balance", "cell": packed_ref("usd", pref("literal", party="vault"))}
    ge0 = {
        "tag": "binary",
        "op": {"tag": "le", "numeric": {"tag": "amount", "asset": "usd"}},
        "x": lit_amt("usd", 0),
        "y": vault_bal,
    }
    t["guard"] = {"tag": "binary", "op": {"tag": "and"}, "x": t["guard"], "y": ge0}
    t["stateReads"] = [packed_ref("usd", pref("literal", party="vault"))]
    return t


def read_alice_transfer():
    t = transfer_template()
    alice_bal = {"tag": "balance", "cell": packed_ref("usd", pref("caller"))}
    t["guard"] = {
        "tag": "binary", "op": {"tag": "and"},
        "x": t["guard"],
        "y": {"tag": "binary", "op": {"tag": "le", "numeric": {"tag": "amount", "asset": "usd"}},
              "x": arg0_usd(), "y": alice_bal},
    }
    t["stateReads"] = [packed_ref("usd", pref("caller"))]
    return t


def observe_transfer():
    t = transfer_template()
    key = {"domain": "main", "id": 7}
    obs = {"tag": "observe", "ref": {"key": key, "unit": unit_amount("usd")}}
    t["deltas"][0]["amount"] = {"tag": "unary", "op": {"tag": "neg", "numeric": {"tag": "amount", "asset": "usd"}}, "x": obs}
    t["deltas"][1]["amount"] = obs
    t["envReads"] = [{"tag": "observation", "key": key}]
    return t


def registry(extra=None):
    entries = [
        {"id": 0, "template": transfer_template()},
        {"id": 4, "template": vault_guarded_transfer()},
        {"id": 5, "template": read_alice_transfer()},
        {"id": 6, "template": observe_transfer()},
    ]
    if extra:
        entries.extend(extra)
    return {"entries": entries}


def domain_admin():
    return [{"domain": d, "party": "vault"} for d in DOMAINS]


def catalog_ok():
    # Bound to Composition.Examples.catalog ownership/ports, operations limited to transfer for this increment baseline.
    alice_usd = cell("main", "alice", "usd")
    bob_usd = cell("main", "bob", "usd")
    vault_usd = cell("main", "vault", "usd")
    alice_share = cell("main", "alice", "share")
    collateral = cell("main", "alice", "collateral")
    return [
        {
            "id": 0,
            "privateCells": [bob_usd],
            "exports": [{"id": 10, "cell": alice_usd, "writable": True}],
            "imports": [],
            "operations": [{
                "operation": 0,
                "inputs": [{"id": 0, "unit": unit_amount("usd")}],
                "outputs": [{"id": 1, "cell": alice_usd}],
            }],
        },
        {
            "id": 1,
            "privateCells": [vault_usd, alice_share],
            "exports": [],
            "imports": [{"source": {"component": 0, "port": 10}, "cell": alice_usd, "writable": True}],
            "operations": [],
        },
        {
            "id": 2,
            "privateCells": [collateral],
            "exports": [],
            "imports": [],
            "operations": [],
        },
    ]


def env_empty():
    return {"entries": []}


def env_price():
    return {"entries": [{
        "key": {"domain": "main", "id": 7},
        "observation": {
            "value": {"unit": {"tag": "price", "base": "collateral", "quote": "usd"}, "value": rat(2)},
            "timestamp": 98,
        },
    }]}


def assumptions_all():
    return {k: "present" for k in SIX}


def judgments(mapping, claimed=None):
    claimed = claimed or {}
    out = []
    for fam in FAMILIES:
        outcome = mapping[fam]
        cl = bool(claimed.get(fam, False))
        if outcome in ("true", "false"):
            match = (cl is False and outcome == "true") or (cl is True and outcome == "true") or (cl is True and outcome == "false")
            # claimed is input label; match means claimed equals recomputed boolean.
            rec = outcome == "true"
            match = (cl == rec)
        else:
            match = not cl  # claiming a not_reached family is a mismatch
        out.append({"family": fam, "outcome": outcome, "claimed": cl, "match": match})
    return out


NA = "not_applicable"
NR = "not_reached"


def typed_success_j():
    return {
        "typeCorrect": "true", "footprintCorrect": "true", "authorityCorrect": "true",
        "accountingCorrect": "true", "compositionCompatible": NA,
        "assumptionsDeclared": "true", "libraryTheoremsInstantiated": NA, "sourceRefinement": NA,
    }


def typed_fail_before(family_false=None, reached_true=()):
    m = {f: NR for f in FAMILIES}
    m["compositionCompatible"] = NA
    m["libraryTheoremsInstantiated"] = NA
    m["sourceRefinement"] = NA
    m["assumptionsDeclared"] = "true"
    for f in reached_true:
        m[f] = "true"
    if family_false:
        m[family_false] = "false"
    return m


def pin():
    return {
        "git": D,
        "lean_toolchain": "leanprover/lean4:v4.33.0-rc2",
        "mathlib_rev": "51e6992efd06126df61a496bebf8f49482a4e129",
        "checker_candidate": "unimplemented",
        "compiler_record": None,
        "audit_record": None,
    }


def roots():
    return [
        "DefiKernel.Certificates",
        "DefiKernel.Typed",
        "DefiKernel.Composition",
    ]


def report(status, failure, world_cells, store, **kw):
    jmap = kw.pop("jmap")
    claimed = kw.pop("claimed", None)
    rec = {
        "status": status,
        "failure": failure,
        "judgments": judgments(jmap, claimed),
        "world": {"state": {"cells": world_cells}, "capabilities": store},
        "receipt": kw.get("receipt"),
        "outputs": kw.get("outputs", []),
        "events": kw.get("events", []),
        "nextIndex": kw.get("nextIndex", 0),
        "cursorFailure": kw.get("cursorFailure"),
        "assumptions": kw.get("assumptions", assumptions_all()),
        "outstanding": kw.get("outstanding", []),
        "source_pin": kw.get("source_pin", pin()),
        "audit_roots": kw.get("audit_roots", roots()),
        "unsupported": kw.get("unsupported"),
    }
    assert set(rec) == {
        "status", "failure", "judgments", "world", "receipt", "outputs", "events",
        "nextIndex", "cursorFailure", "assumptions", "outstanding", "source_pin",
        "audit_roots", "unsupported",
    }
    return rec


def transfer_request(amount=3, recipient="bob", caps=None, claimed_actor=None, op=0):
    return {
        "operation": op,
        "parties": [recipient],
        "arguments": [{"unit": unit_amount("usd"), "value": rat(amount)}],
        "capabilityIds": caps if caps is not None else list(range(12)),
        "claimedActor": claimed_actor,
    }


def invoke_step(amount=3, component=0, op=0, inputs=None, caps=None):
    return {
        "tag": "invoke",
        "invocation": {
            "component": component,
            "operation": op,
            "parties": ["bob"],
            "inputs": inputs if inputs is not None else [{"tag": "literal", "value": {"unit": unit_amount("usd"), "value": rat(amount)}}],
            "capabilityIds": caps if caps is not None else list(range(12)),
            "claimedActor": None,
        },
    }


def receipt_transfer3():
    return {
        "tag": "invoked",
        "request": transfer_request(3),
        "evaluated": {
            "guard": True,
            "deltas": [
                {"cell": cell("main", "alice", "usd"), "amount": rat(-3)},
                {"cell": cell("main", "bob", "usd"), "amount": rat(3)},
            ],
            "supplies": [],
            "requiredStateReads": [],
            "requiredEnvReads": [],
            "declaredStateReads": [],
            "declaredEnvReads": [],
            "writes": [cell("main", "alice", "usd"), cell("main", "bob", "usd")],
        },
    }


def snapshot_alice(index, amount):
    return [{
        "step": index,
        "port": {"component": 0, "port": 1},
        "value": {"unit": unit_amount("usd"), "value": rat(amount)},
    }]


def types():
    return {"parties": PARTIES, "assets": ASSETS, "domains": DOMAINS}


def envelope(mode, payload, **kw):
    env = {
        "schema_version": 1,
        "mode": mode,
        "source_pin": pin(),
        "audit_roots": roots(),
        "types": types(),
        "assumptions": SIX,
        "invariants": kw.get("invariants", []),
        "libraries": kw.get("libraries", []),
        "source_map": kw.get("source_map", {
            "transfer": "lean/DefiKernel/Typed/Examples.lean:transfer",
            "store": "lean/DefiKernel/Composition/Examples.lean:expectedStore",
        }),
        "payload": payload,
        "claimed_judgments": kw.get("claimed_judgments", []),
        "claimed_next_state": kw.get("claimed_next_state"),
        "require_library_discharge": kw.get("require_library_discharge", False),
        "require_invariant_discharge": kw.get("require_invariant_discharge", False),
    }
    return env


def world0():
    return {"state": {"cells": initial_amounts()}, "capabilities": store12()}


def after_transfer3():
    cells = set_amt(initial_amounts(), "main", "alice", "usd", rat(7))
    cells = set_amt(cells, "main", "bob", "usd", rat(3))
    return cells


def after_repeated():
    cells = set_amt(initial_amounts(), "main", "alice", "usd", rat(4))
    cells = set_amt(cells, "main", "bob", "usd", rat(6))
    return cells


def after_second_transfer7():
    cells = after_transfer3()
    cells = set_amt(cells, "main", "alice", "usd", rat(0))
    cells = set_amt(cells, "main", "bob", "usd", rat(10))
    return cells


def payload_typed(req=None, store=None, ctx=None, env=None, state=None, now=100):
    return {
        "registry": registry(),
        "store": store if store is not None else store12(),
        "ctx": ctx or {"principal": "alice", "domain": "main"},
        "env": env if env is not None else env_empty(),
        "now": now,
        "request": req if req is not None else transfer_request(3),
        "state": {"cells": state if state is not None else initial_amounts()},
    }


def payload_step(step, catalog=None, index=0, history=None, pre=None, boundary=None):
    return {
        "config": {
            "registry": registry(),
            "domainAdmin": domain_admin(),
            "catalog": catalog if catalog is not None else catalog_ok(),
        },
        "boundary": boundary or {"ctx": {"principal": "alice", "domain": "main"}, "env": env_empty(), "now": 100},
        "index": index,
        "history": history or [],
        "step": step,
        "pre": pre or world0(),
    }


def payload_run(steps, catalog=None, world=None, boundaries=None):
    n = max(len(steps), 1)
    b = {"ctx": {"principal": "alice", "domain": "main"}, "env": env_empty(), "now": 100}
    return {
        "config": {
            "registry": registry(),
            "domainAdmin": domain_admin(),
            "catalog": catalog if catalog is not None else catalog_ok(),
        },
        "boundaries": boundaries or [b] * n,
        "world": world or world0(),
        "steps": steps,
    }


def codec(status, failure, raw="", ir=None):
    return {
        "mode": "codec",
        "result": {"status": status, "failure": failure, "ir": ir},
        "raw_utf8": raw,
    }


def audit(status, failure, **kw):
    return {
        "mode": "audit",
        "result": {"status": status, "failure": failure, **kw},
    }


def compact(obj):
    return json.dumps(obj, separators=(",", ":"), ensure_ascii=False)


def baseline():
    return {
        "status": "independent_literals_bound_to_D_examples_not_holdouts",
        "source_bindings": {
            "initial_ledger": "lean/DefiKernel/Typed/Examples.lean def initial",
            "transfer": "lean/DefiKernel/Typed/Examples.lean def transfer",
            "store": "lean/DefiKernel/Composition/Examples.lean def expectedStore",
            "catalog_ownership": "lean/DefiKernel/Composition/Examples.lean def catalog",
            "admin": "lean/DefiKernel/Typed/Examples.lean def adminContext / domainAdmin",
            "alice_boundary": "lean/DefiKernel/Typed/Examples.lean def aliceContext",
        },
        "does_not_import_Composition_Examples": True,
        "preservation_dependency": "not in checker runtime closure unless Certificates.Examples imports Composition.Examples",
        "types": types(),
        "cells_32": initial_amounts(),
        "store_12": store12(),
        "fresh_id_from_store12": 12,
        "admin_boundary": {"ctx": {"principal": "vault", "domain": "main"}, "env": env_empty(), "now": 100},
        "alice_boundary": {"ctx": {"principal": "alice", "domain": "main"}, "env": env_empty(), "now": 100},
        "frame_cells_unmoved_by_transfer3": [
            cell("main", "alice", "collateral"),
            cell("main", "alice", "debt"),
            cell("main", "pool", "usd"),
            cell("main", "vault", "usd"),
            cell("main", "alice", "share"),
        ],
        "registry": registry(),
        "catalog": catalog_ok(),
        "transfer_3_expected_cells": after_transfer3(),
        "independent_arithmetic": {
            "F25": "10-3=7 and 0+3=3 and collateral10 debt2 pool100 vault20 share4 unchanged",
            "F09": "10-3-3=4 and 0+6=6",
            "F23": "3!=4",
            "F24": "10-11<0",
            "F48": "after 3 then consume priorOutput 7: alice 0 bob 10",
        },
    }


def catalog_dup_ids():
    ok = catalog_ok()
    other = {
        "id": 0,
        "privateCells": [cell("other", "pool", "debt")],
        "exports": [],
        "imports": [],
        "operations": [],
    }
    return [ok[0], other, ok[1], ok[2]]


def catalog_export_private():
    ok = catalog_ok()
    bad = copy.deepcopy(ok)
    # component 0 exports bobUsd which is its own private cell — designated fault only
    bad[0]["exports"] = [{"id": 10, "cell": cell("main", "bob", "usd"), "writable": True}]
    # output port still aliceUsd which it can read via... canRead includes private and exports.
    # aliceUsd is no longer exported; private is bobUsd only; cannot read aliceUsd for output.
    # Keep a valid output on bobUsd which it can read as private, and add a unique output port id.
    bad[0]["operations"][0]["outputs"] = [{"id": 1, "cell": cell("main", "bob", "usd")}]
    return bad


def catalog_no_vault_read():
    # component 0 cannot read vault usd; used with op 4 vault-guarded transfer
    ok = catalog_ok()
    c0 = copy.deepcopy(ok[0])
    c0["operations"].append({
        "operation": 4,
        "inputs": [{"id": 2, "unit": unit_amount("usd")}],
        "outputs": [{"id": 3, "cell": cell("main", "alice", "usd")}],
    })
    # portIds must be nodup: existing 10,0,1 plus 2,3
    return [c0, ok[1], ok[2]]


def repeated_delta_template():
    t = transfer_template()
    debit = t["deltas"][0]
    credit = t["deltas"][1]
    t["deltas"] = [copy.deepcopy(debit), copy.deepcopy(debit),
                   {**copy.deepcopy(credit), "amount": lit_amt("usd", 6)}]
    # credit uses arg; for amount 3+3 listed as two debits of arg and credit lit 6 would not match
    # Independent: two debit-3 literals plus credit 6, partyArity 0, signature empty? Use lit amounts.
    t["signature"] = []
    t["partyArity"] = 0
    t["guard"] = {"tag": "lit", "unit": {"tag": "bool"}, "value": True}
    t["deltas"] = [
        {"asset": "usd", "target": {"domain": "main", "owner": pref("caller")},
         "amount": {"tag": "unary", "op": {"tag": "neg", "numeric": {"tag": "amount", "asset": "usd"}},
                    "x": lit_amt("usd", 3)}},
        {"asset": "usd", "target": {"domain": "main", "owner": pref("caller")},
         "amount": {"tag": "unary", "op": {"tag": "neg", "numeric": {"tag": "amount", "asset": "usd"}},
                    "x": lit_amt("usd", 3)}},
        {"asset": "usd", "target": {"domain": "main", "owner": pref("literal", party="bob")},
         "amount": lit_amt("usd", 6)},
    ]
    t["writes"] = [
        packed_ref("usd", pref("caller")),
        packed_ref("usd", pref("literal", party="bob")),
    ]
    return t


def unbalanced_template():
    t = transfer_template()
    t["signature"] = []
    t["partyArity"] = 0
    t["guard"] = {"tag": "lit", "unit": {"tag": "bool"}, "value": True}
    t["deltas"] = [
        {"asset": "usd", "target": {"domain": "main", "owner": pref("caller")},
         "amount": {"tag": "unary", "op": {"tag": "neg", "numeric": {"tag": "amount", "asset": "usd"}},
                    "x": lit_amt("usd", 3)}},
        {"asset": "usd", "target": {"domain": "main", "owner": pref("literal", party="bob")},
         "amount": lit_amt("usd", 4)},
    ]
    t["writes"] = [
        packed_ref("usd", pref("caller")),
        packed_ref("usd", pref("literal", party="bob")),
    ]
    return t


def undeclared_write_template():
    t = transfer_template()
    t["writes"] = [packed_ref("usd", pref("caller"))]
    return t


def undeclared_state_read_template():
    t = read_alice_transfer()
    t["stateReads"] = []
    return t


def undeclared_env_read_template():
    t = observe_transfer()
    t["envReads"] = []
    return t


def extra_reg(*ts):
    r = registry()
    r["entries"].extend(ts)
    return r


def build_fixtures():
    init = initial_amounts()
    post = after_transfer3()
    st = store12()
    fx = []

    def add(fid, name, scenarios, kind, inputs, expected, evidence, **kw):
        fx.append({
            "id": fid, "name": name, "scenarios": scenarios, "kind": kind,
            "inputs": inputs, "expected": expected, "evidence_class": evidence,
            "status": "planned_not_executed",
            **kw,
        })

    # codec
    env_ok = envelope("typed-execute", payload_typed())
    raw_ok = compact(env_ok)
    add("F01", "empty document", ["S15", "S62", "S40", "S67", "S80"], "codec",
        {"raw_utf8": ""},
        codec("malformed", {"ctor": "emptyDocument"}, raw=""),
        "malformed control")
    missing = copy.deepcopy(env_ok)
    missing.pop("payload")
    add("F02", "missing payload/transitions field", ["S16", "S62"], "codec",
        {"raw_utf8": compact(missing)},
        codec("malformed", {"ctor": "missingField", "name": "payload"}),
        "missing-field control")
    bad_rat = copy.deepcopy(env_ok)
    bad_rat["payload"]["request"]["arguments"][0]["value"] = {"num": 2, "den": 4}
    add("F03", "unreduced rational", ["S01", "S62"], "codec",
        {"raw_utf8": compact(bad_rat)},
        codec("malformed", {"ctor": "illegalRational", "reason": "noncanonical"}),
        "rational control")
    raw_float = raw_ok.replace('"num":3,"den":1', "0.5", 1)
    add("F04", "float amount lexical", ["S04", "S62", "S77"], "codec",
        {"raw_utf8": raw_float},
        codec("malformed", {"ctor": "lexicalScientificOrFloat"}),
        "rational control")
    zero_den = copy.deepcopy(env_ok)
    zero_den["payload"]["request"]["arguments"][0]["value"] = {"num": 1, "den": 0}
    add("F05", "zero denominator", ["S03", "S62"], "codec",
        {"raw_utf8": compact(zero_den)},
        codec("malformed", {"ctor": "illegalRational", "reason": "zeroDenominator"}),
        "rational control")
    unk = copy.deepcopy(env_ok)
    unk["payload"]["request"]["parties"] = ["carol"]
    add("F06", "unknown party", ["S05"], "codec",
        {"raw_utf8": compact(unk)},
        codec("malformed", {"ctor": "unknownIdentifier", "name": "carol"}),
        "identifier control")
    neg = copy.deepcopy(env_ok)
    neg["payload"]["request"]["operation"] = -1
    add("F07", "negative operation id", ["S06"], "codec",
        {"raw_utf8": compact(neg)},
        codec("malformed", {"ctor": "jsonType", "path": "operation"}),
        "identifier control")

    # F08 duplicate catalog ids — decodes, then configuration
    add("F08", "duplicate component ids otherwise valid", ["S08", "S30", "S44"], "composition-step",
        envelope("composition-step", payload_step(invoke_step(3), catalog=catalog_dup_ids())),
        report("refused", {"class": "configuration", "ctor": "configuration", "payload": None},
               init, st, jmap={
                   "typeCorrect": NR, "footprintCorrect": NR, "authorityCorrect": NR,
                   "accountingCorrect": NR, "compositionCompatible": "false",
                   "assumptionsDeclared": "true", "libraryTheoremsInstantiated": NA, "sourceRefinement": NA,
               }, cursorFailure={"index": 0, "step": None, "reason": {"class": "configuration"}},
               nextIndex=0),
        "catalog refusal")

    # F09 repeated deltas — op 7 needs scoped invoke+debit; IDs 12/13 are the new permanent indices.
    reg9 = extra_reg({"id": 7, "template": repeated_delta_template()})
    st9 = with_grants(st, [grant_invoke(7), grant_debit_alice_usd(7)])
    req9 = {"operation": 7, "parties": [], "arguments": [], "capabilityIds": scoped_caps(2), "claimedActor": None}
    pl9 = payload_typed(req9, store=st9)
    pl9["registry"] = reg9
    add("F09", "repeated deltas add", ["S09", "S87"], "typed-execute",
        envelope("typed-execute", pl9),
        report("accepted", None, after_repeated(), st9, jmap=typed_success_j(),
               receipt={
                   "tag": "invoked", "request": req9,
                   "evaluated": {
                       "guard": True,
                       "deltas": [
                           {"cell": cell("main", "alice", "usd"), "amount": rat(-3)},
                           {"cell": cell("main", "alice", "usd"), "amount": rat(-3)},
                           {"cell": cell("main", "bob", "usd"), "amount": rat(6)},
                       ],
                       "supplies": [], "requiredStateReads": [], "requiredEnvReads": [],
                       "declaredStateReads": [], "declaredEnvReads": [],
                       "writes": [cell("main", "alice", "usd"), cell("main", "bob", "usd")],
                   },
               }),
        "funded execution")

    add("F10", "duplicate capability ids confer no extra debit", ["S10"], "typed-execute",
        envelope("typed-execute", payload_typed(transfer_request(3, caps=[0, 0]))),
        report("refused", {"class": "kernel", "ctor": "unauthorizedDebit", "payload": None},
               init, st, jmap=typed_fail_before("authorityCorrect", reached_true=("typeCorrect", "footprintCorrect"))),
        "authority refusal")

    silent = copy.deepcopy(env_ok)
    silent["silentPass"] = True
    add("F11", "unknown executable field", ["S11"], "codec",
        {"raw_utf8": compact(silent)},
        codec("malformed", {"ctor": "unknownExecutableField", "name": "silentPass"}),
        "schema control")
    ver = copy.deepcopy(env_ok)
    ver["schema_version"] = 2
    add("F12", "schema version mismatch", ["S12"], "codec",
        {"raw_utf8": compact(ver)},
        codec("malformed", {"ctor": "schemaVersion"}),
        "schema control")
    add("F13", "envelope keys present codec ok", ["S13", "S14"], "codec",
        {"raw_utf8": raw_ok},
        codec("ok", None, raw=raw_ok, ir="DecodedIR of F25 payload"),
        "decode positive")
    tree = copy.deepcopy(envelope("composition-step", payload_step({"tag": "treeJoin"})))
    add("F14", "unsupported tree ctor", ["S18", "S62"], "codec",
        {"raw_utf8": compact(tree)},
        codec("malformed", {"ctor": "unsupportedForm", "reason": "treeJoin"}),
        "unsupported-form control")

    # typing
    bad_unit = transfer_request(3)
    bad_unit["arguments"] = [{"unit": unit_amount("share"), "value": rat(3)}]
    add("F15", "argument unit mismatch", ["S19", "S43"], "typed-execute",
        envelope("typed-execute", payload_typed(bad_unit)),
        report("refused", {"class": "kernel", "ctor": "evaluation", "payload": "argumentUnit"},
               init, st, jmap=typed_fail_before("typeCorrect")),
        "typing refusal")
    add("F16", "claimed TypeCorrect with unit mismatch", ["S20", "S37", "S63"], "typed-execute",
        envelope("typed-execute", payload_typed(bad_unit), claimed_judgments=["typeCorrect"]),
        report("refused", {"class": "kernel", "ctor": "evaluation", "payload": "argumentUnit"},
               init, st, jmap=typed_fail_before("typeCorrect"), claimed={"typeCorrect": True}),
        "non-evidence control")

    # Invoke is before applyEvaluated footprint checks; debit is after state/env reads.
    # F17/F18 therefore need only op-matching invoke. F19 needs invoke+debit to reach writeFootprint.
    st17 = with_grants(st, [grant_invoke(8)])
    reg17 = extra_reg({"id": 8, "template": undeclared_state_read_template()})
    pl17 = payload_typed(transfer_request(3, op=8, caps=scoped_caps(1)), store=st17)
    pl17["registry"] = reg17
    add("F17", "undeclared state read", ["S21", "S87"], "typed-execute",
        envelope("typed-execute", pl17),
        report("refused", {"class": "kernel", "ctor": "stateReadFootprint", "payload": None},
               init, st17, jmap=typed_fail_before("footprintCorrect", reached_true=("typeCorrect", "authorityCorrect"))),
        "footprint refusal")
    st18 = with_grants(st, [grant_invoke(9)])
    reg18 = extra_reg({"id": 9, "template": undeclared_env_read_template()})
    pl18 = payload_typed(transfer_request(3, op=9, caps=scoped_caps(1)), store=st18, env=env_amount_obs(3))
    pl18["registry"] = reg18
    add("F18", "undeclared env read", ["S22", "S87"], "typed-execute",
        envelope("typed-execute", pl18),
        report("refused", {"class": "kernel", "ctor": "envReadFootprint", "payload": None},
               init, st18, jmap=typed_fail_before("footprintCorrect", reached_true=("typeCorrect", "authorityCorrect"))),
        "footprint refusal")
    st19 = with_grants(st, [grant_invoke(10), grant_debit_alice_usd(10)])
    reg19 = extra_reg({"id": 10, "template": undeclared_write_template()})
    pl19 = payload_typed(transfer_request(3, op=10, caps=scoped_caps(2)), store=st19)
    pl19["registry"] = reg19
    add("F19", "undeclared write", ["S23", "S87"], "typed-execute",
        envelope("typed-execute", pl19),
        report("refused", {"class": "kernel", "ctor": "writeFootprint", "payload": None},
               init, st19, jmap=typed_fail_before("footprintCorrect", reached_true=("typeCorrect", "authorityCorrect", "accountingCorrect"))),
        "footprint refusal")

    add("F20", "unauthorized invoke", ["S24"], "typed-execute",
        envelope("typed-execute", payload_typed(transfer_request(3, caps=[]))),
        report("refused", {"class": "kernel", "ctor": "unauthorizedInvoke", "payload": None},
               init, st, jmap=typed_fail_before("authorityCorrect", reached_true=("typeCorrect",))),
        "authority refusal")
    add("F21", "unauthorized debit invoke-only caps", ["S25"], "typed-execute",
        envelope("typed-execute", payload_typed(transfer_request(3, caps=[0]))),
        report("refused", {"class": "kernel", "ctor": "unauthorizedDebit", "payload": None},
               init, st, jmap=typed_fail_before("authorityCorrect", reached_true=("typeCorrect", "footprintCorrect"))),
        "authority refusal")

    revoked = copy.deepcopy(st)
    revoked["entries"][0]["live"] = False
    add("F22", "revoked id 0 cannot invoke", ["S26", "S07"], "typed-execute",
        envelope("typed-execute", payload_typed(transfer_request(3, caps=[0]), store=revoked)),
        report("refused", {"class": "kernel", "ctor": "unauthorizedInvoke", "payload": None},
               init, revoked, jmap=typed_fail_before("authorityCorrect", reached_true=("typeCorrect",))),
        "authority refusal")

    st23 = with_grants(st, [grant_invoke(11), grant_debit_alice_usd(11)])
    reg23 = extra_reg({"id": 11, "template": unbalanced_template()})
    req23 = {"operation": 11, "parties": [], "arguments": [], "capabilityIds": scoped_caps(2), "claimedActor": None}
    pl23 = payload_typed(req23, store=st23)
    pl23["registry"] = reg23
    add("F23", "unbalanced accounting", ["S27", "S87"], "typed-execute",
        envelope("typed-execute", pl23),
        report("refused", {"class": "kernel", "ctor": "accounting", "payload": None},
               init, st23, jmap=typed_fail_before("accountingCorrect",
                                               reached_true=("typeCorrect", "footprintCorrect", "authorityCorrect"))),
        "accounting refusal")
    add("F24", "insufficient funds 11 from 10", ["S28", "S43", "S79", "S91"], "typed-execute",
        envelope("typed-execute", payload_typed(transfer_request(11))),
        report("refused", {"class": "kernel", "ctor": "insufficientFunds", "payload": None},
               init, st, jmap=typed_fail_before("accountingCorrect",
                                               reached_true=("typeCorrect", "footprintCorrect", "authorityCorrect"))),
        "funds refusal")

    add("F25", "transfer three success full frame", ["S02", "S29", "S39", "S41", "S45", "S47", "S54", "S61", "S63", "S64", "S66", "S76", "S78", "S82"],
        "typed-execute",
        envelope("typed-execute", payload_typed()),
        report("accepted", None, post, st, jmap=typed_success_j(),
               receipt=receipt_transfer3()),
        "funded actual execution", intact_sibling=True)
    # extra scenario tags applied below via fixtures list mutation after F25 exists

    add("F26", "export of private cell otherwise valid", ["S30", "S44"], "composition-step",
        envelope("composition-step", payload_step(invoke_step(3), catalog=catalog_export_private())),
        report("refused", {"class": "configuration", "ctor": "configuration", "payload": None},
               init, st, jmap={
                   "typeCorrect": NR, "footprintCorrect": NR, "authorityCorrect": NR,
                   "accountingCorrect": NR, "compositionCompatible": "false",
                   "assumptionsDeclared": "true", "libraryTheoremsInstantiated": NA, "sourceRefinement": NA,
               }, cursorFailure={"index": 0, "step": None, "reason": {"class": "configuration"}}),
        "catalog refusal")

    add("F27", "sequential executeStep transfer 3", ["S17", "S31", "S42", "S81"], "composition-step",
        envelope("composition-step", payload_step(invoke_step(3))),
        report("accepted", None, post, st, jmap={
            "typeCorrect": "true", "footprintCorrect": "true", "authorityCorrect": "true",
            "accountingCorrect": "true", "compositionCompatible": "true",
            "assumptionsDeclared": "true", "libraryTheoremsInstantiated": NA, "sourceRefinement": NA,
        }, receipt=receipt_transfer3(), outputs=snapshot_alice(0, 7), nextIndex=0),
        "composition execution")

    half = copy.deepcopy(env_ok)
    half["payload"]["request"]["arguments"][0]["value"] = rat(1, 2)
    add("F28", "canonical one-half decode", ["S02"], "codec",
        {"raw_utf8": compact(half)},
        codec("ok", None, raw=compact(half)),
        "rational positive")

    add("F29", "actor mismatch precedes unauthorized invoke", ["S33"], "typed-execute",
        envelope("typed-execute", payload_typed(transfer_request(3, caps=[], claimed_actor="bob"))),
        report("refused", {"class": "kernel", "ctor": "actorMismatch", "payload": None},
               init, st, jmap=typed_fail_before()),
        "precedence")
    bad_op = transfer_request(3)
    bad_op["operation"] = 999
    bad_op["arguments"] = [{"unit": unit_amount("share"), "value": rat(3)}]
    add("F30", "unknown operation precedes Args.check", ["S34"], "typed-execute",
        envelope("typed-execute", payload_typed(bad_op)),
        report("refused", {"class": "kernel", "ctor": "unknownOperation", "payload": None},
               init, st, jmap=typed_fail_before()),
        "precedence")

    # F31 is not a comparator input; F52 holds the two full reports for M11
    add("F31", "untyped failed bit is codec malformed", ["S35"], "codec",
        {"raw_utf8": compact({"ok": False})},
        codec("malformed", {"ctor": "schemaVersion"}),
        "observation control")

    add("F32", "future priorOutput", ["S32"], "composition-step",
        envelope("composition-step", payload_step(
            invoke_step(3, inputs=[{"tag": "priorOutput", "step": 0, "port": {"component": 0, "port": 1}}]),
            index=0, history=[])),
        report("refused", {"class": "interface", "ctor": "unavailableOutput", "payload": None},
               init, st, jmap={
                   "typeCorrect": NR, "footprintCorrect": NR, "authorityCorrect": NR,
                   "accountingCorrect": NR, "compositionCompatible": "false",
                   "assumptionsDeclared": "true", "libraryTheoremsInstantiated": NA, "sourceRefinement": NA,
               }),
        "interface refusal")

    add("F33", "theorem name outstanding not accepted", ["S36", "S50"], "typed-execute",
        envelope("typed-execute", payload_typed(), libraries=[{"theorem": "asset_delta_balance"}]),
        report("accepted", None, post, st, jmap=typed_success_j(),
               receipt=receipt_transfer3(), outstanding=["libraryTheoremsInstantiated"]),
        "proof-boundary")
    tagged = copy.deepcopy(env_ok)
    tagged["tag"] = "OTHER"
    add("F34", "keyword tag unknown field", ["S37"], "codec",
        {"raw_utf8": compact(tagged)},
        codec("malformed", {"ctor": "unknownExecutableField", "name": "tag"}),
        "non-evidence control")
    ev = copy.deepcopy(env_ok)
    ev["payload"]["evaluated"] = {"guard": True}
    add("F35", "caller Evaluated unknown field", ["S38"], "codec",
        {"raw_utf8": compact(ev)},
        codec("malformed", {"ctor": "unknownExecutableField", "name": "evaluated"}),
        "non-evidence control")

    claimed_state = {"state": {"cells": init}, "capabilities": st}
    add("F36", "claimed next state 10 after transfer 3", ["S46", "S62", "S83", "S93"], "typed-execute",
        envelope("typed-execute", payload_typed(), claimed_next_state=claimed_state),
        report("refused", {"class": "observationMismatch", "ctor": "claimedNextState", "payload": None},
               post, st, jmap=typed_success_j(), receipt=receipt_transfer3()),
        "changed-judgment control")
    stale = envelope("typed-execute", payload_typed())
    stale["source_pin"]["git"] = "deadbeefdeadbeefdeadbeefdeadbeefdeadbeef"
    add("F37", "stale source SHA", ["S48", "S62", "S84"], "typed-execute",
        stale,
        report("refused", {"class": "staleSource", "ctor": "git", "payload": stale["source_pin"]["git"]},
               init, st, jmap=typed_fail_before(), source_pin=stale["source_pin"]),
        "stale control")
    add("F38", "ComponentContract Prop outstanding", ["S49"], "typed-execute",
        envelope("typed-execute", payload_typed(), invariants=["10 ≤ collateral"]),
        report("accepted", None, post, st, jmap=typed_success_j(),
               receipt=receipt_transfer3(), outstanding=["proof.ComponentContract.invariant"]),
        "proof-boundary")
    add("F39", "six trust classes classified", ["S51", "S52", "S54"], "typed-execute",
        envelope("typed-execute", payload_typed()),
        report("accepted", None, post, st, jmap=typed_success_j(), receipt=receipt_transfer3()),
        "assumption classification")
    st40 = with_grants(st, [grant_invoke(6)])
    pl40 = payload_typed(transfer_request(3, op=6, caps=scoped_caps(1)), store=st40, env=env_empty())
    add("F40", "missing observation executable", ["S53", "S87"], "typed-execute",
        envelope("typed-execute", pl40),
        report("refused", {"class": "kernel", "ctor": "evaluation", "payload": "missingObservation"},
               init, st40, jmap=typed_fail_before(None, reached_true=("typeCorrect", "authorityCorrect"))),
        "evaluation refusal")
    miss = envelope("typed-execute", payload_typed())
    miss["assumptions"] = SIX[:-1]
    add("F41", "missing environment-authenticity incomplete", ["S55", "S84"], "typed-execute",
        miss,
        report("incomplete", {"class": "incompleteObligation", "ctor": "environment-authenticity", "payload": None},
               post, st, jmap=typed_success_j(), receipt=receipt_transfer3(),
               assumptions={k: ("present" if k != "environment-authenticity" else "missing") for k in SIX}),
        "assumption control")
    add("F42", "library field informational outstanding", ["S56", "S65"], "typed-execute",
        envelope("typed-execute", payload_typed(),
                 libraries=[{"theorem": "applyEvaluated_accounting", "module": "DefiKernel.Typed.Transition"}]),
        report("accepted", None, post, st, jmap=typed_success_j(),
               receipt=receipt_transfer3(), outstanding=["libraryTheoremsInstantiated"]),
        "proof-boundary")
    add("F43", "source map not fidelity", ["S57"], "typed-execute",
        envelope("typed-execute", payload_typed()),
        report("accepted", None, post, st, jmap=typed_success_j(),
               receipt=receipt_transfer3(), outstanding=["sourceRefinement"]),
        "proof-boundary")

    add("F44", "audit Certificates+Typed+Composition prefixes", ["S58"], "audit",
        {"commands": [
            "#audit_axioms DefiKernel.Certificates",
            "#audit_axioms DefiKernel.Typed",
            "#audit_axioms DefiKernel.Composition",
        ], "imported_theorems_min": 1},
        audit("passed", None, prefixes=["DefiKernel.Certificates", "DefiKernel.Typed", "DefiKernel.Composition"]),
        "audit-root contract")
    add("F45", "unimported Nary/Claims/Arithmetic/Atomic not claimed", ["S59"], "audit",
        {"forbidden_claimed_roots": ["DefiKernel.Nary", "DefiKernel.Claims", "DefiKernel.Arithmetic", "DefiKernel.Atomic"]},
        audit("passed", None, claimed_covered=False),
        "audit-root control")
    add("F46", "empty theorem scope blocked", ["S60"], "audit",
        {"imported_theorems": 0, "prefix": "DefiKernel.Certificates"},
        audit("blocked", "emptyScope"),
        "blocked audit control")

    # M06 companion: vault-guarded transfer, component 0 cannot read vault.
    # Remaining kernel after skip-readAccess needs op-4 invoke+debit (ids 12/13).
    st47 = with_grants(st, [grant_invoke(4), grant_debit_alice_usd(4)])
    add("F47", "forbidden vault read otherwise valid transfer", ["S68", "S81", "S88"], "composition-step",
        envelope("composition-step", payload_step(
            invoke_step(3, op=4, caps=scoped_caps(2),
                        inputs=[{"tag": "literal", "value": {"unit": unit_amount("usd"), "value": rat(3)}}]),
            catalog=catalog_no_vault_read(), pre={"state": {"cells": init}, "capabilities": st47})),
        report("refused", {"class": "interface", "ctor": "readAccess", "payload": None},
               init, st47, jmap={
                   "typeCorrect": NR, "footprintCorrect": NR, "authorityCorrect": NR,
                   "accountingCorrect": NR, "compositionCompatible": "false",
                   "assumptionsDeclared": "true", "libraryTheoremsInstantiated": NA, "sourceRefinement": NA,
               }),
        "access refusal", m06_companion=True)
    # S81 attached to F47 after add; include here by editing the last fixture if needed

    # F48 producer then prior-output consumer
    step0 = invoke_step(3)
    step1 = invoke_step(3, inputs=[{"tag": "priorOutput", "step": 0, "port": {"component": 0, "port": 1}}])
    ev0 = {
        "index": 0, "step": step0, "before": world0(),
        "result": {
            "world": {"state": {"cells": post}, "capabilities": st},
            "receipt": receipt_transfer3(),
            "outputs": snapshot_alice(0, 7),
        },
    }
    rec1 = {
        "tag": "invoked",
        "request": {
            "operation": 0, "parties": ["bob"],
            "arguments": [{"unit": unit_amount("usd"), "value": rat(7)}],
            "capabilityIds": list(range(12)), "claimedActor": None,
        },
        "evaluated": {
            "guard": True,
            "deltas": [
                {"cell": cell("main", "alice", "usd"), "amount": rat(-7)},
                {"cell": cell("main", "bob", "usd"), "amount": rat(7)},
            ],
            "supplies": [], "requiredStateReads": [], "requiredEnvReads": [],
            "declaredStateReads": [], "declaredEnvReads": [],
            "writes": [cell("main", "alice", "usd"), cell("main", "bob", "usd")],
        },
    }
    world48 = {"state": {"cells": after_second_transfer7()}, "capabilities": st}
    ev1 = {
        "index": 1, "step": step1,
        "before": {"state": {"cells": post}, "capabilities": st},
        "result": {"world": world48, "receipt": rec1, "outputs": snapshot_alice(1, 0)},
    }
    add("F48", "producer then prior-output consumer", ["S69"], "composition-run",
        envelope("composition-run", payload_run([step0, step1])),
        report("accepted", None, after_second_transfer7(), st, jmap={
            "typeCorrect": "true", "footprintCorrect": "true", "authorityCorrect": "true",
            "accountingCorrect": "true", "compositionCompatible": "true",
            "assumptionsDeclared": "true", "libraryTheoremsInstantiated": NA, "sourceRefinement": NA,
        }, receipt=rec1, outputs=snapshot_alice(0, 7) + snapshot_alice(1, 0),
               events=[ev0, ev1], nextIndex=2),
        "history dependence")

    step_fail = invoke_step(11)
    step_later = invoke_step(1)
    add("F49", "success prefix then insufficientFunds then inert", ["S70", "S91"], "composition-run",
        envelope("composition-run", payload_run([step0, step_fail, step_later])),
        report("refused", {"class": "kernel", "ctor": "insufficientFunds", "payload": None},
               post, st, jmap={
                   "typeCorrect": "true", "footprintCorrect": "true", "authorityCorrect": "true",
                   "accountingCorrect": "false", "compositionCompatible": "true",
                   "assumptionsDeclared": "true", "libraryTheoremsInstantiated": NA, "sourceRefinement": NA,
               }, receipt=receipt_transfer3(), outputs=snapshot_alice(0, 7),
               events=[ev0], nextIndex=1,
               cursorFailure={"index": 1, "step": step_fail,
                              "reason": {"class": "kernel", "ctor": "insufficientFunds", "payload": None}}),
        "inert continuation")

    new_grant = {"holder": "bob", "domain": "main", "operation": 0, "right": {"tag": "invoke"}}
    issued_store = copy.deepcopy(st)
    issued_store["entries"].append({**new_grant, "live": True})
    admin_b = {"ctx": {"principal": "vault", "domain": "main"}, "env": env_empty(), "now": 100}
    add("F50", "admin issue fresh id 12", ["S07", "S71", "S94"], "composition-step",
        envelope("composition-step", payload_step(
            {"tag": "issue", "grant": new_grant}, boundary=admin_b)),
        report("accepted", None, init, issued_store, jmap={
            "typeCorrect": NA, "footprintCorrect": NA, "authorityCorrect": "true",
            "accountingCorrect": NA, "compositionCompatible": "true",
            "assumptionsDeclared": "true", "libraryTheoremsInstantiated": NA, "sourceRefinement": NA,
        }, receipt={"tag": "issued", "id": 12}, nextIndex=0),
        "authority admin")
    revoked_store = copy.deepcopy(st)
    revoked_store["entries"][0]["live"] = False
    add("F51", "admin revoke id 0 tombstone nextId 12", ["S26", "S72", "S94"], "composition-step",
        envelope("composition-step", payload_step({"tag": "revoke", "id": 0}, boundary=admin_b)),
        report("accepted", None, init, revoked_store, jmap={
            "typeCorrect": NA, "footprintCorrect": NA, "authorityCorrect": "true",
            "accountingCorrect": NA, "compositionCompatible": "true",
            "assumptionsDeclared": "true", "libraryTheoremsInstantiated": NA, "sourceRefinement": NA,
        }, receipt={"tag": "revoked", "id": 0}),
        "authority admin")

    r_funds = report("refused", {"class": "kernel", "ctor": "insufficientFunds", "payload": None},
                     init, st, jmap=typed_fail_before("accountingCorrect", reached_true=("typeCorrect", "footprintCorrect", "authorityCorrect")))
    r_debit = report("refused", {"class": "kernel", "ctor": "unauthorizedDebit", "payload": None},
                     init, st, jmap=typed_fail_before("authorityCorrect", reached_true=("typeCorrect", "footprintCorrect")))
    add("F52", "two complete reports different present constructors", ["S73"], "observation-pair",
        {"left": r_funds, "right": r_debit},
        {"reportEq": False, "isSome_both_failures": True},
        "comparator pair")

    # M16: otherwise-valid invoke payload with unsupported tag
    inv = invoke_step(3)
    inv["tag"] = "treeJoin"
    add("F53", "unsupported tag with valid invoke rest", ["S74"], "codec",
        {"raw_utf8": compact(envelope("composition-step", payload_step(inv)))},
        codec("malformed", {"ctor": "unsupportedForm", "reason": "treeJoin"}),
        "unsupported-form sibling")

    add("F54", "issueCapability from store12 returns id 12 length 13", ["S75"], "composition-step",
        envelope("composition-step", payload_step({"tag": "issue", "grant": new_grant}, boundary=admin_b)),
        report("accepted", None, init, issued_store, jmap={
            "typeCorrect": NA, "footprintCorrect": NA, "authorityCorrect": "true",
            "accountingCorrect": NA, "compositionCompatible": "true",
            "assumptionsDeclared": "true", "libraryTheoremsInstantiated": NA, "sourceRefinement": NA,
        }, receipt={"tag": "issued", "id": 12}),
        "fresh id", alias_of="F50")

    return fx


def main():
    root = Path(__file__).resolve().parent
    base = baseline()
    fixtures = build_fixtures()
    ids = [f["id"] for f in fixtures]
    assert len(ids) == len(set(ids))
    (root / "baseline.json").write_text(json.dumps(base, indent=2, ensure_ascii=False) + "\n")
    (root / "fixtures.json").write_text(json.dumps({
        "status": "planned_not_executed_independent_literals",
        "count": len(fixtures),
        "materializer": "openspec/changes/serialized-kernel-certificates/materialize.py",
        "does_not_call_checker_or_lean": True,
        "fixtures": fixtures,
    }, indent=2, ensure_ascii=False) + "\n")
    print(json.dumps({"fixtures": len(fixtures), "cells": 32, "store": 12}))


if __name__ == "__main__":
    main()
