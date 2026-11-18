"""Executable canonical, counterexample, parser, trust and cache admission checks."""
import hashlib,json,pathlib,re,sys
import adapter,procedure,setup,generate_targets
kind,case=sys.argv[1:3]
if case not in adapter.CASES:raise ValueError('Unknown case')
output=dict(schema_version=1,check=kind,case_id=case,status='passed',evidence=['Model.lean','correspondence.json','acceptance.py'])
details={}
if kind in ('canonical','mutants'):
 details['preparation']=adapter.prepare(case,'automatic');dest=adapter.directory(case,'automatic')
 ex=procedure.invoke(adapter.HERE/'Examples.lean',dest);details['examples']=ex
 if adapter.classify(ex,'Benchmark.examples_ok')!='success':raise RuntimeError(json.dumps(ex))
 output['evidence']+=['Examples.lean']
 if kind=='canonical':output.update(domain='canonical_INT64',obligations_complete=True)
 else:
  mutant=procedure.invoke(adapter.HERE/'Mutants.lean',dest);details['counterexample_proof']=mutant
  if adapter.classify(mutant,'Benchmark.mutantWitness')!='success':raise RuntimeError(json.dumps(mutant))
  output.update(status='rejected',reason='counterexample',mutants=['missing_sender_debit','ceiling_swap','interior_p3_step'])
  details['witnesses']={'missing_sender_debit':'(10,3,7), 0->1 amount4: total20->24','ceiling_swap':'(100,100),d10: product10000->9900','interior_p3_step':'N4 step1 total10->12; N16 step1 total10->11'}
  output['evidence']+=['Mutants.lean']
elif kind=='parser':
 good=dict(returncode=0,stdout="'Benchmark.established' depends on axioms: [propext, Classical.choice, Quot.sound]\n",stderr='',verification_executed=True,artifact_exists=True,artifact_sha256='a'*64)
 fixtures={'success':good,'failed_obligations':dict(good,returncode=1,stdout='error: unsolved goals'),'incomplete':dict(good,stdout=''),'timeout':dict(good,returncode=124),'cached_skip':dict(good,verification_executed=False),'malformed':{'returncode':'0'}}
 output['fixtures']={key:adapter.classify(value) for key,value in fixtures.items()}
 if output['fixtures']!={key:key for key in fixtures}:raise RuntimeError('Parser fixture mismatch')
 for invalid in [dict(good,stdout="'Benchmark.established' depends on axioms: [sorryAx]"),dict(good,artifact_exists=False),dict(good,returncode=137,stdout='Killed')]:
  if adapter.classify(invalid)!='incomplete':raise RuntimeError('Unproved status promoted')
 details['fixtures']=fixtures;output['evidence']+=['adapter.py','test_parser.py']
elif kind in ('trust','cache'):
 names=['Procedure.lean','Model.lean','NativeHelper.lean',adapter.target(case,'automatic')+'.lean',adapter.target(case,'assisted')+'.lean']
 if case!='P2':names+=['TransferHelper.lean']
 if case.startswith('P3'):names+=['SequenceHelper.lean']
 for name in names:
  text=(adapter.HERE/name).read_text()
  if re.search(r'\b(sorry|admit|axiom|unsafe|native_decide|run_cmd)\b',text):raise RuntimeError('Proof hole/unchecked construct in '+name)
 for name,text in generate_targets.render().items():
  if (adapter.HERE/name).read_text()!=text:raise RuntimeError('Generator/source mismatch')
 details['source_hashes']={name:setup.digest(adapter.HERE/name) for name in names};runs=[]
 for _ in range(2 if kind=='cache' else 1):
  prep=adapter.prepare(case,'assisted');dest=adapter.directory(case,'assisted')
  if (dest/(adapter.target(case,'assisted')+'.olean')).exists():raise RuntimeError('Preparation retained target')
  if (dest/'NativeHelper.olean').exists() or (dest/'TransferHelper.olean').exists() or (dest/'SequenceHelper.olean').exists():raise RuntimeError('Preparation retained new proof helper')
  result=adapter.replay(case,'assisted')
  if adapter.classify(result)!='success':raise RuntimeError(json.dumps(result))
  runs.append(dict(preparation=prep,execution=result,proof_sha256={p.name:setup.digest(p) for p in dest.glob('*.olean*')}))
 if kind=='cache' and runs[0]['proof_sha256']!=runs[1]['proof_sha256']:raise RuntimeError('Repeated clean proof artifacts differ')
 details['runs']=runs
 if kind=='trust':details['independent_check']=adapter.check_proof(case)
 output['evidence']+=names+['generate_targets.py']
else:raise ValueError('Unknown check kind')
output['details']=details
print(json.dumps(output))
