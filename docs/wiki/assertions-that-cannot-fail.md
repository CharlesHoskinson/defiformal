# Assertions that cannot fail

**Claim.** The most expensive defects in this work were not in the gates. They
were in the tests for the gates — assertions that stayed green when the thing
they claimed to lock was removed.

A checker never observed failing is not evidence. That rule was applied to every
gate in the repository and exempted, repeatedly, from the tests being written to
apply it.

## Four measured ways it happens

### 1. The assertion tests a copy

The probe for the per-harness attribution fix re-implemented `want()` and
`blocked_out()` inside a heredoc. Reverting the real hunk left the probe
exercising a private copy that still had the fix.

Measured: reverting the hunk left 5 assertions red — but all five were
*incidental* (a syntactically broken script exiting 2, plus the dirty-tree
check). Nothing tested attribution.

**Fix:** lift the function from source. **Bounded** —
`awk '/^fn\(\) \{/,/^\}/'` runs on to the *next* function's closing brace when
the definition is one-lined, so `tail -1 == "}"` passes on swallowed body
(measured: 40 lines, 5 of them script body, lift returned 0). Require non-empty,
ends `}`, exactly one `^name() {`, and no line matching
`^(echo|one |want "|===== )`.

### 2. It greps source instead of running behaviour

A check for `case "$brc" in` in `loop2gate.sh` passed — against a block that was
**dead code after an `exit`**. The source contained the string; the string never
executed.

**Fix:** run the script and assert on what it emits. The replacement implants a
marker after the terminal block and asserts it never prints, *plus* a control
implanting it before the block and asserting it does.

### 3. A parent guard already returns the same code

The per-verdict `Number.isFinite` check sat beneath an existing `tot === 0`
guard. The fixture returned exit 3 with the hunk present *and* reverted, so the
assertion locked nothing.

**Fix:** assert the specific **message**, not just the code.

### 4. The fixture is degenerate

The unreadable-slug test built a **one-slug** corpus. With one slug, removing it
leaves zero obligations and the pre-existing `tot === 0` guard returns 3 — so the
assertion was green against the reverted fix.

With **two** slugs the readable one still contributes, the short total is
compared, and unfixed code exits 1 with `out of step`. That is the silent-skip
disagreement the fix exists to prevent.

**Fix:** the fixture must be able to exhibit the defect. Ask what the minimum
shape is, and build one size larger.

## Both controls, always

Every guard needs:

- a **positive control** — a deliberately defeating input, proving it fires
- a **negative control** — the real input, proving it isn't always-on

The second is not ceremony. A sentence-window anchor shipped that used `[^.]*?`
to reach the end of a claim — but the figures contain dots (`$45.3\%$`), so the
window closed before the number and the **intact corpus failed**. Its negative
control was the only reason a permanently-red gate didn't ship.

The `lift()` guard needed the same treatment twice: its first control ran the
probe from `/tmp`, where the script's relative `cd` lands on `/` and the sentinel
exits before either block is reached — so the check *and* its control were both
vacuous.

## The tell

If you write an assertion and cannot state, in one sentence, the input that
makes it red — it is not an assertion yet. Construct that input and watch it go
red before you commit.

## Related

[Blocked is not failed](blocked-is-not-failed.md) ·
[The economics of adversarial review](adversarial-review-economics.md)
