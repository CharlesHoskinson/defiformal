import pathlib

r = pathlib.Path("/root/DefiElements/research/positive-program/ROADMAP.md")
t = r.read_text(encoding="utf-8")

t = t.replace(
    "| 2.0d kernel (`isqrt`, Newton, sorted walk) | **IN FLIGHT** | expressibility planner; blocks all re-spec work |",
    "| 2.0d kernel (`isqrt`, Newton, sorted walk) | **PASSED** | `phase2/kernel/` 9/9 typecheck (independently verified); sorted walk costs **zero extra reachable states**, Apalache-proved to depth 3 |")

t = t.replace(
    "| 2.1 re-spec the ten | blocked | needs 2.0d + review of contrast sets |",
    "| 2.1 re-spec the ten | **READY** | 2.0d passed; needs contrast-set review, then execution |")

constraints = """**Next gate: 2.1 — write the ten re-specs.** Unblocked.

### Hard constraints discovered at 2.0d (these bind every re-spec)

1. **Quint's default Rust backend is i64, not bignum.** `10^18 * 10^18`
   overflows. Every re-spec must keep its domain inside i64, or pay a large
   speed cost via `--backend=typescript`. This is the only genuine
   expressibility limit found.
2. **A fixed unrolling of Newton is NOT faithful.** A bare `foldl` silently
   deletes the contract's `break`; carrying a `done` flag makes it bit-identical
   where the break fires. Depth **K = 8** (measured worst case 7 — the brief's
   "about 4" was wrong).
3. **Convergence obligations must not live in an action precondition.** Doing so
   made every depth pass, including K = 3, by pruning the very states it was
   meant to expose. That is `approxD`'s failure mode in disguise.
4. **History-based state predicates are unsound as regression guards** — broken
   by insertion, not only by rate changes. The sound form quantifies over
   hypothetical redemptions.
5. **Curve's integer Newton genuinely fails to converge on 2.8% of a 1372-point
   grid**, at any depth up to 96 — a period-2 limit cycle with residual
   oscillating 20 to 21. This is a fact about Curve that `approxD` concealed.

### What the kernel bought

- Extremal selection is not merely expressible, it is **cheaper**: zero extra
  reachable states (machine-checked by a `listIsCanonical` invariant proving the
  list is a function of its element set — the id tie-break is what buys this),
  about 1.6x wall clock per trace, **flat from 3 to 24 troves**, and branching
  *drops* (147 vs 216 nondet combinations per step at N = 24). No restriction on
  user count is needed.
- `isqrt` is **exact** on `0 <= n < 2^62` via 31 folds, verified on ~14k points.
  Newton was measured and rejected: fixed-depth Newton never becomes exact,
  plateauing at 64 wrong values with error 1 at depths 16, 32 and 64.
- The independently built regression linter confirms the fix: `liq_nondet.qnt`
  flags `redeem(u)` as identity selection used as a map key; `liq_sorted.qnt`
  has no trove parameter at all."""

t = t.replace(
    "**Next gate: 2.0d (the kernel).** Nothing in Phase 2 can start without it.",
    constraints)

r.write_text(t, encoding="utf-8")
print("ROADMAP updated")
