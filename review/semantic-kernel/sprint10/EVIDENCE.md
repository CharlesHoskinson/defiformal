# Operational interface evidence

Accepted source: `b165bc586080d668f689fbc18dfa09eb8739d688`.
Native Grok and Fable 5.1 medium accepted the same source and evidence with
limitations. [Adjudication](ADJUDICATION.md) records the findings and dispositions.

The Interface package observes finite typed ledger regions and globally qualified
live resource bindings. Its proofs lift actual receipt accounting and initialized
local invariants through sequential execution, recursive sequential groups and
binary shared interleavings. It adds no replacement executor or admission rule.

| Evidence | Actual result |
|---|---|
| Lean integration | 18 successful commands; 99 new runtime labels, 987 including earlier audits |
| Imported theorem inventory | 310 constants: 144 explicit and 166 generated |
| Explicit theorem categories | 110 generic, 32 reference instances, 2 classified counterexamples |
| Supplemental declarations | 356; zero forbidden axioms across both inventories |
| Production mutations | 14 compiling detections; 15 complete inventories of 99 observations |
| Positive controls | 30 global-positive observations and 14 separately reconciled siblings |
| Runner controls | 65 actual CLI cases: 10 exit 0, 5 exit 1, 50 exit 3 |
| Retained earlier suites | 13 actual c880 suites plus Sprint 9's actual eec499d mutation/control runs, with checked relevant dependency equivalence |

[Integration](integration-r1/verification.json) includes direct elaboration of
each runtime and proof audit root. Its full `lake build` is incremental and uses
Lake's existing hash traces; a from-clean rebuild of all Interface proof modules
is not claimed. The mutation control compiles the complete runtime projection
from source. [The full proof inventory](proof-inventory-r1/proof-inventory.json)
contains elaborated statements, source identities and transitive axiom sets.
Computational fixture proofs use kernel reduction, including `decide +kernel`.

The 99 names are an observation inventory, not 99 independent semantic cases.
`interface.catalog.private-total` intentionally repeats
`interface.catalog.valid`: the default `cfg` is the private-total catalog.
The alias documents that fixture role and is not an additional independent
catalog scenario. Financial worlds, receipts, stores, cursors and attempts are
compared against independently constructed expected records over all 20 cells.

The [mutations](mutations-r1/REPORT.md) alter region, receipt-effect and binding
queries. The financial fixtures call the existing executor, but these mutations
do not change that executor's authority or admission guards. The runner enforces
the two global positives; the [current sibling matrix](acceptance/sibling-matrix.json)
separately reconciles each designated sibling with actual output. The original
reviewed matrix retains its historical pending-status wording. False-observation
overlap is recorded and does not establish unique fault identification. In
particular, dropping a one-edge query can preserve a positive sibling by making
the query empty.

[CLI controls](implementation/runner-controls-r1/REPORT.md) are synthetic driver
and compiler checks. Compile failures and missing or incomplete evidence receive
blocked status, not financial mutation credit. [Root artifact rechecking](acceptance/root-artifact-recheck.json)
independently reparses all 1,485 saved production observations and all 65 CLI
log/path/hash/output/exit/message records. It is not another execution.

[Legacy dependency equivalence](implementation/legacy-dependency-equivalence.json)
retains the 13 suites' actual c880 revision. [The Sprint 9 carry record](acceptance/sprint9-regression-carry.json)
separately binds its 14 mutations and 65 controls to their actual eec499d revision.
Neither record relabels an old execution. The initial legacy checker assertion
failure is preserved; its correction adds the new root import to the explicit
allowed-change list while retaining every per-suite equality check.

The [57-scenario map](coverage-measured-r1/scenario-map.json) records measured
source and execution evidence. Its author-snapshot notes preserve earlier pending
wording; current native acceptance is recorded in the adjudication, and actual
delivery/archive actions have their own records.

Preservation requires initialization, explicit local inductive rules and, for
declared totals, write confinement, regional neutrality, value support and write
exclusion. Binding preservation requires equal actual endpoint effects. Success
algebra does not preserve ordered first-failure payloads. Symmetric closure
equality is sufficient, not necessary. Fixed literal-party fixtures do not
establish a caller-dependent rule for arbitrary principals. There is no new
runtime witness of the private catalog refusing the exposed-total operation.

The model retains exact rational arithmetic and trusted configuration, capability
store and boundary inputs. It claims no general finite-participant executor,
atomic boundary reassociation, deployed protocol fidelity, untouched evaluation,
liveness, confidentiality or unconditional solvency.
