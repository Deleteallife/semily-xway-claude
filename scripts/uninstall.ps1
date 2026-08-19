# Удаление ручной установки Semily XWAY Studio.

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$claudeHome = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE '.claude' }
$targetSkill = Join-Path $claudeHome 'skills\semily-xway-studio'
$targetCommands = Join-Path $claudeHome 'commands\semily-xway'

foreach ($path in @($targetSkill, $targetCommands)) {
    if (Test-Path -LiteralPath $path) {
        Remove-Item -LiteralPath $path -Recurse -Force
        Write-Host "Удалено: $path"
    }
}

$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if ($claudeCmd) {
    & $claudeCmd.Source mcp logout semily_xway 2>$null | Out-Null
    & $claudeCmd.Source mcp remove semily_xway --scope user 2>$null | Out-Null
    Write-Host 'MCP-сервер semily_xway отключён.'
} else {
    Write-Warning 'Claude CLI не найден. Удалите semily_xway вручную из ~/.claude.json или через /mcp.'
}

Write-Host 'Semily XWAY Studio удалён.'
