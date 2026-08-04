# DeFi Atlas Formal-Model Findings

Status: model checking run. Questions 10-14 answered below with the commands
that produced each answer.

Toolchain: quint 0.32.0 (nix store), bundled Apalache 0.56.1, TLC via
`--backend=tlc`, OpenJDK 21.0.11, node v24.18.0.

Two independent evidence lines are used throughout and they are kept separate:

1. **Quint / Apalache / TLC** over `formal/atlas.qnt` — symbolic and randomised
   state-machine checking.
2. **`formal/analyze.mjs`, `formal/probe.mjs`, `formal/completions.mjs`** — an
   independent JavaScript analyzer that re-parses `viz/src/data.ts` directly and
   does *not* import `viz/src/laws.ts`. It exists so that a Quint result and a
   JS result can disagree.

Where they agree it is stated; where only one of them could reach a result that
is stated too.

---

## Intake Findings: Source and Engine Defects

These findings come directly from the current source files. They predate the
Quint model. Re-confirmed by `node --experimental-strip-types analyze.mjs`:

```
{"elementRows":59,"mechanismRows":58,"limitRows":1,"lawRows":29,
 "executableLawRows":25,"internalLawTerms":25,"externalLawTerms":52,
 "mixedLawTerms":5,"hazardRows":20,"hazardFamilies":19,
 "projectedHazardRows":3,"protocolRows":12,"deadProtocolRows":3}
```

### The element count mixes mechanisms with a declared non-element

`ELEMENTS` contains 59 rows. Only 58 rows are mechanisms. The `CSM` row has
status `limit` and states that it is not an element.

### The hazard count has two valid interpretations

`HAZARDS` contains 20 rows. The identifiers represent 19 numbered families
because `X11` has `X11a` and `X11b` variants.

### The protocol death count is three

`PROTOCOLS` contains 12 protocols. Only Terra, Mango, and Euler have
`dead: true`. The source does not identify a fourth dead protocol.

### The TypeScript parser activates only 25 of 29 laws

Confirmed: `unsupportedLaws` =
`[{"id":"L14","subject":"illiquid backing"},{"id":"L23","subject":"Sq"},
{"id":"L25","subject":"wrapped cross-domain collateral"},{"id":"L26","subject":"Aw + Xf"}]`

Also confirmed: **52 of the 77 law terms are external** (no element can satisfy
them) and 5 more are mixed. Only **25 law terms are element-expressible**. The
constraint system is three-quarters prose.

### The hazard projection has a polarity defect

`negativeProjectedHazards` =
`[{"id":"X11a","elements":["Uc","Aw","At"],"combo":"Uc with no Aw, At, collateral or reputation"},
{"id":"X19","elements":["Xf","Aw"],"combo":"Restricted claim bridged via Xf into a representation with no destination-side Aw"}]`

Only `X2`, `X11a`, and `X19` pass the two-symbol threshold, and two of those
three have reversed polarity. The current `armedHazards` result is therefore not
a sound hazard predicate. The Quint model keeps the membership projection but
labels it, and adds `x11aCoreFree` with the source polarity restored.

**New consequence found by this run** (see Q14): under the reversed projection,
`Uc` has *zero* hazard-free legal completion. The element is unrealizable. That
is not a fact about undercollateralized credit; it is the polarity bug made
visible as an emptiness result.

---

## Model Scope

`formal/atlas.qnt`, 58 elements, 29 laws (25 fireable), 20 hazard rows
(3 membership-projectable), 12 protocols.

Machines:

- `rawAssembly(UNIVERSE)` — add one element at a time, no constraint.
- `legalAssembly(UNIVERSE)` — add one element at a time, and **every prefix must
  satisfy `satisfiesClosure` and `hazardFree`**. `legalFull` instantiates it over
  all 58 elements.
- `reflexiveLoop(HAS_EXOGENOUS_CAPITAL)` — peg phase / supply / backing.

Safety properties defined **independently of the 20 written hazard rules**:

- `stratumSafety` = `stratumMonotone` — no fired law may satisfy a term only
  through an element whose hand-assigned stratum is *deeper* than the subject's.
- `atomicScopeSafety` = `atomicScopeConsistent` — `Fl` (atomic flash liquidity,
  atom = `AsyncImpossible`) may not co-occur with any G12 cross-domain element.
