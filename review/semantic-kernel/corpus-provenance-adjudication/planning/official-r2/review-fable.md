VERDICT: ACCEPT WITH LIMITATIONS

The r2 revision resolves the three blocking official-r1 findings with concrete normative text, closed enums, named scenarios and named controls. The eleven lesser findings each have a design location, a scenario and a task. I found no remaining case where the plan would let an implementation emit accepted output with undefined meaning. The findings below are amendments an implementer can absorb without a further planning freeze, provided the acceptance reviewer holds them.

**Blockers**

None.

**Lesser findings**

- **Established applicability has no mechanical basis field.** Decision 5 defines `established` by reviewer judgment only. A checker cannot distinguish it from `current_documentation_only` except by reading the enum. Require each established decision to cite an evidence record whose declared scope covers the 2026-08-04 snapshot, with a closed basis enum such as archived snapshot, dated release, contemporaneous publication, or pinned code plus dated deployment evidence. The "explicitly version-unspecified scope" clause is the likely escape hatch and should require the same basis.
- **Label-level uniqueness across historical scopes is undefined.** Keys include `scope_id`, so two accepted established heads for one unit/facet/label under different historical scopes are each unique in their key but not unique for the label. State that the historical view treats that case as conflicting until reconciled, consistent with the same-key rule that agreeing heads still conflict.
- **Accepting authority is unnamed.** Decision 5 says decisions stay draft until "independently reviewed" but never says who may set `accepted` or that the drafting agent may not. Since acceptance is what alters the historical facet, require reviewer identity fields on every accepted record and prohibit self-acceptance by the authoring model. CHK-09 covers final package review, not per-decision acceptance.
- **R-appchain review coverage touches agreed facets.** ApeX and edgeX have no appchain dispute; their execution facets are agreed without appchain. A ruling on R-appchain cannot change those facets without a separately queued challenge record like the Liquity one, and the queue is fixed at 29 plus one. Say so explicitly, or the "review coverage" wording invites a silent thirtieth item.
- **Budget for non-candidate queue items is undefined.** The three-target rule is per original candidate. Eligible citation-occurrence and attachment items have no stated target budget. Apply the same per-item rule or state one.
- **Offline wrapper scope is coarse and its unavailability blocks everything.** Denying all `socket` calls also denies AF_UNIX, which can break name-service lookups. Specify the denied address families and keep the network namespace as the primary control. Separately, if namespace or seccomp support is absent on the host, build and check exit 3 and no deterministic outputs exist at all. Consider a clearly labelled non-offline mode that records `offline_isolation: not_enforced` so determinism evidence is obtainable while the no-network claim stays unmade. That is not the assertion-only fallback r1 rejected.
- **Complete-work exit zero is unreachable until every item is terminal.** This is intentional, but the implementer should plan for check exiting 3 on production inputs for most of the sprint. Task 7.4 should say which production run is expected to reach exit 0 and which are expected to report `incomplete_work_queue`.
- **"Substantively described" needs a floor.** EV-07 asks the manifest to list every publisher and product a retained source describes. Bound it to entities named inside cited evidence spans, otherwise a long page makes the obligation unbounded and the control unfalsifiable.
- **Old parser exit semantics.** The existing normalization script returns exit 1 on malformed JSON. Decision 7 requires exit 3. The new path must not reuse that helper unchanged. This repeats the r1 GPT-6 note and the design does not mention it.

**Scope limits**

- This is a static review of the frozen normative text, five specs, tasks, rule payload, control inventory, dispute inventory, prior r1 reports and the author resolution map. I ran no command. Author static checks were inspected as evidence, not reproduced.
- I verified by reading that the 29 facet records, 32 label instances, 24 units, 17 labels, adjudication pointer 77, 11 version labels, 65 scenarios, 20 requirements and 116 control cases reconcile to the supplied corpus bytes and specs.
- The r2 freeze manifest binding these bytes to candidate b4705b0 was not among my inputs; the in-change manifests observe b165bc5. I take the stated frozen candidate as given.
- I adjudicated no facet, packet reading or the Liquity challenge. Raw captures and batch logs were not supplied. Nothing here establishes deployment identity, model fidelity, recovery of the original attachments, or any untouched evaluation case.
- Reported reviewer model: claude-fable-5-1.
