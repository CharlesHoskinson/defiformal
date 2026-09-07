import DefiKernel.Typed.Authority

namespace DefiKernel.Typed
namespace AuthorityTests

abbrev P := Fin 3
abbrev A := Fin 2
abbrev D := Fin 2

def config : AuthorityConfig P D :=
  ⟨fun d ↦ if d = 0 then 0 else 2,
   fun op ↦ if op = ⟨0⟩ ∨ op = ⟨2⟩ then some 0 else if op = ⟨1⟩ then some 1 else none⟩

def admin : InvocationContext P D := ⟨0, 0⟩
def holder : InvocationContext P D := ⟨1, 0⟩
def foreignAdmin : InvocationContext P D := ⟨2, 1⟩
def empty : CapabilityStore P A D := .empty

def grant (right : Right P A D := .invoke) : Grant P A D := ⟨1, 0, ⟨0⟩, right⟩

def issued := issueCapability config admin empty (grant .invoke)

def store : CapabilityStore P A D :=
  match issued with
  | .ok (_, s) => s
  | .error _ => empty

def debit : Right P A D := .debit (0, 1, 0)
def supply : Right P A D := .changeSupply 0 0

def issueMore : Except AuthorityFailure (CapabilityStore P A D) := do
  let (_, s) ← issueCapability config admin store (grant debit)
  let (_, s) ← issueCapability config admin s (grant supply)
  return s

def full : CapabilityStore P A D := issueMore.toOption.getD empty

def revoked := revokeCapability config admin full ⟨1⟩
def afterRevoke : CapabilityStore P A D := revoked.toOption.getD empty

def reissued := issueCapability config admin afterRevoke (grant debit)
def afterReissue : CapabilityStore P A D :=
  match reissued with
  | .ok (_, s) => s
  | .error _ => empty

def sameRequest (s : CapabilityStore P A D) : Bool :=
  hasAuthority s [⟨0⟩, ⟨1⟩, ⟨2⟩] holder ⟨0⟩ .invoke &&
  hasAuthority s [⟨0⟩, ⟨1⟩, ⟨2⟩] holder ⟨0⟩ debit

def foreignIssue := issueCapability config foreignAdmin empty
  (⟨1, 1, ⟨1⟩, .invoke⟩ : Grant P A D)

def wrongOperationIssue := issueCapability config admin empty
  { grant .invoke with operation := ⟨2⟩ }

def issueUse (result : Except AuthorityFailure (CapabilityId × CapabilityStore P A D))
    (ctx : InvocationContext P D) (op : OperationId) (right : Right P A D) : Bool :=
  match result with
  | .error _ => false
  | .ok (id, s) => hasAuthority s [id] ctx op right

