#!/usr/bin/env bash
# The reporters must say the right thing about their own failures.
#
# paper/build.sh once printed "a headline total disagrees with the verdicts"
# because totalgate.mjs could not scandir its input. The totals agreed; the gate
# never ran. Line 49 discarded the diagnosis with >/dev/null 2>&1 and mapped
# every nonzero exit onto one editorial sentence. formal/v3/gate.sh carried the
# same fault in a second shape: an unguarded `cd` let it report "FAIL 61 of 72"
# about a corpus it never read.
#
# The existing negtest-*.sh prove the CONTENT checkers catch manuscript errors.
# None of them proved the reporters distinguish a false property from a check
# that could not run, which is why the defect survived to a published clone.
#
# Every outcome is exercised in BOTH polarities. A harness that only ever sees
# one polarity has discriminated nothing.
#
#   exit 0  property holds over a non-empty corpus
#   exit 1  property is false            -> act on the manuscript
#   exit 3  check could not be performed -> act on the environment
#
# Faults are real, not injected: a chmod-induced EACCES from the filesystem at
# the actual syscall, never a throw planted ahead of it. A fault injected before
# the real call tests the handler rather than the subject.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 3
R=$(pwd)

pass=0; fail=0
FX=/tmp/negtest-reporting

caught () { printf '  CAUGHT  %s\n' "$1"; pass=$((pass+1)); }
missed () { printf '  MISSED  %s\n' "$1"; fail=$((fail+1)); }

# assert an exit code
want_rc () { # label want got
  if [ "$2" = "$3" ]; then caught "$1 (exit $3)"; else missed "$1 (want exit $2, got $3)"; fi
}
# assert text present / absent
want_has () { if printf '%s' "$2" | grep -qF -- "$3"; then caught "$1"; else missed "$1 -- $3 absent"; fi; }
want_not () { if printf '%s' "$2" | grep -qF -- "$3"; then missed "$1 -- $3 present"; else caught "$1"; fi; }

cleanup () { chmod -R u+rwX "$FX" 2>/dev/null; rm -rf "$FX"; }
trap cleanup EXIT

# A COMPLETE twelve-category fixture. Defined here, not mid-file: it is used by
# 3b.4's control, which runs long before the section that first introduced it.
mk_two () {   # $1 = dest
  rm -rf "$1"; mkdir -p "$1/paper" "$1/expansion"
  cp "$R/paper/atlas.tex" "$1/paper/atlas.tex"
  cp -r "$R"/expansion/[0-9][0-9]-* "$1/expansion/" 2>/dev/null
}

build_fixture () {  # $1 = fixture dir; expansion symlinked, atlas.tex copied
  rm -rf "$1"; mkdir -p "$1/paper"
  ln -s "$R/expansion" "$1/expansion"
  cp "$R/paper/atlas.tex" "$1/paper/atlas.tex"
}

echo "===== 1. totalgate: VIOLATED vs BLOCKED vs VACUOUS ====="

# --- 1a. control: the real corpus agrees ---------------------------------
out=$(node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "control: real corpus agrees" 0 "$rc"
want_has "control: says totals agree" "$out" "all headline totals agree"

# --- 1b. VIOLATED: a headline total really is wrong ----------------------
build_fixture "$FX/violated"
python3 - "$FX/violated/paper/atlas.tex" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding="utf-8").read()
old, new = "$1{,}259$", "$1{,}260$"
if old not in s:
    print("PERTURBATION DID NOT APPLY: anchor absent", file=sys.stderr); sys.exit(3)
io.open(p, "w", encoding="utf-8").write(s.replace(old, new))
PY
if [ $? -ne 0 ]; then missed "perturbation could not be applied"; else
  out=$(DEFIFORMAL_ROOT="$FX/violated" node formal/v3/totalgate.mjs 2>&1); rc=$?
  want_rc  "VIOLATED: wrong obligations total" 1 "$rc"
  want_has "VIOLATED: names the failing total" "$out" "FAIL obligations total"
fi

# --- 1c. BLOCKED: a real EACCES at the real syscall ----------------------
rm -rf "$FX/blocked"; mkdir -p "$FX/blocked/paper" "$FX/blocked/expansion/01-spot-exchange"
cp "$R/paper/atlas.tex" "$FX/blocked/paper/atlas.tex"
chmod 000 "$FX/blocked/expansion"
out=$(DEFIFORMAL_ROOT="$FX/blocked" node formal/v3/totalgate.mjs 2>&1); rc=$?
chmod 755 "$FX/blocked/expansion"
want_rc  "BLOCKED: unreadable expansion root" 3 "$rc"
want_has "BLOCKED: names the cause"  "$out" "BLOCKED"
want_not "BLOCKED: does NOT claim a disagreement" "$out" "out of step with the verdicts"

