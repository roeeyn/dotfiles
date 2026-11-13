# Event hooks for rex-review blocks. Inert unless the shell was started by
# rex-review with an events file: each line appended tells the agent that
# opened the block what the human did with the prefilled command.
#
#   ready              the line editor owns input; rex-review waits for this
#                      before typing (written once, at the first prompt)
#   ran <base64 cmd>   a command line was submitted (as run, edits included)
#   exit <code>        it finished
#   discarded          the prefilled line was dropped (Ctrl+C, or cleared and
#                      Enter) instead of run
#   closed             the block's shell exited

if [[ -n "${REX_REVIEW_EVENTS:-}" ]]; then
  autoload -Uz add-zsh-hook add-zle-hook-widget
  typeset -g _rex_review_ran=0 _rex_review_prompted=0

  # precmd also runs before the shell's first prompt. Text typed before then
  # sits in the tty and reaches the line editor intact, so a prefill logged
  # before the first prompt was never dropped; only a prompt that was already
  # editing can discard it.
  _rex_review_line_init() {
    if ((!_rex_review_prompted)); then
      _rex_review_prompted=1
      print -r -- "ready" >>"$REX_REVIEW_EVENTS"
    fi
  }

  _rex_review_preexec() {
    _rex_review_ran=1
    print -r -- "ran $(print -rn -- "$1" | base64 | tr -d '\n')" >>"$REX_REVIEW_EVENTS"
  }

  _rex_review_precmd() {
    local code=$?
    if ((_rex_review_ran)); then
      _rex_review_ran=0
      print -r -- "exit $code" >>"$REX_REVIEW_EVENTS"
    elif ((_rex_review_prompted)) &&
      [[ "$(grep -vx ready "$REX_REVIEW_EVENTS" 2>/dev/null | tail -n 1)" == prefilled* ]]; then
      print -r -- "discarded" >>"$REX_REVIEW_EVENTS"
    fi
  }

  _rex_review_zshexit() {
    print -r -- "closed" >>"$REX_REVIEW_EVENTS"
  }

  add-zle-hook-widget line-init _rex_review_line_init
  add-zsh-hook preexec _rex_review_preexec
  add-zsh-hook precmd _rex_review_precmd
  add-zsh-hook zshexit _rex_review_zshexit
fi
