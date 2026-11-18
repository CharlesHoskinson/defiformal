"""Reviewed Lean lexical code lines, Python tokenize, and native parser cross-check.

Native Inventory.lean output is supplemental: parser recovery is explicit because
commands are parsed without elaborating the local environment. Actual sources are
compiled by admission. No complete AST inventory is claimed.
"""
import ast,hashlib,io,json,pathlib,tokenize
HERE=pathlib.Path(__file__).resolve().parent
CASES=['P1','P2','P3-N4','P3-N16']
def lean_lines(text):
 depth=0;out=[]
 for number,line in enumerate(text.splitlines(),1):
  i=0;code=False;string=False
  while i<len(line):
   pair=line[i:i+2]
   if depth:
    if pair=='/-':depth+=1;i+=2
    elif pair=='-/':depth-=1;i+=2
    else:i+=1
   elif string:
    code=True
    if line[i]=='\\':i+=2;continue
    if line[i]=='"':string=False
    i+=1
   elif pair=='--':break
   elif pair=='/-':depth+=1;i+=2
   else:
    if not line[i].isspace():code=True
    if line[i]=='"':string=True
    i+=1
  if code:out.append(number)
 if depth:raise ValueError('Unclosed comment')
 return out
def inventory():
 sources=[]
 def add(name,category,cases=CASES,lines=None,**extra):
  text=(HERE/name).read_text();found=lean_lines(text) if lines is None else lines
  sources.append(dict(path=name,category=category,lines=found,cases=cases,**extra))
 add('Procedure.lean','model_loc')
 model=(HERE/'Model.lean').read_text().splitlines();spec=set()
 for a,b in [(14,14),(19,21),(26,28),(32,39),(43,44)]:spec.update(range(a,b+1))
 add('Model.lean','specification_loc',lines=[i for i in lean_lines('\n'.join(model)) if i in spec])
 add('Model.lean','model_loc',lines=[i for i in lean_lines('\n'.join(model)) if i not in spec])
 for name,users,hid in [('NativeHelper.lean',CASES,'native-correspondence'),('TransferHelper.lean',['P1','P3-N4','P3-N16'],'transfer-law'),('SequenceHelper.lean',['P3-N4','P3-N16'],'sequence-law')]:
  add(name,'shared_helper_loc',users,helper_id=hid,stages=['assisted','build'])
 for case in CASES:
  for stage in ['automatic','assisted']:
   name=case.replace('-','_')+'_'+stage+'.lean';text=(HERE/name).read_text();lines=lean_lines(text)
   generated=stage=='automatic' or case.startswith('P3')
   if generated:
    add(name,'generated_loc',[case],lines=lines,role='specification' if stage=='automatic' else 'guidance',generator='generate_targets.py',stages=[stage])
   else:
    start=next(i for i,line in enumerate(text.splitlines(),1) if 'theorem established' in line)
    finish=next(i for i,line in enumerate(text.splitlines(),1) if '#print axioms' in line)
    add(name,'guidance_loc',[case],lines=[i for i in lines if start<i<finish],stages=[stage])
    add(name,'specification_loc',[case],lines=[i for i in lines if i<=start or i>=finish],stages=[stage])
 text=(HERE/'generate_targets.py').read_text();ast.parse(text)
 lines=set()
 for tok in tokenize.generate_tokens(io.StringIO(text).readline):
  if tok.type not in (tokenize.COMMENT,tokenize.NL,tokenize.NEWLINE,tokenize.INDENT,tokenize.DEDENT,tokenize.ENDMARKER,tokenize.ENCODING):lines.update(range(tok.start[0],tok.end[0]+1))
 lines.discard(1)
 # Generator carries target-specific assisted proof text; count all its code as guidance.
 add('generate_targets.py','guidance_loc',lines=sorted(lines),stages=['assisted'])
 return dict(sources=sources,helpers=[dict(id='native-correspondence',cases=CASES,stages=['assisted','build']),dict(id='transfer-law',cases=['P1','P3-N4','P3-N16'],stages=['assisted','build']),dict(id='sequence-law',cases=['P3-N4','P3-N16'],stages=['assisted','build'])])
if __name__=='__main__':print(json.dumps(inventory(),indent=2))
