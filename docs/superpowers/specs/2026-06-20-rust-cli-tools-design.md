# Rust CLI Tools -- Integracao no PowerShell Profile

**Data:** 2026-06-20
**Status:** Aprovado
**Escopo:** Instalar ferramentas CLI em Rust e integrar no profile com atalhos e fallback

---

## Decisoes

- Aliases existentes (la, ll, ff, grep, head) serao reescritos pra usar ferramentas Rust com fallback pro comando original
- Metodo de instalacao: winget quando disponivel, cargo pro resto
- delta configurado como git pager global
- Conflito `br`: broot fica como `tree`, bun run mantem `br`

## Ferramentas

### Tier 1 -- Substituicoes diretas

| Ferramenta | Instalar via | Substitui | Alias |
|---|---|---|---|
| eza | winget | `la`, `ll` | `eza --icons -a` / `eza --icons -la --git` |
| bat | winget | `head`, leitura de arquivos | `bat -r :10` / `bat` |
| fd | winget | `ff` (find) | `fd` |
| ripgrep | JA INSTALADO | `grep` | `rg` |

### Tier 2 -- Novas capacidades

| Ferramenta | Instalar via | Atalho | Descricao |
|---|---|---|---|
| delta | winget | (git pager) | Diff com syntax highlight |
| navi | cargo | `navi` (Ctrl+G) | Cheatsheet interativo |
| atuin | cargo | (shell widget) | Historico de shell com busca fuzzy |
| xh | cargo | `http` | HTTP client moderno |

### Tier 3 -- Extras

| Ferramenta | Instalar via | Atalho | Descricao |
|---|---|---|---|
| dust | winget | `du` | Uso de disco visual |
| bottom | winget | `top` | Monitor de sistema TUI |
| tokei | winget | `loc` | Contar linhas de codigo |
| gitui | winget | `gui` | TUI do git |
| yazi | winget | `fm` | File manager no terminal |
| broot | cargo | `tree` | Arvore de diretorio interativa |
| hyperfine | winget | `bench` | Benchmark de comandos |
| procs | cargo | `ps2` | Processos com cores |

## Instalacao

### Passo 1 -- winget

```powershell
$wingetPkgs = @(
    'eza-community.eza'
    'sharkdp.bat'
    'sharkdp.fd'
    'dandavison.delta'
    'bootandy.dust'
    'Clement.bottom'
    'XAMPPRocky.tokei'
    'StephanDilly.gitui'
    'sxyazi.yazi'
    'sharkdp.hyperfine'
)
foreach ($pkg in $wingetPkgs) {
    winget install --id $pkg --accept-package-agreements --accept-source-agreements
}
```

### Passo 2 -- cargo

```powershell
$cargoPkgs = @('navi', 'atuin', 'xh', 'broot', 'procs')
foreach ($pkg in $cargoPkgs) {
    cargo install $pkg
}
```

### Passo 3 -- git config

```powershell
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global delta.side-by-side true
git config --global merge.conflictstyle diff3
```

## Alteracoes no Profile

### Aliases reescritos (com fallback)

```powershell
# Listing (eza fallback)
function la {
    if (Get-Command eza -ErrorAction SilentlyContinue) { eza --icons -a @args }
    else { Get-ChildItem | Format-Table -AutoSize }
}

function ll {
    if (Get-Command eza -ErrorAction SilentlyContinue) { eza --icons -la --git @args }
    else { Get-ChildItem -Force | Format-Table -AutoSize }
}

# Find (fd fallback)
function ff ($Name) {
    if (Get-Command fd -ErrorAction SilentlyContinue) { fd $Name @args }
    else { Get-ChildItem -Recurse -Filter $Name -File | Select-Object -ExpandProperty FullName }
}

# Head (bat fallback)
function head ($Path, [int]$Lines = 10) {
    if (Get-Command bat -ErrorAction SilentlyContinue) { bat -r ":$Lines" --style=plain $Path }
    else { Get-Content $Path -Head $Lines }
}
```

### Novos aliases

```powershell
# bat
function cat { bat --style=plain @args }

# Monitoring
function du { dust @args }
function top { btm @args }
function ps2 { procs @args }

# Dev tools
function loc { tokei @args }
function bench { hyperfine @args }
function http { xh @args }

# TUI
function gui { gitui @args }
function fm { yazi @args }
function tree { broot @args }
```

### Alias grep atualizado

```powershell
# Substituir: Set-Alias -Name grep -Value Select-String
# Por: rg ja esta no PATH, alias direto
Set-Alias -Name grep -Value rg
```

### Secao Show-Help -- nova secao "Rust Tools"

```
 Rust Tools
────────────────────────────────────────────────────
  la                 -> eza: list files with icons
  ll                 -> eza: list all + git status
  ff <name>          -> fd: find files fast
  grep <pattern>     -> rg: ripgrep
  head <file> [n]    -> bat: first N lines (default 10)
  cat <file>         -> bat: view with syntax highlight
  du [path]          -> dust: disk usage tree
  top                -> bottom: system monitor
  ps2                -> procs: process list
  loc [path]         -> tokei: count lines of code
  bench <cmd>        -> hyperfine: benchmark command
  http <method> <url> -> xh: HTTP client
  gui                -> gitui: git TUI
  fm                 -> yazi: file manager
  tree [path]        -> broot: interactive tree
  navi               -> cheatsheet interativo
```

## O que NAO muda

- zoxide, oh-my-posh, Terminal-Icons -- intocados
- Todos os aliases de git, docker, bun, mise, yt-dlp, ffmpeg, curl -- intocados
- Funcoes utilitarias (touch, mkcd, trash, etc) -- intocadas
- Keybinds -- intocados

## Riscos

- **winget IDs podem mudar**: verificar com `winget search` antes de rodar
- **cargo install demora**: navi, atuin e broot compilam do fonte (~5-10min cada)
- **atuin/navi precisam init no profile**: adicionar `atuin init powershell | Out-String | Invoke-Expression` e equivalente do navi
- **Conflito cat**: PowerShell tem `Get-Content` aliasado como `cat` nativamente -- precisa remover o alias builtin primeiro

---

Sources:
- [15 Rust CLI Tools - DEV Community](https://dev.to/dev_tips/15-rust-cli-tools-that-will-make-you-abandon-bash-scripts-forever-4mgi)
- [11 Rust CLI Tools 2026 - Repotoire](https://www.repotoire.com/blog/rust-cli-tools-2026)
- [Rust CLI Tools - It's FOSS](https://itsfoss.com/rust-cli-tools/)
- [navi - GitHub](https://github.com/denisidoro/navi)
- [5 Rust TUI Tools for Windows PowerShell - DEV Community](https://dev.to/marlocarlo/5-rust-tui-tools-that-make-windows-powershell-feel-like-linux-2h4p)
- [ModernCLI.com](https://moderncli.com/)
