#!/usr/bin/env python3
"""respec_lint — detect abstraction shortcuts in Quint protocol specs.

Four detectors, each derived from a confirmed defect in the v1 corpus:

  D1 WRITE-ONLY FIELD      a record field written/copied but never read in a
                           guard.  Witness: liquity.qnt `Trove.rate` — the sort
                           key, carried and never compared.
  D2 DEAD STATE            a state var whose only non-frame assignment count is
                           <= 1.  Witness: gmx.qnt `impactPool` — six frame
                           no-ops, one real write, price impact absent.
  D3 COMMENTED NO-OP       a comment naming a mechanism, immediately followed by
                           identity assignments.  Witness: morpho_blue.qnt:156
                           "bad debt: ... socialize" over three no-ops.
  D4 NONDET SELECTION      driver `nondet` over an element identity that a
                           protocol-selection action then uses as a map key.
                           Witness: liquity.qnt `redeem(u, ...)` with
                           `nondet u = USERS.oneOf()` — the contract walks a
                           sorted list; the spec is told which trove.

Usage:  respec_lint.py <spec.qnt> [more.qnt ...]
        respec_lint.py --dir /path/to/models
Exit 1 if any finding, so it can gate a re-spec.
"""
import re
import sys
import glob
import os
from collections import defaultdict

IDENT = r"[A-Za-z_][A-Za-z0-9_]*"
CMP = r"(?:==|!=|<=|>=|<|>)"
# actions where the PROTOCOL picks the target, not the caller
# Actions where the PROTOCOL picks the target. "close" is deliberately absent:
# a user closing their own position is caller-exogenous and legitimate.
SELECTION_VERBS = ("redeem", "liquidat", "absorb", "seize", "settle",
                   "fill", "match", "clear", "auction", "sweep", "harvest",
                   "slash", "default", "writeoff", "socializ")
# comment words that name a mechanism (so a no-op underneath is a deletion)
MECH_WORDS = ("socializ", "accru", "liquidat", "distribut", "apply", "enforc",
              "absorb", "impact", "waterfall", "subordinat", "haircut",
              "discount", "penalt", "slash", "writedown", "write-down",
              "bad debt", "loss", "fee", "premium", "settle")


def strip_comments(src):
    return re.sub(r"//[^\n]*", "", src)


def guard_lines(src):
    """Lines plausibly in a guard/boolean position."""
    out = []
    for ln in src.splitlines():
        s = ln.strip()
        if not s or s.startswith("//"):
            continue
        if re.search(CMP, s) and "'" not in s.split("=")[0]:
            out.append(s)
        elif re.match(r"^(and|or|not|all|any)\b", s):
            out.append(s)
    return out


