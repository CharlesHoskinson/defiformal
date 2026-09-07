## Purpose

Preserve reproducible primary-source evidence and distinguish original provenance recovery from newly reconstructed support.

## ADDED Requirements

### Requirement: Lossless historical references

The system SHALL preserve every original row, proposal byte and citation occurrence with exact input bindings, independently of later source replacement.

#### Scenario: SRC-01 Complete original pointer inventory

- **WHEN** the frozen proposal and historical corpus are inventoried
- **THEN** all 72 rows, 62 citation occurrences, 45 distinct tokens and two attachment pointers are represented with exact locators and no source edits

#### Scenario: SRC-02 Opaque token remains unresolved

- **WHEN** a public primary page supports a claim near an opaque token without the original browsing transcript
- **THEN** the new page is recorded as reconstructed support and the original token mapping remains unresolved

### Requirement: Truthful original recovery

The system MUST require actual original bytes and an origin record for recovered attachments, and an original transcript mapping for recovered citation tokens.

#### Scenario: SRC-03 Actual attachment recovery

- **WHEN** the original attachment bytes and a verifiable origin record are available
- **THEN** recovered_original binds those bytes and origin without replacing the historical pointer

#### Scenario: SRC-04 Reconstructed file is not original

- **WHEN** a newly generated crosswalk or plausible filename is presented as the absent original attachment
- **THEN** recovered_original is rejected and the reconstruction retains its own identity

### Requirement: Retained and scoped source evidence

The system SHALL distinguish retained, fingerprint-only, unavailable and restricted source captures and bind claim locators to actual retained bytes and version/time scope. Validated imports of existing research packets MUST preserve original acquisition identities and failures, distinguish derived-text coordinates from response bytes, and record import-validation tools/times separately from historical acquisition tools/times; an import is not a production collector run or an accepted adjudication.

#### Scenario: SRC-05 Replay retained capture

- **WHEN** an existing research packet or collector record has retained source bytes with matching digests and exact raw or bound derived-text locators
- **THEN** offline checks validate the original capture/extraction binding and precise product/version/time scope without fresh retrieval, preserve actual acquisition times/tools and origin type, and leave its unaccepted interpretation pending review

#### Scenario: SRC-06 Missing retained body

- **WHEN** a source record claims retained status but its body cannot be read
- **THEN** the required replay is blocked with the source ID and no factual promotion; an empty response retained by a transport helper likewise cannot supply substantive support

#### Scenario: SRC-07 Present-day page for historical claim

- **WHEN** only retrieval-time documentation exists for a historical corpus claim
- **THEN** the historical claim remains not evidenced while the current scoped claim can be reviewed separately

### Requirement: Bounded explicit development acquisition

The collector SHALL process only declared development-source queues, record failed requests and limits, and never mutate an accepted adjudication or refresh sources during offline checks. Queue accounting MUST identify validated existing inputs before new requests and preserve each earlier research pass's actual limits rather than retroactively applying the future collector's URL budget.

#### Scenario: SRC-08 Acquisition budget exhaustion

- **WHEN** the declared URL, retry, redirect, size or duration limit is exhausted
- **THEN** the attempt records the exact bound and unresolved remainder and exits blocked rather than claiming a complete acquisition; importing a separately validated earlier research packet preserves its own pass limits and cannot assert that extra failed/fallback URLs met this collector budget

#### Scenario: SRC-09 Restricted or unavailable source

- **WHEN** a development primary source cannot be retrieved or retained through authorized public access
- **THEN** the reason and affected items are recorded without invented bytes or a bypass

#### Scenario: SRC-10 Holdout source request

- **WHEN** a collection queue contains a reserved or otherwise non-development case
- **THEN** the collector rejects the queue before requesting its semantic sources