- `machineCheckableSafety` = `requirementsFullyExpressible` — every fired law's
  requirements are stateable in the element vocabulary.

None of these three is derived from `HAZARDS`. That is the point: a reachable
state that is closed, passes every evaluable written hazard, and still violates
one of these is a hazard nobody wrote down.

### Baseline

```
$ quint test --main=atlasTest --match="test.*" atlas_test.qnt
    ok testVocabularyHasFiftyEightMechanisms passed 1 test(s)
    ok testEveryMechanismHasAttributes passed 1 test(s)
    ok testEmptyProtocolIsClosed passed 1 test(s)
    ok testSourceRelationCounts passed 1 test(s)
    ok testProtocolClosureMatchesCorpus passed 1 test(s)
    ok testProtocolViolationIds passed 1 test(s)
    ok testHazardProjectionExposesReversedPolarity passed 1 test(s)
    ok testMachineCheckabilityIsStricterThanClosure passed 1 test(s)
  8 passing (365ms)
```

(quint 0.32.0 does not auto-discover `run` definitions without `--match`.)

---

## Protocol Closure Results

Quint and the independent analyzer agree exactly. Nine of twelve close; three do
not, and the three that fail are **not** the three that died.

| protocol | closes | violated law | missing term |
|---|---|---|---|
| aave, uniswapv3, maker, liquity, gmx, cow | yes | — | — |
| lido | **no** | L15 | `Tg \| bounded emergency process` |
| cctp | **no** | L19 | `(Bs\|Sl)` |
| centrifuge | **no** | L6 | `(Sv \| mechanical trigger)` |
| terra (dead) | no | L1 | `Ct`, `(Li\|Ad\|Sl\|Bs)` |
| mango (dead) | no | L2, L4 | `(Sh\|Ix)`, `(Ad\|Sl\|Bs)` |
| euler (dead) | no | L15 | `Tg \| bounded emergency process` |

Q3 in QUESTIONS.md asked whether Euler's failure is narrative error or element
error. The checker says Euler fails **for exactly the same reason Lido fails**:
`Up` without `Tg`, i.e. a mutable proxy with no timelock. Both are live-corpus
facts, and one of the two protocols is alive. So L15 as written is either too
strong or its `bounded emergency process` alternative is real and unmodelled —
it cannot be a death predicate, because it does not discriminate.

---

## Question 10: Stratum as Graph Rank

**Answer: no. Stratum is not topological rank, and it is not close.**

Method: build the requirement relation *subject to every alternative of every
element-expressible term*, then compute rank two ways.
`choiceRank(x) = 1 + min over alternatives` (best-case substitution) and
`strictRank(x) = 1 + max over alternatives` (worst case). Elements with no
outgoing requirement edge get rank 0.

```
$ node --experimental-strip-types analyze.mjs      # ranks section
choiceMatch 3   strictMatch 3   hasCycle false
```

**3 of 58 elements agree. 55 disagree.** Full disagreement list
(`symbol hand/choice/strict`):

```
Cp 1/0/0   Wg 1/0/0   St 1/0/0   Cl 1/0/0   Pm 1/0/0   Ob 1/0/0   Rf 1/0/0
Ba 2/0/0   In 4/0/0   Ag 1/0/0   Fl 1/0/0   Pl 3/1/1   Im 3/1/1   Cd 3/1/1
Uc 3/1/2   Ft 3/0/0   Ct 3/0/0   Li 3/0/0   Ad 3/0/0   Sl 3/0/0   Bs 3/0/0
Pf 3/1/1   Op 3/1/1   Tr 3/1/1   Cv 3/0/0   Py 3/1/1   Sv 3/0/0   Dp 3/0/0
Ex 2/0/0   Tp 2/0/0   Oa 2/0/0   At 2/0/0   Sr 2/0/0   Ep 2/0/0   Wq 2/0/0
Em 2/0/0   Fd 2/0/0   Tg 4/0/0   Up 4/1/1   Gp 4/0/0   Au 4/0/0   Gs 3/1/1
Xm 4/0/0   Xf 4/1/1   Rl 4/1/1   Of 4/2/2   Rd 3/0/0   Ps 3/0/0   As 3/0/0
Aw 2/0/0   Sb 2/0/0   Sd 2/0/0   Fz 2/0/0   Rs 4/0/0   Vl 3/0/0
```

