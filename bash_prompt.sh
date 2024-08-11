#!/usr/bin/bash

# Issue #161: do not load if not an interactive shell
# shellcheck disable=SC2268
[ "x${-##*i}" = "x$-" ] || [ -z "${TERM-}" ] || [ "x${TERM-}" = xdumb ] || [ "x${TERM-}" = xunknown ] && return

if test -n "${BASH_VERSION-}"; then
    # Check for recent enough version of bash.
    if (( ${BASH_VERSINFO[0]:-0} < 3 || ( ${BASH_VERSINFO[0]:-0} == 3 && ${BASH_VERSINFO[1]:-0} < 2 ) )); then
        echo "liquidprompt: Bash version $BASH_VERSION not supported" >&2
        return
    fi

    _LP_OPEN_ESC="\["
    _LP_CLOSE_ESC="\]"

    # Escape the given strings
    # Must be used for all strings injected in PS1 that may comes from remote sources,
    # like $PWD, VCS branch names...
    __lp_escape() {
        ret="${1//\\/\\\\}"
        if shopt -q promptvars ; then
            ret="${ret//\$/\\\$}"
            ret="${ret//\`/\\\`}"
        fi
    }

    __lp_strip_escapes() {
        ret="$1"
        while [[ "$ret" == *"$_LP_OPEN_ESC"* ]]; do
            ret="${ret%%"$_LP_OPEN_ESC"*}${ret#*"$_LP_CLOSE_ESC"}"
        done

        ret="${ret//\\\\/\\}"
        if shopt -q promptvars ; then
            ret="${ret//\\\$/\$}"
            ret="${ret//\\\`/\`}"
        fi
    }
fi

# Load the user configuration and setup defaults.
# shellcheck disable=SC2034
__lp_source_config() {

    local af_color='' ab_color=''

    # Colors: variables are local so they will have a value only
    # during config loading and will not conflict with other values
    # with the same names defined by the user outside the config.

    # NO_COL is special: it will be used at runtime, not just during config loading
    NO_COL="${_LP_OPEN_ESC}${_LP_TI_RESET-}${_LP_CLOSE_ESC}"

    LP_COLOR_PATH_BG=7 # white
    __lp_background_color $LP_COLOR_PATH_BG
    LP_COLOR_PATH="${_LP_OPEN_ESC}${_LP_TI_BOLD-}${ab_color}${_LP_CLOSE_ESC}"
    
    LP_COLOR_USER_SESSION_BG=4 # blue
    __lp_background_color $LP_COLOR_USER_SESSION_BG
    __lp_foreground_color 7 # white
    LP_COLOR_USER_SESSION="${_LP_OPEN_ESC}${af_color}${ab_color}${_LP_CLOSE_ESC}"
    LP_COLOR_ROOT_SESSION_BG=1 # red
    __lp_background_color $LP_COLOR_ROOT_SESSION_BG 
    __lp_foreground_color 7 # white
    LP_COLOR_ROOT_SESSION="${_LP_OPEN_ESC}${af_color}${ab_color}${_LP_CLOSE_ESC}"
}

__lp_separator_color() {
    local block_bg=$1
    local next_bg=${2:-}

    local af_color='' ab_color=''
    __lp_foreground_color $block_bg
    if [[ -n $next_bg ]]; then
        __lp_background_color $next_bg
        _lp_separator_color="${_LP_OPEN_ESC}${af_color}${ab_color}${_LP_CLOSE_ESC}"
    else
        _lp_separator_color="${_LP_OPEN_ESC}${af_color}${_LP_CLOSE_ESC}"
    fi
}

__lp_set_prompt() {
    _lp_session
    _lp_path
    PS1=""
    if [[ -n "${LP_SESSION}" ]]; then
        if (( EUID == 0 )); then
            __lp_separator_color $LP_COLOR_ROOT_SESSION_BG $LP_COLOR_PATH_BG
            PS1+="${LP_COLOR_ROOT_SESSION}${LP_SESSION}${NO_COL}${_lp_separator_color}▌${NO_COL}"
        else
            __lp_separator_color $LP_COLOR_USER_SESSION_BG $LP_COLOR_PATH_BG
            PS1+="${LP_COLOR_USER_SESSION}${LP_SESSION}${NO_COL}${_lp_separator_color}▌${NO_COL}"
        fi
    fi
    __lp_separator_color $LP_COLOR_PATH_BG
    PS1+="${LP_COLOR_PATH}${LP_PATH}${NO_COL}${_lp_separator_color}▌${NO_COL}"
}

