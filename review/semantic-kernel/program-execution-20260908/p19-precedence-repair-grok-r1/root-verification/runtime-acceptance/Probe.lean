import DefiKernel.Certificates.Correspondence
open DefiKernel.Certificates
#eval "unterminated_value_space_checkBytes=" ++ reprStr (checkBytes "{\"a\": \"unterminated".toUTF8)
#eval "unterminated_value_no_space_checkBytes=" ++ reprStr (checkBytes "{\"a\":\"unterminated".toUTF8)
#eval "unterminated_key_space_checkBytes=" ++ reprStr (checkBytes "{\"a\":1, \"unterminated".toUTF8)
#eval "unterminated_key_no_space_checkBytes=" ++ reprStr (checkBytes "{\"a\":1,\"unterminated".toUTF8)
#eval "maxBytes_1048577=" ++ reprStr (scanLexical (ByteArray.mk (Array.replicate 1048577 0x7b)))
#eval "maxBytes_1048577_checkBytes=" ++ reprStr (checkBytes (ByteArray.mk (Array.replicate 1048577 0x7b)))
#eval "maxBytes_1048576_not_size_reject=" ++ (if (ByteArray.mk (Array.replicate 1048576 0x7b)).size > 1048576 then "size_gt" else "size_le")
