# gost_anim.sh - Gost Animation (X7Shafin): skull animation on every command + permission colors
# Source this from ~/.bashrc

X7_ANIM=1

# ---------- Color meaning ----------
#   WHITE  = allowed / you can enter
#   RED    = denied / you cannot enter
#   YELLOW = no permission / you can do nothing
#   GREEN  = normal text
_X7_W=$'\e[1;97m'
_X7_R=$'\e[1;38;2;255;42;42m'
_X7_Y=$'\e[1;38;2;255;221;51m'
_X7_G=$'\e[38;2;0;255;65m'
_X7_N=$'\e[0m'

# ls colors for any other ls usage (dirs white, files green, broken links yellow)
export LS_COLORS='di=1;97:tw=1;97:ow=1;97:st=1;97:ln=1;96:ex=1;32:fi=0;32:or=1;33:mi=1;33:su=1;31:sg=1;31:so=1;35:pi=33:bd=33:cd=33'

x7legend() {
  printf '%s■ WHITE  %s= allowed, you can enter\n' "$_X7_W" "$_X7_N"
  printf '%s■ RED    %s= denied, you cannot enter\n' "$_X7_R" "$_X7_N"
  printf '%s■ YELLOW %s= no permission, you can do nothing\n' "$_X7_Y" "$_X7_N"
  printf '%s■ GREEN  %s= normal text\n' "$_X7_G" "$_X7_N"
}

# Colors a stream line by line: red / yellow / white / green
_x7_color_stream() {
  local line l c
  while IFS= read -r line || [ -n "$line" ]; do
    l=${line,,}
    if [[ $l == *"permission denied"* || $l == *"access denied"* || $l == *forbidden* \
       || $l == *"cannot "* || $l == *"unable to"* || $l == *"file exists"* \
       || $l == *error* || $l == *fatal* || $l == *failed* ]]; then
      c=$_X7_R
    elif [[ $l == *"not permitted"* || $l == *"no permission"* || $l == *"read-only"* \
         || $l == *warning* || $l == *"no such file"* || $l == *"not a directory"* \
         || $l == *skipped* || $l == *deprecated* ]]; then
      c=$_X7_Y
    elif [[ $l == *granted* || $l == *allowed* || $l == *success* \
         || $l == *connected* || $l == *accepted* ]]; then
      c=$_X7_W
    else
      c=$_X7_G
    fi
    printf '%s%s%s\n' "$c" "$line" "$_X7_N"
  done
}

# ---------- Permission-aware ls ----------
_x7_class() {   # sets _X7CC to the color of the entry at path $1
  local p=$1
  if [ -L "$p" ] && [ ! -e "$p" ]; then _X7CC=$_X7_Y; return; fi
  if [ -d "$p" ]; then
    if [ -r "$p" ] && [ -x "$p" ]; then _X7CC=$_X7_W; else _X7CC=$_X7_R; fi
  else
    if [ -r "$p" ] || [ -w "$p" ] || [ -x "$p" ]; then _X7CC=$_X7_G; else _X7CC=$_X7_Y; fi
  fi
}

