#!/usr/bin/env python3
"""Extract the outermost balanced JSON object from noisy CLI output.

Some council members (grok, observed) narrate their next tool call inline
with their final answer, so raw stdout is not valid JSON on its own even
though a single well-formed JSON object is present in it, e.g.:

    I'll read `./brief.md` now and follow it exactly.The brief requires
    `./bundle.md` next, so I'll read that and then return only the
    specified JSON.{"lens":"smoke","verdict":"rejected","summary":"..."}

This module finds the first '{' in the text and brace-counts -- respecting
JSON string literals and backslash escapes, not a regex, and not "the last
'}' in the file" -- to find its matching close, then parses that span as
JSON. If the first '{' doesn't lead to a balanced, parseable object, that
is a genuine failure: no fallback search for a later '{'.

Used by council/bin/smoke-members.sh's smoke check, and intended for reuse
by Task 5's validate-reports.py, so the extraction rule lives in exactly
one place rather than being reimplemented (and possibly redefined) twice.
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
    start = text.find("{")
    if start == -1:
        return None, None
    end = _find_matching_brace(text, start)
    if end is None:
        return None, None
    candidate = text[start:end + 1]
    try:
        obj = json.loads(candidate)
    except ValueError:
        return None, None
    before, after = text[:start], text[end + 1:]
    needed = bool(before.strip()) or bool(after.strip())
    return obj, needed


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

    with open(args.path, "r", encoding="utf-8", errors="replace") as f:
        text = f.read()

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
