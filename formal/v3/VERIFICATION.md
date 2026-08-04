# VERIFICATION — machine-checking `paper/atlas.tex`

Date: 2026-08-04. Scope: `formal/v3/` (measurements) and `lean/` (proofs).
Rule observed: nothing outside `lean/` and `formal/v3/` was modified. Nothing was tuned to make a
claim pass; every witness below is reported as found.

Harness: `formal/v3/lib.mjs` re-exports the shipped model from `formal/v2/tables.mjs` but uses it
**as membership predicates only** — `inR`, `inW`, `inH`, `grounded` — never as operators, matching
the paper's own §"Model classes, not operators". The one place an operator is used is
`prop:joinmeet`, which is itself an operator claim.

**Reproducibility note that applies to every sampled figure.** The v2 probes
(`audit/probe4.mjs`) draw pools with `Math.random()` and no seed, so the paper's exact counts
are not reproducible by construction. v3 uses a seeded mulberry32 RNG and reports the seed, and
where feasible replaces sampling with exhaustive enumeration.

---

## Summary table

| Claim | Verdict |
|---|---|
| `meas:closureprops` | **VERIFIED (qualitatively); sampled counts NOT reproducible** |
| `meas:latticeconf` | **VERIFIED** (0 union violations robust; 51,917 is seed-specific, ±3%) |
| `prop:joinmeet` | **REFUTED** — meet is not `Δ^ω(A ∩ B)`; explicit minimal witness |
| `cor:oplusclosed` | **VERIFIED**, and the failure attribution in the paper is **partly wrong** |
| `cor:ourconvex` | **VERIFIED**; the "15 arcs" figure holds only for the raw parse, not for `L*` |
| `lem:polarity` + `thm:closure` | see Lean section |
| `cor:lattice` | see Lean section |
| `thm:convex` | **VERIFIED** in Lean and exhaustively in v3 |
| `thm:excomp` | **VERIFIED** in Lean and on 1,464,616 closed pairs in v3 |

---

## 5. `meas:closureprops` — VERIFIED qualitatively, counts not reproducible

> "{Op,Tp} and {Ex,Op} both satisfy 𝓡, while their intersection {Op} does not (L1a is
> unsatisfied). Sampling 194,775 pairs from 𝓡: 1,923 fail intersection-closure, 0 fail
> union-closure."

```
$ cd /root/DefiElements/formal/v3 && node m1-closureprops.mjs
witness  {Op,Tp} in R : true
witness  {Ex,Op} in R : true
witness  {Op}    in R : false  open terms: [["L1a","Ex|Tp|At|Oa|Sv|Cl|Cp|St|Wg"]]

EXHAUSTIVE over R-members of size<=3: |pool| = 18966, pairs (i<=j) = 179864061
  union-closure failures        : 0
  intersection-closure failures : 68058  (0.038%)

SAMPLED (seed=1, |pool|=3000, v2 probe4 pairing scheme): pairs 175230
  union-closure failures        : 0
  intersection-closure failures : 3342
SAMPLED (seed=2, ...): pairs 175230  union 0  intersection 2955
SAMPLED (seed=3, ...): pairs 175230  union 0  intersection 2809

ADVERSARIAL (density 0.35, seed 77): pairs 155220, union failures 0, inter failures 19013
  first intersection witness: {As,Au,Aw,Ct,Cv,Em,Ft,Fz,Li,Oa,Op,Pf,Ps,Rd,Sh,Sl,Tg,Up,Wg,Wq,Xf}
                            ^ {Ad,As,At,Au,Aw,Cd,Ct,Em,Ex,In,Ix,Op,Pf,Rs,Sr,Tg,Up,Wq}
                            = {As,Au,Aw,Ct,Em,Op,Pf,Tg,Up,Wq}
```

* The named witness is **exactly right**, including the attribution to `L1a`.
* Union-closure: **0 failures** across 179,864,061 exhaustively enumerated pairs plus 680,910
  sampled ones. This is now also a theorem (Lean `Polarity.lean`), so the measurement is
  corroboration, not evidence.
