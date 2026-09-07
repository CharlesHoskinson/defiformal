#!/usr/bin/env python3
"""Freeze the current corpus plan; compact JSON losslessly for native review."""
from pathlib import Path
import datetime
import hashlib
import json
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]

def sha(raw):
    return hashlib.sha256(raw).hexdigest()

def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)

def main():
    head = git('rev-parse', 'HEAD').decode().strip()
    refresh = ROOT / 'review/semantic-kernel/corpus-provenance-adjudication/planning/refresh-03'
    context = json.loads((refresh / 'context-files.json').read_bytes())
    paths = {row['path'] for row in context['files']}
    paths.update(str(p.relative_to(ROOT)) for p in
                 (ROOT / 'openspec/changes/corpus-provenance-adjudication').rglob('*') if p.is_file())
    paths.update(str((refresh / name).relative_to(ROOT)) for name in [
        'REPORT.md', 'scenario-map.json', 'context-files.json', 'research-input-inventory.json',
        'rule-reference-equivalence.json', 'artifact-manifest.json'])
    paths.update([
        'review/semantic-kernel/corpus-provenance-adjudication/source-research/consolidated-01/INDEX.md',
        'review/semantic-kernel/corpus-provenance-adjudication/source-research/consolidated-01/coverage.json',
        'review/semantic-kernel/corpus-provenance-adjudication/source-research/consolidated-01/remaining-research-queue.json',
        'review/semantic-kernel/corpus-provenance-adjudication/source-research/consolidated-01/artifact-manifest.json',
        'review/semantic-kernel/corpus-provenance-adjudication/planning/refresh-02/baseline-reuse.json',
    ])
    prompt = '''You are an independent planning reviewer for DeFiFormal's corpus-provenance-adjudication OpenSpec change. Return a substantive plain-text VERDICT: ACCEPT WITH LIMITATIONS or REQUEST CHANGES, then blocking findings, lesser findings and scope limits. You have no tools; do not emit XML/tool requests or pretend to run code. Review the complete normative proposal/design/five specs/tasks and the actual current corpus/tool context supplied below. The planned scope is5 capabilities,20 requirements,48 scenarios,28 unchecked tasks,18 literal evidence predicates. Evaluate implementability, exact raw-observation preservation, source/deployment/fidelity boundaries, source imports versus original recovery, deterministic real CLI checks, honest blocked/violated outcomes, meaningful controls and monotonic development exposure. Identify missing contracts or loopholes before implementation.

The existing25 source packets cover29 disputed facets/32label instances plus a separate Liquity liquidation challenge, but every proposal is unaccepted. This planning review is NOT their factual adjudication or deployment verification. The consolidated index is a frozen research snapshot:51units lack an exact-ID source packet at that snapshot; concurrent later research cannot silently alter it. The complete raw HTTP/PDF captures are not reproduced here. Full source packets remain bound in their manifests for later implementation/evidence review. Do not infer semantic truth from packet hashes or schema validity.

Original OpenSpec context/scenario metadata and previous readiness records are preserved historical artifacts. The current normative text and refresh-03 maps govern this freeze; the bundle manifest records current input hashes at its candidate. Some historical records were authored at4d42600 or earlier and retain that identity. Sprint9 is accepted at eec499d6 and archived/delivered9908d9b. Sprint10 has no implementation; its required nativeFable planning review is pending. This independent corpus package has its own gate. All12 previously proposed evaluation cases are development-exposed; no new holdout may be acquired here. Current native review policy is Fable5.1 medium; preserve earlier Opus/Fable identities. GPT6 implementation uses stock harness, no Foreman.

JSON files are rendered by lossless compact serialization; source hashes and rendered hashes are distinct. Other text is verbatim. No current checker implementation exists, no production collector run is fabricated, and baseline tests retain their actual c880 execution identity through recorded source equivalence. Do not treat planned controls as executed evidence. Give concise public rationale, not private reasoning.\n'''
    chunks = [prompt, '\nFrozen candidate: ' + head + '\n']
    inputs = []
    for path in sorted(paths):
        raw = (ROOT / path).read_bytes()
        assert git('show', head + ':' + path) == raw, path
        if path.endswith('.json'):
            parsed = json.loads(raw)
            rendered = json.dumps(parsed, ensure_ascii=False, separators=(',', ':')).encode()
            assert json.loads(rendered) == parsed
            mode = 'lossless_compact_json'
        else:
            rendered = raw
            mode = 'verbatim'
        inputs.append({'path': path, 'bytes': len(raw), 'sha256': sha(raw),
                       'git_blob': git('rev-parse', head + ':' + path).decode().strip(),
                       'matches_candidate': True, 'rendering': mode,
                       'rendered_bytes': len(rendered), 'rendered_sha256': sha(rendered)})
        chunks.append('\n===== FILE ' + path + ' | SOURCE SHA256 ' + sha(raw) +
                      ' | RENDERING ' + mode + ' =====\n' + rendered.decode('utf-8') +
                      '\n===== END FILE =====\n')
    bundle = ''.join(chunks).encode()
    for row in inputs:
        assert sha((ROOT / row['path']).read_bytes()) == row['sha256'], row['path']
    assert git('rev-parse', 'HEAD').decode().strip() == head
    s10_path = ROOT / 'review/semantic-kernel/sprint10/planning/r2-candidate.json'
    s10 = json.loads(s10_path.read_bytes())
    assert all(sha((ROOT / row['path']).read_bytes()) == row['sha256'] for row in s10['inputs'])
    manifest = {'kind': 'same-candidate-independent-planning-review', 'candidate': head,
                'created_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
                'input_count': len(inputs), 'inputs': inputs,
                'bundle_sha256': sha(bundle), 'bundle_bytes': len(bundle),
                'builder': {'path': str(Path(__file__).relative_to(ROOT)),
                            'sha256': sha(Path(__file__).read_bytes()),
                            'role': 'local evidence helper; not a normative implementation'},
                'frozen_s10_inputs_unchanged': len(s10['inputs']),
                'planning_accepted': False, 'implementation_authorized': False,
                'omitted_evidence': 'Raw primary capture bodies and full batch tool logs are not rendered; no factual adjudication acceptance is sought.'}
    for name, data in [('bundle.md', bundle), ('manifest.json', (json.dumps(manifest, indent=2) + '\n').encode())]:
        with (HERE / name).open('xb') as handle:
            handle.write(data)
    print(json.dumps({'candidate': head, 'input_count': len(inputs), 'bytes': len(bundle),
                      'sha256': sha(bundle), 's10_inputs_unchanged': len(s10['inputs'])}))

if __name__ == '__main__':
    main()
