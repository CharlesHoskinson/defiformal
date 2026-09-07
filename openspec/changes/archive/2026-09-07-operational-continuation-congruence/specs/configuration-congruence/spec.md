## Purpose

Specify explicit configuration support premises that preserve actual old-program execution and existing operator admission behavior.

## ADDED Requirements

### Requirement: Explicit configuration agreement

Configuration agreement SHALL be a proof premise over a fixed identity universe, with both complete catalogs valid, equal registry templates for every supported operation, equal full component/interface lookup results for every supported invocation pair, and equal trusted domain administrators. Support SHALL include grant-only operation references and every static suffix. Theorems SHALL bind shared identity types and corresponding instances once for both configurations; this SHALL NOT be a heterogeneous type/instance equality field of the agreement proposition.

#### Scenario: Unrelated valid declarations

- **WHEN** an unrelated operation/component is added while both catalogs remain valid and every supported lookup and administrator agrees
- **THEN** a nonempty supported old program retains exact behavior

#### Scenario: Grant-only operation support

- **WHEN** an issued grant references an operation that no invocation in the program calls
- **THEN** that operation remains in the explicit configuration support obligations

#### Scenario: No certificate checker claim

- **WHEN** a theorem is applied using configuration agreement and supported-program premises
- **THEN** the evidence records those premises rather than inventing a new runtime certificate or program-label checker

### Requirement: Exact single-step congruence

Under explicit agreement and support, old and new configurations SHALL give equal actual single-step results for the same full world, authenticated boundary, absolute index and frozen history. Equality SHALL cover success and every refusal, including receipt extraction and administrative failures.

#### Scenario: Invoked success and refusal

- **WHEN** the supported invocation succeeds or fails under the old configuration
- **THEN** the new result has the same world, request/evaluated receipt, outputs or exact failure reason

#### Scenario: Issue and revoke

- **WHEN** supported administration executes against the same current complete store
- **THEN** fresh IDs, tombstones, authorization results and all administrative refusals are equal

#### Scenario: Absent old lookup

- **WHEN** both agreeing supported lookup results are absent
- **THEN** both executions return the same actual unknown-operation or interface refusal

### Requirement: Supported execution lifting

The agreement theorem SHALL lift through sequential continuation and recursive groups, then through the existing invocation-only Parallel, Interleaving and Atomic operators. Every static invocation SHALL be supported; the same boundaries, initial whole world, branch order, schedule, label and Atomic policy SHALL be used.

#### Scenario: Unreachable static suffix

- **WHEN** an early invocation refuses before a later submitted invocation
- **THEN** the later invocation remains covered by the static support premise and structural admission retains its original precedence

#### Scenario: Sequential administration lifting

- **WHEN** issue, invocation and revoke cross nested group boundaries
- **THEN** both configurations return identical complete cursors

#### Scenario: Parallel and interleaved lifting

- **WHEN** supported invocation-only branches use their existing parallel or scheduled shared execution
- **THEN** both admission results and executed results are equal, including exact refusals and histories

#### Scenario: Atomic lifting

- **WHEN** the same supported atomic request commits, refuses admission or aborts
- **THEN** both configurations preserve that exact result, supplied schedule, diagnostic table and public publication behavior

### Requirement: Configuration counterexamples

The evidence SHALL include actual execution differences establishing materiality of the listed agreement or identical-world premises when omitted. It SHALL NOT claim minimality or necessity of full registry-template equality or all-domain administrator equality, which are stronger sufficient conditions. Global catalog validity SHALL remain a premise even for newly added declarations outside old support.

#### Scenario: Changed old registry

- **WHEN** an old supported template changes guard or compatible delta/write behavior while signature/output-domain contracts and remaining applicable premises hold
- **THEN** a concrete old invocation yields a different actual result

#### Scenario: Changed component declaration

- **WHEN** an old component access or output declaration changes without preserving its complete lookup result while export/import/private-cell validity remains intact
- **THEN** a concrete old invocation yields a different access result or frozen output

#### Scenario: Invalid added catalog

- **WHEN** a new duplicate or invalid component makes the complete new catalog invalid
- **THEN** new execution refuses configuration even when old referenced lookups remain unchanged

#### Scenario: Changed grant operation domain

- **WHEN** the domain of a registry operation with no declaring catalog component changes, while invoked lookups and both catalog-validity checks still agree
- **THEN** actual issue success versus operation-domain refusal differs

#### Scenario: Changed trusted administrator

- **WHEN** the relevant domain administrator changes
- **THEN** actual issue or revoke authorization differs

#### Scenario: Changed initial store

- **WHEN** only the initial capability entries differ before authorized issue
- **THEN** the exact returned fresh ID differs, refuting a ledger-only extension premise