* The two sampled numbers do **not** reproduce. The v2 pairing scheme (pool 3000, window 60)
  produces **175,230** pairs, not 194,775 — and 194,775 is the pair count the paper attributes to
  a *different* measurement (`meas:latticeconf`). The intersection-failure count is
  seed-dependent (2,809–3,342 here versus 1,923 reported), and rises to 19,013/155,220 at higher
  sampling density: it is a property of the sampler, not of 𝓡. **Recommendation:** replace both
  figures with the exhaustive ones (0 / 179,864,061 and 68,058 / 179,864,061 at size ≤ 3), which
  are deterministic.

## 6. `meas:latticeconf` — VERIFIED

> "Over 175,230 pairs from 𝓡 ∩ 𝓦 there are 0 union-closure violations. Meet is not
> intersection: 51,917 pairs have X ∩ Y ∉ 𝓡 ∩ 𝓦."

```
$ node m2-latticeconf.mjs
empty in R n W : true
TOP   in R n W : true
TOP   admissible (i.e. also in H) : false

seed=1  |pool|=3000  pairs=175230   union 0   intersection 50223   [paper: 0 / 51,917]
seed=2  |pool|=3000  pairs=175230   union 0   intersection 50611
seed=3  |pool|=3000  pairs=175230   union 0   intersection 50276

EXHAUSTIVE over (R n W)-members of size<=3: |pool|=8023, pairs=32188276
  union-closure violations : 0
  intersection violations  : 396437
```

The pair count **175,230 reproduces exactly** (it is determined by the scheme, not the seed), and
0 union violations is robust across seeds and confirmed exhaustively. 51,917 is within ~3% of the
seeded reruns — consistent, but it is a sample statistic reported as if exact. The hypotheses of
`cor:lattice` (∅ ∈ 𝓡∩𝓦, ⊤ ∈ 𝓡∩𝓦) both check out; note ⊤ is *not* admissible, which is
`cor:admnotlattice` in miniature.

## 7. `prop:joinmeet` — **REFUTED**

> "In 𝓡 ∩ 𝓦 the join of A and B is A ∪ B and the meet is Δ^ω(A ∩ B)."

The join half is correct. The meet half is false, and fails on 4-element sets.

```
$ node m3-joinmeet.mjs
{Cp,Fl}  in R: true  in W: true  in RnW: true
{Cl,Fl}  in R: true  in W: true  in RnW: true
{Fl}     in R: true  in W: false in RnW: false   open=[] unwarranted=["Fl"]
  A n B = {Fl};  Delta^w(A n B) = {};  in RnW: true

tested 4000 pairs (|A n B| <= 18, true meet computed exhaustively over subsets)
  Delta^w(A n B) NOT in R n W          : 16
  Delta^w(A n B) != true meet          : 16
  Delta^w(A n B) == true meet          : 3984

minimal counterexample search over R n W members of size <= 4:
  A={Cp,Ix,Op,Sh} B={Ix,Op,Sh,Wg} AnB={Ix,Op,Sh} Delta^w={Ix,Op,Sh} trueMeet={Ix,Sh} Delta^w in RnW=false
  A={Cp,Ix,Op,Sh} B={Ix,Op,Sh,St} AnB={Ix,Op,Sh} Delta^w={Ix,Op,Sh} trueMeet={Ix,Sh} Delta^w in RnW=false
  A={Cp,Ix,Op,Sh} B={Cl,Ix,Op,Sh} AnB={Ix,Op,Sh} Delta^w={Ix,Op,Sh} trueMeet={Ix,Sh} Delta^w in RnW=false
```

**Witness.** `A = {Cp,Ix,Op,Sh}` and `B = {Ix,Op,Sh,Wg}` are both in 𝓡 ∩ 𝓦.
`A ∩ B = {Ix,Op,Sh}`. `Δ` removes nothing from it (every element still has a consumer present),
so `Δ^ω(A ∩ B) = {Ix,Op,Sh}` — but that set violates `L1a`: `Op` needs a price element, whose
only witnesses were `Cp` in A and `Wg` in B, and neither survives the intersection.
So `Δ^ω(A ∩ B) ∉ 𝓡 ∩ 𝓦` and cannot be the meet. The true meet, computed as the largest member
of 𝓡 ∩ 𝓦 below `A ∩ B` (well defined by union-closure), is `{Ix,Sh}`.

**This is the paper's own `prop:noinvariance` biting.** That proposition proves Δ does not preserve
𝓡; `prop:joinmeet` then asserts a formula whose value is `Δ^ω` of something, and the two are
inconsistent whenever Δ has nothing to remove but the intersection has already lost a disjunctive
witness. The paper's stated witness `{Cp,Fl}/{Cl,Fl}` happens to be a case where Δ *does* fire
(`Δ^ω({Fl}) = ∅`, and ∅ is the meet), which is why the error was not visible.

