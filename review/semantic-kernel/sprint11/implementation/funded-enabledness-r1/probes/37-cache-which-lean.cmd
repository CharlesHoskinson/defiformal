sh -c echo LEAN=$(command -v lean); echo LAKE=$(command -v lake); sha256sum "$(command -v lean)" "$(command -v lake)"; cat lean-toolchain
