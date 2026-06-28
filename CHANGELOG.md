# Changelog — otimizador.ps1

## [3.2] — 2026-06-27

### Adicionado
- **Nova otimização #19 — Remover Home e Galeria:** Desafixa os CLSIDs `{f874310e-b6b7-47dc-bc84-b9e6b38f5903}` (Home) e `{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}` (Galeria) do painel de navegação do Explorer no Windows 11 24H2. (Integração do script `rqa.ps1`)

## [3.1] — 2026-06-26

### Adicionado
- **Nova otimização #18 — CrossDeviceResume:** Cria tarefa agendada (`schtasks`) que mata `CrossDeviceResume.exe` a cada logon (Windows 11 — cross-device/Recall).

## [3.0] — 2026-06-19

### Adicionado
- **Nova otimização #16 — Menu de contexto clássico:** Desativa o menu de contexto moderno do Windows 11 via CLSID `{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}`, restaurando o menu clássico (shift+F10 / "Mostrar mais opções").
- **Nova otimização #17 — Remover Acesso Rápido:** Remove o Acesso Rápido da navegação do Explorer, define "Este Computador" como padrão ao abrir, e desativa arquivos recentes e pastas frequentes.

## [2.0] — 2026-05-22

### Corrigido
- **Rede (#11):** Removido `netsh int tcp set global chimney=enabled` (obsoleto desde o Windows 10 1709). Era a causa dos avisos no terminal e o comando nunca era aplicado.
- **Rede (#11):** `try/catch` substituído por verificação de `$LASTEXITCODE` — o catch antigo nunca capturava falhas do `netsh`, então o script mostrava "aplicado" mesmo quando falhava.
- **Hibernação (#9):** `try/catch` substituído por `Start-Process -PassThru` para capturar o exit code real do `powercfg`.
- **Plano de energia (#13):** GUID extraído com regex em vez de `split` por espaços (quebrava em sistemas com idioma não-inglês).
- **Plano de energia (#13):** Adicionado fallback para buscar também "Ultimate Performance".
- **Limpeza de temp (#15):** Itens em uso agora são ignorados silenciosamente em vez de poluir o terminal com centenas de erros. Contador exibe quantos foram pulados.

### Alterado
- **Explorer:** Agora pergunta antes de reiniciar o Explorer, com opção de pular (`S/N`).

## [1.0] — versão original
- Versão inicial com 15 otimizações para Windows 10/11.