The three that agree (`Sh`, `Ix`, `Rb`) agree only because both values are 0.

The structural reason: derived rank has range **0-2** while hand stratum has
range **0-4**. 45 of 58 elements have no outgoing element-expressible
requirement at all, so their rank is 0 by default — including `Tg`, `Gp`, `Au`,
`Xm`, `Rs` at hand-stratum 4 and the entire G06 liquidation family at
hand-stratum 3. The law graph simply does not carry the depth information that
the stratum axis claims to encode. Those 45 elements have rank 0 not because
they are primitive but because *nobody wrote a law with them as subject*.

**One genuine inversion exists**, and it is the only one in the corpus:

```
deeperDependencies: [{"law":"L21","subject":"Gs","subjectStratum":3,
                      "required":"Au","requiredStratum":4}]
```

`L21: Gs -> Au + metering + fee settlement`. Sponsored-fee liability (S3)
requires delegated execution scope (S4). Either `Gs` belongs at S4, or `Au`
belongs at S3, or the axis is not a dependency order. This is the concrete,
actionable atlas defect from Q10, and it was independently rediscovered by model
checking as the sole minimal `stratumSafety` counterexample (Q12).

**Verdict for the algebra council: stratum must stay asserted.** It is an
editorial axis with one internal contradiction, not a computed one. Do not
build an algebra that assumes `stratum` is a rank function over the law
relation — the two agree on 5% of the vocabulary.

---

## Question 11: Composition as a State Machine

**Answer: yes, and it runs — but the invariant is 25 laws, not 29, and
prefix-legality is strictly stronger than set-legality.**

The machines exist and execute (`rawAssembly`, `legalAssembly`). A "pie" is a
violated invariant and a hazard is a reachable bad state, exactly as Q11 hoped.
Three qualifications, all measured:

1. **The invariant is 25 laws.** L14, L23, L25, L26 have prose or conjunctive
   subjects and can never fire from element membership. `satisfiesClosure` is
   therefore a 25-law predicate wearing a 29-law name. Any claim of the form
   "this composition satisfies the laws" is really "satisfies 25 of them".

2. **Only 25 of 77 terms are checkable.** Even among the 25 fireable laws,
   `requirementsFullyExpressible` fails for most. Exhaustively over all subsets
   of size <= 5 of the full vocabulary, **1,174,236 of 1,458,840 closed and
   hazard-free sets (80.5%)** fire at least one law with an external or mixed
   term. The minimal offenders are 12 *single elements*:
   `Rf, Ba, In, Ex, At, Au, Xm, Aw, Sb, Sd, Fz, Rs` — each one, alone, drags in
   a requirement the table cannot state. Plus `{Tr,Sv}` and `{Tg,Up}`.

3. **`legalAssembly` requires legality at every prefix.** That is a real
   restriction, not a modelling nicety: a set can be closed while no ordering of
   its elements is closed at each step. This is a stated bound on every
   `legalFull` result below. The exhaustive JS search in Q12 does *not* have this
   restriction — it tests final-set legality over all subsets up to a size bound
   — and it returns the same minimal witnesses, so for the witnesses reported
   here the bound is not doing any work.

---

## Question 12: Unwritten Hazard Combinations

**Answer: yes. Model checking found reachable, law-closed, written-hazard-free
element sets that violate safety properties nobody wrote down. Three distinct
minimal witnesses, and they are complete up to size 5 over the whole
vocabulary.**

### 12.1 The prize: `{Fl, Xm}` — atomic flash liquidity across a settlement domain

Apalache, symbolic, all 58 elements:

```
$ quint verify --main=legalFull --invariant=atomicScopeSafety --max-steps=6 atlas.qnt
State 2: state invariant 0 violated.
Found 1 error(s)
The outcome is: Error
An example execution:
[State 0] { legalFull::legalAssembly::chosen: Set() }
[State 1] { legalFull::legalAssembly::chosen: Set(Fl) }
[State 2] { legalFull::legalAssembly::chosen: Set(Fl, Xm) }
[violation] Found an issue (94082ms).
error: found a counterexample
```

