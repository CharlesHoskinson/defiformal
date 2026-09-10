#!/usr/bin/env python3
"""Corrected closeout copy of the parent offline binding probe.

Parent probe path:
  review/semantic-kernel/program-execution-20260908/p31-zkir-dependencies-grok-r1/probes/binding-probe.py
Parent SHA-256:
  6ccafe133f2058d1e2c413ca09427a86d24a82330c202b5a59fab196e330a3fe
This copy is not a second independent audit. It repairs two probe defects:
1. Midnight extracted-member paths are relative to the dependency-source-
   preparation root, not each package directory. blst paths stay packet-relative.
2. Four static-claim byte checks used the wrong 0-based line offsets.

Does not write into the sandbox. Does not fetch network. Does not execute
Rust, C, build scripts, compilers, proofs, or capture.py.
Exit 0 only if every asserted relevant boolean is true.
"""
from __future__ import annotations

import datetime
import hashlib
import json
import os
import sys
import tarfile
import tomllib
from pathlib import Path

STARTED = datetime.datetime.now(datetime.timezone.utc).isoformat()
ARGV = list(sys.argv)
CWD = os.getcwd()
SANDBOX = Path(
    "/home/charl/.cache/defiformal-program/program-execution-20260908/"
    "p31-zkir-dependencies-grok-r1-sandbox"
)
REVIEW = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/"
    "p31-zkir-dependencies-grok-r1"
)
BASE = SANDBOX / "review/semantic-kernel/program-execution-20260908"
DEP = BASE / "p31-zkir-dependency-source-preparation"
BLST = BASE / "p31-zkir-blst-source-preparation"
NAV = BASE / "p31-zkir-dependency-navigation"
ZKIR = BASE / "p31-zkir-source-preparation"
OUT = REVIEW / "closeout/probes/binding-probe-corrected.json"


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_path(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def list_files(root: Path) -> list[str]:
    rows = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames.sort()
        for name in sorted(filenames):
            p = Path(dirpath) / name
            rows.append(str(p.relative_to(root)))
    return rows


def python_identity() -> dict:
    exe = Path(sys.executable).resolve()
    row = {
        "executable": str(exe),
        "version": sys.version,
        "hexversion": sys.hexversion,
        "implementation": sys.implementation.name,
    }
    if exe.is_file():
        row["executable_sha256"] = sha256_path(exe)
        row["executable_bytes"] = exe.stat().st_size
    return row


def safe_tar_name(name: str) -> dict:
    issues = []
    if name.startswith("/") or name.startswith("\\"):
        issues.append("absolute")
    if ".." in Path(name).parts:
        issues.append("dotdot")
    if name.startswith("../") or "/../" in name:
        issues.append("traversal")
    if "\x00" in name:
        issues.append("nul")
    return {"name": name, "safe": not issues, "issues": issues}


def excerpt_from_lines(lines: list[str], start: int, end: int) -> str:
    return "\n".join(lines[start - 1 : end]) + "\n"


def parse_lock(path: Path) -> dict:
    data = tomllib.loads(path.read_text())
    packages = data.get("package", [])
    midnight_all = [p for p in packages if p.get("name", "").startswith("midnight-")]
    midnight_selected = [p for p in midnight_all if p.get("name") != "midnight-zkir"]
    zkir = [p for p in packages if p.get("name") == "midnight-zkir"]
    blst = [p for p in packages if p.get("name") == "blst"]
    return {
        "path": str(path.relative_to(SANDBOX)),
        "sha256": sha256_path(path),
        "bytes": path.stat().st_size,
        "lock_package_count": len(packages),
        "midnight_including_zkir": [
            {"name": p["name"], "version": p["version"], "checksum": p.get("checksum")}
            for p in midnight_all
        ],
        "midnight_excluding_zkir": [
            {"name": p["name"], "version": p["version"], "checksum": p.get("checksum")}
            for p in midnight_selected
        ],
        "midnight_excluding_zkir_count": len(midnight_selected),
        "zkir": [
            {"name": p["name"], "version": p["version"], "checksum": p.get("checksum")}
            for p in zkir
        ],
        "blst": [
            {"name": p["name"], "version": p["version"], "checksum": p.get("checksum")}
            for p in blst
        ],
        "by_key": {(p["name"], p["version"]): p for p in packages},
        "raw_packages": packages,
    }


def check_http(http_path: Path, body_path: Path) -> dict:
    http = json.loads(http_path.read_text())
    body_sha = sha256_path(body_path)
    body_bytes = body_path.stat().st_size
    return {
        "http_path": str(http_path.relative_to(SANDBOX)),
        "url": http.get("url"),
        "final_url": http.get("final_url"),
        "status": http.get("status"),
        "recorded_sha256": http.get("sha256"),
        "recorded_bytes": http.get("bytes"),
        "body_sha256": body_sha,
        "body_bytes": body_bytes,
        "status_200": http.get("status") == 200,
        "sha256_binds_body": http.get("sha256") == body_sha,
        "bytes_bind_body": http.get("bytes") == body_bytes,
        "started_utc": http.get("started_utc"),
        "finished_utc": http.get("finished_utc"),
    }


def check_crate_packet(
    packet: Path,
    receipt_path: Path,
    archive_path: Path,
    registry_path: Path,
    lock_pkg: dict | None,
    source_prefix: Path,
    extracted_root: Path,
) -> dict:
    receipt = json.loads(receipt_path.read_text())
    registry = json.loads(registry_path.read_text())
    version = registry.get("version", registry)
    archive_sha = sha256_path(archive_path)
    archive_bytes = archive_path.stat().st_size
    vcs_path = source_prefix / ".cargo_vcs_info.json"
    vcs = json.loads(vcs_path.read_text()) if vcs_path.is_file() else None
    cargo_orig = source_prefix / "Cargo.toml.orig"
    cargo = tomllib.loads(cargo_orig.read_text()) if cargo_orig.is_file() else {}
    license_files = []
    for name in ["LICENSE", "LICENSE-APACHE", "LICENSE-MIT", "COPYING.md"]:
        p = source_prefix / name
        if p.is_file():
            license_files.append(
                {"name": name, "sha256": sha256_path(p), "bytes": p.stat().st_size}
            )
    crate_http = packet / (archive_path.name + ".http.json")
    registry_http = packet / "registry.json.http.json"
    http_rows = []
    if crate_http.is_file():
        http_rows.append(check_http(crate_http, archive_path))
    if registry_http.is_file():
        http_rows.append(check_http(registry_http, registry_path))
    files = {f["tar_member"]: f for f in receipt.get("source_files", [])}
    unsafe = []
    member_rows = []
    tar_names = []
    with tarfile.open(archive_path) as t:
        members = [m for m in t.getmembers() if m.isfile()]
        tar_names = [m.name for m in members]
        for m in members:
            safety = safe_tar_name(m.name)
            if not safety["safe"]:
                unsafe.append(safety)
            rec = files.get(m.name)
            extracted = None
            extracted_sha = None
            extracted_bytes = None
            if rec is not None:
                extracted = extracted_root / rec["path"]
                if extracted.is_file():
                    extracted_sha = sha256_path(extracted)
                    extracted_bytes = extracted.stat().st_size
            tar_bytes = t.extractfile(m).read()
            tar_sha = sha256_bytes(tar_bytes)
            member_rows.append(
                {
                    "tar_member": m.name,
                    "safe": safety["safe"],
                    "issues": safety["issues"],
                    "tar_sha256": tar_sha,
                    "tar_bytes": m.size,
                    "receipt_sha256": None if rec is None else rec.get("sha256"),
                    "extracted_sha256": extracted_sha,
                    "extracted_bytes": extracted_bytes,
                    "tar_matches_receipt": rec is not None and tar_sha == rec.get("sha256"),
                    "extracted_matches_tar": extracted_sha == tar_sha,
                    "size_agrees": rec is not None
                    and m.size == rec.get("bytes")
                    and extracted_bytes == m.size,
                }
            )
    tar_set = set(tar_names)
    rec_set = set(files)
    lock_checksum = None if lock_pkg is None else lock_pkg.get("checksum")
    return {
        "package": receipt.get("package"),
        "version": receipt.get("version"),
        "archive": str(archive_path.relative_to(SANDBOX)),
        "archive_sha256": archive_sha,
        "archive_bytes": archive_bytes,
        "receipt_archive_sha256": receipt.get("archive_sha256"),
        "receipt_archive_bytes": receipt.get("archive_bytes"),
        "lock_checksum": lock_checksum,
        "registry_checksum": version.get("checksum"),
        "registry_crate_size": version.get("crate_size"),
        "registry_yanked": version.get("yanked"),
        "registry_license": version.get("license"),
        "registry_repository": version.get("repository"),
        "cargo_toml_license": (cargo.get("package") or {}).get("license"),
        "cargo_toml_license_file": (cargo.get("package") or {}).get("license-file"),
        "receipt_license": receipt.get("license"),
        "license_files": license_files,
        "receipt_vcs": receipt.get("vcs") or receipt.get("published_vcs_metadata"),
        "extracted_vcs": vcs,
        "vcs_agrees": (receipt.get("vcs") or receipt.get("published_vcs_metadata")) == vcs,
        "archive_matches_lock": archive_sha == lock_checksum,
        "archive_matches_registry": archive_sha == version.get("checksum"),
        "archive_matches_receipt": archive_sha == receipt.get("archive_sha256"),
        "size_matches_registry": archive_bytes == version.get("crate_size"),
        "size_matches_receipt": archive_bytes == receipt.get("archive_bytes"),
        "receipt_file_count": receipt.get("file_count"),
        "tar_file_members": len(members),
        "receipt_source_files": len(files),
        "tar_names_equal_receipt": tar_set == rec_set,
        "missing_from_tar": sorted(rec_set - tar_set),
        "extra_in_tar": sorted(tar_set - rec_set),
        "unsafe_members": unsafe,
        "all_members_safe": not unsafe,
        "all_members_match": all(
            r["tar_matches_receipt"] and r["extracted_matches_tar"] and r["size_agrees"]
            for r in member_rows
        ),
        "http": http_rows,
        "http_all_bind": all(
            h["status_200"] and h["sha256_binds_body"] and h["bytes_bind_body"]
            for h in http_rows
        )
        and len(http_rows) == 2,
        "member_mismatch_count": sum(
            1
            for r in member_rows
            if not (r["tar_matches_receipt"] and r["extracted_matches_tar"] and r["size_agrees"])
        ),
    }


# --- identity ---
inputs = json.loads((REVIEW / "inputs.json").read_text())
declared = inputs["files"]
sha_match = 0
mismatch = []
missing = []
for rel, expected in sorted(declared.items()):
    path = SANDBOX / rel
    if not path.is_file():
        missing.append(rel)
        continue
    actual = sha256_path(path)
    if actual == expected:
        sha_match += 1
    else:
        mismatch.append({"path": rel, "expected": expected, "actual": actual})

present = set(list_files(SANDBOX))
declared_set = set(declared)
extra = sorted(present - declared_set)
absent_from_disk = sorted(declared_set - present)

# --- lock selection ---
lock_dep = parse_lock(DEP / "inputs/Cargo.lock")
lock_blst = parse_lock(BLST / "Cargo.lock")
lock_zkir = parse_lock(ZKIR / "crate/midnight-zkir-2.1.0/Cargo.lock")
lock_sha_agree = (
    lock_dep["sha256"] == lock_blst["sha256"] == lock_zkir["sha256"] == lock_dep["sha256"]
)
expected_midnight = {
    (p["name"], p["version"]): p["checksum"] for p in lock_dep["midnight_excluding_zkir"]
}

# --- midnight packages ---
midnight_packets = []
for receipt_path in sorted(DEP.glob("midnight-*/receipt.json")):
    packet = receipt_path.parent
    receipt = json.loads(receipt_path.read_text())
    archive = DEP / receipt["archive"]
    source_prefix = packet / "source" / f"{receipt['package']}-{receipt['version']}"
    lock_pkg = lock_dep["by_key"].get((receipt["package"], receipt["version"]))
    midnight_packets.append(
        check_crate_packet(
            packet,
            receipt_path,
            archive,
            packet / "registry.json",
            lock_pkg,
            source_prefix,
            DEP,
        )
    )

selected_keys = {(p["package"], p["version"]) for p in midnight_packets}
lock_keys = set(expected_midnight)
zkir_excluded = ("midnight-zkir", "2.1.0") not in selected_keys
zkir_in_lock = any(
    p["name"] == "midnight-zkir" and p["version"] == "2.1.0" for p in lock_dep["zkir"]
)

# --- blst ---
blst_receipt = json.loads((BLST / "receipt.json").read_text())
blst_packet = check_crate_packet(
    BLST,
    BLST / "receipt.json",
    BLST / blst_receipt["archive"],
    BLST / "registry.json",
    lock_dep["by_key"].get(("blst", "0.3.16")),
    BLST / "source/blst-0.3.16",
    BLST,
)

# --- seals ---
dep_seal = json.loads((DEP / "root-seal.json").read_text())["files"]
blst_seal = json.loads((BLST / "root-seal.json").read_text())["files"]
nav_seal = json.loads((NAV / "root-seal.json").read_text())["files"]


def check_seal(root: Path, seal: dict) -> dict:
    disk = {str(p.relative_to(root)) for p in root.rglob("*") if p.is_file()}
    seal_set = set(seal)
    mismatches = []
    for name, digest in seal.items():
        p = root / name
        if not p.is_file():
            mismatches.append({"path": name, "issue": "missing"})
            continue
        actual = sha256_path(p)
        if actual != digest:
            mismatches.append({"path": name, "issue": "hash", "expected": digest, "actual": actual})
    return {
        "sealed_files": len(seal),
        "disk_files": len(disk),
        "disk_equals_seal_plus_root_seal": disk == seal_set | {"root-seal.json"},
        "extra_vs_seal": sorted(disk - seal_set - {"root-seal.json"}),
        "missing_from_disk": sorted(seal_set - disk),
        "hash_mismatches": mismatches,
        "all_seal_hashes_match": not mismatches,
    }


dep_seal_check = check_seal(DEP, dep_seal)
blst_seal_check = check_seal(BLST, blst_seal)
nav_seal_check = check_seal(NAV, nav_seal)

# --- navigation sources and anchors ---
nav = json.loads((NAV / "navigation.json").read_text())
source_rows = []
for key, src in nav["sources"].items():
    path = SANDBOX / src["path"]
    actual = sha256_path(path) if path.is_file() else None
    source_rows.append(
        {
            "id": key,
            "path": src["path"],
            "recorded_sha256": src["sha256"],
            "actual_sha256": actual,
            "match": actual == src["sha256"],
            "bytes": None if not path.is_file() else path.stat().st_size,
        }
    )

anchor_rows = []
for a in nav["anchors"]:
    path = SANDBOX / a["path"]
    text = path.read_text()
    lines = text.splitlines()
    reconstructed = excerpt_from_lines(lines, a["start_line"], a["end_line"])
    reconstructed_sha = sha256_bytes(reconstructed.encode())
    source_sha = sha256_path(path)
    exact_text_match = reconstructed == a["excerpt"]
    first_line = lines[a["start_line"] - 1] if a["start_line"] <= len(lines) else None
    last_line = lines[a["end_line"] - 1] if a["end_line"] <= len(lines) else None
    anchor_rows.append(
        {
            "id": a["id"],
            "path": a["path"],
            "start_line": a["start_line"],
            "end_line": a["end_line"],
            "source_sha256_match": source_sha == a["source_sha256"],
            "excerpt_sha256_recorded": a["excerpt_sha256"],
            "excerpt_sha256_reconstructed": reconstructed_sha,
            "excerpt_sha256_match": reconstructed_sha == a["excerpt_sha256"],
            "excerpt_text_match": exact_text_match,
            "classification": a["classification"],
            "first_line": first_line,
            "last_line": last_line,
        }
    )

# --- blst matcher uniqueness ---
bindings = (BLST / "source/blst-0.3.16/src/bindings.rs").read_text().splitlines()


def match_lines(lines: list[str], needle: str) -> list[dict]:
    return [{"line": i, "text": l} for i, l in enumerate(lines, 1) if needle in l]


unanchored_mul = match_lines(bindings, "pub fn blst_fr_mul")
anchored_mul = match_lines(bindings, "pub fn blst_fr_mul(")
unanchored_add = match_lines(bindings, "pub fn blst_fr_add")
attempt1_needles = {
    "pub fn blst_fr_add": match_lines(bindings, "pub fn blst_fr_add"),
    "pub fn blst_fr_mul": unanchored_mul,
}
attempt2_needles = {
    "pub fn blst_fr_add": match_lines(bindings, "pub fn blst_fr_add"),
    "pub fn blst_fr_mul(": anchored_mul,
}
exports = (BLST / "source/blst-0.3.16/blst/src/exports.c").read_text().splitlines()
consts = (BLST / "source/blst-0.3.16/blst/src/consts.c").read_text().splitlines()
build_rs = (BLST / "source/blst-0.3.16/build.rs").read_text().splitlines()
attempt2_static = [
    {
        "file": "src/bindings.rs",
        "needle": "pub fn blst_fr_add",
        "matches": match_lines(bindings, "pub fn blst_fr_add"),
    },
    {
        "file": "src/bindings.rs",
        "needle": "pub fn blst_fr_mul(",
        "matches": anchored_mul,
    },
    {
        "file": "blst/src/exports.c",
        "needle": "add_mod_256(ret, a, b, BLS12_381_r)",
        "matches": match_lines(exports, "add_mod_256(ret, a, b, BLS12_381_r)"),
    },
    {
        "file": "blst/src/exports.c",
        "needle": "mul_mont_sparse_256(ret, a, b, BLS12_381_r, r0)",
        "matches": match_lines(exports, "mul_mont_sparse_256(ret, a, b, BLS12_381_r, r0)"),
    },
    {
        "file": "blst/src/consts.c",
        "needle": "const vec256 BLS12_381_r =",
        "matches": match_lines(consts, "const vec256 BLS12_381_r ="),
    },
    {
        "file": "build.rs",
        "needle": 'cc.define("__BLST_NO_ASM__", None)',
        "matches": match_lines(build_rs, 'cc.define("__BLST_NO_ASM__", None)'),
    },
    {
        "file": "build.rs",
        "needle": 'match (cfg!(feature = "portable"), cfg!(feature = "force-adx"))',
        "matches": match_lines(
            build_rs, 'match (cfg!(feature = "portable"), cfg!(feature = "force-adx"))'
        ),
    },
]
attempt2_unique = all(len(x["matches"]) == 1 for x in attempt2_static)

# --- field modulus ---
limbs = [
    0xFFFF_FFFF_0000_0001,
    0x53BD_A402_FFFE_5BFE,
    0x3339_D808_09A1_D805,
    0x73ED_A753_299D_7D48,
]
hex_mod = "0x73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001"
from_hex = int(hex_mod, 16)
from_limbs = limbs[0] | (limbs[1] << 64) | (limbs[2] << 128) | (limbs[3] << 192)
jubjub_limbs = [
    0xD097_0E5E_D6F7_2CB7,
    0xA668_2093_CCC8_1082,
    0x0667_3B01_0134_3B00,
    0x0E7D_B4EA_6533_AFA9,
]
jubjub_hex = "0x0e7db4ea6533afa906673b0101343b00a6682093ccc81082d0970e5ed6f72cb7"
jubjub_from_hex = int(jubjub_hex, 16)
jubjub_from_limbs = (
    jubjub_limbs[0]
    | (jubjub_limbs[1] << 64)
    | (jubjub_limbs[2] << 128)
    | (jubjub_limbs[3] << 192)
)
nav_field = nav.get("field_modulus", {})

# --- static claim line extracts ---
hash_rs = (DEP / "midnight-transient-crypto-2.0.0/source/midnight-transient-crypto-2.0.0/src/hash.rs").read_text().splitlines()
repr_rs = (DEP / "midnight-transient-crypto-2.0.0/source/midnight-transient-crypto-2.0.0/src/repr.rs").read_text().splitlines()
curve_rs = (DEP / "midnight-transient-crypto-2.0.0/source/midnight-transient-crypto-2.0.0/src/curve.rs").read_text().splitlines()
ir_vm = (ZKIR / "crate/midnight-zkir-2.1.0/src/ir_vm.rs").read_text().splitlines()
poseidon_cpu = (DEP / "midnight-circuits-6.0.0/source/midnight-circuits-6.0.0/src/hash/poseidon/poseidon_cpu.rs").read_text().splitlines()
poseidon_chip = (DEP / "midnight-circuits-6.0.0/source/midnight-circuits-6.0.0/src/hash/poseidon/poseidon_chip.rs").read_text().splitlines()
fq_rs = (DEP / "midnight-curves-0.2.0/source/midnight-curves-0.2.0/src/bls12_381/fq.rs").read_text().splitlines()
fr_rs = (DEP / "midnight-curves-0.2.0/source/midnight-curves-0.2.0/src/jubjub/fr.rs").read_text().splitlines()
stdlib = (DEP / "midnight-zk-stdlib-1.0.0/source/midnight-zk-stdlib-1.0.0/src/lib.rs").read_text().splitlines()

static_claims = {
    "transient_commit_opening_first": {
        "file": "midnight-transient-crypto-2.0.0/src/hash.rs",
        "lines": [84, 85, 86],
        "texts": hash_rs[83:87],
        "byte_check": hash_rs[84] == "    let mut preimage = vec![opening];"
        and hash_rs[85] == "    value.field_repr(&mut preimage);",
    },
    "field_repr_slice_no_length_prefix": {
        "file": "midnight-transient-crypto-2.0.0/src/repr.rs",
        "lines": [282, 285],
        "texts": repr_rs[281:286],
        "byte_check": repr_rs[281] == "impl FieldRepr for [Fr] {"
        and repr_rs[283] == "        writer.write(self);",
    },
    "zkir_preprocess_inputs_then_outputs": {
        "file": "midnight-zkir-2.1.0/src/ir_vm.rs",
        "lines": [489, 490],
        "texts": ir_vm[488:491],
        "byte_check": "comm_comm_inputs.extend(preimage.inputs.iter());" in ir_vm[488]
        and "comm_comm_inputs.extend(outputs.iter());" in ir_vm[489]
        and not any("opening" in ir_vm[i] for i in range(488, 491)),
        "index_note": "1-based lines 489-490 are ir_vm[488] and ir_vm[489]",
    },
    "circuit_opening_then_inputs_then_outputs_assert_pi1": {
        "file": "midnight-zkir-2.1.0/src/ir_vm.rs",
        "lines": [779, 780, 781, 782, 785],
        "texts": ir_vm[778:785],
        "byte_check": ir_vm[778] == "            let mut preimage = vec![comm_comm_rand];"
        and "preimage.extend(inputs.iter().cloned());" in ir_vm[779]
        and "preimage.extend(outputs.iter().cloned());" in ir_vm[780]
        and "std.poseidon(layouter, &preimage)" in ir_vm[781]
        and "std.assert_equal(layouter, &comm_comm, &public_inputs[1])" in ir_vm[784],
        "index_note": "1-based line 785 is ir_vm[784]; parent probe used ir_vm[785] which is the closing brace",
    },
    "poseidon_cpu_init_inputs_len": {
        "file": "midnight-circuits-6.0.0/src/hash/poseidon/poseidon_cpu.rs",
        "lines": [254],
        "texts": poseidon_cpu[251:257],
        "byte_check": "init(Some(inputs.len()))" in poseidon_cpu[253],
    },
    "poseidon_chip_init_inputs_len": {
        "file": "midnight-circuits-6.0.0/src/hash/poseidon/poseidon_chip.rs",
        "lines": [558],
        "texts": poseidon_chip[557:560],
        "byte_check": "self.init(layouter, Some(inputs.len()))" in poseidon_chip[557],
        "index_note": "1-based line 558 is poseidon_chip[557]; parent listed 559 and checked [558] (absorb)",
    },
    "wrapper_fr_is_outer_scalar_fq": {
        "file": "midnight-transient-crypto-2.0.0/src/curve.rs",
        "lines": [55, 158],
        "texts": [curve_rs[54], curve_rs[157]],
        "byte_check": curve_rs[54] == "    pub type Scalar = midnight_curves::Fq;"
        and curve_rs[157] == "pub struct Fr(pub outer::Scalar);",
    },
    "embedded_scalar_is_midnight_curves_fr": {
        "file": "midnight-transient-crypto-2.0.0/src/curve.rs",
        "lines": [67],
        "texts": [curve_rs[66]],
        "byte_check": curve_rs[66] == "    pub type Scalar = midnight_curves::Fr;",
    },
    "stdlib_field_is_fq": {
        "file": "midnight-zk-stdlib-1.0.0/src/lib.rs",
        "lines": [102],
        "texts": [stdlib[101]],
        "byte_check": stdlib[101] == "type F = midnight_curves::Fq;",
    },
    "fq_wraps_blst_fr": {
        "file": "midnight-curves-0.2.0/src/bls12_381/fq.rs",
        "lines": [29, 319, 333],
        "texts": [fq_rs[28], fq_rs[318], fq_rs[332]],
        "byte_check": fq_rs[28] == "pub struct Fq(pub(crate) blst_fr);"
        and "blst_fr_add" in fq_rs[318]
        and "blst_fr_mul" in fq_rs[332],
    },
    "jubjub_fr_is_limbs_not_blst": {
        "file": "midnight-curves-0.2.0/src/jubjub/fr.rs",
        "lines": [26, 84, 724],
        "texts": [fr_rs[25], fr_rs[83], fr_rs[723]],
        "byte_check": fr_rs[25] == "pub struct Fr(pub(crate) [u64; 4]);"
        and "0xd097_0e5e_d6f7_2cb7" in fr_rs[84]
        and "0x0e7db4ea6533afa906673b0101343b00a6682093ccc81082d0970e5ed6f72cb7"
        in fr_rs[724],
    },
    "pi_skip_preprocess_has_cursor_and_check": {
        "file": "midnight-zkir-2.1.0/src/ir_vm.rs",
        "lines": [421, 424, 431, 432],
        "texts": ir_vm[420:446],
        "byte_check": "I::PiSkip { guard, count }" in ir_vm[420]
        and "public_transcript_inputs_idx -= *count as usize;" in ir_vm[423]
        and "Public transcript input mismatch" in "\n".join(ir_vm[420:446]),
    },
    "pi_skip_circuit_empty_arm": {
        "file": "midnight-zkir-2.1.0/src/ir_vm.rs",
        "lines": [629],
        "texts": [ir_vm[628]],
        "byte_check": ir_vm[628] == "                I::PiSkip { .. } => {}",
    },
    "fq_modulus_hex_line": {
        "file": "midnight-curves-0.2.0/src/bls12_381/fq.rs",
        "lines": [502, 503],
        "texts": fq_rs[501:504],
        "byte_check": hex_mod in fq_rs[502],
    },
    "blst_r_limbs_match_fq": {
        "file": "blst-0.3.16/blst/src/consts.c",
        "lines": [28, 29, 30],
        "texts": consts[27:31],
        "byte_check": "const vec256 BLS12_381_r =" in consts[27]
        and "0xffffffff00000001" in consts[28]
        and "0x53bda402fffe5bfe" in consts[28]
        and "0x3339d80809a1d805" in consts[29]
        and "0x73eda753299d7d48" in consts[29],
        "index_note": "consts.c writes two TO_LIMB_T values per line; parent looked for the second limb on the next line",
    },
    "blst_fr_mul_export_binds_mont": {
        "file": "blst-0.3.16/blst/src/exports.c",
        "lines": [39, 40],
        "texts": exports[38:41],
        "byte_check": exports[38] == "void blst_fr_mul(vec256 ret, const vec256 a, const vec256 b)"
        and "mul_mont_sparse_256(ret, a, b, BLS12_381_r, r0)" in exports[39],
    },
}

# --- navigation blst uncaptured claim ---
nav_boundary = nav.get("specific_external_boundary", [])
nav_names_blst = [x for x in nav_boundary if x.get("name") == "blst"]

# --- failed attempt credit ---
failure = json.loads(
    (BASE / "p31-zkir-blst-root-verification/failure.json").read_text()
)
attempt2 = json.loads(
    (BASE / "p31-zkir-blst-root-verification-attempt2/result.json").read_text()
)
dep_verify = json.loads(
    (BASE / "p31-zkir-dependency-root-verification/result.json").read_text()
)

# --- remaining lock packages ---
lock_names = {(p["name"], p["version"]) for p in lock_dep["raw_packages"]}
captured_keys = selected_keys | {("blst", "0.3.16"), ("midnight-zkir", "2.1.0")}
remaining_external = sorted(lock_names - captured_keys)

probe_src = Path(__file__).read_bytes()
FINISHED = datetime.datetime.now(datetime.timezone.utc).isoformat()

result = {
    "schema": "defiformal-p31-zkir-dependency-review-probe/v1",
    "started_utc": STARTED,
    "finished_utc": FINISHED,
    "cwd": CWD,
    "argv": ARGV,
    "python": python_identity(),
    "probe_source_sha256": sha256_bytes(probe_src),
    "probe_source_bytes": len(probe_src),
    "sandbox": str(SANDBOX),
    "review": str(REVIEW),
    "network_requests": 0,
    "downloaded_code_executions": 0,
    "rust_c_buildscript_compiler_proof_runs": 0,
    "capture_scripts_rerun": 0,
    "identity": {
        "declared_file_count_field": inputs.get("file_count"),
        "declared_mapping_count": len(declared),
        "sha256_match": sha_match,
        "mismatch": mismatch,
        "missing": missing,
        "extra": extra,
        "absent_from_disk": absent_from_disk,
        "all_match": sha_match == len(declared) and not mismatch and not missing and not extra,
    },
    "lock": {
        "dep_lock_sha256": lock_dep["sha256"],
        "blst_packet_lock_sha256": lock_blst["sha256"],
        "zkir_crate_lock_sha256": lock_zkir["sha256"],
        "three_lock_files_byte_identical": lock_dep["sha256"]
        == lock_blst["sha256"]
        == lock_zkir["sha256"],
        "lock_package_count": lock_dep["lock_package_count"],
        "midnight_excluding_zkir_count": lock_dep["midnight_excluding_zkir_count"],
        "midnight_excluding_zkir": lock_dep["midnight_excluding_zkir"],
        "zkir_in_lock": lock_dep["zkir"],
        "blst_in_lock": lock_dep["blst"],
        "selected_packet_keys_equal_lock_keys": selected_keys == lock_keys,
        "zkir_excluded_from_midnight_packets": zkir_excluded,
        "zkir_present_in_lock": zkir_in_lock,
        "captured_named_crates": 13,
        "remaining_external_lock_packages": len(remaining_external),
        "complete_cargo_build_closure": False,
    },
    "midnight_packets": midnight_packets,
    "midnight_summary": {
        "packet_count": len(midnight_packets),
        "all_archive_match_lock_and_registry": all(
            p["archive_matches_lock"]
            and p["archive_matches_registry"]
            and p["archive_matches_receipt"]
            and p["size_matches_registry"]
            for p in midnight_packets
        ),
        "source_members": sum(p["receipt_source_files"] for p in midnight_packets),
        "all_members_safe": all(p["all_members_safe"] for p in midnight_packets),
        "all_members_match": all(p["all_members_match"] for p in midnight_packets),
        "all_http_bind": all(p["http_all_bind"] for p in midnight_packets),
        "all_vcs_agree": all(p["vcs_agrees"] for p in midnight_packets),
        "licenses": [
            {
                "package": p["package"],
                "receipt_license": p["receipt_license"],
                "registry_license": p["registry_license"],
                "cargo_toml_license": p["cargo_toml_license"],
                "cargo_toml_license_file": p["cargo_toml_license_file"],
                "license_files": p["license_files"],
            }
            for p in midnight_packets
        ],
        "yanked_any": any(p["registry_yanked"] for p in midnight_packets),
    },
    "blst_packet": blst_packet,
    "seals": {
        "dependency": dep_seal_check,
        "blst": blst_seal_check,
        "navigation": nav_seal_check,
    },
    "navigation": {
        "source_count": len(source_rows),
        "anchor_count": len(anchor_rows),
        "sources": source_rows,
        "anchors": anchor_rows,
        "all_sources_match": all(s["match"] for s in source_rows),
        "all_anchors_match": all(
            a["source_sha256_match"]
            and a["excerpt_sha256_match"]
            and a["excerpt_text_match"]
            for a in anchor_rows
        ),
        "blst_listed_as_uncaptured_boundary": nav_names_blst,
        "field_modulus_recorded": nav_field,
        "field_modulus_recomputed": {
            "hex": hex_mod,
            "from_hex": str(from_hex),
            "from_limbs": str(from_limbs),
            "limbs_agree_hex": from_hex == from_limbs,
            "matches_navigation_hex": nav_field.get("hex") == hex_mod,
            "matches_navigation_decimal": nav_field.get("decimal") == str(from_hex),
            "bit_length": from_hex.bit_length(),
        },
        "jubjub_fr_modulus": {
            "hex": jubjub_hex,
            "from_hex": str(jubjub_from_hex),
            "from_limbs": str(jubjub_from_limbs),
            "limbs_agree_hex": jubjub_from_hex == jubjub_from_limbs,
            "distinct_from_fq": jubjub_from_hex != from_hex,
        },
    },
    "blst_matcher": {
        "attempt1_credit": failure.get("credit"),
        "attempt1_exit": failure.get("exit"),
        "attempt1_error": failure.get("error"),
        "unanchored_pub_fn_blst_fr_mul_matches": unanchored_mul,
        "anchored_pub_fn_blst_fr_mul_paren_matches": anchored_mul,
        "unanchored_would_fail_uniqueness": len(unanchored_mul) != 1,
        "anchored_is_unique": len(anchored_mul) == 1,
        "attempt2_static_anchors_unique": attempt2_unique,
        "attempt2_static": [
            {
                "file": x["file"],
                "needle": x["needle"],
                "lines": [m["line"] for m in x["matches"]],
                "unique": len(x["matches"]) == 1,
                "text": None if not x["matches"] else x["matches"][0]["text"],
            }
            for x in attempt2_static
        ],
        "attempt2_members": attempt2.get("archive_members_checked"),
        "attempt2_sealed": attempt2.get("sealed_files_checked"),
        "failed_matcher_is_not_crate_defect": True,
        "attempt1_zero_credit": failure.get("credit") is False,
    },
    "static_claims": static_claims,
    "static_claims_all_byte_true": all(v["byte_check"] for v in static_claims.values()),
    "root_verification_records": {
        "dependency_all_passed": dep_verify.get("all_passed"),
        "dependency_source_members": dep_verify.get("source_members_checked"),
        "dependency_sealed": dep_verify.get("sealed_files_checked"),
        "dependency_acceptance": dep_verify.get("acceptance"),
        "blst_attempt1_credit": failure.get("credit"),
        "blst_attempt2_acceptance": attempt2.get("semantic_or_adapter_acceptance"),
        "blst_attempt2_complete_closure": attempt2.get("complete_dependency_build_closure"),
    },
    "inferences_not_byte_proofs": [
        "CPU and circuit PoseidonChip both initialize with inputs.len; this is source alignment, not generated-constraint correspondence or runtime execution.",
        "PiSkip circuit arm is empty; this is a witness/public-instance/skip correspondence boundary, not by itself a soundness proof or a circuit bug.",
        "Source index/resource assumptions and bounded-integer-to-field refinement need an explicit adapter contract.",
        "These 13 captured crates are not a complete Cargo/build closure.",
        "All source captures are pure acquisition; no circuits, proofs, keys, or real execution.",
        "Old mock artifact execution is historical, not a new run.",
        "Build-script platform/feature/assembly selection remains unverified for any installed binary.",
        "Later blst capture closes the named source gap recorded in navigation.json; it does not close all non-Midnight dependencies.",
        "P31 tasks 32.1-4 remain historical readiness; these additions cannot close adapter 32.7, review 32.9, full P31, P19, P20, or the full program.",
    ],
    "acceptance": False,
}

# drop non-serializable lock internals
result["lock"].pop("by_key", None)
# lock raw packages not needed in output
del result["lock"]

lock_public = {
    "dep_lock_sha256": lock_dep["sha256"],
    "blst_packet_lock_sha256": lock_blst["sha256"],
    "zkir_crate_lock_sha256": lock_zkir["sha256"],
    "three_lock_files_byte_identical": lock_dep["sha256"]
    == lock_blst["sha256"]
    == lock_zkir["sha256"],
    "lock_package_count": lock_dep["lock_package_count"],
    "midnight_excluding_zkir_count": lock_dep["midnight_excluding_zkir_count"],
    "midnight_excluding_zkir": lock_dep["midnight_excluding_zkir"],
    "zkir_in_lock": lock_dep["zkir"],
    "blst_in_lock": lock_dep["blst"],
    "selected_packet_keys_equal_lock_keys": selected_keys == lock_keys,
    "zkir_excluded_from_midnight_packets": zkir_excluded,
    "zkir_present_in_lock": zkir_in_lock,
    "captured_named_crates": 13,
    "remaining_external_lock_packages": len(remaining_external),
    "complete_cargo_build_closure": False,
}
result["lock"] = lock_public

asserted = {
    "identity_all_match": result["identity"]["all_match"],
    "three_lock_files_byte_identical": lock_public["three_lock_files_byte_identical"],
    "lock_package_count_347": lock_public["lock_package_count"] == 347,
    "midnight_excluding_zkir_count_12": lock_public["midnight_excluding_zkir_count"] == 12,
    "selected_packet_keys_equal_lock_keys": lock_public["selected_packet_keys_equal_lock_keys"],
    "zkir_excluded_from_midnight_packets": lock_public["zkir_excluded_from_midnight_packets"],
    "midnight_archive_match_lock_and_registry": result["midnight_summary"]["all_archive_match_lock_and_registry"],
    "midnight_source_members_464": result["midnight_summary"]["source_members"] == 464,
    "midnight_members_safe": result["midnight_summary"]["all_members_safe"],
    "midnight_members_match": result["midnight_summary"]["all_members_match"],
    "midnight_http_bind": result["midnight_summary"]["all_http_bind"],
    "midnight_vcs_agree": result["midnight_summary"]["all_vcs_agree"],
    "blst_archive_match": blst_packet["archive_matches_lock"]
    and blst_packet["archive_matches_registry"]
    and blst_packet["size_matches_registry"],
    "blst_members_159": blst_packet["receipt_source_files"] == 159
    and blst_packet["tar_file_members"] == 159,
    "blst_members_match": blst_packet["all_members_match"],
    "blst_http_bind": blst_packet["http_all_bind"],
    "dep_seal_532": dep_seal_check["sealed_files"] == 532
    and dep_seal_check["all_seal_hashes_match"],
    "blst_seal_167": blst_seal_check["sealed_files"] == 167
    and blst_seal_check["all_seal_hashes_match"],
    "nav_9_sources": result["navigation"]["source_count"] == 9
    and result["navigation"]["all_sources_match"],
    "nav_14_anchors": result["navigation"]["anchor_count"] == 14
    and result["navigation"]["all_anchors_match"],
    "fq_limbs_agree_hex": result["navigation"]["field_modulus_recomputed"]["limbs_agree_hex"],
    "jubjub_distinct_from_fq": result["navigation"]["jubjub_fr_modulus"]["distinct_from_fq"],
    "attempt1_unanchored_not_unique": result["blst_matcher"]["unanchored_would_fail_uniqueness"],
    "attempt2_static_unique": result["blst_matcher"]["attempt2_static_anchors_unique"],
    "static_claims_all_byte_true": result["static_claims_all_byte_true"],
    "complete_cargo_build_closure_false": lock_public["complete_cargo_build_closure"] is False,
}
failed_assertions = [k for k, v in asserted.items() if v is not True]
exit_code = 0 if not failed_assertions else 1
result["asserted"] = asserted
result["failed_assertions"] = failed_assertions
result["exit_code"] = exit_code
result["parent_probe_zero_credit_flags"] = {
    "midnight_all_members_match_was_false": True,
    "four_static_claims_were_false": [
        "zkir_preprocess_inputs_then_outputs",
        "circuit_opening_then_inputs_then_outputs_assert_pi1",
        "poseidon_chip_init_inputs_len",
        "blst_r_limbs_match_fq",
    ],
    "parent_unconditional_exit_0": True,
    "credit_for_those_parent_flags": False,
    "reason": "Parent extracted Midnight members from packet/rec[path] and used 0-based offsets that missed the claimed 1-based lines. Those false flags are probe defects, not crate defects.",
}
FINISHED = datetime.datetime.now(datetime.timezone.utc).isoformat()
result["finished_utc"] = FINISHED
OUT.write_text(json.dumps(result, indent=2) + "\n")
summary = {
    "started_utc": STARTED,
    "finished_utc": FINISHED,
    "cwd": CWD,
    "argv": ARGV,
    "exit": exit_code,
    "identity_match": result["identity"]["all_match"],
    "declared": len(declared),
    "sha256_match": sha_match,
    "extra": extra,
    "missing": missing,
    "midnight_packets": len(midnight_packets),
    "midnight_members": result["midnight_summary"]["source_members"],
    "midnight_members_match": result["midnight_summary"]["all_members_match"],
    "blst_members": blst_packet["receipt_source_files"],
    "blst_members_match": blst_packet["all_members_match"],
    "anchors_match": result["navigation"]["all_anchors_match"],
    "sources_match": result["navigation"]["all_sources_match"],
    "static_claims_all_byte_true": result["static_claims_all_byte_true"],
    "failed_assertions": failed_assertions,
    "attempt1_zero_credit": result["blst_matcher"]["attempt1_zero_credit"],
    "output": str(OUT),
}
print(json.dumps(summary, indent=2))
sys.exit(exit_code)
