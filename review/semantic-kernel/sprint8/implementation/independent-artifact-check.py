#!/usr/bin/env python3
"""Reconcile saved Sprint8 r1 evidence against immutable Git source; no Lean execution."""
import collections, datetime, hashlib, json, re, subprocess
from pathlib import Path
ROOT = Path(__file__).resolve().parents[4]
BASE = ROOT / 'review/semantic-kernel/sprint8'
HERE = Path(__file__).resolve().parent
SNAP = HERE / 'independent-artifact-check-r2'
CANDIDATE = 'a52fb748272fdc08f07d4ad8d2e2a06805b92dd6'
OLD = '88aa4906102f2e304d1039d2e70942503ec9b341'
checks = []
def check(condition, label):
    checks.append({'check': label, 'passed': bool(condition)})
def sha(data): return hashlib.sha256(data).hexdigest()
def read(path): return json.loads(path.read_text())
def gitdata(path):
    return subprocess.check_output(['git','show',f'{CANDIDATE}:{path}'],cwd=ROOT)
def gitblob(path):
    return subprocess.check_output(['git','rev-parse',f'{CANDIDATE}:{path}'],cwd=ROOT,text=True).strip()
inv = read(SNAP / 'proof-inventory.json')
check(inv['candidate'] == CANDIDATE, 'inventory candidate')
check(len(inv['theorems']) == 357 and len(inv['supplemental']) == 496, 'actual declaration counts')
allowed = {'propext','Classical.choice','Quot.sound'}
raw = (SNAP / 'proof-types.log').read_text()
verify = (SNAP / 'proof-inventory-verify.log').read_text()
for field, prefix, audit in [('theorems','ATOMIC_PROOF_JSON ','theorem'), ('supplemental','ATOMIC_SUPPLEMENTAL_JSON ','declaration')]:
    rows = inv[field]
    records = [json.loads(line[len(prefix):]) for line in raw.splitlines() if line.startswith(prefix)]
    byname = {r['name']:r for r in records}
    check(len(byname) == len(records) == len(rows), field+' unique raw inventory')
    audit_records = re.findall(r'AXIOM AUDIT '+audit+r': ([^;]+); module=([^;]+); (?:kind=([^;]+); )?axioms=\[([^\]]*)\]',verify)
    audits = {n:(m,k,sorted(x.strip() for x in ax.split(',') if x.strip())) for n,m,k,ax in audit_records}
    check(set(audits) == set(byname),field+' fresh Verify name set')
    for row in rows:
        name = row['name']; rawrow = byname.get(name,{})
        check(all(row.get(k) == v for k,v in rawrow.items()) and bool(rawrow),name+' exact raw fields/type')
        check(set(row['axioms']) <= allowed,name+' allowed axioms')
        check('⋯' not in row['statement'] and '...' not in row['statement'],name+' literal statement')
        aud = audits.get(name)
        check(aud is not None and aud[0] == row['module'] and aud[2] == sorted(row['axioms']),name+' Verify provenance/axioms')
        check(row['module'].startswith('DefiKernel.Atomic.'),name+' Atomic module provenance')
        check(row['source_sha256'] == inv['source_bindings'][row['source']]['sha256'],name+' source binding')
        if field == 'theorems' and row.get('declaration_origin') == 'explicit':
            src = gitdata(row['source']).decode(); line = src.splitlines()[row['line']-1]
            check(re.search(r'\btheorem\s+(?:[A-Za-z0-9_]+\.)*'+re.escape(row['source_name'].split('.')[-1])+r'\b',line) is not None,name+' source line')
            check(row['source_statement'] in src,name+' literal source statement')
            check(all(s in src for s in row['section_variables']),name+' section variables present')
explicit = [r for r in inv['theorems'] if r['declaration_origin']=='explicit']
check(len(explicit)==106,'106 explicit theorems')
check(collections.Counter(r['category'] for r in inv['theorems'])==inv['counts']['categories'],'actual category counts')
check(len(inv['private_source_name_mapping'])==2,'two private helpers')
for user, internal in inv['private_source_name_mapping'].items():
    check(any(r['name']==internal and r['user_name']==user and r['is_private_name'] for r in explicit),'private mapping '+user)
