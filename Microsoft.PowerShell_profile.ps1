### Chris Titus Tech's PowerShell profile

oh-my-posh init pwsh --config $Home\Documents\PowerShell\cobalt2.omp.json | Invoke-Expression
zoxide init --cmd z powershell | Out-String | Invoke-Expression
Import-Module -Name Terminal-Icons

Write-Host "Use 'Show-Help' to list all available functions" -ForegroundColor Yellow

# History & Colors
Set-PSReadLineOption -PredictionViewStyle ListView -Colors @{
    Command   = '#87CEEB'
    Parameter = '#98FB98'
    Operator  = '#FFB6C1'
    Variable  = '#DDA0DD'
    String    = '#FFDAB9'
    Number    = '#B0E0E6'
    Type      = '#F0E68C'
    Comment   = '#D3D3D3'
    Keyword   = '#8367c7'
    Error     = '#FF6347'
}

#KeyBinds
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord
Set-PSReadLineKeyHandler -Chord 'Alt+d' -Function DeleteWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow' -Function BackwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
Set-PSReadLineKeyHandler -Chord 'Ctrl+y' -Function Redo

# Functions
function Update-Profile {
    Invoke-WebRequest -Uri https://github.com/ChrisTitusTech/powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $Profile
    Write-Host "Updated PowerShell Profile" -ForegroundColor Green
}

# File / Directory Utilities
function touch ($File) {
    if (Test-Path $File) {
        (Get-Item $File).LastWriteTime = Get-Date
    }
    else {
        New-Item $File -ItemType File | Out-Null
    }
}

function mkcd ($Path) {
    New-Item -Path $Path -ItemType Directory -Force | Out-Null
    Set-Location -Path $Path
}

function trash ($Path) {
    if (Test-Path $Path -PathType Container) {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($Path, 'OnlyErrorDialogs', 'SendToRecycleBin')
    }
    else {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($Path, 'OnlyErrorDialogs', 'SendToRecycleBin')
    }
}

function ff ($Name) {
    Get-ChildItem -Recurse -Filter $Name -File | Select-Object -ExpandProperty FullName
}

function head ($Path) {
    Get-Content $Path -Head 10
}

function sed ($File, $Find, $Replace) {
    (Get-Content $File).replace("$Find", $Replace) | Set-Content $file
}

function which ($Name) {
    (Get-Command $Name).Source
}

function pgrep ($Name) {
    Get-Process -Name $Name -ErrorAction SilentlyContinue
}

function pkill ($Name) {
    Get-Process -Name $Name -ErrorAction SilentlyContinue | Stop-Process -Force
}

function k9 ($Name) {
    pkill $Name
}

