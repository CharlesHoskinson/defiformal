# P17 Vault `Operations.lean` — kernel defeq blowup: bounded diagnosis

Reviewer: native Claude Opus (adviser). Scope: **one proof-performance bug**.
Not an implementation review, not planning acceptance. No verdict on P17.
All P17 implementation / source / reuse gates remain **false**.

Frozen inputs: `snapshot/` (hash-bound by `inputs.json`).
`snapshot/Operations.lean` sha256 `3084fcbb1f73b1c7f52d89968f6de0915b68c6674019d925654dc38b7afd2254`.
Author worktree was read only for its compiled `.olean` imports; no author file was written.

## 1. Result in one line

The blowup is **entirely kernel-side**, it is caused by `simp [bind, Except.bind]`
firing over a bind whose **scrutinee is `convertToShares`**, and it is **not** caused by
`mintAfterGuard`. `@[irreducible]` protects the elaborator but the kernel ignores it.
Replacing that one `simp` call with a generic, abstractly-proved `Except` bind lemma
makes the identical statements check in well under 4000 heartbeats.

## 2. Evidence

### Attempt 1 — the current frozen snapshot still fails

Byte-identical copy of `snapshot/Operations.lean` (`work/attempt1/OperationsFrozen.lean`,
same sha256), compiled against the author's built imports:

```
lean -j1 -M4096 --profile -DmaxHeartbeats=10000   # exit 1, wall 9.03s
OperationsFrozen.lean:179:8: error: (kernel) deterministic timeout
type checking took 7.96s
OperationsFrozen.lean:188:8: error: (kernel) unknown constant 'deposit_after_drip'   # cascade
OperationsFrozen.lean:196:8: error: (kernel) unknown constant 'deposit_after_drip'   # cascade
```

Cumulative profile: `elaboration 29.7ms`, `simp 10ms`, `tactic execution 7.86ms`,
**`type checking 7.97s`**.

Line 179 is `deposit_after_drip`. `deposit_invalid_zero` / `deposit_invalid_self` are
pure cascades of it, not independent failures. This matches the root receipt at 20000
heartbeats (`(kernel) excessive memory consumption`, `type checking took 15.2s`,
elaboration 35.2ms) on the earlier match-based snapshot: **the `>>=`/`deposit_def`
rewrite and the `mintAfterGuard` `@[irreducible]` refactor did not change the failure
class at all**; they only moved the reported error from the `match` form to the
`>>=` form.

The 29.7ms elaboration vs 7.96s kernel split is the diagnostic signature: the tactic
block never does the expensive work, it *emits* a proof term whose type obligations
force the kernel to do it. Lean's `@[irreducible]` attribute is an elaborator
transparency setting; the kernel has no notion of it and will delta-unfold
`convertToShares`, `Operations.mul`, `Word.checked`, `uint256Bound`, `Rounding.divideNat`
whenever a defeq check demands a weak head normal form.

### Attempt 2 — bisection ladder (`work/attempt2/Ladder.lean`, 4000 heartbeats, exit 1, 6.62s)

Verbatim copy of the frozen definitions plus stand-ins
(`convStub : Word 256 → Word 192 → Except Failure (Word 256) := fun a _ => .ok a`,
`tailStub ... := .ok (st, shares)`, both `@[irreducible]`, both same type/arity as the
real thing). Every rung uses the frozen proof script unless stated.

| rung | conversion | tail | script | kernel |
|---|---|---|---|---|
| C | `convStub` | `tailStub` | `simp [bind, Except.bind]` | **ok** |
| A | **`convertToShares`** | `tailStub` | `simp [bind, Except.bind]` | **(kernel) deterministic timeout, 2.87s** |
| B | `convStub` | **`mintAfterGuard`** | `simp [bind, Except.bind]` | **ok** |
| D | `convertToShares` | `mintAfterGuard` | `rw [deposit_def, hchi]; exact bindOkGen chi _` | **ok** |
| E | `convertToShares` | `mintAfterGuard` | `simp [bind, Except.bind]` (frozen script) | **(kernel) deterministic timeout, 2.66s** |

Rung B is the decisive negative: the real `usdsTransferFrom`/`mintShares`/`Ledger`
update tail is *innocent*. Rung A is the decisive positive: swapping only the
conversion function, everything else fixed, reproduces the bomb. Rung D is the repair,
on the **exact frozen statement**, with the real definitions on both sides.

### Attempt 3 — mechanism + repair (`work/attempt3/Mechanism.lean`, 4000 heartbeats, exit 1, 4.31s)

Minimal reproducer, no `Ledger`, no guard, no tail, no structure updates:

