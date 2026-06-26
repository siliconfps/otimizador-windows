# =================================================================
# BUILD SCRIPT — Converte otimizador.ps1 em .EXE via PS2EXE
# =================================================================

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$inputFile  = Join-Path $scriptDir "otimizador.ps1"
$outputFile = Join-Path $scriptDir "otimizador.exe"

if (!(Test-Path $inputFile)) {
    Write-Error "Arquivo '$inputFile' nao encontrado."
    exit 1
}

# Instala ps2exe se necessario
if (!(Get-Module -ListAvailable -Name ps2exe)) {
    Write-Host "[>] Instalando modulo ps2exe..." -ForegroundColor Yellow
    try {
        Install-PackageProvider -Name NuGet -Force -ForceBootstrap -Scope CurrentUser -ErrorAction Stop
        Install-Module -Name ps2exe -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck -ErrorAction Stop
    } catch {
        Write-Error "Falha ao instalar ps2exe. Execute como Administrador e tente novamente."
        exit 1
    }
}

Write-Host "[>] Gerando $outputFile ..." -ForegroundColor Cyan

# Parametros:
#   -requireAdmin: embute manifest pedindo elevacao (UAC)
#   -noConsole: executa o script sem janela preta do PowerShell visivel
#   -noOutput: nao gera o .log de saida
#   -noError: nao gera o .err de erro
#   -title: nome que aparece no UAC / Task Manager
#   -version: versao do EXE

Invoke-ps2exe -InputFile $inputFile `
              -OutputFile $outputFile `
              -requireAdmin `
              -noConsole `
              -noOutput `
              -noError `
              -title "Otimizador Windows" `
              -description "Script de otimizacao pos-instalacao Windows 10/11" `
              -version "3.1.0.0" `
              -product "Otimizador Windows" `
              -company ""

if (Test-Path $outputFile) {
    $size = [math]::Round((Get-Item $outputFile).Length / 1KB, 1)
    Write-Host "    Sucesso! $outputFile ($size KB)" -ForegroundColor Green
} else {
    Write-Error "Falha ao gerar o EXE."
    exit 1
}
