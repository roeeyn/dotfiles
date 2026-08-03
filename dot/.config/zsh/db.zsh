# db.zsh — tab-completion for the `db` command (~/.local/bin/db).
# Sourced from ~/.zshrc. The command itself is a script on $PATH so that
# coding agents' non-interactive shells can call it too; only the interactive
# completion lives here.

# List service names declared in ~/.pg_service.conf (the [name] section headers).
_db_services() {
  sed -n 's/^\[\(.*\)\]/\1/p' "${HOME}/.pg_service.conf" 2>/dev/null
}

# Tab-completion: `db <TAB>` offers the service names.
_db_complete() {
  local -a svcs
  svcs=(${(f)"$(_db_services)"})
  compadd -- $svcs
}
compdef _db_complete db 2>/dev/null
