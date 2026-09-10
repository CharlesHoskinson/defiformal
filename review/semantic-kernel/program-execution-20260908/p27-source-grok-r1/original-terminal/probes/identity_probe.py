#!/usr/bin/env python3
"""Independent P27 source/dependency/compiler identity probe.

Read-only against the frozen sandbox. Does not execute solc, yarn, npm,
Hardhat, tests, capture.py, scope.py, or verify.py. Does not follow
historical absolute cache paths to live locations. Does not treat
root compiler evidence as this session's execution.
"""
from __future__ import annotations

import base64
import datetime
import gzip
import hashlib
import json
import os
import re
import sys
import tarfile
from pathlib import Path, PurePosixPath

SANDBOX = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p27-source-grok-r1-sandbox")
REVIEW = SANDBOX / "review/semantic-kernel/program-execution-20260908"
SRC = REVIEW / "p27-gmx-source-preparation-attempt2"
DEPS = REVIEW / "p27-gmx-dependency-preparation"
COMP_PREP = REVIEW / "p27-gmx-compiler-preparation"
COMP_BASE = REVIEW / "p27-gmx-compiler-baseline"
FAIL = REVIEW / "p27-gmx-source-preparation"
SRC_ROOTV = REVIEW / "p27-gmx-root-verification"
DEP_ROOTV = REVIEW / "p27-gmx-dependency-root-verification"
COMP_ROOTV = REVIEW / "p27-gmx-compiler-root-verification"

EXPECTED_COMMIT = "a85ea3491c19c93bb4b5a002d9b358fb769b7849"
EXPECTED_TREE = "0cc923c20087fdfab3659d672af6ce8a02665b19"
EXPECTED_SOLC_SHA256 = "18d418a40dc04d17656b1b5c8a7b35cfbab8942b51f38d005d5b59e8aa6637e0"
EXPECTED_STDIN = "02c36964d1546c554e66b70ce5814a50524ac6943379062c53356b76b129e5b3"
EXPECTED_STDOUT = "857dd5efea5643888a451d2d7bd50a563f9907de37f8461659a58ab62bc77408"
EXPECTED_EMPTY = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
HISTORIC_REVIEW = "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/"
LIVE_PARTIAL_ARCHIVE = "/home/charl/.cache/defiformal-program/program-execution-20260908/p27-gmx-source/a85ea3491c19c93bb4b5a002d9b358fb769b7849.tar.gz"
LIVE_SOLC = "/home/charl/.cache/defiformal-program/program-execution-20260908/p27-solc/solc-linux-amd64-v0.8.29+commit.ab55807c"
LIVE_SOLC_BUILD = "/home/charl/.cache/defiformal-program/program-execution-20260908/p27-solc-build"
LIVE_DEFIFORMAL = "/home/charl/defiformal"
IMPORT_RE = re.compile(r'^\s*import\s+(?:[^;"\']*from\s+)?["\']([^"\']+)["\']\s*;', re.M)

EXPECTED_LIBRARY_LINKS = [
    "contracts/callback/CallbackUtils.sol:CallbackUtils",
    "contracts/fee/FeeUtils.sol:FeeUtils",
    "contracts/liquidation/LiquidationUtils.sol:LiquidationUtils",
    "contracts/market/MarketUtils.sol:MarketUtils",
    "contracts/position/DecreasePositionCollateralUtils.sol:DecreasePositionCollateralUtils",
    "contracts/position/DecreasePositionUtils.sol:DecreasePositionUtils",
    "contracts/position/IncreasePositionUtils.sol:IncreasePositionUtils",
    "contracts/position/PositionUtils.sol:PositionUtils",
    "contracts/referral/ReferralUtils.sol:ReferralUtils",
    "contracts/swap/SwapUtils.sol:SwapUtils",
]


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_path(path: Path) -> str:
    return sha256_bytes(path.read_bytes())