**Correct statement.** The meet exists — 𝓡 ∩ 𝓦 is a complete lattice by `cor:lattice` — and is
`A ⊓ B = ⋃ { C ∈ 𝓡 ∩ 𝓦 : C ⊆ A ∩ B }`, the union of all common lower bounds, exactly as
`cor:lattice`'s own proof says. `Δ^ω(A ∩ B)` is an *upper* estimate of it that is sometimes not
even a member. The clause "and the meet is Δ^ω(A ∩ B)" should be struck.

## 8. `cor:oplusclosed` — VERIFIED, but the attribution around it is partly wrong

> "𝓡 ∩ 𝓦 is closed under ⊕. Composition therefore fails to preserve admissibility only once
> prohibitions are imposed."

```
$ node m4-oplus.mjs
(+)-closure of R n W: 96720 pairs, 0 failures

admissible pool: 2500
pairs 96720; union not admissible: 9883 (10.2%)
  attributable to REQUIREMENTS (closure clauses) : 0
  attributable to WARRANTS                       : 0
  attributable to GROUNDING                      : 0
  attributable to PROHIBITIONS (bansCond)        : 9883
  prohibition rows fired (with multiplicity):
      X21      5679
      X2       2747
      X19*     1188
      X18      1118
  failures where that row was the SOLE cause:
      X21      4955
      X2       2100
      X19*     1032
      X18      976
```

⊕-closure of 𝓡 ∩ 𝓦 holds (0 / 96,720), and it is a consequence of union-closure, so it is a
restatement rather than an independent fact. The half of the sentence that matters is the
attribution, and here is the answer to *which condition produces the failures*:

**No failure comes from a requirement, a warrant, or a grounding clause. Every one of the 9,883
comes from `bansCond`. But `bansCond` is not the prohibition clutter.** Only 4 of its 5
hand-written rows ever fire, and they are not all prohibitions:

```
  X11a*   Uc & !(Aw & At)            => Uc -> Aw ; Uc -> At               DUAL-HORN (a requirement written negatively)
  X19*    Aw & Xf & !(At|Fz|Xm)      => !Aw v !Xf v At v Fz v Xm          MIXED, 2 negative literals — neither Horn nor dual-Horn
  X2      Fl & (Cp|Cl) & (Pl|Cd|Im)  => !Fl v !c v !d for each c,d        PURELY NEGATIVE (Horn) — a genuine prohibition
  X18     Oa & Li & !(Ex|Tp)         => !Oa v !Li v Ex v Tp               MIXED, 2 negative literals — neither Horn nor dual-Horn
  X21     Fl & (Xf|Rl|Of)            => !Fl v !Xf ; !Fl v !Rl ; !Fl v !Of PURELY NEGATIVE (Horn) — a genuine prohibition

per-row union-closure failures, that row alone, 400-member pools:
   X11a*        0 / 79800        <- dual-Horn, union-closed, as predicted by lem:polarity
   X19*      1008 / 79800
   X2        1206 / 79800
   X18       1334 / 79800
   X21      13505 / 79800
```

Consequences for the paper:

1. **The clutter is not doing the work.** Of the 20 recorded prohibition rows, only `X2` projects
   to a positive element set (`HAZ_PROJ` has exactly one member — this confirms `meas:clutter`).
   `X21`, `X19*`, `X18`, `X11a*` are hand-written predicates in the model, not table rows.
   `X2` fires in at most **2,747 of 9,883 failures (27.8%)**, and is the sole cause in 2,100
   (21.2%). So **at least 72% of composition failures are not attributable to the recorded
   prohibition table at all** — they come from hand-written rows, with `X21` alone accounting for
   5,679 (57%). The standing attribution "the failures come from the prohibition clutter" is
   wrong by a factor of ~3.6.
2. **23% of the failures are not prohibitions at all.** `X19*` and `X18` are mixed-polarity
   clauses with two negative literals each. They are neither Horn nor dual-Horn, so they fall
   outside `lem:polarity`'s taxonomy entirely, and they break union-closure for a reason the paper
   never states. `cor:admnotlattice`'s "prohibitions are the sole obstruction" is false as written
   for the shipped model: the sole obstruction is *non-dual-Horn clauses*, of which the
   prohibitions are one species and `X19*`/`X18` another.
