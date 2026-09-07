#!/usr/bin/env python3
from pathlib import Path
import hashlib,json,re,subprocess,datetime
R=Path('/home/charl/defiformal');O=R/'review/semantic-kernel/sprint8/planning/baseline';OLD=R/'review/semantic-kernel/sprint7';checks=[]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def js(p):return json.loads(p.read_text())
def check(name,value):
 checks.append({'check':name,'passed':bool(value)})
 if not value:raise AssertionError(name)
r=js(O/'lean-runs.json');before=js(O/'source-binding-before.json');after=js(O/'source-binding-after.json')
check('12 commands actually completed',len(r['runs'])==12 and all(x['exit']==0 for x in r['runs']))
check('130 nonempty source inputs retained',len(before)==130 and before==after and r['source_unchanged'])
check('no Atomic implementation yet',r['no_atomic_implementation_before'] and r['no_atomic_implementation_after'] and not (R/'lean/DefiKernel/Atomic').exists())
check('same source across observed Git heads',r['all_observed_revisions_have_exact_same_source_blobs'])
for p,row in before.items():
 check('captured Git/current '+p,row['matches_revision'] and row['git_blob']==row['observed_git_blob'] and sha(R/p)==row['sha256'])
 check('accepted Sprint7 source '+p,hashlib.sha256(subprocess.check_output(['git','show',r['accepted_source_context']+':'+p],cwd=R)).hexdigest()==row['sha256'])
for row in r['runs']:
 check(row['log']+' exact full logs',all(sha(O/row[k])==row[k+'_sha256'] for k in ['stdout','stderr','log']))
 if row['log']!='00.log':check(row['log']+' exact accepted baseline output',sha(O/row['log'])==sha(OLD/'integration-final'/row['log']))
check('nonempty full build succeeded','Build completed successfully (' in (O/'00.log').read_text())
runtime={}
for idx,count in [(1,116),(3,131),(5,93),(7,189),(9,33),(10,43)]:
 pairs=re.findall(r'^([^\n:]+): (true|false)$',(O/f'{idx:02}.log').read_text(),re.M)
 check(f'{idx:02} exact runtime denominator',len(pairs)==len(dict(pairs))==count and all(v=='true' for _,v in pairs));runtime[f'{idx:02}.log']={'comparisons':count,'names':[n for n,_ in pairs]}
axioms={}
for idx,nt,nd in [(2,262,271),(4,388,419),(6,328,583),(8,524,978),(11,278,234)]:
 text=(O/f'{idx:02}.log').read_text();theorems=re.findall(r'AXIOM AUDIT theorem: ([^;]+);',text);supp=re.findall(r'AXIOM AUDIT declaration: ([^;]+);',text)
 check(f'{idx:02} exact theorem/supplemental audit',len(theorems)==len(set(theorems))==nt and len(supp)==len(set(supp))==nd and f'AXIOM AUDIT PASSED: {nt}/{nt} theorems; forbidden=0' in text and f'AXIOM AUDIT DECLARATIONS PASSED: {nd}/{nd} supplemental declarations; forbidden=0' in text)
 dependencies=re.findall(r'axioms=\[([^]]*)\]',text,re.S);check(f'{idx:02} actual standard axiom lists',dependencies and all(set(re.findall(r'[\w.]+',d))<={'propext','Classical.choice','Quot.sound'} for d in dependencies));axioms[f'{idx:02}.log']={'theorems':nt,'supplemental':nd,'forbidden':0}
legacy=js(OLD/'regression-runs.json');check('legacy executable identities retained',all(legacy['tools'][key]==r['tools'][key] for key in ['lean_executable_sha256','lake_executable_sha256','python_executable_sha256','git_executable_sha256']));original=js(OLD/'regressions/source-binding.json');carried=[]
for row in legacy['runs']:
 check('legacy '+row['label']+' accepted original execution',row['exit']==0 and row['status']=='complete' and sha(OLD/row['log'])==row['log_sha256'])
 script=row['command'][1];check('legacy '+row['label']+' same actual driver',sha(R/script)==row['script_sha256']);carried.append({'label':row['label'],'execution_revision':legacy['source_revision'],'command':row['command'],'exit':row['exit'],'log':str((OLD/row['log']).relative_to(R)),'log_sha256':row['log_sha256'],'driver':script,'driver_sha256':row['script_sha256']})
differences=[p for p,h in original.items() if sha(R/p)!=h['sha256']];check('original broad manifest difference disclosed',differences==['lean/DefiKernel/Interleaving/Verify.lean'])
closures={}
for label in ['typed-mutations','composition-mutations','parallel-mutations']:
 paths=js(OLD/'regressions'/label/'source-manifest.json')['sources'];check(label+' real input closure unchanged',bool(paths) and all(sha(R/p)==h for p,h in paths.items()));closures[label]=paths
for label,relative,key in [('typing-controls','typing-controls/results.json','sources'),('axiom-controls','axiom-controls/results.json','source_sha256_before')]:
 paths=js(OLD/'regressions'/relative)[key];check(label+' real input closure unchanged',bool(paths) and all(sha(R/p)==h for p,h in paths.items()));closures[label]=paths
for label in ['typed-runner-controls','composition-runner-controls','parallel-runner-controls']:
 summary=js(OLD/'regressions'/label/'summary.json');check(label+' actual fixture harness unchanged',sha(Path(summary['runner_source']))==summary['runner_sha256'] and sha(Path(summary['harness_source']))==summary['harness_sha256'])
corpus={p:h['sha256'] for p,h in original.items() if p.startswith(('corpus/','corpus50/')) or p in ['scripts/corpus_normalize.py','scripts/test_corpus_normalize.py','docs/research/2026-09-06-defi-source-plan.md']};check('corpus source and normalizer dependencies unchanged',bool(corpus) and all(sha(R/p)==h for p,h in corpus.items()));closures['corpus-controls']=corpus
check('legacy 9-suite nonempty retained inventory',len(carried)==9)
carry={'status':'relevant input bytes verified; no new Python regression execution','original_execution_revision':legacy['source_revision'],'baseline_execution_revision':r['actual_initial_revision'],'original_broad_manifest_count':len(original),'broad_manifest_changed_paths':differences,'actual_dependency_closures':closures,'runs':carried,'scope':'Existing mutation closures, typing/axiom sources, corpus/normalizer inputs and runner fixture driver/harness/toolchain identities remain unchanged. The new Interleaving Verify proof import is outside those actual CLI dependencies and is freshly executed in this Lean baseline. Old timestamps/heads are not relabeled.'};(O/'legacy-python-carry.json').write_text(json.dumps(carry,indent=2)+'\n')
verification={'actual_initial_revision':r['actual_initial_revision'],'actual_final_revision':r['actual_final_revision'],'commands_expected':12,'commands_run':len(r['runs']),'all_passed':True,'preserved_files':len(before),'source_unchanged':True,'assertion_count':len(checks),'checks':checks,'runtime':runtime,'axiom_audits':axioms,'legacy_python_new_runs':0,'legacy_python_carried_suites':9,'legacy_python_carry_sha256':sha(O/'legacy-python-carry.json'),'finished_utc':datetime.datetime.now(datetime.timezone.utc).isoformat()};(O/'verification.json').write_text(json.dumps(verification,indent=2)+'\n');print('PASS',len(checks),'evidence checks;12 fresh Lean commands,130 unchanged source inputs,9 accurately carried Python suites')
