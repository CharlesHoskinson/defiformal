# causal-generic-r1 evidence-manifest repair

GPT-6 found one stale digest in the original `hashes/evidence-artifacts.sha256`:
`hashes/source-hash-equality.txt` was overwritten with `worktree_private_final_equal=yes` after that listing was hashed.

This repair does not overwrite or relabel that original listing. Causal.lean is unchanged
(`3cd36f6a0f04b4541db5406a90cdb62c3f200f3e55dd83aa05b175179ef01a67`). The root-preserved
archive `review/semantic-kernel/sprint11/implementation/native-worker/causal-generic-r1-evidence.tar.gz`
is not modified.

Checked the original 46-entry listing against current bytes: 45 match, 1 stale, 0 missing.

| Path | Recorded SHA256 | Current SHA256 |
| --- | --- | --- |
| `hashes/source-hash-equality.txt` | `5040625b1fb6fa4af07226683f6e6003b29e5e70b16f8cfb24be7a752393f0ee` | `dc853d1ffcc182bea6bb598f9920df58d5aa04cd92697a5d599f270bd6e7335d` |

Disposition: keep the original listing as historical bytes. Current regular files, including the
retained original listing and this note, are recorded in separately named `final-artifacts.json`.
That new listing excludes only itself and any symlink. No hashed input is written after it.

Details: `hash-mismatch-disposition.json`.