ls() {
  local a f i long=0 all=0 other=0 dir name line n w cols per
  local -a paths=() names=()
  for a in "$@"; do
    case "$a" in
      --*) other=1 ;;
      -[a-zA-Z]*)
        f=${a#-}
        for ((i = 0; i < ${#f}; i++)); do
          case ${f:i:1} in l) long=1 ;; a|A) all=1 ;; h) ;; *) other=1 ;; esac
        done ;;
      *) paths+=("$a") ;;
    esac
  done
  if (( other )) || [ ! -t 1 ] || [ ${#paths[@]} -gt 1 ]; then
    command ls --color=auto "$@"; return
  fi
  dir=${paths[0]:-.}
  if [ ! -d "$dir" ]; then command ls --color=auto "$@"; return; fi
  if [ ! -r "$dir" ] || [ ! -x "$dir" ]; then
    printf '%sls: cannot open directory %s: Permission denied%s\n' "$_X7_R" "'$dir'" "$_X7_N" >&2
    return 2
  fi

  if (( long )); then
    local perm links owner group size date time
    local fl=(-lh --time-style=long-iso); (( all )) && fl+=(-A)
    while IFS= read -r line; do
      case "$line" in
        total*) printf '%s%s%s\n' "$_X7_G" "$line" "$_X7_N"; continue ;;
      esac
      read -r perm links owner group size date time name <<<"$line"
      n=${name%% -> *}
      _x7_class "$dir/$n"
      printf '%s%s %s %s %s %5s %s %s %s%s%s\n' "$_X7_G" "$perm" "$links" "$owner" "$group" \
        "$size" "$date" "$time" "$_X7CC" "$name" "$_X7_N"
    done < <(command ls "${fl[@]}" -- "$dir")
  else
    local fl=(-1); (( all )) && fl+=(-A)
    while IFS= read -r line; do names+=("$line"); done < <(command ls "${fl[@]}" -- "$dir")
    [ ${#names[@]} -eq 0 ] && return 0
    w=0
    for n in "${names[@]}"; do (( ${#n} > w )) && w=${#n}; done
    w=$(( w + 2 ))
    cols=$(( ${COLUMNS:-60} / w )); (( cols < 1 )) && cols=1
    per=0
    for n in "${names[@]}"; do
      _x7_class "$dir/$n"
      printf '%s%s%s%*s' "$_X7CC" "$n" "$_X7_N" "$(( w - ${#n} ))" ''
      per=$(( per + 1 ))
      if (( per % cols == 0 )); then printf '\n'; fi
    done
    (( per % cols != 0 )) && printf '\n'
  fi
}
ll() { ls -lA "$@"; }

# cd shows denied / missing directories in color
cd() {
  local f rc
  f=$(mktemp)
  builtin cd "$@" 2>"$f"; rc=$?
  [ -s "$f" ] && _x7_color_stream <"$f" >&2
  rm -f "$f"
  return $rc
}

# Colors error messages of simple commands (they print after the output)
_x7_errwrap() {
  local c=$1 f rc; shift
  f=$(mktemp)
  command "$c" "$@" 2>"$f"; rc=$?
  [ -s "$f" ] && _x7_color_stream <"$f" >&2
  rm -f "$f"
  return $rc
}
for _x7c in cat head tail mkdir touch chmod; do
  eval "${_x7c}() { _x7_errwrap ${_x7c} \"\$@\"; }"
done
unset _x7c

# ---------- Skull animation ----------
_x7_draw() {
  # $1 = frame number, $2 = message, $3 = bar string
  local i=$1 msg=$2 bar=$3
  local N=$'\e[0m' G1=$'\e[38;2;0;255;65m' G2=$'\e[38;2;0;204;51m'
  local RD=$'\e[1;38;2;255;42;42m' WH=$'\e[1;97m' CY=$'\e[38;2;95;243;255m'
  local MG=$'\e[38;2;214;112;214m' YL=$'\e[38;2;255;221;51m'
  local eye=$RD sh=''
  (( i % 4 == 0 )) && eye=$WH
  (( i % 5 == 0 )) && sh='  '
  printf '\e[9A'
  printf '%s\e[K\n' "        ${G1}▄▄████████▄▄${N}"
  printf '%s\e[K\n' "      ${G1}▄██████████████▄${N}   ${CY}X 7 S H A F I N${N}"
  printf '%s\e[K\n' "     ${sh}${G1}██████████████████${N}  ${MG}G O S T${N}"
  printf '%s\e[K\n' "     ${G1}███${eye}▄██▄${G1}████${eye}▄██▄${G1}███${N}"
  printf '%s\e[K\n' "     ${G1}███${eye}▀██▀${G1}█▄▄█${eye}▀██▀${G1}███${N}  ${WH}${msg}${N}"
  printf '%s\e[K\n' "      ${G2}▀██${CY} █ █ █ █ ${G2}██▀${N}"
  printf '%s\e[K\n' "        ${MG}▀▀████████▀▀${N}"
  printf '%s\e[K\n' "   ${G1}[${bar}${G1}]${N}"
  printf '%s\e[K\n' "   ${YL}Gost Animation | Powered by X7Shafin${N}"
}

_x7_bar_fill() {  # filled bar, $1 = 0..20
  local DG=$'\e[38;2;60;90;60m' f=$1 a b
  a=$(printf '%*s' "$f" ''); a=${a// /█}
  b=$(printf '%*s' "$((20 - f))" ''); b=${b// /░}
  printf '%s' "${a}${DG}${b}"
}

_x7_bar_scan() {  # moving block, $1 = frame number
  local DG=$'\e[38;2;60;90;60m' p=$(( $1 % 30 )) a b
  (( p > 15 )) && p=$(( 30 - p ))
  a=$(printf '%*s' "$p" ''); a=${a// /░}
  b=$(printf '%*s' "$((15 - p))" ''); b=${b// /░}
  printf '%s' "${DG}${a}"$'\e[38;2;0;255;65m'"█████${DG}${b}"
}

# Short animation (about 0.7 second): plays before every command
x7_anim() {
  local msg="${1:-LOADING}" i
  [ -t 1 ] || return 0
  printf '\n\n\n\n\n\n\n\n\n'
  for i in 1 2 3 4 5 6 7 8; do
    _x7_draw "$i" "$msg" "$(_x7_bar_fill $(( i * 20 / 8 )))"
    sleep 0.05
  done
  sleep 0.15
  printf '\e[9A\e[J'
}

# Runs a command and keeps animating until it really finishes.
# Very fast commands (under 0.3s) run with no animation, so nothing flickers.
x7_run() {
  local msg=$1; shift
  if [ "$X7_ANIM" = "0" ] || [ ! -t 1 ] || [ ! -t 0 ]; then "$@"; return $?; fi

  local log pid i=0 rc shown=0 hadm=0 k
  [[ $- == *m* ]] && hadm=1
  set +m
  log=$(mktemp)
  { "$@" >"$log" 2>&1 </dev/null & } 2>/dev/null
  pid=$!
  trap 'kill "$pid" 2>/dev/null' INT

  for k in 1 2 3; do
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.1
  done

  if kill -0 "$pid" 2>/dev/null; then
    shown=1
    printf '\n\n\n\n\n\n\n\n\n'
    while kill -0 "$pid" 2>/dev/null; do
      i=$(( i + 1 ))
      _x7_draw "$i" "$msg" "$(_x7_bar_scan "$i")"
      sleep 0.08
    done
  fi

  wait "$pid" 2>/dev/null; rc=$?
  trap - INT
  (( hadm )) && set -m
  (( shown )) && printf '\e[9A\e[J'
  # apt prints a harmless "stable CLI interface" warning when its output goes to a file; hide it
  sed -z 's/\n*WARNING: apt does not have a stable CLI interface\. Use with caution in scripts\.\n*/\n/g' "$log" | _x7_color_stream
  rm -f "$log"

  if (( shown )); then
    if [ $rc -eq 0 ]; then
      printf '%s[+] %s: DONE%s\n' "$_X7_G" "$msg" "$_X7_N"
    else
      printf '%s[!] %s: FAILED (code %s)%s\n' "$_X7_R" "$msg" "$rc" "$_X7_N"
    fi
  fi
  return $rc
}

x7off() { X7_ANIM=0; echo "X7 animation: OFF"; }
x7on()  { X7_ANIM=1; echo "X7 animation: ON"; }

# Run ANY command and keep the animation until it ends:  gx python script.py
gx() { x7_run "${1^^}" "$@"; }

brand() {
  echo -e "\e[1;32m░▒▓ 👻 SHAFIN KHAN | X7Shafin ▓▒░\e[0m"
  echo -e "\e[36m TG: https://t.me/GhostX_Hacker\e[0m"
  echo -e "\e[36m FB: https://www.facebook.com/share/1E8gkJwn2c/\e[0m"
  echo -e "\e[38;2;255;221;51m Powered by X7Shafin\e[0m"
}

# ---------- Commands that animate while they work ----------
_x7_pkgish() {
  local name=$1; shift
  case "$1" in
    install|upgrade|full-upgrade|dist-upgrade)
      case " $* " in
        *" -y "*) x7_run "${name^^} ${1^^}" command "$name" "$@" ;;
        *) x7_run "${name^^} ${1^^}" command "$name" "$@" -y ;;
      esac ;;
    update|search) x7_run "${name^^} ${1^^}" command "$name" "$@" ;;
    *) x7_anim "${name^^} ${1^^}"; command "$name" "$@" ;;
  esac
}
pkg()     { _x7_pkgish pkg "$@"; }
apt()     { _x7_pkgish apt "$@"; }
apt-get() { _x7_pkgish apt-get "$@"; }

git() {
  case "$1" in
    clone) x7_run "GIT CLONE" command git "$@"; local s=$?; brand; return $s ;;
    pull|fetch) x7_run "GIT ${1^^}" command git "$@" ;;
    *) x7_anim "GIT ${1^^}"; command git "$@" ;;
  esac
}

pip()  { case "$1" in install|download|uninstall) x7_run "PIP ${1^^}" command pip "$@" ;; *) x7_anim "PIP"; command pip "$@" ;; esac; }
pip3() { case "$1" in install|download|uninstall) x7_run "PIP ${1^^}" command pip3 "$@" ;; *) x7_anim "PIP"; command pip3 "$@" ;; esac; }

