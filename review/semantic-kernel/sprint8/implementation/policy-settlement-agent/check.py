import datetime, hashlib, json, pathlib, re, shutil, subprocess, sys
root=pathlib.Path('/home/charl/defiformal'); work=root/'lean'
out=pathlib.Path(__file__).resolve().parent
owned=[work/'DefiKernel/Atomic'/f'{name}.lean' for name in ['Policy','PolicyProofs','Settlement','Correspondence']]
def sha(p): return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def stamp(): return datetime.datetime.now(datetime.timezone.utc).isoformat()
def capture():
 return {'utc':stamp(),'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),'owned':[{'path':str(p.relative_to(root)),'sha256':sha(p),'bytes':p.stat().st_size,'git_blob':subprocess.check_output(['git','hash-object',str(p)],cwd=root,text=True).strip()} for p in owned]}
meta={'before':capture(),'commands':[]}
plugin=pathlib.Path('/home/charl/.codex/plugins/cache/lean4-skills/lean4/4.8.5')
lake=pathlib.Path(subprocess.check_output(['elan','which','lake'],cwd=work,text=True).strip())
lean=pathlib.Path(subprocess.check_output(['elan','which','lean'],cwd=work,text=True).strip())
meta['tools']=[{'path':str(p),'sha256':sha(p)} for p in [lake,lean,pathlib.Path(sys.executable).resolve(),plugin/'lib/scripts/sorry_analyzer.py',plugin/'lib/scripts/parse_command_args.py']]
commands=[('pinned-version',[str(lean),'--version']),('plugin-prove-parser',[sys.executable,str(plugin/'lib/scripts/parse_command_args.py'),'prove','--cwd',str(work),'--','DefiKernel/Atomic/PolicyProofs.lean']),('build',[str(lake),'build','DefiKernel.Atomic.Policy','DefiKernel.Atomic.PolicyProofs','DefiKernel.Atomic.Settlement','DefiKernel.Atomic.Correspondence']),('audit',[str(lake),'env','lean',str(out/'Audit.lean')])]
commands += [('plugin-sorry-'+p.stem,[str(plugin/'bin/lean4-skills-sorry-analyzer'),str(p),'--format=json']) for p in owned]
for name,cmd in commands:
 started=stamp(); proc=subprocess.run(cmd,cwd=work,capture_output=True)
 a=out/(name+'.stdout');b=out/(name+'.stderr');a.write_bytes(proc.stdout);b.write_bytes(proc.stderr)
 record={'name':name,'argv':cmd,'cwd':str(work),'started_utc':started,'finished_utc':stamp(),'returncode':proc.returncode,'stdout':a.name,'stdout_sha256':sha(a),'stderr':b.name,'stderr_sha256':sha(b)}
 meta['commands'].append(record); print(name,proc.returncode,flush=True)
 (out/'checks.json').write_text(json.dumps(meta,indent=2)+'\n')
meta['after']=capture();meta['owned_bytes_unchanged']=meta['before']['owned']==meta['after']['owned']
meta['all_commands_passed']=all(x['returncode']==0 for x in meta['commands'])
(out/'checks.json').write_text(json.dumps(meta,indent=2)+'\n')
