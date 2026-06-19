# db.zsh — read-only psql helper for AlertMedia databases.
# Sourced from ~/.zshrc. Connection profiles live in ~/.pg_service.conf;
# passwords come from `pass` (or `notsecret` for localhost). Nothing secret here.
#
#   db                       list available services
#   db test03-nc-rr          interactive read-only psql to test03 notify_me_db
#   db local-stats           local stats_db (uses notsecret)
#   db load-nc-rr -c "SQL"   run one query; extra args pass straight to psql
#
# Convention: service <env>-<db>-rr  ->  pass key <env>-<db>-db-rr
# (local-* services skip pass and use the dev password `notsecret`.)

db() {
  emulate -L zsh
  local svc="$1"; shift 2>/dev/null

  if [[ -z "$svc" || "$svc" == (-h|--help) ]]; then
    print -r -- "usage: db <service> [psql args]"
    print -r -- "services:"
    _db_services | sed 's/^/  • /'
    return 1
  fi

  if ! _db_services | grep -qx -- "$svc"; then
    print -r -- "db: unknown service '$svc'"
    print -r -- "services:"
    _db_services | sed 's/^/  • /'
    return 1
  fi

  local pw
  if [[ "$svc" == local-* ]]; then
    pw=notsecret
  else
    local key="${svc%-rr}-db-rr"          # test03-nc-rr -> test03-nc-db-rr
    if ! pw="$(pass "$key" 2>/dev/null)" || [[ -z "$pw" ]]; then
      print -r -- "db: missing credential — add it with:  pass insert $key"
      return 1
    fi
  fi

  # Editor (\e → pg-nvim) and history settings live in ~/.psqlrc, shared by all
  # psql sessions — and psqlrc's \setenv wins over the environment anyway. The
  # one thing psqlrc can't know is which service this is, so we pass
  # PG_NVIM_SERVICE for pg-nvim's per-service schema completion (Phase 3).
  PGPASSWORD="$pw" PG_NVIM_SERVICE="$svc" psql "service=$svc" "$@"
}

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
