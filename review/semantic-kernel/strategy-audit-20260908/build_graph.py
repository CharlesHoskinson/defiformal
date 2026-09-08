#!/usr/bin/env python3
"""Source-snapshot Graphify map. No semantic/proof status is inferred from edges."""
from pathlib import Path
import collections,datetime,hashlib,importlib.util,importlib.metadata,json,os,re,subprocess,sys
from graphify.extract import extract,_DISPATCH
from graphify.detect import detect
from graphify.build import build
from graphify.cluster import cluster,score_all
from graphify.analyze import god_nodes,surprising_connections,suggest_questions
from graphify.export import to_json,to_html
import networkx as nx
R=Path('/home/charl/defiformal'); A=R/'review/semantic-kernel/strategy-audit-20260908'; O=R/'graphify-out/strategy-audit-20260908'; O.mkdir(parents=True,exist_ok=True)
S=Path('/home/charl/.cache/defiformal-program/strategy-audit-20260908/source-snapshot'); S.mkdir(parents=True,exist_ok=True)
spec=importlib.util.spec_from_file_location('prior_builder',R/'graphify-out/codebase/build-source-graph.py');old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)
code=(set(_DISPATCH)-{'.md','.mdx','.qmd','.json','.skill','.toc'})|{'.lean','.qnt','.tla','.sol'}
excluded={'review','graphify-out','.git','.lake','node_modules','vendor','dist','build','generated','__pycache__','.venv','venv','packages','protocol-repos','tmp','.superpowers'}
def sha(b):return hashlib.sha256(b).hexdigest()
def git(root,*args):return subprocess.check_output(['git',*args],cwd=root)
def save(path,x):path.write_text(json.dumps(x,indent=2,ensure_ascii=False)+'\n')
tracked=set(git(R,'ls-files','-z').decode().split('\0'))-{''};untracked=set(git(R,'ls-files','--others','--exclude-standard','-z','--','lean','scripts','viz').decode().split('\0'))-{''}
records=[];blobs={}
def add(layer,root,path,status):
 p=root/path
 if not p.is_file() or p.is_symlink() or any(q.is_symlink() for q in p.parents if q!=root):return
 if Path(path).suffix not in code or any(t in excluded for t in Path(path).parts):return
 raw=p.read_bytes();key=layer+'/'+path;dst=S/key;dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(raw);blobs[key]=raw
 records.append({'id':key,'layer':layer,'path':path,'original_path':str(p),'sha256':sha(raw),'bytes':len(raw),'status':status,'extractor':'Lean literal imports with comments/strings masked' if path.endswith('.lean') else 'Graphify AST' if Path(path).suffix in _DISPATCH else 'inventory only'})
head=git(R,'rev-parse','HEAD').decode().strip()
for path in sorted(tracked|untracked):
 if Path(path).suffix not in code or any(t in excluded for t in Path(path).parts):continue
 p=R/path
 if not p.is_file() or p.is_symlink():continue
 eq=path in tracked and p.read_bytes()==git(R,'show',head+':'+path)
 add('primary',R,path,'delivered HEAD bytes' if eq else 'unaccepted working-tree bytes')
lanes={'sprint12':['lean/DefiKernel/Nary/Tree'],'lifecycle':['lean/DefiKernel/CapabilityProvenance'],'claims':['lean/DefiKernel/Claims'],'corpus':['scripts/corpus_adjudicate.py','scripts/corpus_adjudication','scripts/test_corpus_adjudication.py'],'historical':['scripts/historical_claims.py','scripts/historical_convex_evidence.py','scripts/historical_reconciliation','scripts/test_historical_reconciliation.py'],'atlas':['viz/src','viz/scripts','viz/test'],'honest-gate':['formal/v3/negtest-reporting.sh']}
for lane,roots in lanes.items():
 root=Path('/home/charl')/f'defiformal-wt-{lane}-grok-gpt6-20260908'
 for scope in roots:
  p=root/scope
  for f in sorted(p.rglob('*')) if p.is_dir() else [p]:
   if f.is_file():add(lane,root,str(f.relative_to(root)),'isolated candidate; acceptance must be checked separately')
# Detect code partitions independently; do not ingest documents, corpus payloads, or review archives.
detections={}
for p in sorted(S.iterdir()):
 if p.is_dir():detections[p.name]=detect(p,cache_root=O,gitignore=False)
