# P19 evidence publication

Large raw build/fixture logs and the full fixture report are stored as gzip files. `P19-FINAL-LOG-IDENTITIES.json` binds each decompressed file and archive to its SHA-256. Decompress beside the archive to recover the original paths cited by reviews.

The sixteen mutation runs retain their actual manifests, results, SPECs and control/mutant logs. Their thirty identical captured source/config inputs already exist byte-for-byte in published commits: `P19-MUTATION-PUBLISHED-INPUTS.json` gives the exact Git commit and path for each. This avoids publishing duplicate source trees or generated variants; it does not change the original worktree provenance or execution dates.

Native thought streams are not publication artifacts. Requested/reported model identities and terminal outcomes are preserved in the process records.
