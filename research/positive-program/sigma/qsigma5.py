"""Fifth operationalisation of the Q/Sigma invariant (BASIS.md:31-34).

qsigma4 isolated the defect that made qsigma2/3 return the empty Q: they scanned
`init`, whose literal assignments are replacements by construction. Excluding it
makes the partition non-trivial. But qsigma4 has a defect of its own, visible in
its own violation list, where the reported "actions" are `newSup()`, `minted()`,
`r1n()` -- LOCAL `val` BINDINGS, not actions.

    val newSup = userSupplyScaled.put(u, ... userSupplyScaled.get(u) ...)
    userSupplyScaled' = newSup

Syntactically `userSupplyScaled' = newSup` does not mention the variable, so
qsigma4 scores it a replacement. Semantically the prior value participates
through the binding: it is an UPDATE. This script resolves local `val` bindings
transitively before testing self-mention, and splits spans on `action`/`def`
only, so bodies are no longer chopped at every local `val`.

DIRECTION OF THE CORRECTION, stated before it is measured: resolution can only
move variables from Sigma to Q (an assignment that mentions the variable after
expansion cannot stop mentioning it). So it must RAISE "balances in Q" and LOWER
"prices in Sigma". The second is the half of BASIS.md's prediction that was
already weak in qsigma4, and this makes it weaker.
"""
import glob
import json
import re
from collections import defaultdict

