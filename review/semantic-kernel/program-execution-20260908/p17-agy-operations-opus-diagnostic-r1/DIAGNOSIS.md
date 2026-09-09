# P17 Vault — `withdraw_success_shares` / `redeem_success_assets`: bounded diagnosis

Reviewer: native Claude Opus, **adviser only**. Scope: one proof-performance/failure bug in
the successful-return projection proofs. This is **not** a P17 implementation review and
**not** acceptance. All P17 implementation / source / reuse gates remain **false**.

Author role of record: native AGY `gemini-3.8-flash-high`, effort high. Prior Grok
provenance is historical only. The author is actively editing its worktree; no author file
was written, and no author `.lake` was written or built.

Frozen inputs: `snapshot/`, hash-bound by `inputs.json`; all nine files re-verified
byte-identical after the runs. Authoritative for this diagnostic:

- `snapshot/Operations.lean` sha256 `73b7cc49762423072d6aa252dd2ea0324b5dce22861300736c8fe5aab81b549a`
- `snapshot/Conversion.lean` sha256 `7cfd54d4e19260246612c29f6d7d1477c144180f65b46aca1526c5b56ba1996f`
- `snapshot/Types.lean`      sha256 `2aaf7e2dc031013562c4ec70045a95091f862b81c471d4eeb5c3e81f7f2a3b2f`

Author worktree movement observed by **sha256 only** — I did not read the contents of the
author's moving `Operations.lean`, only hashed it (read-only, no verification claimed):
`.../lean/DefiKernel/Vault/Operations.lean` was already `0be2aaa759d3d9dec26d32677cc36fc589b5fb406a3dde3fd0365c98af0c6a8f`
both before and after my runs, i.e. **the live file had already moved past the frozen
`73b7cc49...` before this diagnostic started**. `Conversion.lean` and `Types.lean` were
byte-identical to the snapshot before *and* after, so the compiled
`Conversion.olean` / `Types.olean` I imported correspond to the frozen sources.

---

## 1. Result in one line

The frozen `withdraw_success_shares` / `redeem_success_assets` do **not** fail in the
kernel — they fail in the **elaborator**, because `rw [hchi] at h` leaves the outer bind
stuck as `Except.ok chi >>= fun chi => …`, so `previewWithdraw assets chi` /
`convertToAssets shares chi` occur only **under a shadowing binder** and every subsequent
`rw` misses. The obvious way to unstick it (`dsimp only [bind, Except.bind]`, which the
previous revision used) is exactly what re-arms the kernel bomb of the prior diagnosis.
The correct repair is a **generic `Except` success-inversion lemma proved at abstract
type**, plus `withdraw_after_drip` / `redeem_after_drip` continuation lemmas in the shape
of the already-working `deposit_after_drip`. Verified: the full repaired chain checks in
**9.55 ms of kernel type-checking**, exit 0, no `sorry`, no `native_decide`, no new axioms.

## 2. What was actually run

Three bounded attempts, each `timeout --kill-after=5s 45s`, Lean pinned to the project
toolchain `v4.33.0-rc2` (**note:** the default `lean` on PATH is 4.33.1 and would not have
loaded these oleans), `-j1 -M4096 -DmaxHeartbeats=10000 --profile`, `LEAN_PATH` built by
hand from the author's package dirs (recorded in `env/LEAN_PATH.txt`). No `lake build`, no
write outside this directory. Inputs, stdout, stderr and exit code of every attempt are
preserved under `work/attemptN/` and were never overwritten.

| # | file | sha256 | exit | wall | kernel type checking |
|---|---|---|---|---|---|
| 1 | `work/attempt1/Repair.lean` | `72e74f03…` | 1 | 1.20 s | 8.6 ms |
| 2 | `work/attempt2/Repair.lean` | `d6de65ab…` | **0** | 1.30 s | 9.55 ms |
| 3 | `work/attempt3/Frozen.lean` | `88df3c05…` | 1 | 1.00 s | 4.38 ms |

