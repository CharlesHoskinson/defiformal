> **Superseded as an execution mandate on 2026-09-06.** The user approved
> the [semantic-kernel migration](../specs/2026-09-06-semantic-kernel-design.md).
> Preserve the record below as historical evidence. Its primitive-basis and
> publication-first instructions do not govern new work.

# Sprint 1: Contribution Council — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Decide which of three contribution candidates becomes the manuscript's headline claim, by running one blinded council round, and record the decision in a form a later gate can check.

**Architecture:** A bundle builder extracts the three candidates from `paper/atlas.tex` into a blinded bundle; a leak checker refuses to ship it if identity survives; `foreman-launch` dispatches one sandboxed vendor CLI per lens with a bounded timeout; a validator rejects any report that does not meet the JSON contract; I triage findings into CONFIRMED / PLAUSIBLE / REFUTED; the surviving candidates become wiki claim pages that each name the command reproducing their figure.

**Tech Stack:** bash, python3 (3.14), node 24, `foreman-launch` (foreman `skills/foreman/runtime/dist/foreman-launch.js`), vendor CLIs `grok` / `claude` / `codex` / `gemini`.

**Spec:** `docs/superpowers/specs/2026-08-23-defiformal-aft-roadmap-design.md`

## Global Constraints

- Repository root is `/home/charl/defiformal`; `main` is at `d22048a`, clean.
- Never add `Co-Authored-By` or any AI attribution to a commit. Commit as `charles.hoskinson@gmail.com`.
- Every script resolves its root from its own location with a `DEFIFORMAL_ROOT` override, matching `formal/v3/xref-kinds.py`. No `/root/...` paths.
- Exit-code contract, repo-wide: `0` property holds, `1` property false, `3` check could not run.
- `foreman-launch` nulls the child's stdin. Any CLI form that reads the prompt from stdin (`codex exec -`) will hang or receive nothing. Prompts are passed positionally and point at a file in the sandbox.
- Files copied from `/mnt/c/...` into WSL land mode `755`; `chmod 644` non-scripts before committing.
- Never put `$` or backslash-bearing regexes in a heredoc that crosses the `wsl.exe` boundary. Write the file, copy it in, run it by path.
- Council output is advisory. The panel's severity labels are input; only my CONFIRMED-severe classification gates the sprint.
- Round budget: 2 rounds, hard cap 3. On reaching the cap without meeting the exit condition, stop and write what is open.

---

## File Structure

**Created:**

| Path | Responsibility |
|---|---|
| `council/bin/members.sh` | The verified per-CLI invocation table. One function per lens. |
| `council/bin/leak-check.py` | Refuses a bundle that leaks author, repo, vendor or model identity. |
| `council/bin/build-bundle.py` | Extracts the three candidates from `atlas.tex` into the blinded bundle. |
| `council/bin/dispatch.sh` | Runs one lens through `foreman-launch` in an empty sandbox. |
| `council/bin/validate-reports.py` | Enforces the JSON output contract on every returned report. |
| `council/sprint1/BUNDLE-blinded.md` | What the panel reads. Generated. |
| `council/sprint1/BUNDLE.sha256` | Hash of the blinded bundle. |
| `council/sprint1/BRIEF-common.md` | Threat model, standards, falsifier rule, output contract. |
| `council/sprint1/BRIEF-{empirical,formal,significance,reproducer}.md` | Per-lens briefs. |
| `council/sprint1/reports/` | `R<n>-<lens>-<cli>.json` and `.log`. |
| `council/sprint1/COUNCIL-LOG.md` | Run record: bundle hash, leak check, per-member status. |
| `council/sprint1/TRIAGE.md` | My CONFIRMED / PLAUSIBLE / REFUTED classification. |
| `docs/wiki/claims/README.md` | What a claim page is and the shape it must hold. |
| `docs/wiki/claims/*.md` | One page per surviving candidate. |
| `DECISION.md` (in `council/sprint1/`) | The headline claim, what it rests on, and the branch answer. |

**Modified:** none until Task 7. Sprint 1 does not touch `paper/atlas.tex`.

---

## Task 1: Verified invocation table

The riskiest unknown is whether each CLI returns contract-shaped JSON through `foreman-launch` at all. Every downstream task assumes it. Establish it first, and commit the exact commands that worked — not the ones the documentation implies.

**Files:**
- Create: `council/bin/members.sh`
- Create: `council/bin/smoke-fixture.md`

**Interfaces:**
- Produces: `run_member <lens> <sandbox-dir> <brief-file> <out-json> <out-log>` — dispatches one member, returns the child's exit code (124 = timed out, 125 = launcher error).

- [ ] **Step 1: Write the smoke fixture**

`council/bin/smoke-fixture.md`:

```markdown
# Fixture bundle

A vocabulary has 3 elements: A, B, C. A requires B. Nothing requires C.

## Claim under review

"C is redundant, because nothing requires it."
```

- [ ] **Step 2: Write the failing smoke test**

`council/bin/smoke-members.sh`:

```bash
#!/usr/bin/env bash
# Each CLI must return ONE JSON object with a "verdict" key, through
# foreman-launch, from an empty sandbox, with stdin nulled.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 3
[ -f council/bin/members.sh ] || { echo "members.sh absent"; exit 3; }
. council/bin/members.sh

pass=0; fail=0
for lens in empirical formal significance reproducer; do
  SB=$(mktemp -d)
  cp council/bin/smoke-fixture.md "$SB/bundle.md"
  cat > "$SB/brief.md" <<'BRIEF'
Read ./bundle.md. Decide whether the claim under review is sound.
Output ONLY a single JSON object, no prose, no markdown fences:
{"lens":"smoke","verdict":"approved","summary":"<=20 words"}
BRIEF
  out="$SB/out.json"; log="$SB/out.log"
  run_member "$lens" "$SB" "$SB/brief.md" "$out" "$log"; rc=$?
  if python3 -c "import json,sys; d=json.load(open(sys.argv[1])); sys.exit(0 if 'verdict' in d else 1)" "$out" 2>/dev/null; then
    echo "  ok   $lens (exit $rc)"; pass=$((pass+1))
  else
    echo "  FAIL $lens (exit $rc): $(head -c 120 "$log" 2>/dev/null)"; fail=$((fail+1))
  fi
  rm -rf "$SB"
done
echo "members smoke: $pass ok, $fail failed"
[ "$fail" -eq 0 ]
```

