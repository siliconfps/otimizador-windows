# Changelog — otimizador.ps1

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
