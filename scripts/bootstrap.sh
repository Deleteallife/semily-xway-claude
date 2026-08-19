#!/usr/bin/env bash
# Semily XWAY Studio — установка одной командой.
#   curl -fsSL https://raw.githubusercontent.com/Deleteallife/semily-xway-claude/main/scripts/bootstrap.sh | bash
#
# Скачивает репозиторий, ставит скилл и MCP-сервер, открывает вход.
# Ни git, ни аккаунт GitHub не нужны.

set -euo pipefail

repo="Deleteallife/semily-xway-claude"
branch="main"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "Semily XWAY Studio для Claude Code"
echo

echo "Загрузка..."
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "https://codeload.github.com/$repo/tar.gz/refs/heads/$branch" -o "$work/source.tar.gz"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$work/source.tar.gz" "https://codeload.github.com/$repo/tar.gz/refs/heads/$branch"
else
  echo "Нужен curl или wget." >&2
  exit 1
fi

tar -xzf "$work/source.tar.gz" -C "$work"
extracted="$(find "$work" -maxdepth 1 -type d -name 'semily-xway-claude-*' | head -1)"
if [ -z "$extracted" ]; then
  echo "Не удалось распаковать архив репозитория." >&2
  exit 1
fi

installer="$extracted/scripts/install.sh"
if [ ! -f "$installer" ]; then
  echo "Не найден установщик: $installer" >&2
  exit 1
fi

bash "$installer"
