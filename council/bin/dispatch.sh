#!/usr/bin/env bash
# One sandboxed member per lens. Each gets an empty directory containing only
# the bundle and its own brief, so "do not read any other file" is enforced by
# the filesystem rather than by asking politely.
#
# CLI map corrected against council/bin/members.sh (the load-bearing source
# of truth, confirmed by Task 1's smoke tests) rather than against the
# original task-6-brief.md, which was extracted before Task 1 ran:
#   - reproducer runs opencode, not gemini. gemini has no auth configured on
#     this box and crashes on startup on a pre-existing ~/.gemini/projects.json
#     collision; members.sh already dispatches opencode for this lens.
#   - formal (claude) is dispatched anyway, on the same path as every other
#     lens, so its failure is recorded honestly rather than silently skipped.
#     `claude auth status` reports loggedIn:false -- credentials are present
#     (Max subscription) but the OAuth session is expired and unrefreshable,
#     which only Charles can fix. It is expected to fail and must not be
#     re-dispatched or substituted.
set -uo pipefail

# This script is invoked as `bash council/bin/dispatch.sh`, not as a login
# shell, so ~/.bashrc / ~/.profile are never sourced and PATH lacks every
# user-local install dir. Observed 2026-08-23: under the bare PATH inherited
# from a non-login `bash script.sh` invocation, `codex` still resolved (it
# happens to also live on /usr/local/bin) but grok, claude and opencode all
# failed with "launcher error: spawn <cli> ENOENT" -- node's child_process
# spawn never found the binary, so no vendor call was made and no cost was
# incurred, but three of four lenses silently never ran. Hardening PATH here,
# rather than depending on the caller's shell, keeps this script correct
# under any invocation (cron, another agent, a plain `bash` call) including
# Task 7's reuse of it for the decider round.
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.npm-global/bin:$HOME/.grok/bin:$PATH"

cd "$(dirname "$0")/../.." || exit 3
REPO="$(pwd)"
. council/bin/members.sh

# run_member (members.sh) executes its whole case statement inside a
# `( cd "$sb" ... )` subshell -- the sandbox directory, not this script's
# cwd. Any relative path handed in as outjson/outlog therefore resolves
# against the sandbox, not the repo, and the redirect in _launch fails
# before the vendor CLI is ever invoked. OUT and the copied brief source
# must be absolute for that reason.
ROUND="${1:-1}"
# Optional space-separated lens subset (2nd arg), defaulting to all four.
# Exists so a lens that failed for an environment reason before ever
# reaching the vendor CLI (e.g. the PATH bug above) can be re-run alone,
# without re-dispatching -- and re-billing -- a lens that already
# succeeded and validated.
LENSES="${2:-empirical formal significance reproducer}"
OUT="$REPO/council/sprint1/reports"
mkdir -p "$OUT"

B="$REPO/council/sprint1/BUNDLE-blinded.md"
[ -s "$B" ] || { echo "dispatch: BLOCKED - no bundle"; exit 3; }
python3 council/bin/leak-check.py "$B" >/dev/null 2>&1 \
  || { echo "dispatch: BLOCKED - bundle failed the leak check"; exit 3; }

declare -A CLI=( [empirical]=grok [formal]=claude [significance]=codex [reproducer]=opencode )

for lens in $LENSES; do
  SB=$(mktemp -d)
  cp "$B" "$SB/bundle.md"
  cp "$REPO/council/sprint1/BRIEF-$lens.md" "$SB/brief.md"
  j="$OUT/R$ROUND-$lens-${CLI[$lens]}.json"
  l="$OUT/R$ROUND-$lens-${CLI[$lens]}.log"
  echo "dispatching $lens (${CLI[$lens]}) ..."
  run_member "$lens" "$SB" "$SB/brief.md" "$j" "$l"
  rc=$?
  echo "  exit=$rc bytes=$(wc -c < "$j" 2>/dev/null || echo 0)"
  rm -rf "$SB"
done

python3 council/bin/validate-reports.py "$OUT"
