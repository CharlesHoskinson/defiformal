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
    refresh = ROOT / 'review/semantic-kernel/corpus-provenance-adjudication/planning/official-r2-preparation'
    context = json.loads((ROOT / 'openspec/changes/corpus-provenance-adjudication/context-files.json').read_bytes())
    paths = {row['path'] for row in context['files']}
    paths.update(str(p.relative_to(ROOT)) for p in
                 (ROOT / 'openspec/changes/corpus-provenance-adjudication').rglob('*') if p.is_file())
    paths.update(str((refresh / name).relative_to(ROOT)) for name in [
        'READINESS.md', 'resolution.json', 'seal.json', 'actual-disputes.json',
        'protected-git-equivalence.json', 'artifact-manifest.json'])
    paths.update([
        'review/semantic-kernel/corpus-provenance-adjudication/source-research/consolidated-01/INDEX.md',
        'review/semantic-kernel/corpus-provenance-adjudication/source-research/consolidated-01/coverage.json',
        'review/semantic-kernel/corpus-provenance-adjudication/source-research/consolidated-01/remaining-research-queue.json',
        'review/semantic-kernel/corpus-provenance-adjudication/source-research/consolidated-01/artifact-manifest.json',
        'review/semantic-kernel/corpus-provenance-adjudication/planning/refresh-02/baseline-reuse.json',
    ])
    prompt = 'You are a nonauthor planning reviewer for DeFiFormal corpus-provenance-adjudication official-r2. Return VERDICT: ACCEPT WITH LIMITATIONS or REQUEST CHANGES, followed by blockers, lesser findings and scope limits. Review the complete normative proposal/design/five specs/tasks/rules/control inventory, current corpus and tool context, prior native findings and exact14-finding resolution. No edits, external communication or claimed execution. Public rationale only. Author static checks are evidence to inspect, not independent proof.\n\nThis revision addresses all3 blocking and11 lesser official-r1 Fable findings. Scope5capabilities20requirements65scenarios28uncheckedtasks,18literal rules,39control families116 separately named planned CLI cases. Judge historical-primary applicability, source-scoped projections, empty/wrapper normalization, retained extraction bytes, uniform reviewed interpretation selection, deterministic effective heads, exact acquisition limits, exposure membership, origin-trust assumptions and enforced offline verification. All current research imports remain draft/review_pending; capture validity does not adjudicate their factual claims.\n\nThe frozen research packets cover all29facetdisputes/32labelinstances plus the separate Liquity challenge. All75original candidates remain development and zero deployments have been verified. All12 proposed evaluation cases are exposed; no replacement holdout selection or reading is authorized here. Mutable current documentation alone does not revise the preserved historical Aug4 research snapshot. Unresolved factual work must stay visible even if bookkeeping is complete.\n\nActual tooling, old normalization and research records retain their original source/time/tool identities. No new corpus collector/checker,116-control execution or source adjudication is claimed by this plan. The current inventories are the r2 author revision, with previous bytes preserved as historical snapshots. S10 operational Interface is implemented/measured at b165bc5 and its separate finalnative gate is running; that gate does not approve corpus work. Existing arithmetic work is outside this plan. Stock GPT6 implementation, native Grok/Fable final review, no Foreman.\n\nAll JSON presentation is lossless compact serialization with separately bound source/rendered hashes. Text is verbatim. Raw primary capture bodies and full batch logs are not reproduced: this is a planning gate, not adjudication or deployment/fidelity approval.\n'
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
