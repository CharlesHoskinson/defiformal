import DefiKernel.Metatheory.ConfigurationGroups
import DefiKernel.Metatheory.OperatorLifting
import DefiKernel.AxiomAudit

#audit_axioms DefiKernel.Metatheory

#print axioms DefiKernel.Metatheory.supportedList_nil
#print axioms DefiKernel.Metatheory.supportedList_cons
#print axioms DefiKernel.Metatheory.supportedList_append
#print axioms DefiKernel.Metatheory.supportedBranch_nil
#print axioms DefiKernel.Metatheory.supportedBranch_cons
#print axioms DefiKernel.Metatheory.supportedBranch_map
#print axioms DefiKernel.Metatheory.SupportedStep.union_left
#print axioms DefiKernel.Metatheory.SupportedStep.union_right
#print axioms DefiKernel.Metatheory.SupportedList.union_left
#print axioms DefiKernel.Metatheory.SupportedList.union_right
#print axioms DefiKernel.Metatheory.ConfigAgreement.refl
#print axioms DefiKernel.Metatheory.ConfigAgreement.symm
#print axioms DefiKernel.Metatheory.ConfigAgreement.trans
#print axioms DefiKernel.Metatheory.ConfigAgreement.union
#print axioms DefiKernel.Metatheory.ConfigAgreement.restrict
#print axioms DefiKernel.Metatheory.prepareInvocation_config_eq
#print axioms DefiKernel.Metatheory.issueCapability_config_eq
#print axioms DefiKernel.Metatheory.revokeCapability_config_eq
#print axioms DefiKernel.Metatheory.typed_execute_registry_eq
#print axioms DefiKernel.Metatheory.extractReceipt_config_eq
#print axioms DefiKernel.Metatheory.executeStep_config_eq
#print axioms DefiKernel.Metatheory.startCursor_config_eq
#print axioms DefiKernel.Metatheory.advance_config_eq
#print axioms DefiKernel.Metatheory.continueRun_config_eq
#print axioms DefiKernel.Metatheory.run_config_eq
#print axioms DefiKernel.Metatheory.supportedGroup_empty
#print axioms DefiKernel.Metatheory.supportedGroup_step
#print axioms DefiKernel.Metatheory.supportedGroup_seq
#print axioms DefiKernel.Metatheory.SupportedGroup.union_left
#print axioms DefiKernel.Metatheory.SupportedGroup.union_right
#print axioms DefiKernel.Metatheory.supportedGroup_union_seq
#print axioms DefiKernel.Metatheory.runGroup_config_eq
#print axioms DefiKernel.Metatheory.analyzeInvocation_config_eq
#print axioms DefiKernel.Metatheory.analyzeBranchFrom_config_eq
#print axioms DefiKernel.Metatheory.analyzeBranch_config_eq
#print axioms DefiKernel.Metatheory.parallel_admit_config_eq
#print axioms DefiKernel.Metatheory.interleaving_admit_config_eq
#print axioms DefiKernel.Metatheory.atomic_admit_config_eq
#print axioms DefiKernel.Metatheory.runBranch_config_eq
#print axioms DefiKernel.Metatheory.runParallel_config_eq
#print axioms DefiKernel.Metatheory.runSerialLR_config_eq
#print axioms DefiKernel.Metatheory.runSerialRL_config_eq
#print axioms DefiKernel.Metatheory.interleaving_advance_config_eq
#print axioms DefiKernel.Metatheory.interleaving_continueRun_config_eq
#print axioms DefiKernel.Metatheory.interleaving_runPrefix_config_eq
#print axioms DefiKernel.Metatheory.runInterleaving_config_eq
#print axioms DefiKernel.Metatheory.atomic_advance_config_eq
#print axioms DefiKernel.Metatheory.atomic_continueRun_config_eq
#print axioms DefiKernel.Metatheory.atomic_runPrefix_config_eq
#print axioms DefiKernel.Metatheory.runAtomic_config_eq
