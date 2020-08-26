#!/bin/zsh

# If a script exists here, use it to deduce hostname symbol
[ -f ~/.zsh/bin/hostname-symbol ] && location=`~/.zsh/bin/hostname-symbol`

# location will be zero length if script did not work above, use the following code as example
if [ -z "$location" ]; then
  sun=☉
  earth=♁
  ground=⏚
  cloud=☁
  unknown="¿"

  case `hostname -s | tr '[:upper:]' '[:lower:]'` in
      "hostname-1")
          location=$sun
          ;;
      "hostname-2")
          location=$earth
          ;;
      "hostname-3") 
          location=$ground
          ;;
      "hostname-4")
          location=$cloud
          ;;
      *)
          location=$unknown
          ;;
  esac
fi

function get_pwd() {
  echo "${PWD/$HOME/~}"
}

function get_time() {
  echo `date -u +"%Y-%m-%dT%H:%M:%SZ"`
}

ZSH_THEME_GIT_PROMPT_PREFIX="[git:"
ZSH_THEME_GIT_PROMPT_SUFFIX="]$reset_color"
ZSH_THEME_GIT_PROMPT_DIRTY="$fg[red]+"
ZSH_THEME_GIT_PROMPT_CLEAN="$fg[green]"

function git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_PREFIX$(current_branch)$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

function put_spacing() {
  local git=$(git_prompt_info)
  if [ ${#git} != 0 ]; then
      ((git=${#git} - 10))
  else
      git=0
  fi

  local termwidth
  (( termwidth = ${COLUMNS} - 1 - 1 - ${#$(get_pwd)} - ${git} - 1 - ${#$(get_time)} ))

  local spacing=""
  for i in {1..$termwidth}; do
      spacing="${spacing} "
  done
  echo $spacing
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
  echo "$fg[cyan]$location $fg[yellow]$(get_pwd)$(put_spacing)$(git_prompt_info) $fg[cyan]$(get_time)
$reset_color$symbols$reset_color➤"
}

PROMPT='$(build_prompt) '
