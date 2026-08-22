## ADDED Requirements

### Requirement: An empty corpus is not a pass

A gate SHALL NOT report success when it examined zero items. It SHALL exit with
the blocked code and name the corpus it expected.

#### Scenario: A glob matches no files

- **WHEN** `sigma/verify_final.py` resolves its spec glob to zero files
- **THEN** it exits 3 reporting that no specs were found, and does not print
  `X21-armed pairs (60-app basis): 0 of 0` as a result

#### Scenario: A validator is pointed at an empty directory

- **WHEN** `formal/v3/validate.mjs` is given a directory containing no specs
- **THEN** it exits 3 rather than printing `0 specs, 0 rejected` and exiting 0

#### Scenario: A certificate check finds no certificates

- **WHEN** `gate33_cert_check.py`'s IR directory exists but contains zero `*.json`
- **THEN** it exits 3 rather than printing `PASS 0 files`

#### Scenario: A non-empty corpus is unaffected

- **WHEN** any of those gates is given its real corpus
- **THEN** it produces exactly the verdict and figures it produces today

### Requirement: Every gate states its denominator

A gate that reports a ratio, count or rate SHALL print the denominator it
measured over, so a reader can see whether the check had anything to examine.

#### Scenario: A rate is reported

- **WHEN** a gate prints a coverage, exclusion or generation figure
- **THEN** the count of items examined appears in the same output line or block

#### Scenario: The denominator is unexpectedly small

- **WHEN** the measured denominator is zero
- **THEN** the requirement above applies and the gate exits blocked

### Requirement: A checker is demonstrated to fail before it is trusted

Every gate whose passing is load-bearing for a claim SHALL have a recorded
negative test that makes it fail, and the recorded failure SHALL come from the
property being false rather than from the input being absent.

#### Scenario: A gate has no observed failure

- **WHEN** a gate cannot be made to print a failure verdict by any perturbation
  of its input content
- **THEN** it is recorded as `CANNOT FAIL` in the audit register rather than
  counted as a passing gate

#### Scenario: The only failure path is a missing input

- **WHEN** a gate fails solely because its input directory is absent
- **THEN** that is recorded as a blocked-path test, not as evidence the gate
  discriminates content

#### Scenario: A perturbation is caught

- **WHEN** a negative test alters the property the gate protects
- **THEN** the gate exits 1 and the harness reports `CAUGHT`
