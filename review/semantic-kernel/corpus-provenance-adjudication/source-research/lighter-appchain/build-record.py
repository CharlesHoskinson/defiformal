"""Build or verify an offline, draft Lighter evidence packet; never retrieve sources."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[4]
REL = str(OUT.relative_to(ROOT))
UNIT = "unit:lane2:c0:p3"


def digest(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return json.loads((ROOT / path).read_text())


def bind(path, pointer=None):
    data = (ROOT / path).read_bytes()
    result = {"path": path, "sha256": digest(data), "bytes": len(data)}
    if pointer is not None:
        result["pointer"] = pointer
    return result


def resolve(path, pointer):
    value = read(path)
    for part in pointer.strip("/").split("/"):
        value = value[int(part)] if isinstance(value, list) else value[part]
    return value


def write(name, value):
    with (OUT / name).open("x") as stream:
        if isinstance(value, str):
            stream.write(value)
        else:
            json.dump(value, stream, indent=2, ensure_ascii=False)
            stream.write("\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verify-only", action="store_true")
    args = parser.parse_args()
    checks = []

    def check(name, result):
        checks.append({"name": name, "pass": bool(result)})
        if not result:
            raise AssertionError(name)

    before = read(REL + "/input-protection-before.json")
    for path, expected in before["files"].items():
        check("protected-before:" + path, bind(path)["sha256"] == expected)
    immutable_names = ["capture.py", "retrievals.json", "extraction.json",
                       "input-protection-before.json", "architecture.txt", "whitepaper.txt", "api.txt"]
    immutable = {name: bind(REL + "/" + name) for name in immutable_names}
    retrievals = read(REL + "/retrievals.json")
    extraction = read(REL + "/extraction.json")
    sources = {row["source_id"]: row for row in retrievals["records"]}
    check("exact-three-source-ids", set(sources) == {"architecture", "whitepaper", "api"})
    total_bytes = 0
    for sid, row in sources.items():
        check("single-successful-retained-attempt:" + sid,
              len(row["attempts"]) == 1 and row["attempts"][0]["http_status"] == 200
              and row["status"] == "retained")
        attempt = row["attempts"][0]
        captured = bind(attempt["capture_path"])
        check("body-binding:" + sid, captured["sha256"] == attempt["body_sha256"]
              and captured["bytes"] == attempt["body_bytes"])
        total_bytes += captured["bytes"]
        immutable["capture:" + sid] = captured
        derived = next(x for x in extraction["sources"] if x["source_id"] == sid)
        check("extraction-binding:" + sid,
              derived["sha256"] == captured["sha256"]
              and derived["capture_path"] == captured["path"]
              and bind(REL + "/" + sid + ".txt")["sha256"] == derived["output_sha256"])
    check("exact-body-byte-total", total_bytes == 3544373)
    check("api-redirect-preserved", sources["api"]["attempts"][0]["final_url"]
          == "https://docs.lighter.xyz/trading/api")
    # Repeat the retained PDF extraction into stdout; preserve all existing bytes.
    method = next(x for x in extraction["methods"] if x["source_id"] == "whitepaper")
    tool = Path(method["argv"][0])
    check("pdf-tool-binding", digest(tool.read_bytes()) == method["tool_sha256"])
    pdf_command = [str(tool), "-layout", sources["whitepaper"]["attempts"][0]["capture_path"], "-"]
    pdf_result = subprocess.run(pdf_command, cwd=ROOT, capture_output=True)
    check("pdf-extraction-reproduced", pdf_result.returncode == 0
          and pdf_result.stdout == (OUT / "whitepaper.txt").read_bytes()
          and not pdf_result.stderr)
    if args.verify_only:
        manifest = read(REL + "/artifact-manifest.json")
        for item in manifest["files"]:
            check("manifest:" + item["path"], bind(item["path"]) == item)
        locators = read(REL + "/evidence-locators.json")["locators"]
    else:
        locators = []

        def span(sid, name, start, end=None):
            data = (OUT / (sid + ".txt")).read_bytes()
            needle = start.encode()
            check("unique-start:" + name, data.count(needle) == 1)
            a = data.index(needle)
            if end is None:
                b = data.index(b"\n", a)
            else:
                closing = end.encode()
                check("unique-end:" + name, data.count(closing) == 1)
                b = data.index(closing, a) + len(closing)
            locators.append({
                "id": sid + ":" + name, "source_id": sid,
                "original_capture": bind(sources[sid]["attempts"][0]["capture_path"]),
                "derived_text": bind(REL + "/" + sid + ".txt"),
                "extraction_record": bind(REL + "/extraction.json"),
                "extraction_method": next(x for x in extraction["methods"] if x["source_id"] == sid),
                "coordinate_space": "Derived UTF-8 text bytes, not original HTML/PDF bytes",
                "byte_start": a, "byte_end_exclusive": b,
                "newline_line_start": data[:a].count(b"\n") + 1,
                "newline_line_end": data[:b - 1].count(b"\n") + 1,
                "pdf_page_start": data[:a].count(b"\f") + 1 if sid == "whitepaper" else None,
                "pdf_page_end": data[:b - 1].count(b"\f") + 1 if sid == "whitepaper" else None,
                "span_sha256": digest(data[a:b]), "exact_text": data[a:b].decode(),
            })

        span("architecture", "canonical-state", "Smart contracts on Ethereum hold deposited assets")
        span("architecture", "sequencer-soft-finality", "A Sequencer coordinates first-in")
        span("architecture", "proof-settlement", "Once the proof for a state-update proposal")
        span("whitepaper", "app-specific-layer2", "To address the challenges of building a trustless financial system",
             "Ethereum’s security and liquidity with the horizontal and vertical scalability of the Lighter Protocol.")
        span("whitepaper", "sequencer-blocks", "The Sequencer serves as the low-latency execution engine.",
             "and state changes through multiple data feeds—to the Indexer and Prover services.")
        span("whitepaper", "linear-batches", "Lighter Protocol batches are arranged in a linear sequence",
             "the chain receives a batch height incremented by one relative to its predecessor.")
        span("whitepaper", "data-availability-boundary", "Lighter executes tens of thousands of user operations per second",
             "the corresponding batch and published to Ethereum as part of its public record through a blob-carrying\ntransaction.")
        span("api", "accounts-and-authorization", "Each account and sub-account on Lighter may interact",
             "In addition to the main account, users may create multiple sub-accounts linked to the same Ethereum wallet.")
    for loc in locators:
        data = (ROOT / loc["derived_text"]["path"]).read_bytes()
        piece = data[loc["byte_start"]:loc["byte_end_exclusive"]]
        check("locator:" + loc["id"], digest(piece) == loc["span_sha256"]
              and piece.decode() == loc["exact_text"] and bind(loc["derived_text"]["path"]) == loc["derived_text"]
              and bind(loc["original_capture"]["path"]) == loc["original_capture"])
    check("eight-unique-locators", len(locators) == len({x["id"] for x in locators}) == 8)
    triage_path = "review/semantic-kernel/corpus-provenance-adjudication/source-research/disagreement-triage.json"
    triage = read(triage_path)
    selected = next(x for x in triage["disagreements"] if x["id"] == "dispute-10")
    observations = {}
    for label, binding in [("raw_a", selected["raw_a"]["record"]),
                           ("raw_b", selected["raw_b"]["record"]),
                           ("generated", selected["generated"]["pointer"]),
                           ("neutral_context", selected["neutral_context"]),
                           ("original_context", selected["original_context"])]:
        check("historical-binding:" + label, bind(binding["path"], binding["pointer"]) == binding)
        observations[label] = {"source": binding, "value": resolve(binding["path"], binding["pointer"])}
    check("exact-raw-facet-a", observations["raw_a"]["value"]["facets"]["execution"]
          == ["offchain_matched_onchain_settled", "appchain"])
    check("exact-raw-facet-b", observations["raw_b"]["value"]["facets"]["execution"]
          == ["offchain_matched_onchain_settled"])
    check("unchanged-generated-unresolved", observations["generated"]["value"] == selected["generated"]["record"]
          and observations["generated"]["value"]["status"] == "unresolved_difference")
    design_path = "openspec/changes/corpus-provenance-adjudication/design.md"
    rule_line, literal = next((i, line) for i, line in enumerate((ROOT / design_path).read_text().splitlines(), 1)
                              if line.startswith("| `R-appchain` /"))
    inventory_path = selected["inventory"]["path"]
    current_inventory = {"binding": bind(inventory_path, "/disagreements/9"),
                         "record": resolve(inventory_path, "/disagreements/9")}
    check("exact-current-unit", current_inventory["record"]["unit_id"] == UNIT)
    if not args.verify_only:
        write("selection-and-observations.json", {
            "selection_rule": "Root-assigned Lighter dispute-10; no prospective evaluation selection",
            "triage": bind(triage_path, "/disagreements/9"), "raw_triage_record": selected,
            "current_inventory": current_inventory, "observations": observations,
            "inventory_hash_note": "Raw triage preserves its older whole-file inventory hash. Current inventory is separately bound after the authorized CP01 planning correction; this packet does not repair or overwrite historical triage.",
        })
        write("evidence-locators.json", {"schema_version": 1, "locators": locators,
              "limits": "Original body hashes bind retained captures; offsets locate derived text only. HTML extraction is the retained declared method, not independently reproduced here. PDF extraction was byte-reproduced offline."})
        claims = [
            {"id": "C1", "kind": "publisher_description", "claim": "The whitepaper explicitly describes an application-specific Layer 2 on Ethereum, with sequential transaction execution into blocks and linear batches.", "evidence": ["whitepaper:app-specific-layer2", "whitepaper:sequencer-blocks", "whitepaper:linear-batches"]},
            {"id": "C2", "kind": "publisher_description", "claim": "The architecture describes sequencer soft finality, Ethereum custody and canonical state, and state updates after Ethereum proof verification.", "evidence": ["architecture:canonical-state", "architecture:sequencer-soft-finality", "architecture:proof-settlement"]},
            {"id": "C3", "kind": "source_scoped_taxonomy_inference", "claim": "The dedicated execution domain and stated Ethereum settlement role support appchain if the proposed rule includes application-specific rollups; this does not establish sovereign Layer 1 consensus.", "evidence": ["whitepaper:app-specific-layer2", "whitepaper:sequencer-blocks", "whitepaper:linear-batches", "architecture:proof-settlement"]},
            {"id": "C4", "kind": "publisher_description_and_limit", "claim": "The whitepaper distinguishes compressed aggregated account-state data published to Ethereum from the full operation stream, which it says cannot be posted entirely. Account reconstruction claims are not evidence that all orders are public.", "evidence": ["whitepaper:data-availability-boundary", "architecture:canonical-state"]},
            {"id": "C5", "kind": "supplemental_publisher_description", "claim": "API documentation describes accounts, subaccounts, API-key authorization and Ethereum-wallet registration. These alone would not satisfy the appchain predicate.", "evidence": ["api:accounts-and-authorization"]},
        ]
        qualifiers = [
            "Rule application is conditional on dedicated application chain including application-specific rollups; independent taxonomy review must ratify this interpretation. The literal rule does not expressly require sovereign Layer 1 consensus or expressly define rollup inclusion.",
            "The appchain and offchain_matched_onchain_settled labels describe compatible facets of dedicated execution and external settlement; this packet adjudicates only the disputed appchain label.",
            "Three retained bodies are from one Lighter publisher family, not three independent confirmations.",
            "The whitepaper body says October 2025. Retrieval time and Last-Modified headers do not establish historical deployed behavior or a deployment date.",
            "No deployment address, implementation revision, proxy/block binding, contract compilation, protocol execution or deployed-fidelity proof is supplied.",
            "Publisher security, fairness, MEV, performance, liveness and censorship-resistance claims are not independently verified. Proof descriptions are not checked cryptographic proofs.",
            "Original missing proposal citations remain unresolved. Current captured source bytes are new source evidence, not recovery of those originals.",
            "Existing corpus rows, intersection results and raw A/B rationales remain unchanged. No untouched holdout certification or evaluation occurred.",
        ]
        proposal = {"schema_version": 1, "unit_id": UNIT, "dispute_id": "dispute-10", "facet": "execution",
                    "process_status": "draft_review_pending", "proposed_disposition": "supported",
                    "disputed_label": "appchain", "accepted_disposition": None,
                    "support_scope": "Conditional source-scoped architecture classification under the explicit rollup-inclusive interpretation; not deployed fidelity",
                    "rule": {"id": "R-appchain", "version": "proposed evidence-adjudication/1",
                             "source": {**bind(design_path), "line": rule_line}, "literal_table_row": literal,
                             "status": "Proposed reusable rule; not accepted by this packet"},
                    "claims": claims, "qualifications": qualifiers,
                    "source_independence_groups": [{"id": "lighter-publisher", "source_ids": list(sources)}],
                    "retrievals": bind(REL + "/retrievals.json"), "extraction": bind(REL + "/extraction.json"),
                    "deployed_fidelity_status": "unresolved", "original_reference_recovery_status": "unresolved",
                    "hypothetical_overlay_if_later_accepted": {"applied": False, "execution": ["appchain", "offchain_matched_onchain_settled"]},
                    "semantic_closure": False}
        for claim in claims:
            check("claim-refs:" + claim["id"], set(claim["evidence"]) <= {x["id"] for x in locators})
        write("proposed-adjudication.json", proposal)
        write("REPORT.md", f"""# Lighter appchain dispute: draft source evidence

