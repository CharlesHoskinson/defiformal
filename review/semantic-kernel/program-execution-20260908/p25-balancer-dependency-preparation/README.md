# P25 locked dependency sources

OpenZeppelin Contracts 5.4.0 and Permit2 `cc56ad0f3439c502c246fc5cfcc3db92bb8b7219` come from the captured Balancer lock. The npm archive matches registry SHA-512 integrity and SHA-1 shasum. Permit2 archive members match the explicit commit tree's Git blob identities. Yarn cache checksums are not raw archive digests.

Source traversal from seven vault/router/mock seeds resolves 308 imports across 68 Balancer, 26 OpenZeppelin, and 4 Permit2 files, with zero unresolved lexical paths. The reference Foundry tests are outside this import closure. This is not compiler import resolution, a package install, an executed Solidity test, a Lean proof, source-to-deployment fidelity, or P25 acceptance. Token and Permit2 implementation behavior and actual compiler/runtime identities still need the later contract and execution work.
