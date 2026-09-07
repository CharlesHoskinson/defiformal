## Purpose

Describe component boundaries and typed connections so workflows can exchange
values and share resources without silently expanding access or proof claims.

## ADDED Requirements

### Requirement: Stable typed port declarations
The system SHALL identify ports by stable component and port identities, distinguish
value inputs, value outputs, and resource access, and reject duplicate identities,
unknown operations, ambiguous operation ownership, and incompatible signatures.
Selected-cell outputs SHALL remain within the registered operation's domain.

#### Scenario: Valid declared operation
- **WHEN** a uniquely owned registered operation has inputs matching its signature and valid selected-cell outputs
- **THEN** its interface is accepted and every output has the selected cell's asset unit

#### Scenario: Invalid declarations
- **WHEN** declarations contain duplicate port identities, an unknown operation, ambiguous ownership, or a signature mismatch
- **THEN** configuration validation refuses before any workflow step executes

#### Scenario: Cross-domain snapshot
- **WHEN** an operation declares a selected-cell output in a different domain
- **THEN** configuration validation refuses even if the component can read that cell

### Requirement: Private ownership and explicit shared access
The system SHALL enforce disjoint private ownership and explicitly matched shared
resource imports and exports, including exact cell identity, domain, asset, and
access rights. Private cells SHALL NOT be accessible as another component's
resources. A component SHALL access only its permitted reads and writes.
Shared cells SHALL have unique exporters, and each component's exported and
imported cells SHALL be disjoint. Export rights SHALL also constrain the exporter.

#### Scenario: Overlapping ownership
- **WHEN** two components claim the same private cell or another component imports that cell as shared
- **THEN** configuration validation refuses without changing the world

#### Scenario: Conflicting exports
- **WHEN** two export declarations claim the same cell or a component imports a cell it also exports
- **THEN** configuration validation refuses instead of combining conflicting permissions

#### Scenario: Authorized shared use
- **WHEN** a component accesses an explicitly exported and matching shared resource within its granted access and kernel authority
- **THEN** the interface boundary permits the operation

#### Scenario: Read-only import
- **WHEN** a component attempts to write a resource imported for reading only
- **THEN** interface validation refuses the step even if a debit capability is otherwise valid

#### Scenario: Funded foreign-private interference
- **WHEN** an operation targets another component's funded private cell with an otherwise valid live debit capability
- **THEN** the interface boundary refuses without changing the world

#### Scenario: Undeclared reads
- **WHEN** a guard, effect, supply expression, output selection, or unselected expression branch references a cell outside permitted read access
- **THEN** the interface boundary rejects the declaration or refuses the step before delegated financial execution

### Requirement: Typed values do not transfer resource rights
The system SHALL route literal values and outputs of earlier successful steps only
when their units match the receiving inputs. Value transfer SHALL NOT create
resource aliases, authorize writes, or move balances by itself.

#### Scenario: Valid snapshot binding
- **WHEN** a USD output from an earlier successful step is bound to a USD input
- **THEN** the receiving operation uses that recorded value and still requires its own resource and capability permissions

#### Scenario: Wrong unit or unavailable output
- **WHEN** a binding has the wrong unit or names an unknown, forward, or unavailable output
- **THEN** the step refuses before financial execution and produces no output

### Requirement: Explicit semantic contract premises
The system SHALL represent initialization, assumptions, invariants, and guarantees
as explicit proof obligations. Arbitrary semantic predicates SHALL NOT be treated
as automatically checked by structural validation or as proved by declaration.

#### Scenario: Initialized invariant reasoning
- **WHEN** an initial-state witness, required boundary assumptions, and local invariant-preservation proofs are supplied
- **THEN** the corresponding workflow invariant theorem is available with those premises recorded

#### Scenario: Missing external assumption
- **WHEN** a declared guarantee relies on observation truth without a proof or supplied premise
- **THEN** the guarantee remains conditional and is not reported as unconditionally verified