# System Utilities
function uptime {
    (Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime | Select-Object Days, Hours, Minutes, Seconds
}

function winutil {
    Invoke-RestMethod https://christitus.com/win | Invoke-Expression
}

function winutildev {
    Invoke-RestMethod https://christitus.com/windev | Invoke-Expression
}

# Git Shortcuts
function gs { git status }
function ga { git add . }
function gp { git push }
function gpush { git push }
function gpull { git pull }
function gcl { git clone $args }
function g { __zoxide_z github }

function gcom {
    git add .
    git commit -m "$args"
}

function lazyg {
    git add .
    git commit -m "$args"
    git push
}

# Claude
function yolo { claude --dangerously-skip-permissions @args }

# Docker
function dcu { docker compose up -d @args }
function dcd { docker compose down @args }
function dcb { docker compose build @args }
function dcl { docker compose logs -f @args }
function dps { docker ps @args }
function dex { docker exec -it @args }

# Bun
function bi { bun install @args }
function br { bun run @args }
function bd { bun run dev @args }
function bt { bun test @args }
function ba { bun add @args }
function bdv { bun run build:dev }

# Mise
function mi { mise install @args }
function mu { mise use @args }
function ml { mise ls @args }

# Navigation
function docs {
    Set-Location -Path ([Environment]::GetFolderPath("MyDocuments"))
}
function proj { Set-Location "$Home\Documents\Projects" }
function trab { Set-Location "$Home\Documents\Trabalho" }
function dl { Set-Location "$Home\Downloads" }
function dt { Set-Location "$Home\Desktop" }
function vid { Set-Location "$Home\Videos" }

# Apps
function ex { explorer.exe $args }
function ag { antigravity-ide $args }
function vlc { & "${env:ProgramFiles}\VideoLAN\VLC\vlc.exe" @args }

# Listing / Viewing
function la {
    Get-ChildItem | Format-Table -AutoSize
}

function ll {
    Get-ChildItem -Force | Format-Table -AutoSize
}

# Network
function myip {
    $geo = (Invoke-RestMethod -Uri 'https://ipinfo.io/json' -UseBasicParsing)
    $dim = $PSStyle.Foreground.BrightBlack
    $city = $PSStyle.Foreground.BrightCyan
    $val = $PSStyle.Foreground.BrightWhite
    $green = $PSStyle.Foreground.BrightGreen
    $r = $PSStyle.Reset
    Write-Host "${city}$($geo.city)${r}${dim}, ${r}${val}$($geo.region)${r}${dim} - ${r}${city}$($geo.country)${r}${dim} ($($geo.org))${r}"
    $geo.ip | Set-Clipboard
    Write-Host "${green}$($geo.ip)${r} ${dim}~ copied${r}"
}
function flushdns { ipconfig /flushdns }
function testport ($Host_, $Port) { Test-NetConnection -ComputerName $Host_ -Port $Port }

# Clipboard / Text
function cb { $input | Set-Clipboard }
function b64 ($Text) { [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Text)) }
function b64d ($Text) { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Text)) }
function uuid { [guid]::NewGuid().ToString() }
function genpass ([int]$Len = 20) {
    $pw = -join ((33..126) | Get-Random -Count $Len | ForEach-Object { [char]$_ })
    $pw | Set-Clipboard
    Write-Host "✓ Copied to clipboard" -ForegroundColor Green
    return $pw
}

# Dev Workflow
function nuke {
    $dirs = @('node_modules', '.bun', '.next', '.nuxt', 'dist', '.turbo')
    $dirs | Where-Object { Test-Path $_ } | ForEach-Object {
        Write-Host "Removing $_" -ForegroundColor Yellow
        Remove-Item $_ -Recurse -Force
    }
    if (Test-Path 'bun.lockb') { bun install } elseif (Test-Path 'package-lock.json') { npm install }
}

function killport ($Port) {
    $pid_ = (Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue).OwningProcess | Select-Object -First 1
    if ($pid_) {
        $proc = Get-Process -Id $pid_ -ErrorAction SilentlyContinue
        Write-Host "Killing $($proc.ProcessName) (PID $pid_) on port $Port" -ForegroundColor Yellow
        Stop-Process -Id $pid_ -Force
    }
    else {
        Write-Host "No process on port $Port" -ForegroundColor Gray
    }
}

# Git Advanced
function gundo { git reset --soft HEAD~1 }
function gstash { git stash @args }
function gpop { git stash pop }
function gclean { git branch --merged | Where-Object { $_ -notmatch '^\*|main|master|dev' } | ForEach-Object { git branch -d $_.Trim() } }