`{Fl, Xm}` is closed under all 25 fireable laws. It arms **none** of the 20
hazard rows. `Fl` is the only element in the atlas with `atom: AsyncImpossible`
— "borrow and repay within one settlement scope or revert". `Xm` is
cross-domain message verification, `atom: AsyncNative`. A single flat element
set cannot say which settlement scope the flash loan lives in, so the atlas
cannot express that these two cannot share one. **No hazard rule names this.**
X2 covers flash-loan price manipulation; nothing covers flash-loan atomicity
meeting a domain boundary.

The second minimal witness of the same shape is `{Fl, Au, Rl}` — flash liquidity
plus a resource lock (`Rl` is G12, and drags in `Au` via L20).

This is the answer to Q12 as asked: a hazard combination that is reachable,
legal, and unlisted.

### 12.2 `{Au, Gs}` — the stratum inversion, found twice, two ways

Apalache, symbolic, all 58 elements:

```
$ quint verify --main=legalFull --invariant=stratumSafety --max-steps=8 atlas.qnt
State 2: state invariant 0 violated.
Found 1 error(s)
The outcome is: Error
An example execution:
[State 0] { legalFull::legalAssembly::chosen: Set() }
[State 1] { legalFull::legalAssembly::chosen: Set(Au) }
[State 2] { legalFull::legalAssembly::chosen: Set(Au, Gs) }
[violation] Found an issue (110576ms).
error: found a counterexample
```

Randomised search reached the same class of state independently:

```
$ quint run --main=legalFull --invariant=stratumSafety --max-samples=20000 \
    --max-steps=12 --seed=0x1234 atlas.qnt
[State 9] { legalFull::legalAssembly::chosen: Set(Au, Cv, Gs, In, Sh, St, Sv, Wq, Xm) }
[violation] Found an issue (61ms at 98 traces/second).
Use --seed=0x1270 --backend=rust to reproduce.
error: Invariant violated
```

This is the same `L21: Gs -> Au` inversion the rank analysis found. It is an
*atlas defect surfaced as an unlisted hazard*, not a financial hazard — worth
saying plainly, because it is the difference between "the checker found a bug in
DeFi" and "the checker found a bug in the table".

### 12.3 Completeness of the search, stated as a bound

The Quint runs above are bounded by trace depth. To get a completeness claim,
`probe.mjs` enumerates **every subset of the full 58-element vocabulary up to a
size bound**, with no prefix-legality restriction, and reports *minimal*
violating sets.

```
$ node --experimental-strip-types probe.mjs 5
=== EXHAUSTIVE BOUNDED SEARCH: all subsets of the full 58-element vocabulary, size <= 5
{"total":5038954,"closed":1459837,"closedSafe":1458840,"stratumInversion":15360,
 "atomicScopeBreak":15320,"inexpressible":1174236}
MINIMAL stratumInversion (closed AND hazardFree AND violating), 1 minimal of 15360 total: [["Au","Gs"]]
MINIMAL atomicScopeBreak (closed AND hazardFree AND violating), 2 minimal of 15320 total: [["Fl","Xm"],["Fl","Au","Rl"]]
MINIMAL inexpressible (closed AND hazardFree AND violating), 30 minimal of 1174236 total: [["Rf"],["Ba"],["In"],["Ex"],["At"],["Au"],["Xm"],["Aw"],["Sb"],["Sd"],["Fz"],["Rs"],["Tr","Sv"],["Tg","Up"],...]
```

(K=4 was run first and gives the same minimal sets from 456,838 subsets:
`{"total":456838,"closed":169260,"closedSafe":169215,"stratumInversion":1039,"atomicScopeBreak":1038,"inexpressible":122266}`.)

**The bound, stated as a bound.** All 5,038,954 subsets of size <= 5 were
enumerated exhaustively. 1,458,840 of them are closed and free of every
membership-evaluable written hazard. Within that space the complete set of
minimal unlisted-hazard witnesses is:

- stratum inversion: `{Au, Gs}` — exactly one, nothing else
- atomic-scope break: `{Fl, Xm}` and `{Fl, Au, Rl}` — exactly two
- inexpressible requirement: 30 minimal sets, 12 of them singletons

