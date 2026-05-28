#!/usr/bin/env bash
# doc-librarian session scan.
#
# Cheap, deterministic, no LLM. Decides only WHETHER the librarian should
# engage; it never groups or summarizes. Grouping is the agent's job.
#
# Reads .agent/librarian.json from the project root. If that file is absent,
# this is a no-op (exit 0, silent) so the hook is harmless in any project.
#
# On a Claude Code SessionStart hook, prints a JSON object whose
# additionalContext nudges the agent to consider dispatching doc-librarian.
# Run standalone, prints the same notice as plain text.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
CONFIG="$PROJECT_DIR/.agent/librarian.json"

# No config, nothing to manage.
[ -f "$CONFIG" ] || exit 0

# Without jq we cannot parse config safely; degrade to silent no-op.
command -v jq >/dev/null 2>&1 || exit 0

threshold=$(jq -r '.chapter_threshold_bytes // 8192' "$CONFIG")
min_docs=$(jq -r '.chapter_min_docs // 3' "$CONFIG")

flags=""

while IFS= read -r root; do
  [ -n "$root" ] || continue
  abs="$PROJECT_DIR/$root"
  [ -d "$abs" ] || continue

  total=0
  count=0
  while IFS= read -r f; do
    sz=$(wc -c < "$f" | tr -d ' ')
    total=$((total + sz))
    count=$((count + 1))
  done < <(find "$abs" -type f -name '*.md' -not -path '*/_chapters/*' ! -name 'INDEX.md')

  [ "$count" -ge "$min_docs" ] || continue
  [ "$total" -ge "$threshold" ] || continue

  index="$abs/INDEX.md"
  if [ ! -f "$index" ]; then
    flags="${flags}- ${root}: ${count} docs, ${total}B over budget, no INDEX.md yet → needs initial catalog"$'\n'
  elif [ -n "$(find "$abs" -type f -name '*.md' -not -path '*/_chapters/*' ! -name 'INDEX.md' -newer "$index" -print -quit)" ]; then
    flags="${flags}- ${root}: documents changed since INDEX.md → needs filing / refresh"$'\n'
  fi
done < <(jq -r '.managed_roots[]?' "$CONFIG")

# Nothing to flag.
[ -n "$flags" ] || exit 0

notice="doc-librarian: managed documentation needs attention.
${flags}
Tell the user this, then dispatch the doc-librarian agent to catalog the flagged root(s). Do not reorganize docs silently."

# Under a Claude Code SessionStart hook, emit JSON additionalContext.
# Run from any other tool or by hand, print the same notice as plain text.
if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
  jq -n --arg ctx "$notice" \
    '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $ctx}}'
else
  printf '%s\n' "$notice"
fi
