if [ "$fail" -ne 0 ]; then
  printf '\n===== LOOP-2 RESULT: FAIL (fail=%s blocked=%s)\n' "$fail" "${blkd:-0}"; exit 1
elif [ "${blkd:-0}" -ne 0 ]; then
  printf '\n===== LOOP-2 RESULT: BLOCKED - one or more checks could not run (fail=%s blocked=%s)\n' "$fail" "${blkd:-0}"; exit 3
else
  printf '\n===== LOOP-2 RESULT: PASS\n'; exit 0
fi
