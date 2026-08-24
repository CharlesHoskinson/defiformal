#!/usr/bin/env python3
"""Extract the outermost balanced JSON object from noisy CLI output.

Some council members (grok, observed) narrate their next tool call inline
with their final answer, so raw stdout is not valid JSON on its own even
though a single well-formed JSON object is present in it, e.g.:

    I'll read `./brief.md` now and follow it exactly.The brief requires
    `./bundle.md` next, so I'll read that and then return only the
    specified JSON.{"lens":"smoke","verdict":"rejected","summary":"..."}

This module tries each '{' in the text in turn -- brace-counting from it,
respecting JSON string literals and backslash escapes, not a regex, and
not "the last '}' in the file" -- and returns the first one whose count
balances and whose span parses as JSON. A '{' that fails (unbalanced, or
balanced but not valid JSON) is skipped in favour of the next one; only
running out of '{' candidates entirely is a genuine failure.

Observed 2026-08-23, council/sprint1/reports/R1-empirical-grok.json,
round-1 attempt 1 (4,915 bytes, since overwritten by the retry that
produced the file now on disk): stdout carried a truncated, self-
interrupted JSON fragment immediately ahead of the real, complete
object --

    {"lens":"emp{"lens":"empirical","ranking":["C","B","A"],...}

-- so brace-counting from the first '{' consumed the real object's own
braces without the count ever returning to zero: no balanced match, full
stop. This case was previously noted in this docstring as a theoretical
gap ("no fallback search for a later '{'"); it is now handled by moving
on to the next '{' rather than failing outright at the first one. (It
does not, by itself, make such a report pass validate-reports.py: the
recovered span is still preceded by discarded bytes, so `needed` is still
True and the "no prose outside the object" contract still correctly
rejects it -- this fix only turns "extraction is fundamentally impossible"
into "extraction found the object, and the report has a separate,
genuine prose problem".)

Used by council/bin/smoke-members.sh's smoke check, and intended for reuse
by Task 5's validate-reports.py, so the extraction rule lives in exactly
one place rather than being reimplemented (and possibly redefined) twice.

Exit codes (repo-wide convention: 0 true, 1 false, 3 could not run):
  0  extraction succeeded and all --require-key keys were present; the
     compact JSON object is on stdout.
  1  no balanced, parseable JSON object exists in the input, or one does
     but is missing a required key -- a genuine "property false", not an
     error running the check.
  3  the input file could not be read at all (missing, unreadable, not
     a decodable text file) -- "could not run", never conflated with 1.
"""
import argparse
import json
import sys


def extract_balanced_json(text):
    """Return (obj, needed_extraction) for the first balanced, parseable
    JSON object in text, or (None, None) if there isn't one.

    needed_extraction is True iff any non-whitespace byte outside the
    matched {...} span was discarded -- i.e. text was not already exactly
    one JSON object give or take surrounding whitespace.
    """
    pos = 0
    while True:
        start = text.find("{", pos)
        if start == -1:
            return None, None
        end = _find_matching_brace(text, start)
        if end is not None:
            candidate = text[start:end + 1]
            try:
                obj = json.loads(candidate)
            except ValueError:
                pass
            else:
                before, after = text[:start], text[end + 1:]
                needed = bool(before.strip()) or bool(after.strip())
                return obj, needed
        # This '{' didn't lead anywhere -- either brace-counting never
        # returned to zero, or it did but the span isn't valid JSON (e.g.
        # a brace inside a string that _find_matching_brace's own string-
        # tracking mis-set for some earlier reason). Try the next '{'.
        pos = start + 1


def _find_matching_brace(text, open_idx):
    """Brace-count text[open_idx:] (text[open_idx] must be '{') to its
    match, respecting JSON string literals and backslash escapes inside
    them so a brace character in a string value doesn't perturb the
    count. Returns the index of the matching '}', or None if the text
    ends with the braces still unbalanced."""
    assert text[open_idx] == "{"
    depth = 0
    in_string = False
    escape = False
    for i in range(open_idx, len(text)):
        ch = text[i]
        if in_string:
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == '"':
                in_string = False
            continue
        if ch == '"':
            in_string = True
        elif ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return i
    return None


def main(argv):
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("path", help="file containing the member's raw stdout")
    p.add_argument("--require-key", action="append", default=[],
                    metavar="KEY",
                    help="fail (exit 1) unless KEY is present in the "
                         "extracted object; repeatable")
    args = p.parse_args(argv)

    try:
        with open(args.path, "r", encoding="utf-8", errors="replace") as f:
            text = f.read()
    except OSError as e:
        print(f"extract-json: could not read {args.path}: {e}", file=sys.stderr)
        return 3

    obj, needed = extract_balanced_json(text)
    if obj is None:
        print("extract-json: no balanced JSON object found", file=sys.stderr)
        return 1

    missing = [k for k in args.require_key if k not in obj]
    if missing:
        print(f"extract-json: missing required key(s): {', '.join(missing)}",
              file=sys.stderr)
        return 1

    print(f"extract-json: extraction {'was' if needed else 'was not'} necessary",
          file=sys.stderr)
    print(json.dumps(obj))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
