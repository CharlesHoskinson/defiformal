def isqrt_f(n):
    if n <= 0:
        return 0
    lo, hi = 0, 1
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


print("=== UNIV2 ===")
for a, b in [(4000, 9000), (1000, 1000), (2000, 8000), (1, 4), (90, 10), (4, 9)]:
    s = isqrt_f(a * b)
    print("sqrt(%d*%d)=%d  mint=%s  min=%d" % (a, b, s, str(s - 1000), min(a, b)))


def mintfee(kLast, r0, r1, ts):
    rootK = isqrt_f(r0 * r1)
    rootKLast = isqrt_f(kLast)
    if rootK <= rootKLast:
        return 0
    return ts * (rootK - rootKLast) // (rootK * 5 + rootKLast)


print("mintFee(kLast=1000000,r=1200,1200,ts=1000) =", mintfee(1000000, 1200, 1200, 1000))
print("mintFee(kLast=1000000,r=2000,2000,ts=1000) =", mintfee(1000000, 2000, 2000, 1000))
print("mintFee(kLast=1000000,r=1000,1000,ts=1000) =", mintfee(1000000, 1000, 1000, 1000))
print("isqrt table:", [(n, isqrt_f(n)) for n in [0, 1, 2, 3, 4, 8, 15, 16, 10**6, 36000000, 2**62 - 1]])

print()
print("=== CURVE get_D, N=2 ===")


def get_D(xp, amp, N=2, maxit=255):
    S = sum(xp)
    if S == 0:
        return 0, 0
    D = S
    Ann = amp * N
    for i in range(maxit):
        D_P = D
        for x in xp:
            D_P = D_P * D // (x * N)
        Dprev = D
        D = (Ann * S + D_P * N) * D // ((Ann - 1) * D + (N + 1) * D_P)
        if abs(D - Dprev) <= 1:
            return D, i + 1
    return D, maxit


for xp in [[100, 100], [100, 25], [150, 50], [190, 10], [199, 1], [120, 80], [160, 40], [180, 20], [195, 5]]:
    d, it = get_D(xp, 100)
    print("get_D(%s,amp=100) = %d  iters=%d  S=%d  2*isqrt=%d" % (xp, d, it, sum(xp), 2 * isqrt_f(xp[0] * xp[1])))

print()
print("=== COMPOUND descaled bps, SCALE=10^4 ===")
S = 10**4


def mulFactor(n, f):
    return n * f // S


def mulPrice(n, p, fromScale):
    return n * p // fromScale


def divPrice(n, p, toScale):
    return n * toScale // p


LF = 9000  # liquidationFactor 0.90
SF = 5000  # storeFrontPriceFactor 0.50
assetPrice = 5 * S
basePrice = 1 * S
for seize in [1000, 750, 300]:
    value = mulPrice(seize, assetPrice, S)
    delta = mulFactor(value, LF)
    deltaBalance = divPrice(delta, basePrice, S)
    print("seize=%d value=%d deltaValue=%d deltaBalance=%d  (shortcut credits %d)" % (seize, value, delta, deltaBalance, value))
discountFactor = mulFactor(SF, S - LF)
assetPriceDiscounted = mulFactor(assetPrice, S - discountFactor)
print("discountFactor=%d assetPriceDiscounted=%d" % (discountFactor, assetPriceDiscounted))
for baseAmount in [4500, 3375, 1350, 950]:
    q = basePrice * baseAmount * S // assetPriceDiscounted // S
    print("quoteCollateral(baseAmount=%d) = %d" % (baseAmount, q))

