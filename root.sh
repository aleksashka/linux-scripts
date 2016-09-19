#!/bin/env bash
# Use the following command to add lines to remote bashrc
# ssh username@hostname "bash" < bash-color.sh
# or just run commands below to add to local bashrc
#
# Source https://habrahabr.ru/post/269967/ (color codes are there as well)

#                     +-- Do not expand variable definitions to actual values
#                     |
cat >> /etc/bashrc << \EOF

# Set root to red
root_cursor_color='#FF0000'
root_prompt_color='196'

case "$TERM" in
xterm*|rxvt*|vte*)
	PS1='\[\e[38;5;'$prompt_color'm\][ \t ] [ \u@\h ] [ $PWD ]\n'
	[[ $UID == 0 ]] && { prompt_color=$root_prompt_color;cursor_color=$root_cursor_color; }
	PS1="$PS1"'\[\e[m\e]12;'$cursor_color'\a\e[38;5;'$prompt_color'm\]\$ \[\e[m\]'
	;;
*)
	PS1='\t j\j \u@\h:\w\n\$ '
	;;
esac
EOF
cat >> /etc/vimrc << \EOF
"########################################
"# Automatically added by script
set background=dark
set tabstop=4
"########################################
EOF
