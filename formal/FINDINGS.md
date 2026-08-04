# DeFi Atlas Formal-Model Findings

Status: implemented and checked with the limits stated below.

## Intake Findings: Source and Engine Defects

These findings come directly from the current source files.
They predate the Quint model.

### The element count mixes mechanisms with a declared non-element

`ELEMENTS` contains 59 rows.
Only 58 rows are mechanisms.
The `CSM` row has status `limit` and states that it is not an element.

### The hazard count has two valid interpretations

`HAZARDS` contains 20 rows.
The identifiers represent 19 numbered families because `X11` has `X11a` and `X11b` variants.

### The protocol death count is three

`PROTOCOLS` contains 12 protocols.
Only Terra, Mango, and Euler have `dead: true`.
The source does not identify a fourth dead protocol.

### The TypeScript parser activates only 25 of 29 laws

The parser cannot derive element subjects for `L14`, `L23`, `L25`, or `L26`.

- `L14` uses the prose subject `illiquid backing`.
- `L23` uses `Sq`, which is contested and absent from `ELEMENTS`.
- `L25` uses the prose subject `wrapped cross-domain collateral`.
- `L26` uses a conjunction, `Aw + Xf`, where the parser accepts only `|` alternatives.

These four laws never fire in the current TypeScript engine.

### The hazard projection has a polarity defect

The TypeScript engine extracts recognized element symbols from hazard prose.
It requires at least two symbols and treats all extracted symbols as present.

Only `X2`, `X11a`, and `X19` pass the two-symbol threshold.
The projection reverses the meaning of `X11a` and `X19`.

- `X11a` describes `Uc` with no `Aw` and no `At`.
  The engine arms it only when `Uc`, `Aw`, and `At` are all present.
- `X19` describes `Xf` with no destination-side `Aw`.
  The engine arms it only when both `Xf` and `Aw` are present.

The current `armedHazards` result is therefore not a sound hazard predicate.
The Quint report keeps the requested membership projection but labels this limitation.

## Model Scope

`atlas.qnt` models the 58 mechanism rows as a closed `Element` type. It records
the name, group, hand-assigned stratum, atom, status, and definition of each
mechanism. It also records all 29 source laws, all 20 hazard rows, and all 12
protocols.

The model has three semantic layers.

1. The faithful layer reproduces the TypeScript closure semantics. A law fires
   when an extracted subject is present. Each internally expressible term must
   contain at least one chosen alternative. Prose-only alternatives are
   recorded as external residue and do not fail closure.
2. The projection layer reproduces the membership-based hazard test that the
   current source permits. It can project only `X2`, `X11a`, and `X19` to
   element conjunctions. This layer preserves the two polarity defects instead
   of silently repairing them.
3. The hypothesis layer checks additional properties that can reveal missing
   annotations. These properties are not claimed to be established financial
   safety laws.

The raw assembly machine starts with the empty set and nondeterministically
adds one element. The legal assembly machine uses the same transition but
admits only prefixes that satisfy `closure` and the projected `hazardFree`.
This separation matters: a raw assembly can pass through an incomplete state,
while every prefix of a legal assembly is a complete legal protocol.

The element set cannot express a reflexive economic loop. The reflexive module
therefore adds explicit phase, supply, backing, and exogenous-capital state.
This is a small scenario model, not a claim that those variables are present
in the source taxonomy.

`analyze.mjs` is an independent executable analysis. It imports `data.ts` and
`protocols.ts`, but it does not import or call the TypeScript closure engine in
`laws.ts`. It independently parses laws, checks protocols, computes ranks, and
enumerates bounded configurations.

## Commands and Bounds

Quint 0.32.0 was already installed. The principal successful commands were:

```text
quint typecheck formal/atlas.qnt
quint typecheck formal/atlas_test.qnt
quint test formal/atlas_test.qnt --main atlasTest --match '^test'
quint test formal/atlas_test.qnt --main rawAssemblyTest --match '^test'
quint test formal/atlas_test.qnt --main legalAssemblyTest --match '^test'
quint test formal/atlas_test.qnt --main reflexiveClosedTest --match '^test'
quint test formal/atlas_test.qnt --main reflexiveCapitalizedTest --match '^test'
node --experimental-strip-types formal/analyze_test.mjs
node --experimental-strip-types formal/analyze.mjs
```

The full 58-element legal assembly was sampled to depth 10 with 10,000
requested traces. No `closure` or projected `hazardFree` violation occurred.
This is a simulation result, not exhaustive proof. Both predicates are also
guards on the legal transition, so this run is principally an implementation
sanity check.

The raw one-element `Pl` instance produced the expected closure counterexample
at depth 1. Reduced legal instances produced these exact counterexample
prefixes:

- depth 1: `{Ex}` violates the external-requirement expressibility property;
- depth 2: `{Fl}` then `{Fl, Xm}` violates the atomic-scope hypothesis;
- depth 2: `{Au}` then `{Au, Gs}` violates stratum monotonicity.

