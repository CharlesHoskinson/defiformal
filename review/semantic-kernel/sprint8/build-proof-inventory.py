#!/usr/bin/env python3
"""Generate a source-bound Atomic inventory from fresh Lean environment discovery.
Writes only this Sprint8 evidence directory; never modifies source or compiles mutation trees.
"""
import collections, datetime, hashlib, json, pathlib, re, subprocess, sys
ROOT = pathlib.Path(__file__).resolve().parents[3]
OUT = ROOT / 'review/semantic-kernel/sprint8'
WORK = ROOT / 'lean'
CANDIDATE = 'a52fb748272fdc08f07d4ad8d2e2a06805b92dd6'
DRIVER = OUT / 'proof-inventory-driver.lean'
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def rel(path): return path.relative_to(ROOT).as_posix()
def now(): return datetime.datetime.now(datetime.timezone.utc).isoformat()
def save(name, obj): (OUT/name).write_text(json.dumps(obj, indent=2, ensure_ascii=False)+'\n')
def git(*args): return subprocess.check_output(['git',*args],cwd=ROOT)
def source_paths():
    found=set(); pending=['DefiKernel.Atomic.Verify','DefiKernel.AxiomAudit']
    while pending:
        module=pending.pop(); path=WORK/(module.replace('.','/')+'.lean')
        if path in found: continue
        assert path.is_file(),path
        found.add(path)
        for imported in re.findall(r'^import\s+(DefiKernel\.[\w.]+)',path.read_text(),re.M):
            pending.append(imported)
    # Includes empty declaration modules, such as Verify, rather than inferring files from constants.
    assert set((WORK/'DefiKernel/Atomic').glob('*.lean')) <= found
    return sorted(found | {WORK/'lean-toolchain',WORK/'lakefile.toml',WORK/'lake-manifest.json'})
def snapshot(paths):
    rows={}
    for path in paths:
        frozen=git('show',f'{CANDIDATE}:{rel(path)}')
        assert frozen==path.read_bytes(),f'Frozen source drift: {path}'
        rows[rel(path)]={'sha256':sha(path),'bytes':len(frozen),
            'git_blob':git('rev-parse',f'{CANDIDATE}:{rel(path)}').decode().strip(),
            'frozen_bytes_match':True}
    return rows
paths=source_paths(); before=snapshot(paths)
lake=pathlib.Path(subprocess.check_output(['elan','which','lake'],cwd=WORK,text=True).strip())
lean=pathlib.Path(subprocess.check_output(['elan','which','lean'],cwd=WORK,text=True).strip())
execution={'candidate':CANDIDATE,'started_utc':now(),'working_head_before':git('rev-parse','HEAD').decode().strip(),
    'source_before':before,'driver_sha256':sha(DRIVER),'builder_sha256':sha(pathlib.Path(__file__)),
    'tools':[{'path':str(p),'sha256':sha(p)} for p in [lake,lean,pathlib.Path(sys.executable).resolve()]],
    'lean_version':subprocess.check_output([str(lean),'--version'],cwd=WORK,text=True).strip(),
    'lsp_limit':'Evidence driver is outside a lean-toolchain ancestor; LSP rejected the path. Pinned lake env lean is used from lean/.',
    'commands':[]}
def run(name,command,logname):
    started=now(); p=subprocess.run(command,cwd=WORK,capture_output=True)
    stdout=OUT/logname;stderr=OUT/(logname+'.stderr');stdout.write_bytes(p.stdout);stderr.write_bytes(p.stderr)
    execution['commands'].append({'name':name,'argv':command,'cwd':str(WORK),
        'started_utc':started,'finished_utc':now(),'exit':p.returncode,
        'stdout':rel(stdout),'stdout_sha256':sha(stdout),'stderr':rel(stderr),'stderr_sha256':sha(stderr)})
    save('proof-inventory-execution.json',execution)
    assert p.returncode==0,f'{name} failed: inspect {stdout} and {stderr}'
run('fresh-verify',[str(lake),'env','lean','DefiKernel/Atomic/Verify.lean'],'proof-inventory-verify.log')
run('full-types-driver',[str(lake),'env','lean',str(DRIVER)],'proof-types.log')
log=(OUT/'proof-types.log').read_text()
def rows(marker): return [json.loads(l.split(marker,1)[1]) for l in log.splitlines() if marker in l]
proofs=rows('ATOMIC_PROOF_JSON '); supplemental=rows('ATOMIC_SUPPLEMENTAL_JSON ')
assert proofs and supplemental,'Empty environment discovery'
for subset in [proofs,supplemental]:
    assert len({r['name'] for r in subset})==len(subset),'Duplicate discovery'
