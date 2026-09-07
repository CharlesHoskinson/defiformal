#!/usr/bin/env python3
"""Freeze complete Interface source and measured evidence for both native reviewers."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[4]
BASE = ROOT / 'review/semantic-kernel/sprint10'
OUT = BASE / 'native-review-r1'
CANDIDATE = 'b165bc586080d668f689fbc18dfa09eb8739d688'
def sha(raw): return hashlib.sha256(raw).hexdigest()
def read(path): return json.loads(path.read_text())
def git(*args): return subprocess.check_output(['git', *args], cwd=ROOT)
proof = read(BASE/'proof-inventory-r1/proof-inventory.json')
assert proof['candidate'] == CANDIDATE and proof['execution']['status'] == 'PASS'
integration = read(BASE/'integration-r1/verification.json')
assert integration['candidate'] == CANDIDATE and integration['all_commands_passed']
assert integration['source_unchanged'] and integration['head_unchanged']
assert all(r['passed'] for r in integration['runtime_extraction_checks'])
for folder in ['mutations-r1', 'implementation/runner-controls-r1']:
    check = read(BASE/folder/'artifact-crosscheck.json')
    assert check['candidate'] == CANDIDATE and check['passed']
legacy = read(BASE/'implementation/legacy-dependency-equivalence.json')
assert legacy['revised_candidate'] == CANDIDATE and legacy['all_relevant_inputs_equal']
OUT.mkdir(exist_ok=False)
compact = {k: proof[k] for k in ['candidate', 'counts', 'discovery', 'validation',
    'source_module_count_scope', 'premise_and_scope_limits']}
compact['theorems'] = []
for row in proof['theorems']:
    item = {k: row[k] for k in ['name', 'module', 'axioms', 'category', 'declaration_origin']}
    item['statement_sha256'] = sha(row['statement'].encode())
    if row['declaration_origin'] == 'explicit':
        item['full_elaborated_statement'] = row['statement']
    compact['theorems'].append(item)
compact['supplemental'] = [{k: row[k] for k in ['name', 'module', 'axioms']} |
    {'statement_sha256': sha(row['statement'].encode())} for row in proof['supplemental']]
compact['scope'] = 'Explicit full types are presented. All generated/supplemental full types remain in the separately hash-bound original inventory and raw Lean output.'
(OUT/'proof-presentation.json').write_text(json.dumps(compact, indent=2)+'\n')
source = set(proof['source_bindings']) | {
    'lean/DefiKernel.lean', 'scripts/run_interface_mutations.py',
    'scripts/test_interface_mutation_runner.py', 'mutations/interface.json'}
change = ROOT/'openspec/changes/operational-interface-binding-preservation'
source.update(str(p.relative_to(ROOT)) for p in change.rglob('*') if p.is_file())
presented_evidence = [
    'planning/r2-gate-acceptance.json', 'planning/r2-review-gpt6.md',
    'planning/r2-review-fable-after-reset.md', 'planning/r2-review-fable-after-reset.invocation.json',
    'implementation/planning-review-disposition.md',
    'implementation/financial/runtime-inventory-r2.json', 'implementation/financial/fixture-map-r2.json',
    'integration-r1/verification.json', 'integration-r1/lean-runs.json', 'integration-r1/01.stdout.log',
    'proof-inventory-r1/proof-inventory-execution.json', 'native-review-r1/proof-presentation.json',
    'mutations-r1/REPORT.md', 'mutations-r1/results.json', 'mutations-r1/summary.json',
    'mutations-r1/sibling-matrix.json', 'mutations-r1/source-manifest.json',
    'mutations-r1/artifact-crosscheck.json',
    'implementation/runner-controls-r1/REPORT.md', 'implementation/runner-controls-r1/summary.json',
    'implementation/runner-controls-r1/artifact-crosscheck.json',
    'implementation/legacy-dependency-equivalence-r1-failure.json',
    'implementation/legacy-dependency-equivalence-r2.py',
    'implementation/legacy-dependency-equivalence.json',
    'coverage-measured-r1/scenario-map.json', 'coverage-measured-r1/preservation.json',
]
header = f'''Independently review DeFi Kernel operational Interface source and completed evidence.
SOURCE CANDIDATE: {CANDIDATE}. Return VERDICT: ACCEPT, ACCEPT WITH LIMITATIONS,
or REVISE, followed by BLOCKERS, REQUIRED CHANGES, LIMITATIONS and CLAIM/SCOPE
CHECK. Cite exact files/declarations. Review supplied source/proof/fixture/runner
and evidence sufficiency. Do not claim independent execution or proof by review.
No edits or external communication. Treat author reports as claims to inspect.
Both native reviewers receive these identical frozen bytes.

The package queries typed finite ledger regions and globally qualified live
resource bindings over the existing operational executor. It proves actual-step
and receipt-suffix accounting, initialized local-to-prefix invariant rules for
sequences, recursive sequential groups and binary shared interleavings, and
binding-preservation rules with explicit equal endpoint effects. Binding success
is insensitive to list grouping/permutation/orientation; ordered failure details
need not be. Symmetric closure equality is sufficient, not necessary. Transitive
redundancy has a concrete all-state proof. It does not generalize the executor
to arbitrary finite participants or reassociate atomic boundaries.

All 18 fresh integration commands passed at this source: 99 new runtime
comparisons and 987 including earlier audits. The dynamic imported audit checks
310 theorems (144 explicit:110 generic,32 reference,2 counterexample-classified;
166 generated) and356 supplemental declarations, with zero forbidden axioms.
Inspect actual statement premises, full finite expected worlds/stores, actual
execution equations and universal local-rule instances. Initialized region
totals require confinement, regional receipt neutrality, support exclusion and
initial equality. Financial counterexamples are also documented by groups of
reference-instance theorems; category totals are an inventory classification.

All14 production mutations compile and falsify designated observations while
retaining both globals and separate siblings:15 inventories of99 observations,
1485 total. These are query mutations; actual financial fixtures execute the
existing kernel. They do not mutate admission/authority/executor internals.
All65 actual synthetic CLI controls passed with exact10/5/50 exit classes.
Inspect false overlap, complete inventories, log/source/tool hashes and genuine
600-second production timeout; failures are blocked, not detected. Old proofs
remain in runtime closure; only new Interface proof suffixes are projected away.
The13 historical regression suites EXECUTED at c880acf, not here. The supplied
exact relevant-dependency and binary check retains their identities. The initial
checker assertion failure and narrow root-import allowlist correction are saved.

All57 normative scenarios have measured evidence links. Final native acceptance,
adjudication, branch delivery and archive remain pending until this review gate
passes. Do not infer completed administrative tasks from the author evidence.
No machine arithmetic, deployed protocol fidelity, untouched evaluation,
liveness, unconditional solvency, private-state confidentiality or arbitrary
parallel regrouping is claimed. Trusted configuration/store/boundary inputs,
exact rational arithmetic and explicit causal/inductive premises remain.
Unrelated in-flight Arithmetic and other planning work is outside this candidate.
'''
parts = [header]
rows = []
seen = set()
def bind(path, present, source_bound=False):
    relative = str(path.relative_to(ROOT))
    if relative in seen: return
    seen.add(relative)
    raw = path.read_bytes()
    row = {'path': relative, 'sha256': sha(raw), 'bytes': len(raw),
           'presentation': 'full bytes in bundle' if present else 'hash-bound retained artifact'}
    if source_bound:
        assert git('show', f'{CANDIDATE}:{relative}') == raw, relative
        row['git_blob'] = git('rev-parse', f'{CANDIDATE}:{relative}').decode().strip()
    rows.append(row)
    if present:
        parts.append(f'\n\n===== INPUT {relative} SHA256 {row["sha256"]} =====\n'+raw.decode())
for path in sorted(source): bind(ROOT/path, True, True)
for path in presented_evidence: bind(BASE/path, True)
# Retain all actual logs, source projections, command records and environment types.
for folder in ['mutations-r1', 'implementation/runner-controls-r1', 'integration-r1',
               'proof-inventory-r1', 'coverage-measured-r1', 'implementation/financial',
               'implementation/regions-accounting-preservation']:
    for path in sorted((BASE/folder).rglob('*')):
        if path.is_file() and not path.is_symlink(): bind(path, False)
raw = ''.join(parts).encode()
(OUT/'bundle.md').write_bytes(raw)
manifest = {'candidate': CANDIDATE, 'kind': 'Interface source and completed proof/runtime/mutation/control evidence; acceptance pending',
    'captured_utc': datetime.now(timezone.utc).isoformat(), 'working_head': git('rev-parse','HEAD').decode().strip(),
    'inputs': rows, 'input_count': len(rows), 'bundle_sha256': sha(raw), 'bundle_bytes': len(raw),
    'builder_sha256': sha(Path(__file__).read_bytes())}
(OUT/'candidate.json').write_text(json.dumps(manifest, indent=2)+'\n')
print(json.dumps({k:v for k,v in manifest.items() if k != 'inputs'}, indent=2))
