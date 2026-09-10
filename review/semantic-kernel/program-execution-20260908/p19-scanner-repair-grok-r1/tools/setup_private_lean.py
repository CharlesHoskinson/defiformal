#!/usr/bin/env python3
"""Set up private Lean copy, record identity/preflight, extract theorem names, write probes."""
from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import stat
from pathlib import Path

from record_cmd import OUT, run_cmd, sha256_file, utc_now

SANDBOX = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p19-scanner-repair-grok-r1-sandbox")
PACKAGES = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p19-r7-root-verification/lean/.lake/packages")
PREV_BUILD = Path("/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-byte-pipeline-grok-r1/private-lean/.lake/build")
PREV_CONFIG = Path("/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-byte-pipeline-grok-r1/private-lean/.lake/config")
TOOL = Path("/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin")
SKILLS_BIN = Path("/home/charl/.codex/plugins/cache/lean4-skills/lean4/4.8.7/bin")
PRIVATE = OUT / "private-lean"
CHANGED = [
    "DefiKernel/Certificates/CanonicalJson.lean",
    "DefiKernel/Certificates/Correspondence.lean",
    "DefiKernel/Certificates/Decode.lean",
    "DefiKernel/Certificates/Encode.lean",
    "DefiKernel/Certificates/Schema.lean",
]


def write_json(path: Path, obj) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2) + "\n")


