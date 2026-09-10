# GitHub worktree preservation, 2026-09-09

This snapshot preserves all registered DeFiFormal worktrees at the times recorded in manifest.json. It does not accept unreviewed implementations. P17 and P18 remain pending native Opus acceptance; Atlas remains parked on feature/atlas. Accepted core implementation is already on semantic-kernel-pivot. P18 R2 candidate and root 8/8 control evidence are delivered separately under program-execution-20260908. The app continuation loop was observed paused.

Restore a worktree from its recorded HEAD, then apply its index and worktree binary patches and restore the recorded files/deletions with their modes. Each SHA-256 object resolves either to a Git blob in this delivery, an archive in this directory, or the earlier snapshot named in its record. Archive members are objects/<sha256>. Git blobs can be read with git cat-file blob <git_oid>. Symlink content is the link target. Nonignored untracked files are preserved; ignored build caches and private installations are excluded. The bundle preserves worktree commits outside the delivery branch and uses the recorded base as its prerequisite.

Historical frozen manifests retain their original statuses. Current execution status is recorded in ../program-execution-20260908/STATE.json and ../strategy-audit-20260908/CURRENT.json.
