# P31 direct codec diagnostic

Eight direct calls to the captured Moriarty codec at commit 7307349d0275af6fcb4144e1661d8b59d6b2663a passed in attempt2. Numeric-looking strings and booleans are preserved; numeric/null values, duplicate keys, unsorted keys, and missing closed-record validators are refused. Generic decoding retains extra fields.

Attempt1 failed before semantic execution because its relative import path was wrong. Its original bytes and receipt are preserved. Attempt2 places the probe at the correct depth. The receipts bind Node, source, probe, and output hashes. The Node installation path does not indicate Foreman orchestration.

This tests only these eight codec calls. It accepts no adapter, compiler, Lean/K proof, settlement, or PCT implementation.
