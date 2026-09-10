# P31 locked Midnight dependency sources

This packet captures the twelve `midnight-*` dependencies selected from the published ZKIR2.1.0 Cargo.lock. Each successful source archive is checked against both that lock checksum and the registry version metadata, then extracted as regular files with original paths and hashes. HTTP request/response receipts, package licenses and published VCS metadata are retained.

This is source acquisition evidence. It does not establish the semantic interface, source-to-installed-binary correspondence, proof soundness, a reproducible build, or adapter acceptance. Non-Midnight dependencies in the lock remain an explicit uncaptured boundary in scope.json. No downloaded source, build script, compiler, circuit or proof was executed.