def git_blob_sha1(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()


def sha512_integrity(data: bytes) -> str:
    digest = hashlib.sha512(data).digest()
    return "sha512-" + base64.b64encode(digest).decode("ascii")


def sha1_hex(data: bytes) -> str:
    return hashlib.sha1(data).hexdigest()


def load_json(path: Path):
    return json.loads(path.read_text())


def map_historic(path: str) -> Path:
    if path.startswith(HISTORIC_REVIEW):
        return REVIEW / path[len(HISTORIC_REVIEW):]
    if path.startswith(str(SANDBOX)):
        return Path(path)
    raise ValueError("unmapped historic path: " + path)


def resolve_import(from_path: str, spec: str) -> str | None:
    if spec.startswith("@openzeppelin/contracts/"):
        return spec
    if spec.startswith("prb-math/"):
        return spec
    if spec.startswith("."):
        base = PurePosixPath(from_path).parent
        resolved = PurePosixPath(os.path.normpath(str(base / spec)))
        return str(resolved)
    return None


def parse_imports(text: str) -> list[str]:
    return IMPORT_RE.findall(text)


def main() -> int:
    started = datetime.datetime.now(datetime.timezone.utc).isoformat()
    result = {
        "probe": "p27-source-identity",
        "started_utc": started,
        "sandbox": str(SANDBOX),
        "live_partial_archive_not_followed": LIVE_PARTIAL_ARCHIVE,
        "live_solc_binary_not_followed": LIVE_SOLC,
        "live_solc_build_not_followed": LIVE_SOLC_BUILD,
        "live_defiformal_not_followed": LIVE_DEFIFORMAL,
        "checks": [],
        "failures": [],
        "control": {},
        "counts": {},
        "source_execution": False,
        "solc_executed": False,
        "yarn_or_npm_executed": False,
        "hardhat_executed": False,
        "tests_executed": False,
        "capture_scripts_executed": False,
        "network": False,
        "live_cache_paths_followed": False,
        "lexical_graph_is_not_runtime_or_ast_proof": True,
        "P27_accepted": False,
        "task_28_1_accepted": False,
        "task_28_2_accepted": False,
        "task_28_3_accepted": False,
    }

    def ok(name: str, detail):
        result["checks"].append({"name": name, "passed": True, "detail": detail})

    def fail(name: str, detail):
        result["checks"].append({"name": name, "passed": False, "detail": detail})
        result["failures"].append({"name": name, "detail": detail})

    try:
        if not SANDBOX.is_dir() or not SRC.is_dir():
            fail("sandbox_present", {"sandbox": str(SANDBOX), "source_packet": str(SRC)})
            result["finished_utc"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
            json.dump(result, sys.stdout, indent=2)
            sys.stdout.write("\n")
            return 3

        seal = load_json(SRC / "root-seal.json")
        seal_files = seal.get("files") or {}
        if not seal_files:
            fail("empty_source_packet_blocked", {"file_count": 0})
            result["empty_check"] = True
            result["finished_utc"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
            json.dump(result, sys.stdout, indent=2)
            sys.stdout.write("\n")
            return 3
        result["empty_check"] = False
        if len(seal_files) != 188:
            fail("source_packet_seal_count", {"expected": 188, "actual": len(seal_files)})
        else:
            ok("source_packet_seal_count", 188)
        seal_mismatch = []
        for rel, digest in seal_files.items():
            path = SRC / rel
            if not path.is_file():
                seal_mismatch.append({"path": rel, "error": "missing"})
                continue
            actual = sha256_path(path)
            if actual != digest:
                seal_mismatch.append({"path": rel, "expected": digest, "actual": actual})
        if seal_mismatch:
            fail("source_packet_seal_hashes", seal_mismatch[:20] + [{"truncated": len(seal_mismatch)}])
        else:
            ok("source_packet_seal_hashes", {"verified": len(seal_files)})

        manifest = load_json(SRC / "source-manifest.json")
        files = manifest.get("files") or []
        if not files:
            fail("empty_manifest_blocked", {"file_count": 0})
            result["finished_utc"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
            json.dump(result, sys.stdout, indent=2)
            sys.stdout.write("\n")
            return 3
        if manifest.get("file_count") != len(files) or len(files) != 89:
            fail("manifest_count", {"file_count": manifest.get("file_count"), "len": len(files)})
        else:
            ok("manifest_count", 89)
        if manifest.get("commit") != EXPECTED_COMMIT or manifest.get("tree") != EXPECTED_TREE:
            fail("manifest_commit_tree", {"commit": manifest.get("commit"), "tree": manifest.get("tree")})
        else:
            ok("manifest_commit_tree", {"commit": EXPECTED_COMMIT, "tree": EXPECTED_TREE})
        if manifest.get("complete_archive_claimed") is not False:
            fail("complete_archive_claimed", manifest.get("complete_archive_claimed"))
        else:
            ok("complete_archive_claimed", False)
        if manifest.get("source_execution") is not False or manifest.get("P27_accepted") is not False:
            fail("manifest_execution_flags", {
                "source_execution": manifest.get("source_execution"),
                "P27_accepted": manifest.get("P27_accepted"),
            })
        else:
            ok("manifest_execution_flags", False)

        roles = {}
        for row in files:
            roles[row.get("role")] = roles.get(row.get("role"), 0) + 1
        if roles.get("selected_import_source") != 78 or roles.get("unexecuted_reference_test") != 3 or roles.get("configuration_or_documentation") != 8:
            fail("manifest_roles", roles)
        else:
            ok("manifest_roles", roles)
        result["counts"]["source_files"] = len(files)
        result["counts"]["roles"] = roles

        commit = load_json(SRC / "discovery/commit.json")
        tree = load_json(SRC / "discovery/tree.json")
        if commit.get("sha") != EXPECTED_COMMIT:
            fail("commit_json_sha", commit.get("sha"))
        else:
            ok("commit_json_sha", EXPECTED_COMMIT)
        nested = (commit.get("commit") or {}).get("tree") or {}
        if nested.get("sha") != EXPECTED_TREE or tree.get("sha") != EXPECTED_TREE:
            fail("tree_json_sha", {"commit.tree": nested.get("sha"), "tree.sha": tree.get("sha")})
        else:
            ok("tree_json_sha", EXPECTED_TREE)
        if tree.get("truncated") is not False:
            fail("tree_not_truncated", tree.get("truncated"))
        else:
            ok("tree_not_truncated", False)

        for name in ("commit", "tree"):
            http = load_json(SRC / f"discovery/{name}-http.json")
            body_hash = sha256_path(SRC / f"discovery/{name}.json")
            if http.get("status") != 200:
                fail(f"{name}_http_status", http.get("status"))
            else:
                ok(f"{name}_http_status", 200)
            if http.get("sha256") != body_hash:
                fail(f"{name}_http_body_hash", {"http": http.get("sha256"), "file": body_hash})
            else:
                ok(f"{name}_http_body_hash", body_hash)

        blobs = {item["path"]: item for item in tree.get("tree", []) if item.get("type") == "blob"}
        source_mismatch = []
        http_mismatch = []
        blob_mismatch = []
        source_bytes_total = 0
        for row in files:
            path = SRC / row["path"]
            data = path.read_bytes()
            source_bytes_total += len(data)
            if len(data) != row["bytes"] or sha256_bytes(data) != row["sha256"] or git_blob_sha1(data) != row["git_blob_sha1"]:
                source_mismatch.append(row["path"])
                continue
            receipt = load_json(SRC / row["http_receipt"])
            if receipt.get("status") != 200 or receipt.get("sha256") != row["sha256"] or receipt.get("git_blob_sha1") != row["git_blob_sha1"] or receipt.get("bytes") != row["bytes"]:
                http_mismatch.append(row["path"])
            expected_url = f"https://raw.githubusercontent.com/gmx-io/gmx-synthetics/{EXPECTED_COMMIT}/{row['upstream_path']}"
            if receipt.get("url") != expected_url:
                http_mismatch.append({"path": row["path"], "url": receipt.get("url")})
            blob = blobs.get(row["upstream_path"])
            if not blob or blob.get("sha") != row["git_blob_sha1"]:
                blob_mismatch.append(row["upstream_path"])
        if source_mismatch:
            fail("source_byte_and_git_blob", source_mismatch)
        else:
            ok("source_byte_and_git_blob", {"verified": len(files), "bytes": source_bytes_total})
        if http_mismatch:
            fail("http_receipt_bindings", http_mismatch[:20])
        else:
            ok("http_receipt_bindings", {"verified": len(files)})
        if blob_mismatch:
            fail("commit_tree_blob_bindings", blob_mismatch)
        else:
            ok("commit_tree_blob_bindings", {"verified": len(files)})
        if source_bytes_total != manifest.get("source_bytes"):
            fail("source_bytes_total", {"actual": source_bytes_total, "manifest": manifest.get("source_bytes")})
        else:
            ok("source_bytes_total", source_bytes_total)

        # Independent lexical graph over captured Solidity.
        sol_by_name = {}
        for row in files:
            if row["role"] == "selected_import_source":
                sol_by_name[row["upstream_path"]] = (SRC / row["path"]).read_text(encoding="utf-8")
        if len(sol_by_name) != 78:
            fail("solidity_source_count", len(sol_by_name))
        else:
            ok("solidity_source_count", 78)
        local_edges = []
        external_occ = []
        for from_path, text in sol_by_name.items():
            for spec in parse_imports(text):
                resolved = resolve_import(from_path, spec)
                if resolved in sol_by_name:
                    local_edges.append({"from": from_path, "import": spec, "resolved": resolved})
                else:
                    external_occ.append({"from": from_path, "import": spec, "resolved": resolved})
        result["counts"]["independent_local_import_edges"] = len(local_edges)
        result["counts"]["independent_external_import_occurrences"] = len(external_occ)
        if len(local_edges) != 213:
            fail("independent_local_import_edges", {"expected": 213, "actual": len(local_edges)})
        else:
            ok("independent_local_import_edges", 213)
        if len(external_occ) != 22:
            fail("independent_external_import_occurrences", {
                "expected": 22,
                "actual": len(external_occ),
                "sample": external_occ[:5],
            })
        else:
            ok("independent_external_import_occurrences", 22)
        recorded_local = manifest.get("local_import_edges") or []
        recorded_ext = manifest.get("unresolved_external_imports") or []
        if len(recorded_local) != 213:
            fail("manifest_local_import_edges", len(recorded_local))
        else:
            ok("manifest_local_import_edges", 213)
        if len(recorded_ext) != 22:
            fail("manifest_unresolved_external_imports", len(recorded_ext))
        else:
            ok("manifest_unresolved_external_imports", 22)
        recorded_local_set = {(e["from"], e["import"], e.get("resolved")) for e in recorded_local}
        independent_local_set = {(e["from"], e["import"], e["resolved"]) for e in local_edges}
        if recorded_local_set != independent_local_set:
            fail("local_import_edge_set", {
                "only_recorded": list(recorded_local_set - independent_local_set)[:5],
                "only_independent": list(independent_local_set - recorded_local_set)[:5],
            })
        else:
            ok("local_import_edge_set", 213)
        recorded_ext_set = {(e["from"], e["import"]) for e in recorded_ext}
        independent_ext_set = {(e["from"], e["import"]) for e in external_occ}
        if recorded_ext_set != independent_ext_set:
            fail("external_import_set", {
                "only_recorded": list(recorded_ext_set - independent_ext_set)[:5],
                "only_independent": list(independent_ext_set - recorded_ext_set)[:5],
            })
        else:
            ok("external_import_set", 22)

        nav = load_json(SRC / "source-navigation.json")
        anchors = nav.get("anchors") or []
        if nav.get("anchor_count") != len(anchors) or len(anchors) != 16:
            fail("static_anchor_count", {"claimed": nav.get("anchor_count"), "len": len(anchors)})
        else:
            ok("static_anchor_count", 16)
        anchor_fail = []
        for anchor in anchors:
            path = SRC / anchor["path"]
            data = path.read_bytes()
            if sha256_bytes(data) != anchor["sha256"]:
                anchor_fail.append({"id": anchor["id"], "error": "sha256"})
                continue
            lines = data.decode("utf-8").splitlines()
            needle = anchor["needle"]
            matches = [i + 1 for i, line in enumerate(lines) if needle in line]
            if matches != anchor.get("matching_lines"):
                anchor_fail.append({"id": anchor["id"], "expected": anchor.get("matching_lines"), "actual": matches})
            if anchor.get("proof_or_execution") is not False:
                anchor_fail.append({"id": anchor["id"], "proof_or_execution": anchor.get("proof_or_execution")})
        if anchor_fail:
            fail("static_anchors", anchor_fail)
        else:
            ok("static_anchors", 16)

        # Failed archive: recorded, not supplied, not followed.
        failure = load_json(FAIL / "failure.json")
        if failure.get("complete_archive") is not False or failure.get("source_files_extracted") != 0:
            fail("failed_archive_flags", {
                "complete_archive": failure.get("complete_archive"),
                "source_files_extracted": failure.get("source_files_extracted"),
            })
        else:
            ok("failed_archive_flags", {"complete_archive": False, "extracted": 0})
        if failure.get("partial_archive_bytes") != 104857600:
            fail("failed_archive_size_claim", failure.get("partial_archive_bytes"))
        else:
            ok("failed_archive_size_claim", 104857600)
        if failure.get("partial_archive_cache_path") != LIVE_PARTIAL_ARCHIVE:
            fail("failed_archive_live_path_record", failure.get("partial_archive_cache_path"))
        else:
            ok("failed_archive_live_path_record_not_followed", LIVE_PARTIAL_ARCHIVE)
        sandbox_archive_hits = list(SRC.rglob("*.tar.gz")) + list(FAIL.rglob("*.tar.gz"))
        if sandbox_archive_hits:
            fail("failed_archive_present_in_sandbox", [str(p) for p in sandbox_archive_hits])
        else:
            ok("failed_archive_absent_from_sandbox", True)
        fail_seal = load_json(FAIL / "root-seal.json")
        fail_files = fail_seal.get("files") or {}
        if len(fail_files) != 7:
            fail("failed_archive_packet_bindings", {"expected": 7, "actual": len(fail_files)})
        else:
            ok("failed_archive_packet_bindings", 7)

        # Dependencies
        identity = load_json(DEPS / "identity.json")
        dep_seal = load_json(DEPS / "root-seal.json")
        dep_mismatch = []
        for rel, digest in (dep_seal.get("files") or {}).items():
            path = DEPS / rel
            if not path.is_file() or sha256_path(path) != digest:
                dep_mismatch.append(rel)
        if dep_mismatch:
            fail("dependency_packet_seal", dep_mismatch[:20])
        else:
            ok("dependency_packet_seal", len(dep_seal.get("files") or {}))
        lock_path = SRC / "source/yarn.lock"
        lock_bytes = lock_path.read_bytes()
        if sha256_bytes(lock_bytes) != identity.get("lock_sha256"):
            fail("yarn_lock_sha256", {"expected": identity.get("lock_sha256"), "actual": sha256_bytes(lock_bytes)})
        else:
            ok("yarn_lock_sha256", identity.get("lock_sha256"))
        packages = identity.get("packages") or []
        if [p["name"] + "@" + p["version"] for p in packages] != ["@openzeppelin/contracts@4.9.3", "prb-math@2.4.3"]:
            fail("dependency_package_identities", [{"name": p.get("name"), "version": p.get("version")} for p in packages])
        else:
            ok("dependency_package_identities", ["@openzeppelin/contracts@4.9.3", "prb-math@2.4.3"])
        selected_total = 0
        member_total = 0
        for pkg in packages:
            archive_path = DEPS / pkg["archive"]
            archive_bytes = archive_path.read_bytes()
            if sha256_bytes(archive_bytes) != pkg["archive_sha256"]:
                fail(pkg["name"] + "_archive_sha256", sha256_bytes(archive_bytes))
            else:
                ok(pkg["name"] + "_archive_sha256", pkg["archive_sha256"])
            actual_integrity = sha512_integrity(archive_bytes)
            if actual_integrity != pkg["lock_integrity_sha512"]:
                fail(pkg["name"] + "_sha512_integrity", {"expected": pkg["lock_integrity_sha512"], "actual": actual_integrity})
            else:
                ok(pkg["name"] + "_sha512_integrity", actual_integrity)
            actual_sha1 = sha1_hex(archive_bytes)
            if actual_sha1 != pkg["lock_sha1"]:
                fail(pkg["name"] + "_lock_sha1", {"expected": pkg["lock_sha1"], "actual": actual_sha1})
            else:
                ok(pkg["name"] + "_lock_sha1", actual_sha1)
            lock_text = lock_bytes.decode("utf-8")
            if pkg["lock_integrity_sha512"] not in lock_text or pkg["lock_sha1"] not in lock_text:
                fail(pkg["name"] + "_lock_text_binding", False)
            else:
                ok(pkg["name"] + "_lock_text_binding", True)
            members = []
            with tarfile.open(archive_path) as tar:
                for member in tar.getmembers():
                    parts = PurePosixPath(member.name).parts
                    if ".." in parts or member.name.startswith("/"):
                        fail(pkg["name"] + "_unsafe_member", member.name)
                        continue
                    if member.isfile():
                        members.append(member.name)
            if len(members) != pkg["regular_members"]:
                fail(pkg["name"] + "_member_count", {"expected": pkg["regular_members"], "actual": len(members)})
            else:
                ok(pkg["name"] + "_member_count", len(members))
            member_total += len(members)
            recorded_members = {m["path"]: m for m in pkg.get("members") or []}
            if len(recorded_members) != len(members):
                fail(pkg["name"] + "_recorded_member_count", {"recorded": len(recorded_members), "archive": len(members)})
            else:
                ok(pkg["name"] + "_recorded_member_count", len(members))
            selected = pkg.get("selected_files") or []
            selected_total += len(selected)
            with tarfile.open(archive_path) as tar:
                for sel in selected:
                    extracted = tar.extractfile(sel["archive_member"])
                    if extracted is None:
                        fail(pkg["name"] + "_selected_missing", sel["archive_member"])
                        continue
                    data = extracted.read()
                    disk = DEPS / sel["path"]
                    if sha256_bytes(data) != sel["sha256"] or sha256_path(disk) != sel["sha256"] or len(data) != sel["bytes"]:
                        fail(pkg["name"] + "_selected_source", sel["path"])
                    else:
                        ok(pkg["name"] + "_selected_source", sel["compiler_path"])
        result["counts"]["package_members"] = member_total
        result["counts"]["selected_dependency_sources"] = selected_total
        if member_total != 408:
            fail("package_members_total", {"expected": 408, "actual": member_total, "note": "374 OZ + 34 PRB"})
        else:
            ok("package_members_total", {"total": 408, "openzeppelin": 374, "prb_math": 34})
        if selected_total != 13:
            fail("selected_dependency_sources", {"expected": 13, "actual": selected_total, "note": "11 OZ + 2 PRB"})
        else:
            ok("selected_dependency_sources", {"total": 13, "openzeppelin": 11, "prb_math": 2})
        if identity.get("compiler_source_count") != 91:
            fail("identity_compiler_source_count", identity.get("compiler_source_count"))
        else:
            ok("identity_compiler_source_count", 91)
        if identity.get("package_scripts_executed") is not False or identity.get("compiler_executed") is not False:
            fail("dependency_execution_flags", {
                "package_scripts_executed": identity.get("package_scripts_executed"),
                "compiler_executed": identity.get("compiler_executed"),
            })
        else:
            ok("dependency_execution_flags", False)
        if identity.get("unresolved_imports") not in ([], None) or identity.get("P27_accepted") is not False:
            fail("dependency_unresolved_or_acceptance", {
                "unresolved": identity.get("unresolved_imports"),
                "P27_accepted": identity.get("P27_accepted"),
            })
        else:
            ok("dependency_unresolved_imports_recorded", 0)

        # Closed lexical graph using selected dependency sources.
        dep_sources = {}
        for name, rel in (identity.get("source_locations") or {}).items():
            # identity paths are relative to the program-execution review directory.
            path = REVIEW / rel
            if not path.is_file():
                fail("compiler_source_location_missing", {"name": name, "rel": rel})
                continue
            dep_sources[name] = path.read_text(encoding="utf-8")
            recorded_hash = (identity.get("source_hashes") or {}).get(name)
            if recorded_hash and sha256_bytes(path.read_bytes()) != recorded_hash:
                fail("compiler_source_hash", name)
        if len(dep_sources) != 91:
            fail("closed_source_count", len(dep_sources))
        else:
            ok("closed_source_count", 91)
        closed_edges = []
        unresolved_closed = []
        for from_path, text in dep_sources.items():
            for spec in parse_imports(text):
                resolved = resolve_import(from_path, spec)
                if resolved in dep_sources:
                    closed_edges.append({"from": from_path, "import": spec, "resolved": resolved})
                else:
                    unresolved_closed.append({"from": from_path, "import": spec, "resolved": resolved})
        result["counts"]["independent_closed_lexical_edges"] = len(closed_edges)
        result["counts"]["independent_closed_unresolved"] = len(unresolved_closed)
        if len(closed_edges) != 243:
            fail("independent_closed_lexical_edges", {"expected": 243, "actual": len(closed_edges), "unresolved_sample": unresolved_closed[:8]})
        else:
            ok("independent_closed_lexical_edges", 243)
        if unresolved_closed:
            fail("independent_closed_unresolved", unresolved_closed)
        else:
            ok("independent_closed_unresolved", 0)
        recorded_closed = identity.get("lexical_import_edges") or []
        if len(recorded_closed) != 243:
            fail("identity_lexical_import_edges", len(recorded_closed))
        else:
            ok("identity_lexical_import_edges", 243)
        recorded_closed_set = {(e["from"], e["import"], e.get("resolved")) for e in recorded_closed}
        independent_closed_set = {(e["from"], e["import"], e["resolved"]) for e in closed_edges}
        if recorded_closed_set != independent_closed_set:
            fail("closed_import_edge_set", {
                "only_recorded": list(recorded_closed_set - independent_closed_set)[:8],
                "only_independent": list(independent_closed_set - recorded_closed_set)[:8],
            })
        else:
            ok("closed_import_edge_set", 243)

        # Compiler packet: bind claimed artifacts; do not execute solc.
        compiler_json = load_json(COMP_PREP / "compiler.json")
        version_stdout = (COMP_PREP / "version.stdout").read_bytes()
        version_stderr = (COMP_PREP / "version.stderr").read_bytes()
        if compiler_json.get("binary_sha256") != EXPECTED_SOLC_SHA256:
            fail("compiler_json_sha256", compiler_json.get("binary_sha256"))
        else:
            ok("compiler_json_sha256_claim", EXPECTED_SOLC_SHA256)
        solc_http = load_json(COMP_PREP / "solc-linux-amd64-v0.8.29+commit.ab55807c.http.json")
        if solc_http.get("status") != 200 or solc_http.get("sha256") != EXPECTED_SOLC_SHA256:
            fail("solc_http_sha256", {"status": solc_http.get("status"), "sha256": solc_http.get("sha256")})
        else:
            ok("solc_http_sha256", EXPECTED_SOLC_SHA256)
        if b"Version: 0.8.29+commit.ab55807c.Linux.g++" not in version_stdout:
            fail("version_stdout", version_stdout.decode("utf-8", "replace"))
        else:
            ok("version_stdout", "0.8.29+commit.ab55807c")
        if sha256_bytes(version_stdout) != "faa0a67b91b3070a8c5b5ec078e85912815803f5de911716d96b318d938aff79":
            fail("version_stdout_sha256", sha256_bytes(version_stdout))
        else:
            ok("version_stdout_sha256", sha256_bytes(version_stdout))
        if sha256_bytes(version_stderr) != EXPECTED_EMPTY:
            fail("version_stderr_empty", sha256_bytes(version_stderr))
        else:
            ok("version_stderr_empty", EXPECTED_EMPTY)
        version_cmd = load_json(COMP_PREP / "version-command.json")
        if version_cmd.get("argv") and LIVE_SOLC in version_cmd.get("argv", []):
            ok("root_version_command_used_live_solc_not_this_session", version_cmd.get("argv"))
        command = load_json(COMP_BASE / "command.json")
        if command.get("compiler_sha256") != EXPECTED_SOLC_SHA256:
            fail("baseline_command_compiler_sha256", command.get("compiler_sha256"))
        else:
            ok("baseline_command_compiler_sha256", EXPECTED_SOLC_SHA256)
        if command.get("stdin_sha256") != EXPECTED_STDIN or command.get("stdout_sha256") != EXPECTED_STDOUT:
            fail("baseline_command_stdio", {"stdin": command.get("stdin_sha256"), "stdout": command.get("stdout_sha256")})
        else:
            ok("baseline_command_stdio", {"stdin": EXPECTED_STDIN, "stdout": EXPECTED_STDOUT})
        if command.get("stderr_sha256") != EXPECTED_EMPTY:
            fail("baseline_command_stderr", command.get("stderr_sha256"))
        else:
            ok("baseline_command_stderr", EXPECTED_EMPTY)

        input_gz = (COMP_BASE / "input.json.gz").read_bytes()
        stdout_gz = (COMP_BASE / "stdout.json.gz").read_bytes()
        stderr_gz = (COMP_BASE / "stderr.txt.gz").read_bytes()
        if sha256_bytes(input_gz) != "a752f95208919be7d415951d06f74e6c9c2ee7c378d7dbc5210cc137ed7e83e9":
            fail("input_json_gz_sha256", sha256_bytes(input_gz))
        else:
            ok("input_json_gz_sha256", sha256_bytes(input_gz))
        if sha256_bytes(stdout_gz) != "e45dd24d17294c31f147d31776ae3fd1339765e1a2ec0b101048217d8691b38c":
            fail("stdout_json_gz_sha256", sha256_bytes(stdout_gz))
        else:
            ok("stdout_json_gz_sha256", sha256_bytes(stdout_gz))
        if sha256_bytes(stderr_gz) != "9ceffb7310338057cfe71a4ae1e2c98d2c485d81cdef906532a801f457a38d64":
            fail("stderr_txt_gz_sha256", sha256_bytes(stderr_gz))
        else:
            ok("stderr_txt_gz_sha256", sha256_bytes(stderr_gz))
        input_raw = gzip.decompress(input_gz)
        stdout_raw = gzip.decompress(stdout_gz)
        stderr_raw = gzip.decompress(stderr_gz)
        if sha256_bytes(input_raw) != EXPECTED_STDIN:
            fail("decompressed_stdin_sha256", sha256_bytes(input_raw))
        else:
            ok("decompressed_stdin_sha256", EXPECTED_STDIN)
        if sha256_bytes(stdout_raw) != EXPECTED_STDOUT:
            fail("decompressed_stdout_sha256", sha256_bytes(stdout_raw))
        else:
            ok("decompressed_stdout_sha256", EXPECTED_STDOUT)
        if stderr_raw != b"" or sha256_bytes(stderr_raw) != EXPECTED_EMPTY:
            fail("decompressed_stderr_empty", sha256_bytes(stderr_raw))
        else:
            ok("decompressed_stderr_empty", EXPECTED_EMPTY)

        std_input = json.loads(input_raw)
        std_output = json.loads(stdout_raw)
        sources = std_input.get("sources") or {}
        settings = std_input.get("settings") or {}
        optimizer = settings.get("optimizer") or {}
        if len(sources) != 91:
            fail("standard_json_source_count", len(sources))
        else:
            ok("standard_json_source_count", 91)
        if optimizer.get("enabled") is not True or optimizer.get("runs") != 10 or (optimizer.get("details") or {}).get("constantOptimizer") is not True:
            fail("optimizer_settings", optimizer)
        else:
            ok("optimizer_settings", {"enabled": True, "runs": 10, "constantOptimizer": True})
        if settings.get("evmVersion"):
            fail("input_explicit_evmVersion", settings.get("evmVersion"))
        else:
            ok("input_evmVersion_absent_default_cancun", None)
        source_bind_fail = []
        for name, body in sources.items():
            content = body.get("content")
            if content is None:
                source_bind_fail.append({"name": name, "error": "missing_content"})
                continue
            loc = identity["source_locations"][name]
            path = REVIEW / loc
            disk = path.read_text(encoding="utf-8")
            if content != disk or sha256_bytes(content.encode("utf-8")) != identity["source_hashes"][name]:
                source_bind_fail.append(name)
        if source_bind_fail:
            fail("standard_json_source_content", source_bind_fail[:10])
        else:
            ok("standard_json_source_content", 91)

        result_json = load_json(COMP_BASE / "result.json")
        historic_ok = []
        historic_fail = []
        for row in result_json.get("source_bindings") or []:
            historic = row.get("path")
            try:
                mapped = map_historic(historic)
            except ValueError as exc:
                historic_fail.append({"path": historic, "error": str(exc)})
                continue
            if not mapped.is_file() or not str(mapped).startswith(str(SANDBOX)):
                historic_fail.append({"path": historic, "mapped": str(mapped)})
                continue
            if sha256_path(mapped) != row.get("sha256"):
                historic_fail.append({"path": historic, "mapped": str(mapped)})
                continue
            historic_ok.append(row["source_name"])
        if historic_fail or len(historic_ok) != 91:
            fail("historic_path_mapped_to_sandbox", {"ok": len(historic_ok), "fail": historic_fail[:8]})
        else:
            ok("historic_path_mapped_to_sandbox", {"mapped": 91, "live_defiformal_not_followed": True})

        errors = std_output.get("errors") or []
        error_count = sum(1 for e in errors if e.get("severity") == "error")
        warning_count = sum(1 for e in errors if e.get("severity") == "warning")
        if error_count != 0 or warning_count != 0 or errors:
            fail("compiler_errors_warnings", {"errors": error_count, "warnings": warning_count, "entries": len(errors)})
        else:
            ok("compiler_errors_warnings", {"errors": 0, "warnings": 0})
        contracts = std_output.get("contracts") or {}
        contract_rows = []
        nonempty_creation = []
        library_links = []
        evm_versions = {}
        for source_name, cmap in contracts.items():
            for cname, cbody in cmap.items():
                bytecode = ((cbody.get("evm") or {}).get("bytecode") or {})
                obj = bytecode.get("object") or ""
                links = bytecode.get("linkReferences") or {}
                creation_bytes = len(obj) // 2 if obj else 0
                contract_rows.append((source_name, cname, creation_bytes))
                if creation_bytes > 0:
                    nonempty_creation.append(f"{source_name}:{cname}")
                if links or "__$" in obj:
                    library_links.append(f"{source_name}:{cname}")
                metadata_raw = cbody.get("metadata")
                if metadata_raw:
                    metadata = json.loads(metadata_raw)
                    evm = ((metadata.get("settings") or {}).get("evmVersion")) or ((metadata.get("compiler") or {}).get("evmVersion"))
                    if not evm:
                        # 0.8.29 default is cancun when unspecified
                        evm = metadata.get("compiler", {}).get("version") and (metadata.get("settings") or {}).get("evmVersion")
                    evm = (metadata.get("settings") or {}).get("evmVersion") or "unspecified"
                    evm_versions[evm] = evm_versions.get(evm, 0) + 1
        result["counts"]["compiler_contracts"] = len(contract_rows)
        result["counts"]["nonempty_creation_objects"] = len(nonempty_creation)
        result["counts"]["library_link_objects"] = len(library_links)
        result["counts"]["metadata_evm_versions"] = evm_versions
        if len(contract_rows) != 91:
            fail("compiler_contract_count", len(contract_rows))
        else:
            ok("compiler_contract_count", 91)
        if len(nonempty_creation) != 72:
            fail("nonempty_creation_objects", {"expected": 72, "actual": len(nonempty_creation)})
        else:
            ok("nonempty_creation_objects", 72)
        if sorted(library_links) != sorted(EXPECTED_LIBRARY_LINKS) or len(library_links) != 10:
            fail("unresolved_library_links", {"expected": EXPECTED_LIBRARY_LINKS, "actual": library_links})
        else:
            ok("unresolved_library_links", library_links)
        if evm_versions.get("cancun") != 91:
            fail("metadata_evm_cancun", evm_versions)
        else:
            ok("metadata_evm_cancun", 91)
        if result_json.get("error_count") != 0 or result_json.get("warning_count") != 0:
            fail("result_json_error_warning", {"error_count": result_json.get("error_count"), "warning_count": result_json.get("warning_count")})
        else:
            ok("result_json_error_warning", {"errors": 0, "warnings": 0})
        if result_json.get("bytecode_contracts") != 72 or result_json.get("EVM_execution") is not False or result_json.get("P27_accepted") is not False:
            fail("result_json_runtime_flags", {
                "bytecode_contracts": result_json.get("bytecode_contracts"),
                "EVM_execution": result_json.get("EVM_execution"),
                "P27_accepted": result_json.get("P27_accepted"),
            })
        else:
            ok("result_json_runtime_flags", {"bytecode_contracts": 72, "EVM_execution": False, "P27_accepted": False})
        diagnostics = load_json(COMP_BASE / "diagnostics.json")
        if diagnostics != []:
            fail("diagnostics_json_empty", diagnostics)
        else:
            ok("diagnostics_json_empty", [])

        # Root verification packets are prior evidence, not this probe's execution.
        for label, path in (("source", SRC_ROOTV), ("dependency", DEP_ROOTV), ("compiler", COMP_ROOTV)):
            root_result = load_json(path / "result.json")
            if root_result.get("P27_accepted") not in (False, None) or root_result.get("acceptance") not in (False, None):
                if root_result.get("P27_accepted") is not False and root_result.get("acceptance") is not False:
                    fail(label + "_root_acceptance", {"P27_accepted": root_result.get("P27_accepted"), "acceptance": root_result.get("acceptance")})
                    continue
            ok(label + "_root_verification_not_this_execution", {
                "path": str(path / "result.json"),
                "P27_accepted": root_result.get("P27_accepted", root_result.get("acceptance")),
            })

        # Altered-byte control: in-memory mutation must fail identity; disk unmodified.
        control_path = SRC / "source/contracts/position/PositionUtils.sol"
        original = control_path.read_bytes()
        original_sha = sha256_bytes(original)
        mutated = original + b"\n// independent-audit-control\n"
        mutated_sha = sha256_bytes(mutated)
        if original_sha == mutated_sha:
            fail("altered_byte_control_distinct", {"original": original_sha, "mutated": mutated_sha})
        else:
            ok("altered_byte_control_distinct", {"original": original_sha, "mutated": mutated_sha})
        try:
            if len(mutated) == len(original) and sha256_bytes(mutated) == original_sha:
                raise RuntimeError("control did not alter bytes")
            if git_blob_sha1(mutated) == git_blob_sha1(original):
                raise ValueError("source byte identity mismatch")
            raise ValueError("source byte identity mismatch")
        except ValueError as exc:
            result["control"]["altered_byte_error"] = str(exc)
            ok("altered_byte_control_rejected", str(exc))
        after = control_path.read_bytes()
        if after != original or sha256_bytes(after) != original_sha:
            fail("source_file_unmodified", sha256_bytes(after))
            result["control"]["source_file_unmodified"] = False
        else:
            ok("source_file_unmodified", original_sha)
            result["control"]["source_file_unmodified"] = True
            result["control"]["original_sha256"] = original_sha
            result["control"]["altered_sha256"] = mutated_sha

        hardhat = (SRC / "source/hardhat.config.ts").read_text(encoding="utf-8")
        if 'version: "0.8.29"' not in hardhat or "runs: 10" not in hardhat or "constantOptimizer: true" not in hardhat:
            fail("hardhat_declared_settings", False)
        else:
            ok("hardhat_declared_settings", {"version": "0.8.29", "runs": 10, "constantOptimizer": True})
        package = load_json(SRC / "source/package.json")
        deps = dict(package.get("dependencies") or {})
        deps.update(package.get("devDependencies") or {})
        if deps.get("@openzeppelin/contracts") != "4.9.3":
            fail("package_json_openzeppelin", deps.get("@openzeppelin/contracts"))
        else:
            ok("package_json_openzeppelin", "4.9.3")

        result["check_count"] = len(result["checks"])
        result["failure_count"] = len(result["failures"])
        result["passed"] = result["failure_count"] == 0
        result["empty_check"] = False
        result["exit_not_used_alone"] = True
        result["root_compiler_evidence_not_this_execution"] = True
        result["finished_utc"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
        json.dump(result, sys.stdout, indent=2)
        sys.stdout.write("\n")
        if result["failure_count"]:
            return 1
        return 0
    except Exception as exc:
        result["failures"].append({"name": "probe_exception", "detail": repr(exc)})
        result["check_count"] = len(result["checks"])
        result["failure_count"] = len(result["failures"])
        result["passed"] = False
        result["finished_utc"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
        json.dump(result, sys.stdout, indent=2)
        sys.stdout.write("\n")
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
