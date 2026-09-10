# P19 compiler boundary preparation

The frozen R5 public driver can report an audit pass from supplied counts and strings. Its fixture runner also performs a real global Verify audit, but that execution is separate from the pure checkAudit result. The next author repair must connect the public audit decision to actual matching compiler evidence. This preparation supplies one real empty-scope control; it does not complete that repair or accept F46.

`EmptyCertificatesScope.lean` imports DefiKernel.AxiomAudit alone and requests the Certificates declaring-module prefix. The pinned Lean compiler reports modules=[] and blocks with theorems=0. See empty-scope-receipt.json for source, command, compiler and output identities. The first attempt failed because the private cache lacked AxiomAudit.olean; that setup failure is retained separately. After building the unchanged audit module, the intended empty-scope observation was obtained.

The full candidate Verify environment has different imports and nonempty scopes. Never reuse this negative control as its inventory. AxiomAudit discovers elaborated theorem constants by declaring-module provenance; it excludes declarations in the current module. Verify is the wrapper that executes the commands. Its presence does not imply that Verify itself declares an imported theorem.

The upcoming repair has these concrete obligations:

1. Keep certificate decoding and pure execution independent of host compiler IO. Audit envelope counts, command text, roots and record-shaped JSON are requests or claims, not evidence of an executed audit.
2. Add an explicit public host path that obtains and validates the actual compiler record for the frozen candidate. Bind exact source/dependency identities, resolved pinned compiler, command/import wrapper, exit and output records, requested scopes and nonempty elaborated inventories. Existing matching evidence can be reused; no cryptographic signing or per-certificate recompilation is required.
3. Make every public audit success path require that validated evidence. A fixture-only check after the public driver has already returned an unauthenticated pass does not repair the driver. Preserve the pure API's classification role without advertising an untrusted classification as proof discharge.
4. F44 uses the real three-scope candidate audit and rejects missing or mismatched candidate/compiler/scope records. F45 compares the forbidden claims with the candidate's actual declared covered roots. F46 uses an explicitly separate empty-import wrapper such as this one; its supplied zero count cannot select a fabricated result.
5. Preserve codec/audit/Report result distinctions, source-identity error precedence and the ban on ambient registry/environment/config values. Host compiler records are explicit evidence inputs, not a new ambient execution registry. Record any required API/result amendment separately from frozen planning bytes.
6. Exercise the complete host path with a valid positive, missing/mismatched/stale evidence, compiler failure, actual empty scope and substituted declared roots. Parser-only controls remain useful but cannot replace these host controls. Keep later library/source-refinement discharge separate; an audit pass alone cannot establish theorem instantiation or deployed fidelity.

The exact design and implementation belong to the native AGY author after the active parser proof batch. Fresh Grok must review the repaired candidate. This note makes the existing boundary repair reviewable without modifying production source or broadening the accepted grammar.
