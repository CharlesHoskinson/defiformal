#!/usr/bin/env python3
"""Fail-closed P19 certificate host validator.

Binds host inventory JSON to:
  1. TrustedHost constants evaluated by the absolute pinned Lean executable
     under `lake env` (HostIdentityExport.lean --run)
  2. the imported TrustedHost.olean on LEAN_PATH (not source-hash claims)
  3. actual source-file bytes on disk
  4. reviewed source identity of TrustedHost.lean and of the export itself
  5. pinned Lean/Lake executable digests

Host JSON is not ground truth. A replaced .olean or a fake
`.lake/build/bin/lean` is not a binding. No PATH fallback. Export failure
or malformed stdout fails closed.

CLI:
  python3 scripts/verify_certificate_host.py
  python3 scripts/verify_certificate_host.py --repo ROOT --host-records PATH
"""
from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import sys
from pathlib import Path

TRUSTED_HOST_LEAN = "lean/DefiKernel/Certificates/TrustedHost.lean"
IDENTITY_EXPORT_REL = "lean/DefiKernel/Certificates/HostIdentityExport.lean"
DEFAULT_HOST_RECORDS = "lean/DefiKernel/Certificates/trusted-host-records.json"
GRAMMAR_REL = "openspec/changes/serialized-kernel-certificates/grammar.json"
SCHEMA_REL = "openspec/changes/serialized-kernel-certificates/schema.json"
ARITHMETIC_REL = "lean/DefiKernel/Arithmetic/Operations.lean"
KIND = "certificates-trusted-host-records/v1"
IDENTITY_MARKER = "DEFIFORMAL_HOST_IDENTITY_V1"
PINNED_TRUSTED_HOST_SHA256 = "d2227d592f22878e1ab4a6b58b1dfadcbe35bcd346464756f2eb721f0d7f501d"
PINNED_IDENTITY_EXPORT_SHA256 = "acf4af5867bb3889622a246af161dcdf2c9fa7d4a5ee732129c7d41130c09c88"
PINNED_TRUSTED_HOST_OLEAN_SHA256 = "27b0f65e94341cff5556b20eea38189e9d98f460a3cc04fd643059694a90e7b6"
PINNED_TOOLCHAIN = Path.home() / ".elan/toolchains/leanprover--lean4---v4.33.0-rc2"
PINNED_LEAN = PINNED_TOOLCHAIN / "bin/lean"
PINNED_LAKE = PINNED_TOOLCHAIN / "bin/lake"
PINNED_LEAN_SHA256 = "e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550"
PINNED_LAKE_SHA256 = "60330ab6f07dce20f3fa9ebb08e8b984ea9549eac172afeb15d9d2227060e2b3"
PINNED_LEAN_VERSION_MARK = "4.33.0-rc2"
PRINTENV = Path("/usr/bin/printenv")
CANONICAL_OLEAN_REL = "lean/.lake/build/lib/lean/DefiKernel/Certificates/TrustedHost.olean"


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    if not path.is_file():
        return ""
    return sha256_bytes(path.read_bytes())


def fail(message: str) -> None:
    raise SystemExit(f"ERROR: {message}")


def require_pinned_tools() -> dict:
    if not PINNED_LEAN.is_file():
        fail(f"pinned Lean executable missing: {PINNED_LEAN}")
    if not PINNED_LAKE.is_file():
        fail(f"pinned Lake executable missing: {PINNED_LAKE}")
    lean_sha = sha256_file(PINNED_LEAN)
    lake_sha = sha256_file(PINNED_LAKE)
    if lean_sha != PINNED_LEAN_SHA256:
        fail(f"pinned Lean executable digest mismatch: {lean_sha} != {PINNED_LEAN_SHA256}")
    if lake_sha != PINNED_LAKE_SHA256:
        fail(f"pinned Lake executable digest mismatch: {lake_sha} != {PINNED_LAKE_SHA256}")
    try:
        ver_proc = subprocess.run(
            [str(PINNED_LEAN), "--version"],
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
        )
    except OSError as exc:
        fail(f"pinned Lean --version could not start: {exc}")
    version = (ver_proc.stdout or "").strip()
    if ver_proc.returncode != 0 or PINNED_LEAN_VERSION_MARK not in version:
        fail(f"pinned Lean version mismatch: {version!r}")
    if not PRINTENV.is_file():
        fail(f"printenv missing: {PRINTENV}")
    return {
        "lean": str(PINNED_LEAN),
        "lake": str(PINNED_LAKE),
        "lean_sha256": lean_sha,
        "lake_sha256": lake_sha,
        "lean_version": version,
    }


