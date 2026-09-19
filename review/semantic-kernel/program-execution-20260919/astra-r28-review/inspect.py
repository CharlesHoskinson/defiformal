import pathlib,re,json,subprocess
root=pathlib.Path.cwd(); out=pathlib.Path(__file__).parent
old=(root/'recovered-r28/R27-Roundtrip.lean').read_text(); new=(root/'lean/DefiKernel/Certificates/Roundtrip.lean').read_text(); end='end DefiKernel.Certificates'; prefix=old[:old.rindex(end)]; assert new.startswith(prefix); assert new[new.rindex(end):]==old[old.rindex(end):]
added=new[len(prefix):new.rindex(end)]; names=re.findall(r'^theorem (\w+)',added,re.M); assert len(names)==38
assert not re.search(r'\b(sorry|axiom|native_decide)\b',added)
statements=[]
for m in re.finditer(r'^theorem (\w+)[\s\S]*?(?=^theorem |\Z)',added,re.M):
 text=m.group(); statements.append(dict(name=m[1],line=new[:len(prefix)+m.start()].count('\n')+1,statement=text.split(':=',1)[0].strip()))
(out/'new-declarations.json').write_text(json.dumps(statements,indent=2)+'\n')
probe='import DefiKernel.Certificates.Roundtrip\n\n'+''.join('#print axioms DefiKernel.Certificates.'+n+'\n' for n in names)
(root/'lean/AstraR28Axioms.lean').write_text(probe); (out/'AstraR28Axioms.lean').write_text(probe)
packages=json.loads((root/'lean/lake-manifest.json').read_text())['packages']; checks=[]
for p in packages:
 folder=root/'lean/.lake/packages'/p['name']; actual=subprocess.check_output(['git','-C',str(folder),'rev-parse','HEAD'],text=True).strip(); assert actual==p['rev']; assert not folder.is_symlink(); checks.append(dict(name=p['name'],revision=actual))
print(json.dumps(dict(old_theorems=len(re.findall(r'^theorem ',old,re.M)),new_theorems=len(re.findall(r'^theorem ',new,re.M)),new_declarations=names,inherited_source_exact=True,packages=checks),indent=2))
