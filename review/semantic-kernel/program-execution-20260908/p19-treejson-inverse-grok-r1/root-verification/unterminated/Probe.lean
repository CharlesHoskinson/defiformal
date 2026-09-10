import DefiKernel.Certificates.Correspondence
open DefiKernel.Certificates
#eval "unterminated_value_space" ++ ";scan=" ++ reprStr (scanLexical "{\"a\": \"unterminated".toUTF8) ++ ";decode=" ++ reprStr (decodeBytes "{\"a\": \"unterminated".toUTF8)
#eval "unterminated_value_no_space" ++ ";scan=" ++ reprStr (scanLexical "{\"a\":\"unterminated".toUTF8) ++ ";decode=" ++ reprStr (decodeBytes "{\"a\":\"unterminated".toUTF8)
#eval "unterminated_key_space" ++ ";scan=" ++ reprStr (scanLexical "{\"a\":1, \"unterminated".toUTF8) ++ ";decode=" ++ reprStr (decodeBytes "{\"a\":1, \"unterminated".toUTF8)
#eval "unterminated_key_no_space" ++ ";scan=" ++ reprStr (scanLexical "{\"a\":1,\"unterminated".toUTF8) ++ ";decode=" ++ reprStr (decodeBytes "{\"a\":1,\"unterminated".toUTF8)
