from pathlib import Path
import datetime,hashlib,json,subprocess,shutil
B=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908');O=B/'p19-r22-root-object-diagnostic';S=Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p19-module-map-stuck-grok-r1-sandbox');T=Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin');now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
assert not Path('/proc/2285155').exists();O.mkdir(exist_ok=False);shutil.copy2(__file__,O/'run.py')
probe=O/'ObjectDiagnostic.lean';probe.write_text('''import DefiKernel.Certificates.Correspondence
open Lean DefiKernel.Certificates
namespace RootObjectDiagnostic
-- This projection inspects representation only; it is not a production API.
def rootKey : Json → String
  | .obj o => match o.inner.inner with
    | .leaf => "<empty>"
    | .inner _ k _ _ _ => k
  | _ => "<nonobject>"
def encodedOrder : Json :=
  (TreeJson.obj [("theorem", .str "t"), ("module", .str "m")]).toJson
def mappedOrder : Json :=
  libraryRefToJson {theoremName := "t", moduleName := some "m"}
#eval rootKey encodedOrder
#eval rootKey mappedOrder
#eval encodedOrder == mappedOrder
-- A real counterexample to structural equality of this scratch representation.
theorem distinct_roots : rootKey encodedOrder ≠ rootKey mappedOrder := by decide
theorem distinct_json : encodedOrder ≠ mappedOrder := by
  intro h
  exact distinct_roots (congrArg rootKey h)
-- Unsupported raw tags are outside the admitted step grammar.
theorem unsupported_quote_mismatch :
    encodeStep (.unsupported "\\\"") ≠
      (TreeJson.obj [("tag", .str "\\\"")]).encode := by decide
#print axioms RootObjectDiagnostic.distinct_roots
#print axioms RootObjectDiagnostic.distinct_json
#print axioms RootObjectDiagnostic.unsupported_quote_mismatch
end RootObjectDiagnostic
''')
inputs=json.loads((B/'p19-module-map-stuck-grok-r1/inputs.json').read_text())
for n,d in inputs['files'].items():assert h(S/n)==d,n
argv=[str(T/'lake'),'env',str(T/'lean'),str(probe)];start=now()
with (O/'stdout').open('xb') as out,(O/'stderr').open('xb') as err:
 p=subprocess.run(argv,cwd=S/'lean',stdout=out,stderr=err,timeout=90)
put(O/'command.json',{'argv':argv,'cwd':str(S/'lean'),'started_utc':start,'finished_utc':now(),'exit':p.returncode,'probe_sha256':h(probe),'lean_sha256':h(T/'lean'),'lake_sha256':h(T/'lake'),'stdout_sha256':h(O/'stdout'),'stderr_sha256':h(O/'stderr'),'input_bindings_verified':len(inputs['files']),'input_manifest_sha256':h(B/'p19-module-map-stuck-grok-r1/inputs.json'),'scope':'New ROOT diagnostic on immutable R22 production/previous reviewer cache. Not a Grok or AGY execution; not a full codec theorem.'})
put(O/'root-seal.json',{'utc':now(),'files':{p.name:h(p) for p in O.iterdir() if p.is_file()},'acceptance':False});print('exit',p.returncode);print((O/'stdout').read_text());print((O/'stderr').read_text())
