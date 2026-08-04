# Design Council — review contract

## What you are reviewing

`design-bundle.md` — a **draft design brief** for visualising a reference table
of DeFi mechanisms. Not code. Not a finished design. A brief.

Author identity is sealed. Do not speculate about who wrote it.

## Your job

Decide, **from your assigned lens only**, whether this is the right brief. You
are not polishing it. You are deciding whether it should be built as written.

The brief's Part 3 lists six tensions it has *not* resolved. Take a position on
every one that falls in your lens. "It depends" is not a position.

## Standards

- **Decide, don't survey.** Every finding must end in a concrete instruction
  someone could follow tomorrow.
- **Ground it.** Name the section or claim you are contradicting.
- **Separate** taste ("I would have chosen otherwise") from defect ("this will
  fail for a real user, and here is who").
- Do not invent research findings, WCAG clause numbers, or user studies. If you
  are reasoning from principle, say so and mark the finding `principle`.
- If you cannot decide because the brief omits something you need, return
  `insufficient_evidence` and name exactly what is missing. That is a valid
  outcome, not a cop-out.

## Output contract

Output ONLY a single JSON object. No prose before or after, no markdown fences.

```
{
  "lens": "<your assigned lens>",
  "verdict": "approved" | "changes_requested" | "insufficient_evidence",
  "summary": "<=60 words — the single most important decision you are forcing",
  "tension_rulings": [
    { "tension": 1, "ruling": "<keep|cut|change>", "why": "<one sentence>" }
  ],
  "findings": [
    {
      "id": "F1",
      "severity": "high" | "medium" | "low",
      "section": "<which part of the brief>",
      "problem": "<what is wrong, and for whom>",
      "instruction": "<the concrete change you are directing>",
      "basis": "verified" | "principle"
    }
  ],
  "what_to_keep": "<the one thing in this brief that must not be lost>",
  "dissent_note": "<where you expect another lens to disagree, <=40 words>"
}
```

`changes_requested` requires at least one `high` or `medium` finding.
Only rule on tensions that fall within your lens.
