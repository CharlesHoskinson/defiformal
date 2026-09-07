# Author self-review of initial planning candidate

Candidate: `a3b2dec486de281080a84ae5f7cfc0da39d066a9`.
This is author analysis, not either required independent verdict. No implementation.

Potential blocking fixture contradiction: design section 7 and the output scenario
ask for the same complete `(local step, QualifiedPort)` key to carry different values
in admitted branches. Under the current static selected-cell outputs and globally
unique operation membership, the same qualified output port selects the same cell.
If either branch changes that cell, the peer output read conflicts with its write.
If neither writes it, both snapshots equal the common initial value. Thus a
successful admitted pair cannot provide that particular differing-value collision.

Proposed correction for the revised candidate: use equal local step and unqualified
numeric port ID with distinct component IDs and distinct selected cells to exercise
full qualification, plus a shared read-only output having the same full local key
and equal value to exercise branch labels/multiplicity. Test history leakage using
a peer-only earlier key that the consumer's local history lacks, even when its
index is later; it must remain unavailable. This keeps the routing requirement
meaningful without requiring an impossible accepted fixture.

Await the independent GPT-6 audit before preparing a combined revision. Fable's
initial call was unavailable due to credits, so no Fable verdict exists to retain
or reinterpret as approval.
