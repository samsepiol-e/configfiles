#!/bin/bash
#Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
##iterm2
brew install --cask iterm2
#git
brew install git
#python, cmake etc...
brew install cmake python mono go nodejs
#vim
brew install vim
#OhMyZsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
#powerlevel10k
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
if cat ~./zshrc | grep ZSH_THEME | grep -v "#": then
  echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' > ~/.zshrc_temp
  cat ~/.zshrc >> ~/.zshrc_temp
  mv ~/.zshrc_temp ~/.zshrc
else
  sed -i '' -E 's/(^ZSH_THEME=).+$/\1"powerlevel10k\/powerlevel10k"/' ~/.zshrc
fi
#zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
sed -i '' -E 's/(^plugins=\().+$/\1zsh-autosuggestions/' ~/.zshrc
