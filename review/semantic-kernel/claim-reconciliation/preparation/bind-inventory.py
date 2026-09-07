#!/usr/bin/env python3
"""Bind a bounded author claim-site inspection to exact existing source bytes.

This is provenance bookkeeping, not a semantic checker or theorem prover.
Original source files and the held Sprint10 inputs are read only.
"""
from pathlib import Path
import hashlib
import json
import subprocess
import sys
from datetime import datetime, timezone

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]

def sha(data):
    return hashlib.sha256(data).hexdigest()

def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)

def dump(name, value):
    (HERE / name).write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n')

def main():
    claim_bytes = (HERE / 'claims.json').read_bytes()
    claims = json.loads(claim_bytes)
    frozen_path = ROOT / 'review/semantic-kernel/sprint10/planning/r2-candidate.json'
    frozen = json.loads(frozen_path.read_bytes())
    checks = []
    def check(label, ok):
        checks.append({'check': label, 'ok': bool(ok)})
        if not ok:
            raise RuntimeError(label)
    def hold(stage):
        for entry in frozen['inputs']:
            check(stage + ':' + entry['path'], sha((ROOT / entry['path']).read_bytes()) == entry['sha256'])
    hold('frozen_before')
    head = git('rev-parse', 'HEAD').decode().strip()
    check('nonempty_inventory', bool(claims['entries']))
    ids = [entry['id'] for entry in claims['entries']]
    check('unique_claim_ids', len(ids) == len(set(ids)))
    paths = sorted({site['path'] for entry in claims['entries'] for site in entry['sites']})
    inputs = {}
    for path in paths:
        raw = (ROOT / path).read_bytes()
        check('git_bytes:' + path, git('show', head + ':' + path) == raw)
        inputs[path] = {'path': path, 'bytes': len(raw), 'sha256': sha(raw),
                        'git_blob': git('rev-parse', head + ':' + path).decode().strip()}
        dest = HERE / 'inputs' / path
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(raw)
    bound = []
    for entry in claims['entries']:
        item = dict(entry)
        item['sites'] = []
        for index, site in enumerate(entry['sites'], 1):
            raw = (ROOT / site['path']).read_bytes()
            lines = raw.splitlines(keepends=True)
            first, last = site['start_line'], site['end_line']
            check(f"line_bounds:{entry['id']}:{index}", 1 <= first <= last <= len(lines))
            start = sum(map(len, lines[:first - 1]))
            excerpt = b''.join(lines[first - 1:last])
            check(f"nonempty_excerpt:{entry['id']}:{index}", bool(excerpt.strip()))
            check(f"exact_bytes:{entry['id']}:{index}", raw[start:start + len(excerpt)] == excerpt)
            item['sites'].append({**site, 'source_sha256': inputs[site['path']]['sha256'],
                                  'byte_start': start, 'byte_end_exclusive': start + len(excerpt),
                                  'excerpt_sha256': sha(excerpt), 'excerpt': excerpt.decode('utf-8')})
        bound.append(item)
    for path, record in inputs.items():
        check('source_unchanged:' + path, sha((ROOT / path).read_bytes()) == record['sha256'])
    hold('frozen_after')
    check('head_unchanged', git('rev-parse', 'HEAD').decode().strip() == head)
    check('author_claims_unchanged', (HERE / 'claims.json').read_bytes() == claim_bytes)
    output = {'status': claims['status'], 'created_utc': datetime.now(timezone.utc).isoformat(),
              'source_head': head, 'scope': claims['scope'],
              'author_claims_sha256': sha(claim_bytes), 'inputs': list(inputs.values()),
              'claim_count': len(bound), 'site_count': sum(len(c['sites']) for c in bound),
              'entries': bound,
              'limits': ['Author interpretation; no independent acceptance.',
                         'Checks verify provenance, exact excerpts and held inputs only.',
                         'No original source edits, Lean builds, model runs or new proofs.',
                         'Historical measurements retain their original revision and execution identity.',
                         'No claim of complete downstream coverage.']}
    dump('bound-inventory.json', output)
    dump('checks.json', {'status': 'PASS_PROVENANCE_ONLY', 'count': len(checks), 'checks': checks})
    report = ['# Historical claim-site inspection', '',
              'This bounded author review identifies passages to reconcile with the adopted claim-disposition register. '
              'It records proposed corrections and citation guards; it does not apply them or certify the whole manuscript.', '',
              f"Source revision: `{head}`. {len(bound)} findings, {output['site_count']} exact excerpts from {len(inputs)} files.", '',
              '| ID | Subject | Proposed disposition |', '| --- | --- | --- |']
    report += [f"| {c['id']} | {c['topic']} | {c['disposition'].replace('_', ' ')} |" for c in bound]
    report += ['', '## Findings', '']
    for c in bound:
        report += [f"### {c['id']}: {c['topic']}", '', c['finding'], '',
                   '**Proposed wording:** ' + c['proposed_wording'], '', '**Limit:** ' + c['limit'], '',
                   'Source spans: ' + '; '.join(f"`{s['path']}:{s['start_line']}–{s['end_line']}` ({s['role']})" for s in c['sites']) + '.', '']
    report += ['## Evidence boundary', '',
               f"The {len(checks)} passing checks establish source hashes, excerpt locations, Git byte identity and preservation of all {len(frozen['inputs'])} frozen Sprint 10 inputs. They do not establish the truth of the proposed mathematical interpretation.", '',
               'No historical proof or negative result has been changed. No Lean build, model check, numerical rerun, current axiom audit or independent native review was performed for this packet. '
               'A complete reconciliation still requires a reviewed plan, source-specific edits, downstream search, and independent result review. '
               'The concrete historical-instance correspondence and full paper rewrite remain separate roadmap obligations.', '']
    (HERE / 'REPORT.md').write_text('\n'.join(report))
    files = sorted(p for p in HERE.rglob('*') if p.is_file() and p.name != 'artifact-manifest.json')
    dump('artifact-manifest.json', {'status': 'DRAFT_AUTHOR_PACKET', 'files': [
        {'path': str(p.relative_to(ROOT)), 'bytes': p.stat().st_size, 'sha256': sha(p.read_bytes())} for p in files]})
    print(json.dumps({'status': 'PASS_PROVENANCE_ONLY', 'claims': len(bound), 'sites': output['site_count'],
                      'source_files': len(inputs), 'checks': len(checks), 'frozen_inputs_unchanged': len(frozen['inputs'])}))

if __name__ == '__main__':
    main()