SPECS = sorted(glob.glob("/root/DefiElements/quint-models/L*/*.qnt"))
IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
CONTAINER = re.compile(r"\.(put|set|append|tail|head|replaceAt)\s*\(")
# spans are ACTIONS AND DEFS ONLY -- never `val`, which is what broke qsigma4
HEAD = re.compile(r"^\s*(?:pure\s+)?(action|def)\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)
LOCAL_VAL = re.compile(r"\bval\s+([A-Za-z_][A-Za-z0-9_]*)\s*=", re.M)
INIT_NAMES = {"init"}
MAX_EXPAND = 8


def rhs_of(text, at):
    tail = text[at:]
    depth = 0
    cut = len(tail)
    for i, ch in enumerate(tail):
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            if depth == 0:
                cut = i
                break
            depth -= 1
        elif ch == "," and depth == 0:
            cut = i
            break
    return tail[:cut].strip()


def local_bindings(body):
    """name -> its defining expression, for `val name = expr` inside a body."""
    out = {}
    for m in LOCAL_VAL.finditer(body):
        out[m.group(1)] = rhs_of(body, m.end())
    return out


def expand(expr, binds):
    """Transitively inline local val names appearing in expr."""
    seen = set()
    for _ in range(MAX_EXPAND):
        names = set(IDENT.findall(expr)) & set(binds)
        names -= seen
        if not names:
            break
        for n in names:
            seen.add(n)
            expr = expr + " " + binds[n]
    return expr


def scan(resolve, exclude_init=True):
    rows = []
    for path in SPECS:
        lane, spec = path.split("/")[-2], path.split("/")[-1]
        src = open(path, encoding="utf-8", errors="replace").read()
        src = re.sub(r"//[^\n]*", "", src)
        varnames = set(re.findall(
            r"^\s*var\s+([A-Za-z_][A-Za-z0-9_]*)", src, re.M))
        if not varnames:
            continue
        heads = list(HEAD.finditer(src))
        for i, h in enumerate(heads):
            name = h.group(2)
            start = h.end()
            end = heads[i + 1].start() if i + 1 < len(heads) else len(src)
            body = src[start:end]
            if name in INIT_NAMES and exclude_init:
                continue
            binds = local_bindings(body) if resolve else {}
            for m in re.finditer(r"([A-Za-z_][A-Za-z0-9_]*)'\s*=", body):
                v = m.group(1)
                if v not in varnames:
                    continue
                raw = rhs_of(body, m.end())
                tested = expand(raw, binds) if resolve else raw
                mentions_self = v in set(IDENT.findall(tested))
                container = bool(CONTAINER.search(tested))
                rows.append({
                    "lane": lane, "spec": spec, "var": v, "action": name,
                    "replacement": not mentions_self and not container,
                    "rhs": raw[:70]})
    by_var = defaultdict(lambda: {"n": 0, "repl": 0, "ex": []})
    for r in rows:
        k = (r["lane"], r["spec"], r["var"])
        by_var[k]["n"] += 1
        if r["replacement"]:
            by_var[k]["repl"] += 1
            if len(by_var[k]["ex"]) < 2:
                by_var[k]["ex"].append((r["action"], r["rhs"]))
    return rows, by_var


def bucket(name):
    n = name.lower()
    if any(w in n for w in ("price", "rate", "index", "oracle", "nav", "amp",
                            "time", "epoch", "block", "phase", "paused",
                            "frozen", "mode", "status", "enabled", "active")):
        return "price/rate/phase"
    if any(w in n for w in ("bal", "supply", "total", "coll", "debt", "share",
                            "reserve", "deposit", "liquid", "pool", "fund",
                            "asset", "locked", "staked")):
        return "balance/supply"
    return "other"


def report(label, rows, by_var):
    Q = {k for k, v in by_var.items() if v["repl"] == 0}
    S = {k for k, v in by_var.items() if v["repl"] > 0}
    n = len(by_var)
    tab = defaultdict(lambda: [0, 0])
    for k, v in by_var.items():
        tab[bucket(k[2])][0 if v["repl"] == 0 else 1] += 1
    print(f"--- {label} ---")
    print(f"  vars {n}   Q {len(Q)}   Sigma {len(S)}"
          f"   non-trivial {0 < len(S) < n}   Sigma frac {len(S)/n:.3f}")
    qb, sb = tab["balance/supply"]
    qp, sp = tab["price/rate/phase"]
    print(f"  balance/supply in Q       {qb}/{qb+sb} = {100*qb/(qb+sb):5.1f}%")
    print(f"  price/rate/phase in Sigma {sp}/{qp+sp} = {100*sp/(qp+sp):5.1f}%")
    print()
    return Q, S, tab


print(__doc__)
print("=" * 72)
rows_a, by_a = scan(resolve=False)
report("A. qsigma4's rule (no binding resolution)", rows_a, by_a)
rows_b, by_b = scan(resolve=True)
Q, S, tab = report("B. binding resolution ON -- the corrected figure", rows_b, by_b)

moved = sorted(k for k in by_a if by_a[k]["repl"] > 0 and by_b[k]["repl"] == 0)
print(f"variables reclassified Sigma -> Q by binding resolution: {len(moved)}")
for k in moved[:12]:
    print(f"   {k[0]}/{k[1]}:{k[2]}")
print()

print("=" * 72)
print("REMAINING Sigma members that are balances/supplies:")
viol = sorted((k, v) for k, v in by_b.items()
              if v["repl"] > 0 and bucket(k[2]) == "balance/supply")
for k, v in viol:
    act, rhs = v["ex"][0]
    print(f"   {k[0]}/{k[1]}:{k[2]}  {v['repl']}/{v['n']}  in {act}()  {rhs[:42]}")
print(f"   total: {len(viol)}")

print("\nREMAINING Q members that are prices/rates/phases"
      " (BASIS.md predicts these are Sigma):")
inv = sorted(k for k, v in by_b.items()
             if v["repl"] == 0 and bucket(k[2]) == "price/rate/phase")
for k in inv:
    print(f"   {k[0]}/{k[1]}:{k[2]}")
print(f"   total: {len(inv)}")

json.dump({"Q": sorted(list(k) for k in Q), "Sigma": sorted(list(k) for k in S)},
          open("/root/DefiElements/research/positive-program/sigma/qsigma5.json",
               "w"), indent=2)
print("\nwritten: sigma/qsigma5.json")
