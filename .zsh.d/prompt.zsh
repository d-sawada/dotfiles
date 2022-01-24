RPROMPT=""

autoload -Uz vcs_info
autoload -Uz add-zsh-hook
autoload -Uz is-at-least
autoload -Uz colors; colors

! is-at-least 4.3.11 && { echo 'require zsh >= 4.3.11'; exit 1 }

zstyle ':vcs_info:*' enable git # Gitしか勝たん
zstyle ':vcs_info:git:*' formats '%F{white} - [%F{cyan}%b%F{white}] %m%f'
zstyle ':vcs_info:git:*' actionformats '%F{white} - [%F{red}%b | %a%F{white}] %m%f'
zstyle ':vcs_info:git+set-message:*' \
  hooks \
  git-hook-begin \
  git-push-status \
  git-status \
  git-stash-count

function +vi-git-hook-begin() {
  if test $(git rev-parse --is-inside-work-tree 2> /dev/null) != 'true'; then
    return 1
  else
    hook_com[misc]="" # NOTE: rebaseメッセージとかいらない
    return 0
  fi
}

function +vi-git-push-status() {
  ! git config remote.origin.url >/dev/null 2>&1 && return 0
  ! git rev-parse --verify origin/${hook_com[branch]} 1>/dev/null 2>&1 && return 0

  local remotes
  remotes=$(git rev-list ${hook_com[branch]}..origin/${hook_com[branch]} 2>/dev/null \
    | wc -l \
    | tr -d ' ')
  test "$remotes" -gt 0 && hook_com[misc]+="%F{magenta}￬${remotes}"

  local locals
  locals=$(git rev-list origin/${hook_com[branch]}..${hook_com[branch]} 2>/dev/null \
    | wc -l \
    | tr -d ' ')
  test "$locals" -gt 0 && hook_com[misc]+="%F{green}￪${locals}"

  test "$remotes" -gt 0 -a "$locals" -gt 0 && hook_com[misc]="%F{yellow}⚠ ${hook_com[misc]}"
  return 0
}

function +vi-git-status() {
  local git_status
  git_status=$(git status -s 2>/dev/null)

  local added
  added=$(echo "$git_status" | grep -e '^\w ' 2>/dev/null | wc -l | tr -d ' ')
  test "$added" -gt 0 && hook_com[misc]+="%F{green}+${added}"

  local modified
  modified=$(echo "$git_status" | grep -e '^ \w' 2>/dev/null | wc -l | tr -d ' ')
  test "$modified" -gt 0 && hook_com[misc]+="%F{red}-${modified}"

  local unstaged
  unstaged=$(echo "$git_status" | grep -e '^??' 2>/dev/null | wc -l | tr -d ' ')
  test "$unstaged" -gt 0 && hook_com[misc]+="%F{red}?${unstaged}"

  return 0
}

function +vi-git-stash-count() {
  local stash
  stash=$(git stash list 2>/dev/null | wc -l | tr -d ' ')

  test "$stash" -gt 0 && hook_com[misc]+="%F{cyan}:${stash}"
  return 0
}

function _update_prompt_with_vcs_info() {
  LANG=en_US.UTF-8 vcs_info

  if [[ -z ${vcs_info_msg_0_} ]]; then
    PROMPT=""
  else
    PROMPT="%{${fg[yellow]}%}-------------------------------------------------------------
%{${reset_color}%}[%m %{${fg[cyan]}%}%n %{${fg[green]}%}%~%{${reset_color}%}]%{${vcs_info_msg_0_}%}
%{${fg[red]}%}%% %{${reset_color}%}"
  fi
}

add-zsh-hook precmd _update_prompt_with_vcs_info
