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

# 6. DESATIVAR CORTANA
Write-Host "[>] Desativando Cortana..." -ForegroundColor Yellow
$cortanaPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
if (!(Test-Path $cortanaPath)) { New-Item -Path $cortanaPath -Force | Out-Null }
try {
    Set-ItemProperty -Path $cortanaPath -Name "AllowCortana" -Value 0 -Type DWord -ErrorAction Stop
    Write-Host "    Cortana desativada." -ForegroundColor Green
} catch {
    Write-Warning "    Erro ao desativar Cortana: $($_.Exception.Message)"
}

# 7. DESATIVAR SERVICOS XBOX
Write-Host "[>] Desativando servicos Xbox..." -ForegroundColor Yellow
$servicosXbox = @("XblAuthManager","XblGameSave","XboxNetApiSvc","XboxGipSvc")
foreach ($svc in $servicosXbox) {
    Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
    Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
}
Write-Host "    Servicos Xbox desativados." -ForegroundColor Green

# 8. DESATIVAR DICAS E SUGESTOES DO WINDOWS
Write-Host "[>] Desativando dicas e sugestoes..." -ForegroundColor Yellow
$tipsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
if (!(Test-Path $tipsPath)) { New-Item -Path $tipsPath -Force | Out-Null }
try {
    Set-ItemProperty -Path $tipsPath -Name "SoftLandingEnabled" -Value 0 -Type DWord -ErrorAction Stop
    Set-ItemProperty -Path $tipsPath -Name "SubscribedContent-338393Enabled" -Value 0 -Type DWord -ErrorAction Stop
    Set-ItemProperty -Path $tipsPath -Name "SubscribedContent-353694Enabled" -Value 0 -Type DWord -ErrorAction Stop
    Set-ItemProperty -Path $tipsPath -Name "SubscribedContent-353696Enabled" -Value 0 -Type DWord -ErrorAction Stop
    Write-Host "    Dicas e sugestoes desativadas." -ForegroundColor Green
} catch {
    Write-Warning "    Erro ao desativar dicas: $($_.Exception.Message)"
}

# 9. DESATIVAR HIBERNACAO (Libera GBs de espaco)
Write-Host "[>] Desativando hibernacao..." -ForegroundColor Yellow
try {
    powercfg -h off
    Write-Host "    Hibernacao desativada (arquivo hiberfil.sys removido)." -ForegroundColor Green
} catch {
    Write-Warning "    Erro ao desativar hibernacao: $($_.Exception.Message)"
}

# 10. DESATIVAR OTIMIZACAO DE ENTREGA (P2P de updates)
Write-Host "[>] Desativando Otimizacao de Entrega (P2P)..." -ForegroundColor Yellow
$deliveryOptPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
if (!(Test-Path $deliveryOptPath)) { New-Item -Path $deliveryOptPath -Force | Out-Null }
try {
    Set-ItemProperty -Path $deliveryOptPath -Name "DODownloadMode" -Value 0 -Type DWord -ErrorAction Stop
    Write-Host "    Otimizacao de entrega (P2P) desativada." -ForegroundColor Green
} catch {
    Write-Warning "    Erro no Delivery Optimization: $($_.Exception.Message)"
}

# 11. AJUSTES DE REDE (TCP Autotuning)
Write-Host "[>] Aplicando ajustes de rede..." -ForegroundColor Yellow
try {
    netsh int tcp set global autotuninglevel=normal
    netsh int tcp set global rss=enabled
    netsh int tcp set global chimney=enabled
    Write-Host "    Ajustes de rede aplicados." -ForegroundColor Green
} catch {
    Write-Warning "    Erro nos ajustes de rede: $($_.Exception.Message)"
}

# 12. DESATIVAR APPS EM SEGUNDO PLANO
Write-Host "[>] Desativando apps em segundo plano..." -ForegroundColor Yellow
$bgAppsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
if (!(Test-Path $bgAppsPath)) { New-Item -Path $bgAppsPath -Force | Out-Null }
try {
    Set-ItemProperty -Path $bgAppsPath -Name "GlobalUserDisabled" -Value 1 -Type DWord -ErrorAction Stop
    Write-Host "    Apps em segundo plano limitados." -ForegroundColor Green
} catch {
    Write-Warning "    Erro nos apps em segundo plano: $($_.Exception.Message)"
}

# 13. PLANO DE ENERGIA - ALTO DESEMPENHO
Write-Host "[>] Ativando plano de Alto Desempenho..." -ForegroundColor Yellow
try {
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    Write-Host "    Plano Alto Desempenho ativado." -ForegroundColor Green
} catch {
    try {
        $highPerf = powercfg -list | Select-String -Pattern "Alto desempenho|High performance"
        if ($highPerf) {
            $guid = ($highPerf -split '\s+')[3]
            powercfg -setactive $guid
            Write-Host "    Plano Alto Desempenho ativado." -ForegroundColor Green
        }
    } catch {
        Write-Warning "    Erro ao ativar plano de energia: $($_.Exception.Message)"
    }
}

# 14. DESATIVAR WIDGETS (Windows 11)
Write-Host "[>] Desativando Widgets..." -ForegroundColor Yellow
$widgetsPath = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
if (!(Test-Path $widgetsPath)) { New-Item -Path $widgetsPath -Force | Out-Null }
try {
    Set-ItemProperty -Path $widgetsPath -Name "AllowNewsAndInterests" -Value 0 -Type DWord -ErrorAction Stop
    Write-Host "    Widgets desativados." -ForegroundColor Green
} catch {
    Write-Warning "    Erro ao desativar Widgets: $($_.Exception.Message)"
}

# 15. LIMPEZA DE ARQUIVOS TEMPORARIOS
Write-Host "[>] Limpando arquivos temporarios..." -ForegroundColor Yellow
try {
    Get-ChildItem -Path $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path "C:\Windows\Temp" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "    Arquivos temporarios removidos." -ForegroundColor Green
} catch {
    Write-Warning "    Erro na limpeza de temporarios: $($_.Exception.Message)"
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
