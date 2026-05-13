#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_SRC="$ROOT_DIR/skills/supply-chain-safety"
GUARDRAIL_SRC="$ROOT_DIR/templates/supply-chain-guardrail.md"

TARGET_AGENT="${TARGET_AGENT:-codex}"
INSTALL_GUARDRAIL="${INSTALL_GUARDRAIL:-1}"

usage() {
  cat <<'USAGE'
Usage: scripts/install.sh [--agent codex|claude|both] [--no-guardrail]

Environment overrides:
  CODEX_HOME   Default: ~/.codex
  CLAUDE_HOME  Default: ~/.claude

Examples:
  scripts/install.sh
  scripts/install.sh --agent claude
  scripts/install.sh --agent both
  INSTALL_GUARDRAIL=0 scripts/install.sh
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)
      TARGET_AGENT="${2:-}"
      shift 2
      ;;
    --agent=*)
      TARGET_AGENT="${1#--agent=}"
      shift
      ;;
    --no-guardrail)
      INSTALL_GUARDRAIL=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

install_skill() {
  local home_dir="$1"
  local skills_dir="$home_dir/skills"
  local target="$skills_dir/supply-chain-safety"

  mkdir -p "$skills_dir"
  rm -rf "$target"
  cp -R "$SKILL_SRC" "$target"
  echo "Installed skill: $target"
}

upsert_guardrail() {
  local file="$1"
  local start_marker="<!-- supply-chain-safety-skill:start -->"
  local end_marker="<!-- supply-chain-safety-skill:end -->"
  local tmp
  tmp="$(mktemp)"

  mkdir -p "$(dirname "$file")"
  if [[ -f "$file" ]]; then
    awk -v start="$start_marker" -v end="$end_marker" '
      $0 == start { skip=1; next }
      $0 == end { skip=0; next }
      skip != 1 { print }
    ' "$file" > "$tmp"
  else
    : > "$tmp"
  fi

  {
    sed '/^[[:space:]]*$/{$d;}' "$tmp"
    echo
    echo "$start_marker"
    cat "$GUARDRAIL_SRC"
    echo "$end_marker"
  } > "$file"

  rm -f "$tmp"
  echo "Updated guardrail: $file"
}

install_codex() {
  local codex_home="${CODEX_HOME:-$HOME/.codex}"
  install_skill "$codex_home"
  if [[ "$INSTALL_GUARDRAIL" == "1" ]]; then
    upsert_guardrail "$codex_home/AGENTS.md"
  fi
}

install_claude() {
  local claude_home="${CLAUDE_HOME:-$HOME/.claude}"
  install_skill "$claude_home"
  if [[ "$INSTALL_GUARDRAIL" == "1" ]]; then
    upsert_guardrail "$claude_home/CLAUDE.md"
  fi
}

case "$TARGET_AGENT" in
  codex)
    install_codex
    ;;
  claude)
    install_claude
    ;;
  both)
    install_codex
    install_claude
    ;;
  *)
    echo "--agent must be codex, claude, or both" >&2
    exit 2
    ;;
esac