**Nothing is claimed above size 5.** A minimal unlisted hazard requiring six or
more co-present elements would not be found by this search, and the Apalache
runs above only certify the absence of shallower counterexamples along
prefix-legal traces. The honest statement is: *within all element sets of size 5
or smaller over the complete 58-element vocabulary, the unlisted hazards are
exactly the three families above.*

### 12.4 What this does and does not turn the table into

It found real structure the hazard list is missing (12.1) and a real internal
contradiction (12.2). But note the ratio: 1,174,236 of 1,458,840 legal sets fire
a requirement the vocabulary cannot state. The instrument works; the material it
is measuring is 80% prose. The table is closer to being an instrument than a
record, and it is nowhere near being a decision procedure.

---

## Question 13: The Reflexive Loop

**Answer, part 1 — as a graph cycle: no, and this is a hard negative.**

The TypeScript engine's `cycles()` found nothing for Terra, but that was over
the *present-element* restriction of the requirement relation, which is only
evidence about Terra. The stronger check:

```
$ node --experimental-strip-types probe.mjs 5
=== Q13 cycles in FULL law relation (subject -> every alternative, all 58 elements): NONE - the relation is a DAG
Q13 self-loops: []
Q13 Terra elements: ["As","Rd","Ex","Pl","Ix","Em"] out-edges within Terra: [["Pl",["Ex","Ix"]]]
```

The requirement relation over the *entire* vocabulary, taking every alternative
of every term (the most permissive edge set the laws admit), is **acyclic and
has no self-loops**. Since every restriction of a DAG is a DAG, **no subset of
elements can contain a requirement cycle.** Not Terra, not any protocol, not any
hypothetical one. Reflexivity is not hiding in the law graph under some other
restriction; it is absent from the relation.

Terra's own element set has exactly one internal requirement edge,
`Pl -> {Ex, Ix}`. Its collapse is nowhere near it.

**Can a relation be defined in which Terra's collapse IS a cycle?** Not over
`Element` alone — proved above, since any relation *derived from the laws* is a
sub-relation of an acyclic one. It requires a strictly richer carrier. The
minimal such relation:

> Let the carrier be pairs `(e, a)` of an element and the **asset argument** it
> is instantiated over — the atlas already gestures at this with its isotope
> syntax `At{subject=borrower-financials}`. Define `backs : (e1,a1) -> (e2,a2)`
> to hold when the solvency of instance `(e1,a1)` is a function of the market
> value of `a2`. Terra is `(As, UST) -backs-> (Rd, LUNA) -backs-> (As, UST)`:
> algorithmic supply adjustment mints LUNA to defend UST, and UST demand is what
> gives LUNA its price. That is a 2-cycle in `backs`.

The cycle is real, but it lives over element *instances indexed by asset*, not
over element types. This is the precise reason the law graph cannot see it: the
laws quantify over types, and the reflexive bind is a statement about a
particular assignment of assets to two element instances. **X1 is prose not
because nobody formalised it, but because the vocabulary has no place to put an
asset argument.** Adding `backs` requires promoting the isotope annotation from
a display string to a real index — that is the change Q13 is actually asking
for.

**Answer, part 2 — as a temporal property: yes, and it checks.**

`reflexiveLoop` is a state machine over `(phase, supply, backing)` where the
only defense available without exogenous capital is `endogenousDefense`, which
increases supply and decreases backing.

```
$ quint verify --backend=tlc --main=reflexiveClosed --temporal=eventualRecovery --max-steps=8 atlas.qnt
Checking temporal properties for the complete state space with 4 total distinct states
Error: Temporal properties were violated.
Error: The following behavior constitutes a counter-example:
State 1: <Initial predicate>   phase |-> Healthy,   supply |-> 1, backing |-> 2
State 2: <shock>               phase |-> Depegged,  supply |-> 1, backing |-> 2
State 3: <endogenousDefense>   phase |-> Spiraling, supply |-> 2, backing |-> 1
State 4: <endogenousDefense>   phase |-> Collapsed, supply |-> 3, backing |-> 0
State 5: Stuttering
[violation] Found an issue (921ms).
```

