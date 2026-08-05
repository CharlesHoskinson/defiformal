#!/bin/bash
# Parse every quint spec in the corpus to IR JSON.
OUT=/root/gen-ir
mkdir -p $OUT
ok=0; fail=0
for f in /root/DefiElements/quint-models/L*/*.qnt; do
  lane=$(basename $(dirname $f))
  base=$(basename $f .qnt)
  cd $(dirname $f)
  if quint parse --out $OUT/${lane}__${base}.json $(basename $f) >/dev/null 2>&1; then
    ok=$((ok+1))
  else
    fail=$((fail+1)); echo "PARSE-FAIL: $f"
  fi
done
echo "parsed_ok=$ok parse_fail=$fail"
ls $OUT | wc -l
