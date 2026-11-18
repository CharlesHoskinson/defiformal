# Upstream maintainer handover

This handover covers the `competitive-landscape-adoption` contribution from
[stefan-contiu/defiformal](https://github.com/stefan-contiu/defiformal) to
[CharlesHoskinson/defiformal](https://github.com/CharlesHoskinson/defiformal).
Target `semantic-kernel-pivot`. These are integration instructions, not a record
of an upstream merge, CI run or release. The separate validation change remains
out of scope.

## CI approval and settings

The [Lean workflow](../.github/workflows/lean.yml) runs on pull requests targeting
`semantic-kernel-pivot` and pushes to that branch. It uses GitHub-hosted Ubuntu,
the pinned Lean dependencies, `contents: read`, and no repository secrets. It
builds the project, audits the imported kernel and runs the audit failure
controls. It does not publish releases or run every evidence script.

An upstream maintainer should:

1. Confirm Actions is enabled and permits the pinned `actions/checkout` and
   `leanprover/lean-action` actions in the workflow. Repository settings do not
   transfer with the PR.
2. Review and approve the fork workflow run if GitHub requests approval. The
   contributor's read-only upstream access cannot supply that approval.
3. Require a successful upstream PR run against the proposed merge result and
   a successful push run after integration. Record their exact revisions and
   URLs separately from the fork's CI evidence.
4. Configure a required status check through branch protection or a ruleset if
   desired; adding the workflow file alone does not enforce a merge gate.

The existing `pull_request` workflow needs neither write permission nor secrets.
Keep that permission boundary when approving it. See GitHub's
[fork workflow settings](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository)
and [pull request event behavior](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#pull_request).

## Merge history and evidence

Prefer a normal merge that preserves the contributed commits. Some evidence
checks inspect those commits directly: for example,
[`check_capability_corrections.py`](../scripts/check_capability_corrections.py)
uses `git show` on the original ShareQuote introduction commit. Run such checks
from a full-history checkout; a shallow checkout may lack the required objects.
The current Lean CI does not run that history-dependent correction checker.

If upstream requires squash or rebase merging, agree how the original history
will remain retrievable and how to fetch it before running those checks. An
ordinary clone of the squashed branch may not contain the referenced commits.
Do not replace historical hashes with the new merge or squash hash: they bind
the actual reviewed source and artifacts.

Keep frozen reports, review identities, publication receipts and original URLs
unchanged. Add new upstream integration records. The
[accepted grade corrections](research/competitive-landscape-2026-11/capability-grade-corrections-2026-11-18.md)
state the current scoped capability claims; the original reports remain dated
evidence.

## Upstream release publication

Merging the PR transfers repository files, not the fork's tags, GitHub releases
or uploaded assets. The current workflow contains no release-publishing job.
Creating an upstream release and uploading assets requires an authorized
maintainer or automation with the necessary write permissions; read-only
upstream access is insufficient. See GitHub's
[release permissions](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository).

The existing [v0.16.0 publication receipt](evidence/compiled-margin-close-macos-arm64/publication.json)
identifies the fork's archive and its source revision. Choose one publication path:

- Retain the fork-hosted downloads as historical evidence and link to them
  explicitly. Their availability continues to depend on the fork.
- Mirror the exact reviewed archive upstream: verify its existing checksum,
  preserve its embedded source identity and clearly describe it as that original
  artifact. Publish a new upstream receipt recording the actual tag, source
  relationship, asset URLs and hashes; do not relabel it as a build of the merge.
- Build a new package for the integrated upstream revision using the
  [assembly and replay instructions](../tools/compiled-evidence/README.md).
  Verify and review the new archive, then publish it with its own source, runtime,
  checksum and replay records. The builder expects an already built checkout;
  it does not rebuild source for you.

Choose an available upstream tag deliberately; no existing fork tag is created
by the PR. Verify the downloaded upstream assets after publication. Existing
archives and the current builder/replay path support macOS arm64; the Ubuntu CI
source build does not provide a Linux compiled package. Preserve license notices
and the distinction between engineering replay and actual outside reproduction.