print()
print("=== MORPHO descaled bps ===")
CURSOR = 3000
MAXLIF = 11500
for lltv in [8600, 9000, 7700, 0, 9800, 5000]:
    inner = S - CURSOR * (S - lltv) // S
    lif = min(MAXLIF, S * S // inner)
    print("lltv=%d inner=%d LIF=%d" % (lltv, inner, lif))

VS = 10**6
VA = 1


def toAssetsUp(shares, tA, tS):
    num = shares * (tA + VA)
    den = tS + VS
    return -(-num // den)


for (tA, tS, bshares) in [(1000, 1000 * VS, 200 * VS), (1000, 1000 * VS, 1000 * VS), (500, 400 * VS, 150 * VS)]:
    bda = min(tA, toAssetsUp(bshares, tA, tS))
    print("totalBorrowAssets=%d totalBorrowShares=%d badDebtShares=%d -> badDebtAssets=%d  newTotalSupplyAssets=%d (from 2000)" % (tA, tS, bshares, bda, 2000 - bda))

print()
print("=== APEX ===")


def amountOut(ain, rin, rout):
    aw = ain * 999
    return aw * rout // (rin * 1000 + aw)


def amountIn(aout, rin, rout):
    return (rin * aout * 1000) // ((rout - aout) * 999) + 1


for (ain, rin, rout) in [(100, 1000, 1000), (10, 1000, 1000), (50, 2000, 500), (1, 1000, 1000), (200, 1000, 1000)]:
    o = amountOut(ain, rin, rout)
    nofee = ain * rout // (rin + ain)
    k0 = rin * rout
    k1 = (rin + ain) * (rout - o)
    print("amountOut(%d,%d,%d)=%d  nofee=%d  k %d -> %d (delta %d)" % (ain, rin, rout, o, nofee, k0, k1, k1 - k0))
for (aout, rin, rout) in [(100, 1000, 1000), (50, 2000, 500)]:
    print("amountIn(%d,%d,%d)=%d  (unrounded %s)" % (aout, rin, rout, amountIn(aout, rin, rout), (rin * aout * 1000) / ((rout - aout) * 999)))
for (b, q) in [(4000, 9000), (2000, 2000)]:
    print("apex mint sqrt(%d*%d)-1000 = %d  linear=%d" % (b, q, isqrt_f(b * q) - 1000, b))

print()
print("=== GMX descaled, SCALE=10^4, exponent 2 ===")


def applyExponentFactor(d, expfac):
    if d < S:
        return 0
    if expfac == S:
        return d
    # exponent 2 exactly
    if expfac == 2 * S:
        return d * d // S
    raise Exception("only 1 or 2")


def applyImpactFactor(d, f, expfac):
    return applyExponentFactor(d, expfac) * f // S


F = 50
for d in [0, 5000, 10000, 20000, 30000, 40000]:
    print("applyImpactFactor(d=%d,f=50,exp=2) = %d   [linear exp=1 -> %d]" % (d, applyImpactFactor(d, F, 2 * S), applyImpactFactor(d, F, S) if d >= S else 0))
pairs = [(20000, 10000), (10000, 0), (0, 20000), (30000, 20000), (10000, 20000), (20000, 30000)]
for (i0, i1) in pairs:
    a = applyImpactFactor(i0, F, 2 * S)
    b = applyImpactFactor(i1, F, 2 * S)
    delta = abs(a - b)
    sign = 1 if i1 < i0 else -1
    la = applyImpactFactor(i0, F, S)
    lb = applyImpactFactor(i1, F, S)
    print("sameSide(init=%d,next=%d) = %+d   [linear = %+d]" % (i0, i1, sign * delta, sign * abs(la - lb)))

print()
print("=== HUMA ===")


def ceilDiv(a, b):
    return -(-a // b)


for (senior, junior, ratio) in [(700, 200, 4), (700, 300, 4), (800, 200, 4), (750, 250, 4), (700, 175, 4)]:
    mj = ceilDiv(senior, ratio)
    mr = junior - mj if junior > mj else 0
    print("senior=%d junior=%d ratio=%d minJunior=%d maxRedeemable=%d" % (senior, junior, ratio, mj, mr))

print()
print("=== DERIVE descaled, UNIT=10^4, perp+base only ===")
U = 10**4


def shockedPerp(pos, perpPrice, spotShock):
    if pos == 0:
        return 0
    v = (spotShock - U) * perpPrice // U
    return pos * v // U


def baseValue(pos, spot, stable, spotShock):
    if pos == 0:
        return 0
    return pos * spot // U * spotShock // U * U // stable


SHOCKS = [8000, 9000, 10000, 11000, 12000]
spot = 100 * U
perpPrice = 100 * U
stable = U
for (bpos, ppos) in [(2 * U, -3 * U), (0, -3 * U), (2 * U, 0), (1 * U, 1 * U)]:
    bv0 = baseValue(bpos, spot, stable, U)
    vals = []
    for sh in SHOCKS:
        sv = baseValue(bpos, spot, stable, sh)
        pv = shockedPerp(ppos, perpPrice, sh)
        vals.append(sv + pv - bv0)
    m = min(vals)
    print("base=%d perp=%d -> scenarioMtM %s  min=%d argmin=%d" % (bpos, ppos, vals, m, vals.index(m)))

print()
print("=== POLYMARKET ===")


def takingAmount(making, makerAmount, takerAmount):
    return making * takerAmount // makerAmount


cases = [(50, 100, 40), (30, 100, 40), (100, 100, 65), (25, 50, 35), (60, 100, 40)]
for (making, ma, ta) in cases:
    print("calculateTakingAmount(making=%d, makerAmount=%d, takerAmount=%d) = %d" % (making, ma, ta, takingAmount(making, ma, ta)))


def matchType(takerSide, makerSide):
    return (takerSide + 1) * (1 if takerSide == makerSide else 0)


for t in [0, 1]:
    for m in [0, 1]:
        print("matchType(taker=%d,maker=%d)=%d" % (t, m, matchType(t, m)))