- [ ] **Step 3: Run it to verify it fails**

```bash
bash council/bin/smoke-members.sh
```

Expected: `members.sh absent`, exit 3.

- [ ] **Step 4: Write members.sh, discovering the working form per CLI**

Start from these and correct them against what actually runs. `foreman-launch` nulls stdin, so every prompt is positional and points at a file in the sandbox.

```bash
#!/usr/bin/env bash
# The verified invocation table. Each entry was confirmed by
# council/bin/smoke-members.sh, not taken from documentation.
#
# foreman-launch nulls the child's stdin, so `codex exec -` (stdin form)
# cannot be used here. Every prompt is positional and names a file the
# member reads from its own sandbox.
FL="$HOME/foreman/skills/foreman/runtime/dist/foreman-launch.js"
TIMEOUT="${COUNCIL_TIMEOUT:-900}"

_launch () {  # $1=outjson $2=outlog ; rest = command
  local out="$1" log="$2"; shift 2
  node "$FL" --timeout "$TIMEOUT" -- "$@" >"$out" 2>"$log"
}

run_member () {  # $1=lens $2=sandbox $3=brief $4=outjson $5=outlog
  local lens="$1" sb="$2" brief="$3" out="$4" log="$5"
  local ask="Read ./$(basename "$brief") in full and follow it exactly. Do not read any other file. Output only the JSON object it specifies."
  ( cd "$sb" || exit 125
    case "$lens" in
      empirical)    _launch "$out" "$log" grok --single "$ask" -m grok-4.6 --effort high ;;
      formal)       _launch "$out" "$log" claude -p --model claude-opus-5 "$ask" ;;
      significance) _launch "$out" "$log" codex exec --skip-git-repo-check "$ask" ;;
      reproducer)   _launch "$out" "$log" gemini -p "$ask" ;;
      decider)      _launch "$out" "$log" claude -p --model claude-fable-5 "$ask" ;;
      *) echo "unknown lens: $lens" >&2; exit 125 ;;
    esac )
}
```

- [ ] **Step 5: Run the smoke until all four pass**

```bash
bash council/bin/smoke-members.sh
```

Expected: `members smoke: 4 ok, 0 failed`.

When a member fails, fix the invocation in `members.sh` — do not weaken the test. Two known traps: `gemini` resolves to the Windows npm shim at `/mnt/c/Users/charl/AppData/Roaming/npm/gemini`, so a WSL path argument may not survive; and vendor CLIs sometimes wrap JSON in markdown fences, which is a real contract violation and belongs in Task 5's validator, not hidden here.

- [ ] **Step 6: Record what each member actually printed**

Append the confirmed forms as comments in `members.sh`, including any flag that had to change. A future reader must not have to rediscover this.

- [ ] **Step 7: Commit**

```bash
chmod 755 council/bin/members.sh council/bin/smoke-members.sh
chmod 644 council/bin/smoke-fixture.md
git add council/bin/
git commit -m "Verify the council invocation table against foreman-launch

foreman-launch nulls the child's stdin, so codex's documented `exec -`
stdin form returns nothing. Every member takes a positional prompt that
names a brief file in its own sandbox. The forms recorded here are the
ones that ran, not the ones the docs imply."
```

---

## Task 2: The leak checker

A blinded bundle that leaks identity is worse than no blinding, because the log will record "blinded" either way. This checker must be shown to fail.

**Files:**
- Create: `council/bin/leak-check.py`
- Create: `council/bin/test-leak-check.sh`

**Interfaces:**
- Consumes: nothing from Task 1.
- Produces: `python3 council/bin/leak-check.py <file>` → exit `0` clean, `1` leaked, `3` could not run.

- [ ] **Step 1: Write the failing test**

`council/bin/test-leak-check.sh`:

```bash
#!/usr/bin/env bash
# Control first: a clean fixture must pass, or a mutation that fails proves
# nothing. Then each leak class must be caught individually.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 3
C=council/bin/leak-check.py
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0

check () {  # $1=label $2=content $3=want-exit
  printf '%s\n' "$2" > "$T/b.md"
  python3 "$C" "$T/b.md" >/dev/null 2>&1; rc=$?
  if [ "$rc" = "$3" ]; then echo "  ok   $1"; pass=$((pass+1))
  else echo "  FAIL $1 (want $3, got $rc)"; fail=$((fail+1)); fi
}

check "CONTROL: clean text passes" "A vocabulary of 58 elements over a 72-protocol corpus." 0
check "author name"        "Reviewed by Charles Hoskinson." 1
check "repo name"          "See the defiformal repository." 1
check "old corpus root"    "Files live under /root/DefiElements." 1
check "home path"          "Written at /home/charl/paper." 1
check "vendor identity"    "This was drafted with Claude." 1
check "vendor identity 2"  "Generated by OpenAI GPT-4." 1
check "github url"         "https://github.com/CharlesHoskinson/x" 1
check "missing file is blocked, not clean" "" 3

python3 "$C" "$T/definitely-absent.md" >/dev/null 2>&1
[ $? = 3 ] && { echo "  ok   absent file exits 3"; pass=$((pass+1)); } || { echo "  FAIL absent file"; fail=$((fail+1)); }

echo "leak-check: $pass ok, $fail failed"
[ "$fail" -eq 0 ]
```

- [ ] **Step 2: Run it to verify it fails**

```bash
bash council/bin/test-leak-check.sh
```

