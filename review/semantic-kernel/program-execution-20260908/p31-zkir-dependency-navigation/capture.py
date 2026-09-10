from pathlib import Path
import json,hashlib,datetime,re,tomllib,shutil
R=Path('/home/charl/defiformal');B=R/'review/semantic-kernel/program-execution-20260908';O=B/'p31-zkir-dependency-navigation';O.mkdir(exist_ok=False)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat();put=lambda p,d:p.write_text(json.dumps(d,indent=2)+'\n')
D=B/'p31-zkir-dependency-source-preparation';Z=B/'p31-zkir-source-preparation/crate/midnight-zkir-2.1.0';seal=json.loads((D/'root-seal.json').read_text())['files'];assert seal
for n,digest in seal.items():assert h(D/n)==digest,n
lock=tomllib.loads((D/'inputs/Cargo.lock').read_text());package={(p['name'],p['version']):p for p in lock['package']}
def dep(n,v,rel):return D/(n+'-'+v)/'source'/(n+'-'+v)/rel
sources={
 'ir':Z/'src/ir.rs','vm':Z/'src/ir_vm.rs',
 'hash':dep('midnight-transient-crypto','2.0.0','src/hash.rs'),
 'repr':dep('midnight-transient-crypto','2.0.0','src/repr.rs'),
 'curve':dep('midnight-transient-crypto','2.0.0','src/curve.rs'),
 'stdlib':dep('midnight-zk-stdlib','1.0.0','src/lib.rs'),
 'poseidon_cpu':dep('midnight-circuits','6.0.0','src/hash/poseidon/poseidon_cpu.rs'),
 'poseidon_chip':dep('midnight-circuits','6.0.0','src/hash/poseidon/poseidon_chip.rs'),
 'fq':dep('midnight-curves','0.2.0','src/bls12_381/fq.rs')}
# Each interval is navigation into exact frozen bytes, not a semantic theorem.
spans=[('commitment_preprocess','vm',484,499,['comm_comm_inputs.extend(preimage.inputs.iter())','transient_commit(&comm_comm_inputs[..], comm_comm.1)']),('commitment_circuit','vm',765,789,['let mut preimage = vec![comm_comm_rand]','preimage.extend(inputs.iter().cloned())','preimage.extend(outputs.iter().cloned())','&public_inputs[1]']),('transient_hash_and_commit','hash',75,89,['PoseidonChip<outer::Scalar>','let mut preimage = vec![opening]','value.field_repr(&mut preimage)']),('field_slice_representation','repr',282,289,['impl FieldRepr for [Fr]','writer.write(self)']),('outer_and_embedded_aliases','curve',51,73,['pub type Scalar = midnight_curves::Fq','pub type Scalar = midnight_curves::Fr']),('outer_fr_wrapper','curve',145,159,['pub struct Fr(pub outer::Scalar)']),('stdlib_field','stdlib',98,103,['type F = midnight_curves::Fq']),('stdlib_poseidon_call','stdlib',691,701,['pub fn poseidon(','.hash(layouter, input)']),('poseidon_cpu_hash','poseidon_cpu',252,259,['HashCPU<F, F> for PoseidonChip<F>','init(Some(inputs.len()))']),('poseidon_circuit_hash','poseidon_chip',550,563,['HashInstructions<F, AssignedNative<F>, AssignedNative<F>>','self.init(layouter, Some(inputs.len()))']),('fq_modulus_limbs','fq',42,48,['const MODULUS: [u64; 4]']),('fq_modulus_hex','fq',501,504,['0x73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001']),('pi_skip_preprocess','vm',421,445,['I::PiSkip { guard, count }','public_transcript_inputs_idx -= *count as usize','Public transcript input mismatch']),('pi_skip_circuit','vm',624,632,['I::PiSkip { .. } => {}'])]
records=[]
for ident,key,start,end,needles in spans:
 p=sources[key];lines=p.read_text().splitlines(keepends=True);excerpt=''.join(lines[start-1:end]);assert all(n in excerpt for n in needles),(ident,needles)
 records.append({'id':ident,'path':str(p.relative_to(R)),'source_sha256':h(p),'start_line':start,'end_line':end,'excerpt':excerpt,'excerpt_sha256':hashlib.sha256(excerpt.encode()).hexdigest(),'classification':'static_source_navigation_not_execution_or_proof'})
