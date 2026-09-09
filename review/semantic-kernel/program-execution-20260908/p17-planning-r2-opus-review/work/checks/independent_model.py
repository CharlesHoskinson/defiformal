#!/usr/bin/env python3
"""Independent bounded re-derivation of the P17 r2 stateful fixtures.

Written by the Opus planning reviewer from the CAPTURED Solidity source
(p17-source-acquisition/capture/src/SUsds.sol + test/mocks/UsdsMock.sol),
NOT from the candidate's own diagnose.py. This is a Python model of the
source, not solc/EVM execution. It gives no source-execution credit.
"""
import json, sys

RAY = 10**27
MAX = 2**256 - 1
BOUND = 2**256

CELLS = None  # set from construction.defaults

class Revert(Exception):
    def __init__(self, msg): self.msg = msg

class Panic(Exception):
    def __init__(self, code): self.code = code


class World:
    """Cells are the flat dotted names used by the candidate fixtures."""
    def __init__(self, pre):
        self.s = dict(pre)
        self.logs = []

    def g(self, k):
        if k not in self.s:
            raise KeyError("unobserved cell " + k)
        return int(self.s[k])

    def put(self, k, v):
        if k not in self.s:
            raise KeyError("unobserved cell " + k)
        assert 0 <= v <= MAX, (k, v)
        self.s[k] = str(v)

    # ---- UsdsMock (msg.sender is always the vault in these paths) ----
    def usds_transferFrom(self, frm, to, value):
        # require(to != address(0) && to != address(this))  [line 112]
        if to in ("ZERO", "usds"):
            raise Revert("Usds/invalid-address")
        bal = self.g("usds.balance." + frm)
        if not bal >= value:                                  # line 114
            raise Revert("Usds/insufficient-balance")
        if frm != "vault":                                    # from != msg.sender
            allowed = self.g("usds.allowance.%s.vault" % frm)  # line 117
            if allowed != MAX:
                if not allowed >= value:                      # line 119
                    raise Revert("Usds/insufficient-allowance")
                self.put("usds.allowance.%s.vault" % frm, allowed - value)
        self.put("usds.balance." + frm, bal - value)
        self.put("usds.balance." + to, self.g("usds.balance." + to) + value)
        self.logs.append({"emitter": "usds", "name": "Transfer",
                          "from": frm, "to": to, "value": str(value)})

    def usds_transfer(self, to, value):                        # msg.sender == vault
        if to in ("ZERO", "usds"):
            raise Revert("Usds/invalid-address")
        bal = self.g("usds.balance.vault")
        if not bal >= value:
            raise Revert("Usds/insufficient-balance")
        self.put("usds.balance.vault", bal - value)
        self.put("usds.balance." + to, self.g("usds.balance." + to) + value)
        self.logs.append({"emitter": "usds", "name": "Transfer",
                          "from": "vault", "to": to, "value": str(value)})

    # ---- SUsds ----
    def drip(self):
        chi_, rho_ = self.g("chi"), self.g("rho")
        ts = self.g("timestamp")
        if ts > rho_:
            raise NotImplementedError("accrual branch is out of the selected domain")
        nChi = chi_
        self.logs.append({"emitter": "vault", "name": "Drip",
                          "chi": str(nChi), "diff": "0"})
        return nChi

    def _mint(self, assets, shares, receiver, sender):
        if receiver in ("ZERO", "vault"):                      # SUsds line 285
            raise Revert("SUsds/invalid-address")
        self.usds_transferFrom(sender, "vault", assets)        # line 287
        # unchecked adds; premises say they do not wrap
        self.put("susds.balance." + receiver,
                 (self.g("susds.balance." + receiver) + shares) % BOUND)
        self.put("susds.totalSupply", (self.g("susds.totalSupply") + shares) % BOUND)
        self.logs.append({"emitter": "vault", "name": "Deposit", "sender": sender,
                          "owner": receiver, "assets": str(assets), "shares": str(shares)})
        self.logs.append({"emitter": "vault", "name": "Transfer", "from": "ZERO",
                          "to": receiver, "value": str(shares)})

    def _burn(self, assets, shares, receiver, owner, sender):
        bal = self.g("susds.balance." + owner)
        if not bal >= shares:                                  # line 300
            raise Revert("SUsds/insufficient-balance")
        if owner != sender:
            allowed = self.g("susds.allowance.%s.%s" % (owner, sender))
            if allowed != MAX:
                if not allowed >= shares:                      # line 306
                    raise Revert("SUsds/insufficient-allowance")
                self.put("susds.allowance.%s.%s" % (owner, sender), allowed - shares)
        self.put("susds.balance." + owner, bal - shares)
        self.put("susds.totalSupply", self.g("susds.totalSupply") - shares)
        self.usds_transfer(receiver, assets)                   # line 318, BEFORE the events
        self.logs.append({"emitter": "vault", "name": "Transfer", "from": owner,
                          "to": "ZERO", "value": str(shares)})
        self.logs.append({"emitter": "vault", "name": "Withdraw", "sender": sender,
                          "receiver": receiver, "owner": owner,
                          "assets": str(assets), "shares": str(shares)})

    @staticmethod
    def _divup(x, y):
        return ((x - 1) // y) + 1 if x != 0 else 0

    @staticmethod
    def cmul(a, b):
        r = a * b
        if r >= BOUND:
            raise Panic(0x11)
        return r

    def deposit(self, assets, receiver, sender):
        nChi = self.drip()
        shares = self.cmul(assets, RAY) // nChi
        self._mint(assets, shares, receiver, sender)
        return shares

    def mint(self, shares, receiver, sender):
        nChi = self.drip()
        assets = self._divup(self.cmul(shares, nChi), RAY)
        self._mint(assets, shares, receiver, sender)
        return assets

    def withdraw(self, assets, receiver, owner, sender):
        nChi = self.drip()
        shares = self._divup(self.cmul(assets, RAY), nChi)
        self._burn(assets, shares, receiver, owner, sender)
        return shares

    def redeem(self, shares, receiver, owner, sender):
        nChi = self.drip()
        assets = self.cmul(shares, nChi) // RAY
        self._burn(assets, shares, receiver, owner, sender)
        return assets


META = {"chi_setup", "chi_setup_protocol_reachable", "chi_setup_is_harness_assumption"}


def run(fixtures_path):
    d = json.load(open(fixtures_path))
    defaults = d["construction"]["defaults"]
    overlay = d["construction"]["domain_overlay"]
    results = []
    for f in d["fixtures"]:
        if f.get("kind") != "source":
            continue
        r = {"id": f["id"], "checks": {}}
        # -- merge rule: defaults, then domain overlay, then pre_overrides
        merged = dict(defaults)
        merged.update(overlay.get(f["domain"], {}))
        merged.update(f.get("pre_overrides", {}))
        stored = f["pre"]
        r["checks"]["merge_rule_matches_stored_pre"] = (
            {k: str(v) for k, v in merged.items()} == {k: str(v) for k, v in stored.items()})
        if not r["checks"]["merge_rule_matches_stored_pre"]:
            r["merge_diff"] = {k: (merged.get(k), stored.get(k))
                               for k in set(merged) | set(stored)
                               if str(merged.get(k)) != str(stored.get(k))}
        # -- execute the model
        state = {k: v for k, v in stored.items() if k not in META}
        w = World(state)
        inp = f["inputs"]
        sender = inp["msg.sender"]
        op = f["operation"]
        outcome = {}
        try:
            if op == "deposit":
                ret = w.deposit(int(inp["assets"]), inp["receiver"], sender)
                outcome = {"status": "success", "ok_shares": str(ret)}
            elif op == "mint":
                ret = w.mint(int(inp["shares"]), inp["receiver"], sender)
                outcome = {"status": "success", "ok_assets": str(ret)}
            elif op == "withdraw":
                ret = w.withdraw(int(inp["assets"]), inp["receiver"], inp["owner"], sender)
                outcome = {"status": "success", "ok_shares": str(ret)}
            elif op == "redeem":
                ret = w.redeem(int(inp["shares"]), inp["receiver"], inp["owner"], sender)
                outcome = {"status": "success", "ok_assets": str(ret)}
            else:
                raise AssertionError("unknown op " + op)
        except Revert as e:
            outcome = {"status": "revert", "error": e.msg}
        except Panic as e:
            outcome = {"status": "revert", "error": "Panic(0x%x)" % e.code}
        exp = f["expected"]
        r["model_outcome"] = outcome
        r["checks"]["status_matches"] = outcome["status"] == exp["status"]
        for k in ("ok_shares", "ok_assets", "error"):
            if k in exp:
                r["checks"]["%s_matches" % k] = str(exp[k]) == outcome.get(k)
        if outcome["status"] == "success":
            model_post = w.s
            # (a) every cell the fixture states must match the model
            declared = exp.get("post", {})
            bad = {k: (v, model_post.get(k)) for k, v in declared.items()
                   if k not in META and str(model_post.get(k)) != str(v)}
            r["checks"]["declared_post_cells_match_model"] = not bad
            if bad:
                r["declared_post_mismatch"] = bad
            # (b) every OBSERVED cell omitted from expected.post must be UNCHANGED
            #     (this is exactly the sparse-post editorial interpretation)
            omitted_changed = {}
            for k in state:
                if k in declared or k in META:
                    continue
                if str(model_post[k]) != str(state[k]):
                    omitted_changed[k] = (state[k], model_post[k])
            r["checks"]["omitted_post_cells_are_unchanged"] = not omitted_changed
            if omitted_changed:
                r["omitted_but_changed"] = omitted_changed
            # (c) declared post cells that are in fact unchanged (redundant but legal)
            r["declared_post_cells_actually_unchanged"] = sorted(
                k for k in declared if k not in META and str(state.get(k)) == str(declared[k]))
            # (d) full logs
            if "full_logs" in exp:
                r["checks"]["full_logs_match"] = exp["full_logs"] == w.logs
                if exp["full_logs"] != w.logs:
                    r["model_logs"] = w.logs
        else:
            r["checks"]["no_post_declared"] = exp.get("post") == "omitted"
        results.append(r)
    return results


if __name__ == "__main__":
    res = run(sys.argv[1])
    fails = []
    for r in res:
        for name, ok in r["checks"].items():
            if not ok:
                fails.append((r["id"], name))
    print(json.dumps({"fixtures_checked": len(res),
                      "total_checks": sum(len(r["checks"]) for r in res),
                      "failures": fails, "detail": res}, indent=2))
    sys.exit(1 if fails else 0)
