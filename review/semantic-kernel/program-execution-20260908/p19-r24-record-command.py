"""Record real R24 compiler/probe results even when the native UI returns before completion."""
from pathlib import Path
import argparse
import datetime
import fcntl
import hashlib
import json
import os
import re
import signal
import subprocess

WORK = Path('/home/charl/defiformal-wt-p19-certificates-grok-opus-20260909')
EVIDENCE = WORK / 'review/semantic-kernel/certificates/p19/implementation/agy-r24-proof'
TOOL = Path('/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def write(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--id', required=True)
    parser.add_argument('--origin', choices=['native_author', 'root_preflight'], default='native_author')
    parser.add_argument('--cwd', default=str(WORK / 'lean'))
    parser.add_argument('--timeout', type=int, default=360)
    parser.add_argument('argv', nargs=argparse.REMAINDER)
    args = parser.parse_args()
    if not re.fullmatch(r'[a-zA-Z0-9_-]+', args.id):
        parser.error('id must contain only letters, numbers, underscores or hyphens')
    argv = args.argv[1:] if args.argv[:1] == ['--'] else args.argv
    if not argv or not 1 <= args.timeout <= 900:
        parser.error('supply a command and timeout from 1 through 900 seconds')
    cwd = Path(args.cwd).resolve()
    if not cwd.is_relative_to(WORK):
        parser.error('cwd must stay in the R24 author working copy')
    out = EVIDENCE / 'logs' / args.id
    out.mkdir(parents=True, exist_ok=False)
    sources = {str(p.relative_to(WORK)): sha(p)
               for p in (WORK / 'lean/DefiKernel/Certificates').rglob('*.lean')}
    assert sources
    probe_inputs = {str(Path(a).resolve()): sha(Path(a).resolve()) for a in argv
                    if a.endswith('.lean') and Path(a).is_file()}
    metadata = {'id': args.id, 'origin': args.origin, 'argv': argv, 'cwd': str(cwd), 'started_utc': now(),
                'source_sha256_before': sources, 'probe_inputs': probe_inputs,
                'lean_sha256': sha(TOOL / 'lean'), 'lake_sha256': sha(TOOL / 'lake'),
                'recorder_sha256': sha(Path(__file__).resolve()),
                'scope': 'Actual subprocess execution by the R24 recording wrapper.',
                'P19_accepted': False}
    write(out / 'started.json', metadata)
    timed_out = False
    launch_error = None
    with (out / 'stdout').open('xb') as stdout, (out / 'stderr').open('xb') as stderr:
        try:
            process = subprocess.Popen(argv, cwd=cwd, stdout=stdout, stderr=stderr,
                                       start_new_session=True)
            write(out / 'pid.json', {'pid': process.pid, 'observed_utc': now()})
            try:
                code = process.wait(timeout=args.timeout)
            except subprocess.TimeoutExpired:
                timed_out = True
                os.killpg(process.pid, signal.SIGTERM)
                try:
                    code = process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    os.killpg(process.pid, signal.SIGKILL)
                    code = process.wait()
        except OSError as error:
            code = None
            launch_error = repr(error)
    metadata.update({'finished_utc': now(), 'exit': code, 'timed_out': timed_out,
                     'launch_error': launch_error,
                     'stdout_path': str((out / 'stdout').relative_to(EVIDENCE)),
                     'stderr_path': str((out / 'stderr').relative_to(EVIDENCE)),
                     'stdout_sha256': sha(out / 'stdout'), 'stderr_sha256': sha(out / 'stderr'),
                     'source_sha256_after': {str(p.relative_to(WORK)): sha(p)
                         for p in (WORK / 'lean/DefiKernel/Certificates').rglob('*.lean')}})
    write(out / 'command.json', metadata)
    with (EVIDENCE / '.commands.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        commands = [json.loads(p.read_text()) for p in sorted((EVIDENCE / 'logs').glob('*/command.json'))]
        temporary = EVIDENCE / 'commands.json.tmp'
        write(temporary, commands)
        os.replace(temporary, EVIDENCE / 'commands.json')
    print(json.dumps({'id': args.id, 'exit': code, 'timed_out': timed_out,
                      'receipt': str(out / 'command.json'), 'launch_error': launch_error}), flush=True)
    print((out / 'stdout').read_text(errors='replace')[-14000:], end='', flush=True)
    print((out / 'stderr').read_text(errors='replace')[-4000:], end='', flush=True)
    raise SystemExit(3 if launch_error else (124 if timed_out else code))


if __name__ == '__main__':
    main()
