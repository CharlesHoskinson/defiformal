# Cleanup review 03 — 2026-09-08

**Verdict: approve a small, hash-checked artifact cleanup; do not purge historical source trees or dirty candidate worktrees.** Five files totaling 154727 bytes are concrete removal candidates. No source-file deletion has been established safe. No files were deleted by this reviewer.

Reviewed primary HEAD `a12b7cac05a818cc8d35c2ca440b7170a2807e92`. The companion JSON records exact absolute paths, sizes, SHA-256, references, preserved evidence, validation and restoration for every candidate. Original `texput.log` bytes are embedded there, preserving the failed invocation even if the root removes the working copy.

## High-confidence cleanup

- `texput.log` (753 bytes): tracked failed pdfTeX invocation for absent root `atlas.tex`, no PDF produced. It is incidental scratch. `formal/v3/VERIFICATION.md:396` records its concurrent rewrite, and that provenance remains. Restore from the reviewed Git revision or embedded original bytes.
- Four exact files under `scripts/__pycache__/`: ignored CPython bytecode with retained Python sources; no explicit filename caller in the bounded search. `check_integer_arithmetic_evidence.cpython-314.pyc` is positively stale: both header timestamp and source size differ. Other three headers match their retained source. Remove only the named cache files after rechecking hashes. The JSON gives source parse commands; this review claims no runtime tests or builds.

`tmp/sheaf_corpus.json` has a known generator (`research/positive-program/evidence/sheafcalc.py:122`) and no bounded-search reader, but defer deletion: reproduction would read historical corpus inputs outside this review's data scope. Its ignored status is not sufficient proof of reproducibility.

## Preserve these apparent false starts

`algebra/.gp-ord-scratch.mjs` is dynamically imported three times by `.gp-ord-test.mjs` (lines 8, 21, 30). The source graph has the same `ast_dynamic_import` incoming edge. Its CLI and historical classification behavior remain evidence. No excluded assessment or blind-set payload was executed or opened.

`lean/Axioms.lean` is a standalone audit root, with explicit `lake env lean Axioms.lean` commands in historical audit reports. `lean/DefiHistorical.lean` is a named Lake library despite not being a default target. The default roots are `Defialgebra` and `DefiKernel`; root import reachability alone would misclassify these files. Historical negative results and older Defialgebra proofs are explicitly protected by the migration design.

Mutation runner fixtures and captured source trees are intentional. `scripts/test_nary_mutation_runner.py:321` creates `fixture-repo`; lines 376–437 compile/setup actual isolated inputs. The untracked Sprint11 fixture `.lake` has `build/` and `config/`; it is not a symlink at that level, but its nested ownership and evidence bindings were not inspected. Do not recursively delete it on this evidence. No .lake or node_modules content scan was performed.

All ten isolated worktrees were checked through `git status`, AGENTS identity and shallow cache identity. Their modified plans, Lean foundations, Claims partial proofs, source-ready packages, native review logs and copied review evidence remain pending work. The workstate explicitly preserves cancelled/incomplete Claims proofs and interrupted reviews. Unaccepted is not dead. No worktree deletion is justified, including Sprint11: it still contains unique untracked program and review records.

## Historical routing rather than erasure

`research/positive-program/AGENDA.md` still presents an “Agenda loop state,” an obsolete live tree/branch and IDLE. It says the scheduler stopped but has no migration banner. Add a short historical-only routing notice to current `roadmap.md` and `review/semantic-kernel/program-loop-20260908/WORKSTATE.json`; keep the old body.

`research/positive-program/tooling/patch_roadmap5.py` is a one-shot historical roadmap mutator containing an actual correction to Curve intermediate-arithmetic reasoning. No caller was found beyond source manifests; nevertheless, it is provenance rather than dispensable implementation. Recommend an additive historical-tooling index that warns these patch scripts replay old edits. Do not execute them, erase them or relocate them without preserving source and reference bindings.

`runstate/STATE.md`, positive-program README and ROADMAP already have explicit supersession banners. Their conflicting old mandates are historical text, not instructions. Root `roadmap.md` also preserves an old “all implementation tasks remain unchecked” planning paragraph, but explicitly labels it historical below; a clearer top-level route would help, not deletion of the record.

## Graph and validation limits

The graphify skill was consulted and the existing codebase graph was traversed for incoming links. Its builder excludes review/generated trees and admits only a narrow untracked set. It cannot prove dirty corpus/historical package reachability. `graphify-out/codebase/artifact-manifest.json` binds nine artifacts, and README links that graph. Root and expansion graphs are not uniformly disposable: `.gitignore` documents gate consumers of graph.json and GRAPH_REPORT.md and non-byte-reproducible regeneration. Do not remove an apparently stale graph while its replacement is being built.

The exact filename search covered 992 tracked text files no larger than 200 KB, excluding review-wide content, corpus, corpus50, expansion, protocol-repos, papers, paper/kg-corpus, and filenames containing holdout/assessment/blind-test/discovery.json. Graph metadata and explicitly named control/status files were read separately. This is bounded static evidence, not a whole-repository call graph. No `/tmp/historical-discovery-r2/discovery.json` or old12 assessment/holdout payload was read. No financial proof, compiler acceptance, mutation result or package acceptance was inferred from cleanup.

Before applying removals, root should verify current hashes and no intervening changes, retain this review, remove only approved exact paths, parse the four retained Python sources, and check the diff. Do not use `git clean`, delete untracked directories, or broaden the five-path list automatically.

Validation performed: companion JSON parsed; all 11 recorded file sizes and hashes matched current bytes; all four retained Python sources parsed with `ast.parse`. No build or runtime suite was run.
