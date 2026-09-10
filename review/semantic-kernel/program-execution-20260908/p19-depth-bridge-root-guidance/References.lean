import DefiKernel.Certificates.Roundtrip
import Std.Data.TreeMap.Raw.Lemmas
#check Std.TreeMap.Raw.foldl_eq_foldl_toList
#check Std.TreeMap.Raw.toList_insert_perm
#check Std.TreeMap.Raw.ofList_equiv_foldl
#check Std.TreeMap.Raw.Equiv.foldl_eq
#check Std.TreeMap.Raw.getElem?_ofList_of_mem
#check DefiKernel.Certificates.jsonDepth_stable_of_le64
#check DefiKernel.Certificates.jsonMaxArrayLength_stable_of_le64
open DefiKernel.Certificates in
#eval let duplicate : TreeJson := .obj [("k", .arr [.arr [.null]]), ("k", .null)]
      (duplicate.depth, jsonDepth duplicate.toJson)
