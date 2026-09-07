#!/usr/bin/env python3
"""Bounded primary identity research; original inputs are read only."""
from pathlib import Path
from datetime import datetime, timezone
from concurrent.futures import ThreadPoolExecutor
import hashlib
import importlib.metadata
import json
import subprocess
import sys
import urllib.request
import urllib.error
from bs4 import BeautifulSoup

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
MAX_BODY = 5 * 1024 * 1024

def sha(data):
    return hashlib.sha256(data).hexdigest()

def now():
    return datetime.now(timezone.utc).isoformat()

def save(path, obj):
    with path.open('x') as handle:
        json.dump(obj, handle, ensure_ascii=False, indent=2)
        handle.write('\n')

def head():
    return subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()

class Redirects(urllib.request.HTTPRedirectHandler):
    max_redirections = 5
    max_repeats = 2

def capture(url):
    key = sha(url.encode())[:16]
    attempts = []
    for index in range(1, 3):
        item = {'attempt': index, 'started_utc': now()}
        try:
            req = urllib.request.Request(url, headers={
                'User-Agent': 'DeFiFormal-identity-research/1.0', 'Accept-Encoding': 'identity'})
            with urllib.request.build_opener(Redirects()).open(req, timeout=30) as response:
                body = response.read(MAX_BODY + 1)
                if len(body) > MAX_BODY:
                    raise ValueError('declared body limit exceeded; no replay body retained')
                digest = sha(body)
                dest = HERE / 'captures' / digest
                try:
                    with dest.open('xb') as handle:
                        handle.write(body)
                except FileExistsError:
                    assert dest.read_bytes() == body
                item.update(http_status=response.status, final_url=response.url,
                            headers=dict(response.headers), body_bytes=len(body), body_sha256=digest,
                            capture_path=str(dest.relative_to(ROOT)),
                            status='retained_response_unassessed' if body else 'empty_response_no_support')
                ctype = response.headers.get('Content-Type', '')
                if body and ('html' in ctype.lower() or body.lstrip().lower().startswith(b'<!doctype html')):
                    soup = BeautifulSoup(body, 'html.parser')
                    for element in soup(['script', 'style', 'noscript', 'svg']):
                        element.decompose()
                    chosen = soup.find('main') or soup.find('article') or soup.body or soup
                    text = chosen.get_text('\n', strip=True).encode('utf-8')
                    text_path = HERE / 'extracted' / (key + '.txt')
                    text_path.write_bytes(text)
                    item['extraction'] = {'path': str(text_path.relative_to(ROOT)), 'sha256': sha(text),
                        'bytes': len(text), 'method': 'BeautifulSoup html.parser; remove script/style/noscript/svg; first main else article else body else document; newline get_text(strip=True)',
                        'title': soup.title.get_text(' ', strip=True) if soup.title else None,
                        'scope': 'Derived UTF8 coordinate space; source and extractor bound separately. Content availability/identity remains unassessed.'}
        except Exception as error:
            item.update(status='failed_no_support', error_type=type(error).__name__, error=str(error))
        item['finished_utc'] = now()
        attempts.append(item)
        if item['status'] != 'failed_no_support':
            break
    record = {'source_id': key, 'requested_url': url, 'attempts': attempts,
              'status': attempts[-1]['status'], 'accepted_evidence': False}
    save(HERE / 'responses' / (key + '.json'), record)
    return record

def main():
    for directory in ['captures', 'extracted', 'responses']:
        (HERE / directory).mkdir(exist_ok=False)
    queue_path = ROOT / 'review/semantic-kernel/corpus-provenance-adjudication/source-research/consolidated-01/remaining-research-queue.json'
    queue = json.loads(queue_path.read_bytes())['remaining'][32:51]
    targets = json.loads((HERE / 'targets.json').read_bytes())
    assert len(queue) == len(targets['targets_by_queue_offset']) == 19
    bindings = [{**row, 'target_urls': urls} for row, urls in zip(queue, targets['targets_by_queue_offset'])]
    assert all(0 < len(set(x['target_urls'])) <= 3 for x in bindings)
    protected = {str(p.relative_to(ROOT)) for d in ['corpus/normalized', 'corpus50']
                 for p in (ROOT / d).rglob('*') if p.is_file()}
    for manifest in ['review/semantic-kernel/sprint10/planning/r2-candidate.json',
                     'review/semantic-kernel/corpus-provenance-adjudication/planning/official-r1/manifest.json']:
        protected.update(row['path'] for row in json.loads((ROOT / manifest).read_bytes())['inputs'])
    protected.add(str(queue_path.relative_to(ROOT)))
    hashes = {path: sha((ROOT / path).read_bytes()) for path in sorted(protected)}
    before = {'recorded_utc': now(), 'head': head(), 'protected': hashes,
              'helper_sha256': sha(Path(__file__).read_bytes()), 'targets_sha256': sha((HERE / 'targets.json').read_bytes()),
              'python': sys.version, 'python_executable': sys.executable,
              'python_executable_sha256': sha(Path(sys.executable).resolve().read_bytes()),
              'beautifulsoup4_version': importlib.metadata.version('beautifulsoup4')}
    save(HERE / 'before.json', before)
    save(HERE / 'selected-units.json', {'status': 'identity_research_only', 'units': bindings})
    urls = sorted({url for row in bindings for url in row['target_urls']})
    with ThreadPoolExecutor(max_workers=4) as pool:
        records = list(pool.map(capture, urls))
    unchanged = all(sha((ROOT / path).read_bytes()) == digest for path, digest in hashes.items())
    after = {'recorded_utc': now(), 'head': head(), 'protected_unchanged': unchanged,
             'head_changed': head() != before['head'], 'limits': 'Response retention is not source applicability, identity acceptance, code pin verification or deployment evidence.'}
    save(HERE / 'after.json', after)
    save(HERE / 'retrievals.json', {'status': 'captured_pending_content_and_identity_review', 'unit_count': 19,
                                  'distinct_urls': len(urls), 'records': records})
    assert unchanged
    print(json.dumps({'units': len(bindings), 'urls': len(urls), 'response_statuses': {s: sum(r['status'] == s for r in records) for s in sorted({r['status'] for r in records})},
                      'protected_unchanged': unchanged}))

if __name__ == '__main__':
    main()
