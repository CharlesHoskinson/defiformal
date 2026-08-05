"""Is K=8 sufficient across the 10^6 domain recommended for curve?

W1 measured K=8 tight on its reachable grid (worst case exactly 8). That grid
tops out around 10^5. The domain recommendation for curve is <=10^6. If any
CONVERGING pair inside 10^6 needs more than 8 iterations, K=8 truncates it and
the spec silently returns a wrong D — a new instance of the trap where a bound
is validated on a domain smaller than the one it ships against.
"""
N = 2


def get_D(x, y, amp, maxit=200):
    S = x + y
    if S == 0:
        return 0, 0, True
    D = S
    Ann = amp * N
    for i in range(1, maxit + 1):
        D_P = D
        D_P = D_P * D // (x * N)
        D_P = D_P * D // (y * N)
        Dprev = D
        num = (Ann * S + D_P * N) * D
        den = (Ann - 1) * D + (N + 1) * D_P
        if den == 0:
            return D, i, False
        D = num // den
        if abs(D - Dprev) <= 1:
            return D, i, True
    return D, maxit, False


print("Max iterations among CONVERGING pairs, by domain cap (amp=100):\n")
for cap, step in [(10**4, 149), (10**5, 1429), (10**6, 14293)]:
    worst, wp, nconv, tot = 0, None, 0, 0
    over8 = 0
    for x in range(1, cap, step):
        for y in range(1, cap, step):
            tot += 1
            D, it, conv = get_D(x, y, 100)
            if conv:
                if it > worst:
                    worst, wp = it, (x, y)
                if it > 8:
                    over8 += 1
            else:
                nconv += 1
    verdict = "SUFFICIENT" if worst <= 8 else "TRUNCATES converging pairs"
    exp = len(str(cap)) - 1
    print(f"  cap 10^{exp}: {tot} pairs, worst converging = {worst} iters at {wp}")
    print(f"            non-converging {nconv}, converging-but->8-iters {over8}")
    print(f"            -> K=8 {verdict}\n")