**Proposed: supported under a rollup-inclusive reading of R-appchain; independent review pending.** The original corpus remains unresolved and unchanged.

This packet addresses only `dispute-10`, `{UNIT}`, execution/appchain. Raw A includes appchain; raw B omits it while noting a vocabulary limitation. The generated `/adjudications/133` retains offchain_matched_onchain_settled and records appchain as unresolved. [Exact observations](selection-and-observations.json) preserve A/B `/annotations/26`, rationales, uncertainty and original context.

The current proposed rule at `{design_path}:{rule_line}` requires a dedicated application chain with its execution/settlement role stated. The whitepaper explicitly describes an application-specific Layer 2, sequencer execution into blocks, and linear batches. Architecture documentation describes soft finality followed by Ethereum proof verification and canonical state updates. Together these support the label **if application-specific rollups fall within that rule**. They do not establish sovereign Layer 1 consensus. Independent review must ratify this interpretation; no rule was silently rewritten. See [whitepaper](https://assets.lighter.xyz/whitepaper.pdf) and [architecture](https://docs.lighter.xyz/about-lighter/technical-architecture-lighter-core), retained on 2026-09-07.

The architecture's account-state reconstruction description must be read with the whitepaper's data-availability boundary: not every operation is posted to Ethereum; aggregated account changes and relevant market data are compressed for publication. This packet does not infer that all orders are public. [API documentation](https://docs.lighter.xyz/trading/api) adds account and authorization context, which alone would not prove the classification. Publisher security, fairness, MEV, performance and liveness claims remain unverified.

Exactly three pre-existing captures total **{total_bytes:,} body bytes**: architecture 434,793; whitepaper 2,712,774; API 396,806. All are from one publisher family. Requested/final URLs, exact headers and capture UTC times remain in [retrievals.json](retrievals.json); the API request redirected from `/perpetual-futures/api` to `/trading/api`. The PDF title date is October 2025, not evidence of a historical deployment. No new network request was made while completing this packet.

[Eight locators](evidence-locators.json) bind exact UTF-8 spans in retained extracted text, its extraction record and the original body hashes. Their offsets are **derived-text coordinates**, not original PDF/HTML coordinates. Newline line numbers count LF bytes; PDF page numbers count form feeds. The PDF extraction was reproduced byte-for-byte offline with the recorded pdftotext binary. The retained HTML extraction method is documented but not independently reproduced here.

[The proposal](proposed-adjudication.json) separates publisher statements from the conditional taxonomy inference. It establishes no deployed contract/source revision, proxy state, address/block binding, verified cryptographic proof or original missing citation recovery. It changes no other label and supplies no holdout evidence. The old triage's whole-inventory hash remains historical; the current inventory is separately bound after the root-authorized CP01 correction elsewhere in the planning inventory.

[Verification](verification.json) checks all {len(before['files'])} protected inputs, capture and extraction hashes, exact observation pointers and all locators. Recheck offline with `python3 {REL}/build-record.py --verify-only` from the repository root. A first build without that flag writes new packet artifacts exclusively and refuses overwriting existing outputs. [The manifest](artifact-manifest.json) binds every packet file except itself. These are integrity checks, not execution or independent semantic acceptance.
""")
    for path, expected in before["files"].items():
        check("protected-after:" + path, bind(path)["sha256"] == expected)
    for name, expected in immutable.items():
        check("immutable-after:" + name, bind(expected["path"]) == expected)
    if not args.verify_only:
        write("verification.json", {
            "created_utc": datetime.now(timezone.utc).isoformat(), "all_passed": True,
            "check_count": len(checks), "checks": checks, "protected_files": len(before["files"]),
            "protected_drift": [], "git_head_at_capture": before["head"],
            "git_head_at_completion": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(),
            "immutable_before_after_bindings": immutable, "source_bodies": 3, "source_bytes": total_bytes,
            "pdf_reproduction": {"argv": pdf_command, "exit": pdf_result.returncode,
                                 "tool_sha256": method["tool_sha256"], "stdout_sha256": digest(pdf_result.stdout),
                                 "stderr": pdf_result.stderr.decode()},
            "scope": "Offline byte, locator and record checks only; no network, corpus edits, Lean or protocol execution, independent review or deployed-fidelity acceptance",
        })
        files = []
        for path in sorted(OUT.rglob("*")):
            check("not-symlink:" + str(path), not path.is_symlink())
            if path.is_file() and path.name != "artifact-manifest.json":
                files.append(bind(str(path.relative_to(ROOT))))
        write("artifact-manifest.json", {"schema_version": 1, "scope": "Draft source-research packet; excludes manifest self", "files": files})
    print(json.dumps({"all_passed": True, "checks": len(checks), "source_bytes": total_bytes,
                      "protected_files": len(before["files"]), "locators": len(locators),
                      "manifest": bind(REL + "/artifact-manifest.json")}, indent=2))


if __name__ == "__main__":
    main()