Full-vocabulary sampled runs also found all three kinds of candidate violation
within depth 5, with 10,000 requested traces per property.

The independent exhaustive bound was the 12-element universe
`{Fl, Xm, Xf, Rl, Of, Bs, Sl, Au, Gs, Uc, Aw, At}`. The analyzer checked all
`2^12 = 4,096` subsets. It found 680 closure models and 460 models that also
pass the projected hazard predicate. This result is exhaustive only for that
named universe. An exhaustive search over all `2^58` sets was not attempted.

`quint verify` was attempted with the default Apalache backend and with
`--backend=tlc`, initially at depth 2. Both attempts failed before state-space
exploration because the sandbox denied Apalache's local Java server socket
with `java.net.SocketException: Operation not permitted`. The TLC selection
still passes through the same Quint-to-Apalache compilation server. Therefore,
this report does not present sampled `quint run` output as exhaustive Quint
model-checker proof. Exhaustive claims below come only from direct enumeration
of the stated 12-element finite universe.

## Protocol Closure Results

The Quint assertions and the independent analyzer agree with the TypeScript
classification. Uniswap v3, which was not named in the expected-result list,
also passes.

| Protocol | Closure | Missing source terms |
| --- | --- | --- |
| Aave v3 | Pass | None |
| Uniswap v3 | Pass | None |
| Maker / Sky | Pass | None |
| Liquity v1 | Pass | None |
| GMX v2 | Pass | None |
| Lido v2 | Fail | L15: `Tg` |
| CoW Protocol | Pass | None |
| CCTP v2 Fast | Fail | L19: `Bs | Sl` |
| Centrifuge | Fail | L6: `Sv` |
| Terra / Anchor | Fail | L1: `Ct` and `Li | Ad | Sl | Bs` |
| Mango Markets | Fail | L2: `Sh | Ix`; L4: `Ad | Sl | Bs` |
| Euler v1 | Fail | L15: `Tg` |

This confirms Aave, Maker, Liquity, GMX, and CoW as closed. It confirms Lido,
CCTP, Centrifuge, Terra, Mango, and Euler as not closed. It also confirms
Uniswap v3 as closed. The result is independent at the implementation level,
but it intentionally uses the same source-level treatment of external prose
alternatives.

## Question 10: Stratum as Graph Rank

The current S0 through S4 assignment is not derivable as topological rank over
the executable law graph.

The graph is acyclic, but it is shallow. Its maximum strict dependency rank is
2, while the hand assignment reaches S4. Both strict rank and a choice-aware
rank match only 3 of 58 elements: `Sh`, `Ix`, and `Rb`, all at rank 0/S0.
Most elements have graph rank 0 because no internally expressible law requires
them. The nonzero choice-aware ranks are:

- rank 1: `Pl`, `Im`, `Cd`, `Uc`, `Pf`, `Op`, `Tr`, `Py`, `Up`, `Gs`, `Xf`,
  and `Rl`;
- rank 2: `Of`.

Under strict rank, which counts every disjunct as a dependency, `Uc` also moves
to rank 2. This is the only rank difference caused by treating alternatives as
choice rather than conjunction.

There is one edge that directly conflicts with the hand depth direction:
L21 makes `Gs` at S3 require `Au` at S4. The graph is not cyclic, but this edge
says that a shallower mechanism depends on a deeper one.

Conclusion: the hand stratum is a semantic classification, not a graph depth.
The sparse internal law graph and its many prose-only terms cannot reconstruct
the five strata.

## Question 11: Composition as a State Machine

Incremental assembly is useful because it distinguishes an incomplete prefix
from a complete protocol. In the raw machine, adding `Pl` to the empty set
immediately violates closure. In the legal machine, dependent mechanisms must
be added after their prerequisites: `Gs` is disabled from the empty state but
is enabled after `Au`.

This semantics makes construction order observable. It is appropriate for a
protocol builder UI, but it is stronger than a final-set validity check. If a
future law introduces a genuine dependency cycle, no member of the cycle can
be added one at a time under the legal-prefix rule even when the final set
would be closed. The current executable dependency graph has no such cycle.

## Question 12: Unwritten Hazard Combinations

No confirmed new financial-loss hazard was derivable from the available state.
That negative result is important: element membership alone contains no price,
collateral amount, liquidity, timing, trust-domain, or loss variable against
which to state a general financial safety invariant.

The search did find reachable, closure-valid, projected-hazard-free states that
violate three additional properties. None is named by the 19 hazard families:

| Minimal state | Violated property | Interpretation |
| --- | --- | --- |
| `{Ex}` in Quint; `{Xm}`, `{Au}`, `{Aw}`, and `{At}` in the 12-element exhaustive bound | Every fired requirement is machine-expressible | A law can be reported as closed while its substantive requirement is only external prose. This is a new **unverifiable-composition** finding, not proof of financial loss. |
| `{Fl, Xm}`; also `{Fl, Rl, Au}` in the 12-element bound | Atomic scope is consistent | A flat protocol set combines flash atomicity with a cross-domain mechanism. This is a **scope-ambiguity hypothesis**: local flash use plus a bridge may be safe. |
| `{Au, Gs}` | Dependencies do not point to a deeper hand stratum | L21 requires S4 `Au` for S3 `Gs`. This is a **taxonomy inconsistency**, not a financial hazard. |

