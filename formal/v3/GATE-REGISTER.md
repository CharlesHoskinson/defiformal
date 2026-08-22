# Gate register

Every gate, what it claims, and whether it has been *observed* failing on a
known-bad input. A checker never seen to fail is not evidence, and a row marked
`CANNOT FAIL` contributes none to any claim in the paper.

Verdicts:

| Verdict | Meaning |
|---|---|
| `DISCRIMINATES` | Made to fail on bad **content**, and to pass on good content. Both polarities observed. |
| `CANNOT FAIL` | No perturbation of input content produces a failure verdict. |
| `VACUOUS` | Passes over an empty corpus, or a conjunct that is constant by construction. |
| `BLOCKED` | Cannot run in this tree; no verdict either way. |

Exit-code contract: `0` property holds over a non-empty corpus · `1` property is
false · `3` check could not be performed. Exit 3 follows the pre-existing
`negtest-*.sh` convention (`PERTURBATION DID NOT APPLY`, `sys.exit(3)`).

## Registered gates

| Gate | Claims | Observed failure | Perturbation | Verdict |
|---|---|---|---|---|
| `formal/v3/totalgate.mjs` | Headline totals in `atlas.tex` equal the verdict sums; four stale round-2 values absent | Yes, both polarities | `$1{,}259$` → `$1{,}260$` in a fixture tex (exit 1); `chmod 000` expansion root (exit 3); empty root (exit 3) | `DISCRIMINATES` |
| `paper/build.sh` totals branch | Distinguishes a false total from a gate that could not run | Yes, both polarities | Fixture tex perturbation vs real `EACCES` | `DISCRIMINATES` |
| `formal/v3/gate.sh` | LOOP-2 integrity over build, harnesses, claims, graphs | Yes | Run from a directory that is not a defiformal tree — now exits 3 instead of printing `FAIL 61 of 72` | `DISCRIMINATES` |
| `research/positive-program/sigma/gate33_cert_check.py` | Keyword certificate over `gen-ir-v2ten`: every file has ≥1 tagged name; tags ⊆ {Led,Prop,Cmp,Post,OTHER} | Partial | Empty-of-names JSON → `FAIL: empty file`, exit 1. Empty IR → exit 3 (was `PASS 0 files`) | `DISCRIMINATES` emptiness only — the **tag-subset invariant CANNOT FAIL**: `tag_name` returns only members of `allowed` by construction, so `FAIL: bad tag` is unreachable |
| `research/positive-program/sigma/verify_final.py` | X21-armed pair counts over expansion specs | Yes | Empty corpus → exit 3. **Before this change the glob matched zero files on any tree but the author's and printed `X21-armed pairs (60-app basis): 0 of 0`, exit 0** — a live pass on an empty denominator. It now measures 60 specs | `DISCRIMINATES` |
| `research/positive-program/sigma/gate12_deletion_ir.py` | "IR deletion": how much of the IR surface disappears if a family is deleted | **No** — no failure path exists. Empty and missing IR both exit 0 and still write `MEASURED` | — | `CANNOT FAIL`. The residual counts are a rewrite of tag base rates (Post/Cmp = 3279/39 = 84.08×); nothing is actually deleted |
| `research/positive-program/sigma/gate11a_census_v1.py` | Independent-witness census; N3 printed `indep=0 shared=6` | **No** — no failure path; empty corpus still exits 0 and writes `MEASURED` | Classification does change on constructed input, but the script cannot report failure | `CANNOT FAIL`. N3 `indep=0` is `VACUOUS` — the local-def markers match zero definitions in the tree. The maple `SHARED` hit matches a **comment**, not a call |
| `formal/v3/claims.mjs` | 109 category claims recomputed from the corpus | Not in-tree | Against a mutated 71-protocol corpus a repointed copy gives 18 failures, exit 1 | `BLOCKED` in-tree (`tables.mjs` root). **CANNOT FAIL on `atlas.tex` errors — it never opens the paper** |
| `formal/v3/selftest.mjs` | 22 self-tests of `construct.mjs`, incl. an inadmissible X2 fixture | Not in-tree | Repointed copy vs a 71-protocol corpus: `FAIL corpus size: got 71 want 72` | `BLOCKED` in-tree; copy `DISCRIMINATES` its frozen goldens |
| `formal/v3/verify-measurements.mjs` | `meas:pairs` / `meas:whereitfails` numerals must appear | Not in-tree | Copy: `$147$`→`$148$` VIOLATED. **`Twenty of the`→`Nineteen of the` still VERIFIED** | `BLOCKED` in-tree; `CANNOT FAIL` on the duplicate word-form |
| `formal/v3/verify-graphs.py` | GRAPHS.md figures vs the merged/domain/lane graphs | Not in-tree | Copy: 777→9999 gives `GRAPH CLAIMS VIOLATED`, exit 1 | `BLOCKED` in-tree; copy `DISCRIMINATES` |
| `formal/v3/validate.mjs` | Rejects malformed construction specs | Not in-tree | Copy: 2 bad specs → 2 rejected, exit 1. Empty dir guard added but **not exercisable here** | `BLOCKED` in-tree by `formal/v2/tables.mjs`'s hardcoded root |
| `research/positive-program/basis/denominators.py` | Ten-protocol generation rate (`v2 119/716 = 16.6%`) | Yes | Missing IR → exit 1; `UNGEN_V1/V2` mismatch → exit 1 | `DISCRIMINATES` those two. **The 16.6% figure itself is not a threshold** — any rate prints and exits 0 |

## Rows that carry no evidence

`gate12_deletion_ir.py` and `gate11a_census_v1.py` are `CANNOT FAIL`. Both write
a document headed `MEASURED` regardless of input, including empty input. Neither
supports a claim, and `AGENDA-COMPLETE.md` lists both among its verification
commands. Gate 1.1a is cited as MEASURED for the basis census and gate 1.2 for
the deletion experiment; those citations rest on scripts with no failure path.

## Not addressed by this change

`totalgate.mjs`'s content checks remain unanchored `String.includes` tests over
the whole `.tex`, so a dummy file containing the four tokens also passes. It
computes `inad` (15) and `assigned` (570) and checks neither. The stale-value
blacklist is a frozen round-2 fossil rather than a derived invariant. Widening a
check and fixing how failure is reported are separate changes and were kept
apart deliberately; this is the candidate for the next one.

`formal/v2/tables.mjs`'s hardcoded `/root/DefiElements` root blocks four gates
above from running in any clone. That is the head of the root-resolution work,
explicitly a non-goal here.