`always(distressed implies eventually(recovered))` fails with
`HAS_EXOGENOUS_CAPITAL = false`. Note the state space is complete (4 distinct
states, 0 left on queue) — this is not a bounded result, it is exhaustive for
this machine.

Giving the machine exogenous capital is **not** sufficient on its own:

```
$ quint verify --backend=tlc --main=reflexiveCapitalized --temporal=eventualRecovery --max-steps=8 atlas.qnt
Error: Temporal properties were violated.
State 4: <endogenousDefense>  phase |-> Collapsed, supply |-> 3, backing |-> 0
State 5: Stuttering
[violation] Found an issue (805ms).
```

Capital that exists but is never deployed does not save the peg — the run that
spirals to `Collapsed` without ever taking `recover` is still a legal behaviour.
Only under **weak fairness on `recover`** does the property hold:

```
$ quint verify --backend=tlc --main=reflexiveCapitalized --temporal=eventualRecoveryUnderFairness --max-steps=8 atlas.qnt
11 states generated, 7 distinct states found, 0 states left on queue.
The depth of the complete state graph search is 5.
[ok] No violation found (870ms).
```

So Q13's proposed phrasing is confirmed with a sharpening: it is not "no fair
execution restores the peg" but **"recovery requires exogenous capital *and* a
fairness assumption that it will actually be committed"**. Two separate
conditions, and Terra had neither. A hazard rule can state the first; only a
temporal property can state the second. That is the real argument for moving X1
out of the hazard table.

---

## Question 14: Alternatives and the Legal-Protocol Order

**Answer: yes, there is a lattice — but only for closure, and the meet is not
intersection. Adding the hazard rules destroys it.**

### 14.1 Closure alone: a complete lattice with join = union

Exhaustive over a 12-element universe (`Fl Xm Xf Rl Of Bs Sl Au Gs Uc Aw At`),
all 4096 subsets, all pairs of the 680 closed sets:

```
$ node --experimental-strip-types analyze.mjs      # boundedSearch section
"totalSubsets": 4096, "closureModelCount": 680, "safeModelCount": 460,
"closureUnionClosed": true,
"closureFormsFiniteLattice": true,
"intersectionFailure": {"left":["Xm","Xf","Of","Bs"],
                        "right":["Xm","Xf","Of","Sl"],
                        "intersection":["Xm","Xf","Of"]},
```

Corroborated over the full 58-element vocabulary by random sampling:

```
$ node --experimental-strip-types probe.mjs 5
closed sets sampled: 4000 (from ~95000 random draws)
union counterexample: NONE among all C(n,2) sampled pairs
intersection counterexample: ["Ix,Wg,St,Cl,Ba,In,Im,Ct,Li,Ad,Sl,Op,Tr,Cv,Sv,At,Gp,Ps,Rs",
                              "Rb,St,Ob,Ag,Ft,Ct,Bs,Op,Sv,Dp,Tp,Sr,Wq,Rd,As,Aw,Fz",
                              "St,Ct,Op,Sv"]
empty set closed: true ; full vocabulary closed: true ; full vocabulary hazardFree: false
```

Union-closure is not an empirical accident, it is structural: `lawSatisfied` is
monotone in the element set (a satisfied term stays satisfied under superset),
and a law fires in `A u B` iff it fires in `A` or in `B`. So closure is
preserved by arbitrary unions. Intersection is not, and the reason is exactly
the `|` alternatives: `{Xm,Xf,Of,Bs}` and `{Xm,Xf,Of,Sl}` each satisfy L19's
`(Bs|Sl)` by a *different* disjunct, and the intersection satisfies it by
neither.

Therefore the law-satisfying sets form a **union-closed family containing the
empty set and the full vocabulary**, which is a complete lattice under subset
inclusion with

- `join(A,B) = A u B`
- `meet(A,B) =` the largest closed subset of `A n B` (well-defined precisely
  because the union of all closed subsets of `A n B` is itself closed)
- bottom = the empty set, top = `allElements`

**Substitution Space is a real object.** It is the interval lattice above a
partial protocol. But the meet is a derived operation, not set intersection, and
any algebra that assumes "two legal protocols share a legal common part" is
wrong.

### 14.2 How many legal completions does a partial protocol have?

