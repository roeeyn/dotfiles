# Event hooks for rex-review blocks. Inert unless the shell was started by
# rex-review with an events file: each line appended tells the agent that
# opened the block what the human did with the prefilled command.
#
#   ran <base64 cmd>   a command line was submitted (as run, edits included)
#   exit <code>        it finished
#   discarded          the prefilled line was dropped (Ctrl+C) instead of run
#   closed             the block's shell exited

if [[ -n "${REX_REVIEW_EVENTS:-}" ]]; then
  autoload -Uz add-zsh-hook
  typeset -g _rex_review_ran=0

  _rex_review_preexec() {
    _rex_review_ran=1
    print -r -- "ran $(print -rn -- "$1" | base64 | tr -d '\n')" >>"$REX_REVIEW_EVENTS"
  }

  _rex_review_precmd() {
    local code=$?
    if ((_rex_review_ran)); then
      _rex_review_ran=0
      print -r -- "exit $code" >>"$REX_REVIEW_EVENTS"
    elif [[ "$(tail -n 1 "$REX_REVIEW_EVENTS" 2>/dev/null)" == prefilled* ]]; then
      print -r -- "discarded" >>"$REX_REVIEW_EVENTS"
    fi
  }

  _rex_review_zshexit() {
    print -r -- "closed" >>"$REX_REVIEW_EVENTS"
  }

  add-zsh-hook preexec _rex_review_preexec
  add-zsh-hook precmd _rex_review_precmd
  add-zsh-hook zshexit _rex_review_zshexit
fi