Expected: every line FAIL, because `leak-check.py` does not exist yet.

- [ ] **Step 3: Write the checker**

`council/bin/leak-check.py`:

```python
#!/usr/bin/env python3
"""Refuse a bundle that leaks who wrote it or what produced it.

A blinded council is worth nothing if the panel can tell whose work it is
reviewing, and the log records "blinded" whether or not the blinding held.
This is the check that makes the log's claim true.

Exit: 0 clean, 1 leaked, 3 could not run.
"""
import os
import pathlib
import re
import sys

PATTERNS = [
    ("author",  r"\bhoskinson\b|\bcharles\b"),
    ("repo",    r"\bdefiformal\b|\bDefiElements\b"),
    ("path",    r"/root/|/home/charl|/mnt/c/Users"),
    ("forge",   r"github\.com/[A-Za-z0-9_-]+"),
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
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
bash council/bin/test-leak-check.sh
```

Expected: `leak-check: 10 ok, 0 failed`.

- [ ] **Step 5: Confirm the model patterns do not fire on the manuscript**

The `model` class matches `gemini`, `claude`, `grok`, `opus`, `sonnet`,
`fable` — all of which could plausibly name a protocol or an exchange in a
DeFi corpus, and a false positive here blocks dispatch for no reason.

```bash
for w in gemini claude grok opus sonnet fable anthropic openai; do
  printf '%-10s %s
' "$w" "$(grep -ciE "\b$w\b" paper/atlas.tex)"
done
```

Expected: `0` for every word — measured at `d22048a`. If a later corpus
addition changes that, narrow the pattern rather than deleting the class.

- [ ] **Step 6: Commit**

```bash
chmod 755 council/bin/leak-check.py council/bin/test-leak-check.sh
git add council/bin/
git commit -m "Add the identity-leak check, with a control and one case per class

The council log records 'identity leak check: clean' whether or not the
blinding held. This is the check that makes that line mean something.
Nine leak classes, each with its own case, and a control proving the
checker is not simply always-red."
```

---

## Task 3: The bundle builder

**Files:**
- Create: `council/bin/build-bundle.py`
- Create: `council/bin/test-build-bundle.sh`

**Interfaces:**
- Consumes: `leak-check.py` from Task 2.
- Produces: `council/sprint1/BUNDLE-blinded.md` and `council/sprint1/BUNDLE.sha256`.

- [ ] **Step 1: Write the failing test**

`council/bin/test-build-bundle.sh`:

```bash
#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 3
pass=0; fail=0
want () { if [ "$2" = "$3" ]; then echo "  ok   $1"; pass=$((pass+1));
          else echo "  FAIL $1 (want $3, got $2)"; fail=$((fail+1)); fi; }

python3 council/bin/build-bundle.py >/dev/null 2>&1
B=council/sprint1/BUNDLE-blinded.md

want "bundle exists"          "$([ -s "$B" ] && echo y || echo n)" "y"
want "candidate A present"    "$(grep -c 'CANDIDATE A' "$B")" "1"
want "candidate B present"    "$(grep -c 'CANDIDATE B' "$B")" "1"
want "candidate C present"    "$(grep -c 'CANDIDATE C' "$B")" "1"
want "residue figure 689"     "$(grep -c '689' "$B")" "1"
want "pairs figure 1830"      "$(grep -c '1830' "$B")" "1"
python3 council/bin/leak-check.py "$B" >/dev/null 2>&1
want "bundle passes leak check" "$?" "0"
want "sha recorded"           "$([ -s council/sprint1/BUNDLE.sha256 ] && echo y || echo n)" "y"
want "sha matches bundle"     "$(sha256sum "$B" | cut -d' ' -f1)" "$(cut -d' ' -f1 < council/sprint1/BUNDLE.sha256)"

# The bundle must be REGENERATED identically, or its hash means nothing.
h1=$(sha256sum "$B" | cut -d' ' -f1)
python3 council/bin/build-bundle.py >/dev/null 2>&1
want "regenerates identically" "$(sha256sum "$B" | cut -d' ' -f1)" "$h1"

echo "build-bundle: $pass ok, $fail failed"
[ "$fail" -eq 0 ]
```

- [ ] **Step 2: Run it to verify it fails**

```bash
bash council/bin/test-build-bundle.sh
```

Expected: all FAIL — the builder does not exist.

- [ ] **Step 3: Write the builder**

`council/bin/build-bundle.py`:

