from pathlib import Path
P=Path('openspec/changes/corpus-provenance-adjudication')
def edit(cap,replacements,additions):
 p=P/'specs'/cap/'spec.md';s=p.read_text()
 for a,b in replacements:
  assert a in s,a;s=s.replace(a,b)
 # Append scenarios within named existing requirements, keeping requirement inventory fixed.
 for req,scenarios in additions.items():
  start=s.index('### Requirement: '+req);nxt=s.find('\n### Requirement:',start+1)
  if nxt<0:nxt=len(s)
  s=s[:nxt].rstrip()+'\n\n'+scenarios.strip()+'\n'+s[nxt:]
 p.write_text(s)
edit('corpus-source-provenance',[
 ('an original transcript mapping for recovered citation tokens.','an original transcript mapping for recovered citation tokens, with explicit origin-trust assumptions and custody/provenance review; byte integrity alone does not authenticate a transcript.'),
 ('retained, fingerprint-only, unavailable and restricted source captures','retained, empty_or_non_substantive, fingerprint-only, unavailable and restricted source captures'),
 ('an empty response retained by a transport helper likewise cannot supply substantive support','a readable empty/non-substantive body falsely marked retained is rejected with exit one and receives zero support'),
 ('the historical claim remains not evidenced while the current scoped claim can be reviewed separately','unit_applicability is current_documentation_only, the historical-primary claim remains not evidenced and semantically unresolved, and the source-claims table can show separately reviewed scoped support'),
 ('the collector rejects the queue before requesting its semantic sources','the collector checks exact membership/ancestry against the bound development manifest and rejects the queue before any request, even if its caller-supplied role says development')],{
 'Retained and scoped source evidence':'''#### Scenario: SRC-11 Empty and wrapper import normalization

- **WHEN** an old packet calls a zero-byte HTTP202 body or redirect-only/access wrapper retained
- **THEN** import preserves raw bytes/status/manifests but creates a new empty_or_non_substantive overlay record with zero support; retained status or any support locator into it is rejected, while a substantive positive-length retained sibling replays

#### Scenario: SRC-12 Retained derived coordinate space

- **WHEN** a derived-text locator has only extractor metadata, missing output bytes, or an empty/out-of-range byte span
- **THEN** missing extraction output blocks replay with missing_extraction_output, invalid readable spans violate the record contract, and only a nonempty in-range span bound to retained output and original body bytes can replay''',
 'Truthful original recovery':'''#### Scenario: SRC-13 Transcript provenance assumption

- **WHEN** a supplied browsing transcript maps a historical token and its digest and span match
- **THEN** recovery remains conditional on its explicit reviewed origin-trust assumption; unknown provenance leaves the original mapping unresolved and byte checks do not claim authenticity''',
 'Bounded explicit development acquisition':'''#### Scenario: SRC-14 Distinct target and retry accounting

- **WHEN** three requested URL targets include a failed guess, a corrected slug and a third source, with retries and server redirects
- **THEN** all three targets consume slots, same-target retries are bounded to two total attempts, redirects consume their separate five-hop bound, and a fourth requested target blocks before network access while preserving every attempt and pass identity'''
})
edit('corpus-evidence-adjudication',[
 ('exactly the 29 inventoried unit/facet records across 24 units are queued, with all 32 symmetric-difference label instances','the actual normalized INTERSECTION_UNRESOLVED records and raw A/B symmetric differences independently derive 29 unit/facet records across 24 units and 32 label instances, which must exactly equal the queue'),
 ('a frozen explicit inclusion predicate, product/version/time scope and direct-service/no-inheritance rules','the authoritative rules.json payload and literally equal design table, product/version/time scope, a uniform selected interpretation when applicable, and direct-service/no-inheritance rules'),
 ('separate scoped decisions can update the effective view','separate accepted established-applicability decisions can update the historical-primary view, while source-only readings enter only the source-claims table'),
 ('derive effective facets with explicit reasons.','derive historical-primary facets and a separate scoped source-claims table with explicit reasons. Every decision MUST include unit_applicability established, current_documentation_only or unresolved; historical semantic closure requires established applicability for every effective disputed-label decision.')],{
 'Reusable scoped label predicates':'''#### Scenario: ADJ-12 Uniform interpretation ruling

- **WHEN** an accepted R-appchain interpretation is selected for a bound rule version
- **THEN** every accepted decision for that rule/version references the same reviewed ruling, and a mismatched or missing reference is rejected across all units, including the Lighter/ApeX/edgeX review queue without predetermining their labels

#### Scenario: ADJ-13 Ambiguity remains pending

- **WHEN** a packet's proposed support depends on an unresolved rollup/validium interpretation or an unaccepted ruling
- **THEN** the imported decision stays review_pending and cannot produce accepted support merely from conditional author wording''',
 'Versioned evidence adjudication and effective view':'''#### Scenario: ADJ-14 Historical applicability projections

- **WHEN** the same label has separately reviewed source support with established, current_documentation_only and unresolved applicability
- **THEN** only a unique established historical decision can change the historical facet; other readings remain in their exact scoped source-claims records, and coverage counts each applicability/disposition/review-status combination separately

#### Scenario: ADJ-15 Source-only support cannot close historical facets

- **WHEN** every disputed label has accepted current-documentation support but none has established historical applicability
- **THEN** no historical disagreement is counted semantically resolved, original intersection labels stay visibly provisional, and imports remain unaccepted until separate review

#### Scenario: ADJ-16 Conflicting accepted heads

- **WHEN** two non-superseded accepted decisions share a unit/facet/label/rule-version/scope key, even with equal dispositions
- **THEN** the effective result is conflicting with both IDs and no timestamp/order winner; only a reviewed successor explicitly superseding every head resolves it, while a draft successor does not retire an accepted predecessor

#### Scenario: ADJ-17 Invalid supersession graph

- **WHEN** a supersession reference is missing, cyclic, self-referential or crosses decision scope/key, or an interpretation has conflicting heads
- **THEN** validation rejects the invalid graph or blocks dependent acceptance without removing earlier bytes; a valid same-key acyclic unique-head sibling projects deterministically'''
})
edit('corpus-evaluation-boundary',[],{
 'Permanent development membership':'''#### Scenario: EV-07 Described publisher and product exposure

- **WHEN** a retained source for one development unit substantively describes another publisher or product
- **THEN** the development manifest records each description with exact source locators and unresolved identity/alias limits, and later overlap checks include it without treating the URL host as legal identity

#### Scenario: EV-08 Spoofed collector role

- **WHEN** a queue request claims development while its unit/ancestry lacks bound development-manifest membership
- **THEN** the collector rejects it before any network attempt and an actual registered development sibling remains eligible'''
})
edit('corpus-adjudication-evidence',[
 ('without network access, repair or mutation.','without network access, repair or mutation under a hash-bound OS-enforced namespace/seccomp wrapper covering subprocesses, with an actual socket-denial and local-file positive self-test; unavailable enforcement is blocked, never silently bypassed.'),
 ('a readable frozen work inventory omits or duplicates one item while valid siblings remain','a readable frozen work inventory omits or duplicates one item while actual bound INTERSECTION_UNRESOLVED records and raw symmetric differences still supply the complete independent denominator'),
 ('a relevant source, rule, schema, driver or HEAD changes between initial binding and completion','relevant source/rule/schema/driver bytes or Git-object bindings change between initial binding and completion'),
 ('the actual command exits three and invalidates the run integrity claim','the actual command exits three and invalidates run integrity; unrelated HEAD movement is recorded at both ends without relabeling or rejecting identical relevant inputs')],{
 'Deterministic offline build and read-only check':'''#### Scenario: CHK-11 Actual offline denial

- **WHEN** build/check and a child-process socket probe run under the bound namespace/seccomp policy
- **THEN** the probe is actually denied while a local-file positive and valid offline projection succeed, with exact launcher/policy identities and no asserted-only network guarantee

#### Scenario: CHK-12 Offline enforcement unavailable

- **WHEN** the required launcher, namespace/seccomp support or denial self-test is unavailable
- **THEN** offline verification exits three with offline_isolation_unavailable and cannot claim a passed no-network check''',
 'Complete input and output identity safeguards':'''#### Scenario: CHK-13 Closed work dispositions

- **WHEN** the full queue includes not_attempted, review_pending, attempted_unavailable, budget_exhausted, reviewed_unresolved and reviewed_resolved items
- **THEN** every enum value is counted; open first-two states block complete-work exit zero, the four documented terminal states may pass bookkeeping with required reasons/evidence, and unknown values violate the schema without implying factual closure

#### Scenario: CHK-14 Literal authoritative rules

- **WHEN** one displayed design predicate differs from the authoritative rules.json row or a decision binds another rule payload
- **THEN** validation rejects the drift while a literally equal rule/table and exact decision binding pass

#### Scenario: CHK-15 Refreshed official inventory

- **WHEN** a revised plan is frozen for review or implementation
- **THEN** current artifact/context/scenario/task/control manifests are regenerated and hash-bound, earlier copies remain historical, and a stale map cannot silently be used as the current inventory'''
})
# strengthen tasks without adding tasks; derive scenario count after edits
import re
count=sum(len(re.findall(r'^#### Scenario:',p.read_text(),re.M))for p in (P/'specs').glob('*/spec.md'))
p=P/'tasks.md';s=p.read_text().replace('48 unique mapped scenarios',f'{count} unique mapped scenarios').replace('all applicable 48 scenarios',f'all applicable {count} scenarios')
s=s.replace('exact context manifest; verify','exact context manifest, regenerate authoritative rule/scenario/task/control/artifact inventories and preserve prior snapshots at each official freeze; verify',1)
s=s.replace('actual CLI controls accept a bound original-byte fixture','transcript-origin trust/custody assumptions stay explicit and unknown origin remains unresolved; actual CLI controls accept a bound original-byte fixture')
s=s.replace('retained/fingerprint-only/unavailable/restricted distinctions','retained/empty_or_non_substantive/fingerprint-only/unavailable/restricted distinctions')
s=s.replace('empty transport bodies receive no support','empty/wrapper bodies are normalized only in new overlay records, retained requires positive substantive bytes, derived output bytes/digests are mandatory, nonempty in-range locator spans are checked and empty transport bodies receive no support')
s=s.replace('Implement explicit bounded `collect`','After task 6.1 establishes the bound development manifest, implement explicit bounded `collect`')
s=s.replace('verify timeout/retry/redirect/size bounds through a local HTTP fixture','verify exact three requested-target slots including failed guesses, two total attempts per target, five server redirects outside target slots and 30-second attempt deadlines through a local HTTP fixture; reject role spoofing by actual manifest membership')
s=s.replace('Import the complete 29-record disagreement inventory','Independently derive the INTERSECTION_UNRESOLVED set and raw A/B symmetric differences from bound normalized corpus bytes, then compare and import the complete 29-record disagreement inventory')
s=s.replace('with all 18 concrete inclusion predicates and common scope/direct-service/no-inheritance rules','with authoritative rules.json, all 18 literally matched design predicates, common scope/direct-service/no-inheritance rules and version-bound interpretation records selected uniformly across units')
s=s.replace('verify every disputed label has its declared predicate','verify every disputed label has its declared predicate and every accepted affected-rule decision uses the same reviewed interpretation head; ambiguous conditional packets remain review_pending')
s=s.replace('and the effective facet view','and explicit historical-primary/scoped-source projections with mandatory unit_applicability')
s=s.replace('accepted supersession updates only the overlay and old bytes remain exact','only established accepted decisions affect historical facets, current-only support never closes them, same-key supersession is acyclic and unique accepted heads project deterministically, multiple heads conflict and old bytes remain exact')
s=s.replace('every case has exact review/rationale evidence','every case has exact review/rationale/applicability/interpretation evidence and coverage cross-tabulates supported counts by applicability')
s=s.replace('Implement monotonic development exposure/ancestry projection','Implement monotonic development exposure/ancestry projection before task 2.4, including per-source publishers and substantively described products with exact locators and identity limits')
s=s.replace('no offline network calls occur','a pinned namespace/seccomp wrapper actually denies child-process sockets with a file-positive sibling; missing enforcement is blocked, and no offline network calls occur')
s=s.replace('source/rule/schema/driver/HEAD drift during execution','relevant source/rule/schema/driver byte or Git-object drift during execution, with unrelated HEAD movement recorded rather than treated as relevant drift')
s=s.replace('complete source/identity/reference/adjudication counts','complete source/identity/reference/adjudication counts and all closed work-disposition counts, with open not_attempted/review_pending excluded from complete-work exit zero')
s=s.replace('6 can proceed independently','6.1 must precede 2.4; the remaining package 6 work can proceed independently')
p.write_text(s)
print({'scenario_count':count})
