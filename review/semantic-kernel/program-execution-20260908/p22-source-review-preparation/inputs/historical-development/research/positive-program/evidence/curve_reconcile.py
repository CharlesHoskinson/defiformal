"""Reconcile the two Curve convergence claims.

Gate 2.0d (expressibility): integer Newton fails to converge on 2.8% of a
    1372-point grid, at any depth up to 96 — a period-2 limit cycle.
Gate 2.0e (contract): swept all 200x200 pairs at AMP=100, K=8 — zero
    non-converging, worst case 3 iterations.

Both cannot be adopted uncritically: if the pathology exists but is invisible on
the small domain, then choosing the small domain re-runs the exact failure by
which Curve's spec reached bal0=bal1=100 and lost its discrimination witness.

This computes get_D faithfully (StableSwap n=2, integer arithmetic, as in
curve-contract get_D) and reports, per domain and per amplification, the
non-convergence rate and the worst iteration count.
"""
N = 2


def get_D(x, y, amp, max_iter=255):
    """Integer StableSwap D for n=2. Returns (D, iters, converged)."""
    S = x + y
    if S == 0:
        return 0, 0, True
    D = S
    Ann = amp * N
    prev_seen = []
    for i in range(1, max_iter + 1):
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
        # period-2 limit cycle detection
        prev_seen.append(D)
        if len(prev_seen) >= 4 and prev_seen[-1] == prev_seen[-3] and prev_seen[-2] == prev_seen[-4]:
            return D, i, False
    return D, max_iter, False


def sweep(lo, hi, step, amp, cap_iter):
    tot = bad = worst = 0
    worst_pt = None
    bad_pts = []
    for x in range(lo, hi + 1, step):
        for y in range(lo, hi + 1, step):
            tot += 1
            D, it, conv = get_D(x, y, amp, cap_iter)
            if not conv:
                bad += 1
                if len(bad_pts) < 5:
                    bad_pts.append((x, y, D))
            elif it > worst:
                worst, worst_pt = it, (x, y)
    return tot, bad, worst, worst_pt, bad_pts


print("Curve get_D — integer StableSwap, n=2\n")
print(f"{'domain':<24} {'amp':>5} {'K':>4} {'points':>8} {'non-conv':>9} {'rate':>7} {'worst it':>9}")
print("-" * 74)

cases = [
    ("1..200 step 1", 1, 200, 1),
    ("1..200 step 1", 1, 200, 1),
    ("1..2000 step 13", 1, 2000, 13),
    ("1..10^5 step 701", 1, 10**5, 701),
    ("1..10^7 step 70001", 1, 10**7, 70001),
]
for (label, lo, hi, step), amp in [(c, a) for c in cases[:1] for a in (10, 100, 1000)] + \
                                   [(c, 100) for c in cases[2:]]:
    for K in (8, 96):
        tot, bad, worst, wp, bp = sweep(lo, hi, step, amp, K)
        rate = 100.0 * bad / tot if tot else 0
        print(f"{label:<24} {amp:>5} {K:>4} {tot:>8} {bad:>9} {rate:>6.2f}% {worst:>9}")
        if bad and K == 96:
            print(f"    first non-converging points: {bp}")

# targeted: extreme imbalance, the region a small domain cannot host
print("\nExtreme-imbalance probe (amp=100, K=96):")
for x, y in [(199, 1), (1000, 1), (10**4, 1), (10**5, 1), (10**6, 1),
             (10**6, 10), (10**7, 100)]:
    D, it, conv = get_D(x, y, 100, 96)
    print(f"   ({x}, {y}): D={D}  iters={it}  converged={conv}")
