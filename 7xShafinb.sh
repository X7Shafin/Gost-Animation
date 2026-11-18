#!/data/data/com.termux/files/usr/bin/bash
# 7xShafinb.sh - SHAFIN KHAN | X7Shafin
# Cleans ~/.bashrc and applies the full hacker theme to Termux.

G='\033[1;32m'; R='\033[1;31m'; N='\033[0m'
say() { echo -e "${G}[+]${N} $1"; }

say "Installing dependencies"
pkg install python -y >/dev/null 2>&1
pip install -q pyfiglet rich 2>/dev/null

say "Backing up old .bashrc to ~/.bashrc.bak"
[ -f ~/.bashrc ] && cp ~/.bashrc ~/.bashrc.bak

say "Removing old files"
rm -f ~/fontx.py ~/GhostX_Hacker.py ~/ghostx_anim.sh

say "Copying X7Shafin files"
# Looks next to this script first (git clone), then in the Download folder
SRC="$(cd "$(dirname "$0")" && pwd)"
for f in X7Shafin.py x7anim.sh; do
  if [ -f "$SRC/$f" ] && [ "$SRC" != "$HOME" ]; then
    cp "$SRC/$f" ~/"$f"
  elif [ -f "/sdcard/Download/$f" ]; then
    cp "/sdcard/Download/$f" ~/"$f"
  fi
done
[ -f ~/X7Shafin.py ] || echo -e "${R}[!] X7Shafin.py not found.${N}"
[ -f ~/x7anim.sh ]   || echo -e "${R}[!] x7anim.sh not found.${N}"

say "Writing clean .bashrc"
cat > ~/.bashrc <<'EOT'
# ---- SHAFIN KHAN | X7Shafin hacker theme ----
case $- in *i*) ;; *) return ;; esac

export PS1='\[\e[1;32m\]┌──(\[\e[1;31m\]shafin@termux\[\e[1;32m\])-[\[\e[1;36m\]\w\[\e[1;32m\]]\n└─\[\e[1;31m\]#\[\e[0m\] '

alias cls='clear && python ~/X7Shafin.py -q 2>/dev/null'
alias banner='python ~/X7Shafin.py 2>/dev/null'
alias update='pkg update && pkg upgrade'

[ -f ~/x7anim.sh ] && source ~/x7anim.sh
[ -f ~/X7Shafin.py ] && python ~/X7Shafin.py -q 2>/dev/null
EOT

say "Applying green hacker colors"
mkdir -p ~/.termux
cat > ~/.termux/colors.properties <<'EOT'
background=#000000
foreground=#00ff41
cursor=#00ff41
color0=#000000
color1=#ff3b3b
color2=#00ff41
color3=#e5e510
color4=#3b8bff
color5=#d670d6
color6=#00e5ff
color7=#c8c8c8
color8=#555555
color9=#ff6b6b
color10=#5cff7a
color11=#fff176
color12=#6aa9ff
color13=#e895e8
color14=#5ff3ff
color15=#ffffff
EOT

touch ~/.hushlogin
termux-reload-settings 2>/dev/null

say "Done. Close Termux completely and open it again."
