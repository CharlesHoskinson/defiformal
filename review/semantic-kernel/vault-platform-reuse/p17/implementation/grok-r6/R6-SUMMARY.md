# Grok R6 errata / summary

This directory is the RR4-NEG-FALSIFIER repair on top of the frozen Grok R5 candidate (`df5521cca52a53ff38858611befb82044cb676d64f50c8dea29d0291a4ede74c`). R5 bytes are not overwritten. AGY r1–r4 and earlier Grok authorship remain in their original directories.

Thirteen Opus R2 closed items (R-1..R-9, ROOT-T2.2, ROOT-T2.3, ROOT-T2.5, ROOT-FULL-COVERAGE) are carried forward with those R5 identities. This round does not rerun unchanged full EVM campaigns or production mutants.

Changed source: `scripts/platform_engine/rr4_metadata_diagnostics.py` (validator) and `scripts/platform_engine/common.py` (`_DEFAULT_EVIDENCE` now `grok-r6` so accidental runs cannot write R5). No Lean theorem statement changed.

`P17.platform_reuse` remains false. Root alone accepts. P18 and the remaining core program stay queued. Atlas stays parked.
