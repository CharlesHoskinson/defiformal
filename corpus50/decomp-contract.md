# Decomposition contract — testing completeness and composability

You are measuring whether a 58-mechanism vocabulary can express real DeFi.
This is an **empirical test of the framework**, not a documentation exercise.
A finding that the vocabulary FAILS is more valuable than a forced fit.

## Method

1. **Rank by real data.** Use DefiLlama (or equivalent) for TVL/volume. Name
   your source and the date. Do not rank from memory.
2. **Decompose each protocol** into element symbols from `vocab.md`, in the
   order each part becomes necessary where you can determine it.
3. **Record residue** — anything the protocol does that no symbol names. Be
   specific: "no element for validator set management", not "some staking bits".
4. **Flag forced fits** — where you used a symbol that only approximately
   applies. These are as important as outright residue.

## Rules

- **Never invent a symbol.** If nothing fits, that is residue.
- **Candidates are usable** but mark them. Contested-register symbols may NOT
  be used without a note saying why.
- Prefer **fewer symbols honestly** over more symbols speculatively.
- If two protocols in a category decompose identically, say so — that is a
  finding about the vocabulary's resolution, not a mistake.

## Output — one JSON object, no prose, no fences

```
{
  "lane": "<your assigned categories>",
  "source": "<where the rankings came from, with date>",
  "categories": [
    {
      "category": "<name>",
      "why_a_category": "<what design question its members all answer>",
      "protocols": [
        { "name": "...", "rank_basis": "<TVL/volume figure and date>",
          "elements": ["Pl","Ix","Ct"],
          "order_known": true,
          "residue": ["<what the vocabulary could not express>"],
          "forced": [{"symbol":"X","why":"only approximately applies because ..."}] }
      ],
      "category_residue": "<what is missing across the whole category>",
      "identical_decompositions": [["A","B"]]
    }
  ],
  "completeness_verdict": "<what fraction of what you saw was expressible, and where it failed hardest>",
  "vocabulary_gaps": ["<named missing mechanisms, in priority order>"],
  "most_surprising": "<one sentence>"
}
```
