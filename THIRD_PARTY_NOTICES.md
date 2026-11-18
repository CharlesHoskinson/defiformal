# License scope and retained notices

## Authorized project license

DeFiFormal's original code and Lean proofs are distributed under the
[Apache License, Version 2.0](LICENSE). The
[recorded user authorization](review/semantic-kernel/competitive-landscape-adoption-20261117/LICENSE-AUTHORIZATION.json)
also authorizes the selected 168 IOG benchmark adapter files under Apache-2.0.
Their exact scope is the [adapter provenance inventory](benchmarks/competitive-landscape/PROVENANCE.json),
not the complete assessment repository. Existing notices and source bytes remain
unchanged.

The source headers in `lean/Defialgebra/Permission.lean`, `Extremal.lean`,
`Nary.lean`, `Independence.lean`, `Interface.lean` and `FlowPolarity.lean` identify
Charles Hoskinson in their 2026 copyright notices. Those notices, including
retained "All rights reserved" wording, are preserved. Files without a named
holder are left unnamed here. Repository location, authorship attribution and
AI-assistance records are not used to assign copyright ownership.

The IOG Technical Intelligence assessment retains attribution for the benchmark
adapter work. This attribution does not assert that IOG is its copyright holder.
The selected inventory contains six unchanged native DeFiFormal snapshots:
`Core.lean` and `Examples.lean` in the transfer and workflow adapters, and
`Typed/Types.lean` and `Typed/Expr.lean` in the swap adapter. Their bytes match
DeFiFormal revision `2b60322cdc8c98f0e0c27cab3b2d6dcc824c3eda`. No additional
third-party source copy was identified within that selected inventory.

## Dependencies and historical evidence

All retained historical third-party snapshots are excluded from the project
Apache-2.0 grant. The project license does not replace the terms of third-party
dependencies, source captures, excerpts, papers, datasets or other historical evidence. Such
material retains its source notices and provenance wherever it appears,
including copied records under `review/`, `research/`, `corpus/` and `docs/`.
A missing or incomplete license record does not create an Apache-2.0 grant for
third-party material.

[Lake's dependency lock](lean/lake-manifest.json) records exact dependency
revisions. The inspected pinned license files for mathlib, plausible,
LeanSearchClient, importGraph, ProofWidgets, Aesop, Qq and Batteries identify
Apache-2.0; Cli's license identifies MIT and retains its own copyright notice.
These dependency terms and individual source notices remain in force.

The following non-exhaustive index identifies retained historical exceptions.
The linked texts, their parameters and individual file headers govern those
copies; this table does not replace them or determine copyright ownership.

| Retained material | Terms recorded with that material |
| --- | --- |
| [P17 vault source capture](review/semantic-kernel/program-execution-20260908/p17-source-acquisition/capture/LICENSE) and its historical review copies | GNU AGPL v3 text. |
| [P22 Curve source capture](review/semantic-kernel/program-execution-20260908/p22-source-entry-preparation/upstream/LICENSE) and its review copy | Rights reserved; the recorded text grants no reproduction or distribution rights except where a specific source header provides otherwise. |
| [P23 Liquity V2 source](review/semantic-kernel/program-execution-20260908/p23-source-entry-inspection/upstream/LICENSE), including its contracts license | Business Source License 1.1 with recorded parameters and change provisions. |
| [P23 V1 source](review/semantic-kernel/program-execution-20260908/p23-v1-source-entry-preparation/upstream/LICENSE), including its contracts package | GNU GPL v3 text. |
| [P24 source](review/semantic-kernel/program-execution-20260908/p24-source-entry-preparation/upstream/LICENSE) | GNU GPL v2 text. |
| [P25 Balancer source](review/semantic-kernel/program-execution-20260908/p25-balancer-source-preparation/source/LICENSE) and [Permit2 dependency](review/semantic-kernel/program-execution-20260908/p25-balancer-dependency-preparation/permit2/metadata/LICENSE) | GPL v3 and MIT texts respectively. |
| [P26 IBC source](review/semantic-kernel/program-execution-20260908/p26-ibc-source-preparation/source/LICENSE) and [NOTICE](review/semantic-kernel/program-execution-20260908/p26-ibc-source-preparation/source/NOTICE) | Apache-2.0 with the retained upstream NOTICE. |
| [P27 GMX source](review/semantic-kernel/program-execution-20260908/p27-gmx-source-preparation-attempt2/source/LICENSE) | Business Source License 1.1 with its recorded use grant and change provisions. |
| [P28 depeg source](review/semantic-kernel/program-execution-20260908/p28-depeg-source-preparation/source/LICENSE), [esusfarm source](review/semantic-kernel/program-execution-20260908/p28-esusfarm-source-preparation/source/LICENSE) and their GIF dependency records | Apache-2.0 texts; individual source notices remain. |
| [P28 OpenZeppelin](review/semantic-kernel/program-execution-20260908/p28-depeg-dependency-preparation/source/openzeppelin/LICENSE) and [Chainlink](review/semantic-kernel/program-execution-20260908/p28-depeg-dependency-preparation/source/chainlink/LICENSE) dependencies | MIT texts with retained upstream copyright notices. |
| [P31 Midnight dependency records](review/semantic-kernel/program-execution-20260908/p31-zkir-dependency-source-preparation/) | Retained Apache-2.0, MIT and dual-license records; see each package's `LICENSE*` and `COPYING.md`. |
| [Concentrated-liquidity source capture](review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/upstream/LICENSE), [interfaces](review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/upstream/contracts/interfaces/LICENSE) and [library records](review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/upstream/contracts/libraries/) | Retained Business Source License 1.1, GPL v2 and MIT texts, according to the specific source file. |

Historical license copies remain evidence of their captured revisions. This
release preparation does not relicense them or infer a present license conversion
from a recorded change date. Preserve the actual source terms and notices when
reusing material.