_x7_wrap() { local c=$1; shift; x7_run "${c^^}" command "$c" "$@"; }
for _x7c in curl wget find grep tar unzip zip gzip bzip2 xz rsync make cmake gcc clang cargo npm yarn dpkg nmap; do
  eval "${_x7c}() { _x7_wrap ${_x7c} \"\$@\"; }"
done
unset _x7c

# ---------- Animation before ANY other command ----------
X7_SKIP=" cd clear cls exit banner brand gx x7on x7off x7legend source . alias unalias export unset set history echo printf pwd true false : "
X7_WRAPPED=" pkg apt apt-get git pip pip3 curl wget find grep tar unzip zip gzip bzip2 xz rsync make cmake gcc clang cargo npm yarn dpkg nmap "
_x7_ready=0
_x7_prompt() { _x7_ready=1; }
_x7_debug() {
  [ "$_x7_ready" = 1 ] || return 0
  _x7_ready=0
  [ "$X7_ANIM" = "0" ] && return 0
  [[ $BASH_COMMAND == *X7Shafin.py* ]] && return 0
  local first=${BASH_COMMAND%% *}
  case "$X7_SKIP$X7_WRAPPED" in *" $first "*) return 0 ;; esac
  x7_anim "${first^^}"
}
trap '_x7_debug' DEBUG
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}_x7_prompt"
