# What this is actually for

> **Note.** Identity claims between protocol decompositions are false against the arrays in corpus50/lanes. Of 10 claimed identical groups only 3 hold: USDT/USD1, LiquidMesh/KyberSwap, Binance Wallet/OKX DEX. Use containment (80 strict pairs, computed by viz/scripts/check-collisions.py) rather than identity.


No mathematics in this file. If anything below stops being true of the model,
this file is wrong and must be fixed — it is maintained alongside `MODEL.md` and
`LEDGER.md`, not written once.

---

## The idea in one paragraph

DeFi protocols are not each invented from nothing. They are assembled from a
few dozen recurring parts — a pool that prices trades, a test that decides when
you're undercollateralised, a feed that says what things are worth, a queue for
withdrawals. We catalogued 58 of these parts, and then catalogued the rules
about which parts need which other parts. The question was whether that adds up
to a **grammar**: something that can tell you, of a combination you have not
seen before, whether it is buildable.

It does. But the rule book turned out to be half-written, and finding the
missing half is the useful result.

## The missing half

Every rule we had written said what a part **needs**. A liquidation mechanism
needs a collateral test. A synthetic asset needs a price source.

Nothing anywhere said what a part is **for**.

Computing the second half — what each part *serves* — makes the model roughly
**1.8 times sharper** at telling real protocols from broken ones.

*(An earlier version of this file said four times. That was wrong, and the
correction came from re-implementing the measurement independently. The bigger
headline number in our notes turned out to come mostly from two other checks
entirely, not from adding purpose. Purpose still helps, and it is still the
most interesting thing missing — it just is not doing most of the work.)*

**Why the second half is the valuable one.** The first half answers a question
designers already ask: *what am I missing?* The second half answers one nobody
was asking: **what am I carrying that nothing justifies?**

A mechanism sitting in a protocol with nothing to serve is not neutral. It is
surface that can be attacked, code that can break, and authority someone holds,
with no compensating function. It is the signature of a system that accumulated
features rather than being designed. Before this, the atlas had no way to say
that, because it had no vocabulary for purpose.

## Three things the model tells you that are worth knowing

**You cannot tell USDT from USD1 by looking at what they're made of.** Same
parts, same structure — very different credit. This is not a gap in our
cataloguing that better work would close. It is a result: *what backs a
stablecoin is not among its mechanisms.* If you want to distinguish them you
must add who the obligor is, who attests, and under what jurisdiction. That
tells you exactly where to point your due diligence: not at the contract.

**What killed Terra is invisible at this level of description.** Terra died of a
loop — the token backing the stablecoin was itself priced by demand for the
stablecoin. Describe both protocols as lists of parts and that loop cannot be
seen at all; we proved it cannot. You only see it when you track *which asset*
each part refers to. Same parts, wired to different assets, is the difference
between a working protocol and a collapse. Reassuringly, when we added asset
tracking, Terra shows the loop and a comparable live protocol does not.

**Those two problems are the same problem.** Both are things destroyed by the
act of flattening a protocol into a list of parts. That is a tidy result: fix
the flattening and you fix both.

## What it means for composability

The promise of DeFi is that pieces snap together. The honest finding is that
**you cannot, in general, check two protocols separately and conclude the
combination is safe.** We proved that with explicit counterexamples. Combining
two individually sound protocols can produce an unsound one, and no summary of
the parts is enough to predict it.

That sounds like bad news and is actually the most actionable thing here,
because it is not uniformly true. There is a well-behaved core where separate
checking *does* work, and a boundary where it stops. **Finding exactly where
that boundary sits is the main open problem**, and it is worth solving: it
would tell an integrator which combinations need a full audit and which do not.

We also know *why* it breaks, which is unusual. Rules of the form "this needs
that" and rules of the form "these two must never appear together" pull in
opposite directions mathematically. A system with only the first kind is
well-behaved. A system with only the second kind is well-behaved. Ours has both,
and that mixture is provably not well-behaved — which is a fact about the shape
of the rules, not about DeFi being messy.

## What we found out about the catalogue itself

Measuring 72 real protocols against the vocabulary was unkind to it, and that
was the point:

- **It describes on-chain machinery well and everything else badly.** Coverage
  falls the more of a protocol lives off-chain — and the biggest things in DeFi
  are the most off-chain. USDT, the largest asset in the set, reduces to five
  parts, three of them forced.
- **Its detail is in the wrong places.** Five separate parts distinguish
  variants of the same pool formula; one part covers every option ever written.
  It is fine-grained where lots of people wrote code, and coarse where the
  hardest finance is.
- **The biggest bridges are indistinguishable from each other**, and the
  description contains no notion of verification at all — because there isn't
  any. A company holds the asset.
- **A fast-growing business has no name in it.** Curators — firms that allocate
  other people's deposits for a fee — hold billions and there is no part for
  them, because they are not a mechanism. They are a person with discretion.

## The mistake worth admitting

For a long time the model said three live, working protocols were invalid, and
we treated that as an interesting finding about DeFi.

It was a bug in our own parser. A rule saying "you need a timelock **or** a
bounded emergency process" was being read as "you need a timelock." Five rules
were affected. Once fixed, those three protocols are fine, and the only things
that fail are the two that actually collapsed.

Two of the nine independent reviewers found it. It is in the record because the
lesson generalises: we had also said "two independent implementations agree,"
which sounded like verification and wasn't — both were built from the same
wrong specification.

## What you'd use it for

- **Designing:** what am I missing, and what am I carrying that I can't justify?
- **Reviewing:** which of these parts has no purpose here?
- **Integrating:** is this combination in the region where checking separately
  is valid?
- **Due diligence:** the model states plainly what it cannot see — obligor,
  custody, legal recourse, who decides. That is a map of where the contract
  stops answering and you have to go look at the paperwork.