def lake_env_run(lean_dir: Path, argv: list[str], timeout: int = 180) -> subprocess.CompletedProcess[str]:
    if not argv or not Path(argv[0]).is_absolute():
        fail("lake env command must be an absolute executable path")
    try:
        return subprocess.run(
            [str(PINNED_LAKE), "env", *argv],
            cwd=lean_dir,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
    except subprocess.TimeoutExpired:
        fail("lake env command timed out")
    except OSError as exc:
        fail(f"lake env command could not start: {exc}")


def imported_trusted_host_artifacts(lean_dir: Path) -> list[Path]:
    proc = lake_env_run(lean_dir, [str(PRINTENV), "LEAN_PATH"], timeout=30)
    if proc.returncode != 0:
        err = (proc.stderr or "").strip().replace("\n", " ")[:400]
        fail(f"could not read LEAN_PATH: exit={proc.returncode} stderr={err!r}")
    lean_path = (proc.stdout or "").strip()
    if not lean_path:
        fail("LEAN_PATH is empty")
    found: list[Path] = []
    seen: set[Path] = set()
    for entry in lean_path.split(":"):
        if not entry:
            continue
        for suffix in (".olean", ".ir"):
            art = Path(entry) / f"DefiKernel/Certificates/TrustedHost{suffix}"
            if art.is_file():
                resolved = art.resolve()
                if resolved not in seen:
                    seen.add(resolved)
                    found.append(resolved)
    return found


def bind_imported_trusted_host_olean(repo_root: Path, lean_dir: Path) -> dict:
    canonical = repo_root / CANONICAL_OLEAN_REL
    if not canonical.is_file():
        fail(f"imported TrustedHost.olean missing: {CANONICAL_OLEAN_REL}")
    canonical_sha = sha256_file(canonical)
    if canonical_sha != PINNED_TRUSTED_HOST_OLEAN_SHA256:
        fail(
            "imported TrustedHost.olean digest mismatch: "
            f"{canonical_sha} != {PINNED_TRUSTED_HOST_OLEAN_SHA256}"
        )
    imported = imported_trusted_host_artifacts(lean_dir)
    if not imported:
        fail("LEAN_PATH contains no TrustedHost.olean/.ir artifact")
    mismatches = []
    resolved_canonical = canonical.resolve()
    saw_canonical = False
    for art in imported:
        if art.suffix == ".ir":
            fail(f"unexpected TrustedHost.ir on LEAN_PATH: {art}")
        digest = sha256_file(art)
        if art.suffix == ".olean" and digest != PINNED_TRUSTED_HOST_OLEAN_SHA256:
            mismatches.append({"path": str(art), "sha256": digest})
        if art == resolved_canonical:
            saw_canonical = True
    if mismatches:
        fail("LEAN_PATH TrustedHost artifact digest mismatch: " + json.dumps(mismatches))
    if not saw_canonical:
        fail("canonical TrustedHost.olean is not on LEAN_PATH")
    return {
        "trusted_host_olean": str(canonical.relative_to(repo_root)),
        "trusted_host_olean_sha256": canonical_sha,
        "imported_artifacts": [str(p) for p in imported],
    }


def parse_identity_stdout(stdout: str) -> dict:
    if not isinstance(stdout, str) or not stdout.strip():
        fail("identity export produced empty stdout")
    text = stdout.replace("\r\n", "\n").strip()
    lines = text.split("\n")
    if len(lines) != 2 or lines[0] != IDENTITY_MARKER:
        fail("identity export stdout is not exactly marker+JSON")
    try:
        obj = json.loads(lines[1])
    except Exception as exc:
        fail(f"identity export JSON malformed: {exc}")
    if not isinstance(obj, dict):
        fail("identity export JSON is not an object")
    required = [
        "git",
        "lean_toolchain",
        "mathlib_rev",
        "grammar_sha256",
        "schema_sha256",
        "arithmetic_token",
        "trusted_host_source_sha256",
        "dependencies",
    ]
    missing = [k for k in required if k not in obj]
    if missing:
        fail("identity export missing fields: " + json.dumps(missing))
    deps = obj["dependencies"]
    if not isinstance(deps, dict) or not deps:
        fail("identity export dependencies missing or empty")
    for key, value in deps.items():
        if not isinstance(key, str) or not isinstance(value, str):
            fail("identity export dependencies are not string:string")
    token = obj["arithmetic_token"]
    if not isinstance(token, str):
        fail("identity export arithmetic_token is not a string")
    token_parts = token.split(":")
    if len(token_parts) < 3:
        fail("identity export arithmetic_token is malformed")
    arith_path = token_parts[0]
    arith_sha = token_parts[1]
    arith_theorem = ":".join(token_parts[2:])
    if arith_path != ARITHMETIC_REL:
        fail(f"compiled arithmetic path {arith_path!r} != {ARITHMETIC_REL!r}")
    if len(arith_sha) != 64 or any(c not in "0123456789abcdef" for c in arith_sha):
        fail("compiled arithmetic sha256 is not a lowercase hex digest")
    if not arith_theorem:
        fail("compiled arithmetic theorem name is empty")
    for field in required:
        if field == "dependencies":
            continue
        if not isinstance(obj[field], str) or not obj[field]:
            fail(f"identity export field {field} is empty")
    git = obj["git"]
    if git in deps.values():
        fail("compiled gitSha must not appear as a path+sha256 dependency digest")
    return {
        "git": git,
        "lean_toolchain": obj["lean_toolchain"],
        "mathlib_rev": obj["mathlib_rev"],
        "grammar_sha256": obj["grammar_sha256"],
        "schema_sha256": obj["schema_sha256"],
        "dependencies": deps,
        "arithmetic_path": arith_path,
        "arithmetic_sha256": arith_sha,
        "arithmetic_theorem": arith_theorem,
        "arithmetic_token": token,
        "trusted_host_source_sha256": obj["trusted_host_source_sha256"],
    }


def evaluate_host_identity(repo_root: Path) -> dict:
    tools = require_pinned_tools()
    export_path = repo_root / IDENTITY_EXPORT_REL
    if not export_path.is_file():
        fail(f"identity export missing: {IDENTITY_EXPORT_REL}")
    export_sha = sha256_file(export_path)
    if export_sha != PINNED_IDENTITY_EXPORT_SHA256:
        fail(
            "identity export source drift from pinned identity: "
            f"{export_sha} != {PINNED_IDENTITY_EXPORT_SHA256}"
        )
    lean_src = repo_root / TRUSTED_HOST_LEAN
    if not lean_src.is_file():
        fail(f"compiled identity source missing: {TRUSTED_HOST_LEAN}")
    trusted_sha = sha256_file(lean_src)
    if trusted_sha != PINNED_TRUSTED_HOST_SHA256:
        fail(
            "TrustedHost.lean source drift from reviewed identity: "
            f"{trusted_sha} != {PINNED_TRUSTED_HOST_SHA256}"
        )
    lean_dir = repo_root / "lean"
    if not (lean_dir / "lakefile.toml").is_file():
        fail("lean/lakefile.toml missing")
    artifacts = bind_imported_trusted_host_olean(repo_root, lean_dir)
    proc = lake_env_run(
        lean_dir,
        [tools["lean"], "--run", "DefiKernel/Certificates/HostIdentityExport.lean"],
        timeout=180,
    )
    if proc.returncode != 0:
        err = (proc.stderr or "").strip().replace("\n", " ")[:500]
        fail(f"identity export lean failed: exit={proc.returncode} stderr={err!r}")
    compiled = parse_identity_stdout(proc.stdout)
    if compiled["trusted_host_source_sha256"] != PINNED_TRUSTED_HOST_SHA256:
        fail(
            "identity export reviewed TrustedHost hash does not match pin: "
            f"{compiled['trusted_host_source_sha256']!r} != {PINNED_TRUSTED_HOST_SHA256!r}"
        )
    if trusted_sha != compiled["trusted_host_source_sha256"]:
        fail(
            "TrustedHost.lean bytes do not match identity-export reviewed hash: "
            f"{trusted_sha} != {compiled['trusted_host_source_sha256']}"
        )
    compiled["trusted_host_lean_sha256"] = trusted_sha
    compiled["identity_export_sha256"] = export_sha
    compiled["trusted_host_olean"] = artifacts["trusted_host_olean"]
    compiled["trusted_host_olean_sha256"] = artifacts["trusted_host_olean_sha256"]
    compiled["imported_artifacts"] = artifacts["imported_artifacts"]
    compiled["lean_executable"] = tools["lean"]
    compiled["lake_executable"] = tools["lake"]
    compiled["lean_executable_sha256"] = tools["lean_sha256"]
    compiled["lake_executable_sha256"] = tools["lake_sha256"]
    compiled["lean_version"] = tools["lean_version"]
    return compiled


def _resolve_host_path(repo_root: Path, host_rel: str) -> Path:
    if not host_rel:
        fail("trusted host records path missing")
    candidate = Path(host_rel)
    return candidate if candidate.is_absolute() else (repo_root / candidate)


def verify_trusted_host(repo_root: Path, host_rel: str) -> dict:
    """Verify host inventory against evaluated TrustedHost constants and source bytes."""
    repo_root = Path(repo_root)
    compiled = evaluate_host_identity(repo_root)

    grammar_path = repo_root / GRAMMAR_REL
    schema_path = repo_root / SCHEMA_REL
    if not grammar_path.is_file():
        fail(f"grammar.json missing: {GRAMMAR_REL}")
    if not schema_path.is_file():
        fail(f"schema.json missing: {SCHEMA_REL}")
    grammar_actual = sha256_file(grammar_path)
    schema_actual = sha256_file(schema_path)
    if grammar_actual != compiled["grammar_sha256"]:
        fail(
            "grammar.json bytes do not match compiled TrustedHost.grammarSha256: "
            f"{grammar_actual} != {compiled['grammar_sha256']}"
        )
    if schema_actual != compiled["schema_sha256"]:
        fail(
            "schema.json bytes do not match compiled TrustedHost.schemaSha256: "
            f"{schema_actual} != {compiled['schema_sha256']}"
        )

    host_path = _resolve_host_path(repo_root, host_rel)
    if not host_path.is_file():
        fail(f"trusted host records file missing: {host_rel}")
    try:
        host = json.loads(host_path.read_text(encoding="utf-8"))
    except Exception as exc:
        fail(f"trusted host records malformed JSON: {exc}")
    if not isinstance(host, dict) or host.get("kind") != KIND:
        fail("trusted host records schema/kind mismatch")

    for field in ("git", "lean_toolchain", "mathlib_rev", "grammar_sha256", "schema_sha256"):
        if host.get(field) != compiled[field]:
            fail(
                f"host JSON {field} does not match compiled TrustedHost constant: "
                f"{host.get(field)!r} != {compiled[field]!r}"
            )

    deps = host.get("dependencies")
    if not isinstance(deps, dict) or not deps:
        fail("trusted host dependencies missing or empty")
    compiled_deps = compiled["dependencies"]
    missing = sorted(p for p in compiled_deps if p not in deps)
    extra = sorted(p for p in deps if p not in compiled_deps)
    if missing:
        fail("trusted host required inventory missing: " + json.dumps(missing))
    if extra:
        fail("trusted host inventory has undeclared paths: " + json.dumps(extra))
    mismatches = []
    for rel, expected_sha in compiled_deps.items():
        if deps.get(rel) != expected_sha:
            mismatches.append({"path": rel, "host": deps.get(rel), "compiled": expected_sha})
        actual = sha256_file(repo_root / rel)
        if actual != expected_sha:
            mismatches.append({"path": rel, "compiled": expected_sha, "actual": actual})
    if mismatches:
        fail("trusted host dependency mismatch: " + json.dumps(mismatches))

    lib = host.get("library_compiler_records")
    if not isinstance(lib, dict) or not lib:
        fail("trusted host library_compiler_records missing or empty")
    ops = lib.get(compiled["arithmetic_path"])
    if not isinstance(ops, dict):
        fail("trusted host arithmetic library record missing")
    if ops.get("sha256") != compiled["arithmetic_sha256"]:
        fail(
            "library record sha256 does not match compiled arithmeticAddCompilerRecord: "
            f"{ops.get('sha256')!r} != {compiled['arithmetic_sha256']!r}"
        )
    if ops.get("theorem") != compiled["arithmetic_theorem"]:
        fail(
            "library record theorem does not match compiled arithmeticAddCompilerRecord: "
            f"{ops.get('theorem')!r} != {compiled['arithmetic_theorem']!r}"
        )
    if ops.get("token") != compiled["arithmetic_token"]:
        fail(
            "library record token does not match compiled arithmeticAddCompilerRecord: "
            f"{ops.get('token')!r} != {compiled['arithmetic_token']!r}"
        )
    if any(key != compiled["arithmetic_path"] for key in lib):
        fail("library_compiler_records contains undeclared entries: " + json.dumps(sorted(lib)))
    ops_actual = sha256_file(repo_root / compiled["arithmetic_path"])
    if ops_actual != compiled["arithmetic_sha256"]:
        fail(
            "Arithmetic/Operations.lean bytes do not match compiled arithmetic record: "
            f"{ops_actual} != {compiled['arithmetic_sha256']}"
        )

    toolchain_path = repo_root / "lean/lean-toolchain"
    if not toolchain_path.is_file():
        fail("lean-toolchain file missing")
    toolchain_text = toolchain_path.read_text(encoding="utf-8").strip()
    if toolchain_text != compiled["lean_toolchain"]:
        fail(
            "lean-toolchain file does not match compiled TrustedHost.leanToolchain: "
            f"{toolchain_text!r} != {compiled['lean_toolchain']!r}"
        )

    git_in_tokens = any(
        compiled["git"] in str(digest) and not rel.endswith("lean-toolchain")
        for rel, digest in compiled_deps.items()
    )
    try:
        host_display = str(host_path.relative_to(repo_root))
    except ValueError:
        host_display = str(host_path)
    return {
        "grammar_sha256": compiled["grammar_sha256"],
        "schema_sha256": compiled["schema_sha256"],
        "host_records": host_display,
        "trusted_host_lean": TRUSTED_HOST_LEAN,
        "trusted_host_lean_sha256": compiled["trusted_host_lean_sha256"],
        "identity_export": IDENTITY_EXPORT_REL,
        "identity_export_sha256": compiled["identity_export_sha256"],
        "trusted_host_olean": compiled["trusted_host_olean"],
        "trusted_host_olean_sha256": compiled["trusted_host_olean_sha256"],
        "lean_executable": compiled["lean_executable"],
        "lake_executable": compiled["lake_executable"],
        "lean_executable_sha256": compiled["lean_executable_sha256"],
        "lake_executable_sha256": compiled["lake_executable_sha256"],
        "lean_version": compiled["lean_version"],
        "dependency_count": len(compiled_deps),
        "library_compiler_records": 1,
        "arithmetic_token": compiled["arithmetic_token"],
        "compiled_toolchain": compiled["lean_toolchain"],
        "compiled_git": compiled["git"],
        "compiled_mathlib": compiled["mathlib_rev"],
        "git_distinct_from_path_tokens": not git_in_tokens,
        "trusted_git": compiled["git"],
        "required_inventory": sorted(compiled_deps),
        "binding": "absolute-pinned-lean+imported-olean+source-bytes",
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Verify certificate trusted-host inventory against evaluated Lean identity and source bytes"
    )
    parser.add_argument("--repo", default="", help="Repository root (default: parent of scripts/)")
    parser.add_argument(
        "--host-records",
        default=DEFAULT_HOST_RECORDS,
        help=f"Host records JSON relative to repo or absolute (default: {DEFAULT_HOST_RECORDS})",
    )
    args = parser.parse_args(argv)
    repo = Path(args.repo).resolve() if args.repo else Path(__file__).resolve().parent.parent
    result = verify_trusted_host(repo, args.host_records)
    json.dump(result, sys.stdout, indent=2, sort_keys=True)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
