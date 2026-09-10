#!/usr/bin/env python3
"""Independent P26 source-identity probe.

Read-only against the frozen sandbox. Does not execute Go, tests, Makefiles,
module installs, capture.py, scope.py, or verify.py. Does not follow historical
absolute cache paths to live locations.
"""
from __future__ import annotations

import datetime
import hashlib
import json
import os
import sys
import tarfile
from pathlib import Path, PurePosixPath

SANDBOX = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p26-source-grok-r1-sandbox")
PREP = SANDBOX / "review/semantic-kernel/program-execution-20260908/p26-ibc-source-preparation"
ROOTV = SANDBOX / "review/semantic-kernel/program-execution-20260908/p26-ibc-root-verification"
ARCHIVE = SANDBOX / "source-archives/ibc-go.tar.gz"
HISTORICAL_CACHE = "/home/charl/.cache/defiformal-program/program-execution-20260908/p26-ibc-source/8a7d8134b7f7cedb3a2809ad3797717f38e44293.tar.gz"
LIVE_DEFIFORMAL = "/home/charl/defiformal"
EXPECTED_COMMIT = "8a7d8134b7f7cedb3a2809ad3797717f38e44293"
EXPECTED_TREE = "d9c9af96ebb809bf6eab6bd6c93989ec86dc71a8"


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_path(path: Path) -> str:
    return sha256_bytes(path.read_bytes())


