import json,pathlib
O=pathlib.Path(__file__).parent;rows=json.loads((O/'compiled-inventory.json').read_text());s='import DefiKernel.Certificates.Lexical\nimport Lean.Elab.Command\n'
for r in rows:
 n='Lean.Name.anonymous'
 for p in r['name'].split('.'):
  n=('Lean.Name.num ('+n+') '+p) if p.isdigit() else ('Lean.Name.str ('+n+') '+json.dumps(p))
 s+='run_cmd do\n  let n := '+n+'\n  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))\n'
(O/'ExactAxioms.lean').write_text(s);print('Generated exact Name-based #print axioms for',len(rows),'constants, including numeric private Name components.')
