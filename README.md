# Otimizador Windows

Script PowerShell para otimizacao pos-instalacao do Windows 10/11 com foco em desempenho e privacidade.

Compativel com **Windows 10** e **Windows 11** (21H2+).

---

## O que o script faz

| # | Otimizacao | Descricao |
|---|-----------|------------|
| 1 | Mitigacoes de CPU | Desativa mitigacoes Spectre/Meltdown (ganho de desempenho) |
| 2 | Compressao de Memoria | Desativa compressao para reduzir latencia |
| 3 | Telemetria | Bloqueia coleta de dados e DiagTrack |
| 4 | Busca do Bing | Remove Bing da pesquisa do menu Iniciar |
| 5 | Game Overlay | Desativa avisos e captura de tela (Win+G) |
| 6 | Cortana | Desativa assistente virtual |
| 7 | Servicos Xbox | Desativa XblAuth, GameSave, NetApi e GipSvc |
| 8 | Dicas/Sugestoes | Remove anuncios e recomendacoes |
| 9 | Hibernacao | Remove hiberfil.sys e libera GBs de disco |
| 10 | P2P de Updates | Desativa Otimizacao de Entrega |
| 11 | Rede | Ajustes TCP (autotuning, RSS, chimney) |
| 12 | Apps em segundo plano | Impede execucao desnecessaria em background |
| 13 | Plano de energia | Ativa Alto Desempenho |
| 14 | Widgets | Desativa Widgets (Windows 11) |
| 15 | Arquivos temporarios | Remove lixo do TEMP e Windows/Temp |
| 16 | Menu de contexto Win11 | Restaura o menu de contexto classico (desativa o moderno) |
| 17 | Acesso Rapido | Remove Acesso Rapido do Explorer e abre em "Este Computador" |

---

## Avisos importantes

- **Remove as correcoes de vulnerabilidades de CPU (Spectre/Meltdown)** -- use por sua conta e risco. Nao recomendado para servidores ou maquinas corporativas.
- A **hibernacao sera desativada** -- voce nao podera usar o modo hibernar, mas o arquivo `hiberfil.sys` (que ocupa GBs) sera removido.
- Algumas alteracoes exigem **reinicializacao** para ter efeito completo.
- Recomenda-se **criar um ponto de restauracao** antes de executar.

---

## Como usar

1. Abra o **PowerShell como Administrador** (clique direito > Executar como administrador)

2. Libere a execucao de scripts:
```powershell
Set-ExecutionPolicy Unrestricted -Scope Process -Force
```

3. Navegue ate a pasta do script e execute:
```powershell
.\otimizador.ps1
```

4. Ao final, o script perguntara se deseja **reiniciar o PC**. Responda `S` para sim ou `N` para reiniciar depois.

### Execucao rapida (uma linha)

```powershell
Set-ExecutionPolicy Unrestricted -Scope Process -Force; .\otimizador.ps1
```

### Usando o EXE (mais simples)

Basta baixar o arquivo `otimizador.exe`, clicar com o botao direito e escolher **Executar como administrador**. O UAC aparecera automaticamente.

Para gerar o EXE voce mesmo:

```powershell
.\build-exe.ps1
```

> Requer o modulo `ps2exe` (o script de build instala automaticamente se necessario).

---

## Reverter alteracoes

Para reverter as principais mudancas manualmente:

| Otimizacao | Como reverter |
|------------|---------------|
| Mitigacoes CPU | `FeatureSettingsOverride` = 0 (HKLM) |
| Telemetria | `AllowTelemetry` = 1, reativar DiagTrack |
| Hibernacao | `powercfg -h on` |
| Plano de energia | Painel de Controle > Opcoes de Energia > Equilibrado |
| Cortana | `AllowCortana` = 1 (HKLM) |
| Servicos Xbox | `Set-Service -StartupType Manual` |
| Menu de contexto Win11 | Deletar `HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}` |
| Acesso Rapido | `HubMode` = 0, `LaunchTo` = 0 no Explorer\Advanced |

---

## Requisitos

- Windows 10 ou Windows 11 (64-bit)
- PowerShell 5.1+
- Executar como **Administrador**

---

## Licenca

MIT -- veja o arquivo [LICENSE](LICENSE).