All three files are reviewer-owned, in namespaces `DefiKernel.Vault.OpusDiagR1` /
`…R1Frozen`. Each contains **byte-verbatim copies** of the frozen `Ledger`,
`usdsTransfer`, `burnShares`, `dripChi`, `withdraw`, `redeem`, `bind_ok`, `bind_error`.
`previewWithdraw`, `convertToAssets`, `previewWithdraw_ok`, `convertToAssets_ok`,
`Word`, `Rounding`, `rayWord`, `Failure`, `Addr` are the **real** production constants,
imported from the author's compiled `DefiKernel.Vault.Conversion`.

### Attempt 3 — reproduction of the frozen failure (the decisive negative)

`work/attempt3/Frozen.lean` embeds `snapshot/Operations.lean` lines 344–369 and 379–404
**byte-for-byte** (verified by `diff` against the snapshot: identical). Result — four
errors, all the same, no kernel involvement at all:

```
Frozen.lean:97:8:  error: Tactic `rewrite` failed: Did not find an occurrence of the pattern
  convertToAssets shares chi
in the target expression
  (do let chi ← Except.ok chi
      let assets ← convertToAssets shares chi
      let st ← burnShares st owner caller shares.value
      let st ← usdsTransfer st Addr.vault receiver assets.value
      pure (st, assets)) = Except.ok (st', assets)
```
plus `Frozen.lean:100:8` (same, `ok` branch), and `Frozen.lean:124:8` / `127:8` for
`previewWithdraw assets chi`. Total kernel time for the whole file: **4.38 ms**.

Read the printed goal carefully: after `rw [hchi] at hred` the head is still
`Except.ok chi >>= fun chi => …`. `rw` does not iota-reduce that bind. The `chi` inside
`convertToAssets shares chi` in the goal is the **do-block's bound `chi`**, not the
theorem's free `chi`, so the pattern genuinely does not occur. Every later `rw [hc]`,
`rw [hb]`, `rw [ht]` is dead for the same reason, and the `contradiction` /
`Except.ok.inj` steps are never reached.

### Attempt 1 → 2 — the repair

Attempt 1 was the full repair; it produced exactly one error, at
`Repair.lean:96:31`, `Application type mismatch … Except.noConfusion h'` (metavariables
for `v1`/`v2` not yet assigned at elaboration of the argument). Everything else compiled;
`bind_eq_error`, `withdraw_after_drip` and `redeem_after_drip` were already axiom-clean,
and kernel type checking for the whole file was 8.6 ms. Attempt 2 is attempt 1 with that
single line changed from `exact Except.noConfusion h'` to `contradiction` (`diff` is two
lines, one of them the docstring). Exit **0**, no errors, no warnings:

```
'DefiKernel.Vault.OpusDiagR1.bind_eq_ok' does not depend on any axioms
'DefiKernel.Vault.OpusDiagR1.bind_eq_error' does not depend on any axioms
'DefiKernel.Vault.OpusDiagR1.withdraw_after_drip'      depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.Vault.OpusDiagR1.redeem_after_drip'        depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.Vault.OpusDiagR1.withdraw_success_shares'  depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.Vault.OpusDiagR1.redeem_success_assets'    depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.Vault.OpusDiagR1.withdraw_ceil_shares'     depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.Vault.OpusDiagR1.redeem_floor_assets'      depends on axioms: [propext, Classical.choice, Quot.sound]
```

No `sorryAx`. The three axioms are the ordinary Lean/Mathlib trio introduced by `unfold`
and `rw`; they are the same ones the rest of the module already carries.

## 3. Why the previous revision looked like a kernel bug, and why that was a red herring

The revision that produced `task-379` / `task-446` had `dsimp only [bind, Except.bind]`
in these proofs. That is why `task-446` reports

```
Operations.lean:373:12 / 413:12: Tactic `rewrite` failed: Did not find an occurrence of
  Except.ok ?a >>= ?f
in the target expression
  (match Except.ok st2 with | Except.error err => Except.error err | Except.ok v => pure (v, a)) = …
```

