# defiformal → AFT: a sprint roadmap

**Date:** 2026-08-23
**Repository state at authoring:** `main` at `25a13c6`, working tree clean.
**Destination:** a submission-ready manuscript for AFT / Financial Cryptography.

---

## 1. What this roadmap is for

The manuscript exists — 40 pages, 37 proved items, 44 measurements, 3 open
conjectures, a 120-page supplement, a 72-protocol corpus. The gates behind it
are green: `gate.sh` PASS 10/10, `smoke.sh` 0, `negtest-reporting` 207/0,
`paper/build.sh` 0, `totalgate` 0.

None of that is the reason it would be rejected.

Referee C wrote that the applied results "largely restate what practitioners
know". That finding was **ACCEPTED**, and the response was to soften the claim
rather than strengthen it — the perpetuals result is now presented as close to
definitional, with its value relocated to a statement about the method. At a
DeFi-native venue that is the acceptance risk, and it is larger than any of the
five open technical items combined.

So the roadmap leads with the contribution and holds the rig work until the
framing settles.

### Constraints

- **Milestone-based, not calendar.** Each sprint exits on a written condition.
- **Round budget as a backstop.** Two council rounds per sprint, hard cap of
  three. A sprint that hits the cap without meeting its condition stops and
  reports what is open. This is structural, not advisory: a previous iteration
  ran twenty-one adversarial rounds because the stop condition was "the
  reviewers stop objecting", which two adversaries told to attack will never
  produce.
- **Contribution before rig.** Hardening a harness behind figures a reframing
  may demote is the scaffolding-before-target failure. Sprints 4 and 5 are
  deliberately late.

---

## 2. The contribution problem, concretely

Three results are candidates for the headline. They are not equal, and the
paper currently leads with the weakest.

**The perpetuals separation.** The canonical form separates order-book from
oracle-priced-pool microstructure without being told either exists. Referee C
conceded this is close to definitional — nobody designs a perp DEX without a
liquidation engine — and its remaining value is a claim about the *method*
rather than about DeFi.

**The residue.** Of 1259 recorded obligations, 689 have no name in the
vocabulary. That is a negative result about DeFi taxonomy, and it is not
obtainable by reading protocols: it requires a vocabulary complete enough to
fail against. The paper already states the mechanism — "a vocabulary whose
positive theory excludes nothing will not fail to cover an obligation by being
over-constrained; it will fail by having no name" — but does not lead with it.

**The concentration finding.** 1645 of 1830 pairs compose cleanly, which reads
as reassurance and is not: deployed compositions are not uniform, and the pairs
that actually occur in production concentrate among the spot exchanges and
lending markets that `meas:pairs` ranks most hostile. A 90% figure whose
complement is where the deployments live is a different paper from a 90% figure.

Sprint 1 decides which of these is the claim. It is a real decision with a real
branch: the residue and the concentration finding may need measurements the
paper does not currently carry.

---

## 3. Operating model

### foreman — transport and orchestration, never judgement

Foreman dispatches blinded council rounds across the vendor CLIs it already
drives (`agy`, `claude`, `codex`, `gemini`, `grok`, `opencode`) over session
transport, so no API keys are involved. It enforces the discipline recorded in
its own `AGENT_TRAPS.md`: an empty working directory per member, a brief that
says *answer from this bundle and read no other file*, and a check of the raw
log — not the summary — that each reply is on topic.

It collects reports. It does not rank them, and it does not decide what blocks.

### The council — blinded and advisory

The repository already has the right pattern and this roadmap does not invent a
new one: `BUNDLE-blinded.md`, `BUNDLE.sha256`, an identity-leak check, and a log
that records *"advisory. The council decides the brief; it does not own the
build."*

Blinding matters more here than it did for the design council. An AFT
simulation is worth nothing if the panel can tell whose work it is reviewing.

### wiki-llm — a second shelf, and it is checkable

`docs/wiki/` currently holds nine pages about verification engineering — one
page per idea, each stating the claim, the evidence that produced it, and what
it costs to forget it.

This roadmap adds a shelf of **claim pages**: one per headline claim in the
manuscript, carrying the claim, the evidence, the attacks tried against it, and
which survived.

The reason is a measured failure, not tidiness. `review/ACTIONS.md` recorded
`prop:ct` as ACTIONED while `atlas.tex` still said "a primitive in none" at two
sites; the same file recorded an arc count of twelve where the code and the
paper both say fifteen, a `meas:frag` bound stale by three orders of magnitude,
and a closing line asserting "none outstanding" directly above two OUTSTANDING
bullets. Council output stored as a snapshot drifts from the manuscript, and
nothing catches it.