lp_activate() {
    # TermInfo feature detection
    _lp_af_colors=() _lp_ab_colors=()

    __lp_foreground_color() { return 2 ; }
    __lp_background_color() { return 2 ; }
    
    if ! command -v tput >/dev/null; then
        echo "liquidprompt: 'tput' not available; will not be able to format terminal" >&2
        LP_ENABLE_COLOR=0
    else
        _LP_TI_RESET="$( { tput sgr0 || tput me ; } 2>/dev/null )"
        _LP_TI_BOLD="$( { tput bold || tput md ; } 2>/dev/null )"
        _LP_TI_UNDERLINE="$( { tput smul || tput us ; } 2>/dev/null )"
        _LP_TI_COLORS="$( tput colors 2>/dev/null )"
        _LP_TI_COLORS=${_LP_TI_COLORS:-8}

        if tput setaf 0 >/dev/null 2>&1; then
            __lp_foreground_color() { af_color="${_lp_af_colors[$1+1]:=$(tput setaf "$1")}"; }
        elif tput AF 0 >/dev/null 2>&1; then
            # FreeBSD
            __lp_foreground_color() { af_color="${_lp_af_colors[$1+1]:=$(tput AF "$1")}"; }
        elif tput AF 0 0 0 >/dev/null 2>&1; then
            # OpenBSD
            __lp_foreground_color() { af_color="${_lp_af_colors[$1+1]:=$(tput AF "$1" 0 0)}"; }
        else
            echo "liquidprompt: terminal '${TERM-}' does not support foreground colors" >&2
        fi
        if tput setab 0 >/dev/null 2>&1; then
            __lp_background_color() { ab_color="${_lp_ab_colors[$1+1]:=$(tput setab "$1")}"; }
        elif tput AB 0 >/dev/null 2>&1; then
            # FreeBSD
            __lp_background_color() { ab_color="${_lp_ab_colors[$1+1]:=$(tput AB "$1")}"; }
        elif tput AB 0 0 0 >/dev/null 2>&1; then
            # OpenBSD
            __lp_background_color() { ab_color="${_lp_ab_colors[$1+1]:=$(tput AB "$1" 0 0)}"; }
        else
            echo "liquidprompt: terminal '${TERM-}' does not support background colors" >&2
        fi
    fi
    
    __lp_source_config
    __lp_set_prompt
}

# Return the username element
_lp_username() {
    if (( EUID == 0 )) || [[ "${USER-}" != "$(logname 2>/dev/null || printf '%s' "${LOGNAME-}")" ]]; then
        # user is root or not login user
        ret="\u"
    else
        ret=""
    fi
}

# Return the hostname element
_lp_hostname() {
    if [[ "x${PBS_ENVIRONMENT}" == "xPBS_INTERACTIVE" ]]; then
        ret="\h PBS"
    elif [[ -n "${SLURM_JOB_ID}" || -n "${SLURM_PTY_PORT}" ]]; then
        ret="\h Slurm"
    elif [[ -n "${SSH_CLIENT-}${SSH2_CLIENT-}${SSH_TTY-}" ]]; then
        ret="\h"
    elif [[ -n ${REMOTEHOST-} ]]; then
        ret="\h TEL"
    else
        ret=""
    fi
}

_lp_session() {
    # concat usename and hostname elements with space if both are non-empty
    _lp_username
    LP_SESSION=$ret
    _lp_hostname
    if [[ -n $LP_SESSION && -n $ret ]]; then
        LP_SESSION="${LP_SESSION} ${ret}"
    else
        LP_SESSION="${LP_SESSION}${ret}"
    fi
}

_lp_agnoster_short_path() {
    local LP_tilde="~"
    local LP_PWD='$(echo -n "${PWD/#$HOME/$LP_tilde}" | awk -F "/" '"'"'{ if (length($0) > 12) { if (NF>3) print $1 "/…/" $(NF-1) "/" $NF; else if (NF==3) print $1 "/…/" $NF; else print $0; } else print $0;}'"'"')'

    local ret
    __lp_escape $(eval "echo ${LP_PWD}")
    LP_PWD="$ret"
    echo "$LP_PWD"
}

_lp_path() {
    LP_PATH='$(eval "_lp_agnoster_short_path")' 
}
