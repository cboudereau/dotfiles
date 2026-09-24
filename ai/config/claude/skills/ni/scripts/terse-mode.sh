#!/usr/bin/env bash
# Read or write the ni terse level. State: $CLAUDE_CONFIG_DIR/ni/terse (default ~/.claude/ni/terse).
# Usage: terse-mode.sh            -> print current level (lite|full|off)
#        terse-mode.sh <level>    -> set level and print it
set -u
CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
STATE="$CONFIG_DIR/ni/terse"
DEFAULT="lite"

valid() { case "$1" in lite|full|off) return 0;; *) return 1;; esac; }

if [ $# -ge 1 ]; then
  level="$(printf %s "$1" | tr '[:upper:]' '[:lower:]')"
  if ! valid "$level"; then
    echo "ni terse: unknown level '$1'. Valid: lite, full, off." >&2
    exit 1
  fi
  mkdir -p "$(dirname "$STATE")"
  printf %s "$level" > "$STATE"
  echo "$level"
  exit 0
fi

if [ -r "$STATE" ]; then
  level="$(head -c 16 "$STATE" | tr -d '[:space:]')"
  valid "$level" && { echo "$level"; exit 0; }
fi
echo "$DEFAULT"
