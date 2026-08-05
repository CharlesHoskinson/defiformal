import json
import glob
from itertools import combinations

specs = {}
for f in sorted(glob.glob("/root/DefiElements/expansion/*/specs/*.json")):
    d = json.load(open(f))
    app = d.get("app", f)
    con = set(d.get("construction", []))
    specs[app] = con

print("apps loaded:", len(specs))

# --- claim: Fl in 5, Xf in 25, Rl in 1, Of in 0
for sym in ("Fl", "Xf", "Rl", "Of", "Cp", "Cl", "Pl", "Cd", "Pm"):
    holders = [a for a, c in specs.items() if sym in c]
    print(f"{sym:<3} n={len(holders):<3} ({100*len(holders)/len(specs):.1f}%)  {holders[:6]}")

# --- claim: exactly one app contains Fl AND one of Xf/Rl/Of
X21_ARMS = {"Xf", "Rl", "Of"}
both = [a for a, c in specs.items() if "Fl" in c and (c & X21_ARMS)]
print("\napps containing Fl AND (Xf|Rl|Of):", both)

# --- claim: X21 arms 159 of 1770 pairs
apps = sorted(specs)
pairs = list(combinations(apps, 2))
armed21 = [(a, b) for a, b in pairs
           if "Fl" in (specs[a] | specs[b]) and ((specs[a] | specs[b]) & X21_ARMS)]
print(f"total pairs: {len(pairs)}   X21-armed: {len(armed21)}")

# X2 = Fl + (Cp|Cl) + (Pl|Cd)
armed2 = [(a, b) for a, b in pairs
          if "Fl" in (specs[a] | specs[b])
          and ((specs[a] | specs[b]) & {"Cp", "Cl"})
          and ((specs[a] | specs[b]) & {"Pl", "Cd"})]
print(f"X2-armed: {len(armed2)}")
union = set(armed21) | set(armed2)
print(f"either armed (union): {len(union)}")

# --- collision classes
def cmp(a, b):
    if a not in specs or b not in specs:
        missing = [x for x in (a, b) if x not in specs]
        return f"  {a} vs {b}: MISSING {missing}"
    A, B = specs[a], specs[b]
    j = len(A & B) / len(A | B) if (A | B) else 1.0
    return (f"  {a} vs {b}: identical={A == B} symdiff={sorted(A ^ B)} "
            f"J={j:.3f} |A|={len(A)} |B|={len(B)}")

print("\n--- named collision classes ---")
names = list(specs)
def find(sub):
    return [n for n in names if sub.lower() in n.lower()]
print("USDT candidates:", find("usdt") or find("tether"))
print("USD1 candidates:", find("usd1") or find("world"))
print("USDC candidates:", find("usdc") or find("circle"))
for pair in [("Tether USDT", "USD1"), ("USDC", "USD1"),
             ("LiquidMesh", "KyberSwap"), ("Binance Wallet", "OKX DEX"),
             ("Jupiter", "1inch")]:
    print(cmp(*pair))

# --- exhaustive: all identical-support pairs
print("\n--- ALL identical-support pairs in the 60 ---")
ident = [(a, b) for a, b in pairs if specs[a] == specs[b]]
for a, b in ident:
    print(f"  {a} == {b}  support={sorted(specs[a])}")
print("count:", len(ident))
