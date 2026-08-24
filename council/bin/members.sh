#!/usr/bin/env bash
# The verified invocation table. Each entry was confirmed (or, where noted,
# blocked) by council/bin/smoke-members.sh, not taken from documentation.
#
# foreman-launch nulls the child's stdin, so `codex exec -` (stdin form)
# cannot be used here. Every prompt is positional and names a file the
# member reads from its own sandbox.
FL="$HOME/foreman/skills/foreman/runtime/dist/foreman-launch.js"
TIMEOUT="${COUNCIL_TIMEOUT:-900}"

_launch () {  # $1=outjson $2=outlog ; rest = command
  local out="$1" log="$2"; shift 2
  node "$FL" --timeout "$TIMEOUT" -- "$@" >"$out" 2>"$log"
}

# opencode's default ("formatted") run output renders nothing to stdout
# outside a real TTY -- only `--format json` gives a programmatic stream,
# and that stream is NDJSON protocol *events*, not the member's plain-text
# answer. This pulls out and concatenates every `{"type":"text",...}`
# event's `part.text`, which is opencode's equivalent of "what the other
# CLIs already put on stdout for free". This is unwrapping a documented,
# structured transport to reach the model's actual final answer -- not
# cleaning up the answer's content, which stays members.sh's business to
# leave alone (see the empirical/grok case below and extract-json.py).
_unwrap_opencode_text () {  # $1=raw ndjson $2=out
  python3 -c '
import json, sys
raw, out = sys.argv[1], sys.argv[2]
chunks = []
try:
    with open(raw, "r", encoding="utf-8", errors="replace") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                ev = json.loads(line)
            except ValueError:
                continue
            if ev.get("type") == "text":
                t = ev.get("part", {}).get("text")
                if t:
                    chunks.append(t)
except FileNotFoundError:
    pass
with open(out, "w", encoding="utf-8") as f:
    f.write("".join(chunks))
' "$1" "$2"
}

