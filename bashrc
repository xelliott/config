# This file only contains the customization of bash,
# and should only be sourced by bashrc as needed,
# instead of being used as bashrc directly.

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]]; then
	return
fi

# Check if LC_ALL is set
if [ -n "$LC_ALL" ]; then
    # Check if LC_ALL is not equal to LANG
    if [[ -n "$LC_ALL" && "$LC_ALL" != "$LANG" ]]; then
        echo "Warning: LC_ALL is set but does not match LANG. Setting LC_ALL to LANG."
        export LC_ALL="$LANG"
    fi
fi

CDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

shopt | grep -q '^direxpand\b' && shopt -s direxpand

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

# Disable completion when the input buffer is empty.  i.e. Hitting tab
# and waiting a long time for bash to expand all of $PATH.
shopt -s no_empty_cmd_completion

# Enable history appending instead of overwriting when exiting.  #139609
shopt -s histappend

# Prevent logging of repeated identical commands
export HISTCONTROL=ignoredups
export HISTSIZE=5000

#################
# CONFIGURATION #
#################
########################
# Construct the prompt #
########################
# do source config files
source ${CDIR}/prompt.sh

SHELL_INTEGRATION_SKIP_CWD=1
source ${CDIR}/shell_integration.sh

# __term_resize_shell() {
# 	resize >/dev/null 2>&1
# }
# # on some remote machines, the shell rows and columns are not updated
# # with window resize, so add a resize command on each prompt
# if [[ -n "${LP_HOST-}" || "x${PBS_ENVIRONMENT}" == "xPBS_INTERACTIVE" ]]; then
# 	if type resize >/dev/null 2>&1; then
# 		precmd_functions+=(__term_resize_shell)
# 	fi
# fi

# man page colors
man() {
	env LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;31m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;32m") \
		man "$@"
}

# alias
alias grep='grep --color=auto'
alias ls='ls -h --color=auto'
alias ll='ls -l'
alias la='ls -al'
alias mkdir='mkdir -p'

source ${CDIR}/lscolors.sh
# Enviroment variables
# Some applications read the EDITOR variable to determine your favourite text
# editor. So uncomment the line below and enter the editor of your choice :-)
# export EDITOR=/usr/bin/vim
export EDITOR=vim
export LESS='-i -R'

# if [ -f $HOME/.bash_local ]; then
#     source $HOME/.bash_local
# fi
