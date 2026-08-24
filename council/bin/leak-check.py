#!/usr/bin/env python3
"""Refuse a bundle that leaks who wrote it or what produced it.

A blinded council is worth nothing if the panel can tell whose work it is
reviewing, and the log records "blinded" whether or not the blinding held.
This is the check that makes the log's claim true.

Exit: 0 clean, 1 leaked, 3 could not run.
"""
import pathlib
import re
import sys

PATTERNS = [
    ("author",  r"\bhoskinson\b|\bcharles\b"),
    ("repo",    r"\bdefiformal\b|\bDefiElements\b"),
    ("path",    r"/root/|/home/charl|/mnt/c/Users"),
    ("forge",   r"(?:github|gitlab|bitbucket)\.com/[A-Za-z0-9_-]*(?:hoskinson|defiformal|defielements)[A-Za-z0-9_-]*"),
    ("vendor",  r"\banthropic\b|\bopenai\b|\bxai\b|\bgoogle\s+deepmind\b"),
    ("model",   r"\bclaude\b|\bgpt-?[0-9]\b|\bgrok\b|\bgemini\b|\bopus\b|\bsonnet\b|\bfable\b"),
]

def main(argv):
    if len(argv) != 2:
        print("usage: leak-check.py <file>", file=sys.stderr)
        return 3
    p = pathlib.Path(argv[1])
    if not p.is_file():
        print("leak-check: BLOCKED - no such file: %s" % p, file=sys.stderr)
        return 3
    text = p.read_text(encoding="utf-8", errors="replace")
    if not text.strip():
        print("leak-check: BLOCKED - file is empty; nothing was checked", file=sys.stderr)
        return 3

    hits = []
    for label, pat in PATTERNS:
        for m in re.finditer(pat, text, re.IGNORECASE):
            line = text[:m.start()].count("\n") + 1
            hits.append((label, line, m.group(0)))

    for label, line, s in hits:
        print("  LEAK %-8s %s:%d  %r" % (label, p, line, s))
    print("leak-check: %d pattern class(es), %d hit(s)" % (len(PATTERNS), len(hits)))
    return 1 if hits else 0

if __name__ == "__main__":
    sys.exit(main(sys.argv))
