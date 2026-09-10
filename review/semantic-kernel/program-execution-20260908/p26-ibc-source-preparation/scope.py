from pathlib import Path
import datetime,hashlib,json,shutil
O=Path('/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p26-ibc-source-preparation')
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat(); h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def put(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
rows=[]
def anchor(label,path,needle,claim):
 p=O/'source'/path; lines=p.read_text().splitlines();matches=[i+1 for i,line in enumerate(lines) if needle in line]
 assert matches,(label,needle)
 rows.append({'id':label,'path':'source/'+path,'sha256':h(p),'needle':needle,'matching_lines':matches,'static_observation':claim,'proof_or_execution':False})
packet='modules/core/04-channel/keeper/packet.go'; msg='modules/core/keeper/msg_server.go';timeout='modules/core/04-channel/keeper/timeout.go';relay='modules/apps/transfer/keeper/relay.go'
anchor('receive-proof',packet,'k.connectionKeeper.VerifyPacketCommitment(', 'Receive verifies the remote packet commitment before applying replay protection; a valid packet proof is an explicit environmental input.')
anchor('stale-lifecycle-replay',packet,'packet already processed in previous channel upgrade','A packet sequence below recvStartSequence returns ErrPacketReceived. The same guard also protects acknowledgement writing.')
anchor('ordinary-replay',packet,'return types.ErrNoOpMsg','Ordinary unordered duplicate receipts and older ordered receive sequences yield ErrNoOpMsg; this is distinct from stale-lifecycle and out-of-order errors.')
anchor('receive-noop-api',msg,'return &channeltypes.MsgRecvPacketResponse{Result: channeltypes.NOOP}, nil','The top-level receive handler maps ErrNoOpMsg to NOOP with nil error and returns before the application callback.')
anchor('ack-noop-api',msg,'return &channeltypes.MsgAcknowledgementResponse{Result: channeltypes.NOOP}, nil','Acknowledgement relay no-op is also a successful API result, not transaction failure.')
anchor('timeout-noop-api',msg,'return &channeltypes.MsgTimeoutResponse{Result: channeltypes.NOOP}, nil','Timeout relay no-op returns before the refund callback; required verification precedes this classification.')
anchor('timeout-maturity',timeout,'packet timeout not reached','Timeout requires maturity at the supplied proof height/timestamp. Missing local commitment alone is not the entire timeout guard.')
anchor('timeout-nonreceipt',timeout,'k.connectionKeeper.VerifyPacketReceiptAbsence(','Unordered timeout needs a verified absence of the remote receive receipt. Ordered timeout instead checks next receive sequence and its proof.')
anchor('ack-consumes-commitment',packet,'k.deletePacketCommitment(ctx, packet.GetSourcePort(), packet.GetSourceChannel(), packet.GetSequence())','Successful acknowledgement deletes the source packet commitment before the caller performs its application acknowledgement callback.')
anchor('timeout-consumes-commitment',timeout,'k.deletePacketCommitment(ctx, packet.GetSourcePort(), packet.GetSourceChannel(), packet.GetSequence())','timeoutExecuted deletes the commitment and closes an ordered channel. Local Cosmos transaction semantics remain an external runtime obligation.')
anchor('refund-callback',relay,'return k.refundPacketTokens(ctx, sourcePort, sourceChannel, data)','Timeout invokes token refund. Error acknowledgement also refunds; successful acknowledgement returns without token movement on the sending chain.')
anchor('refund-authority-guard',relay,'if k.IsBlockedAddr(sender) {','Refund can reject a blocked sender. Refund success is conditional; it must not be asserted from timeout maturity alone.')
anchor('refund-asset-origin',relay,'if token.Denom.HasPrefix(sourcePort, sourceChannel) {','Refund remints previously burned vouchers for a prefixed denomination; otherwise it unescrows. These are different accounting branches.')
anchor('verified-misbehaviour','modules/core/02-client/keeper/client.go','clientModule.UpdateStateOnMisbehaviour(ctx, clientID, clientMsg)','UpdateClient verifies the client message, checks misbehaviour, updates/freeze state and returns nil on detected misbehaviour; it does not directly refund pending transfers.')
anchor('freeze-state','modules/light-clients/07-tendermint/update.go','cs.FrozenHeight = FrozenHeight','Tendermint UpdateStateOnMisbehaviour sets FrozenHeight; the caller must have verified and detected misbehaviour.')
put(O/'source-navigation.json',{'utc':now(),'anchors':rows,'anchor_count':len(rows),'scope':'Static source navigation. No Go compilation, runtime test, formal proof, dependency closure, complete workflow contract or acceptance.','acceptance':False})
m=json.loads((O/'source-manifest.json').read_text())
(O/'README.md').write_text(f'''# P26 IBC source candidate

Root captured 33 official IBC-Go files at commit `{m['commit']}`. Each selected file matches the Git blob recorded in the captured commit tree and the cached upstream archive. The source contains the classic ICS-04 packet handlers, ICS-20 transfer callbacks and Tendermint client misbehaviour handling. Four reference test files are retained without execution. This is a source candidate for AGY's later entry design and Grok review, not acceptance of task 27.1 or a deployed-chain identity.

The key source constraint is the distinction between duplicate consumption prevention and transaction failure. Ordinary duplicate receives produce `ErrNoOpMsg` internally and `MsgRecvPacketResponse{{Result: NOOP}}, nil` at the public handler, before the application callback. Acknowledgement and timeout relay duplicates have corresponding NOOP paths. Packets below the channel lifecycle receive-start sequence instead return `ErrPacketReceived`; out-of-order packets have another actual error. The P26 replay observation must preserve these results. If its required executor-refusal scenario cannot be instantiated faithfully, select a different workflow or state an explicit reviewed observation mapping. Do not invent an error-returning API for ordinary IBC duplicates.

Acknowledgement and timeout processing consume the sending chain's packet commitment. Timeout requires verified remote non-receipt and proof-height/time maturity. A successful acknowledgement does not refund; an error acknowledgement or successful timeout callback refunds by unescrow or voucher remint according to denomination origin. Refund itself can fail, including for a blocked recipient. Exact source/destination asset identities, local SDK transaction atomicity, authenticated light-client proofs, sequencing and receipt retention require explicit assumptions or further correspondence evidence. These local transactions do not roll back another chain.

Verified client misbehaviour freezes the Tendermint client with a successful update result. That is a challenge/finality control path, not automatic per-message compensation or proof that all frozen packets can be refunded. Pending transfers after a freeze, recoveries, custody failures, oracle authenticity, legal status and finality assumptions must remain visible in the later contract. P29's complete cross-domain accounting remains separate.

The graph query found no matching P26 nodes; that is a navigation limitation, not repository-wide absence evidence. The authoritative program specifies all lifecycle, finality, replay, timeout, challenge and compensation obligations. None is waived by this source selection.

The source declares module `github.com/cosmos/ibc-go/v11` and Go `1.26.5`, with Cosmos SDK `v0.55.0` and CometBFT `v0.40.0`. Those are source declarations, not installed tool identities. Imports and build dependencies are not closed. No downloaded code, reference test, Lean proof or chain runtime was executed. No P26 or P29 task is accepted. Full workflow selection, plan/observation review, implementation, at-most-once and exclusive terminal proofs, successful/control/refusal executions, double-terminal mutation and independent negative remain required.
''')
shutil.copy2(__file__,O/'scope.py')
files={str(p.relative_to(O)):h(p) for p in O.rglob('*') if p.is_file()};assert 'root-seal.json' not in files
put(O/'root-seal.json',{'utc':now(),'files':files,'file_count':len(files),'P26_accepted':False,'P29_accepted':False})
print(json.dumps({'sealed_files':len(files),'source_files':m['file_count'],'static_anchors':len(rows),'acceptance':False}))
