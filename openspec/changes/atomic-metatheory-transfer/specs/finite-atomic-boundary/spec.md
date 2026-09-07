## Purpose

Preserves the accepted first-abort and typed clearing behavior over an actual finite invocation-stream executor.

## ADDED Requirements

### Requirement: FA01 Ordered full admission

Finite Atomic admission SHALL preserve catalog, full-branch, policy and schedule validation order, with principal coverage distinct from stream identity.

#### Scenario: A01 Several admission failures are present

- **WHEN** several admission failures are present
- **THEN** the exact first failure follows the global roster/policy order, including unreachable suffixes.

#### Scenario: A02 Two lanes share domain and asset but have different vaults

- **WHEN** two lanes share domain and asset but have different vaults
- **THEN** policy admission rejects the duplicate key and retains both ordered lane values.

#### Scenario: A03 Two streams use the same authenticated principal

- **WHEN** two streams use the same authenticated principal
- **THEN** obligations share that principal partition, while outputs and local indices remain stream-specific.

### Requirement: FA02 Single actual step and absorbing abort

Each active atomic step SHALL call the actual finite dispatcher once and update from only its appended attempt; after an abort the entire machine SHALL remain unchanged.

#### Scenario: A04 An actual kernel error occurs

- **WHEN** an actual kernel error occurs
- **THEN** the first participant/index/global pre-step position/invocation/reason are retained and no receipt update occurs.

#### Scenario: A05 A successful receipt violates lane supply

- **WHEN** a successful receipt violates lane supply
- **THEN** speculation and owed update are retained diagnostically before the exact supply abort.

#### Scenario: A06 Tokens follow an earlier abort or a pre-abort skip occurs

- **WHEN** tokens follow an earlier abort or a pre-abort skip occurs
- **THEN** post-abort tokens change nothing, while the pre-abort skip advances position without inventing a receipt.

### Requirement: FA03 Receipt-derived signed settlement

Outstanding obligations SHALL equal the actual successful-receipt fold partitioned by lane and authenticated principal, with exact-zero clearance and ordered nonzero residuals.

#### Scenario: A07 A nonempty draw7/return7 sequence runs

- **WHEN** a nonempty draw7/return7 sequence runs
- **THEN** cash3/owed7 is visible after draw and exact zero clearance permits commit after return.

#### Scenario: A08 Under-return6 or funded over-return8 occurs

- **WHEN** under-return6 or funded over-return8 occurs
- **THEN** residual+1 or credit−1 is preserved; credit clears only after the actual compensating draw1.

#### Scenario: A09 Another principal repays the borrowed amount

- **WHEN** another principal repays the borrowed amount
- **THEN** scalar net zero does not clear separate+7/−7 obligations; cross-asset/domain entries remain distinct.

### Requirement: FA04 Publication and rollback

Refused and aborted results SHALL publish exact entry world/store, no committed history and zero committed supply; successful finish SHALL publish one outer event.

#### Scenario: A10 A tentative mint/output is followed by abort

- **WHEN** a tentative mint/output is followed by abort
- **THEN** public world/store roll back and tentative supply/output are absent from publication.

#### Scenario: A11 An admitted empty batch or funded nonempty batch clears

- **WHEN** an admitted empty batch or funded nonempty batch clears
- **THEN** both publish exactly one event with their own complete label/schedule/inner observations.

#### Scenario: A12 A public follow-up starts after abort

- **WHEN** a public follow-up starts after abort
- **THEN** it starts from publicWorld and fresh history and cannot consume an aborted snapshot.
