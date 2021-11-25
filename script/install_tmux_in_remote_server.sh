#!/bin/bash

#------------------------------------------------------------------------------#
#                          Installing tmux preferences                         #
#------------------------------------------------------------------------------#

# For downloading this file and executing it:
# curl -L https://raw.githubusercontent.com/roeeyn/dotfiles/master/script/install_tmux_in_remote_server.sh | sh

echo "****************************************"
echo "Validate you have zsh and git installed"
echo "****************************************"

# Adding the plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Adding the tmux config
curl -fLo ~/.tmux.conf https://raw.githubusercontent.com/roeeyn/dotfiles/master/dot/.tmux.conf
 
# Installing oh my zsh
curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

curl -fLo ~/.vimrc https://raw.githubusercontent.com/roeeyn/dotfiles/master/dot/.vimrc

# Installing oh my zsh plugins
git clone https://github.com/zsh-users/zsh-docker.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-docker
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions  
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

rm ~/.zshrc || echo "Skipping deleting original zshrc"

# Add template for .zshrc
curl -fLo ~/.zshrc https://raw.githubusercontent.com/roeeyn/dotfiles/master/dot/.zshrc.template
