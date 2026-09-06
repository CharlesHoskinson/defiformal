import datetime, hashlib, json, pathlib, subprocess, sys, tempfile
provider, bundle_arg, out_arg = sys.argv[1:]
bundle = pathlib.Path(bundle_arg).resolve()
out = pathlib.Path(out_arg).resolve()
out.parent.mkdir(parents=True, exist_ok=True)
if provider == "grok":
    model = "grok-4.6"
    argv = ["grok", "--model", model, "--reasoning-effort", "medium", "--no-subagents", "--disable-web-search", "--tools", "", "--output-format", "json", "--prompt-file", str(bundle)]
    prompt = None
elif provider == "fable":
    model = "claude-fable-5-1"
    argv = ["claude", "--print", "--model", model, "--effort", "medium", "--output-format", "json", "--tools", "", "--strict-mcp-config", "--mcp-config", '{"mcpServers":{}}', "--setting-sources", "", "--disable-slash-commands", "--no-session-persistence"]
    prompt = bundle.read_bytes()
else:
    raise SystemExit("unknown provider")
record = {"provider": provider, "requested_model": model, "argv": argv, "bundle_sha256": hashlib.sha256(bundle.read_bytes()).hexdigest(), "started_at": datetime.datetime.now(datetime.timezone.utc).isoformat(), "review_kind": "source review via native CLI; no independent execution claimed; no Foreman"}
with tempfile.TemporaryDirectory(prefix="defiformal-native-review-") as review_cwd:
    with out.open("wb") as stdout, out.with_suffix(".stderr").open("wb") as stderr:
        try:
            proc = subprocess.run(argv, input=prompt, cwd=review_cwd, stdout=stdout, stderr=stderr, timeout=600)
            record["exit_code"] = proc.returncode
        except subprocess.TimeoutExpired:
            record["exit_code"] = 124
            record["execution_error"] = "native review exceeded 600 seconds"
record["finished_at"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
record["response_sha256"] = hashlib.sha256(out.read_bytes()).hexdigest()
record["response_bytes"] = out.stat().st_size
out.with_suffix(".invocation.json").write_text(json.dumps(record, indent=2)+"\n")
print(json.dumps(record, indent=2))
raise SystemExit(record["exit_code"])
