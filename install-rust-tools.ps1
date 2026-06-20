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
