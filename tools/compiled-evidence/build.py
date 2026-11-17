#!/usr/bin/env python3
"""Bundle selected already-built Lean modules, actual import closure and macOS runtime."""
from pathlib import Path
import argparse
import datetime
import hashlib
import json
import platform
import re
import shutil
import subprocess
import sys
import tarfile

HERE = Path(__file__).resolve().parent

class Blocked(Exception):
    pass


def sha(path):
    h = hashlib.sha256()
    with path.open('rb') as source:
        for data in iter(lambda: source.read(1024*1024), b''):
            h.update(data)
    return h.hexdigest()



def r2_inputs(repo, revision, directory, tc):
    """Bind the three accepted auxiliary source recipes and original replay records."""
    directory = directory.resolve()
    def required(path):
        data = path.read_bytes()
        if not data:
            raise Blocked('empty R2 replay input: '+str(path))
        return data
    def git_bytes(path):
        found = subprocess.run(['git','show',revision+':'+path],cwd=repo,
            stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        if found.returncode:
            raise Blocked('R2 source absent from revision: '+path)
        data = required(repo/path)
        if data != found.stdout:
            raise RuntimeError('R2 source differs from revision: '+path)
        return data
    paths = dict(model='lean/DefiKernel/AMM/R2Bridge.lean',
        controls='lean/DefiKernel/AMM/R2BridgeAudit.lean',
        original='benchmarks/competitive-landscape/upstream/rational-1/swap-2b60322-2/SwapModel.lean',
        relation='benchmarks/competitive-landscape/library-replays/r2-20261117/OriginalContractRelation.lean')
    data = {name:git_bytes(path) for name,path in paths.items()}
    header = b'import DefiKernel.AMM.R2Bridge\n'
    if not data['controls'].startswith(header) or data['relation'].count(header)!=1:
        raise RuntimeError('unexpected R2 source recipe boundary')
    recipes = dict(R2Replay=data['model']+b'\n'+data['controls'][len(header):],
        SwapModel=data['original'],
        OriginalContractRelation=data['relation'].replace(header,b'import R2Replay\n'))
    sources = {}
    for module, expected in recipes.items():
        source = directory/(module+'.lean')
        if required(source)!=expected:
            raise RuntimeError('generated R2 source differs from recipe: '+module)
        parts = []
        for suffix in ['.olean','.olean.server','.olean.private']:
            part = directory/(module+suffix)
            if suffix=='.olean' or part.exists():
                required(part)
                parts.append(dict(name=part.name,sha256=sha(part)))
        sources[module] = dict(path=source,sha256=sha(source),parts=parts)
    report_path = directory/'result.json'
    try:
        report = json.loads(required(report_path))
    except ValueError as error:
        raise RuntimeError('invalid R2 replay result JSON') from error
    if not report.get('commands'):
        raise Blocked('empty R2 replay command inventory')
    if report.get('status')!='PASS' or report.get('assertions')!=16:
        raise RuntimeError('R2 replay did not pass exact16 controls')
    hashes = {name:hashlib.sha256(value).hexdigest() for name,value in data.items()}
    if report.get('input_sha256')!=hashes or report.get('lean_sha256')!=sha(tc/'bin/lean'):
        raise RuntimeError('R2 replay source/tool identity differs')
    version = subprocess.check_output([str(tc/'bin/lean'),'--version'],text=True).strip()
    if report.get('lean_version')!=version:
        raise RuntimeError('R2 replay Lean version differs')
    names = ['version','dependencies','lake-path','fresh-source','original-model',
        'original-relation','audit','kernel-r2','kernel-relation']
    if [row.get('name') for row in report['commands']]!=names:
        raise RuntimeError('R2 replay command inventory differs')
    evidence = [report_path]
    for row in report['commands']:
        if row.get('exit')!=0:
            raise RuntimeError('R2 replay command failed: '+row['name'])
        for stream in ['stdout','stderr']:
            path = directory/(row['name']+'.'+stream)
            content = path.read_bytes()
            expected = row.get(stream+'_sha256')
            allowed_empty = stream=='stderr' or row['name'] in ['original-model','original-relation']
            if not content and (not allowed_empty or expected!=hashlib.sha256(b'').hexdigest()):
                raise Blocked('empty required R2 replay log: '+path.name)
            if hashlib.sha256(content).hexdigest()!=expected:
                raise RuntimeError('R2 replay log changed: '+path.name)
            evidence.append(path)
    return directory,sources,evidence,dict(input_sources=paths,input_sha256=hashes,
        generated_sources={name:dict(sha256=entry['sha256'],parts=entry['parts'])
            for name,entry in sources.items()},
        recipes=dict(R2Replay='model bytes + newline + controls bytes after one leading self-import',
            SwapModel='byte-identical pinned original',
            OriginalContractRelation='accepted relation with sole self-import replaced by import R2Replay'),
        original_replay_result_sha256=sha(report_path),
        artifact_boundary='Accepted generated artifacts are reused and individually checksummed; source recipes and recorded execution are provenance, not a new source-to-binary refinement proof.')

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--toolchain', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True, help='new package directory')
    parser.add_argument('--archive', type=Path, required=True, help='new .tar.gz outside package')
    parser.add_argument('--r2-replay', type=Path, help='accepted fresh R2 replay directory; exact source recipes required')
    args = parser.parse_args()
    repo, tc, out, archive = [p.resolve() for p in [args.repo, args.toolchain, args.output, args.archive]]
    if platform.system() != 'Darwin' or platform.machine() != 'arm64':
        raise RuntimeError('this builder currently supports macOS arm64 only')
    if out.exists() or archive.exists() or out == archive or out in archive.parents:
        raise RuntimeError('output/archive must be new and archive outside output')
    targets = json.loads((HERE/'targets.json').read_text())
    if not targets:
        raise Blocked('empty target set')
    source_targets = list(targets)
    auxiliary = {}
    auxiliary_evidence = []
    r2 = None
    revision = subprocess.check_output(['git','rev-parse','HEAD'],cwd=repo,text=True).strip()
    if args.r2_replay is not None:
        auxiliary_root, auxiliary, auxiliary_evidence, r2 = r2_inputs(repo,revision,args.r2_replay,tc)
        targets = [target for target in targets if target not in
            ['DefiKernel.AMM.R2Bridge','DefiKernel.AMM.R2BridgeAudit']] + ['R2Replay','OriginalContractRelation']
    if not targets:
        raise Blocked('empty target set')
    if len(set(targets)) != len(targets) or any(not re.fullmatch(r'DefiKernel(?:\.[A-Za-z_][A-Za-z_0-9]*)+', t) and not
            (r2 is not None and t in ['R2Replay','OriginalContractRelation']) for t in targets):
        raise RuntimeError('empty, duplicate or malformed target inventory')
    out.mkdir(parents=True)
    def copy(source, relative):
        if not source.is_file():
            raise Blocked('missing required artifact: ' + str(source))
        target = out / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
        return str(relative)
    toolenv = {'PATH': str(tc/'bin') + ':/usr/bin:/bin', 'HOME': str(Path.home())}
    argv = [str(tc/'bin/lake'),'env','lean','--run',str(HERE/'ImportClosure.lean'),*targets]
    if r2 is not None:
        lake_path = subprocess.check_output([str(tc/'bin/lake'),'env','printenv','LEAN_PATH'],
            cwd=repo/'lean',env=toolenv,text=True).strip()
        toolenv['LEAN_PATH'] = str(auxiliary_root)+':'+lake_path
        argv = [str(tc/'bin/lean'),'--run',str(HERE/'ImportClosure.lean'),*targets]
    closure = subprocess.run(argv,cwd=repo/'lean',env=toolenv,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    if closure.returncode:
        raise RuntimeError('compiled metadata extraction failed: '+closure.stderr.decode()+closure.stdout.decode())
    rows = [json.loads(line) for line in closure.stdout.decode().splitlines()]
    if not rows or not set(targets) <= {row['module'] for row in rows}:
        raise Blocked('incomplete or empty metadata closure')
    if r2 is not None and any(row['module'] in
            ['DefiKernel.AMM.R2Bridge','DefiKernel.AMM.R2BridgeAudit'] for row in rows):
        raise RuntimeError('duplicate production and auxiliary R2 declaration closure')
    modules = []
    package_owners = set()
    for row in rows:
        source_olean = Path(row['olean'])
        base = Path(*row['module'].split('.'))
        parts = []
        for suffix in ['.olean','.olean.server','.olean.private']:
            src = Path(str(source_olean)[:-6]+suffix)
            if src.exists():
                parts.append(copy(src,Path('lib/lean')/Path(str(base)+suffix)))
        if not parts or not parts[0].endswith('.olean'):
            raise RuntimeError('missing olean: '+row['module'])
        if row['module'] in auxiliary:
            if source_olean.resolve() != (auxiliary_root/(row['module']+'.olean')).resolve():
                raise RuntimeError('unexpected auxiliary compiled origin: '+row['module'])
            source = auxiliary[row['module']]['path']
            origin = 'R2 source recipe/'+row['module']+' (manifest.r2_replay)'
        elif '/.lake/build/lib/lean/' in str(source_olean):
            source_root = Path(str(source_olean).split('/.lake/build/lib/lean/')[0])
            if source_root != repo/'lean':
                package_owners.add(source_root)
            source = source_root/base.with_suffix('.lean')
            origin = str(source.relative_to(repo))
            # Source provenance must describe the current accepted repository or a pinned dependency.
            if source_root == repo/'lean':
                expected = subprocess.check_output(['git','show',revision+':'+origin],cwd=repo)
                if expected != source.read_bytes():
                    raise RuntimeError('source differs from revision: '+origin)
        else:
            if not source_olean.is_relative_to(tc/'lib/lean'):
                raise RuntimeError('unrecognized compiled origin: '+str(source_olean))
            source = tc/'src/lean'/base.with_suffix('.lean')
            origin = 'Lean toolchain/'+str(source.relative_to(tc))
        source_name = copy(source,Path('sources')/base.with_suffix('.lean'))
        modules.append(dict(module=row['module'],imports=row['imports'],parts=parts,
            source=source_name,source_sha256=sha(source),source_origin=origin,
            selected_target=row['module'] in targets,
            trust='Imported declarations are trusted during each default target replay.'))
    runtime = []
    for name in ['lean','leanchecker']:
        runtime.append(copy(tc/'bin'/name,Path('bin')/name))
    # Exactly the bundled dylibs referenced by lean/leanchecker and their transitive @rpath dependencies.
    libraries = ['libInit_shared.dylib','libLake_shared.dylib','libleanshared.dylib','libleanshared_1.dylib','libleanshared_2.dylib']
    for name in libraries:
        runtime.append(copy(tc/'lib/lean'/name,Path('lib/lean')/name))
    linkage = []
    minimum = (0,)
    for name in runtime:
        info = subprocess.check_output(['/usr/bin/otool','-L',str(out/name)],text=True)
        dependencies = [line.strip().split(' (')[0] for line in info.splitlines()[1:]]
        for dep in dependencies:
            if dep.startswith('@rpath/'):
                if not (out/'lib/lean'/dep.removeprefix('@rpath/')).is_file():
                    raise RuntimeError('unbundled runtime dependency: '+dep)
            elif dep not in ['/usr/lib/libSystem.B.dylib','/usr/lib/libc++.dylib']:
                raise RuntimeError('unreviewed runtime dependency: '+dep)
        commands = subprocess.check_output(['/usr/bin/otool','-l',str(out/name)],text=True)
        for value in re.findall(r'\bminos\s+(\d+(?:\.\d+)*)',commands):
            minimum = max(minimum,tuple(map(int,value.split('.'))))
        linkage.append(dict(file=name,dependencies=dependencies))
    copy(tc/'LICENSE',Path('licenses/lean/LICENSE'))
    copy(tc/'LICENSES',Path('licenses/lean/LICENSES'))
    owners = []
    for package in sorted(package_owners):
        license_path = package/'LICENSE'
        copy(license_path,Path('licenses/dependencies')/package.name/'LICENSE')
        commit = subprocess.check_output(['git','rev-parse','HEAD'],cwd=package,text=True).strip()
        owners.append(dict(package=package.name,revision=commit,license='licenses/dependencies/'+package.name+'/LICENSE'))
    copy(repo/'LICENSE',Path('licenses/defiformal/LICENSE'))
    copy(repo/'THIRD_PARTY_NOTICES.md',Path('licenses/defiformal/THIRD_PARTY_NOTICES.md'))
    evidence = json.loads((HERE/'evidence-files.json').read_text())
    token0 = repo/'docs/correspondence/token0'
    relation = json.loads((token0/'differential-observations.json').read_text())
    evidence += [entry['path'] for entry in relation['bound_files']]
    evidence += [str(p.relative_to(repo)) for p in token0.iterdir() if p.is_file()]
    allowed_empty = []
    for name in sorted(set(evidence)):
        dest = copy(repo/name,Path('evidence/repository')/name)
        if (repo/name).stat().st_size == 0:
            if not any(pin['path']==name and pin.get('allow_empty') for pin in relation['bound_files']):
                raise RuntimeError('unexpected empty evidence: '+name)
            allowed_empty.append(dest)
    for source in auxiliary_evidence:
        dest = copy(source,Path('evidence/r2-replay')/source.name)
        if not source.stat().st_size:
            allowed_empty.append(dest)
    for name in ['build.py','ImportClosure.lean','targets.json','evidence-files.json','recheck.py','replay.sh','README.md']:
        copy(HERE/name,Path('provenance/builder')/name)
    if r2 is not None:
        copy(HERE/'targets.json',Path('provenance/builder/targets.source.json'))
        (out/'provenance/builder/targets.json').write_text(json.dumps(targets,indent=2)+'\n')
        r2['target_recipe'] = dict(source_targets=source_targets,effective_targets=targets,
            removed=['DefiKernel.AMM.R2Bridge','DefiKernel.AMM.R2BridgeAudit'],
            added=['R2Replay','OriginalContractRelation'])
    copy(HERE/'recheck.py',Path('recheck.py'))
    copy(HERE/'replay.sh',Path('replay.sh'))
    (out/'targets.txt').write_text(''.join(t+'\n' for t in targets))
    (out/'allowed-empty.txt').write_text(''.join(t+'\n' for t in allowed_empty))
    copy(HERE/'README.md',Path('README.md'))
    copy(repo/'lean/lean-toolchain',Path('provenance/lean-toolchain'))
    copy(repo/'lean/lake-manifest.json',Path('provenance/lake-manifest.json'))
    copy(tc/'src/lean/LeanChecker.lean',Path('provenance/LeanChecker.lean'))
    version = subprocess.check_output([str(tc/'bin/lean'),'--version'],text=True).strip()
    manifest = dict(schema='defiformal-compiled-evidence/v1',source_revision=revision,
        generated_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
        targets=targets,modules=modules,dependencies=owners,r2_replay=r2,
        allowed_empty_evidence_files=allowed_empty,
        checker=dict(name='Lean leanchecker',version=version,
            version_identity='Lean toolchain version; leanchecker has no dedicated version flag.',
            leanchecker_sha256=sha(out/'bin/leanchecker'),lean_sha256=sha(out/'bin/lean'),
            mode='Default target declarations replayed using imported environment; same Lean kernel, not an external verifier.'),
        platform=dict(os='macOS',architecture='arm64',minimum_macos='.'.join(map(str,minimum)),
            tested_on=platform.platform(),macos_version=platform.mac_ver()[0],runtime_linkage=linkage,
            os_libraries='macOS supplies /usr/lib/libSystem.B.dylib and /usr/lib/libc++.dylib'),
        check_scope=dict(replay='All declarations in each explicitly selected target; imported declarations are trusted, including another selected module when imported.',
            checksums='Pinned package bytes and nonempty target/import inventories.',
            axiom_boundary='Kernel replay permits axioms; separate accepted axiom audits remain evidence, not an extra property of leanchecker.',
            finite_execution='Historical runtime/control records are bound; cached artifacts and kernel replay do not rerun #eval controls.',
            source_observations='Historical 12 source invocations plus 4 model invocations remain distinct; no new Solidity/EVM campaign.',
            refinement='Token0 Solidity/EVM/ABI/compiler refinement remains unproved.',
            third_party='No outside reproduction or corroborated adoption is established.'))
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    files = sorted(p for p in out.rglob('*') if p.is_file())
    (out/'SHA256SUMS').write_text(''.join(sha(p)+'  '+str(p.relative_to(out))+'\n' for p in files))
    archive.parent.mkdir(parents=True,exist_ok=True)
    with tarfile.open(archive,'w:gz',compresslevel=6) as tar:
        tar.add(out,arcname='defiformal-evidence')
    print(json.dumps(dict(status='BUILT',targets=len(targets),modules=len(modules),files=len(files),
        archive=str(archive),archive_bytes=archive.stat().st_size,archive_sha256=sha(archive)),indent=2))
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (Blocked, FileNotFoundError, PermissionError) as error:
        print('BLOCKED: '+str(error),file=sys.stderr)
        sys.exit(3)
    except RuntimeError as error:
        print('FAIL: '+str(error),file=sys.stderr)
        sys.exit(1)
