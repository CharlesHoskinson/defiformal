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

The system MUST require actual original bytes and an origin record for recovered attachments, and an original transcript mapping for recovered citation tokens, with explicit origin-trust assumptions and custody/provenance review; byte integrity alone does not authenticate a transcript.

#### Scenario: SRC-03 Actual attachment recovery

- **WHEN** the original attachment bytes and a verifiable origin record are available
- **THEN** recovered_original binds those bytes and origin without replacing the historical pointer

#### Scenario: SRC-04 Reconstructed file is not original

- **WHEN** a newly generated crosswalk or plausible filename is presented as the absent original attachment
- **THEN** recovered_original is rejected and the reconstruction retains its own identity

#### Scenario: SRC-13 Transcript provenance assumption

- **WHEN** a supplied browsing transcript maps a historical token and its digest and span match
- **THEN** recovery remains conditional on its explicit reviewed origin-trust assumption; unknown provenance leaves the original mapping unresolved and byte checks do not claim authenticity

### Requirement: Retained and scoped source evidence

The system SHALL distinguish retained, empty_or_non_substantive, fingerprint-only, unavailable and restricted source captures and bind claim locators to actual retained bytes and version/time scope. Validated imports of existing research packets MUST preserve original acquisition identities and failures, distinguish derived-text coordinates from response bytes, and record import-validation tools/times separately from historical acquisition tools/times; an import is not a production collector run or an accepted adjudication.

#### Scenario: SRC-05 Replay retained capture

- **WHEN** an existing research packet or collector record has retained source bytes with matching digests and exact raw or bound derived-text locators
- **THEN** offline checks validate the original capture/extraction binding and precise product/version/time scope without fresh retrieval, preserve actual acquisition times/tools and origin type, and leave its unaccepted interpretation pending review

#### Scenario: SRC-06 Missing retained body

- **WHEN** a source record claims retained status but its body cannot be read
- **THEN** the required replay is blocked with the source ID and no factual promotion; a readable empty/non-substantive body falsely marked retained is rejected with exit one and receives zero support

#### Scenario: SRC-07 Present-day page for historical claim

- **WHEN** only retrieval-time documentation exists for a historical corpus claim
- **THEN** unit_applicability is current_documentation_only, the historical-primary claim remains not evidenced and semantically unresolved, and the source-claims table can show separately reviewed scoped support

#### Scenario: SRC-11 Empty and wrapper import normalization

- **WHEN** an old packet calls a zero-byte HTTP202 body or redirect-only/access wrapper retained
- **THEN** import preserves raw bytes/status/manifests but creates a new empty_or_non_substantive overlay record with zero support; retained status or any support locator into it is rejected, while a substantive positive-length retained sibling replays

#### Scenario: SRC-12 Retained derived coordinate space

- **WHEN** a derived-text locator has only extractor metadata, missing output bytes, or an empty/out-of-range byte span
- **THEN** missing extraction output blocks replay with missing_extraction_output, invalid readable spans violate the record contract, and only a nonempty in-range span bound to retained output and original body bytes can replay

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
- **THEN** the collector checks exact membership/ancestry against the bound development manifest and rejects the queue before any request, even if its caller-supplied role says development

#### Scenario: SRC-14 Distinct target and retry accounting

- **WHEN** three requested URL targets include a failed guess, a corrected slug and a third source, with retries and server redirects
- **THEN** all three targets consume slots, same-target retries are bounded to two total attempts, redirects consume their separate five-hop bound, and a fourth requested target blocks before network access while preserving every attempt and pass identity
