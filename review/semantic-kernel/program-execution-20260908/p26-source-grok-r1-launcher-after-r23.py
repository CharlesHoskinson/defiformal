"""Prepared source audit. Launch only after the P19 R23 audit is sealed and the slot is free."""
from pathlib import Path
import datetime
import hashlib
import json
import shutil
import subprocess

ROOT = Path('/home/charl/defiformal')
BASE = ROOT / 'review/semantic-kernel/program-execution-20260908'
OUT = BASE / 'p26-source-grok-r1'
SANDBOX = Path('/home/charl/.cache/defiformal-program/program-execution-20260908/p26-source-grok-r1-sandbox')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read(path):
    return json.loads(path.read_text())


def write(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def main():
    previous = BASE / 'p19-module-tree-grok-r1'
    if not (previous / 'root-seal.json').exists():
        raise SystemExit('P19 R23 independent review must be complete and root-sealed first.')
    dispatch = read(previous / 'dispatch.json')
    if Path('/proc', str(dispatch['pid'])).exists():
        raise SystemExit('Prior reviewer still present; do not occupy a second audit slot.')
    if (BASE / 'p19-roundtrip-proof-agy-r24-process.json').exists():
        raise SystemExit('R24 is terminal: assess and prioritize its proof audit before this source audit.')
    OUT.mkdir(exist_ok=False)
    SANDBOX.mkdir(exist_ok=False)
    for name in ['p26-ibc-source-preparation', 'p26-ibc-root-verification']:
        packet = BASE / name
        seal = read(packet / 'root-seal.json')
        assert len(seal['files']) == seal['file_count'] > 0
        for path, digest in seal['files'].items():
            assert sha(packet / path) == digest, path
        for path in list(seal['files']) + ['root-seal.json']:
            source = packet / path
            target = SANDBOX / source.relative_to(ROOT)
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
    for path in [
        'AGENTS.md',
        'openspec/changes/reusable-verification-platform-program/tasks.md',
        'openspec/changes/reusable-verification-platform-program/specs/source-bound-library-families/spec.md',
        'review/semantic-kernel/program-execution-20260908/PLAN-ACCEPTANCE.md',
    ]:
        target = SANDBOX / path
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(ROOT / path, target)
    archive = read(BASE / 'p26-ibc-source-preparation/archive-http.json')
    source = Path(archive['archive_cache_path'])
    assert sha(source) == archive['sha256']
    (SANDBOX / 'source-archives').mkdir()
    shutil.copy2(source, SANDBOX / 'source-archives/ibc-go.tar.gz')
    inputs = {str(p.relative_to(SANDBOX)): sha(p) for p in SANDBOX.rglob('*') if p.is_file()}
    write(OUT / 'inputs.json', {'utc': now(), 'sandbox': str(SANDBOX), 'files': inputs,
                              'file_count': len(inputs), 'acceptance': False})
    brief = f'''Fresh native Grok 4.6 high independent P26 source-preparation audit.
Read only frozen sandbox {SANDBOX}; write only {OUT}. AGY is implementing P19
separately. Do not inspect any author worktree, live review drafts, logs or caches.
No subagents, Foreman, network, extra windows, branches, commits or pushes.
Do not execute downloaded Go code, tests, Makefiles, module installs or capture
scripts. Your own bounded Python source/hash probes are allowed. Current AGY
implementation / Grok review routing supersedes historical AGENTS roles.

Audit the P26 IBC source candidate at commit
8a7d8134b7f7cedb3a2809ad3797717f38e44293, tree
d9c9af96ebb809bf6eab6bd6c93989ec86dc71a8. This is observed official main HEAD,
not a deployed chain identity. Root packet seals 44 files, including 33 selected
source/config/reference-test files and 15 static navigation anchors. Four Go test
files were retained without execution. Full archive has 1890 regular members;
only 33 selected Git blob identities are claimed checked. Original archive is
supplied at source-archives/ibc-go.tar.gz. Resolve historical absolute cache paths
against this sandbox; do not follow them to live locations. Verify commit/tree,
archive HTTP and selected source hashes/Git blobs, exact anchors, scope claims,
root verifier evidence and the altered-byte control. Root verification is source
identity evidence, not proof or runtime execution. No import closure is claimed.

Read the actual classic ICS-04 packet/timeout handlers, core message server,
ICS-20 transfer callbacks and selected Tendermint light-client code. Critical
observation: ordinary duplicate receipts / old ordered receive sequences return
ErrNoOpMsg internally and public MsgRecvPacketResponse Result NOOP with nil error.
The handler returns before the app callback. Ack and timeout have corresponding
NOOP paths. Other guards run first, so do not claim every malformed or expired
replay necessarily reaches NOOP. Packets below recvStartSequence return an actual
ErrPacketReceived; ordered future sequence is another actual refusal. P26's
required replay-refusal observation cannot be represented as an invented
transaction error for ordinary duplicates. Classify source suitability and any
needed explicit observation mapping separately from whole workflow acceptance.

Ack and timeout delete the source packet commitment; timeout verifies remote
non-receipt and maturity at proof height/time. ICS-20 successful ack does not
refund; error ack and timeout refund by unescrow or voucher remint depending on
asset origin. Refund can fail, including blocked sender. Core callbacks and SDK
cache/transaction commit boundaries must not be confused with synchronous rollback
of a remote chain. Do not claim unconditional compensation or refund success.

Verified client misbehaviour freezes Tendermint client state and returns success;
this does not automatically refund pending packets. Inspect verification-before-
freeze and identify missing assumptions/paths such as frozen-client recoveries.
The source declarations Go 1.26.5 / ibc-go v11 / SDK v0.55.0 / CometBFT v0.40.0
are not installed runtime identities. Oracle, custody, legal, sequencing, finality
and proof authenticity remain explicit future contract obligations. P26 must cover
all lifecycle/finality/replay/timeout/challenge/compensation requirements. P29's
complete cross-domain accounting is separate. No narrowed substitute acceptance.

Give a scoped usable/changes-required verdict on source preparation. Task 27.1
still needs AGY's concrete workflow and frozen observation/assumption contract and
independent review. Tasks 27.2/27.3 need actual Lean implementation/proofs, success,
refusal, double-terminal mutation and source-independent two-terminal negative.
Do not mark P26 or P29 accepted from this packet.

Maximum 20 turns. Reserve the last five turns for complete final reports. Create all five artifacts early, then finalize: REVIEW.md,
verdict.json, findings.json, commands.json and self-excluding MANIFEST.json.
Record every actual probe argv/cwd/start/end/exit and script/input/tool/raw stdout/
stderr identities. Preserve failed attempts; no invented past times or success
from exit code alone. Manifest must bind immutable evidence and exclude growing
native logs. Actual model stays unknown until terminal telemetry. Collect children
before ending. No need for a full Go build or more sources to judge the stated
bounded packet; identify missing runtime work without pretending it was performed.
'''
    (OUT / 'brief.txt').write_text(brief)
    started = now()
    argv = ['grok', '-p', brief, '--model', 'grok-4.6', '--reasoning-effort', 'high',
            '--no-subagents', '--disable-web-search', '--permission-mode', 'bypassPermissions',
            '--output-format', 'streaming-json', '--max-turns', '20']
    with (OUT / 'native.jsonl').open('x') as stdout, (OUT / 'native.stderr').open('x') as stderr:
        process = subprocess.Popen(argv, cwd=SANDBOX, stdout=stdout, stderr=stderr)
        dispatch = {'schema': 'defiformal-native-dispatch/v3', 'started_utc': started,
                    'pid': process.pid, 'requested_model': 'grok-4.6', 'effort': 'high',
                    'fresh_session': True, 'sandbox': str(SANDBOX),
                    'brief_sha256': sha(OUT / 'brief.txt'), 'scope': 'P26 frozen source preparation audit',
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
