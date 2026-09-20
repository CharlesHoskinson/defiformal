import DefiKernel.Certificates.Encode
import DefiKernel.Certificates.Tests
open DefiKernel.Certificates
open DefiKernel.Certificates.Tests
def main : IO Unit := do
 let rep := checkTyped defaultEnvelope defaultPayload
 IO.println (encodeReport { rep with unsupported := some "treeJoin" })
 IO.println (encodeReport { rep with unsupported := some "quoted\"reason\nline" })
 IO.println (encodeReport { rep with unsupported := none })
