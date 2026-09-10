from pathlib import Path
import datetime, hashlib, json, re, shutil

o = Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p31-zkir-source-preparation')
read = lambda p: json.loads(p.read_text())
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
write = lambda p, d: p.write_text(json.dumps(d, indent=2) + '\n')
now = lambda: datetime.datetime.now(datetime.timezone.utc).isoformat()
assert not (o / 'root-seal.json').exists()
receipts = read(o / 'fetch-receipts.json')
for rec in receipts:
    if 'path' in rec:
        assert sha(o / rec['path']) == rec['sha256'], rec['path']
discovery = read(o / 'discovery.json')
root = o / 'crate/midnight-zkir-2.1.0'
for path, digest in discovery['crate_files'].items(): assert sha(root / path) == digest
comp = read(o / 'source-comparison.json')
trees = {name: read(o / ('crate-commit-tree.json' if name == 'crate-vcs' else name + '-tree.json'))
         for name in comp['commits']}
for f in comp['files']:
    p = root / f['crate_path']
    data = p.read_bytes()
    assert sha(p) == f['crate_sha256']
    blob = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
    assert blob == f['computed_git_blob']
    for name, result in f['commits'].items():
        entry = next(x for x in trees[name]['tree'] if x['path'] == f['git_path'])
        assert entry['sha'] == result['blob']
        assert (entry['sha'] == blob) == result['matches_crate']

ir = (root / 'src/ir.rs').read_text().splitlines()
vm = (root / 'src/ir_vm.rs').read_text().splitlines()
opcodes = {'add': 'Add', 'assert': 'Assert', 'cond_select': 'CondSelect',
    'constrain_bits': 'ConstrainBits', 'constrain_to_boolean': 'ConstrainToBoolean',
    'declare_pub_input': 'DeclarePubInput', 'less_than': 'LessThan', 'load_imm': 'LoadImm',
    'mul': 'Mul', 'neg': 'Neg', 'pi_skip': 'PiSkip', 'test_eq': 'TestEq'}
navigation = []
for op, variant in opcodes.items():
    defs = [n for n, line in enumerate(ir, 1) if re.match(r'    ' + variant + r'\s*\{', line)]
    implementations = [n for n, line in enumerate(vm, 1) if 'I::' + variant + ' {' in line]
    assert len(defs) == 1 and len(implementations) >= 2, (op, defs, implementations)
    navigation.append({'observed_opcode': op, 'rust_variant': variant,
        'definition_file': 'crate/midnight-zkir-2.1.0/src/ir.rs', 'definition_line': defs[0],
        'implementation_file': 'crate/midnight-zkir-2.1.0/src/ir_vm.rs',
        'implementation_match_lines': implementations,
        'scope': 'Navigation to both preprocessing and constraint construction; no correspondence proof claimed'})
write(o / 'semantic-source-navigation.json', {'utc': now(), 'observed_opcode_count': len(navigation),
    'opcodes': navigation, 'source_commit': discovery['crate_vcs']['git']['sha1'],
    'source_ir_sha256': sha(root / 'src/ir.rs'), 'source_vm_sha256': sha(root / 'src/ir_vm.rs'),
    'semantic_contract_accepted': False, 'acceptance': False})
(o / 'README.md').write_text('''# P31 ZKIR source preparation

Root located and captured published `midnight-zkir` 2.1.0 source for the next interface review. This is source evidence; the ZKIR adapter and its semantic contract remain unaccepted.

The crate archive matches the crates.io checksum. Its `.cargo_vcs_info.json` pins Midnight ledger commit `6d1b0acb1d03e01bc0580ec10cd55e54cd813f5a`. All six comparable files match Git blob identities at that commit: the original Cargo manifest, four implementation files, and one test file. Cargo.lock, normalized Cargo.toml and VCS metadata remain separately hash-bound crate files.

The annotated `crate-zkir-2.1.0` tag targets `04a6105472777d0ded1fdab27f611738cd435fd9`; the `zkir-2.1.0` tag targets `9da0b63cde82b93ccf1132a943ce05a86de06fe2`. Both match the five inspected Rust files and differ in Cargo.toml. The `ledger-8.0.2` tag targets `dfb450d558d23100d056d2ba121fe2b865e1208c` and matches ir.rs, ir_vm.rs and lib.rs, while the manifest, main.rs and tests differ. The full comparisons and upstream trees are retained. Do not substitute one commit for another.

The installed tool hashes to `5443f87db07b7f19cc273380c224b77b4b7ca124deac6d54f7a165628fc5e1fc`. Its version string matches the crate version. A source-to-binary build binding is not established. The GitHub release endpoint for `zkir-2.1.0` returned HTTP404; the existing Git tag was retrieved successfully. The failed acquisition script and HTTP failure receipt are retained. Later comparison completion used the already downloaded bytes and did not rerun the failed acquisition.

`semantic-source-navigation.json` locates all twelve opcodes observed across the two frozen loan snapshot circuits. `ir.rs` defines JSON instruction fields and the version2.0 loader. `ir_vm.rs` contains both preprocessing and constraint construction. Preprocessing checks input count, index/boolean/bit constraints and transcript consumption; the communications commitment has additional input/output binding checks. These implementations give concrete material for interface review. They are not a formal specification already accepted by DeFiFormal.

Arithmetic is over a prime field; integer financial arithmetic requires its own range and refinement argument. Public-input declarations and `PiSkip` markers affect transcript processing. The snapshot wrapper circuits and the pure financial transitions remain distinct. `main.rs` shows that mock-compile loads the IR and obtains a cost model; it does not run the witness preprocessing or produce a cryptographic proof.

Next: independently review this exact source pin and its relationship to the installed tool; close relevant dependency/interface definitions; bind public inputs, witness layout, commitments and the emitted instruction subset; then implement and prove the actual Compact-to-ZKIR adapter correspondence. Earlier accepted readiness records remain historical. Task32.7 and fullP31 remain open.

Sources: [published crate](https://docs.rs/crate/midnight-zkir/2.1.0/source/), [pinned ledger source](https://github.com/midnightntwrk/midnight-ledger/tree/6d1b0acb1d03e01bc0580ec10cd55e54cd813f5a/zkir). Upstream Apache2.0 license is retained in `upstream-root/LICENSE`. No downloaded code was executed, compiled or installed by this preparation.
''')
shutil.copy2(__file__, o / 'finalize.py')
write(o / 'root-seal.json', {'utc': now(), 'files': {
    str(p.relative_to(o)): sha(p) for p in sorted(o.rglob('*')) if p.is_file() and not p.is_symlink()},
    'successful_fetches': sum('path' in x for x in receipts),
    'failed_fetches': [x for x in receipts if 'error' in x],
    'crate_files': len(discovery['crate_files']), 'git_comparable_files': len(comp['files']),
    'observed_opcode_sources_located': len(navigation), 'independent_review': 'pending',
    'acceptance': False, 'adapter_32_7_accepted': False})
print(json.dumps({'sealed_files': len(read(o / 'root-seal.json')['files']),
    'crate_files': len(discovery['crate_files']), 'opcode_sources': len(navigation),
    'source_binary_binding': False, 'acceptance': False}))
