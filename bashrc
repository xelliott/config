if [ -f /etc/bashrc ]; then                                                    
    source /etc/bashrc
fi

[[ $- != *i* ]] && return

#-------------------------------------------------------------
# Greeting, motd etc. ...
#-------------------------------------------------------------

# Color definitions (taken from Color Bash Prompt HowTo).

# Normal Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

NC="\e[m"               # Color Reset


ALERT=${BWhite}${On_Red} # Bold White on red background

#-------------------------------------------------------------
# Shell Prompt - for many examples, see:
#       http://www.debian-administration.org/articles/205
#       http://www.askapache.com/linux/bash-power-prompt.html
#       http://tldp.org/HOWTO/Bash-Prompt-HOWTO
#       https://github.com/nojhan/liquidprompt
#-------------------------------------------------------------
# Current Format: localhost [USER@HOST PWD] >
#                 SSH [HOST PWD] >
# USER:
#    Cyan      == normal user
#    Orange    == SU to user
#    Red       == root
# HOST:
#    Cyan      == local session
#    Green     == secured remote connection (via ssh)
#    Red       == unsecured remote connection
#

PS1=""

# Test connection type:
if [ -n "${SSH_CONNECTION}" ]; then
    PS1HOST=${PS1}"\[${Green}\]\h\[${NC}\]" # Connected via SSH       
elif [[ "${DISPLAY%%:0*}" != "" ]]; then
    PS1HOST=${PS1}"\[${ALERT}\]\h\[${NC}\]" # Connected on remote machine, not via ssh (bad).
else
    PS1HOST=""    # Connected on local machine.
fi

# Test user type:
if [[ ${EUID} == 0 ]]; then
    PS1USER="\[${Red}\]\u\[${NC}\]"    # User is root.
else
    #PS1USER="\[${BCyan}\]\u\[${NC}\]"  # User is normal.
    PS1USER=""
fi

if [[ "x${PS1HOST}" == "x" || "x${PS1USER}" == "x" ]]; then
    PS1=${PS1}${PS1HOST}${PS1USER}
else
    PS1=${PS1}${PS1HOST}"@"${PS1USER}
fi
if [ -n ${PS1} ]; then
    PS1=${PS1}" "
fi
PS1=${PS1}"\[${BBlue}\]\W \$([[ \$? != 0 ]] && echo \"\[${BRed}\]:(\[${BBlue}\] \")\\$\[${NC}\] "
PS2="> "
PS3="> "
PS4="+ "

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

# Enviroment variables
# Some applications read the EDITOR variable to determine your favourite text
# editor. So uncomment the line below and enter the editor of your choice :-)
# export EDITOR=/usr/bin/vim
export EDITOR=vim

if [ -f $HOME/.bash_local ]; then                                                    
    source $HOME/.bash_local
fi

