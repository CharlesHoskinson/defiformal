# LEAN-GAMEPLAN — how we use Lean skills on defiformal

Live tree: `/root/DefiElements`.

## Skills

| Stack | Use |
|-------|-----|
| leanprover `lean-proof` | One tactic → check → next; hardest first; cleanup |
| lean4 plugin draft/prove/disprove/review | Multi-cycle structure |
| mathlib-build | cache + quiet builds |
| Codex Sol | External audit only |
| Quint skills | M4 / Pendle only |

## Profile
scripts_only unless Lean LSP MCP is available: `lake env lean File.lean` after each step.

## Quality gate
`lake build` + zero sorry in scope + only propext/Classical.choice/Quot.sound + negative companion + honest module scope.

## Milestone order
M3 n-ary → Sol → M4 Pendle/invariants → checkpoint.

## Standing rules
See prior session gameplan: one step at a time; statements are API; Sol after self-review; WSL live tree only.
