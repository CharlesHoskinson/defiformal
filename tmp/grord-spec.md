# Task: GR-ORD -- order-theoretic algebra of DeFi composition

You are mathematician GR-ORD on a nine-person council. Working directory is
/root/DefiElements (a git repo -- read-only git commands only, never commit,
never add/reset/branch/push). Read these files FULLY before doing anything:

- /root/DefiElements/algebra/BRIEF.md (240 lines -- the full spec of what every
  council member must deliver; read it end to end, it is short)
- /root/DefiElements/viz/src/data.ts (58 elements, 29 laws, 20 hazard rules)
- /root/DefiElements/viz/src/laws.ts (reference parser and closure engine --
  the ground truth for how laws fire and are satisfied; do not reinvent this
  parsing logic, reuse it or reimplement it identically)
- /root/DefiElements/viz/src/protocols.ts (12 hand-decomposed real protocols
  with element sets -- PROTOCOLS array)
- /root/DefiElements/corpus50/lanes/*.json (72 more real protocol decompositions
  across 3 lane files, each protocol has an "elements" array -- richer corpus)
- /root/DefiElements/formal/FINDINGS.md (results from Apalache/Quint and JS
  model checking -- these are FIXED RESULTS, do not re-derive them, build on
  them)
- /root/DefiElements/corpus50/VERDICT.md (what the 69/72-protocol corpus
  benchmark found about the vocabulary)

DO NOT open, read, or use /root/DefiElements/algebra/blind-test-KEY.json for
ANY reason. It is the answer key for the blind test you must classify. Using
it would defeat the entire exercise. If you accidentally see its contents, do
not let them influence any classification.

## Your assigned lens: ORDER-THEORETIC

Lattices, closure operators, Galois connections, Formal Concept Analysis (FCA),
Duquenne-Guigues bases. Two classes of things are already settled and you must
NOT re-derive them, only build on them (from BRIEF.md section 4b and
FINDINGS.md):

Already proved (do not re-prove):
1. Law-satisfying ("closed") element sets form a complete lattice under subset
   inclusion: join(A,B) = A union B (union-closed because law satisfaction is
   monotone), bottom = empty set, top = the full 58-element vocabulary.
2. Meet is NOT intersection. Meet(A,B) = the largest closed subset of
   A intersect B (a derived operation, well-defined, but not equal to set
   intersection). Witness: {Xm,Xf,Of,Bs} intersect {Xm,Xf,Of,Sl} = {Xm,Xf,Of},
   which is open (L19 has term (Bs|Sl) satisfied by different disjuncts in
   each operand, by neither in the intersection).
3. Hazards destroy even the join: {Xm,Xf} union {Aw} arms hazard X19 even
   though {Xm,Xf} and {Aw} are each individually legal and hazard-free. So:
   closure alone is lattice-structured; VALIDITY (closure AND hazard-free) is
   not compositional, not a lattice.
4. FCA cannot recover stratum as lattice level (concept lattices are not
   graded) -- already established by FINDINGS.md Q10 (rank vs stratum: 3/58
   agree, all trivially). Do not spend effort here.
5. Disjunctive law conclusions are structurally outside Horn (FCA intents are
   intersection-closed, and disjunctive terms like (Bs|Sl) are not). Do not
   spend effort re-litigating this -- it is why a literal Duquenne-Guigues
   base over the 29 laws-as-written cannot be computed directly; work around
   it with the scoped recipe below.

Your open question (spend your effort here): are the 29 laws reducible to a
smaller Duquenne-Guigues base, and which of the 58 elements are redundant
generators? This has NOT been answered by anyone yet.

## A concrete, tractable recipe for the open question -- use this; it is
## designed to be honest and computable given the Horn-wall above. You may
## improve it, but do not skip it for a hand-wavy answer.

Recipe A -- empirical redundancy from real protocol data (FCA proper).
Build a formal context K = (G, M, I): objects G = the union of all real
protocols in viz/src/protocols.ts (12) and corpus50/lanes/*.json (72) -- up to
84 objects total (dedupe by name if the same protocol appears in both
sources; document how many remain after dedup); attributes M = the 58
elements; I(g,m) holds iff element m is in that protocol elements list. For
every ordered pair of elements (m, m2), check whether Ext(m) is a subset of
Ext(m2) across all objects in G (every protocol that has m also has m2). This
is exactly a valid attribute implication "m implies m2" in this context.
Report:
  - every pair with Ext(m) = Ext(m2) (mutual implication): these are
    EMPIRICALLY REDUNDANT GENERATORS -- m and m2 are interchangeable given the
    corpus, name them explicitly (this is the type-level analogue of the
    USDT-equivalent-USD1 finding already recorded in BRIEF section 4 point 2,
    which was about protocol instances, not element types -- say explicitly
    whether you found any type-level case or none, and if none, say that
    plainly).
  - every strict pair Ext(m) proper-subset Ext(m2) with m appearing in >=2
    objects (to exclude accidental single-object coincidences): list the
    interesting or surprising ones (at most 15), and note whether any
    already-written law contradicts or duplicates one.
  - elements m whose Ext(m) is empty (never appear in any of the up-to-84
    protocols) -- flag these as ungrounded, no empirical evidence either way.

Recipe B -- law-basis redundancy (rules-based, using the reference engine).
Using the exact same parsing semantics as viz/src/laws.ts (subjects split on
"|", terms split on "+", each term alts list split on "|" and filtered to
symbols that exist in ELEMENTS -- do not diverge from this), extract, from
the 25 fireable laws, every term whose alts array has length exactly 1 (a
genuine Horn implication subject -> alt, since it has no disjunction and is
not external or prose). This gives a finite multiset of unit implications
over the 58-symbol universe (a law with a disjunctive subject like
"(Pl|Im|Cd|Pf|Op) -> X" contributes one implication per subject: Pl->X,
Im->X, etc).
Compute the closure operator this set of unit implications generates
(standard forward chaining / unit propagation, polynomial time).
Test each unit implication s -> a for redundancy: it is REDUNDANT iff a is in
cl_rest({s}), where cl_rest is the closure operator generated by every OTHER
unit implication in the set. A non-redundant unit implication belongs in the
minimal (Duquenne-Guigues-style) basis for this Horn fragment.
Report: which of the 29 written laws contribute at least one non-redundant
unit implication (keep them), which contribute only redundant ones (flag as
reducible, already entailed by the rest), and which contribute NO singleton
terms at all (their entire content is disjunctive or external -- explicitly
list these; per FINDINGS.md they include the 4 unfireable laws
L14/L23/L25/L26 plus any fireable law whose every term is a disjunction of
>=2 elements or prose) -- these sit permanently outside the Horn/DG-reducible
fragment and you should say so plainly rather than force them in.
State the resulting minimal basis size vs. 29, and state explicitly which
laws or terms could never even enter this analysis (the disjunctive ones)
and why that is a scope choice, not an oversight.

Use recipe A redundant-generator pairs and recipe B redundant-law list
together to answer BRIEF section 6 question 3 ("Are the 58 elements
independent, or is there a smaller generating set? Name the redundant
ones.") concretely, by symbol name.

## Your validity predicate -- use this exact design for classifying the 156
## blind cases. It operationalizes the order-theoretic recommendation already
## written down in formal/FINDINGS.md final section, which explicitly tells
## the council: "reformulate hazards as requirements... Option (b) is the
## recommendation; it also fixes the polarity bug that makes Uc unrealizable"

Define ADMISSIBLE(X) for an element set X subset-of the 58-symbol universe as:

1. Closed under the 25 fireable laws PLUS one new law you add, justified
   below: L19b: Xf -> Aw (this promotes hazard X19 -- "restricted claim
   bridged via Xf into a representation with no destination-side Aw" -- from
   a negated, unevaluable hazard into a positive requirement, exactly Option
   (b) from FINDINGS.md recommendation. This is YOUR order-theoretic move: it
   restores union-closure/lattice structure for this one hazard by folding it
   back into the requirement lattice instead of leaving it as a
   join-destroying external filter). Use the reference laws.ts
   evaluate/closes semantics for everything else unchanged (external terms
   auto-satisfied, etc).
   - Before adding L19b, check whether X11a ("Uc with no Aw, At, collateral
     or reputation") is already implied by existing law L3 ("Uc -> Aw +
     At{subject=borrower-financials} + (Bs|Tr) + obligor") -- if L3
     Aw/At/(Bs|Tr) requirements already force everything X11a would forbid
     the absence of, say explicitly "X11a is already subsumed by L3,
     promoting it to a law is a no-op" rather than adding a redundant second
     rule. If you find it is NOT fully subsumed, add the missing piece as
     L11a-prime and say so.
2. Hazard-free under the hazard rules AS THE REFERENCE ENGINE EVALUATES THEM
   (armedHazards() in laws.ts: only rules with >=2 named element symbols AND
   no negation word in the combo text -- this will in practice mean the
   evaluable ones such as X2, X3, X5, X6, X8, X9, X10, X13, X15, X16, X17 --
   run the function yourself, do not guess the list) PLUS one new hazard you
   add: atomic-scope safety -- Fl (atomic flash liquidity, the vocabulary
   only async-impossible element) may not co-occur with any G12 cross-domain
   element (Xm, Xf, Rl, Of). This is the {Fl,Xm}/{Fl,Au,Rl} witness from
   FINDINGS.md section 12.1, which FINDINGS explicitly recommends treating as
   "a 21st hazard". Call it X21 in your report.
   - Explicitly DO NOT add the {Au,Gs} stratum inversion as a hazard for
     classification purposes. FINDINGS.md is explicit that it is a table
     defect (an erratum in L21 stratum assignment), not a financial hazard,
     and your Q10 answer already says stratum stays asserted with one known
     defect. State this as a deliberate choice.

ADMISSIBLE(X) = closed_with_L19b(X) AND hazard_free_with_X21(X).
INADMISSIBLE(X) = not ADMISSIBLE(X).

This predicate is decidable in time O(|laws| * |terms per law| * |X|) --
linear in the size of the input set and the fixed law/hazard table (no
fixpoint iteration needed to CHECK a fixed set, unlike computing minimal
completions). State the exact complexity class in your report (P; give the
precise bound).

## What to build and where (paths are absolute, exactly these)

1. Write a Node.js script (any filename under /root/DefiElements/tmp/, this is
   scratch space, not a deliverable) that:
   - loads ELEMENTS/LAWS/HAZARDS from viz/src/data.ts (dynamic import of the
     .ts file works under Node 24 type stripping -- see formal/analyze.mjs
     and formal/probe.mjs for the exact working pattern, reuse it)
   - reimplements or reuses laws.ts evaluate/closes/armedHazards logic
   - implements ADMISSIBLE(X) exactly as specified above (base engine + L19b +
     X21, minus {Au,Gs})
   - runs recipe A over the real protocols (protocols.ts + corpus50 lanes) and
     recipe B over the 25 fireable laws, printing the redundancy results
   - loads /root/DefiElements/algebra/blind-test-set.json (156 cases under
     "cases": [{"id","elements"},...] -- verify it is exactly 156, not the
     stale "144" in its own note field) and classifies every case
   - writes /root/DefiElements/algebra/verdicts/GR-ORD.json in EXACTLY this
     shape: {"verdicts":[{"id":"T001","verdict":"ADMISSIBLE"},...]} with all
     156 entries in id order, verdict one of "ADMISSIBLE"/"INADMISSIBLE"
   - run: python3 -m json.tool /root/DefiElements/algebra/verdicts/GR-ORD.json
     and assert (in your own final message to me) that
     len(json["verdicts"]) == 156

2. Write /root/DefiElements/algebra/reports/GR-ORD.md following BRIEF.md
   section 8 exactly:
   1. Signature, carrier, operations, laws -- formal, with proofs. State the
      carrier explicitly (sets of symbols over the 58-element vocabulary;
      answer BRIEF section 6 Q1 directly: is one sort enough? VERDICT.md
      "strategy" finding says no for the yield category -- decide whether
      YOUR carrier stays one-sorted for element-sets and you simply flag
      strategies as out-of-scope, or whether you add a second sort; make the
      choice and label it).
   2. The validity predicate above and its complexity.
   3. Numbered answers to BRIEF section 6 questions 1-5, using your recipes
      results for Q3, using FINDINGS.md Q10 for Q4 (stratum stays asserted,
      cite the one inversion), and FINDINGS.md Q13 for Q5 (the
      (element,asset)-pair "backs" relation and the Terra 2-cycle -- decide
      and state whether YOUR carrier needs this second sort or whether you
      treat it as future work and remain a set-of-symbols algebra; do not
      just repeat FINDINGS.md verbatim, take a position).
   4. What you added to the vocabulary (L19b if added; state if X11a needed
      L11a-prime) and what you cut, if anything.
   5. Your self-assessed discrimination ratio on the blind set: you will not
      know ground truth, so instead report (a) the ADMISSIBLE rate you
      produced on the 156 cases, (b) the ADMISSIBLE rate the baseline
      (closure + reference armedHazards only, no L19b, no X21) would have
      produced on the same 156 cases for comparison, and (c) your reasoning
      for why adding L19b and X21 should tighten discrimination relative to
      that baseline without needing to see the key.
   6. One short section: what breaks (order-theoretic lens specifically --
      e.g. the meet-not-intersection result means "two legal protocols share
      a legal common part" is false; say what a user of your algebra must
      never assume).
   Be direct, state results as results, no hedging, no essay about whether a
   model is possible.

## Constraints

- Never write to blind-test-KEY.json, never use its contents.
- Never run git add/commit/reset/branch/push/checkout/merge/rebase/tag. Only
  read-only git (status/diff/log/show) is allowed if you need it at all.
- Do not modify viz/src/data.ts, viz/src/laws.ts, viz/src/protocols.ts, or any
  corpus50/formal file -- read-only inputs.
- Only write to: /root/DefiElements/tmp/* (scratch),
  /root/DefiElements/algebra/reports/GR-ORD.md,
  /root/DefiElements/algebra/verdicts/GR-ORD.json.
- The report should follow BRIEF.md six-part section 8 structure -- be
  thorough but not padded. A short summary is not required from you; your
  supervisor writes that separately after you finish.

## Verification command to run yourself before finishing, and report the
## actual output in your final message

Run this exact python3 one-liner style check and paste its output verbatim
into your final message, along with an ls -la of both deliverable files:

python3 -m json.tool /root/DefiElements/algebra/verdicts/GR-ORD.json > /dev/null
python3 -c "import json; d=json.load(open('/root/DefiElements/algebra/verdicts/GR-ORD.json')); v=d['verdicts']; assert len(v)==156, len(v); ids=set(x['id'] for x in v); assert len(ids)==156; assert all(x['verdict'] in ('ADMISSIBLE','INADMISSIBLE') for x in v); print('OK', len(v), 'unique ids', len(ids), 'admissible count', sum(1 for x in v if x['verdict']=='ADMISSIBLE'))"
ls -la /root/DefiElements/algebra/reports/GR-ORD.md /root/DefiElements/algebra/verdicts/GR-ORD.json

Include the actual output of these commands in your final message to me.

## IMPORTANT scratch isolation note

Other council members are running concurrently in this same repository and
also using /root/DefiElements/tmp/ as scratch space (you may see files like
opord/, GP-ORD.json, GP-CAT.json, OP-CAT.json already there -- these belong to
OTHER agents, not you; do not read, use, or overwrite them). Put ALL of your
own scratch scripts under a directory you create yourself:
/root/DefiElements/tmp/gr-ord-scratch/ -- do not write scratch files anywhere
else. Your only two deliverable files outside that scratch directory are
/root/DefiElements/algebra/reports/GR-ORD.md and
/root/DefiElements/algebra/verdicts/GR-ORD.json exactly as specified above.
