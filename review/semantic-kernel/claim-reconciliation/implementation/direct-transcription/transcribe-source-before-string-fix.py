#!/usr/bin/env python3
"""Author Lean literals directly from original source rows; never imports the comparison extractor."""
import hashlib,json,pathlib,re,datetime,subprocess
R=pathlib.Path(__file__).resolve().parents[5];O=pathlib.Path(__file__).resolve().parent
src=R/'viz/src/data.ts';table=R/'formal/v2/tables.mjs'
sha=lambda b:hashlib.sha256(b).hexdigest()
quote=lambda s:json.dumps(s,ensure_ascii=False)
# Read individual source lines independently of the JavaScript table module.
symbols=[];parsed=[];ledger=[]
for line_number,line in enumerate(src.read_text().splitlines(),1):
 if re.match(r'  \{ id: "(?:E[0-9]+|CSM)", sym:',line):
  fields={k:json.loads(v) for k,v in re.findall(r'(id|sym|name|group|stratum|atom|status): ("(?:[^"\\]|\\.)*"|[0-9]+)',line)}
  assert set(fields)=={'id','sym','name','group','stratum','atom','status'}
  symbols.append(fields);ledger.append({'kind':'symbol','path':str(src.relative_to(R)),'line':line_number,'text':line,'fields':fields})
assert len(symbols)==59 and len({s['sym'] for s in symbols})==59
known={s['sym'] for s in symbols}
def strip_annotation(term):
 return re.sub(r'\{[^}]*\}','',term).replace('(','').replace(')','').strip()
for n,line in enumerate(src.read_text().splitlines(),1):
 m=re.match(r'  \{ id: "(L[0-9]+)", rule: ("(?:[^"\\]|\\.)*")',line)
 if not m:continue
 ident,raw=m[1],json.loads(m[2]);left,_,right=raw.partition('→')
 subjects=[x for atom in left.split('|') if (x:=strip_annotation(atom)) in known]
 terms=[]
 for chunk in right.split('+'):
  prose=chunk.strip();parts=[strip_annotation(atom) for atom in prose.split('|')]
  alts=[x for x in parts if x in known];mixed=bool(alts) and len(alts)<len(parts)
  terms.append({'alts':alts,'prose':prose,'external':not alts or mixed,'mixed':mixed})
 row={'id':ident,'raw_rule':raw,'raw_subject':left,'source_path':'viz/src/data.ts','source_line':n,'source_text':line,'subject_decision':'parsed' if subjects else 'prose_subject_zero','subjects':subjects,'terms':terms}
 parsed.append(row);ledger.append({'kind':'parsed-law-transcription','path':'viz/src/data.ts','line':n,'text':line,'literal':row,'rationale':'Direct original law-string transcription, retaining exact subject whitespace and explicit symbol/prose/mixed decisions. Separate Python procedure, no JavaScript module execution or comparison output.'})
assert len(parsed)==29
# Independently transcribe all eleven explicit LSTAR rows and four aliases from the source text.
price=['Ex','Tp','At','Oa','Sv','Cl','Cp','St','Wg'];index=['Ex','Tp','Oa','At'];loss=['Li','Ad','Sl','Bs'];terminal=['Sl','Ad','Bs','Tr','Cv','Wq','Rd','Ps','Sv','Im','Of']
lstar_literals=[
 ('L1a',['Pl','Im','Cd','Pf','Op'],[price]),
 ('L1c',['Pl','Im','Cd','Pf'],[['Ct']]),
 ('L1d',['Pl','Im','Cd','Pf'],[loss]),
 ('L2',['Pl'],[['Sh','Ix','Rb'],terminal]),
 ('L3',['Uc'],[['Aw'],['At'],['Bs','Tr','Sv','Ft','Ct'],['Sv','Ft','Fz','Ep','Tr']]),
 ('L4',['Pf'],[index,['Ct'],['Li','Ad','Sl','Bs']]),
 ('L5',['Py'],[['Sh','Ix','Rb'],['Ep'],['Rd']]),
 ('L7',['Cd'],[['Rd','Ps','Li','Ad','Sl','Bs']]),
 ('L19',['Of'],[['Xm'],['Xf'],['Bs','Sl']]),
 ('L20',['Rl'],[['Au']]),('L21',['Gs'],[['Au']])]