allowed={'propext','Classical.choice','Quot.sound'}
for row in proofs+supplemental:
    assert set(row['axioms'])<=allowed,row['name']
    assert '⋯' not in row['statement'] and '...' not in row['statement'],row['name']

# Source indexing is supplemental attribution; Lean environment discovery determines inventory scope.
# Atomic sources use one outer namespace and no nested namespace blocks; assert that constraint.
declarations={};explicit={}
pattern=r'^(?:@\[[^\n]*\]\s*)?(?:(private|protected)\s+)?(theorem|lemma|def|abbrev|structure|inductive|instance)\s+([\w.]+)'
for path in sorted((WORK/'DefiKernel/Atomic').glob('*.lean')):
    text=path.read_text(); nss=re.findall(r'^namespace (\S+)',text,re.M)
    assert len(nss)<=1,f'Nested namespaces require parser extension: {path}'
    ns=nss[0] if nss else '';module='.'.join(path.relative_to(WORK).with_suffix('').parts)
    for match in re.finditer(pattern,text,re.M):
        visibility,kind,name=match.groups(); full=ns+'.'+name;start=match.start()
        assert full not in declarations,full
        tail=text[start:];statement=tail.split(':=',1)[0].strip() if kind in ('theorem','lemma') else tail.split('\n\n',1)[0]
        line=text[:start].count('\n')+1
        decl={'source_name':full,'module':module,'source':rel(path),'line':line,
            'source_statement':statement,'section_variables':re.findall(r'^variable[^\n]*(?:\n[ ]+[^\n]*)*',text[:start],re.M),
            'immediately_preceding_lines':text.splitlines()[max(0,line-5):line-1],
            'kind':kind,'visibility':visibility or 'public','private':visibility=='private',
            'source_sha256':before[rel(path)]['sha256'],'source_git_blob':before[rel(path)]['git_blob']}
        declarations[full]=decl
        if kind in ('theorem','lemma'): explicit[full]=decl
mapped={}
for row in proofs:
    # privateToUserName? from Lean is authoritative; no suffix heuristic for private helpers.
    user=row['user_name'];decl=explicit.get(user)
    if decl and decl['module']==row['module']:
        assert user not in mapped,f'Multiple elaborated names map to {user}'
        assert decl['private']==row['is_private_name'],user
        mapped[user]=row['name'];row.update(decl);row['declaration_origin']='explicit'
        base=user.rsplit('.',1)[-1]
        if base in {'scalar_netting_counterexample','missing_frame_support_counterexample','underlying_success_does_not_imply_commit'}:
            row['category']='counterexample'
        elif base=='empty_support_is_false': row['category']='counterexample-corollary'
        elif row['module']=='DefiKernel.Atomic.InvariantFixtures': row['category']='referenceinstance'
        else: row['category']='genericproof'
        row['premises']='The full elaborated statement is authoritative, including retained section parameters, typeclasses and hypotheses. Source context is supplemental; no premise-free claim is inferred from absent textual binders.'
        if row['category']=='referenceinstance':
            row['scope_note']='Concrete typed fixture configuration/operations/initial world; any quantified schedules, states or histories remain exactly as in the elaborated statement. Development instance, not a holdout or universal economic claim.'
    else:
        row['declaration_origin']='generated';row['category']='generated'
        row['source']='lean/'+row['module'].replace('.','/')+'.lean'
        owners=[n for n,d in declarations.items() if d['module']==row['module'] and user.startswith(n+'.')]
        owner=max(owners,key=len) if owners else None
        row['source_owner']=owner;row['line']=declarations[owner]['line'] if owner else None
        row['source_sha256']=before[row['source']]['sha256'];row['source_git_blob']=before[row['source']]['git_blob']
        row['scope_note']='Generated theorem constant; owner line is attribution when identifiable, not an explicit theorem statement. Full elaborated type and transitive axioms are retained.'
assert set(mapped)==set(explicit),f'Explicit theorem coverage mismatch: {set(explicit)-set(mapped)}'
private_map={n:mapped[n] for n,d in explicit.items() if d['private']}
for row in supplemental:
    row['source']='lean/'+row['module'].replace('.','/')+'.lean'
    row['source_sha256']=before[row['source']]['sha256'];row['source_git_blob']=before[row['source']]['git_blob']
    user=row['user_name'];decl=declarations.get(user)
    if decl and decl['module']==row['module']:
        row['source_declaration']=decl;row['declaration_origin']='explicit'
    else: row['declaration_origin']='generated-or-private-elaboration'
