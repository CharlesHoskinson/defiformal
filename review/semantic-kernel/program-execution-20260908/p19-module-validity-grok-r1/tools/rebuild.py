#!/usr/bin/env python3
"""Independent Roundtrip then Verify rebuild in reviewer private-lean."""
from __future__ import annotations

import json
from pathlib import Path

from record_cmd import OUT, run_cmd

TOOL = Path("/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin")
PRIVATE = OUT / "private-lean"
SKILLS_BIN = Path("/home/charl/.codex/plugins/cache/lean4-skills/lean4/4.8.7/bin")


def main() -> int:
    rec_rt = run_cmd(
        "lake-rebuild-roundtrip",
        [str(TOOL / "lake"), "build", "DefiKernel.Certificates.Roundtrip"],
        PRIVATE,
        timeout=1800,
        source="reviewer-private-lean",
        tool=str(TOOL / "lake"),
        note="Independent rebuild of R24 Roundtrip.lean. Initial cache from completed R23 grok review. No author/live cache.",
    )
    rec_vf = run_cmd(
        "lake-rebuild-verify",
        [str(TOOL / "lake"), "build", "DefiKernel.Certificates.Verify"],
        PRIVATE,
        timeout=1800,
        source="reviewer-private-lean",
        tool=str(TOOL / "lake"),
        note="Independent rebuild of Certificates.Verify after new Roundtrip oleans. Named target is Certificates.Verify, not full DefiKernel.",
    )
    rec_sorry = run_cmd(
        "sorry-analyzer-roundtrip",
        [
            str(SKILLS_BIN / "lean4-skills-sorry-analyzer"),
            str(PRIVATE / "DefiKernel" / "Certificates" / "Roundtrip.lean"),
            "--report-only",
        ],
        PRIVATE,
        source="lean4-skill",
        tool=str(SKILLS_BIN / "lean4-skills-sorry-analyzer"),
        note="scripts_only sorry scan of R24 Roundtrip.lean; --report-only so findings are not treated as command failure.",
    )
    print(
        json.dumps(
            {
                "roundtrip_exit": rec_rt["exit"],
                "roundtrip_credit": rec_rt["credit"],
                "verify_exit": rec_vf["exit"],
                "verify_credit": rec_vf["credit"],
                "sorry_exit": rec_sorry["exit"],
            },
            indent=2,
        )
    )
    return 0 if rec_rt["exit"] == 0 and rec_vf["exit"] == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
