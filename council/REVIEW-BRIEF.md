# Council Review Brief — Profile 1 (advisory, blinded)

## What you are reviewing

`/root/DefiElements/council/BUNDLE-blinded.md` — v0.1 of a unified "periodic
table" of DeFi mechanisms. It reconciles four independent prior reports
(SOURCE-A, SOURCE-B, SOURCE-C, SOURCE-D). Author identity is sealed; do not
speculate about who wrote it or which system produced which source.

Read the whole bundle before writing anything.

## Your job

Review it **through your assigned lens only** (given separately). Do not write a
general summary. Do not restate the document back. Find what is **wrong,
unsound, unusable, or missing** from your perspective, and say what would fix it.

## Standards

- **Be adversarial.** Your value is dissent, not agreement. A review with no
  findings must justify why.
- **Ground every finding.** Point to a specific section or claim. A finding
  that cannot name what it contradicts is not admissible.
- **Distinguish** a modelling convention you would have chosen differently
  (low severity) from a claim that is actually false or a rule that would fail
  in production (high severity).
- **Do not invent incidents, dollar figures or citations.** If you do not know,
  say so and mark the finding `unverified`.
- If you cannot review because evidence is missing, return
  `insufficient_evidence` and say exactly what is missing. That is a valid,
  respected outcome — it is not an approval and not a rejection.

## Output contract

Output ONLY a single JSON object, no prose before or after, no markdown fences:

```
{
  "lens": "<your assigned lens name>",
  "verdict": "approved" | "changes_requested" | "insufficient_evidence",
  "summary": "<=60 words, the single most important thing you found",
  "findings": [
    {
      "id": "F1",
      "severity": "high" | "medium" | "low",
      "section": "<section number or heading in the bundle>",
      "claim": "<what the bundle says>",
      "problem": "<why it is wrong, unsound or unusable - be specific>",
      "fix": "<the concrete change you want>",
      "status": "verified" | "unverified"
    }
  ],
  "strongest_thing_in_the_document": "<one sentence>",
  "dissent_note": "<if you expect other lenses to disagree with you, say why - <=40 words>"
}
```

`changes_requested` requires at least one `high` or `medium` finding.
