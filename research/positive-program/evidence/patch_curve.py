p = "/tmp/expr/curvePool.qnt"
s = open(p).read()
# Convergence must be an INVARIANT, never a guard: as a guard it prunes exactly
# the states it is supposed to expose.
s = s.replace("      dConverged(b0, b1, AMP), dConverged(b0 + a0, b1 + a1, AMP),\n", "")
s = s.replace("      dConverged(b0, b1, AMP),\n", "")

recfg = (
    "  /// jump to an arbitrary pool configuration -- stresses the D domain directly\n"
    "  action reconfigure(x: int, y: int): bool = all {\n"
    "    x > 0, y > 0,\n"
    "    (if (x > y) x / y else y / x) <= MAXIMBALANCE,\n"
    "    b0" + chr(39) + " = x, b1" + chr(39) + " = y, lpSupply" + chr(39) + " = lpSupply,\n"
    "  }\n\n"
    "  action step = any {"
)
s = s.replace("  action step = any {", recfg)
s = s.replace(
    "    nondet a = AMTS.oneOf()\n    exchange(a),\n  }",
    "    nondet a = AMTS.oneOf()\n    exchange(a),\n"
    "    nondet x = WIDE.oneOf()\n    nondet y = WIDE.oneOf()\n    reconfigure(x, y),\n  }",
)
s = s.replace(
    "pure val MAXIMBALANCE: int = 100   //",
    "pure val WIDE: Set[int] = Set(1, 5, 100, 999, 5000, 100000, 1000000)\n"
    "  pure val MAXIMBALANCE: int = 100   //",
)
open(p, "w").write(s)
print("patched")
