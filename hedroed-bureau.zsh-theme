# oh-my-zsh Bureau Theme

### Git [±master ▾●]

ZSH_THEME_GIT_PROMPT_PREFIX="[%{$fg_bold[green]%}±%{$reset_color%}%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}]"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[yellow]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"

bureau_git_branch () {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

bureau_git_status () {
  _INDEX=$(command git status --porcelain -b 2> /dev/null)
  _STATUS=""
  if $(echo "$_INDEX" | grep '^[AMRD]. ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
  fi
  if $(echo "$_INDEX" | grep '^.[MTD] ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
  fi
  if $(echo "$_INDEX" | command grep -E '^\?\? ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
  fi
  if $(echo "$_INDEX" | grep '^UU ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
  fi
  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STASHED"
  fi
  if $(echo "$_INDEX" | grep '^## .*ahead' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
  if $(echo "$_INDEX" | grep '^## .*behind' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi
  if $(echo "$_INDEX" | grep '^## .*diverged' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_DIVERGED"
  fi

  echo $_STATUS
}

bureau_git_prompt () {
  local _branch=$(bureau_git_branch)
  local _status=$(bureau_git_status)
  local _result=""
  if [[ -n $_branch ]]; then
    _result="$ZSH_THEME_GIT_PROMPT_PREFIX$_branch"
    if [[ -n $_status ]]; then
      _result+=" $_status"
    fi
    _result+="$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
  echo $_result
}

### NVM ⬡8.10.10

nvm_prompt_info () {
  if which node 2>/dev/null 1>/dev/null; then
    NODE_VERSION=`node -v 2>/dev/null`
    echo -n "${ZSH_THEME_NVM_PREFIX:="⬡ "}${NODE_VERSION:1}${ZSH_THEME_NVM_SUFFIX:=" "}"
  fi
}

### Python 🐍3.6.3

python_prompt_info () {
  if which python 2>/dev/null 1>/dev/null && [ ! -z `ls | grep \.py$ | head -1` ] ; then
    PYTHON_VERSION=`python -c 'import platform; print(platform.python_version())'`
    echo -n "${ZSH_THEME_PYTHON_PREFIX:="🐍"}${PYTHON_VERSION}${ZSH_THEME_PYTHON_SUFFIX:=" "}"
  fi
}

### Virtualenv [(e) envName]

ZSH_THEME_VIRTUALENV_PREFIX="[(e) "
ZSH_THEME_VIRTUALENV_SUFFIX="] "

### Docker 🐳17.12.0-ce

docker_prompt_info () {
  if which docker 2>/dev/null 1>/dev/null && [[ -f "./Dockerfile" || -f "./docker-compose.yml" ]] ; then
    DOCKER_VERSION=`docker -v | awk '{print substr($3, 0, length($3))}'`
    echo -n "${ZSH_THEME_DOCKER_PREFIX:="🐳"}${DOCKER_VERSION}${ZSH_THEME_DOCKER_SUFFIX:=" "}"
  fi
}

### Bureau

get_space () {
  local STR=$1$2
  local zero='%([BSUbfksu]|([FB]|){*})'
  local LENGTH=${#${(S%%)STR//$~zero/}} 
  local SPACES=""
  (( LENGTH = ${COLUMNS} - $LENGTH - 1))
  
  for i in {0..$LENGTH}
    do
      SPACES+=" "
    done

  echo $SPACES
}

bureau_precmd () {
  local path="%{$fg[magenta]%}%~"
  local username="%{$fg_bold[yellow]%}%n%{$fg_no_bold[yellow]%}@%m%{$reset_color%} "
  local left="$username$path"
  local right="%{$fg[magenta]%}% [%*] %{$reset_color%}"

  local spaces=`get_space $left $right`
  print 
  print -rP "$left$spaces$right"
}

bureau_prompt () {
  RETVAL=$?
  local liberty=""
  
  if [[ $RETVAL -ne 0 ]]; then
    liberty+="%{$fg[red]%}"
  else
    liberty+="%{$fg[white]%}"
  fi
  liberty+="> "
    
  if [[ $EUID -eq 0 ]]; then
    liberty+="%{$fg[yellow]%}# "
  else
    liberty+="%{$fg[green]%}$ "
  fi
  liberty+="%{$reset_color%}"

  echo -n $liberty
}

setopt prompt_subst
PROMPT='$(bureau_prompt)'
RPROMPT='%{$fg_bold[blue]%}$(docker_prompt_info)%{$fg[yellow]%}$(python_prompt_info)%{$fg[green]%}$(nvm_prompt_info)%{$reset_color%}$(virtualenv_prompt_info)$(bureau_git_prompt)'

autoload -U add-zsh-hook
add-zsh-hook precmd bureau_precmd
