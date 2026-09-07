#!/usr/bin/env python3
"""Bind a human exposure assessment to existing source lines and retained Git history."""
import hashlib
import json
import re
import subprocess
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
OUT = Path(__file__).resolve().parent
PLAN = 'docs/research/2026-09-06-defi-source-plan.md'
LEGACY = 'corpus/elementsdefi.md'
GPT = 'corpus/elementsdefiGPT.md'
CASE_DATA = [
    ('dYdX Chain', 373, [388], [(LEGACY, [72, 225, 239]), (GPT, [198, 424])],
     'The plan uses node-local books and price-time matching to motivate ordering/finality semantics. Older corpus documents explicitly decompose dYdX v4 as an app-chain book with perpetual margin.',
     'dYdX Chain/v4 is a repository-supported conceptual alias through the app-chain description; no deployment identity is inferred. v3 and unversioned dYdX mentions are family context.'),
    ('Osmosis', 374, [388], [(LEGACY, [72, 284]), (GPT, [128, 196, 232, 474])],
     'Router heterogeneity is analyzed in the source plan; earlier corpus text uses Osmosis for execution-model independence, concentrated liquidity and TWAP mechanisms.',
     'Exact protocol name appears in original broad corpus descriptions; no pinned deployment/version is supplied.'),
    ('DeepBookV3', 375, [388], [],
     'The adopted plan analyzes Sui/Move Pool, state, book, vault and balance-manager objects to separate matching from accounting. This is substantive design-context exposure beyond its candidate-list row.',
     'DeepBookV3 is the explicit plan spelling. No additional standalone corpus/model use was found in this bounded retained-text search; absence is not cleanliness evidence.'),
    ('THORChain', 376, [388, 912], [],
     'The plan uses native cross-chain swaps to motivate explicit finality/message lifecycle assumptions and reject reduction to atomic same-state wiring.',
     'Exact name in the adopted source plan; no deployment or chain revision is reconstructed.'),
    ('Velocity', 377, [390, 916, 918, 920], [],
     'The plan uses joint perpetual collateral/lendable inventory, unsettled profit and loss socialization to require obligations and a richer margin/funding library.',
     'Only the financial source-plan references identify this candidate. Constant-velocity UI motion in council documents is unrelated and excluded.'),
    ('Kamino', 378, [390], [(LEGACY, [72, 284]),
      ('expansion/12-prediction/01-research.md', [745, 746, 906, 907, 908]),
      ('expansion/12-prediction/specs/steakhouse-financial.json', [31])],
     'The plan analyzes allocator weights/caps and lending configuration. Earlier corpus text lists Kamino; retained Steakhouse research and its specification discuss allocation onto Kamino as a substrate.',
     'Prior nested-platform use is exposure, not a standalone normalized Kamino row. The retained research disputes the earlier generic Morpho/Euler substrate description; this audit does not adjudicate that factual dispute.'),
    ('Euler V2', 379, [390], [(LEGACY, [72]), (GPT, [210]),
      ('corpus50/lanes/lane2-perps-yield-bridges-intents.json', [251]),
      ('corpus50/lanes/lane3-rwa-options-stables-prediction.json', [381]),
      ('formal/atlas.qnt', [189])],
     'Euler v2 is a named isolated-market example in the old taxonomy. The adopted plan describes modular credit vaults and EVC batching/subaccounts/operators/controller authority.',
     'Euler v1 in the actual old atlas is a different version and cannot prove Euler V2 deployment use. Unversioned Euler inside Steakhouse rows is family/substrate context, not a resolved V2 alias.'),
    ('Term Finance', 380, [390], [(GPT, [213])],
     'The plan analyzes recurring fixed-term credit auctions and rate discovery. The old taxonomy already names Term Finance as its fixed-term debt example E017.',
     'Exact product name occurs as a mechanism-library example, not as a standalone normalized72 row.'),
    ('UMA Optimistic Oracle', 381, [323], [(LEGACY, [166]), (GPT, [233]),
      ('corpus50/lanes/lane2-perps-yield-bridges-intents.json', [383]),
      ('corpus50/lanes/lane3-rwa-options-stables-prediction.json', [349, 408]),
      ('quint-models/L6/common.qnt', [146]),
      ('quint-models-v2/polymarket.qnt', [82])],
     'The plan uses UMA to distinguish truth/dispute infrastructure from economic functions. Earlier taxonomy, Across/Polymarket rows and actual Quint resolution models already encode or discuss its optimistic-oracle dependency.',
     'This is nested dependency exposure, including a bundled prediction-market comparison. Version/deployment fidelity is not established. The unrelated maude.lcc.uma.es academic domain is excluded.'),
    ('Nexus Mutual', 382, [392, 924, 926], [(GPT, [222]),
      ('algebra/reports/OP-LOG.md', [525, 526, 527]),
      ('algebra/solvers/OP-LOG/theory.py', [317, 318, 319, 320, 321, 322])],
     'The plan explicitly models Nexus-style cover as a conditional claim with externally adjudicated proof of loss. Earlier taxonomy names Nexus Mutual for mutual cover, and an old solver cites it as a counterexample to a vocabulary-support restriction.',
     'Nexus-style in the same source-plan section is linked to Nexus Mutual by its neighboring explicit description. zkLink Nexus settlement in ApeX material is unrelated and excluded.'),
    ('Lightning Network', 383, [392, 912], [],
     'Chained conditional payments motivate obligations, timeouts, asynchronous settlement and explicit cross-domain assumptions in the adopted plan.',
     'Exact candidate name plus Lightning shorthand in the same plan. No additional standalone local protocol encoding was found; no completeness claim follows.'),
    ('Balancer V3', 384, [392, 880, 882, 884, 886, 1105], [(LEGACY, [76, 216]),
      (GPT, [27, 194, 416]),
      ('corpus50/lanes/lane1-dex-lending-cdp-lsd.json', [92]),
      ('wiki-llm/sprint-8-atomic-synchronization-draft.md', [37, 38, 39, 40, 180, 181, 182, 183, 184, 185])],
     'The source plan explicitly prescribes a shared vault, transient deltas and settlement postcondition, and selects Balancer shared/transient accounting for porting. Sprint8 cites this design source while implementing a deliberately limited loan/return clearing model.',
     'Original corpus examples include Balancer v2 and unversioned pool families; the corpus50 category residue explicitly mentions V3. These are not a verified V2=V3 alias or deployed Balancer correspondence. Generic load-balancer text is unrelated.'),
]


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def main():
    assert not (OUT/'assessment.json').exists(), 'Preserve the prior audit.'
    scan = json.loads((OUT/'scan-inputs.json').read_text())
    source_map = {r['path']: r for r in scan['files']}
    head = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
    refs, histories = {}, {}

    def evidence(path, lines, role):
        key = path+':'+','.join(map(str, lines))
        if key not in refs:
            raw = (ROOT/path).read_bytes()
            assert sha(raw) == source_map[path]['sha256']
            text = raw.decode().splitlines()
            rows = []
            for line in lines:
                blame = subprocess.check_output(['git', 'blame', '--line-porcelain',
                    '-L', f'{line},{line}', head, '--', path], cwd=ROOT, text=True)
                fields = dict(x.split(' ', 1) for x in blame.splitlines()[1:]
                              if ' ' in x and not x.startswith('\t'))
                commit = blame.splitlines()[0].split()[0]
                rows.append({'line': line, 'text': text[line-1],
                             'line_sha256': sha(text[line-1].encode()),
                             'retained_line_commit': commit,
                             'committer_epoch': fields.get('committer-time'),
                             'committer_timezone': fields.get('committer-tz')})
            blob = subprocess.check_output(['git', 'rev-parse', head+':'+path],
                                           cwd=ROOT, text=True).strip()
            refs[key] = {'path': path, 'sha256': sha(raw), 'git_blob': blob, 'lines': rows}
            if path not in histories:
                histories[path] = subprocess.check_output(['git', 'log', '--follow',
                    '--format=%H %cI %s', '--', path], cwd=ROOT, text=True).splitlines()
        return {'evidence_id': key, 'role': role}

    source_rows = json.loads((ROOT/'corpus/normalized/generated/corpus.json').read_text())['source_records']
    units = json.loads((ROOT/'corpus/normalized/inputs/annotation-input.json').read_text())['units']
    cases = []
    for name, proposal_line, plan_lines, prior, finding, aliases in CASE_DATA:
        pattern = re.compile(scan['patterns'][name], re.I)
        direct_rows = [r['legacy_id'] for r in source_rows if pattern.search(r['original']['name'])]
        direct_units = [r['identity']['unit_id'] for r in units if pattern.search(r['identity']['label'])]
        refs_for_case = [evidence(PLAN, [proposal_line], 'candidate_list_with_mechanism_rationale'),
                         evidence(PLAN, plan_lines, 'substantive_design_analysis'),
                         evidence(PLAN, [394], 'explicit_collective_kernel_design_conclusion')]
        refs_for_case += [evidence(p, lines, 'prior_corpus_library_model_or_design_context')
                          for p, lines in prior]
        cases.append({'name': name, 'finding': finding, 'alias_and_version_boundary': aliases,
                      'evidence': refs_for_case,
                      'normalized72_direct_name_rows': direct_rows,
                      'normalized75_direct_name_units': direct_units,
                      'conservative_eligibility': 'development_exposed_do_not_present_as_untouched',
                      'untouched_certified': False,
                      'proposed_replacement': None})
    rule = evidence('docs/superpowers/specs/2026-09-06-semantic-kernel-design.md',
                    [54, 55, 56, 57, 58, 59], 'approved_development_vs_untouched_rule')
    protected = {p: r for p, r in source_map.items() if p.startswith(
        ('corpus/', 'corpus50/', 'expansion/', 'docs/research/',
         'openspec/changes/corpus-provenance-adjudication/'))
        or p in ['wiki-llm/corpus-provenance-planning-draft.md',
                 'wiki-llm/corpus-provenance-adjudication.md']}
    frozen = json.loads((ROOT/'review/semantic-kernel/sprint10/planning/r2-candidate.json').read_text())
    for r in frozen['inputs']:
        protected[r['path']] = r
    frozen_paths = {r['path'] for r in frozen['inputs']}
    context_drift = []
    for p, r in protected.items():
        current_sha = sha((ROOT/p).read_bytes())
        if current_sha != r['sha256']:
            assert p not in frozen_paths, p
            context_drift.append({'path': p, 'scan_sha256': r['sha256'],
                                  'current_sha256': current_sha,
                                  'scope': 'concurrent planning context; not edited by this audit'})
    data = {'status': 'bounded_existing_record_exposure_audit_not_evaluation_manifest',
            'utc': datetime.now(timezone.utc).isoformat(), 'scan_head': scan['head'],
            'report_head': head, 'cases': cases, 'evidence': refs,
            'approved_rule': rule, 'retained_path_histories': histories,
            'membership_scope': {'source_records': len(source_rows), 'candidate_units': len(units),
                'matching_rule': 'Exact lexical candidate/family patterns against original.name and identity.label only; nested mentions reported separately, version identity not inferred.'},
            'protection_check': {'S10_bound_inputs': len(frozen['inputs']),
                'total_protected_existing_inputs': len(protected),
                'all_S10_hashes_unchanged': True,
                'selected_historical_evidence_hashes_unchanged': True,
                'all_scanned_context_hashes_unchanged': not context_drift,
                'concurrent_context_drift': context_drift},
            'limits': ['No external retrieval, new prospective case reading, replacement selection, or evaluation-manifest edit.',
                'Existing citation tokens/URLs are recorded material, not newly verified sources.',
                'Git line/path history establishes retained repository presence, not original research dates or every human exposure.',
                'Search is tracked existing text and selected retained path histories; untracked/deleted/unreachable/private records and semantic aliases without matching names are not exhaustively covered.',
                'Lexical matches include copies and false positives; counts are not independent exposure counts.',
                'A graph with source-only scope cannot establish absence from research/corpus; source graph was used only for scope orientation.',
                'No accepted evaluation freeze has been certified; no case is certified untouched.']}
    (OUT/'assessment.json').write_text(json.dumps(data, indent=2, ensure_ascii=False)+'\n')
    print(json.dumps({'cases': len(cases), 'evidence_records': len(refs),
                      'protected_inputs': len(protected),
                      'direct_named_legacy_rows': sum(len(c['normalized72_direct_name_rows']) for c in cases)}))


if __name__ == '__main__':
    main()
