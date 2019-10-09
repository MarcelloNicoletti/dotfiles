#!/usr/bin/env bash

# System vars
export PATH="$PATH:$HOME/bin"
export EDITOR="$(command -v nano)"

# Bash prompt
RegularUserPart="\\[\\e[36m\\]\\u\\[\\e[0m\\]"
RootUserPart="\\[\\e[31;5m\\]\\u\\[\\e[0m\\]"
Between="\\[\\e[0m\\]@\\[\\e[0m\\]"
HostPart="\\[\\e[32m\\]\\h\\[\\e[0m\\]:"
PathPart="\\[\\e[34;1m\\]\\w\\[\\e[0m\\]"
PROMPT_DIRTRIM=2

case $( id -u ) in
    0 ) export PS1="$RootUserPart$Between$HostPart$PathPart # ";;
    * ) export PS1="$RegularUserPart$Between$HostPart$PathPart $ ";;
esac

# ls colors
case $( uname -s ) in
    "Darwin"|"darwin"|"*BSD*"|"*bsd*" )
        export LSCOLORS=GxFxCxDxBxegedabagaced
        export CLICOLOR=1 # Environment var rather than ls alias
        ;;
    * )
        colors="di=1;36:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:"
        colors+="cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=34;43"
        export LS_COLORS=$colors
        alias ls="ls --color=auto"
        ;;
esac

# Enable bash completion
if [ -f /usr/local/share/bash-completion/bash_completion ]; then
    source /usr/local/share/bash-completion/bash_completion
fi

# Extra files
source "$HOME/.bash_functions"
