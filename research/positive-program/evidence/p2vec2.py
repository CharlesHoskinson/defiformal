def isqrt_f(n):
    if n <= 0:
        return 0
    hi = 1
    while hi * hi <= n:
        hi *= 2
    lo = hi // 2
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if mid * mid <= n:
            lo = mid
        else:
            hi = mid - 1
    return lo


print("=== APEX: find (ain,rin,rout) where fee and no-fee differ ===")


def amountOut(ain, rin, rout):
    aw = ain * 999
    return aw * rout // (rin * 1000 + aw)


def nofee(ain, rin, rout):
    return ain * rout // (rin + ain)


found = []
for rin in [100, 200, 500, 1000, 2000, 5000]:
    for rout in [100, 200, 500, 1000, 2000, 5000]:
        for ain in [1, 5, 10, 20, 50, 100, 200, 500, 1000]:
            a = amountOut(ain, rin, rout)
            b = nofee(ain, rin, rout)
            if a != b:
                found.append((ain, rin, rout, a, b))
print("count differing:", len(found))
for f in found[:25]:
    print("  amountOut(ain=%d,rin=%d,rout=%d) = %d   nofee = %d" % f)

print()
print("smallest reserves that discriminate:")
best = sorted(found, key=lambda t: max(t[1], t[2]))[:8]
for f in best:
    print("  amountOut(ain=%d,rin=%d,rout=%d) = %d   nofee = %d" % f)

print()
print("=== APEX k monotone with/without fee ===")
for (ain, rin, rout) in [(200, 1000, 1000), (500, 1000, 1000), (100, 500, 500)]:
    o = amountOut(ain, rin, rout)
    n = nofee(ain, rin, rout)
    print("ain=%d rin=%d rout=%d  fee out=%d k'=%d ; nofee out=%d k'=%d ; k=%d" %
          (ain, rin, rout, o, (rin + ain) * (rout - o), n, (rin + ain) * (rout - n), rin * rout))

print()
print("=== CURVE convergence over declared domain ===")


def get_D(xp, amp, N=2, maxit=8):
    S = sum(xp)
    if S == 0:
        return 0, 0, True
    D = S
    Ann = amp * N
    for i in range(maxit):
        D_P = D
        for x in xp:
            D_P = D_P * D // (x * N)
        Dprev = D
        D = (Ann * S + D_P * N) * D // ((Ann - 1) * D + (N + 1) * D_P)
        if abs(D - Dprev) <= 1:
            return D, i + 1, True
    return D, maxit, False


bad = []
maxit_seen = 0
maxprod = 0
for a in range(1, 201):
    for b in range(1, 201):
        d, it, ok = get_D([a, b], 100, maxit=8)
        maxit_seen = max(maxit_seen, it)
        if not ok:
            bad.append((a, b))
print("domain [1,200]^2 amp=100: non-converging pairs =", len(bad), " worst iters =", maxit_seen)
print("  first few bad:", bad[:10])
bad2 = []
for a in range(1, 201):
    for b in range(1, 201):
        for amp in [1, 10, 100, 500]:
            d, it, ok = get_D([a, b], amp, maxit=8)
            if not ok:
                bad2.append((a, b, amp))
print("amp in {1,10,100,500}: non-converging =", len(bad2), bad2[:10])

print()
print("=== CURVE separation from rivals across domain ===")
for xp in [[100, 100], [150, 50], [180, 20], [190, 10], [195, 5], [199, 1]]:
    d, it, ok = get_D(xp, 100, maxit=8)
    print("  x=%3d y=%3d : D=%3d  S=%3d  2sqrt(xy)=%3d  blend(2*min + ...)=?  iters=%d" %
          (xp[0], xp[1], d, sum(xp), 2 * isqrt_f(xp[0] * xp[1]), it))

print()
print("=== DERIVE descaled UNIT=100 ===")
U = 100


def shockedPerp(pos, perpPrice, spotShock):
    if pos == 0:
        return 0
    v = (spotShock - U) * perpPrice // U
    return pos * v // U


def baseValue(pos, spot, stable, spotShock):
    if pos == 0:
        return 0
    return pos * spot // U * spotShock // U * U // stable


SHOCKS = [80, 90, 100, 110, 120]
SHOCKS = [s * U // 100 for s in SHOCKS]
spot = 100 * U
perpPrice = 100 * U
stable = U
for (bpos, ppos) in [(2 * U, -3 * U), (2 * U, 0), (0, -3 * U), (3 * U, -1 * U), (1 * U, -1 * U)]:
    bv0 = baseValue(bpos, spot, stable, U)
    vals = []
    for sh in SHOCKS:
        sv = baseValue(bpos, spot, stable, sh)
        pv = shockedPerp(ppos, perpPrice, sh)
        vals.append(sv + pv - bv0)
    m = min(vals)
    print("base=%d perp=%d bv0=%d -> mtm %s min=%d argmin=%d" % (bpos, ppos, bv0, vals, m, vals.index(m)))

print()
print("=== LIQUITY prefix redemption, descaled price=1 ===")
troves = [(1, 5, 100), (2, 8, 100), (3, 12, 300)]  # (id, rate, debt) ; lowest rate redeemed first
for amount in [50, 100, 150, 250, 400, 500, 600]:
    rem = amount
    touched = 0
    coll = 0
    out = []
    for (i, r, dbt) in sorted(troves, key=lambda t: t[1]):
        if rem <= 0:
            out.append(dbt)
            continue
        lot = min(rem, dbt)
        rem -= lot
        coll += lot
        touched += 1
        out.append(dbt - lot)
    print("redeem %3d -> touched=%d remaining=%3d newDebts(by rate asc)=%s" % (amount, touched, rem, out))

print()
print("=== POLYMARKET batched match ===")


def taking(making, ma, ta):
    return making * ta // ma


def matchType(t, m):
    return (t + 1) * (1 if t == m else 0)


# taker BUY YES 100 shares paying 60 collateral => makerAmount=60(collateral), takerAmount=100(shares)
makers = [(0, 100, 40, 50), (0, 100, 40, 30), (1, 100, 65, 20)]  # (side, makerAmount, takerAmount, fill making)
totalMint = 0
totalMerge = 0
for (side, ma, ta, making) in makers:
    mt = matchType(0, side)
    tk = taking(making, ma, ta)
    if mt == 1:
        totalMint += tk
    elif mt == 2:
        totalMerge += making
    print("  maker side=%d makerAmount=%d takerAmount=%d making=%d -> matchType=%d taking=%d" % (side, ma, ta, making, mt, tk))
print("totalMintAmount=%d totalMergeAmount=%d" % (totalMint, totalMerge))
