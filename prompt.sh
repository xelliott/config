#!/usr/bin/bash

# Issue #161: do not load if not an interactive shell
# shellcheck disable=SC2268
[ "x${-##*i}" = "x$-" ] || [ -z "${TERM-}" ] || [ "x${TERM-}" = xdumb ] || [ "x${TERM-}" = xunknown ] && return

if test -n "${BASH_VERSION-}"; then
    # Check for recent enough version of bash.
    if ((${BASH_VERSINFO[0]:-0} < 3 || (${BASH_VERSINFO[0]:-0} == 3 && ${BASH_VERSINFO[1]:-0} < 2))); then
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
        if shopt -q promptvars; then
            ret="${ret//\$/\\\$}"
            ret="${ret//\`/\\\`}"
        fi
    }
fi

__lp_segment_separator() {
    local left_bg=$1
    local right_bg=$2

    local af_color='' ab_color=''
    local separator_style=''
    if [[ -z "${left_bg}" && -z "${right_bg}" ]]; then
        ret="${_LP_STYLE_RESET} ${_LP_STYLE_RESET}"
    elif [[ -n "${left_bg}" && -n "${right_bg}" ]]; then
        __lp_background_color $right_bg
        __lp_foreground_color $left_bg
        separator_style="${_LP_OPEN_ESC}${af_color}${ab_color}${_LP_CLOSE_ESC}"
        ret="${_LP_STYLE_RESET}${separator_style}▌${_LP_STYLE_RESET}"
    elif [[ -z "${left_bg}" ]]; then
        __lp_foreground_color $right_bg
        separator_style="${_LP_OPEN_ESC}${af_color}${_LP_CLOSE_ESC}"
        ret="${_LP_STYLE_RESET}${separator_style}▐${_LP_STYLE_RESET}"
    else
        __lp_foreground_color $left_bg
        separator_style="${_LP_OPEN_ESC}${af_color}${_LP_CLOSE_ESC}"
        ret="${_LP_STYLE_RESET}${separator_style}▌${_LP_STYLE_RESET}"
    fi
}

__lp_set_prompt() {
    _LP_STYLE_RESET="${_LP_OPEN_ESC}${_LP_TI_RESET-}${_LP_CLOSE_ESC}"

    local LP_COLOR_PATH_BG=7         # white
    local LP_COLOR_USER_SESSION_BG=4 # blue
    local LP_COLOR_ROOT_SESSION_BG=1 # red
    local LP_COLOR_SESSION_FG=7      # white

    PS1=""

    # Colors and styles: variables are local so they will have a value only
    # during config loading and will not conflict with other values
    # with the same names defined by the user outside the config.
    local af_color='' ab_color=''
    local lp_last_segment_bg=""
    local lp_active_segment_bg="" lp_active_segment_fg=""
    local lp_separator_color=''
    local active_style=''
    local ret=''

    # Session segment
    _lp_session # Call the function to get the PS1 of this segment
    if [[ -n "${LP_SESSION}" ]]; then
        if ((EUID == 0)); then
            lp_active_segment_bg=$LP_COLOR_ROOT_SESSION_BG
        else
            lp_active_segment_bg=$LP_COLOR_USER_SESSION_BG
        fi
        lp_active_segment_fg=$LP_COLOR_SESSION_FG

        __lp_segment_separator "$lp_last_segment_bg" "$lp_active_segment_bg"
        PS1+="$ret"

        __lp_background_color $lp_active_segment_bg
        __lp_foreground_color $lp_active_segment_fg
        active_style="${_LP_OPEN_ESC}${af_color}${ab_color}${_LP_CLOSE_ESC}"
        PS1+="${active_style}${LP_SESSION}"
    fi
    lp_last_segment_bg=$lp_active_segment_bg
    unset LP_SESSION

    # Path segment
    lp_active_segment_bg=$LP_COLOR_PATH_BG
    __lp_segment_separator "$lp_last_segment_bg" "$lp_active_segment_bg"
    PS1+="$ret"

    __lp_background_color $lp_active_segment_bg
    active_style="${_LP_OPEN_ESC}${_LP_TI_BOLD-}${ab_color}${_LP_CLOSE_ESC}"
    # PS1+="${active_style}${LP_PATH}"
    PS1+="${active_style}"'$(_lp_eval_path)'

    # Ending separator
    __lp_segment_separator "$lp_active_segment_bg" ""
    PS1+="$ret"
}

