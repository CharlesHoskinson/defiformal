# R4 mutation source bundle transport

The original Git bundle is split into ordered 32 MiB parts to satisfy GitHub's per-file limit. Concatenate the listed parts and verify the full SHA256 in manifest.json before using the bundle. This reproduces the exact original bundle bytes and Git identity; no source or history is filtered.

The frozen R4 terminal manifest retains the original bundle filename and hash. This directory supplies its lossless transport. The original unchunked local file and unpublished commit are also preserved. This is unaccepted candidate evidence, not production integration.
