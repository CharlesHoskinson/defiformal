## Purpose

Resolve stable globally qualified balance resources and preserve initialized typed equality constraints over actual execution prefixes.

## ADDED Requirements

### Requirement: Exact typed global binding query

The system SHALL resolve endpoints through their exact component and resource-export IDs, validate the actual catalog first, and then process input edges in original order. Per edge it MUST check left resolution, right resolution, domain, asset and balance in that order, returning the exact first failure with zero-based index and relevant names, cells or amounts. A Boolean success projection MUST agree with the exact query.

#### Scenario: GB01 Exact qualified identity
- **WHEN** two valid components both export local port0 but their USD balances are4 and5
- **THEN** the query compares distinct actual cells and reports unequal at the original edge index with amounts4,5

#### Scenario: GB02 Missing endpoint kind and side
- **WHEN** an edge refers to absent component99 or absent port99 in existing component0
- **THEN** the query distinguishes missingComponent from missingPort and records the exact left/right endpoint and edge index

#### Scenario: GB03 Dimensional mismatch
- **WHEN** equal numeric balances are linked across USD/EUR or home/away
- **THEN** assetMismatch or domainMismatch is returned; domainMismatch wins when both differ

#### Scenario: GB04 Failure precedence
- **WHEN** edge0 has unequal resolved balances and edge1 has a missing endpoint
- **THEN** edge0 unequal is returned; within an edge missing left wins over missing right

#### Scenario: GB05 Catalog precedes emptiness
- **WHEN** a duplicate-component catalog is queried with an empty edge list
- **THEN** configuration failure is returned; the same empty list succeeds for a valid catalog

#### Scenario: GB06 Outputs are not live resources
- **WHEN** a qualified ID names only a historical output/input port, not a resource export
- **THEN** resource resolution returns missingPort even if a history value exists

### Requirement: Binding meaning and actual alias distinction

The system SHALL define agreement as successful typed resolution plus equality for every global edge and prove query acceptance equivalent to catalog validity and that proposition. Existing imports MUST retain exact export-cell identity; distinct exported cells MUST NOT be treated as aliases merely because balances match.

#### Scenario: GB07 Positive distinct-cell equality
- **WHEN** A and B resolve to distinct USD cells both containing5
- **THEN** agreement holds at entry, with no implied future write discipline

#### Scenario: GB08 One-sided accepted write
- **WHEN** actual one-sided debit1 changes A5 to4 while B remains5
- **THEN** agreement becomes false after successful execution

#### Scenario: GB09 Existing resource alias
- **WHEN** a valid import references canonical export A and actual transfer changes its cell6 to4
- **THEN** both views read the same exact cell4 without declaring a duplicate export

#### Scenario: GB10 Self binding
- **WHEN** a self-edge references a resolving resource in a valid catalog
- **THEN** it succeeds in every state; an unresolved self-edge still reports its endpoint error

### Requirement: Initialized actual binding preservation

The system SHALL derive edge preservation from initialized equality and equal actual receipt effects, then prove all global bindings at every sequential and binary shared prefix from initialization and locally quantified actual-step obligations. Refusal/skip identity and administrative balance identity MUST be included; group lifting MUST use accepted actual M1 simulation. Arbitrary-entry sequential/group preservation MUST retain supplied prefix data and use actual continuation/suffix induction plus Metatheory.runGroup_eq_continueRun, without inventing a TraceSound genesis witness.

#### Scenario: GB11 Nonzero paired effects
- **WHEN** one actual receipt debits1 from each of A5/B5 and credits2 elsewhere
- **THEN** A=B=4 after that step, and initialized equality holds at every prefix

#### Scenario: GB12 Sequential refusal retained
- **WHEN** the paired step is followed by actual insufficient-funds refusal and stopped suffix
- **THEN** the binding remains4=4 with exact successful prefix and first refusal

#### Scenario: GB13 Shared peer progression
- **WHEN** F17 runs under left,right,left and companion F19 runs under left,left,right
- **THEN** A=B=3 in both final states; F19 retains the exact left refusal at4/4/2 before the right peer progresses, with both actual histories and the unchanged store

#### Scenario: GB14 Administrative or skipped step
- **WHEN** an actual administrative transition or failed/exhausted-stream identity occurs
- **THEN** balance bindings remain true while actual capability-store effects are retained

### Requirement: Global constraint algebra and scope

The system SHALL prove agreement over list concatenation is conjunction, and prove edge-reorientation, duplicate idempotence, permutation and associativity laws at proposition/query-success level. It MUST transfer initialization and step obligations to prefix invariants while preserving the complete global edge set. It MUST NOT claim identical first-error diagnostics after reordering or participant regrouping from these algebraic laws.

#### Scenario: GB15 Union and orientation
- **WHEN** global edge lists are concatenated, reassociated, duplicated or each edge reversed
- **THEN** agreement has the corresponding conjunction/equivalence law and initialized prefix obligations transport

#### Scenario: GB16 Global skip edge
- **WHEN** A=C is wholly inside one side of the cut {A,C}|{B}, with amounts4 and5
- **THEN** the actual global query rejects it; the deliberately empty cut-extracted list succeeds and therefore does not represent the same constraint

#### Scenario: GB17 Diagnostic distinction
- **WHEN** two failing edges are reordered or a failing edge is reversed
- **THEN** success equivalence holds but exact first index/side/amount payloads may change as specified

### Requirement: Symmetric closure is sufficient only

The system SHALL prove equal symmetric closures imply equivalent global agreement predicates, and provide a typed valid-catalog counterexample to necessity using transitive equality. It MUST NOT advertise symmetric-closure equality as a complete semantic equivalence checker.

#### Scenario: GB18 Sufficient closure criterion
- **WHEN** two global edge sets have equal symmetric closures
- **THEN** their agreement predicates are equivalent for every state under the same catalog

#### Scenario: GB19 Redundant transitive edge
- **WHEN** E=[A=B,B=C] and F=E+[A=C] use three resolving same-dimension resources
- **THEN** agreement predicates are equivalent for every state although symmetric closures differ

#### Scenario: GB20 Independent omitted edge
- **WHEN** an independently constraining A=B edge is omitted at balances4,5,5
- **THEN** the query can change from failure to success; redundancy is not inferred from omission alone
