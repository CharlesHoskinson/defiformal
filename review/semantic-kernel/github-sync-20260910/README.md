# GitHub worktree preservation, 2026-09-10

This snapshot preserves all registered DeFiFormal worktrees at the recorded times, including unpublished source, evidence, tracked changes and index/worktree binary patches. P17 and P18 are accepted and delivered. P19 R11 is a frozen partial candidate; its full codec proof remains open. The P24 source diagnostics have a completed scoped Grok review. Snapshot publication does not change any candidate acceptance status. The full authorized core goal remains active, and Atlas remains parked.

Restore from each recorded HEAD, apply its index/worktree patches and restore files/deletions with recorded modes. SHA-256 objects resolve to delivery Git blobs, objects/<sha256> archive members, or recursively to the previous snapshot named in the object record. Git blobs are available via git cat-file blob <git_oid>. Symlink content is its target. The bundle preserves registered worktree commits outside the delivery branch using the recorded base as a prerequisite.

Ignored files and rebuildable .lake, node_modules, __pycache__, and .venv paths are excluded. Explicitly excluded Git-visible cache paths are listed in each worktree record. Original user files remain unchanged in their working directories, including AGENDA.md; their current bytes are preserved here. Filesystem symlinks are preserved as links; their targets are not followed.

Current execution and acceptance state is recorded in ../program-execution-20260908/STATE.json and ../strategy-audit-20260908/CURRENT.json. Historical records retain their original identities and statuses.
