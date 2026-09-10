#!/usr/bin/env python3
"""Independent P25 source/compiler-preparation audit probe.

Reads only the frozen sandbox. Writes only under the review directory.
Does not download, install, execute contracts, or rerun capture helpers.
"""
from __future__ import annotations

import base64
import gzip
import hashlib
import io
import json
import os
import re
import stat
import subprocess
import tarfile
import time
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

SANDBOX = Path(
    "/home/charl/.cache/defiformal-program/program-execution-20260908/p25-source-grok-r1-sandbox"
)
REVIEW = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p25-source-grok-r1"
)
SB_REV = SANDBOX / "review/semantic-kernel/program-execution-20260908"
SRC_PREP = SB_REV / "p25-balancer-source-preparation"
DEP_PREP = SB_REV / "p25-balancer-dependency-preparation"
COMP_PREP = SB_REV / "p25-balancer-compiler-preparation"
COMP_BASE = SB_REV / "p25-balancer-compiler-baseline"
TREE_FU = SB_REV / "p25-balancer-tree-identity-followup"
NAV = SB_REV / "p25-balancer-source-verification-attempt2"
FAIL = SB_REV / "p25-balancer-source-verification"
PROF = SB_REV / "p25-balancer-build-profile-followup"
DEP_VER = SB_REV / "p25-balancer-dependency-root-verification"

LOGS = REVIEW / "logs"
SOLC_REPRO = LOGS / "solc-repro"
COMMANDS: list[dict[str, Any]] = []
CHECKS: list[dict[str, Any]] = []


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def sha1_file(path: Path) -> str:
    h = hashlib.sha1()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def sha512_file(path: Path) -> bytes:
    h = hashlib.sha512()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.digest()


def git_blob_sha1(data: bytes) -> str:
    h = hashlib.sha1()
    h.update(f"blob {len(data)}\0".encode("ascii"))
    h.update(data)
    return h.hexdigest()


def record_check(name: str, ok: bool, **detail: Any) -> None:
    CHECKS.append({"name": name, "ok": bool(ok), **detail})


def run_cmd(
    argv: list[str],
    *,
    cwd: str,
    stdin: bytes | None = None,
    timeout: int = 120,
    stdout_path: Path | None = None,
    stderr_path: Path | None = None,
    id: str,
) -> dict[str, Any]:
    started = utc_now()
    t0 = time.time()
    try:
        proc = subprocess.run(
            argv,
            cwd=cwd,
            input=stdin,
            capture_output=True,
            timeout=timeout,
        )
        exit_code = proc.returncode
        timed_out = False
        out = proc.stdout
        err = proc.stderr
    except subprocess.TimeoutExpired as exc:
        exit_code = None
        timed_out = True
        out = exc.stdout or b""
        err = exc.stderr or b""
    finished = utc_now()
    rec: dict[str, Any] = {
        "id": id,
        "argv": argv,
        "cwd": cwd,
        "started_utc": started,
        "finished_utc": finished,
        "elapsed_s": round(time.time() - t0, 6),
        "exit": exit_code,
        "timed_out": timed_out,
        "stdout_sha256": sha256_bytes(out),
        "stderr_sha256": sha256_bytes(err),
        "stdout_bytes": len(out),
        "stderr_bytes": len(err),
        "stdin_sha256": None if stdin is None else sha256_bytes(stdin),
        "stdin_bytes": None if stdin is None else len(stdin),
    }
    if stdout_path is not None:
        stdout_path.write_bytes(out)
        rec["stdout_path"] = str(stdout_path.relative_to(REVIEW))
    if stderr_path is not None:
        stderr_path.write_bytes(err)
        rec["stderr_path"] = str(stderr_path.relative_to(REVIEW))
    COMMANDS.append(rec)
    return rec


def tar_path_issues(name: str) -> list[str]:
    issues = []
    if "\x00" in name:
        issues.append("nul")
    if name.startswith("/") or name.startswith("\\"):
        issues.append("absolute")
    n = name.replace("\\", "/")
    if n.startswith("/") or n.startswith("./"):
        # leading ./ is common and not an escape by itself
        pass
    parts = [p for p in n.split("/") if p not in ("", ".")]
    if any(p == ".." for p in parts):
        issues.append("dotdot")
    if n.startswith("../"):
        issues.append("dotdot-prefix")
    return issues


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def resolve_stored(stored_path: str) -> Path:
    """Map historical stored_path under defiformal/review to sandbox copy."""
    marker = "/review/semantic-kernel/program-execution-20260908/"
    if marker in stored_path:
        rel = stored_path.split(marker, 1)[1]
        return SB_REV / rel
    if stored_path.startswith("/home/charl/.cache/"):
        return Path(stored_path)
    return Path(stored_path)


IMPORT_RE = re.compile(
    r"""^\s*import\s+(?:\{[^}]*\}\s+from\s+)?["']([^"']+)["']\s*;""",
    re.MULTILINE,
)


def parse_imports(text: str) -> list[str]:
    return IMPORT_RE.findall(text)


