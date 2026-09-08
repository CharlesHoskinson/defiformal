# Certificates official planning r4

Planning candidate only. `STATUS.gate_accepted` is false. Remaining R1/R3 repairs from official r3 CHANGES_REQUIRED.

```bash
python3 review/semantic-kernel/certificates/planning/grok-gpt6-official-r4/package.py --prepare
python3 review/semantic-kernel/certificates/planning/grok-gpt6-official-r4/package.py --seal
python3 review/semantic-kernel/certificates/planning/grok-gpt6-official-r4/package.py --check
python3 review/semantic-kernel/certificates/planning/grok-gpt6-official-r4/package.py --controls
python3 review/semantic-kernel/certificates/planning/grok-gpt6-official-r4/package.py --reachability
```

Independent GPT-6 must review this freeze. Do not treat author `--check` as planning acceptance.

r1 archive SHA-256 `a845bc2b5d6a055252152c47c700adfd3dd89aeb3a7c25c0f1e792d7ccbba3ed`, r2 archive SHA-256 `122118df438c8c05a09f48e5097fb6f6bfd3c19cedece4dee20aa32757c4bc13`, and r3 archive SHA-256 `e5b6415c6fe74b8654e9633e48dbc528118072b2f1306865b2c56855dab9b6a9` remain recoverable and unresealed.
