from pathlib import Path
import shutil,subprocess
r=Path('/private/tmp/defiformal-ci-author');e=Path('/private/tmp/defiformal-amm-word-settlement-author');f=e/'cli-fixture';(f/'scripts').mkdir(parents=True);(f/'lean/DefiKernel/AMM').mkdir(parents=True);(f/'lean/.lake').mkdir()
(f/'scripts/replay_amm_word_settlement.py').write_bytes((r/'scripts/replay_amm_word_settlement.py').read_bytes())
for p in (r/'lean').iterdir():
 if p.name not in ['DefiKernel','.lake']:(f/'lean'/p.name).symlink_to(p,target_is_directory=p.is_dir())
for p in (r/'lean/DefiKernel').iterdir():
 if p.name!='AMM':(f/'lean/DefiKernel'/p.name).symlink_to(p,target_is_directory=p.is_dir())
for p in (r/'lean/DefiKernel/AMM').iterdir():
 q=f/'lean/DefiKernel/AMM'/p.name
 if p.name in ['WordSettlement.lean','WordSettlementAudit.lean']:q.write_bytes(p.read_bytes())
 else:q.symlink_to(p,target_is_directory=p.is_dir())
(f/'lean/.lake/packages').symlink_to(r/'lean/.lake/packages',target_is_directory=True)
subprocess.run(['/bin/cp','-cR',str(r/'lean/.lake/build'),str(f/'lean/.lake/build')],check=True)
# Lake's own compiled configuration cache stays isolated too.
for p in (r/'lean/.lake').iterdir():
 if p.name not in ['packages','build']:
  if p.is_file():shutil.copy2(p,f/'lean/.lake'/p.name)
print(f)
