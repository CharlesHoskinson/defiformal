"""Offline setup for the pinned DeFiFormal dependency closure."""
import hashlib
import json
import os
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent
VERSIONS = {
    'lean': '4.33.0-rc2',
    'defiformal': '2b60322cdc8c98f0e0c27cab3b2d6dcc824c3eda',
    'mathlib': '51e6992efd06126df61a496bebf8f49482a4e129',
}
ARCHIVES = {
    'lean-toolchain.tar.zst': '136b2710bc6bbcd02a13701176873e0ae6021c41f1ab6daf0db9376ff27f7a1f',
    'upstream-cache.tar.gz': 'c9ae6053aa68bbcc438cc4b4e5a423379e22e46357157161416a33a14396332e',
}


def root():
    for candidate in (HERE, *HERE.parents):
        if (candidate / 'workspace.json').is_file():
            return candidate
    raise RuntimeError('Cannot locate evaluation workspace')


def runtime():
    inputs = os.environ.get('ONBOARDING_RECONSTRUCTION_INPUTS')
    if inputs:
        return Path(inputs).parent / 'defiformal-environment'
    return root() / 'results/onboarding/request-c19aa3d881e14b41'


def digest(path):
    with Path(path).open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def lean():
    return runtime() / 'lean-4.33.0-rc2-darwin_aarch64/bin/lean'


def environment(extra=None):
    upstream = runtime() / 'upstream/lean'
    paths = [upstream / '.lake/build/lib/lean']
    paths += sorted((upstream / '.lake/packages').glob('*/.lake/build/lib/lean'))
    if extra is not None:
        paths.insert(0, Path(extra))
    env = os.environ.copy()
    env['LEAN_PATH'] = os.pathsep.join(map(str, paths))
    env['PATH'] = str(lean().parent) + os.pathsep + env.get('PATH', '')
    return env


def install():
    base = runtime()
    stamp = base / 'offline-setup-lock.json'
    expected = {'versions': VERSIONS, 'archives': ARCHIVES}
    if stamp.exists():
        if json.loads(stamp.read_text()) != expected:
            raise RuntimeError('Offline runtime lock mismatch')
    else:
        base.mkdir(parents=True, exist_ok=True)
        inputs = os.environ.get('ONBOARDING_RECONSTRUCTION_INPUTS')
        source = Path(inputs) if inputs else root() / 'archives/toolchains/defiformal-2b60322'
        for name, sha in ARCHIVES.items():
            archive = source / name
            if digest(archive) != sha:
                raise RuntimeError('Dependency checksum mismatch: ' + name)
            command = ['tar', '--zstd', '-xf'] if name.endswith('.zst') else ['tar', '-xzf']
            subprocess.run(command + [str(archive), '-C', str(base)],
                           capture_output=True, check=True, timeout=540)
        stamp.write_text(json.dumps(expected, sort_keys=True) + '\n')
    version = subprocess.check_output([str(lean()), '--version'], text=True).strip()
    if 'version 4.33.0-rc2,' not in version:
        raise RuntimeError('Incorrect Lean release: ' + version)
    return version


if __name__ == '__main__':
    version = install()
    probe = runtime() / 'Readiness.lean'
    probe.write_text('import DefiKernel.Arithmetic.Rounding\n'
                     'import DefiKernel.Arithmetic.Operations\n'
                     'import DefiKernel.Examples\n'
                     '#check DefiKernel.Arithmetic.Operations.add_ok_iff\n'
                     '#check DefiKernel.Arithmetic.Rounding.divideNat_down_ok_iff\n')
    run = subprocess.run([str(lean()), '-j1', str(probe)], env=environment(),
                         capture_output=True, text=True, timeout=120)
    if run.returncode:
        raise RuntimeError(run.stdout + run.stderr)
    print(json.dumps({'status': 'ready', 'versions': VERSIONS, 'version_output': version,
                      'probe_output': run.stdout,
                      'boundary': 'Pinned official Lean binary and mathlib compiled cache; native DeFiFormal modules built locally. Fresh extracted source/cache for reconstruction; host OS shared.'}))
