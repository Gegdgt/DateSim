$ErrorActionPreference = 'Stop'
$loveCommand = Get-Command love.exe -ErrorAction SilentlyContinue
$loveExecutable = if ($loveCommand) { $loveCommand.Source } else { Join-Path $env:ProgramFiles 'LOVE\love.exe' }
if (-not (Test-Path -LiteralPath $loveExecutable)) {
    throw 'Instala LÖVE 11.5 desde https://love2d.org/ o agrega love.exe al PATH.'
}
& $loveExecutable $PSScriptRoot
