# Rust CLI Tools Integration — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Install 15 Rust CLI tools and integrate them into the PowerShell profile with aliases and fallback to original commands.

**Architecture:** One install script (`install-rust-tools.ps1`) runs once to install all tools. The profile (`Microsoft.PowerShell_profile.ps1`) gets updated with fallback-aware aliases, new tool aliases, shell init lines, and a new Show-Help section. A helper function `_has` caches `Get-Command` lookups to keep fallback checks fast.

**Tech Stack:** PowerShell 7, winget, cargo, git config

**Spec:** `docs/superpowers/specs/2026-06-20-rust-cli-tools-design.md`

---

## File Structure

| File | Action | Responsibility |
|---|---|---|
| `install-rust-tools.ps1` | Create | One-shot install script for all tools |
| `Microsoft.PowerShell_profile.ps1` | Modify | Profile aliases, init lines, Show-Help |

---

### Task 1: Create the install script

**Files:**
- Create: `install-rust-tools.ps1`

- [ ] **Step 1: Create `install-rust-tools.ps1`**

```powershell
# install-rust-tools.ps1 — Run once to install all Rust CLI tools
# Usage: .\install-rust-tools.ps1

$dim = $PSStyle.Foreground.BrightBlack
$grn = $PSStyle.Foreground.BrightGreen
$ylw = $PSStyle.Foreground.BrightYellow
$rst = $PSStyle.Reset

Write-Host "${ylw}Instalando ferramentas Rust via winget...${rst}"

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
    $name = $pkg.Split('.')[-1]
    if (Get-Command $name -ErrorAction SilentlyContinue) {
        Write-Host "  ${dim}$name ja instalado, pulando${rst}"
    } else {
        Write-Host "  ${grn}Instalando $name...${rst}"
        winget install --id $pkg --accept-package-agreements --accept-source-agreements --silent
    }
}

Write-Host ""
Write-Host "${ylw}Instalando ferramentas Rust via cargo...${rst}"
Write-Host "${dim}(compila do fonte, pode demorar ~5-10min por ferramenta)${rst}"

$cargoPkgs = @('navi', 'atuin', 'xh', 'broot', 'procs')

foreach ($pkg in $cargoPkgs) {
    if (Get-Command $pkg -ErrorAction SilentlyContinue) {
        Write-Host "  ${dim}$pkg ja instalado, pulando${rst}"
    } else {
        Write-Host "  ${grn}Compilando $pkg...${rst}"
        cargo install $pkg
    }
}

Write-Host ""
Write-Host "${ylw}Configurando delta como git pager...${rst}"
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global delta.side-by-side true
git config --global merge.conflictstyle diff3
Write-Host "${grn}delta configurado${rst}"

Write-Host ""
Write-Host "${grn}Instalacao completa! Reinicie o terminal para carregar os novos aliases.${rst}"
```

- [ ] **Step 2: Verify script syntax**

Run: `pwsh -NoProfile -Command "& { $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content '.\install-rust-tools.ps1' -Raw), [ref]$null); Write-Host 'Syntax OK' }"`
Expected: `Syntax OK`

- [ ] **Step 3: Commit**

```bash
git add install-rust-tools.ps1
git commit -m "feat: add Rust CLI tools install script (winget + cargo)"
```

---

### Task 2: Add the `_has` helper function to the profile

This helper caches command existence checks so fallback aliases don't call `Get-Command` on every invocation.

**Files:**
- Modify: `Microsoft.PowerShell_profile.ps1` (after line 5, before the `Write-Host` banner on line 7)

- [ ] **Step 1: Add `_has` helper after the imports block**

Insert after line 5 (`Import-Module -Name Terminal-Icons`) and before line 7 (`Write-Host "Use 'Show-Help'..."`):

```powershell
# Rust CLI tools — fallback helper
$_cmdCache = @{}
function _has ($Cmd) {
    if (-not $_cmdCache.ContainsKey($Cmd)) {
        $_cmdCache[$Cmd] = [bool](Get-Command $Cmd -ErrorAction SilentlyContinue)
    }
    $_cmdCache[$Cmd]
}
```

- [ ] **Step 2: Verify profile still loads**

Run: `pwsh -NoProfile -Command "& { . '$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1' 2>&1; Write-Host 'Profile OK' }"`
Expected: Output ends with `Profile OK`

- [ ] **Step 3: Commit**

```bash
git add Microsoft.PowerShell_profile.ps1
git commit -m "feat: add _has helper for Rust tool fallback checks"
```

---

### Task 3: Rewrite existing aliases with fallback

**Files:**
- Modify: `Microsoft.PowerShell_profile.ps1`
  - Lines 166-172: Replace `la` and `ll` functions
  - Lines 65-66: Replace `ff` function
  - Lines 69-71: Replace `head` function
  - Line 334: Replace `grep` alias

- [ ] **Step 1: Replace `la` function (line 166-168)**

Replace:
```powershell
function la {
    Get-ChildItem | Format-Table -AutoSize
}
```

