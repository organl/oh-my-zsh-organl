#!/bin/zsh

sun=☉
earth=♁
cloud=☁
atom=⚛
neptune=♆
airplane=✈︎
heart=♥︎
diamonds=❖
yinyang=☯
flag=⚐
node=☊

case `hostname -s | tr '[:upper:]' '[:lower:]'` in
    "f45c89a3afa7") 
        location=$airplane
        ;;
    "a82066391a90")
        location=$atom
        ;;
    "dev-dsk-przasnys-m4xl-i-34f5ceef") 
        location=$cloud
        ;;
    "newman")
        location=$diamonds
        ;;
    "motion")
        location=$yinyang
        ;;
    "capture")
        location=$flag
        ;;
    "kramer") 
        location=$earth
        ;;
    "hackintosh") 
        location=$neptune
        ;;
    "soupnazi") 
        location=$heart
        ;;
    "SEA-9901942132")
        location=$node
	;;
    *)
        location="¿"
        ;;
esac

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