```python
#!/usr/bin/env python3
"""Assemble the blinded contribution bundle for Sprint 1.

Extracts the abstract and the three contribution candidates from the
manuscript, wraps them in a neutral frame, and writes a hash. The frame is
written here rather than quoted from the paper because the paper's framing is
exactly what is under review: quoting it would ask the panel to endorse the
current emphasis instead of choosing one.

Deterministic: the same manuscript produces the same bytes, so the hash in the
council log identifies exactly what was reviewed.
"""
import hashlib
import os
import pathlib
import re
import sys

_SELF = pathlib.Path(__file__).resolve().parents[2]
_REPO = pathlib.Path(os.environ.get("DEFIFORMAL_ROOT", _SELF))
TEX = _REPO / "paper" / "atlas.tex"
OUT = _REPO / "council" / "sprint1" / "BUNDLE-blinded.md"

def between(text, start_pat, end_pat):
    a = re.search(start_pat, text)
    if not a:
        return None
    b = re.search(end_pat, text[a.end():])
    return text[a.end(): a.end() + b.start()].strip() if b else None

def env(text, label):
    """The environment body carrying \\label{label}."""
    i = text.find("\\label{%s}" % label)
    if i < 0:
        return None
    start = text.rfind("\\begin{", 0, i)
    endm = re.search(r"\\end\{[a-z]+\}", text[i:])
    return text[start: i + endm.end()].strip() if endm else None

def strip_tex(s):
    s = re.sub(r"\\label\{[^}]*\}", "", s)
    s = re.sub(r"\\ref\{[^}]*\}", "[ref]", s)
    s = re.sub(r"\\(begin|end)\{[a-z]+\}", "", s)
    s = re.sub(r"\\[a-zA-Z]+\*?", "", s)
    s = s.replace("$", "").replace("~", " ").replace("\\%", "%")
    s = re.sub(r"[{}]", "", s)
    return re.sub(r"\n{3,}", "\n\n", s).strip()

def main():
    if not TEX.is_file():
        print("build-bundle: BLOCKED - no manuscript at %s" % TEX, file=sys.stderr)
        return 3
    tex = TEX.read_text(encoding="utf-8")

    abstract = between(tex, r"\\begin\{abstract\}", r"\\end\{abstract\}")
    perps = env(tex, "meas:perps")
    pairs = env(tex, "meas:pairs")
    if not (abstract and perps and pairs):
        print("build-bundle: BLOCKED - an anchor is missing "
              "(abstract=%s meas:perps=%s meas:pairs=%s)"
              % (bool(abstract), bool(perps), bool(pairs)), file=sys.stderr)
        return 3

    L = []
    L.append("# Three candidate results — which one is the contribution?")
    L.append("")
    L.append("A formal vocabulary for decentralised-finance mechanisms: 58 elements,")
    L.append("a requirement/prohibition/consumer algebra, and a 72-protocol corpus of")
    L.append("hand-made decompositions. Every figure below is computed from the corpus")
    L.append("by committed scripts.")
    L.append("")
    L.append("Author identity is sealed. Do not speculate about who wrote this or what")
    L.append("produced it.")
    L.append("")
    L.append("## Abstract as it currently stands")
    L.append("")
    L.append(strip_tex(abstract))
    L.append("")
    L.append("---")
    L.append("")
    L.append("## CANDIDATE A — the microstructure separation")
    L.append("")
    L.append(strip_tex(perps))
    L.append("")
    L.append("Supporting figures: of 72 corpus protocols, 61 satisfy the laws and")
    L.append("warrants; 29 have a canonical form strictly smaller than themselves.")
    L.append("")
    L.append("A prior reviewer judged this close to definitional — nobody builds a")
    L.append("perpetuals venue without a liquidation engine — and its remaining value")
    L.append("was relocated to a claim about the method rather than about the domain.")
    L.append("")
    L.append("## CANDIDATE B — the residue")
    L.append("")
    L.append("Across 60 constructions the corpus records 1259 functional obligations.")
    L.append("The vocabulary covers 570 of them. The remaining 689 are residue:")
    L.append("obligations for which the vocabulary has no name at all.")
    L.append("")
    L.append("Coverage is 45.3% permissive, 29.0% strict; 205 rows are approximate")
    L.append("fits, 15 constructions are inadmissible.")
    L.append("")
    L.append("The mechanism claimed for this: a vocabulary whose positive theory")
    L.append("excludes nothing will not fail to cover an obligation by being")
    L.append("over-constrained. It will fail by having no name.")
    L.append("")
    L.append("## CANDIDATE C — where composition actually fails")
    L.append("")
    L.append(strip_tex(pairs))
    L.append("")
    L.append("Of 1830 protocol pairs, 1645 compose cleanly (90%) and 185 fail.")
    L.append("Failure attribution: 15 arcs, 10 elements with a strict below-set.")
    L.append("Twenty of the 61 admissible protocols compose with every other.")
    L.append("")
    L.append("The paper notes, but does not lead with, that this 90% is over pairs")
    L.append("drawn uniformly, while deployed compositions are not uniform: the pairs")
    L.append("that occur in production concentrate among the spot exchanges and")
    L.append("lending markets that the measurement above ranks most hostile.")
    L.append("")
    L.append("---")
    L.append("")
    L.append("## The question")
    L.append("")
    L.append("Which of A, B or C is a result that a competent practitioner could not")
    L.append("have obtained by reading the protocols themselves?")
    L.append("")
    text = "\n".join(L) + "\n"

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(text, encoding="utf-8")
    digest = hashlib.sha256(text.encode("utf-8")).hexdigest()
    (OUT.parent / "BUNDLE.sha256").write_text(
        "%s  %s\n" % (digest, OUT.name), encoding="utf-8")
    print("wrote %s (%d bytes)\nsha256 %s" % (OUT, len(text), digest))
    return 0

if __name__ == "__main__":
    sys.exit(main())
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
bash council/bin/test-build-bundle.sh
```

Expected: `build-bundle: 10 ok, 0 failed`.

- [ ] **Step 5: Commit**

```bash
chmod 755 council/bin/build-bundle.py council/bin/test-build-bundle.sh
chmod 644 council/sprint1/BUNDLE-blinded.md council/sprint1/BUNDLE.sha256
git add council/bin/ council/sprint1/
git commit -m "Build the blinded contribution bundle from the manuscript

The frame around the three candidates is written here rather than quoted
from the paper, because the paper's framing is what is under review:
quoting it would ask the panel to endorse the current emphasis instead of
choosing one.

Deterministic — the test asserts the bundle regenerates to the same
bytes, so the hash in the council log identifies exactly what was read."
```

---

## Task 4: The briefs

**Files:**
- Create: `council/sprint1/BRIEF-common.md`
- Create: `council/sprint1/BRIEF-empirical.md`
- Create: `council/sprint1/BRIEF-formal.md`
- Create: `council/sprint1/BRIEF-significance.md`
- Create: `council/sprint1/BRIEF-reproducer.md`
- Create: `council/bin/test-briefs.sh`

**Interfaces:**
- Produces: one brief file per lens, each self-contained — a member reads only its own brief plus the bundle.

- [ ] **Step 1: Write the failing test**

`council/bin/test-briefs.sh`:

