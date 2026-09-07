"""Bind a proposed scope-limited reading to retained PDF bytes and exact extracted spans."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
OUT = Path(__file__).resolve().parent
def sha(data):
    return hashlib.sha256(data).hexdigest()
def bind(path):
    p = ROOT / path
    data = p.read_bytes()
    return {'path': str(p.relative_to(ROOT)), 'sha256': sha(data), 'bytes': len(data)}
def write(name, value):
    with (OUT / name).open('x') as handle:
        json.dump(value, handle, indent=2)
        handle.write('\n')

prefix = str(OUT.relative_to(ROOT))
triage_path = 'review/semantic-kernel/corpus-provenance-adjudication/source-research/disagreement-triage.json'
triage = json.loads((ROOT / triage_path).read_text())
row = next(x for x in triage['disagreements'] if x['id'] == 'dispute-06')
raw = {}
for key in ['raw_a', 'raw_b']:
    source = row[key]['record']
    raw[key] = {'source': bind(source['path']), 'pointer': source['pointer'],
        'value': json.loads((ROOT / source['path']).read_text())['annotations'][19]}
generated_path = row['generated']['pointer']['path']
raw['generated'] = {'source': bind(generated_path), 'pointer': '/adjudications/95',
    'value': json.loads((ROOT / generated_path).read_text())['adjudications'][95]}
write('observations.json', {'triage': bind(triage_path), 'selected_record': row, **raw})

retrievals = json.loads((OUT / 'retrievals.json').read_text())
terms = retrievals['records'][0]['attempts'][-1]
assert terms['http_status'] == 200 and terms['body_bytes'] > 0
body = (OUT / 'terms-layout.txt').read_bytes()
locators = []
for start, end in [('2.3.', '2.4.'), ('3.2.', '3.3.'), ('4.1.', '4.2.'),
                   ('5.2.', '5.3.'), ('7.1.', '7.2.'), ('7.2.', '7.3.'),
                   ('7.3.', '7.4.'), ('7.4.', '8. CONVERSION'),
                   ('11.', '12. TRANSLATIONS')]:
    assert body.count(start.encode()) == 1, start
    a = body.index(start.encode())
    b = body.index(end.encode(), a + len(start))
    locators.append({'id': 'terms-clause-' + start.rstrip('.'), 'source': bind(terms['capture_path']),
        'extracted_text': bind(prefix + '/terms-layout.txt'),
        'extraction': bind(prefix + '/extraction.json'),
        'byte_start': a, 'byte_end_exclusive': b,
        'line_start': body[:a].count(b'\n') + 1,
        'line_end': body[:b].count(b'\n') + 1,
        'pdf_page_one_based': body[:a].count(b'\f') + 1,
        'span_sha256': sha(body[a:b]),
        'coordinate_system': 'Exact pdftotext -layout output bytes, not PDF byte offsets'})
write('evidence-locators.json', {'locators': locators})
availability = []
for item in retrievals['records']:
    result = item['attempts'][-1]
    usable = result.get('http_status') == 200 and result.get('body_bytes', 0) > 0
    availability.append({'source_id': item['source_id'],
        'capture_status': 'retained' if usable else 'restricted',
        'usable_primary_body': usable,
        'reason': 'Nonempty official PDF retained' if usable else
            'HTTP202 WAF challenge with zero response bytes; no page content captured',
        'raw_response_metadata': bind(prefix + '/retrievals.json')})
write('source-availability.json', {'sources': availability,
    'raw_capture_label_limitation': 'capture.py records successful HTTP transport as retained; this semantic availability record distinguishes two empty challenge responses from the one retained primary body. Raw records are not overwritten.',
    'discovery': 'Official-domain web search located the terms PDF. Search snippets and the FAQ browser rendering are discovery only; no uncaptured wording is used as retained evidence.',
    'missing_provenance': 'Service page and FAQ returned empty challenges. No live product-page-to-PDF link or universal user-jurisdiction applicability established.'})
design_path = 'openspec/changes/corpus-provenance-adjudication/design.md'
rule = next(line for line in (ROOT / design_path).read_text().splitlines()
            if line.startswith('| `R-offchain_claims` /'))
write('proposed-adjudication.json', {'process_status': 'draft_review_pending',
    'unit_id': row['unit_id'], 'dispute_id': row['id'], 'facet': 'economic_functions',
    'label': 'offchain_claims', 'rule_id': 'R-offchain_claims',
    'rule_source': bind(design_path), 'literal_proposed_rule': rule,
    'scoped_source_reading': 'supported',
    'scoped_proposition': 'The captured ADGM ETH Staking terms describe WBETH redemption through Binance account processing, supporting the proposed offchain-claims predicate for that described service.',
    'source_scope': {'document': 'ETH STAKING PRODUCT TERMS', 'version': '1.0',
        'stated_effective_date': '2026-01-05', 'named_service_entity': 'NEST TRADING LIMITED',
        'scope_is_document_assertion': True},
    'claim_locators': ['terms-clause-2.3', 'terms-clause-3.2', 'terms-clause-4.1',
        'terms-clause-5.2', 'terms-clause-7.1', 'terms-clause-7.3', 'terms-clause-11'],
    'unit_wide_disposition': 'not_evidenced',
    'unit_wide_gap': 'Generic historical WBETH unit has no jurisdiction/account binding to these ADGM terms; no universal holder entitlement is established.',
    'qualifications': ['Redemption remains quota/pool constrained and processed with possible delay.',
        'Incorporated Terms of Use were not retrieved; enforceability and all-user legal rights are not assessed.',
        'No deployed code, contract execution, original citation recovery or untouched evaluation.'],
    'accepted_disposition': None, 'overlay_applied': False,
    'next_step': 'Independent source/rule review and identity-scope resolution before any effective-label promotion.'})
report = '''# WBETH source preparation

The captured ADGM terms describe WBETH redemption through Binance account processing, with quota, pool and delay conditions. That supports a scoped offchain-claims reading. It does not establish that these terms cover every holder or the historical corpus unit. [Official terms](https://bin.bnbstatic.com/static/cms/cg08ou2ak0tn7mcplvfg/file/b6d497d5f7fc086ad597b7b4bd608cfc57cce5f2f9191bbfa84a7e17af93cd17.pdf)

The unit-wide proposed disposition remains `not_evidenced` pending identity and scope evidence. No labels changed. One nonempty primary PDF was retained; both website requests returned empty HTTP202 challenges. Nine exact extracted-text locators are bound to the PDF and extraction tool. Independent review remains pending.
'''
with (OUT / 'REPORT.md').open('x') as handle:
    handle.write(report)
checks = []
def check(name, result):
    checks.append({'id': name, 'passed': bool(result)})
    assert result, name
before = json.loads((OUT / 'input-protection-before.json').read_text())
for path, digest in before['files'].items():
    check('protected:' + path, sha((ROOT / path).read_bytes()) == digest)
for item in retrievals['records']:
    result = item['attempts'][-1]
    data = (ROOT / result['capture_path']).read_bytes()
    check('capture:' + item['source_id'], sha(data) == result['body_sha256'] and len(data) == result['body_bytes'])
for item in locators:
    check('locator:' + item['id'], sha(body[item['byte_start']:item['byte_end_exclusive']]) == item['span_sha256'])
check('raw-offchain-a-only', row['a_only'] == ['offchain_claims'] and row['b_only'] == [])
check('nonempty-primary-count', sum(x['usable_primary_body'] for x in availability) == 1)
check('challenge-count', sum(x['capture_status'] == 'restricted' for x in availability) == 2)
write('verification.json', {'utc': datetime.now(timezone.utc).isoformat(), 'checks': checks,
    'checks_passed': len(checks), 'scope': 'Offline records and input integrity, not semantic or legal acceptance'})
artifacts = [bind(str(p.relative_to(ROOT))) for p in sorted(OUT.rglob('*')) if p.is_file()]
write('artifact-manifest.json', {'artifacts': artifacts, 'count': len(artifacts),
    'status': 'draft_source_research_no_accepted_corpus_change'})
print(json.dumps({'checks': len(checks), 'locators': len(locators), 'primary_bodies': 1,
    'empty_challenges': 2, 'artifact_count': len(artifacts)}))
