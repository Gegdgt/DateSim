# Campaña manual aislada. F8 guarda captura y checkpoint en tests/artifacts/.
$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    & 'C:\Program Files\LOVE\love.exe' . --qa-campaign
} finally {
    Pop-Location
}