So **each claim page names the command that reproduces its figure.** That makes
the shelf checkable rather than narrative: a gate walks the pages, runs each
command, and compares against the stated number. It is the move that turned
`xref-kinds.py` from an observation into a check, and it closes the drift class
instead of re-auditing it.

Claim pages are written from Sprint 1 onward so evidence accumulates in a
checkable shape. The checker itself is built in Sprint 5.

---

## 4. Sprint sequence

Each sprint exits on its condition or on the 3-round cap, whichever comes first.

### Sprint 1 — What does the algebra buy?

Bundle the abstract, introduction, and the three contribution candidates with
the measurements behind each. The council brief asks one question: *which of
these could a DeFi practitioner not have obtained by reading the protocols?*
Members attack all three and construct the strongest version of the claim.

**Exit condition.** A headline claim is decided and written down together with
what it rests on. A claim page exists for each surviving candidate.

**Branch point.** Whether the decided framing needs new measurements or only a
rewrite. Every later sprint depends on this answer, which is why nothing else
starts first.

### Sprint 2 — Make the headline claim true

Shape follows Sprint 1's branch: either a reframing (abstract, introduction,
conclusion and the applied section re-pointed at the decided claim) or a new
computation. Either way, every figure the framing depends on gets its
reproducing command recorded on its claim page.

**Exit condition.** A council round on the reframed contribution returns no
CONFIRMED-severe finding.

### Sprint 3 — Corpus defensibility

*Not on the existing open-items list. Added because it is the second-largest
AFT risk and nothing currently answers it.*

Referees will ask why these 72 protocols, what was excluded and on what
grounds, who produced the decompositions, under what protocol, and whether two
annotators would agree. The repository discloses the Uniswap+Aave circularity
in a provenance remark, which is the right instinct applied to one example; it
has no corpus-selection methodology.

**Exit condition.** A corpus-provenance section survives a council round briefed
specifically on selection bias.

### Sprint 4 — The evidence behind the figures

The technical backlog earns its place here, restricted to what the headline
claim rests on:

- **The eight dead negative-test harnesses.** `negtest-cattable`,
  `negtest-claims`, `negtest-composition`, `negtest-emission`,
  `negtest-footprints`, `negtest-graphs`, `negtest-measurements` and
  `negtest-setclaims` all die on `cd /root/defiformal: Permission denied`. Only
  `negtest-reporting` runs. These are the negative controls for the gates that
  produce the manuscript's figures: until they run, every green gate is green
  on the strength of a check nothing has tested.
- **`meas:frag` recomputation**, recorded OUTSTANDING — its stored output
  terminates in an uncaught TypeError, so the conjecture stands on a downgrade
  rather than a repair.
- **Referee B4's L\* robustness figures.** The normativity half is done: the
  Method remark now states that every figure uses the recorded 29-row system.
  The referee also asked for the L\* figures as a robustness check, and they
  are unreported.
- **The three division-by-zero models.** Apalache reaches `0 // 0` in
  `curve.qnt`, `699 // 0` in `huma.qnt`, `8000000000 // 0` in `liquity.qnt` —
  states 4000 random samples never construct. Each model has 400–760 division
  sites, so this needs the counterexample trace, not inspection.
- **The merged-graph decision** (see §6).

**Exit condition.** Every headline figure traces to a command that runs, and
every gate behind those figures has an *observed* failure with a control
proving it is not always-red.

### Sprint 5 — Clean-clone reproducibility

A fresh clone with no `/root` and no `/mnt/c/defiformal-work`, running
everything. Build the claim-page checker. Close Referee A's outstanding
bibliography item — three entries for roughly fifteen named theorems.

**Exit condition.** A stranger reproduces every headline figure from the
repository alone.

### Sprint 6 — Dress rehearsal

The full blinded council seated as an AFT program committee, returning
accept / major revision / reject with reasons.

**Exit condition.** No member returns reject on grounds that are fixable.

### On planning these

This document is the roadmap for six sprints; it is not an implementation plan
for all six. Only Sprint 1 can be planned in detail now, because Sprint 1's
branch point decides the contents of Sprints 2 and 4. Each sprint gets its own
plan, written when the sprint before it has exited. Planning Sprint 4 today
would be planning against figures a reframing may demote — the same mistake the
sprint ordering exists to avoid.

