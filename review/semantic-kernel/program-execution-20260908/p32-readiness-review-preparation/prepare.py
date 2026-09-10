from pathlib import Path
import datetime, hashlib, json, shutil, subprocess

r = Path('/home/charl/defiformal')
b = r / 'review/semantic-kernel/program-execution-20260908'
cache = Path('/home/charl/.cache/defiformal-program/program-execution-20260908')
prep = b / 'p32-readiness-review-preparation'
sandbox = cache / 'p32-readiness-grok-r1-sandbox'
out = b / 'p32-readiness-grok-r1'
read = lambda p: json.loads(p.read_text())
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
write = lambda p, d: p.write_text(json.dumps(d, indent=2) + '\n')
now = lambda: datetime.datetime.now(datetime.timezone.utc).isoformat()
assert not prep.exists() and not sandbox.exists() and not out.exists()
source = b / 'p32-readiness-preparation'
seal = read(source / 'root-seal.json')
for name, digest in seal['files'].items():
    assert sha(source / name) == digest, name
bindings = read(source / 'source-bindings.json')['files']
for name, digest in bindings.items():
    assert sha(r / name) == digest, name
files = set(bindings)
files.update(str(p.relative_to(r)) for p in source.iterdir() if p.is_file())
baseline = r / 'review/semantic-kernel/uniswap-token0/p16/implementation/grok-r6/compiler/baseline'
files.update(str(p.relative_to(r)) for p in baseline.rglob('*') if p.is_file())
files.add('review/semantic-kernel/program-execution-20260908/PLAN-ACCEPTANCE.md')
prep.mkdir()
sandbox.mkdir()
frozen = {}
for name in sorted(files):
    p = r / name
    assert not p.is_symlink(), name
    dest = sandbox / name
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(p, dest)
    frozen[name] = sha(p)
    assert sha(dest) == frozen[name]
write(prep / 'inputs.json', {'schema': 'defiformal-review-inputs/v1', 'utc': now(),
      'sandbox': str(sandbox), 'source_head': subprocess.check_output(
          ['git', 'rev-parse', 'HEAD'], cwd=r, text=True).strip(), 'files': frozen,
      'scope': 'Six P32 readiness records, bound requirements and historical P16 source/compiler evidence; no held assessment cases'})
brief = f'''Independently audit P32 environment readiness tasks33.1-33.7. You are the fresh native Grok4.6 high reviewer, not the author. Work in {sandbox}; write final evidence only to {out}. No subagents, Foreman, implementation edits, Lean builds, package installation, or selection/inspection of held assessment payloads. Maximum20 turns; reserve final turns for all five reports.
Read review/semantic-kernel/program-execution-20260908/p32-readiness-preparation/README.md, readiness-index.json and all six environment JSON records; then bound tasks.md/spec.md/environment-scope-inputs.json and PLAN-ACCEPTANCE.md. Historical model names are not current assignments. Verify every input hash from {out}/inputs.json before/after. Do not rerun capture.py: it writes original evidence. Use your own uniquely named probe directories, preserving every failed source/command/output.
Assess actual task scope: six readiness records are required, and missing source/toolchain bindings must remain explicit blocked_unavailable. Readiness records do not prove P34 execution or whole-program completion. EVM token0 cannot score other environments. Determine whether each record and task33.7 is acceptable on this scope; do not accept missing implementation pins as available platforms. Source-plan line1116 is agenda input only. No mainnet deployment is claimed.
For EVM, cross-check seven source-closure hashes, Uniswap commit/tag, actual helper, standard-json input settings, genesis/prestate, source overlay, compiler receipts and runtime bytes. Full baseline compiler evidence is frozen alongside the earlier20 source bindings. Distinguish compiler evmVersion from supplied genesis execution fork. Re-run only the two absolute-path --version commands using your own output directory; verify binary hashes against frozen receipts. Existing twelve token0 comparisons/six mutations are historical accepted P16 evidence, not new P32 execution. No compilation/financial rerun required absent a specific discrepancy.
For five missing environments, inspect exact bounded discovery method and declared searched roots/PATH. Absence from those lookups is not whole-machine or public-network absence. Check missing source/deployment/toolchain fields and concrete unblock requirements; generic Rust/Go are not chain readiness. You may repeat bounded discovery read-only, with timestamps and exact scope. Do not install tools or invent a source selection.
Final files: REVIEW.md, verdict.json, findings.json, commands.json, MANIFEST.json. Include exact reviewed hashes, requested/reported model/session identity from actual native evidence if available (unknown stays unknown), per-task verdicts, findings with evidence and fixes, limitations, and explicit P34/whole-program nonacceptance. commands.json binds each actual argv/cwd/start/end/exit/tool hash/source hash/raw stdout+stderr paths and hashes; never invent missing data. MANIFEST.json self-excludes and hashes every report/probe/log you wrote. Tool output and failed attempts are evidence, not proof. Root alone adjudicates and publishes. Finish all five artifacts even if findings remain.
'''
(prep / 'brief.txt').write_text(brief)
launcher = (b / 'p31-zkir-artifact-review-preparation/launcher.py').read_text()
launcher = launcher.replace('p31-zkir-artifact', 'p32-readiness')
start = launcher.index("assert (b/'p19-structural")
end = launcher.index('for entry in b.iterdir():', start)
launcher = launcher[:start] + launcher[end:]
launcher = launcher.replace('P31 generated ZKIR artifact/interface preparation and native mock-format controls', 'P32 six environment readiness records and exact P16 evidence bindings')
compile(launcher, str(prep / 'launcher.py'), 'exec')
(prep / 'launcher.py').write_text(launcher)
shutil.copy2(__file__, prep / 'prepare.py')
write(prep / 'preparation.json', {'utc': now(), 'status': 'prepared_not_dispatched',
      'requested_model': 'grok-4.6', 'effort': 'high', 'fresh_session': True,
      'frozen_files': len(frozen), 'brief_sha256': sha(prep / 'brief.txt'),
      'priority': 'After current P31 review; terminal P19 candidate review has priority',
      'acceptance': False, 'p34_accepted': False})
write(prep / 'root-seal.json', {'utc': now(), 'files': {
    str(p.relative_to(prep)): sha(p) for p in sorted(prep.iterdir()) if p.is_file()},
    'acceptance': False})
print(json.dumps({'prepared_files': len(frozen), 'status': 'prepared_not_dispatched',
                  'brief_sha256': sha(prep / 'brief.txt')}))
