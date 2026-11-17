import pathlib,json,hashlib,subprocess,shutil,os,time
root=pathlib.Path('/Users/andreaskendziorra/repositories/from_Stefan/defiformal'); ev=root/'review/semantic-kernel/competitive-landscape-adoption-20261117/margin-close-proof-review';ev.mkdir(exist_ok=True)
a=pathlib.Path('/private/tmp/defiformal-margin-close-author'); own=pathlib.Path('/private/tmp/defiformal-margin-close-review');own.mkdir(exist_ok=True); baseline=pathlib.Path('/private/tmp/defiformal-ci-baseline'); f=json.loads((a/'PROOF-FREEZE.json').read_text()); sha=lambda b:hashlib.sha256(b).hexdigest()
rt='/private/tmp/defiformal-adapter-author/runtime/lean-4.33.0-rc2-darwin_aarch64/bin';env=dict(os.environ,PATH=rt+':'+os.environ['PATH']);runs=[]
cmds=[('build',[rt+'/lake','build','DefiKernel.Margin.Verify'],0,[]),('controls',[rt+'/lake','env','lean','DefiKernel/Margin/CloseAudit.lean'],0,['CLOSE_CONTROL PASSED 26/26']),('audit',[rt+'/lake','env','lean',str(own/'Audit.lean')],0,[])]
cmds += [('kernel-'+m.split('.')[-1],[rt+'/lake','env','leanchecker','-v',m],0,[]) for m in ['DefiKernel.Margin.Close','DefiKernel.Margin.CloseAudit']]
mut=json.loads((own/'mutations.json').read_text())
for r in mut['runs']:
 p=own/pathlib.Path(r['argv'][-1]).name;assert sha(p.read_bytes())==r['source_sha256'];assert sha((own/(pathlib.Path(r['argv'][-1]).stem+'.log')).read_bytes())==r['log_sha256']
 cmds.append((r['name'],[rt+'/lake','env','lean','-R',str(own),str(p)],r['exit'],r['required_diagnostics']))
cmds.append(('whole-root-audit',[rt+'/lake','env','lean','DefiKernel.lean'],0,['forbidden=0']))
for name,argv,expected,diagnostics in cmds:
 t=time.time();r=subprocess.run(argv,cwd=baseline/'lean',env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(ev/(name+'.log')).write_bytes(r.stdout);s=r.stdout.decode(); item={'name':name,'argv':argv,'exit':r.returncode,'expected':expected,'seconds':time.time()-t,'log_sha256':sha(r.stdout),'diagnostics':diagnostics,'passed':r.returncode==expected and all(d in s for d in diagnostics)};runs.append(item);print(name,item['passed'],flush=True);assert item['passed'],s[-5000:]
(ev/'independent-verification.json').write_text(json.dumps({'runs':runs,'status':'PASS'},indent=2)+'\n')
