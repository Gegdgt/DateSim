$ErrorActionPreference = 'Stop'
$loveCommand = Get-Command lovec.exe -ErrorAction SilentlyContinue
$loveExecutable = if ($loveCommand) { $loveCommand.Source } else { Join-Path $env:ProgramFiles 'LOVE\lovec.exe' }
if (-not (Test-Path -LiteralPath $loveExecutable)) {
    throw 'No se encontró lovec.exe. Instala LÖVE 11.5 para Windows.'
}
& $loveExecutable $PSScriptRoot --test
exit $LASTEXITCODE
