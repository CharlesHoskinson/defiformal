# Working instructions

The user approved the semantic-kernel pivot on 2026-09-06. Read
`docs/superpowers/specs/2026-09-06-semantic-kernel-design.md` and
`docs/research/semantic-kernel-progress.md` before continuing work.

- The new migration supersedes the old publication-first runstate and the
  positive-program primitive-basis mandate. Historical documents remain
  evidence, not instructions to pursue a withdrawn objective.
- Use GPT-6 for implementation through the stock Codex harness. Have Grok and
  Fable independently check substantive results. Invoke their native CLIs
  directly from Codex. Do not use Foreman. Never substitute a GPT reviewer and
  label its response Grok or Fable.
- Record the exact reviewed revision, requested/reported model identity,
  result, findings, and fixes. An unavailable reviewer is an open review, not
  an approval. Review is advisory evidence, not a mathematical proof.
- Preserve existing proofs and negative results. Put new kernel work in a
  separate namespace. Do not change a historical theorem statement to make a
  new claim pass.
- Read `.claude/skills/defi-footguns/SKILL.md` and
  `formal/v3/GATE-REGISTER.md` when editing or reporting verification behavior.
  Empty checks are blocked. Keep proof, bounded execution, measurement and
  unchecked assumptions distinct, with exact input and tool identities.
- Lean is the mathematical authority. Any executable IR or Quint abstraction
  needs explicit correspondence. No `sorry`, custom axioms or `native_decide`
  in accepted kernel proofs.
- Preserve the original corpus and versioned source evidence. Do not silently
  relabel development examples as untouched holdouts.
- User authorization to execute this migration is already present. Resolve
  routine implementation details without repeatedly requesting approval.

## Reviewer change, 2026-09-07

The user explicitly replaced Fable with Opus for future external reviews. Use
native Grok plus native Claude Opus for substantive implementation/evidence
reviews, and nonauthor GPT-6 plus native Opus for new OpenSpec planning gates.
Request the native `opus` model alias and record the actual returned model.
Existing Fable reports and accepted historical plan bytes retain their original
identity. References to future Fable reviews in older plans are superseded by
this instruction; freeze updated reviewer bindings before new review execution.
GPT-6 implementation, stock Codex harness, and the no-Foreman rule remain in force.

## Latest reviewer change, 2026-09-07

The user subsequently instructed: "fable is back online use 5.1 medium effort".
This supersedes the earlier Opus selection for upcoming reviews. Use nonauthor
GPT-6 plus native Fable 5.1 for new planning gates, and native Grok plus Fable 5.1
for substantive implementation and evidence reviews. Invoke Claude with model
`claude-fable-5-1[1m]` and `--effort medium`, recording the actual returned model.
Preserve completed Opus and historical Fable reports with their original
identities; they are not relabelled as new Fable reviews. GPT-6 stock-harness
implementation, no Foreman, and existing execution authorization remain unchanged.
