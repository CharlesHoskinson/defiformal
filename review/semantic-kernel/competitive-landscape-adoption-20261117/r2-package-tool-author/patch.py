from pathlib import Path
r=Path('/private/tmp/defiformal-ci-author');p=r/'tools/compiled-evidence/build.py';s=p.read_text()
helper='''
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
    header = b'import DefiKernel.AMM.R2Bridge\\n'
    if not data['controls'].startswith(header) or data['relation'].count(header)!=1:
        raise RuntimeError('unexpected R2 source recipe boundary')
    recipes = dict(R2Replay=data['model']+b'\\n'+data['controls'][len(header):],
        SwapModel=data['original'],
        OriginalContractRelation=data['relation'].replace(header,b'import R2Replay\\n'))
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
    report = json.loads(required(report_path))
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
            if not content and expected!=hashlib.sha256(b'').hexdigest():
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

'''
s=s.replace('\ndef main():','\n'+helper+'def main():',1)
s=s.replace("parser.add_argument('--archive', type=Path, required=True, help='new .tar.gz outside package')", "parser.add_argument('--archive', type=Path, required=True, help='new .tar.gz outside package')\n    parser.add_argument('--r2-replay', type=Path, help='accepted fresh R2 replay directory; exact source recipes required')")
s=s.replace("    targets = json.loads((HERE/'targets.json').read_text())", "    targets = json.loads((HERE/'targets.json').read_text())\n    source_targets = list(targets)\n    auxiliary = {}\n    auxiliary_evidence = []\n    r2 = None\n    revision = subprocess.check_output(['git','rev-parse','HEAD'],cwd=repo,text=True).strip()\n    if args.r2_replay is not None:\n        auxiliary_root, auxiliary, auxiliary_evidence, r2 = r2_inputs(repo,revision,args.r2_replay,tc)\n        targets = [target for target in targets if target not in\n            ['DefiKernel.AMM.R2Bridge','DefiKernel.AMM.R2BridgeAudit']] + ['R2Replay','OriginalContractRelation']")
s=s.replace("any(not re.fullmatch(r'DefiKernel(?:\\.[A-Za-z_][A-Za-z_0-9]*)+', t) for t in targets)", "any(not re.fullmatch(r'DefiKernel(?:\\.[A-Za-z_][A-Za-z_0-9]*)+', t) and not\n            (r2 is not None and t in ['R2Replay','OriginalContractRelation']) for t in targets)")
s=s.replace("    argv = [str(tc/'bin/lake'),'env','lean','--run',str(HERE/'ImportClosure.lean'),*targets]", "    argv = [str(tc/'bin/lake'),'env','lean','--run',str(HERE/'ImportClosure.lean'),*targets]\n    if r2 is not None:\n        lake_path = subprocess.check_output([str(tc/'bin/lake'),'env','printenv','LEAN_PATH'],\n            cwd=repo/'lean',env=toolenv,text=True).strip()\n        toolenv['LEAN_PATH'] = str(auxiliary_root)+':'+lake_path\n        argv = [str(tc/'bin/lean'),'--run',str(HERE/'ImportClosure.lean'),*targets]")
s=s.replace("    modules = []", "    if r2 is not None and any(row['module'] in\n            ['DefiKernel.AMM.R2Bridge','DefiKernel.AMM.R2BridgeAudit'] for row in rows):\n        raise RuntimeError('duplicate production and auxiliary R2 declaration closure')\n    modules = []",1)
s=s.replace("        if '/.lake/build/lib/lean/' in str(source_olean):", "        if row['module'] in auxiliary:\n            if source_olean.resolve() != (auxiliary_root/(row['module']+'.olean')).resolve():\n                raise RuntimeError('unexpected auxiliary compiled origin: '+row['module'])\n            source = auxiliary[row['module']]['path']\n            origin = 'R2 source recipe/'+row['module']+' (manifest.r2_replay)'\n        elif '/.lake/build/lib/lean/' in str(source_olean):")
s=s.replace("    for name in ['build.py','ImportClosure.lean'", "    for source in auxiliary_evidence:\n        dest = copy(source,Path('evidence/r2-replay')/source.name)\n        if not source.stat().st_size:\n            allowed_empty.append(dest)\n    for name in ['build.py','ImportClosure.lean'",1)
s=s.replace("    copy(HERE/'recheck.py',Path('recheck.py'))", "    if r2 is not None:\n        copy(HERE/'targets.json',Path('provenance/builder/targets.source.json'))\n        (out/'provenance/builder/targets.json').write_text(json.dumps(targets,indent=2)+'\\n')\n        r2['target_recipe'] = dict(source_targets=source_targets,effective_targets=targets,\n            removed=['DefiKernel.AMM.R2Bridge','DefiKernel.AMM.R2BridgeAudit'],\n            added=['R2Replay','OriginalContractRelation'])\n    copy(HERE/'recheck.py',Path('recheck.py'))",1)
s=s.replace("        targets=targets,modules=modules,dependencies=owners,", "        targets=targets,modules=modules,dependencies=owners,r2_replay=r2,")
p.write_text(s)
p=r/'tools/compiled-evidence/replay.sh';s=p.read_text().replace('case "$target" in DefiKernel.*) ;;','case "$target" in DefiKernel.*|R2Replay|OriginalContractRelation) ;;');p.write_text(s)
