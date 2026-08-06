"""Convention 6h retrofit, step 1: what does each contract actually gate?

For every action in the ten v2 re-specs, find the Solidity/Vyper function it
models and decide whether the contract restricts the caller.

  MODELLED       the spec already takes a caller as its first parameter
  GATED          the contract restricts the caller; the spec must model or declare
  PERMISSIONLESS the contract restricts nobody -- a POSITIVE, citable claim
  UNMATCHED      no function matched by name; needs a hand lookup, and is NOT
                 evidence of absence

WHY THIS IS THE SECOND VERSION. The first looked only at MODIFIERS, in the text
between the parameter list and the opening brace. It reported 50 permissionless,
including `huma.closePool` and `huma.distributeProfit`. Both are gated -- Huma
does access control in the FUNCTION BODY:

    function closePool() external {
        poolConfig.onlyPoolOwnerOrHumaOwner(msg.sender);      <- the gate

    function distributeLoss(uint256 loss) external {
        if (msg.sender != address(creditManager)) revert ...  <- the gate

So the body is scanned too, for `msg.sender` used in a comparison, revert or
`only*` call. Huma additionally carries `@custom:access` NatSpec, which is read
where present because it is the contract author's own statement of intent.
"""
import glob
import os
import re

ROOT = "/root/DefiElements"

REPO = {
    "uniswap_v2": "dex/Uniswap_v2-core",
    "curve": "dex/curvefi_curve-contract",
    "apex": "perp/ApeX-Protocol_apex-protocol",
    "compound_v3": "lend/compound-finance_comet",
    "morpho_blue": "lend/morpho-org_morpho-blue",
    "gmx": "perp/gmx-io_gmx-synthetics",
    "liquity": "cdp/liquity_bold",
    "polymarket": "pred/Polymarket_ctf-exchange-v2",
    "derive": "opt/derivexyz_v2-core",
    "huma": "yield/00labs_huma-contracts-v2",
}

ACTION = re.compile(r"^\s*action\s+([a-zA-Z_][A-Za-z0-9_]*)\s*(\(([^)]*)\))?", re.M)
MODIFIER = re.compile(
    r"\b(only[A-Z]\w*|auth\b|requiresAuth|restricted|onlyRole\([^)]*\))\b")
# access control performed inside the body
BODY_GATE = re.compile(
    r"(msg\.sender\s*(?:!=|==)|"
    r"\b_?only[A-Z]\w*\s*\(\s*(?:msg\.sender|_?msgSender\(\))|"
    r"\brequire\s*\([^;]*msg\.sender|"
    r"\b_?checkRole\s*\(|\bhasRole\s*\()")
NATSPEC = re.compile(r"@custom:access\s+([^\n*]+)")
CALLERISH = re.compile(r"^\s*(caller|sender|msgSender|u|user|acct|account|by)\s*:",
                       re.I)


def balanced(src, i, o, c):
    """Return index just past the balanced group starting at src[i] == o."""
    d = 0
    while i < len(src):
        if src[i] == o:
            d += 1
        elif src[i] == c:
            d -= 1
            if d == 0:
                return i + 1
        i += 1
    return len(src)


def functions(src):
    """Yield (name, header_tail, body, line, natspec)."""
    for m in re.finditer(r"function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", src):
        name = m.group(1)
        p_end = balanced(src, m.end() - 1, "(", ")")
        brace = src.find("{", p_end)
        semi = src.find(";", p_end)
        if brace == -1 or (semi != -1 and semi < brace):
            tail = src[p_end: semi if semi != -1 else p_end]
            body = ""
            end = semi
        else:
            tail = src[p_end:brace]
            end = balanced(src, brace, "{", "}")
            body = src[brace:end]
        pre = src[max(0, m.start() - 700): m.start()]
        ns = NATSPEC.findall(pre)
        yield name, tail, body, src[:m.start()].count("\n") + 1, ns


def index(repo):
    idx = {}
    root = os.path.join(ROOT, "protocol-repos", repo)
    files = [p for p in glob.glob(root + "/**/*.sol", recursive=True)
             if "/test" not in p.lower() and "/lib/" not in p
             and "/mock" not in p.lower() and "/interfaces/" not in p.lower()]
    for p in files:
        try:
            src = open(p, encoding="utf-8", errors="replace").read()
        except OSError:
            continue
        for name, tail, body, line, ns in functions(src):
            mods = sorted(set(MODIFIER.findall(tail)))
            bg = BODY_GATE.search(body)
            idx.setdefault(name.lower(), []).append({
                "file": os.path.relpath(p, root), "line": line, "mods": mods,
                "body_gate": bg.group(0).strip() if bg else None,
                "natspec": ns[0].strip() if ns else None})
    # Vyper
    for p in glob.glob(root + "/**/*.vy", recursive=True):
        src = open(p, encoding="utf-8", errors="replace").read()
        for m in re.finditer(r"^def\s+([A-Za-z_]\w*)", src, re.M):
            idx.setdefault(m.group(1).lower(), []).append({
                "file": os.path.relpath(p, root),
                "line": src[:m.start()].count("\n") + 1,
                "mods": [], "body_gate": None, "natspec": None})
    return idx


def best(idx, action):
    a = action.lower()
    if a in idx:
        return idx[a]
    c = [k for k in idx if len(k) >= 5 and (a.startswith(k) or k.startswith(a))]
    return idx[sorted(c, key=lambda k: -len(k))[0]] if c else None


totals = {"MODELLED": 0, "GATED": 0, "PERMISSIONLESS": 0, "UNMATCHED": 0}
work = []
print(f"{'spec':<13} {'action':<24} {'verdict':<15} evidence")
print("-" * 108)
for spec, repo in REPO.items():
    idx = index(repo)
    src = open(f"{ROOT}/quint-models-v2/{spec}.qnt",
               encoding="utf-8", errors="replace").read()
    for m in ACTION.finditer(src):
        name, params = m.group(1), m.group(3) or ""
        if name in ("init", "step"):
            continue
        modelled = bool(CALLERISH.search(params.split(",")[0])) if params else False
        hit = best(idx, name)
        if hit is None:
            v, ev = "UNMATCHED", "no contract function matched by name"
        else:
            gated = [h for h in hit if h["mods"] or h["body_gate"] or h["natspec"]]
            if gated:
                h = gated[0]
                why = (",".join(h["mods"]) or h["body_gate"]
                       or ("@custom:access " + (h["natspec"] or "")))
                v = "MODELLED" if modelled else "GATED"
                ev = f"{h['file']}:{h['line']}  {why}"
                if v == "GATED":
                    work.append((spec, name, ev))
            else:
                h = hit[0]
                v = "PERMISSIONLESS"
                ev = f"{h['file']}:{h['line']}  no caller check found"
        totals[v] += 1
        print(f"{spec:<13} {name[:24]:<24} {v:<15} {ev[:60]}")

print("\n" + "=" * 108)
for k in ("MODELLED", "GATED", "PERMISSIONLESS", "UNMATCHED"):
    print(f"  {k:<15} {totals[k]}")
print(f"\nRETROFIT WORK-LIST (GATED): {len(work)} actions")
for s, n, e in work:
    print(f"   {s:<13} {n:<24} {e[:60]}")
