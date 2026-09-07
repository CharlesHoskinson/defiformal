#!/usr/bin/env python3
"""Build explicitly provisional identity cards from manually inspected captures."""
from pathlib import Path
import hashlib
import json
import subprocess
from datetime import datetime, timezone
import bs4

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]

def sha(data):
    return hashlib.sha256(data).hexdigest()

def write(name, value):
    with (HERE / name).open('x') as handle:
        json.dump(value, handle, ensure_ascii=False, indent=2)
        handle.write('\n')

# Each tuple is (captured source identifier, inclusive derived-text lines).
# These are author observations, not accepted canonical identities or facets.
ASSESSMENTS = [
 ('DFlow spot-trading API', [('68978f43555cd3b1',1,9)],
  'The captured landing text binds DFlow to a unified API for aggregated Solana spot liquidity.',
  'API documentation landing snapshot; no protocol release or code revision.',
  'Keep API provider, routing service and underlying liquidity venues separate. The short landing page does not establish the complete settlement or intent mechanism.'),
 ('1inch aggregation and Fusion', [('2cd652f87e5b6447',25,32),('2cd652f87e5b6447',41,49)],
  'The help article describes aggregation/routing and separately introduces Fusion orders filled by resolvers.',
  'Undated moving help article; relative update text is not a release pin.',
  'Aggregation, limit-order and Fusion paths need product/version bindings. Marketing claims about prices, gas and MEV are not verified guarantees.'),
 ('Ondo USDY and rUSDY', [('58c20a3444a0a878',15,25),('58c20a3444a0a878',43,67),('eb5a6b654be43622',1,6),('8061195a3c493e21',27,29)],
  'Current basics distinguish accumulating USDY from the rUSDY wrapper, issuance-date-dependent backing and separate redemption routes; the retained 2023 launch article is historical context.',
  'Current captured docs mention December 15, 2025 restructuring; launch article is dated August 3, 2023. Neither is a deployed code pin.',
  'Preserve the existing USDY child and parent-row residue. Propose a separate wrapper boundary for rUSDY, without silently adding a canonical unit. Do not infer novation of every token or economic rights from website-only terms.'),
 ('Ondo OUSG', [('cefcf993e856c3d9',9,29),('2fa1ad43279c6326',7,8),('8061195a3c493e21',27,29)],
  'The OUSG overview describes tokenized fund exposure and qualified mint/redemption paths; the compliance page names Ondo I LP as issuer.',
  'Moving documentation snapshot; issuer statement is source-attributed and not independently registry verified.',
  'Keep OUSG separate from USDY and stock-exposure tokens. Instant operations have limits and non-instant alternatives. Website terms do not replace fund subscription or holder documents.'),
 ('Ondo Global Markets / Ondo Stocks', [('40bf5523cd69c36e',7,10),('8061195a3c493e21',27,29)],
  'The captured disclaimer identifies the former Global Markets token name with Ondo Stocks, describes economic exposure and denies rights to hold or receive the underlying assets.',
  'Current documentation terminology and February 2, 2026 website terms; no release, offering-document or deployment verification.',
  'Retain the original Global Markets child name and proposed alias as separate evidence. Do not classify tokens as direct ownership of underlying shares or transfer bundled parent facets to this child.'),
 ('Circle USYC / SDYF', [('3811c12d069e9311',7,23)],
  'Developer documentation describes USYC as a representation of Hashnote International Short Duration Yield Fund Ltd and names Circle International Bermuda Limited as issuer.',
  'Developer-document snapshot; no audited-code or Cayman/Bermuda registry verification.',
  'The product-page retrieval failed. The developer page makes broad atomic T+0 statements; this packet does not establish unconditional redemption liquidity, eligibility or every offchain step. Keep issuer, fund, token and integration contract separate.'),
 ('BlackRock BUIDL share classes', [('bd3d52b6456f6ee3',1,12),('1ba267c1efb42450',1,10)],
  'Securitize announcements bind BUIDL to BlackRock’s tokenized fund, with an Ethereum launch and a later Solana share class.',
  'Dated announcements March 20, 2024 and March 25, 2025, not current chain exhaustiveness or deployed-bytecode checks.',
  'Separate fund, share class, transfer agent and placement agent. A source-published token address or chain list remains a deployment candidate until independently checked.'),
 ('Maple Syrup products and institutional pools', [('e1f9b0b152658b97',8,30)],
  'Current Syrup documentation distinguishes syrupUSDC, syrupUSDT and syrupUSDG pools and legal portfolio names, separating them from existing institutional pools.',
  'Moving documentation snapshot; no contract or legal-entity verification.',
  'Original row bundles syrupUSDC/USDT and institutional pools; preserve that residue and propose product splits. Newly mentioned syrupUSDG is source context, not an automatically added canonical unit. Source language about legal separation is not an independent legal conclusion.'),
 ('Centrifuge protocol V3 family', [('3cbae65b9967f409',14,36),('5f66738afbf8b34c',5,14)],
  'The overview describes hub/spoke asset management with synchronous and asynchronous vault interfaces. The deployment page labels a v3.1.0 code reference.',
  'The captured page prints 6b9d36eabee48728486f377ea2766a5cd233c555; this is a 40-character source-published commit candidate. No repository object was fetched or verified.',
  'Preserve V3 source-row identity. Separate protocol core, configured extensions, pool/share class and deployment. Do not promote the source-published commit reference or its security-review claim into verified code/deployment evidence.'),
 ('Derive chain, protocol and exchange', [('faeec7b26ed3d5c2',84,108),('7b4fc5b930cb7cf9',84,96)],
  'Documentation separates the OP Stack chain, margin-settlement protocol and orderbook exchange operated by Derive Trading Co; it also describes accounts, risk managers and assets.',
  'Moving documentation with relative update text, not a code release.',
  'Preserve the source’s broad DAO-governance statement alongside the exchange-operator distinction. Governance is not identical to operation; no universal self-custody or audit conclusion is established here.'),
 ('Hegic', [],
  'Both bounded attempts at the selected primary website failed; no retained source body supports a new identity claim.',
  'Unresolved.',
  'Original development row remains provisional. Product/version and source acquisition need a separate bounded pass.'),
 ('Aevo exchange and product family', [('1db01bd1afc83aa4',7,21)],
  'The documentation introduces an OP Stack derivatives exchange with offchain order matching, onchain settlement and multiple products.',
  'Moving documentation snapshot; no release or deployment pin.',
  'Separate exchange, chain, OTC, strategies and other products. The introductory architecture statement does not establish implementation correspondence or operational guarantees.'),
 ('Panoptic; V2 binding unresolved', [('2e05f6240c7dbb9a',3,14)],
  'The landing documentation describes perpetual options and Perpetual Option Vaults on Ethereum.',
  'This captured introduction does not identify V2 or a code release.',
  'Original V2-qualified source row is not resolved by a generic current introduction. Separate direct options positions from deposit-based POV strategies; do not silently relabel the historical version.'),
 ('Circle-issued USDC by chain', [('66270bffe3272787',10,13),('66270bffe3272787',41,42),('66270bffe3272787',97,108)],
  'Circle’s address page lists chain-specific USDC contracts, distinguishes mainnet and valueless testnet tokens, and explicitly separates native X Layer USDC from USDC.e.',
  'Captured address-directory version, not deployed-code or issuer-obligation verification.',
  'Ethereum address is a source-published candidate only. Do not merge bridged representations with Circle-issued native tokens or assume a single deployment for the brand-level row.'),
 ('World Liberty Financial USD1', [('0ff43debefb312de',1,15),('0ff43debefb312de',23,35)],
  'The product page describes USD1 and advertises multichain use, reserve backing and bridge/conversion interfaces.',
  'Moving marketing page with no issuer legal instrument or code release retained.',
  'No unconditional holder redemption rights, verified reserves, issuer legal identity or cross-chain protocol are established by this landing page. Keep bridge tool and token issuer obligations distinct.'),
 ('Global Dollar USDG', [],
  'HTTP 200 returned a retained body but the declared static-text extraction was empty; no new identity support is assigned.',
  'Unresolved; successful transport is not substantive evidence.',
  'Keep the original Paxos / Global Dollar Network row and organizational uncertainty. A separate primary source or explicitly bound alternative extraction is required.'),
 ('PayPal USD / Paxos issuer wording', [('7cc8406cbd4a93b7',41,50),('7cc8406cbd4a93b7',59,69),('7cc8406cbd4a93b7',77,95)],
  'The page identifies PYUSD and separates PayPal account rewards from token use; its FAQ names Paxos Trust Company, LLC while footnotes name Paxos Trust Company, N.A.',
  'Captured page includes conflicting issuer-form wording and regional service qualifications; no independent corporate transition verification.',
  'Preserve LLC versus N.A. discrepancy rather than silently resolve it. PayPal opt-in rewards are not intrinsic yield for every onchain token holder. Future market rollout language is not current availability.'),
 ('Azuro', [('1ca8d79ee7bdd90a',1,6)],
  'The captured page contains navigation and the tagline identifying Azuro as a predictions layer, with no substantive mechanism explanation.',
  'Landing-shell branding only.',
  'Product boundary, settlement model and version remain unresolved; a successful HTTP status and tagline are not protocol evidence.'),
 ('Steakhouse Financial risk curators', [],
  'Both bounded attempts to retrieve the selected primary documentation failed; no new identity claim is supported.',
  'Unresolved.',
  'Retain the risk-curator row separately from the other Steakhouse development row until their precise products and overlap are reviewed. No merge or label propagation is authorized by name similarity.'),
]

