I'll start by reading the review skill and the full offloaded prompt so the verdict stays inside the stated scope.Using an advisory source review of the four attachments only: I’ll hash-check them against the candidate, then judge whether the CLI tests actually discriminate the advertised failures.The workspace is empty, so I’ll locate the candidate files and hash-check the four attachments without running the suite.Hashes of the four attachments match candidate `045126ef8493ff34da5f485c80d71414b29b2df3`. This is an advisory source review of those files and the attached parent log. I did not run the CLI or the unittest suite.

## Verdict

**Do not treat the parent log as verification of the live corpus.** The 15 tests in the log (`OK`, 8.296s) exercise a **synthetic** annotation pair and lock **374 provisional agreements / 1 unresolved**. Live `coverage.json` reports **346 / 29**. Those figures are different objects. The suite is a real subprocess CLI harness and, in this log, the coarse needles happened to match specific FAIL/BLOCKED lines. It still does **not** lock the advertised `INTERSECTION_UNRESOLVED` rule, and it never calls advertised `check --data`.

**Not ready** as evidence that the live 75-unit integration was checked. **Not a substitute** for a `check` of `corpus/normalized/generated`.

## What the evidence actually shows

| Artifact | Bound hash | What it is |
|---|---|---|
| `scripts/test_corpus_normalize.py` | `f208acb0…f2d697` | Isolated CLI tests; `setUp` **replaces** live `a.json`/`b.json` with empty-label fixtures plus one unit-0 disagreement |
| `review/semantic-kernel/sprint3/cli-tests.log` | `5fa243a8…0fa6e1` | Parent unittest stdout for that file: 15 methods, all `ok` |
| `corpus/normalized/generated/coverage.json` | `21674bd7…44dc49` | Live coverage: 72 rows, 75 development units, 375 decisions, **346 / 29**, 0 holdouts, 0 verified deployments |
| `corpus/normalized/README.md` | `c3cf73f6…c437f0` | Honest reconstruction limits; reproduce snippet still lists the synthetic suite as a corpus check |

Live arithmetic in `coverage.json` is internally consistent (22+30+20=72; 5+6+3+8+7=29; 70+69+72+67+68=346; 346+29=375). That is **not** what the tests assert.

## Blockers

**1. Parent log is fixture counts, not live annotations**
- File: `scripts/test_corpus_normalize.py:39-53`, `78-81`; `corpus/normalized/README.md:428-435`
- Tests copy live lanes/inputs, then write synthetic annotations (`rationale: 'Synthetic CLI fixture…'`). Unit 0: A=`economic_functions=['exchange']`, B adds `mechanisms=['amm']`. That yields **374 / 1**, which the log prints on every OK build/check.
- Live `coverage.json` is **346 / 29**. The log never mentions 346 or 29.
- README reproduce runs `build --out /tmp/corpus-build-NEW`, then `check --repo .` (default **live** `generated/`), then `test_corpus_normalize.py` (synthetic). Readers can treat 15 passing tests as a check of the integration corpus.
- **Fix:** Split the docs: (a) `check --data` on the live tree is the integration check; (b) the unittest suite is an isolated CLI regression and must state 374/1 is synthetic. Do not cite `cli-tests.log` as coverage evidence.

**2. Advertised `INTERSECTION_UNRESOLVED` is not discriminated**
- File: `scripts/test_corpus_normalize.py:45-47, 79-94, 109`
- The only disagreement is `[]` vs `['amm']`. Intersection is `[]`. The positive test only asserts `units[0].facets.mechanisms == []` and the substring `1 unresolved differences`. That same payload is produced by “intersection”, “prefer annotator A”, or “clear the facet on conflict”. Union is rejected (`['amm']` would fail); **retain-intersection is not**.
- `false agreement` only flips `rule` to `AGREE` and accepts diagnostic `'adjudications'` (`test_derived_corruptions:109`). The log’s actual line is `/adjudications/2/rule` — this run was the right path; the assertion would also accept any other adjudications mismatch.
- **Fix:** Fixture where A=`['exchange']`, B=`['exchange','amm']`. Assert unit labels `['exchange']`, rule `INTERSECTION_UNRESOLVED`, unresolved symmetric difference `['amm']`. Assert the full FAIL line for the false-AGREE case.

**3. Advertised `check --data DIR` is never invoked**
- File: `scripts/test_corpus_normalize.py:55-61`; README:438-439
- `cli()` adds `--data` only when `out is not None`. No test calls `check` that way. Default check happened to hit the temp `generated/` in this log (`374 / 1`, paths under `/tmp/corpus-cli-…`).
- **Fix:** `self.cli('check', out=self.out)` and `self.cli('check', out=second)` after the second build.

## Important (in scope, not future work)

**Coarse `assertIn` needles.** Several cases pass on the wrong failure: `'schema'` (dropped source, omitted unit, holdout, unknown facet, extra field), `'units'` (wrong mapping; also appears in many messages), `'source_records'`, `'adjudications'`, `'coverage.json'` (newline vs `unresolved_differences=0` are indistinguishable). This log’s FAIL/BLOCKED text is more specific than the tests require. **Fix:** assert the exact `FAIL:` / `BLOCKED:` strings from this log.

**Identity corruptions are weaker than annotation corruptions.** `test_identity_corruptions:181-191` has no `subTest` and does not assert the output dir was not created (`test_annotation_corruptions:151` does). **Fix:** mirror annotation cases.

**Partial-source test depends on manifest order.** `test_partial_source_content…:175-179` updates `files[0]`. This log’s `source row count mismatch` implies `files[0]` was lane1. **Fix:** select the lane1 entry by path.

## Not bugs in these attachments

- Isolation from live annotations is explicit in the test docstring; that design is fine if it is not sold as integration evidence.
- In this parent log, the 15 methods all ran; exit 0/1/3 and the printed FAIL/BLOCKED lines match the README’s exit contract for those cases.
- Positive path rejects union on unit 0 mechanisms; read-only `check` snapshot; second-build byte compare; missing/empty/unreadable; source hash vs row-count; path/symlink escape; duplicate JSON keys; schema `$ref`.
- `coverage.json` limits match the stated sprint bounds (all development, 0 holdouts, 0 deployments, agreement ≠ accuracy). README does not claim recovered proposal CSV/schema or 31/72 stats.
- 72→75 appears in both the synthetic OK lines and live coverage; that is reconstruction size, not annotation content.

## Future work (out of this scope)

Deployments, remaining bundles, publisher authentication, legal-entity identity of shared labels, holdouts, proposal statistics, semantic accuracy of GPT-6 labels. Model agreement is not truth. Hashes bind these four files in this commit; they do not authenticate a publisher.

**Assessment:** CLI regression is a real isolated harness; the attached log is consistent with that harness. It does not verify live annotations or lock `INTERSECTION_UNRESOLVED`. Keep blockers 1–3 in this increment; do not defer them as “later source acquisition.”
