# =================================================================
# SCRIPT DE OTIMIZACAO POS-INSTALACAO (WINDOWS 10/11)
# Compativel com Windows 11 21H2+
# =================================================================

# Verifica se esta rodando como Administrador
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Por favor, execute este script como Administrador."
    exit
}

Write-Host "--- Iniciando Otimizacoes ---" -ForegroundColor Cyan

# 1. DESATIVAR MITIGACOES DO PROCESSADOR (Spectre/Meltdown)
Write-Host "[>] Desativando mitigacoes do processador (Performance Boost)..." -ForegroundColor Yellow
$memMgmt = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
try {
    Set-ItemProperty -Path $memMgmt -Name "FeatureSettingsOverride" -Value 3 -Type DWord -ErrorAction Stop
    Set-ItemProperty -Path $memMgmt -Name "FeatureSettingsOverrideMask" -Value 3 -Type DWord -ErrorAction Stop
    Write-Host "    Mitigacoes desativadas." -ForegroundColor Green
} catch {
    Write-Warning "    Erro ao desativar mitigacoes: $($_.Exception.Message)"
}

# 2. DESATIVAR COMPRESSAO DE MEMORIA
Write-Host "[>] Desativando compressao de memoria..." -ForegroundColor Yellow
if (Get-Module -ListAvailable -Name MMAgent -ErrorAction SilentlyContinue) {
    $savedStartMode = $null
    try {
        # Obtem o estado atual do SysMain (Superfetch) -- necessario para o MMAgent funcionar
        $sysMainCim = Get-CimInstance -ClassName Win32_Service -Filter "Name='SysMain'" -ErrorAction SilentlyContinue
        if ($sysMainCim) {
            $savedStartMode = $sysMainCim.StartMode
            if ($sysMainCim.StartMode -eq 'Disabled') {
                Set-Service -Name SysMain -StartupType Manual -ErrorAction SilentlyContinue
                Start-Service -Name SysMain -ErrorAction SilentlyContinue | Out-Null
            }
        }
        # Executa a desativacao
        Import-Module MMAgent -Force -ErrorAction Stop
        Disable-MMAgent -MemoryCompression -ErrorAction Stop
        Write-Host "    Compressao de memoria desativada." -ForegroundColor Green
    } catch {
        Write-Warning "    Erro na compressao de memoria: $($_.Exception.Message)"
    }
    # Restaura o estado original do SysMain
    if ($sysMainCim -and $savedStartMode -eq 'Disabled') {
        Stop-Service -Name SysMain -Force -ErrorAction SilentlyContinue
        Set-Service -Name SysMain -StartupType Disabled -ErrorAction SilentlyContinue
    }
} else {
    Write-Warning "    Modulo MMAgent nao encontrado -- compressao de memoria ignorada."
}

# 3. DESATIVAR TELEMETRIA E COLETA DE DADOS
Write-Host "[>] Desativando telemetria e servicos de rastreio..." -ForegroundColor Yellow
$telemetryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (!(Test-Path $telemetryPath)) { New-Item -Path $telemetryPath -Force | Out-Null }
try {
    Set-ItemProperty -Path $telemetryPath -Name "AllowTelemetry" -Value 0 -Type DWord -ErrorAction Stop
} catch {
    Write-Warning "    Erro ao configurar telemetria: $($_.Exception.Message)"
}
Stop-Service -Name DiagTrack -ErrorAction SilentlyContinue | Out-Null
Set-Service -Name DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue

# 4. DESATIVAR BING NA PESQUISA DO MENU INICIAR
Write-Host "[>] Removendo Bing da pesquisa local..." -ForegroundColor Yellow
$searchPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
if (!(Test-Path $searchPath)) { New-Item -Path $searchPath -Force | Out-Null }
try {
    Set-ItemProperty -Path $searchPath -Name "BingSearchEnabled" -Value 0 -Type DWord
} catch {
    Write-Warning "    Erro ao desativar Bing: $($_.Exception.Message)"
}

# 5. DESATIVAR AVISO MS-GAMINGOVERLAY (WIN+G)
Write-Host "[>] Desativando avisos de Game Overlay..." -ForegroundColor Yellow
$gameDvr = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"
if (!(Test-Path $gameDvr)) { New-Item -Path $gameDvr -Force | Out-Null }
try {
    Set-ItemProperty -Path $gameDvr -Name "AppCaptureEnabled" -Value 0 -Type DWord
} catch {
    Write-Warning "    Erro no GameDVR (HKCU): $($_.Exception.Message)"
}
$gamePolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
if (!(Test-Path $gamePolicy)) { New-Item -Path $gamePolicy -Force | Out-Null }
try {
    Set-ItemProperty -Path $gamePolicy -Name "AllowGameDVR" -Value 0 -Type DWord
} catch {
    Write-Warning "    Erro no GameDVR (HKLM): $($_.Exception.Message)"
}

# REINICIAR EXPLORER PARA APLICAR MUDANCAS VISUAIS
Write-Host "[!] Reiniciando Windows Explorer..." -ForegroundColor Magenta
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

Write-Host "---"
Write-Host "Sucesso! Algumas alteracoes precisam de REINICIALIZACAO para funcionar." -ForegroundColor Green
$resposta = Read-Host "Deseja reiniciar o computador agora? (S/N)"
if ($resposta -eq "S" -or $resposta -eq "s") {
    Restart-Computer -Force
}