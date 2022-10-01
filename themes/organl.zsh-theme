#!/bin/zsh
plugins=(
  git
  docker
)

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

typeset -A moy
# Store decimal value of the starting unicode character
MOY_1=$(echo "obase=10; ibase=16; 32C0" | bc)
# Iterate over months of year
for i in {1..12}; do
  # MOY_V = 1-1+1, 1-1+2, ... , 1-1+12
  MOY_V=$(expr ${MOY_1} - 1 + ${i} )
  # Convert back to base16
  dom[i]=$(echo "obase=16; ibase=10; ${MOY_V}" | bc)
done
typeset -A dom
# Store decimal value of the starting unicode character
DOM_1=$(echo "obase=10; ibase=16; 33E0" | bc)
# Iterate over days of month
for i in {1..31}; do
  # DOM_V = 1-1+1, 1-1+2, ... , 1-1+31
  DOM_V=$(expr ${DOM_1} - 1 + ${i} )
  # Convert back to base16
  dom[i]=$(echo "obase=16; ibase=10; ${DOM_V}" | bc)
done
typeset -A hod
# Store decimal value of the starting unicode character
HOUR_0=$(echo "obase=10; ibase=16; 33E0" | bc)
# Iterate over hours of day
for i in {0..24}; do
  # HOUR_V = 0-1+1, 0-1+2, ... , 0-1+24
  HOUR_V=$(expr ${HOUR_0} - 1 + ${i} )
  # Convert back to base16
  hod[i]=$(echo "obase=16; ibase=10; ${HOUR_V}" | bc)
done

function get_time() {
  M=$moy[$(date -u +"%m")]
  D=$dom[$(date -u +"%d")]
  H=$hod[$(date -u +"%H")]
  date -u +"${M}${D}${H}%M:%SZ"
}

ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=")${C}"
ZSH_THEME_GIT_PROMPT_SEPARATOR="|"
ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[magenta]%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[red]%}%{●%G%}"
ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg[red]%}%{✖%G%}"
ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[blue]%}%{✚%G%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{↓%G%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{↑%G%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{…%G%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}%{✔%G%}"

function git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_PREFIX$(current_branch)$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
build_prompt() {
  RETVAL=$?
  local symbols
  [[ $RETVAL -ne 0 ]] && symbols="$fg[red]✘"
  [[ $UID -eq 0 ]] && symbols="$symbols$fg[yellow]⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols="$symbols$fg[cyan]⚙"
  [ -n "$symbols" ] && symbols="$symbols "
  echo "\
${c}$location${C} \
${iK}$(get_time)${C} \
${y}$(get_pwd)${C} \
$(git_prompt_info) 
$symbols➤"
}

PROMPT='$(build_prompt) '