— the `dsimp` had already replaced every `>>=` by its matcher, so `rw [bind_ok]` had
nothing to fire on. Removing the `dsimp` (which the frozen snapshot does) fixed *that*,
but left the binds un-stepped, which is the failure I reproduced in attempt 3. The two
revisions are the two horns of the same dilemma:

- **leave the binds alone** → the scrutinee stays under a binder → `rw` cannot find it;
- **`dsimp only [bind, Except.bind]`** → the binds become matchers over
  `previewWithdraw assets chi` / `convertToAssets shares chi`, i.e. over unevaluated
  `Operations.mul` / `Rounding.divideNat` / `Word.checked` / `uint256Bound` — the exact
  standing condition the prior native Opus diagnosis identified, and the source of
  `(kernel) deep recursion detected` at `Operations.lean:386:8` in both old build logs.

The escape from the dilemma is to step each bind with a lemma whose **scrutinee is a
variable**, so the kernel never has to whnf anything arithmetic.

**Not reproduced here:** I did **not** reproduce `(kernel) deep recursion detected`. It
belongs to the older revision that fed `task-379`/`task-446`, not to the frozen snapshot,
and the frozen `withdraw`/`redeem` projections fail before the kernel is ever reached. I
make no claim that the deep-recursion site is gone from the author's live file.

## 4. Recommended repair — verified, statement-preserving

No statement, premise, ordering, definition or semantics is changed. `withdraw`,
`redeem`, `previewWithdraw`, `convertToAssets` and the two theorem statements are exactly
the frozen ones; arithmetic and source ordering are untouched. Nothing is weakened: the
conclusion is still derived from the hypothesis, not assumed.

### R1 — add one generic `Except` success-inversion lemma (and its error dual)

Proved at fully abstract `{ε α β}` with a **variable** scrutinee, so the kernel checks it
once against nothing but `Except`'s own iota rules. Every later use is a free
instantiation. Verified: `does not depend on any axioms`.

```lean
theorem bind_eq_ok {ε α β} {e : Except ε α} {f : α → Except ε β} {b : β}
    (h : e >>= f = .ok b) : ∃ a, e = .ok a ∧ f a = .ok b := by
  cases e with
  | error x =>
      have h' : (Except.error x : Except ε β) = .ok b := h
      contradiction
  | ok a => exact ⟨a, rfl, h⟩

theorem bind_eq_error {ε α β} {e : Except ε α} {f : α → Except ε β} {x : ε}
    (h : e >>= f = .error x) :
    e = .error x ∨ ∃ a, e = .ok a ∧ f a = .error x := by
  cases e with
  | error y =>
      have h' : (Except.error y : Except ε β) = .error x := h
      exact Or.inl (congrArg Except.error (Except.error.inj h'))
  | ok a => exact Or.inr ⟨a, rfl, h⟩
```

Use `contradiction`, not `exact Except.noConfusion h'` — the latter fails to elaborate
here (attempt 1, `Repair.lean:96:31`). No such lemma exists in the pinned core, Batteries
or Mathlib (checked by grep), so it must be added rather than imported.

### R2 — add `withdraw_after_drip` / `redeem_after_drip`, in the shape of the working `deposit_after_drip`

These are **new** lemmas, not edits; they mirror the existing `deposit_after_drip`
(L187) and `mint_after_drip` (L278), so they fit the file's established shape.

```lean
theorem withdraw_after_drip (st : Ledger) (assets : Word 256) (receiver owner caller : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) :
    withdraw st assets receiver owner caller =
      (previewWithdraw assets chi >>= fun shares =>
        burnShares st owner caller shares.value >>= fun st1 =>
          usdsTransfer st1 .vault receiver assets.value >>= fun st2 =>
            pure (st2, shares)) := by
  unfold withdraw
  rw [hchi]
  exact bind_ok chi _

theorem redeem_after_drip (st : Ledger) (shares : Word 256) (receiver owner caller : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) :
    redeem st shares receiver owner caller =
      (convertToAssets shares chi >>= fun assets =>
        burnShares st owner caller shares.value >>= fun st1 =>
          usdsTransfer st1 .vault receiver assets.value >>= fun st2 =>
            pure (st2, assets)) := by
  unfold redeem
  rw [hchi]
  exact bind_ok chi _
```

