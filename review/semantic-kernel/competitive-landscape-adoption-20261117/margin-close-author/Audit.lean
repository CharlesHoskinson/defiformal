import DefiKernel.Margin.CloseAudit
import DefiKernel.AxiomAudit
#audit_axioms DefiKernel.Margin.Close
#audit_axioms DefiKernel.Margin.CloseAudit
#print axioms DefiKernel.Margin.Close.liquidation_correct
#print axioms DefiKernel.Margin.Close.constructive_solvency
#print axioms DefiKernel.Margin.Close.run_execution
#print axioms DefiKernel.Margin.Close.run_accounting
#print axioms DefiKernel.Margin.Close.run_chain
#print axioms DefiKernel.Margin.Close.run_prefix
#print axioms DefiKernel.Margin.Close.run_pending
#print axioms DefiKernel.Margin.CloseAudit.simple_constructive_witness