The exact exhaustive search covered all 4,096 subsets of the named 12-element
universe above. The full 58-element search was sampled to depth 5 for each
candidate property, with 10,000 requested traces, and found a counterexample
for each. I did not find and cannot honestly claim a new economically grounded
hazard beyond the source rules.

The known-hazard projection itself creates two false results:

- `Uc` requires `{Bs, Aw, At}` for closure in the bounded universe, but adding
  `Aw` and `At` arms projected `X11a`. Therefore no projected-hazard-free legal
  set in the bound can contain `Uc`.
- `{Xm, Xf}` and `{Aw}` are separately legal and projected-hazard-free, but
  their union arms projected `X19`. The prose says the hazard is the absence of
  destination-side `Aw`, so this result has the opposite polarity.

These are not newly discovered hazards. They are counterexamples to the
soundness of the current hazard extraction.

## Question 13: Reflexive Loop as a Temporal Property

The best fit is a liveness property over economic state:

```text
always(distressed implies eventually(recovered))
```

Membership in a set cannot express this loop. The scenario model uses phases
`Healthy`, `Depegged`, `Spiraling`, `Collapsed`, and `Recovered`. A shock moves
the system to `Depegged`. Endogenous defense expands supply and consumes
backing, then reaches `Collapsed`. Recovery is enabled only when exogenous
capital is available.

The closed-capital tests execute this trace:

```text
Healthy(supply=1, backing=2)
-> Depegged(1, 2)
-> Spiraling(2, 1)
-> Collapsed(3, 0)
```

`Collapsed` has a self-loop and no recovery transition when exogenous capital
is false. It is therefore a reachable terminal strongly connected component
that refutes eventual recovery. Weak fairness on `recover` does not help,
because that action is disabled.

When exogenous capital is true, a sampled trace reaches `Recovered`. The model
states the stronger conditional property as weak fairness of `recover` implies
eventual recovery. Without fairness, a capitalized execution can remain on the
collapsed self-loop forever. The temporal formula typechecks, but its backend
verification could not start because of the Java socket restriction described
above. The liveness conclusion is therefore supported by explicit finite-state
reasoning and executable traces, not by an Apalache run.

## Question 14: Alternatives and the Legal-Protocol Order

Yes, `|` alternatives can be treated as nondeterministic assembly choices, and
they generate meaningful substitution branches. For example, the bounded
model has two minimal closures containing `Of`:

- `{Xm, Xf, Of, Bs}`;
- `{Xm, Xf, Of, Sl}`.

The 680 closure models in the exhaustive bound are closed under union. Ordered
by set inclusion, they form a finite lattice. Set intersection is not always
the meet: the two `Of` configurations above intersect at `{Xm, Xf, Of}`, which
violates L19. Their greatest legal lower bound is `{Xm, Xf}`.

Adding the projected hazard predicate leaves 460 configurations and destroys
the lattice. `{Xm, Xf}` and `{Aw}` are each safe, but their union is rejected
by projected X19. Because X19 has reversed polarity, this specific join failure
is an extraction artifact rather than evidence that hazard-free protocols can
never form a lattice.

Conclusion: the closure relation gives a useful lattice of compositional
choices in this bound. Hazard constraints turn it into a compatibility space
with missing joins. The result is meaningful, but it should be recomputed
after hazard polarity and external clauses have structured representations.

## Visualization Implications

The current visualization should not present all relations as the same kind of
edge.

- Show hand stratum and computed dependency rank as separate fields. Do not
  position S0 through S4 as if the laws derived that order.
- Render each law term as an explicit OR group. The two minimal `Of` closures
  show that alternatives are real branches, not decorative syntax.
- Distinguish an incomplete assembly prefix from a closed protocol. A builder
  can show the currently missing terms after each added mechanism.
- Give hazards typed polarity and scope: `present`, `absent`, external prose,
  and unknown. A conjunction-only badge reverses X11a and X19.
- Mark prose-only law residue as unverifiable instead of silently satisfied.
  The current corpus has 25 internal terms, 52 external terms, and 5 mixed
  terms across the 29 laws.
- Draw reflexive loops as a separate time-based scenario or feedback overlay.
  A static element edge cannot show expanding supply, declining backing,
  terminal collapse, or the fairness assumption behind recovery.
- Treat the legal configurations as a substitution/compatibility space. OR
  branches can show alternative implementations; missing joins can show
  incompatible compositions. Label projection artifacts so they are not
  mistaken for economic conclusions.

## Most Surprising Finding

The most surprising result is that the current X11a projection makes every
closed undercollateralized-credit configuration hazardous precisely because it
contains the attestation and allowlisting controls whose absence the prose
hazard was meant to detect.
