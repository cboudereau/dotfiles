#!/usr/bin/env bash
# SessionStart hook: inject the terse ruleset as hidden session context.
# Plain stdout from a SessionStart hook becomes context for the session.
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cat >/dev/null   # drain the hook payload on stdin
level="$("$ROOT/scripts/terse-mode.sh")"
[ "$level" = "off" ] && { echo OK; exit 0; }
skill="$ROOT/skills/terse/SKILL.md"
echo "NI TERSE ACTIVE, level: $level. Apply the rules below to every reply. Switch with /ni:terse lite|full|off."
echo
if [ -r "$skill" ]; then
  # Strip the frontmatter block, keep the body.
  awk 'BEGIN{fm=0} NR==1 && /^---$/ {fm=1; next} fm==1 && /^---$/ {fm=0; next} fm==0 {print}' "$skill"
else
  echo "Reply short. Every technical fact stays. Only filler goes. No openers, hedging, recaps, or tool narration. Technical terms, code, commands, and errors verbatim. Persisted text (docs, MR/PR, issues, comments, commit messages) follows lite rules, never fragments. Plain prose for security warnings and irreversible actions."
fi
