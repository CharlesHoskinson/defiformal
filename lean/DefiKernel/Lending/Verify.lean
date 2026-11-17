import DefiKernel.Lending.RepayAudit
import DefiKernel.Lending.BorrowAudit
import DefiKernel.Lending.AccrueAudit
import DefiKernel.Lending.DepositCollateralAudit
import DefiKernel.Lending.WithdrawCollateralAudit
import DefiKernel.Lending.LifecycleAudit
import DefiKernel.AxiomAudit

/-! Nonempty audit of the implemented lending operation namespace. -/
#audit_axioms DefiKernel.Lending
