#!/bin/bash

# List of required tools
REQUIRED_TOOLS=("curl" "git" "wget" "fd-find" "ripgrep" "fzf"
  "neovim" "luarocks" "tmux" "bat" "ghosty" "lazygit" "yazi"
  "zsh" "openssh")

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

zsh_install() {
  # install zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  # setup style
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
  # setup auto suggestion
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}

load_configs() {
  # Generate a new SSH key
  ssh-keygen -o -t rsa -C "alireza2000jadidi@gmail.com"

  echo "Grab the key below and add it to your GitHub SSH keys:"
  cat ~/.ssh/id_rsa.pub
  echo
  read -p "Press Enter when you're ready to continue..."

  # Clone the private GitHub repository using SSH
  git clone git@github.com:REAPERali00/myConfigs.git "$HOME/myConfigs"

  # Move dotfiles (.*) to home, excluding special entries
  find "$HOME/myConfigs" -maxdepth 1 -type f -name ".*" ! -name "." ! -name ".." ! -name ".git" -exec mv -v {} "$HOME/" \;

  # Move folders inside myConfigs to ~/.config/
  for d in "$HOME/myConfigs"/*/; do
    [ -d "$d" ] && mv -v "$d" "$HOME/.config/"
  done

  # Optional cleanup
  rm -rf "$HOME/myConfigs"
}

# Detect package manager
detect_package_manager() {
  if command_exists apt; then
    echo "apt"
  elif command_exists dnf; then
    echo "dnf"
  elif command_exists yum; then
    echo "yum"
  elif command_exists pacman; then
    echo "pacman"
  elif command_exists brew; then
    echo "brew"
  else
    echo "unknown"
  fi
}

# Check version of package manager
check_version() {
  local pkg_mgr=$1
  echo "Package Manager: $pkg_mgr"

  case "$pkg_mgr" in
  apt) apt --version | head -n1 ;;
  dnf) dnf --version ;;
  yum) yum --version | head -n1 ;;
  pacman) pacman -V ;;
  brew) brew --version | head -n1 ;;
  *) echo "Cannot detect version. Unsupported package manager." ;;
  esac
}

# Install required tools
install_tools() {
  local pkg_mgr=$1
  for tool in "${REQUIRED_TOOLS[@]}"; do
    if command_exists "$tool"; then
      echo "$tool is already installed."
    else
      echo "Installing $tool..."
      case "$pkg_mgr" in
      apt) sudo apt update && sudo apt install -y "$tool" ;;
      dnf) sudo dnf install -y "$tool" ;;
      yum) sudo yum install -y "$tool" ;;
      pacman) sudo pacman -Sy --noconfirm "$tool" ;;
      brew) brew install "$tool" ;;
      *) echo "Unsupported package manager." ;;
      esac
    fi
  done
}

# Run the script
main() {
  pkg_mgr=$(detect_package_manager)

  if [[ "$pkg_mgr" == "unknown" ]]; then
    echo "❌ Error: No supported package manager found."
    exit 1
  fi

  check_version "$pkg_mgr"
  install_tools "$pkg_mgr"
  zsh_install
  load_configs
}

main
