#!/usr/bin/env python3
"""Output-only frozen identity recompute. Does not write into the sandbox."""
from __future__ import annotations

import datetime
import hashlib
import json
import os
import sys
import tarfile
import zipfile
from pathlib import Path

STARTED = datetime.datetime.now(datetime.timezone.utc).isoformat()
SANDBOX = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p31-zkir-source-grok-r1-sandbox")
REVIEW = Path("/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p31-zkir-source-grok-r1")
INPUTS = json.loads((REVIEW / "inputs.json").read_text())
OUT = REVIEW / "root-verification" / "identity-recompute.json"


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_path(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def git_blob(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()


def list_files(root: Path) -> list[str]:
    rows = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames.sort()
        for name in sorted(filenames):
            p = Path(dirpath) / name
            rel = str(p.relative_to(root))
            rows.append(rel)
    return rows


declared = INPUTS["files"]
sha_rows = []
mismatch = []
missing = []
for rel, expected in sorted(declared.items()):
    path = SANDBOX / rel
    if not path.is_file():
        missing.append(rel)
        continue
    actual = sha256_path(path)
    ok = actual == expected
    sha_rows.append({"path": rel, "expected": expected, "actual": actual, "match": ok, "bytes": path.stat().st_size})
    if not ok:
        mismatch.append(rel)

present = set(list_files(SANDBOX))
declared_set = set(declared)
extra = sorted(present - declared_set)
absent_from_disk = sorted(declared_set - present)

crate_root = SANDBOX / "p31-zkir-source-preparation/crate/midnight-zkir-2.1.0"
package_files = ["Cargo.toml", "Cargo.lock", ".cargo_vcs_info.json"]
comparable = {
    "Cargo.toml.orig": "zkir/Cargo.toml",
    "src/ir.rs": "zkir/src/ir.rs",
    "src/ir_vm.rs": "zkir/src/ir_vm.rs",
    "src/lib.rs": "zkir/src/lib.rs",
    "src/main.rs": "zkir/src/main.rs",
    "tests/proofs.rs": "zkir/tests/proofs.rs",
}
trees = {
    "crate-vcs": SANDBOX / "p31-zkir-source-preparation/crate-commit-tree.json",
    "crate-tag": SANDBOX / "p31-zkir-source-preparation/crate-tag-tree.json",
    "binary-tag": SANDBOX / "p31-zkir-source-preparation/binary-tag-tree.json",
    "ledger-tag": SANDBOX / "p31-zkir-source-preparation/ledger-tag-tree.json",
}
commits = {
    "crate-vcs": "6d1b0acb1d03e01bc0580ec10cd55e54cd813f5a",
    "crate-tag": "04a6105472777d0ded1fdab27f611738cd435fd9",
    "binary-tag": "9da0b63cde82b93ccf1132a943ce05a86de06fe2",
    "ledger-tag": "dfb450d558d23100d056d2ba121fe2b865e1208c",
}
tree_index = {}
tree_meta = {}
for name, path in trees.items():
    data = json.loads(path.read_text())
    tree_meta[name] = {
        "sha": data.get("sha"),
        "truncated": data.get("truncated"),
        "tree_count": len(data.get("tree", [])),
        "zkir_blob_count": sum(1 for x in data.get("tree", []) if x.get("path", "").startswith("zkir/")),
    }
    tree_index[name] = {x["path"]: x.get("sha") for x in data.get("tree", []) if "path" in x}

comparable_rows = []
for local, remote in comparable.items():
    data = (crate_root / local).read_bytes()
    blob = git_blob(data)
    row = {
        "crate_path": local,
        "git_path": remote,
        "crate_sha256": sha256_bytes(data),
        "bytes": len(data),
        "computed_git_blob": blob,
        "commits": {},
    }
    for name, commit in commits.items():
        entry = tree_index[name].get(remote)
        row["commits"][name] = {
            "commit": commit,
            "tree_sha": tree_meta[name]["sha"],
            "blob": entry,
            "matches_crate": entry == blob,
        }
    comparable_rows.append(row)

package_rows = []
for local in package_files:
    data = (crate_root / local).read_bytes()
    package_rows.append({
        "crate_path": local,
        "sha256": sha256_bytes(data),
        "bytes": len(data),
        "computed_git_blob": git_blob(data),
        "treated_as_git_comparable": False,
        "present_in_crate_vcs_tree_as_zkir_path": ("zkir/" + local) in tree_index["crate-vcs"],
    })

crate_archive = SANDBOX / "p31-zkir-source-preparation/midnight-zkir-2.1.0.crate"
crate_meta = json.loads((SANDBOX / "p31-zkir-source-preparation/crate-metadata.json").read_text())
crate_archive_sha = sha256_path(crate_archive)
crate_archive_bytes = crate_archive.stat().st_size

crate_members = []
with tarfile.open(crate_archive, "r:gz") as tar:
    for member in tar.getmembers():
        if not member.isfile():
            continue
        extracted = tar.extractfile(member)
        data = extracted.read() if extracted is not None else b""
        rel = member.name
        crate_members.append({
            "archive_member": rel,
            "bytes": len(data),
            "sha256": sha256_bytes(data),
        })

extracted_map = {}
for row in crate_members:
    name = row["archive_member"]
    prefix = "midnight-zkir-2.1.0/"
    if name.startswith(prefix):
        extracted_map[name[len(prefix):]] = row["sha256"]

extracted_vs_disk = []
for rel, digest in sorted(extracted_map.items()):
    disk = crate_root / rel
    if disk.is_file():
        extracted_vs_disk.append({
            "path": rel,
            "archive_sha256": digest,
            "disk_sha256": sha256_path(disk),
            "match": digest == sha256_path(disk),
        })
    else:
        extracted_vs_disk.append({"path": rel, "archive_sha256": digest, "disk_sha256": None, "match": False})

binding = json.loads((SANDBOX / "p31-compact-release-binding/binding.json").read_text())
archive_path = Path(binding["archive_path"])
archive_sha = sha256_path(archive_path)
archive_bytes = archive_path.stat().st_size
zip_members = []
with zipfile.ZipFile(archive_path) as zf:
    for info in zf.infolist():
        if info.is_dir():
            continue
        data = zf.read(info.filename)
        zip_members.append({
            "member": info.filename,
            "bytes": len(data),
            "archive_member_sha256": sha256_bytes(data),
        })

installed_rows = []
for claimed in binding["files"]:
    inst = Path(claimed["installed_path"])
    inst_sha = sha256_path(inst) if inst.is_file() else None
    zip_row = next((x for x in zip_members if x["member"] == claimed["member"]), None)
    installed_rows.append({
        "member": claimed["member"],
        "claimed_archive_sha256": claimed["archive_member_sha256"],
        "claimed_installed_sha256": claimed["installed_sha256"],
        "recomputed_installed_sha256": inst_sha,
        "recomputed_zip_member_sha256": None if zip_row is None else zip_row["archive_member_sha256"],
        "installed_bytes": None if not inst.is_file() else inst.stat().st_size,
        "zip_member_bytes": None if zip_row is None else zip_row["bytes"],
        "installed_exists": inst.is_file(),
        "exact_match_installed_claimed": inst_sha == claimed["installed_sha256"],
        "exact_match_zip_claimed": zip_row is not None and zip_row["archive_member_sha256"] == claimed["archive_member_sha256"],
        "exact_match_zip_installed": zip_row is not None and zip_row["archive_member_sha256"] == inst_sha,
    })

source_tree = json.loads((SANDBOX / "p31-compact-release-binding/source-tree.json").read_text())
source_paths = [x.get("path") for x in source_tree.get("tree", [])]
compiler_like = [
    p for p in source_paths
    if p and any(tok in p.lower() for tok in ["src/", "compiler", "zkir", "compactc.rs", "cargo.toml", "package.json", ".rs", ".ts"])
]
# Keep explicit documentation/prerelease zips out of "compiler source" false positives
compiler_like_filtered = [
    p for p in compiler_like
    if not p.startswith("prerelease/")
    and p not in {".github/workflows/scan.yaml", "CHANGELOG.md", "CODEOWNERS", "CODE_OF_CONDUCT.md", "CONTRIBUTING.md", "LICENSE", "README.md", "SECURITY.md", "renovate.json"}
    and not p.startswith(".github/")
]

license_path = SANDBOX / "p31-zkir-source-preparation/upstream-root/LICENSE"
license_text = license_path.read_text(errors="replace")
license_head = license_text.splitlines()[:3]

release = json.loads((SANDBOX / "p31-compact-release-binding/release.json").read_text())
musl_asset = next(a for a in release["assets"] if a["name"] == "compactc_v0.31.1_x86_64-unknown-linux-musl.zip")

comparison = json.loads((SANDBOX / "p31-zkir-source-preparation/source-comparison.json").read_text())
comparison_vs_recompute = []
for row in comparable_rows:
    claimed = next(x for x in comparison["files"] if x["crate_path"] == row["crate_path"])
    comparison_vs_recompute.append({
        "crate_path": row["crate_path"],
        "blob_match_claimed": row["computed_git_blob"] == claimed["computed_git_blob"],
        "sha_match_claimed": row["crate_sha256"] == claimed["crate_sha256"],
        "commit_match_flags": {
            name: row["commits"][name]["matches_crate"] == claimed["commits"][name]["matches_crate"]
            and row["commits"][name]["blob"] == claimed["commits"][name]["blob"]
            for name in commits
        },
    })

FINISHED = datetime.datetime.now(datetime.timezone.utc).isoformat()
result = {
    "started_utc": STARTED,
    "finished_utc": FINISHED,
    "argv": sys.argv,
    "cwd": os.getcwd(),
    "sandbox": str(SANDBOX),
    "inputs_file_count": len(declared),
    "sha256_match_count": sum(1 for r in sha_rows if r["match"]),
    "sha256_mismatch": mismatch,
    "missing_from_disk": missing,
    "extra_sandbox_files": extra,
    "absent_from_disk": absent_from_disk,
    "crate_archive": {
        "path": str(crate_archive),
        "bytes": crate_archive_bytes,
        "sha256": crate_archive_sha,
        "registry_checksum": crate_meta.get("version", {}).get("checksum"),
        "registry_crate_size": crate_meta.get("version", {}).get("crate_size"),
        "matches_registry_checksum": crate_archive_sha == crate_meta.get("version", {}).get("checksum"),
        "matches_registry_size": crate_archive_bytes == crate_meta.get("version", {}).get("crate_size"),
        "yanked": crate_meta.get("version", {}).get("yanked"),
        "license": crate_meta.get("version", {}).get("license"),
        "bin_names": crate_meta.get("version", {}).get("bin_names"),
    },
    "crate_archive_members": crate_members,
    "crate_extracted_vs_disk": extracted_vs_disk,
    "package_files": package_rows,
    "comparable_files": comparable_rows,
    "tree_meta": tree_meta,
    "comparison_vs_recompute": comparison_vs_recompute,
    "license": {
        "path": str(license_path.relative_to(SANDBOX)),
        "sha256": sha256_path(license_path),
        "bytes": license_path.stat().st_size,
        "head": license_head,
        "mentions_apache_2": "Apache License" in license_text and "Version 2.0" in license_text,
    },
    "release_binding": {
        "archive_path": str(archive_path),
        "archive_bytes": archive_bytes,
        "archive_sha256": archive_sha,
        "claimed_archive_sha256": binding["archive_sha256"],
        "claimed_archive_bytes": binding["archive_bytes"],
        "github_asset_digest": musl_asset.get("digest"),
        "github_asset_id": musl_asset.get("id"),
        "github_asset_size": musl_asset.get("size"),
        "matches_binding_archive": archive_sha == binding["archive_sha256"] and archive_bytes == binding["archive_bytes"],
        "matches_github_asset_digest": archive_sha == musl_asset.get("digest", "").removeprefix("sha256:"),
        "matches_github_asset_size": archive_bytes == musl_asset.get("size"),
        "zip_member_count": len(zip_members),
        "zip_members": zip_members,
        "installed": installed_rows,
        "source_tag_commit": binding["source_tag_commit"],
        "source_tree_sha": source_tree.get("sha"),
        "source_tree_truncated": source_tree.get("truncated"),
        "source_tree_entry_count": len(source_tree.get("tree", [])),
        "source_tree_paths": source_paths,
        "compiler_like_paths_excluding_docs_prerelease": compiler_like_filtered,
    },
    "archive_not_copied_to_reports": True,
}
OUT.write_text(json.dumps(result, indent=2) + "\n")
summary = {
    "started_utc": STARTED,
    "finished_utc": FINISHED,
    "exit": 0 if not mismatch and not missing and not extra else 2,
    "inputs": len(declared),
    "sha256_match": sum(1 for r in sha_rows if r["match"]),
    "mismatch": mismatch,
    "extra": extra,
    "crate_checksum_match": result["crate_archive"]["matches_registry_checksum"],
    "archive_digest_match": result["release_binding"]["matches_github_asset_digest"],
    "installed_all_match": all(r["exact_match_zip_installed"] and r["exact_match_installed_claimed"] for r in installed_rows),
    "comparable_crate_vcs_all_match": all(r["commits"]["crate-vcs"]["matches_crate"] for r in comparable_rows),
    "output": str(OUT),
}
print(json.dumps(summary, indent=2))
sys.exit(summary["exit"])
