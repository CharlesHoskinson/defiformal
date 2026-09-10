from pathlib import Path
import datetime, hashlib, json, shutil, subprocess

r = Path('/home/charl/defiformal')
b = r / 'review/semantic-kernel/program-execution-20260908'
cache = Path('/home/charl/.cache/defiformal-program/program-execution-20260908')
prep = b / 'p31-zkir-source-review-preparation'
sandbox = cache / 'p31-zkir-source-grok-r1-sandbox'
out = b / 'p31-zkir-source-grok-r1'
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
read = lambda p: json.loads(p.read_text())
write = lambda p, d: p.write_text(json.dumps(d, indent=2) + '\n')
now = lambda: datetime.datetime.now(datetime.timezone.utc).isoformat()
assert not prep.exists() and not sandbox.exists() and not out.exists()
paths = {}
old = read(b / 'p31-zkir-artifact-grok-r1/inputs.json')
for name, digest in old['files'].items():
    p = Path(old['sandbox']) / name
    assert sha(p) == digest, name
    paths[name] = p
for name in ['p31-zkir-source-preparation', 'p31-compact-release-binding']:
    source = b / name
    seal = read(source / 'root-seal.json')
    for path, digest in seal['files'].items():
        assert sha(source / path) == digest, path
        paths[name + '/' + path] = source / path
    paths[name + '/root-seal.json'] = source / 'root-seal.json'
for name in ['root-adjudication.json', 'closeout/REVIEW.md']:
    paths['root-context/artifact-review/' + name] = b / 'p31-zkir-artifact-grok-r1' / name
prep.mkdir()
sandbox.mkdir()
files = {}
for name, source in sorted(paths.items()):
    assert source.is_file() and not source.is_symlink()
    dest = sandbox / name
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, dest)
    files[name] = sha(source)
    assert sha(dest) == files[name]
write(prep / 'inputs.json', {'schema': 'defiformal-review-inputs/v1', 'utc': now(),
    'sandbox': str(sandbox), 'source_head': subprocess.check_output(
        ['git', 'rev-parse', 'HEAD'], cwd=r, text=True).strip(), 'files': files,
    'scope': 'Pinned ZKIR crate/source/release metadata and already reviewed generated artifact context'})
brief = f'''Fresh independent native Grok4.6 high review of P31 ZKIR source and release binding preparation. Sandbox {sandbox}, reports {out}. No other worker/source/cache inspection. No subagents, Foreman, network, package installation, source edits, Rust/Lean builds, key generation, branches, commits or pushes. Source/tree/release/crate bytes are frozen; verify all hashes before/after. Use output-only uniquely named probes if a specific discrepancy requires them. Existing mock/materialization checks are sealed historical evidence; do not rerun without a concrete unresolved concern.
Read p31-zkir-source-preparation/README.md and discovery/source-comparison/semantic-source-navigation/fetch-receipts/root-seal, then p31-compact-release-binding/README.md and binding/release/tag/tree/fetch records. Cross-check original crate archive checksum with registry metadata, crate VCS commit and six Git-comparable source files, all four distinct commits and exact matching/differing file sets. Normalized Cargo.toml/Cargo.lock/VCS metadata are package files, not falsely matched Git files. Check fetched LICENSE provenance. HTTP404 release lookup is retained; a Git tag exists. Original failing script is not to rerun or overwrite.
Read the captured ir.rs, ir_vm.rs, main.rs and library/Cargo manifests. Check the claimed locations for all12 observed circuit opcodes and version2.0 loader. Distinguish schema definitions, preprocessing, constraint construction, cost-model/mock execution and cryptographic proving. In particular verify field arithmetic/range/boolean/index assumptions, public-input/skip transcript behavior and communications commitment boundaries. Dependencies are declared/pinned metadata but their full semantic source closure is not captured. This is a source-navigation/readiness preparation, not a new accepted normative semantic contract or adapter implementation.
Release binding: locally installed archive digest matches official GitHub asset digest and all6members match installed files. Audit exact source_tag_commit against complete tree: the release snapshot does not supply compiler build sources. Artifact identity does not prove source-to-binary equivalence. Review root's disclosed build assumption without inventing a mandatory reproducible-build gate absent the accepted task/spec. A source version match alone is insufficient to claim compiler correctness. You may read/hash the existing archive and binaries at paths in binding.json; no execution required. Do not duplicate the27MB archive in reports.
Read root-context/artifact-review and accepted-program/tasks/spec and P31 readiness acceptance. Preserve accepted tasks32.1-32.4; clarify how newly acquired source changes the historical source/interface gap without rewriting old evidence. Assess whether this exact source/release preparation is usable for a subsequent reviewed ZKIR interface design. Keep actual semantics/Compact-to-ZKIR correspondence, adapter32.7/32.9 and P20-dependent PCT/fullP31 open. Do not credit materialization or mock acceptance as constraint soundness, ledger settlement or correspondence. No new independent full-proof claim.
Maximum20turns. Write draft verdict/findings by turn10, reserve final7 for all five final reports: REVIEW.md, verdict.json, findings.json, commands.json, self-excluding MANIFEST.json. Every executed command binds exact argv/cwd/start/end/exit/tool/source/rawstdout/rawstderr identities; non-command read/hash observations should be labeled observations, not fabricated command receipts. Unknown identity stays unknown; root captures actual native model. Preserve failures separately. Root alone verifies, adjudicates and publishes. End immediately after complete reports/manifest. Same scope acceptance remains separate from full adapter acceptance.
'''
(prep / 'brief.txt').write_text(brief)
launcher = (b / 'p32-readiness-review-preparation/launcher.py').read_text().replace('p32-readiness', 'p31-zkir-source')
launcher = launcher.replace('P32 six environment readiness records and exact P16 evidence bindings', 'P31 pinned ZKIR source and Compact release identity readiness review')
compile(launcher, str(prep / 'launcher.py'), 'exec')
(prep / 'launcher.py').write_text(launcher)
shutil.copy2(__file__, prep / 'prepare.py')
write(prep / 'preparation.json', {'utc': now(), 'status': 'prepared_not_dispatched',
    'requested_model': 'grok-4.6', 'effort': 'high', 'fresh_session': True,
    'frozen_files': len(files), 'brief_sha256': sha(prep / 'brief.txt'),
    'priority': 'After active P19 review, terminal P19 candidate review and already queued P32 readiness review',
    'acceptance': False})
write(prep / 'root-seal.json', {'utc': now(), 'files': {
    str(p.relative_to(prep)): sha(p) for p in sorted(prep.iterdir()) if p.is_file()}, 'acceptance': False})
print(json.dumps({'frozen_files': len(files), 'status': 'prepared_not_dispatched',
                  'brief_sha256': sha(prep / 'brief.txt')}))
