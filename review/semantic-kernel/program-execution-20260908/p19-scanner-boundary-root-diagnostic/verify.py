from pathlib import Path
import json,hashlib,datetime,subprocess
b=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');p=b/'p19-module-decoder-grok-r1/private-lean';o=b/'p19-scanner-boundary-root-diagnostic';o.mkdir(exist_ok=False)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
source_names=['Decode','CanonicalJson','Encode','Roundtrip'];m=json.loads((b/'p19-roundtrip-proof-agy-r26-terminal-manifest.json').read_text());bindings={}
for name in source_names:
 relative='lean/DefiKernel/Certificates/'+name+'.lean';source=p/'DefiKernel/Certificates'/str(name+'.lean');expected=next(f['sha256'] for f in m['files'] if f['path']==relative);assert h(source)==expected;bindings[relative]=expected
probe=o/'Boundary.lean';probe.write_text('''import DefiKernel.Certificates.Roundtrip
open DefiKernel.Certificates

def status {α : Type} : Except DecodeFailure α → String
  | .ok _ => "ok"
  | .error (.resourceLimit name) => "resource:" ++ name
  | .error _ => "other-error"

def nest : Nat → TreeJson
  | 0 => .null
  | n + 1 => .arr [nest n]

def observe (label : String) (tree : TreeJson) : IO Unit := do
  let text := TreeJson.encode tree
  IO.println (label ++ "|" ++ status (scanLexical text.toUTF8) ++ "|" ++ status (parseCanonicalJson text))

#eval do
  for n in [4096, 4097, 4098] do
    observe ("array-" ++ toString n) (.obj [("items", .arr (List.replicate n .null))])
  for n in [63, 64] do
    observe ("depth-" ++ toString (n + 1)) (.obj [("items", nest n)])
''')
argv=['/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin/lake','env','lean',str(probe)];start=now();run=subprocess.run(argv,cwd=p,capture_output=True,timeout=90)
(o/'stdout').write_bytes(run.stdout);(o/'stderr').write_bytes(run.stderr);put(o/'command.json',{'started_utc':start,'finished_utc':now(),'argv':argv,'cwd':str(p),'exit':run.returncode,'probe_sha256':h(probe),'source_bindings':bindings,'candidate_archive_sha256':m['sha256'],'stdout_sha256':h(o/'stdout'),'stderr_sha256':h(o/'stderr'),'actor':'root','scope':'Five executed TreeJson scanner/parser boundary examples using completed independent R26 reviewer build; no new production proof, DecodedIR admission or live author access'})
expected=['array-4096|ok|ok','array-4097|ok|resource:max_array_length','array-4098|resource:max_array_length|resource:max_array_length','depth-64|ok|ok','depth-65|resource:maxDepth|resource:maxDepth'];actual=run.stdout.decode().splitlines();put(o/'result.json',{'expected':expected,'actual':actual,'matches':actual==expected and run.returncode==0,'new_proofs':0,'full_P19_accepted':False,'interpretation':'Scanner counts commas and permits4097elements in this example; parser refuses4097. Existing TreeJson.Valid restricts arrays to4096, so this is not an admitted-domain counterexample. Depth64accepted and65refused by both in these cases. Neither finite observation proves the universal scanner or depth bridge.'})
(o/'verify.py').write_bytes(Path(__file__).read_bytes());put(o/'root-seal.json',{'utc':now(),'files':{p.name:h(p) for p in o.iterdir()},'file_count':6,'acceptance':False});assert run.returncode==0 and actual==expected,(run.stdout.decode(),run.stderr.decode());print(json.dumps({'cases':5,'actual':actual,'new_proofs':0,'P19_accepted':False}))
