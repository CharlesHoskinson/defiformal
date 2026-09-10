#!/usr/bin/env python3
"""Set up isolated private Lean copy and independent R21 inventories."""
from __future__ import annotations

import json
import os
import re
import shutil
from pathlib import Path

from record_cmd import OUT, run_cmd, sha256_file, utc_now

SANDBOX = Path(
    "/home/charl/.cache/defiformal-program/program-execution-20260908/p19-tree-text-grok-r1-sandbox"
)
PACKAGES = Path(
    "/home/charl/.cache/defiformal-program/program-execution-20260908/p19-r7-root-verification/lean/.lake/packages"
)
PREV_BUILD = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-recursive-token-grok-r1/private-lean/.lake/build"
)
PREV_CONFIG = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-recursive-token-grok-r1/private-lean/.lake/config"
)
TOOL = Path("/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin")
SKILLS_BIN = Path("/home/charl/.codex/plugins/cache/lean4-skills/lean4/4.8.7/bin")
PRIVATE = OUT / "private-lean"
CHANGED = ["DefiKernel/Certificates/CanonicalJson.lean"]
UNCHANGED = [
    "DefiKernel/Certificates/Correspondence.lean",
    "DefiKernel/Certificates/Decode.lean",
    "DefiKernel/Certificates/Encode.lean",
    "DefiKernel/Certificates/Schema.lean",
]
CONSUMERS = [
    "DefiKernel/Certificates/Check.lean",
    "DefiKernel/Certificates/Tests.lean",
    "DefiKernel/Certificates/Verify.lean",
    "DefiKernel/Certificates/Observation.lean",
    "DefiKernel/Certificates/Soundness.lean",
    "DefiKernel/Certificates/Audit.lean",
]
DECL_RE = re.compile(r"^(theorem|lemma)\s+([A-Za-z0-9_?'.]+)")
DEF_RE = re.compile(r"^def\s+([A-Za-z0-9_?'.]+)")
R20_HASHES = {
    "CanonicalJson": "67ae180613f04fb6ee652878b01634119fead96f92be2df36d3ee40226c5b0fb",
    "Correspondence": "93a3a29e90a3c844b3d2309240d266b782b3fc7b137e671d12964a217d6ceaa9",
    "Decode": "7561716fe3f2bdba355015de7c1b81e3c594f1d6a51df0009294be248c38a23d",
    "Encode": "9b4fdc4c0b6fd07a13f7552506cf2c6f0d0eaa3e3a31fb590ea974c1261ca3b8",
    "Schema": "24e99089cb0380ab8150ffde06f0f60b4362d345436e4c1e06199b46f9fb961b",
    "Check": "2cd24e9b302de52a85d7999c034cb7b08e4cb3d06b5fe79eb9943d4aa24ad66c",
    "Tests": "c8bee83edb30caf21075e080a6b662de53e451c1a1e9d093a2646589f7ee037b",
    "Verify": "47ba130e824c224e37b63c590329486a6c642403f8e70a7874743a4dc0d53f16",
    "Observation": "d33b251aa1868bc5e7c945e39d629109d2f9f46d2cc652d06d9bac96f5079a62",
    "Soundness": "262e726f0c7380acaaf67cd7d89d9560bc7af568032690f96269275c0c143556",
}
R21_NEW = [
    "nonDigitHead_nil",
    "nonDigitHead_comma",
    "nonDigitHead_colon",
    "nonDigitHead_rbracket",
    "nonDigitHead_rbrace",
    "escapeTreeString_eq",
    "tokenizeFuel_escapeTreeString",
    "toList_comma",
    "toList_colon",
    "toList_lbracket",
    "toList_rbracket",
    "toList_lbrace",
    "toList_rbrace",
    "encode_arr_toList",
    "encode_obj_toList",
    "encodeList_cons_cons_toList",
    "encodeObj_singleton_toList",
    "encodeObj_cons_cons_toList",
    "toDigits_nonempty_length",
    "toString_nat_length_ge_one",
    "toString_int_length_ge_one",
    "escapeTreeString_length_ge_two",
    "tokensList_length_le_encodeList_length",
    "tokensObj_length_le_encodeObj_length",
    "tokens_length_le_encode_length",
    "tokenizeFuel_encodeList",
    "tokenizeFuel_encodeObj",
    "tokenizeFuel_tree",
    "tokenize_tree",
    "parseCanonicalJson_tree",
]
# Delete oleans that must rebuild because CanonicalJson changed and they import it
# or import a module that imports it on the Correspondence target path.
DELETE_OLEAN_RELS = [
    "DefiKernel/Certificates/CanonicalJson.lean",
    "DefiKernel/Certificates/Decode.lean",
    "DefiKernel/Certificates/Check.lean",
    "DefiKernel/Certificates/Observation.lean",
    "DefiKernel/Certificates/Correspondence.lean",
]


