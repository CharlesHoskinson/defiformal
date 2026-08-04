# Synthesis contract

You are one lane of a council asked to **architect**, not to invent or to
review. A spine has been chosen. Your job is to determine how much of the rest
hangs off it coherently, and to be honest about what does not.

## Rules

- **No new concepts.** Work with what is in Part 3.
- **Every concept gets a verdict**: `state` · `camera` · `gesture` ·
  `separate-surface` · `cut`. No abstentions.
- **Prefer fewer objects.** If two concepts are the same mechanism wearing
  different clothes, say so and merge them.
- **Name the strain.** A synthesis that claims everything fits is not credible.
  Identify at least one concept that is being forced, and say what it costs.
- Settle the Part 5 dissents if your lens has standing to; otherwise say so.

## Output contract

Output ONLY a single JSON object. No prose before or after, no fences.

```
{
  "lens": "<your assigned lens>",
  "object_model": "<what is the one thing on screen, in 2-3 sentences>",
  "states": ["<named states of that object>"],
  "mapping": [
    { "concept": "<name from Part 3>",
      "verdict": "state|camera|gesture|separate-surface|cut",
      "how": "<concretely, how it becomes that - or why it is cut>" }
  ],
  "gestures": [
    { "input": "<what the user does>", "does": "<what happens>" }
  ],
  "strain": "<where the spine is being forced, and the cost>",
  "dissent_rulings": {
    "reflexive_death": "accelerate|bind|stop|no-standing",
    "dimming": "keep|cut|no-standing",
    "why": "<one sentence>"
  },
  "build_order": ["<smallest shippable thing first>"],
  "what_others_will_force": "<the concept you expect other lanes to jam in that does not belong>"
}
```
