# PowerShell Profile

Repo de configuracao do PowerShell com aliases, atalhos e tema oh-my-posh.

## Preferencias

- Sem emojis. Usar Nerd Font glyphs ou caracteres unicode (ex: 󰊢 󰘴 󰉋 ✓)
- Portugues brasileiro nas mensagens do terminal (Write-Host)
- Cores via `$PSStyle.Foreground.*` — manter consistencia com o esquema existente
- Nomes de funcao curtos (2-4 chars): `gs`, `dcu`, `b64`, etc

## Estrutura

- `Microsoft.PowerShell_profile.ps1` — profile principal com todos os atalhos
- `cobalt2.omp.json` — tema oh-my-posh
- `profile.ps1` — profile secundario (vazio)

## Convencoes de codigo

- Funcoes simples em uma linha: `function gs { git status }`
- Funcoes com logica usam `Write-Host` com `-ForegroundColor` pra feedback
- Show-Help organizado por secoes com Nerd Font icons e separadores `────`
- Parametros com defaults sensatos (ex: `genpass` default 20 chars)
- Atalhos que copiam pro clipboard mostram `"✓ Copied to clipboard"` em verde

## Ao adicionar novos atalhos

1. Adicionar a funcao na secao correta do profile
2. Atualizar o `Show-Help` com a nova entrada na secao correspondente
3. Manter aliases curtos e mnemonicos
4. Prefixo `v` = variante que salva em `~/Videos` (ex: `vytmp4`)
5. Prefixo `to` = conversao ffmpeg (ex: `tomp4`, `tomp3`)

## Stack do usuario

- Bun, Docker, Mise, Cargo/Rust, Python
- IDE: Antigravity IDE (`antigravity-ide`)
- Terminal: PowerShell 7, oh-my-posh (cobalt2), zoxide, Terminal-Icons
- Media: yt-dlp, ffmpeg, VLC
