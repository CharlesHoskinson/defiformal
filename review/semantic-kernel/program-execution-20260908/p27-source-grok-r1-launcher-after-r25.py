"""Prepared source audit. Launch only after the P19 R25 audit is sealed and the slot is free."""
from pathlib import Path
import datetime
import hashlib
import json
import shutil
import subprocess

ROOT = Path('/home/charl/defiformal')
BASE = ROOT / 'review/semantic-kernel/program-execution-20260908'
OUT = BASE / 'p27-source-grok-r1'
SANDBOX = Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p27-source-grok-r1-sandbox')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read(path):
    return json.loads(path.read_text())


def write(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def main():
    previous = BASE / 'p19-typed-payload-grok-r1'
    if not (previous / 'root-seal.json').exists():
        raise SystemExit('P19 R25 independent review must be complete and root-sealed first.')
    dispatch = read(previous / 'dispatch.json')
    if Path('/proc', str(dispatch['pid'])).exists():
        raise SystemExit('Prior reviewer still present; do not occupy a second audit slot.')
    if (BASE / 'p19-roundtrip-proof-agy-r26-process.json').exists():
        raise SystemExit('R26 is terminal: assess and prioritize its proof audit before this source audit.')
    author = read(BASE / 'p19-roundtrip-proof-agy-r26-dispatch.json')
    if not Path('/proc', str(author['pid'])).exists():
        raise SystemExit('R26 author is no longer live; prioritize its freeze and proof review.')
    OUT.mkdir(exist_ok=False)
    SANDBOX.mkdir(exist_ok=False)
    for name in ['p27-gmx-source-preparation','p27-gmx-source-preparation-attempt2','p27-gmx-root-verification','p27-gmx-dependency-preparation','p27-gmx-dependency-root-verification','p27-gmx-compiler-preparation','p27-gmx-compiler-baseline','p27-gmx-compiler-root-verification']:
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
    brief = f"Fresh native Grok4.6 high independent audit of P27 GMX source/dependency/compiler preparation. Frozen sandbox {SANDBOX}; write only {OUT}. AGY implements P19 separately; no authorworktree, live drafts/caches, subagents, network, Foreman, windows, branches, commits or pushes. Current AGY author/Grok reviewer routing supersedes older AGENTS roles.\n\nOfficial gmx-io/gmx-synthetics pin a85ea3491c19c93bb4b5a002d9b358fb769b7849, tree0cc923c20087fdfab3659d672af6ce8a02665b19. Observed mainHEAD, not deployed chain identity. Failed initial100MiB archive capture preserved: partial bytes not supplied and not a complete archive/extraction. Successful raw attempt2 packet seals188files:89captured files=78Solidity+3unexecutedTS+8configs/docs,16staticanchors. Verify HTTP/sourceGitblob/commit/tree bindings against actual sources, no invented runtime credit. Source213locallexicaledges+22externaloccurrences; deps close to91sources/243lexicaledges,0unresolved. Lexical graph is not a full runtime or AST proof.\n\nDependencies are exact yarn.lock OpenZeppelin4.9.3 and prb-math2.4.3 npm archives included in packet. SHA512/SHA1lockbindings verified previously. Archives374+34members, selected11OZ+2PRB sources. Check package/source/lockidentities and complete selected import closure; no install/package script execution. Earlier rootfiles sometimes reference absolute historic paths; map to sandbox, never follow live caches. Own read-only Python hash/source probes allowed.\n\nCompiler packet is actual solc0.8.29+ab55807c SHA18d418a40dc04d17656b1b5c8a7b35cfbab8942b51f38d005d5b59e8aa6637e0, optimizer10constantOptimizertrue, metadata defaultCancun. Original standardJSON input/output compressed in packet.91sources91contracts72nonemptycreationobjects,0error0warning. TENcreationobjects contain unresolved library links, not deployable ready bytecode. FullHardhat/EVM/tests notrun. Verify all source/compilerinput/rawcommand/outputbindings and metadata/settings; rebuilding is not required to judge statedsourcepacket. No needdownload/compilerexec. Rootcompiler evidence is not your execution or proof.\n\nInspect funding/equity/position/liquidation source faithfully. Distinguish collateral,cash, signed PnL, liquidation equity and borrowing/positionfees. Some collateral-sufficiency checks deductnegativePnL withoutcreditingpositivePnL; liquidationhealth includesPnL. Fundingunsignedfees and separatelong/shortclaimables have directionalrounding and are keyed bymarket/token/account. Inspect source to identify actual rejectionguards and source conditions; do not invent arefusal or equate unsettledPnLwithcash. Allowed liquidation/bankruptcy is successful exceptional behavior, not executorrefusal. Fullcloseinsolvency is special toliquidation/secondaryADL; ordinaryunpaidcost paths may revert. Shortfall events do not automatically imply insurance coversresidual. Secondaryintegerdivision residuals/rounding must be explicit, not silentlyexactrationaldebt. Oracle, custody, callerrole, holdingaddress and finality assumptions remain explicit.\n\nScope verdict usable/changes-required only for sourcepreparation. Task28.1 needs AGY's frozen signedfunding/equity observations and actual selectedsource rejectiongate with independent review.28.2 Lean Margin implementation/signedreconciliation/explicitbankruptcyresidual and28.3 funding/liquidationexception/actualrefusal/PnLascashmutant/source-independentequitynegative remainOPEN. No narrowedsubstitute fullP27acceptance from compile/sourcehashes.\n\n30turn cap. Create all5reportsEARLY, finalize byturn24 and reserve6turnscloseout. REVIEW.md,verdict.json,findings.json,commands.json,self-excludingMANIFEST.json. Record actual probe argv/cwd/start/end/exit/tool/script/source/rawhashes, failures retained. Manifest afterlastrecordedcommand; no stale commands hash. Bind all immutable reports/probes/rawstreams; exclude growingnative. Actualmodel unknown untilterminaltelemetry. Stop newinvestigation nearcap and finalize honestopenquestions. Collectchildren; rootverifiesadjudicatespublishes. Fullauthorizedcore remainsactive."
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
                    'brief_sha256': sha(OUT / 'brief.txt'), 'scope': 'P27 frozen GMX source/dependency/compiler preparation audit',
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
