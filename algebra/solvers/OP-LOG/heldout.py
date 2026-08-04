"""Held-out generalisation check.

formal/atlas.qnt carries twelve protocol decompositions authored independently
of the corpus50 lanes -- its Aave is 10 symbols where the lane's is 17. None of
them was used to fit any axiom, and three of them (Terra, Mango, Euler) are
dead protocols that appear nowhere in the census. This is the only genuinely
out-of-sample positive evidence available.
"""
import re
import atlas as A, theory as T

src = open("/root/DefiElements/formal/atlas.qnt", encoding="utf8").read()
P = []
for m in re.finditer(r'\{ id: "(\w+)", name: "([^"]+)", elements: Set\(([^)]*)\), dead: (\w+) \}', src):
    P.append((m.group(1), m.group(2),
              [x.strip() for x in m.group(3).split(",") if x.strip()],
              m.group(4) == "true"))

print(f"{'protocol':14s} {'dead':5s} {'atlas-closes':12s} {'OP-LOG':14s} violated")
ok = 0
for pid, name, syms, dead in P:
    v = T.violations(syms)
    if not v:
        ok += 1
    print(f"{pid:14s} {str(dead):5s} {str(A.closes(syms)):12s} "
          f"{'ADMISSIBLE' if not v else 'INADMISSIBLE':14s} {v}")
print(f"\nOP-LOG accepts {ok}/{len(P)} = {ok/len(P):.1%} of an independently "
      f"authored decomposition set")
print(f"atlas closure accepts {sum(1 for _,_,s,_ in P if A.closes(s))}/{len(P)}")

alive = [(p, s) for p, _, s, d in P if not d]
print(f"\nlive only: OP-LOG {sum(1 for _,s in alive if T.valid(s))}/{len(alive)}, "
      f"atlas {sum(1 for _,s in alive if A.closes(s))}/{len(alive)}")
