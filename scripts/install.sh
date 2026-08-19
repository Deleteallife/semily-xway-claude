#!/usr/bin/env bash
# Ручная установка Semily XWAY Studio как обычного скилла Claude Code.
# Рекомендуемый способ — плагин: /plugin marketplace add Deleteallife/semily-xway-claude
# Этот скрипт нужен, только если система плагинов не используется.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_plugin="$repo_root/plugins/semily-xway-studio"
source_skill="$source_plugin/skills/semily-xway-studio"
source_commands="$source_plugin/commands"
mcp_config="$source_plugin/.mcp.json"

if [ ! -f "$source_skill/SKILL.md" ]; then
  echo "Не найден SKILL.md в $source_skill. Запускайте скрипт из распакованного репозитория." >&2
  exit 1
fi

claude_home="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
target_skill="$claude_home/skills/semily-xway-studio"
target_commands="$claude_home/commands/semily-xway"

mkdir -p "$claude_home/skills" "$claude_home/commands"
rm -rf "$target_skill"
cp -R "$source_skill" "$target_skill"
echo "Скилл установлен: $target_skill"

if [ -d "$source_commands" ]; then
  rm -rf "$target_commands"
  cp -R "$source_commands" "$target_commands"
  echo "Команды установлены: $target_commands  (/semily-xway:start, :status, :winner)"
fi

# --- Регистрация MCP-сервера ---

if command -v claude >/dev/null 2>&1; then
  server_json='{"type":"http","url":"https://plugin.semily.ru/mcp","oauth":{"clientId":"b7mFlRgJXJwBfF8DdGId8aCD4KvdwIr0","callbackPort":4321}}'
  claude mcp remove semily_xway --scope user >/dev/null 2>&1 || true
  claude mcp add-json semily_xway "$server_json" --scope user
  echo "MCP-сервер semily_xway зарегистрирован (user scope)."
else
  # Claude CLI недоступен — правим ~/.claude.json напрямую, с резервной копией.
  config_json="${SEMILY_XWAY_TEST_CONFIG_JSON:-$HOME/.claude.json}"
  py=""
  for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c 'import json' >/dev/null 2>&1; then
      py="$candidate"; break
    fi
  done

  if [ -n "$py" ]; then
    [ -f "$config_json" ] && cp "$config_json" "$config_json.semily-backup"
    "$py" - "$config_json" "$mcp_config" <<'PYEOF'
import json, os, sys
config_path, mcp_path = sys.argv[1], sys.argv[2]
entry = json.load(open(mcp_path, encoding="utf-8"))["mcpServers"]["semily_xway"]
config = {}
if os.path.exists(config_path):
    with open(config_path, encoding="utf-8") as fh:
        config = json.load(fh)
config.setdefault("mcpServers", {})["semily_xway"] = entry
with open(config_path, "w", encoding="utf-8") as fh:
    json.dump(config, fh, ensure_ascii=False, indent=2)
PYEOF
    echo "MCP-сервер semily_xway записан в $config_json (резервная копия: $config_json.semily-backup)."
  else
    echo "Claude CLI и Python не найдены — зарегистрируйте сервер вручную содержимым $mcp_config:" >&2
    cat "$mcp_config" >&2
    echo "Добавьте объект semily_xway в \"mcpServers\" файла $config_json." >&2
  fi
fi

# --- Вход в Semily ---
# Если Claude CLI доступен, открываем браузер сразу. Иначе вход делается через /mcp.

echo
if command -v claude >/dev/null 2>&1 && [ "${SEMILY_XWAY_SKIP_LOGIN:-}" != "1" ]; then
  echo "Открываю вход в Semily в браузере..."
  if claude mcp login semily_xway; then
    echo
    echo "Готово. Перезапустите Claude Code — скилл активен."
    echo "Пример запуска: /semily-xway:start 123456789"
    exit 0
  fi
  echo "Автоматический вход не завершён — войдите вручную через /mcp." >&2
fi

echo "Готово. Осталось войти в Semily:"
echo "  1. Откройте Claude Code (если он был запущен — перезапустите)."
echo "  2. Выполните /mcp, выберите semily_xway и нажмите Authenticate."
echo "  3. Браузер откроется сам — введите логин Semily."
echo
echo "Пример запуска: /semily-xway:start 123456789"
