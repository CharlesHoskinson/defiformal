# Resume Sprint 6 after required Fable planning review

Planning candidate: `c0f6f0bcc19ab30e0146a2e1e8ff209f8ce8c1a7`.
Authoritative candidate files/hash manifest: `r2-candidate.json`.
Review input: `r2-bundle.md`, SHA-256
`73f4ff8c70b85e8468e33f4c63d784b37c8543c1ed068341ed120607d19942fa`.
GPT-6: ACCEPT in `r2-gpt6.md`. Fable: no verdict; provider credits exhausted on R1
and on both R2 retries (`claude-fable-5-1` and configured `claude-fable-5-1[1m]`).
No new implementation has begun. All 48 execution tasks are saved; only planning
freeze/validation task 1.1 is checked. Source and existing proof/corpus bytes are
unchanged. The source-context manifest is checked against actual Git objects.

After Fable credits/access are restored, use its native CLI through the existing
stock-harness review driver from `/home/charl/defiformal`:

```sh
python3 review/semantic-kernel/sprint4/native-review.py fable review/semantic-kernel/sprint6/planning/r2-bundle.md review/semantic-kernel/sprint6/planning/r2-fable-retry2.json
```

Use a new attempt basename if an output already exists; preserve failures. Record
requested/reported model identities, native response, exit and hashes. An error,
unavailable response, timeout, or malformed verdict is not a pass. Do not substitute
another provider or label a GPT response Fable. Native review is advisory planning
analysis, not mathematical proof.

Inspect any blocking finding and revise the OpenSpec candidate as necessary. Both
reviewers' final verdicts must cover the same final candidate. If Fable accepts
this unchanged candidate without unresolved blockers, update planning adjudication,
gate state and tasks 1.2/1.3, then execute the already authorized sprint from task
1.4 onward. Do not ask for execution permission again. Do not waive any SHALL in
order to turn a limited verdict into approval.

Implementation uses GPT-6 and the stock Codex harness; no Foreman. Follow
`AGENTS.md`, the approved migration design, progress ledger and these OpenSpec
tasks. Final substantive implementation results still require native Grok/Fable
review, complete Lean/runtime/mutation/regression evidence, verified branch push,
and OpenSpec archive. No merge to main or deployment is authorized by this record.
