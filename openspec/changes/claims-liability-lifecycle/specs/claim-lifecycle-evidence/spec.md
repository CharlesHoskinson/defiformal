## Purpose

Defines the bounded fixed-claim lifecycle contract described in design.md.

## ADDED Requirements

### Requirement: CE01 Use independent full-state financial fixtures

The evidence SHALL provide24 named literal fixtures with complete finite state/claim/receipt expectations and distinct authority, default, amount, payment and observation negatives.

#### Scenario: E01 The fixture suite executes

- **WHEN** the fixture suite executes
- **THEN** every ID is nonempty, unique and backed by a literal expected result outside the mutated runtime path.

#### Scenario: E02 A wrong debtor, default erasure, overpayment or missing ledger payment candidate executes

- **WHEN** a wrong debtor, default erasure, overpayment or missing ledger payment candidate executes
- **THEN** the relevant false financial oracle detects it; another guard or compiler failure is not mislabelled detection.

### Requirement: CE02 Run actual mutations and honest CLI controls

The gate SHALL execute20 named source mutations plus separately enumerated actual CLI controls with exact source/tool/output identity and exit0/1/3 semantics.

#### Scenario: E03 An actual compiled mutant produces a false named result

- **WHEN** an actual compiled mutant produces a false named result
- **THEN** the gate records semantic detection separately from successful process exit.

#### Scenario: E04 Source drift, timeout, malformed/empty/duplicate evidence or output-path conflict occurs

- **WHEN** source drift, timeout, malformed/empty/duplicate evidence or output-path conflict occurs
- **THEN** the attempt is blocked and preserved without overwriting prior evidence or awarding mutant credit.

### Requirement: CE03 Require proof inventories and independent accepted gates

Implementation SHALL require the frozen nonauthor GPT-6/native Fable planning gate and final native Grok/Fable source/evidence review, with actual proof statements and explicit dependencies.

#### Scenario: E05 Only this author draft or an unavailable reviewer exists

- **WHEN** only this author draft or an unavailable reviewer exists
- **THEN** implementation and acceptance remain false.

#### Scenario: E06 All scoped checks and required reviews pass

- **WHEN** all scoped checks and required reviews pass
- **THEN** the parent records exact delivery while conditional claims, async lifecycle, integer/deployment/provenance work remain open.
