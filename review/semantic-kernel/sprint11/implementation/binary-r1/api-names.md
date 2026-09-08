# Binary conversion API names

F03 and the correspondence proofs must use these Observation definitions.
Do not copy them into Tests. Do not import `DefiKernel.Nary.BinaryCorrespondence`
into Examples, Tests, Audit, or any other runtime root.

Roster (ordered `[left, right]`, named to avoid clashing with `Examples.binaryRoster`):

- `binaryParticipants : Roster Parallel.BranchId`

Branch / boundary:

- `binaryLeft`, `binaryRight`
- `ofBinaryBranches`
- `toBinaryBoundaries`, `ofBinaryBoundaries` (identity on `ParallelBoundary`)

Local / attempt / machine / result (every stored field, including raw worlds and receipts):

- `toBinaryLocals`, `ofBinaryLocals`
- `toBinaryAttempt`, `ofBinaryAttempt`, `toBinaryAttempts`, `ofBinaryAttempts`
- `toBinaryMachine`, `ofBinaryMachine`
- `toBinaryResult` (schedule errors go through the diagnostic projection)

Diagnostic projection (recomputes **both** counts from original branches and schedule;
the n-ary first-mismatch payload is not copied):

- `projectBinaryCounts`
- `projectScheduleMismatch`
- `projectAdmissionFailure`
- `projectAdmitSuccess`

Existing binary executor wrappers (same conversions the proofs relate):

- `existingBinaryAdmit`
- `existingBinaryAdvance`
- `existingBinaryContinue`
- `existingBinaryPrefix`
- `existingBinaryRun`

Boolean agreement (full field comparison, not `Interleaving.observationsEqual`):

- `interleavingMachineEq`, `interleavingResultEq`
- `binaryMachineAgrees`, `binaryResultAgrees`
- `binaryAdmitAgrees`, `binaryAdvanceAgrees`, `binaryContinueAgrees`
- `binaryPrefixAgrees`, `binaryRunAgrees`

Proofs of those Bools being true, plus start/advance/continue/admit/run simulation,
are in `DefiKernel.Nary.BinaryCorrespondence`.