def main() -> int:
    LOGS.mkdir(parents=True, exist_ok=True)
    SOLC_REPRO.mkdir(parents=True, exist_ok=True)
    (LOGS / "failed-attempts").mkdir(parents=True, exist_ok=True)

    inputs = load_json(REVIEW / "inputs.json")
    input_files: dict[str, str] = inputs["files"]
    hash_mismatches = []
    missing = []
    for rel, expected in input_files.items():
        path = SANDBOX / rel
        if not path.is_file():
            missing.append(rel)
            continue
        actual = sha256_file(path)
        if actual != expected:
            hash_mismatches.append({"path": rel, "expected": expected, "actual": actual})
    record_check(
        "inputs_json_sandbox_hashes",
        not missing and not hash_mismatches,
        file_count=len(input_files),
        missing=missing,
        mismatches=hash_mismatches,
    )

    manifest = load_json(SRC_PREP / "source-manifest.json")
    files = manifest["files"]
    roles = Counter(f["role"] for f in files)
    record_check(
        "source_manifest_file_counts",
        len(files) == 78 and roles.get("import_traversal_source", 0) == 68,
        total=len(files),
        roles=dict(roles),
        commit=manifest.get("commit"),
        selection=manifest.get("selection"),
        archive_regular_members=manifest.get("archive_regular_members"),
        test_import_closure_claimed=manifest.get("test_import_closure_claimed"),
        compiler_import_closure_claimed=manifest.get("compiler_import_closure_claimed"),
        acceptance=manifest.get("acceptance"),
    )
    record_check(
        "commit_is_observed_main_head_not_deployment",
        manifest.get("commit") == "449f7e074be4a92f9ed35ac8d201f45d4ac01f7e"
        and "not deployment" in str(manifest.get("selection", "")).lower(),
        commit=manifest.get("commit"),
        selection=manifest.get("selection"),
    )

    blob_mismatches = []
    size_mismatches = []
    for f in files:
        path = SRC_PREP / f["path"]
        data = path.read_bytes()
        if sha256_bytes(data) != f["sha256"]:
            blob_mismatches.append({"path": f["path"], "kind": "sha256"})
        if git_blob_sha1(data) != f["git_blob_sha1"]:
            blob_mismatches.append({"path": f["path"], "kind": "git_blob", "expected": f["git_blob_sha1"], "actual": git_blob_sha1(data)})
        if len(data) != f["bytes"]:
            size_mismatches.append({"path": f["path"], "expected": f["bytes"], "actual": len(data)})
    record_check(
        "captured_source_git_blobs",
        not blob_mismatches and not size_mismatches,
        checked=len(files),
        blob_mismatches=blob_mismatches,
        size_mismatches=size_mismatches,
    )

    local_edges = manifest.get("local_import_edges", [])
    unresolved_ext = manifest.get("unresolved_external_imports", [])
    record_check(
        "original_packet_import_graph",
        len(local_edges) == 210 and len(unresolved_ext) == 72,
        local_import_edges=len(local_edges),
        unresolved_external_imports=len(unresolved_ext),
    )

    # Independent lexical recount on captured Balancer .sol files.
    captured_sol = [f for f in files if f["path"].endswith(".sol")]
    local_recount = 0
    ext_recount = 0
    ext_specs: Counter[str] = Counter()
    for f in captured_sol:
        text = (SRC_PREP / f["path"]).read_text(encoding="utf-8")
        rel = f["upstream_path"]
        for spec in parse_imports(text):
            if spec.startswith("@openzeppelin/") or spec.startswith("permit2/"):
                ext_recount += 1
                ext_specs[spec] += 1
            elif spec.startswith("@balancer-labs/") or spec.startswith("./") or spec.startswith("../") or not spec.startswith("@"):
                local_recount += 1
            else:
                ext_recount += 1
                ext_specs[spec] += 1
    record_check(
        "independent_captured_sol_import_recount",
        local_recount == 210 and ext_recount == 72,
        captured_sol=len(captured_sol),
        local_recount=local_recount,
        ext_recount=ext_recount,
        ext_specifier_kinds=len(ext_specs),
        ext_specifiers=sorted(ext_specs),
    )

    failure = load_json(FAIL / "failure.json")
    record_check(
        "initial_tree_identity_failure_preserved_zero_credit",
        failure.get("exit") == 1 and failure.get("credit") is False,
        failure=failure,
    )

    commit = load_json(SRC_PREP / "discovery/commit.json")
    commit_sha = commit["sha"]
    commit_tree_sha = commit["commit"]["tree"]["sha"]
    orig_tree = load_json(SRC_PREP / "discovery/tree.json")
    fu_tree = load_json(TREE_FU / "tree.json")
    orig_http = load_json(SRC_PREP / "discovery/tree.json.http.json")
    fu_http = load_json(TREE_FU / "http.json")
    orig_entries = orig_tree.get("tree", [])
    fu_entries = fu_tree.get("tree", [])
    orig_paths = {(e.get("path"), e.get("sha"), e.get("mode"), e.get("type")) for e in orig_entries}
    fu_paths = {(e.get("path"), e.get("sha"), e.get("mode"), e.get("type")) for e in fu_entries}
    record_check(
        "original_tree_api_called_with_commit_sha_echoes_commit_sha",
        orig_http["url"].endswith(f"/git/trees/{commit_sha}?recursive=1")
        and orig_tree.get("sha") == commit_sha
        and orig_tree.get("sha") != commit_tree_sha,
        url=orig_http["url"],
        tree_json_sha_field=orig_tree.get("sha"),
        commit_sha=commit_sha,
        commit_tree_sha=commit_tree_sha,
        truncated=orig_tree.get("truncated"),
        entry_count=len(orig_entries),
    )
    record_check(
        "explicit_tree_followup_returns_commit_tree_sha",
        fu_http["url"].endswith(f"/git/trees/{commit_tree_sha}?recursive=1")
        and fu_tree.get("sha") == commit_tree_sha
        and len(fu_entries) == 1247
        and len(orig_entries) == 1247
        and orig_paths == fu_paths,
        url=fu_http["url"],
        followup_sha_field=fu_tree.get("sha"),
        orig_entries=len(orig_entries),
        followup_entries=len(fu_entries),
        entries_identical=orig_paths == fu_paths,
        truncated=fu_tree.get("truncated"),
    )
    record_check(
        "do_not_treat_failed_first_tree_check_as_success",
        failure.get("exit") == 1
        and orig_tree.get("sha") != commit_tree_sha
        and fu_tree.get("sha") == commit_tree_sha,
        first_attempt_exit=failure.get("exit"),
        first_sha_field=orig_tree.get("sha"),
        followup_sha_field=fu_tree.get("sha"),
    )

    # Git-bind captured files against followup tree blobs.
    blob_index = {e["path"]: e for e in fu_entries if e.get("type") == "blob"}
    git_tree_miss = []
    for f in files:
        up = f["upstream_path"]
        ent = blob_index.get(up)
        if ent is None:
            git_tree_miss.append({"path": up, "reason": "missing"})
        elif ent.get("sha") != f["git_blob_sha1"]:
            git_tree_miss.append({"path": up, "reason": "sha", "tree": ent.get("sha"), "file": f["git_blob_sha1"]})
    record_check(
        "captured_files_match_followup_git_tree_blobs",
        not git_tree_miss,
        misses=git_tree_miss,
        tree_blob_count=sum(1 for e in fu_entries if e.get("type") == "blob"),
        tree_tree_count=sum(1 for e in fu_entries if e.get("type") == "tree"),
    )

    # Balancer archive path safety and member identity.
    balancer_tar = SANDBOX / "source-archives/balancer.tar.gz"
    tar_issues: list[dict[str, Any]] = []
    member_names = []
    regular = 0
    with tarfile.open(balancer_tar, "r:gz") as tf:
        for m in tf.getmembers():
            member_names.append(m.name)
            issues = tar_path_issues(m.name)
            if m.issym() or m.islnk():
                issues.append("link:" + (m.linkname or ""))
                link_issues = tar_path_issues(m.linkname or "")
                issues.extend("link-" + x for x in link_issues)
            if issues:
                tar_issues.append({"name": m.name, "issues": issues, "type": m.type.decode("ascii") if isinstance(m.type, (bytes, bytearray)) else str(m.type)})
            if m.isfile():
                regular += 1
    # Map captured files into archive. GitHub tarball prefix is typically repo-commit/.
    prefixes = set()
    for n in member_names:
        if "/" in n:
            prefixes.add(n.split("/", 1)[0])
    archive_hit_miss = []
    with tarfile.open(balancer_tar, "r:gz") as tf:
        by_suffix = {}
        for m in tf.getmembers():
            if not m.isfile():
                continue
            # strip first path component
            rest = m.name.split("/", 1)[1] if "/" in m.name else m.name
            by_suffix[rest] = m
        for f in files:
            up = f["upstream_path"]
            m = by_suffix.get(up)
            if m is None:
                archive_hit_miss.append({"path": up, "reason": "missing"})
                continue
            extracted = tf.extractfile(m)
            assert extracted is not None
            data = extracted.read()
            if sha256_bytes(data) != f["sha256"] or git_blob_sha1(data) != f["git_blob_sha1"]:
                archive_hit_miss.append({"path": up, "reason": "hash"})
    record_check(
        "balancer_archive_path_safety_and_members",
        not tar_issues and not archive_hit_miss and regular == 1081,
        regular_members=regular,
        total_members=len(member_names),
        prefixes=sorted(prefixes),
        tar_issues=tar_issues[:20],
        archive_hit_miss=archive_hit_miss,
        archive_sha256=sha256_file(balancer_tar),
        expected_archive_sha256="a163dac24b7650d9ab131cc3bdb1d12cb6d76cc08b44ea443d19cf2f409ff1af",
    )

    # OpenZeppelin npm archive.
    identity = load_json(DEP_PREP / "identity.json")
    oz_archive = DEP_PREP / "openzeppelin/archive.tgz"
    oz_sha256 = sha256_file(oz_archive)
    oz_sha1 = sha1_file(oz_archive)
    oz_sha512 = sha512_file(oz_archive)
    sri = "sha512-" + base64.b64encode(oz_sha512).decode("ascii")
    registry = load_json(DEP_PREP / "openzeppelin/registry.json")
    oz_meta = load_json(DEP_PREP / "openzeppelin/metadata/package.json")
    version_block = registry.get("versions", {}).get("5.4.0", {})
    dist = version_block.get("dist", {})
    oz_tar_issues = []
    oz_regular = 0
    oz_members = []
    with tarfile.open(oz_archive, "r:gz") as tf:
        for m in tf.getmembers():
            oz_members.append(m.name)
            issues = tar_path_issues(m.name)
            if m.issym() or m.islnk():
                issues.append("link")
            if issues:
                oz_tar_issues.append({"name": m.name, "issues": issues})
            if m.isfile():
                oz_regular += 1
    record_check(
        "openzeppelin_5_4_0_npm_archive_integrity",
        oz_sha256 == identity["npm_archive_sha256"]
        and sri == identity["npm_integrity"]
        and oz_sha1 == identity["npm_shasum"]
        and dist.get("integrity") == sri
        and dist.get("shasum") == oz_sha1
        and oz_meta.get("version") == "5.4.0"
        and not oz_tar_issues,
        archive_sha256=oz_sha256,
        sri=sri,
        sha1=oz_sha1,
        registry_integrity=dist.get("integrity"),
        registry_shasum=dist.get("shasum"),
        package_version=oz_meta.get("version"),
        regular_members=oz_regular,
        tar_issues=oz_tar_issues[:10],
    )

    # Permit2 archive git blobs.
    p2_archive = DEP_PREP / "permit2/archive.tar.gz"
    p2_commit = load_json(DEP_PREP / "permit2/commit.json")
    p2_tree = load_json(DEP_PREP / "permit2/tree.json")
    p2_commit_sha = p2_commit.get("sha") or p2_commit.get("commit", {}).get("tree", {}).get("sha")
    # GitHub commit object: sha is commit, commit.tree.sha is tree
    p2_actual_commit = p2_commit["sha"]
    p2_tree_entries = p2_tree.get("tree", [])
    p2_blobs = {e["path"]: e["sha"] for e in p2_tree_entries if e.get("type") == "blob"}
    p2_tar_issues = []
    p2_blob_fail = []
    p2_file_members = 0
    p2_checked = 0
    with tarfile.open(p2_archive, "r:gz") as tf:
        for m in tf.getmembers():
            issues = tar_path_issues(m.name)
            if m.issym() or m.islnk():
                issues.append("link")
            if issues:
                p2_tar_issues.append({"name": m.name, "issues": issues})
            if not m.isfile():
                continue
            p2_file_members += 1
            rest = m.name.split("/", 1)[1] if "/" in m.name else m.name
            extracted = tf.extractfile(m)
            assert extracted is not None
            data = extracted.read()
            blob = git_blob_sha1(data)
            expected = p2_blobs.get(rest)
            p2_checked += 1
            if expected is None:
                p2_blob_fail.append({"path": rest, "reason": "not-in-tree", "blob": blob})
            elif expected != blob:
                p2_blob_fail.append({"path": rest, "reason": "mismatch", "tree": expected, "blob": blob})
    record_check(
        "permit2_archive_git_blob_all_members",
        p2_actual_commit == "cc56ad0f3439c502c246fc5cfcc3db92bb8b7219"
        and p2_checked == 104
        and not p2_blob_fail
        and not p2_tar_issues
        and identity["permit2_all_archive_file_git_blobs_verified"] is True,
        commit=p2_actual_commit,
        file_members=p2_file_members,
        checked=p2_checked,
        blob_fails=p2_blob_fail[:10],
        tar_issues=p2_tar_issues[:10],
        tree_blob_count=len(p2_blobs),
        archive_sha256=sha256_file(p2_archive),
    )

    # Yarn checksums are cache containers, not raw archive hashes.
    yarn = (SRC_PREP / "source/yarn.lock").read_text(encoding="utf-8")
    oz_yarn = re.findall(
        r'"@openzeppelin/contracts@npm:5\.4\.0".*?checksum: ([0-9a-f]+)',
        yarn,
        flags=re.S,
    )
    # Yarn berry checksums often look like 10c0 + hash. Collect nearby checksums.
    oz_block = None
    p2_block = None
    blocks = yarn.split("\n\n")
    for b in blocks:
        if "@openzeppelin/contracts@" in b and "5.4.0" in b:
            oz_block = b
        if "permit2@" in b.lower() or "/permit2@" in b:
            p2_block = b
    def extract_checksum(block: str | None) -> str | None:
        if not block:
            return None
        m = re.search(r"checksum:\s*([0-9a-fA-F]+)", block)
        return m.group(1) if m else None
    oz_checksum = extract_checksum(oz_block)
    p2_checksum = extract_checksum(p2_block)
    oz_raw_hex = oz_sha512.hex()
    record_check(
        "yarn_checksums_are_cache_containers_not_raw_archive_hashes",
        oz_checksum is not None
        and oz_checksum.lower() != oz_raw_hex
        and oz_checksum.lower() != oz_sha256
        and oz_checksum.lower() != oz_sha1
        and (p2_checksum is None or p2_checksum.lower() != sha256_file(p2_archive)),
        oz_yarn_checksum=oz_checksum,
        oz_archive_sha512_hex=oz_raw_hex,
        oz_archive_sha256=oz_sha256,
        oz_archive_sha1=oz_sha1,
        permit2_yarn_checksum=p2_checksum,
        permit2_archive_sha256=sha256_file(p2_archive),
        identity_note=identity.get("yarn_checksums"),
    )

    imports = load_json(DEP_PREP / "imports.json")
    imp_files = imports["files"]
    pkg_counts = Counter(f["package"] for f in imp_files)
    edges = imports.get("edges")
    if edges is None:
        # look for alternative key
        edge_keys = [k for k in imports.keys() if "edge" in k or "import" in k]
        edges = imports.get("import_edges") or imports.get("edges") or []
        record_check("imports_json_edge_key", False, keys=list(imports.keys())[:30], edge_keys=edge_keys)
    unresolved = imports.get("unresolved", [])
    # Recount independently from resolved files.
    pkg_paths = {}
    for f in imp_files:
        pkg_paths[(f["package"], f["path"])] = resolve_stored(f["stored_path"])
    missing_resolved = []
    hash_fail = []
    for f in imp_files:
        p = resolve_stored(f["stored_path"])
        if not p.is_file():
            missing_resolved.append(f["stored_path"])
            continue
        data = p.read_bytes()
        if sha256_bytes(data) != f["sha256"] or len(data) != f["bytes"]:
            hash_fail.append(f["path"])
    record_check(
        "selected_98_sources_resolved_from_sandbox",
        len(imp_files) == 98
        and pkg_counts["balancer"] == 68
        and pkg_counts["openzeppelin"] == 26
        and pkg_counts["permit2"] == 4
        and not missing_resolved
        and not hash_fail,
        total=len(imp_files),
        counts=dict(pkg_counts),
        missing=missing_resolved,
        hash_fail=hash_fail,
    )

    # Reconstruct lexical edges from 98 sources with remappings.
    aliases = {
        "@balancer-labs/v3-governance-scripts/": "pkg/governance-scripts/",
        "@balancer-labs/v3-interfaces/": "pkg/interfaces/",
        "@balancer-labs/v3-oracles/": "pkg/oracles/",
        "@balancer-labs/v3-pool-cow/": "pkg/pool-cow/",
        "@balancer-labs/v3-pool-gyro/": "pkg/pool-gyro/",
        "@balancer-labs/v3-pool-hooks/": "pkg/pool-hooks/",
        "@balancer-labs/v3-pool-stable/": "pkg/pool-stable/",
        "@balancer-labs/v3-pool-utils/": "pkg/pool-utils/",
        "@balancer-labs/v3-pool-weighted/": "pkg/pool-weighted/",
        "@balancer-labs/v3-solidity-utils/": "pkg/solidity-utils/",
        "@balancer-labs/v3-standalone-utils/": "pkg/standalone-utils/",
        "@balancer-labs/v3-vault/": "pkg/vault/",
        "@balancer-labs/v3-benchmarks/": "pvt/benchmarks/",
        "@balancer-labs/v3-common/": "pvt/common/",
        "@balancer-labs/v3-helpers/": "pvt/helpers/",
        "@balancer-labs/solidity-toolbox/": "pvt/solidity-toolbox/",
    }
    selected = {f["path"]: f for f in imp_files}
    # Also index by package-qualified compile names used in compiler input.
    def resolve_import(from_path: str, spec: str) -> str | None:
        if spec.startswith("@openzeppelin/contracts/"):
            return spec  # compiler key
        if spec.startswith("permit2/"):
            return spec
        mapped = spec
        for a, dest in aliases.items():
            if spec.startswith(a):
                mapped = dest + spec[len(a):]
                break
        if mapped.startswith("./") or mapped.startswith("../"):
            from_dir = str(Path(from_path).parent)
            mapped = str(Path(from_dir, mapped))
            mapped = os.path.normpath(mapped)
        if mapped in selected:
            return mapped
        # OZ keys in selected files use @openzeppelin/contracts/...
        if spec.startswith("@openzeppelin/"):
            # selected paths for OZ are like interfaces/IERC20.sol under package openzeppelin
            rest = spec[len("@openzeppelin/contracts/"):] if spec.startswith("@openzeppelin/contracts/") else spec
            for f in imp_files:
                if f["package"] == "openzeppelin" and (f["path"] == rest or f["path"].endswith("/" + rest) or spec.endswith(f["path"])):
                    return spec
        if spec.startswith("permit2/"):
            return spec
        return mapped if mapped in selected else None

    # Build set of compile keys as used later.
    oz_keys = {f["path"] for f in imp_files if f["package"] == "openzeppelin"}
    p2_keys = {f["path"] for f in imp_files if f["package"] == "permit2"}
    bal_keys = {f["path"] for f in imp_files if f["package"] == "balancer"}

    def compile_key(f: dict[str, Any]) -> str:
        if f["package"] == "openzeppelin":
            return "@openzeppelin/contracts/" + f["path"]
        if f["package"] == "permit2":
            return "permit2/" + f["path"] if not f["path"].startswith("src/") else "permit2/" + f["path"] if not f["path"].startswith("permit2/") else f["path"]
        return f["path"]

    # Fix permit2 keys: stored path is src/interfaces/... so compile key permit2/src/interfaces/...
    key_set = set()
    file_by_key = {}
    for f in imp_files:
        if f["package"] == "openzeppelin":
            k = "@openzeppelin/contracts/" + f["path"]
        elif f["package"] == "permit2":
            k = "permit2/" + f["path"] if not f["path"].startswith("permit2/") else f["path"]
        else:
            k = f["path"]
        key_set.add(k)
        file_by_key[k] = f

    lexical_edges = []
    unresolved_paths = []
    for k, f in file_by_key.items():
        p = resolve_stored(f["stored_path"])
        text = p.read_text(encoding="utf-8")
        from_path = f["path"] if f["package"] == "balancer" else k
        for spec in parse_imports(text):
            target = spec
            if spec.startswith("@balancer-labs/"):
                mapped = spec
                for a, dest in aliases.items():
                    if spec.startswith(a):
                        mapped = dest + spec[len(a):]
                        break
                target = mapped
            elif spec.startswith("./") or spec.startswith("../"):
                base = f["path"] if f["package"] == "balancer" else (
                    "@openzeppelin/contracts/" + f["path"] if f["package"] == "openzeppelin" else "permit2/" + f["path"]
                )
                target = os.path.normpath(str(Path(base).parent / spec))
            if target not in key_set:
                unresolved_paths.append({"from": k, "import": spec, "resolved": target})
            lexical_edges.append({"from": k, "import": spec, "resolved": target})

    # Prefer imports.json recorded edge count if present.
    recorded_edges = None
    for cand in ("edges", "import_edges", "lexical_edges", "imports"):
        if isinstance(imports.get(cand), list) and cand != "files":
            recorded_edges = imports[cand]
            break
    # Some packets store edges after files. Scan values.
    if recorded_edges is None:
        for k, v in imports.items():
            if k in ("files", "unresolved", "seeds", "package_aliases"):
                continue
            if isinstance(v, list) and v and isinstance(v[0], dict) and ("from" in v[0] or "import" in v[0]):
                recorded_edges = v
                break
    recorded_n = len(recorded_edges) if recorded_edges is not None else None
    record_check(
        "final_selected_lexical_graph",
        recorded_n == 308 and len(unresolved) == 0 and len(unresolved_paths) == 0 and len(lexical_edges) == 308,
        recorded_edge_count=recorded_n,
        independent_lexical_edges=len(lexical_edges),
        unresolved_recorded=len(unresolved),
        unresolved_independent=len(unresolved_paths),
        unresolved_sample=unresolved_paths[:10],
        imports_top_keys=[k for k in imports.keys() if k != "files"],
        excludes_reference_tests=True,
        not_full_npm_build_closure=True,
    )

    dep_result = load_json(DEP_VER / "result.json")
    record_check(
        "dependency_root_verification_counts",
        dep_result.get("source_files_verified") == 98
        and dep_result.get("import_edges_verified") == 308
        and dep_result.get("source_import_paths_unresolved") == 0
        and dep_result.get("counts") == {"balancer": 68, "openzeppelin": 26, "permit2": 4}
        and dep_result.get("permit2_archive_git_blob_members_verified") == 104
        and dep_result.get("P25_accepted") is False
        and dep_result.get("compiler_resolution_verified") is False
        and dep_result.get("test_import_closure_verified") is False,
        result_subset={
            k: dep_result.get(k)
            for k in (
                "source_files_verified",
                "import_edges_verified",
                "source_import_paths_unresolved",
                "counts",
                "P25_accepted",
                "compiler_resolution_verified",
                "test_import_closure_verified",
            )
        },
    )

    # Compiler preparation identity.
    compiler = load_json(COMP_PREP / "compiler.json")
    version_cmd = load_json(COMP_PREP / "version-command.json")
    binary = Path(compiler["binary_path"])
    binary_ok = binary.is_file()
    binary_hash = sha256_file(binary) if binary_ok else None
    list_json = load_json(COMP_PREP / "list.json")
    builds = list_json.get("builds") or list_json
    official = None
    if isinstance(list_json, dict) and "builds" in list_json:
        for b in list_json["builds"]:
            if b.get("path") == "solc-linux-amd64-v0.8.27+commit.40a35a09":
                official = b
                break
    record_check(
        "compiler_binary_hash_matches_official_0_8_27",
        binary_ok
        and binary_hash == "b9977d500c17cba6f0032ca939ef98c4decf6363f19f386d05fb02f708115264"
        and compiler["binary_sha256"] == binary_hash
        and official is not None
        and official.get("sha256", "").replace("0x", "") == binary_hash
        and compiler.get("source_compilation") is False,
        binary_path=str(binary),
        binary_sha256=binary_hash,
        official=official,
        reported_version=compiler.get("reported_version"),
        version_cmd_exit=version_cmd.get("exit"),
        version_stdout_sha256=version_cmd.get("stdout_sha256"),
        version_stdout_file_sha256=sha256_file(COMP_PREP / "version.stdout"),
        version_stderr_file_sha256=sha256_file(COMP_PREP / "version.stderr"),
    )

    # Frozen gzip streams.
    input_gz = COMP_BASE / "input.json.gz"
    stdout_gz = COMP_BASE / "stdout.json.gz"
    stderr_gz = COMP_BASE / "stderr.txt.gz"
    cmdj = load_json(COMP_BASE / "command.json")
    resultj = load_json(COMP_BASE / "result.json")
    diags = load_json(COMP_BASE / "diagnostics.json")
    input_raw = gzip.decompress(input_gz.read_bytes())
    stdout_raw = gzip.decompress(stdout_gz.read_bytes())
    stderr_raw = gzip.decompress(stderr_gz.read_bytes())
    record_check(
        "frozen_gzip_raw_streams",
        sha256_file(input_gz) == cmdj["archive_files"]["input.json.gz"]
        and sha256_file(stdout_gz) == cmdj["archive_files"]["stdout.json.gz"]
        and sha256_file(stderr_gz) == cmdj["archive_files"]["stderr.txt.gz"]
        and sha256_bytes(input_raw) == cmdj["stdin_sha256"] == "9d7e02a1c04be2539d4c56424e5fe027f7436fbac6d85f38577b5873e62e4ac0"
        and sha256_bytes(stdout_raw) == cmdj["stdout_sha256"] == "d0407c5bdef01e56c2158fa28eb1af0366ede87ae23b79cfe04b6c73f8a4400c"
        and sha256_bytes(stderr_raw) == cmdj["stderr_sha256"] == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        and len(stderr_raw) == 0,
        input_gz=sha256_file(input_gz),
        stdout_gz=sha256_file(stdout_gz),
        stderr_gz=sha256_file(stderr_gz),
        input_raw=sha256_bytes(input_raw),
        stdout_raw=sha256_bytes(stdout_raw),
        stderr_raw=sha256_bytes(stderr_raw),
        input_bytes=len(input_raw),
        stdout_bytes=len(stdout_raw),
    )

    inp = json.loads(input_raw)
    settings = inp.get("settings", {})
    sources = inp.get("sources", {})
    via_ir = settings.get("viaIR", "OMITTED")
    opt = settings.get("optimizer", {})
    source_hash_fail = []
    for name, body in sources.items():
        content = body.get("content", "")
        data = content.encode("utf-8")
        # Find matching selected file
        matched = None
        for f in resultj["source_bindings"]:
            if f["source_name"] == name:
                matched = f
                break
        if matched is None:
            source_hash_fail.append({"name": name, "reason": "not-in-bindings"})
            continue
        p = resolve_stored(matched["path"])
        if sha256_bytes(p.read_bytes()) != matched["sha256"] or sha256_bytes(data) != matched["sha256"]:
            source_hash_fail.append({"name": name, "reason": "bytes"})
    record_check(
        "compiler_input_settings_and_source_bytes",
        len(sources) == 98
        and opt.get("enabled") is True
        and opt.get("runs") == 999
        and settings.get("evmVersion") == "cancun"
        and via_ir == "OMITTED"
        and "viaIR" not in settings
        and not source_hash_fail
        and resultj.get("source_count") == 98,
        source_count=len(sources),
        optimizer=opt,
        evmVersion=settings.get("evmVersion"),
        viaIR=via_ir,
        settings_keys=sorted(settings.keys()),
        source_hash_fail=source_hash_fail,
        remappings=settings.get("remappings"),
        outputSelection=settings.get("outputSelection"),
        language=inp.get("language"),
    )

    out = json.loads(stdout_raw)
    errors = out.get("errors") or []
    err_sev = Counter(e.get("severity") for e in errors)
    contracts = out.get("contracts") or {}
    contract_count = 0
    bytecode_count = 0
    bytecode_sizes = {}
    for src, cmap in contracts.items():
        for cname, cbody in cmap.items():
            contract_count += 1
            deployed = (((cbody.get("evm") or {}).get("deployedBytecode") or {}).get("object")) or ""
            creation = (((cbody.get("evm") or {}).get("bytecode") or {}).get("object")) or ""
            if deployed or creation:
                bytecode_count += 1
            if src.endswith("Router.sol") and cname == "Router":
                bytecode_sizes["Router"] = len(deployed) // 2
            if src.endswith("Vault.sol") and cname == "Vault":
                bytecode_sizes["Vault"] = len(deployed) // 2
            if src.endswith("VaultExtension.sol") and cname == "VaultExtension":
                bytecode_sizes["VaultExtension"] = len(deployed) // 2
    diag_codes = [d.get("errorCode") for d in diags]
    record_check(
        "frozen_compiler_output_parse",
        out.get("errors") is not None or True,
        parsed=True,
        error_objects=len(errors),
        severity=dict(err_sev),
        contract_count=contract_count,
        bytecode_count=bytecode_count,
        result_contract_count=resultj.get("contract_count"),
        result_bytecode_contracts=resultj.get("bytecode_contracts"),
        result_error_count=resultj.get("error_count"),
        result_warning_count=resultj.get("warning_count"),
        bytecode_sizes=bytecode_sizes,
        diagnostics_n=len(diags),
        diagnostic_codes=diag_codes,
        has_error_severity=any(e.get("severity") == "error" for e in errors),
        compiler_success_flag=resultj.get("compiler_success"),
        P25_accepted=resultj.get("P25_accepted"),
        EVM_execution=resultj.get("EVM_execution"),
    )
    record_check(
        "frozen_output_counts_match_claim",
        contract_count == 96
        and bytecode_count == 44
        and err_sev.get("error", 0) == 0
        and err_sev.get("warning", 0) == 4
        and bytecode_sizes == {"Router": 26365, "Vault": 33240, "VaultExtension": 28902}
        and diag_codes == ["2394", "5574", "5574", "5574"],
        contract_count=contract_count,
        bytecode_count=bytecode_count,
        severity=dict(err_sev),
        bytecode_sizes=bytecode_sizes,
        diagnostic_codes=diag_codes,
    )

    # Fresh isolated solc reproduction.
    version_rec = run_cmd(
        [str(binary), "--version"],
        cwd=str(REVIEW),
        stdout_path=SOLC_REPRO / "version.stdout",
        stderr_path=SOLC_REPRO / "version.stderr",
        id="solc-version-probe",
        timeout=30,
    )
    (SOLC_REPRO / "input.json").write_bytes(input_raw)
    repro = run_cmd(
        [str(binary), "--standard-json"],
        cwd=str(SOLC_REPRO),
        stdin=input_raw,
        stdout_path=SOLC_REPRO / "stdout.json",
        stderr_path=SOLC_REPRO / "stderr.txt",
        id="solc-standard-json-repro",
        timeout=120,
    )
    repro_out = (SOLC_REPRO / "stdout.json").read_bytes()
    repro_err = (SOLC_REPRO / "stderr.txt").read_bytes()
    repro_parsed = json.loads(repro_out) if repro_out else {}
    repro_errors = repro_parsed.get("errors") or []
    repro_sev = Counter(e.get("severity") for e in repro_errors)
    repro_contracts = repro_parsed.get("contracts") or {}
    repro_cc = sum(len(v) for v in repro_contracts.values())
    repro_bc = 0
    repro_sizes = {}
    for src, cmap in repro_contracts.items():
        for cname, cbody in cmap.items():
            deployed = (((cbody.get("evm") or {}).get("deployedBytecode") or {}).get("object")) or ""
            creation = (((cbody.get("evm") or {}).get("bytecode") or {}).get("object")) or ""
            if deployed or creation:
                repro_bc += 1
            if cname in ("Router", "Vault", "VaultExtension") and src.endswith(cname + ".sol"):
                repro_sizes[cname] = len(deployed) // 2
    stdout_identical = sha256_bytes(repro_out) == sha256_bytes(stdout_raw)
    record_check(
        "fresh_isolated_solc_reproduction",
        repro["exit"] == 0
        and not repro["timed_out"]
        and sha256_bytes(repro_err) == sha256_bytes(b"")
        and repro_sev.get("error", 0) == 0
        and repro_sev.get("warning", 0) == 4
        and repro_cc == 96
        and repro_bc == 44
        and repro_sizes == {"Router": 26365, "Vault": 33240, "VaultExtension": 28902}
        and stdout_identical,
        exit=repro["exit"],
        timed_out=repro["timed_out"],
        stdout_sha256=repro["stdout_sha256"],
        stderr_sha256=repro["stderr_sha256"],
        frozen_stdout_sha256=sha256_bytes(stdout_raw),
        stdout_identical=stdout_identical,
        repro_contracts=repro_cc,
        repro_bytecode=repro_bc,
        repro_sizes=repro_sizes,
        repro_severity=dict(repro_sev),
        version_exit=version_rec["exit"],
        version_stdout=version_rec["stdout_sha256"],
        compiler_sha256=binary_hash,
        argv=repro["argv"],
        cwd=repro["cwd"],
        started_utc=repro["started_utc"],
        finished_utc=repro["finished_utc"],
        note="Exit 0 is insufficient; parsed nonempty JSON, 0 errors, 4 warnings, 96/44 counts.",
    )

    # Hardhat / Foundry profile.
    hh_vault = (PROF / "source/pkg/vault/hardhat.config.ts").read_text(encoding="utf-8")
    hh_base = (PROF / "source/pvt/common/hardhat-base-config.ts").read_text(encoding="utf-8")
    foundry = (SRC_PREP / "source/pkg/vault/foundry.toml").read_text(encoding="utf-8")
    comparison = load_json(PROF / "comparison.json")
    allow_unlimited = "allowUnlimitedContractSize: true" in hh_vault
    viair_unless_coverage = "const viaIR = !(process.env.COVERAGE === 'true' ? true : false);" in hh_base
    has_0826 = "version: '0.8.26'" in hh_base
    has_0827 = "version: '0.8.27'" in hh_base
    vault_override_500 = (
        "'@balancer-labs/v3-vault/contracts/Vault.sol'" in hh_base
        and "runs: 500" in hh_base
    )
    default_runs_9999 = "runs: 9999" in hh_base
    custom_seq = "DEFAULT_OPTIMIZER_STEPS" in hh_base
    foundry_999 = "optimizer_runs = 999" in foundry and "solc_version = '0.8.27'" in foundry
    record_check(
        "hardhat_foundry_profile_observation",
        allow_unlimited and viair_unless_coverage and has_0826 and has_0827 and vault_override_500 and foundry_999
        and comparison.get("baseline_runtime_sizes") == {"Router": 26365, "Vault": 33240, "VaultExtension": 28902}
        and comparison.get("P25_accepted") is False,
        allowUnlimitedContractSize=allow_unlimited,
        viaIR_unless_COVERAGE=viair_unless_coverage,
        compilers=["0.8.26", "0.8.27"] if has_0826 and has_0827 else None,
        vault_vaultextension_override_runs500=vault_override_500,
        default_compiler_runs_9999=default_runs_9999,
        custom_optimizer_sequence=custom_seq,
        foundry_0_8_27_runs_999_cancun=foundry_999,
        hardhat_resolution_run=False,
        comparison_interpretation=comparison.get("interpretation"),
        no_deployed_size_inferred=True,
        no_size_limit_bypass_endorsed=True,
    )
    # Flag if packet claimed Hardhat default runs were 999 (it did not).
    profile_claim_mismatch = []
    if "0.8.26" not in comparison.get("hardhat_observed", ""):
        profile_claim_mismatch.append("missing 0.8.26")
    if "viaIR" not in comparison.get("hardhat_observed", ""):
        profile_claim_mismatch.append("missing viaIR")
    if "500" not in comparison.get("hardhat_observed", ""):
        profile_claim_mismatch.append("missing 500")
    record_check(
        "profile_claim_mismatch",
        not profile_claim_mismatch,
        mismatches=profile_claim_mismatch,
        extra_observed={"hardhat_default_runs": 9999, "foundry_runs": 999, "baseline_runs": 999, "baseline_viaIR": "omitted/false"},
    )

    # Navigation excerpts vs source.
    nav = load_json(NAV / "navigation.json")
    excerpt_fail = []
    for a in nav["anchors"]:
        src = (SRC_PREP / a["path"]).read_text(encoding="utf-8")
        lines = src.splitlines(keepends=True)
        start, end = a["start_line"], a["end_line"]
        extracted = "".join(lines[start - 1 : end])
        # stored excerpt may omit keepends identically; compare stripped-normalized
        if sha256_bytes(src.encode("utf-8")) != a["source_sha256"]:
            excerpt_fail.append({"path": a["path"], "reason": "source_sha256"})
        if a["excerpt"] not in src.replace("\r\n", "\n"):
            # try without requiring exact newline match of the JSON excerpt
            if a["excerpt"].replace("\n", "") not in src.replace("\n", ""):
                excerpt_fail.append({"path": a["path"], "reason": "excerpt_absent", "topic": a["navigation_topic"]})
        if sha256_bytes(a["excerpt"].encode("utf-8")) != a["excerpt_sha256"]:
            excerpt_fail.append({"path": a["path"], "reason": "excerpt_sha256", "topic": a["navigation_topic"]})
    record_check(
        "six_navigation_excerpts_source_backed",
        len(nav["anchors"]) == 6 and not excerpt_fail,
        anchors=len(nav["anchors"]),
        excerpt_fail=excerpt_fail,
        topics=[a["navigation_topic"] for a in nav["anchors"]],
    )

    # Source-backed subtleties.
    vault = (SRC_PREP / "source/pkg/vault/contracts/Vault.sol").read_text(encoding="utf-8")
    common = (SRC_PREP / "source/pkg/vault/contracts/VaultCommon.sol").read_text(encoding="utf-8")
    hooks = (SRC_PREP / "source/pkg/vault/contracts/lib/HooksConfigLib.sol").read_text(encoding="utf-8")
    subtleties = {
        "credit_negative_debt_positive": "_accountDelta(token, -credit.toInt256())" in common
        and "_accountDelta(token, debt.toInt256())" in common
        and "A positive delta represents debt" in common,
        "nonzero_counter_only_zero_transitions": "if (next == 0)" in common
        and "_nonZeroDeltaCount().tDecrement()" in common
        and "else if (current == 0)" in common
        and "_nonZeroDeltaCount().tIncrement()" in common,
        "outer_unlock_requires_zero_deltas": "if (_nonZeroDeltaCount().tload() != 0)" in vault
        and "revert BalanceNotSettled();" in vault
        and "if (isUnlockedBefore == false)" in vault,
        "settle_balance_minus_reserves_cap_hint": "credit = currentReserves - reservesBefore;" in vault
        and "if (credit > amountHint)" in vault
        and "credit = amountHint;" in vault
        and "_reservesOf[token] = currentReserves;" in vault,
        "before_hook_reload_before_accounting": "shouldCallBeforeAddLiquidity()" in vault
        and "poolData.reloadBalancesAndRates" in vault
        and "shouldCallAfterAddLiquidity()" in vault,
        "after_hook_false_or_wrong_length_reverts": "success == false || hookAdjustedAmountsInRaw.length != amountsInRaw.length" in hooks
        and "AfterAddLiquidityHookFailed()" in hooks,
    }
    record_check(
        "source_backed_accounting_hook_subtleties",
        all(subtleties.values()),
        subtleties=subtleties,
        not_whole_evm_rollback_proof=True,
        p17_pin_not_substituted=True,
    )

    # Settle residue: reserves updated to currentReserves even when credit capped.
    settle_updates_reserves_before_cap = vault.find("_reservesOf[token] = currentReserves;") < vault.find(
        "if (credit > amountHint)"
    )
    record_check(
        "settle_excess_residue_stays_in_reserves_not_credited",
        settle_updates_reserves_before_cap,
        note="credit is capped by amountHint after _reservesOf is set to token.balanceOf. Excess is absorbed into stored reserves and is not supplied as delta credit. Later observation contract must not treat that residue as vanished or as caller credit.",
    )

    att2 = load_json(NAV / "result.json")
    record_check(
        "attempt2_and_baseline_do_not_accept_P25",
        att2.get("acceptance") is False
        and att2.get("source_execution") is False
        and resultj.get("P25_accepted") is False
        and comparison.get("P25_accepted") is False
        and manifest.get("acceptance") is False,
        attempt2_acceptance=att2.get("acceptance"),
        attempt2_anchors=att2.get("anchors"),
        attempt2_local_edges=att2.get("local_import_edges_verified"),
        attempt2_external=att2.get("external_occurrences_recorded"),
        attempt2_files=att2.get("archive_members_and_git_blobs_verified"),
    )

    summary = {
        "checks_total": len(CHECKS),
        "checks_passed": sum(1 for c in CHECKS if c["ok"]),
        "checks_failed": [c["name"] for c in CHECKS if not c["ok"]],
    }
    payload = {
        "utc": utc_now(),
        "sandbox": str(SANDBOX),
        "review": str(REVIEW),
        "summary": summary,
        "checks": CHECKS,
    }
    def _json_default(o: Any) -> Any:
        if isinstance(o, (bytes, bytearray)):
            return o.decode("utf-8", "replace")
        if isinstance(o, Path):
            return str(o)
        return str(o)

    (LOGS / "probe-results.json").write_text(
        json.dumps(payload, indent=2, default=_json_default) + "\n", encoding="utf-8"
    )
    (LOGS / "commands-run.json").write_text(json.dumps(COMMANDS, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(summary, indent=2))
    return 0 if not summary["checks_failed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