```lean
theorem probe_bomb (e : Except Failure (Word 192)) (c : Word 192) (h : e = .ok c)
    (a : Word 256) (f : Word 256 → Except Failure (Word 256)) :
    (e >>= fun c => convertToShares a c >>= f) = (convertToShares a c >>= f) := by
  rw [h]
  simp [bind, Except.bind]
-- Mechanism.lean:176:8: error: (kernel) deterministic timeout / type checking took 3.12s
```

`probe_control`, identical except `convStub` replaces `convertToShares`: **passes**.
`probe_repair`, identical except the last line is `exact bindOkGen c _`: **passes**.

The only varying factor between `probe_control` and `probe_bomb` is whether the
scrutinee's body whnfs to a constructor (`.ok assets`) or to open arithmetic. This is
direct evidence that the kernel is *reducing the scrutinee*, and that the cost lives in
`convertToShares`'s arithmetic body (`Operations.mul`, `Rounding.divideNat`,
`Word.checked (w := 256)`, `uint256Bound = 2 ^ 256`), reached through
`simp`'s unfolded `Except.bind` matcher.

Also in attempt 3, all four repaired production-shape theorems compiled at 4000
heartbeats with no error and no `sorry`: `deposit_after_drip'`, `deposit_invalid_zero'`,
`deposit_invalid_self'`, `deposit_invalid_zero_simponly`.

Two probes (`probe_matcher_stub`, `probe_matcher_bomb`) failed at **elaboration** with
`Type mismatch / rfl`, including the control. They tested nothing and are void; they are
recorded only because failures are not overwritten.

## 3. Why it explodes

1. `simp [bind, Except.bind]` does not merely iota-reduce `Except.ok c >>= k`. It
   **unfolds `Except.bind` everywhere in the goal**, including the *inner* binds whose
   scrutinees are `convertToShares assets chi` and `guardReceiver receiver`, turning them
   into matcher applications.
2. The emitted proof term therefore contains equations whose two sides are headed by
   different constants — `Except.bind`-headed on one side, matcher/`Except.casesOn`-headed
   on the other — over the same scrutinee.
3. The kernel discharges those by lazy delta-unfolding and, to iota-reduce the matcher,
   must whnf the scrutinee. `@[irreducible]` is invisible to the kernel, so it descends
   into `convertToShares` → `Operations.mul` → `Rounding.divideNat` → `Word.checked` →
   `uint256Bound`. With symbolic `assets`/`chi` this never reaches a constructor; it just
   grows terms. Hence `(kernel) deterministic timeout` at 4000/10000 heartbeats and
   `(kernel) excessive memory consumption` at 20000 heartbeats — the same reduction,
   given more budget, spends it on memory.
4. `mintAfterGuard` was never on this path (rung B). Its `@[irreducible]` marker gives no
   kernel protection either; it happens to be harmless because nothing forces its whnf.
5. Contrast: the *existing, passing* `Conversion.lean` proofs use `simp [bind, Except.bind]`
   freely, but only **after** `rw [mul_ray_ok ...]` / `cases hd : Rounding.divideNat ...`
   have put every scrutinee into explicit constructor form. That is exactly the invariant
   `deposit_after_drip` violates: it asks `simp` to reduce a bind whose scrutinee is still
   an unevaluated arithmetic call.

## 4. Recommended repair (for the Grok author)

Statement-preserving, script-only. No statement, ordering, semantics, definition,
`axiom`, `sorry`, `native_decide` or claim strength changes.

**R1 — add two generic congruence lemmas, proved at fully abstract type.** Their `rfl`
is checked by the kernel at `{ε α β}` with a variable scrutinee, so the kernel does zero
arithmetic; every later use is a cheap instantiation.

```lean
theorem bindOkGen {ε α β} (a : α) (f : α → Except ε β) :
    (Except.ok a : Except ε α) >>= f = f a := rfl

theorem bindErrorGen {ε α β} (e : ε) (f : α → Except ε β) :
    (Except.error e : Except ε α) >>= f = (Except.error e : Except ε β) := rfl
```

**R2 — in `deposit_after_drip`, replace `simp [bind, Except.bind]` with `exact bindOkGen chi _`.**
Verified on the frozen statement (attempt 2 rung D, attempt 3 `deposit_after_drip'`):

```lean
theorem deposit_after_drip ... := by
  rw [deposit_def, hchi]
  exact bindOkGen chi _
```

**R3 — in `deposit_invalid_zero` / `deposit_invalid_self`, drop `simp [bind, Except.bind]`**
and close by rewriting with the generic lemmas. Both forms below were verified:

```lean
  obtain ⟨shares, hs⟩ := hconv
  rw [deposit_after_drip st assets .zero sender st.chi hchi, hs, bindOkGen,
    guardReceiver_zero, bindErrorGen]
```
or, if a `simp` shape is preferred,
`simp only [hs, bindOkGen, guardReceiver_zero, bindErrorGen]` after the
`deposit_after_drip` rewrite. Use `simp only`, never plain `simp [bind, Except.bind]`.

