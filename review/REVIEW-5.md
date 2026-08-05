# Round 5 — Halmos and Gottlieb on the manuscript

# Joint review

We agree that the manuscript is not yet publishable. This is not a cautious verdict: several theorem-class statements are false as written, one displayed proof witness fails its own predicate, the residual argument assumes an inclusion relation that the computation disproves, and the submission omits the instantiated tables needed to check its witnesses. The empirical work is substantial, and several fourth-round repairs are sound, but the central mathematical arc still overstates what has been proved.

## Must change before publication

1. **Both — The model-class repair is internally contradicted, and the closure theorem contains a false witness.**

   At [paper/atlas.tex:353](/root/defiformal/paper/atlas.tex:353):

   > “The lattice, polarity and convex-geometry results are results about \(\Adm\).”

   This is false. The lattice result is about \(\Pos=\mathcal R\cap\mathcal W\); polarity is separately about \(\mathcal R,\mathcal W,\mathcal H\); and the convex geometry concerns \(Cn\) on the definite fragment. Lines 336–341 state this correctly, so lines 353–360 undo the repair.

   Worse, the proof at [paper/atlas.tex:386](/root/defiformal/paper/atlas.tex:386) says that

   > “\(\{Cd,Cp,Fl,Im,Pl,St,Uc,Wg\}\) and \(\{Bs,Cd,Cl,Sl,Uc,Wg\}\) lie in \(\mathcal H\).”

   The checker reports both sets outside its prohibition class; the first arms \(X2\), and both also trigger the operational \(X11a^*\) test. The proof is therefore false. For the operational \(X2\) predicate, \(\{Fl,Cp\}\) and \(\{Pl\}\) are valid separate models whose union arms \(X2\). If \(\mathcal H\) is meant to contain a different listed projection, exhibit that projection and choose a witness from it.

   The operational definition at [paper/atlas.tex:344](/root/defiformal/paper/atlas.tex:344) also says every conditional prohibition has “two or more negative literals together with a positive one,” while Proposition 3 immediately classifies \(X21\) as purely negative and \(X11a^*\) as dual-Horn. Replace that description with the actual three-way classification.

