Focused remediation review of Sprint4 verification at final source revision 76c99e44689fcdd3422d998f4b82cf2f8e794c57. Prior foundation/executor/library/evidence native Grok and Fable reviews all accepted with limitations; this scope closes actionable evidence findings. Use only supplied bundle, no skills/tools/other files/web. If prompt offloaded read only prompt file. Return <=650words: ACCEPT / ACCEPT WITH LIMITATIONS / REQUEST CHANGES with any remaining concrete blocking issue. Do not claim independent execution.

Changes: added actual exit1 controls for a required-false observation that remains true and for a protected positive that flips; both produce expected distinct FAIL messages.17/17 real CLI controls pass. Harness now creates its own temporary Git repository instead of sharing source index metadata. Typing-positive error regex now recognizes tagged Lean diagnostics; real positive and3 typing-refusals rerun successfully. Mutation runner itself and ALL Lean sources unchanged:24mutants still bound to the same accepted bytes. No source test/code changes beyond supplied diff.

Git-binding finding closed by candidate-binding.json: actual git rev-parse REV:path and git cat-file blob for every relevant recorded SHA256; reports Git object IDs and computed hashes. Build verification relabels source_revision as execution_start_revision (3a44e4e), and supplies actual verified_input_candidate1c1485b. Its whole recorded map matches that commit; ALL Lean build inputs also match final76c99e4. The only later changes are two Python scripts, separately retested with recorded hashes tied to76c99e4. Mutation and typing source maps and both runner/harness hashes also checked against final committed blobs. Working-tree SHA equality is additionally checked, not substituted for commit binding. Raw original records kept as .initial.json; no hidden rerun claim.

Mutation toolchain version+executable SHA are now included from original source-manifest in summary. Full189 named control map,34/37/48/70 split, recorded full-build1005jobs, typed524/978 audit, old278/234audit,33+43runtime and99old audit controls are included as machine records or exact excerpts below. Actual individual mutation logs were read, their hashes matched recorded run records,189 names parsed, sole expected error lines validated and required falses/protected positives rechecked; extracted lines/hashes below. Native review remains advisory; actual checks were run by stock Codex GPT6. All reference examples are development-only, exact rational/net-effect/trusted-adapter scope; no deployed fidelity/composition/claim-lifecycle/owner-consent or refused-path confidentiality claim.


===== exact remediation diff =====
diff --git a/scripts/check_typed_kernel_typing.py b/scripts/check_typed_kernel_typing.py
index 3c2c6e4..16e167b 100644
--- a/scripts/check_typed_kernel_typing.py
+++ b/scripts/check_typed_kernel_typing.py
@@ -9,6 +9,7 @@ import argparse
 import hashlib
 import json
 from pathlib import Path
+import re
 import subprocess
 import sys
 
