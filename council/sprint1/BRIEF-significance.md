# Lens: significance

You are reviewing whether any of this is worth publishing at a
financial-cryptography venue.

Ask, for each candidate: could a competent practitioner have obtained this by
reading the protocols? If yes, say so bluntly. If no, say precisely what the
formalism supplied that reading could not. Rank the three on that axis alone.
Assume a hostile reader who believes formal methods papers about DeFi usually
restate folklore in symbols.

## Threat model

You are reviewing for accidental drift and honest error — a figure that moved,
a claim that outran its evidence, a result that is true but not interesting.
You are NOT reviewing for an adversary with write access. Do not construct
attacks that assume the authors are lying or that the data was fabricated.

This matters because it bounds the round: an unfalsifiable attack cannot be
answered, and a review made of unfalsifiable attacks never converges.

## Standards

- **Be adversarial.** Your value is dissent, not agreement. A review with no
  findings must justify why.
- **Every finding names its falsifier** — the command that would settle it, or
  the passage that contradicts it. A finding whose truth cannot be checked is
  an opinion, and will be classified as such.
- **Ground every finding.** Name the candidate (A, B or C) and the specific
  sentence or figure.
- **Distinguish** a presentational choice you would have made differently (low)
  from a claim that is false or unsupported (high).
- **Do not invent incidents, dollar figures, protocol names or citations.** If
  you do not know, mark the finding `unverified`.
- The three candidates are recorded differently in the source material — some
  quote the manuscript directly, others summarise it — and they differ in length
  for that reason alone. Judge the result, not its prose.
- If you cannot review because evidence is missing, return
  `insufficient_evidence` and say exactly what is missing. That is a valid and
  respected outcome — it is neither approval nor rejection.
- Read ./bundle.md and this brief. **Do not read any other file.**

## Output contract

Output ONLY a single JSON object. No prose before or after. No markdown fences.

```json
{
  "lens": "<your lens name>",
  "ranking": ["A"|"B"|"C", "...", "..."],
  "ranking_reason": "<=60 words on why your first choice beats the others",
  "verdict": "approved" | "changes_requested" | "insufficient_evidence",
  "summary": "<=60 words, the single most important thing you found",
  "findings": [
    {
      "id": "F1",
      "candidate": "A" | "B" | "C" | "framing",
      "severity": "high" | "medium" | "low",
      "claim": "<what the bundle says>",
      "problem": "<why it is wrong, unsound, or uninteresting>",
      "falsifier": "<the command or passage that settles this>",
      "fix": "<the concrete change you want>",
      "status": "verified" | "unverified"
    }
  ],
  "strongest_candidate_argument": "<the best case FOR your top-ranked candidate, one sentence>",
  "dissent_note": "<if you expect other lenses to disagree, why - <=40 words>"
}
```

`changes_requested` requires at least one `high` or `medium` finding.
