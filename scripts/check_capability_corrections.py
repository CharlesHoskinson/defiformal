#!/usr/bin/env python3
"""Check a competitive-landscape correction record against the repository bytes.

Checks every bound SHA-256, every cited line, every superseded statement, the
historical report grades, the peer calibration findings in the report data, the
ShareQuote commit identity and the line accounting.

Requires all three corrections and their mandatory evidence sections.
Exit 0: the complete inventory's byte bindings, citations and counts agree.
This is an integrity check, not independent acceptance of grades or proof claims.
Exit 1: a recorded value contradicts the repository.
Exit 3: the record or a required input is missing, empty or unreadable, a
required inventory is missing or empty, or git is unavailable.
The checker only reads; it writes nothing.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

REPO = Path(__file__).resolve().parents[1]
DEFAULT_RECORD = REPO / "review/semantic-kernel/competitive-landscape-corrections-20261118/CORRECTIONS.json"
ROLES = ("model", "specification", "guidance", "excluded", "blank")
# This dated checker has a fixed scope. The input cannot redefine completeness.
REQUIRED_SECTIONS = {
    "C1-liquidation-grades": ("supersedes", "effective_grades", "historical_report_grades", "calibration"),
    "C2-amm-grades": ("completes", "effective_grades", "historical_report_grades", "calibration"),
    "C3-sharequote-accounting": ("supersedes", "commit", "accounting"),
}
REQUIRED_CELLS = {
    "C1-liquidation-grades": {
        "cell:liquidation:liquidation_correctness", "cell:liquidation:solvency", "primitive:liquidation",
    },
    "C2-amm-grades": {"cell:amm:conservation", "cell:amm:no_arbitrage"},
}


class Blocked(Exception):
    pass


class Failed(Exception):
    pass


def read_bytes(relative):
    path = REPO / relative
    try:
        data = path.read_bytes()
    except OSError as error:
        raise Blocked(f"missing or unreadable input: {relative} ({error.strerror})")
    if not data:
        raise Blocked(f"empty input: {relative}")
    return data


def bound_text(entry, tally):
    data = read_bytes(entry["path"])
    actual = hashlib.sha256(data).hexdigest()
    if actual != entry["sha256"]:
        raise Failed(f"sha256 mismatch: {entry['path']}: recorded {entry['sha256']}, actual {actual}")
    tally["hashes"] += 1
    return data.decode("utf-8")


def nonempty(items, label):
    if not items:
        raise Blocked(f"empty inventory: {label}")
    return items


def check_inventory(record):
    if record.get("schema") != "competitive-landscape-corrections-1":
        raise Failed("unsupported correction schema")
    corrections = nonempty(record.get("corrections"), "corrections")
    if not isinstance(corrections, list) or not all(isinstance(c, dict) for c in corrections):
        raise Failed("corrections must be a list of records")
    seen = set()
    for correction in corrections:
        name = correction.get("id")
        if not isinstance(name, str) or name not in REQUIRED_SECTIONS:
            raise Failed(f"unexpected correction id: {name!r}")
        if name in seen:
            raise Failed(f"duplicate correction id: {name}")
        seen.add(name)
        for section in ("scenario", "evidence") + REQUIRED_SECTIONS[name]:
            nonempty(correction.get(section), f"{name} {section}")
        if name in REQUIRED_CELLS:
            grades = correction["effective_grades"]
            if not isinstance(grades, dict):
                raise Failed(f"{name}: effective_grades must be an object")
            missing = REQUIRED_CELLS[name] - grades.keys()
            if missing:
                raise Blocked(f"{name}: missing grade cells: {sorted(missing)}")
            extra = grades.keys() - REQUIRED_CELLS[name]
            if extra:
                raise Failed(f"{name}: unexpected grade cells: {sorted(extra)}")
    missing = REQUIRED_SECTIONS.keys() - seen
    if missing:
        raise Blocked(f"missing corrections: {sorted(missing)}")
    return corrections


def check_statements(entries, label, tally):
    for entry in entries:
        text = bound_text(entry, tally)
        if entry["contains"] not in text:
            raise Failed(f"{label}: statement absent from {entry['path']}: {entry['contains']!r}")
        tally["statements"] += 1


def check_evidence(entries, tally):
    for entry in entries:
        lines = bound_text(entry, tally).split("\n")
        number = entry["line"]
        if not 1 <= number <= len(lines):
            raise Failed(f"cited line {number} outside {entry['path']} ({len(lines)} lines)")
        if entry["contains"] not in lines[number - 1]:
            raise Failed(f"{entry['path']}:{number} does not contain {entry['contains']!r}")
        tally["lines"] += 1


def report_members(html):
    marker = html.find('id="report-data"')
    if marker < 0:
        raise Failed("report-data element absent from report")
    start = html.index(">", marker) + 1
    end = html.index("</script>", start)
    data = json.loads(html[start:end])
    members = [m for s in data["capability"]["selections"] for m in s["members"]]
    return nonempty(members, "report capability members")


def check_calibration(entries, members, tally):
    for entry in entries:
        prefix = f"competitors/{entry['tool']}.md"
        matches = [finding
                   for member in members if member["link"].startswith(prefix)
                   for finding in member["findings"].get(entry["cell"], [])
                   if finding.get("support") == entry["support"]
                   and (finding.get("claim") or "").startswith(entry["claim_prefix"])]
        if not matches:
            raise Failed(f"report has no {entry['support']} {entry['cell']} finding for "
                         f"{entry['tool']} starting {entry['claim_prefix']!r}")
        tally["calibrations"] += 1


def git(*arguments):
    try:
        result = subprocess.run(["git", *arguments], cwd=REPO, text=True,
                                env=dict(os.environ, TZ="UTC"),
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=60)
    except OSError as error:
        raise Blocked(f"git unavailable: {error.strerror}")
    if result.returncode != 0:
        raise Failed(f"git {' '.join(arguments)} failed: {result.stderr.strip()}")
    return result.stdout


def check_commit(commit, tally):
    added = git("show", "--name-status", "--format=", commit["sha"]).splitlines()
    if f"A\t{commit['adds']}" not in added:
        raise Failed(f"commit {commit['sha']} does not add {commit['adds']}")
    stamp = git("show", "-s", "--format=%ad", "--date=format-local:%Y-%m-%dT%H:%M:%SZ",
                commit["sha"]).strip()
    if stamp != commit["author_time_utc"]:
        raise Failed(f"commit time {stamp} differs from recorded {commit['author_time_utc']}")
    if not commit["interval_start_utc"] <= stamp <= commit["interval_recorded_through_utc"]:
        raise Failed(f"commit time {stamp} lies outside the recorded implementation interval")
    tally["commits"] += 1


def zero_counts():
    return {role: 0 for role in ROLES}


def check_accounting(accounting, tally):
    lines = bound_text(accounting["source"], tally).split("\n")
    if lines and lines[-1] == "":
        lines.pop()
    if len(lines) != accounting["physical_lines"]:
        raise Failed(f"physical lines {len(lines)} differ from recorded {accounting['physical_lines']}")
    counts = {}
    expected = 1
    for first, last, owner, role in nonempty(accounting["ranges"], "accounting ranges"):
        if first != expected or last < first:
            raise Failed(f"ranges not contiguous at line {expected}: [{first}, {last}]")
        if role not in ROLES:
            raise Failed(f"unknown role {role!r}")
        for number in range(first, last + 1):
            if (lines[number - 1].strip() == "") != (role == "blank"):
                raise Failed(f"line {number}: blank state disagrees with role {role}")
        counts.setdefault(owner, zero_counts())[role] += last - first + 1
        expected = last + 1
    if expected != len(lines) + 1:
        raise Failed(f"ranges end at line {expected - 1}, file has {len(lines)} lines")
    if counts != accounting["counts"]:
        raise Failed(f"recomputed counts {counts} differ from recorded counts")
    frozen = json.loads(bound_text(accounting["frozen_workflow_record"], tally))["counts"]
    combined = {}
    for source in (frozen, counts):
        for owner, roles in source.items():
            target = combined.setdefault(owner, zero_counts())
            for role in ROLES:
                target[role] += roles[role]
    if combined != accounting["combined_with_workflow_record"]:
        raise Failed(f"combined counts {combined} differ from recorded combined counts")
    tally["accounted_lines"] += len(lines)


def run(record_path):
    try:
        raw = record_path.read_bytes()
    except OSError as error:
        raise Blocked(f"missing or unreadable record: {record_path} ({error.strerror})")
    if not raw:
        raise Blocked(f"empty record: {record_path}")
    record = json.loads(raw)
    corrections = check_inventory(record)
    tally = {key: 0 for key in ("hashes", "statements", "lines", "calibrations",
                                "historical_grades", "commits", "accounted_lines")}
    labels = set(record["grade_labels"])
    html = bound_text(record["report"], tally)
    members = report_members(html)
    for correction in corrections:
        name = correction["id"]
        scenario = correction["scenario"]
        spec = bound_text(scenario, tally)
        if f"#### Scenario: {scenario['name']}" not in spec:
            raise Failed(f"{name}: scenario {scenario['name']!r} absent from {scenario['path']}")
        check_statements(correction.get("supersedes", []) + correction.get("completes", []), name, tally)
        check_evidence(nonempty(correction.get("evidence", []), f"{name} evidence"), tally)
        if "effective_grades" in correction:
            for cell, grade in nonempty(correction["effective_grades"], f"{name} grades").items():
                if grade not in labels:
                    raise Failed(f"{name}: {cell} grade {grade!r} is not a report label")
            for historical in nonempty(correction["historical_report_grades"], f"{name} history"):
                if historical not in html:
                    raise Failed(f"{name}: historical grade absent from report: {historical}")
                tally["historical_grades"] += 1
            check_calibration(nonempty(correction["calibration"], f"{name} calibration"), members, tally)
        if "commit" in correction:
            check_commit(correction["commit"], tally)
        if "accounting" in correction:
            check_accounting(correction["accounting"], tally)
    return len(corrections), tally


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--record", type=Path, default=DEFAULT_RECORD)
    args = parser.parse_args()
    try:
        count, tally = run(args.record.resolve())
    except Blocked as error:
        print(f"BLOCKED: {error}", file=sys.stderr)
        return 3
    except Failed as error:
        print(f"FAILED: {error}", file=sys.stderr)
        return 1
    except (KeyError, TypeError, ValueError) as error:
        print(f"FAILED: malformed record or report data: {error!r}", file=sys.stderr)
        return 1
    details = ", ".join(f"{key}={value}" for key, value in tally.items())
    print(f"CORRECTIONS PASSED: {count} corrections; {details}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
