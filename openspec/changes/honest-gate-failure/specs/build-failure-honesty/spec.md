## ADDED Requirements

### Requirement: A blocked check is never reported as a failed property

A build or gate script SHALL distinguish a check that evaluated its property and
found it false from a check that could not evaluate its property at all, and
SHALL NOT describe the second as the first.

#### Scenario: The totals gate cannot reach its input

- **WHEN** `formal/v3/totalgate.mjs` exits non-zero because its expansion root is
  missing, unreadable, or outside the tree
- **THEN** `paper/build.sh` reports that the totals were **not checked**, names
  the exit code, and does not print "a headline total disagrees with the verdicts"

#### Scenario: A headline total genuinely disagrees

- **WHEN** `atlas.tex` is edited so a headline total no longer matches the
  verdicts, and the gate can read its input
- **THEN** `paper/build.sh` prints "a headline total disagrees with the verdicts"
  and exits 1

#### Scenario: Both polarities are distinguishable in a scrollback

- **WHEN** a reader sees either failure in terminal output
- **THEN** the two use different leading words and different colours, so neither
  can be mistaken for the other

### Requirement: Gate diagnostics reach the operator

A caller SHALL NOT discard the standard error of a gate it invokes.

#### Scenario: The gate writes a diagnosis before failing

- **WHEN** an invoked gate writes to stderr and exits non-zero
- **THEN** the caller emits that text to its own stderr before reporting its verdict

#### Scenario: The gate succeeds

- **WHEN** an invoked gate exits 0
- **THEN** its routine output does not clutter the build summary

### Requirement: A failed directory change halts the script

Every gate shell SHALL resolve its working directory relative to its own
location and SHALL exit immediately if that change fails.

#### Scenario: The hardcoded root does not exist

- **WHEN** `formal/v3/gate.sh` runs in a tree that is not `/root/defiformal`
- **THEN** it either resolves the correct root or exits with the blocked code,
  and in no case proceeds to report content verdicts

#### Scenario: A harness reports a corpus verdict it did not measure

- **WHEN** any gate shell would print a count-bearing verdict such as
  `FAIL 61 of 72` after failing to reach the corpus
- **THEN** the script has already exited and the verdict is never printed

### Requirement: Exit codes carry the outcome

A gate SHALL exit 0 when the property holds over a non-empty corpus, 1 when the
property is false, and 3 when the check could not be performed.

#### Scenario: A caller needs to branch on the reason

- **WHEN** a caller invokes a gate
- **THEN** it can distinguish the three outcomes from the exit code alone,
  without parsing output

#### Scenario: An existing exit code conflicts

- **WHEN** a gate already exits with a value that contradicts this scheme
- **THEN** it is remapped and its callers are updated in the same change