check(len(inv['source_bindings'])==49,'49 source bindings')
for path,b in inv['source_bindings'].items():
    data = gitdata(path)
    check(sha(data)==b['sha256'] and len(data)==b['bytes'] and gitblob(path)==b['git_blob'], 'immutable source '+path)
atomic_sources = [p for p in inv['source_bindings'] if p.startswith('lean/DefiKernel/Atomic/')]
source_theorems = {(p,i) for p in atomic_sources for i,line in enumerate(gitdata(p).decode().splitlines(),1) if re.match(r'\s*(?:@\[[^]]+\]\s*)*(?:private\s+)?theorem\s+',line)}
check(source_theorems=={(r['source'],r['line']) for r in explicit},'all explicit source theorem locations imported')
meta = read(SNAP/'implementation/lean-review-candidate.json')
bundle = (SNAP/'implementation/lean-review-bundle.md').read_bytes()
check(meta['candidate']==OLD and len(meta['inputs'])==meta['input_count']==57,'native bundle candidate/57 inputs')
check(sha(bundle)==meta['bundle_sha256'] and len(bundle)==meta['bundle_bytes'],'native bundle exact hash/size')
for b in meta['inputs']:
    data = subprocess.check_output(['git','show',f"{OLD}:{b['path']}"],cwd=ROOT)
    check(sha(data)==b['sha256'] and len(data)==b['bytes'] and subprocess.check_output(['git','rev-parse',f"{OLD}:{b['path']}"],cwd=ROOT,text=True).strip()==b['git_blob'],'native immutable input '+b['path'])
    marker = f"===== SOURCE {b['path']} SHA256 {b['sha256']} =====\n".encode()
    check(bundle.count(marker)==1 and marker+data in bundle,'native literal embedded input '+b['path'])
control = read(SNAP/'implementation/runner-controls/summary.json')
check(control['total']==control['passed']==len(control['cases'])==65,'65 actual controls')
check(len({c['name'] for c in control['cases']})==65,'unique control names')
for key in ['runner','harness']:
    path = str(Path(control[key+'_source']).relative_to(ROOT))
    check(sha(gitdata(path))==control[key+'_sha256'],key+' execution bytes equal candidate bytes')
for case in control['cases']:
    p = HERE/'runner-controls-r3'/(case['name']+'.log')
    data = p.read_bytes()
    check(sha(data)==case['log_sha256'] and data.decode()==case['cli_output'],case['name']+' exact raw log')
    check(case['passed'] and case['actual_exit']==case['expected_exit'] and case['expected_message'] in data.decode(),case['name']+' expected outcome')
    check(case['command'][1]==control['runner_source'] and '--repo' in case['command'],case['name']+' actual runner command')
    for variant, obs in case['lean_observations'].items():
        log = HERE/'runner-controls-r3'/'runs'/case['name']/(variant+'.log')
        if not log.exists():
            matches = list((HERE/'runner-controls-r3').rglob(variant+'.log'))
            matches = [p for p in matches if case['name'] in p.parts]
            check(len(matches)==1,case['name']+'/'+variant+' preserved log')
            if len(matches)!=1: continue
            log=matches[0]
        text=log.read_text()
        check(sha(log.read_bytes())==obs['log_sha256'],case['name']+'/'+variant+' raw hash')
        lines=[list(m) for m in re.findall(r'^([a-z][a-z0-9_-]*(?:\.[a-z0-9_-]+)*): *(true|false)$',text,re.M)]
        check(lines==obs['lines'],case['name']+'/'+variant+' observations')
blocked_dir=BASE/'mutation-attempts/r1-audit-protocol'
blocked=read(blocked_dir/'BLOCKED.json')
check(blocked['source_candidate']==OLD and blocked['accepted_production_detections']==0 and blocked['observed_runner_exit']==3,'blocked production not counted accepted')
runtime={}
for label in ['control','retain-prefix-on-abort']:
    data=(blocked_dir/(label+'.log')).read_text()
    obs=re.findall(r'^(atomic\.[a-z0-9_.-]+): *(true|false)$',data,re.M)
    check(len(obs)==129 and len(dict(obs))==129,label+' actual129 unique comparisons')
    runtime[label]=dict(obs)
