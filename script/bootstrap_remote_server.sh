#!/bin/bash

# This script is used to bootstrap a remote server and Ubuntu is the tested OS.
# It may run with another OS but it is not guaranteed to work.

#------------------------------------------------------------------------------#
#                          Installing tmux preferences                         #
#------------------------------------------------------------------------------#

# For downloading this file and executing it:
# curl -L https://raw.githubusercontent.com/roeeyn/dotfiles/master/script/bootstrap_remote_server.sh | sh

echo "**********************************************"
echo "Validate you have zsh, git, and curl installed"
echo "**********************************************"
echo "Giving you ten secs to cancel..."

sleep 10

# Adding the plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Adding the tmux config
curl -fLo ~/.tmux.conf https://raw.githubusercontent.com/roeeyn/dotfiles/master/dot/.tmux.conf

# Installing oh my zsh
curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

# Installing oh my zsh plugins
git clone https://github.com/zsh-users/zsh-docker.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-docker
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

rm ~/.zshrc || echo "Skipping deleting original zshrc"

# Add template for .zshrc
curl -fLo ~/.zshrc https://raw.githubusercontent.com/roeeyn/dotfiles/master/dot/.zshrc.template

# Setting Vim rc
curl -fLo ~/.vimrc https://raw.githubusercontent.com/roeeyn/dotfiles/master/dot/.vimrc

# Default shell to zsh
chsh -s $(which zsh)
echo "You need to log out and get back again to have shell, or just execute zsh"
