#!/usr/bin/env python3
"""Bind current configuration without changing the author's M3 plan."""
import hashlib
import json
from pathlib import Path
import subprocess
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[5]
OUT = Path(__file__).resolve().parent
AUTHOR = ROOT / 'review/semantic-kernel/sprint11/planning/accepted-m2-refresh'
PLAN = ROOT / 'openspec/changes/finite-participant-causal-composition'

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

def record(path):
    raw = (ROOT / path).read_bytes()
    return {'path': path, 'sha256': digest(raw), 'bytes': len(raw)}

def main():
    head = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
    author = json.loads((AUTHOR / 'artifact-manifest.json').read_bytes())
    assert len(author['files']) == 50
    for row in author['files']:
        assert record(row['path']) == {k: row[k] for k in ['path', 'sha256', 'bytes']}, row['path']
    closure = json.loads((AUTHOR / 'accepted-runtime-closure.json').read_bytes())
    checks = []
    for row in closure['modules']:
        old = subprocess.check_output(['git', 'show', closure['source_candidate'] + ':' + row['path']], cwd=ROOT)
        now = (ROOT / row['path']).read_bytes()
        assert old == now and digest(now) == row['sha256'], row['path']
        checks.append({**record(row['path']), 'equal_to_accepted_source': True})
    integration_path = 'review/semantic-kernel/claim-reconciliation/implementation/library-integration/fresh-r1/result.json'
    integration = json.loads((ROOT / integration_path).read_bytes())
    assert integration['status'] == 'PASS'
    configs = ['lean/lakefile.toml', 'lean/lake-manifest.json', 'lean/lean-toolchain', 'lean/DefiKernel.lean']
    for path in configs:
        assert record(path)['sha256'] == integration['source_before'][path]['sha256'], path
        assert integration['source_before'][path] == integration['source_after'][path], path
    result = {
        'kind': 'current_M3_planning_context_not_new_M3_execution',
        'utc': datetime.now(timezone.utc).isoformat(), 'head': head,
        'author_manifest': record(str((AUTHOR / 'artifact-manifest.json').relative_to(ROOT))),
        'author_50_inputs_unchanged': True, 'accepted_runtime_modules': checks,
        'configuration': [record(path) for path in configs],
        'fresh_integration': record(integration_path), 'actual_integration_candidate': integration['candidate'],
        'limits': [
            'Only the author plan and current dependency context are prepared here; independent planning reviews remain open.',
            'The third DefiHistorical Lake library changes the previous complete configuration. No whole-input equivalence to accepted M2 execution is claimed.',
            'Seven affected integration commands were executed at ce5bed24; prior mutation and control runs keep their original revisions.',
            'The existing 18 runtime dependency modules still match accepted M2 source; the proposed Nary API and its 16 mutations/65 controls have not been implemented or executed.',
            'The parent prepares this bundle and context; the separate nonauthor GPT-6 reviewer did not author the M3 plan.'
        ]
    }
    (OUT / 'current-context.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'author_files': 50, 'equal_runtime_modules': len(checks), 'actual_integration_candidate': integration['candidate']}))

if __name__ == '__main__':
    main()
