import pathlib,json,hashlib,re,subprocess,collections,datetime,runpy,copy,sys
sys.dont_write_bytecode=True
R=pathlib.Path('/home/charl/defiformal-wt-sprint11-grok-gpt6-20260907');I=R/'review/semantic-kernel/sprint11/implementation';E=I/'gpt6-review/final-adjudication-interim';F=I/'proof-inventory-final-r2';C='94f70e502c75132656bd0902a17be60ca45ab1c2';inputs={};commands=[]
def sha(b):return hashlib.sha256(b).hexdigest()
def read(p):
 b=p.read_bytes();inputs[str(p)]={'sha256':sha(b),'bytes':len(b),'mtime_ns':p.stat().st_mtime_ns};return b
def j(p):return json.loads(read(p))
def git(*args):
 start=datetime.datetime.now(datetime.timezone.utc).isoformat();r=subprocess.run(['git',*args],cwd=R,capture_output=True);commands.append({'argv':['git',*args],'utc':start,'exit':r.returncode,'stdout_sha256':sha(r.stdout),'stderr':r.stderr.decode()});assert r.returncode==0;return r.stdout
inv=j(F/'proof-inventory.json');exe=j(F/'proof-inventory-execution.json');outer=j(I/'verification-commands-r2/inventory.json');assert inv['execution']==exe
assert inv['candidate']==exe['candidate']==C and exe['source_before']==exe['source_after'] and inv['source_bindings']==exe['source_before']
for ext in ['stdout','stderr']:assert sha(read(I/('verification-commands-r2/inventory.'+ext)))==outer[ext+'_sha256']
logchecks=[]
for command in exe['commands']:
 assert command['exit']==0
 for stream in ['stdout','stderr']:
  b=read(R/command[stream]);logchecks.append({'path':command[stream],'match':sha(b)==command[stream+'_sha256'] and len(b)==command[stream+'_bytes']})
source={}
for p,row in exe['source_before'].items():
 raw=git('show',C+':'+p);assert sha(raw)==row['sha256'] and len(raw)==row['bytes'];assert sha(b'blob '+str(len(raw)).encode()+b'\0'+raw) # git blob uses SHA1 below
 assert hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()==row['git_blob'];source[p]=raw.decode();dest=E/'candidate-source'/p;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(raw)
all_nary=git('ls-tree','-r','--name-only',C,'lean/DefiKernel/Nary').decode().splitlines();all_nary={p for p in all_nary if p.endswith('.lean')};assert len(all_nary)==20 and all_nary<=set(source)
# Independent lexical comment masking for this candidate's one-module import convention.
def mask(s):
 out=[];i=0;depth=0
 while i<len(s):
  if s[i:i+2]=='/-':depth+=1;out.extend('  ');i+=2
  elif depth and s[i:i+2]=='-/':depth-=1;out.extend('  ');i+=2
  elif depth:out.append('\n' if s[i]=='\n' else ' ');i+=1
  elif s[i:i+2]=='--':
   end=s.find('\n',i);end=len(s) if end<0 else end;out.extend(' '*(end-i));i=end
  else:out.append(s[i]);i+=1
 assert depth==0;return ''.join(out)
closure=set();external=[];todo=['lean/DefiKernel/Nary/Verify.lean','lean/DefiKernel/AxiomAudit.lean']
while todo:
 path=todo.pop()
 if path in closure:continue
 assert path in source;closure.add(path)
 for line in mask(source[path]).splitlines():
  if re.match(r'^\s*(?:public\s+)?import\b',line):
   m=re.fullmatch(r'\s*(?:public\s+)?import\s+([A-Za-z0-9_.]+)\s*',line);assert m,(path,line);name=m[1]
   if name.startswith('DefiKernel.'):todo.append('lean/'+name.replace('.','/')+'.lean')
   else:external.append((path,name))
assert closure|{'lean/lakefile.toml','lean/lake-manifest.json','lean/lean-toolchain'}==set(source)
verify=read(F/'proof-inventory-verify.log').decode();driver=read(F/'proof-types.log').decode();data_checks={};rawgroups={}
for key,tag,audtag in [('theorems','NARY_PROOF_JSON ','theorem'),('supplemental','NARY_SUPPLEMENTAL_JSON ','declaration')]:
 raw=[json.loads(line[len(tag):]) for line in driver.splitlines() if line.startswith(tag)];rawgroups[key]=raw
 assert len(raw)==len(inv[key]) and len({x['name'] for x in raw})==len(raw)
 rows=re.findall(r'^AXIOM AUDIT '+audtag+r': ([^;]+); module=([^;]+); (?:kind=([^;]+); )?axioms=\[([^\]]*)\]',verify,re.M)
 assert len(rows)==len(raw) and len({x[0] for x in rows})==len(rows)
 audited={name:(module,set(re.findall(r'[^,\s]+',axs)),kind) for name,module,kind,axs in rows}
 saved={r['name']:r for r in inv[key]}
 for row in raw:
  assert all(saved[row['name']][k]==v for k,v in row.items());assert row['statement'].strip() and all(mark not in row['statement'] for mark in ['...','⋯','…'])
  assert set(row['axioms'])<=set(['propext','Classical.choice','Quot.sound'])
  assert audited[row['name']][:2]==(row['module'],set(row['axioms']))
  if key=='supplemental':assert audited[row['name']][2]==row['kind']
  p='lean/'+row['module'].replace('.','/')+'.lean';assert p in all_nary and saved[row['name']]['source']==p and saved[row['name']]['source_sha256']==exe['source_before'][p]['sha256']
 data_checks[key]={'rows':len(raw),'unique_names':len(saved),'fresh_verify_names_modules_axioms_exact':True,'raw_statement_equal':True,'nonempty_no_ellipsis':True,'axioms_standard_only':True,'full_statement_characters':sum(len(x['statement']) for x in raw),'shortest_statement':min(len(x['statement']) for x in raw),'longest_statement':max(len(x['statement']) for x in raw)}
