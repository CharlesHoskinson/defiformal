from pathlib import Path
import json,hashlib,datetime,tarfile,subprocess
r=Path('/home/charl/defiformal');b=r/'review/semantic-kernel/program-execution-20260908';o=b/'p19-scanner-root-guidance';o.mkdir(exist_ok=False)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n');now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
m=json.loads((b/'p19-roundtrip-proof-agy-r26-terminal-manifest.json').read_text());assert h(b/m['archive'])==m['sha256'];sources={}
with tarfile.open(b/m['archive']) as t:
 for n in ['Decode','CanonicalJson']:
  path='lean/DefiKernel/Certificates/'+n+'.lean';raw=t.extractfile(path).read();claimed=next(f['sha256'] for f in m['files'] if f['path']==path);assert hashlib.sha256(raw).hexdigest()==claimed
  text=raw.decode();lines=text.splitlines();spans=[(25,164)] if n=='Decode' else [(368,394),(926,946),(1021,1075),(1660,1685),(1721,1737),(1741,1766)]
  sources[path]={'sha256':claimed,'excerpts':[{'start_line':a,'end_line':z,'text':'\n'.join(lines[a-1:z])} for a,z in spans]}
put(o/'source-excerpts.json',{'archive_sha256':m['sha256'],'files':sources})
notes='''# Remaining lexical scanner proof: frozen R26 guidance

This is root analysis of the frozen production definitions, not an AGY implementation, a Grok review, or a completed scanner theorem. R27 is live; this packet is for the next handoff. Do not interrupt or inspect its drafts.

The target remains `scanLexical (encodeModule ir) = .ok ()` under existing `StructurallyAdmissibleIR`. Proving parser inversion again does not establish the extra lexical pass.

1. Separate wrapper checks from the recursive scanner. `scanLexical` checks byte size <=1048576, valid UTF8, nonempty filtered characters and an opening object brace, then starts at depth0/scopes[]/numeric buffer[]/whitespacefalse with character length+1 fuel. Existing `string_fromUTF8?_toUTF8` handles the UTF8 inversion. The module is an object; do not generalize the wrapper to scalar documents.
2. Use a continuation lemma for `scanLexicalFuel` on canonical `TreeJson.encode` fragments. State must include depth, scope stack, numeric buffer and whitespace. Object scopes store visited decoded keys and an expectKey flag; list induction needs remaining keys disjoint from visited keys. Actual recursive `TreeJson.Valid` supplies distinct keys and array length, without assuming scanner success.
3. Strings consume one outer scanner step, although `lexString` may consume many escaped characters. Existing `lexString_escapeJsonString` proves the successful branch for arbitrary canonical Unicode and control escapes. Key strings add one decoded key and clear expectKey; value strings preserve scopes. Do not impose an arbitrary string-length cap or allow whitespace inside encoded strings to set the outer whitespace flag.
4. Numbers consume one scanner step per character and remain buffered until a delimiter or end of document. A generic value-fragment lemma cannot claim every scalar clears the numeric buffer: the numeric leaf leaves decimal characters there. Either track a canonical buffered-number postcondition or include the following delimiter in the induction interface. `scanLexicalCheckNum` must exclude '.', 'e', 'E' for integer encodings, including negative integers. Booleans/null do not form numeric buffers.
5. Opening braces/brackets increment depth and enforce <=64; matching closing delimiters decrement depth and pop the top scope. A useful invariant is initial depth plus tree depth <=64 with matching stack frames. An arbitrary continuation with malformed closing delimiters does not justify a well-formed-stack claim.
6. Array scope count is incremented on commas, not elements. On a nonempty list of n elements there are n-1 increments. The scanner checks `cnt+1>4096`; do not describe that scanner alone as the exact 4096-element parser bound. Existing Valid array length<=4096 is sufficient for every comma guard, and the canonical parser separately enforces array admission. This is a proof-accounting observation, not a newly demonstrated admitted counterexample or authorization to change the scanner.
7. Do not copy the tokenizer's exact token-fuel accounting: the scanner advances for each numeric/literal character but skips whole strings. One route is a separate structural scanner-cost bound <= encoded character length; another is sufficient-fuel invariance proved with actual lexString progress. Both are proposed proof routes, not proved lemmas. Preserve the existing length+1 wrapper budget.

After the generic fragment result, specialize to the complete encoded module, discharge depth from the actual whole-document depth bridge and validity from the existing module validity theorem, and compose with the new R26 whole-module decoder theorem. The universal roundtrip theorem and all P19 campaign/host/schema obligations remain open until separately verified.

The attached command only checks the availability of existing declarations against the completed independent R25 build. Decode/CanonicalJson source bytes match frozen R26. It does not build R27, prove these proposed invariants, or add production lemmas.
'''
(o/'NOTES.md').write_text(notes)
probe=o/'References.lean';probe.write_text('import DefiKernel.Certificates.Roundtrip\n'+''.join('#check DefiKernel.Certificates.'+n+'\n' for n in ['lexString_escapeJsonString','string_fromUTF8?_toUTF8','escapeTreeString_eq','encode_obj_toList','encodeObj_cons_cons_toList','toString_int_length_ge_one','TreeJson.valid_of_mem_validObj']))
p=b/'p19-typed-payload-grok-r1/private-lean'
for n in ['Decode','CanonicalJson']:
 rel='lean/DefiKernel/Certificates/'+n+'.lean';assert h(p/'DefiKernel/Certificates'/str(n+'.lean'))==sources[rel]['sha256']
argv=['/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin/lake','env','lean',str(probe)];start=now();run=subprocess.run(argv,cwd=p,capture_output=True,timeout=60)
(o/'stdout').write_bytes(run.stdout);(o/'stderr').write_bytes(run.stderr);put(o/'command.json',{'started_utc':start,'finished_utc':now(),'argv':argv,'cwd':str(p),'exit':run.returncode,'probe_sha256':h(probe),'stdout_sha256':h(o/'stdout'),'stderr_sha256':h(o/'stderr'),'actor':'root','scope':'Existing declaration availability only; completed R25 reviewer build, matching R26 Decode/CanonicalJson sources; no new proof or live worker reads'})
(o/'verify.py').write_bytes(Path(__file__).read_bytes());put(o/'root-seal.json',{'utc':now(),'files':{p.name:h(p) for p in o.iterdir()},'file_count':7,'acceptance':False});assert run.returncode==0,run.stdout.decode()+run.stderr.decode();print(json.dumps({'existing_declarations_checked':7,'new_proofs':0,'files':7,'exit':run.returncode,'for_next_author_handoff':True}))
