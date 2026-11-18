#!/bin/sh
# macOS arm64 package-only checksum verification and default Lean kernel replay.
set -eu
root=$(CDPATH= cd -- "$(/usr/bin/dirname -- "$0")" && pwd -P)
blocked() { echo "BLOCKED: $*" >&2; exit 3; }
failed() { echo "FAIL: $*" >&2; exit 1; }
for tool in /usr/bin/shasum /usr/bin/env /usr/bin/uname /usr/bin/mktemp /usr/bin/tr /usr/bin/dirname /bin/mkdir /bin/rm; do
  [ -x "$tool" ] || blocked "required macOS system tool unavailable: $tool"
done
[ "$(/usr/bin/uname -s)" = Darwin ] && [ "$(/usr/bin/uname -m)" = arm64 ] || blocked 'requires macOS arm64'
[ -s "$root/SHA256SUMS" ] || blocked 'empty or missing checksum inventory'
[ -s "$root/targets.txt" ] || blocked 'empty or missing target inventory'
[ -s "$root/allowed-empty.txt" ] || blocked 'empty or missing optional-evidence inventory'
for input in SHA256SUMS targets.txt allowed-empty.txt; do
  [ -r "$root/$input" ] || blocked "unreadable input: $input"
done
# Check missing/empty inputs separately from contradictory bytes.
while IFS= read -r line; do
  name=${line#*  }
  case "$name" in ''|/*|../*|*/../*) failed 'invalid checksum path';; esac
  [ -f "$root/$name" ] || blocked "missing artifact: $name"
  [ -r "$root/$name" ] || blocked "unreadable artifact: $name"
  if [ ! -s "$root/$name" ]; then
    allowed=false
    while IFS= read -r optional; do
      [ "$name" != "$optional" ] || allowed=true
    done < "$root/allowed-empty.txt"
    [ "$allowed" = true ] || blocked "empty required artifact: $name"
  fi
done < "$root/SHA256SUMS"
(cd "$root" && /usr/bin/shasum -a 256 -c SHA256SUMS) || failed 'checksum mismatch'
[ "$#" -eq 1 ] || blocked 'usage: /bin/sh replay.sh NEW_RESULTS_DIRECTORY'
case "$1" in /*) results=$1;; *) results=$PWD/$1;; esac
case "$results" in "$root"|"$root"/*) failed 'results must be outside package';; esac
[ ! -e "$results" ] || failed 'results directory already exists'
/bin/mkdir -p "$results"
work=$(/usr/bin/mktemp -d /private/tmp/defiformal-package-replay.XXXXXXXX)
trap '/bin/rm -rf "$work"' EXIT HUP INT TERM
count=0
seen='|'
while IFS= read -r target; do
  [ -n "$target" ] || blocked 'empty target name'
  case "$target" in *[!A-Za-z0-9_.]*) failed 'malformed target name';; esac
  case "$target" in DefiKernel.*|R2Replay|OriginalContractRelation) ;; *) failed 'unexpected target namespace';; esac
  case "$seen" in *"|$target|"*) failed 'duplicate target';; esac
  seen=$seen$target'|'
  module_path=$(echo "$target" | /usr/bin/tr . /)
  [ -s "$root/lib/lean/$module_path.olean" ] || blocked "missing target: $target"
  status=0
  (cd "$work" && /usr/bin/env -i PATH="$root/bin:/usr/bin:/bin" HOME="$work" \
    "$root/bin/leanchecker" -v "$target") > "$results/$target.stdout.log" 2> "$results/$target.stderr.log" || status=$?
  [ "$status" -eq 0 ] || failed "kernel replay failed ($status): $target"
  expected="replaying $target"
  observed=''
  IFS= read -r observed < "$results/$target.stdout.log" || failed "no replay observation: $target"
  [ "$observed" = "$expected" ] || failed "unexpected replay observation: $target"
  lines=0
  while IFS= read -r observed; do lines=$((lines+1)); done < "$results/$target.stdout.log"
  [ "$lines" -eq 1 ] || failed "unexpected replay denominator: $target"
  count=$((count+1))
  echo "PASS: $target"
done < "$root/targets.txt"
[ "$count" -gt 0 ] || blocked 'empty target denominator'
echo "PASS: $count selected modules replayed; imported declarations trusted; no outside-reproduction claim" > "$results/summary.txt"
IFS= read -r summary < "$results/summary.txt"
echo "$summary"
