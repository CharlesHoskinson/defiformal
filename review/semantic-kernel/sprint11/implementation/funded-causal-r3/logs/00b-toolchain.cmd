bash -lc echo "lean=$(command -v lean)"; lean --version; echo "lake=$(command -v lake)"; lake --version; echo "LEAN_PATH=${LEAN_PATH-}"; sha256sum "$(command -v lean)" "$(command -v lake)"