text=sources['fq'].read_text();hexvalue=re.search(r'const MODULUS: &\x27static str =\s*"(0x[0-9a-f]+)"',text).group(1);limbtext=re.search(r'const MODULUS: \[u64; 4\] = \[(.*?)\];',text,re.S).group(1);limbs=[int(x.replace('_',''),16) for x in re.findall(r'0x[0-9a-f_]+',limbtext)];value=sum(x<<(64*i) for i,x in enumerate(limbs));assert value==int(hexvalue,16)
external=[p for p in lock['package'] if p['name']=='blst'];assert len(external)==1
put(O/'navigation.json',{'schema':'defiformal-zkir-dependency-navigation/v1','utc':now(),'dependency_seal_sha256':h(D/'root-seal.json'),'lock_sha256':h(D/'inputs/Cargo.lock'),'sources':{k:{'path':str(p.relative_to(R)),'sha256':h(p)} for k,p in sources.items()},'anchors':records,'field_modulus':{'hex':hexvalue,'decimal':str(value),'bit_length':value.bit_length(),'little_endian_limbs_agree':True,'method':'Python integer parsing of two constants in captured Fq source; no downloaded Rust execution.'},'specific_external_boundary':external,'acceptance':False,'semantic_contract_accepted':False})
(O/'README.md').write_text('''# P31 ZKIR dependency navigation

This is a root source-navigation record over the captured crate versions. It is input preparation for the native AGY adapter author and fresh Grok review. It does not implement or accept the semantic contract.

## Commitment data flow

The ZKIR preprocessing path concatenates its inputs and computed outputs, then passes that field slice and the commitment randomness to `transient_commit`. That helper puts the opening first. The `FieldRepr` implementation for `[Fr]` writes the slice directly, without a length prefix. The circuit path explicitly assembles randomness, inputs and outputs in that same order, calls the standard library Poseidon gadget, and asserts equality with public input index1. These source expressions resolve the previously uncaptured preimage-layout dependency.

The CPU hash and circuit hash both use `PoseidonChip` with fixed-length initialization from the number of input elements. This is source-level alignment, not proof that the implementations or generated constraints agree. The internal sponge/permutation constraints, field operations, witness and public-input binding, and actual harness execution remain required within the declared adapter scope.

## Field identity

The transient-crypto wrapper `Fr` contains `outer::Scalar`, which aliases `midnight_curves::Fq`. The standard library field is also `midnight_curves::Fq`. The separate embedded curve scalar aliases `midnight_curves::Fr`; it must not be substituted merely because its Rust identifier matches the wrapper name. The captured Fq modulus is `0x73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001`. The decimal value and agreement with the four little-endian limbs are recomputed in navigation.json.

Arithmetic is over that field. Any supported bounded-integer financial operation needs an explicit representation and range/no-wrap correspondence; source capture does not supply it. Fq arithmetic also calls `blst`, whose exact locked package is recorded as an uncaptured external dependency in navigation.json. Capturing all twelve Midnight packages is not a full dependency build closure.

## Transcript boundary

`PiSkip` has preprocessing behavior: a false guard records a skip and adjusts the transcript input cursor; the other branch checks the associated public-transcript elements. The circuit match arm is empty. This difference must be accounted for by the adapter's witness, transcript, skip and public-instance interface. It is not, by itself, proof of a circuit bug or of soundness. Source index/bounds assumptions must remain explicit.

## Next implementation obligations

The AGY author must declare the supported opcodes and representation, witness/public-input ordering, transcript rules, and commitment interface, and establish scoped correspondence with real execution before adapter acceptance. Compiler source-to-installed-binary correspondence remains a disclosed assumption unless separately established; no new universal compiler-correctness or mandatory reproducible-build gate is introduced here. Full P31, P19/P20 integration and the whole roadmap remain open.

All fourteen anchors bind original repository paths, complete source hashes, line intervals and exact excerpt hashes. No downloaded source or circuit was executed by this navigation step.
''')
shutil.copy2(__file__,O/'capture.py');put(O/'root-seal.json',{'utc':now(),'files':{str(p.relative_to(O)):h(p) for p in O.rglob('*') if p.is_file()},'acceptance':False});print(json.dumps({'source_files':len(sources),'anchors':len(records),'modulus_limbs_match_hex':True,'modulus_decimal':str(value),'external_blst':external[0]['version'],'acceptance':False}))