def analyse(path):
    raw = open(path, encoding="utf-8", errors="replace").read()
    src = strip_comments(raw)
    findings = []

    # ---------- D1: write-only record fields ----------
    fields = set()
    for m in re.finditer(r"type\s+(%s)\s*=\s*\{([^}]*)\}" % IDENT, src, re.S):
        for f in m.group(2).split(","):
            if ":" in f:
                fields.add(f.split(":")[0].strip())
    gl = "\n".join(guard_lines(src))
    for f in sorted(fields):
        writes = len(re.findall(r"\b%s\s*:" % re.escape(f), src))       # in record literals
        copies = len(re.findall(r"\.%s\b" % re.escape(f), src))          # field reads
        read_in_guard = len(re.findall(r"\.%s\b" % re.escape(f), gl))
        if writes >= 1 and read_in_guard == 0:
            findings.append(("D1", f,
                             f"field written {writes}x, accessed {copies}x, "
                             f"read in a guard 0x — carried, never decides anything"))

    # ---------- D2: dead / near-dead state ----------
    varnames = set(re.findall(r"^\s*var\s+(%s)" % IDENT, src, re.M))
    for v in sorted(varnames):
        asgn = [a.strip() for a in
                re.findall(r"\b%s'\s*=\s*([^,\n]*)" % re.escape(v), src)]
        frames = sum(1 for a in asgn if a == v)
        real = [a for a in asgn if a != v]
        nontrivial = [a for a in real if not re.fullmatch(r"-?\d+", a)
                      and not re.fullmatch(r"(List|Set|Map)\(\s*\)", a)]
        # A var assigned directly from a bare identifier that is neither itself
        # nor another state var is being set from an action parameter — i.e. it
        # is a legitimate exogenous input (an oracle price, a clock), not dead
        # state.  Exempt it.
        exogenous = any(re.fullmatch(IDENT, a) and a != v and a not in varnames
                        for a in nontrivial)
        # NOTE: do NOT exempt self-increments as "counters". `impactPool' =
        # impactPool + max(0, p.collateral)` is syntactically a self-increment
        # and is the confirmed gmx defect — GMX's price-impact function is
        # absent and the pool is fed only by liquidation residue. Exempting
        # counters loses that finding, so clocks are accepted as known noise.
        if not asgn or exogenous:
            continue
        if len(nontrivial) == 0 and frames >= 2:
            # declared mutable, never actually written: a constant wearing `var`.
            # Real, but a hygiene defect rather than a deleted mechanism.
            findings.append(("D2a", v,
                             f"{frames} frame no-ops, never substantively written — "
                             f"constant declared as `var`"))
        elif len(nontrivial) == 1 and frames >= 2:
            findings.append(("D2", v,
                             f"{frames} frame no-ops, 1 substantive write, no "
                             f"exogenous setter — state declared but never driven "
                             f"by its own mechanism"))

    # ---------- D6: written-but-never-read state ----------
    # Proposed after the uniswap_v2 pilot, which exposed a blind spot: v1's
    # `kLast` is written by mint/burn and read by NOTHING, because its only
    # reader (`_mintFee`, UniswapV2Pair.sol:89-107) was absent from the spec
    # entirely. D1 misses it (not a record field), D2 misses it (it has real
    # writes). A variable that is maintained and never consulted is a mechanism
    # deleted down to its bookkeeping.
    for v in sorted(varnames):
        # remove the declaration and every `v' = <rhs>` assignment, so what
        # remains is genuine reads (self-reads inside its own update don't count)
        stripped = re.sub(r"^\s*var\s+%s\s*:[^\n]*" % re.escape(v), "", src, flags=re.M)
        stripped = re.sub(r"\b%s'\s*=\s*[^,\n]*" % re.escape(v), "", stripped)
        reads = len(re.findall(r"\b%s\b" % re.escape(v), stripped))
        asgn = [a.strip() for a in
                re.findall(r"\b%s'\s*=\s*([^,\n]*)" % re.escape(v), src)]
        substantive = [a for a in asgn
                       if a != v and not re.fullmatch(r"-?\d+", a)
                       and not re.fullmatch(r"(List|Set|Map)\(\s*\)", a)]
        if reads == 0 and len(substantive) >= 1:
            findings.append(("D6", v,
                             f"{len(substantive)} substantive write(s), read by "
                             f"nothing — state maintained but never consulted; its "
                             f"consumer is likely missing from the spec"))

    # ---------- D3: commented no-op ----------
    lines = raw.splitlines()

    def is_identity(text):
        t = text.strip().rstrip(",")
        m = re.fullmatch(r"(%s)'\s*=\s*(%s)" % (IDENT, IDENT), t)
        return bool(m and m.group(1) == m.group(2))

    for i, ln in enumerate(lines):
        # A mechanism-naming comment may be standalone OR trailing. The trailing
        # form is the confirmed apex defect:
        #   marginPool' = marginPool,  // simplified: collateral absorbed, ...
        # so matching only standalone comments misses it.
        if "//" not in ln:
            continue
        code, comment = ln.split("//", 1)
        low = comment.lower()
        if not any(w in low for w in MECH_WORDS):
            continue
        noops = 1 if (code.strip() and is_identity(code)) else 0
        start = i if noops else i + 1
        for j in range(start + 1, min(start + 5, len(lines))):
            t = lines[j].split("//")[0]
            if is_identity(t):
                noops += 1
            elif t.strip():
                break
        if noops >= 2:
            kind = "trailing" if code.strip() else "standalone"
            findings.append(("D3", f"line {i+1}",
                             f"{kind} comment names a mechanism, {noops} adjacent "
                             f"assignments are identities: //{comment.strip()[:58]}"))

    # ---------- D4: nondet over protocol-selected identity ----------
    nondets = dict(re.findall(r"nondet\s+(%s)\s*=\s*(%s)" % (IDENT, IDENT), src))
    for m in re.finditer(r"^\s*(%s)\s*\(([^)]*)\)\s*,?\s*$" % IDENT, src, re.M):
        act, args = m.group(1), m.group(2)
        if not any(v in act.lower() for v in SELECTION_VERBS):
            continue
        for a in [x.strip() for x in args.split(",")]:
            if a in nondets:
                # Is that parameter used as a map key inside the action?
                #
                # The previous body regex terminated on the first nested `val`,
                # and `val t = troves.get(u)` is typically the FIRST line of the
                # body — so `keyed` was always false and D4a never fired. Use a
                # generous character window from the action header instead:
                # over-inclusive is fine for a screen, silently-empty is not.
                # `keyed` must be decided for THIS argument, not for the action.
                # A previous version broke out of the parameter loop on the first
                # keying parameter and then attributed that flag to every
                # argument — so in `startAuction(u, sid)` the integer `sid`,
                # which keys nothing, was reported as D4a because `u` keys. That
                # collapses the D4a/D4b split for every action with more than one
                # driver-supplied argument, i.e. exactly where it matters.
                hdr = re.search(r"action\s+%s\s*\(([^)]*)\)" % re.escape(act), src)
                keyed = False
                if hdr:
                    params = [p.split(":")[0].strip() for p in hdr.group(1).split(",")]
                    window = src[hdr.end(): hdr.end() + 2500]
                    # stop at the next module-level action/def to avoid bleeding
                    nxt = re.search(r"\n\s{0,4}(?:action|pure\s+def|def)\s+", window)
                    if nxt:
                        window = window[:nxt.start()]
                    # map the driver-site argument `a` to the formal it binds to,
                    # positionally, then ask whether THAT formal keys state
                    argv = [x.strip() for x in args.split(",")]
                    formal = None
                    if a in argv:
                        i = argv.index(a)
                        if i < len(params):
                            formal = params[i]
                    for cand in ([formal] if formal else params):
                        if cand and re.search(
                                r"\.(get|put|set)\s*\(\s*%s\b" % re.escape(cand), window):
                            keyed = True
                            break
                # D4a vs D4b (pilot/W3 finding): the `keyed` flag was previously
                # computed and thrown away into message text, so the linter
                # scored a REPAIRED `redeemCollateral(boldAmt)` exactly as
                # loudly as the defective `redeem(u, boldAmt)` — it could not
                # tell a defect from its own repair. Keyed means the parameter
                # indexes protocol state, i.e. it names WHICH element; unkeyed
                # is usually an exogenous quantity (an amount), which is
                # legitimate.
                # 6h EXEMPTION (D4c). A caller modelled per convention 6h is a
                # driver-supplied identity BY DESIGN, and D4 cannot distinguish
                # it from a deleted selection. The test is not the name of the
                # parameter but whether it is USED AS A CALLER: passed to an
                # authority predicate, or compared against authority state.
                # Reported, not suppressed -- an invisible exemption is how a
                # linter stops being trusted.
                authority = None
                if formal:
                    fesc = re.escape(formal)
                    m6 = (re.search(r"\b((?:is|has|only)[A-Z]\w*)\s*\(\s*%s\b"
                                    % fesc, window)
                          or re.search(r"%s\s*==\s*([A-Z][A-Z0-9_]{2,})" % fesc,
                                       window)
                          or re.search(r"%s\s*==\s*(curator|owner|admin|operator|"
                                       r"custodian|guardian|manager)\b" % fesc,
                                       window, re.I))
                    if m6:
                        authority = m6.group(1)
                if authority:
                    findings.append(("D4c", f"{act}({a})",
                                     f"`{a}` is a caller modelled under convention "
                                     f"6h, guarded by `{authority}` — exempt from "
                                     f"D4a/D4b, not counted"))
                elif keyed:
                    findings.append(("D4a", f"{act}({a})",
                                     f"driver picks `{a}` from {nondets[a]} and the "
                                     f"selection action uses it as a map key — the "
                                     f"protocol is being told WHICH element to act on"))
                else:
                    findings.append(("D4b", f"{act}({a})",
                                     f"driver picks `{a}` from {nondets[a]} for a "
                                     f"selection action but never keys state with it "
                                     f"— likely an exogenous quantity; confirm it is "
                                     f"not an identity"))
    return findings


def main():
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        return 2
    if args[0] == "--dir":
        paths = sorted(glob.glob(os.path.join(args[1], "**", "*.qnt"), recursive=True))
    else:
        paths = args
    total = 0
    for p in paths:
        # NOTE: kernel.qnt was previously skipped here. That was wrong (pilot
        # trap K5): the kernel is the shared machinery every spec depends on,
        # so exempting it left the most load-bearing file in the tree unchecked.
        # It is now linted like anything else.
        f = analyse(p)
        if not f:
            continue
        print(f"\n=== {p}")
        for code, where, why in f:
            print(f"  [{code}] {where}: {why}")
        # D4c is a 6h caller exemption: printed so it can be audited, not
        # counted, because it is a compliance marker rather than a defect.
        total += len([x for x in f if x[0] != "D4c"])
    print(f"\n{'-'*60}\nTOTAL FINDINGS: {total} across {len(paths)} spec(s)")
    return 1 if total else 0


if __name__ == "__main__":
    sys.exit(main())