**R4 — standing rule for the rest of P17 (`mint`, `withdraw`, `redeem`, `Adapter`).**
Never let `Except.bind`/`bind` be unfolded while any scrutinee is still an unevaluated
`convertToShares` / `convertToAssets` / `previewMint` / `previewWithdraw` /
`Operations.*` / `Word.checked` call. Either put the scrutinee in constructor form first
(`rw [... _ok ...]`, `cases h : ...`) — the pattern `Conversion.lean` already uses — or
step the bind with `bindOkGen`/`bindErrorGen`. `withdraw`/`redeem` use `do`-notation over
the same `Except`, so they will hit this the moment continuation lemmas are attempted.

**R5 — do not spend further effort on source-level helper abstraction.** `mintAfterGuard`
and the `@[irreducible]` markers on it and on the conversions do not and cannot fix this:
rung B shows the tail is innocent, and the kernel ignores `@[irreducible]` by
construction. Keep them if they help elaboration, but they are not the lever.
`opaque` *would* stop the kernel, but it would also break the existing
`convertToShares_ok` / `_floor` characterisation proofs, which need to unfold the body;
it is not recommended.

Expected effect: `deposit_after_drip` and its two dependants go from
`(kernel) deterministic timeout` at 10000 heartbeats to checking within 4000 heartbeats,
with no change to any statement.

## 5. Limitations and uncertainty

- Bounded to three diagnostic runs, as instructed. Each used a real
  `timeout --kill-after=5s 45s`; none hit the wall clock (9.03s, 6.62s, 4.31s), and no
  run was classified as a proof falsity.
- Diagnostics were compiled against the **author's** `.olean` cache in
  `/home/charl/defiformal-wt-p17-implementation-grok-opus-20260909/lean` (read-only,
  via `LEAN_PATH`, direct `lean` binary, no `lake`, no build). Per the brief these
  successes are **debugging context only and are not independent proof evidence**.
- The repaired theorems were checked in the reviewer's own namespace copy of the frozen
  definitions, not in the author's file, and not as part of a full-module build. Whether
  the whole module then compiles, and whether `mint`/`withdraw`/`redeem`/`Adapter`
  contain further independent bottlenecks, is **not** established here.
- `#print axioms` was not run on the repaired chain (attempt budget exhausted). The
  repair introduces only two `rfl` lemmas and removes tactic calls, and no `sorry`
  warning was emitted, but this is an argument, not a check.
- `probe_matcher_stub` / `probe_matcher_bomb` failed to elaborate and contribute nothing;
  the whnf-of-scrutinee mechanism rests on the `probe_control` vs `probe_bomb` contrast
  and on the A/B/C ladder, which is a controlled single-variable comparison, not on a
  direct kernel trace. A kernel-level trace was not available at this budget.
- Heartbeat counts are a proxy for kernel work; a timeout at N heartbeats is a resource
  outcome, never a statement that a goal is false.

## 6. Reviewer status

Adviser only. No production candidate was patched, no author file touched, nothing
committed. Implementation acceptance: **not given, not in scope**.

## 7. Addendum — the author's live source has already moved past the frozen blob

Read-only observation made after the three attempts, for forwarding only. No Lean run,
no verification by this reviewer.

`.../lean/DefiKernel/Vault/Operations.lean` is now sha256
`c1cafb4a38876807b13d07c2defec04ff7d01b4254c5a056aed5fb735c2b70ff`
(frozen was `3084fcbb...`, mtime 12:16 vs freeze 12:13). The live version has
independently converged on the same repair:

```lean
theorem bind_ok {α β} (a : α) (f : α → Except Failure β) : bind (Except.ok a) f = f a := rfl
theorem bind_error {α β} (e : Failure) (f : α → Except Failure α') : ... := rfl
-- deposit_after_drip now ends with `exact bind_ok chi _`
-- deposit_invalid_zero/_self now `rw [..., hs, bind_ok, guardReceiver_zero, bind_error]`
```

This is R1/R2/R3. The diagnosis therefore **confirms** the direction the author has
already taken rather than redirecting it. Two remarks still stand:

- The live `bind_ok`/`bind_error` are specialised to `Failure` rather than a generic
  `{ε}`. That is sufficient — what matters for kernel cost is that the scrutinee in the
  lemma statement is a *variable*, which it is — so no change is required.
- The new `depositImpl` indirection plus `deposit_eq_impl`/`unfold depositImpl` is not
  what fixes the timeout, and it was not exercised here. Per rung B and R5, source-level
  indirection is not the lever; `exact bind_ok chi _` is. Keep it only if it aids
  readability.

R4 (the standing rule for `mint`/`withdraw`/`redeem`/`Adapter`) and R5 remain the
forward-looking content of this diagnosis.