@@ -68,7 +69,8 @@ abbrev E := Expr Bool Bool Bool []
                                 'log_sha256': digest(out / (name + '.log'))}
         (out / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
         if name == 'positive':
-            if proc.returncode != 0 or 'typing_positive: true' not in log or ': error:' in log:
+            if (proc.returncode != 0 or 'typing_positive: true' not in log or
+                    re.search(r': error(?:\([^)]*\))?:', log)):
                 raise RuntimeError('positive typing control failed')
         else:
             assert proc.returncode != 0, f'{name}: deliberately ill-typed expression accepted'
diff --git a/scripts/test_typed_kernel_mutation_runner.py b/scripts/test_typed_kernel_mutation_runner.py
index 77445b3..a215b9c 100644
--- a/scripts/test_typed_kernel_mutation_runner.py
+++ b/scripts/test_typed_kernel_mutation_runner.py
@@ -2,7 +2,7 @@
 """Exercise the mutation runner's CLI against real temporary Lean computations.
 
 No subprocess is mocked. The temporary repository links installed dependency packages
-and reads the source repository's git metadata. All fixtures/logs stay outside the
+and has its own isolated git metadata. All fixtures/logs stay outside the
 source repository. Exit 0 means every nonempty control has the expected classification;
 exit 1 means an observed classification differs; exit 3 means the harness could not run.
 """
@@ -82,6 +82,12 @@ def cases():
          'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
         {'name': 'all-true-mutant', 'exit': 1, 'spec': specification(mutation(replacement='n ≤ 3')),
          'message': 'all comparisons still pass under mutation'},
+        {'name': 'required-observation-stays-true', 'exit': 1,
+         'spec': specification(mutation(required=['runner_positive'])),
+         'message': 'required mutation not detected'},
+        {'name': 'positive-control-flipped', 'exit': 1,
+         'spec': specification(mutation(replacement='n == 5')),
+         'message': 'positive control failed'},
         {'name': 'compilation-only-failure', 'exit': 3,
          'spec': specification(mutation('-- compiler-control', '#check runnerUndefinedConstant')),
          'message': 'failure is not solely the expected runtime comparison failure'},
@@ -152,12 +158,19 @@ def main():
     lean_version = identify('lean-version', ['lake', 'env', 'lean', '--version'])
     lean_path = Path(identify('lean-path', ['lake', 'env', 'which', 'lean']))
     git_head = identify('git-head', ['git', 'rev-parse', 'HEAD'])
-    git_dir = Path(identify('git-directory', ['git', 'rev-parse', '--absolute-git-dir']))
     fake = out / 'fixture-repo'
     lean = fake / 'lean'
     typed = lean / 'DefiKernel/Typed'
     typed.mkdir(parents=True)
-    (fake / '.git').write_text(f'gitdir: {git_dir}\n')
+    # Independent metadata prevents even optional index refreshes in the source repo.
+    for command in [
+        ['git', 'init', '--quiet', str(fake)],
+        ['git', '-C', str(fake), '-c', 'user.name=DeFiFormal fixture',
+         '-c', 'user.email=fixture@invalid', 'commit', '--allow-empty', '--quiet',
+         '-m', 'Initialize isolated mutation-runner fixture'],
+    ]:
+        proc = subprocess.run(command, text=True, capture_output=True, timeout=60)
+        require(proc.returncode == 0, f'isolated fixture git setup failed: {proc.stderr}')
     (lean / '.lake').mkdir()
     # Reuse dependency packages, never the source project's .lake/build directory.
     (lean / '.lake/packages').symlink_to(repo / 'lean/.lake/packages', target_is_directory=True)


===== candidate-binding.json =====
{
  "schema_version": 1,
  "source_candidate": "76c99e44689fcdd3422d998f4b82cf2f8e794c57",
  "method": "Actual git rev-parse REV:path and git cat-file blob OBJECT, SHA256 computed over returned blob bytes and compared with recorded evidence.",
  "source_blobs": {
    "lean/DefiKernel/Typed/Acceptance.lean": {
      "git_blob": "6215aed9b4efb5354af401504e4bf9d7ba39cd2a",
      "sha256": "4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1",
      "working_tree_matches": true
    },
    "lean/DefiKernel/Typed/Audit.lean": {
      "git_blob": "c9e2a259936ed139599b35d4ed1467a54f67e460",
      "sha256": "20ffa1753cf50ef5b60dec0d8bb6950c2b9f623011df23c7c0d8a542aeaeb3c4",
      "working_tree_matches": true
    },
    "lean/DefiKernel/Typed/Authority.lean": {
      "git_blob": "f7fb9de0cb97cc9e003bf487d742ec902250efc9",
      "sha256": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
      "working_tree_matches": true
    },
    "lean/DefiKernel/Typed/AuthorityTests.lean": {
      "git_blob": "0565fc81a0625e064ee560613408356bac7c4cda",
      "sha256": "02c7028ade18e53815d436f57fc3c80cd79c06dc585a3e985b1be8dab544ae77",
      "working_tree_matches": true
    },
    "lean/DefiKernel/Typed/Examples.lean": {
      "git_blob": "5094c617948dc2955e6662009fe621b47edc6417",
      "sha256": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
      "working_tree_matches": true
    },
    "lean/DefiKernel/Typed/Expr.lean": {
      "git_blob": "4142a771422ee0d74aad24f5c9f7101db0d27195",
      "sha256": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
      "working_tree_matches": true
    },
    "lean/DefiKernel/Typed/ExprTests.lean": {
      "git_blob": "f101da3b78d9cdf473377b406cac58bc836a4588",
      "sha256": "8fd89353f21e5f3f94f1ed56ae6d1e28d375952b5720ed9e29c177e4a4e88e29",
      "working_tree_matches": true
    },
    "lean/DefiKernel/Typed/Transition.lean": {
      "git_blob": "344109d8e783c2b80f1385fa39f0a4b923b0d07c",
      "sha256": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
      "working_tree_matches": true
    },
    "lean/DefiKernel/Typed/TransitionTests.lean": {
      "git_blob": "09ecdc3ee7b659eb08be15701a76595ec3c8b18d",
      "sha256": "e9d3af4f0d81c9ab76ab20e0440228c30c6dcf54f5e80ccd32117f4c961561bc",
      "working_tree_matches": true
    },
    "lean/DefiKernel/Typed/Types.lean": {
      "git_blob": "fd5c617ee1c7b7ff56092218e55b0c3ce2ac1da8",
      "sha256": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
      "working_tree_matches": true
    },
    "lean/DefiKernel/Typed/Verify.lean": {
      "git_blob": "c0bc41f3703eb6e26ef62c9da6b0282166e19504",
      "sha256": "2f8fc6cb7202a70d2438dad6d665edcccc3fec47add99087284b03b9b30f8d8d",
      "working_tree_matches": true
    },
    "lean/DefiKernel.lean": {
      "git_blob": "1f0b262cf4ea5b3812ea70c4fa17fd236df229ec",
      "sha256": "0ff4580a1bf16942c351d170d5322f7e9c65790dc5cd1978282b40b5268835c2",
      "working_tree_matches": true
    },
    "lean/DefiKernel/AxiomAudit.lean": {
      "git_blob": "32032f9638d0f934ebfa9b4b6de6c475d8b4237d",
      "sha256": "4a8e330d42e7cd1c46df96ee201923ba2f5d17f37a74b2cb262c318193e72524",
      "working_tree_matches": true
    },
    "lean/lean-toolchain": {
      "git_blob": "c084c7fbe586b0276863b66f16d2955a43bc3fc6",
      "sha256": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
      "working_tree_matches": true
    },
    "lean/lakefile.toml": {
      "git_blob": "3bf93ee79697e086fda3a57b2fb7df069c25eb3c",
      "sha256": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86",
      "working_tree_matches": true
    },
    "lean/lake-manifest.json": {
      "git_blob": "51fea05cf51f6ff04ca93c5a8d8d40c12d4334b1",
      "sha256": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002",
      "working_tree_matches": true
    },
    "scripts/check_typed_kernel_mutations.py": {
      "git_blob": "5c2db9a6294d5a8de66f23686d282a26780a9915",
      "sha256": "f988c2a1c10dce1b3b0c13caf92e9de0138c4985fa2fce7f1538ab1ca758dc50",
      "working_tree_matches": true
    },
    "scripts/test_typed_kernel_mutation_runner.py": {
      "git_blob": "a215b9cc55c2ee2ca3d0fd72385bfebda7ea435b",
      "sha256": "921457f86eba3e0f8e6fec1250a1a0745fd56fb717074d6db61b2bb1cfa8dd93",
      "working_tree_matches": true
    },
    "scripts/check_typed_kernel_typing.py": {
      "git_blob": "16e167b5d1d230bd004d8152552c239d7f00bc1d",
      "sha256": "f85c32ae261c19fe6f7c2253328f7ea4689e942fc8fd91c79e63d2e9bebe7fb6",
      "working_tree_matches": true
    },
    "scripts/test_kernel_axiom_audit.py": {
      "git_blob": "84d1bebfd92bec4c804fe3e7a2fe9f54650bfa1b",
      "sha256": "b40c73684a40e0cadabf45c29e55e19861614a4e6ba975cacbf8f18d81966c5b",
      "working_tree_matches": true
    }
  },
  "evidence_bindings": [
    {
      "component": "full-build",
      "verified_source_candidate": "1c1485bea152fadbd3be5bdd4d07a35c0d07ec2f",
      "all_recorded_hashes_match_commit": true,
      "blobs": {
        "lean/DefiKernel/Typed/Acceptance.lean": {
          "git_blob": "6215aed9b4efb5354af401504e4bf9d7ba39cd2a",
          "sha256": "4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1"
        },
        "lean/DefiKernel/Typed/Audit.lean": {
          "git_blob": "c9e2a259936ed139599b35d4ed1467a54f67e460",
          "sha256": "20ffa1753cf50ef5b60dec0d8bb6950c2b9f623011df23c7c0d8a542aeaeb3c4"
        },
        "lean/DefiKernel/Typed/Authority.lean": {
          "git_blob": "f7fb9de0cb97cc9e003bf487d742ec902250efc9",
          "sha256": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb"
        },
        "lean/DefiKernel/Typed/AuthorityTests.lean": {
          "git_blob": "0565fc81a0625e064ee560613408356bac7c4cda",
          "sha256": "02c7028ade18e53815d436f57fc3c80cd79c06dc585a3e985b1be8dab544ae77"
        },
        "lean/DefiKernel/Typed/Examples.lean": {
          "git_blob": "5094c617948dc2955e6662009fe621b47edc6417",
          "sha256": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41"
        },
        "lean/DefiKernel/Typed/Expr.lean": {
          "git_blob": "4142a771422ee0d74aad24f5c9f7101db0d27195",
          "sha256": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed"
        },
        "lean/DefiKernel/Typed/ExprTests.lean": {
          "git_blob": "f101da3b78d9cdf473377b406cac58bc836a4588",
          "sha256": "8fd89353f21e5f3f94f1ed56ae6d1e28d375952b5720ed9e29c177e4a4e88e29"
        },
        "lean/DefiKernel/Typed/Transition.lean": {
          "git_blob": "344109d8e783c2b80f1385fa39f0a4b923b0d07c",
          "sha256": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2"
        },
        "lean/DefiKernel/Typed/TransitionTests.lean": {
          "git_blob": "09ecdc3ee7b659eb08be15701a76595ec3c8b18d",
          "sha256": "e9d3af4f0d81c9ab76ab20e0440228c30c6dcf54f5e80ccd32117f4c961561bc"
        },
        "lean/DefiKernel/Typed/Types.lean": {
          "git_blob": "fd5c617ee1c7b7ff56092218e55b0c3ce2ac1da8",
          "sha256": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82"
        },
        "lean/DefiKernel/Typed/Verify.lean": {
          "git_blob": "c0bc41f3703eb6e26ef62c9da6b0282166e19504",
          "sha256": "2f8fc6cb7202a70d2438dad6d665edcccc3fec47add99087284b03b9b30f8d8d"
        },
        "lean/DefiKernel.lean": {
          "git_blob": "1f0b262cf4ea5b3812ea70c4fa17fd236df229ec",
          "sha256": "0ff4580a1bf16942c351d170d5322f7e9c65790dc5cd1978282b40b5268835c2"
        },
        "scripts/check_typed_kernel_mutations.py": {
          "git_blob": "5c2db9a6294d5a8de66f23686d282a26780a9915",
          "sha256": "f988c2a1c10dce1b3b0c13caf92e9de0138c4985fa2fce7f1538ab1ca758dc50"
        },
        "scripts/check_typed_kernel_typing.py": {
          "git_blob": "3c2c6e48dbfff6a2714c2dd341d1a6d6e94f6f63",
          "sha256": "98392920c32379721b56aee8ddb57313e5ef87fee76f76bf4c4c077cf74e2edc"
        },
        "scripts/test_typed_kernel_mutation_runner.py": {
          "git_blob": "77445b3259503e0e49b950e8674b5d31706e9f0a",
          "sha256": "fa82c057ec746a28ffa3eb4be907823f39c81def38261e7db55068b3f50a4f06"
        }
      }
    },
    {
      "component": "mutations",
      "verified_source_candidate": "76c99e44689fcdd3422d998f4b82cf2f8e794c57",
      "all_recorded_hashes_match_commit": true,
      "blobs": {
        "lean/DefiKernel/Typed/Types.lean": {
          "git_blob": "fd5c617ee1c7b7ff56092218e55b0c3ce2ac1da8",
          "sha256": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82"
        },
        "lean/DefiKernel/Typed/Expr.lean": {
          "git_blob": "4142a771422ee0d74aad24f5c9f7101db0d27195",
          "sha256": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed"
        },
        "lean/DefiKernel/Typed/Authority.lean": {
          "git_blob": "f7fb9de0cb97cc9e003bf487d742ec902250efc9",
          "sha256": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb"
        },
        "lean/DefiKernel/Typed/Transition.lean": {
          "git_blob": "344109d8e783c2b80f1385fa39f0a4b923b0d07c",
          "sha256": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2"
        },
        "lean/DefiKernel/Typed/ExprTests.lean": {
          "git_blob": "f101da3b78d9cdf473377b406cac58bc836a4588",
          "sha256": "8fd89353f21e5f3f94f1ed56ae6d1e28d375952b5720ed9e29c177e4a4e88e29"
        },
        "lean/DefiKernel/Typed/AuthorityTests.lean": {
          "git_blob": "0565fc81a0625e064ee560613408356bac7c4cda",
          "sha256": "02c7028ade18e53815d436f57fc3c80cd79c06dc585a3e985b1be8dab544ae77"
        },
        "lean/DefiKernel/Typed/TransitionTests.lean": {
          "git_blob": "09ecdc3ee7b659eb08be15701a76595ec3c8b18d",
          "sha256": "e9d3af4f0d81c9ab76ab20e0440228c30c6dcf54f5e80ccd32117f4c961561bc"
        },
        "lean/DefiKernel/Typed/Examples.lean": {
          "git_blob": "5094c617948dc2955e6662009fe621b47edc6417",
          "sha256": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41"
        },
        "lean/DefiKernel/Typed/Acceptance.lean": {
          "git_blob": "6215aed9b4efb5354af401504e4bf9d7ba39cd2a",
          "sha256": "4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1"
        },
        "lean/DefiKernel/Typed/Audit.lean": {
          "git_blob": "c9e2a259936ed139599b35d4ed1467a54f67e460",
          "sha256": "20ffa1753cf50ef5b60dec0d8bb6950c2b9f623011df23c7c0d8a542aeaeb3c4"
        },
        "lean/lean-toolchain": {
          "git_blob": "c084c7fbe586b0276863b66f16d2955a43bc3fc6",
          "sha256": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6"
        },
        "lean/lake-manifest.json": {
          "git_blob": "51fea05cf51f6ff04ca93c5a8d8d40c12d4334b1",
          "sha256": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002"
        },
        "lean/lakefile.toml": {
          "git_blob": "3bf93ee79697e086fda3a57b2fb7df069c25eb3c",
          "sha256": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86"
        },
        "scripts/check_typed_kernel_mutations.py": {
          "git_blob": "5c2db9a6294d5a8de66f23686d282a26780a9915",
          "sha256": "f988c2a1c10dce1b3b0c13caf92e9de0138c4985fa2fce7f1538ab1ca758dc50"
        }
      }
    },
    {
      "component": "typing",
      "verified_source_candidate": "76c99e44689fcdd3422d998f4b82cf2f8e794c57",
      "all_recorded_hashes_match_commit": true,
      "blobs": {
        "lean/DefiKernel/Typed/Types.lean": {
          "git_blob": "fd5c617ee1c7b7ff56092218e55b0c3ce2ac1da8",
          "sha256": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82"
        },
        "lean/DefiKernel/Typed/Expr.lean": {
          "git_blob": "4142a771422ee0d74aad24f5c9f7101db0d27195",
          "sha256": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed"
        },
        "lean/lean-toolchain": {
          "git_blob": "c084c7fbe586b0276863b66f16d2955a43bc3fc6",
          "sha256": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6"
        },
        "lean/lakefile.toml": {
          "git_blob": "3bf93ee79697e086fda3a57b2fb7df069c25eb3c",
          "sha256": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86"
        },
        "lean/lake-manifest.json": {
          "git_blob": "51fea05cf51f6ff04ca93c5a8d8d40c12d4334b1",
          "sha256": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002"
        },
        "scripts/check_typed_kernel_typing.py": {
          "git_blob": "16e167b5d1d230bd004d8152552c239d7f00bc1d",
          "sha256": "f85c32ae261c19fe6f7c2253328f7ea4689e942fc8fd91c79e63d2e9bebe7fb6"
        }
      }
    },
    {
      "component": "runner-controls",
      "verified_source_candidate": "76c99e44689fcdd3422d998f4b82cf2f8e794c57",
      "all_recorded_hashes_match_commit": true,
      "blobs": {
        "scripts/check_typed_kernel_mutations.py": {
          "git_blob": "5c2db9a6294d5a8de66f23686d282a26780a9915",
          "sha256": "f988c2a1c10dce1b3b0c13caf92e9de0138c4985fa2fce7f1538ab1ca758dc50"
        },
        "scripts/test_typed_kernel_mutation_runner.py": {
          "git_blob": "a215b9cc55c2ee2ca3d0fd72385bfebda7ea435b",
          "sha256": "921457f86eba3e0f8e6fec1250a1a0745fd56fb717074d6db61b2bb1cfa8dd93"
        }
      }
    }
  ],
  "all_final_lean_build_inputs_unchanged": true,
  "scope": "Build snapshot includes earlier harness/typing scripts as incidental snapshots; those scripts are separately retested after review. Lean bytes and mutation runner are unchanged. Historical execution-start HEAD fields are retained, not treated as code identity."
}


===== final-verification.json =====
{
  "schema_version": 1,
  "source_candidate": "76c99e44689fcdd3422d998f4b82cf2f8e794c57",
  "source_sha256": {
    "lean/DefiKernel/Typed/Acceptance.lean": "4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1",
    "lean/DefiKernel/Typed/Audit.lean": "20ffa1753cf50ef5b60dec0d8bb6950c2b9f623011df23c7c0d8a542aeaeb3c4",
    "lean/DefiKernel/Typed/Authority.lean": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
    "lean/DefiKernel/Typed/AuthorityTests.lean": "02c7028ade18e53815d436f57fc3c80cd79c06dc585a3e985b1be8dab544ae77",
    "lean/DefiKernel/Typed/Examples.lean": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
    "lean/DefiKernel/Typed/Expr.lean": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
    "lean/DefiKernel/Typed/ExprTests.lean": "8fd89353f21e5f3f94f1ed56ae6d1e28d375952b5720ed9e29c177e4a4e88e29",
    "lean/DefiKernel/Typed/Transition.lean": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
    "lean/DefiKernel/Typed/TransitionTests.lean": "e9d3af4f0d81c9ab76ab20e0440228c30c6dcf54f5e80ccd32117f4c961561bc",
    "lean/DefiKernel/Typed/Types.lean": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
    "lean/DefiKernel/Typed/Verify.lean": "2f8fc6cb7202a70d2438dad6d665edcccc3fec47add99087284b03b9b30f8d8d",
    "lean/DefiKernel.lean": "0ff4580a1bf16942c351d170d5322f7e9c65790dc5cd1978282b40b5268835c2",
    "lean/DefiKernel/AxiomAudit.lean": "4a8e330d42e7cd1c46df96ee201923ba2f5d17f37a74b2cb262c318193e72524",
    "lean/lean-toolchain": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
    "lean/lakefile.toml": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86",
    "lean/lake-manifest.json": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002",
    "scripts/check_typed_kernel_mutations.py": "f988c2a1c10dce1b3b0c13caf92e9de0138c4985fa2fce7f1538ab1ca758dc50",
    "scripts/test_typed_kernel_mutation_runner.py": "921457f86eba3e0f8e6fec1250a1a0745fd56fb717074d6db61b2bb1cfa8dd93",
    "scripts/check_typed_kernel_typing.py": "f85c32ae261c19fe6f7c2253328f7ea4689e942fc8fd91c79e63d2e9bebe7fb6",
    "scripts/test_kernel_axiom_audit.py": "b40c73684a40e0cadabf45c29e55e19861614a4e6ba975cacbf8f18d81966c5b"
  },
  "full_build": {
    "exit": 0,
    "jobs": 1005,
    "evidence": "build-verification.json"
  },
  "typed_runtime": {
    "executed": 189,
    "passed": 189,
    "by_module": {
      "expr": 34,
      "authority": 37,
      "transition": 48,
      "reference": 70
    }
  },
  "legacy_runtime": {
    "legacy-runtime": 33,
    "legacy-contract-runtime": 43
  },
  "typed_imported_audit": {
    "theorems": 524,
    "supplemental": 978,
    "forbidden": 0
  },
  "legacy_imported_audit": {
    "theorems": 278,
    "supplemental": 234,
    "forbidden": 0
  },
  "named_proof_inventory": 52,
  "mutation_campaign": {
    "mutants": 24,
    "detected": 24,
    "comparisons_per_run": 189,
    "control": 1,
    "protected_positives": 3,
    "evidence": "mutations/summary.json"
  },
  "mutation_runner_controls": {
    "executed": 17,
    "passed": 17,
    "evidence": "mutation-runner-controls.json"
  },
  "existing_axiom_controls": {
    "assertions": 99,
    "passed": 99,
    "evidence": "axiom-controls/results.json"
  },
  "typing": {
    "positive": 1,
    "expected_type_refusals": 3,
    "evidence": "typing/results.json"
  },
  "proof_source_scan": {
    "no_sorry_admit_native_decide_custom_axiom": true,
    "scope": "lean/DefiKernel/Typed/*.lean"
  },
  "preservation": "preservation.json",
  "review_status": "All four native review scopes accepted with limitations; focused evidence-remediation review pending.",
  "limits": [
    "Exact rational, finite-carrier, net-effect semantics; no deployed protocol fidelity or machine refinement.",
    "Trusted registry/admin/store/context and observation truth; no signature verification or separate debit owner consent.",
    "Successful expression-read/write/domain conditions, not refused-path confidentiality or full operation noninterference.",
    "No composition, claim lifecycle, allowances, replay protection or general solvency claim."
  ],
  "candidate_binding": "candidate-binding.json"
}


===== typing/results.json =====
{
  "script_sha256": "f85c32ae261c19fe6f7c2253328f7ea4689e942fc8fd91c79e63d2e9bebe7fb6",
  "sources": {
    "lean/DefiKernel/Typed/Types.lean": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
    "lean/DefiKernel/Typed/Expr.lean": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
    "lean/lean-toolchain": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
    "lean/lakefile.toml": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86",
    "lean/lake-manifest.json": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002"
  },
  "runs": {
    "positive": {
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/defiformal-sprint4-typing-reviewed/positive.lean"
      ],
      "exit": 0,
      "fixture_sha256": "8d95cce34f1284e5c2c8738d19a5420c817ea1bce797b2fff9fbaedf3d9803d9",
      "log_sha256": "3d256bd4f0f7b201507a165cb13a7dbf22a10267edda4a4153a99881cf19e505"
    },
    "mixed-assets": {
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/defiformal-sprint4-typing-reviewed/mixed-assets.lean"
      ],
      "exit": 1,
      "fixture_sha256": "b673901f3e58e781085d4205c464f975d00464a2762b96867ae4196c238ae031",
      "log_sha256": "cd32813b70f5ad0b9e904751652b71793cd2c80cb536004e88a699788fd2492c"
    },
    "reversed-price": {
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/defiformal-sprint4-typing-reviewed/reversed-price.lean"
      ],
      "exit": 1,
      "fixture_sha256": "8234c91c69c89f689b3f8fbcb295d98d4b4d89f59fea2c893bc39851cfe5e616",
      "log_sha256": "635b21fb5c32b59e2dacc0f9e42a5fe753dfd95469d6a79712ea5022557f75f1"
    },
    "implicit-debt-conversion": {
      "command": [
        "lake",
        "env",
        "lean",
        "/tmp/defiformal-sprint4-typing-reviewed/implicit-debt-conversion.lean"
      ],
      "exit": 1,
      "fixture_sha256": "33bc7d8d5aeb997b541cfd472dcb28414071acc40bd7ccab1b0b6a1db4b89aea",
      "log_sha256": "15a9faedbd7a28a8820d3fd6659ef91be8a84ac4acfe7087cd360dbaa252432d"
    }
  },
  "git_head": "1c1485bea152fadbd3be5bdd4d07a35c0d07ec2f",
  "lean_version": "Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)",
  "lean_executable_sha256": "e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550",
  "input_sources_unchanged": true,
  "scope": "One executed positive and three compiler-rejected unit mismatches; no financial counterexample claim."
}