table_lines=table.read_text().splitlines();lstar=[]
for ident,subjects,term_alts in lstar_literals:
 matches=[(n,line) for n,line in enumerate(table_lines,1) if line.startswith('  ["'+ident+'",')];assert len(matches)==1
 n,line=matches[0]
 row={'id':ident,'raw_rule':'','raw_subject':'','source_path':'formal/v2/tables.mjs','source_line':n,'source_text':line,'subject_decision':'explicit','subjects':subjects,'terms':[{'alts':a,'prose':'','external':False,'mixed':False} for a in term_alts]}
 lstar.append(row);ledger.append({'kind':'lstar-manual-row','path':'formal/v2/tables.mjs','line':n,'text':line,'literal':row,'rationale':'Explicit tuple and PRICE/INDEX/LOSS/TERMINAL lists manually transcribed from original source; no table-module execution or extractor output.'})
for key,values in [('PRICE',price),('INDEX',index),('LOSS',loss),('TERMINAL',terminal)]:
 n,line=next((n,l) for n,l in enumerate(table_lines,1) if l.startswith('const '+key+' ='))
 assert json.loads(line.split('=',1)[1].strip().rstrip(';'))==values
 ledger.append({'kind':'lstar-alias','path':'formal/v2/tables.mjs','line':n,'text':line,'values':values})
names=[s['sym'] for s in symbols if s['status']!='limit'];assert len(names)==58
for row in parsed+lstar:
 assert all(s in names for s in row['subjects'])
 assert all(s in names for t in row['terms'] for s in t['alts'])
assert [r['id'] for r in parsed if not r['subjects']]==['L14','L23','L25','L26']
lines=['import Mathlib.Data.Fintype.Basic','import Mathlib.Data.List.FinRange','', '/-! Fixed historical source transcription. The comparison extractor did not supply these literals. -/', 'namespace DefiHistorical.Convex.Data','', 'structure Symbol where','  id : String','  sym : String','  name : String','  group : String','  stratum : Nat','  atom : String','  status : String','  deriving DecidableEq, Repr','', 'structure Term where','  alts : List String','  prose : String','  external : Bool','  mixed : Bool','  deriving DecidableEq, Repr','', 'structure Law where','  id : String','  rawRule : String','  rawSubject : String','  sourcePath : String','  sourceLine : Nat','  sourceText : String','  subjectDecision : String','  subjects : List String','  terms : List Term','  deriving DecidableEq, Repr','', 'inductive Instance | lstar | parsedNew','  deriving DecidableEq, Repr, Fintype','', 'def symbols : List Symbol := [']
for i,s in enumerate(symbols):
 vals=[quote(s[k]) if k!='stratum' else str(s[k]) for k in ['id','sym','name','group','stratum','atom','status']]
 lines.append('  ⟨'+', '.join(vals)+'⟩'+(',' if i<len(symbols)-1 else ']'))
def liststr(xs):return '['+', '.join(quote(s) for s in xs)+']'
for name,rows in [('lstarLaws',lstar),('parsedNewLaws',parsed)]:
 lines+=['',f'def {name} : List Law := [']
 for i,row in enumerate(rows):
  terms=['⟨'+liststr(t['alts'])+', '+quote(t['prose'])+', '+str(t['external']).lower()+', '+str(t['mixed']).lower()+'⟩' for t in row['terms']]
  vals=[quote(row[k]) for k in ['id','raw_rule','raw_subject','source_path']]+[str(row['source_line']),quote(row['source_text']),quote(row['subject_decision']),liststr(row['subjects']),'['+', '.join(terms)+']']
  lines.append('  ⟨'+',
    '.join(vals)+'⟩'+(',' if i<len(rows)-1 else ']'))