check(all(v=='true' for v in runtime['control'].values()),'production unchanged control all true')
check([n for n,v in runtime['retain-prefix-on-abort'].items() if v=='false']==blocked['first_mutant_false'],'blocked actual mutant false set')
spec=read(SNAP/'mutation-spec.json')
check(len(spec['mutations'])==len({m['name'] for m in spec['mutations']})==18,'18 unique mutation designs')
for m in spec['mutations']:
    source=gitdata('lean/'+m['module'].replace('.','/')+'.lean').decode()
    runtime_source=source.split('-- BEGIN PROOFS')[0]
    check(runtime_source.count(m['needle'])==1 and m['needle']!=m['replacement'],m['name']+' unique runtime edit')
    check(bool(m['required_false']) and all(n in runtime['control'] for n in m['required_false']),m['name']+' existing designated observations')
check(bool(spec['positive_checks']) and all(runtime['control'].get(n)=='true' for n in spec['positive_checks']),'protected production positives present/true')
production = read(BASE/'mutations/results.json')
manifest = read(BASE/'mutations/source-manifest.json')
check(manifest['git_head']==CANDIDATE and manifest['git_head_after']==CANDIDATE,'production actual revised candidate')
check(manifest['input_sources_unchanged'] and manifest['specification_unchanged'] and manifest['runner_unchanged'],'production immutable inputs')
for path,h in manifest['sources'].items():
    check(sha(gitdata(path))==h and sha((ROOT/path).read_bytes())==h,'production source '+path)
check(sha((BASE/'mutation-spec.json').read_bytes())==manifest['spec_sha256'],'production specification exact bytes')
mutations={m['name']:m for m in spec['mutations']}
check(set(production['results'])==set(mutations)|{'control'},'production exact eighteen plus control')
for label,row in production['results'].items():
    rawlog=(BASE/'mutations'/(label+'.log')).read_text()
    obs=re.findall(r'^([a-z][a-z0-9_-]*(?:\.[a-z0-9_-]+)*): *(true|false)$',rawlog,re.M)
    check(len(obs)==len(dict(obs))==135 and dict(obs)==row['checks'],label+' production135 exact observations')
    check(sha((BASE/'mutations'/(label+'.lean')).read_bytes())==row['fixture_sha256'],label+' production executed fixture')
    false=sorted(n for n,v in obs if v=='false')
    check(false==row['false_comparisons'],label+' production actual false set')
    if label=='control':check(row['exit']==0 and not false,'production control success')
    else:
        check(row['exit']==1 and set(mutations[label]['required_false'])<=set(false),label+' required semantic detection')
        check(all(row['checks'][n]=='true' for n in spec['positive_checks']),label+' protected positives survive')
        errors=[x for x in rawlog.splitlines() if 'error:' in x]
        check(len(errors)==1 and errors[0].endswith('Atomic runtime comparisons failed: '+str(len(false))),label+' exact runtime failure protocol')
for record in production['runs']:
    log=BASE/'mutations'/(record['label']+'.log')
    check(log.exists() and sha(log.read_bytes())==record['log_sha256'],record['label']+' production command rawlog')
integration=read(BASE/'integration-final/lean-runs.json')
check(integration['candidate']==CANDIDATE and len(integration['runs'])==14,'fourteen fresh integration commands')
for i,run in enumerate(integration['runs']):
    check(run['exit_code']==0,'integration command '+str(i))
    for kind,b in run['logs'].items():
        data=(BASE/'integration-final'/b['path']).read_bytes()
        check(sha(data)==b['sha256'] and len(data)==b['bytes'],f'integration {i} {kind} raw log')
