# GitHub preservation snapshot

The user requested “merge everything to github”. Accepted implementation is delivered on `semantic-kernel-pivot`. This snapshot also preserves unfinished and rejected work without promoting it to accepted production source. It does not merge to main, close review gates, or erase local worktrees.

The manifest records 15 worktrees and 9,386 changed/untracked file entries. Content is deduplicated into 4,489 SHA-256 objects in four archives. Every archive member and reference was verified. One otherwise unpublished clean validation commit is retained as a Git bundle with its prerequisite commit recorded.

To recover a worktree, start from its `head_at_capture` commit in an isolated checkout. For every file entry with a SHA-256, find the corresponding `objects/<sha256>` member in the archive named by the manifest, verify its SHA-256, and copy it to the recorded relative path with the recorded mode. Entries absent at capture represent deleted/missing paths; consult their status before removal. The manifest also preserves exact staged, working and combined binary patches as content objects, allowing the index/worktree distinction to be reconstructed. Do not overlay a recovery onto an active checkout.

The capture covers Git-visible changes and nonignored untracked files. Ignored build caches and private installed tools remain reproducible local infrastructure. Each file read was checked for concurrent changes during that read. Atlas author work and an independent source review were active, so this is a dated partial snapshot, not an atomic final candidate. Later worker output requires its own review/freeze.

The canonical accepted/open status remains `../program-execution-20260908/STATE.json` and `../strategy-audit-20260908/CURRENT.json`. In particular, the P16 proof/model/recorder subset is accepted; the source campaign has confirmed gate defects and is not accepted. Atlas repairs are unfinished. Historical failed attempts and unaccepted corpus, Claims, certificate, and other candidate bytes retain their original status.