# Disk / Cleanup
function cleantemp {
    $before = (Get-ChildItem $env:TEMP -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
    Get-ChildItem $env:TEMP -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    $after = (Get-ChildItem $env:TEMP -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "Freed $([math]::Round($before - $after, 1)) MB" -ForegroundColor Green
}

# PowerToys
function colorpick { Start-Process "${env:ProgramFiles}\PowerToys\PowerToys.ColorPickerUI.exe" }

# yt-dlp
function ytmp4 { yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]' -o '%(title)s.%(ext)s' @args }
function ytmp3 { yt-dlp -x --audio-format mp3 --audio-quality 0 -o '%(title)s.%(ext)s' @args }
function yt720 { yt-dlp -f 'bestvideo[height<=720]+bestaudio/best[height<=720]' -o '%(title)s.%(ext)s' @args }
function yt1080 { yt-dlp -f 'bestvideo[height<=1080]+bestaudio/best[height<=1080]' -o '%(title)s.%(ext)s' @args }
function yt4k { yt-dlp -f 'bestvideo[height<=2160]+bestaudio/best[height<=2160]' -o '%(title)s.%(ext)s' @args }
function ytbest { yt-dlp -f 'bestvideo+bestaudio/best' -o '%(title)s.%(ext)s' @args }
function ytls { yt-dlp -F @args }

# yt-dlp -> ~/Videos
$_vdir = "$Home\Videos"
function vytmp4 { ytmp4 -o "$_vdir\%(title)s.%(ext)s" @args }
function vytmp3 { ytmp3 -o "$_vdir\%(title)s.%(ext)s" @args }
function vyt720 { yt720 -o "$_vdir\%(title)s.%(ext)s" @args }
function vyt1080 { yt1080 -o "$_vdir\%(title)s.%(ext)s" @args }
function vyt4k { yt4k -o "$_vdir\%(title)s.%(ext)s" @args }
function vytbest { ytbest -o "$_vdir\%(title)s.%(ext)s" @args }

# FFmpeg
function tomp4 ($In) { ffmpeg -i $In -c:v libx264 -crf 23 -c:a aac -b:a 192k "$([IO.Path]::ChangeExtension($In, '.mp4'))" }
function tomp3 ($In) { ffmpeg -i $In -vn -c:a libmp3lame -q:a 0 "$([IO.Path]::ChangeExtension($In, '.mp3'))" }
function towav ($In) { ffmpeg -i $In -vn -c:a pcm_s16le "$([IO.Path]::ChangeExtension($In, '.wav'))" }
function togif ($In, [int]$Fps = 15, [int]$W = 480) { ffmpeg -i $In -vf "fps=$Fps,scale=${W}:-1:flags=lanczos" -loop 0 "$([IO.Path]::ChangeExtension($In, '.gif'))" }
function towebm ($In) { ffmpeg -i $In -c:v libvpx-vp9 -crf 30 -b:v 0 -c:a libopus "$([IO.Path]::ChangeExtension($In, '.webm'))" }
function toflac ($In) { ffmpeg -i $In -vn -c:a flac "$([IO.Path]::ChangeExtension($In, '.flac'))" }

# Aliases
Set-Alias -Name unzip -Value Expand-Archive
Set-Alias -Name grep -Value Select-String

# Help Function
function Show-Help {
    $title = $PSStyle.Foreground.BrightMagenta
    $section = $PSStyle.Foreground.BrightBlue
    $command = $PSStyle.Foreground.BrightGreen
    $desc = $PSStyle.Foreground.BrightWhite
    $accent = $PSStyle.Foreground.BrightYellow
    $dim = $PSStyle.Foreground.BrightBlack
    $reset = $PSStyle.Reset

    Write-Host @"
${title}󰘳 PowerShell Profile Help${reset}
${dim}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}

${section}󰊢 Git${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}g${reset}                  ${accent}→${reset} ${desc}GitHub directory${reset}
  ${command}gs${reset}                 ${accent}→${reset} ${desc}git status${reset}
  ${command}ga${reset}                 ${accent}→${reset} ${desc}git add .${reset}
  ${command}gp / gpush${reset}         ${accent}→${reset} ${desc}git push${reset}
  ${command}gpull${reset}              ${accent}→${reset} ${desc}git pull${reset}
  ${command}gcl <repo>${reset}         ${accent}→${reset} ${desc}git clone${reset}
  ${command}gcom <msg>${reset}         ${accent}→${reset} ${desc}add + commit${reset}
  ${command}lazyg <msg>${reset}        ${accent}→${reset} ${desc}add + commit + push${reset}
  ${command}gundo${reset}              ${accent}→${reset} ${desc}undo last commit (keep changes)${reset}
  ${command}gstash / gpop${reset}      ${accent}→${reset} ${desc}stash / pop${reset}
  ${command}gclean${reset}             ${accent}→${reset} ${desc}delete merged branches${reset}

${section}󰚩 Claude${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}yolo${reset}               ${accent}→${reset} ${desc}claude --dangerously-skip-permissions${reset}

${section}󰡨 Docker${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}dcu${reset}                ${accent}→${reset} ${desc}compose up -d${reset}
  ${command}dcd${reset}                ${accent}→${reset} ${desc}compose down${reset}
  ${command}dcb${reset}                ${accent}→${reset} ${desc}compose build${reset}
  ${command}dcl${reset}                ${accent}→${reset} ${desc}compose logs -f${reset}
  ${command}dps${reset}                ${accent}→${reset} ${desc}docker ps${reset}
  ${command}dex <id> <cmd>${reset}     ${accent}→${reset} ${desc}docker exec -it${reset}

${section}󰈸 Bun${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}bi${reset}                 ${accent}→${reset} ${desc}bun install${reset}
  ${command}br <script>${reset}        ${accent}→${reset} ${desc}bun run${reset}
  ${command}bd${reset}                 ${accent}→${reset} ${desc}bun run dev${reset}
  ${command}bt${reset}                 ${accent}→${reset} ${desc}bun test${reset}
  ${command}ba <pkg>${reset}           ${accent}→${reset} ${desc}bun add${reset}
  ${command}bdv${reset}                ${accent}→${reset} ${desc}bun run build:dev${reset}

${section}󱁤 Mise${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}mi${reset}                 ${accent}→${reset} ${desc}mise install${reset}
  ${command}mu <tool@ver>${reset}      ${accent}→${reset} ${desc}mise use${reset}
  ${command}ml${reset}                 ${accent}→${reset} ${desc}mise ls${reset}

${section}󰉋 Navigation${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}proj${reset}               ${accent}→${reset} ${desc}~/Documents/Projects${reset}
  ${command}trab${reset}               ${accent}→${reset} ${desc}~/Documents/Trabalho${reset}
  ${command}docs${reset}               ${accent}→${reset} ${desc}~/Documents${reset}
  ${command}dl${reset}                 ${accent}→${reset} ${desc}~/Downloads${reset}
  ${command}dt${reset}                 ${accent}→${reset} ${desc}~/Desktop${reset}
  ${command}vid${reset}                ${accent}→${reset} ${desc}~/Videos${reset}

${section}󰀶 Apps${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}ag [path]${reset}          ${accent}→${reset} ${desc}Antigravity IDE${reset}
  ${command}ex [path]${reset}          ${accent}→${reset} ${desc}Explorer${reset}
  ${command}vlc <file>${reset}         ${accent}→${reset} ${desc}VLC media player${reset}
  ${command}colorpick${reset}          ${accent}→${reset} ${desc}PowerToys Color Picker${reset}

${section}󰛳 Network${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}myip${reset}               ${accent}→${reset} ${desc}Public IP + location (copies IP)${reset}
  ${command}flushdns${reset}           ${accent}→${reset} ${desc}Clear DNS cache${reset}
  ${command}testport <h> <p>${reset}   ${accent}→${reset} ${desc}Test port connectivity${reset}

${section}󰅍 Clipboard / Text${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}<cmd> | cb${reset}         ${accent}→${reset} ${desc}Copy output to clipboard${reset}
  ${command}b64 <text>${reset}         ${accent}→${reset} ${desc}Base64 encode${reset}
  ${command}b64d <text>${reset}        ${accent}→${reset} ${desc}Base64 decode${reset}
  ${command}uuid${reset}              ${accent}→${reset} ${desc}Generate UUID${reset}
  ${command}genpass [len]${reset}      ${accent}→${reset} ${desc}Random password (default 20)${reset}

${section}󰁯 Dev Workflow${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}nuke${reset}               ${accent}→${reset} ${desc}Remove node_modules + reinstall${reset}
  ${command}killport <port>${reset}    ${accent}→${reset} ${desc}Kill process on port${reset}

${section}󰋊 Disk / Cleanup${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}cleantemp${reset}          ${accent}→${reset} ${desc}Clear %TEMP%${reset}

${section}󰗃 yt-dlp${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}ytmp4 <url>${reset}        ${accent}→${reset} ${desc}Download MP4 (best)${reset}
  ${command}ytmp3 <url>${reset}        ${accent}→${reset} ${desc}Extract audio as MP3${reset}
  ${command}yt720 <url>${reset}        ${accent}→${reset} ${desc}Download 720p${reset}
  ${command}yt1080 <url>${reset}       ${accent}→${reset} ${desc}Download 1080p${reset}
  ${command}yt4k <url>${reset}         ${accent}→${reset} ${desc}Download 4K${reset}
  ${command}ytbest <url>${reset}       ${accent}→${reset} ${desc}Download best quality${reset}
  ${command}ytls <url>${reset}         ${accent}→${reset} ${desc}List available formats${reset}
  ${dim}  v* variants save to ~/Videos:${reset}
  ${command}vytmp4 / vytmp3${reset}    ${accent}→${reset} ${desc}MP4 / MP3 -> Videos${reset}
  ${command}vyt720 / vyt1080${reset}   ${accent}→${reset} ${desc}720p / 1080p -> Videos${reset}
  ${command}vyt4k / vytbest${reset}    ${accent}→${reset} ${desc}4K / best -> Videos${reset}

${section}󰈫 FFmpeg${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}tomp4 <file>${reset}       ${accent}→${reset} ${desc}Convert to MP4 (H.264)${reset}
  ${command}tomp3 <file>${reset}       ${accent}→${reset} ${desc}Convert to MP3${reset}
  ${command}towav <file>${reset}       ${accent}→${reset} ${desc}Convert to WAV${reset}
  ${command}toflac <file>${reset}      ${accent}→${reset} ${desc}Convert to FLAC${reset}
  ${command}togif <f> [fps] [w]${reset} ${accent}→${reset} ${desc}Convert to GIF (default 15fps 480w)${reset}
  ${command}towebm <file>${reset}      ${accent}→${reset} ${desc}Convert to WebM (VP9)${reset}

${section}󰘴 System${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}ff <name>${reset}          ${accent}→${reset} ${desc}Search files${reset}
  ${command}grep <pattern>${reset}     ${accent}→${reset} ${desc}Search text${reset}
  ${command}head <file>${reset}        ${accent}→${reset} ${desc}First 10 lines${reset}
  ${command}touch <file>${reset}       ${accent}→${reset} ${desc}Create file${reset}
  ${command}mkcd <dir>${reset}         ${accent}→${reset} ${desc}Create + enter dir${reset}
  ${command}sed <f> <find> <rep>${reset} ${accent}→${reset} ${desc}Replace text${reset}
  ${command}la / ll${reset}            ${accent}→${reset} ${desc}List files / all files${reset}
  ${command}pgrep / pkill / k9${reset} ${accent}→${reset} ${desc}Find / kill process${reset}
  ${command}which <name>${reset}       ${accent}→${reset} ${desc}Locate command${reset}
  ${command}unzip <file>${reset}       ${accent}→${reset} ${desc}Extract zip${reset}
  ${command}uptime${reset}             ${accent}→${reset} ${desc}System uptime${reset}
  ${command}winutil${reset}            ${accent}→${reset} ${desc}Run WinUtil${reset}

${section}󰏗 Profile${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}Update-Profile${reset}     ${accent}→${reset} ${desc}Update from remote${reset}

${dim}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}
"@
}
