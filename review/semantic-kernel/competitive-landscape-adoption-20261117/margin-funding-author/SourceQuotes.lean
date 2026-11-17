import DefiKernel.Margin.Funding
open DefiKernel.Margin.Funding
private def initial : Position := ⟨precision+1,10,-1,⟨0,0,0⟩⟩
private def shifted : Position := {initial with snapshots:=⟨10,10,10⟩}
private def q := quote initial ⟨1,2,3⟩ (by decide)
private def shiftedQ := quote shifted ⟨11,13,13⟩ (by decide)
private def zeroQ := quote shifted ⟨10,10,10⟩ (by decide)
private def zeroSizeQ := quote {initial with sizeUsd:=0} ⟨1,2,3⟩ (by decide)
#eval do
  for (name,value) in [("fee_ceil_positive_remainder",q.feePrimary),
    ("long_claim_floor",q.pendingClaimPrimary),("short_claim_floor",q.pendingClaimSecondary),
    ("fee_snapshot_delta",shiftedQ.feePrimary),("claim_snapshot_delta",shiftedQ.pendingClaimSecondary),
    ("zero_delta_fee",zeroQ.feePrimary),("zero_size_fee",zeroSizeQ.feePrimary)] do
    IO.println s!"FUNDING_SOURCE_PAIR {name} {value}"
