"""Read-only structural review of the OpenSpec program; not a semantic acceptance gate."""
from pathlib import Path
import collections
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[3]
CHANGE = ROOT / "openspec/changes/reusable-verification-platform-program"
REVIEW = Path(__file__).resolve().parent


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    index = json.loads((CHANGE / "sprint-index.json").read_text())
    sprints = index["sprints"]
    by_id = {s["id"]: s for s in sprints}
    expected_ids = {f"P{i:02}" for i in range(1, 38)}
    checks = {"unique_37_sprints": len(sprints) == len(by_id) == 37 and set(by_id) == expected_ids}
    edges = {(d, s["id"]) for s in sprints for d in s["dependencies"]}
    checks["dependency_ids_exist"] = all(a in by_id and b in by_id for a, b in edges)
    visited, visiting = set(), set()

    def visit(key):
        if key not in by_id or key in visiting:
            return False
        if key in visited:
            return True
        visiting.add(key)
        if not all(visit(dep) for dep in by_id[key]["dependencies"]):
            return False
        visiting.remove(key)
        visited.add(key)
        return True

    checks["dag_acyclic"] = all(visit(k) for k in by_id)
    def ancestors(key):
        result = set()
        pending = list(by_id[key]["dependencies"])
        while pending:
            item = pending.pop()
            if item in result or item not in by_id:
                continue
            result.add(item)
            pending.extend(by_id[item]["dependencies"])
        return result
    checks["full_completion_joins_all_other_sprints"] = ancestors("P37") == expected_ids - {"P37"}
    order = index["recommended_order"]
    checks["recommended_order_covers_all"] = len(order) == len(set(order)) == 37 and set(order) == expected_ids
    positions = {k: n for n, k in enumerate(order)}
    checks["recommended_order_respects_hard_dependencies"] = all(positions.get(a, 999) < positions.get(b, -1) for a, b in edges)
    roadmap_expected = {x["id"] for x in json.loads((REVIEW / "input-manifest.json").read_text())["roadmap_open_items"]}
    roadmap_actual = {k for s in sprints for k in s["roadmap_ids"]}
    checks["all_47_roadmap_ids_mapped"] = roadmap_actual == roadmap_expected and len(roadmap_actual) == 47
    current = {x["id"]: x for x in json.loads((ROOT / "review/semantic-kernel/strategy-audit-20260908/CURRENT.json").read_text())["lanes"]}
    lane_actual = {k for s in sprints for k in s["lane_ids"]}
    lane_actual |= {s["lane"] for s in index["historical_completed_baseline"] if "lane" in s}
    checks["all_17_current_lanes_mapped"] = lane_actual == set(current) and len(lane_actual) == 17
    bindings = []
    for s in sprints:
        old = s["legacy_mapping"]
        if "archive_sha256" in old:
            expected = current[old["lane"]]["candidate"]["sha256"]
            bindings.append({"sprint": s["id"], "matches": old["archive_sha256"] == expected, "expected": expected})
    checks["candidate_hashes_match_current"] = bool(bindings) and all(x["matches"] for x in bindings)
    tasks = (CHANGE / "tasks.md").read_text()
    task_rows = re.findall(r"^- \[([ x])\] (\d+\.\d+[a-z]?) (.+)$", tasks, re.M)
    ids = [row[1] for row in task_rows]
    checks["tasks_nonempty_unique_unchecked"] = bool(ids) and len(ids) == len(set(ids)) == len(re.findall(r"^- \[[ x]\] ", tasks, re.M)) and all(row[0] == " " for row in task_rows)
    checks["all_sprints_have_tasks"] = all(any(k in row[2] for row in task_rows) for k in expected_ids)
    specs = []
    for spec in sorted(CHANGE.glob("specs/*/spec.md")):
        content = spec.read_text()
        specs.append({"capability": spec.parent.name, "requirements": content.count("### Requirement:"), "scenarios": content.count("#### Scenario:")})
    checks["six_nonempty_capability_specs"] = len(specs) == 6 and all(s["requirements"] and s["scenarios"] for s in specs)
    graph_differences = {}
    def edge_closure(graph_edges):
        reached = set(graph_edges)
        while True:
            added = {(a, d) for a, b in reached for c, d in reached if b == c} - reached
            if not added:
                return reached
            reached |= added
    for name in ("design.md", "sprint-plan.md"):
        content = (CHANGE / name).read_text()
        blocks = re.findall(r"```mermaid\n(.*?)```", content, re.S)
        uses_canonical_diagram = False
        if not blocks and name == "sprint-plan.md" and "design.md" in content and "DAG" in content:
            blocks = re.findall(r"```mermaid\n(.*?)```", (CHANGE / "design.md").read_text(), re.S)
            uses_canonical_diagram = True
        graph_edges = set()
        for block in blocks:
            graph_edges.update(re.findall(r"(?=\b(P\d{2})(?:\[[^\]]*\])?\s*-->\s*(P\d{2})\b)", block))
        graph_differences[name] = {"missing_direct_edges": sorted(edges - graph_edges), "extra_direct_edges": sorted(graph_edges - edges), "uses_canonical_design_diagram": uses_canonical_diagram, "note": "Transitive reduction is allowed; required predecessor reachability must match exactly."}
        checks[name + "_dependency_reachability_matches_index"] = bool(blocks) and edge_closure(graph_edges) == edge_closure(edges)
    missing_links = []
    for file in CHANGE.rglob("*.md"):
        for target in re.findall(r"\[[^\]]+\]\(([^)]+)\)", file.read_text()):
            target = target.strip("<>").split("#", 1)[0]
            if not target or re.match(r"[a-z]+://", target):
                continue
            if not (file.parent / target).exists():
                missing_links.append({"file": str(file.relative_to(CHANGE)), "target": target})
    checks["relative_markdown_link_targets_exist"] = not missing_links
    legacy_path = CHANGE / "legacy-task-disposition.json"
    legacy_summary = {}
    if legacy_path.exists():
        legacy = json.loads(legacy_path.read_text())
        rows = legacy["tasks"]
        found = collections.defaultdict(dict)
        duplicate = []
        owner_errors = []
        for row in rows:
            path, task_id = row["path"], row["task_id"]
            if task_id in found[path]:
                duplicate.append((path, task_id))
            found[path][task_id] = row["historically_checked"]
            owners = re.findall(r"P\d{2}", row["owner_sprint"])
            if not owners or any(owner not in by_id for owner in owners):
                owner_errors.append((path, task_id, row["owner_sprint"]))
        errors = []
        for path, actual in found.items():
            source = ROOT / path
            if not source.exists():
                errors.append({"path": path, "missing": True})
                continue
            expected = {task_id: mark == "x" for mark, task_id in re.findall(r"^- \[([ x])\] (\d+\.\d+)", source.read_text(), re.M)}
            if actual != expected:
                errors.append({"path": path, "missing_ids": sorted(set(expected) - set(actual)), "extra_ids": sorted(set(actual) - set(expected)), "checkbox_mismatch": sorted(k for k in actual.keys() & expected.keys() if actual[k] != expected[k])})
        checks["all_11_legacy_packages_exact_task_ids_and_historical_marks"] = len(found) == 11 and not errors and not duplicate and legacy["count"] == len(rows)
        checks["legacy_task_owners_exist"] = not owner_errors
        legacy_summary = {"packages": len(found), "tasks": len(rows), "errors": errors, "duplicates": duplicate, "owner_errors": owner_errors}
    else:
        checks["all_11_legacy_packages_exact_task_ids_and_historical_marks"] = False
    report = {"scope": "Structural planning checks only; requires separate semantic review", "checks": checks, "sprints": len(sprints), "tasks": len(ids), "hard_edges": len(edges), "candidate_bindings": bindings, "spec_counts": specs, "graph_differences": graph_differences, "missing_links": missing_links, "legacy": legacy_summary}
    print(json.dumps(report, indent=2))
    return 0 if all(checks.values()) else 1


if __name__ == "__main__":
    raise SystemExit(main())
