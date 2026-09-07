All 14 production mutants compiled and were discriminated at `c880acf62944746ff9a376afc0c0050702f037f7`. The unchanged control had 148/148 true comparisons. Each variant emitted the same 148 unique names, made its designated observation false and retained both global positives. Runner exit 0.

Eight mutations change actual recursive execution; six change the production comparator on explicitly synthetic observer pairs. These are separate evidence classes. All imported proof suffixes remain intact; only Metatheory proof tails are projected away.

| Mutation | Designated false | False count |
|---|---|---:|
| entry-world-at-seq | metatheory.group.world-chain | 27 |
| entry-store-at-seq | metatheory.group.store-chain | 4 |
| reset-history-at-seq | metatheory.group.history-chain | 25 |
| reset-index-at-seq | metatheory.group.index-chain | 27 |
| clear-failure-at-seq | metatheory.group.refusal-absorption | 10 |
| skip-second-child | metatheory.group.child-executed | 27 |
| reverse-child-order | metatheory.group.ordered | 27 |
| zero-boundary-index | metatheory.group.boundary-index | 16 |
| omit-observed-ledger | metatheory.observe.world-diff | 1 |
| omit-observed-store | metatheory.observe.store-diff | 2 |
| omit-observed-history | metatheory.observe.output-diff | 6 |
| omit-observed-failure | metatheory.observe.failure-diff | 5 |
| omit-observed-receipt | metatheory.observe.receipt-diff | 16 |
| omit-observed-index | metatheory.observe.next-index-diff | 1 |

Both global positives are `metatheory.positive.single-leaf` and `metatheory.positive.equal-observation`. All 14 supplemental sibling observations passed; six overlap the global equal-observation control, as explicitly recorded. This adds no new runner schema or behavior.

All 91 pairwise false-inventory overlaps are recorded in summary.json. Identical inventories: entry-world-at-seq / reset-index-at-seq. Overlap can prevent identification of a particular fault from the false labels alone.

Exact command, Git/source/spec/driver/harness hashes, complete source inputs/projections and raw logs are preserved. The production command explicitly uses a 600-second command timeout. Run UTC and inherited labeled-command/variant elapsed fields are retained; no per-command UTC or binding-call timing is claimed.