`completions.mjs` enumerates all *minimal* closed supersets (add only what a law
demands, branch on every disjunct):

```
$ node --experimental-strip-types completions.mjs
=== Q14: minimal legal completions of each corpus protocol (full 58-element vocabulary)
aave        closed=true  minimalCompletions= 1 hazardFree= 1 added=[[]]
uniswapv3   closed=true  minimalCompletions= 1 hazardFree= 1 added=[[]]
maker       closed=true  minimalCompletions= 1 hazardFree= 1 added=[[]]
liquity     closed=true  minimalCompletions= 1 hazardFree= 1 added=[[]]
gmx         closed=true  minimalCompletions= 1 hazardFree= 1 added=[[]]
lido        closed=false minimalCompletions= 1 hazardFree= 1 added=[["Tg"]]
cow         closed=true  minimalCompletions= 1 hazardFree= 1 added=[[]]
cctp        closed=false minimalCompletions= 2 hazardFree= 2 added=[["Sl"],["Bs"]]
centrifuge  closed=false minimalCompletions= 1 hazardFree= 0 added=[["Sv"]]
terra       closed=false minimalCompletions= 4 hazardFree= 4 added=[["Bs","Ct"],["Ct","Sl"],["Ad","Ct"],["Ct","Li"]]
mango       closed=false minimalCompletions= 6 hazardFree= 6 added=[["Bs","Ix"],["Ix","Sl"],["Ad","Ix"],["Bs","Sh"],["Sh","Sl"],["Ad","Sh"]]
euler       closed=false minimalCompletions= 1 hazardFree= 1 added=[["Tg"]]
```

So the answer to "how many legal completions" is **1 to 6 for real protocols**,
and the completion set is the concrete repair menu: Lido and Euler have exactly
one repair (`+Tg`), CCTP has two (`+Bs` or `+Sl`), Terra four, Mango six.

Per single element, the substitution space is bimodal:

```
elements with exactly one trivial completion (themselves): 45 of 58
  Pl  completions=24   Cd  completions=24   Im  completions=12   Op  completions=12
  Uc  completions= 2   Pf  completions= 3   Py  completions= 3   Of  completions= 2
  Tr  completions= 1   Up  completions= 1   Gs  completions= 1   Xf  completions= 1   Rl  completions= 1
elements with ZERO hazard-free completion: ["Uc"]
```

**45 of 58 elements have no substitution space at all** — they require nothing,
so their only minimal closed superset is themselves. The lattice is a tall thin
structure over 13 elements sitting on a flat 45-element floor. This is the same
flatness Q5 observed in in-degree, now measured on the other side of the arrow.

**`Uc` has zero hazard-free completion.** Both of its closed completions
(`{At,Aw,Bs,Uc}` and `{At,Aw,Sv,Tr,Uc}`) arm X11a under the reversed-polarity
projection. Under the current hazard table, undercollateralized credit is
formally unrealizable. That is a bug report about X11a, delivered as a
lattice-emptiness result.

### 14.3 Adding hazards destroys the lattice

```
"safeFormsFiniteLattice": false,
"safeJoinFailure": {"left":["Xm","Xf"], "right":["Aw"],
                    "union":["Xm","Xf","Aw"], "armedHazards":["X19"]}
```

`hazardFree` is *downward*-closed (subsets of hazard-free sets are hazard-free)
while `closure` is *upward*-closed under union. Their conjunction is neither.
Two legal protocols joined can arm a hazard: `{Xm,Xf}` is legal, `{Aw}` is legal,
`{Xm,Xf,Aw}` arms X19. Legality is not compositional.

This is arguably the sharpest result for the algebra council: **you get a lattice
if you model requirements, and you lose it the moment you model prohibitions.**

---

## Visualization Implications

- The three protocols that fail closure (Lido, CCTP, Centrifuge) are all live.
  Failing closure is not a death predicate and the viz should not present it as
  one. Euler and Lido fail *identically* (`Up` without `Tg`); the "Euler was
  perfect and the table was blind" narrative is not supported — the table does
  flag Euler, it just flags a live protocol the same way.
- The completion sets give the viz a genuine interactive object: for any
  incomplete protocol, show the 1-6 minimal repairs as alternative paths. That
  is Substitution Space with real content.