```bash
#!/usr/bin/env bash
# Every brief must carry the three rules the post-mortem made non-negotiable,
# and must be self-contained: a member reads its brief and the bundle, nothing
# else.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 3
pass=0; fail=0
has () { if grep -qi "$2" "$1"; then echo "  ok   $(basename "$1"): $3"; pass=$((pass+1));
         else echo "  FAIL $(basename "$1"): $3"; fail=$((fail+1)); fi; }

for b in council/sprint1/BRIEF-empirical.md council/sprint1/BRIEF-formal.md \
         council/sprint1/BRIEF-significance.md council/sprint1/BRIEF-reproducer.md; do
  [ -f "$b" ] || { echo "  FAIL $b absent"; fail=$((fail+1)); continue; }
  has "$b" "accidental drift"        "states the threat model"
  has "$b" "falsifier"               "requires a falsifier per finding"
  has "$b" "insufficient_evidence"   "allows insufficient_evidence"
  has "$b" "single JSON object"      "states the output contract"
  has "$b" "do not read any other"   "sandbox instruction"
  # self-contained: no cross-references to sibling briefs
  if grep -qi "BRIEF-" "$b"; then echo "  FAIL $(basename "$b"): references a sibling brief"; fail=$((fail+1));
  else echo "  ok   $(basename "$b"): self-contained"; pass=$((pass+1)); fi
done
echo "briefs: $pass ok, $fail failed"
[ "$fail" -eq 0 ]
```

- [ ] **Step 2: Run it to verify it fails**

```bash
bash council/bin/test-briefs.sh
```

Expected: four `absent` failures.

- [ ] **Step 3: Write BRIEF-common.md**

This is the text pasted into the head of each lens brief in Step 4. It is not read directly by any member.

```markdown
## Threat model

You are reviewing for accidental drift and honest error — a figure that moved,
a claim that outran its evidence, a result that is true but not interesting.
You are NOT reviewing for an adversary with write access. Do not construct
attacks that assume the authors are lying or that the data was fabricated.

This matters because it bounds the round: an unfalsifiable attack cannot be
answered, and a review made of unfalsifiable attacks never converges.

## Standards

- **Be adversarial.** Your value is dissent, not agreement. A review with no
  findings must justify why.
- **Every finding names its falsifier** — the command that would settle it, or
  the passage that contradicts it. A finding whose truth cannot be checked is
  an opinion, and will be classified as such.
- **Ground every finding.** Name the candidate (A, B or C) and the specific
  sentence or figure.
- **Distinguish** a presentational choice you would have made differently (low)
  from a claim that is false or unsupported (high).
- **Do not invent incidents, dollar figures, protocol names or citations.** If
  you do not know, mark the finding `unverified`.
- If you cannot review because evidence is missing, return
  `insufficient_evidence` and say exactly what is missing. That is a valid and
  respected outcome — it is neither approval nor rejection.
- Read ./bundle.md and this brief. **Do not read any other file.**

## Output contract

Output ONLY a single JSON object. No prose before or after. No markdown fences.

{
  "lens": "<your lens name>",
  "ranking": ["A"|"B"|"C", "...", "..."],
  "ranking_reason": "<=60 words on why your first choice beats the others",
  "verdict": "approved" | "changes_requested" | "insufficient_evidence",
  "summary": "<=60 words, the single most important thing you found",
  "findings": [
    {
      "id": "F1",
      "candidate": "A" | "B" | "C" | "framing",
      "severity": "high" | "medium" | "low",
      "claim": "<what the bundle says>",
      "problem": "<why it is wrong, unsound, or uninteresting>",
      "falsifier": "<the command or passage that settles this>",
      "fix": "<the concrete change you want>",
      "status": "verified" | "unverified"
    }
  ],
  "strongest_candidate_argument": "<the best case FOR your top-ranked candidate, one sentence>",
  "dissent_note": "<if you expect other lenses to disagree, why - <=40 words>"
}

`changes_requested` requires at least one `high` or `medium` finding.
```

- [ ] **Step 4: Write the four lens briefs**

Each is `BRIEF-common.md`'s text with a lens-specific header prepended. Write the headers as:

`BRIEF-empirical.md`:
```markdown
# Lens: empirical

You are reviewing the corpus, the measurements and the statistics.

Ask: are the figures load-bearing or decorative? Is 1259 obligations over 60
constructions enough to carry a claim about DeFi as a field? Does the 90%
composition figure mean what candidate C says it means, and is the
concentration argument evidenced or asserted? Would a different corpus of 72
protocols produce a different answer, and does the bundle give you any way to
tell?
```

`BRIEF-formal.md`:
```markdown
# Lens: formal

You are reviewing the algebra and what it licenses.

Ask: does the canonical form do the work candidate A claims, or is the
separation an artefact of how the vocabulary was built? Is "the vocabulary has
no name for it" (candidate B) a statement about DeFi or about the vocabulary —
and can the bundle distinguish those? Does any candidate claim more than a
finite corpus computation can support?
```

`BRIEF-significance.md`:
```markdown
# Lens: significance

You are reviewing whether any of this is worth publishing at a
financial-cryptography venue.

Ask, for each candidate: could a competent practitioner have obtained this by
reading the protocols? If yes, say so bluntly. If no, say precisely what the
formalism supplied that reading could not. Rank the three on that axis alone.
Assume a hostile reader who believes formal methods papers about DeFi usually
restate folklore in symbols.
```

`BRIEF-reproducer.md`:
```markdown
# Lens: reproducer

You are not reviewing quality. You are checking whether the claims in the
bundle are stated precisely enough to be checked at all.

For each figure — 1259, 689, 570, 1830, 1645, 185, 61, 45.3%, 29.0% — ask: is
it defined well enough that an independent party could recompute it and get the
same number, or would they have to guess a convention? Name every figure whose
definition is ambiguous, and say what the ambiguity is. You cannot run code;
judge from the text alone.
```

- [ ] **Step 5: Run the test to verify it passes**

```bash
bash council/bin/test-briefs.sh
```