lines+=['', 'def laws : Instance → List Law','  | .lstar => lstarLaws','  | .parsedNew => parsedNewLaws','', 'def mechanismNames : List String := (symbols.filter (fun s ↦ s.status != "limit")).map Symbol.sym','', 'abbrev Vertex := Fin 58','', 'def decode (v : Vertex) : String := mechanismNames[v.val]?.getD ""','', 'def encode (name : String) : Option Vertex :=','  (List.finRange 58).find? (fun v ↦ decode v == name)','', '/-- Ordered non-self unary occurrences. All external and non-unary terms are excluded. -/','def occurrencePairs (instance : Instance) : List (String × String) :=','  (laws instance).flatMap fun law ↦ law.terms.flatMap fun term ↦','    if !term.external && term.alts.length == 1 then','      law.subjects.filterMap fun subject ↦','        let target := term.alts.headD ""','        if subject == target then none else some (subject, target)','    else []','', '/-- Keep the first occurrence of each directed edge. -/','def relationEdges (instance : Instance) : List (String × String) :=','  (occurrencePairs instance).foldl (fun seen pair ↦','    if seen.contains pair then seen else seen ++ [pair]) []','', '/-- The same named edge list is exported and used by the finite-instance proofs. -/','def edge (instance : Instance) (a b : Vertex) : Prop :=','  (decode a, decode b) ∈ relationEdges instance','', 'instance (i : Instance) : DecidableRel (edge i) := fun a b ↦ inferInstance','', '/-- Check complete parsed subjects and alternatives before selecting unary edges. -/','def allNamesBound (instance : Instance) : Bool :=','  (laws instance).all fun law ↦','    law.subjects.all (fun name ↦ mechanismNames.contains name) &&','    law.terms.all (fun term ↦ term.alts.all (fun name ↦ mechanismNames.contains name))','', 'theorem symbols_length : symbols.length = 59 := by decide','theorem mechanismNames_length : mechanismNames.length = 58 := by decide','theorem mechanismNames_nodup : mechanismNames.Nodup := by decide','theorem names_bound (i : Instance) : allNamesBound i = true := by cases i <;> decide','theorem encode_decode : ∀ v : Vertex, encode (decode v) = some v := by decide','', 'theorem decode_encode (name : String) (v : Vertex) (found : encode name = some v) :','    decode v = name := by','  exact of_decide_eq_true (by simpa only [encode, beq_iff_eq] using List.find?_some found)','', 'end DefiHistorical.Convex.Data','']
path=R/'lean/DefiHistorical/Convex/Data.lean';path.parent.mkdir(parents=True,exist_ok=True);assert not path.exists();path.write_text('
'.join(lines))
record={'status':'DIRECT_SOURCE_TRANSCRIPTION_BEFORE_COMPARISON','started_from_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip(),'captured_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sources':{str(p.relative_to(R)):{'sha256':sha(p.read_bytes()),'bytes':p.stat().st_size} for p in [src,table]},'generator_sha256':sha(pathlib.Path(__file__).read_bytes()),'output':{'path':str(path.relative_to(R)),'sha256':sha(path.read_bytes())},'rows':ledger,'zero_subject_rows':['L14','L23','L25','L26'],'independence':'Direct original-source reading and manual LSTAR literal transcription in this separate Python author procedure. No comparison extractor code, output, table-module execution or Lean export was read. Schema agreement only. Mathematical proof and independent source comparison remain pending.'}
(O/'transcription-ledger.json').write_text(json.dumps(record,indent=2,ensure_ascii=False)+'\n')
print('WROTE',path,'59symbols/58mechanisms/11+29laws',sha(path.read_bytes()))
