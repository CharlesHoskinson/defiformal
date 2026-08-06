"""How many pairs does curve.qnt's K=8 guard actually REFUSE?

curve.qnt:78-80 declares: "measured on the reachable grid, 36 of 4900 balance
pairs never break". evidence/curve_k.py measures, on a 4900-pair grid capped at
10^6: 20 non-converging PLUS 97 converging-but-needing->8. Both are refused by
`st.done`, since `done` is true only if the break fired within K=8.

So the declared figure and the measured figure should be compared on the SAME
grid before either is trusted.
"""
N = 2
AMP = 100
K = 8


def newton_d_full(x, y, amp, k):
    """Mirrors curve.qnt newtonDFull: exactly k folds carrying a done flag."""
    S = x + y
    if S == 0:
        return 0, True
    D = S
    Ann = amp * N
    done = False
    for _ in range(k):
        if done:
            continue
        D_P = D
        D_P = D_P * D // (x * N)
        D_P = D_P * D // (y * N)
        Dprev = D
        num = (Ann * S + D_P * N) * D
        den = (Ann - 1) * D + (N + 1) * D_P
        if den == 0:
            return D, False
        D = num // den
        if abs(D - Dprev) <= 1:
            done = True
    return D, done


def sweep(cap, step, label):
    tot = refused = 0
    worst = None
    for x in range(1, cap, step):
        for y in range(1, cap, step):
            tot += 1
            _, done = newton_d_full(x, y, AMP, K)
            if not done:
                refused += 1
                if worst is None:
                    worst = (x, y)
    pct = 100.0 * refused / tot
    print(f"  {label:<28} {tot} pairs, REFUSED (done=false at K=8) = {refused}"
          f"  ({pct:.2f}%)   first = {worst}")
    return tot, refused


print("Pairs refused by the K=8 `done` guard, i.e. the (E<=) restriction:\n")
sweep(10**6, 14293, "cap 10^6 (curve_k.py grid)")
sweep(10**5, 1429, "cap 10^5")
sweep(10**4, 149, "cap 10^4")

print("\nFor comparison, the two components at cap 10^6:")
tot = nonconv = over8 = 0
for x in range(1, 10**6, 14293):
    for y in range(1, 10**6, 14293):
        tot += 1
        S, D, Ann = x + y, x + y, AMP * N
        conv_it = None
        for i in range(1, 201):
            D_P = D * D // (x * N)
            D_P = D_P * D // (y * N)
            Dprev = D
            den = (Ann - 1) * D + (N + 1) * D_P
            if den == 0:
                break
            D = (Ann * S + D_P * N) * D // den
            if abs(D - Dprev) <= 1:
                conv_it = i
                break
        if conv_it is None:
            nonconv += 1
        elif conv_it > 8:
            over8 += 1
print(f"  never converge at all      = {nonconv}")
print(f"  converge but need > 8      = {over8}")
print(f"  total refused by K=8 guard = {nonconv + over8}")
