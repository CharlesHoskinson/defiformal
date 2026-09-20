# P19 S14 fixture-role correction

This addendum resolves an inconsistent fixture designation; the strict canonical decoder contract remains binding. Acceptance of this addendum requires independent review.

The frozen grammar requires decoder input bytes to equal the canonical encodeModule representation, including lexicographically ordered dynamic source_map keys. S14 incorrectly names original F13 as a successful positive despite its noncanonical key order. See P19-CODEC-CONTROLS-REVIEW.md for the exact clauses and preserved execution evidence.

For current verification, designate C13-canonical, raw SHA-256 `9b8c2b4206e59de2f35c145024d3f25327c8660e4f43be66a729341ba01b66a9`, as S14's positive envelope/structural-IR companion. Its only input change is source_map key order. Keep original F13/C13-permuted, raw SHA-256 `147d3f956a7c316338e151c11d679d953fb9b38aab30e08648c77d922c8c84c8`, as the required rejected canonicality control. Keep C13-changedIR, with the identical canonical input and deliberately wrong expected destination party, as the comparator negative.

Preserve original scenario text, F13/F28 fixture bytes and historical expectations unchanged. This separate mapping records the correction; it does not claim original F13 now decodes successfully, relax canonical decoding, or change theorem statements.

S14 evidence qualification remains open until positive envelope coverage and the comparator negative are bound to actual inputs and runner source. The preserved R6 records did not hash the Python comparator; a bounded rerun or recovery of a bound snapshot is required. This addendum closes neither that verification requirement nor P19/P20.
