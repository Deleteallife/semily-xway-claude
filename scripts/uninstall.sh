#!/usr/bin/env bash
# Удаление ручной установки Semily XWAY Studio.

set -euo pipefail

claude_home="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

for path in "$claude_home/skills/semily-xway-studio" "$claude_home/commands/semily-xway"; do
  if [ -e "$path" ]; then
    rm -rf "$path"
    echo "Удалено: $path"
  fi
done

if command -v claude >/dev/null 2>&1; then
  claude mcp logout semily_xway >/dev/null 2>&1 || true
  claude mcp remove semily_xway --scope user >/dev/null 2>&1 || true
  echo "MCP-сервер semily_xway отключён."
else
  echo "Claude CLI не найден. Удалите semily_xway вручную из ~/.claude.json или через /mcp." >&2
fi

echo "Semily XWAY Studio удалён."
