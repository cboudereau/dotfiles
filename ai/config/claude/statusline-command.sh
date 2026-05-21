#!/bin/bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$used" ]; then
  filled=$(printf "%.0f" "$(echo "$used * 20 / 100" | bc -l)")
  empty=$((20 - filled))
  bar=""
  for i in $(seq 1 $filled); do bar="${bar}#"; done
  for i in $(seq 1 $empty); do bar="${bar}-"; done
  printf "%s  [%s] %.0f%%" "$model" "$bar" "$used"
else
  printf "%s  [--------------------] --%%" "$model"
fi