This is what discharges the binder-capture problem: the RHS is written out explicitly with
the theorem's own free `chi`, so `previewWithdraw assets chi` and `convertToAssets shares chi`
become genuine free occurrences. `bind_ok` (already in the file, L178) is used exactly as
`deposit_after_drip` uses it.

### R3 — the two projection proofs (statements verbatim frozen)

```lean
theorem withdraw_success_shares (st : Ledger) (assets : Word 256) (receiver owner caller : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) (st' : Ledger) (shares : Word 256)
    (hwd : withdraw st assets receiver owner caller = .ok (st', shares)) :
    previewWithdraw assets chi = .ok shares := by
  rw [withdraw_after_drip st assets receiver owner caller chi hchi] at hwd
  obtain ⟨s, hs, hwd⟩ := bind_eq_ok hwd
  obtain ⟨st1, _hb, hwd⟩ := bind_eq_ok hwd
  obtain ⟨st2, _ht, hwd⟩ := bind_eq_ok hwd
  have hfin : (Except.ok (st2, s) : Except Failure (Ledger × Word 256)) = .ok (st', shares) := hwd
  have hss : s = shares := congrArg Prod.snd (Except.ok.inj hfin)
  rw [hs, hss]

theorem redeem_success_assets (st : Ledger) (shares : Word 256) (receiver owner caller : Addr)
    (chi : Word 192) (hchi : dripChi st = .ok chi) (st' : Ledger) (assets : Word 256)
    (hred : redeem st shares receiver owner caller = .ok (st', assets)) :
    convertToAssets shares chi = .ok assets := by
  rw [redeem_after_drip st shares receiver owner caller chi hchi] at hred
  obtain ⟨a, ha, hred⟩ := bind_eq_ok hred
  obtain ⟨st1, _hb, hred⟩ := bind_eq_ok hred
  obtain ⟨st2, _ht, hred⟩ := bind_eq_ok hred
  have hfin : (Except.ok (st2, a) : Except Failure (Ledger × Word 256)) = .ok (st', assets) := hred
  have haa : a = assets := congrArg Prod.snd (Except.ok.inj hfin)
  rw [ha, haa]
```

Each `bind_eq_ok` peels one bind and hands back the scrutinee's `.ok` witness *and* the
continuation equation, so the error branches disappear entirely — no `cases`, no
`contradiction` on a stuck `Except`, no `dsimp`, no `change`. The `hfin` `have` is a
one-step defeq coercion of `pure (st2, s)` to `Except.ok (st2, s)`; state it explicitly
rather than relying on `Except.ok.inj` to unfold `pure` by itself.

`withdraw_ceil_shares` and `redeem_floor_assets` need **no change**; both were compiled
unmodified on top of the repaired projections in attempt 2 and passed.

### R4 — standing rule, updated

The prior diagnosis's R4 still holds, and this diagnosis sharpens it. Never let
`bind` / `Except.bind` be unfolded (by `simp`, `simp only`, `dsimp` or `dsimp only`) while
any scrutinee is still an unevaluated `convertToShares` / `convertToAssets` /
`previewMint` / `previewWithdraw` / `Operations.*` / `Word.checked` call. For **inverting
a success hypothesis**, prefer `bind_eq_ok` over the `cases … / rw / contradiction`
pattern: it is shorter, it is immune to binder capture, and it moves zero work to the
kernel. `deposit_success_shares` (L245) currently does the same job with `cases` + two
`change` steps; it works, but `bind_eq_ok` would make it uniform and removes the `change`
steps, which are brittle against any future edit of the `deposit` do-block.

### R5 — do not raise limits

`maxRecDepth := 2000000` (~13 GiB RSS) is treating a symptom, and the frozen snapshot's
actual failure is not even a recursion-depth failure. No `maxRecDepth`, `maxHeartbeats`,
`opaque` or `@[irreducible]` change is needed or recommended. The repaired chain runs at
default `maxRecDepth` inside a 10000-heartbeat budget with 9.55 ms of kernel time.

## 5. Exactly what was checked, and what was not