/-- Named comparisons run public issue/revoke/use definitions. These are development tests. -/
def checks : List (String × Bool) := [
  ("authority_issue_succeeds_with_id_zero", decide (issued = .ok (⟨0⟩, ⟨[⟨grant .invoke, true⟩]⟩))),
  ("authority_unauthorized_issuer", decide (issueCapability config holder empty (grant .invoke) =
    .error .unauthorizedAdmin)),
  ("authority_issuer_wrong_authenticated_domain", decide
    (issueCapability config ⟨0, 1⟩ empty (grant .invoke) = .error .unauthorizedAdmin)),
  ("authority_unknown_operation_grant", decide (issueCapability config admin empty
    { grant .invoke with operation := ⟨99⟩ } = .error .operationDomain)),
  ("authority_foreign_operation_grant", decide (issueCapability config admin empty
    { grant .invoke with operation := ⟨1⟩ } = .error .operationDomain)),
  ("authority_foreign_debit_resource_grant", decide (issueCapability config admin empty
    (grant (.debit (1, 1, 0))) = .error .resourceDomain)),
  ("authority_foreign_supply_resource_grant", decide (issueCapability config admin empty
    (grant (.changeSupply 1 0)) = .error .resourceDomain)),
  ("authority_invoke_live_holder", hasAuthority full [⟨0⟩] holder ⟨0⟩ .invoke),
  ("authority_debit_live_holder", hasAuthority full [⟨1⟩] holder ⟨0⟩ debit),
  ("authority_supply_live_holder", hasAuthority full [⟨2⟩] holder ⟨0⟩ supply),
  ("authority_wrong_holder", !hasAuthority full [⟨0⟩] ⟨2, 0⟩ ⟨0⟩ .invoke),
  ("authority_wrong_authenticated_domain", !hasAuthority full [⟨0⟩] ⟨1, 1⟩ ⟨0⟩ .invoke),
  ("authority_unknown_capability", !hasAuthority full [⟨99⟩] holder ⟨0⟩ .invoke),
  ("authority_empty_capability_request", !hasAuthority full [] holder ⟨0⟩ .invoke),
  ("authority_wrong_operation", !hasAuthority full [⟨0⟩] holder ⟨2⟩ .invoke),
  ("authority_wrong_debit_owner", !hasAuthority full [⟨1⟩] holder ⟨0⟩ (.debit (0, 2, 0))),
  ("authority_wrong_debit_asset", !hasAuthority full [⟨1⟩] holder ⟨0⟩ (.debit (0, 1, 1))),
  ("authority_wrong_supply_asset", !hasAuthority full [⟨2⟩] holder ⟨0⟩ (.changeSupply 0 1)),
  ("authority_right_kind_mismatch", !hasAuthority full [⟨0⟩] holder ⟨0⟩ debit),
  ("authority_duplicates_preserve_success", hasAuthority full [⟨0⟩, ⟨0⟩] holder ⟨0⟩ .invoke),
  ("authority_duplicates_add_no_right", !hasAuthority full [⟨0⟩, ⟨0⟩] holder ⟨0⟩ debit),
  ("authority_unauthorized_revoker", decide (revokeCapability config holder full ⟨1⟩ =
    .error .unauthorizedAdmin)),
  ("authority_revoker_wrong_authenticated_domain", decide
    (revokeCapability config ⟨0, 1⟩ full ⟨1⟩ = .error .unauthorizedAdmin)),
  ("authority_unknown_revocation", decide (revokeCapability config admin full ⟨99⟩ =
    .error .unknownCapability)),
  ("authority_same_request_before_revoke", sameRequest full),
  ("authority_revoke_accepted", decide (revoked = .ok
    ⟨[⟨grant .invoke, true⟩, ⟨grant debit, false⟩, ⟨grant supply, true⟩]⟩)),
  ("authority_same_request_after_revoke", !sameRequest afterRevoke),
  ("authority_revoke_keeps_invoke_sibling", hasAuthority afterRevoke [⟨0⟩] holder ⟨0⟩ .invoke),
  ("authority_revoke_keeps_supply_sibling", hasAuthority afterRevoke [⟨2⟩] holder ⟨0⟩ supply),
  ("authority_revoke_is_idempotent", decide
    (revokeCapability config admin afterRevoke ⟨1⟩ = .ok afterRevoke)),
  ("authority_reissue_receives_fresh_id_three", decide
    (reissued = .ok (⟨3⟩, ⟨afterRevoke.entries ++ [⟨grant debit, true⟩]⟩))),
  ("authority_reissued_right_usable_by_new_id", hasAuthority afterReissue [⟨3⟩] holder ⟨0⟩ debit),
  ("authority_old_revoked_id_remains_unusable", !hasAuthority afterReissue [⟨1⟩] holder ⟨0⟩ debit),
  ("authority_foreign_grant_positive_sibling", issueUse foreignIssue ⟨1, 1⟩ ⟨1⟩ .invoke),
  ("authority_foreign_grant_cannot_authorize_local_context",
    !issueUse foreignIssue holder ⟨1⟩ .invoke),
  ("authority_other_operation_positive_sibling", issueUse wrongOperationIssue holder ⟨2⟩ .invoke),
  ("authority_other_operation_cannot_authorize_original",
    !issueUse wrongOperationIssue holder ⟨0⟩ .invoke)]

end AuthorityTests

-- BEGIN PROOFS

#eval AuthorityTests.checks
#eval AuthorityTests.checks.length

theorem authority_checks_pass : AuthorityTests.checks.all Prod.snd = true := by decide

end DefiKernel.Typed
