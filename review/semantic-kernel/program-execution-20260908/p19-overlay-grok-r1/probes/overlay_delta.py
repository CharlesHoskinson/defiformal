#!/usr/bin/env python3
"""Static field-level comparison of R5 overlay vs frozen planning fixtures.

Read-only on the frozen sandbox. Writes JSON under the review probes directory.
"""
from __future__ import annotations

import hashlib
import json
import re
from collections import OrderedDict
from copy import deepcopy
from pathlib import Path

SANDBOX = Path(
    "/home/charl/.cache/defiformal-program/program-execution-20260908/p19-overlay-grok-r1-sandbox"
)
OUT = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-overlay-grok-r1/probes"
)

ENVELOPE_KEYS = [
    "schema_version",
    "mode",
    "source_pin",
    "audit_roots",
    "types",
    "assumptions",
    "invariants",
    "libraries",
    "source_map",
    "payload",
    "claimed_judgments",
    "claimed_next_state",
    "require_library_discharge",
    "require_invariant_discharge",
]


def sha256_bytes(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


def sha256_file(p: Path) -> str:
    return sha256_bytes(p.read_bytes())


def sha256_json(obj) -> str:
    return sha256_bytes(json.dumps(obj, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8"))


def source_map_key_order(sm) -> list | None:
    if isinstance(sm, dict):
        return list(sm.keys())
    if isinstance(sm, str):
        m = re.search(r'"source_map"\s*:\s*\{([^}]*)\}', sm)
        if not m:
            return None
        return re.findall(r'"([^"]+)"\s*:', m.group(1))
    return None


def walk_diffs(a, b, path=""):
    diffs = []
    if type(a) is not type(b) and not (
        (a is None or b is None) and not isinstance(a, (dict, list)) and not isinstance(b, (dict, list))
    ):
        if type(a) != type(b):
            diffs.append(
                {
                    "path": path or "$",
                    "kind": "type",
                    "original_type": type(a).__name__,
                    "overlay_type": type(b).__name__,
                    "original": a if not isinstance(a, (dict, list)) else {"sha256": sha256_json(a)},
                    "overlay": b if not isinstance(b, (dict, list)) else {"sha256": sha256_json(b)},
                }
            )
            return diffs
    if isinstance(a, dict) and isinstance(b, dict):
        keys = list(dict.fromkeys(list(a.keys()) + list(b.keys())))
        a_order = list(a.keys())
        b_order = list(b.keys())
        if a_order != b_order and set(a.keys()) == set(b.keys()):
            diffs.append(
                {
                    "path": path or "$",
                    "kind": "object_key_order",
                    "original_order": a_order,
                    "overlay_order": b_order,
                }
            )
        for k in keys:
            sub = f"{path}.{k}" if path else k
            if k not in a:
                diffs.append(
                    {
                        "path": sub,
                        "kind": "added",
                        "overlay": b[k] if not isinstance(b[k], (dict, list)) else {"sha256": sha256_json(b[k])},
                    }
                )
            elif k not in b:
                diffs.append(
                    {
                        "path": sub,
                        "kind": "removed",
                        "original": a[k] if not isinstance(a[k], (dict, list)) else {"sha256": sha256_json(a[k])},
                    }
                )
            else:
                diffs.extend(walk_diffs(a[k], b[k], sub))
        return diffs
    if isinstance(a, list) and isinstance(b, list):
        if len(a) != len(b):
            diffs.append(
                {
                    "path": path or "$",
                    "kind": "list_length",
                    "original_len": len(a),
                    "overlay_len": len(b),
                }
            )
        for i, (x, y) in enumerate(zip(a, b)):
            diffs.extend(walk_diffs(x, y, f"{path}[{i}]"))
        return diffs
    if a != b:
        diffs.append(
            {
                "path": path or "$",
                "kind": "value",
                "original": a,
                "overlay": b,
            }
        )
    return diffs


def classify_entry(fid, kind, input_diffs, expected_diffs, orig, over):
    classes = set()
    notes = []
    ir_paths = [d for d in expected_diffs if d["path"].endswith(".ir") or d["path"] == "result.ir"]
    outstanding_paths = [d for d in expected_diffs if "outstanding" in d["path"]]
    raw_input_diffs = [d for d in input_diffs if "raw_utf8" in d["path"]]
    source_map_input = [d for d in input_diffs if "source_map" in d["path"]]
    source_map_expected = [d for d in expected_diffs if "source_map" in d["path"]]

    orig_raw = None
    over_raw = None
    if kind == "codec":
        orig_raw = orig.get("inputs", {}).get("raw_utf8")
        over_raw = over.get("inputs", {}).get("raw_utf8")
        if orig_raw is not None and over_raw is not None and orig_raw != over_raw:
            orig_sm = source_map_key_order(orig_raw)
            over_sm = source_map_key_order(over_raw)
            orig_obj = json.loads(orig_raw)
            over_obj = json.loads(over_raw)
            orig_obj["source_map"] = dict(sorted(orig_obj.get("source_map", {}).items()))
            over_obj["source_map"] = dict(sorted(over_obj.get("source_map", {}).items()))
            only_sm_order = json.dumps(orig_obj, sort_keys=True) == json.dumps(over_obj, sort_keys=True)
            orig_canon = json.dumps(orig_obj, sort_keys=True, separators=(",", ":"))
            over_canon = json.dumps(over_obj, sort_keys=True, separators=(",", ":"))
            semantic_equal = orig_canon == over_canon
            if orig_sm != over_sm and semantic_equal:
                classes.add("canonical_serialization_only")
                notes.append(
                    f"raw source_map order {orig_sm} -> {over_sm}; semantic payload equal after sorting keys"
                )
            elif orig_sm != over_sm and only_sm_order:
                classes.add("canonical_serialization_only")
            else:
                # field-level besides order
                raw_obj_diffs = walk_diffs(json.loads(orig_raw), json.loads(over_raw), "raw_object")
                extra = [d for d in raw_obj_diffs if d["kind"] != "object_key_order"]
                sm_only = all(
                    d["path"].endswith("source_map") or ".source_map" in d["path"] or d["kind"] == "object_key_order"
                    for d in raw_obj_diffs
                )
                if sm_only and extra:
                    # check extra are only source_map key order
                    non_order = [d for d in extra if d["kind"] != "object_key_order"]
                    if not non_order:
                        classes.add("canonical_serialization_only")
                    else:
                        # values of source_map?
                        if all("source_map" in d["path"] for d in non_order):
                            if all(d["kind"] == "object_key_order" or d.get("path", "").endswith("source_map") for d in non_order):
                                classes.add("canonical_serialization_only")
                            else:
                                classes.add("other_input_field_change")
                                notes.append("raw object differs beyond source_map key order")
                        else:
                            classes.add("other_input_field_change")
                            notes.append("raw object differs beyond source_map")
                elif extra:
                    classes.add("other_input_field_change")
                    notes.append("raw bytes differ by fields other than source_map order")
                else:
                    classes.add("canonical_serialization_only")

    if outstanding_paths:
        classes.add("informational_source_map_expectation")
    if ir_paths:
        for d in ir_paths:
            if d.get("original") == "DecodedIR of F25 payload" and d.get("overlay") is None:
                classes.add("ir_equality_expectation_weakening")
            elif d.get("original") is not None and d.get("overlay") is None:
                classes.add("ir_equality_expectation_weakening")
            else:
                classes.add("ir_expectation_change")
    added = [d for d in input_diffs + expected_diffs if d["kind"] == "added"]
    removed = [d for d in input_diffs + expected_diffs if d["kind"] == "removed"]
    if added:
        classes.add("missing_or_default_field_repair")
        notes.append("added paths: " + ",".join(d["path"] for d in added[:12]))
    if removed:
        classes.add("field_removal")
        notes.append("removed paths: " + ",".join(d["path"] for d in removed[:12]))

    # expected raw_utf8 echo order
    expected_raw_diffs = [d for d in expected_diffs if "raw_utf8" in d["path"]]
    if expected_raw_diffs and kind == "codec":
        oer = orig.get("expected", {}).get("raw_utf8")
        ner = over.get("expected", {}).get("raw_utf8")
        if isinstance(oer, str) and isinstance(ner, str) and oer != ner:
            if source_map_key_order(oer) != source_map_key_order(ner):
                classes.add("canonical_serialization_only")

    if not classes and (input_diffs or expected_diffs):
        classes.add("other")
    if not input_diffs and not expected_diffs:
        classes.add("byte_identical_copy")

    # object-valued source_map order without raw bytes
    if kind != "codec":
        osm = orig.get("inputs", {}).get("source_map")
        nsm = over.get("inputs", {}).get("source_map")
        if isinstance(osm, dict) and isinstance(nsm, dict):
            if list(osm.keys()) != list(nsm.keys()) and osm == nsm:
                classes.add("canonical_serialization_only")
            elif list(osm.keys()) == list(nsm.keys()) == ["transfer", "store"]:
                notes.append(
                    "object-valued source_map presentation remains transfer/store; not a raw-byte specimen"
                )

    return sorted(classes), notes


def canonicalize_json(obj):
    if not isinstance(obj, dict):
        return obj
    envelope_keys = ENVELOPE_KEYS
    if "mode" in obj and "source_pin" in obj:
        res = {}
        for k in envelope_keys:
            if k in obj:
                v = obj[k]
                if k == "source_map" and isinstance(v, dict):
                    res[k] = dict(sorted(v.items()))
                elif k == "payload" and isinstance(v, dict):
                    mode = obj.get("mode")
                    if mode == "typed-execute":
                        pkeys = ["registry", "store", "ctx", "env", "now", "request", "state"]
                        res[k] = {pk: v[pk] for pk in pkeys if pk in v}
                    elif mode == "composition-step":
                        pkeys = ["config", "boundary", "index", "history", "step", "pre"]
                        res[k] = {pk: v[pk] for pk in pkeys if pk in v}
                    elif mode == "composition-run":
                        pkeys = ["config", "boundaries", "world", "steps"]
                        res[k] = {pk: v[pk] for pk in pkeys if pk in v}
                    elif mode == "audit":
                        res[k] = dict(sorted(v.items()))
                    else:
                        res[k] = v
                else:
                    res[k] = v
        return res
    return obj


def compact(obj) -> bytes:
    return json.dumps(obj, separators=(",", ":"), ensure_ascii=False).encode("utf-8")


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    fixtures_path = SANDBOX / "openspec/changes/serialized-kernel-certificates/fixtures.json"
    overlay_path = (
        SANDBOX
        / "review/semantic-kernel/certificates/p19/implementation/agy-r5/fixture-canonical-order-overlay.json"
    )
    harness_path = SANDBOX / "scripts/run_certificate_fixtures.py"
    fixtures_data = json.loads(fixtures_path.read_text(encoding="utf-8"))
    overlay_data = json.loads(overlay_path.read_text(encoding="utf-8"))
    fixtures = {f["id"]: f for f in fixtures_data["fixtures"]}
    overlays = overlay_data.get("overlays", {})
    regressions = overlay_data.get("regressions", [])

    overlay_schema_keys = list(overlay_data.keys())
    overlay_entry_keys = {}
    for fid, ent in overlays.items():
        overlay_entry_keys[fid] = list(ent.keys())

    cases = []
    class_counts = {}
    harness_changed_unchanged_inputs = []
    original_identity_bound = []

    for fid, ent in overlays.items():
        orig = fixtures.get(fid)
        if orig is None:
            cases.append({"id": fid, "error": "unknown_fixture_id_in_overlay"})
            continue
        kind = orig.get("kind")
        orig_in = orig.get("inputs")
        orig_ex = orig.get("expected")
        over_in = ent.get("inputs")
        over_ex = ent.get("expected")
        in_diffs = walk_diffs(orig_in, over_in, "inputs")
        ex_diffs = walk_diffs(orig_ex, over_ex, "expected")
        classes, notes = classify_entry(fid, kind, in_diffs, over_ex and ex_diffs or [], orig, ent)
        # reclassify using actual diffs
        classes, notes = classify_entry(fid, kind, in_diffs, ex_diffs, orig, ent)
        for c in classes:
            class_counts[c] = class_counts.get(c, 0) + 1

        orig_in_hash = sha256_json(orig_in)
        over_in_hash = sha256_json(over_in)
        orig_ex_hash = sha256_json(orig_ex)
        over_ex_hash = sha256_json(over_ex)

        raw_hashes = {}
        if kind == "codec":
            o_raw = orig_in.get("raw_utf8", "")
            n_raw = over_in.get("raw_utf8", "")
            raw_hashes = {
                "original_raw_utf8_sha256": sha256_bytes(o_raw.encode("utf-8")),
                "overlay_raw_utf8_sha256": sha256_bytes(n_raw.encode("utf-8")),
                "original_source_map_order": source_map_key_order(o_raw),
                "overlay_source_map_order": source_map_key_order(n_raw),
                "original_expected_raw_utf8_sha256": sha256_bytes(
                    str(orig_ex.get("raw_utf8", "")).encode("utf-8")
                ),
                "overlay_expected_raw_utf8_sha256": sha256_bytes(
                    str(over_ex.get("raw_utf8", "")).encode("utf-8")
                ),
            }
            original_identity_bound.append(
                {
                    "id": fid,
                    "original_raw_utf8_sha256": raw_hashes["original_raw_utf8_sha256"],
                    "overlay_binds_original_hash": False,
                }
            )

        # harness serialization of object-valued inputs
        harness_note = None
        if kind != "codec" and isinstance(orig_in, dict) and orig_in == over_in:
            ser_orig = compact(orig_in)
            ser_canon = compact(canonicalize_json(orig_in))
            if ser_orig != ser_canon:
                harness_changed_unchanged_inputs.append(
                    {
                        "id": fid,
                        "kind": kind,
                        "object_input_sha256": sha256_json(orig_in),
                        "python_compact_sha256": sha256_bytes(ser_orig),
                        "harness_canonicalize_sha256": sha256_bytes(ser_canon),
                        "source_map_object_order": source_map_key_order(orig_in.get("source_map")),
                        "canonical_source_map_order": source_map_key_order(
                            canonicalize_json(orig_in).get("source_map")
                        ),
                    }
                )
                harness_note = "unchanged object input; harness canonicalize_json rewrites source_map key order before Lean"

        orig_outstanding = orig_ex.get("outstanding") if isinstance(orig_ex, dict) else None
        over_outstanding = over_ex.get("outstanding") if isinstance(over_ex, dict) else None
        orig_status = orig_ex.get("status") if isinstance(orig_ex, dict) else None
        over_status = over_ex.get("status") if isinstance(over_ex, dict) else None
        orig_ir = None
        over_ir = None
        if isinstance(orig_ex, dict) and isinstance(orig_ex.get("result"), dict):
            orig_ir = orig_ex["result"].get("ir")
            orig_status = orig_ex["result"].get("status", orig_status)
        if isinstance(over_ex, dict) and isinstance(over_ex.get("result"), dict):
            over_ir = over_ex["result"].get("ir")
            over_status = over_ex["result"].get("status", over_status)

        # compact expected-only outstanding / status / failure
        status_unchanged = orig_status == over_status
        failure_orig = orig_ex.get("failure") if isinstance(orig_ex, dict) else None
        failure_over = over_ex.get("failure") if isinstance(over_ex, dict) else None
        if isinstance(orig_ex, dict) and "result" in orig_ex:
            failure_orig = orig_ex.get("result", {}).get("failure", failure_orig)
        if isinstance(over_ex, dict) and "result" in over_ex:
            failure_over = over_ex.get("result", {}).get("failure", failure_over)

        cases.append(
            {
                "id": fid,
                "name": orig.get("name"),
                "kind": kind,
                "scenarios": orig.get("scenarios"),
                "overlay_entry_keys": list(ent.keys()),
                "classes": classes,
                "notes": notes,
                "input_equal_object": orig_in == over_in,
                "expected_equal_object": orig_ex == over_ex,
                "original_inputs_sha256": orig_in_hash,
                "overlay_inputs_sha256": over_in_hash,
                "original_expected_sha256": orig_ex_hash,
                "overlay_expected_sha256": over_ex_hash,
                "input_diff_count": len(in_diffs),
                "expected_diff_count": len(ex_diffs),
                "input_diffs": in_diffs,
                "expected_diffs": ex_diffs,
                "original_outstanding": orig_outstanding,
                "overlay_outstanding": over_outstanding,
                "original_status": orig_status,
                "overlay_status": over_status,
                "status_preserved": status_unchanged,
                "failure_preserved": failure_orig == failure_over,
                "original_ir": orig_ir,
                "overlay_ir": over_ir,
                "raw_hashes": raw_hashes,
                "harness_serialization_note": harness_note,
                "overlay_rationale": ent.get("rationale"),
            }
        )

    # regressions
    reg_records = []
    for reg in regressions:
        rid = reg.get("id")
        raw = reg.get("inputs", {}).get("raw_utf8", "")
        raw_sha = sha256_bytes(raw.encode("utf-8"))
        src = None
        if rid.startswith("F13"):
            src = fixtures["F13"]["inputs"]["raw_utf8"]
        elif rid.startswith("F28"):
            src = fixtures["F28"]["inputs"]["raw_utf8"]
        src_sha = sha256_bytes(src.encode("utf-8")) if src is not None else None
        reg_records.append(
            {
                "id": rid,
                "name": reg.get("name"),
                "kind": reg.get("kind"),
                "scenarios": reg.get("scenarios"),
                "entry_keys": list(reg.keys()),
                "raw_utf8_sha256": raw_sha,
                "matches_original_planning_raw": raw_sha == src_sha,
                "original_planning_raw_sha256": src_sha,
                "source_map_order": source_map_key_order(raw),
                "expected": reg.get("expected"),
                "expected_failure_ctor": (reg.get("expected") or {}).get("result", {}).get("failure", {}).get("ctor"),
            }
        )

    # fixtures not in overlay
    not_overlaid = sorted(set(fixtures) - set(overlays))
    overlaid_not_in_fixtures = sorted(set(overlays) - set(fixtures))

    # object-valued fixtures with unsorted source_map even if not overlaid
    object_sm_order = []
    for fid, fix in fixtures.items():
        if fix.get("kind") == "codec":
            continue
        sm = fix.get("inputs", {}).get("source_map")
        if isinstance(sm, dict) and sm:
            order = list(sm.keys())
            canon = sorted(order)
            object_sm_order.append(
                {
                    "id": fid,
                    "in_overlay": fid in overlays,
                    "object_order": order,
                    "lex_order": canon,
                    "object_order_canonical": order == canon,
                    "inputs_equal_to_overlay": fid in overlays and fix["inputs"] == overlays[fid]["inputs"],
                }
            )

    # original outstanding nonempty
    orig_outstanding_nonempty = []
    for fid, fix in fixtures.items():
        ex = fix.get("expected") or {}
        outst = ex.get("outstanding")
        if isinstance(outst, list) and outst:
            orig_outstanding_nonempty.append({"id": fid, "kind": fix.get("kind"), "outstanding": outst})

    overlay_outstanding_nonempty = []
    for fid, ent in overlays.items():
        ex = ent.get("expected") or {}
        outst = ex.get("outstanding")
        if isinstance(outst, list) and outst:
            overlay_outstanding_nonempty.append({"id": fid, "outstanding": outst})

    harness_src = harness_path.read_text(encoding="utf-8")
    harness_identity = {
        "checks_original_fixture_hash": "original" in harness_src.lower()
        and "sha256" in harness_src
        and "overlay" in harness_src,
        "applies_by_id_only": 'if fid in overlays' in harness_src,
        "overwrites_inputs_and_expected": 'fix["inputs"] = overlays[fid]["inputs"]' in harness_src
        and 'fix["expected"] = overlays[fid]["expected"]' in harness_src,
        "detects_unknown_overlay_ids": False,
        "detects_unapplied_overlay_ids": False,
        "detects_stale_overlay": False,
        "regression_binds_original_hash": False,
        "altered_control_mutates": "status" if "altered[\"status\"]" in harness_src or "altered['status']" in harness_src else "see make_altered_control",
        "overlay_schema_enforced": "schema" in harness_src and "defiformal-certificate-fixture-overlay" in harness_src,
    }
    # more precise
    harness_identity["detects_unknown_overlay_ids"] = (
        "unknown overlay" in harness_src.lower() or "stale overlay" in harness_src.lower()
    )
    harness_identity["checks_original_identity"] = (
        "original_sha" in harness_src or "planning_sha" in harness_src or "raw_utf8_sha256" in harness_src
    )
    harness_identity["make_altered_control_touches_ir"] = "ir" in harness_src.split("def make_altered_control", 1)[-1].split("def canonicalize_json", 1)[0]

    summary = {
        "schema": "defiformal-overlay-delta-map/v1",
        "mark": "OVERLAY_AND_POLICY_REVIEW_ONLY_FULL_P19_OPEN",
        "frozen_fixtures_sha256": sha256_file(fixtures_path),
        "overlay_sha256": sha256_file(overlay_path),
        "harness_sha256": sha256_file(harness_path),
        "fixture_count_planning": len(fixtures),
        "overlay_count": len(overlays),
        "regression_count": len(regressions),
        "overlay_schema_keys": overlay_schema_keys,
        "overlay_entry_key_sets": sorted({tuple(v) for v in overlay_entry_keys.values()}),
        "overlay_ids": sorted(overlays),
        "not_overlaid_ids": not_overlaid,
        "overlaid_not_in_fixtures": overlaid_not_in_fixtures,
        "class_counts": class_counts,
        "cases": cases,
        "regressions": reg_records,
        "harness_changed_unchanged_object_inputs": harness_changed_unchanged_inputs,
        "object_valued_source_map_order": object_sm_order,
        "original_nonempty_outstanding": orig_outstanding_nonempty,
        "overlay_nonempty_outstanding": overlay_outstanding_nonempty,
        "harness_overlay_logic": harness_identity,
        "root_expected_original_raw_hashes": {
            "F13": "147d3f956a7c316338e151c11d679d953fb9b38aab30e08648c77d922c8c84c8",
            "F28": "c3f1e7f3215967056e398a92ff31dc21bf574207d7fb987abfb99bfbefeb4bd9",
        },
    }
    outp = OUT / "overlay-delta-raw.json"
    outp.write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {outp}")
    print("overlay_count", len(overlays))
    print("class_counts", json.dumps(class_counts, sort_keys=True))
    print("not_overlaid", not_overlaid)
    print("regressions", [(r["id"], r["matches_original_planning_raw"], r["raw_utf8_sha256"], r["expected_failure_ctor"]) for r in reg_records])
    print("harness_changed_count", len(harness_changed_unchanged_inputs))
    print("harness_identity", json.dumps(harness_identity, indent=2))
    # F13/F28 hashes
    for fid in ("F13", "F28"):
        c = next(x for x in cases if x["id"] == fid)
        print(fid, "classes", c["classes"])
        print(fid, "raw", c["raw_hashes"])
        print(fid, "ir", c["original_ir"], "->", c["overlay_ir"])
        print(fid, "rationale", c["overlay_rationale"])
    for fid in ("F25", "F43", "F27"):
        c = next((x for x in cases if x["id"] == fid), None)
        if c:
            print(fid, "classes", c["classes"], "in_eq", c["input_equal_object"], "status_preserved", c["status_preserved"])
            print(fid, "outstanding", c["original_outstanding"], "->", c["overlay_outstanding"])
            print(fid, "expected_diffs", c["expected_diffs"])
            print(fid, "input_diff_count", c["input_diff_count"])


if __name__ == "__main__":
    main()