lp_activate() {
    # TermInfo feature detection
    _lp_af_colors=() _lp_ab_colors=()

    __lp_foreground_color() { return 2; }
    __lp_background_color() { return 2; }

    if ! command -v tput >/dev/null; then
        echo "liquidprompt: 'tput' not available; will not be able to format terminal" >&2
        LP_ENABLE_COLOR=0
    else
        _LP_TI_RESET="$({ tput sgr0 || tput me; } 2>/dev/null)"
        _LP_TI_BOLD="$({ tput bold || tput md; } 2>/dev/null)"
        _LP_TI_UNDERLINE="$({ tput smul || tput us; } 2>/dev/null)"
        _LP_TI_COLORS="$(tput colors 2>/dev/null)"
        _LP_TI_COLORS=${_LP_TI_COLORS:-8}

        if tput setaf 0 >/dev/null 2>&1; then
            __lp_foreground_color() { af_color="${_lp_af_colors[$1 + 1]:=$(tput setaf "$1")}"; }
        elif tput AF 0 >/dev/null 2>&1; then
            # FreeBSD
            __lp_foreground_color() { af_color="${_lp_af_colors[$1 + 1]:=$(tput AF "$1")}"; }
        elif tput AF 0 0 0 >/dev/null 2>&1; then
            # OpenBSD
            __lp_foreground_color() { af_color="${_lp_af_colors[$1 + 1]:=$(tput AF "$1" 0 0)}"; }
        else
            echo "liquidprompt: terminal '${TERM-}' does not support foreground colors" >&2
        fi
        if tput setab 0 >/dev/null 2>&1; then
            __lp_background_color() { ab_color="${_lp_ab_colors[$1 + 1]:=$(tput setab "$1")}"; }
        elif tput AB 0 >/dev/null 2>&1; then
            # FreeBSD
            __lp_background_color() { ab_color="${_lp_ab_colors[$1 + 1]:=$(tput AB "$1")}"; }
        elif tput AB 0 0 0 >/dev/null 2>&1; then
            # OpenBSD
            __lp_background_color() { ab_color="${_lp_ab_colors[$1 + 1]:=$(tput AB "$1" 0 0)}"; }
        else
            echo "liquidprompt: terminal '${TERM-}' does not support background colors" >&2
        fi
    fi

    __lp_set_prompt
}

_lp_session() {
    local ret=''

    # username element
    if ((EUID == 0)) || [[ "${USER-}" != "$(logname 2>/dev/null || printf '%s' "${LOGNAME-}")" ]]; then
        # user is root or not login user
        ret="\u"
    else
        ret=""
    fi
    LP_SESSION=$ret

    # hostname element
    if [[ "x${PBS_ENVIRONMENT}" == "xPBS_INTERACTIVE" ]]; then
        ret="\h│PBS"
    elif [[ -n "${SLURM_JOB_ID}" || -n "${SLURM_PTY_PORT}" ]]; then
        ret="\h│Slurm"
    elif [[ -n "${SSH_CLIENT-}${SSH2_CLIENT-}${SSH_TTY-}" ]]; then
        ret="\h"
    elif [[ -n ${REMOTEHOST-} ]]; then
        ret="\h│TEL"
    else
        ret=""
    fi

    # concat usename and hostname elements with space if both are non-empty
    if [[ -n $LP_SESSION && -n $ret ]]; then
        LP_SESSION="${LP_SESSION}@{ret}"
    else
        LP_SESSION="${LP_SESSION}${ret}"
    fi
}

_lp_eval_path() {
    echo $(${CDIR}/tools/prompt_path)
}

lp_activate
unset -f __lp_escape __lp_segment_separator __lp_set_prompt lp_activate _lp_session
unset _LP_OPEN_ESC _LP_CLOSE_ESC _LP_TI_RESET _LP_TI_BOLD _LP_TI_UNDERLINE _LP_TI_COLORS
