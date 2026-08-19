# Ручная установка Semily XWAY Studio как обычного скилла Claude Code.
# Рекомендуемый способ — плагин: /plugin marketplace add Deleteallife/semily-xway-claude
# Этот скрипт нужен, только если система плагинов не используется.

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourcePlugin = Join-Path $repoRoot 'plugins\semily-xway-studio'
$sourceSkill = Join-Path $sourcePlugin 'skills\semily-xway-studio'
$sourceCommands = Join-Path $sourcePlugin 'commands'
$mcpConfigPath = Join-Path $sourcePlugin '.mcp.json'

if (-not (Test-Path -LiteralPath (Join-Path $sourceSkill 'SKILL.md'))) {
    throw "Не найден SKILL.md в $sourceSkill. Запускайте скрипт из распакованного репозитория."
}

$claudeHome = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE '.claude' }
$skillsRoot = Join-Path $claudeHome 'skills'
$commandsRoot = Join-Path $claudeHome 'commands'
$targetSkill = Join-Path $skillsRoot 'semily-xway-studio'
$targetCommands = Join-Path $commandsRoot 'semily-xway'

# Защита от выхода за пределы каталога скиллов.
$skillsResolved = [System.IO.Path]::GetFullPath($skillsRoot).TrimEnd('\') + '\'
if (-not ([System.IO.Path]::GetFullPath($targetSkill)).StartsWith($skillsResolved, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Небезопасный путь установки скилла.'
}

New-Item -ItemType Directory -Force -Path $skillsRoot | Out-Null
New-Item -ItemType Directory -Force -Path $commandsRoot | Out-Null

if (Test-Path -LiteralPath $targetSkill) { Remove-Item -LiteralPath $targetSkill -Recurse -Force }
Copy-Item -LiteralPath $sourceSkill -Destination $targetSkill -Recurse -Force
Write-Host "Скилл установлен: $targetSkill"

if (Test-Path -LiteralPath $sourceCommands) {
    if (Test-Path -LiteralPath $targetCommands) { Remove-Item -LiteralPath $targetCommands -Recurse -Force }
    Copy-Item -LiteralPath $sourceCommands -Destination $targetCommands -Recurse -Force
    Write-Host "Команды установлены: $targetCommands  (/semily-xway:start, :status, :winner)"
}

# --- Регистрация MCP-сервера ---

$mcpEntry = (Get-Content -Raw -LiteralPath $mcpConfigPath | ConvertFrom-Json).mcpServers.semily_xway
$serverJson = $mcpEntry | ConvertTo-Json -Depth 10 -Compress

$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if ($claudeCmd) {
    & $claudeCmd.Source mcp remove semily_xway --scope user 2>$null | Out-Null
    & $claudeCmd.Source mcp add-json semily_xway $serverJson --scope user
    if ($LASTEXITCODE -ne 0) {
        throw 'Не удалось зарегистрировать MCP-сервер semily_xway через Claude CLI.'
    }
    Write-Host 'MCP-сервер semily_xway зарегистрирован (user scope).'
} else {
    # Claude CLI недоступен — правим ~/.claude.json напрямую, с резервной копией.
    $configPath = Join-Path $env:USERPROFILE '.claude.json'
    $config = if (Test-Path -LiteralPath $configPath) {
        Copy-Item -LiteralPath $configPath -Destination "$configPath.semily-backup" -Force
        Get-Content -Raw -LiteralPath $configPath | ConvertFrom-Json
    } else {
        [PSCustomObject]@{}
    }

    if (-not $config.PSObject.Properties.Name.Contains('mcpServers') -or $null -eq $config.mcpServers) {
        $config | Add-Member -NotePropertyName 'mcpServers' -NotePropertyValue ([PSCustomObject]@{}) -Force
    }
    $config.mcpServers | Add-Member -NotePropertyName 'semily_xway' -NotePropertyValue $mcpEntry -Force

    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($configPath, ($config | ConvertTo-Json -Depth 100), $utf8NoBom)
    Write-Host "MCP-сервер semily_xway записан в $configPath (резервная копия: $configPath.semily-backup)."
}

Write-Host ''
Write-Host 'Готово. Перезапустите Claude Code, затем выполните /mcp и войдите в semily_xway.'
Write-Host 'Пример запуска: /semily-xway:start 123456789'
