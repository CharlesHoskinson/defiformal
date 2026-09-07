"""Bounded primary-source preparation; no corpus mutation or adjudication acceptance."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess
import urllib.request

ROOT = Path(__file__).resolve().parents[5]
OUT = Path(__file__).resolve().parent
def sha(data):
    return hashlib.sha256(data).hexdigest()
def now():
    return datetime.now(timezone.utc).isoformat()
def write(name, value):
    with (OUT / name).open('x') as handle:
        json.dump(value, handle, indent=2)
        handle.write('\n')

paths = set()
for directory in ['corpus/normalized', 'corpus50']:
    paths.update(p for p in (ROOT / directory).rglob('*') if p.is_file())
paths.update(ROOT / row['path'] for row in json.loads((ROOT /
    'review/semantic-kernel/sprint10/planning/r2-candidate.json').read_text())['inputs'])
paths.update(ROOT / p for p in [
    'openspec/changes/corpus-provenance-adjudication/design.md',
    'openspec/changes/corpus-provenance-adjudication/dispute-inventory.json',
    'review/semantic-kernel/corpus-provenance-adjudication/source-research/disagreement-triage.json'])
protected = {str(p.relative_to(ROOT)): sha(p.read_bytes()) for p in sorted(paths)}
write('input-protection-before.json', {'utc': now(), 'files': protected,
    'head': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()})

class Redirects(urllib.request.HTTPRedirectHandler):
    max_redirections = 5
    max_repeats = 2

targets = [
    ('architecture', 'https://docs.lighter.xyz/about-lighter/technical-architecture-lighter-core'),
    ('whitepaper', 'https://assets.lighter.xyz/whitepaper.pdf'),
    ('api', 'https://docs.lighter.xyz/perpetual-futures/api'),
]

opener = urllib.request.build_opener(Redirects())
(OUT / 'captures').mkdir(exist_ok=False)
records = []
for source_id, url in targets:
    row = {'source_id': source_id, 'requested_url': url, 'attempts': []}
    for attempt in range(1, 3):
        result = {'attempt': attempt, 'started_utc': now()}
        try:
            request = urllib.request.Request(url, headers={
                'User-Agent': 'DeFiFormal-source-research/1.0', 'Accept-Encoding': 'identity'})
            with opener.open(request, timeout=30) as response:
                body = response.read(5 * 1024 * 1024 + 1)
                if len(body) > 5 * 1024 * 1024:
                    raise ValueError('body limit exceeded')
                digest = sha(body)
                path = OUT / 'captures' / digest
                if not path.exists():
                    path.write_bytes(body)
                result.update(status='retained', http_status=response.status,
                    final_url=response.url, headers=dict(response.headers),
                    body_bytes=len(body), body_sha256=digest,
                    capture_path=str(path.relative_to(ROOT)))
        except Exception as error:
            result.update(status='failed', error_type=type(error).__name__, error=str(error))
        result['finished_utc'] = now()
        row['attempts'].append(result)
        if result['status'] == 'retained':
            break
    row['status'] = row['attempts'][-1]['status']
    records.append(row)
write('retrievals.json', {'unit_id': 'unit:lane2:c0:p3', 'dispute_id': 'dispute-10',
    'status': 'source_capture_only_no_accepted_disposition',
    'scope': 'Current official Lighter execution/settlement architecture; no deployed revision equivalence',
    'bounds': {'distinct_primary_urls': 3, 'max_attempts_per_url': 2,
        'socket_timeout_seconds': 30, 'max_redirects': 5, 'max_body_bytes': 5 * 1024 * 1024},
    'hash_scope': 'Exact response body bytes, identity encoding, headers excluded',
    'records': records})
assert all(sha((ROOT / p).read_bytes()) == digest for p, digest in protected.items())
print(json.dumps([{'source': x['source_id'], 'status': x['status'],
    'bytes': x['attempts'][-1].get('body_bytes')} for x in records]))
