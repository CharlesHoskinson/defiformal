---
title: Fix(Γ) is not a Moore family
status: PROVED
---

# Fix(Γ) is not a Moore family

**Status: PROVED**

`{Op,Tp}` and `{Ex,Op}` both satisfy the laws; `{Op}` does not (L1a open).
1,923 of 194,775 sampled pairs fail intersection-closure; 0 fail union-closure.

Root cause: **there is no closure operator for disjunctive requirements.** A term
with several alternatives determines no unique addition. Work with model classes.

Corrects an earlier framing. Related: [[R01-polarity]], [[R02-lattice]].