def main():
    units = json.loads((HERE/'selected-units.json').read_bytes())['units']
    records = json.loads((HERE/'retrievals.json').read_bytes())['records']
    by_id = {r['source_id']: r for r in records}
    assert len(units) == len(ASSESSMENTS) == 19
    cards = []
    for unit, (name, refs, observation, version, residue) in zip(units, ASSESSMENTS):
        locators = []
        for source_id, start, end in refs:
            record = by_id[source_id]
            assert record['requested_url'] in unit['target_urls']
            attempt = record['attempts'][-1]
            ext = attempt['extraction']
            data = (ROOT/ext['path']).read_bytes()
            assert sha(data) == ext['sha256']
            lines = data.decode().splitlines()
            assert 1 <= start <= end <= len(lines), (source_id,start,end,len(lines))
            snippet = '\n'.join(lines[start-1:end])
            locators.append({'source_id': source_id, 'requested_url': record['requested_url'],
                'capture_path': attempt['capture_path'], 'capture_sha256': attempt['body_sha256'],
                'derived_path': ext['path'], 'derived_sha256': ext['sha256'],
                'line_start': start, 'line_end': end, 'excerpt': snippet,
                'excerpt_sha256': sha(snippet.encode()), 'coordinate_space': 'derived_utf8_lines_1_based_inclusive'})
        cards.append({'unit_id': unit['unit_id'], 'original_label': unit['label'],
            'canonical_record': unit['canonical_record'], 'source_row': unit['source_row'],
            'original_source_label': unit['original_source_label'], 'proposed_boundary': name,
            'author_observation': observation, 'version_scope': version, 'unresolved_residue': residue,
            'target_urls': unit['target_urls'], 'locators': locators,
            'status': 'provisional_source_boundary' if refs else 'source_gap',
            'accepted_identity': False, 'accepted_facet_changes': [], 'verified_deployment': False,
            'verified_code_pin': False, 'evaluation_role': 'development',
            'inherited_facets_from_parent': False})
    # Tool identity measured now is not backdated to capture time.
    tool_files = [{'path':str(p), 'sha256':sha(p.read_bytes())}
                  for p in sorted(Path(bs4.__file__).parent.rglob('*.py'))]
    write('cards.json', {'status':'AUTHOR_RESEARCH_NOT_ADJUDICATION', 'cards':cards,
        'limits':'Retained bodies, source assertions and proposed boundaries do not change canonical identities, facets, deployments, legal rights or fidelity judgments.'})
    write('assessment-environment.json', {'recorded_utc':datetime.now(timezone.utc).isoformat(),
        'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
        'assessment_helper_sha256':sha(Path(__file__).read_bytes()),
        'beautifulsoup_source_files_measured_after_capture':tool_files,
        'capture_time_package_file_hashes_measured':False})
    print(json.dumps({'cards':len(cards),'locators':sum(len(c['locators']) for c in cards),
        'unaccepted':all(not c['accepted_identity'] for c in cards)}))

if __name__ == '__main__':
    main()