- `{Fl, Xm}` should be surfaced as a derived, unwritten hazard alongside the 20
  written ones, visually distinguished as *computed* rather than *recorded*.
- 45 of 58 elements are requirement-terminal. Any layout that implies uniform
  depth is misleading; the law structure is a thin spine over a wide flat base.

## Most Surprising Finding

Not the unlisted hazard. The most surprising result is that **the requirement
relation over the entire vocabulary is a DAG with no self-loops** — reflexivity,
the mechanism behind the largest failure in the corpus, is provably not
expressible as a cycle over element types no matter how the relation is
restricted. The table's central cautionary tale is the one thing its formalism
structurally cannot say.

Runner-up: `Uc` is unrealizable. The hazard table forbids every legal completion
of one of its own elements.

---

## For the algebra council

**Is there a lattice? (Q14) — Yes for closure, no for legality.**

Law-satisfying element sets form a **complete lattice**: join is union
(structurally, because law satisfaction is monotone and firing distributes over
union), bottom is the empty set, top is the full vocabulary. Verified
exhaustively on 680 closed sets over a 12-element universe and by sampling 4000
closed sets over all 58. But **meet is not intersection** — the `|` alternatives
break it, witness `{Xm,Xf,Of,Bs} n {Xm,Xf,Of,Sl} = {Xm,Xf,Of}` which is open.
Meet must be defined as "largest closed subset of the intersection", which
exists but is a derived operation. Build on `(closed sets, subset, union,
meet*)`. Do not assume distributivity; it was not checked.

The moment hazards are added the structure collapses: hazard-freedom is
downward-closed, closure is union-closed, and the conjunction is neither.
`{Xm,Xf}` join `{Aw}` arms X19. **There is no algebra in which "legal" is
compositional.** If the council wants compositional legality it must either
(a) work in the closure lattice and treat hazards as a separate filter applied
at the end, or (b) reformulate hazards as requirements — turn "X19: Xf without
destination Aw" into a law `Xf -> Aw`, at which point it becomes union-closed
and rejoins the lattice. Option (b) is the recommendation; it also fixes the
polarity bug that makes `Uc` unrealizable, and it is what X11a and X19 are
already trying to say.

**Is stratum derivable? (Q10) — No. It must stay asserted.**

Derived topological rank matches the hand-assigned stratum on **3 of 58
elements**, and all three matches are the trivial rank-0 case. Rank has range
0-2; stratum has range 0-4. 45 elements have no outgoing element-expressible
requirement, so rank cannot distinguish `Tg` (S4) from `Sh` (S0). Any algebra
that types elements by stratum is using an axis the constraint system does not
support. There is exactly one true inversion in the corpus — `L21: Gs(S3) ->
Au(S4)` — and it should be fixed in the atlas regardless.

**Are there unwritten hazards? (Q12) — Yes, and the complete list up to size 5
is short.**

Exhaustively over all 5,038,954 element sets of size <= 5 drawn from the full
58-element vocabulary, restricted to the 1,458,840 that are law-closed and free
of every membership-evaluable written hazard, the minimal violations of
independently-defined safety are exactly:

- `{Fl, Xm}` and `{Fl, Au, Rl}` — atomic flash liquidity co-present with a
  cross-domain element. Genuinely unlisted; a real composition hazard; the atlas
  has no way to scope `Fl` to one settlement domain.
- `{Au, Gs}` — stratum inversion. An atlas defect, not a financial hazard.
- 30 minimal "requirement not expressible in the vocabulary" sets, 12 of them
  single elements.

Nothing is claimed for sets of size 6 or larger. The council should treat
`{Fl, Xm}` as a 21st hazard and `{Au, Gs}` as an erratum.

**The load-bearing caveat.** 52 of 77 law terms are prose. 80.5% of legal element
sets fire at least one requirement the vocabulary cannot state. An algebra over
this data is an algebra over the 25 expressible terms, and it will be sound and
almost entirely silent. The first job is not more algebra — it is converting
prose terms into elements, or admitting a second sort for the things elements
cannot name (settlement domain, asset argument, counterparty). The Q13 result is
the sharpest instance: the reflexive loop needs an asset index on element
instances, and until the vocabulary has one, X1 can only ever be prose.
