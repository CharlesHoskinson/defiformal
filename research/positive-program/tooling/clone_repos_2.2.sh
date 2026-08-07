#!/usr/bin/env bash
# Gate 2.2 ACQUIRE clones (gitignored under protocol-repos/)
# Usage: from repo root, bash research/positive-program/tooling/clone_repos_2.2.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
PR="$ROOT/protocol-repos"

clone_into() {
  local cat="$1" url="$2" name="$3"
  local dest="$PR/$cat/$name"
  mkdir -p "$PR/$cat"
  if [ -d "$dest/.git" ]; then
    echo "SKIP $dest"
    return 0
  fi
  echo "CLONE $dest"
  git clone --depth 1 "$url" "$dest"
}

clone_into cdp https://github.com/ethena-labs/bbp-public-assets.git ethena-labs_bbp-public-assets
clone_into cdp https://github.com/lista-dao/lista-dao-contracts.git lista-dao_lista-dao-contracts
clone_into yield https://github.com/cian-ai/cian-protocol.git cian-ai_cian-protocol
clone_into intent https://github.com/okxlabs/Web3-DEX-Router-EVM-V1.git okxlabs_Web3-DEX-Router-EVM-V1
clone_into fiat https://github.com/worldliberty/usd1-smart-contracts.git worldliberty_usd1-smart-contracts
clone_into opt https://github.com/aevoxyz/aevo-sdk.git aevoxyz_aevo-sdk
clone_into opt https://github.com/rysk-finance/ryskV12-cli.git rysk-finance_ryskV12-cli
clone_into perp https://github.com/julianfssen/jupiter-perps-anchor-idl-parsing.git julianfssen_jupiter-perps-anchor-idl-parsing

echo "done"