# --- 1d. VACUOUS: empty corpus must not read as a disagreement -----------
# With tot === 0 the percentages are NaN, every `has` test fails, and the
# unguarded gate would exit 1 -- announcing a disagreement it never measured.
rm -rf "$FX/vacuous"; mkdir -p "$FX/vacuous/paper" "$FX/vacuous/expansion"
cp "$R/paper/atlas.tex" "$FX/vacuous/paper/atlas.tex"
out=$(DEFIFORMAL_ROOT="$FX/vacuous" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "VACUOUS: empty expansion root" 3 "$rc"
want_not "VACUOUS: does NOT report NaN totals as a disagreement" "$out" "out of step"

echo
echo "===== 2. paper/build.sh reports the two failures differently ====="

# --- 2a. BLOCKED through build.sh -- the exact published defect ----------
rm -rf "$FX/b2"; mkdir -p "$FX/b2/paper" "$FX/b2/expansion/01-spot-exchange"
cp "$R/paper/atlas.tex" "$FX/b2/paper/atlas.tex"
chmod 000 "$FX/b2/expansion"
out=$(cd "$R" && DEFIFORMAL_ROOT="$FX/b2" ./paper/build.sh 2>&1); rc=$?
out=$(printf '%s' "$out" | sed 's/\x1b\[[0-9;]*m//g')
chmod 755 "$FX/b2/expansion"
want_rc  "build BLOCKED: exit code" 3 "$rc"
want_has "build BLOCKED: says the totals were not checked" "$out" "were NOT checked"
want_not "build BLOCKED: does NOT say a total disagrees"   "$out" "a headline total disagrees"
want_has "build BLOCKED: surfaces the gate diagnosis"      "$out" "EACCES"

# --- 2b. VIOLATED through build.sh --------------------------------------
out=$(cd "$R" && DEFIFORMAL_ROOT="$FX/violated" ./paper/build.sh 2>&1); rc=$?
out=$(printf '%s' "$out" | sed 's/\x1b\[[0-9;]*m//g')
want_rc  "build VIOLATED: exit code" 1 "$rc"
want_has "build VIOLATED: says a total disagrees"    "$out" "a headline total disagrees"
want_not "build VIOLATED: does NOT say it was blocked" "$out" "were NOT checked"

# --- 2c. control: the real tree builds clean ----------------------------
out=$(cd "$R" && ./paper/build.sh 2>&1 | sed 's/\x1b\[[0-9;]*m//g'); rc=$?
want_rc  "build control: real tree" 0 "$rc"
want_has "build control: reports OK" "$out" "OK  atlas.pdf"

echo
echo "===== 3. gate.sh: a failed cd must stop the script ====="
guard=$(sed -n '3p' formal/v3/gate.sh)
want_has "gate.sh cd is guarded" "$guard" "|| exit"
want_not "gate.sh no longer hardcodes /root" "$guard" "/root/defiformal"
# a resolution that must fail: run a copy from a directory with no repo above it
mkdir -p "$FX/orphan"
cp formal/v3/gate.sh "$FX/orphan/gate.sh"
out=$(cd "$FX/orphan" && bash ./gate.sh 2>&1); rc=$?
want_rc  "gate.sh orphan: exit code" 3 "$rc"
want_has "gate.sh orphan: says BLOCKED"                 "$out" "GATE BLOCKED"
want_not "gate.sh emits no corpus verdict when blocked" "$out" "FAIL 61 of 72"

# a fake tree of correctly-NAMED but empty files must not pass the sentinel
rm -rf "$FX/fake"; mkdir -p "$FX/fake/paper" "$FX/fake/expansion" "$FX/fake/corpus50/lanes" "$FX/fake/formal/v3"
: > "$FX/fake/paper/atlas.tex"
cp formal/v3/gate.sh "$FX/fake/formal/v3/gate.sh"
out=$(cd "$FX/fake/formal/v3" && bash ./gate.sh 2>&1); rc=$?
want_rc  "sentinel: empty look-alike tree is blocked" 3 "$rc"
want_has "sentinel: names it"                         "$out" "not a defiformal tree"

echo
echo "===== 3b. the contract holds INSIDE the corpus walk ====="
# The first version of this change guarded readdir and left every readFileSync /
# JSON.parse unguarded: an EACCES or malformed JSON one directory deeper threw,
# node exited 1, and build.sh called it a totals disagreement. Same lie, next
# syscall. These lock the depth.

mk_real () {   # a fixture holding ONE real slug, so totals are computable
  rm -rf "$1"; mkdir -p "$1/paper"
  cp "$R/paper/atlas.tex" "$1/paper/atlas.tex"
  mkdir -p "$1/expansion"
  cp -r "$R/expansion/01-spot-exchange" "$1/expansion/"
}

# 3b.1 unreadable verdicts.json (real EACCES at the real syscall)
mk_real "$FX/inner1"
chmod 000 "$FX/inner1/expansion/01-spot-exchange/verdicts.json"
out=$(DEFIFORMAL_ROOT="$FX/inner1" node formal/v3/totalgate.mjs 2>&1); rc=$?
chmod 644 "$FX/inner1/expansion/01-spot-exchange/verdicts.json"
want_rc  "inner: unreadable verdicts.json" 3 "$rc"
want_not "inner: not called a disagreement" "$out" "out of step with the verdicts"

# 3b.2 malformed spec JSON
mk_real "$FX/inner2"
sp=$(ls "$FX/inner2/expansion/01-spot-exchange/specs/"*.json | head -1)
printf '{ this is not json' > "$sp"
out=$(DEFIFORMAL_ROOT="$FX/inner2" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "inner: malformed spec JSON" 3 "$rc"
want_has "inner: names the parse failure" "$out" "cannot parse"

# 3b.3 tot === 0 -- slugs present, no obligations. Unguarded this is NaN and
# every `has` test fails, so the gate would exit 1 and announce a disagreement.
mk_real "$FX/inner3"
printf '[]' > "$FX/inner3/expansion/01-spot-exchange/verdicts.json"
out=$(DEFIFORMAL_ROOT="$FX/inner3" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "inner: zero obligations" 3 "$rc"
want_not "inner: zero obligations is not a disagreement" "$out" "out of step"

# 3b.4 the same, through build.sh -- the caller must not relabel it.
# The fault must be LIVE for this run: with permissions restored the fixture is a
# one-slug corpus and the gate correctly reports a real disagreement, which is
# not what this case is testing.
chmod 000 "$FX/inner1/expansion/01-spot-exchange/verdicts.json"
out=$(cd "$R" && DEFIFORMAL_ROOT="$FX/inner1" ./paper/build.sh 2>&1); rc=$?
chmod 644 "$FX/inner1/expansion/01-spot-exchange/verdicts.json"
want_rc  "inner through build.sh: exit code" 3 "$rc"
want_not "inner through build.sh: no disagreement claim" "$out" "a headline total disagrees"

# The control for that control: without it, 3b.4 would pass against a build.sh
# that called everything blocked. It used to use this one-slug fixture, but a
# one-slug tree no longer reaches the comparison at all -- the denominator guard
# blocks it (12 categories expected, 1 walked). A genuine disagreement now means
# a COMPLETE corpus whose manuscript states the wrong number.
mk_two "$FX/innerctl"
python3 - "$FX/innerctl/paper/atlas.tex" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding="utf-8").read()
old, new = "$1{,}259$", "$1{,}260$"
if old not in s:
    print("PERTURBATION DID NOT APPLY: anchor absent", file=sys.stderr); sys.exit(3)
io.open(p, "w", encoding="utf-8").write(s.replace(old, new))
PY
out=$(cd "$R" && DEFIFORMAL_ROOT="$FX/innerctl" ./paper/build.sh 2>&1); rc=$?
out=$(printf '%s' "$out" | sed 's/\x1b\[[0-9;]*m//g')
want_rc  "inner control: a complete corpus really can disagree" 1 "$rc"
want_has "inner control: and says so"  "$out" "a headline total disagrees"

echo
echo "===== 3d. the contract holds at the TYPE, not just the parse ====="
# Round 2 guarded readFileSync and JSON.parse. Valid JSON `null` is neither a
# read failure nor a parse failure, so it slipped through and the next property
# access threw a TypeError -- node exits 1, the "manuscript is wrong" code.

# 3d.1 a spec that is literally null
mk_real "$FX/t1"
sp=$(ls "$FX/t1/expansion/01-spot-exchange/specs/"*.json | head -1)
printf 'null' > "$sp"
out=$(DEFIFORMAL_ROOT="$FX/t1" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "type: spec is JSON null" 3 "$rc"
want_not "type: null spec is not a disagreement" "$out" "out of step"

# 3d.2 a null element inside the verdicts array
mk_real "$FX/t2"
printf '[null]' > "$FX/t2/expansion/01-spot-exchange/verdicts.json"
out=$(DEFIFORMAL_ROOT="$FX/t2" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "type: null verdict element" 3 "$rc"

# 3d.3 a non-numeric obligation count
mk_real "$FX/t3"
printf '[{"obligationsTotal":"many","obligationsCovered":1,"verdict":"OK"}]' \
  > "$FX/t3/expansion/01-spot-exchange/verdicts.json"
out=$(DEFIFORMAL_ROOT="$FX/t3" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "type: non-numeric obligation count" 3 "$rc"
# The parent `!Number.isFinite(tot)` guard also returns 3 here, so exit code
# alone does not lock the per-element check. Assert its OWN message.
want_has "type: blocked BY the per-verdict check" "$out" "has a non-numeric obligation count"

# 3d.4 an unreadable slug DIRECTORY. existsSync returns false here, so the slug
# used to be silently skipped and its obligations vanished from the totals --
# the short total was then compared and reported as a real disagreement.
# TWO slugs, deliberately. With one, an unreadable slug leaves zero obligations
# and the pre-existing tot===0 guard returns 3 regardless -- the assertion stays
# green against the reverted fix and locks nothing. With two, the readable slug
# still contributes, the short total is compared, and the unfixed code exits 1
# with "out of step": the silent-skip disagreement this fix exists to prevent.
rm -rf "$FX/t4"; mkdir -p "$FX/t4/paper" "$FX/t4/expansion"
cp "$R/paper/atlas.tex" "$FX/t4/paper/atlas.tex"
cp -r "$R/expansion/01-spot-exchange" "$FX/t4/expansion/"
cp -r "$R/expansion/02-lending"       "$FX/t4/expansion/"
chmod 000 "$FX/t4/expansion/02-lending"
out=$(DEFIFORMAL_ROOT="$FX/t4" node formal/v3/totalgate.mjs 2>&1); rc=$?
chmod 755 "$FX/t4/expansion/02-lending"
want_rc  "type: unreadable slug among readable ones" 3 "$rc"
want_has "type: names the slug it could not enter" "$out" "cannot enter slug 02-lending"
want_not "type: unreadable slug is not silently skipped" "$out" "out of step"

# Four quadrants of (is-a-directory) x (carries a backup suffix). Deciding by
# NAME before stat'ing conflated two of them and dropped a renamed category.
# (a) a plain FILE on a category-shaped name -> BLOCK (covered by t6 below)
# (b) a DROPPING file (99-notes.bak) -> skipped silently
rm -rf "$FX/t5"; mkdir -p "$FX/t5/paper" "$FX/t5/expansion"
cp "$R/paper/atlas.tex" "$FX/t5/paper/atlas.tex"
cp -r "$R"/expansion/[0-9][0-9]-* "$FX/t5/expansion/" 2>/dev/null
: > "$FX/t5/expansion/99-notes.bak"
out=$(DEFIFORMAL_ROOT="$FX/t5" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "slug: a dropping FILE is skipped, run still passes" 0 "$rc"
# (c) a plain FILE on a category-shaped name with no suffix -> BLOCK
rm -rf "$FX/t5b"; mkdir -p "$FX/t5b/paper" "$FX/t5b/expansion"
cp "$R/paper/atlas.tex" "$FX/t5b/paper/atlas.tex"
cp -r "$R"/expansion/[0-9][0-9]-* "$FX/t5b/expansion/" 2>/dev/null
: > "$FX/t5b/expansion/99-not-a-dir"
out=$(DEFIFORMAL_ROOT="$FX/t5b" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "slug: a bare FILE on a category name blocks" 3 "$rc"
# (d) a renamed category DIRECTORY -> BLOCK, not silently dropped. Before this
# fix the name filter removed it, its obligations vanished, and the short total
# was reported as a disagreement with the manuscript.
rm -rf "$FX/t5c"; mkdir -p "$FX/t5c/paper" "$FX/t5c/expansion"
cp "$R/paper/atlas.tex" "$FX/t5c/paper/atlas.tex"
cp -r "$R"/expansion/[0-9][0-9]-* "$FX/t5c/expansion/" 2>/dev/null
mv "$FX/t5c/expansion/02-lending" "$FX/t5c/expansion/02-lending.bak"
out=$(DEFIFORMAL_ROOT="$FX/t5c" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "slug: a renamed category DIRECTORY blocks" 3 "$rc"
want_not "slug: renamed category is not a disagreement" "$out" "out of step"

# A: a non-directory occupying a real category name must BLOCK, not be skipped.
# Skipping it drops that category's obligations and the short total then reads
# as a genuine disagreement -- the published lie, one shape further on.
rm -rf "$FX/t6"; mkdir -p "$FX/t6/paper" "$FX/t6/expansion"
cp "$R/paper/atlas.tex" "$FX/t6/paper/atlas.tex"
cp -r "$R/expansion/01-spot-exchange" "$FX/t6/expansion/"
cp -r "$R/expansion/02-lending"       "$FX/t6/expansion/"
rm -rf "$FX/t6/expansion/02-lending"; : > "$FX/t6/expansion/02-lending"
out=$(DEFIFORMAL_ROOT="$FX/t6" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "slug: a FILE on a category name blocks" 3 "$rc"
want_not "slug: file-on-category is not a disagreement" "$out" "out of step"

# ... but an editor dropping is not a category and must not block the gate
rm -rf "$FX/t7"; mkdir -p "$FX/t7/paper" "$FX/t7/expansion"
cp "$R/paper/atlas.tex" "$FX/t7/paper/atlas.tex"
cp -r "$R"/expansion/[0-9][0-9]-* "$FX/t7/expansion/" 2>/dev/null
: > "$FX/t7/expansion/01-spot-exchange.bak"
out=$(DEFIFORMAL_ROOT="$FX/t7" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "slug: a .bak dropping does not block" 0 "$rc"

# D: a missing interpreter or script is a blocked check, not a content failure.
# Lift the real function here -- this section runs before 3c defines it.
eval "$(awk '/^blocked_out\(\) \{/,/^\}/' formal/v3/gate.sh)"
declare -F blocked_out >/dev/null || missed "could not lift blocked_out() from gate.sh"
if blocked_out "bash: line 1: nosuchtool: command not found"; then
  caught "blocked_out recognises 'command not found'"
else missed "blocked_out misses 'command not found'"; fi
if blocked_out "python3: can't open file '/x/y.py': [Errno 2] No such file or directory"; then
  caught "blocked_out recognises a missing python script"
else missed "blocked_out misses a missing python script"; fi

# loop2gate has its OWN blocked_out; section D above lifted gate.sh's. Both must
# recognise the same signatures or one gate lies while the other does not.
eval "$(awk '/^blocked_out\(\) \{/,/^\}/' formal/v3/loop2gate.sh | sed 's/^blocked_out()/l2_blocked_out()/')"
if declare -F l2_blocked_out >/dev/null; then
  for probe in "bash: line 1: nosuchtool: command not found" \
               "python3: can't open file '/x/y.py': [Errno 2] No such file or directory" \
               "Error: EACCES: permission denied"; do
    if l2_blocked_out "$probe"; then
      caught "loop2gate blocked_out recognises: $(printf '%s' "$probe" | cut -c1-34)"
    else
      missed "loop2gate blocked_out misses: $(printf '%s' "$probe" | cut -c1-34)"
    fi
  done
else
  missed "could not lift loop2gate's blocked_out()"
fi

# --- lock the exit-code gating that round 7 measured as untested ----------
# Reverting each of these left only the dirty-tree assertion red, i.e. the
# headline fix of ab5f334 was locked by nothing. Each probe drives the REAL
# function lifted from source.

# (i) want()'s ok-path must require rc=0
cat > "$FX/w_rc.sh" <<SNIP
declare -A HOUT HRC
HOUT[pairs]="pairs: 1830"; HRC[pairs]=7
fail=0; blkd=0
. "$FX/attrib/fns.sh"
want "died but printed the needle" 'pairs: 1830' pairs
SNIP
wout=$(bash "$FX/w_rc.sh" 2>&1)
want_not "want(): a dead harness is not ok on a stray needle" "$wout" "  ok   died but printed"

# (ii) chk()'s BLOCKED branch must require a non-zero exit
cat > "$FX/c_blk.sh" <<SNIP
fail=0; blkd=0
$(awk '/^blocked_out\(\) \{/,/^\}/' formal/v3/gate.sh)
$(awk '/^chk\(\) \{/,/^\}/' formal/v3/gate.sh)
chk "ran clean, wrong numbers, noisy" "computed 60 of 72
Error: EACCES: permission denied" "61/72" 0
SNIP
cout=$(bash "$FX/c_blk.sh" 2>&1)
want_not "chk(): a clean-exit content failure is not relabelled BLOCKED" "$cout" "  BLOCKED ran clean"
want_has "chk(): it is reported as FAIL"                                  "$cout" "  FAIL ran clean"

# (iii) the three inline gate.sh ladders must require rc=0 before ok
for pair in "cl:109-claim checker:, 0 failed" "sm:smoke:SMOKE OK" "gr:graph claims:GRAPH CLAIMS VERIFIED"; do
  v=${pair%%:*}; rest=${pair#*:}; lbl=${rest%%:*}; ndl=${rest#*:}
  ladder=$(grep -n "${v}rc:-1" formal/v3/gate.sh | head -1)
  if printf '%s' "$ladder" | grep -q '= "0" \] &&'; then
    caught "inline $lbl requires a zero exit before ok"
  else
    missed "inline $lbl issues ok without checking ${v}rc"
  fi
done

# E: gate.sh's chk() must not call a non-zero harness ok on a stray needle
gchk=$(awk '/^chk\(\) \{/,/^\}/' formal/v3/gate.sh)
if printf '%s' "$gchk" | grep -q '\${4:-0}'; then
  caught "gate.sh chk() consults the harness exit code"
else
  missed "gate.sh chk() ignores the harness exit code"
fi
cat > "$FX/gchk.sh" <<SNIP
fail=0; blkd=0
$(awk '/^blocked_out\(\) \{/,/^\}/' formal/v3/gate.sh)
$gchk
chk "stray needle, harness died" "boom
pairs: 1830" "pairs: 1830" 3
SNIP
gout=$(bash "$FX/gchk.sh" 2>&1)
want_not "gate.sh chk: a dead harness is not ok on a stray needle" "$gout" "  ok   stray needle"

echo
echo "===== 3e. loop2gate.sh derives its verdict from the exit code ====="
# The previous round only added a printf here and left the verdict coming from
# `case "$b" in *"OK"*)`. The note is not the fix.
want_has "loop2gate: branches on the exit code" "$(cat formal/v3/loop2gate.sh)" 'case "$brc" in'
want_not "loop2gate: no longer hardcodes /root"  "$(cat formal/v3/loop2gate.sh)" "cd /root/defiformal"
# A source grep is not enough: the first attempt at this fix appended a result
# block AFTER the script's existing `exit`, so the new branch was dead code and
# a grep for it still passed. Assert there is no statement after the terminal
# exit, and assert the BLOCKED path actually reaches stdout.
# The previous version of this check looked for a line beginning `exit `, but
# the terminal block puts `exit` on the same line as its printf, so the pattern
# never matched and the assertion passed against ANY file -- including the dead
# code it was written to catch. Behavioural instead: implant a marker after the
# terminal block in a copy and confirm it never prints.
# The probe needs a tree whose ../.. is a real defiformal root, or the sentinel
# exits 3 first and BOTH the probe and its control pass/fail vacuously.
probe_tree () {   # $1 = dest
  # paper/ is a REAL directory holding a copy of atlas.tex and a stub build.sh.
  # It used to be a symlink to the repo's paper/, which meant every negtest run
  # executed two extra full paper builds inside the real tree -- atlas.pdf and
  # atlas.log mtimes moved, measured. Only git-ignored files were touched, so
  # git status stayed clean and it went unnoticed for two rounds.
  rm -rf "$1"; mkdir -p "$1/formal/v3" "$1/paper"
  cp "$R/paper/atlas.tex" "$1/paper/atlas.tex"
  cat > "$1/paper/build.sh" <<'STUB'
#!/usr/bin/env bash
# stub: the dead-code probe needs loop2gate's control flow, not a real build
printf 'OK  atlas.pdf: 39 pages, 0 bytes\n'
exit 0
STUB
  chmod +x "$1/paper/build.sh"
  for d in expansion corpus50 research; do ln -s "$R/$d" "$1/$d"; done
  ln -s "$R/formal/v2" "$1/formal/v2"
  for f in "$R"/formal/v3/*; do
    b=$(basename "$f"); [ "$b" = "loop2gate.sh" ] && continue
    ln -s "$f" "$1/formal/v3/$b"
  done
}
probe_tree "$FX/pdead"
cp formal/v3/loop2gate.sh "$FX/pdead/formal/v3/loop2gate.sh"
printf '\necho DEAD-CODE-MARKER\n' >> "$FX/pdead/formal/v3/loop2gate.sh"
dout=$(bash "$FX/pdead/formal/v3/loop2gate.sh" 2>&1)
want_not "loop2gate: nothing executes after the terminal block" "$dout" "DEAD-CODE-MARKER"
want_not "loop2gate: dead-code probe reached the terminal block" "$dout" "is not a defiformal tree"

# Control: the same marker placed BEFORE the terminal block MUST print. Without
# this, the check above passes against a script that exited long before either
# block -- which is exactly how the previous two versions of it were vacuous.
probe_tree "$FX/plive"
awk '/^if \[ "\$fail" -ne 0 \]; then/ && !d {print "echo DEAD-CODE-MARKER"; d=1} {print}' \
  formal/v3/loop2gate.sh > "$FX/plive/formal/v3/loop2gate.sh"
lout=$(bash "$FX/plive/formal/v3/loop2gate.sh" 2>&1)
want_has "loop2gate: the dead-code probe can fail (control)" "$lout" "DEAD-CODE-MARKER"
# F3: nothing locked probe_tree's stub build.sh. Reverting it to the old symlink
# form silently restored two full paper builds inside the REAL tree each run
# (atlas.pdf mtime moved, measured in round 5). Assert the probe does not typeset.
want_not "probe_tree: paper/ is not a symlink into the repo" \
  "$(readlink -f "$FX/pdead/paper" 2>/dev/null)" "$R/paper"
want_has "probe_tree: uses a stub build.sh"  "$(cat "$FX/pdead/paper/build.sh" 2>/dev/null)" "stub:"
pdf_before=$(stat -c %Y "$R/paper/atlas.pdf" 2>/dev/null || echo none)
bash "$FX/pdead/formal/v3/loop2gate.sh" >/dev/null 2>&1
pdf_after=$(stat -c %Y "$R/paper/atlas.pdf" 2>/dev/null || echo none)
if [ "$pdf_before" = "$pdf_after" ]; then
  caught "probe_tree: the probe does not typeset the real paper/"
else
  missed "probe_tree: the probe rebuilt the real paper/ (mtime $pdf_before -> $pdf_after)"
fi
mkdir -p "$FX/orphan2"
cp formal/v3/loop2gate.sh "$FX/orphan2/loop2gate.sh"
out=$(cd "$FX/orphan2" && bash ./loop2gate.sh 2>&1); rc=$?
want_rc  "loop2gate orphan: exit code" 3 "$rc"
want_not "loop2gate orphan: emits no build verdict" "$out" "FAIL build did not report OK"

# Behavioural, not a source grep: on this tree many v3 harnesses cannot run, so
# loop2gate must report BLOCKED with fail=0, never content verdicts about a
# corpus nothing read. Before this fix it printed ten of them and exited 1.
l2=$(bash formal/v3/loop2gate.sh 2>&1); l2rc=$?
want_rc  "loop2gate: blocked tree gives exit 3, not 1" 3 "$l2rc"
want_has "loop2gate: says BLOCKED"                  "$l2" "LOOP-2 RESULT: BLOCKED"
want_has "loop2gate: fail flag is zero"             "$l2" "fail=0"
want_not "loop2gate: no stale-brief content verdict" "$l2" "FAIL section briefs are stale"
want_not "loop2gate: no free-set content verdict"    "$l2" "FAIL free-set claim"

# F1: a blocked sibling harness must not mask a measured content failure in a
# healthy one. want() previously judged blocked against the union of all four.
rm -rf "$FX/attrib"; mkdir -p "$FX/attrib"
# Drive the REAL blocked_out() and want() lifted verbatim out of loop2gate.sh.
# The previous version re-implemented them in a heredoc, so reverting the
# per-harness hunk left this probe testing a copy that still had the fix.
# Lifting a function by line range is a parser of the source, not a test of the
# behaviour, and ordinary bash style defeats it: a one-line definition has no
# `^}` terminator, so the range runs to the end of file and the eval swallows
# the rest of the script -- including its `exit`. Guard on all three failure
# shapes, and refuse to proceed on any of them rather than testing nothing.
lift () { # $1 = file, $2 = function name, $3 = dest
  awk -v fn="$2" 'index($0, fn "()")==1 || index($0, fn " ()")==1 {inside=1}
                  inside {print}
                  inside && /^\}/ {exit}' "$1" > "$3"
  # `tail -1 == }` alone is NOT enough. A one-lined definition has no terminator
  # of its own, so the range runs on to the next function's closing brace: the
  # tail check passes while the extract carries script body. Measured on a
  # one-lined blocked_out: 40 lines, 5 of them body, and lift returned 0.
  [ -s "$3" ] || return 1
  [ "$(tail -1 "$3")" = "}" ] || return 1
  # exactly one definition, and nothing that is plainly script body
  [ "$(grep -cE '^[A-Za-z_][A-Za-z0-9_]* *\(\) *\{' "$3")" = "1" ] || return 1
  grep -qE '^(echo|one |want "|chk "|===== |[a-z]+=\$\()' "$3" && return 1
  return 0
}
: > "$FX/attrib/fns.sh"
for fn in blocked_out want; do
  if lift formal/v3/loop2gate.sh "$fn" "$FX/attrib/one.sh"; then
    cat "$FX/attrib/one.sh" >> "$FX/attrib/fns.sh"
  else
    missed "attribution probe: could not lift $fn() from loop2gate.sh (reformatted?)"
  fi
done
if [ "$(grep -c '^}' "$FX/attrib/fns.sh")" != "2" ]; then
  missed "attribution probe: lifted text does not contain exactly two function bodies"
fi
# the lift must not have swallowed the rest of the file
if grep -qE '^(echo|one |want "|===== )' "$FX/attrib/fns.sh"; then
  missed "attribution probe: the lift swallowed script body beyond the function"
else
  caught "attribution probe: the lift is bounded to the function body"
fi
# F3: the guards above have no positive control -- nothing proved they FIRE on a
# defeating reformat, so the guard mechanism could be reverted with every
# assertion staying green. Construct the reformat: a one-line definition has no
# ^} terminator, which is what defeats a range-based lift.
mkdir -p "$FX/reformat"
# Collapse the whole blocked_out body onto one line -- the shape that has no
# ^} terminator and therefore defeats a range-based lift.
awk 'BEGIN{d=0}
     /^blocked_out\(\) \{/ {d=1; printf "blocked_out() { printf %s \"$1\" | grep -q X; }  # one-lined\n", "'"'"'%s'"'"'"; next}
     d && /^\}/ {d=0; next}
     d {next}
     {print}' formal/v3/loop2gate.sh > "$FX/reformat/l2.sh"
if lift "$FX/reformat/l2.sh" blocked_out "$FX/reformat/out.sh"; then
  missed "lift(): a one-lined definition is not detected (guard does not fire)"
else
  caught "lift(): a one-lined definition is refused (guard fires)"
fi
# and the control for the control: the unmodified file must still lift cleanly
if lift formal/v3/loop2gate.sh blocked_out "$FX/reformat/ok.sh"; then
  caught "lift(): the real definition still lifts (guard is not always-on)"
else
  missed "lift(): refuses the real definition"
fi
cat > "$FX/attrib/probe.sh" <<SNIP
declare -A HOUT HRC
HOUT[pairs]="pairs: 1830"; HRC[pairs]=0
HOUT[safe]="Error [ERR_MODULE_NOT_FOUND]: Cannot find module"; HRC[safe]=1
fail=0; blkd=0
. "$FX/attrib/fns.sh"
want "healthy harness, wrong number" 'pairs: 9999' pairs
want "genuinely blocked harness"     'EVERY other' safe
SNIP
aout=$(bash "$FX/attrib/probe.sh" 2>&1)
want_has "attribution: a wrong number in a healthy harness is FAIL" "$aout" "  FAIL healthy harness"
want_has "attribution: the blocked harness is BLOCKED"              "$aout" "  BLOCKED genuinely blocked"

# F5: loop2gate's sentinel must be as strong as gate.sh's
rm -rf "$FX/fake2"
mkdir -p "$FX/fake2/paper" "$FX/fake2/corpus50/lanes" "$FX/fake2/formal/v3"
echo "hello atlas" > "$FX/fake2/paper/atlas.tex"
echo '{}' > "$FX/fake2/corpus50/lanes/x.json"
cp formal/v3/loop2gate.sh "$FX/fake2/formal/v3/loop2gate.sh"
out=$(cd "$FX/fake2/formal/v3" && bash ./loop2gate.sh 2>&1); rc=$?
want_rc  "loop2gate sentinel: look-alike tree is blocked" 3 "$rc"
want_not "loop2gate sentinel: emits no corpus verdict"    "$out" "FAIL 61 of 72"

echo
echo "===== 3f. the inline blocked_out sites are inverted too ====="
# chk() was inverted last round; the three inline sites were not, and they are
# the only checks actually blocked today.
gs=$(cat formal/v3/gate.sh)
for needle in "109-claim checker" "smoke" "graph claims"; do
  # the expected-string grep must appear BEFORE the blocked_out call in each block
  blk=$(printf '%s' "$gs" | grep -n "BLOCKED $needle" | head -1 | cut -d: -f1)
  okl=$(printf '%s' "$gs" | grep -n "ok   $needle" | head -1 | cut -d: -f1)
  if [ -n "$blk" ] && [ -n "$okl" ] && [ "$okl" -lt "$blk" ]; then
    caught "inline inversion: $needle tests the expected string first"
  else
    missed "inline inversion: $needle still tests blocked_out first"
  fi
done

echo
echo "===== 3g. validate.mjs prints no vacuous result line ====="
rm -rf "$FX/vspecs"; mkdir -p "$FX/vspecs"
vout=$(node formal/v3/validate.mjs "$FX/vspecs" 2>&1); vrc=$?
want_rc  "validate: empty dir exit code" 3 "$vrc"
want_not "validate: no '0 specs, 0 rejected' line" "$vout" "0 specs, 0 rejected"
want_has "validate: says it was blocked"           "$vout" "BLOCKED"

echo
echo "===== 3h. a missing verdicts.json is a blocked check, not a disagreement ====="
# Measured before fixing: 12 of 12 slugs carry a verdicts.json, so absence is a
# corpus defect. Deleting one gave exit 1, "3 total(s) out of step", and
# BUILD FAILED: a headline total disagrees -- the published lie through the one
# `continue` that had never been examined. Two slugs minimum, or the tot===0
# guard returns 3 for an unrelated reason and the assertion locks nothing.
mk_two "$FX/v1"; rm -f "$FX/v1/expansion/02-lending/verdicts.json"
out=$(DEFIFORMAL_ROOT="$FX/v1" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "verdicts: a deleted verdicts.json blocks" 3 "$rc"
want_has "verdicts: names the slug"                 "$out" "02-lending has no verdicts.json"
want_not "verdicts: not blamed on the manuscript"   "$out" "out of step"

mk_two "$FX/v2"
mv "$FX/v2/expansion/03-cdp-stablecoins/verdicts.json" "$FX/v2/expansion/03-cdp-stablecoins/verdicts.json.bak"
out=$(DEFIFORMAL_ROOT="$FX/v2" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "verdicts: a renamed verdicts.json blocks" 3 "$rc"

# and through build.sh, which is where the lie was actually published
mk_two "$FX/v3"; rm -f "$FX/v3/expansion/05-perpetuals/verdicts.json"
bout=$(cd "$R" && DEFIFORMAL_ROOT="$FX/v3" ./paper/build.sh 2>&1); brc=$?
bout=$(printf '%s' "$bout" | sed 's/\x1b\[[0-9;]*m//g')
want_rc  "verdicts: through build.sh, exit code" 3 "$brc"
want_not "verdicts: build.sh does not blame the manuscript" "$bout" "a headline total disagrees"

# control: the intact fixture must still pass, or the guard is always-on
mk_two "$FX/v4"
DEFIFORMAL_ROOT="$FX/v4" node formal/v3/totalgate.mjs >/dev/null 2>&1
want_rc "verdicts: intact corpus still passes (control)" 0 "$?"

echo
echo "===== 3j. an empty or json-less specs/ is a blocked check ====="
# A MISSING specs/ already blocked via ENOENT. A present-but-empty one gave zero
# iterations: `approx` came up short while tot/cov stayed complete, and strict
# was compared -- FAIL strict coverage 29.5% against the paper's 29.0%, exit 1,
# BUILD FAILED: a headline total disagrees. The other walk of the same lie.
mk_two "$FX/s1"; rm -f "$FX/s1/expansion/04-liquid-staking/specs/"*.json
out=$(DEFIFORMAL_ROOT="$FX/s1" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "specs: an emptied specs/ blocks" 3 "$rc"
want_has "specs: names the slug"           "$out" "04-liquid-staking has no *.json under specs/"
want_not "specs: strict is not compared"   "$out" "FAIL strict coverage"
want_not "specs: not blamed on the manuscript" "$out" "out of step"

# the renamed-suffix variant, which took the same branch
mk_two "$FX/s2"
for f in "$FX/s2/expansion/06-yield-vaults/specs/"*.json; do mv "$f" "$f.bak"; done
out=$(DEFIFORMAL_ROOT="$FX/s2" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "specs: renamed *.json blocks" 3 "$rc"

# through build.sh, where the lie was published
mk_two "$FX/s3"; rm -f "$FX/s3/expansion/07-bridges/specs/"*.json
bout=$(cd "$R" && DEFIFORMAL_ROOT="$FX/s3" ./paper/build.sh 2>&1); brc=$?
bout=$(printf '%s' "$bout" | sed 's/\x1b\[[0-9;]*m//g')
want_rc  "specs: through build.sh, exit code" 3 "$brc"
want_not "specs: build.sh does not blame the manuscript" "$bout" "a headline total disagrees"

# a MISSING specs/ must still block by its own message, not this one
mk_two "$FX/s4"; rm -rf "$FX/s4/expansion/08-intents/specs"
out=$(DEFIFORMAL_ROOT="$FX/s4" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "specs: a missing specs/ still blocks" 3 "$rc"
want_has "specs: missing dir keeps its own message" "$out" "cannot read specs for 08-intents"

# control: intact corpus still passes, or the guard is always-on
mk_two "$FX/s5"
DEFIFORMAL_ROOT="$FX/s5" node formal/v3/totalgate.mjs >/dev/null 2>&1
want_rc "specs: intact corpus still passes (control)" 0 "$?"

echo
echo "===== 3k. completeness, not just non-emptiness ====="
# Every guard before this round was count-based -- zero versus non-zero -- which
# says nothing about four files of five, or about an array that is well-formed
# and empty. Three defects of that shape, one of them a SILENT PASS.

# (a) an empty verdicts array. `[]` IS an array, so the type check passed, the
# loop ran zero times, tot/cov omitted the slug while approx still counted its
# specs, and the comparison proceeded on a short total.
mk_two "$FX/k1"; printf '[]' > "$FX/k1/expansion/02-lending/verdicts.json"
out=$(DEFIFORMAL_ROOT="$FX/k1" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "complete: an empty verdicts array blocks" 3 "$rc"
want_not "complete: empty verdicts is not a disagreement" "$out" "out of step"

# (b) four of five spec files deleted -- one remains, so the zero-file guard
# stays silent, approx comes up short and strict is compared.
mk_two "$FX/k2"
ls "$FX/k2/expansion/03-cdp-stablecoins/specs/"*.json | tail -4 | xargs rm -f
out=$(DEFIFORMAL_ROOT="$FX/k2" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "complete: a partial specs/ blocks" 3 "$rc"
# Either guard is a correct answer here: the cross-source check fires first
# (specs hold fewer items than verdicts report) and the file-count check
# would fire next. Assert that it blocks for a stated corpus reason, not
# that it produced one particular sentence.
if printf '%s' "$out" | grep -qE "internally inconsistent|the corpus is incomplete"; then
  caught "complete: a partial specs/ blocks for a stated corpus reason"
else
  missed "complete: a partial specs/ blocked without naming a corpus reason"
fi
want_not "complete: strict is not silently short" "$out" "FAIL strict coverage 29.0"

# (c) THE SILENT PASS. An empty functionalObligations array in EVERY spec file:
# each file is counted, no assignment is, and before this fix the gate reported
# that every headline total agreed while having measured no assignment at all.
mk_two "$FX/k3"
for f in "$FX/k3/expansion/"*/specs/*.json; do
  python3 - "$f" <<'PY'
import json,sys
p=sys.argv[1]
d=json.load(open(p)); d["functionalObligations"]=[]
json.dump(d,open(p,"w"))
PY
done
out=$(DEFIFORMAL_ROOT="$FX/k3" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "complete: empty obligations everywhere blocks" 3 "$rc"
want_not "complete: NOT a silent pass" "$out" "all headline totals agree"

# (d) the gate states its denominator at all
out=$(node formal/v3/totalgate.mjs 2>&1)
want_has "complete: the gate reports spec files walked" "$out" "60 spec files"
want_has "complete: the gate reports categories counted" "$out" "walked 12 categories"

# control: intact corpus still passes
mk_two "$FX/k4"
DEFIFORMAL_ROOT="$FX/k4" node formal/v3/totalgate.mjs >/dev/null 2>&1
want_rc "complete: intact corpus still passes (control)" 0 "$?"

echo
echo "===== 3l. the two sources must agree before anything is published ====="
# Round 10's guard counted FILES and CATEGORIES. Round 11 found the non-empty
# pole: a TRUNCATED verdicts array and an ALL-RESIDUE obligations array both
# keep 12/60 intact while the item-level walk comes up short. Guarding counts
# one level deeper would only move the pole again. verdicts/ and specs/ carry
# the same two quantities independently, so a short walk on either side now
# shows up as the two disagreeing with EACH OTHER rather than with the paper.

# (a) a truncated verdicts array -- non-empty, so every earlier guard passes
mk_two "$FX/x1"
python3 - "$FX/x1/expansion/02-lending/verdicts.json" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p))
json.dump(d[:1], open(p, "w"))     # keep one record of five
PY
out=$(DEFIFORMAL_ROOT="$FX/x1" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "sources: a truncated verdicts array blocks" 3 "$rc"
want_has "sources: names the inconsistency" "$out" "internally inconsistent"
want_not "sources: not blamed on the manuscript" "$out" "out of step"

# (b) every obligation made residue -- the array stays non-empty, the files are
# all counted, and before this fix the gate reported that every total agreed.
mk_two "$FX/x2"
for f in "$FX/x2/expansion/"*/specs/*.json; do
  python3 - "$f" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p))
for o in d.get("functionalObligations", []):
    o["elements"] = []
json.dump(d, open(p, "w"))
PY
done
out=$(DEFIFORMAL_ROOT="$FX/x2" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "sources: all-residue obligations block" 3 "$rc"
want_not "sources: NOT a silent pass" "$out" "all headline totals agree"

# (c) the gate states both denominators, so a reader can see what it counted
out=$(node formal/v3/totalgate.mjs 2>&1)
want_has "sources: reports the item denominators" "$out" "1259 obligation items"
want_has "sources: reports the agreement"         "$out" "the two sources agree"

# control: the cross-check must not be always-on
mk_two "$FX/x3"
DEFIFORMAL_ROOT="$FX/x3" node formal/v3/totalgate.mjs >/dev/null 2>&1
want_rc "sources: intact corpus still passes (control)" 0 "$?"

echo
echo "===== 3m. a figure must appear where it is CLAIMED, not anywhere ====="
# `has()` was tex.includes() over a 151 KB document, so a wrong measurement could
# be satisfied by the same digits in an unrelated sentence. Stripping every
# approximate-fit marker drives approx to 0, makes strict equal the pooled
# coverage (45.3), and the coverage literal eleven lines above satisfied it:
# exit 0, "all headline totals agree", while the paper claims 29.0%. A silent
# PASS, and the last gate defect class of this branch.
mk_two "$FX/m1"
python3 - "$FX/m1" <<'PY'
import json, pathlib, re, sys
root = pathlib.Path(sys.argv[1]) / "expansion"
for f in root.glob("*/specs/*.json"):
    d = json.load(open(f))
    for o in d.get("functionalObligations", []):
        if re.search(r"approx|forced|partial|stretch", o.get("note") or "", re.I):
            o["note"] = "discharged"
    json.dump(d, open(f, "w"))
PY
out=$(DEFIFORMAL_ROOT="$FX/m1" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "claim: the needle-collision mutation is caught" 1 "$rc"
want_not "claim: NOT a silent pass" "$out" "all headline totals agree"
want_has "claim: strict is what fails" "$out" "FAIL strict coverage"
want_has "claim: coverage still legitimately passes" "$out" "ok   coverage 45.3%"

# the anchors must be bound to a real claim site: if the manuscript stops making
# the claim where the gate looks, that is a blocked check, not a pass.
mk_two "$FX/m2"
python3 - "$FX/m2/paper/atlas.tex" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding="utf-8").read()
s = s.replace("Counting those as residue gives", "Treating those as residue yields")
io.open(p, "w", encoding="utf-8").write(s)
PY
out=$(DEFIFORMAL_ROOT="$FX/m2" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "claim: a moved claim site blocks" 3 "$rc"
want_has "claim: says the figure is no longer stated there" "$out" "no longer states this figure"

# control: intact corpus still passes, so the anchors are not simply always-red.
# The first version of these anchors used a sentence window that closed before
# the figure (the figures contain dots), and the intact corpus FAILED. This
# control is the only reason that did not ship.
mk_two "$FX/m3"
DEFIFORMAL_ROOT="$FX/m3" node formal/v3/totalgate.mjs >/dev/null 2>&1
want_rc "claim: intact corpus still passes (control)" 0 "$?"

echo
echo "===== 3n. every claim site of a figure must agree ====="
# tot was required in both meas:covsens and tab:categories; res was required
# only in the table. So the old gate caught a prose-side edit and missed the
# table, and this one caught the table and missed the prose -- an internally
# inconsistent paper shipping at exit 0, the mirror of the defect anchoring was
# introduced to remove.

# (a) edit the residue PROSE claim, leave the table alone
mk_two "$FX/n1"
python3 - "$FX/n1/paper/atlas.tex" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding="utf-8").read()
old = "The sixty constructions leave $689$"
if old not in s:
    print("PERTURBATION DID NOT APPLY", file=sys.stderr); sys.exit(3)
io.open(p, "w", encoding="utf-8").write(s.replace(old, "The sixty constructions leave $690$"))
PY
out=$(DEFIFORMAL_ROOT="$FX/n1" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "sites: a prose-only residue edit is caught" 1 "$rc"
want_has "sites: residue is what fails" "$out" "FAIL residue total"

# (b) edit the residue TABLE cell, leave the prose alone
mk_two "$FX/n2"
python3 - "$FX/n2/paper/atlas.tex" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding="utf-8").read()
old = "total & --- & 1259 & 570 & 689 & 15"
if old not in s:
    print("PERTURBATION DID NOT APPLY", file=sys.stderr); sys.exit(3)
io.open(p, "w", encoding="utf-8").write(s.replace(old, "total & --- & 1259 & 570 & 690 & 15"))
PY
out=$(DEFIFORMAL_ROOT="$FX/n2" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "sites: a table-only residue edit is caught" 1 "$rc"

# (c) the same for tot, both directions, which HEAD already required
mk_two "$FX/n3"
python3 - "$FX/n3/paper/atlas.tex" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding="utf-8").read()
io.open(p, "w", encoding="utf-8").write(
    s.replace("total & --- & 1259 & 570 & 689 & 15", "total & --- & 1260 & 570 & 689 & 15"))
PY
out=$(DEFIFORMAL_ROOT="$FX/n3" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "sites: a table-only tot edit is caught" 1 "$rc"

# control: an untouched manuscript still passes
mk_two "$FX/n4"
DEFIFORMAL_ROOT="$FX/n4" node formal/v3/totalgate.mjs >/dev/null 2>&1
want_rc "sites: an untouched manuscript still passes (control)" 0 "$?"

echo
echo "===== 3o. the register does not overstate the hole ====="
# The register claimed a pair-delete is "reported as agreement". It is caught by
# the file-count guard, exit 3. A register that overstates a hole mis-sizes a
# reader's trust as surely as one that hides it, so the claim is now measured.
mk_two "$FX/o1"
rm -rf "$FX/o1/expansion/09-rwa/specs/"*.json
python3 - "$FX/o1/expansion/09-rwa/verdicts.json" <<'PY'
import json, sys
p = sys.argv[1]
d = json.load(open(p))
json.dump(d[:-1] if len(d) > 1 else d, open(p, "w"))
PY
out=$(DEFIFORMAL_ROOT="$FX/o1" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_not "register: a pair-delete is NOT reported as agreement" "$out" "all headline totals agree"
reg=$(cat formal/v3/GATE-REGISTER.md)
want_has "register: records the correction rather than amending it" "$reg" "Correction."
want_has "register: names the cardinality-preserving variant"       "$reg" "cardinality-preserving"

echo
echo "===== 3p. a claim in a comment is not a claim ====="
# claimsNumAt used tex.match(), so the FIRST occurrence anywhere won -- including
# inside a LaTeX comment, which never typesets. Plant the old sentence in a
# comment, edit the visible one, leave the table: the gate reported agreement
# about a manuscript that would print 690 in prose and 689 in the table.

mk_two "$FX/p1"
python3 - "$FX/p1/paper/atlas.tex" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding="utf-8").read()
real = "The sixty constructions leave $689$"
if real not in s:
    print("PERTURBATION DID NOT APPLY", file=sys.stderr); sys.exit(3)
s = s.replace(real, "The sixty constructions leave $690$", 1)   # visible text edited
s = "% " + real + " obligations that no element discharges.\n" + s  # decoy comment
io.open(p, "w", encoding="utf-8").write(s)
PY
out=$(DEFIFORMAL_ROOT="$FX/p1" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_not "comment: a commented decoy does not satisfy the claim" "$out" "all headline totals agree"
if [ "$rc" = "0" ]; then
  missed "comment: exit 0 on a manuscript that prints 690 in prose and 689 in the table"
else
  caught "comment: the decoy is refused (exit $rc)"
fi

# a duplicated VISIBLE claim is ambiguous, not a pass: the gate cannot tell
# which sentence the reader sees.
mk_two "$FX/p2"
python3 - "$FX/p2/paper/atlas.tex" <<'PY'
import io, sys
p = sys.argv[1]
s = io.open(p, encoding="utf-8").read()
real = "The sixty constructions leave $689$ obligations that no element discharges."
if real not in s:
    print("PERTURBATION DID NOT APPLY", file=sys.stderr); sys.exit(3)
io.open(p, "w", encoding="utf-8").write(s.replace(real, real + "\n" + real, 1))
PY
out=$(DEFIFORMAL_ROOT="$FX/p2" node formal/v3/totalgate.mjs 2>&1); rc=$?
want_rc  "comment: a duplicated claim blocks" 3 "$rc"
want_has "comment: says it cannot tell which is typeset" "$out" "cannot tell"

# control: the real manuscript, with its real comments, still passes
mk_two "$FX/p3"
DEFIFORMAL_ROOT="$FX/p3" node formal/v3/totalgate.mjs >/dev/null 2>&1
want_rc "comment: the untouched manuscript still passes (control)" 0 "$?"

echo
echo "===== 3i. loop2gate says plainly that no citation checker exists ====="
# Routing evidence.mjs / cites.mjs through one() replaced "no verdict" with a
# WRONG verdict: evidence.mjs is the supplement emitter (no failure path, its
# stderr always carries the needle) and cites.mjs never prints its needle and
# cannot fail. On a host where /root/defiformal exists, one() would have called
# the emitter ok and the checker FAIL.
l2src=$(cat formal/v3/loop2gate.sh)
want_not "citations: no one() on the emitter"  "$l2src" 'one "citation evidence"'
want_not "citations: no one() on cites.mjs"    "$l2src" 'one "citation URLs'
want_has "citations: states no checker exists" "$l2src" "no citation checker exists"
# and both are registered as CANNOT FAIL rather than counted as gates
reg=$(cat formal/v3/GATE-REGISTER.md)
want_has "citations: evidence.mjs registered CANNOT FAIL" "$reg" "formal/v3/evidence.mjs"
want_has "citations: cites.mjs registered CANNOT FAIL"    "$reg" "formal/v3/cites.mjs"
# L1: the assertions above are all greps of source text -- deleting `blkd=1`
# leaves every one of them green while loop2gate silently regains a PASS path.
# Behavioural: the citation section must actually set the blocked flag.
want_has "citations: the section sets blkd" "$l2src" "no citation checker exists in this tree."
if awk '/no citation checker exists in this tree/,/^$/' formal/v3/loop2gate.sh | grep -q '^blkd=1'; then
  caught "citations: blkd=1 follows the notice (behavioural, not a source grep)"
else
  missed "citations: the notice does not set blkd, so PASS is reachable again"
fi

echo
echo "===== 3c. blocked_out must not hide a content failure ====="
# blocked_out is a new lie in the opposite direction if it is over-broad: a
# harness that RAN and got the wrong answer, but whose output also carries a
# traceback, must read FAIL -- not BLOCKED.
# Lift the REAL blocked_out out of gate.sh rather than restating it here: a
# restated copy keeps passing after the original is changed or reverted, which
# is how the attribution probe went two rounds testing nothing.
eval "$(awk '/^blocked_out\(\) \{/,/^\}/' formal/v3/gate.sh)"
if ! declare -F blocked_out >/dev/null; then
  missed "could not lift blocked_out() from gate.sh"
fi
if blocked_out "Traceback (most recent call last):
  File x
ValueError: computed 60 of 72"; then
  missed "blocked_out hides a content failure that merely traced back"
else
  caught "blocked_out does not hide a bare traceback"
fi
if blocked_out "PermissionError: [Errno 13] Permission denied: '/root/x'"; then
  caught "blocked_out still recognises a real PermissionError"
else
  missed "blocked_out no longer recognises a real PermissionError"
fi
if blocked_out "pairs: 1830   BLOCKED-looking word in normal output"; then
  missed "blocked_out trips on the bare word BLOCKED in ordinary output"
else
  caught "blocked_out ignores the bare word BLOCKED in ordinary output"
fi

echo
echo "===== 4. vacuity guards on the other gates ====="

rm -rf "$FX/emptyir"; mkdir -p "$FX/emptyir"
# gate33 writes its result JSON back into the tree, so the control mutates a
# tracked file. Snapshot and restore: this harness must leave the repo exactly
# as it found it, and section 5 asserts that.
G33=research/positive-program/sigma/GATE-3.3-CERT-RESULT.json
cp "$R/$G33" "$FX/g33.bak" 2>/dev/null
python3 research/positive-program/sigma/gate33_cert_check.py >/dev/null 2>&1; rc=$?
[ -f "$FX/g33.bak" ] && cp "$FX/g33.bak" "$R/$G33"
want_rc "gate33 control: real IR" 0 "$rc"
GEN_IR="$FX/emptyir" python3 research/positive-program/sigma/gate33_cert_check.py >/dev/null 2>&1; rc=$?
want_rc "gate33 VACUOUS: empty IR" 3 "$rc"
if [ -f "$FX/emptyir/GATE-3.3-CERT-RESULT.json" ]; then
  missed "gate33 wrote a PASS artefact on an empty IR"
else
  caught "gate33 wrote no artefact on an empty IR"
fi

rm -rf "$FX/emptyrepo"; mkdir -p "$FX/emptyrepo/expansion"
timeout 300 python3 research/positive-program/sigma/verify_final.py >/dev/null 2>&1; rc=$?
want_rc "verify_final control: real corpus" 0 "$rc"
DEFIFORMAL_ROOT="$FX/emptyrepo" python3 research/positive-program/sigma/verify_final.py >/dev/null 2>&1; rc=$?
want_rc "verify_final VACUOUS: empty corpus" 3 "$rc"

# validate.mjs is blocked in-tree by formal/v2/tables.mjs, which hardcodes
# /root/DefiElements. That root fix is out of scope for this change, so the
# guard is present but NOT demonstrable here. Recorded, not claimed.
rm -rf "$FX/emptyspecs"; mkdir -p "$FX/emptyspecs"
vout=$(node formal/v3/validate.mjs "$FX/emptyspecs" 2>&1); vrc=$?
if printf '%s' "$vout" | grep -q 'EACCES'; then
  printf '  BLOCKED validate.mjs vacuity guard NOT demonstrated -- blocked by\n'
  printf '          formal/v2/tables.mjs hardcoded root (out of scope here)\n'
else
  want_rc "validate.mjs VACUOUS: empty dir" 3 "$vrc"
fi

echo
echo "===== 5. the harness itself leaves the repository untouched ====="
# Every prior run silently regenerated GATE-3.3-CERT-RESULT.json. A checker that
# mutates the tree it is auditing cannot be trusted about that tree.
dirty=$(cd "$R" && git status --porcelain -uall 2>/dev/null | grep -v '^?? formal/v3/evidence/' | head -20)
if [ -z "$dirty" ]; then
  caught "harness leaves the repository clean"
else
  missed "harness left the repository dirty: $(printf '%s' "$dirty" | tr '\n' ' ')"
fi

printf '\n===== negtest-reporting: %d caught, %d missed =====\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
