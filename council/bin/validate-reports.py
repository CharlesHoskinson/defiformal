#!/usr/bin/env python3
"""Enforce the council output contract.

A member that returns prose, or JSON in markdown fences, has not answered the
brief. Catching that at collection costs one re-run; catching it at triage
costs a round, and a round is the scarce thing.

Deliberately strict about fences and preambles: the brief says "no prose before
or after, no markdown fences", so accepting them quietly would make the
instruction decorative.

Reuses council/bin/extract-json.py's extract_balanced_json() instead of
re-implementing brace/string-aware scanning here. That function already
answers exactly the question this validator needs -- does a single balanced
JSON object exist in the text, and was anything discarded outside it to find
it -- so a report is contract-clean iff extraction finds an object AND
needed no discarding. A bare substring check for "```" would also misfire on
a report whose own finding text legitimately quotes a code fence from the
bundle under review; extract_balanced_json only looks at what sits outside
the matched {...} span, so it doesn't share that false-positive risk.

ranking's shape depends on verdict: a full permutation of A, B, C for
"approved"/"changes_requested", but an empty array for
"insufficient_evidence" (see BRIEF-common.md's Output contract). A lens that
honestly reports insufficient_evidence with an empty ranking is obeying its
brief and must pass; a full ranking under that verdict is a contract
violation and must fail.

Exit: 0 all valid, 1 at least one invalid, 3 nothing to validate.
"""
import importlib.util
import pathlib
import sys

_HERE = pathlib.Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location(
    "_council_extract_json", _HERE / "extract-json.py")
_extract_json = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_extract_json)
extract_balanced_json = _extract_json.extract_balanced_json

TOP = ["lens", "ranking", "ranking_reason", "verdict", "summary",
       "findings", "strongest_candidate_argument", "dissent_note"]
FIND = ["id", "candidate", "severity", "claim", "problem", "falsifier",
        "fix", "status"]
VERDICTS = {"approved", "changes_requested", "insufficient_evidence"}

def check(path):
    raw = path.read_text(encoding="utf-8", errors="replace")
    problems = []

    doc, needed = extract_balanced_json(raw)
    if doc is None:
        problems.append("no single balanced, parseable JSON object found")
        return problems
    if not isinstance(doc, dict):
        problems.append("top level is not an object")
        return problems
    if needed:
        problems.append(
            "output is not exactly one JSON object -- prose or markdown "
            "fences present outside it")

    for k in TOP:
        if k not in doc:
            problems.append("missing %r" % k)

    verdict = doc.get("verdict")
    if verdict not in VERDICTS:
        problems.append("verdict %r not in contract" % (verdict,))

    r = doc.get("ranking")
    if verdict == "insufficient_evidence":
        if r != []:
            problems.append(
                "ranking must be an empty array when verdict is "
                "insufficient_evidence; got %r" % (r,))
    else:
        if not (isinstance(r, list) and sorted(str(x) for x in r) == ["A", "B", "C"]):
            problems.append(
                "ranking must be a permutation of A, B, C; got %r" % (r,))

    findings = doc.get("findings", [])
    if not isinstance(findings, list):
        problems.append("findings is not a list")
        findings = []
    for i, f in enumerate(findings):
        if not isinstance(f, dict):
            problems.append("finding %d is not an object" % i)
            continue
        for k in FIND:
            if k not in f or not str(f.get(k, "")).strip():
                problems.append("finding %s missing %r" % (f.get("id", i), k))

    if verdict == "changes_requested":
        sev = {str(f.get("severity")) for f in findings if isinstance(f, dict)}
        if not (sev & {"high", "medium"}):
            problems.append("changes_requested needs a high or medium finding")

    return problems

def main(argv):
    if len(argv) != 2:
        print("usage: validate-reports.py <dir>", file=sys.stderr)
        return 3
    d = pathlib.Path(argv[1])
    if not d.is_dir():
        print("validate-reports: BLOCKED - not a directory: %s" % d, file=sys.stderr)
        return 3
    files = sorted(d.glob("*.json"))
    if not files:
        print("validate-reports: BLOCKED - no reports in %s; nothing was validated" % d,
              file=sys.stderr)
        return 3
    bad = 0
    for f in files:
        problems = check(f)
        if problems:
            bad += 1
            print("  INVALID %s" % f.name)
            for p in problems:
                print("      %s" % p)
        else:
            print("  ok      %s" % f.name)
    print("validate-reports: %d report(s), %d invalid" % (len(files), bad))
    return 1 if bad else 0

if __name__ == "__main__":
    sys.exit(main(sys.argv))
