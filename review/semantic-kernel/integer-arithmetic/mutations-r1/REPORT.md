# Arithmetic production mutation evidence

Actual execution `ddf1ac0e50f2e032385664a0965bab59eef91ea3`: unchanged control and all 12 mutants compiled, with 45 unique comparisons each (585 total). All 12 designated comparisons became false. Both global positives remained true in all 13 variants (26 results), and all 12 planned sibling results stayed true.

The suite took 147.311001 seconds; the unchanged projection command took 11.698353 seconds. Each command limit was 600 seconds. Exact commands, run UTC, labelled command elapsed times, raw logs, source captures, Git objects and hashes are preserved. No per-command UTC or unlogged binding-call timing is inferred.

The projection contains nine Arithmetic runtime roots and four retained Typed dependencies, plus three pinned configuration inputs. Only Arithmetic proof suffixes are stripped; imported Typed proofs remain. ProofAudit and Verify are separate proof roots.

M04 changes the shared divideNat denominator check and also falsifies F45. M05/M06/M10 propagate into quote-derived reference fixtures; M12 edits the actual collector effect consumed by Typed.execute. The matrix records every false result; overlap does not identify a unique fault.

The original M12 development-site hash predates a Reference proof-tail extension. The checker retains that record and proves exact runtime-prefix equality between the captured old bytes and the frozen source. qualification-r4.json records both hashes. No mutation needle or expected result changed.

This is mechanical evidence qualification. Native scientific review and scoped delivery remain pending.