save(O/'detection.json',detections)
ast=extract([S/k for k in blobs if Path(k).suffix in _DISPATCH],root=S,cache_root=O,parallel=False)
ast=json.loads(json.dumps(ast).replace(str(S)+'/', ''));save(O/'ast-extraction.json',ast)
nodes=[{'id':x['id'],'label':x['id'],'source_file':x['original_path'],'source_location':'L1','file_type':'code','layer':x['layer'],'source_sha256':x['sha256'],'source_status':x['status'],'family':x['layer']+'/'+('/'.join(Path(x['path']).parts[:3]) if x['path'].startswith('lean/DefiKernel/') else '/'.join(Path(x['path']).parts[:2]))} for x in records]
edges=[];external=[];unparsed=[];byid={n['id']:n for n in ast['nodes']};dropped=collections.Counter()
for e in ast['edges']:
 l=byid.get(e.get('source'),{}).get('source_file');r=byid.get(e.get('target'),{}).get('source_file')
 if l not in blobs or r not in blobs or l==r:dropped['within_file_or_outside_selection']+=1;continue
 if e.get('confidence')!='EXTRACTED':dropped['not_extracted']+=1;continue
 edges.append({'source':l,'target':r,'relation':'ast_'+e['relation'],'confidence':'EXTRACTED','source_file':str(S/l),'source_location':e.get('source_location'),'weight':1.0})
for row in records:
 k=row['id'];path=row['path'];layer=row['layer']
 if path.endswith('.lean'):
  source=old.mask_lean(blobs[k].decode())
  for m in re.finditer(r'^[ \t]*(?:public[ \t]+)?import[ \t]+([^\n]+)',source,re.M):
   line=source.count('\n',0,m.start())+1
   for mod in m.group(1).split():
    if not re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*(?:\.[A-Za-z_][A-Za-z_0-9]*)*',mod):unparsed.append({'file':k,'line':line,'token':mod});continue
    suffix='lean/'+mod.replace('.','/')+'.lean';target=layer+'/'+suffix
    if target not in blobs:target='primary/'+suffix
    if target in blobs:edges.append({'source':k,'target':target,'relation':'imports','confidence':'EXTRACTED','source_file':row['original_path'],'source_location':f'L{line}','weight':1.0})
    else:external.append({'file':k,'line':line,'module':mod,'status':'external or excluded; not read'})
