#!/usr/bin/env python3
"""Set up isolated private Lean copy, inventories, author bindings, and axiom probes."""
from __future__ import annotations

import json
import os
import re
import shutil
from pathlib import Path

from record_cmd import OUT, run_cmd, sha256_file, utc_now

SANDBOX = Path(
    "/home/charl/.cache/defiformal-program/program-execution-20260908/p19-recursive-token-grok-r1-sandbox"
)
PACKAGES = Path(
    "/home/charl/.cache/defiformal-program/program-execution-20260908/p19-r7-root-verification/lean/.lake/packages"
)
PREV_BUILD = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-treejson-inverse-grok-r1/private-lean/.lake/build"
)
PREV_CONFIG = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-treejson-inverse-grok-r1/private-lean/.lake/config"
)
R19_INVENTORY = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-treejson-inverse-grok-r1/probes/axioms343/inventory.json"
)
TOOL = Path("/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin")
SKILLS_BIN = Path("/home/charl/.codex/plugins/cache/lean4-skills/lean4/4.8.7/bin")
PRIVATE = OUT / "private-lean"
CHANGED = [
    "DefiKernel/Certificates/CanonicalJson.lean",
    "DefiKernel/Certificates/Correspondence.lean",
]
UNCHANGED = [
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
EXTRA_DEFS = [
    "IsValueContext",
    "assetToTreeJson",
    "binaryOpToTreeJson",
    "cellRefToTreeJson",
    "domainToTreeJson",
    "exprToTreeJson",
    "numericUnitToTreeJson",
    "observationKeyToTreeJson",
    "observationRefToTreeJson",
    "packedCellRefToTreeJson",
    "packedValueToTreeJson",
    "partyRefToTreeJson",
    "partyToTreeJson",
    "ratToTreeJson",
    "unaryOpToTreeJson",
    "unitToTreeJson",
]
AUTHOR_PRINT_RE = re.compile(
    r"^#print axioms DefiKernel\.Certificates\.([A-Za-z0-9_?'.]+)$"
)
R19_HASHES = {
    "CanonicalJson": "abf8fb4d5ee4a5a814204f95e67586b29d7969a5d913ce2373655f7ddf81b120",
    "Correspondence": "8797e9866c79c08a16d7fe0149faa2b86940dd34660480342ef3c1b3d333e28b",
    "Decode": "7561716fe3f2bdba355015de7c1b81e3c594f1d6a51df0009294be248c38a23d",
    "Encode": "9b4fdc4c0b6fd07a13f7552506cf2c6f0d0eaa3e3a31fb590ea974c1261ca3b8",
    "Schema": "24e99089cb0380ab8150ffde06f0f60b4362d345436e4c1e06199b46f9fb961b",
    "Check": "2cd24e9b302de52a85d7999c034cb7b08e4cb3d06b5fe79eb9943d4aa24ad66c",
    "Tests": "c8bee83edb30caf21075e080a6b662de53e451c1a1e9d093a2646589f7ee037b",
    "Verify": "47ba130e824c224e37b63c590329486a6c642403f8e70a7874743a4dc0d53f16",
    "Observation": "d33b251aa1868bc5e7c945e39d629109d2f9f46d2cc652d06d9bac96f5079a62",
    "Soundness": "262e726f0c7380acaaf67cd7d89d9560bc7af568032690f96269275c0c143556",
}


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
    }


