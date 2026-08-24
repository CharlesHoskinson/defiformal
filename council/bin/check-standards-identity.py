#!/usr/bin/env python3
import hashlib
import sys
import os

# Assume we're running from the repo root
repo_root = os.getcwd()

briefs = {
    "BRIEF-empirical.md": (35, 37),
    "BRIEF-formal.md": (34, 36),
    "BRIEF-significance.md": (35, 37),
    "BRIEF-reproducer.md": (35, 37),
}

hashes = {}
for brief, (start, end) in briefs.items():
    path = os.path.join(repo_root, "council/sprint1", brief)
    try:
        with open(path) as f:
            lines = f.readlines()
            # Get lines in the range (1-indexed in the hash dict, 0-indexed in list)
            bullet_lines = lines[start-1:end]
            bullet = "".join(bullet_lines)
            h = hashlib.md5(bullet.encode()).hexdigest()
            hashes[brief] = h
    except Exception as e:
        print(f"  FAIL: Could not read {brief}: {e}")
        sys.exit(1)

# Verify all hashes are identical
first_hash = list(hashes.values())[0]
if not first_hash or first_hash == "d41d8cd98f00b204e9800998ecf8427e":
    print("  FAIL: Standards bullet is empty")
    sys.exit(1)

for brief, h in hashes.items():
    if h != first_hash:
        print(f"  FAIL: Standards bullet hash mismatch in {brief}")
        print(f"    Expected: {first_hash}")
        print(f"    Got:      {h}")
        sys.exit(1)

print("  ok   Standards bullet identity: all four briefs have byte-identical sentence")
sys.exit(0)
