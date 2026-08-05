# Stage-3 findings: what the checker established

Machine-checked results, not lane opinions. Every figure here comes from
`node formal/v3/construct.mjs` over specs that `validate.mjs` accepted, and is
reproducible from `expansion/<slug>/verdicts.json`.

**Running total, 35 constructions across 7 categories:
712 obligations, 327 discharged, 385 residue — 45.9% coverage.
26 PARTIAL, 9 INADMISSIBLE, 0 COMPLETE.**

Not one application is fully expressible. The corpus reached that verdict by
lane self-assessment; this reaches it by counting obligations one at a time
against a checker, and lands in the same place.

---

## 1. The options rejections resolve, and they resolve two different ways

This was the open question the paper could not settle. The requirement tables
reject four of five options venues. Under a corrected decomposition:

**Two were decomposition artefacts and the rejection disappears.** Aevo's
collateral test is an order-gating engine and its auto-deleveraging has its own
documentation page; the corpus carried neither. Panoptic's collateral test is a
2,401-line audited risk engine, and the price source the corpus carried *none*
of is an on-chain time-weighted price — "oracle-free" meant no external feed,
not no price. Both are now PARTIAL.

**Two survive, and they are exactly the two that escrow maximum payoff at trade
time.** Rysk and Hegic close their threshold, liquidator and backstop
obligations **by construction**: the obligation cannot arise. The requirement
language admits only one way to discharge a term — name a satisfying element —
so it reads a closed obligation as an unspecified one. The rejection is correct
about the tables and wrong about the protocols.

**This is now evidenced obligation by obligation rather than argued**, and it is
a change to the constraint language rather than to the vocabulary.

## 2. `Vl` drops out of all five liquid-staking constructions

The corpus said one symbol stood for at least five separable mechanisms. Written
out as obligations, the position is worse than that: **the symbol is carried by
none of the five members of the category it supposedly defines.** Every
obligation it would discharge is residue, or does not arise.

| protocol | of the five sub-mechanisms |
|---|---|
| Lido | 5 of 5, **plus a sixth** the corpus did not name |
| ether.fi | 5 of 5, in five separate source files |
| EigenLayer | 4 of 5; front-running defence closed by construction |
| Babylon | 3 of 5; allocation and front-running closed by construction |
| WBETH | **0 of 5 — inapplicable, not approximate** |

A candidate element that no member of its own category carries is not a
candidate. It is a category label that was mistaken for a mechanism.

## 3. Discharge by construction is now a three-lane finding

It appeared first in options (maximum loss escrowed at trade time), and stage 3
found it independently in liquid staking twice: deposit front-running defence is
closed by construction in two protocols. Three sightings across two categories,
from different evidence, on a gap in the *language* rather than the vocabulary.

Of the four cross-lane convergences recorded at stage 1, this is the one the
checker has now independently corroborated.

## 4. Where the residue is, by category

Emitted by `node formal/v3/residue.mjs /root/defiformal/expansion`, not
transcribed by hand — an earlier draft of this table was written from memory and
four of its seven rows were wrong, which is the exact failure invariant 1 exists
to catch.

| lane | apps | obligations | covered | residue | coverage |
|---|---|---|---|---|---|
| 05-perpetuals | 5 | 115 | 68 | 47 | 59.1% |
| 04-liquid-staking | 5 | 108 | 60 | 48 | 55.6% |
| 06-yield-vaults | 5 | 103 | 52 | 51 | 50.5% |
| 10-options | 5 | 101 | 50 | 51 | 49.5% |
| 12-prediction | 5 | 98 | 43 | 55 | 43.9% |
| 07-bridges | 5 | 89 | 28 | 61 | 31.5% |
| 08-intents | 5 | 98 | 26 | 72 | 26.5% |
| **total** | **35** | **712** | **327** | **385** | **45.9%** |

Intents is the thinnest at 26.5% and bridges next at 31.5% — the two categories
whose members hold the most capital per element. That is the paper's
inverse-correlation claim, measured on obligations rather than asserted.

Perpetuals is the *highest* at 59.1%, which is worth stating against itself: the
vocabulary discharges more of that category's obligations than any other, and
all twenty-five of its trust-model obligations are still residue. A high
coverage figure and a blind spot on everything that distinguishes the members
are not in tension — they are the same fact about where the vocabulary looks.
