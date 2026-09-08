## Purpose

Reports actual historical JavaScript executions with exact inputs, nonempty counters, honest failure classification and explicit enumeration bounds.

## ADDED Requirements

### Requirement: HE01 Capture actual unchanged execution

The evidence system SHALL bind the actual command, absolute tool, environment, read closure, revision, times and raw outputs, preserving original scripts and prior runs.

#### Scenario: E01 The unchanged m5 script runs on the frozen closure

- **WHEN** the unchanged m5 script runs on the frozen closure
- **THEN** both graph blocks and all raw outputs are retained with exact executable/source identities and separate wrapper verdict.

#### Scenario: E02 A new source revision has not actually been executed

- **WHEN** a new source revision has not actually been executed
- **THEN** an older run remains labelled with its measured revision; source-equivalent reuse requires an explicit relevant-closure comparison.

#### Scenario: E03 A timeout, unreadable dependency or runtime error occurs

- **WHEN** a timeout, unreadable dependency or runtime error occurs
- **THEN** the attempt is preserved as blocked with actual exit/signal information and never labelled a mathematical counterexample.

### Requirement: HE02 Validate nonempty counters and denominators

The evidence system SHALL validate every expected block, counter and denominator and SHALL distinguish generator indices, unique states and bounded input families.

#### Scenario: E04 The actual equality and union counters are parsed

- **WHEN** the actual equality and union counters are parsed
- **THEN** 32567 excludes empty and 30856 means only the i<j<k singleton/pair split; neither is presented as every subset or split.

#### Scenario: E05 The actual anti-exchange and composition counters are parsed

- **WHEN** the actual anti-exchange and composition counters are parsed
- **THEN** ordered outside-point tests, deduplicated closures and 1711 possibly repeated generator indices are distinguished from unique closed states.

#### Scenario: E06 The process exits zero but a violation counter is positive

- **WHEN** the process exits zero but a violation counter is positive
- **THEN** the wrapper returns exit1 and preserves the failing counter; the unchanged valid sibling returns exit0.

### Requirement: HE03 Separate failure from blocked evidence

The evidence system SHALL use exit0 for complete nonempty checks, exit1 for bound content violations and exit3 for missing, malformed, ambiguous or drifted evidence; offline checks SHALL preserve input bytes and mtimes.

#### Scenario: E07 A graph block is missing, duplicated, truncated or has an empty denominator

- **WHEN** a graph block is missing, duplicated, truncated or has an empty denominator
- **THEN** the checker returns exit3 rather than success or a scientific refutation.

#### Scenario: E08 A well-formed inventory changes an edge or calls repeated indices distinct states

- **WHEN** a well-formed inventory changes an edge or calls repeated indices distinct states
- **THEN** the checker returns exit1 with an exact discrepancy and preserves all other records.

#### Scenario: E09 An output path already exists or is a symlink, or source identity drifts

- **WHEN** an output path already exists or is a symlink, or source identity drifts
- **THEN** the operation is blocked without overwriting earlier artifacts or changing original sources.