def parse_author_names(path: Path) -> list[str]:
    names = []
    for line in path.read_text().splitlines():
        m = AUTHOR_PRINT_RE.match(line)
        if m:
            names.append(m.group(1))
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
            str(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "Correspondence.lean"),
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
    for name, old in R19_HASHES.items():
        rel = f"DefiKernel/Certificates/{name}.lean"
        now = src_hashes[rel]["sha256"]
        hash_cmp[name] = {
            "r19": old,
            "r20": now,
            "unchanged": old == now,
        }
    write_json(OUT / "logs" / "r19-r20-source-hash-compare.json", hash_cmp)

    scans = {rel: source_scan(SANDBOX / "lean" / rel) for rel in CHANGED + UNCHANGED}
    write_json(OUT / "logs" / "source-forbidden-scan.json", scans)

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

    delete_rels = CHANGED + [
        "DefiKernel/Certificates/Encode.lean",
        "DefiKernel/Certificates/Check.lean",
        "DefiKernel/Certificates/Observation.lean",
        "DefiKernel/Certificates/Soundness.lean",
        "DefiKernel/Certificates/Tests.lean",
        "DefiKernel/Certificates/Verify.lean",
        "DefiKernel/Certificates/Audit.lean",
    ]
    deleted = []
    for rel in delete_rels:
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
        "live_agy_cache_copied": False,
        "changed_oleans_deleted": delete_rels,
        "deleted_artifacts": deleted,
        "sandbox_sources_written": False,
        "live_agy_inspected": False,
        "started": utc_now(),
    }
    write_json(OUT / "logs" / "private-lean-setup.json", setup_note)

    cj = extract_decls(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "CanonicalJson.lean")
    co = extract_decls(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "Correspondence.lean")
    named = cj + co
    theorems = [d for d in named if d["kind"] == "theorem"]
    lemmas = [d for d in named if d["kind"] == "lemma"]
    current_names = [d["name"] for d in named]
    current_theorems = [d["name"] for d in theorems]

    r19_names = []
    if R19_INVENTORY.exists():
        prev = json.loads(R19_INVENTORY.read_text())
        r19_names = prev.get("CanonicalJson_names", []) + prev.get("Correspondence_names", [])
    missing_prev = [n for n in r19_names if n not in current_names]
    new_theorems_lemmas = [n for n in current_names if n not in r19_names]

    cj_defs = extract_top_defs(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "CanonicalJson.lean")
    co_defs = extract_top_defs(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "Correspondence.lean")
    all_top_defs = cj_defs + co_defs
    extra_defs = []
    extra_missing = []
    extra_found_names = {d["name"] for d in all_top_defs}
    for name in EXTRA_DEFS:
        hits = [d for d in all_top_defs if d["name"] == name]
        if hits:
            extra_defs.append(hits[0])
        else:
            extra_missing.append(name)

    author_probe = (
        SANDBOX
        / "review/semantic-kernel/certificates/p19/implementation/agy-r20-proof/probes/named_axioms_434.lean"
    )
    root_author = SANDBOX / "root-context" / "p19-r20-root-scope" / "Author434.lean"
    author_names = parse_author_names(author_probe)
    root_names = parse_author_names(root_author)
    named_plus_defs = current_names + [d["name"] for d in extra_defs]

    inventory = {
        "CanonicalJson_theorems": len([d for d in cj if d["kind"] == "theorem"]),
        "CanonicalJson_lemmas": [d["name"] for d in cj if d["kind"] == "lemma"],
        "Correspondence_theorems": len([d for d in co if d["kind"] == "theorem"]),
        "Correspondence_lemmas": [d["name"] for d in co if d["kind"] == "lemma"],
        "named_total_418": len(named),
        "theorem_total": len(theorems),
        "lemma_total": len(lemmas),
        "CanonicalJson_names": [d["name"] for d in cj],
        "Correspondence_names": [d["name"] for d in co],
        "decls": named,
        "previous_r19_named": len(r19_names),
        "missing_previous_r19": missing_prev,
        "new_theorem_lemma_names": new_theorems_lemmas,
        "new_theorem_lemma_count": len(new_theorems_lemmas),
        "includes_exprDepth_pos": "exprDepth_pos" in current_names,
        "extra_defs": extra_defs,
        "extra_defs_count": len(extra_defs),
        "extra_defs_missing": extra_missing,
        "named_plus_16_defs_total": len(named_plus_defs),
        "author434_count": len(author_names),
        "root_author434_count": len(root_names),
        "author434_equals_root": author_names == root_names,
        "author434_set_equals_418_plus_16": set(author_names) == set(named_plus_defs),
        "author434_order_equals_source_418_plus_16": author_names == named_plus_defs,
        "author_minus_source": sorted(set(author_names) - set(named_plus_defs)),
        "source_minus_author": sorted(set(named_plus_defs) - set(author_names)),
        "note": "Independent source extraction of ^theorem|^lemma (418) plus explicit 16 defs. exprDepth_pos predates R17.",
    }
    write_json(OUT / "probes" / "axioms434" / "inventory.json", inventory)

    probe_dir = OUT / "probes" / "axioms434"
    probe_dir.mkdir(parents=True, exist_ok=True)
    lines = [
        "import DefiKernel.Certificates.Correspondence",
        '#eval IO.println "PROBE_AXIOMS_START"',
    ]
    for name in named_plus_defs:
        lines.append(f"#print axioms DefiKernel.Certificates.{name}")
    lines.append('#eval IO.println "PROBE_AXIOMS_END"')
    lines.append(f'#eval IO.println "NAMED_PLUS_DEFS={len(named_plus_defs)}"')
    lines.append(f'#eval IO.println "THEOREMS_LEMMAS={len(named)}"')
    (probe_dir / "Probe.lean").write_text("\n".join(lines) + "\n")

    # Copy Author434 independently as a comparison artifact, not executed as the probe.
    shutil.copyfile(root_author, probe_dir / "Author434.copied.lean")

    author_cmds = json.loads(
        (
            SANDBOX
            / "review/semantic-kernel/certificates/p19/implementation/agy-r20-proof/commands.json"
        ).read_text()
    )
    author_root = SANDBOX / "review/semantic-kernel/certificates/p19/implementation/agy-r20-proof"
    bindings = []
    for cmd in author_cmds:
        stdout_p = author_root / cmd["rawstdout"]
        stderr_p = author_root / cmd["rawstderr"]
        recb = {
            "id": cmd["id"],
            "name": cmd.get("name"),
            "argv": cmd.get("argv"),
            "cwd": cmd.get("cwd"),
            "start": cmd.get("start"),
            "end": cmd.get("end"),
            "exit": cmd.get("exit"),
            "claimed_stdout_sha256": cmd.get("stdout_sha256"),
            "claimed_stderr_sha256": cmd.get("stderr_sha256"),
            "actual_stdout_sha256": sha256_file(stdout_p) if stdout_p.exists() else None,
            "actual_stderr_sha256": sha256_file(stderr_p) if stderr_p.exists() else None,
            "stdout_exists": stdout_p.exists(),
            "stderr_exists": stderr_p.exists(),
            "stdout_bytes": stdout_p.stat().st_size if stdout_p.exists() else None,
            "stderr_bytes": stderr_p.stat().st_size if stderr_p.exists() else None,
            "probe": cmd.get("probe"),
            "probe_sha256_claimed": cmd.get("probe_sha256"),
        }
        recb["stdout_hash_match"] = recb["actual_stdout_sha256"] == recb["claimed_stdout_sha256"]
        recb["stderr_hash_match"] = recb["actual_stderr_sha256"] == recb["claimed_stderr_sha256"]
        if cmd.get("probe"):
            pp = author_root / cmd["probe"]
            recb["actual_probe_sha256"] = sha256_file(pp) if pp.exists() else None
            recb["probe_hash_match"] = recb["actual_probe_sha256"] == recb["probe_sha256_claimed"]
        bindings.append(recb)

    verify_lines = []
    cmd04 = author_root / "logs" / "cmd-04" / "stdout.log"
    if cmd04.exists():
        for line in cmd04.read_text(errors="replace").splitlines():
            if "AXIOM AUDIT" in line:
                verify_lines.append(line)

    write_json(
        OUT / "logs" / "author-command-bindings.json",
        {
            "count": len(bindings),
            "all_stdout_match": all(b["stdout_hash_match"] for b in bindings),
            "all_stderr_match": all(b["stderr_hash_match"] for b in bindings),
            "cmd02_elapsed_s": None,
            "cmd02_is_named_library_target": True,
            "cmd02_unqualified_full_lake_build": False,
            "verify_summary_lines": verify_lines,
            "commands": bindings,
        },
    )

    probe_hashes = {
        "axioms434": {"sha256": sha256_file(probe_dir / "Probe.lean")},
        "Author434.copied": {"sha256": sha256_file(probe_dir / "Author434.copied.lean")},
        "author_named_axioms_434": {"sha256": sha256_file(author_probe)},
        "root_Author434": {"sha256": sha256_file(root_author)},
    }
    write_json(OUT / "logs" / "probe-source-hashes.json", probe_hashes)

    print(
        json.dumps(
            {
                "private_lean": str(PRIVATE),
                "named_total_418": len(named),
                "theorems": len(theorems),
                "lemmas": [d["name"] for d in lemmas],
                "new_theorem_lemma_count": len(new_theorems_lemmas),
                "extra_defs_count": len(extra_defs),
                "named_plus_16": len(named_plus_defs),
                "missing_previous_r19": missing_prev,
                "canonicaljson_changed": not hash_cmp["CanonicalJson"]["unchanged"],
                "correspondence_changed": not hash_cmp["Correspondence"]["unchanged"],
                "decode_unchanged": hash_cmp["Decode"]["unchanged"],
                "encode_unchanged": hash_cmp["Encode"]["unchanged"],
                "schema_unchanged": hash_cmp["Schema"]["unchanged"],
                "author_cmd_bindings": len(bindings),
                "author_stdout_all_match": all(b["stdout_hash_match"] for b in bindings),
                "author_stderr_all_match": all(b["stderr_hash_match"] for b in bindings),
                "author434_set_equals_418_plus_16": set(author_names) == set(named_plus_defs),
                "includes_exprDepth_pos": "exprDepth_pos" in current_names,
                "verify_summary_lines": verify_lines,
            },
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
