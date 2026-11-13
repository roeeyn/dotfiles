# Apply one of Rex's built-in themes to a single pane using OSC color sequences.
# Rex ignores the block API's set_theme from the CLI (the app owns the block),
# but honors escape sequences a program inside the pane writes.
#
#   rex-theme                     pick a theme with fzf, apply to this pane
#   rex-theme cinder-peak         apply by id
#   rex-theme reset               back to the app's theme
#   rex-theme -b BLOCK [name]     apply to another pane (must be at a shell prompt)
#   rex-theme -l                  list theme ids

# The theme list ships inside the app bundle; beta and stable installs differ in name.
if [[ -z "${REX_THEMES_JSON:-}" ]]; then
  for _rex_app in "/Applications/Rex Beta.app" "/Applications/Rex.app"; do
    REX_THEMES_JSON="$_rex_app/Contents/Resources/SuperUI_SuperDesignTokens.bundle/Contents/Resources/themes.json"
    [[ -r "$REX_THEMES_JSON" ]] && break
  done
  unset _rex_app
fi

_rex_theme_osc() {
  # Prints the escape sequences for theme id $1, or the resets for "reset".
  if [[ "$1" == reset ]]; then
    printf '\e]104\a\e]110\a\e]111\a\e]112\a\e]117\a\e]119\a'
    return
  fi
  jq -j --arg id "$1" '
    (.[] | select(.id == $id) | .source) as $t
    | ($t.ansi | to_entries | map("\u001b]4;\(.key);\(.value)\u0007") | join("")),
      "\u001b]10;\($t.foreground)\u0007",
      "\u001b]11;\($t.background)\u0007",
      "\u001b]12;\($t.cursor)\u0007",
      "\u001b]17;\($t.selectionBackground)\u0007",
      "\u001b]19;\($t.selectionForeground)\u0007"
  ' "$REX_THEMES_JSON"
}

rex-theme() {
  local block="" id
  if [[ ! -r "$REX_THEMES_JSON" ]]; then
    print -u2 "rex-theme: themes.json not found; set REX_THEMES_JSON"
    return 1
  fi
  if [[ "$1" == -l ]]; then
    jq -r '.[] | "\(.id)\t\(.appearance)"' "$REX_THEMES_JSON" | column -t
    return
  fi
  if [[ "$1" == -b ]]; then
    block="$2"; shift 2
  fi
  id="$1"
  if [[ -z "$id" ]]; then
    id=$(jq -r '.[] | "\(.id)\t\(.appearance)\t\(.name)"' "$REX_THEMES_JSON" \
      | fzf --with-nth=1,2 --delimiter='\t' --prompt='rex theme> ' | cut -f1)
    [[ -z "$id" ]] && return 1
  fi
  if [[ "$id" != reset ]] && ! jq -e --arg id "$id" 'any(.[]; .id == $id)' "$REX_THEMES_JSON" >/dev/null; then
    print -u2 "rex-theme: unknown theme '$id' (try rex-theme -l)"
    return 1
  fi

  if [[ -z "$block" ]]; then
    _rex_theme_osc "$id"
  else
    # Ask the target pane's shell to run this same function; its output must
    # come from inside that pane for Rex to apply it.
    rex block send -b "$block" "rex-theme $id"$'\n'
  fi
}
