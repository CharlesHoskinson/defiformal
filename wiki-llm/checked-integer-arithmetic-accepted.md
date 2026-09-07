# Checked integer arithmetic

Accepted source ddf1ac0e50f2e032385664a0965bab59eef91ea3 adds arbitrary-width checked
words, exact floor/ceiling division, separate fee policies, dimensioned scale
conversion and actual Typed fee-transfer proofs. Grok4.6-build and Fable5.1 medium
accepted the identical bundle with limitations. All22 tasks are complete; branch
archive delivery6d73e6dcf7b99c2b6cd1114985562a9f4081f4c4 is verified.

The important semantic boundary is aggregate net effects. Coincident payer,
recipient and collector cells combine before debit authority and funding checks.
A zero net transfer may succeed without gross funding; this matches the kernel
and is not sequential token-debit fidelity. Scale positivity is an explicit
valid-use premise, not a runtime guard in the raw reference template constructor.

Generic theorems,45 runtime fixtures,12 compiling mutants,65 runner controls,
asset compiler checks and27,968 finite oracle comparisons have separate records.
Native review is advisory and the checker is artifact consistency, not execution
attestation. Actual earlier revisions remain named. Exact evidence and limits:
review/semantic-kernel/integer-arithmetic/{EVIDENCE,ADJUDICATION}.md.

Historical claim tooling and the finite-participant composition plan are the next
active work. Protocol-specific arithmetic, claims/asynchronous lifecycles, real
certificate checking and deployed correspondence remain on roadmap.md.
