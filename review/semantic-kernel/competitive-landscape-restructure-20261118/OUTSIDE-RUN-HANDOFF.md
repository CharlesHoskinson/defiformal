# Outside reproduction handoff

Status: prepared instructions, no participant or completed outside run recorded.
Do not count this document as task 3.1 or 4.1 evidence. One outside developer may
perform both procedures; record each separately and disclose all assistance.

## P18 procedure (validation 3.1)

Use repository revision `cd2f8ef5409c7e79a47e069738922858b5947409` and follow
`examples/platform-increment/README.md` at that revision. Record host OS/architecture,
prerequisites and existing caches before starting. Measure setup elapsed time from
starting acquisition/setup until the example can be invoked, and record any waits
or interruptions separately. Preserve commands, stdout/stderr and exit statuses.
The README describes environment binding and the twelve-observation token0 run.
Record its actual outcome; a failed or abandoned attempt with diagnostics and
measured setup time satisfies the attempt-record criterion, not successful reproduction.
Historical limitations in that pinned README remain part of the supplied document.

## Compiled-only procedure (validation 4.1)

Use the v0.16.0 asset:

https://github.com/stefan-contiu/defiformal/releases/download/v0.16.0/defiformal-evidence-11197ef1-margin-close-macos-arm64.tar.gz

Archive SHA-256: `bc3a7aa0d31affc96d2e38525427c5de9395bf21138a35f4dfd815736b3da265`.
Size: 612087096 bytes. This is the macOS arm64 package, with its pinned bundled
Lean runtime. A participant needs a compatible host and the prerequisites stated
inside the archive. Obtain the published checksum file from the same release,
verify the archive and follow its contained README/replay instructions from a
fresh extraction. Keep this run separate from any P18 source checkout/build cache.
Do not supply additional undocumented build instructions or private dependencies.
Record missing prerequisites or instructions as actual setup problems.

Record acquisition/setup elapsed time separately from replay elapsed time, retain
all output and confirm the actual selected-module denominator. A successful result
must match the package's recorded 43-target replay. Missing/blocked/failed results
remain evidence and leave task 4.1 open. Package replay uses the same Lean kernel
and trusted imports; it does not rerun source-level finite assertions.

## Record fields for each actual participant/run

- Participant's stated role and basis for being outside the project; no private
  contact details are needed in the repository.
- Date, exact source/README or release/archive identities, environment and
  pre-existing prerequisites/caches.
- Timestamped start/end and explicit timing method for setup and execution;
  interruptions and assistance, including whether assistance changed the procedure.
- Commands, exit codes, complete relevant stdout/stderr with hashes, actual outcome
  and encountered problems. Preserve failed attempts when repairs are tried.
- Participant confirmation of their own record and independent evidence review.

An agent or maintainer cannot fill the participant role. No invitations have been
sent. Recruitment and external communication need explicit authorization.
