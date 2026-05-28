#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SOURCE_DIR="$REPO_ROOT/source"
PLUGIN_DIR="$REPO_ROOT/plugins/jihan-agents"
OPENCODE_DIST_DIR="$REPO_ROOT/distributions/opencode-plugin"
GEMINI_DIST_DIR="$REPO_ROOT/distributions/gemini-extension"
CODEX_DIST_DIR="$REPO_ROOT/distributions/codex-plugin"

AGENTS=(
  notion-writer
  verifier-on-sandbox
  notion-doc-verifier
  notion-verifier-gui
  notion-verifier-concept
  doc-librarian
)

SKILLS=(
  general-doc-rules
  method-doc-rules
)

# Claude Code plugin: single bundle, all roles flat under agents/, all skills flat under skills/.
mkdir -p "$PLUGIN_DIR/agents" "$PLUGIN_DIR/skills"

# Wipe stale agent/skill files in the plugin dir so removed roles don't linger.
rm -f "$PLUGIN_DIR"/agents/*.md
rm -rf "$PLUGIN_DIR"/skills/*

for agent in "${AGENTS[@]}"; do
  cp "$SOURCE_DIR/agents/$agent.md" "$PLUGIN_DIR/agents/$agent.md"
done

for skill in "${SKILLS[@]}"; do
  mkdir -p "$PLUGIN_DIR/skills/$skill"
  cp "$SOURCE_DIR/skills/$skill/SKILL.md" "$PLUGIN_DIR/skills/$skill/SKILL.md"
done

# doc-librarian SessionStart scan: Claude Code plugin only.
# Hooks are Claude-Code-specific; other distributions get doc-librarian as a
# manually-invoked agent/skill without the auto-scan.
mkdir -p "$PLUGIN_DIR/hooks" "$PLUGIN_DIR/scripts"
cp "$SOURCE_DIR/hooks/librarian-hooks.json" "$PLUGIN_DIR/hooks/hooks.json"
cp "$SOURCE_DIR/scripts/librarian-scan.sh" "$PLUGIN_DIR/scripts/librarian-scan.sh"
chmod +x "$PLUGIN_DIR/scripts/librarian-scan.sh"

# OpenCode distribution: same flat layout under .opencode/.
mkdir -p \
  "$OPENCODE_DIST_DIR/.opencode/agents" \
  "$OPENCODE_DIST_DIR/.opencode/skills"

rm -f "$OPENCODE_DIST_DIR/.opencode/agents"/*.md
rm -rf "$OPENCODE_DIST_DIR/.opencode/skills"/*

for skill in "${SKILLS[@]}"; do
  mkdir -p "$OPENCODE_DIST_DIR/.opencode/skills/$skill"
  cp "$SOURCE_DIR/skills/$skill/SKILL.md" \
    "$OPENCODE_DIST_DIR/.opencode/skills/$skill/SKILL.md"
done

for agent in "${AGENTS[@]}"; do
  agent_description=$(awk '/^description: / { sub(/^description: /, ""); print; exit }' "$SOURCE_DIR/agents/$agent.md")

  {
    printf -- "---\n"
    printf "description: %s\n" "$agent_description"
    printf "mode: subagent\n"
    printf -- "---\n\n"
    awk '
      NR == 1 && $0 == "---" { in_frontmatter = 1; next }
      in_frontmatter && $0 == "---" { in_frontmatter = 0; body = 1; next }
      body { print }
    ' "$SOURCE_DIR/agents/$agent.md"
  } > "$OPENCODE_DIST_DIR/.opencode/agents/$agent.md"
done

# Gemini CLI extension: agents become user-invokable skills, source skills stay as-is.
# gemini-extension.json and GEMINI.md are committed source files, not regenerated here.
mkdir -p "$GEMINI_DIST_DIR/skills"

rm -rf "$GEMINI_DIST_DIR/skills"/*

for skill in "${SKILLS[@]}"; do
  mkdir -p "$GEMINI_DIST_DIR/skills/$skill"
  cp "$SOURCE_DIR/skills/$skill/SKILL.md" \
    "$GEMINI_DIST_DIR/skills/$skill/SKILL.md"
done

for agent in "${AGENTS[@]}"; do
  agent_description=$(awk '/^description: / { sub(/^description: /, ""); print; exit }' "$SOURCE_DIR/agents/$agent.md")

  case "$agent" in
    notion-verifier-gui|notion-verifier-concept)
      user_invokable=false ;;
    *)
      user_invokable=true ;;
  esac

  mkdir -p "$GEMINI_DIST_DIR/skills/$agent"
  {
    printf -- "---\n"
    printf "name: %s\n" "$agent"
    printf "description: %s\n" "$agent_description"
    printf "user-invokable: %s\n" "$user_invokable"
    printf -- "---\n\n"
    awk '
      NR == 1 && $0 == "---" { in_frontmatter = 1; next }
      in_frontmatter && $0 == "---" { in_frontmatter = 0; body = 1; next }
      body { gsub(/에이전트/, "스킬"); print }
    ' "$SOURCE_DIR/agents/$agent.md"
  } > "$GEMINI_DIST_DIR/skills/$agent/SKILL.md"
done

# Codex CLI plugin: agents and source skills land flat under skills/.
# Codex SKILL.md frontmatter is minimal (name, description). No user-invokable.
# .codex-plugin/plugin.json is a committed source file, not regenerated here.
mkdir -p "$CODEX_DIST_DIR/skills"

rm -rf "$CODEX_DIST_DIR/skills"/*

for skill in "${SKILLS[@]}"; do
  mkdir -p "$CODEX_DIST_DIR/skills/$skill"
  cp "$SOURCE_DIR/skills/$skill/SKILL.md" \
    "$CODEX_DIST_DIR/skills/$skill/SKILL.md"
done

for agent in "${AGENTS[@]}"; do
  agent_description=$(awk '/^description: / { sub(/^description: /, ""); print; exit }' "$SOURCE_DIR/agents/$agent.md")

  mkdir -p "$CODEX_DIST_DIR/skills/$agent"
  {
    printf -- "---\n"
    printf "name: %s\n" "$agent"
    printf "description: %s\n" "$agent_description"
    printf -- "---\n\n"
    awk '
      NR == 1 && $0 == "---" { in_frontmatter = 1; next }
      in_frontmatter && $0 == "---" { in_frontmatter = 0; body = 1; next }
      body { gsub(/에이전트/, "스킬"); print }
    ' "$SOURCE_DIR/agents/$agent.md"
  } > "$CODEX_DIST_DIR/skills/$agent/SKILL.md"
done

echo "synced distributions from source"
