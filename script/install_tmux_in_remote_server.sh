#!/bin/bash

#------------------------------------------------------------------------------#
#                          Installing tmux preferences                         #
#------------------------------------------------------------------------------#

# For downloading this file and executing it:
# curl -L https://raw.githubusercontent.com/roeeyn/dotfiles/master/script/install_tmux_in_remote_server.sh | sh

# Adding the plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Adding the tmux config
curl -fLo ~/.tmux.conf https://raw.githubusercontent.com/roeeyn/dotfiles/master/dot/.tmux.conf

