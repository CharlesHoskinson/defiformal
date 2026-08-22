# Portability and dead roots

**Claim.** The work was done in `/root/DefiElements` and published from a
different tree. Nothing was parameterised on the way out, and the resulting
count was easy to get wrong in both directions.

## The numbers

- **256** tracked files reference `/root/DefiElements` or `/root/defiformal`
  (the union — 16 name both, so 196 + 77 double-counts).
- **160** of those are scripts with a filesystem operand. Zero were comment-only.
- **+42** hidden dependents: scripts with no such string that *import* one that
  has one.
- **202** scripts a third party cannot run.

The naive count (160) is the right count of *string hits in executables* and the
wrong count of *scripts that are broken*. Walk one import hop.

## The fix pattern

`formal/v2/tables.mjs:4` was `const ROOT = "/root/DefiElements"` and gated all
three README reproduce commands. It resolves from `import.meta.url` now, with a
`DEFIFORMAL_ROOT` override — and **announces the override on stderr**, because a
stale environment variable silently computing the published figures from another
tree is exactly the class of confident wrong answer this repo exists to remove.

One line was not enough: six sibling scripts re-read `corpus50/lanes` by absolute
path rather than using the root `tables.mjs` had just resolved. `ROOT` is now
exported and they use it.

The Python gates were **already correct** — they resolve from `__file__`. Only
the JavaScript was welded to the dead tree.

## What remains

`formal/v3/construct.mjs:59` still defaults
`loadCorpus(root = "/root/DefiElements")`, which gates `claims.mjs`,
`selftest.mjs` and therefore `smoke.sh`. About 52 `formal/v3` scripts still
import by absolute ESM specifier. `gate.sh` reports **BLOCKED** rather than PASS
because of it — which is the honest verdict, and the remaining work.

## The trap worth remembering

Verification scripts write their result files back into the tree, so *verifying*
and *regenerating* are the same action and a gate can never disagree with its own
record. Re-running gate 3.3 reproduced the committed result bit-for-bit except
the recorded provenance path — which is what a genuine reproduction looks like.
Numbers that *move* mean the committed evidence was stale.

## Related

[Blocked is not failed](blocked-is-not-failed.md)