Expected: `briefs: 24 ok, 0 failed`.

- [ ] **Step 6: Commit**

```bash
chmod 644 council/sprint1/BRIEF-*.md
chmod 755 council/bin/test-briefs.sh
git add council/bin/ council/sprint1/
git commit -m "Write the four lens briefs, each carrying the threat model

Every brief states that the review is for accidental drift and honest
error, not for an adversary with write access, and requires each finding
to name the command or passage that would settle it. Both rules exist
because their absence produced a twenty-one-round review that never
converged.

Each brief also asks for a RANKING of the three candidates, which is the
sprint's actual question - findings alone would not answer it."
```

---

## Task 5: The report validator

A member that returns prose, or JSON wrapped in fences, has not answered. Catching that at collection time costs one re-run; catching it at triage time costs a round.

**Files:**
- Create: `council/bin/validate-reports.py`
- Create: `council/bin/test-validate-reports.sh`

**Interfaces:**
- Consumes: reports written by Task 6.
- Produces: `python3 council/bin/validate-reports.py <dir>` → exit `0` all valid, `1` at least one invalid, `3` nothing to validate.

- [ ] **Step 1: Write the failing test**

`council/bin/test-validate-reports.sh`:

```bash
#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 3
V=council/bin/validate-reports.py
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
want () { if [ "$2" = "$3" ]; then echo "  ok   $1"; pass=$((pass+1));
          else echo "  FAIL $1 (want $3, got $2)"; fail=$((fail+1)); fi; }

good='{"lens":"empirical","ranking":["B","C","A"],"ranking_reason":"r","verdict":"changes_requested","summary":"s","findings":[{"id":"F1","candidate":"A","severity":"high","claim":"c","problem":"p","falsifier":"run x","fix":"f","status":"verified"}],"strongest_candidate_argument":"a","dissent_note":"d"}'

printf '%s' "$good" > "$T/R1-empirical-grok.json"
python3 "$V" "$T" >/dev/null 2>&1; want "CONTROL: a valid report passes" "$?" "0"

printf '```json\n%s\n```' "$good" > "$T/R1-formal-claude.json"
python3 "$V" "$T" >/dev/null 2>&1; want "markdown fences rejected" "$?" "1"
rm "$T/R1-formal-claude.json"

printf 'Here is my review:\n%s' "$good" > "$T/R1-formal-claude.json"
python3 "$V" "$T" >/dev/null 2>&1; want "prose preamble rejected" "$?" "1"
rm "$T/R1-formal-claude.json"

printf '%s' '{"lens":"x","verdict":"approved","summary":"s"}' > "$T/R1-formal-claude.json"
python3 "$V" "$T" >/dev/null 2>&1; want "missing ranking rejected" "$?" "1"
rm "$T/R1-formal-claude.json"

printf '%s' '{"lens":"x","ranking":["A","B","C"],"ranking_reason":"r","verdict":"changes_requested","summary":"s","findings":[{"id":"F1","candidate":"A","severity":"high","claim":"c","problem":"p","fix":"f","status":"verified"}],"strongest_candidate_argument":"a","dissent_note":"d"}' > "$T/R1-formal-claude.json"
python3 "$V" "$T" >/dev/null 2>&1; want "finding without falsifier rejected" "$?" "1"
rm "$T/R1-formal-claude.json"

printf '%s' '{"lens":"x","ranking":["A","B","C"],"ranking_reason":"r","verdict":"changes_requested","summary":"s","findings":[],"strongest_candidate_argument":"a","dissent_note":"d"}' > "$T/R1-formal-claude.json"
python3 "$V" "$T" >/dev/null 2>&1; want "changes_requested with no finding rejected" "$?" "1"
rm "$T/R1-formal-claude.json"

rm -f "$T"/*.json
python3 "$V" "$T" >/dev/null 2>&1; want "empty dir is BLOCKED not clean" "$?" "3"

echo "validate-reports: $pass ok, $fail failed"
[ "$fail" -eq 0 ]
```

- [ ] **Step 2: Run it to verify it fails**

```bash
bash council/bin/test-validate-reports.sh
```

Expected: all FAIL — the validator does not exist.

- [ ] **Step 3: Write the validator**

`council/bin/validate-reports.py`:

```python
#!/usr/bin/env python3
"""Enforce the council output contract.

A member that returns prose, or JSON in markdown fences, has not answered the
brief. Catching that at collection costs one re-run; catching it at triage
costs a round, and a round is the scarce thing.

Deliberately strict about fences and preambles: the brief says "no prose before
or after, no markdown fences", so accepting them quietly would make the
instruction decorative.

Exit: 0 all valid, 1 at least one invalid, 3 nothing to validate.
"""
import json
import os
import pathlib
import sys

TOP = ["lens", "ranking", "ranking_reason", "verdict", "summary",
       "findings", "strongest_candidate_argument", "dissent_note"]
FIND = ["id", "candidate", "severity", "claim", "problem", "falsifier",
        "fix", "status"]
VERDICTS = {"approved", "changes_requested", "insufficient_evidence"}

def check(path):
    raw = path.read_text(encoding="utf-8", errors="replace")
    problems = []
    if raw.lstrip().startswith("```") or "```" in raw:
        problems.append("markdown fences present")
    try:
        doc = json.loads(raw)
    except json.JSONDecodeError as e:
        problems.append("not a single JSON object (%s)" % e.msg)
        return problems
    if not isinstance(doc, dict):
        problems.append("top level is not an object")
        return problems
    for k in TOP:
        if k not in doc:
            problems.append("missing %r" % k)
    if doc.get("verdict") not in VERDICTS:
        problems.append("verdict %r not in contract" % doc.get("verdict"))
    r = doc.get("ranking")
    if not (isinstance(r, list) and sorted(str(x) for x in r) == ["A", "B", "C"]):
        problems.append("ranking must be a permutation of A, B, C; got %r" % (r,))
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
    if doc.get("verdict") == "changes_requested":
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
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
bash council/bin/test-validate-reports.sh
```