assert 'AXIOM AUDIT PASSED: 1459/1459 theorems; forbidden=0' in verify and 'AXIOM AUDIT DECLARATIONS PASSED: 1131/1131 supplemental declarations; forbidden=0' in verify
# Re-run only pure attribution/classification over frozen strings; never inventory entry point or Lean.
builder=I/'gpt6-review/inventory-r3-logs/build-proof-inventory.py';driverpath=builder.parent/'proof-inventory-driver.lean'
assert sha(read(builder))==exe['builder_sha256_before']==exe['builder_sha256_after'];assert sha(read(driverpath))==exe['driver_sha256_before']==exe['driver_sha256_after']
api=runpy.run_path(str(builder),run_name='review_data_only');decls={};notes=[]
for path in sorted(all_nary):
 module=path.removeprefix('lean/').removesuffix('.lean').replace('/','.');ds,ns=api['index_source_text'](source[path],module,path,exe['source_before'][path]);decls.update(ds);notes.extend(ns)
assert not notes
classification=[]
for key in ['theorems','supplemental']:
 for original in rawgroups[key]:
  row=copy.deepcopy(original);func='attribute_theorem' if key=='theorems' else 'attribute_supplemental';api[func](row,decls,exe['source_before']);saved=next(x for x in inv[key] if x['name']==row['name']);assert row['declaration_origin']==saved['declaration_origin']
  if key=='theorems':
   cat,note=api['classify_claim'](row,row['declaration_origin']);assert cat==saved['category'] and note==saved['scope_note'];classification.append((cat,row['declaration_origin']))
# Saved binaries are read-only hashed, not run; historical before/after equality is independently checked.
assert exe['tools_before']==exe['tools_after'];tools=[]
for tool in exe['tools_before']:
 p=pathlib.Path(tool['path']);b=read(p);tools.append({'path':str(p),'matches_saved':sha(b)==tool['sha256'] and len(b)==tool['bytes']})
for p in [I/'gpt6-review/inventory-r3-review.md',I/'gpt6-review/inventory-r3-inputs.json',I/'gpt6-review/inventory-r3-acceptance.json',I/'candidate-source-freeze-r1.json',I/'parent-import-integration.json']:read(p)
for p in (I/'integrated-r2').iterdir():
 if p.is_file():read(p)
before=j(I/'integrated-r2/sources-before.json');after=j(I/'integrated-r2/sources-after.json');assert before==after
binding={r['path']:r for r in before};integrated_match={p:binding[p]['sha256']==r['sha256'] for p,r in exe['source_before'].items()};assert all(integrated_match.values())
build=j(I/'integrated-r2/01-lake-build.json');assert build['exit_code']==0
for stream in ['stdout','stderr']:assert sha(read(I/('integrated-r2/01-lake-build.'+stream)))==build[stream+'_sha256']
counts={'origins':dict(collections.Counter(r['declaration_origin'] for r in inv['theorems'])),'categories':dict(collections.Counter(r['category'] for r in inv['theorems'])),'category_by_origin':{'|'.join(k):v for k,v in collections.Counter(classification).items()},'supplemental_kinds':dict(collections.Counter(r['kind'] for r in inv['supplemental'])),'unresolved_modules':dict(collections.Counter(r['module'] for r in inv['theorems'] if r['declaration_origin'].startswith('unresolved'))),'private_names':sum(r['is_private_name'] for r in inv['theorems']),'foreign_namespace_theorems':sum(not r['user_name'].startswith('DefiKernel.Nary.') for r in inv['theorems'])}
selected=['DefiKernel.Nary.toBinary_runNary','DefiKernel.Nary.continueMonitored_every_prefix','DefiKernel.Nary.FundedEnabledness.producer_execute','DefiKernel.Nary.InterfaceInstances.f14_runNary_expected']
(E/'selected-full-statements.json').write_text(json.dumps([r for r in inv['theorems'] if r['name'] in selected],indent=2)+'\n')
result={'candidate':C,'data_checks':data_checks,'counts':counts,'source_closure_files':len(source),'local_lean_modules':len(closure),'nary_sources':len(all_nary),'nary_imported_with_declarations':len({r['module'] for r in inv['theorems']+inv['supplemental']}),'external_imports':external,'independent_import_closure_matches':True,'source_bytes_and_git_blobs_match':True,'classification_pure_replay_matches':True,'log_checks':logchecks,'tools':tools,'integrated_build_exit':build['exit_code'],'integrated_57_sources_match_inventory':integrated_match,'execution':exe,'unresolved_names':[{'name':r['name'],'module':r['module'],'origin':r['declaration_origin'],'category':r['category']} for r in inv['theorems'] if r['declaration_origin'].startswith('unresolved')],'scope_limits':inv['premise_and_scope_limits'],'commands':commands,'inputs':inputs,'diagnostics':['One preliminary metadata printer assumed integrated sources-before was a dict; actual list shape read and handled; AttributeError was a reviewer display probe, not inventory execution failure.']}
result['input_drift']=[p for p,row in inputs.items() if sha(pathlib.Path(p).read_bytes())!=row['sha256'] or pathlib.Path(p).stat().st_mtime_ns!=row['mtime_ns']]
(E/'audit-results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:result[k] for k in ['candidate','data_checks','counts','source_closure_files','local_lean_modules','nary_sources','nary_imported_with_declarations','tools','integrated_build_exit','input_drift']},indent=2))
