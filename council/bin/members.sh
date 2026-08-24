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
      # grok 1.0.5: `-p`/`--single` takes the prompt as ITS VALUE (matches
      # the brief's guess). `--always-approve` is load-bearing: without it,
      # grok's Read tool call for ./brief.md sits waiting on a permission
      # prompt that foreman-launch's nulled stdin can never answer, and the
      # run times out (exit 124) instead of completing. `--max-turns 10`
      # bounds a read+compose task that needs only a couple of turns.
      #
      # OPEN FINDING, not fixed by any invocation tried: grok reaches the
      # model, reads the right file, and reasons correctly, but its final
      # stdout is consistently prefixed with a short narration sentence
      # before the JSON, e.g.:
      #   I'll read `./brief.md` now and follow it exactly.The brief
      #   requires `./bundle.md` next, so I'll read that and then return
      #   only the specified JSON.{"lens":"smoke","verdict":"rejected",...}
      # This survived four distinct attempts: (1) the plain ask above with
      # its "no narration" clause, (2) adding `--no-plan`, (3) a much more
      # forceful ask ("no narration ... nothing before or after the JSON"),
      # and (4) replacing the whole agent system prompt with
      # `--system-prompt-override "You are a silent JSON-emitting tool...
      # your FINAL reply must consist of nothing but the requested JSON
      # object"`. All four produced the same shape of lead-in sentence.
      # `--output-format json` was also tried: it does NOT wrap the raw
      # narration+JSON in a fence to strip -- the narration is already
      # baked into the model's own final-turn "text" field inside that
      # envelope, so switching output format doesn't help either, and the
      # envelope's top-level keys (text/stopReason/sessionId/...) aren't
      # contract-shaped regardless. Conclusion: this looks like CLI/model
      # scaffolding narrating its next tool call inline with the final
      # answer whenever a Read tool call is involved, not a prompt-
      # compliance gap `--single` can be steered out of. Left un-worked-
      # around here per the brief's own instruction that this class of
      # problem (clean JSON extraction from noisy CLI output) belongs to
      # Task 5's validator, not to this invocation table.
      empirical)    _launch "$out" "$log" grok --single "$ask" -m grok-4.6 --effort high --always-approve --max-turns 10 ;;
      # claude 2.1.233: brief's guess is syntactically correct and
      # unchanged. `-p`/`--print` is a boolean flag (prompt is positional,
      # not its value); Read is an always-allowed tool in print mode so no
      # permission-mode flag is needed for a read-only task. `--model
      # claude-opus-5` is a valid full model name (same generation-5 naming
      # as claude-fable-5, which `claude --help` gives as its own example).
      #
      # BLOCKED, not an invocation problem: `claude auth status` on this
      # box reports `{"loggedIn": false, "authMethod": "none"}`. A direct
      # call (bypassing foreman-launch entirely) returns the same result:
      # stdout "Failed to authenticate: OAuth session expired and could not
      # be refreshed", exit 0. No ANTHROPIC_API_KEY, no CLAUDE_CONFIG_DIR,
      # and no foreman-specific claude credential profile (unlike grok's
      # GROK_HOME) were found on PATH or in foreman-launch.js. This needs a
      # human to run `claude auth login` (or `claude setup-token`, which
      # also requires interactive confirmation) in this WSL profile before
      # this lens -- or `decider`, below, which hits the identical wall --
      # can be verified end-to-end. Not attempted here: logging in is a
      # credential action outside an agent's remit, not something an
      # invocation flag fixes.
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
      # gemini 0.52.0 via the Windows npm shim at
      # /mnt/c/Users/charl/AppData/Roaming/npm/gemini: the shim has no
      # sibling `node.exe` next to it, so it falls through to WSL's own
      # `node` on PATH and runs bundle/gemini.js from the Windows-mounted
      # path under a normal WSL process -- the sandbox dir (a WSL /tmp
      # path) is then just this process's cwd, not an argument the shim
      # has to translate, so the brief's stated risk ("may not accept WSL
      # path arguments") did not bite here: no path is ever passed as an
      # argument, only the prompt text is. `--skip-trust` added because,
      # without it, gemini treats the fresh sandbox dir as an untrusted
      # workspace and blocks on a trust dialog that nulled stdin can't
      # answer.
      #
      # BLOCKED by two independent, pre-existing environment problems,
      # neither caused by this task and neither fixable by an invocation
      # flag: (1) no auth method is configured at all -- ~/.gemini/
      # settings.json does not exist, and none of GEMINI_API_KEY /
      # GOOGLE_GENAI_USE_VERTEXAI / GOOGLE_GENAI_USE_GCA are set; (2) even
      # before reaching auth, every invocation (including a direct call
      # from a fresh, unrelated mktemp dir, outside foreman-launch) crashes
      # during gemini's own startup checkpoint-cleanup with an uncaught
      # `EEXIST`: "Slug council is already owned by
      # /mnt/c/Users/charl/Council" -- a pre-existing, case-colliding entry
      # in ~/.gemini/projects.json's project-slug registry
      # ({"/mnt/c/Users/charl/Council": "council", ...}), unrelated to our
      # sandbox's own (non-colliding) slug. This matches the brief's own
      # pre-approved risk for this lens: after this genuine attempt, no
      # workaround was invented (neither the registry file nor gemini
      # settings were edited). Recommend the controller move this lane to
      # `opencode` or `agy` as the brief anticipates.
      reproducer)   _launch "$out" "$log" gemini -p "$ask" --skip-trust ;;
      # Not exercised by the Task 1 smoke test (only used starting in Task
      # 7's decider round) but defined here per the brief's interface so
      # dispatch.sh (Task 6) and Task 7 have a working `decider` case.
      # Mirrors the `formal` lens's flags with the fable model, and hits
      # the identical claude-auth blocker documented above.
      decider)      _launch "$out" "$log" claude -p --model claude-fable-5 "$ask" ;;
      *) echo "unknown lens: $lens" >&2; exit 125 ;;
    esac )
}
