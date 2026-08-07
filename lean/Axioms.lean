import Defialgebra
open Defialgebra
-- Obstruction (NOT covered by any in-repo AxiomAudit section)
#print axioms Defialgebra.aft_obstruction
#print axioms Defialgebra.aft_obstruction_eq
#print axioms Defialgebra.fix_iterate
#print axioms Defialgebra.adm_univ_of_consistent
-- spot re-check of headline results
#print axioms Defialgebra.ConvexGeometry.ex_reachCl_union_ex
#print axioms Defialgebra.ConvexGeometry.thm_convex
#print axioms Defialgebra.Lattice.UnionClosedFamily.completeLattice
#print axioms Defialgebra.Polarity.req_models_union_closed
#print axioms Defialgebra.Polarity.dualHorn_not_inter_closed
-- statements, printed
#check @Defialgebra.ConvexGeometry.ex_reachCl_union_ex
#check @Defialgebra.ConvexGeometry.thm_convex
#check @Defialgebra.adm_univ_of_consistent
#check @Defialgebra.Polarity.req_models_union_closed
#check @Defialgebra.Polarity.warrant_models_union_closed

-- M1 Interface
#print axioms Defialgebra.Interface.cons_of_portConfined
#print axioms Defialgebra.Interface.cons_broken_if_sup_is_port
-- M2 FlowPolarity
#print axioms Defialgebra.FlowPolarity.antiCaller_settle
#print axioms Defialgebra.FlowPolarity.DirectedEdge.antiCaller_both
#print axioms Defialgebra.FlowPolarity.antiCaller_broken_if_polarity_flipped
#print axioms Defialgebra.FlowPolarity.directedEdge_broken_if_same_polarity

-- M3 Nary (full surface)
#print axioms Defialgebra.Nary.agrees_iff_agrees_sym
#print axioms Defialgebra.Nary.agrees_union
#print axioms Defialgebra.Nary.union_assoc
#print axioms Defialgebra.Nary.union_comm
#print axioms Defialgebra.Nary.agrees_union_assoc
#print axioms Defialgebra.Nary.agrees_of_same_symClosure
#print axioms Defialgebra.Nary.pairLocal_excludes_skip
#print axioms Defialgebra.Nary.skip_not_pairLocal_witness


-- Gate 0.2 F9 extremal irreducibility
#print axioms Defialgebra.Extremal.extremal_not_local
#print axioms Defialgebra.Extremal.f9_irreducible_to_sum_local