def write_json(path: Path, obj) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2) + "\n")


def extract_decls(path: Path) -> list[dict]:
    decls = []
    for i, line in enumerate(path.read_text().splitlines(), 1):
        m = DECL_RE.match(line)
        if m:
            decls.append(
                {
                    "kind": m.group(1),
                    "name": m.group(2),
                    "line": i,
                    "file": path.name,
                }
            )
    return decls


def extract_top_defs(path: Path) -> list[dict]:
    defs = []
    for i, line in enumerate(path.read_text().splitlines(), 1):
        m = DEF_RE.match(line)
        if m:
            defs.append(
                {
                    "kind": "def",
                    "name": m.group(1),
                    "line": i,
                    "file": path.name,
                }
            )
    return defs


def source_scan(path: Path) -> dict:
    text = path.read_text()
    lines = text.splitlines()
    sorry_lines = []
    native_decide_lines = []
    axiom_lines = []
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        if stripped.startswith("--"):
            continue
        if "sorry" in line:
            sorry_lines.append(i)
        if "native_decide" in line:
            native_decide_lines.append(i)
        if re.match(r"^axiom\s+", line):
            axiom_lines.append(i)
    return {
        "path": str(path.relative_to(SANDBOX)),
        "bytes": path.stat().st_size,
        "sha256": sha256_file(path),
        "sorry_lines": sorry_lines,
        "native_decide_lines": native_decide_lines,
        "custom_axiom_lines": axiom_lines,
        "line_count": len(lines),
    }


