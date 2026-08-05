#!/bin/bash
# Negative control: the emission check must FAIL when the article's construction
# measurement is altered. A check that cannot fail is not a check.
cd /root/defiformal || exit 9

echo "--- baseline (article untouched) ---"
python3 formal/v3/verify-emission.py 2>&1 | tail -3
echo "baseline exit: $?"

cp paper/atlas.tex /tmp/atlas.backup

# perturb a single digit inside the Uniswap case measurement
python3 - <<'PY'
import io, re
p = "/root/defiformal/paper/atlas.tex"
s = io.open(p, encoding="utf-8").read()
i = s.index("\\label{case:dex:uniswap}")
seg = s[i:i+4000]
m = re.search(r"(\\begin\{measurement\}.*?)(\b\d{2}\b)", seg, re.S)
if not m:
    print("PERTURB: no two-digit number found in the case block"); raise SystemExit(3)
old = m.group(2)
new = str((int(old) + 7) % 100).zfill(2)
seg2 = seg[:m.start(2)] + new + seg[m.end(2):]
io.open(p, "w", encoding="utf-8", newline="\n").write(s[:i] + seg2 + s[i+4000:])
print(f"PERTURB: changed {old} -> {new} inside the Uniswap case measurement")
PY

echo
echo "--- with one digit changed, the check MUST fail ---"
out=$(python3 formal/v3/verify-emission.py 2>&1)
echo "$out" | tail -4
case "$out" in
  *VIOLATED*) echo "NEGATIVE CONTROL PASSED: the check detected the change" ;;
  *)          echo "NEGATIVE CONTROL FAILED: the check did not notice" ;;
esac

cp /tmp/atlas.backup paper/atlas.tex
echo
echo "--- restored ---"
git diff --stat paper/atlas.tex | tail -2
python3 formal/v3/verify-emission.py 2>&1 | tail -2
