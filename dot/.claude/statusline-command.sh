#!/usr/bin/env bash
# Claude Code status line script
# Mirrors a Starship-style prompt with Claude Code context info

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Claude.ai subscription rate limits. Present only for Pro/Max/Team accounts,
# and only after the session's first API response — each window can be absent
# independently, so every read falls back to empty.
five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
five_h_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_d_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Shorten the path: replace $HOME with ~
home_dir="$HOME"
short_cwd="${cwd/#$home_dir/~}"

# Git branch (skip optional locks)
git_branch=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" -c core.hooksPath=/dev/null symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Build the status line with ANSI colors (printf handles escape sequences)
dir_part="$short_cwd"

line=""

# The bar carries three number-bearing clusters that mean different things —
# where you are, what this session is doing, what the account has left. Run
# together they read as one undifferentiated string of percentages, so groups
# are joined by a dim │ (the same divider the watcher block below uses).
# add_group emits the separator only between two non-empty groups, which keeps
# the bar from opening or ending with a dangling divider when a field is absent.
sep=$(printf ' \033[90m│\033[0m ')

add_group() {
  [ -z "$1" ] && return
  [ -n "$line" ] && line+="$sep"
  line+="$1"
}

# location: directory in bold blue, git branch in yellow
loc=$(printf '\033[1;34m%s\033[0m' "$dir_part")
if [ -n "$git_branch" ]; then
  loc+=$(printf ' \033[33m(%s)\033[0m' "$git_branch")
fi
add_group "$loc"

# session: model in magenta, context window green until it gets tight
ses=""
if [ -n "$model" ]; then
  ses+=$(printf '\033[35m[%s]\033[0m' "$model")
fi
if [ -n "$used_pct" ]; then
  used_int=${used_pct%.*}
  if [ "$used_int" -ge 80 ] 2>/dev/null; then
    ses+=$(printf ' \033[31mctx:%s%%\033[0m' "$used_int")
  else
    ses+=$(printf ' \033[32mctx:%s%%\033[0m' "$used_int")
  fi
fi
add_group "${ses# }"

# Rate-limit window: "5h:9%" green under 50, yellow to 79, red at 80+. The
# reset clock is appended only once a window runs hot — when there's headroom
# the timestamp is noise, and when there isn't it's the only number that helps.
# (Replaces an older block that rendered wall-clock session duration as "/5h";
# elapsed time is not utilization, so it read as data while telling you nothing.)
limit_seg() {
  local label=$1 pct=$2 reset=$3 color
  [ -z "$pct" ] && return
  local int=${pct%.*}
  if [ "$int" -ge 80 ] 2>/dev/null; then
    color=31
  elif [ "$int" -ge 50 ] 2>/dev/null; then
    color=33
  else
    color=32
  fi
  local text
  text=$(printf '%s: %s%%' "$label" "$int")
  if [ "$int" -ge 80 ] 2>/dev/null && [ -n "$reset" ]; then
    local at
    at=$(date -r "$reset" +%H:%M 2>/dev/null) && text+="→$at"
  fi
  printf ' \033[%sm%s\033[0m' "$color" "$text"
}

quota="$(limit_seg 5h "$five_h" "$five_h_reset")$(limit_seg 7d "$seven_d" "$seven_d_reset")"
add_group "${quota# }"

printf '%s' "$line"


