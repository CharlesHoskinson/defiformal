# The council report — Claim 1 is false, and the obstruction is cyclicity

**Three adversarial referees were run against `CHARACTERISATION.md`. Two have
reported. One refuted the closure induction; the other refuted Claim 1 outright,
and it is right. The theorem's premise does not hold for the actual basis. A
corrected obstruction survives both, and it is a different property.**

---

## 1. Claim 1 is false — `Post` is authority-parameterised

`CHARACTERISATION.md` §2 asserts "every basis family is permission-free" and
tabulates `Led`, `Prop`, index accrual, `Cmp`, `liquidate`, trading function, rate
curve. **`Post` — one of the four primitives — is not in the table.**

And it is precisely the one that fails. `BASIS.md` §2 P4:

> `post_X : N × X × X → X` for `X ∈ {Σ, Φ, T}`, **parameterised by an authority
> `n ∈ N`** … `post_X(n, x, x′)` is **defined iff `n` is the declared writer**.

That is a guard reading an identity — the exact negation of permission-freedom.
So the induction has **no base case for a quarter of the generators**, and the
theorem fails at its first premise.

**This is my error, not a subtlety.** I wrote a universal quantification over "every
basis family" from a table I built by reading, and omitted a primitive. It is the
`asserted, not measured` artifact class, committed in the document that names that
class.

## 2. The two referees disagree, and the disagreement is productive

**Referee B:** the mandate **is** generated. `Φ` is "finite, written by the
protocol", so a role assignment `R : N ⇀ Φ` is a legal carrier; `setIsAllocator` is
`post_Φ(owner, ·, ·)`; the gate is `P3`'s equality on `Φ`. `BASIS.md` §4 already
performs this reduction ("F2 drops to `Post(Φ)` for the status machine"), and
`L4/common.qnt:215-217`'s `applyDelegate`/`applyExecute`/`applyRevoke` is cited as
a P4 instantiation.

**Referee C:** role maps are `N ⇀ B`, no primitive writes `B`, so they are not legal
carriers at all and permission-freedom is ill-typed rather than merely false.

**Adjudication: Referee B's reduction is the better reading, and it fails anyway —
on `P4.2`.**

## 3. The corrected obstruction: cyclicity — REFUTED, see `sigma/RETRACTION.md`

> **This section is wrong and is kept for the record.** A fourth referee refuted it
> on every line. Acyclicity of `R_Φ` is *descriptive*, not definitional — P4.3 says
> "**When** `R_X` is acyclic…" and P4.4 admits `(x,x) ∈ R_X`, which a DAG cannot
> have. The corpus contains role cycles already (`L6/usdc.qnt:105-125`,
> `blacklist`/`unblacklist` on `restricted : str ⇀ bool`). And a monotone encoding
> with `grants, revokes : N ⇀ T` reproduces a cyclic role from acyclic `post_T`
> writes. The table below also cites two *different* principals, so it witnesses an
> antichain rather than a cycle.

## 3. The corrected obstruction: cyclicity (REFUTED)

`BASIS.md` P4.2, *R-respect*:

> Every write lies in `R_X`; `R_T` is `<` (clocks advance), **`R_Φ` is the acyclic
> status DAG**, `R_Σ` is `Σ_{>0} × Σ_{>0}` (free).

A delegated mandate requires a role that can be **granted, revoked, and granted
again**. That is a cycle in the role coordinate. `R_Φ` is acyclic by P4.2, so
`post_Φ` cannot express revocation-then-regrant. `R_Σ` is free, but `Σ` is "a ratio
against a declared unit" — a scalar, not a per-principal assignment. `R_T` is `<`.

**No `post_X` expresses role revocation.**

### And the cycle is machine-checked, from this session's own specs

| spec | grant | revoke |
|---|---|---|
| `huma` | `wit_lenderGranted` `[violation]` | `wit_lenderRevoked` `[violation]` |
| `polymarket` | `wit_operatorGranted` `[violation]` | `wit_operatorRenounced` `[violation]` |
| `polymarket` | `wit_adminGranted` `[violation]` | `wit_adminRemoved` `[violation]` |

Both directions reachable, in three independent role hierarchies. The contracts
agree: `TrancheVault.sol:192/:223` `addApprovedLender`/`removeApprovedLender`,
`Auth.sol:49/:68` `addAdmin`/`removeAdmin`, `:59/:79`
`addOperator`/`removeOperator`.

**Why this survives both referees.** It does not need "every basis family is
permission-free" (false). It does not need role maps to be illegal carriers
(Referee B's counter). It uses `BASIS.md`'s own P4.2 against `BASIS.md`'s own
reduction, and the witness is machine-checked rather than argued.

## 4. What this does to the Lean development

`lean/Defialgebra/Permission.lean` proves a **true** theorem — permission-freedom
is preserved by the closure, so a permission-dependent transition is outside it,
sorry-free and axiom-free. **Its premise does not hold for the actual basis**,
because `Post` is not permission-free. The development therefore does not currently
support the conclusion it was written for.

It is kept, unchanged and correctly scoped: it is the right theorem about a
factored state, and it is reusable if a permission-free sub-basis is ever isolated.
The conclusion it was cited for is withdrawn.

**The cyclicity argument is the one that should be formalised next**, and it is a
different shape: a reachability statement about `R_Φ`, not a factorisation.

## 5. Status

- `CHARACTERISATION.md` §2 Claim 1: **REFUTED**. §5's Theorem: **premise fails**.
- `mandate = Perm ⋈ Led.move`: **withdrawn as stated.** The basis is not "incomplete
  by one primitive"; `Post` already carries an authority parameter.
- The genuine gap is between `BASIS.md` and the **corpus**: P4 models the declared
  writer and the 57 specs delete it (deletion class 11, 0 of 17 gate actions). The
  743/820 generation figure was measured against specs missing what P4 carries.
- **Open, and the current best candidate:** the mandate is outside the closure
  because role revocation is a cycle and `R_Φ` is acyclic.
- Third referee (a Yearn-based counterexample to generation) still running.

Nothing here is recorded as settled. Two of three referees reported; both refuted
something; one refuted a claim I had already committed.
