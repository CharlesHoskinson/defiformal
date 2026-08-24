#!/usr/bin/env python3
import hashlib
import sys
import os

# Resolve paths from script location, not cwd
script_dir = os.path.dirname(os.path.abspath(__file__))
repo_root = os.path.dirname(os.path.dirname(script_dir))

briefs = [
    "BRIEF-empirical.md",
    "BRIEF-formal.md",
    "BRIEF-significance.md",
    "BRIEF-reproducer.md",
]

hashes = {}
extracted = {}

for brief in briefs:
    path = os.path.join(repo_root, "council/sprint1", brief)
    try:
        with open(path) as f:
            lines = f.readlines()
    except Exception as e:
        print(f"  FAIL: Could not read {brief}: {e}")
        sys.exit(3)

    # Find the Standards bullet by content anchor
    # Look for the line starting with "- The three candidates"
    bullet_start = None
    for i, line in enumerate(lines):
        if line.startswith("- The three candidates are recorded"):
            bullet_start = i
            break

    if bullet_start is None:
        print(f"  FAIL: Could not find Standards bullet in {brief}")
        sys.exit(3)

    # Extract the bullet (current line + next 2 lines for the continuation)
    bullet_lines = lines[bullet_start:bullet_start+3]
    bullet = "".join(bullet_lines)

    # Store for later display on mismatch
    extracted[brief] = bullet

    # Hash the extracted bullet
    h = hashlib.md5(bullet.encode()).hexdigest()
    hashes[brief] = h

# Verify all hashes are identical
first_hash = list(hashes.values())[0]
first_brief = list(hashes.keys())[0]

if not first_hash or first_hash == "d41d8cd98f00b204e9800998ecf8427e":
    print("  FAIL: Standards bullet is empty")
    sys.exit(1)

all_match = True
for brief, h in hashes.items():
    if h != first_hash:
        print(f"  FAIL: Standards bullet hash mismatch in {brief}")
        print(f"    Expected ({first_brief}):")
        print("    " + "\n    ".join(extracted[first_brief].rstrip().split("\n")))
        print(f"    Got ({brief}):")
        print("    " + "\n    ".join(extracted[brief].rstrip().split("\n")))
        all_match = False

if not all_match:
    sys.exit(1)

print("  ok   Standards bullet identity: all four briefs have byte-identical sentence")
sys.exit(0)