# >>> statusline-watcher >>>
# Progress watchers from ~/.claude/statusline-watcher/state-<session>.json,
# rendered as extra status-bar rows. Managed by the statusline-watcher skill —
# install.sh replaces everything between these markers on update; edit the
# skill repo, not this copy.
# Requires: bash, jq, and the host script capturing stdin as $input (input=$(cat)).
sw_sid=$(printf '%s' "${input:-}" | jq -r '.session_id // empty' 2>/dev/null)
if [ -n "$sw_sid" ]; then
  sw_state="$HOME/.claude/statusline-watcher/state-${sw_sid}.json"
  sw_ttl=3600
  if [ -s "$sw_state" ]; then
    sw_now=$(date +%s)
    sw_spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    sw_frame="${sw_spin:$((sw_now % 10)):1}"
    sw_cols=${COLUMNS:-120}
    sw_layout=$(jq -r '.layout // "row"' "$sw_state" 2>/dev/null)
    sw_maxlabel=0
    sw_maxcount=0
    if [ "$sw_layout" = "stack" ]; then
      sw_maxlabel=$(jq -r --argjson now "$sw_now" --argjson ttl "$sw_ttl" \
        '[.watchers[] | select(($now - .started_at) < $ttl) | .label | length] | max // 0' \
        "$sw_state" 2>/dev/null)
      sw_maxcount=$(jq -r --argjson now "$sw_now" --argjson ttl "$sw_ttl" \
        '[.watchers[] | select(($now - .started_at) < $ttl) | "\(.current)/\(.total)" | length] | max // 0' \
        "$sw_state" 2>/dev/null)
    fi
    sw_line=""
    sw_line_len=0
    while IFS=$'\t' read -r sw_label sw_cur sw_tot sw_started sw_eta; do
      sw_span=$((sw_eta - sw_started)); [ "$sw_span" -le 0 ] && sw_span=1
      sw_pct=$(( (sw_now - sw_started) * 100 / sw_span ))
      [ "$sw_pct" -gt 100 ] && sw_pct=100
      [ "$sw_pct" -lt 0 ] && sw_pct=0
      sw_filled=$((sw_pct * 12 / 100))
      sw_bar=""
      for ((sw_i = 0; sw_i < 12; sw_i++)); do
        if [ "$sw_i" -lt "$sw_filled" ]; then sw_bar+="█"; else sw_bar+="░"; fi
      done
      sw_left=$((sw_eta - sw_now))
      if [ "$sw_left" -ge 0 ]; then
        sw_time_plain="${sw_left}s left"
        sw_time=$(printf '\033[36m%s\033[0m' "$sw_time_plain")
      else
        sw_time_plain="overdue $((-sw_left))s"
        sw_time=$(printf '\033[31m%s\033[0m' "$sw_time_plain")
      fi
      sw_count="$sw_cur/$sw_tot"
      if [ "$sw_layout" = "stack" ]; then
        sw_label=$(printf '%-*s' "$sw_maxlabel" "$sw_label")
        sw_count=$(printf '%-*s' "$sw_maxcount" "$sw_count")
      fi
      sw_seg=$(printf '%s \033[1m%s\033[0m \033[33m%s\033[0m [%s] %s' \
        "$sw_frame" "$sw_label" "$sw_count" "$sw_bar" "$sw_time")
      sw_plain="$sw_frame $sw_label $sw_count [$sw_bar] $sw_time_plain"
      sw_seg_len=${#sw_plain}
      if [ "$sw_layout" = "stack" ]; then
        printf '\n%s' "$sw_seg"
      elif [ -z "$sw_line" ]; then
        sw_line="$sw_seg"
        sw_line_len=$sw_seg_len
      elif [ $((sw_line_len + 3 + sw_seg_len)) -le "$sw_cols" ]; then
        sw_line+=" │ $sw_seg"
        sw_line_len=$((sw_line_len + 3 + sw_seg_len))
      else
        printf '\n%s' "$sw_line"
        sw_line="$sw_seg"
        sw_line_len=$sw_seg_len
      fi
    done < <(jq -r --argjson now "$sw_now" --argjson ttl "$sw_ttl" \
      '.watchers[] | select(($now - .started_at) < $ttl) | [.label, .current, .total, .started_at, .eta_at] | @tsv' \
      "$sw_state" 2>/dev/null)
    if [ -n "$sw_line" ]; then printf '\n%s' "$sw_line"; fi
  fi
fi
# <<< statusline-watcher <<<
