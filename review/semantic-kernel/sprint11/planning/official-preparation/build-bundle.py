#!/usr/bin/env python3
"""Freeze committed M3 planning source and dependency evidence for both reviewers."""
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[5]
PREP = Path(__file__).resolve().parent
OUT = PREP.parent / 'official-r1'
AUTHOR = PREP.parent / 'accepted-m2-refresh'
PLAN = ROOT / 'openspec/changes/finite-participant-causal-composition'

def main():
    sha = lambda raw: hashlib.sha256(raw).hexdigest()
    candidate = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
    author = json.loads((AUTHOR / 'artifact-manifest.json').read_bytes())
    paths = {row['path'] for row in author['files']}
    paths.add(str((AUTHOR / 'artifact-manifest.json').relative_to(ROOT)))
    paths |= {str(p.relative_to(ROOT)) for p in PREP.glob('*') if p.is_file()}
    closure = json.loads((AUTHOR / 'accepted-runtime-closure.json').read_bytes())
    paths |= {row['path'] for row in closure['modules']}
    baseline = json.loads((PLAN / 'dependency-baseline.json').read_bytes())
    paths |= {row['path'] for row in baseline['baseline_references']}
    for directory in ['lean/DefiKernel/Interface', 'lean/DefiKernel/Interleaving', 'lean/DefiKernel/Metatheory']:
        paths |= {str(p.relative_to(ROOT)) for p in (ROOT / directory).glob('*.lean')}
    paths |= {
        'AGENTS.md', 'docs/superpowers/specs/2026-09-06-semantic-kernel-design.md',
        '.claude/skills/defi-footguns/SKILL.md', 'formal/v3/GATE-REGISTER.md',
        'lean/lakefile.toml', 'lean/lake-manifest.json', 'lean/lean-toolchain', 'lean/DefiKernel.lean',
        'scripts/run_interface_mutations.py', 'scripts/test_interface_mutation_runner.py',
        'review/semantic-kernel/sprint10/ADJUDICATION.md',
        'review/semantic-kernel/claim-reconciliation/implementation/library-integration/configuration-change.json',
        'review/semantic-kernel/claim-reconciliation/implementation/library-integration/lakefile-before.toml',
        'review/semantic-kernel/claim-reconciliation/implementation/library-integration/run-checks.py',
    }
    integration = ROOT / 'review/semantic-kernel/claim-reconciliation/implementation/library-integration/fresh-r1'
    paths |= {str(p.relative_to(ROOT)) for p in integration.iterdir() if p.is_file()}
    header = f'''Independently review the finite-participant causal-composition OpenSpec planning candidate {candidate}.
The author is stock GPT-6 agent Hegel. This is a planning gate, not implemented Nary code or proof acceptance. Both nonauthor GPT-6 and native Fable 5.1 medium receive this identical bundle. The parent only prepared the current dependency context and bundle; the nonauthor reviewer must independently assess the normative design and literal contracts.

Scope: 5 capabilities, 19 requirements, 52 scenarios, 35 unchecked tasks, 19 fixtures, 16 actual source mutations to implement, and 65 inherited CLI controls to adapt. Assess executability, mathematical sufficiency and noncircularity, finite roster/admission precedence, exact binary correspondence, continuation from arbitrary populated machine, initialized peer interference, causal monitor update/erasure/common-prefix statements, and actual financial witnesses. Check all complete observations, refusals and stored histories/capabilities. Validate proposed contracts against actual accepted APIs, literal schedules, source-mutant sites and exact driver substitutions. Reject compiler failures or synthetic parser/comparator controls promoted to semantic mutation evidence.

Accepted M2 is b165bc586080d668f689fbc18dfa09eb8739d688. Existing 18 runtime modules still match; historical baseline executions retain their actual identities. Current Lake adds the third DefiHistorical library and the root includes accepted Arithmetic. Fresh seven-command affected integration at ce5bed24 is supplied separately, not relabeled as original M2 or M3 execution. The author refresh's original run/manifest remain unchanged. Current-context.json explains the configuration delta.

No finite operational implementation, unrestricted schedule independence, participant-tree regrouping, active extension, atomic transfer, deployment fidelity or untouched holdout credit is supplied. Those remain later work. Review advisory evidence is not a theorem. Return ACCEPT WITH LIMITATIONS, NEEDS REVISION or REJECT with concrete required changes, other findings, inspected evidence, and limits. Do not edit files, communicate externally or assume advertised tool restrictions are enforced. Record any extra read-only probes distinctly from this frozen supplied bundle.
'''
    parts = [header.encode()]
    rows = []
    for rel in sorted(paths):
        p = ROOT / rel
        raw = p.read_bytes()
        assert subprocess.check_output(['git', 'show', candidate + ':' + rel], cwd=ROOT) == raw, rel
        rendered = (json.dumps(json.loads(raw), ensure_ascii=False, separators=(',', ':')) + '\n').encode() if p.suffix == '.json' else raw
        rows.append({'path': rel, 'sha256': sha(raw), 'bytes': len(raw),
                     'rendered_sha256': sha(rendered), 'rendered_bytes': len(rendered),
                     'representation': 'lossless_compact_json' if p.suffix == '.json' else 'verbatim_utf8'})
        parts.extend([f'\n\n## INPUT {rel}\nSource SHA256 {sha(raw)}\nRendered SHA256 {sha(rendered)}\n\n'.encode(), rendered])
    data = b''.join(parts)
    OUT.mkdir(exist_ok=False)
    (OUT / 'bundle.md').write_bytes(data)
    manifest = {'kind': 'openspec-planning-finite-participant-causal-composition-r1',
                'candidate': candidate, 'inputs': rows, 'input_count': len(rows),
                'bundle_sha256': sha(data), 'bundle_bytes': len(data),
                'scope': {'capabilities': 5, 'requirements': 19, 'scenarios': 52, 'unchecked_tasks': 35,
                          'planned_fixtures': 19, 'planned_mutants': 16, 'planned_controls': 65}}
    (OUT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps({k: v for k, v in manifest.items() if k != 'inputs'}))

if __name__ == '__main__':
    main()