Expected: `validate-reports: 7 ok, 0 failed`.

- [ ] **Step 5: Commit**

```bash
chmod 755 council/bin/validate-reports.py council/bin/test-validate-reports.sh
git add council/bin/
git commit -m "Enforce the council output contract at collection time

A member that answers in prose, or wraps its JSON in fences, has not
answered the brief. Rejecting that when the report lands costs one
re-run; discovering it at triage costs a round.

Strict about fences and preambles on purpose - the brief forbids both,
and quietly accepting them would make the instruction decorative. Every
finding must carry its falsifier, which is the rule the whole round
depends on."
```

---

## Task 6: Run Round 1

**Files:**
- Create: `council/bin/dispatch.sh`
- Create: `council/sprint1/reports/` (populated)
- Create: `council/sprint1/COUNCIL-LOG.md`

**Interfaces:**
- Consumes: `members.sh` (Task 1), the bundle (Task 3), the briefs (Task 4), the validator (Task 5).

- [ ] **Step 1: Write the dispatcher**

`council/bin/dispatch.sh`:

```bash
#!/usr/bin/env bash
# One sandboxed member per lens. Each gets an empty directory containing only
# the bundle and its own brief, so "do not read any other file" is enforced by
# the filesystem rather than by asking politely.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 3
. council/bin/members.sh

ROUND="${1:-1}"
OUT=council/sprint1/reports
mkdir -p "$OUT"

B=council/sprint1/BUNDLE-blinded.md
[ -s "$B" ] || { echo "dispatch: BLOCKED - no bundle"; exit 3; }
python3 council/bin/leak-check.py "$B" >/dev/null 2>&1 \
  || { echo "dispatch: BLOCKED - bundle failed the leak check"; exit 3; }

declare -A CLI=( [empirical]=grok [formal]=claude [significance]=codex [reproducer]=gemini )

for lens in empirical formal significance reproducer; do
  SB=$(mktemp -d)
  cp "$B" "$SB/bundle.md"
  cp "council/sprint1/BRIEF-$lens.md" "$SB/brief.md"
  j="$OUT/R$ROUND-$lens-${CLI[$lens]}.json"
  l="$OUT/R$ROUND-$lens-${CLI[$lens]}.log"
  echo "dispatching $lens (${CLI[$lens]}) ..."
  run_member "$lens" "$SB" "$SB/brief.md" "$j" "$l"
  echo "  exit=$? bytes=$(wc -c < "$j" 2>/dev/null || echo 0)"
  rm -rf "$SB"
done

python3 council/bin/validate-reports.py "$OUT"
```

- [ ] **Step 2: Build the bundle and dispatch**

```bash
python3 council/bin/build-bundle.py
bash council/bin/dispatch.sh 1
```

Expected: four reports written, `validate-reports: 4 report(s), 0 invalid`.

- [ ] **Step 3: Re-run any member the validator rejected**

Do not hand-edit a report to make it valid — that silently substitutes your judgement for the member's. Fix the brief or the invocation and dispatch that lens again.

- [ ] **Step 4: Verify each member actually read the bundle**

```bash
grep -c 'A\|B\|C' council/sprint1/reports/R1-*.json
python3 -c "
import json,glob
for f in sorted(glob.glob('council/sprint1/reports/R1-*.json')):
    d=json.load(open(f))
    print('%-40s ranking=%s findings=%d' % (f.split('/')[-1], d['ranking'], len(d['findings'])))
"
```

A member whose findings never name a figure from the bundle answered from priors, not from the text. Per foreman's `AGENT_TRAPS.md`, check the `.log`, not just the `.json` — a CLI that wandered into local files will say so in its raw output.

- [ ] **Step 5: Write the run record**

`council/sprint1/COUNCIL-LOG.md`:

```markdown
# Sprint 1 Council — run record

**Bundle:** `BUNDLE-blinded.md`
**sha256:** `<paste from BUNDLE.sha256>`
**Identity leak check:** clean (`council/bin/leak-check.py`, exit 0)
**Date:** <date>
**Status:** advisory. The council ranks the candidates; it does not decide the paper.

## Round 1

| lens | CLI | exit | verdict | ranking | findings |
|---|---|---|---|---|---|
| empirical | grok | | | | |
| formal | claude/Opus | | | | |
| significance | codex/GPT | | | | |
| reproducer | gemini | | | | |

## Notes

<anything that went wrong: a member that had to be re-dispatched, a CLI that
wandered, a timeout. Record it even if the re-run succeeded.>
```

- [ ] **Step 6: Commit**

```bash
chmod 755 council/bin/dispatch.sh
chmod 644 council/sprint1/reports/*.json council/sprint1/reports/*.log council/sprint1/COUNCIL-LOG.md
git add council/
git commit -m "Round 1: four blinded lenses rank the three candidates

Each member ran in an empty directory holding only the bundle and its own
brief, so the sandbox instruction is enforced by the filesystem rather
than by asking. Reports are recorded as returned, including any that had
to be re-dispatched, with the reason in the log."
```

---

## Task 7: Triage, claim pages, decision

**Files:**
- Create: `council/sprint1/TRIAGE.md`
- Create: `council/sprint1/DECISION.md`
- Create: `docs/wiki/claims/README.md`
- Create: `docs/wiki/claims/<candidate>.md` (one per surviving candidate)

- [ ] **Step 1: Dispatch the decider**

The decider reads the four reports and nothing else, and produces a synthesis.
Its purpose is to give me something to disagree with: a second reading of the
same reports, made before I have written my own. It does not decide anything —
the triage rule is unchanged, and a decider that merely agrees with the loudest
lens is worth recording as exactly that.