run_member () {  # $1=lens $2=sandbox $3=brief $4=outjson $5=outlog
  local lens="$1" sb="$2" brief="$3" out="$4" log="$5"
  local ask="Read ./$(basename "$brief") in full and follow it exactly. Do not read any other file. Output only the JSON object it specifies: no narration of what you are about to do or did, no markdown fences, nothing before or after the JSON."
  ( cd "$sb" || exit 125
    case "$lens" in
      # grok 1.0.5: `--prompt-file` (single-turn prompt read from a file)
      # used instead of `--single "$ask"` even though today's $ask is
      # small -- it sidesteps grok's documented argv-truncation trap for
      # good, so a future larger ask can't silently reintroduce it.
      # `--always-approve` is load-bearing: without it, grok's Read tool
      # call for ./brief.md sits waiting on a permission prompt that
      # foreman-launch's nulled stdin can never answer, and the run times
      # out (exit 124) instead of completing. `--max-turns 10` bounds a
      # read+compose task that needs only a couple of turns.
      #
      # TRIED AND REJECTED: `--json-schema` (constrained decoding, implies
      # --output-format json). It does defeat the narration prefix -- but
      # by skipping the read entirely. Against the real smoke fixture it
      # returned in a single turn (`"num_turns": 1`, no tool_use event)
      # with content totally unrelated to the actual brief/bundle:
      #   {"lens":"ux","verdict":"pass","summary":"No blocking UX issues.
      #   Primary actions are labeled, empty and error states are
      #   present, and the layout stays usable on a narrow viewport."}
      # -- fabricated, schema-shaped, and never grounded in ./brief.md or
      # ./bundle.md, whose actual subject (a 3-element vocabulary and a
      # redundancy claim) appears nowhere in it. Constrained output and
      # the tool call this interface requires are mutually exclusive in
      # this grok version: real finding, not a config error on our side.
      # (The response DID also carry a clean top-level "structuredOutput"
      # object alongside the noisy "text" field -- so if a future grok
      # version makes --json-schema tool-call-aware, unwrapping that
      # field would be the right fix; not applicable today.)
      #
      # Still open: grok's plain-mode stdout remains narration-prefixed
      # (a lead-in sentence before the JSON) on every read-then-answer
      # call -- four separate invocation attempts, including a full
      # --system-prompt-override, could not suppress it (see git history
      # for the earlier round's detail). That is now handled uniformly by
      # extract-json.py at the validation layer, not papered over here.
      empirical)
        local promptfile="$sb/.grok-prompt.txt"
        printf '%s' "$ask" > "$promptfile"
        _launch "$out" "$log" grok --prompt-file "$promptfile" -m grok-4.6 --effort high --always-approve --max-turns 10
        ;;
      # claude 2.1.233: brief's guess is syntactically correct and
      # unchanged. `-p`/`--print` is a boolean flag (prompt is positional,
      # not its value); Read is an always-allowed tool in print mode so no
      # permission-mode flag is needed for a read-only task. `--model
      # claude-opus-5` is a valid full model name (same generation-5 naming
      # as claude-fable-5, which `claude --help` gives as its own example).
      #
      # BLOCKED, not an invocation problem, and left exactly as written
      # per instruction: `claude auth status` on this box reports
      # `{"loggedIn": false, "authMethod": "none"}`. A direct call
      # (bypassing foreman-launch entirely) returns the same result:
      # stdout "Failed to authenticate: OAuth session expired and could
      # not be refreshed", exit 0. No ANTHROPIC_API_KEY, no
      # CLAUDE_CONFIG_DIR, and no foreman-specific claude credential
      # profile (unlike grok's GROK_HOME) were found on PATH or in
      # foreman-launch.js. This needs Charles to run `claude auth login`
      # (or `claude setup-token`, also interactive) once in this WSL
      # profile -- already surfaced to him; not an agent-fixable problem.
      formal)       _launch "$out" "$log" claude -p --model claude-opus-5 "$ask" ;;
      # codex-cli 0.149.0: brief's guess ran unchanged, first try, no
      # corrections needed. `codex exec` (the non-interactive subcommand,
      # distinct from bare `codex`) takes the prompt positionally and does
      # not stop for shell/file-read approval in this sandbox. `--skip-git-
      # repo-check` is required because the sandbox is a plain mktemp -d,
      # not a git repo, and codex exec refuses to start outside one
      # otherwise. VERIFIED end-to-end: returned a clean, contract-shaped
      # JSON object with a "verdict" key on the first live call.
      significance) _launch "$out" "$log" codex exec --skip-git-repo-check "$ask" ;;
      # SWITCHED from gemini to opencode 0.52.0 (opencode/big-pickle, its
      # own zero-config free-tier model -- `opencode auth list` shows "0
      # credentials" but that store is only for bring-your-own external
      # provider keys; the opencode/* models authenticate some other way
      # and just work). gemini was dropped per ruling: it has no auth
      # method configured on this box AND crashes in its own checkpoint
      # cleanup on a pre-existing ~/.gemini/projects.json slug collision,
      # reproduced even from a brand-new, unrelated mktemp -d -- both
      # environmental, neither ours to patch.
      #
      # `opencode run "$ask"` is the positional-prompt form. `--format
      # json` is required: opencode's default "formatted" renderer prints
      # nothing to stdout without a real TTY, so it is not merely a nicer
      # output mode here, it is the only one that produces anything
      # programmatically at all. `--auto` (auto-approve permissions not
      # explicitly denied) was added pre-emptively for the same class of
      # trap hit twice already (grok's --always-approve, gemini's
      # --skip-trust: a permission/trust prompt that nulled stdin can
      # never answer) -- not proven load-bearing by a negative control,
      # but cheap insurance given the pattern. VERIFIED end-to-end against
      # the real smoke fixture: it read ./brief.md via a tool call and
      # returned a clean final "text" part with NO narration prefix at
      # all -- extraction was not necessary for opencode in this run.
      # Raw stdout is NDJSON protocol events, not the answer text, hence
      # `_unwrap_opencode_text` above.
      #
      # Minor, non-blocking finding while verifying this: the shared $ask
      # wrapper says "Do not read any other file", but this smoke fixture's
      # own brief.md says "Read ./bundle.md" -- a real ambiguity in the
      # generic ask text. grok resolved it by reading bundle.md anyway;
      # opencode/big-pickle resolved it the other way and answered
      # "unverified" without reading bundle.md. Both satisfy this smoke
      # test (it only checks for a "verdict" key, not its value), so left
      # unchanged here -- worth a look wherever the brief-writing task
      # owns $ask's wording.
      reproducer)
        local raw="$sb/.opencode-events.jsonl"
        _launch "$raw" "$log" opencode run "$ask" --format json --auto
        local rc=$?
        _unwrap_opencode_text "$raw" "$out"
        exit "$rc"
        ;;
      # Not exercised by the Task 1 smoke test (only used starting in Task
      # 7's decider round) but defined here per the brief's interface so
      # dispatch.sh (Task 6) and Task 7 have a working `decider` case.
      # Mirrors the `formal` lens's flags with the fable model, and hits
      # the identical claude-auth blocker documented above.
      decider)      _launch "$out" "$log" claude -p --model claude-fable-5 "$ask" ;;
      *) echo "unknown lens: $lens" >&2; exit 125 ;;
    esac )
}
