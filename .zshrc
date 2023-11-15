autoload -Uz add-zsh-hook

##################################################
# Key binding
##################################################
bindkey -d
bindkey -e
shift-arrow() {
  ((REGION_ACTIVE)) || zle set-mark-command
  zle $1
}
shift-left() shift-arrow backward-char
shift-right() shift-arrow forward-char
shift-up() shift-arrow up-line-or-history
shift-down() shift-arrow down-line-or-history
zle -N shift-left
zle -N shift-right
zle -N shift-up
zle -N shift-down
bindkey $terminfo[kLFT] shift-left
bindkey $terminfo[kRIT] shift-right
bindkey $terminfo[kri] shift-up
bindkey $terminfo[kind] shift-down
bindkey '^h' zaw-history

##################################################
# Key operation
##################################################
# Don't quit zsh by 'Ctrl+D'
setopt ignore_eof

##################################################
# Alias and Function
##################################################
alias zrc='code ~/.zshrc'
alias reload='source ~/.zshrc'
alias sudo='sudo '

export LSCOLORS=gxfxcxdxbxegedabagacad
alias ls='ls -G'
alias la='ls -Ga'
function lspk() {
  lsof -i:"$1" -P | awk '{ print $2 }' | grep -v PID | sort | uniq | xargs kill -9
}

if [ -x "`which colordiff`" ]; then
  alias diff='colordiff'
else
  alias diff='diff'
fi
alias diffa="/usr/bin/diff --new-line-format='+%L' --old-line-format='-%L' --unchanged-line-format=' %L'"

alias gs='git status'
alias gc='git commit --allow-empty -m'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gdn='git diff --name-only'
alias gb='git branch'
alias gw='git switch'
alias gwc='git switch -c'
alias gco='git checkout'
alias gcob='git checkout -b'
alias ga='git add'
alias gau='git add -u'
alias gaa='git add -A'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gcam='git commit --amend -m'
alias gl="git log --graph --pretty=format:'%C(yellow)%cd %C(cyan)%h %C(bold blue)%an %Creset%s %C(red)%d' --abbrev-commit --date=short"
alias gla="gl --all"
alias git-clean="git stash clear && git branch --merged | xargs git branch -D || git fetch --prune"
alias git-prune="git stash clear && git branch | xargs git branch -D || git fetch --prune"
function gdhh() {
  git diff ${1:-@}~1 ${1:-@}
}
function gdnhh() {
  git diff --name-only ${1:-@}~1 ${1:-@}
}
function gri() {
  git rebase -i @~$1
}
function ggw() {
  git grep "$1" | xargs -0 ruby -e 'puts ARGV.join("\n").scan(/\w*'"$1"'\w*/).uniq.sort'
}

alias gbdm="git branch --merged | grep -vE '^\*|master$|develop$' | xargs -I % git branch -d %"
alias ghpe='gh pr edit'

export FZF_DEFAULT_OPTS='--reverse --border'
alias f='fzf'
alias fgl='gl | f --no-sort'

alias be='bundle exec'

alias vi='vim'
alias via='vim +PluginInstall +qall'

alias d='docker'
alias fig='docker compose'
alias docker-prune='docker rm $(docker ps -aq) -f; docker system prune -af; docker volume prune -f'

##################################################
# Option
##################################################
# Histroy
setopt share_history
setopt hist_ignore_all_dups
setopt hist_verify
setopt hist_reduce_blanks
setopt hist_expand
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Pushd
setopt auto_pushd
setopt pushd_ignore_dups

# Others
setopt nobeep

##################################################
# Env
##################################################
export LESS='-R'
export LESSCHARSET=utf-8
export EDITOR="code"

##################################################
# Local Settings
##################################################
ZSHHOME="${HOME}/.zsh.d"
if [ -d $ZSHHOME -a -r $ZSHHOME -a -x $ZSHHOME ]; then
  for i in $ZSHHOME/*; do
    [[ ${i##*/} = *.zsh ]] && [ \( -f $i -o -h $i \) -a -r $i ] && . $i
  done
fi
