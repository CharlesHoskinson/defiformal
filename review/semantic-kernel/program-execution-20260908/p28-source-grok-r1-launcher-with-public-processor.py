"""Prepared source audit. Launch only after R26 proof review is root-sealed and the slot is free."""
from pathlib import Path
import datetime
import hashlib
import json
import shutil
import subprocess

ROOT = Path('/home/charl/defiformal')
BASE = ROOT / 'review/semantic-kernel/program-execution-20260908'
OUT = BASE / 'p28-source-grok-r1'
SANDBOX = Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p28-source-grok-r1-sandbox')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read(path):
    return json.loads(path.read_text())


def write(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def main():
    previous = BASE / 'p19-module-decoder-grok-r1'
    if not (previous / 'root-seal.json').exists():
        raise SystemExit('R26 proof review must be complete and root-sealed first.')
    prior_seal = read(previous / 'root-seal.json')
    for relative, expected in prior_seal['files'].items():
        assert sha(previous / relative) == expected, relative
    assert (BASE / 'p27-source-grok-r1/root-adjudication.json').exists()
    dispatch = read(previous / 'dispatch.json')
    if Path('/proc', str(dispatch['pid'])).exists():
        raise SystemExit('Prior reviewer still present; do not occupy a second audit slot.')
    if (BASE / 'p19-roundtrip-proof-agy-r27-process.json').exists():
        raise SystemExit('R27 is terminal: assess and prioritize its proof audit before this source audit.')
    author = read(BASE / 'p19-roundtrip-proof-agy-r27-dispatch.json')
    if not Path('/proc', str(author['pid'])).exists():
        raise SystemExit('R27 author is no longer live; prioritize its freeze and proof review.')
    current = read(BASE / 'STATE.json').get('independent_reviewer', {})
    current_pid = current.get('pid')
    if current_pid and Path('/proc', str(current_pid)).exists():
        raise SystemExit('Current independent reviewer is still live.')
    OUT.mkdir(exist_ok=False)
    SANDBOX.mkdir(exist_ok=False)
    for name in ['p28-depeg-source-preparation', 'p28-depeg-dependency-preparation', 'p28-depeg-license-source', 'p28-depeg-lifecycle-scope', 'p28-depeg-compiler-preparation', 'p28-depeg-compiler-baseline', 'p28-insurance-root-verification', 'p28-payout-abi-diagnostic', 'p28-payout-abi-diagnostic-attempt2', 'p28-payout-abi-root-verification', 'p28-depeg-lifecycle-diagnostic', 'p28-depeg-lifecycle-root-verification', 'p28-public-processor-diagnostic', 'p28-public-processor-root-verification']:
        packet = BASE / name
        seal = read(packet / 'root-seal.json')
        assert len(seal['files']) > 0
        if 'file_count' in seal: assert len(seal['files']) == seal['file_count']
        for path, digest in seal['files'].items():
            assert sha(packet / path) == digest, path
        for path in list(seal['files']) + ['root-seal.json']:
            source = packet / path
            target = SANDBOX / source.relative_to(ROOT)
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
    for path in [
        'review/semantic-kernel/program-execution-20260908/p28-payout-abi-runtime-scope.json',
        'review/semantic-kernel/program-execution-20260908/p28-depeg-lifecycle-diagnostic-scope.md',
        'review/semantic-kernel/program-execution-20260908/p28-public-processor-scope.md',
        'AGENTS.md',
        '.claude/skills/defi-footguns/SKILL.md',
        'formal/v3/GATE-REGISTER.md',
        'openspec/changes/reusable-verification-platform-program/tasks.md',
        'openspec/changes/reusable-verification-platform-program/specs/source-bound-library-families/spec.md',
        'review/semantic-kernel/program-execution-20260908/PLAN-ACCEPTANCE.md',
    ]:
        target = SANDBOX / path
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(ROOT / path, target)
    inputs = {str(p.relative_to(SANDBOX)): sha(p) for p in SANDBOX.rglob('*') if p.is_file()}
    write(OUT / 'inputs.json', {'utc': now(), 'sandbox': str(SANDBOX), 'files': inputs,
                              'file_count': len(inputs), 'acceptance': False})
    brief = f'Fresh native Grok4.6 high independent P28 insurance source/compiler and bounded EVM diagnostic audit. Frozen sandbox {SANDBOX}; write only {OUT}. AGY implements P19 separately. Do not inspect author worktrees, live source/caches, or other live reviews. No subagents, network, Foreman, extra windows, branches, commits or pushes. Latest user routing is AGY author and Grok independent reviewer; older AGENTS model instructions are historical.\n\nOfficial Etherisc depeg-contracts develop pin4447d725f8f756c5b884677cdafe88714da283e5/tree8292282de8a8b041563aa78d2abbd11af0cf8649; current source pin, not deployed identity. Brownie dependency route: OZ4.7.3/ecd2ca2cd7cac116f7a37d0e474bbb3d7d5e1c4d, Chainlink1.10.0/aeb8c8022290bb742948eac2b3c6a0f3dd200cce, GIFinterface3b0002ab746e145b7d59635b0fbeb3fac423d41a, GIFcoreb58fd27a34452e062d10b175f3bdd7ee16b9d1a7. Actual dependency records are authoritative. Npm route differs and is not mixed into this compile. Selected closure71sources184lexicaledges; 6CRLF-to-LF compiler input normalizations recorded. Solc0.8.2+661d1103 SHA b6b9429d71d4395901795936a0aaee0b23082fcaee10d563d87b42e69c0e68c2; optimizer200 defaultIstanbul. Baseline71contracts26nonemptycreationobjects,0errors10warnings. Inspect source, lock/ref, compiler input/output and raw identity bindings. No new compiler download/build is required for source evidence audit. No Solidity/Python package installation.\n\nRead the actual public DepegProduct claim and attestation flow, ProductService authorization/delegation, PolicyDefaultFlow, TreasuryModule/PolicyController and token transfer assumptions. Protected wallet authorizes claim creation; contract owner attests historical wallet balances and may overwrite them; processing is public but state-gated. Policy metadata.owner receives GIF payout; protected wallet is not automatically recipient. Balance coverage is token units, payout is rounded price-loss units; preserve min(protected,attested,remaining) and claimAmount cap. Creation expires/queues, not discharge. Missing attestation DP043, zero DP044, not queued DP042, exhausted DP045 are distinct. Historical/oracle/legal truth and real token behavior remain external assumptions.\n\nAudit ROOT diagnostic authorship precisely. Payout ABI attempt1 and2 each have5actual EVM cases through actual Product/ProductService/PolicyDefaultFlow, with mocks. Actual flow returns(bool success,uint fee,uint net); bool staysfalse; Product reads two uint words(0,7), ignoring93. DepegProduct ignores those returned words. Attempt1 wrapper return length64 was a constant marker; attempt2 measures actual64 rawbytes. Raw service length96. Two source refusals checked. Do not claim a lost-token exploit or real payout failure from this bounded ABI behavior.\n\nNew public lifecycle diagnostic has11actual cases and12outputwords each; actual DepegProduct, ProductService, PolicyDefaultFlow constructors/functions execute unchanged. Policy/instance service, treasury, pool/riskpool, oracle, component/license and registry are explicitly MOCKS. Application/active policy state is fixture-provided; premium/underwriting/application creation not executed; NO real token transfers or actual PolicyController/TreasuryModule/PoolController accounting. Source-free fixture code is not a source-faithful financial library. Mock application protects100 units perpolicy, price80/target100. Inspect harness and all raw results/expected vectors: one success processes100/pays20; missing/zero attestation preserves queue; unauthorized claim and owner-attestation refuse; three policies share150 with100+50 thenDP045; overwritten50 afterprocessed100 triggersactualPanic0x11; mocktreasuryrevert rolls back queue/processed/mockeffects; processing batchsecondDP045 rollsbackfirsttoo; invalidattestationbatchreturns1good2bad andretainsvalid150. Revertbytesare checked by executed harness assertions, markersaloneare not independent rawrevert logs. Original11case lifecycle packet does not execute unrelatedcaller processing. NEW p28-public-processor-diagnostic executes only scenarios11–13: distinct nonowner/noninsured contract invokes actual processPolicy, queued+attested succeeds with processed100/mockpaid20, missingattestation rejectsDP043, absentqueue rejectsDP042. Actual executed harness asserts owner/caller distinction and exact refusalbytes. Its57236byteharness is injected, not ordinarily deployed. Six actual root commands and12rawstreams, all71upstreamsource strings andcontractobjects unchanged. Original11cases not rerun. New rootverification has actualalteredpayout vector negative. Audit this new observation with the same mock/token/identity/proof limitations. Mocklicensingdoesnotprove actualregistrygovernance.\n\nPinned geth evm1.15.11 SHA d298ce2c811de089d650ed4f9535c0c58efc72e7adee9b61a40b6c10cc26fb5c executeslocalParisgenesis block0timestamp1. Actualconstructedruntimebytes:Depeg23233,service1106,flow13138. ABIattempt2 harness24631 andlifecycleharness56325 exceedEIP170; injected evmrunharnesses, not normaldeployments. Eachdiagnostic addsoneharnesssource, preservingall71priorcompilerstrings andcreation/runtimeobjects. Checkactualsource/bytecode equality; do not infer deployed safety orrealcash fromfixtureeffects. Rootverifierschecked streams, vectors and an alteredexpectedpayout negative; do notattribute those rootcommands to you. You may use your own read-onlyPython audit probes with rawcommand receipts. No needrerun unchangedEVM cases to judge honestlylimitedexisting evidence, but inspectactualharness paths andinputs, notjustroot summaries.\n\nVerdict is scoped to source/compiler/diagnostic preparation. P28tasks29.1 source-faithful AGY observation/assumption contract withindependentreview,29.2 ConditionalClaims/authorizedlifecycleproofs(P07dependencyifClaimsused),29.3 successfuldischarge/missing-attestation/unauthorized-discharge mutant/source-independentdisappearance negative allremainOPEN. No fullP28acceptance from sourcehashes/compile/mocks. Identify concrete missing boundaries or incorrectclaims. Preserve root diagnostic vs AGYimplementation vs your audit vs Leanproof distinctions.\n\n30turn cap. Begin bounded source and artifact checks early; create all5reportsEARLY and finalize byturn24 with6turn reserve. REVIEW.md,verdict.json,findings.json,commands.json,self-excludingMANIFEST.json. Each actual probe:argv,cwd,start/end,exit,script/tool/source/rawhashes; preserve failures. Manifestafterlastrecordedcommand includesall immutable reports/probes/rawstreams andexcludesgrowingnative. Actualreturnedmodelunknownuntilterminaltelemetry. Stop newinvestigationnearcap, reportunresolvedquestions honestly, collectchildren. Rootverifiesadjudicatespublishes; fullauthorizedcore remainsactive.'
    (OUT / 'brief.txt').write_text(brief)
    started = now()
    argv = ['grok', '-p', brief, '--model', 'grok-4.6', '--reasoning-effort', 'high',
            '--no-subagents', '--disable-web-search', '--permission-mode', 'bypassPermissions',
            '--output-format', 'streaming-json', '--max-turns', '30']
    with (OUT / 'native.jsonl').open('x') as stdout, (OUT / 'native.stderr').open('x') as stderr:
        process = subprocess.Popen(argv, cwd=SANDBOX, stdout=stdout, stderr=stderr)
        dispatch = {'schema': 'defiformal-native-dispatch/v3', 'started_utc': started,
                    'pid': process.pid, 'requested_model': 'grok-4.6', 'effort': 'high',
                    'fresh_session': True, 'sandbox': str(SANDBOX),
                    'brief_sha256': sha(OUT / 'brief.txt'), 'scope': 'P28 frozen Etherisc source/compiler and bounded ABI/lifecycle evidence audit',
                    'status': 'running', 'acceptance': False}
        write(OUT / 'dispatch.json', dispatch)
        print(json.dumps(dispatch), flush=True)
        code = process.wait()
    models, sessions, terminal = set(), set(), []
    for line in (OUT / 'native.jsonl').read_text().splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        models.update(event.get('modelUsage', {}))
        if event.get('model'):
            models.add(event['model'])
        for key in ['sessionId', 'session_id']:
            if event.get(key):
                sessions.add(event[key])
        if event.get('type') in ['end', 'error', 'result']:
            terminal.append(event)
    result = {'started_utc': started, 'finished_utc': now(), 'process_exit': code,
              'reported_models': sorted(models), 'sessions': sorted(sessions),
              'log_sha256': sha(OUT / 'native.jsonl'), 'terminal_events': terminal,
              'acceptance': False}
    write(OUT / 'process.json', result)
    print(json.dumps({k: v for k, v in result.items() if k != 'terminal_events'}), flush=True)


if __name__ == '__main__':
    main()
