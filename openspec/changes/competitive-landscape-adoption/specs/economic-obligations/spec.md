## Purpose

Explore ordering safety on the interleaving executor with an explicit counterexample or a proven bound under declared assumptions. Serves task IV.2.

## ADDED Requirements

### Requirement: An ordering scenario SHALL be run on the interleaving executor

One small ordering scenario SHALL be run on the interleaving executor and the invariant or gain bound it suggests SHALL be stated with its assumptions.

#### Scenario: Scenario yields a counterexample or a bound

- **WHEN** one small ordering scenario is replayed on the interleaving executor
- **THEN** the record holds either a replayed counterexample or a proven gain bound with its declared assumptions
