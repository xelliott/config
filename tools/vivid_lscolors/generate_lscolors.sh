#!/bin/bash
#
CDIR="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" >/dev/null 2>&1 && pwd  )"
# ls_colors_output=$(vivid -d $CDIR/filetypes.yml generate catppuccin-latte)
ls_colors_output=$(vivid -d $CDIR/filetypes.yml -m 8-bit generate ./ansi.yml)
echo "LS_COLORS=\"$ls_colors_output\"" > ${CDIR}/lscolors.sh
echo "export LS_COLORS" >> ${CDIR}/lscolors.sh
