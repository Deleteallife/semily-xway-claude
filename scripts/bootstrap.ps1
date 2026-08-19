# Semily XWAY Studio — установка одной командой.
#   irm https://raw.githubusercontent.com/Deleteallife/semily-xway-claude/main/scripts/bootstrap.ps1 | iex
#
# Скачивает репозиторий, ставит скилл и MCP-сервер, открывает вход.
# Ни git, ни аккаунт GitHub не нужны.

$ErrorActionPreference = 'Stop'

$repo = 'Deleteallife/semily-xway-claude'
$branch = 'main'
$work = Join-Path ([System.IO.Path]::GetTempPath()) ("semily-xway-" + [guid]::NewGuid().ToString('N').Substring(0, 8))

Write-Host 'Semily XWAY Studio для Claude Code'
Write-Host ''

try {
    New-Item -ItemType Directory -Force -Path $work | Out-Null
    $zip = Join-Path $work 'source.zip'

    Write-Host 'Загрузка...'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "https://codeload.github.com/$repo/zip/refs/heads/$branch" -OutFile $zip -UseBasicParsing

    Expand-Archive -LiteralPath $zip -DestinationPath $work -Force
    $extracted = Get-ChildItem -LiteralPath $work -Directory | Select-Object -First 1
    if (-not $extracted) { throw 'Не удалось распаковать архив репозитория.' }

    $installer = Join-Path $extracted.FullName 'scripts\install.ps1'
    if (-not (Test-Path -LiteralPath $installer)) { throw "Не найден установщик: $installer" }

    & powershell -ExecutionPolicy Bypass -File $installer
    if ($LASTEXITCODE -ne 0) { throw 'Установщик завершился с ошибкой.' }
}
finally {
    if (Test-Path -LiteralPath $work) {
        Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
    }
}
