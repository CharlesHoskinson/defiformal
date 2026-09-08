# interface-r1 manifest repair

The original `hashes/evidence-files.sha256` is retained unmodified. It has one
stale self-hash (empty-file digest `e3b0c442…` versus the filled 2265-byte
file) and omits REPORT.md, compile-status.json, identity.json,
root-source-snapshot/InterfaceInstances.lean, source-scan.txt and
statements.json.

This repair does not overwrite that manifest or REPORT.md. Current regular
files, excluding only `final-artifacts.json` itself, are listed in
`final-artifacts.json`. Disposition is in `hash-mismatch-disposition.json`.

Owned Lean source of the r1 candidate is unchanged by this evidence repair.
Previous failed compile logs remain.
