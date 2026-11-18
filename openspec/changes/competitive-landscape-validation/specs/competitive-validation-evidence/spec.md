## Purpose

Collect prospective component-effort measurements and actual outside reproduction
records for the delivered verification library, with enough identity and scope
information to distinguish observations, unknowns and unsupported claims.

## ADDED Requirements

### Requirement: Prospective effort SHALL have a declared measurement protocol

Before the measured work starts, the protocol SHALL identify two component
instances, the shared financial/library work, source baselines, the operation and
proof obligations, authoring and review roles, count categories and effort units.
It SHALL distinguish human active authoring, agent elapsed sessions, tool/build
time, waits and shared overhead. It SHALL specify how failed attempts, repairs,
interruptions and shared changes are recorded. Unmeasured quantities MUST remain
unknown. A prospective experiment MUST NOT reconstruct historical effort.

#### Scenario: Protocol precedes the experiment

- **WHEN** a prospective component-reuse experiment is started
- **THEN** its reviewed, timestamped protocol already names the component/shared scopes, source/tool identities, effort units, allocation rules and financial acceptance obligations

### Requirement: Reuse effort SHALL be measured separately for each instance

The experiment SHALL report source-bound model, specification and guidance counts,
attribution and separately recorded effort for each instance, with shared overhead
reported separately. Evidence SHALL include failed attempts and review/repair work
under the declared allocation rules. The measured obligations MUST be stated, and
the completed artifacts MUST meet their declared financial/proof acceptance gates.
Any efficiency claim SHALL use comparable scopes and its stated measurement unit;
a missing baseline or unmatched workload MUST NOT support a reduction claim. No
particular improvement is required for completion.

#### Scenario: Separate effort is observed

- **WHEN** both declared component instances complete the prospective experiment
- **THEN** the evidence reports each instance's exact source scope, counts, attribution and separately observed authoring-session effort, with shared overhead and failure/review costs explicit, and preserves unavailable historical vault/token0/workflow effort as unknown

#### Scenario: Incomplete measurements cannot become savings

- **WHEN** a component interval, baseline or allocation is missing or incomparable
- **THEN** the record identifies the gap, leaves the affected measurement criterion open and makes no effort-reduction claim from line counts or a shared elapsed interval

### Requirement: An actual outside developer SHALL reproduce the P18 package

A developer outside the project SHALL follow the pinned P18 token0 package README.
The record SHALL identify their role and basis for outside-project status, exact
package/source and README identities, environment and prerequisites, commands,
setup-time definition and measurement, outcome and any problems or assistance.
Outcome and setup time SHALL be recorded whether the run passes or fails. An
agent execution, maintainer execution, download or release MUST NOT substitute for
the outside developer's record. Personal contact details are not required.

#### Scenario: P18 reproduction is on record

- **WHEN** the outside developer finishes or abandons the documented P18 reproduction attempt
- **THEN** a corroborated record includes their role, exact inputs/environment, setup time and pass/fail outcome with diagnostics and assistance disclosed; a failed attempt may satisfy the record requirement but cannot establish successful reproduction

### Requirement: An actual outside developer SHALL recheck the compiled package alone

An outside developer SHALL receive an exact published compiled-evidence archive
with its checksum and package-contained instructions, use only those contents and
declared host prerequisites, and attempt the selected `leanchecker` replay. The
record SHALL identify their role, release/archive hash, host environment, commands,
setup and replay times, result, output and any assistance. Successful reproduction
requires actual replay of the nonempty selected-module inventory matching the
recorded result, without a source checkout or maintainer build cache. A blocked or
failed attempt SHALL remain evidence but MUST NOT close the successful-recheck
criterion. Repairs require a new exact package identity and fresh qualifying run.

#### Scenario: Outside package-only replay succeeds

- **WHEN** an outside developer rechecks the published archive using only its instructions and declared host prerequisites
- **THEN** their corroborated record binds the exact archive/checker/environment and shows the selected-module replay produced the recorded successful result, with setup/replay time and assistance disclosed

#### Scenario: Outside package-only replay is blocked or fails

- **WHEN** a required input is absent, the instructions need undocumented support, or the outside replay fails
- **THEN** the attempt and diagnostics are retained, successful outside rechecking remains open, and no agent replay or proposed repair supplies a passing result

### Requirement: Validation claims SHALL preserve evidence boundaries

One outside developer MAY perform both reproduction procedures, but each SHALL
have a distinct qualifying run record. Independently reviewed closure SHALL map
each criterion to actual evidence and preserve transferred obligation IDs. No
measurement or reproduction SHALL by itself establish adoption, comparative replay
speed, general productivity, deployed-code equivalence or a complete adversary
model. Agent reviews SHALL retain their actual identities and MUST NOT be labelled
outside-developer reproduction.

#### Scenario: Validation closure follows actual observations

- **WHEN** this validation change is proposed for completion
- **THEN** independent review finds an accepted prospective experiment and both qualifying outside records, distinguishes failed P18 records from successful package rechecking, and leaves broader unsupported claims explicit