3. `X11a*` is a requirement in negative clothing and provably cannot break anything — 0 failures,
   as `lem:polarity` predicts. That is a small positive confirmation of the polarity lemma on real
   data.

## 9. `cor:ourconvex` — VERIFIED (with one number off)

> "D has 15 arcs and 58 strongly connected components, none non-trivial, so it is acyclic; and
> Cn coincides with reachability in D (checked on 21,712 seeds)."

```
$ node m5-convex.mjs
LSTAR (paper's L*): definite (singleton-term) arcs = 13, distinct = 12
   Pl->Ct Im->Ct Cd->Ct Pf->Ct Uc->Aw Uc->At Py->Ep Py->Rd Of->Xm Of->Xf Rl->Au Gs->Au
PARSED_NEW (raw data.ts law strings): definite arcs = 16, distinct = 15
   Pl->Ct Im->Ct Cd->Ct Pf->Ct Op->Ct Uc->Aw Uc->At Pf->Ex Pf->Li Py->Ep Py->Rd Of->Xm Of->Xf Rl->Au Gs->Au

--- LSTAR definite digraph ---
vertices 58; arcs 13; SCCs 58; non-trivial SCCs 0; self-loops 0
ACYCLIC: true
Cn == reachability on all 32567 seeds of size <= 3: mismatches 0
Cn(A u B) == Cn(A) u Cn(B) on 30856 split seeds: failures 0
anti-exchange over 1700 closed sets x 58^2 pairs (5169336 tests): violations 0
thm:excomp  ex(A u B) == max(ex A u ex B) over 1464616 closed pairs: failures 0
elements whose principal closure is themselves (Cn({e}) = {e}): 49 / 58

--- PARSED_NEW definite digraph ---
vertices 58; arcs 16; SCCs 58; non-trivial SCCs 0; self-loops 0
ACYCLIC: true
Cn == reachability on all 32567 seeds of size <= 3: mismatches 0
Cn(A u B) == Cn(A) u Cn(B) on 30856 split seeds: failures 0
anti-exchange over 1697 closed sets x 58^2 pairs (5142758 tests): violations 0
thm:excomp  ex(A u B) == max(ex A u ex B) over 1464616 closed pairs: failures 0
elements whose principal closure is themselves (Cn({e}) = {e}): 48 / 58
```

* **Acyclicity: verified**, 58 SCCs, none non-trivial, no self-loops — under *both* extractions.
* **`Cn` = reachability: verified exhaustively** on all 32,567 seeds of size ≤ 3 (the paper's
  21,712 is a subset of this), 0 mismatches.
* **Union-stability verified** (0 / 30,856), which is the `lem:cm` hypothesis of `thm:convex`.
* **Anti-exchange verified** by direct exhaustive test over 5.1M configurations, independently of
  the acyclicity route.
* **"15 arcs" is the wrong table.** The paper's own corrected law system `L*` yields **13 arcs
  (12 distinct)**. 15 distinct arcs is what the *raw* `data.ts` law strings give (`PARSED_NEW`),
  which additionally contain `Op→Ct`, `Pf→Ex`, `Pf→Li`. Nothing downstream changes — both
  digraphs are acyclic and give the same verdicts — but the figure cited should say which
  extraction it refers to.
* **`cor:ex`'s honesty caveat is if anything understated**: 49 of 58 elements have
  `Cn({e}) = {e}`, so the canonical form is the identity on 84% of singletons.

---

## Files

* `formal/v3/lib.mjs` — seeded harness, membership predicates only
* `formal/v3/m1-closureprops.mjs`, `m1.out` — `meas:closureprops`
* `formal/v3/m2-latticeconf.mjs`, `m2.out` — `meas:latticeconf`, `cor:lattice` hypotheses
* `formal/v3/m3-joinmeet.mjs`, `m3.out` — `prop:joinmeet` (refutation)
* `formal/v3/m4-oplus.mjs`, `m4.out` — `cor:oplusclosed` + failure attribution
* `formal/v3/m5-convex.mjs`, `m5.out` — `cor:ourconvex`, `thm:convex`, `thm:excomp`
* `formal/v3/LEAN-REPORT.md` — full Lean detail (axioms, per-theorem content classification)
