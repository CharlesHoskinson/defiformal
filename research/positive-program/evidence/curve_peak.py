"""Check the claim that my CF3 domain recommendation overflows i64.

I justified 10^5..10^7 by observing 10^7 * 10^7 = 10^14 << 9.22e18. That is the
product of the two BALANCES. The quantity that actually has to fit is the peak
intermediate inside the Newton step:

    D_P  = D*D//(x*N) * D//(y*N)          ~ D^3 / (N^2 * x * y)
    num  = (Ann*S + D_P*N) * D

At extreme imbalance (y = 1) D_P is cubic in D, so num is much larger than x*y.
"""
N = 2
I64 = 2**63 - 1


def peak(x, y, amp, max_iter=96):
    """Largest intermediate the integer get_D would form."""
    S = x + y
    if S == 0:
        return 0, 0, True
    D = S
    Ann = amp * N
    hi = max(S, x * N, y * N)
    for i in range(1, max_iter + 1):
        t1 = D * D
        hi = max(hi, t1)
        D_P = t1 // (x * N)
        t2 = D_P * D
        hi = max(hi, t2)
        D_P = t2 // (y * N)
        Dprev = D
        num = (Ann * S + D_P * N) * D
        den = (Ann - 1) * D + (N + 1) * D_P
        hi = max(hi, num, den)
        if den == 0:
            return hi, i, False
        D = num // den
        if abs(D - Dprev) <= 1:
            return hi, i, True
    return hi, max_iter, False


print(f"i64 max = {I64:,}\n")
print(f"{'point (x,y)':<22} {'amp':>5} {'peak intermediate':>22} {'x*y':>18} {'fits i64':>9} {'conv':>6}")
print("-" * 92)
for x, y in [(200, 1), (2000, 1), (10**4, 1), (10**5, 1), (10**6, 1),
             (2_642_245, 1), (3_000_000, 1), (10**7, 1), (10**7, 10**7)]:
    hi, it, conv = peak(x, y, 100)
    print(f"{('(%d, %d)' % (x, y)):<22} {100:>5} {hi:>22,} {x*y:>18,} "
          f"{'YES' if hi <= I64 else 'NO':>9} {str(conv):>6}")

print("\nLargest x with y=1 whose peak still fits i64 (amp=100):")
lo, hi_b = 1, 10**8
while lo < hi_b:
    mid = (lo + hi_b + 1) // 2
    p, _, _ = peak(mid, 1, 100)
    if p <= I64:
        lo = mid
    else:
        hi_b = mid - 1
print(f"   x_max = {lo:,}")
p, it, conv = peak(lo, 1, 100)
print(f"   peak at x_max = {p:,}  ({I64/p:.1f}x headroom)  converged={conv}")

print("\nDoes a 10^6 cap still host the divergence witness? (amp=100, K=8)")
import math
bad = 0
tot = 0
for x in range(1, 10**6, 7919):
    for y in (1, 2, 5):
        tot += 1
        _, it, conv = peak(x, y, 100, 8)
        if not conv:
            bad += 1
print(f"   {bad} of {tot} non-converging at K=8  ->  witness {'HOSTED' if bad else 'ABSENT'}")
