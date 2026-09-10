# One development branch

The sole development and delivery branch is `semantic-kernel-pivot`. This consolidates branch names and preserves their history; it does not accept unfinished candidates or enable parked Atlas work. Existing auxiliary worktrees retain their files and index at their original detached HEADs. They are candidate or historical working copies, not separate development branches.

`manifest.json` records every former local and GitHub branch head and its recovery source. Ancestor commits are already in the delivery history. The preceding GitHub snapshot preserves all 21 worktrees, including unpublished files. Its commit bundle preserves the Atlas and honest-gate detached commits. Local backup refs under `refs/archive/one-branch-20260910/` retain original heads without creating branches.

One old R4 commit contains a 279 MB blob that GitHub cannot accept directly. Its 18 other missing Git objects are stored as raw object bodies in `unpublished-r4-git-objects.tar.gz`; the large blob is already preserved in nine ordered parts at the manifest path recorded for that object. To recover it, concatenate those parts and verify the recorded SHA-256. Feed each recovered body to `git hash-object -w -t <type> --stdin`, checking the returned object ID against the manifest. With the delivery history available, this restores commit `7c2c49a3fea11e627b55c6ebaeeda3167737e440` exactly. Never push that commit directly to GitHub because its oversized blob remains in its tree.

Future implementation and independent review use detached isolated working copies. Accepted work is integrated into the sole branch. Historical manifests and reviews retain their original branch names and hashes.