With:
```powershell
function la {
    if (_has eza) { eza --icons -a @args }
    else { Get-ChildItem | Format-Table -AutoSize }
}
```

- [ ] **Step 2: Replace `ll` function (lines 170-172)**

Replace:
```powershell
function ll {
    Get-ChildItem -Force | Format-Table -AutoSize
}
```

With:
```powershell
function ll {
    if (_has eza) { eza --icons -la --git @args }
    else { Get-ChildItem -Force | Format-Table -AutoSize }
}
```

- [ ] **Step 3: Replace `ff` function (lines 65-66)**

Replace:
```powershell
function ff ($Name) {
    Get-ChildItem -Recurse -Filter $Name -File | Select-Object -ExpandProperty FullName
}
```

With:
```powershell
function ff ($Name) {
    if (_has fd) { fd $Name @args }
    else { Get-ChildItem -Recurse -Filter $Name -File | Select-Object -ExpandProperty FullName }
}
```

- [ ] **Step 4: Replace `head` function (lines 69-71)**

Replace:
```powershell
function head ($Path) {
    Get-Content $Path -Head 10
}
```

With:
```powershell
function head ($Path, [int]$Lines = 10) {
    if (_has bat) { bat -r ":$Lines" --style=plain $Path }
    else { Get-Content $Path -Head $Lines }
}
```

- [ ] **Step 5: Replace `grep` alias (line 334)**

Replace:
```powershell
Set-Alias -Name grep -Value Select-String
```

With:
```powershell
if (_has rg) { Set-Alias -Name grep -Value rg }
else { Set-Alias -Name grep -Value Select-String }
```

- [ ] **Step 6: Verify profile loads and aliases work**

Run: `pwsh -NoProfile -Command "& { . '$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1' 2>&1; la; Write-Host 'Profile OK' }"`
Expected: Directory listing followed by `Profile OK`

- [ ] **Step 7: Commit**

```bash
git add Microsoft.PowerShell_profile.ps1
git commit -m "feat: rewrite la/ll/ff/head/grep with Rust tool fallback"
```

---

### Task 4: Add new tool aliases

**Files:**
- Modify: `Microsoft.PowerShell_profile.ps1` — insert new section after the `# Listing / Viewing` block (after `ll`, around line 172)

- [ ] **Step 1: Add Rust tool aliases block**

Insert after the `ll` function, before the `# Network` section:

```powershell
# Rust Tools
Remove-Alias cat -Force -ErrorAction SilentlyContinue
function cat {
    if (_has bat) { bat --style=plain @args }
    else { Get-Content @args }
}
function du {
    if (_has dust) { dust @args }
    else { Get-ChildItem -Recurse -File @args | Measure-Object -Property Length -Sum }
}
function top { btm @args }
function ps2 { procs @args }
function loc { tokei @args }
function bench { hyperfine @args }
function http { xh @args }
function gui { gitui @args }
function fm { yazi @args }
function tree {
    if (_has broot) { broot @args }
    else { Get-ChildItem -Recurse -Depth 2 @args }
}
```

- [ ] **Step 2: Verify profile loads**

Run: `pwsh -NoProfile -Command "& { . '$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1' 2>&1; Write-Host 'Profile OK' }"`
Expected: Output ends with `Profile OK`

- [ ] **Step 3: Commit**

```bash
git add Microsoft.PowerShell_profile.ps1
git commit -m "feat: add Rust tool aliases (cat, du, top, ps2, loc, bench, http, gui, fm, tree)"
```

---

### Task 5: Add atuin and navi shell init

**Files:**
- Modify: `Microsoft.PowerShell_profile.ps1` — insert after zoxide init (line 4), before `Import-Module`

- [ ] **Step 1: Add shell init lines**

Insert after line 4 (`zoxide init --cmd z powershell | Out-String | Invoke-Expression`) and before line 5 (`Import-Module -Name Terminal-Icons`):

```powershell
if (Get-Command atuin -ErrorAction SilentlyContinue) { atuin init powershell --disable-up-arrow | Out-String | Invoke-Expression }
if (Get-Command navi -ErrorAction SilentlyContinue) { navi widget powershell | Out-String | Invoke-Expression }
```

Note: `--disable-up-arrow` keeps the existing PSReadLine HistorySearchBackward keybind on UpArrow. Atuin uses Ctrl+R instead.

- [ ] **Step 2: Verify profile loads without atuin/navi installed**

Run: `pwsh -NoProfile -Command "& { . '$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1' 2>&1; Write-Host 'Profile OK' }"`
Expected: Output ends with `Profile OK` (init lines silently skipped since tools not installed yet)

- [ ] **Step 3: Commit**

```bash
git add Microsoft.PowerShell_profile.ps1
git commit -m "feat: add atuin and navi shell init with guard checks"
```

---

### Task 6: Update Show-Help with Rust Tools section

**Files:**
- Modify: `Microsoft.PowerShell_profile.ps1` — inside the `Show-Help` function, add new section before the System section (before `${section}󰘴 System`)

- [ ] **Step 1: Add Rust Tools section to Show-Help**