2. **Both — The AFT theorem is not a theorem about a standard AFT approximator.**

   At [paper/atlas.tex:556](/root/defiformal/paper/atlas.tex:556):

   > “No approximator \(A\) on \(L^2\) has lower and upper components \(\Gamma\) and \(\Delta\)…”

   The proof then concedes at [paper/atlas.tex:577](/root/defiformal/paper/atlas.tex:577) that the proposed diagonal is incompatible with exactness, but calls the object a “non-exact approximator.” In standard AFT, an approximator is precision-monotone and maps exact pairs to exact pairs; the diagonal \((\Gamma(x),\Delta(x))\) with distinct components therefore fails the definition before the displayed inequality is reached. See the definition in the [official IJCAI AFT account](https://www.ijcai.org/proceedings/2025/0506.pdf).

   The Lean file [lean/Defialgebra/Obstruction.lean:47](/root/defiformal/lean/Defialgebra/Obstruction.lean:47) formalizes only the elementary implication
   \[
   x\leq\Gamma(x)\leq\Delta(x)\leq x,
   \]
   not the AFT definition. It therefore does not repair the scope error.

   Either delete the AFT theorem and its corollary, or define a nonstandard “consistent bounding pair” without calling it an AFT approximator. In either case revise the abstract, introduction, and conclusion, which presently advertise an obstruction to a standard framework.

3. **Both — The bilattice proof is valid only for the bespoke family \(\mathcal C\); the following remark is false.**

   Definition `def:rect` at [paper/atlas.tex:488](/root/defiformal/paper/atlas.tex:488) now makes the rectangle induction complete. It proves that the diagonal is not obtainable from the full carrier by the particular set-transformations declared in \(\mathcal C\). It does not prove the broader prose claim that “interlaced bilattices cannot represent” the diagonal. Avron’s result supplies the product representation of the bilattice; it does not identify the manuscript’s newly defined \(\mathcal C\) as the unique notion of representability. See the [published abstract of Avron’s representation result](https://www.cambridge.org/core/journals/mathematical-structures-in-computer-science/article/abs/structure-of-interlaced-bilattices/B4134AFCB598A5DA8413FF14D9BC0A83).

   The remark at [paper/atlas.tex:535](/root/defiformal/paper/atlas.tex:535) is mathematically false:

   > “\(\Delta\) is closed under the coordinatewise operations…”

   In the standard two-lattice product, truth meet applies different component operations; for example \((0,0)\wedge_t(1,1)=(0,1)\), which is off the diagonal. Delete the remark or restrict it to operations whose two components agree on the intersection.

   Finally, \(\Delta\) already denotes the warrant kernel at [paper/atlas.tex:480](/root/defiformal/paper/atlas.tex:480) and is reused for the diagonal at [paper/atlas.tex:508](/root/defiformal/paper/atlas.tex:508). Rename the diagonal, for example \(\operatorname{Diag}(\Pos)\).

4. **Both — The residual section asserts an inclusion interval that does not exist.**

   At [paper/atlas.tex:858](/root/defiformal/paper/atlas.tex:858):

   > “The residual is narrower per element than the fitted table…”

   and at [paper/atlas.tex:875](/root/defiformal/paper/atlas.tex:875):

   > “some \(C\) strictly between the residual and the shipped table…”

   The current computation gives:

   - 27 elements with a fitted `CONSUME` entry;
   - 18 with a residual entry;
   - 10 defined in both, all ten different;
   - 17 only in `CONSUME`;
   - 8 only in the residual.

   Thus the two assignments are incomparable, not endpoints of an interval. For example, `Rb` has fitted consumers \(\{Cd,Im,Ix,Pl,Ps,Rd,Sh,Vl\}\) and residual consumer \(\{Py\}\).

   Define the requirement relation whose residual is being taken—\(R\) currently risks confusion with the model class \(\mathcal R\)—and rewrite the section as a comparison of two incomparable assignments. Remove “minimum,” “maximal extension,” “strictly between,” and “exactly the extension.” The empirical invariance and classification figures may remain once stated as results for two different assignments.

   The notation table at [paper/atlas.tex:292](/root/defiformal/paper/atlas.tex:292) also calls \(\War\) “derived,” contradicting lines 271–278, which correctly call it independent data.

5. **Both — Lemma `lem:cm` is false without missing hypotheses.**

   At [paper/atlas.tex:896](/root/defiformal/paper/atlas.tex:896):

   > “For a single implication \(A\to B\)… union-stable iff \(|A|=1\), or \(A=\emptyset\) and \(|B|=1\).”

   Counterexamples are immediate:

   - If \(B\subseteq A\), the implication is tautological; the closure is the identity and is union-stable even when \(|A|>1\).
   - If \(A=\emptyset\), the closure is \(X\mapsto X\cup B\), which is union-stable for arbitrary \(B\), not only singleton \(B\).

   State the omitted reduced/nontriviality hypotheses from the cited theorem, or replace the lemma with the sufficient fact actually needed: closures generated by singleton-premise implications are union-stable.

6. **Both — The instantiated mathematical object is absent from the submitted documents.**

   The caption at [paper/atlas.tex:309](/root/defiformal/paper/atlas.tex:309) says:

   > “Element symbols … are listed in full in the supplement.”

   They are not. [paper/supplement.tex:16](/root/defiformal/paper/supplement.tex:16) begins directly with the sixty profiles, followed by evidence. Neither document contains the 58-element dictionary, the 29 requirements, 27 warrants, listed prohibitions, grounding rule, or conditional clauses.

   This makes witnesses involving \(L1\), \(X2\), `Ct`, `Fl`, and so on impossible to check from the publication. Repository availability is useful but does not cure the false cross-reference or make the article self-contained.

   Add a formal-data appendix to the supplement containing the exact vocabulary and every instantiated constraint used by the proofs and scripts. Give it a version/hash and cite it wherever an instantiated witness is used.

7. **Both — Two extension “propositions” are not defined well enough to prove.**

   At [paper/atlas.tex:2359](/root/defiformal/paper/atlas.tex:2359):

   > “Adjoin party facts as positive existential atoms occurring only as heads. Then [five results] hold unchanged, and \(X9\) becomes enforceable…”

   “Party fact,” the enlarged signature, its rules, and the encoding of \(X9\) are not defined. The sketch about 15 arcs cannot establish all five listed conclusions.

   At [paper/atlas.tex:2411](/root/defiformal/paper/atlas.tex:2411):

   > “Recording the mandate at presence granularity … preserves every result above…”

   Again there is no formal signature or clause set, and an exhaustive check over \(2^{12}\) assignments does not prove “every result above.”

   Define both extensions formally, state exactly which results transfer, and prove each transfer. Otherwise demote these environments to proposals or measurements.

8. **Both — The computational gate can pass while relevant manuscript claims are wrong.**

   The strongest individual checks do real work: `onesystem.mjs` found zero disagreement on 30,856 triples; `verify-freeset.mjs` exhaustively checked 4,194,304 subsets; current emission produced 60 profiles and matched all 60. But the overall evidence system remains porous:

   - [formal/v3/m4-oplus.mjs:19](/root/defiformal/formal/v3/m4-oplus.mjs:19) samples with the repaired `L.adm`, then evaluates unions with the old `T.admissible` at line 26. Its current output reports 82 requirement failures among unions of supposedly admissible inputs. That is the old and new requirement systems inside one v3 script.
   - [formal/v3/onesystem.mjs:10](/root/defiformal/formal/v3/onesystem.mjs:10) compares only `lib.inR` and `construct.openRequirements` on three-element sets. It cannot establish that every paper-facing script uses that system.
   - [formal/v3/residual-check.mjs:51](/root/defiformal/formal/v3/residual-check.mjs:51) prints which prose sentence should be wrong but never asserts the manuscript or exits nonzero.
   - [formal/v3/m1-closureprops.mjs:9](/root/defiformal/formal/v3/m1-closureprops.mjs:9) still tests the retired `{Op,Tp}` witness, reports it false under the repaired system, calls the old `gammaOpen` for diagnostics, and exits successfully.
   - [formal/v3/totalgate.mjs:28](/root/defiformal/formal/v3/totalgate.mjs:28) uses unanchored `tex.includes`; its computed `inad` value is never checked. Correct figures may occur anywhere while the intended table is wrong.
   - [formal/v3/verify-extensions.mjs:59](/root/defiformal/formal/v3/verify-extensions.mjs:59) computes `party` but never checks it. It does not verify the manuscript’s 135 party-sort total, the 95/7/26 breakdown, or the mandate subcounts, yet prints “0 mismatch.”
   - [formal/v3/claims.mjs:104](/root/defiformal/formal/v3/claims.mjs:104) labels a size-difference check “proper subset.” The elements are not compared.
   - [formal/v3/verify-structure.py:14](/root/defiformal/formal/v3/verify-structure.py:14) collects article labels and never uses them, despite promising duplicate detection across both documents.
   - [formal/v3/verify-emission.py:16](/root/defiformal/formal/v3/verify-emission.py:16) does not require exactly 60 emitted profiles. It also checks only the four article measurement environments, allowing the four incorrect adjacent residue sentences below to pass.
   - [formal/v3/loop2gate.sh:70](/root/defiformal/formal/v3/loop2gate.sh:70) prints citation output but never changes `fail` when citation checks report a defect. `cites.mjs` itself has no failing exit.
   - [formal/v3/domain-fresh.sh:12](/root/defiformal/formal/v3/domain-fresh.sh:12) and [formal/v3/brief-fresh.sh:12](/root/defiformal/formal/v3/brief-fresh.sh:12) overwrite committed artifacts before comparison and do not restore the original on a stale result. They are mutations, not safe verification gates.
   - The graph checks gate generated graph artifacts even though those graphs are not evidence for a paper claim.

   Replace substring tests with anchored parsing of the named environment/table; make every mismatch exit nonzero; require exact populations; remove all v2 predicate calls from v3 evidence; and make freshness checks regenerate into temporary files. Add deliberately corrupted-manuscript negative tests proving that each gate fails for the error it claims to detect.

## Should change

9. **Both — \(\Pos\) should now be the sole notation for its object.**

   After its definition, the manuscript repeatedly returns to the expanded form at [paper/atlas.tex:419](/root/defiformal/paper/atlas.tex:419), [paper/atlas.tex:528](/root/defiformal/paper/atlas.tex:528), [paper/atlas.tex:827](/root/defiformal/paper/atlas.tex:827), [paper/atlas.tex:2262](/root/defiformal/paper/atlas.tex:2262), and [paper/atlas.tex:2644](/root/defiformal/paper/atlas.tex:2644). The split is not defensible: the expanded expression carries no additional information and invites attribution errors such as line 355.

   Use \(\Pos\) everywhere after its defining equation, expanding it only when the two factors are themselves being discussed. At [paper/atlas.tex:2494](/root/defiformal/paper/atlas.tex:2494), the heading asks for the structure of \(\Admf\) but the question asks whether \(\Adm\) is a lattice; choose the intended class.

10. **Both — The abstract and conclusion currently promise central results that the body does not establish.**

   The opening does answer Gottlieb’s questions: by page two the reader knows the problem, the model, and why composition matters. The sampling units and reliability limitations at lines 184–226 are unusually clear.

   But the abstract’s bilattice/AFT claims at [paper/atlas.tex:48](/root/defiformal/paper/atlas.tex:48) and the conclusion’s “two standard frameworks” at [paper/atlas.tex:2586](/root/defiformal/paper/atlas.tex:2586) depend on the defective results above. Revise them after those results are corrected.

   Other unearned claims should be removed or measured:

   - [paper/atlas.tex:90](/root/defiformal/paper/atlas.tex:90): “the coarsest such form that is still faithful to practice.” No comparison establishes coarseness or fidelity.
   - [paper/atlas.tex:176](/root/defiformal/paper/atlas.tex:176) and [paper/atlas.tex:2611](/root/defiformal/paper/atlas.tex:2611): coverage “degrades systematically” with off-chain substance. No off-chain fraction is coded.
   - [paper/atlas.tex:2115](/root/defiformal/paper/atlas.tex:2115): resolution is “inversely correlated with capital.” The paper explicitly says this relation was not measured.
   - [paper/atlas.tex:2603](/root/defiformal/paper/atlas.tex:2603): the Uniswap/Aave counterexample does not “follow from the canonical form”; it follows from the two decompositions and \(X2\).

11. **Both — Several reported figures have drifted outside the generated environments.**

   The generated measurements say residues of 12, 8, 15, and 12, while the following prose says 13, 9, 16, and 13:

   - [paper/atlas.tex:1679](/root/defiformal/paper/atlas.tex:1679)
   - [paper/atlas.tex:1811](/root/defiformal/paper/atlas.tex:1811)
   - [paper/atlas.tex:1948](/root/defiformal/paper/atlas.tex:1948)
   - [paper/atlas.tex:2079](/root/defiformal/paper/atlas.tex:2079)

   Correct those four sentences or generate them from the same source as the environments.

   The methods claim “639 distinct sources” at [paper/atlas.tex:211](/root/defiformal/paper/atlas.tex:211). The current citation audit reports 638 distinct URLs. The supplement contains 658 per-application reference entries. State the unit explicitly: “658 listed entries representing 638 distinct URLs.”

12. **Reader Two — The twelve category sections accumulate rather than argue. Reader One partly disagrees: parallelism is suitable in the supplement, but not in the article.**

   The article explains the repeated template at [paper/atlas.tex:1463](/root/defiformal/paper/atlas.tex:1463), then repeats variants of

   > “Each subsection states what the system does…”

   at lines 1656–1664, 1718–1726, 1752–1760, 1787–1795, 1925–1933, and 2165–2173. Most category sections contain no article subsection at all. The cross-category argument finally appears at [paper/atlas.tex:2152](/root/defiformal/paper/atlas.tex:2152), after eleven parallel passes.

   Keep the three overview tables, move “Reading the twelve together” immediately after them, and reduce each category to its distinctive finding plus any load-bearing case. The sixty parallel profiles belong in the supplement and should remain there.

13. **Both — The free-set repair is computationally sound but placed in the wrong environment.**

   At [paper/atlas.tex:766](/root/defiformal/paper/atlas.tex:766), one conjecture contains:

   - the vague conjecture that a “substantial fraction” can be certified;
   - the proved fact that the displayed 22-element set is free;
   - the disclaimer that no certification rate is claimed.

   The exhaustive check of all 4,194,304 subsets passes. Split this into a proposition or measurement giving the verified free family and lower bound, followed by a precise conjecture with an actual quantitative or structural target. Do not put a proof inside a conjecture and then disclaim the conjecture’s only quantitative phrase.

14. **Reader One — Several theorem-class environments still contain computation or assertion where proof is required.**

   The clearest example is [paper/atlas.tex:440](/root/defiformal/paper/atlas.tex:440):

   > “\(\Pos\) is closed under \(\oplus\): verified on 96,720 pairs…”

   This is a corollary, not a measurement. It also forward-references a composition operation not defined until line 732. Move `def:oplus` before its first use and give the one-line proof: members of \(\Pos\) are already closed under every definite rule, their union remains in \(\Pos\), hence \(Cn(A\cup B)=A\cup B\).

   Add proofs or demote the non-obvious claims at [paper/atlas.tex:706](/root/defiformal/paper/atlas.tex:706) and [paper/atlas.tex:794](/root/defiformal/paper/atlas.tex:794). The former’s corollary additionally uses undefined relations `reads` and `over`.

15. **Both — The blocker terminology is reversed.**

   At [paper/atlas.tex:1021](/root/defiformal/paper/atlas.tex:1021):

   > “a transversal meets each member exactly once…”

   Standard hypergraph usage is nonempty intersection with every edge, not exactly once; an exact transversal is a special object. For example, the cited research literature defines a transversal as a set having [nonempty intersection with every edge](https://arxiv.org/abs/1512.02871). Delete the remark or use “exact transversal” for the exactly-once notion. The blocker definition itself is sound.

16. **Reader Two — The supplement’s evidence belongs there, but the editorial voice repeatedly turns defensive.**

   Examples include “This is not a defect in the witness,” “the honest decomposition,” and “the only honest one” at [paper/atlas.tex:2083](/root/defiformal/paper/atlas.tex:2083), [paper/supplement.tex:969](/root/defiformal/paper/supplement.tex:969), and [paper/supplement.tex:2059](/root/defiformal/paper/supplement.tex:2059). These phrases protect the coding decision; they do not explain it. Replace them with the factual premise: “No attestation exists,” “maximum payoff is escrowed,” or “the available alternatives require a feed or attester.”

   Many supplement remarks are also single paragraphs of 150–250 words; [paper/supplement.tex:38](/root/defiformal/paper/supplement.tex:38) is representative. Split mechanism description, evidential qualification, and interpretation into separate paragraphs. Reader One would preserve the technical density; Reader Two would cut the verdict-like flourishes.

17. **Both — Originality claims need a reproducible search record.**

   At [paper/atlas.tex:2550](/root/defiformal/paper/atlas.tex:2550):

   > “appears to be unnamed. Searches … return nothing.”

   Because the paper is submitted as original mathematics, name the databases, exact queries, and search date, or replace “return nothing” with the narrower “we have not found prior work under the following formulations.” The surrounding related-work section is otherwise candid and well organized.

## Would improve it

18. **Both — Correct the remaining copy and reference defects.**

   - [paper/atlas.tex:1752](/root/defiformal/paper/atlas.tex:1752): the CDP section says “Lido is treated here.” Remove it.
   - [paper/atlas.tex:1165](/root/defiformal/paper/atlas.tex:1165) and [paper/atlas.tex:1251](/root/defiformal/paper/atlas.tex:1251): duplicated “Measurement.”
   - [paper/atlas.tex:2195](/root/defiformal/paper/atlas.tex:2195): `conj:frag` is called a Measurement.
   - [paper/atlas.tex:146](/root/defiformal/paper/atlas.tex:146): “appears to satisfy anti-exchange” should be “satisfies,” since the result is later proved.
   - Cut subjective superlatives such as “sharpest statement” at [paper/atlas.tex:1238](/root/defiformal/paper/atlas.tex:1238), “sharpest case” at [paper/atlas.tex:2077](/root/defiformal/paper/atlas.tex:2077), and “best-evidenced” at [paper/atlas.tex:2400](/root/defiformal/paper/atlas.tex:2400), unless each is tied to a stated comparison criterion.

## Repairs that are sound

The repaired non-preservation theorem at [paper/atlas.tex:740](/root/defiformal/paper/atlas.tex:740)–764 is sound: \(D(P)\) and \(X_P\) are distinguished, both component decompositions pass the recorded operational predicate, and their union arms \(X2\). The positive lattice argument and the join/meet witness at lines 405–433 are sound once notation is normalized. The restated small-set closure measurement at lines 2633–2640 correctly separates the exhaustive range from the size-five counterexample. The 22-element free family passes exhaustive verification. The supplement contains all sixty profiles in twelve groups, and their emitted measurement blocks match the recorded artifacts. The citation checker reports a URL and access date for all 1,259 obligations, though it checks syntax and presence, not the truth or availability of the sources.

Repository note: no manuscript file was edited during this review. Near the end, unrelated changes appeared in `formal/v3/.cite-audit-offsets` and a new `formal/v3/cite-blindspot.py`; I left them untouched.

## Verdict

**Not yet.** The blockers are specific and finite: correct the false \(\mathcal H\) witness and model-class attribution; either recast or withdraw the AFT and broad bilattice claims; rewrite the residual section around two incomparable relations; repair the false singleton-premise lemma; formally define or demote the party and mandate propositions; include the complete instantiated vocabulary and constraint tables in the supplement; and make the evidence gates fail on the manuscript errors they claim to detect. Once those are done, the remaining work is substantial editing rather than a new research programme, and the paper could then merit a publishable-after-revision verdict.
2026-08-05T12:40:02.500655Z ERROR codex_core::session: failed to record rollout items: thread 019fd1c2-a8a2-7ed3-829b-072e61186378 not found
2026-08-05T12:40:02.500735Z ERROR codex_core::session: failed to record rollout items: thread 019fd1c2-a8a2-7ed3-829b-072e61186378 not found
2026-08-05T12:40:02.500823Z ERROR codex_core::session: failed to record rollout items: thread 019fd1c2-a8a2-7ed3-829b-072e61186378 not found
2026-08-05T12:40:02.500875Z ERROR codex_core::session: failed to record rollout items: thread 019fd1c2-a8a2-7ed3-829b-072e61186378 not found
tokens used
651,552
# Joint review

We agree that the manuscript is not yet publishable. This is not a cautious verdict: several theorem-class statements are false as written, one displayed proof witness fails its own predicate, the residual argument assumes an inclusion relation that the computation disproves, and the submission omits the instantiated tables needed to check its witnesses. The empirical work is substantial, and several fourth-round repairs are sound, but the central mathematical arc still overstates what has been proved.

## Must change before publication

1. **Both — The model-class repair is internally contradicted, and the closure theorem contains a false witness.**

   At [paper/atlas.tex:353](/root/defiformal/paper/atlas.tex:353):

   > “The lattice, polarity and convex-geometry results are results about \(\Adm\).”

   This is false. The lattice result is about \(\Pos=\mathcal R\cap\mathcal W\); polarity is separately about \(\mathcal R,\mathcal W,\mathcal H\); and the convex geometry concerns \(Cn\) on the definite fragment. Lines 336–341 state this correctly, so lines 353–360 undo the repair.

   Worse, the proof at [paper/atlas.tex:386](/root/defiformal/paper/atlas.tex:386) says that

   > “\(\{Cd,Cp,Fl,Im,Pl,St,Uc,Wg\}\) and \(\{Bs,Cd,Cl,Sl,Uc,Wg\}\) lie in \(\mathcal H\).”

   The checker reports both sets outside its prohibition class; the first arms \(X2\), and both also trigger the operational \(X11a^*\) test. The proof is therefore false. For the operational \(X2\) predicate, \(\{Fl,Cp\}\) and \(\{Pl\}\) are valid separate models whose union arms \(X2\). If \(\mathcal H\) is meant to contain a different listed projection, exhibit that projection and choose a witness from it.

   The operational definition at [paper/atlas.tex:344](/root/defiformal/paper/atlas.tex:344) also says every conditional prohibition has “two or more negative literals together with a positive one,” while Proposition 3 immediately classifies \(X21\) as purely negative and \(X11a^*\) as dual-Horn. Replace that description with the actual three-way classification.

2. **Both — The AFT theorem is not a theorem about a standard AFT approximator.**

   At [paper/atlas.tex:556](/root/defiformal/paper/atlas.tex:556):

   > “No approximator \(A\) on \(L^2\) has lower and upper components \(\Gamma\) and \(\Delta\)…”

   The proof then concedes at [paper/atlas.tex:577](/root/defiformal/paper/atlas.tex:577) that the proposed diagonal is incompatible with exactness, but calls the object a “non-exact approximator.” In standard AFT, an approximator is precision-monotone and maps exact pairs to exact pairs; the diagonal \((\Gamma(x),\Delta(x))\) with distinct components therefore fails the definition before the displayed inequality is reached. See the definition in the [official IJCAI AFT account](https://www.ijcai.org/proceedings/2025/0506.pdf).

   The Lean file [lean/Defialgebra/Obstruction.lean:47](/root/defiformal/lean/Defialgebra/Obstruction.lean:47) formalizes only the elementary implication
   \[
   x\leq\Gamma(x)\leq\Delta(x)\leq x,
   \]
   not the AFT definition. It therefore does not repair the scope error.

   Either delete the AFT theorem and its corollary, or define a nonstandard “consistent bounding pair” without calling it an AFT approximator. In either case revise the abstract, introduction, and conclusion, which presently advertise an obstruction to a standard framework.

3. **Both — The bilattice proof is valid only for the bespoke family \(\mathcal C\); the following remark is false.**

   Definition `def:rect` at [paper/atlas.tex:488](/root/defiformal/paper/atlas.tex:488) now makes the rectangle induction complete. It proves that the diagonal is not obtainable from the full carrier by the particular set-transformations declared in \(\mathcal C\). It does not prove the broader prose claim that “interlaced bilattices cannot represent” the diagonal. Avron’s result supplies the product representation of the bilattice; it does not identify the manuscript’s newly defined \(\mathcal C\) as the unique notion of representability. See the [published abstract of Avron’s representation result](https://www.cambridge.org/core/journals/mathematical-structures-in-computer-science/article/abs/structure-of-interlaced-bilattices/B4134AFCB598A5DA8413FF14D9BC0A83).

   The remark at [paper/atlas.tex:535](/root/defiformal/paper/atlas.tex:535) is mathematically false:

   > “\(\Delta\) is closed under the coordinatewise operations…”

   In the standard two-lattice product, truth meet applies different component operations; for example \((0,0)\wedge_t(1,1)=(0,1)\), which is off the diagonal. Delete the remark or restrict it to operations whose two components agree on the intersection.

   Finally, \(\Delta\) already denotes the warrant kernel at [paper/atlas.tex:480](/root/defiformal/paper/atlas.tex:480) and is reused for the diagonal at [paper/atlas.tex:508](/root/defiformal/paper/atlas.tex:508). Rename the diagonal, for example \(\operatorname{Diag}(\Pos)\).

4. **Both — The residual section asserts an inclusion interval that does not exist.**

   At [paper/atlas.tex:858](/root/defiformal/paper/atlas.tex:858):

   > “The residual is narrower per element than the fitted table…”

   and at [paper/atlas.tex:875](/root/defiformal/paper/atlas.tex:875):

   > “some \(C\) strictly between the residual and the shipped table…”

   The current computation gives:

   - 27 elements with a fitted `CONSUME` entry;
   - 18 with a residual entry;
   - 10 defined in both, all ten different;
   - 17 only in `CONSUME`;
   - 8 only in the residual.

   Thus the two assignments are incomparable, not endpoints of an interval. For example, `Rb` has fitted consumers \(\{Cd,Im,Ix,Pl,Ps,Rd,Sh,Vl\}\) and residual consumer \(\{Py\}\).

   Define the requirement relation whose residual is being taken—\(R\) currently risks confusion with the model class \(\mathcal R\)—and rewrite the section as a comparison of two incomparable assignments. Remove “minimum,” “maximal extension,” “strictly between,” and “exactly the extension.” The empirical invariance and classification figures may remain once stated as results for two different assignments.

   The notation table at [paper/atlas.tex:292](/root/defiformal/paper/atlas.tex:292) also calls \(\War\) “derived,” contradicting lines 271–278, which correctly call it independent data.

5. **Both — Lemma `lem:cm` is false without missing hypotheses.**

   At [paper/atlas.tex:896](/root/defiformal/paper/atlas.tex:896):

   > “For a single implication \(A\to B\)… union-stable iff \(|A|=1\), or \(A=\emptyset\) and \(|B|=1\).”

   Counterexamples are immediate:

   - If \(B\subseteq A\), the implication is tautological; the closure is the identity and is union-stable even when \(|A|>1\).
   - If \(A=\emptyset\), the closure is \(X\mapsto X\cup B\), which is union-stable for arbitrary \(B\), not only singleton \(B\).

   State the omitted reduced/nontriviality hypotheses from the cited theorem, or replace the lemma with the sufficient fact actually needed: closures generated by singleton-premise implications are union-stable.

6. **Both — The instantiated mathematical object is absent from the submitted documents.**

   The caption at [paper/atlas.tex:309](/root/defiformal/paper/atlas.tex:309) says:

   > “Element symbols … are listed in full in the supplement.”

   They are not. [paper/supplement.tex:16](/root/defiformal/paper/supplement.tex:16) begins directly with the sixty profiles, followed by evidence. Neither document contains the 58-element dictionary, the 29 requirements, 27 warrants, listed prohibitions, grounding rule, or conditional clauses.

   This makes witnesses involving \(L1\), \(X2\), `Ct`, `Fl`, and so on impossible to check from the publication. Repository availability is useful but does not cure the false cross-reference or make the article self-contained.

   Add a formal-data appendix to the supplement containing the exact vocabulary and every instantiated constraint used by the proofs and scripts. Give it a version/hash and cite it wherever an instantiated witness is used.

7. **Both — Two extension “propositions” are not defined well enough to prove.**

   At [paper/atlas.tex:2359](/root/defiformal/paper/atlas.tex:2359):

   > “Adjoin party facts as positive existential atoms occurring only as heads. Then [five results] hold unchanged, and \(X9\) becomes enforceable…”

   “Party fact,” the enlarged signature, its rules, and the encoding of \(X9\) are not defined. The sketch about 15 arcs cannot establish all five listed conclusions.

   At [paper/atlas.tex:2411](/root/defiformal/paper/atlas.tex:2411):

   > “Recording the mandate at presence granularity … preserves every result above…”

   Again there is no formal signature or clause set, and an exhaustive check over \(2^{12}\) assignments does not prove “every result above.”

   Define both extensions formally, state exactly which results transfer, and prove each transfer. Otherwise demote these environments to proposals or measurements.

8. **Both — The computational gate can pass while relevant manuscript claims are wrong.**

   The strongest individual checks do real work: `onesystem.mjs` found zero disagreement on 30,856 triples; `verify-freeset.mjs` exhaustively checked 4,194,304 subsets; current emission produced 60 profiles and matched all 60. But the overall evidence system remains porous:

   - [formal/v3/m4-oplus.mjs:19](/root/defiformal/formal/v3/m4-oplus.mjs:19) samples with the repaired `L.adm`, then evaluates unions with the old `T.admissible` at line 26. Its current output reports 82 requirement failures among unions of supposedly admissible inputs. That is the old and new requirement systems inside one v3 script.
   - [formal/v3/onesystem.mjs:10](/root/defiformal/formal/v3/onesystem.mjs:10) compares only `lib.inR` and `construct.openRequirements` on three-element sets. It cannot establish that every paper-facing script uses that system.
   - [formal/v3/residual-check.mjs:51](/root/defiformal/formal/v3/residual-check.mjs:51) prints which prose sentence should be wrong but never asserts the manuscript or exits nonzero.
   - [formal/v3/m1-closureprops.mjs:9](/root/defiformal/formal/v3/m1-closureprops.mjs:9) still tests the retired `{Op,Tp}` witness, reports it false under the repaired system, calls the old `gammaOpen` for diagnostics, and exits successfully.
   - [formal/v3/totalgate.mjs:28](/root/defiformal/formal/v3/totalgate.mjs:28) uses unanchored `tex.includes`; its computed `inad` value is never checked. Correct figures may occur anywhere while the intended table is wrong.
   - [formal/v3/verify-extensions.mjs:59](/root/defiformal/formal/v3/verify-extensions.mjs:59) computes `party` but never checks it. It does not verify the manuscript’s 135 party-sort total, the 95/7/26 breakdown, or the mandate subcounts, yet prints “0 mismatch.”
   - [formal/v3/claims.mjs:104](/root/defiformal/formal/v3/claims.mjs:104) labels a size-difference check “proper subset.” The elements are not compared.
   - [formal/v3/verify-structure.py:14](/root/defiformal/formal/v3/verify-structure.py:14) collects article labels and never uses them, despite promising duplicate detection across both documents.
   - [formal/v3/verify-emission.py:16](/root/defiformal/formal/v3/verify-emission.py:16) does not require exactly 60 emitted profiles. It also checks only the four article measurement environments, allowing the four incorrect adjacent residue sentences below to pass.
   - [formal/v3/loop2gate.sh:70](/root/defiformal/formal/v3/loop2gate.sh:70) prints citation output but never changes `fail` when citation checks report a defect. `cites.mjs` itself has no failing exit.
   - [formal/v3/domain-fresh.sh:12](/root/defiformal/formal/v3/domain-fresh.sh:12) and [formal/v3/brief-fresh.sh:12](/root/defiformal/formal/v3/brief-fresh.sh:12) overwrite committed artifacts before comparison and do not restore the original on a stale result. They are mutations, not safe verification gates.
   - The graph checks gate generated graph artifacts even though those graphs are not evidence for a paper claim.

   Replace substring tests with anchored parsing of the named environment/table; make every mismatch exit nonzero; require exact populations; remove all v2 predicate calls from v3 evidence; and make freshness checks regenerate into temporary files. Add deliberately corrupted-manuscript negative tests proving that each gate fails for the error it claims to detect.

## Should change

9. **Both — \(\Pos\) should now be the sole notation for its object.**

   After its definition, the manuscript repeatedly returns to the expanded form at [paper/atlas.tex:419](/root/defiformal/paper/atlas.tex:419), [paper/atlas.tex:528](/root/defiformal/paper/atlas.tex:528), [paper/atlas.tex:827](/root/defiformal/paper/atlas.tex:827), [paper/atlas.tex:2262](/root/defiformal/paper/atlas.tex:2262), and [paper/atlas.tex:2644](/root/defiformal/paper/atlas.tex:2644). The split is not defensible: the expanded expression carries no additional information and invites attribution errors such as line 355.

   Use \(\Pos\) everywhere after its defining equation, expanding it only when the two factors are themselves being discussed. At [paper/atlas.tex:2494](/root/defiformal/paper/atlas.tex:2494), the heading asks for the structure of \(\Admf\) but the question asks whether \(\Adm\) is a lattice; choose the intended class.

10. **Both — The abstract and conclusion currently promise central results that the body does not establish.**

   The opening does answer Gottlieb’s questions: by page two the reader knows the problem, the model, and why composition matters. The sampling units and reliability limitations at lines 184–226 are unusually clear.

   But the abstract’s bilattice/AFT claims at [paper/atlas.tex:48](/root/defiformal/paper/atlas.tex:48) and the conclusion’s “two standard frameworks” at [paper/atlas.tex:2586](/root/defiformal/paper/atlas.tex:2586) depend on the defective results above. Revise them after those results are corrected.

   Other unearned claims should be removed or measured:

   - [paper/atlas.tex:90](/root/defiformal/paper/atlas.tex:90): “the coarsest such form that is still faithful to practice.” No comparison establishes coarseness or fidelity.
   - [paper/atlas.tex:176](/root/defiformal/paper/atlas.tex:176) and [paper/atlas.tex:2611](/root/defiformal/paper/atlas.tex:2611): coverage “degrades systematically” with off-chain substance. No off-chain fraction is coded.
   - [paper/atlas.tex:2115](/root/defiformal/paper/atlas.tex:2115): resolution is “inversely correlated with capital.” The paper explicitly says this relation was not measured.
   - [paper/atlas.tex:2603](/root/defiformal/paper/atlas.tex:2603): the Uniswap/Aave counterexample does not “follow from the canonical form”; it follows from the two decompositions and \(X2\).

11. **Both — Several reported figures have drifted outside the generated environments.**

   The generated measurements say residues of 12, 8, 15, and 12, while the following prose says 13, 9, 16, and 13:

   - [paper/atlas.tex:1679](/root/defiformal/paper/atlas.tex:1679)
   - [paper/atlas.tex:1811](/root/defiformal/paper/atlas.tex:1811)
   - [paper/atlas.tex:1948](/root/defiformal/paper/atlas.tex:1948)
   - [paper/atlas.tex:2079](/root/defiformal/paper/atlas.tex:2079)

   Correct those four sentences or generate them from the same source as the environments.

   The methods claim “639 distinct sources” at [paper/atlas.tex:211](/root/defiformal/paper/atlas.tex:211). The current citation audit reports 638 distinct URLs. The supplement contains 658 per-application reference entries. State the unit explicitly: “658 listed entries representing 638 distinct URLs.”

12. **Reader Two — The twelve category sections accumulate rather than argue. Reader One partly disagrees: parallelism is suitable in the supplement, but not in the article.**

   The article explains the repeated template at [paper/atlas.tex:1463](/root/defiformal/paper/atlas.tex:1463), then repeats variants of

   > “Each subsection states what the system does…”

   at lines 1656–1664, 1718–1726, 1752–1760, 1787–1795, 1925–1933, and 2165–2173. Most category sections contain no article subsection at all. The cross-category argument finally appears at [paper/atlas.tex:2152](/root/defiformal/paper/atlas.tex:2152), after eleven parallel passes.

   Keep the three overview tables, move “Reading the twelve together” immediately after them, and reduce each category to its distinctive finding plus any load-bearing case. The sixty parallel profiles belong in the supplement and should remain there.

13. **Both — The free-set repair is computationally sound but placed in the wrong environment.**

   At [paper/atlas.tex:766](/root/defiformal/paper/atlas.tex:766), one conjecture contains:

   - the vague conjecture that a “substantial fraction” can be certified;
   - the proved fact that the displayed 22-element set is free;
   - the disclaimer that no certification rate is claimed.

   The exhaustive check of all 4,194,304 subsets passes. Split this into a proposition or measurement giving the verified free family and lower bound, followed by a precise conjecture with an actual quantitative or structural target. Do not put a proof inside a conjecture and then disclaim the conjecture’s only quantitative phrase.

14. **Reader One — Several theorem-class environments still contain computation or assertion where proof is required.**

   The clearest example is [paper/atlas.tex:440](/root/defiformal/paper/atlas.tex:440):

   > “\(\Pos\) is closed under \(\oplus\): verified on 96,720 pairs…”

   This is a corollary, not a measurement. It also forward-references a composition operation not defined until line 732. Move `def:oplus` before its first use and give the one-line proof: members of \(\Pos\) are already closed under every definite rule, their union remains in \(\Pos\), hence \(Cn(A\cup B)=A\cup B\).

   Add proofs or demote the non-obvious claims at [paper/atlas.tex:706](/root/defiformal/paper/atlas.tex:706) and [paper/atlas.tex:794](/root/defiformal/paper/atlas.tex:794). The former’s corollary additionally uses undefined relations `reads` and `over`.

15. **Both — The blocker terminology is reversed.**

   At [paper/atlas.tex:1021](/root/defiformal/paper/atlas.tex:1021):

   > “a transversal meets each member exactly once…”

   Standard hypergraph usage is nonempty intersection with every edge, not exactly once; an exact transversal is a special object. For example, the cited research literature defines a transversal as a set having [nonempty intersection with every edge](https://arxiv.org/abs/1512.02871). Delete the remark or use “exact transversal” for the exactly-once notion. The blocker definition itself is sound.

16. **Reader Two — The supplement’s evidence belongs there, but the editorial voice repeatedly turns defensive.**

   Examples include “This is not a defect in the witness,” “the honest decomposition,” and “the only honest one” at [paper/atlas.tex:2083](/root/defiformal/paper/atlas.tex:2083), [paper/supplement.tex:969](/root/defiformal/paper/supplement.tex:969), and [paper/supplement.tex:2059](/root/defiformal/paper/supplement.tex:2059). These phrases protect the coding decision; they do not explain it. Replace them with the factual premise: “No attestation exists,” “maximum payoff is escrowed,” or “the available alternatives require a feed or attester.”

   Many supplement remarks are also single paragraphs of 150–250 words; [paper/supplement.tex:38](/root/defiformal/paper/supplement.tex:38) is representative. Split mechanism description, evidential qualification, and interpretation into separate paragraphs. Reader One would preserve the technical density; Reader Two would cut the verdict-like flourishes.

17. **Both — Originality claims need a reproducible search record.**

   At [paper/atlas.tex:2550](/root/defiformal/paper/atlas.tex:2550):

   > “appears to be unnamed. Searches … return nothing.”

   Because the paper is submitted as original mathematics, name the databases, exact queries, and search date, or replace “return nothing” with the narrower “we have not found prior work under the following formulations.” The surrounding related-work section is otherwise candid and well organized.

## Would improve it

18. **Both — Correct the remaining copy and reference defects.**

   - [paper/atlas.tex:1752](/root/defiformal/paper/atlas.tex:1752): the CDP section says “Lido is treated here.” Remove it.
   - [paper/atlas.tex:1165](/root/defiformal/paper/atlas.tex:1165) and [paper/atlas.tex:1251](/root/defiformal/paper/atlas.tex:1251): duplicated “Measurement.”
   - [paper/atlas.tex:2195](/root/defiformal/paper/atlas.tex:2195): `conj:frag` is called a Measurement.
   - [paper/atlas.tex:146](/root/defiformal/paper/atlas.tex:146): “appears to satisfy anti-exchange” should be “satisfies,” since the result is later proved.
   - Cut subjective superlatives such as “sharpest statement” at [paper/atlas.tex:1238](/root/defiformal/paper/atlas.tex:1238), “sharpest case” at [paper/atlas.tex:2077](/root/defiformal/paper/atlas.tex:2077), and “best-evidenced” at [paper/atlas.tex:2400](/root/defiformal/paper/atlas.tex:2400), unless each is tied to a stated comparison criterion.

## Repairs that are sound

The repaired non-preservation theorem at [paper/atlas.tex:740](/root/defiformal/paper/atlas.tex:740)–764 is sound: \(D(P)\) and \(X_P\) are distinguished, both component decompositions pass the recorded operational predicate, and their union arms \(X2\). The positive lattice argument and the join/meet witness at lines 405–433 are sound once notation is normalized. The restated small-set closure measurement at lines 2633–2640 correctly separates the exhaustive range from the size-five counterexample. The 22-element free family passes exhaustive verification. The supplement contains all sixty profiles in twelve groups, and their emitted measurement blocks match the recorded artifacts. The citation checker reports a URL and access date for all 1,259 obligations, though it checks syntax and presence, not the truth or availability of the sources.

Repository note: no manuscript file was edited during this review. Near the end, unrelated changes appeared in `formal/v3/.cite-audit-offsets` and a new `formal/v3/cite-blindspot.py`; I left them untouched.

## Verdict

**Not yet.** The blockers are specific and finite: correct the false \(\mathcal H\) witness and model-class attribution; either recast or withdraw the AFT and broad bilattice claims; rewrite the residual section around two incomparable relations; repair the false singleton-premise lemma; formally define or demote the party and mandate propositions; include the complete instantiated vocabulary and constraint tables in the supplement; and make the evidence gates fail on the manuscript errors they claim to detect. Once those are done, the remaining work is substantial editing rather than a new research programme, and the paper could then merit a publishable-after-revision verdict.