def git_blob_sha1(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()


def verify_bytes(data: bytes, row: dict) -> None:
    if len(data) != row["bytes"] or sha256_bytes(data) != row["sha256"]:
        raise ValueError("source byte identity mismatch")
    if git_blob_sha1(data) != row["git_blob_sha1"]:
        raise ValueError("Git blob identity mismatch")


def load_json(path: Path):
    return json.loads(path.read_text())


def main() -> int:
    started = datetime.datetime.now(datetime.timezone.utc).isoformat()
    result = {
        "probe": "p26-source-identity",
        "started_utc": started,
        "sandbox": str(SANDBOX),
        "historical_cache_path_not_followed": HISTORICAL_CACHE,
        "live_defiformal_not_followed": LIVE_DEFIFORMAL,
        "archive_resolved_to": str(ARCHIVE),
        "checks": [],
        "failures": [],
        "control": {},
        "source_execution": False,
        "Go_tests_executed": False,
        "Makefile_executed": False,
        "capture_scripts_executed": False,
        "network": False,
        "import_closure_claimed": False,
        "P26_accepted": False,
        "P29_accepted": False,
    }

    def ok(name: str, detail):
        result["checks"].append({"name": name, "passed": True, "detail": detail})

    def fail(name: str, detail):
        result["checks"].append({"name": name, "passed": False, "detail": detail})
        result["failures"].append({"name": name, "detail": detail})

    try:
        if not ARCHIVE.is_file():
            fail("sandbox_archive_present", {"path": str(ARCHIVE)})
            result["finished_utc"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
            json.dump(result, sys.stdout, indent=2)
            sys.stdout.write("\n")
            return 2

        # Packet seals
        seal = load_json(PREP / "root-seal.json")
        if seal.get("file_count") != len(seal.get("files", {})) or seal.get("file_count") != 44:
            fail("prep_root_seal_count", {"file_count": seal.get("file_count"), "len": len(seal.get("files", {}))})
        else:
            ok("prep_root_seal_count", 44)
        seal_mismatch = []
        for rel, digest in seal["files"].items():
            path = PREP / rel
            if not path.is_file():
                seal_mismatch.append({"path": rel, "error": "missing"})
                continue
            actual = sha256_path(path)
            if actual != digest:
                seal_mismatch.append({"path": rel, "expected": digest, "actual": actual})
        if seal_mismatch:
            fail("prep_root_seal_hashes", seal_mismatch)
        else:
            ok("prep_root_seal_hashes", {"verified": len(seal["files"])})
        if seal.get("P26_accepted") is not False or seal.get("P29_accepted") is not False:
            fail("prep_root_seal_acceptance_flags", {"P26_accepted": seal.get("P26_accepted"), "P29_accepted": seal.get("P29_accepted")})
        else:
            ok("prep_root_seal_acceptance_flags", False)

        manifest = load_json(PREP / "source-manifest.json")
        if manifest.get("file_count") != len(manifest.get("files", [])) or manifest.get("file_count") != 33:
            fail("manifest_count", {"file_count": manifest.get("file_count"), "len": len(manifest.get("files", []))})
        else:
            ok("manifest_count", 33)
        if manifest.get("commit") != EXPECTED_COMMIT or manifest.get("tree") != EXPECTED_TREE:
            fail("manifest_commit_tree", {"commit": manifest.get("commit"), "tree": manifest.get("tree")})
        else:
            ok("manifest_commit_tree", {"commit": EXPECTED_COMMIT, "tree": EXPECTED_TREE})
        if manifest.get("import_closure_claimed") is not False:
            fail("manifest_import_closure", manifest.get("import_closure_claimed"))
        else:
            ok("manifest_import_closure", False)
        if manifest.get("source_execution") is not False or manifest.get("compiler_runtime_dependencies_resolved") is not False:
            fail("manifest_execution_flags", {
                "source_execution": manifest.get("source_execution"),
                "compiler_runtime_dependencies_resolved": manifest.get("compiler_runtime_dependencies_resolved"),
            })
        else:
            ok("manifest_execution_flags", False)
        if manifest.get("P26_accepted") is not False or manifest.get("P29_accepted") is not False:
            fail("manifest_acceptance_flags", {
                "P26_accepted": manifest.get("P26_accepted"),
                "P29_accepted": manifest.get("P29_accepted"),
            })
        else:
            ok("manifest_acceptance_flags", False)
        if manifest.get("archive_regular_members") != 1890:
            fail("manifest_archive_regular_members_claim", manifest.get("archive_regular_members"))
        else:
            ok("manifest_archive_regular_members_claim", 1890)
        test_roles = [row for row in manifest["files"] if row.get("role") == "unexecuted_reference_test"]
        if len(test_roles) != 4 or any(not row["upstream_path"].endswith("_test.go") for row in test_roles):
            fail("unexecuted_reference_tests", [{"path": r["upstream_path"], "role": r["role"]} for r in test_roles])
        else:
            ok("unexecuted_reference_tests", [r["upstream_path"] for r in test_roles])

        commit = load_json(PREP / "discovery/commit.json")
        tree = load_json(PREP / "discovery/tree.json")
        if commit.get("sha") != EXPECTED_COMMIT:
            fail("commit_json_sha", commit.get("sha"))
        else:
            ok("commit_json_sha", EXPECTED_COMMIT)
        tree_sha = tree.get("sha")
        nested = (commit.get("commit") or {}).get("tree") or {}
        if nested.get("sha") != EXPECTED_TREE or tree_sha != EXPECTED_TREE:
            fail("tree_json_sha", {"commit.tree": nested.get("sha"), "tree.sha": tree_sha})
        else:
            ok("tree_json_sha", EXPECTED_TREE)
        if tree.get("truncated") is not False:
            fail("tree_not_truncated", tree.get("truncated"))
        else:
            ok("tree_not_truncated", False)

        for name in ("commit", "tree"):
            http = load_json(PREP / f"discovery/{name}-http.json")
            body_hash = sha256_path(PREP / f"discovery/{name}.json")
            if http.get("status") != 200:
                fail(f"{name}_http_status", http.get("status"))
            else:
                ok(f"{name}_http_status", 200)
            if http.get("sha256") != body_hash:
                fail(f"{name}_http_body_hash", {"http": http.get("sha256"), "file": body_hash})
            else:
                ok(f"{name}_http_body_hash", body_hash)

        archive_http = load_json(PREP / "archive-http.json")
        archive_bytes = ARCHIVE.read_bytes()
        archive_hash = sha256_bytes(archive_bytes)
        archive_size = ARCHIVE.stat().st_size
        if archive_http.get("status") != 200:
            fail("archive_http_status", archive_http.get("status"))
        else:
            ok("archive_http_status", 200)
        if archive_http.get("sha256") != archive_hash:
            fail("archive_sha256", {"http": archive_http.get("sha256"), "sandbox": archive_hash})
        else:
            ok("archive_sha256", archive_hash)
        if archive_http.get("bytes") != archive_size:
            fail("archive_size", {"http": archive_http.get("bytes"), "sandbox": archive_size})
        else:
            ok("archive_size", archive_size)
        if archive_http.get("archive_cache_path") != HISTORICAL_CACHE:
            fail("historical_cache_path_record", archive_http.get("archive_cache_path"))
        else:
            ok("historical_cache_path_record_remapped", {
                "recorded": HISTORICAL_CACHE,
                "resolved": str(ARCHIVE),
                "followed_live": False,
            })
        if archive_http.get("archive_published") is not False:
            fail("archive_published_flag", archive_http.get("archive_published"))
        else:
            ok("archive_published_flag", False)

        blobs = {item["path"]: item for item in tree.get("tree", []) if item.get("type") == "blob"}
        missing_blobs = []
        blob_mismatch = []
        source_mismatch = []
        tar_mismatch = []
        members = {}
        with tarfile.open(ARCHIVE) as tar:
            for member in tar.getmembers():
                parts = PurePosixPath(member.name).parts
                if not parts or ".." in parts or member.name.startswith("/"):
                    fail("archive_member_path_safety", member.name)
                    continue
                if member.isfile():
                    path = "/".join(parts[1:])
                    if path in members:
                        fail("archive_duplicate_member", path)
                    members[path] = member
            if len(members) != 1890:
                fail("archive_regular_members", len(members))
            else:
                ok("archive_regular_members", 1890)
            for row in manifest["files"]:
                data = (PREP / row["path"]).read_bytes()
                try:
                    verify_bytes(data, row)
                except ValueError as error:
                    source_mismatch.append({"path": row["path"], "error": str(error)})
                    continue
                upstream = row["upstream_path"]
                blob = blobs.get(upstream)
                if blob is None:
                    missing_blobs.append(upstream)
                elif blob.get("sha") != row["git_blob_sha1"]:
                    blob_mismatch.append({
                        "path": upstream,
                        "tree": blob.get("sha"),
                        "manifest": row["git_blob_sha1"],
                    })
                member = members.get(upstream)
                if member is None:
                    tar_mismatch.append({"path": upstream, "error": "missing from archive"})
                else:
                    extracted = tar.extractfile(member).read()
                    if extracted != data:
                        tar_mismatch.append({
                            "path": upstream,
                            "error": "archive bytes differ from selected source",
                            "archive_sha256": sha256_bytes(extracted),
                            "source_sha256": sha256_bytes(data),
                        })
        if source_mismatch:
            fail("selected_source_bytes", source_mismatch)
        else:
            ok("selected_source_bytes", 33)
        if missing_blobs:
            fail("selected_git_blobs_present", missing_blobs)
        elif blob_mismatch:
            fail("selected_git_blobs", blob_mismatch)
        else:
            ok("selected_git_blobs", 33)
        if tar_mismatch:
            fail("selected_archive_members", tar_mismatch)
        else:
            ok("selected_archive_members", 33)

        nav = load_json(PREP / "source-navigation.json")
        if nav.get("anchor_count") != len(nav.get("anchors", [])) or nav.get("anchor_count") != 15:
            fail("anchor_count", {"anchor_count": nav.get("anchor_count"), "len": len(nav.get("anchors", []))})
        else:
            ok("anchor_count", 15)
        if nav.get("acceptance") is not False:
            fail("navigation_acceptance", nav.get("acceptance"))
        else:
            ok("navigation_acceptance", False)
        anchor_failures = []
        anchor_hits = []
        for row in nav["anchors"]:
            path = PREP / row["path"]
            actual_hash = sha256_path(path)
            lines = path.read_text().splitlines()
            matches = [i + 1 for i, line in enumerate(lines) if row["needle"] in line]
            hit = {
                "id": row["id"],
                "path": row["path"],
                "matching_lines": matches,
                "claimed_lines": row.get("matching_lines"),
                "sha256": actual_hash,
                "proof_or_execution": row.get("proof_or_execution"),
            }
            anchor_hits.append(hit)
            problems = []
            if actual_hash != row.get("sha256"):
                problems.append({"hash": {"claimed": row.get("sha256"), "actual": actual_hash}})
            if matches != row.get("matching_lines"):
                problems.append({"lines": {"claimed": row.get("matching_lines"), "actual": matches}})
            if row.get("proof_or_execution") is not False:
                problems.append({"proof_or_execution": row.get("proof_or_execution")})
            if problems:
                anchor_failures.append({"id": row["id"], "problems": problems})
        if anchor_failures:
            fail("anchors", anchor_failures)
        else:
            ok("anchors", [{"id": h["id"], "matching_lines": h["matching_lines"]} for h in anchor_hits])
        result["anchor_hits"] = anchor_hits

        packet_row = next(r for r in manifest["files"] if r["upstream_path"] == "modules/core/04-channel/keeper/packet.go")
        control = (PREP / packet_row["path"]).read_bytes()
        bad = bytes([control[0] ^ 1]) + control[1:]
        rejected = None
        try:
            verify_bytes(bad, packet_row)
            accepted_bad = True
        except ValueError as error:
            accepted_bad = False
            rejected = str(error)
        intact_after = (PREP / packet_row["path"]).read_bytes() == control
        result["control"] = {
            "scope": "Same verify_bytes function used for intact files and one altered in-memory packet.go byte string. No source file was modified.",
            "intact_sources_accepted": 33 if not source_mismatch else len(manifest["files"]) - len(source_mismatch),
            "altered_source_rejected": (not accepted_bad) and rejected == "source byte identity mismatch",
            "error": rejected,
            "source_file_unmodified": intact_after,
        }
        if accepted_bad or rejected != "source byte identity mismatch" or not intact_after:
            fail("altered_byte_control", result["control"])
        else:
            ok("altered_byte_control", result["control"])

        go_mod = (PREP / "source/go.mod").read_text().splitlines()
        decls = {
            "module": next((line[7:].strip() for line in go_mod if line.startswith("module ")), None),
            "go": next((line[3:].strip() for line in go_mod if line.startswith("go ")), None),
            "cosmos_sdk": next((line.split()[1] for line in go_mod if "github.com/cosmos/cosmos-sdk " in line and not line.strip().startswith("//")), None),
            "cometbft": next((line.split()[1] for line in go_mod if "github.com/cometbft/cometbft " in line and not line.strip().startswith("//")), None),
        }
        expected_decls = {
            "module": "github.com/cosmos/ibc-go/v11",
            "go": "1.26.5",
            "cosmos_sdk": "v0.55.0",
            "cometbft": "v0.40.0",
        }
        if decls != expected_decls:
            fail("go_mod_declarations", {"actual": decls, "expected": expected_decls})
        else:
            ok("go_mod_declarations_source_only", {
                "declarations": decls,
                "installed_runtime_identities": False,
            })

        # Root verifier evidence (hashes only; do not execute verify.py)
        root_seal = load_json(ROOTV / "root-seal.json")
        root_mismatch = []
        for rel, digest in root_seal["files"].items():
            path = ROOTV / rel
            actual = sha256_path(path)
            if actual != digest:
                root_mismatch.append({"path": rel, "expected": digest, "actual": actual})
        if root_seal.get("file_count") != 5 or len(root_seal.get("files", {})) != 5:
            fail("root_verifier_seal_count", {"file_count": root_seal.get("file_count"), "len": len(root_seal.get("files", {}))})
        else:
            ok("root_verifier_seal_count", 5)
        if root_mismatch:
            fail("root_verifier_seal_hashes", root_mismatch)
        else:
            ok("root_verifier_seal_hashes", sorted(root_seal["files"]))
        if root_seal.get("P26_accepted") is not False:
            fail("root_verifier_acceptance", root_seal.get("P26_accepted"))
        else:
            ok("root_verifier_acceptance", False)

        command = load_json(ROOTV / "command.json")
        stdout_bytes = (ROOTV / "stdout").read_bytes()
        stderr_bytes = (ROOTV / "stderr").read_bytes()
        verify_bytes_hash = sha256_path(ROOTV / "verify.py")
        command_ok = True
        command_detail = {}
        if command.get("exit") != 0:
            command_ok = False
            command_detail["exit"] = command.get("exit")
        if command.get("stdout_sha256") != sha256_bytes(stdout_bytes):
            command_ok = False
            command_detail["stdout_sha256"] = {
                "claimed": command.get("stdout_sha256"),
                "actual": sha256_bytes(stdout_bytes),
            }
        if command.get("stderr_sha256") != sha256_bytes(stderr_bytes):
            command_ok = False
            command_detail["stderr_sha256"] = {
                "claimed": command.get("stderr_sha256"),
                "actual": sha256_bytes(stderr_bytes),
            }
        if command.get("script_sha256") != verify_bytes_hash:
            command_ok = False
            command_detail["script_sha256"] = {
                "claimed": command.get("script_sha256"),
                "actual": verify_bytes_hash,
            }
        if stderr_bytes != b"":
            command_ok = False
            command_detail["stderr_empty"] = False
        if command_ok:
            ok("root_command_bindings", {
                "argv": command.get("argv"),
                "cwd": command.get("cwd"),
                "exit": command.get("exit"),
                "script_sha256": command.get("script_sha256"),
                "stdout_sha256": command.get("stdout_sha256"),
                "stderr_sha256": command.get("stderr_sha256"),
            })
        else:
            fail("root_command_bindings", command_detail)

        assessment = load_json(ROOTV / "assessment.json")
        stdout_obj = json.loads(stdout_bytes.decode())
        if assessment != stdout_obj:
            fail("root_assessment_stdout_equality", {
                "assessment_keys": sorted(assessment),
                "stdout_keys": sorted(stdout_obj),
            })
        else:
            ok("root_assessment_stdout_equality", True)
        expected_assessment = {
            "packet_bindings_verified": 44,
            "selected_source_files_verified": 33,
            "static_anchor_bindings_verified": 15,
            "archive_regular_members": 1890,
            "selected_git_blobs_verified": 33,
            "source_execution": False,
            "Go_tests_executed": False,
            "proof_credit": False,
            "P26_accepted": False,
            "P29_accepted": False,
        }
        assessment_flags = {k: assessment.get(k) for k in expected_assessment}
        if assessment_flags != expected_assessment:
            fail("root_assessment_flags", assessment_flags)
        else:
            ok("root_assessment_flags", expected_assessment)
        control = assessment.get("control") or {}
        if control.get("altered_source_rejected") is not True or control.get("error") != "source byte identity mismatch" or control.get("intact_sources_accepted") != 33:
            fail("root_assessment_control", control)
        else:
            ok("root_assessment_control", {
                "altered_source_rejected": True,
                "error": "source byte identity mismatch",
                "independent_reproduction": result["control"],
            })

        # Source declaration vs runtime: record that no compiler/runtime probe was attempted.
        result["runtime_not_probed"] = {
            "go": False,
            "ibc_go": False,
            "cosmos_sdk": False,
            "cometbft": False,
            "reason": "Source declarations only. This probe does not install modules or execute Go.",
        }

        # Confirm live cache path was not opened.
        result["live_path_follow_attempts"] = 0

    except Exception as error:  # noqa: BLE001 - record unexpected probe failure
        fail("probe_exception", {"type": type(error).__name__, "error": str(error)})
        result["finished_utc"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
        json.dump(result, sys.stdout, indent=2, default=str)
        sys.stdout.write("\n")
        return 1

    result["passed"] = not result["failures"]
    result["check_count"] = len(result["checks"])
    result["failure_count"] = len(result["failures"])
    result["finished_utc"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    json.dump(result, sys.stdout, indent=2)
    sys.stdout.write("\n")
    return 0 if result["passed"] else 3


if __name__ == "__main__":
    os.chdir(SANDBOX)
    sys.exit(main())
