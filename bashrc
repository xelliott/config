# This file only contains the customization of bash,
# and should only be sourced by bashrc as needed,
# instead of being used as bashrc directly.

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]]; then
	return
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

# LIQUID PROMPT
# In Bash shells, PROMPT_DIRTRIM is the number of directories to keep at the end
# of the displayed path (if "\w" is present in the PS1 var).
# PROMPT_DIRTRIM=3

#################
# CONFIGURATION #
#################
# Setup color variables that can be used by the user.
_lp_source_config() {

	# TermInfo feature detection
	local ti_sgr0="$({ tput sgr0 || tput me; } 2>/dev/null)"
	local ti_bold="$({ tput bold || tput md; } 2>/dev/null)"
	local ti_setaf
	local ti_setab
	if tput setaf 0 >/dev/null 2>&1; then
		ti_setaf() { tput setaf "$1"; }
		ti_setab() { tput setab "$1"; }
	elif tput AF 0 >/dev/null 2>&1; then
		# FreeBSD
		ti_setaf() { tput AF "$1"; }
		ti_setab() { tput AB "$1"; }
	elif tput AF 0 0 0 >/dev/null 2>&1; then
		# OpenBSD
		ti_setaf() { tput AF "$1" 0 0; }
		ti_setab() { tput AB "$1" 0 0; }
	else
		echo "liquidprompt: terminal $TERM not supported" >&2
		ti_setaf() { :; }
		ti_setab() { :; }
	fi

	local BOLD="\[${ti_bold}\]"
	local BLACK="\[$(ti_setaf 0)\]"
	local BOLD_GRAY="\[${ti_bold}$(ti_setaf 0)\]"
	local WHITE="\[$(ti_setaf 7)\]"
	local BOLD_WHITE="\[${ti_bold}$(ti_setaf 7)\]"
	local RED="\[$(ti_setaf 1)\]"
	local BOLD_RED="\[${ti_bold}$(ti_setaf 1)\]"
	local WARN_RED="\[$(
		ti_setaf 0
		ti_setab 1
	)\]"
	local CRIT_RED="\[${ti_bold}$(
		ti_setaf 7
		ti_setab 1
	)\]"
	local DANGER_RED="\[${ti_bold}$(
		ti_setaf 3
		ti_setab 1
	)\]"
	local GREEN="\[$(ti_setaf 2)\]"
	local BOLD_GREEN="\[${ti_bold}$(ti_setaf 2)\]"
	local YELLOW="\[$(ti_setaf 3)\]"
	local BOLD_YELLOW="\[${ti_bold}$(ti_setaf 3)\]"
	local BLUE="\[$(ti_setaf 4)\]"
	local BOLD_BLUE="\[${ti_bold}$(ti_setaf 4)\]"
	local PURPLE="\[$(ti_setaf 5)\]"
	local PINK="\[${ti_bold}$(ti_setaf 5)\]"
	local CYAN="\[$(ti_setaf 6)\]"
	local BOLD_CYAN="\[${ti_bold}$(ti_setaf 6)\]"

	# NO_COL is special: it will be used at runtime, not just during config loading
	NO_COL="\[${ti_sgr0}\]"

	unset ti_sgr0 ti_bold
	unset -f ti_setaf ti_setab

	# Default values (globals)
	LP_COLOR_PATH=${BOLD}
	LP_COLOR_PATH_ROOT=${BOLD_YELLOW}
	LP_COLOR_ERR=${PURPLE}
	LP_COLOR_MARK=${BOLD}
	LP_COLOR_MARK_ROOT=${BOLD_RED}
	LP_COLOR_USER_ALT=${BOLD}
	LP_COLOR_USER_ROOT=${BOLD_YELLOW}
	LP_COLOR_SSH=${BLUE}

	LP_tilde="~"
	LP_PWD='$(echo -n "${PWD/#$HOME/$LP_tilde}" | awk -F "/" '"'"'{ if (length($0) > 12) { if (NF>3) print $1 "/…/" $(NF-1) "/" $NF; else if (NF==3) print $1 "/…/" $NF; else print $0; } else print $0;}'"'"')'

}
# do source config files
_lp_source_config
unset -f _lp_source_config

###############
# Who are we? #
###############
# Yellow for root, bold if the user is not the login one, else no color.
if ((EUID != 0)); then # if user is not root
	# if user is not login user
	if [[ "${USER}" != "$(logname 2>/dev/null || echo "$LOGNAME")" ]]; then
		LP_USER="${LP_COLOR_USER_ALT}\u${NO_COL} "
	else
		LP_USER=""
	fi
else # root!
	LP_USER="${LP_COLOR_USER_ROOT}\u${NO_COL} "
	LP_COLOR_MARK="${LP_COLOR_MARK_ROOT}"
	LP_COLOR_PATH="${LP_COLOR_PATH_ROOT}"
fi

# Detect whether in a PBS or Slurm interactive job
if [[ "x${PBS_ENVIRONMENT}" == "xPBS_INTERACTIVE" ]]; then
	LP_HOST="${LP_COLOR_SSH}PBS \h${NO_COL} "
elif [[ -n "${SLURM_JOB_ID}" || -n "${SLURM_PTY_PORT}" ]]; then
	LP_HOST="${LP_COLOR_SSH}Slurm \h${NO_COL} "
elif [[ -n "${SSH_CLIENT-}${SSH2_CLIENT-}${SSH_TTY-}" ]]; then
	LP_HOST="${LP_COLOR_SSH}\h${NO_COL} "
else
	LP_HOST="" # no hostname if local
fi

if [[ -n "${LP_HOST-}" ]]; then
	SHELL_INTEGRATION_SKIP_CWD=1
fi

########################
# Construct the prompt #
########################
PS1="[${LP_USER}${LP_HOST}${LP_COLOR_PATH}"
PS1+='$(eval "echo ${LP_PWD}")'
PS1+="$NO_COL]"
# add return code and prompt mark
PS1+="\$(err=\$? && [[ \$err != 0 ]] && echo \" $LP_COLOR_ERR\$err$NO_COL \")"
PS1+="${LP_COLOR_MARK}\$${NO_COL} "

source ${CDIR}/shell_integration.sh

__term_resize_shell() {
	resize >/dev/null 2>&1
}
# on some remote machines, the shell rows and columns are not updated
# with window resize, so add a resize command on each prompt
if [[ -n "${LP_HOST-}" || "x${PBS_ENVIRONMENT}" == "xPBS_INTERACTIVE" ]]; then
	if type resize >/dev/null 2>&1; then
		precmd_functions+=(__term_resize_shell)
	fi
fi

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
