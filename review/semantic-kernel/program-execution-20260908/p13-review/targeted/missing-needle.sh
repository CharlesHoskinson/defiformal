set -uo pipefail
declare -A HOUT HRC
HOUT[pairs]="pairs: 1829"; HRC[pairs]=0
fail=0; blkd=0
. "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p13-review/targeted/intact-fns.sh"
want "witness" 'pairs: 1830' pairs
if [ "$fail" -ne 0 ]; then
  printf '\n===== LOOP-2 RESULT: FAIL (fail=%s blocked=%s)\n' "$fail" "${blkd:-0}"; exit 1
elif [ "${blkd:-0}" -ne 0 ]; then
  printf '\n===== LOOP-2 RESULT: BLOCKED - one or more checks could not run (fail=%s blocked=%s)\n' "$fail" "${blkd:-0}"; exit 3
else
  printf '\n===== LOOP-2 RESULT: PASS\n'; exit 0
fi
