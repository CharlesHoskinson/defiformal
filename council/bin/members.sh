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
      # per instruction. Correction to the original characterisation:
      # this is NOT "never logged in". `~/.claude/.credentials.json`
      # exists (Max subscription, full scopes) -- the credentials are
      # present. But its `expiresAt` is 0 and the token refresh fails,
      # which is why `claude auth status` still reports `{"loggedIn":
      # false, "authMethod": "none"}` and a direct call (bypassing
      # foreman-launch entirely) returns "Failed to authenticate: OAuth
      # session expired and could not be refreshed" (exit 0). The
      # accurate statement is "credentials present but the OAuth session
      # is expired and unrefreshable", not "never logged in" -- that
      # points at Charles re-authenticating (`claude auth login` or
      # `claude setup-token`) to refresh the existing session, not at
      # setting up a fresh one. No ANTHROPIC_API_KEY, no
      # CLAUDE_CONFIG_DIR, and no foreman-specific claude credential
      # profile (unlike grok's GROK_HOME) were found on PATH or in
      # foreman-launch.js as an alternate route. Already surfaced to
      # Charles; not an agent-fixable problem.
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
      # Lens history, in order:
      #  1. gemini -- BLOCKED: no auth method configured on this box, and
      #     every invocation (even a direct call from a fresh, unrelated
      #     mktemp -d, outside foreman-launch) crashes in gemini's own
      #     checkpoint cleanup on a pre-existing ~/.gemini/projects.json
      #     slug collision. Neither ours to patch.
      #  2. opencode -- switched to `opencode run "$ask" --format json
      #     --auto` (opencode/big-pickle, its zero-config free model).
      #     `--format json` was required: opencode's default renderer
      #     prints nothing to stdout without a real TTY. VERIFIED
      #     end-to-end against the real smoke fixture, TWICE, reproduced
      #     identically both times: it read ./brief.md via a real tool
      #     call and returned a clean final answer with no narration
      #     prefix -- extraction was not necessary. For the record, since
      #     it cuts against what's below: this was not a fluke or a
      #     misread -- two independent live full-fixture runs, both
      #     correct and grounded in the actual fixture content.
      #  3. `opencode auth list` was then found to report "0 credentials"
      #     (~/.local/share/opencode/auth.json) -- the same shape of
      #     signal that flagged gemini as broken -- so this lane was
      #     redirected to agy (Antigravity) rather than risk relying on
      #     an unexplained zero-config path. (The "0 credentials" store
      #     is documented as being for bring-your-own external provider
      #     keys only; whatever lets opencode/* models authenticate
      #     without one is a separate, unexplained mechanism -- it just
      #     happened to work twice in direct testing here.)
      #
      # agy 1.1.19 (Antigravity) -- UNVERIFIED, CONTROLLER TESTING. Per
      # explicit instruction, this invocation is recorded from `agy
      # --help` only and has NOT been run: the controller is verifying
      # agy's own auth in parallel and asked that this lane not also be
      # dispatched from here, to avoid two sessions driving the same CLI
      # and confusing each other's results. Flags per --help: `--print`
      # (alias `-p`; boolean -- prompt is positional per the pattern
      # every other lens follows) starts non-interactive print mode;
      # `--output-format json` for machine-readable output; `--json-schema
      # <schema>` "to enforce structured output" (--help notes it is
      # "for stream-json, only applicable to the final result", so its
      # interaction with plain --output-format json is itself unverified);
      # `--dangerously-skip-permissions` to avoid the same class of
      # stalled-approval trap hit with grok and gemini. The schema below
      # is a smoke-fixture-specific placeholder (lens/verdict/summary) --
      # like grok's --json-schema attempt, this does not generalize to
      # Task 6/7's real per-lens contracts (ranking/findings) without
      # further work, which is untouched here.
      #
      # Once the controller confirms agy's auth, replace this guard with
      # a real dispatch and re-verify against the smoke fixture before
      # trusting it in Task 6/7.
      reproducer)
        echo "reproducer/agy: recorded, not dispatched -- controller is verifying agy auth separately; see members.sh comment" > "$log"
        : > "$out"
        # would-be invocation, NOT executed:
        #   _launch "$out" "$log" agy --print --output-format json \
        #     --json-schema '{"type":"object","properties":{"lens":{"type":"string"},"verdict":{"type":"string"},"summary":{"type":"string"}},"required":["lens","verdict","summary"]}' \
        #     --dangerously-skip-permissions "$ask"
        exit 125
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
