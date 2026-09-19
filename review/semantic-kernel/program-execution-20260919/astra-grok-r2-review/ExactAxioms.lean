import DefiKernel.Certificates.Lexical
import Lean.Elab.Command
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "contains_eq_false_of_not_mem"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "decodeBytes_encodeModule_of_lex"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "decodeBytes_encodeModule_run_of_lex"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "decodeBytes_encodeModule_step_of_lex"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "digitChar_lt_10_isDigit"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "encodeList_nil_toList"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "encodeList_singleton_toList"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "encode_bool_false_toList"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "encode_bool_true_toList"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "encode_null_toList"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "isDigit_ge_le"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "isDigit_ne_nondigit"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "isDigit_not_struct"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "isDigit_num_cont"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "isDigit_num_start"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "jsonDepthFuel_compositionRunPayload"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "jsonDepthFuel_compositionStepPayload"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "jsonDepthFuel_decodedIR"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "jsonDepthFuel_decodedIR_run"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "jsonDepthFuel_decodedIR_step"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "jsonDepthFuel_inputSource"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "jsonDepthFuel_invocation"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "jsonDepthFuel_outputObservation"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "jsonDepthFuel_step"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "minus_not_struct"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "minus_num_start"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "moduleToTreeJson_depth_le_64"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "moduleToTreeJson_run_depth_le_64"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "moduleToTreeJson_step_depth_le_64"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "notExpectKey_arr"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "notExpectKey_nil"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "notExpectKey_obj_val"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "ofList_contains_false_of_not_mem"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCost_arr_nil"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCost_obj_nil"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalCheckNum_int"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalCheckNum_nat"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalCheckNum_numBuf"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_a"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_comma_arr_flush"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_comma_obj_flush"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_digit_cont"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_digit_start"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_digits_cont"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_e"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_encode_arr_nil"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_encode_bool"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_encode_null"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_encode_num"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_encode_obj_nil"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_encode_scalar"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_encode_str"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_f"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_false"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_int"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_l"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_minus"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_n"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_nat"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_null"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_num_cont"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_num_start"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_other"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_r"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_rbrace_flush"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_rbracket_flush"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_s"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_str_key"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_str_value"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_t"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_true"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_u"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "toDigits_not_mem_dot_e"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "Nat") "digitChar") "eq_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "contains_eq_false_of_not_mem") "_simp_1_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "isDigit_ne_nondigit") "_simp_1_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "jsonDepthFuel_inputSource") "_simp_1_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "jsonDepthFuel_inputSource") "_simp_1_2"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "jsonDepthFuel_invocation") "_simp_1_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "jsonDepthFuel_outputObservation") "_simp_1_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "jsonDepthFuel_outputObservation") "_simp_1_2"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "jsonDepthFuel_step") "_simp_1_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "jsonDepthFuel_step") "_simp_1_2"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "numBuf") "eq_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "numBuf") "eq_2"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalCheckNum") "eq_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_comma_arr_flush") "_proof_1_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_encode_arr_nil") "_proof_1_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_encode_obj_nil") "_proof_1_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_encode_scalar") "_proof_1_4"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_encode_scalar") "_proof_1_5"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "numBuf") "_sparseCasesOn_1") "else_eq"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.num (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "_private") "DefiKernel") "Certificates") "Lexical") 0) "DefiKernel") "Certificates") "numBuf") "match_1") "eq_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.num (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "_private") "DefiKernel") "Certificates") "Lexical") 0) "DefiKernel") "Certificates") "numBuf") "match_1") "eq_2"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.num (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "_private") "DefiKernel") "Certificates") "Lexical") 0) "DefiKernel") "Certificates") "scanLexicalFuel") "match_1") "eq_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.num (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "_private") "DefiKernel") "Certificates") "Lexical") 0) "DefiKernel") "Certificates") "scanLexicalFuel") "match_1") "eq_2"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.num (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "_private") "DefiKernel") "Certificates") "Lexical") 0) "DefiKernel") "Certificates") "scanLexicalFuel") "match_3") "eq_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.num (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "_private") "DefiKernel") "Certificates") "Lexical") 0) "DefiKernel") "Certificates") "scanLexicalFuel") "match_3") "eq_2"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "notExpectKey"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "numBuf"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCost"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCostList"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCostObj"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "notExpectKey") "_sparseCasesOn_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "notExpectKey") "_sparseCasesOn_2"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "notExpectKey") "_sparseCasesOn_3"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "notExpectKey") "match_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "numBuf") "_sparseCasesOn_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "numBuf") "match_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCost") "_f"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCost") "_sunfold"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCost") "_unsafe_rec"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCost") "match_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCostList") "_f"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCostList") "_sparseCasesOn_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCostList") "_sunfold"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCostList") "_unsafe_rec"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCostList") "match_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCostObj") "_f"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCostObj") "_sunfold"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCostObj") "_unsafe_rec"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanCostObj") "match_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalCheckNum_int") "match_1_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalCheckNum_nat") "match_1_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_encode_scalar") "_sparseCasesOn_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "DefiKernel") "Certificates") "scanLexicalFuel_encode_scalar") "match_1"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.num (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "_private") "DefiKernel") "Certificates") "Lexical") 0) "DefiKernel") "Certificates") "numBuf") "match_1") "splitter"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.num (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "_private") "DefiKernel") "Certificates") "Lexical") 0) "DefiKernel") "Certificates") "scanLexicalFuel") "match_1") "splitter"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.num (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "_private") "DefiKernel") "Certificates") "Lexical") 0) "DefiKernel") "Certificates") "scanLexicalFuel") "match_3") "splitter"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.num (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "_private") "DefiKernel") "Certificates") "Lexical") 0) "DefiKernel") "Certificates") "scanLexicalFuel") "match_3") "splitter") "_sparseCasesOn_2"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.num (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "_private") "DefiKernel") "Certificates") "Lexical") 0) "DefiKernel") "Certificates") "scanLexicalFuel") "match_3") "splitter") "_sparseCasesOn_3"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
run_cmd do
  let n := Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.num (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.str (Lean.Name.anonymous) "_private") "DefiKernel") "Certificates") "Lexical") 0) "DefiKernel") "Certificates") "scanLexicalFuel") "match_3") "splitter") "_sparseCasesOn_4"
  Lean.Elab.Command.elabCommand (← `(command| #print axioms $(Lean.mkIdent n)))
