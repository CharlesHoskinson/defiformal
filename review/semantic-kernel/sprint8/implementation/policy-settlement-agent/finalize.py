import hashlib,json,pathlib,re
out=pathlib.Path(__file__).resolve().parent;root=out.parents[5]
meta=json.loads((out/'checks.json').read_text()); log=(out/'audit.stdout').read_text()
records=[{'class':kind,'name':name,'module':mod,'axioms':re.findall(r'[^,\s]+',ax)} for kind,name,mod,ax in re.findall(r'AXIOM AUDIT (theorem|declaration): (.*?); module=(.*?); (?:kind=.*?; )?axioms=\[(.*?)\]',log,re.S)]
standard={'propext','Classical.choice','Quot.sound'}
assert all(set(r['axioms'])<=standard for r in records)
assert sum(r['class']=='theorem' for r in records)==265
assert sum(r['class']=='declaration' for r in records)==232
modules=['DefiKernel.Atomic.'+n for n in ['Policy','PolicyProofs','Settlement','Correspondence']]
counts={m:{c:sum(r['class']==c and r['module']==m for r in records) for c in ['theorem','declaration']} for m in modules}
assert meta['all_commands_passed'] and meta['owned_bytes_unchanged']
lsp=json.loads((out/'lsp-final.json').read_text());assert all(x['result']['result']['success'] and not x['result']['result']['items'] for x in lsp)
for n in ['Policy','PolicyProofs','Settlement','Correspondence']:
 j=json.loads((out/('plugin-sorry-'+n+'.stdout')).read_text());assert j['total_count']==0 and j['files_failed']==0 and j['files_scanned']==1
summary={'status':'PASS','owned_source_before_after_equal':True,'commands_passed':len(meta['commands']),'lsp_clean_modules':4,'explicit_source_theorems':45,'explicit_private_helpers':2,'imported_axiom_theorems':265,'imported_axiom_supplemental':232,'forbidden_axioms':0,'owned_module_audit_counts':counts,'records':records}
(out/'verification.json').write_text(json.dumps(summary,indent=2)+'\n')
report='''Implemented the agreed Policy runtime and generic settlement/correspondence proofs in four new Atomic modules. Status: PASS for this bounded implementation and its proof checks. Parent integration, financial fixtures, production mutations and native independent audit remain separate gates.

Policy checks lane uniqueness by domain/asset even when vaults differ, participant uniqueness, and every static boundary principal in left-then-right order. Duplicate diagnostics retain both indices and lane values. Receipt effects sum all evaluated deltas at the exact lane cell. Signed updates affect only configured lanes and the authenticated principal. Residuals retain complete typed lane/principal/value keys in declared lane-major order. Supply checks return the first configured lane with nonzero whole-asset receipt supply.

The 45 explicit source theorems (including two private helpers) establish acceptance iff complete uniqueness/coverage; canonical residual membership, key uniqueness and pointwise clearance; peer, unconfigured-lane and zero-effect update stability; complete participant-sum change; actual accepted receipt/cell correspondence; maintained debt equals an independent fold of actual attempts; and cash plus signed obligations equals entry cash for every reachable prefix, including the successful receipt that causes policy abort. Cleared and committed vault restoration are explicit corollaries.

The converse and bidirectional correspondence criterion use the actual Interleaving attempt list, successful actual outcomes, zero actual per-receipt lane supply, and clearance of the independent attempt fold. They do not premise an Atomic result, absence of Atomic abort, or the desired machine/table equality. Those facts are derived. The successful forward direction also proves every actual attempt passed supply policy.

Verification ran with pinned Lean 4.33.0-rc2, commit d8b18978322de05a8f3dba51ef03cf5461676c17, from the lean/ working directory. All eight recorded commands passed: pinned version, literal installed Lean4 plugin prove parser, targeted four-module build (942 jobs), automatic imported Atomic axiom audit, and literal installed plugin sorry analyzer for each owned file. The automatic audit checked 265/265 theorem and 232/232 supplemental declarations across the eight imported Atomic modules; all axiom lists were empty or contained only propext, Classical.choice and Quot.sound. All four final LSP results have no errors or warnings. Replayed pre-existing Typed.Transition linter messages occurred in the build; owned modules are clean. Full stdout/stderr, exact commands, UTC timing, executable hashes and per-file source/Git-blob hashes are saved beside this report.

The final recorded run was 2026-09-07 08:30:31–08:30:36 UTC at workspace HEAD 80c56c48a322316b75b3928904526932d8d5be2c. The four new source files were untracked during the run; this is a working-source check, not a claim that HEAD contains them. Their bytes were identical before/after. No historical source, root imports, tasks or commits were edited by this agent. Runtime declarations precede proof markers; outstandingFromAttempts and its updater precede the Settlement marker, and GoodAttempts is a proposition before the Correspondence marker.

Initial missing-feature observation: the Atomic directory initially contained Execution.lean only, and the Policy import target did not exist. No preimplementation failing financial assertion was run. During the first runtime check, an erroneous `lake -d lean build DefiKernel.Atomic.Policy` from the repository root selected default Lean 4.33.1. It was terminated; parent quarantined four incompatible dependency cache modules and rebuilt them with pinned rc2, without source edits. Subsequent recorded checks use only the pinned executable. This failed setup attempt is not counted as financial detection or a successful verification.

Limits: these are kernel-checked generic semantic proofs over the existing trusted kernel/configuration/boundary APIs and rational model. They do not establish deployed EVM fidelity, arbitrary shared-state commutation, or external economic assumptions. This agent did not run production mutations, financial runtime suites, or provider audits and claims no detection credit for the proof build. The implementation used the requested GPT-6 stock harness and installed Lean4 plugin runtime without Foreman; independent model/build telemetry was not exposed. The report is an author implementation report, not an independent non-author audit.
'''
(out/'REPORT.md').write_text(report)
manifest=[{'path':p.name,'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in sorted(out.iterdir()) if p.is_file() and p.name!='artifact-manifest.json']
(out/'artifact-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps({k:v for k,v in summary.items() if k!='records'},indent=2))