# Variants are inventoried separately, not represented as runtime calls or accepted supersession.
variants=[{'candidate':r['id'],'primary':'primary/'+r['path'],'same_bytes':r['sha256']==sha(blobs['primary/'+r['path']])} for r in records if r['layer']!='primary' and 'primary/'+r['path'] in blobs]
extraction={'nodes':nodes,'edges':edges,'input_tokens':0,'output_tokens':0};save(O/'file-extraction.json',extraction)
G=build([extraction],directed=True,dedup=False,root=R);assert G.number_of_nodes()==len(records)>0
communities=cluster(G);scores=score_all(G,communities);labels={c:collections.Counter(G.nodes[n]['family'] for n in ns).most_common(1)[0][0] for c,ns in communities.items()}
assert to_json(G,communities,str(O/'graph.json'),community_labels=labels,built_at_commit=head)
if G.number_of_nodes()>5000:raise RuntimeError('Need user-visible HTML node warning before visualization')
assert to_html(G,communities,str(O/'graph.html'),community_labels=labels)
hubs=sorted([{'file':n,'incoming':G.in_degree(n),'outgoing':G.out_degree(n)} for n in G],key=lambda r:(-r['incoming'],r['file']))[:20]
missing=[(u,v) for u,v in G.edges if u not in G or v not in G];assert not missing
cycles=[sorted(c) for c in nx.strongly_connected_components(G) if len(c)>1]
roots=[n for n in G if n.endswith('/Verify.lean') or n in ['primary/lean/DefiKernel.lean','primary/lean/DefiHistorical.lean']]
reachable=set(roots)
for n in roots:reachable.update(nx.descendants(G,n))
analysis={'nodes':len(G),'edges':G.number_of_edges(),'communities':len(communities),'cohesion':scores,'labels':labels,'hubs':hubs,'cycles':cycles,'layer_counts':dict(collections.Counter(r['layer'] for r in records)),'extensions':dict(collections.Counter(Path(r['path']).suffix for r in records)),'ast_nodes':len(ast['nodes']),'ast_edges':len(ast['edges']),'ast_failed_sources':ast.get('failed_sources',[]),'dropped_ast_edges':dict(dropped),'variants':variants,'lean_roots':roots,'lean_not_reachable_from_selected_roots':[n for n in G if n.endswith('.lean') and n not in reachable],'unreachability_is_not_deadcode_proof':True,'graph_health':{'dangling_edges':len(missing),'unparsed_lean_imports':len(unparsed)},'model_tokens':{'input':0,'output':0}}
save(O/'analysis.json',analysis)
drift=[r['original_path'] for r in records if not Path(r['original_path']).is_file() or sha(Path(r['original_path']).read_bytes())!=r['sha256']]
manifest={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'primary_head':head,'sources':records,'changed_since_snapshot':drift,'lean_external_imports':external,'lean_unparsed_imports':unparsed,'graphify_version':importlib.metadata.version('graphifyy'),'python':sys.executable,'script_sha256':sha(Path(__file__).read_bytes()),'scope':'Code-only primary tracked/untracked Lean/scripts/viz plus owned isolated candidate source; no docs/payload/holdout semantic extraction','limitations':['Lean imports only; no Lean AST/theorem/call extraction','Quint/TLA/Solidity unsupported by installed AST remain file inventory','Static AST resolution is incomplete especially dynamic CLI and shell calls','Candidate->primary import fallback is architectural navigation, not candidate dependency equality verification','Disconnected files are not proven dead','Metadata counts and community cohesion are not proof or progress scores'],'extraction_model_tokens':{'input':0,'output':0}}
save(O/'source-manifest.json',manifest);assert not drift
report=f'''# DeFiFormal source graph — strategic audit\n\nCaptured {manifest['utc']}. Primary HEAD `{head}`.\n\n{len(records)} source-file nodes, {G.number_of_edges()} directed edges, {len(communities)} communities. Graphify AST: {len(ast['nodes'])} symbol nodes / {len(ast['edges'])} edges before file aggregation. Model extraction tokens: 0 input / 0 output. No token-reduction benchmark was run.\n\n## Scope and limits\n\n'''+''.join('- '+x+'\n' for x in manifest['limitations'])+'\nPrimary and candidate layers are separate. No candidate is accepted by appearing in this graph. Existing root/codebase graphs remain preserved as historical snapshots. HTML uses Graphify’s CDN visualization dependency.\n\n## Layer inventory\n\n'+''.join(f'- {k}: {v} files\n' for k,v in analysis['layer_counts'].items())+'\n## God nodes: measured file dependency hubs\n\n'+''.join(f'- `{r["file"]}`: {r["incoming"]} incoming / {r["outgoing"]} outgoing\n' for r in hubs)+'\n## Surprising connections and audit implications\n\nThe legacy `formal/v2/tables.mjs` remains a dependency of reporting/visualization tools. It is not safely removable merely because the proof program pivoted. New candidate proof modules are often standalone roots and must not be deleted based on the delivered umbrella root alone. See actual paths in graph.json.\n\n## Communities\n\n| ID | Dominant file family | Files | Raw cohesion |\n|---|---|---:|---:|\n'+''.join(f'| {c} | {labels[c]} | {len(ns)} | {scores[c]} |\n' for c,ns in sorted(communities.items(),key=lambda x:-len(x[1])) if len(ns)>1)+'\n## Suggested questions\n\n- Which historical tools remain on the current reporting and Atlas dependency paths?\n- Which candidate modules are absent from delivered verification roots?\n- Which apparent orphan files are externally invoked CLI or evidence roots?\n\n## Integrity\n\nSource drift: 0. Dangling edges: 0. Unparsed Lean import tokens: '+str(len(unparsed))+'. Extraction failures are recorded in analysis.json. No inference of semantic soundness follows from graph integrity.\n'
(O/'GRAPH_REPORT.md').write_text(report)
save(O/'artifact-manifest.json',[{'path':str(p.relative_to(O)),'sha256':sha(p.read_bytes()),'bytes':p.stat().st_size} for p in sorted(O.glob('*')) if p.is_file() and p.name!='artifact-manifest.json'])
print(json.dumps({k:analysis[k] for k in ['nodes','edges','communities','layer_counts','ast_failed_sources','graph_health']}))
