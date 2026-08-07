"""Fourth operationalisation of the Q/Sigma invariant (BASIS.md:31-34).

    "Across all 57 specs no state variable of sort Q is ever assigned a value
     that is not an arithmetic term over prior Qs"

WHY THE PRIOR ATTEMPTS FAILED, AND IT IS NOT THE CLAIM

`qsigma.py` asked "does the RHS mention a formal parameter". That flags
`totalSupply' = totalSupply + amount` as exogenous, which the claim explicitly
allows -- BASIS.md's own USDT example is `reserve' = reserve + amount`, cited AS
a Q. qsigma2 diagnosed this correctly and switched to the right distinction:

    REPLACEMENT : x' = e   where x does NOT occur in e   (prior value discarded)
    UPDATE      : x' = e   where x DOES occur in e       (prior value survives)

But qsigma2 scans the whole file --

    for m in re.finditer(r"([A-Za-z_][A-Za-z0-9_]*)'\\s*=", src)

-- with no action scoping, so it reads `init` too. `init` assigns every variable
a literal, and a literal never mentions the variable, so EVERY variable scores
exactly one replacement and Q collapses to the empty set. The tell is in
qsigma2's own output: nearly every violation is `1/N`, and the quoted RHS is
`100`, `0`, `USERS.mapBy(_ => 0)` -- initialisers, every one.

The claim is about the TRANSITION RELATION. At `init` there are no "prior Qs",
so the claim is vacuous there rather than false. This script is qsigma2 with the
initialiser excluded, and nothing else changed.

`qsigma3.py` is not a third operationalisation: it is byte-identical to qsigma2
apart from its output filename (`diff` reports only lines 108 and 110).
"""
import glob
import json
import re
from collections import defaultdict

SPECS = sorted(glob.glob("/root/DefiElements/quint-models/L*/*.qnt"))
IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
CONTAINER = re.compile(r"\.(put|set|append|tail|head|replaceAt)\s*\(")
HEAD = re.compile(
    r"^\s*(?:pure\s+)?(action|def|val)\s+([A-Za-z_][A-Za-z0-9_]*)", re.M)

# An initialiser, for this corpus. Reported so the exclusion is auditable.
INIT_NAMES = {"init"}


def rhs_of(text, at):
    """The right-hand side of an assignment, cut at the enclosing delimiter."""
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


def scan(exclude_init):
    rows = []
    excluded = defaultdict(int)
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
            is_init = name in INIT_NAMES
            for m in re.finditer(r"([A-Za-z_][A-Za-z0-9_]*)'\s*=", body):
                v = m.group(1)
                if v not in varnames:
                    continue
                if is_init:
                    excluded[v] += 1
                    if exclude_init:
                        continue
                rhs = rhs_of(body, m.end())
                mentions_self = v in set(IDENT.findall(rhs))
                container = bool(CONTAINER.search(rhs))
                rows.append({
                    "lane": lane, "spec": spec, "var": v, "action": name,
                    "replacement": not mentions_self and not container,
                    "rhs": rhs[:70]})

    by_var = defaultdict(lambda: {"n": 0, "repl": 0, "ex": []})
    for r in rows:
        k = (r["lane"], r["spec"], r["var"])
        by_var[k]["n"] += 1
        if r["replacement"]:
            by_var[k]["repl"] += 1
            if len(by_var[k]["ex"]) < 2:
                by_var[k]["ex"].append((r["action"], r["rhs"]))
    return rows, by_var, excluded


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
    print(f"--- {label} ---")
    print(f"  assignments analysed:     {len(rows)}")
    print(f"  distinct state variables: {n}")
    print(f"  Q     (never replaced):   {len(Q)}")
    print(f"  Sigma (replaced >=1):     {len(S)}")
    nontrivial = 0 < len(S) < n
    print(f"  PARTITION NON-TRIVIAL:    {nontrivial}"
          f"   (Sigma fraction {len(S)/n:.3f})" if n else "  no data")

    tab = defaultdict(lambda: [0, 0])
    for k, v in by_var.items():
        tab[bucket(k[2])][0 if v["repl"] == 0 else 1] += 1
    print(f"\n  {'category':<20} {'Q':>5} {'Sigma':>7}  {'% in Q':>7}")
    for cat in ("balance/supply", "price/rate/phase", "other"):
        q, s = tab[cat]
        pct = 100 * q / (q + s) if (q + s) else 0
        print(f"  {cat:<20} {q:>5} {s:>7}  {pct:>6.1f}%")
    print()
    return Q, S, tab


print(__doc__)
print("=" * 72)

rows_a, by_a, excluded = scan(exclude_init=False)
report("A. qsigma2's rule, init INCLUDED (reproduces the prior result)",
       rows_a, by_a)

rows_b, by_b, _ = scan(exclude_init=True)
Q, S, tab = report("B. same rule, init EXCLUDED (the only change)", rows_b, by_b)

print(f"init assignments removed: {sum(excluded.values())}"
      f" across {len(excluded)} variable names\n")

print("=" * 72)
print("The semantic prediction BASIS.md makes: balances/supplies are Q,")
print("prices/rates/phases are Sigma. Scored on partition B:\n")
qb, sb = tab["balance/supply"]
qp, sp = tab["price/rate/phase"]
print(f"  balance/supply in Q      : {qb}/{qb+sb} = {100*qb/(qb+sb):.1f}%"
      if qb + sb else "  no balance/supply vars")
print(f"  price/rate/phase in Sigma: {sp}/{qp+sp} = {100*sp/(qp+sp):.1f}%"
      if qp + sp else "  no price/rate/phase vars")

print("\n--- Sigma members that are balances/supplies (predicted Q, scored Sigma) ---")
viol = sorted((k, v) for k, v in by_b.items()
              if v["repl"] > 0 and bucket(k[2]) == "balance/supply")
for k, v in viol[:20]:
    act, rhs = v["ex"][0]
    print(f"   {k[0]}/{k[1]}:{k[2]}  {v['repl']}/{v['n']}  in {act}()  {rhs[:44]}")
print(f"   total: {len(viol)}")

print("\n--- Q members that are prices/rates/phases (predicted Sigma, scored Q) ---")
inv = sorted(k for k, v in by_b.items()
             if v["repl"] == 0 and bucket(k[2]) == "price/rate/phase")
for k in inv[:20]:
    print(f"   {k[0]}/{k[1]}:{k[2]}")
print(f"   total: {len(inv)}")

json.dump({"Q": sorted(list(k) for k in Q), "Sigma": sorted(list(k) for k in S)},
          open("/root/DefiElements/research/positive-program/sigma/qsigma4.json",
               "w"), indent=2)
print("\nwritten: sigma/qsigma4.json")