verify=(OUT/'proof-inventory-verify.log').read_text()
def audit_rows(marker):
    return {name:(mod,set(re.findall(r'[^,\s]+',axioms))) for name,mod,axioms in re.findall(
        rf'AXIOM AUDIT {marker}: ([^;]+); module=([^;]+); (?:kind=[^;]+; )?axioms=\[(.*?)\]',verify,re.S)}
for data,marker in [(proofs,'theorem'),(supplemental,'declaration')]:
    audited=audit_rows(marker)
    assert set(audited)=={r['name'] for r in data},marker+' names mismatch'
    for row in data: assert audited[row['name']]==(row['module'],set(row['axioms'])),row['name']
assert re.search(rf'AXIOM AUDIT PASSED: {len(proofs)}/{len(proofs)} theorems; forbidden=0',verify)
assert re.search(rf'AXIOM AUDIT DECLARATIONS PASSED: {len(supplemental)}/{len(supplemental)} supplemental declarations; forbidden=0',verify)
after=snapshot(paths);assert before==after,'Input drift during inventory execution'
assert execution['driver_sha256']==sha(DRIVER) and execution['builder_sha256']==sha(pathlib.Path(__file__))
execution.update({'finished_utc':now(),'working_head_after':git('rev-parse','HEAD').decode().strip(),
    'source_after':after,'source_bytes_unchanged':True,'driver_bytes_unchanged':True,'builder_bytes_unchanged':True,
    'status':'PASS'})
save('proof-inventory-execution.json',execution)
limits={
    'authority':'Trusted registry/catalog/domain-admin, authenticated static boundaries and initial capability store. Authority is checked at actual speculative pre-worlds; invocation-only branches preserve the complete store.',
    'state':'State carries its own pointwise nonnegativity proof. Public nonnegativity projects this witness; it is not a separate solvency or guard-inference result.',
    'arithmetic':'Exact signed rationals with finite typed domains/assets/principals. No machine-width arithmetic, EVM rounding, oracle truth or deployed-code fidelity.',
    'policy':'Lane uniqueness is by domain/asset; participant uniqueness and full static coverage support sums. Receipt effects use exact configured vault cells; supply policy is whole-asset signed receipt supply.',
    'settlement':'Generic reachable-prefix cash+owed conservation includes the successful receipt triggering policy abort. Final clearance is pointwise over every configured lane/participant pair. Empty lanes are ordinary batch mode, not evidence of transient settlement.',
    'correspondence':'Converse assumes actual admission, all actual underlying attempts succeeded and passed lane supply policy, and independent attempt-fold clearance. It does not premise the Atomic outcome, no-abort, or desired table/machine equality.',
    'publication':'Noncommit public world is the complete entry world, with empty committed history and zero committed supply. Diagnostic speculative attempts/tables are separate. Atomic comparison retains full schedules.',
    'locality':'Actual/analyzed-write framing requires exclusion of writes; predicate lifting requires Supports. Initialized macro invariants additionally require actual LocalObligation, CrossInclusion and Stable premises.',
    'scope':'Finite schedules, not liveness/fairness or arbitrary shared-state commutation. Numeric and counterexample fixtures are development evidence, not untouched holdouts.',
    'review':'This is mechanical author inventory from the requested GPT-6 stock harness, not independent approval. Independent model/build telemetry unavailable. No provider or Foreman calls.'}
record={'schema_version':2,'kind':'imported-atomic-proof-inventory','candidate':CANDIDATE,
    'captured_utc':now(),'discovery':'Lean importedTheorems/importedSupplemental by exact Atomic module provenance via Verify; privateToUserName? maps source helpers.',
    'execution':execution,'counts':{'theorems':len(proofs),'supplemental':len(supplemental),
        'explicit_theorems':len(explicit),'private_explicit_theorems':len(private_map),
        'categories':dict(collections.Counter(r['category'] for r in proofs)),
        'atomic_source_modules':len(list((WORK/'DefiKernel/Atomic').glob('*.lean')))},
    'validation':{'nonempty':True,'all_explicit_source_theorems_imported':True,
        'theorem_names_modules_axioms_exactly_match_fresh_verify':True,
        'supplemental_names_modules_axioms_exactly_match_fresh_verify':True,
        'forbidden_axioms':0,'no_pretty_statement_ellipsis':True,'all_source_bytes_match_candidate_before_and_after':True},
    'private_source_name_mapping':private_map,'source_bindings':before,'premise_and_scope_limits':limits,
    'theorems':proofs,'supplemental':supplemental}
save('proof-inventory.json',record)
print(json.dumps(record['counts'],indent=2))
