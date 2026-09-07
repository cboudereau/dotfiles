#!/bin/bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
cwd="${cwd/#$HOME/~}"
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
tokens_used=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
tokens_max=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

human() {
  awk -v n="$1" 'BEGIN {
    if (n >= 1000000) { v = n / 1000000; suffix = "M" }
    else if (n >= 1000) { v = n / 1000; suffix = "k" }
    else { printf "%d", n; exit }
    if (v >= 100) printf "%.0f%s", v, suffix
    else printf "%.1f%s", v, suffix
  }'
}
session_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
session_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

if [ -n "$used" ]; then
  filled=$(printf "%.0f" "$(echo "$used * 20 / 100" | bc -l)")
  empty=$((20 - filled))
  bar=""
  for i in $(seq 1 $filled); do bar="${bar}#"; done
  for i in $(seq 1 $empty); do bar="${bar}-"; done
  out=$(printf "%s  [%s] %.0f%%" "$model" "$bar" "$used")
  if [ -n "$tokens_used" ] && [ -n "$tokens_max" ]; then
    out="$out ($(human "$tokens_used")/$(human "$tokens_max"))"
  fi
else
  out=$(printf "%s  [--------------------] --%%" "$model")
fi

if [ -n "$session_pct" ]; then
  quota=$(printf "session %.0f%%" "$session_pct")
  if [ -n "$session_reset" ]; then
    quota="$quota (resets $(date -d "@$session_reset" +%H:%M))"
  fi
  out="$out | $quota"
fi

if [ -n "$week_pct" ]; then
  out="$out | week $(printf "%.0f%%" "$week_pct")"
fi

if [ -n "$cwd" ]; then
  out="$out | $cwd"
fi

printf "%s" "$out"
