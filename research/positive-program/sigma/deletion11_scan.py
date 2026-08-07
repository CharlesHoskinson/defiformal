"""Deletion class 11 (access control), counted across all 51 protocol specs.

`wbtc.confirmMint` carries the comment "onlyCustodian" and the signature
`(id: int)`. P2-SCOPE recorded ten deletions across the ten protocols someone
looked at; this is an eleventh, in a protocol nobody re-specced. The question is
how many more there are.

THE CLASS: an action whose OWN COMMENT asserts an access restriction, and whose
code models no caller at all.

CALIBRATION -- deliberately biased toward UNDER-reporting. Two detectors have
already produced false positives in this programme by being generous (`owner`
matched as a caller check when it is a record field; `n=2` notation missed
entirely). So:

  * the authority claim must appear in THIS action's own comment block or body
    comments, not anywhere in the file;
  * anything that looks like caller modelling counts as MODELLED -- a caller-ish
    parameter, a membership test against a constant set, a comparison against an
    authority identifier, or a guard on a role-ish state variable. A spec that
    models authority in any of these ways is not counted as a deletion.

So the reported number is a FLOOR. Actions that model authority sloppily are
credited as modelling it.
"""
import glob
import os
import re

ROOT = "/root/DefiElements/quint-models"

# An action header, keeping the preceding comment block.
ACTION = re.compile(r"^([ \t]*)action\s+([A-Za-z_][A-Za-z0-9_]*)\s*"
                    r"(\(([^)]*)\))?", re.M)

# A comment asserting an access restriction.
CLAIM = re.compile(
    r"(only[A-Z][A-Za-z]*|onlyOwner|only\s+(the\s+)?(owner|admin|custodian|"
    r"governance|guardian|operator|issuer|keeper|manager|minter|oracle)|"
    r"\bpermissioned\b|\bauthori[sz]ed\b|\baccess\s+control\b|"
    r"msg\.sender\s*==|\brole\b|\bonly-|\bgated\b)", re.I)

# Anything that counts as MODELLING a caller. Generous on purpose.
CALLER_PARAM = re.compile(
    r"\b(caller|sender|who|u|user|acct|account|addr|by)\s*:", re.I)
MODELS = re.compile(
    r"(?<![.\w])(caller|sender|msgSender|isAdmin|onlyOwner|ADMINS?|OWNERS?|"
    r"CUSTODIAN\w*|GOVERNANCE|GUARDIAN\w*|OPERATORS?|ISSUERS?|MINTERS?|"
    r"KEEPERS?|MANAGERS?|AUTHORITY|ROLE\w*|authorized|permitted)\b")


def comment_block_before(src, idx):
    """The contiguous // comment lines immediately above position idx."""
    head = src[:idx].rstrip()
    lines = head.split("\n")
    out = []
    for line in reversed(lines):
        s = line.strip()
        if s.startswith("//"):
            out.append(s)
        elif s == "":
            if out:
                break
        else:
            break
    return "\n".join(reversed(out))


specs = [p for p in sorted(glob.glob(f"{ROOT}/L*/*.qnt"))
         if os.path.basename(p) != "common.qnt"]
print(f"scanning {len(specs)} protocol specs\n")

findings = []
claims = modelled = 0
for path in specs:
    raw = open(path, encoding="utf-8", errors="replace").read()
    hits = list(ACTION.finditer(raw))
    for i, m in enumerate(hits):
        name, params = m.group(2), m.group(4) or ""
        end = hits[i + 1].start() if i + 1 < len(hits) else len(raw)
        body = raw[m.end():end]
        doc = comment_block_before(raw, m.start())
        body_comments = "\n".join(
            l for l in body.split("\n") if l.strip().startswith("//"))
        claim_text = doc + "\n" + body_comments
        cm = CLAIM.search(claim_text)
        if not cm:
            continue
        claims += 1
        code = re.sub(r"//[^\n]*", "", body)
        if CALLER_PARAM.search(params) or MODELS.search(code) or MODELS.search(params):
            modelled += 1
            continue
        lane = path.split("/")[-2]
        line_no = raw[:m.start()].count("\n") + 1
        findings.append((lane, os.path.basename(path)[:-4], name, line_no,
                         cm.group(0)[:26], params[:22]))

print(f"actions whose own comment asserts an access restriction : {claims}")
print(f"   of those, modelling a caller in any form             : {modelled}")
print(f"   of those, modelling NOTHING  (deletion class 11)      : {len(findings)}")
print()
print(f"{'lane':<4} {'spec':<14} {'action':<24} {'line':>5}  {'claim':<26} params")
print("-" * 92)
for f in sorted(findings):
    print(f"{f[0]:<4} {f[1]:<14} {f[2][:24]:<24} {f[3]:>5}  {f[4]:<26} {f[5]}")

by_lane = {}
by_spec = {}
for f in findings:
    by_lane[f[0]] = by_lane.get(f[0], 0) + 1
    by_spec[f[1]] = by_spec.get(f[1], 0) + 1
print(f"\nby lane: " + "  ".join(f"{k} {v}" for k, v in sorted(by_lane.items())))
print(f"specs affected: {len(by_spec)} of {len(specs)}")
print("\nP2-SCOPE recorded 10 deletions across the 10 re-specced protocols.")
inside = {"uniswap_v2", "curve", "compound_v3", "morpho_blue", "liquity",
          "apex", "gmx", "huma", "derive", "polymarket"}
out = sorted(s for s in by_spec if s not in inside)
print(f"Of the specs above, {len(out)} are OUTSIDE that list: {', '.join(out)}")
