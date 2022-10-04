#!/bin/zsh

 C="\e[0m"       # 0  = clear codes
 O="\e[1m"       # 1  = turn on bOld
 k="\e[38;5;0m"  # 0  = blacK
 r="\e[38;5;1m"  # 1  = Red
 g="\e[38;5;2m"  # 2  = Green
 y="\e[38;5;3m"  # 3  = Yellow
 b="\e[38;5;4m"  # 4  = Blue
 m="\e[38;5;5m"  # 5  = Magenta
 c="\e[38;5;6m"  # 6  = Cyan
 w="\e[38;5;7m"  # 7  = White
iK="\e[38;5;8m"  # 8  = Intense blacK (grey)
ir="\e[38;5;9m"  # 9  = Intense Red
ig="\e[38;5;10m" # 10 = Intense Green
iy="\e[38;5;11m" # 11 = Intense Yellow
ib="\e[38;5;12m" # 12 = Intense Blue
im="\e[38;5;13m" # 13 = Inense Magenta
ic="\e[38;5;14m" # 14 = Intense Cyan
iw="\e[38;5;15m" # 15 = Intense White

# If a script exists here, use it to deduce hostname symbol
[ -f ~/.zsh/bin/hostname-symbol ] && location=`~/.zsh/bin/hostname-symbol`

# location will be zero length if script did not work above, use the following code as example
if [ -z "$location" ]; then
  location="¿"
fi

function get_pwd() {
  echo "${PWD/$HOME/~}"
}

function get_infograph() {
  CODE=${1}
  FMT=${2}
  OFFSET=${3}
  VAL=$(date -u +"${FMT}")
  DEC=$(echo "obase=10; ibase=16; ${CODE}" | bc)
  CODE_DEC=$(expr ${DEC} - ${OFFSET} + ${VAL})
  CODE_HEX=$(echo "obase=16; ibase=10; ${CODE_DEC}" | bc)
  echo "\u${CODE_HEX}"
}

function get_moy() {
  # ㋀
  get_infograph "32C0" "%m" "1"
}

function get_dom() {
  # ㏠
  get_infograph "33E0" "%d" "1"
}

function get_hod() {
  # ㍘
  get_infograph "3358" "%H" "0"
}

function get_time() {
  date +"$(get_moy)$(get_dom)●%H:%M:%S"
  #date +"%Y-%m-%dT%H:%M:%S"
}

function hidden_utc() {
  DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  echo -n "%{$fg[black]%}♁${DATE}♁%{$reset_color%} "
}

function hidden_time() {
  DATE=$(date +"%Y-%m-%dT%H:%M:%S")
  echo -n "%{$fg[black]%}↓${DATE}↓%{$reset_color%}"
}

fucntion cookie_expiration() {
  local cookie_file="${HOME}/.$(echo -e '\x6d\x69\x64\x77\x61\x79')/cookie"
  if [ -f "${cookie_file}" ]; then
    local remaining=$(expr $(awk '/session/ { print $5 }' ${cookie_file}) - $(date +%s))
    local display=$(date -r ${remaining} -u +%H:%M 2>/dev/null || date -d@${remaining} -u +%H:%M 2>/dev/null)
    if [ ${remaining} -lt 600 ]; then
      echo "(M%{$fg_bold[red]%}${display}%{$reset_color%})"
    else
      echo "%{$fg_bold[black]%}(M${display})%{$reset_color%}"
    fi
  fi
}

function get_spacing() {
  local left="${0}"
  local right"${1}"
  local termwidth
  (( termwidth = ${COLUMNS} - ${#$(left)} - ${git} - 1 - ${#$(get_time)} ))
  local sp=""
  for i in {1..$termwidth}; do
      sp="${sp}X"
  done
  echo $sp
}

# Usage: prompt-length TEXT [COLUMNS]
#
# If you run `print -P TEXT`, how many characters will be printed
# on the last line?
#
# Or, equivalently, if you set PROMPT=TEXT with prompt_subst
# option unset, on which column will the cursor be?
#
# The second argument specifies terminal width. Defaults to the
# real terminal width.
#
# Assumes that `%{%}` and `%G` don't lie.
#
# Examples:
#
#   prompt-length ''            => 0
#   prompt-length 'abc'         => 3
#   prompt-length $'abc\nxy'    => 2
#   prompt-length '❎'          => 2
#   prompt-length $'\t'         => 8
#   prompt-length $'\u274E'     => 2
#   prompt-length '%F{red}abc'  => 3
#   prompt-length $'%{a\b%Gb%}' => 1
#   prompt-length '%D'          => 8
#   prompt-length '%1(l..ab)'   => 2
#   prompt-length '%(!.a.)'     => 1 if root, 0 if not
function prompt_length() {
  emulate -L zsh
  local COLUMNS=${2:-$COLUMNS}
  local -i x y=${#1} m
  if (( y )); then
    while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
      x=y
      (( y *= 2 ))
    done
    while (( y > x + 1 )); do
      (( m = x + (y - x) / 2 ))
      (( ${${(%):-$1%$m(l.x.y)}[-1]} = m ))
    done
  fi
  echo $x
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
build_prompt() {
  RETVAL=$?
  local symbols
  [[ $RETVAL -ne 0 ]] && symbols="%{$fg[red]%}✘%{$reset_color%}"
  [[ $UID -eq 0 ]] && symbols="$symbols%{$fg[yellow]%}⚡%{$reset_color%}"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols="$symbols%{$fg[cyan]%}⚙%{$reset_color%}"
  [ -n "$symbols" ] && symbols="$symbols "
  LEFT="\
%{$fg[cyan]%}$location%{$reset_color%} \
%{$fg_bold[black]%}$(get_time)%{$reset_color%} \
%{$fg[yellow]%}$(get_pwd)%{$reset_color%}"
  OPTIONALS=($(hidden_time) $(hidden_utc))
  RIGHT="$(cookie_expiration) $(git_super_status)"

  PSEUDO_PROMPT="$LEFT $OPTIONALS$RIGHT"
  promptwidth=$(prompt_length "$PSEUDO_PROMPT")
  padamount=0
  (( padamount = ${COLUMNS} - ${promptwidth} ))
  local PAD=""
  for i in {1..$padamount}; do
      PAD="${PAD} "
  done
  echo -n "${LEFT} ${OPTIONALS}${PAD}${RIGHT}\n$symbols➤"
}

PROMPT='$(build_prompt) '
RPROMPT=''
