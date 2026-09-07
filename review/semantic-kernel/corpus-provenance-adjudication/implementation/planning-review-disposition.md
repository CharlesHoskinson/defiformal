# Corpus execution refinements

Both official-r2 planning reviews accepted with limitations. Original frozen
normative text and reports remain unchanged. These refinements implement Fable's
nine findings and remain obligations for final acceptance.

1. Every established applicability decision references retained evidence covering
   the 2026-08-04 snapshot and a closed basis: archived_snapshot, dated_release,
   contemporaneous_publication, or pinned_code_with_dated_deployment. Version-
   unspecified units require the same basis. A checker validates record/date/
   locator bindings; factual adequacy still needs independent source review.
2. Across historical scopes, more than one effective established decision for
   a unit/facet/label conflicts, even if dispositions agree. Resolution requires
   explicit reviewed supersession/reconciliation; no ordering winner.
3. Accepted decisions identify their author and an independent accepting reviewer
   with actual report/source digests. Self-acceptance by the authoring model is
   rejected. Native package review cannot silently substitute for per-decision
   source review. Imported packets remain draft/review_pending.
4. R-appchain interpretation coverage does not alter ApeX/edgeX agreed facets.
   Changes to those facets require separately queued challenges and an explicit
   inventory extension; they do not become a thirtieth original disagreement.
5. Eligible citation-occurrence and attachment items use the same three-target,
   two-attempt/five-redirect bounds per item per pass. Group reuse retains actual
   request identity and does not multiply factual support.
6. Keep the strict offline contract. User/network namespaces are available here;
   no non-offline fallback mode is added. Deny network families AF_INET/AF_INET6/
   AF_PACKET/AF_NETLINK and inherited network descriptors. AF_UNIX may be denied
   as well when the positive file/build/check probes demonstrate compatibility;
   a narrower allow rule needs an explicit absence-of-egress argument. Use the
   namespace as primary isolation, inherited seccomp denial for descendants,
   close inherited nonstandard descriptors and record actual probes. Missing
   enforcement remains exit3. Root's user+network namespace and bwrap probes
   succeeded; ordinary unshare --net returnedEPERM. These are feasibility facts,
   not an implemented seccomp pass.
7. Intermediate production queues may correctly exit3 incomplete_work_queue.
   The final complete-work run targets exit0 only after every declared item has
   a terminal disposition with supporting references. Reviewed-unresolved stays
   factually unresolved; no forced fact acceptance to obtain exit0.
8. Exposure must include all entities named in cited evidence spans, plus any
   other substantive entities actually inspected during design or source review.
   Do not infer untouched status from absence in a citation. Every source/body
   is bounded; original source-level exposure remains preserved.
9. New malformed JSON paths use exit3. Do not reuse the historical normalizer's
   malformed-input exit1 unchanged; preserve the old command's behavior.

These are record/validation refinements, not accepted source facts. The native
final review must inspect their concrete fixtures, source and measurements.