```bash
SB=$(mktemp -d)
cp council/sprint1/reports/R1-*.json "$SB/"
cat > "$SB/brief.md" <<'BRIEF'
# Lens: decider

Four blinded reviewers ranked three candidate results, A, B and C. Their reports
are the R1-*.json files in this directory. Read all four.

You contribute no findings of your own. Synthesise:
- where the four agree, and where they split
- which disagreements are substantive and which are the same objection worded
  differently
- which candidate the reports collectively support, and how strongly

Output ONLY a single JSON object, no prose, no fences:
{
  "consensus_ranking": ["A"|"B"|"C", "...", "..."],
  "agreement": "<what all four agree on, <=50 words>",
  "split": "<where they genuinely disagree, <=50 words>",
  "confidence": "strong" | "weak" | "none",
  "confidence_reason": "<=40 words>"
}
Do not read any other file.
BRIEF
. council/bin/members.sh
run_member decider "$SB" "$SB/brief.md" \
  council/sprint1/reports/R1-decider-claude.json \
  council/sprint1/reports/R1-decider-claude.log
rm -rf "$SB"
```

If `confidence` comes back `strong` while the four rankings actually disagree,
that is a decider failure and belongs in `COUNCIL-LOG.md` under Notes.

- [ ] **Step 2: Classify every finding**

Write `council/sprint1/TRIAGE.md` with one row per finding across all four reports:

```markdown
# Sprint 1 triage

The panel's severity labels are input. This table is the verdict.

| id | lens | candidate | panel severity | falsifier | checked? | class |
|---|---|---|---|---|---|---|
```

For each finding, run its stated falsifier and record the outcome:

- **CONFIRMED** — the falsifier was run and the finding reproduced.
- **PLAUSIBLE** — argued, but the falsifier could not be run or was not decisive.
- **REFUTED** — the falsifier was run and the finding is false.

A finding whose `falsifier` field is vague enough that it cannot be run is **PLAUSIBLE**, not CONFIRMED, however convincing it reads.

- [ ] **Step 3: Verify the figures the panel disputed**

Run the reproducing commands for every figure any finding challenged:

```bash
node formal/v2/pairs.mjs 2>&1 | grep -aE '61/72|1830|185'
node formal/v3/totalgate.mjs 2>&1 | grep -aE '^ok'
```

Record actual output in the triage table. A panel finding that a figure is wrong is CONFIRMED only if the command disagrees with the bundle.

- [ ] **Step 4: Write the claim pages**

`docs/wiki/claims/README.md`:

```markdown
# Claim pages

One page per headline claim in the manuscript. Each page carries the claim,
the command that reproduces its figures, the attacks tried against it, and
which survived.

The command line is the point. `review/ACTIONS.md` recorded findings as
ACTIONED while the sentences they were about were still on the page — an arc
count of twelve where the code says fifteen, a bound stale by three orders of
magnitude, "none outstanding" written above two OUTSTANDING bullets. Prose
records drift from the manuscript and nothing catches it. A page that names its
reproducing command can be checked.

Refuted attacks are recorded too. A panel with no memory raises settled
objections every round.

## Shape

    # <claim, one sentence>
    **Status:** headline | supporting | withdrawn
    **Reproduces with:** `<command>`
    **Expected:** `<the figure the command must print>`
    ## What it rests on
    ## Attacks tried
    | round | lens | attack | falsifier | outcome |
```

Then one page per surviving candidate, following that shape exactly.

- [ ] **Step 5: Write the decision**

`council/sprint1/DECISION.md` records:

1. **The headline claim**, in one sentence.
2. **What it rests on** — the specific figures and the commands that produce them.
3. **Why the other two were demoted**, citing the rankings and the CONFIRMED findings.
4. **The branch answer:** does the decided framing need new measurements, or only a rewrite? This determines Sprint 2's shape and must be explicit.
5. **What is open** — PLAUSIBLE findings not resolved, and whether the round budget was reached.

If the four lenses split on the ranking with no majority, that is a result: record the split and run Round 2 with a brief that asks each lens to argue against its own top choice. Do not average the rankings.

- [ ] **Step 6: Check the exit condition**

The sprint exits when:
- `DECISION.md` names a headline claim and its branch answer, **and**
- a claim page exists for each surviving candidate, **and**
- every CONFIRMED-severe finding is either fixed or recorded in `DECISION.md` as accepted-and-open.

If Round 1 leaves CONFIRMED-severe findings on the decided claim, run Round 2 on the revised framing. Stop at Round 3 regardless and report.

- [ ] **Step 7: Commit**

```bash
chmod 644 council/sprint1/TRIAGE.md council/sprint1/DECISION.md docs/wiki/claims/*.md
git add council/ docs/wiki/
git commit -m "Sprint 1 decision: <headline claim>

<Which candidate won and why, citing the lens rankings.>

<Why the other two were demoted, citing CONFIRMED findings.>

Branch answer: <new measurements needed | rewrite only>. This decides
Sprint 2's shape.

Triage classified <n> findings: <a> CONFIRMED, <b> PLAUSIBLE, <c>
REFUTED. The panel's severity labels are recorded but did not gate -
each finding was classified by running the falsifier it named, and a
finding whose falsifier could not be run is PLAUSIBLE however well it
reads.

Refuted attacks are written into the claim pages so the next round does
not re-litigate them."
```

---

## Verification

Sprint 1 is complete when all of these pass from a clean tree:

```bash
bash council/bin/test-leak-check.sh          # 10 ok, 0 failed
bash council/bin/test-build-bundle.sh        # 10 ok, 0 failed
bash council/bin/test-briefs.sh              # 24 ok, 0 failed
bash council/bin/test-validate-reports.sh    #  7 ok, 0 failed
bash council/bin/smoke-members.sh            #  4 ok, 0 failed
python3 council/bin/validate-reports.py council/sprint1/reports   # 0 invalid
bash formal/v3/gate.sh                       # GATE RESULT: PASS
./paper/build.sh                             # exit 0
```

The manuscript is untouched in Sprint 1: `git diff main --stat -- paper/` must be empty.