**Checked** (attempt 2, exit 0, `#print axioms` captured, `work/attempt2/stdout.txt`):

- `bind_eq_ok`, `bind_eq_error` — no axioms.
- `withdraw_after_drip`, `redeem_after_drip` — new statements, axiom-clean.
- `withdraw_success_shares`, `redeem_success_assets` — **statements byte-identical to the
  frozen snapshot**, proved by R3, axiom-clean.
- `withdraw_ceil_shares`, `redeem_floor_assets` — frozen statements, frozen proof scripts,
  unchanged, still passing on top of the repaired projections.

**Checked as failing** (attempt 3, exit 1, `work/attempt3/stdout.txt`): the frozen
snapshot's own `withdraw_success_shares` / `redeem_success_assets` scripts, embedded
byte-for-byte, fail with four `rewrite failed: Did not find an occurrence` errors.

**Not checked — do not read this report as covering any of it:**

- Whether `DefiKernel/Vault/Operations.lean` compiles as a whole module. I ran no module
  build and no `lake build`.
- The author's **live** file (`0be2aaa7…`), which had already moved past the frozen
  snapshot before I started. Names and line numbers in §4 refer to the frozen
  `73b7cc49…` and may have shifted.
- `mint_success_assets` (snapshot L306–334). It uses `dsimp [bind, Except.bind] at hmint`
  at L317 and L324. Those calls are *probably* safe, because `rw [hp]` has already put the
  `previewMint` scrutinee into `.ok a` form before the `dsimp` fires — this is the
  invariant the passing `Conversion.lean` proofs satisfy. But it is a full `dsimp` with
  bind unfolding and I did not run it. If it ever misbehaves, R1+R3 applies verbatim
  except for `mint`'s trailing raw `match` on `mintAfterGuard`, which `bind_eq_ok` does
  **not** cover and would need its own step.
- `Adapter.lean`, `Examples.lean`, and everything else in the snapshot.
- The generic output-to-conversion / supply / burn lemmas the author reports adding: not
  present in the frozen snapshot I was given, so not inspected and not evaluated.
- `(kernel) deep recursion detected` — not reproduced, see §3.

## 6. Limitations

- Three bounded attempts, as instructed. Real `timeout --kill-after=5s 45s`; none came near
  the wall clock (1.20 s / 1.30 s / 1.00 s). No run was, or should be read as, a claim
  that any goal is false.
- Diagnostics were compiled against the **author's** `.olean` cache via `LEAN_PATH`
  (read-only, direct `lean` binary, no `lake`, no build, no write to author `.lake`). Per
  the brief these successes are **debugging context only, not independent proof evidence**.
  The imports I bound are `DefiKernel.Vault.Conversion` and its transitive closure;
  `Conversion.olean` sha256 `6d4a3fab…` and `Types.olean` sha256 `9992daa7…` were
  unchanged before and after all three runs, and their sources were byte-identical to the
  snapshot, so for these two the olean/source correspondence is as tight as it can be
  without a rebuild. I did **not** import `Operations.olean`; its source has moved.
- `Ledger`, `usdsTransfer`, `burnShares`, `dripChi`, `withdraw`, `redeem`, `bind_ok`,
  `bind_error` in my files are byte-copies of the frozen text but are *different
  constants* in a reviewer namespace. The repair does not depend on their bodies — it only
  depends on `withdraw`/`redeem` being the frozen bind chains — but a re-check in the
  author's own namespace, in the real module, is still required.
- Toolchain: `v4.33.0-rc2` per `lean-toolchain`. The `lean` on `PATH` is 4.33.1; using it
  would have failed on olean version. Anyone reproducing must use the pinned binary.
- Attempt 1's single error is preserved, not overwritten; its `sorryAx` lines are the
  consequence of that one failed elaboration and are superseded by attempt 2.

## 7. Reviewer status

Adviser only. No production file patched, no author file or `.lake` touched, no commit, no
push, no subagent, no Foreman. **Implementation acceptance: not given, not in scope.**
Full frozen-implementation Opus review of P17 remains pending; this covers one bug.
