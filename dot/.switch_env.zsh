############# Switch Env #############

switch-env() {
  if [ -z "${1:-}" ]; then
    git checkout -
    return $?
  fi

  local current_branch
  current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

  if [ -z "$current_branch" ]; then
    echo "Error: not in a git repository or HEAD is detached"
    return 1
  fi

  local target_branch="${1}-${current_branch}"

  # Try checking out existing branch first (local or remote-tracking),
  # otherwise create a new one from current HEAD
  git checkout "$target_branch" 2>/dev/null || git checkout -b "$target_branch"
}
