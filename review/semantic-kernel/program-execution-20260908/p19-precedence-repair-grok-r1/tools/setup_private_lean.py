#!/usr/bin/env python3
"""Set up private Lean copy, record identity/preflight, extract theorem+lemma names, write probes."""
from __future__ import annotations

import json
import os
import re
import shutil
from pathlib import Path

from record_cmd import OUT, run_cmd, sha256_file, utc_now

SANDBOX = Path(
    "/home/charl/.cache/defiformal-program/program-execution-20260908/p19-precedence-repair-grok-r1-sandbox"
)
PACKAGES = Path(
    "/home/charl/.cache/defiformal-program/program-execution-20260908/p19-r7-root-verification/lean/.lake/packages"
)
PREV_BUILD = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-rational-inverse-grok-r1/private-lean/.lake/build"
)
PREV_CONFIG = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-rational-inverse-grok-r1/private-lean/.lake/config"
)
R17_INVENTORY = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-rational-inverse-grok-r1/probes/axioms299/inventory.json"
)
R16_INVENTORY = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-scanner-repair-grok-r1/probes/axioms269/inventory.json"
)
TOOL = Path("/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin")
SKILLS_BIN = Path("/home/charl/.codex/plugins/cache/lean4-skills/lean4/4.8.7/bin")
PRIVATE = OUT / "private-lean"
CHANGED = [
    "DefiKernel/Certificates/CanonicalJson.lean",
    "DefiKernel/Certificates/Correspondence.lean",
    "DefiKernel/Certificates/Decode.lean",
]
UNCHANGED_FROM_R17 = [
    "DefiKernel/Certificates/Encode.lean",
    "DefiKernel/Certificates/Schema.lean",
]
DECL_RE = re.compile(r"^(theorem|lemma)\s+([A-Za-z0-9_?']+)")


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
    for rel in CHANGED + UNCHANGED_FROM_R17 + [
        "DefiKernel/Certificates/Check.lean",
        "DefiKernel/Certificates/Tests.lean",
        "DefiKernel/Certificates/Verify.lean",
        "DefiKernel/Certificates/Observation.lean",
        "DefiKernel/Certificates/Soundness.lean",
        "DefiKernel/Certificates/Audit.lean",
        "lake-manifest.json",
        "lean-toolchain",
        "lakefile.toml",
    ]:
        p = SANDBOX / "lean" / rel
        src_hashes[rel] = {"sha256": sha256_file(p), "bytes": p.stat().st_size}
    write_json(OUT / "logs" / "frozen-source-hashes.json", src_hashes)

    r17 = {
        "CanonicalJson": "68335a6e8f7722041689602a782139fdc6c1c127d17544e531ef2e6a0616692c",
        "Correspondence": "bc4c47b988d9952cc31c3ad36ba8ed831025a0e8db95122a10ae77ebe4ca31e4",
        "Decode": "bd38b66b42f6b2a7fb312258ee0abfba0e24f316e085e3768eaa92d95fa1328d",
        "Encode": "9b4fdc4c0b6fd07a13f7552506cf2c6f0d0eaa3e3a31fb590ea974c1261ca3b8",
        "Schema": "24e99089cb0380ab8150ffde06f0f60b4362d345436e4c1e06199b46f9fb961b",
        "Check": "2cd24e9b302de52a85d7999c034cb7b08e4cb3d06b5fe79eb9943d4aa24ad66c",
        "Tests": "c8bee83edb30caf21075e080a6b662de53e451c1a1e9d093a2646589f7ee037b",
        "Verify": "47ba130e824c224e37b63c590329486a6c642403f8e70a7874743a4dc0d53f16",
        "Observation": "d33b251aa1868bc5e7c945e39d629109d2f9f46d2cc652d06d9bac96f5079a62",
        "Soundness": "262e726f0c7380acaaf67cd7d89d9560bc7af568032690f96269275c0c143556",
    }
    hash_cmp = {}
    for name, old in r17.items():
        rel = f"DefiKernel/Certificates/{name}.lean"
        now = src_hashes[rel]["sha256"]
        hash_cmp[name] = {
            "r17": old,
            "r18": now,
            "unchanged": old == now,
        }
    write_json(OUT / "logs" / "r17-r18-source-hash-compare.json", hash_cmp)

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
    for rel in CHANGED:
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
        "changed_oleans_deleted": CHANGED,
        "deleted_artifacts": deleted,
        "sandbox_sources_written": False,
        "live_agy_inspected": False,
        "r19_inspected": False,
        "started": utc_now(),
    }
    write_json(OUT / "logs" / "private-lean-setup.json", setup_note)

    cj = extract_decls(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "CanonicalJson.lean")
    co = extract_decls(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "Correspondence.lean")
    named = cj + co
    theorems = [d for d in named if d["kind"] == "theorem"]
    lemmas = [d for d in named if d["kind"] == "lemma"]
    r17_names = []
    r17_theorems = []
    r17_lemmas = []
    if R17_INVENTORY.exists():
        prev = json.loads(R17_INVENTORY.read_text())
        r17_names = prev.get("CanonicalJson_names", []) + prev.get("Correspondence_names", [])
        r17_theorems = [
            n
            for n in prev.get("CanonicalJson_names", [])
            if n not in prev.get("CanonicalJson_lemmas", [])
        ] + [
            n
            for n in prev.get("Correspondence_names", [])
            if n not in prev.get("Correspondence_lemmas", [])
        ]
        r17_lemmas = prev.get("Correspondence_lemmas", []) + prev.get("CanonicalJson_lemmas", [])
    r16_names = []
    if R16_INVENTORY.exists():
        prev16 = json.loads(R16_INVENTORY.read_text())
        r16_names = prev16.get("CanonicalJson_names", []) + prev16.get("Correspondence_names", [])
    current_names = [d["name"] for d in named]
    current_theorems = [d["name"] for d in theorems]
    missing_prev = [n for n in r17_names if n not in current_names]
    new_theorems = [n for n in current_theorems if n not in r17_names]
    inventory = {
        "CanonicalJson_theorems": len([d for d in cj if d["kind"] == "theorem"]),
        "CanonicalJson_lemmas": [d["name"] for d in cj if d["kind"] == "lemma"],
        "Correspondence_theorems": len([d for d in co if d["kind"] == "theorem"]),
        "Correspondence_lemmas": [d["name"] for d in co if d["kind"] == "lemma"],
        "named_total": len(named),
        "theorem_total": len(theorems),
        "lemma_total": len(lemmas),
        "CanonicalJson_names": [d["name"] for d in cj],
        "Correspondence_names": [d["name"] for d in co],
        "decls": named,
        "previous_r17_named": len(r17_names),
        "previous_r17_theorems": len(r17_theorems) if r17_theorems else None,
        "previous_r17_lemmas": r17_lemmas,
        "previous_r16_named_or_theorems": len(r16_names),
        "missing_previous_r17": missing_prev,
        "new_theorem_names": new_theorems,
        "includes_exprDepth_pos": "exprDepth_pos" in current_names,
        "exprDepth_pos_new_in_r18": False,
        "exprDepth_pos_new_in_r17": "exprDepth_pos" not in r16_names if r16_names else None,
        "note": "Independent source extraction of ^theorem|^lemma. 311 includes lemma exprDepth_pos, which predates R17.",
    }
    write_json(OUT / "probes" / "axioms311" / "inventory.json", inventory)

    probe_dir = OUT / "probes" / "axioms311"
    probe_dir.mkdir(parents=True, exist_ok=True)
    lines = [
        "import DefiKernel.Certificates.Correspondence",
        '#eval IO.println "PROBE_AXIOMS_START"',
    ]
    for d in named:
        lines.append(f"#print axioms DefiKernel.Certificates.{d['name']}")
    lines.append('#eval IO.println "PROBE_AXIOMS_END"')
    lines.append(f'#eval IO.println "NAMED={len(named)}"')
    (probe_dir / "Probe.lean").write_text("\n".join(lines) + "\n")

    root_ctrl = SANDBOX / "root-context" / "p19-r18-root-controls"
    mixed_src = root_ctrl / "mixed-six" / "Probe.lean"
    c0_src = root_ctrl / "c0-controls" / "Probe.lean"
    unt_src = root_ctrl / "unterminated-r18" / "Probe.lean"
    mixed_dst = OUT / "probes" / "mixed-six"
    c0_dst = OUT / "probes" / "c0-controls"
    unt_dst = OUT / "probes" / "unterminated"
    mixed_dst.mkdir(parents=True, exist_ok=True)
    c0_dst.mkdir(parents=True, exist_ok=True)
    unt_dst.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(mixed_src, mixed_dst / "Probe.lean")
    shutil.copyfile(c0_src, c0_dst / "Probe.lean")
    shutil.copyfile(unt_src, unt_dst / "Probe.lean")
    probe_hashes = {
        "mixed-six": {
            "sha256": sha256_file(mixed_dst / "Probe.lean"),
            "source": str(mixed_src),
            "copied_bytes_equal": sha256_file(mixed_dst / "Probe.lean") == sha256_file(mixed_src),
        },
        "c0-controls": {
            "sha256": sha256_file(c0_dst / "Probe.lean"),
            "source": str(c0_src),
            "copied_bytes_equal": sha256_file(c0_dst / "Probe.lean") == sha256_file(c0_src),
        },
        "unterminated": {
            "sha256": sha256_file(unt_dst / "Probe.lean"),
            "source": str(unt_src),
            "copied_bytes_equal": sha256_file(unt_dst / "Probe.lean") == sha256_file(unt_src),
        },
        "axioms311": {"sha256": sha256_file(probe_dir / "Probe.lean")},
    }
    write_json(OUT / "logs" / "probe-source-hashes.json", probe_hashes)

    new_dir = OUT / "probes" / "runtime-acceptance"
    new_dir.mkdir(parents=True, exist_ok=True)
    new_probe = """import DefiKernel.Certificates.Correspondence
open DefiKernel.Certificates
#eval "unterminated_value_space_checkBytes=" ++ reprStr (checkBytes "{\\"a\\": \\"unterminated".toUTF8)
#eval "unterminated_value_no_space_checkBytes=" ++ reprStr (checkBytes "{\\"a\\":\\"unterminated".toUTF8)
#eval "unterminated_key_space_checkBytes=" ++ reprStr (checkBytes "{\\"a\\":1, \\"unterminated".toUTF8)
#eval "unterminated_key_no_space_checkBytes=" ++ reprStr (checkBytes "{\\"a\\":1,\\"unterminated".toUTF8)
#eval "maxBytes_1048577=" ++ reprStr (scanLexical (ByteArray.mk (Array.replicate 1048577 0x7b)))
#eval "maxBytes_1048577_checkBytes=" ++ reprStr (checkBytes (ByteArray.mk (Array.replicate 1048577 0x7b)))
#eval "maxBytes_1048576_not_size_reject=" ++ (if (ByteArray.mk (Array.replicate 1048576 0x7b)).size > 1048576 then "size_gt" else "size_le")
"""
    (new_dir / "Probe.lean").write_text(new_probe)
    probe_hashes["runtime-acceptance"] = {"sha256": sha256_file(new_dir / "Probe.lean")}
    write_json(OUT / "logs" / "probe-source-hashes.json", probe_hashes)

    author_cmds = json.loads(
        (
            SANDBOX
            / "review/semantic-kernel/certificates/p19/implementation/agy-r18-proof/commands.json"
        ).read_text()
    )
    author_root = SANDBOX / "review/semantic-kernel/certificates/p19/implementation/agy-r18-proof"
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
    write_json(
        OUT / "logs" / "author-command-bindings.json",
        {
            "count": len(bindings),
            "all_stdout_match": all(b["stdout_hash_match"] for b in bindings),
            "all_stderr_match": all(b["stderr_hash_match"] for b in bindings),
            "commands": bindings,
        },
    )

    print(
        json.dumps(
            {
                "private_lean": str(PRIVATE),
                "named_total": len(named),
                "theorems": len(theorems),
                "lemmas": [d["name"] for d in lemmas],
                "new_theorems": new_theorems,
                "missing_previous_r17": missing_prev,
                "canonicaljson_changed": not hash_cmp["CanonicalJson"]["unchanged"],
                "correspondence_changed": not hash_cmp["Correspondence"]["unchanged"],
                "decode_changed": not hash_cmp["Decode"]["unchanged"],
                "encode_unchanged": hash_cmp["Encode"]["unchanged"],
                "schema_unchanged": hash_cmp["Schema"]["unchanged"],
                "author_cmd_bindings": len(bindings),
                "author_stdout_all_match": all(b["stdout_hash_match"] for b in bindings),
            }
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