---

## 5. Council protocol

### Panel

Four attacking lanes and a decider, each on a different model so the diversity
is real rather than nominal.

| Lane | Attacks | CLI | Model |
|---|---|---|---|
| Empirical | corpus, measurements, statistics | `grok` | grok-4.6 |
| Formal | algebra, Lean, quint, soundness | `claude` | Opus |
| Significance | the "so what", novelty, related work | `codex` | GPT |
| Reproducer | re-runs the claims from the bundle alone, nothing else | `gemini` | Gemini |
| Decider | synthesises; contributes no findings | `claude` | Fable |

The Formal lane and the Decider share a CLI and differ only by model. That is a
weaker separation than the other three lanes have, and it is recorded rather
than hidden: if the two ever agree suspiciously often, the Formal lane moves to
`opencode` or `agy`, both of which foreman also drives.

### Rules carried from the twenty-one-round post-mortem

**The threat model goes in every brief.** Accidental drift and honest error —
not an adversary with write access. Unstated, attackers invent unfalsifiable
attacks and the round never converges. That was the root cause last time.

**Every finding names its falsifier** — the command or the passage that settles
it. A finding that cannot be checked is an opinion, and discovering that costs
a round.

**Reviewers do not define what blocks.** Each finding is classified as
**CONFIRMED** (reproduced against the artifact), **PLAUSIBLE** (argued, not
reproduced), or **REFUTED** (checked, false). Only CONFIRMED-severe gates a
sprint. Panel severity labels are input, not verdict.

### Round mechanics

Round 1 finds. CONFIRMED findings are fixed. Round 2 confirms the fixes and
hunts regressions. A third round is permitted only if Round 2 surfaced
genuinely new CONFIRMED-severe findings. After that the sprint stops and
reports what remains open.

**REFUTED findings are recorded on the claim page with the reason.** A panel
with no memory raises settled attacks every round; re-litigating them was a
measured cost of the previous loop.

---

## 6. Decisions required from Charles

**The merged graph.** `formal/v3/merged-fresh.sh` reports STALE and is correct.
The committed `expansion/graphify-out/merged-graph.json` was produced by a
graphify that did not namespace ids by lane — it holds `section_brief_kalshi`
where the installed 0.9.44 produces
`01-spot-exchange::section_brief_kalshi`. Node and link counts are identical
(777 / 684), no node changed, and 24 links differ by that renaming alone.
Regenerating rewrites 777 ids that other artefacts key on.

Either regenerate and repoint the consumers, or pin graphify to the producing
version. Weakening the check is not an option — it is currently the only thing
reporting the discrepancy.

This blocks Sprint 4's exit condition.

---

## 7. Out of scope

- **Foreman feature work.** Foreman is used as it stands. Its v0.3.1 session
  portability work is a separate track and this roadmap does not depend on it
  landing.
- **The remaining 43 files carrying dead `/root/` roots** outside the gate
  path. Sprint 4 fixes the eight negative-test harnesses because they gate the
  figures; the rest are not on the path to submission.
- **`polymarket.qnt`'s Apalache encoding failure.** The backend rejects a
  sequence length derived from a fold. That is a tool limitation, not a
  statement about the model, and no manuscript claim rests on it.
- **Promoting the thirteen timed-out models to verified.** They are recorded as
  timeouts and folded into no correctness claim.

---

## 8. Risks

**Sprint 1 reframes the paper and invalidates prepared work.** This is the
reason the rig sprints are late, and it is a managed risk rather than an
eliminated one. If Sprint 1 concludes the residue is the headline, the
composition harness matters less than the obligation ledger, and Sprint 4's
contents change accordingly.

**The council softens because it recognises the work.** Mitigated by blinding
and the identity-leak check, which the repository already performs and logs.
If a round's reports read as uniformly favourable, treat that as a blinding
failure to investigate, not as a result.

**A sprint hits the round cap without meeting its condition.** This is designed
behaviour, not failure. The sprint reports what is open and Charles triages.
The alternative — running until the reviewers stop objecting — has been
measured at twenty-one rounds.

**New measurements in Sprint 2 introduce new unvalidated gates.** Any figure
added under a new framing needs the same treatment as an old one: a reproducing
command on its claim page, and a gate with an observed failure. Sprint 4's exit
condition covers figures added in Sprint 2.