def extract_decls(path: Path) -> list[dict]:
    decls = []
    text = path.read_text()
    for i, line in enumerate(text.splitlines(), 1):
        m = re.match(r"^(theorem|lemma)\s+([A-Za-z0-9_?']+)", line)
        if m:
            decls.append({"kind": m.group(1), "name": m.group(2), "line": i, "file": str(path.name)})
    return decls


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "logs").mkdir(exist_ok=True)
    (OUT / "probes").mkdir(exist_ok=True)
    (OUT / "failed-probes").mkdir(exist_ok=True)

    # Identity hashes of pinned compiler.
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
        credit=True,
        note="Pinned Lean identity; do not invent timestamps or model identity.",
    )
    identity["lean_version_exit"] = rec["exit"]
    identity["lean_version_stdout_sha256"] = rec["rawstdout_sha256"]
    write_json(OUT / "logs" / "compiler-identity.json", identity)

    rec = run_cmd(
        "lean4-skills-preflight",
        [str(SKILLS_BIN / "lean4-skills-preflight"), "--codex"],
        SANDBOX,
        source="lean4-skill",
        tool=str(SKILLS_BIN / "lean4-skills-preflight"),
        credit=True,
        note="Literal lean4-skills-preflight --codex as required by lean4 SKILL.md.",
    )
    rec = run_cmd(
        "lean4-skills-project-context",
        [
            str(SKILLS_BIN / "lean4-skills-project-context"),
            "--from",
            str(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "Correspondence.lean"),
        ],
        SANDBOX,
        source="lean4-skill",
        tool=str(SKILLS_BIN / "lean4-skills-project-context"),
        credit=True,
    )

    # Frozen source hashes from sandbox (R16 freeze).
    src_hashes = {}
    for rel in CHANGED + [
        "DefiKernel/Certificates/Check.lean",
        "DefiKernel/Certificates/Tests.lean",
        "DefiKernel/Certificates/Verify.lean",
        "DefiKernel/Certificates/Observation.lean",
        "DefiKernel/Certificates/Soundness.lean",
        "DefiKernel/Certificates/Audit.lean",
        "lake-manifest.json",
        "lean-toolchain",
    ]:
        p = SANDBOX / "lean" / rel
        src_hashes[rel] = {"sha256": sha256_file(p), "bytes": p.stat().st_size}
    write_json(OUT / "logs" / "frozen-source-hashes.json", src_hashes)

    # Private lean copy: sources only, packages symlink, private build cache.
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
    # Copy previous private build cache so unchanged modules are not rebuilt.
    if PREV_BUILD.exists():
        shutil.copytree(PREV_BUILD, lake_dir / "build", symlinks=True, dirs_exist_ok=True)
    if PREV_CONFIG.exists():
        shutil.copytree(PREV_CONFIG, lake_dir / "config", symlinks=True, dirs_exist_ok=True)
    # Force rebuild of R16-changed modules.
    for rel in CHANGED:
        stem = Path(rel).with_suffix("")
        for root in [lake_dir / "build" / "lib" / "lean", lake_dir / "build" / "ir"]:
            base = root / stem
            for ext in [".olean", ".olean.hash", ".ilean", ".ilean.hash", ".trace", ".c", ".c.hash", ".setup.json"]:
                p = Path(str(base) + ext)
                if p.exists():
                    p.unlink()
            # also Directory form unused

    setup_note = {
        "private_lean": str(PRIVATE),
        "packages_symlink": str(packages_link),
        "packages_target": str(PACKAGES),
        "packages_is_symlink": packages_link.is_symlink(),
        "build_cache_copied_from": str(PREV_BUILD) if PREV_BUILD.exists() else None,
        "changed_oleans_deleted": CHANGED,
        "sandbox_sources_written": False,
        "live_r17_inspected": False,
        "started": utc_now(),
    }
    write_json(OUT / "logs" / "private-lean-setup.json", setup_note)

    # Independent theorem extraction.
    cj = extract_decls(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "CanonicalJson.lean")
    co = extract_decls(SANDBOX / "lean" / "DefiKernel" / "Certificates" / "Correspondence.lean")
    theorems_cj = [d for d in cj if d["kind"] == "theorem"]
    theorems_co = [d for d in co if d["kind"] == "theorem"]
    lemmas_cj = [d for d in cj if d["kind"] == "lemma"]
    lemmas_co = [d for d in co if d["kind"] == "lemma"]
    inventory = {
        "CanonicalJson_theorems": len(theorems_cj),
        "Correspondence_theorems": len(theorems_co),
        "named_theorems_total": len(theorems_cj) + len(theorems_co),
        "CanonicalJson_lemmas": [d["name"] for d in lemmas_cj],
        "Correspondence_lemmas": [d["name"] for d in lemmas_co],
        "CanonicalJson_names": [d["name"] for d in theorems_cj],
        "Correspondence_names": [d["name"] for d in theorems_co],
        "decls": theorems_cj + theorems_co,
        "lemmas": lemmas_cj + lemmas_co,
        "note": "Independent source extraction of ^theorem/^lemma. Lemma names are not in exact269.",
    }
    write_json(OUT / "probes" / "axioms269" / "inventory.json", inventory)

    # Write axiom probe from extracted names.
    probe_dir = OUT / "probes" / "axioms269"
    probe_dir.mkdir(parents=True, exist_ok=True)
    lines = [
        "import DefiKernel.Certificates.Correspondence",
        "import DefiKernel.Certificates.CanonicalJson",
        '#eval IO.println "PROBE_AXIOMS_START"',
    ]
    for d in theorems_cj + theorems_co:
        lines.append(f"#print axioms DefiKernel.Certificates.{d['name']}")
    lines.append('#eval IO.println "PROBE_AXIOMS_END"')
    lines.append('#eval IO.println s!"NAMED={len(theorems_cj) + len(theorems_co)}"')
    (probe_dir / "Probe.lean").write_text("\n".join(lines) + "\n")

    # Copy root C0 probe into output (do not run against live worktree).
    c0_src = SANDBOX / "root-context" / "p19-r16-escaped-key-root-check" / "Probe.lean"
    c0_dir = OUT / "probes" / "c0-replay"
    c0_dir.mkdir(parents=True, exist_ok=True)
    shutil.copy2(c0_src, c0_dir / "Probe.lean")
    shutil.copy2(c0_src, c0_dir / "root-original-Probe.lean")
    for name in ["assessment.json", "receipt.json", "stderr.log", "stdout.log", "verify.py"]:
        src = SANDBOX / "root-context" / "p19-r16-escaped-key-root-check" / name
        if src.exists():
            shutil.copy2(src, c0_dir / f"root-original-{name}")

    # Preserve R15 failed attempt1 separately; never overwrite.
    failed_src = Path("/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-byte-pipeline-grok-r1/probes/escaped-key/attempt1")
    failed_dst = OUT / "failed-probes" / "r15-escaped-key-attempt1"
    if failed_src.exists() and not failed_dst.exists():
        shutil.copytree(failed_src, failed_dst)
    root_orig = Path("/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-byte-pipeline-grok-r1/probes/escaped-key/root-original/attempt1")
    root_dst = OUT / "failed-probes" / "r15-escaped-key-root-original-attempt1"
    if root_orig.exists() and not root_dst.exists():
        shutil.copytree(root_orig, root_dst)

    print(json.dumps({
        "private_lean": str(PRIVATE),
        "canonicaljson_theorems": len(theorems_cj),
        "correspondence_theorems": len(theorems_co),
        "named_total": len(theorems_cj) + len(theorems_co),
        "lemmas": [d["name"] for d in lemmas_cj + lemmas_co],
        "preflight_exit": rec["exit"] if False else None,
    }))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
