import DefiKernel.Certificates.Correspondence
import DefiKernel.Certificates.CanonicalJson
import DefiKernel.Certificates.Encode
import DefiKernel.Certificates.Decode
open DefiKernel.Certificates
open Lean

/-- Bounded R14 probe: object-decoder theorem shape, fuel exhaustion, sorted source-map helper. -/

def showSM : Except DecodeFailure (List (String × String)) → String
  | .ok xs => s!"ok:{xs}"
  | .error e => encodeDecodeFailure e

def showIR : Except DecodeFailure DecodedIR → String
  | .ok (.execution (.typed env _)) => s!"ok typed mode={env.mode} sm={env.source_map.length}"
  | .ok (.execution (.step env _)) => s!"ok step mode={env.mode}"
  | .ok (.execution (.run env _)) => s!"ok run mode={env.mode}"
  | .ok (.audit _) => "ok audit"
  | .ok (.codec _) => "ok codec"
  | .error e => encodeDecodeFailure e

def nestArr : Nat → Json
  | 0 => Json.str "x"
  | n + 1 => Json.arr #[nestArr n]

def nestObj : Nat → Json
  | 0 => Json.str "x"
  | n + 1 => Json.mkObj [("k", nestObj n)]

#check decodeDecodedIR_of_structurallyAdmissible
#check decodeSourceMap_sourceMapToJson
#check ofList_toList_eq
#check jsonDepthFuel_stable
#check jsonMaxArrayLengthFuel_stable
#check jsonDepth_stable_of_le64
#check jsonMaxArrayLength_stable_of_le64
#check parser_max_depth_bound
#check parser_max_array_bound
#check jsonMaxArrayLengthFuel_adequate
#check EncodeDecodeRoundtripStatement
#print EncodeDecodeRoundtripStatement
#print decodeDecodedIR_of_structurallyAdmissible
#print jsonDepthFuel_stable
#print jsonMaxArrayLengthFuel_stable
#print parser_max_depth_bound
#print parser_max_array_bound
#print jsonMaxArrayLengthFuel_adequate

#eval (do
  let deep2 := nestArr 2
  IO.println s!"arr2_fuel0={jsonDepthFuel 0 deep2}"
  IO.println s!"arr2_fuel1={jsonDepthFuel 1 deep2}"
  IO.println s!"arr2_fuel2={jsonDepthFuel 2 deep2}"
  IO.println s!"arr2_fuel3={jsonDepthFuel 3 deep2}"
  IO.println s!"arr2_fuel100={jsonDepthFuel 100 deep2}"
  let obj2 := nestObj 2
  IO.println s!"obj2_fuel0={jsonDepthFuel 0 obj2}"
  IO.println s!"obj2_fuel1={jsonDepthFuel 1 obj2}"
  IO.println s!"obj2_fuel2={jsonDepthFuel 2 obj2}"
  IO.println s!"obj2_fuel3={jsonDepthFuel 3 obj2}"
  let big := Json.arr (Array.replicate 5 (Json.str "a"))
  IO.println s!"arr5_max_fuel0={jsonMaxArrayLengthFuel 0 big}"
  IO.println s!"arr5_max_fuel1={jsonMaxArrayLengthFuel 1 big}"
  IO.println s!"arr5_max_fuel2={jsonMaxArrayLengthFuel 2 big}"
  let twoAB := Json.mkObj [("a", Json.str "1"), ("b", Json.str "2")]
  let twoBA := Json.mkObj [("b", Json.str "2"), ("a", Json.str "1")]
  IO.println s!"sm_two_ab={showSM (decodeSourceMap twoAB)}"
  IO.println s!"sm_two_ba_mkObj={showSM (decodeSourceMap twoBA)}"
  IO.println s!"two_ab_compress={twoAB.compress}"
  IO.println s!"two_ba_compress={twoBA.compress}"
  IO.println s!"prod_sm_ab={encodeSourceMap [("a","1"),("b","2")]}"
  IO.println s!"prod_sm_ba={encodeSourceMap [("b","2"),("a","1")]}"
  IO.println s!"witness_obj={showIR (decodeDecodedIR (decodedIRToJson canonicalWitnessIR) "unused")}"
  IO.println s!"witness_bytes={showIR (decodeBytes (encodeModule canonicalWitnessIR))}"
  pure ())
