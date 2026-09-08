# Serialized kernel certificates official planning r2

Native Grok 4.6 repaired CERT-P1–P7 from independent GPT-6 r1 NEEDS REVISION. Independent GPT-6 must review this r2 freeze. Gate remains false. No certificate feature is implemented.

r1 archive SHA-256 `a845bc2b5d6a055252152c47c700adfd3dd89aeb3a7c25c0f1e792d7ccbba3ed` and r1 synthetic controls are preserved as historical evidence.

## Reviewer command (read-only)

```
python3 review/semantic-kernel/certificates/planning/grok-gpt6-official-r2/package.py --check
```

`--check` writes nothing. Independently hash `MANIFEST.json` and compare to `ANCHOR.json` field `manifest_sha256`.
