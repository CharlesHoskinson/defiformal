#!/usr/bin/env python3
"""Build the P18 token0 operation packet from verified existing evidence.

Counts come from files, not directory names. Schema validity is not credit.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from collections import OrderedDict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
R6 = ROOT / "review/semantic-kernel/uniswap-token0/p16/implementation/grok-r6"
R2 = ROOT / "review/semantic-kernel/uniswap-token0/p16/implementation/grok-r2"
PACKETS = ROOT / "review/semantic-kernel/platform-increment/p18/packets"
PRIMARY = ROOT / "review/semantic-kernel/program-execution-20260908"

MUTANTS = [
    "T0-ID-SKIP",
    "T0-WRAP-SKIP",
    "T0-PROD-SKIP",
    "T0-REQ-SKIP",
    "T0-FLOOR",
    "T0-CHECKED-ADD",
]


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def load(path: Path):
    return json.loads(path.read_text())


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--example-receipt", default=None)
    parser.add_argument("--runtime-receipt", default=None)
    parser.add_argument("--tests-receipt", default=None)
    parser.add_argument("--out", required=True)
    parser.add_argument("--bindings-out", required=True)
    args = parser.parse_args()

    rows = load(R6 / "evm/baseline/rows.json")
    if len(rows) != 12:
        raise SystemExit(f"baseline rows {len(rows)} != 12")
    score = load(R6 / "campaign-score.json")
    if score["baseline"]["denominator"] != 12 or score["baseline"]["ok"] != 12:
        raise SystemExit(f"campaign baseline {score['baseline']}")
    if score["mutants"]["denominator"] != 6 or score["mutants"]["ok"] != 6:
        raise SystemExit(f"campaign mutants {score['mutants']}")
    mutant_score = load(R6 / "evm/mutants/score.json")
    if mutant_score["denominator"] != 6 or mutant_score["ok"] != 6:
        raise SystemExit(f"mutant score {mutant_score}")

    partitions_map: OrderedDict[str, list[str]] = OrderedDict()
    for row in rows:
        partitions_map.setdefault(row["partition"], []).append(row["id"])
    partitions = []
    for pid, cases in partitions_map.items():
        partitions.append(
            {
                "id": pid,
                "description": f"Accepted P16 partition {pid} with {len(cases)} actual case(s).",
                "nonempty": True,
                "count": len(cases),
                "cases": cases,
            }
        )
    nonempty = sum(1 for p in partitions if p["nonempty"])
    empty = sum(1 for p in partitions if not p["nonempty"])

    source_runs = []
    for row in rows:
        obs = load(R6 / f"evm/baseline/{row['id']}/observation.json")
        if obs["stdout_sha256"] is None:
            raise SystemExit(f"missing source log hash {row['id']}")
        source_runs.append(
            {
                "id": f"p16-r6-source-{row['id']}",
                "status": "executed",
                "tool": "evm",
                "exit_code": obs["process_exit"],
                "log_sha256": obs["stdout_sha256"],
                "notes": (
                    f"Reused accepted P16 r6 baseline {row['id']}; "
                    f"class={obs['observation']['class']}; comparison_match={row['comparison']['match']}. "
                    "Private historical argv paths are not part of the public API."
                ),
            }
        )

    bind_sum = load(R6 / "lean/bindings-summary.json")
    bind_receipt = load(R6 / "lean/bindings/receipt.json")
    if bind_sum["denominator"] != 12 or bind_receipt["exit"] != 0:
        raise SystemExit("lean bindings not 12/12")
    model_runs = [
        {
            "id": "p16-r6-lean-bindings",
            "status": "executed",
            "tool": "lake env lean",
            "exit_code": bind_receipt["exit"],
            "log_sha256": bind_receipt["stdout_sha256"],
            "notes": "Reused accepted P16 r6 twelve-row Lean source-binding export. Finite model comparison, not Solidity.",
        }
    ]
    runtime_sum = load(R6 / "lean/runtime-summary.json")
    runtime_receipt_path = R6 / "lean/runtime/receipt.json"
    if runtime_receipt_path.is_file():
        rt = load(runtime_receipt_path)
        model_runs.append(
            {
                "id": "p16-r6-runtime-audit",
                "status": "executed",
                "tool": "lake env lean",
                "exit_code": rt.get("exit", runtime_sum["exit"]),
                "log_sha256": rt.get("stdout_sha256"),
                "notes": f"Reused accepted RuntimeAudit; p16_true={runtime_sum['p16_true']} of denominator {runtime_sum['denominator']}.",
            }
        )

    extra_model = []
    for label, path in (
        ("p18-token0-example", args.example_receipt),
        ("p18-runtime-audit-consumer", args.runtime_receipt),
        ("p18-tests-consumer", args.tests_receipt),
    ):
        if not path:
            continue
        rec = load(Path(path))
        extra_model.append(
            {
                "id": label,
                "status": "executed" if rec.get("exit") == 0 else "blocked",
                "tool": "lake env lean",
                "exit_code": rec.get("exit"),
                "log_sha256": rec.get("stdout_sha256"),
                "notes": f"P18 changed-module/consumer check; classification={rec.get('classification')}.",
            }
        )
    model_runs.extend(extra_model)

    production = []
    controls = []
    for mid in MUTANTS:
        summary = load(R6 / f"evm/mutants/{mid}/summary.json")
        if summary["status"] != "ok" or summary["compile_status"] != "compiled":
            raise SystemExit(f"mutant {mid} not compiled/ok")
        if not summary["designated"]["changed"] or not summary["unaffected_control"]["unchanged"]:
            raise SystemExit(f"mutant {mid} designated/control gate failed")
        production.append(
            {
                "id": mid,
                "status": "compiled_production",
                "designated_observation": summary["designated"]["id"],
                "unaffected_sibling": summary["unaffected_control"]["id"],
                "notes": (
                    f"Reused accepted P16 r6 compiled mutant. designated_changed={summary['designated']['changed']}; "
                    f"unaffected_unchanged={summary['unaffected_control']['unchanged']}; "
                    f"runtime_bytecode_sha256={summary['runtime_bytecode_sha256']}."
                ),
            }
        )
        controls.append(
            {
                "id": f"{mid}-unaffected-{summary['unaffected_control']['id']}",
                "status": "compiled_production",
                "designated_observation": summary["unaffected_control"]["id"],
                "unaffected_sibling": summary["designated"]["id"],
                "notes": (
                    f"Independently verified unaffected control on compiled mutant {mid}. "
                    f"unchanged={summary['unaffected_control']['unchanged']}."
                ),
            }
        )

    sqrt = ROOT / "lean/DefiKernel/ConcentratedLiquidity/SqrtPriceMath.lean"
    proofs = ROOT / "lean/DefiKernel/ConcentratedLiquidity/Token0Proofs.lean"
    source = ROOT / (
        "review/semantic-kernel/program-loop-20260908/"
        "concentrated-liquidity-source-readiness-gpt6-evidence/upstream/contracts/libraries/SqrtPriceMath.sol"
    )
    archive = PRIMARY / "p16-source-candidate-r6.tar.gz"
    proof_archive = PRIMARY / "p16-proof-recorder-candidate-r2.tar.gz"
    for path, expected in (
        (sqrt, "437ceee45ca2b9aa4910128672a7781fc352aba306412a450a6de3523452c82f"),
        (proofs, "fd2e1ffadf85649f20b8b61280dc00282eee7bc02bdc1d828f7ef6094eabc3f9"),
        (source, "ddd62e3a94346248677f30f1ab009ef015e71e4b8696dcca890eeabc9dc6c149"),
        (archive, "8a8a9400e04a63ade06976959faca2a575e8158fa92f31d29e612cdc049ff981"),
        (proof_archive, "62a2b86a3148a38cc9db59658a6843723a81454d8732eae8b23344f2309a1ec8"),
    ):
        actual = sha256_file(path)
        if actual != expected:
            raise SystemExit(f"hash mismatch {path}: {actual} != {expected}")

    theorem_types = load(R2 / "logs/theorem-types.json")
    named_theorems = []
    public = [
        "identity",
        "primary_add",
        "wrap_fallback",
        "prod_fallback",
        "remove_require",
        "remove_primary",
        "add_result_le",
        "addPrimary_fullmath",
        "removePrimary_fullmath",
        "checkedAdd_ok_iff",
        "wrap_ge_iff_sum_fit",
        "product_overflow_iff",
    ]
    by_name = {t["name"]: t for t in theorem_types["theorems"]}
    for short in public:
        rec = by_name.get(short)
        if rec is None:
            raise SystemExit(f"missing theorem {short}")
        path = ROOT / rec["file"]
        named_theorems.append(
            {
                "name": f"DefiKernel.ConcentratedLiquidity.SqrtPriceMath.{short}",
                "module": "DefiKernel.ConcentratedLiquidity.SqrtPriceMath",
                "path": rec["file"],
                "sha256": sha256_file(path),
                "status": "named",
            }
        )

    executed = [r for r in source_runs + model_runs if r["status"] == "executed"]
    unexecuted = [r for r in source_runs + model_runs if r["status"] != "executed"]
    packet = {
        "schema_id": "reusable-verification-platform.p15.evidence-packet",
        "schema_version": "0.1.0",
        "packet_id": "p18.token0.next-price.accepted-p16-increment",
        "packet_status": "ready_for_independent_review",
        "credit_eligible": False,
        "credit_eligible_reason": (
            "Author cannot self-assert complete-operation credit. Independent native Claude Opus "
            "review of this exact P18 candidate is pending. Structural schema validity is not proof, "
            "not source execution, and not acceptance. P16 historical GPT-6 reviews are bound as "
            "recorded_historical evidence, not as this packet's verdict."
        ),
        "operation": {
            "id": "uniswap.v3.token0.next-price",
            "kind": "pure_function",
            "name": "SqrtPriceMath.getNextSqrtPriceFromAmount0RoundingUp",
            "pin_status": "established",
        },
        "identities": {
            "source": {
                "status": "established",
                "kind": "solidity-library-function",
                "path": (
                    "review/semantic-kernel/program-loop-20260908/"
                    "concentrated-liquidity-source-readiness-gpt6-evidence/upstream/contracts/libraries/SqrtPriceMath.sol"
                ),
                "revision": "e3589b192d0be27e100cd0daaf6c97204fdb1899",
                "sha256": sha256_file(source),
                "bytes": source.stat().st_size,
                "compiler": "solc 0.7.6+commit.7338295f",
                "compiler_settings": "optimizer enabled, runs 800, metadata.bytecodeHash none, evmVersion istanbul target; execution fork istanbul",
                "notes": (
                    "Accepted P16 pin. Versioned campaign archive "
                    "review/semantic-kernel/program-execution-20260908/p16-source-candidate-r6.tar.gz "
                    f"sha256={sha256_file(archive)}. Do not substitute a private worktree or cache path."
                ),
            },
            "model": {
                "status": "established",
                "kind": "lean-library",
                "path": "lean/DefiKernel/ConcentratedLiquidity/SqrtPriceMath.lean",
                "revision": "d03abac355e79bde0945df5c52c68a99c4933a9b",
                "sha256": sha256_file(sqrt),
                "bytes": sqrt.stat().st_size,
                "notes": (
                    "Accepted P16 proof/recorder archive "
                    "review/semantic-kernel/program-execution-20260908/p16-proof-recorder-candidate-r2.tar.gz "
                    f"sha256={sha256_file(proof_archive)}. Bytes match grok-r2 used-closure."
                ),
            },
            "tools": [
                {
                    "name": "lake-env-lean",
                    "status": "recorded",
                    "path": None,
                    "version": "Lean 4.33.0-rc2 via lean/lean-toolchain",
                    "sha256": None,
                    "argv": ["lake", "env", "lean"],
                },
                {
                    "name": "solc",
                    "status": "recorded",
                    "path": None,
                    "version": "0.7.6+commit.7338295f",
                    "sha256": "bd69ea85427bf2f4da74cb426ad951dd78db9dfdd01d791208eccc2d4958a6bb",
                    "argv": ["solc"],
                },
                {
                    "name": "evm",
                    "status": "recorded",
                    "path": None,
                    "version": "istanbul selected fork; compiler evmVersion is not the execution fork",
                    "sha256": "d298ce2c811de089d650ed4f9535c0c58efc72e7adee9b61a40b6c10cc26fb5c",
                    "argv": ["evm", "run", "--prestate"],
                },
            ],
        },
        "observation_relation": {
            "id": "token0.pure.next-price",
            "kind": "pure_function",
            "inputs": ["sqrtPX96:uint160", "liquidity:uint128", "amount:uint256", "add:bool"],
            "pre_state": [],
            "outputs": ["uint160"],
            "post_state": [],
            "refusals": [
                "remove-path require product-fit and numerator1 > product",
                "FullMath zero denominator or quotient overflow",
                "fallback LowGasSafeMath.add overflow mapped to checked addOverflow",
                "remove-path SafeCast.toUint160",
            ],
            "includes_ledger_history": False,
            "notes": (
                "Pure helper. No fee, pool storage, vault shares, or sequential composition. "
                "Zero amount is identity success. Model error names are not EVM payloads."
            ),
        },
        "obligation_classes": [
            {
                "class": "model_proof",
                "status": "recorded_historical",
                "claim_boundary": "Accepted P16 branch-equation proofs over the model. Not source refinement.",
                "evidence_refs": [
                    "review/semantic-kernel/program-execution-20260908/P16-PROOF-RECORDER-ACCEPTANCE.md",
                    "review/semantic-kernel/program-execution-20260908/p16-proof-recorder-candidate-r2.tar.gz",
                    "review/semantic-kernel/uniswap-token0/p16/implementation/grok-r2/logs/axiom-inventory.json",
                ],
            },
            {
                "class": "bounded_source_execution",
                "status": "recorded_historical",
                "claim_boundary": "Accepted P16 twelve-row Solidity/EVM comparison and six compiled mutants. Finite, not universal.",
                "evidence_refs": [
                    "review/semantic-kernel/program-execution-20260908/P16-SOURCE-ACCEPTANCE.md",
                    "review/semantic-kernel/program-execution-20260908/p16-source-candidate-r6.tar.gz",
                    "review/semantic-kernel/uniswap-token0/p16/implementation/grok-r6/campaign-score.json",
                ],
            },
            {
                "class": "authenticity_environment_assumption",
                "status": "recorded_historical",
                "claim_boundary": "solc 0.7.6, Istanbul genesis/EVM, and Lean 4.33.0-rc2 identities are recorded, not discharged as compiler-correctness proofs.",
                "evidence_refs": [
                    "review/semantic-kernel/uniswap-token0/p16/implementation/grok-r6/result.json",
                    "lean/lean-toolchain",
                ],
            },
            {
                "class": "representation_correspondence",
                "status": "open",
                "claim_boundary": "P20 remains open. This increment is not a certificate or IR correspondence.",
            },
            {
                "class": "source_refinement",
                "status": "open",
                "claim_boundary": "P30 remains open. Twelve finite comparisons are not a universal refinement theorem.",
            },
        ],
        "theorem_evidence": {
            "theorems": named_theorems,
            "premises": [
                "identity: amount.value = 0 implies getNextSqrtPriceFromAmount0RoundingUp = .ok sqrtP, for either add flag",
                "primary_add: amount ≠ 0, product fits uint256, wrapped denominator sum fits, add=true selects addPrimary/FullMath.mulDivRoundingUp then bare uint160",
                "wrap_fallback: amount ≠ 0, product fits, wrapped numerator1+product overflows, add=true selects addFallback; checkedAdd of floor(numerator1/sqrtP)+amount then divRoundingUp",
                "prod_fallback: amount ≠ 0, product overflows uint256, add=true selects addFallback",
                "remove_require: amount ≠ 0, add=false, product overflow or numerator1 ≤ product yields .error .subUnderflow",
                "remove_primary: amount ≠ 0, add=false, product fits and numerator1 > product selects removePrimary then toUint160",
                "add_result_le: successful add result q satisfies q.value ≤ sqrtP.value",
                "checkedAdd uses Arithmetic.Operations.add, which refuses addOverflow rather than wrapping",
                "source add-path uses wrapping uint256 sum; Lean models that wrap then checked fallback add",
                "no sorry, custom axioms, or native_decide in accepted kernel proofs; transitive axioms are propext, Classical.choice, Quot.sound",
            ],
            "axioms": [
                "propext",
                "Classical.choice",
                "Quot.sound",
                "Inventory: review/semantic-kernel/uniswap-token0/p16/implementation/grok-r2/logs/axiom-inventory.json; 138 theorem chunks; only those three axioms occur. Not re-audited by this P18 publication.",
            ],
            "inventory_ref": "review/semantic-kernel/uniswap-token0/p16/implementation/grok-r2/logs/axiom-inventory.json",
        },
        "executions": {
            "partitions": partitions,
            "source_runs": source_runs,
            "model_runs": model_runs,
        },
        "mutations": {
            "production": production,
            "unaffected_controls": controls,
            "python_only": [],
        },
        "independent_verdict": {
            "reviewer_role": "independent native Claude Opus for this P18 candidate",
            "requested_model": "opus",
            "reported_model": None,
            "verdict": "pending",
            "input_sha256": None,
            "review_path": None,
            "notes": (
                "P16 source campaign independent reviewer: nonauthor GPT-6 root, stock Codex harness; "
                "no separate provider model identity; verdict ACCEPT_WITH_LIMITATIONS; "
                "archive 8a8a9400e04a63ade06976959faca2a575e8158fa92f31d29e612cdc049ff981; "
                "review SHA-256 b711a01859f079386be214245d5a9d239165c03ae79315afd0d907183b3e2265. "
                "P16 proof/recorder independent reviewer: same GPT-6 role; archive "
                "62a2b86a3148a38cc9db59658a6843723a81454d8732eae8b23344f2309a1ec8. "
                "Native P16 author requested grok-4.6/high and reported grok-4.6-build. "
                "Those identities do not accept this P18 packet. Opus reported_model remains null until review."
            ),
        },
        "remaining_obligations": [
            "Independent native Claude Opus review of this exact P18 candidate; leave credit_eligible false until that review.",
            "P17 remains open; do not add P17 packets or claim platform_reuse, vault storage, or token0-vault composition.",
            "P30 source/assembly refinement remains open.",
            "P19/P20 certificates and representation correspondence remain open.",
            "P21 residual liquidity library, compiled M09, and original 45-fixture campaign remain open.",
            "P37 whole-program completion remains open.",
            "Root freeze, integrate, and parent-publish accepted release only to semantic-kernel-pivot; no merge to main.",
            "Compiler/runtime authenticity remains an assumption.",
            "Do not treat packet schema validity as execution or proof credit.",
        ],
        "denominators": {
            "partitions": {
                "declared": len(partitions),
                "nonempty": nonempty,
                "empty": empty,
            },
            "executions": {
                "planned": len(source_runs) + len(model_runs),
                "actually_run": len(executed),
                "unexecuted": len(unexecuted),
            },
            "mutations": {
                "planned": 6,
                "compiled_production": len(production),
                "python_only": 0,
                "unaffected_controls": len(controls),
                "unexecuted": 0,
            },
            "theorems": {"named": len(named_theorems), "not_yet_proved": 0},
            "independent_reviews": {"required": 1, "completed": 0},
        },
        "notes": (
            f"Early accepted-P16 increment. theorem-types source-written count={theorem_types['count']}. "
            "P17 packets omitted because P17 implementation is not accepted. "
            "Old P15 illustrative packets were not rewritten."
        ),
    }

    if packet["denominators"]["partitions"]["nonempty"] == 0:
        raise SystemExit("empty partition denominator")
    if packet["denominators"]["mutations"]["compiled_production"] != 6:
        raise SystemExit("need 6 compiled mutants")
    if packet["denominators"]["mutations"]["unaffected_controls"] != 6:
        raise SystemExit("need 6 unaffected controls")
    if packet["denominators"]["executions"]["actually_run"] == 0:
        raise SystemExit("zero executions")

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(packet, indent=2) + "\n")
    bindings = {
        "sqrt_sha256": sha256_file(sqrt),
        "proofs_sha256": sha256_file(proofs),
        "source_sha256": sha256_file(source),
        "source_archive_sha256": sha256_file(archive),
        "proof_archive_sha256": sha256_file(proof_archive),
        "campaign_score_sha256": sha256_file(R6 / "campaign-score.json"),
        "baseline_rows": 12,
        "partitions_declared": len(partitions),
        "partitions_nonempty": nonempty,
        "compiled_mutants": 6,
        "unaffected_controls": 6,
        "theorems_named": len(named_theorems),
        "theorem_types_count": theorem_types["count"],
        "executions_actually_run": len(executed),
        "p17_packets": 0,
    }
    Path(args.bindings_out).write_text(json.dumps(bindings, indent=2) + "\n")
    print(json.dumps({"out": str(out), "bindings": args.bindings_out, **bindings}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
