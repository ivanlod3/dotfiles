#!/bin/bash

# Configuración de la instalación
DOTFILES_REPO="https://github.com/ivanlod3/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

# Función para clonar el repositorio de dotfiles
clone_dotfiles() {
  if [ ! -d "$DOTFILES_DIR" ]; then
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi
}

# Función para crear enlaces simbólicos a los archivos de configuración
create_symlinks() {
  # ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
  # ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
  # ln -sf "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
}

# Instala los plugins y el tema de Oh My Zsh
#
# 1. Instala los plugins de Oh My Zsh
# 2. Instala el tema "powerlevel10k"
# 3. Agrega los plugins y el tema a la configuración de Oh My Zsh
# 4. Recarga la configuración de Oh My Zsh
configure_ohmyzsh() {
  # Instala los plugins de Oh My Zsh
  git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
  git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git $ZSH_CUSTOM/plugins/fast-syntax-highlighting
  git clone https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete
  git clone https://github.com/MichaelAquilina/zsh-you-should-use.git $ZSH_CUSTOM/plugins/you-should-use

  # Instala el tema "powerlevel10k"
  # git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

  # Agrega los plugins y el tema a la configuración de Oh My Zsh
  sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete you-should-use)/g' $HOME/.zshrc
  # sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k/powerlevel10k"/g' $HOME/.zshrc

  # Recarga la configuración de Oh My Zsh
  source $HOME/.zshrc
}

# Ejecuta las funciones en orden
clone_dotfiles
create_symlinks
configure_ohmyzsh