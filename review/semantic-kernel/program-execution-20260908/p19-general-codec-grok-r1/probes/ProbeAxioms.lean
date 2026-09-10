import DefiKernel.Certificates.Correspondence
open DefiKernel.Certificates

/- Axiom audit of exact named CanonicalJson and Correspondence theorem declarations. -/

#check EncodeDecodeRoundtripStatement
#check DecodeEncodeCanonicalBytesStatement
#check StructurallyAdmissibleIR
#check SupportedIR
#check SerializedByteBound
#check ExprDepthBounded
#check TemplateDepthBounded
#check exprMaxStackDepth
#check exprDepth
#check ExprCanonical
#check PackedValueCanonical
#check OperationInterfaceLengthBounds
#check ComponentLengthBounds
#check ConfigLengthBounds
#check ClaimedNextStateLengthBounds
#check exprDepth_pos

#print axioms hexVal_hexDigit
#print axioms bool_cond_of_lt32
#print axioms lexString_quote
#print axioms lexString_slash
#print axioms lexString_u00
#print axioms lexString_normal
#print axioms lexString_char
#print axioms lexString_escapeChars
#print axioms lexString_escapeJsonString
#print axioms string_fromUTF8?_toUTF8
#print axioms tokenizeFuel_string
#print axioms parseTokens_str
#print axioms parseTokens_num
#print axioms parseTokens_bool
#print axioms parseTokens_null
#print axioms structurallyAdmissible_nonempty
#print axioms decodeBytes_encode_canonical
#print axioms decode_encode_roundtrip_of_decode
#print axioms decode_encode_canonical_bytes
#print axioms decode_error_no_kernel
#print axioms decode_error_resource_limit
#print axioms checkBytes_no_kernel_on_error
#print axioms checkBytes_ok
#print axioms checkBytes_typed_correspondence
#print axioms checkBytes_step_correspondence
#print axioms checkBytes_run_correspondence
#print axioms rational_decode_canonical
#print axioms rat_fromRat_num_den
#print axioms rational_roundtrip
#print axioms decodeParty_encodeParty
#print axioms decodeAsset_encodeAsset
#print axioms decodeDomain_encodeDomain
#print axioms decodeRight_invoke
#print axioms decodePartyRef_caller
#print axioms decodePartyRef_literal
#print axioms decodeNumericUnit_scalar
#print axioms decodeNumericUnit_amount
#print axioms decodeUnit_bool
#print axioms decodeUnit_scalar
#print axioms decodeUnit_amount
#print axioms decodeRegistry_empty
#print axioms decodeStore_empty
#print axioms decodeRight_debit
#print axioms decodeRight_changeSupply
#print axioms decodePartyRef_argument
#print axioms decodeNumericUnit_price
#print axioms decodePackedValue_bool
#print axioms decodePackedValue_canonical_bool
#print axioms decodeObservationKey_roundtrip
#print axioms decodeEnvRead_currentTime
#print axioms decodeUnaryOp_not
#print axioms decodeUnaryOp_neg
#print axioms decodeBinaryOp_and
#print axioms decodeBinaryOp_or
#print axioms decodeCellRef_roundtrip
#print axioms decodeCell_roundtrip
#print axioms decodeContext_roundtrip
#print axioms decodeDomainAdmin_roundtrip
#print axioms decodeQualifiedPort_roundtrip
#print axioms decodeStep_revoke
#print axioms decodeExprFuel_now
#print axioms decodeExprFuel_arg_bool
#print axioms decodeExprFuel_lit_bool
#print axioms decodeExpr_now
#print axioms decodeExpr_lit_bool
#print axioms decodeObservationRef_roundtrip
#print axioms decodeRat_zero
#print axioms decodePackedValue_scalar_zero
#print axioms decodePackedValue_amount_zero
#print axioms decodeBinaryOp_add
#print axioms decodeBinaryOp_convert
#print axioms decodeBinaryOp_eq
#print axioms decodeStep_issue
#print axioms decodePackedCellRef_roundtrip
#print axioms decodeEnvRead_observation
#print axioms decodeSourcePin_roundtrip
#print axioms decodeGrant_roundtrip
#print axioms decodeTypesEnum_roundtrip
#print axioms decodeCapability_invoke
#print axioms decodeExprFuel_balance
#print axioms decodeExprFuel_timestamp
#print axioms decodeExprFuel_unary_not
#print axioms decodeExprFuel_binary_and
#print axioms decodeExprFuel_ite
#print axioms decodeExpr_balance
#print axioms decodeExpr_timestamp
#print axioms decodeExpr_unary_not
#print axioms decodeExpr_binary_and
#print axioms decodeExpr_ite
#print axioms string_roundtrip
#print axioms serialized_byte_bound_exceeded_not_supported
#print axioms decodeRat_mkObj
#print axioms decodePackedValue_scalar_val
#print axioms decodePackedValue_amount_val
#print axioms decodeParty_partyToJson
#print axioms decodeAsset_assetToJson
#print axioms decodeDomain_domainToJson
#print axioms decodeCell_cellToJson
#print axioms decodeRight_rightToJson
#print axioms decodeGrant_grantToJson
#print axioms decodePartyRef_partyRefToJson
#print axioms decodeCellRef_cellRefToJson
#print axioms decodePackedCellRef_packedCellRefToJson
#print axioms decodeObservationKey_observationKeyToJson
#print axioms decodeNumericUnit_numericUnitToJson
#print axioms decodeUnit_unitToJson
#print axioms decodeObservationRef_observationRefToJson
#print axioms decodeUnaryOp_unaryOpToJson
#print axioms decodeBinaryOp_binaryOpToJson
#print axioms decodeStateCell_canonical
#print axioms exprToJson_decode_now
#print axioms exprToJson_decode_timestamp
#print axioms exprToJson_decode_observe
#print axioms exprToJson_decode_balance
#print axioms exprToJson_decode_arg
#print axioms exprToJson_decode_unary_step
#print axioms exprToJson_decode_binary_step
#print axioms exprToJson_decode_ite_step
#print axioms rat_toRat_fromRat
#print axioms decodeRat_ratToJson
#print axioms decodeRat_fromRat
#print axioms decodeExprFuel_lit_canonical
#print axioms decodeExprFuel_exprToJson
#print axioms decodeExpr_exprToJson
#print axioms decodeEnvRead_envReadToJson
#print axioms decodeCellDelta_cellDeltaToJson
#print axioms decodeSupplyDelta_supplyDeltaToJson
#print axioms list_mapM_decode_ok
#print axioms decodeTemplate_templateToJson
#print axioms filter_not_beq_of_not_mem
#print axioms eraseDups_eq_of_nodup
#print axioms nodup_eraseDups_length
#print axioms decodeRegistryEntry_registryEntryToJson
#print axioms decodeRegistry_registryToJson
#print axioms decodeCapability_capabilityToJson
#print axioms decodeStore_storeToJson
#print axioms decodeContext_contextToJson
#print axioms decodePackedValue_canonical
#print axioms decodeObservation_observationToJson
#print axioms decodeEnvironmentEntry_environmentEntryToJson
#print axioms decodeEnvironment_environmentToJson
#print axioms decodeDomainAdmin_domainAdminToJson
#print axioms decodeInputPort_inputPortToJson
#print axioms decodeOutputPort_outputPortToJson
#print axioms decodeResourcePort_resourcePortToJson
#print axioms decodeQualifiedPort_qualifiedPortToJson
#print axioms decodeResourceImport_resourceImportToJson
#print axioms decodeSourcePin_sourcePinToJson
#print axioms decodeTypesEnum_typesEnumToJson
#print axioms decodeStateCell_stateCellToJson