Insert before the `${section}󰘴 System${reset}` line inside the here-string:

```
${section}󱓞 Rust Tools${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}la${reset}                 ${accent}→${reset} ${desc}eza: listar com icons${reset}
  ${command}ll${reset}                 ${accent}→${reset} ${desc}eza: listar tudo + git status${reset}
  ${command}ff <nome>${reset}          ${accent}→${reset} ${desc}fd: buscar arquivos${reset}
  ${command}grep <padrao>${reset}      ${accent}→${reset} ${desc}rg: ripgrep${reset}
  ${command}head <arq> [n]${reset}     ${accent}→${reset} ${desc}bat: primeiras N linhas${reset}
  ${command}cat <arq>${reset}          ${accent}→${reset} ${desc}bat: ver com syntax highlight${reset}
  ${command}du [path]${reset}          ${accent}→${reset} ${desc}dust: uso de disco${reset}
  ${command}top${reset}                ${accent}→${reset} ${desc}bottom: monitor do sistema${reset}
  ${command}ps2${reset}                ${accent}→${reset} ${desc}procs: lista de processos${reset}
  ${command}loc [path]${reset}         ${accent}→${reset} ${desc}tokei: contar linhas de codigo${reset}
  ${command}bench <cmd>${reset}        ${accent}→${reset} ${desc}hyperfine: benchmark${reset}
  ${command}http <met> <url>${reset}   ${accent}→${reset} ${desc}xh: HTTP client${reset}
  ${command}gui${reset}                ${accent}→${reset} ${desc}gitui: git TUI${reset}
  ${command}fm${reset}                 ${accent}→${reset} ${desc}yazi: file manager${reset}
  ${command}tree [path]${reset}        ${accent}→${reset} ${desc}broot: arvore interativa${reset}
  ${command}navi${reset}               ${accent}→${reset} ${desc}cheatsheet interativo (Ctrl+G)${reset}

```

- [ ] **Step 2: Remove now-redundant entries from old sections**

In the existing Show-Help, the following entries now belong to the Rust Tools section. Remove them from their old locations:

From the **System** section, remove:
```
  ${command}ff <name>${reset}          ${accent}→${reset} ${desc}Search files${reset}
  ${command}grep <pattern>${reset}     ${accent}→${reset} ${desc}Search text${reset}
  ${command}head <file>${reset}        ${accent}→${reset} ${desc}First 10 lines${reset}
  ${command}la / ll${reset}            ${accent}→${reset} ${desc}List files / all files${reset}
```

- [ ] **Step 3: Verify profile loads and Show-Help renders**

Run: `pwsh -NoProfile -Command "& { . '$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1' 2>&1; Show-Help | Select-Object -First 5; Write-Host 'Profile OK' }"`
Expected: First lines of help output followed by `Profile OK`

- [ ] **Step 4: Commit**

```bash
git add Microsoft.PowerShell_profile.ps1
git commit -m "feat: add Rust Tools section to Show-Help, move entries from System"
```

---

### Task 7: Run the install script and verify end-to-end

- [ ] **Step 1: Run the winget portion of the install**

Run: `.\install-rust-tools.ps1`

This will take several minutes. winget installs are fast (pre-compiled binaries). cargo installs compile from source and take 5-10min each.

- [ ] **Step 2: Restart terminal and verify tools are available**

Run each tool to confirm it's on PATH:
```powershell
eza --version
bat --version
fd --version
rg --version
delta --version
dust --version
btm --version
tokei --version
gitui --version
yazi --version
hyperfine --version
navi --version
atuin --version
xh --version
broot --version
procs --version
```

- [ ] **Step 3: Verify fallback aliases work**

```powershell
la
ll
ff "*.ps1"
head Microsoft.PowerShell_profile.ps1
cat Microsoft.PowerShell_profile.ps1
grep "function" Microsoft.PowerShell_profile.ps1
du .
loc .
```

- [ ] **Step 4: Verify delta is working as git pager**

```powershell
git log --oneline -5
git diff HEAD~1
```

Expected: Colored, syntax-highlighted diff output via delta.

- [ ] **Step 5: Verify Show-Help**

```powershell
Show-Help
```

Expected: New "Rust Tools" section visible with all 16 entries.

- [ ] **Step 6: Final commit if any adjustments needed**

```bash
git add -A
git commit -m "fix: post-install adjustments"
```

---

## Summary

| Task | What | Files |
|---|---|---|
| 1 | Install script | `install-rust-tools.ps1` (create) |
| 2 | `_has` helper | `Microsoft.PowerShell_profile.ps1` (modify) |
| 3 | Rewrite existing aliases | `Microsoft.PowerShell_profile.ps1` (modify) |
| 4 | New tool aliases | `Microsoft.PowerShell_profile.ps1` (modify) |
| 5 | atuin/navi init | `Microsoft.PowerShell_profile.ps1` (modify) |
| 6 | Show-Help update | `Microsoft.PowerShell_profile.ps1` (modify) |
| 7 | Install + end-to-end verify | Run script, test everything |