===== mutations/log-validation.json =====
[
  {
    "variant": "control",
    "exit": 0,
    "comparison_count": 189,
    "log_sha256": "19ecc53feba3fbe993b6f2fed294efb170716f6b5a555a4d34bd1bad7f05af1e",
    "compiler_error_lines": [],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "admin-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "20c20b7305ffb1a35b79c6ccd876d18e2ac700436c658a6998b007f88b34f5ae",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/admin-bypass.lean:1647:0: error: Typed runtime comparisons failed: 6"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "holder-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "8233db7f3a9f01ff76793c27fd5ba053e063182a3bfa00a6fca6e31fbe0b49e0",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/holder-bypass.lean:1647:0: error: Typed runtime comparisons failed: 3"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "live-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "273c2c55a08a00afd4f3bddff26eb6019ed02c2245740dbb98806e94530e18b8",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/live-bypass.lean:1647:0: error: Typed runtime comparisons failed: 7"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "cap-domain-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "faae11f48aa4b1d142c2c14d33654c437adccbaea04a8fb071a4c261384158de",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/cap-domain-bypass.lean:1647:0: error: Typed runtime comparisons failed: 2"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "cap-operation-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "0daf5c8d48c2b9960c152986c037526dbd13ae49658dff97116ada572071daec",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/cap-operation-bypass.lean:1647:0: error: Typed runtime comparisons failed: 6"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "cap-resource-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "2366fb3aae958d37bede2e14da669ed8d34d48843f39649058d9ee51306ee557",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/cap-resource-bypass.lean:1647:0: error: Typed runtime comparisons failed: 16"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "revoke-noop",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "c6b0ba1e9e7f2eaf3924eb75c2983bc0703661dfa5fcf93947b79894f437dea1",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/revoke-noop.lean:1647:0: error: Typed runtime comparisons failed: 10"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "invoke-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "8d0c7a940c18243327651796bc6bed5665d65a807143ef5e9238806149a95c96",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/invoke-bypass.lean:1647:0: error: Typed runtime comparisons failed: 7"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "guard-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "575c5516eb8d1835fbd758b85872463ea00554371693b23fe70bd6eb4f3f313e",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/guard-bypass.lean:1647:0: error: Typed runtime comparisons failed: 13"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "state-read-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "7b192983da3ff5ef37f534621aa6fea1030e20d42dfbc0601b38ddfd34f66ebf",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/state-read-bypass.lean:1647:0: error: Typed runtime comparisons failed: 6"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "env-read-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "7c9f63635a8e0a8ae4e0e31c45f65e142258b010bdd4e317660a4c6845892b79",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/env-read-bypass.lean:1647:0: error: Typed runtime comparisons failed: 4"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "domain-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "4edd28df57879cccdac79d720c70f277992ae7d6236d9ad4de19bc5fb3b3f13b",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/domain-bypass.lean:1647:0: error: Typed runtime comparisons failed: 3"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "debit-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "9e4376a15d3838a7866d91e71136c1070c97bca1d3b817247328c6a3d81b5226",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/debit-bypass.lean:1647:0: error: Typed runtime comparisons failed: 4"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "supply-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "a0d348dde891f1173d5bd7daec39d47975551bb05111472a3ebe1c068febe0eb",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/supply-bypass.lean:1647:0: error: Typed runtime comparisons failed: 3"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "accounting-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "a8bf1d1380b483df283dd933b3357f5f1c9d2678882e7224219bc4e597d26846",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/accounting-bypass.lean:1647:0: error: Typed runtime comparisons failed: 5"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "write-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "daf189516137e9da8d2570bc5944f28d307f4e1a9412389d272089d8b24cec06",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/write-bypass.lean:1647:0: error: Typed runtime comparisons failed: 2"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "registry-selection",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "74a38079215d909da6eacdd5ebc7dbad2ed3f0805fe141c092715224f039ac98",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/registry-selection.lean:1647:0: error: Typed runtime comparisons failed: 38"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "zero-division-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "fa79f24cdc74d0498e929d94082b0b3139283d944ce344a3b760758ab5d589cd",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/zero-division-bypass.lean:1647:0: error: Typed runtime comparisons failed: 2"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "inactive-state-read-omission",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "badb629bf3fadabc627106f6abfb2becac9c8c80709b7aa84d5af9f59d288103",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/inactive-state-read-omission.lean:1647:0: error: Typed runtime comparisons failed: 3"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "supply-first-only",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "420bad3b1e5346842df0b755ffbba764ae2e976fcbcb0bdc2d9348556f1a8402",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/supply-first-only.lean:1647:0: error: Typed runtime comparisons failed: 1"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "oracle-freshness-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "c63078cc8244a7652dd41e4d765dc1be4013ffeda6ebc53479a0fcbbe1345586",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/oracle-freshness-bypass.lean:1647:0: error: Typed runtime comparisons failed: 1"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "oracle-future-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "c3c3d858431fef579e4447bf044ee3217ee9d54067f4dfc3062cc60ae74cdcf3",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/oracle-future-bypass.lean:1647:0: error: Typed runtime comparisons failed: 1"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "oracle-positive-price-bypass",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "16b4edf75d845e6903c3b6cb1ab89240e479a291ebc765b09f02b5646c88a6c5",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/oracle-positive-price-bypass.lean:1647:0: error: Typed runtime comparisons failed: 2"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  },
  {
    "variant": "collateral-factor-weakened",
    "exit": 1,
    "comparison_count": 189,
    "log_sha256": "4c59ca115dcea76496be7ad7997ad187dba8bb65a97b4843a8d56368bdf30a1e",
    "compiler_error_lines": [
      "/tmp/defiformal-sprint4-mutations-1/collateral-factor-weakened.lean:1647:0: error: Typed runtime comparisons failed: 1"
    ],
    "protected_positives_pass": true,
    "required_false_observed": true
  }
]


===== final17 CLI controls =====
{
  "total": 17,
  "passed": 17,
  "runner_sha256": "f988c2a1c10dce1b3b0c13caf92e9de0138c4985fa2fce7f1538ab1ca758dc50",
  "harness_sha256": "921457f86eba3e0f8e6fec1250a1a0745fd56fb717074d6db61b2bb1cfa8dd93",
  "lean_version": "Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)",
  "lean_executable_sha256": "e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550",
  "fixture_git_isolated": true,
  "cases": [
    {
      "name": "live-discriminating-mutant",
      "expected_exit": 0,
      "actual_exit": 0,
      "passed": true,
      "cli_output": "control: exit=0; comparisons=2; false=[]\nprobe: exit=1; comparisons=2; false=['runner_sensitivity']\nDISCRIMINATES: 1 mutants and one nonempty unchanged control\n"
    },
    {
      "name": "all-true-mutant",
      "expected_exit": 1,
      "actual_exit": 1,
      "passed": true,
      "cli_output": "control: exit=0; comparisons=2; false=[]\nFAIL: probe: all comparisons still pass under mutation\n"
    },
    {
      "name": "required-observation-stays-true",
      "expected_exit": 1,
      "actual_exit": 1,
      "passed": true,
      "cli_output": "control: exit=0; comparisons=2; false=[]\nFAIL: probe: required mutation not detected\n"
    },
    {
      "name": "positive-control-flipped",
      "expected_exit": 1,
      "actual_exit": 1,
      "passed": true,
      "cli_output": "control: exit=0; comparisons=2; false=[]\nFAIL: probe: positive control failed\n"
    },
    {
      "name": "compilation-only-failure",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "control: exit=0; comparisons=2; false=[]\nBLOCKED: Blocked: probe: failure is not solely the expected runtime comparison failure\n"
    },
    {
      "name": "compiler-error-with-runtime-failure",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "control: exit=0; comparisons=2; false=[]\nBLOCKED: Blocked: probe: failure is not solely the expected runtime comparison failure\n"
    },
    {
      "name": "empty-observations",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: Blocked: control: empty/duplicate observations\n"
    },
    {
      "name": "duplicate-observations",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: Blocked: control: empty/duplicate observations\n"
    },
    {
      "name": "missing-positive-observation",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: Blocked: control: missing positive controls\n"
    },
    {
      "name": "missing-required-observation",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: Blocked: probe: missing required observation in control\n"
    },
    {
      "name": "partial-mutant-observations",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "control: exit=0; comparisons=2; false=[]\nBLOCKED: Blocked: probe: partial execution\n"
    },
    {
      "name": "no-op-mutation",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: Blocked: mutation must actually change the source\n"
    },
    {
      "name": "missing-mutation-needle",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: Blocked: probe: mutation did not apply exactly once\n"
    },
    {
      "name": "missing-source-setup",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: FileNotFoundError: [Errno 2] No such file or directory: '/tmp/defiformal-sprint4-runner-controls-reviewed/fixture-repo/lean/DefiKernel/Typed/RunnerInput.lean'\n"
    },
    {
      "name": "missing-manifest-setup",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: FileNotFoundError: [Errno 2] No such file or directory: '/tmp/defiformal-sprint4-runner-controls-reviewed/fixture-repo/lean/lake-manifest.json'\n"
    },
    {
      "name": "existing-output-setup",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: Blocked: output already exists\n"
    },
    {
      "name": "empty-mutation-inventory",
      "expected_exit": 3,
      "actual_exit": 3,
      "passed": true,
      "cli_output": "BLOCKED: Blocked: empty mutation inventory\n"
    }
  ]
}

===== actual189 control observations =====
{
  "expr_exact_price_conversion": "true",
  "expr_explicit_debt_valuation": "true",
  "expr_inverse_price_conversion": "true",
  "expr_exact_fractional_conversion": "true",
  "expr_same_unit_addition": "true",
  "expr_scalar_scaling": "true",
  "expr_signed_negation": "true",
  "expr_safe_scalar_division": "true",
  "expr_zero_scalar_division_refused": "true",
  "expr_safe_ratio": "true",
  "expr_zero_ratio_refused": "true",
  "expr_zero_inverse_price_refused": "true",
  "expr_missing_observation_refused": "true",
  "expr_wrong_observation_unit_refused": "true",
  "expr_tracked_freshness": "true",
  "expr_stale_observation": "true",
  "expr_missing_timestamp_refused": "true",
  "expr_fresh_time_tracked": "true",
  "expr_timestamp_observation_tracked": "true",
  "expr_inactive_environment_branch_tracked": "true",
  "expr_inactive_state_branch_tracked": "true",
  "expr_inactive_missing_branch_not_evaluated": "true",
  "expr_boolean_and_is_eager": "true",
  "expr_boolean_or_is_eager": "true",
  "expr_successful_party_lookup": "true",
  "expr_failed_party_lookup_refused": "true",
  "expr_concrete_read_resolution": "true",
  "expr_footprint_party_lookup_refused": "true",
  "expr_checked_argument": "true",
  "expr_wrong_argument_unit_refused": "true",
  "expr_missing_argument_refused": "true",
  "expr_excess_argument_refused": "true",
  "expr_unrelated_balance_change": "true",
  "expr_read_change_observed": "true",
  "authority_issue_succeeds_with_id_zero": "true",
  "authority_unauthorized_issuer": "true",
  "authority_issuer_wrong_authenticated_domain": "true",
  "authority_unknown_operation_grant": "true",
  "authority_foreign_operation_grant": "true",
  "authority_foreign_debit_resource_grant": "true",
  "authority_foreign_supply_resource_grant": "true",
  "authority_invoke_live_holder": "true",
  "authority_debit_live_holder": "true",
  "authority_supply_live_holder": "true",
  "authority_wrong_holder": "true",
  "authority_wrong_authenticated_domain": "true",
  "authority_unknown_capability": "true",
  "authority_empty_capability_request": "true",
  "authority_wrong_operation": "true",
  "authority_wrong_debit_owner": "true",
  "authority_wrong_debit_asset": "true",
  "authority_wrong_supply_asset": "true",
  "authority_right_kind_mismatch": "true",
  "authority_duplicates_preserve_success": "true",
  "authority_duplicates_add_no_right": "true",
  "authority_unauthorized_revoker": "true",
  "authority_revoker_wrong_authenticated_domain": "true",
  "authority_unknown_revocation": "true",
  "authority_same_request_before_revoke": "true",
  "authority_revoke_accepted": "true",
  "authority_same_request_after_revoke": "true",
  "authority_revoke_keeps_invoke_sibling": "true",
  "authority_revoke_keeps_supply_sibling": "true",
  "authority_revoke_is_idempotent": "true",
  "authority_reissue_receives_fresh_id_three": "true",
  "authority_reissued_right_usable_by_new_id": "true",
  "authority_old_revoked_id_remains_unusable": "true",
  "authority_foreign_grant_positive_sibling": "true",
  "authority_foreign_grant_cannot_authorize_local_context": "true",
  "authority_other_operation_positive_sibling": "true",
  "authority_other_operation_cannot_authorize_original": "true",
  "transition_transfer_exact": "true",
  "transition_issue_all_rights": "true",
  "transition_unknown_operation": "true",
  "transition_claimed_actor_ok": "true",
  "transition_claimed_actor_wrong": "true",
  "transition_wrong_cap_holder": "true",
  "transition_context_domain": "true",
  "transition_party_arity": "true",
  "transition_argument_count": "true",
  "transition_invoke_required": "true",
  "transition_guard_false": "true",
  "transition_guard_read_ok": "true",
  "transition_guard_read_missing": "true",
  "transition_effect_read_ok": "true",
  "transition_effect_read_missing": "true",
  "transition_inactive_read_ok": "true",
  "transition_inactive_read_missing": "true",
  "transition_supply_read_ok": "true",
  "transition_supply_only_read_ok": "true",
  "transition_supply_only_read_missing": "true",
  "transition_observed_ok": "true",
  "transition_env_read_missing": "true",
  "transition_observation_missing": "true",
  "transition_foreign_state_read": "true",
  "transition_foreign_effect": "true",
  "transition_debit_required": "true",
  "transition_revoked_debit": "true",
  "transition_mint_ok": "true",
  "transition_supply_required": "true",
  "transition_insufficient_funds": "true",
  "transition_unbalanced": "true",
  "transition_mismatched_supply": "true",
  "transition_wrong_asset_accounting": "true",
  "transition_missing_write": "true",
  "transition_repeated_effects_sum": "true",
  "transition_repeated_supply_sum": "true",
  "transition_duplicate_cap_ids": "true",
  "transition_positive_provisioning": "true",
  "transition_revoked_tombstone_exact": "true",
  "transition_clock_read_ok": "true",
  "transition_now_read_missing": "true",
  "transition_timestamp_read_missing": "true",
  "transition_foreign_supply": "true",
  "transition_foreign_observation_ok": "true",
  "transition_foreign_netzero_ok": "true",
  "transition_false_guard_failing_effect_precedence": "true",
  "transition_underfunded_unbalanced_precedence": "true",
  "transition_false_guard_missing_read_precedence": "true",
  "reference_initial_all_cells": "true",
  "reference_provisioned_twelve_grants": "true",
  "reference_transfer_full_post": "true",
  "reference_deposit_full_post": "true",
  "reference_withdraw_full_post": "true",
  "reference_borrow_full_post": "true",
  "reference_collateral_boundary_accept": "true",
  "reference_fractional_deposit": "true",
  "reference_zero_transfer": "true",
  "reference_self_transfer": "true",
  "reference_zero_deposit": "true",
  "reference_zero_withdraw": "true",
  "reference_zero_borrow": "true",
  "reference_negative_transfer": "true",
  "reference_negative_deposit": "true",
  "reference_negative_withdraw": "true",
  "reference_negative_borrow": "true",
  "reference_transfer_capabilities_preserved": "true",
  "reference_deposit_capabilities_preserved": "true",
  "reference_withdraw_capabilities_preserved": "true",
  "reference_borrow_capabilities_preserved": "true",
  "reference_unknown_operation": "true",
  "reference_wrong_holder": "true",
  "reference_claimed_actor_mismatch": "true",
  "reference_claimed_actor_correct": "true",
  "reference_wrong_domain": "true",
  "reference_wrong_operation_capabilities": "true",
  "reference_unknown_capability": "true",
  "reference_missing_debit": "true",
  "reference_missing_share_supply": "true",
  "reference_missing_debt_supply": "true",
  "reference_duplicate_capabilities": "true",
  "reference_revoked_invocation": "true",
  "reference_live_repeat_same_request": "true",
  "reference_issue_use_revoke_same_request": "true",
  "reference_resource_revoked_same_request": "true",
  "reference_unrelated_revocation": "true",
  "reference_revocation_tombstone": "true",
  "reference_reissue_fresh_id": "true",
  "reference_reissued_new_id_works": "true",
  "reference_old_id_stays_revoked": "true",
  "reference_unauthorized_issue": "true",
  "reference_unauthorized_revoke": "true",
  "reference_oracle_age_boundary_accept": "true",
  "reference_oracle_stale": "true",
  "reference_oracle_zero": "true",
  "reference_oracle_negative": "true",
  "reference_oracle_positive_zero_exposure": "true",
  "reference_oracle_zero_independent": "true",
  "reference_oracle_negative_independent": "true",
  "reference_oracle_future": "true",
  "reference_oracle_wrong_feed": "true",
  "reference_oracle_missing": "true",
  "reference_oracle_wrong_dimension": "true",
  "reference_collateral_exceeded": "true",
  "reference_transfer_insufficient": "true",
  "reference_deposit_insufficient": "true",
  "reference_withdraw_insufficient": "true",
  "reference_pool_illiquid": "true",
  "reference_wrong_argument_dimension": "true",
  "reference_missing_argument": "true",
  "reference_missing_party": "true",
  "reference_missing_write": "true",
  "reference_missing_guard_state_read": "true",
  "reference_missing_guard_env_read": "true",
  "reference_declared_effect_read": "true",
  "reference_missing_effect_read": "true",
  "reference_unbalanced": "true",
  "reference_wrong_asset_accounting": "true",
  "reference_zero_divisor": "true"
}

===== final-axioms.log scope/summary =====
AXIOM AUDIT scope: imported module prefix DefiKernel.Typed; modules=[DefiKernel.Typed.Types,
 DefiKernel.Typed.Expr,
 DefiKernel.Typed.ExprTests,
 DefiKernel.Typed.Authority,
 DefiKernel.Typed.AuthorityTests,
 DefiKernel.Typed.Transition,
 DefiKernel.Typed.TransitionTests,
 DefiKernel.Typed.Examples,
 DefiKernel.Typed.Acceptance,
 DefiKernel.Typed.Audit]
AXIOM AUDIT DECLARATIONS PASSED: 978/978 supplemental declarations; forbidden=0
AXIOM AUDIT PASSED: 524/524 theorems; forbidden=0

===== final-legacy-axioms.log scope/summary =====
AXIOM AUDIT scope: imported module prefix DefiKernel; modules=[DefiKernel.Core,
 DefiKernel.Examples,
 DefiKernel.Acceptance,
 DefiKernel.Audit,
 DefiKernel.Contracts,
 DefiKernel.ContractExamples,
 DefiKernel.ContractAcceptance,
 DefiKernel.ContractAudit,
 DefiKernel.AxiomAudit]
AXIOM AUDIT theorem: DefiKernel.applyEffect_accounting; module=DefiKernel.Core; axioms=[propext,
AXIOM AUDIT DECLARATIONS PASSED: 234/234 supplemental declarations; forbidden=0
AXIOM AUDIT PASSED: 278/278 theorems; forbidden=0

===== unchanged imported audit implementation =====
import Lean.Elab.Command
import Lean.Util.CollectAxioms

/-!
Audit theorem constants and supplemental definitions, opaque constants, and axioms in
imported modules whose names extend a given module prefix.
Discovery uses elaborated constant kinds and module provenance, never declaration source text.
Files outside the import closure and declarations in the current module are outside this scope.
-/

namespace DefiKernel.AxiomAudit

open Lean Elab Command

/-- The only permitted transitive axioms for the pilot's inspected declarations. -/
def allowedAxioms : Array Name := #[``propext, ``Classical.choice, ``Quot.sound]

/-- Discover all imported theorem constants with module provenance under `modulePrefix`. -/
def importedTheorems (env : Environment) (modulePrefix : Name) : Array (Name × Name) :=
  (env.constants.fold (init := #[]) fun found name info =>
    match info with
    | .thmInfo _ =>
      match env.getModuleIdxFor? name with
      | some idx =>
        let moduleName := env.header.moduleNames[idx.toNat]!
        if modulePrefix.isPrefixOf moduleName then found.push (name, moduleName) else found
      | none => found
    | _ => found).qsort fun a b => Name.lt a.1 b.1

/-- Discover imported definitions, opaque constants, and axioms under `modulePrefix`. -/
def importedSupplemental (env : Environment) (modulePrefix : Name) : Array (Name × Name × String) :=
  (env.constants.fold (init := #[]) fun found name info =>
    let kind := match info with
      | .defnInfo _ => "definition"
      | .opaqueInfo _ => "opaque"
      | .axiomInfo _ => "axiom"
      | _ => "other"
    if kind == "other" then found else
    match env.getModuleIdxFor? name with
    | some idx =>
      let moduleName := env.header.moduleNames[idx.toNat]!
      if modulePrefix.isPrefixOf moduleName then found.push (name, moduleName, kind) else found
    | none => found).qsort fun a b => Name.lt a.1 b.1

/--
Report every discovered theorem with its module and exact transitive axiom set.
Also inspect definitions, opaque constants, and axiom declarations, even if no theorem uses them.
Reject empty imported theorem scope and every dependency outside the standard allowlist.
For example, `#audit_axioms DefiKernel` audits loaded `DefiKernel.*` modules.
-/
elab "#audit_axioms " modulePrefix:ident : command => do
  let scopePrefix := modulePrefix.getId
  let env ← getEnv
  let modules := env.header.moduleNames.filter (scopePrefix.isPrefixOf ·)
  let theorems := importedTheorems env scopePrefix
  logInfo m!"AXIOM AUDIT scope: imported module prefix {scopePrefix}; modules={modules}"
  if theorems.isEmpty then
    throwError "AXIOM AUDIT BLOCKED: empty theorem scope for imported module prefix {scopePrefix}; theorems=0"
  let mut rejected : Nat := 0
  for (name, moduleName) in theorems do
    let axioms ← collectAxioms name
    logInfo m!"AXIOM AUDIT theorem: {name}; module={moduleName}; axioms={axioms}"
    let forbidden := axioms.filter fun ax => !allowedAxioms.contains ax
    unless forbidden.isEmpty do
      rejected := rejected + 1
      logError m!"AXIOM AUDIT FORBIDDEN: {name}; axioms={forbidden}"
  let supplemental := importedSupplemental env scopePrefix
  let mut supplementalRejected : Nat := 0
  for (name, moduleName, kind) in supplemental do
    let axioms ← collectAxioms name
    logInfo m!"AXIOM AUDIT declaration: {name}; module={moduleName}; kind={kind}; axioms={axioms}"
    let forbidden := axioms.filter fun ax => !allowedAxioms.contains ax
    unless forbidden.isEmpty do
      supplementalRejected := supplementalRejected + 1
      logError m!"AXIOM AUDIT DECLARATION FORBIDDEN: {name}; kind={kind}; axioms={forbidden}"
  if rejected > 0 then
    throwError "AXIOM AUDIT FAILED: {rejected}/{theorems.size} theorems use forbidden axioms"
  if supplementalRejected > 0 then
    throwError (m!"AXIOM AUDIT DECLARATIONS FAILED: {supplementalRejected}/{supplemental.size} " ++
      m!"supplemental declarations use forbidden axioms")
  if supplemental.isEmpty then
    logInfo "AXIOM AUDIT DECLARATIONS: supplemental declarations=0; theorem audit remains required"
  else
    logInfo <| m!"AXIOM AUDIT DECLARATIONS PASSED: {supplemental.size}/{supplemental.size} " ++
      m!"supplemental declarations; forbidden=0"
  logInfo m!"AXIOM AUDIT PASSED: {theorems.size}/{theorems.size} theorems; forbidden=0"

end DefiKernel.AxiomAudit