def parse_print_names(path: Path) -> list[str]:
    names = []
    prefix = "#print axioms "
    for line in path.read_text().splitlines():
        if line.startswith(prefix):
            names.append(line[len(prefix) :].strip())
    return names


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "logs").mkdir(exist_ok=True)
    (OUT / "probes").mkdir(exist_ok=True)
    (OUT / "failed-probes").mkdir(exist_ok=True)
    (OUT / "draft").mkdir(exist_ok=True)

    lean_bin = TOOL / "lean"
    lake_bin = TOOL / "lake"
    shared = TOOL.parent / "lib" / "lean" / "libleanshared.so"
    identity = {
        "toolchain_file": (SANDBOX / "lean" / "lean-toolchain").read_text().strip(),
        "lean_bin": str(lean_bin),
        "lake_bin": str(lake_bin),
        "lean_bin_sha256": sha256_file(lean_bin),
        "lake_bin_sha256": sha256_file(lake_bin),
        "libleanshared_so_sha256": sha256_file(shared) if shared.exists() else "unknown",
        "mathlib_rev": "51e6992efd06126df61a496bebf8f49482a4e129",
        "model_identity": "unknown",
        "live_agy_inspected": False,
        "live_agy_cache_copied": False,
        "r20_cache_copied_from": str(PREV_BUILD),
        "packages_from": str(PACKAGES),
    }
    rec = run_cmd(
        "lean-version",
        [str(lean_bin), "--version"],
        SANDBOX,
        source="pinned-toolchain",
        tool=str(lean_bin),
        note="Pinned Lean identity; do not invent timestamps or model identity.",
    )
    identity["lean_version_exit"] = rec["exit"]
    identity["lean_version_stdout_sha256"] = rec["rawstdout_sha256"]
    write_json(OUT / "logs" / "compiler-identity.json", identity)

    run_cmd(
        "lean4-skills-preflight",
        [str(SKILLS_BIN / "lean4-skills-preflight"), "--codex"],
        SANDBOX,
        source="lean4-skill",
        tool=str(SKILLS_BIN / "lean4-skills-preflight"),
        note="Literal lean4-skills-preflight --codex as required by lean4 SKILL.md.",
    )
    run_cmd(
        "lean4-skills-project-context",
        [
            str(SKILLS_BIN / "lean4-skills-project-context"),
            "--from",
            str(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "CanonicalJson.lean"),
        ],
        SANDBOX,
        source="lean4-skill",
        tool=str(SKILLS_BIN / "lean4-skills-project-context"),
    )

    src_hashes = {}
    for rel in CHANGED + UNCHANGED + CONSUMERS + [
        "lake-manifest.json",
        "lean-toolchain",
        "lakefile.toml",
    ]:
        p = SANDBOX / "lean" / rel
        src_hashes[rel] = {"sha256": sha256_file(p), "bytes": p.stat().st_size}
    write_json(OUT / "logs" / "frozen-source-hashes.json", src_hashes)

    hash_cmp = {}
    for name, old in R20_HASHES.items():
        rel = f"DefiKernel/Certificates/{name}.lean"
        now = src_hashes[rel]["sha256"]
        hash_cmp[name] = {
            "r20": old,
            "r21": now,
            "unchanged": old == now,
        }
    write_json(OUT / "logs" / "r20-r21-source-hash-compare.json", hash_cmp)

    scans = {rel: source_scan(SANDBOX / "lean" / rel) for rel in CHANGED + UNCHANGED}
    write_json(OUT / "logs" / "source-forbidden-scan.json", scans)

    author_proof = (
        SANDBOX
        / "review/semantic-kernel/certificates/p19/implementation/agy-r21-proof"
    )
    write_json(
        OUT / "logs" / "author-evidence-gap.json",
        {
            "requested_agy_r21_proof": str(author_proof),
            "exists": author_proof.exists(),
            "is_dir": author_proof.is_dir() if author_proof.exists() else False,
            "note": "Requested author proof directory is absent. No R21 author commands/REPORT/MANIFEST or raw build/test receipts credited.",
        },
    )

    if PRIVATE.exists():
        shutil.rmtree(PRIVATE)

    def ignore_lake(dirpath, names):
        if Path(dirpath).name == "lean" and ".lake" in names:
            return {".lake"}
        return set()

    shutil.copytree(SANDBOX / "lean", PRIVATE, ignore=ignore_lake, symlinks=True)
    lake_dir = PRIVATE / ".lake"
    lake_dir.mkdir(exist_ok=True)
    packages_link = lake_dir / "packages"
    if packages_link.exists() or packages_link.is_symlink():
        packages_link.unlink()
    os.symlink(PACKAGES, packages_link)
    if PREV_BUILD.exists():
        shutil.copytree(PREV_BUILD, lake_dir / "build", symlinks=True, dirs_exist_ok=True)
    if PREV_CONFIG.exists():
        shutil.copytree(PREV_CONFIG, lake_dir / "config", symlinks=True, dirs_exist_ok=True)

    deleted = []
    for rel in DELETE_OLEAN_RELS:
        stem = Path(rel).with_suffix("")
        for root in [lake_dir / "build" / "lib" / "lean", lake_dir / "build" / "ir"]:
            base = root / stem
            for ext in [
                ".olean",
                ".olean.hash",
                ".ilean",
                ".ilean.hash",
                ".trace",
                ".c",
                ".c.hash",
                ".setup.json",
            ]:
                p = Path(str(base) + ext)
                if p.exists():
                    p.unlink()
                    deleted.append(str(p.relative_to(lake_dir)))

    setup_note = {
        "private_lean": str(PRIVATE),
        "packages_symlink": str(packages_link),
        "packages_target": str(PACKAGES),
        "packages_is_symlink": packages_link.is_symlink(),
        "packages_target_exists": PACKAGES.exists(),
        "packages_target_is_dir": PACKAGES.is_dir(),
        "build_cache_copied_from": str(PREV_BUILD) if PREV_BUILD.exists() else None,
        "config_copied_from": str(PREV_CONFIG) if PREV_CONFIG.exists() else None,
        "live_agy_cache_copied": False,
        "changed_oleans_deleted": DELETE_OLEAN_RELS,
        "deleted_artifacts": deleted,
        "sandbox_sources_written": False,
        "live_agy_inspected": False,
        "encode_oleans_deleted": False,
        "soundness_tests_verify_audit_oleans_deleted": False,
        "started": utc_now(),
    }
    write_json(OUT / "logs" / "private-lean-setup.json", setup_note)

    cj = extract_decls(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "CanonicalJson.lean")
    co = extract_decls(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "Correspondence.lean")
    named = cj + co
    theorems = [d for d in named if d["kind"] == "theorem"]
    lemmas = [d for d in named if d["kind"] == "lemma"]
    current_names = [d["name"] for d in named]
    fq_names = [f"DefiKernel.Certificates.{d['name']}" for d in named]

    cj_defs = extract_top_defs(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "CanonicalJson.lean")
    co_defs = extract_top_defs(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "Correspondence.lean")

    root_axioms = SANDBOX / "root-context" / "p19-r21-root-inventory" / "Axioms.lean"
    root_names = parse_print_names(root_axioms)
    root_inv = json.loads(
        (SANDBOX / "root-context" / "p19-r21-root-inventory" / "inventory.json").read_text()
    )

    missing_new = [n for n in R21_NEW if n not in current_names]
    extra_new = [n for n in current_names if n in R21_NEW]
    dotted = [n for n in current_names if "." in n]

    inventory = {
        "CanonicalJson_theorems": len([d for d in cj if d["kind"] == "theorem"]),
        "CanonicalJson_lemmas": [d["name"] for d in cj if d["kind"] == "lemma"],
        "CanonicalJson_named": len(cj),
        "Correspondence_theorems": len([d for d in co if d["kind"] == "theorem"]),
        "Correspondence_lemmas": [d["name"] for d in co if d["kind"] == "lemma"],
        "Correspondence_named": len(co),
        "named_total": len(named),
        "theorem_total": len(theorems),
        "lemma_total": len(lemmas),
        "CanonicalJson_names": [d["name"] for d in cj],
        "Correspondence_names": [d["name"] for d in co],
        "fq_names": fq_names,
        "decls": named,
        "new_theorem_names_expected": R21_NEW,
        "new_theorem_names_present": extra_new,
        "new_theorem_names_missing": missing_new,
        "new_theorem_count": len(extra_new),
        "includes_exprDepth_pos": "exprDepth_pos" in current_names,
        "exprDepth_pos_kind": next((d["kind"] for d in named if d["name"] == "exprDepth_pos"), None),
        "dotted_TreeJson_names": dotted,
        "NonDigitHead_def_present": any(d["name"] == "NonDigitHead" for d in cj_defs),
        "CanonicalJson_top_defs": [d["name"] for d in cj_defs],
        "Correspondence_top_defs": [d["name"] for d in co_defs],
        "root_inventory_count": len(root_inv.get("names", [])),
        "root_print_count": len(root_names),
        "source_fq_equals_root_names": fq_names == root_inv.get("names", []),
        "source_fq_set_equals_root_names": set(fq_names) == set(root_inv.get("names", [])),
        "source_minus_root": sorted(set(fq_names) - set(root_inv.get("names", []))),
        "root_minus_source": sorted(set(root_inv.get("names", [])) - set(fq_names)),
        "note": "Independent source extraction of ^theorem|^lemma only. Definitions/generated declarations are separate. No R21 author 434/465 inventory claim.",
    }
    write_json(OUT / "probes" / "axioms448" / "inventory.json", inventory)

    probe_dir = OUT / "probes" / "axioms448"
    probe_dir.mkdir(parents=True, exist_ok=True)
    lines = [
        "import DefiKernel.Certificates.Correspondence",
        '#eval IO.println "PROBE_AXIOMS_START"',
    ]
    for name in fq_names:
        lines.append(f"#print axioms {name}")
    lines.append('#eval IO.println "PROBE_AXIOMS_END"')
    lines.append(f'#eval IO.println "NAMED={len(fq_names)}"')
    (probe_dir / "Probe.lean").write_text("\n".join(lines) + "\n")
    shutil.copyfile(root_axioms, probe_dir / "RootAxioms.copied.lean")

    write_json(
        OUT / "logs" / "probe-source-hashes.json",
        {
            "axioms448": {"sha256": sha256_file(probe_dir / "Probe.lean"), "bytes": (probe_dir / "Probe.lean").stat().st_size},
            "RootAxioms.copied": {"sha256": sha256_file(probe_dir / "RootAxioms.copied.lean")},
            "root_Axioms": {"sha256": sha256_file(root_axioms)},
            "probe_equals_root_axioms_bytes": sha256_file(probe_dir / "Probe.lean") == sha256_file(root_axioms),
        },
    )

    print(
        json.dumps(
            {
                "private_lean": str(PRIVATE),
                "named_total": len(named),
                "CanonicalJson_named": len(cj),
                "Correspondence_named": len(co),
                "lemmas": [d["name"] for d in lemmas],
                "new_theorem_count": len(extra_new),
                "missing_new": missing_new,
                "includes_exprDepth_pos": "exprDepth_pos" in current_names,
                "dotted": dotted,
                "source_fq_equals_root_names": fq_names == root_inv.get("names", []),
                "canonicaljson_changed": not hash_cmp["CanonicalJson"]["unchanged"],
                "correspondence_changed": not hash_cmp["Correspondence"]["unchanged"],
                "decode_unchanged": hash_cmp["Decode"]["unchanged"],
                "encode_unchanged": hash_cmp["Encode"]["unchanged"],
                "schema_unchanged": hash_cmp["Schema"]["unchanged"],
                "packages_exists": PACKAGES.exists(),
                "prev_build_exists": PREV_BUILD.exists(),
                "agy_r21_proof_exists": author_proof.exists(),
            },
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