pre=read(BASE/'integration-final/source-before.json');post=read(BASE/'integration-final/source-after.json')
check({p:b['sha256'] for p,b in pre.items()}==post and len(pre)==104,'all104 integration source bindings unchanged')
for path,b in pre.items():check(sha(gitdata(path))==b['sha256'] and gitblob(path)==b['git_blob'],'integration immutable '+path)
legacy=read(HERE/'legacy-dependency-equivalence.json')
check(legacy['status']=='PASS' and legacy['revised_candidate']==CANDIDATE and len(legacy['suites'])==11 and all(s['relevant_inputs_equal'] for s in legacy['suites']),'legacy eleven explicit dependency equivalence')

scenario_map=read(BASE/'scenario-to-evidence.json')
check(scenario_map['candidate']==CANDIDATE and len(scenario_map['scenarios'])==49,'canonical49 scenarios at candidate')
evidence={e['id']:e for e in scenario_map['evidence']}
check(len(evidence)==len(scenario_map['evidence']),'unique canonical evidence IDs')
proofs={r['name']:r for r in inv['theorems']}
for scenario in scenario_map['scenarios']:
    check(all(k in evidence for k in scenario['evidence']),scenario['id']+' valid evidence references')
    line=gitdata(scenario['path']).decode().splitlines()[scenario['line']-1]
    check(scenario['scenario'] in line,scenario['id']+' exact normative source scenario')
for e in evidence.values():
    if e['id'].startswith('proof:'):
        row=proofs.get(e['name'],{})
        check(bool(row) and all(e[k]==row[k] for k in ['statement','source','line','category']),e['id']+' exact proof type and classification')
    elif e['category']=='boundedruntime':
        check(production['results']['control']['checks'].get(e['name'])=='true',e['id']+' observed true')
        check(gitdata(e['source']).decode().splitlines()[e['line']-1]==e['source_line'],e['id']+' exact fixture source line')
for path,b in scenario_map['input_bindings'].items():
    check(sha((ROOT/path).read_bytes())==b['sha256'], 'scenario input '+path)

inputs={str(p.relative_to(ROOT)):sha(p.read_bytes()) for p in SNAP.rglob('*') if p.is_file()}
for p in [BASE/'mutations/results.json',BASE/'mutations/source-manifest.json',BASE/'integration-final/lean-runs.json',BASE/'integration-final/source-before.json',BASE/'integration-final/source-after.json',HERE/'runner-controls-r3/summary.json',HERE/'legacy-dependency-equivalence.json',BASE/'scenario-to-evidence.json']:
    inputs[str(p.relative_to(ROOT))]=sha(p.read_bytes())
report={'schema_version':1,'candidate':CANDIDATE,'captured_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'status':'CURRENT_RECONCILIATION_PASS' if all(c['passed'] for c in checks) else 'RECONCILIATION_FAILURE','scope':'Nonauthor saved-artifact reconciliation of root/policy proof inventory and runner evidence; author of Atomic financial fixtures and legacy regressions, so no independent judgment of those components. No fresh Lean invocation or final acceptance.','source_policy':'Current inventory and execution inputs bind a52; preserved initial native bundle and blocked production bind88aa. No execution identities are relabeled.','counts':inv['counts'],'source_bindings':len(inv['source_bindings']),'native_bundle_inputs':len(meta['inputs']),'runner_execution_candidate':control['git_head'],'pending':['Final native evidence verdicts and delivery','Native and delivery scenario rows remain pending'],'preserved_r1_blocker':blocked,'current_production':{'mutants':18,'comparisons_per_run':135,'status':'PASS'},'metadata_limitations':['Two new runner control case log fields incorrectly point to nested probe.log; exact CLI bytes were reconciled through preserved top-level case-name.log and recorded SHA256. No execution or result was relabeled.'],'inputs':inputs,'checker_sha256':sha(Path(__file__).read_bytes()),'assertions':len(checks),'passed':sum(c['passed'] for c in checks),'failures':[c for c in checks if not c['passed']]}
(HERE/'independent-artifact-check.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:report[k] for k in ['status','assertions','passed','failures']},indent=2))
raise SystemExit(bool(report['failures']))
