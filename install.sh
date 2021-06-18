#!/bin/zsh

# Define a function which rename a `target` file to `target.backup` if the file
# exists and if it's a 'real' file, ie not a symlink
backup() {
  target=$1
  if [ -e "$target" ]; then
    if [ ! -L "$target" ]; then
      mv "$target" "$target.backup"
      echo "-----> Moved your old $target config file to $target.backup"
    fi
  fi
}

# For all files `$name` in the present folder except `*.sh`, `README.md`, `settings.json`,
# and `config`, backup the target file located at `~/.$name` and symlink `$name` to `~/.$name`
for name in *; do
  if [ ! -d "$name" ]; then
    target="$HOME/.$name"
    if [[ ! "$name" =~ '\.sh$' ]] && [ "$name" != 'README.md' ] && [[ "$name" != 'vscode_settings.json' ]] && [[ "$name" != 'config' ]]; then
      backup $target
      if [ ! -e "$target" ]; then
        echo "-----> Symlinking your new $target"
        ln -s "$PWD/$name" "$target"
      fi
    fi
  fi
done

# Install zsh-syntax-highlighting plugin
CURRENT_DIR=`pwd`
ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$ZSH_PLUGINS_DIR" && cd "$ZSH_PLUGINS_DIR"
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
  echo "-----> Installing zsh plugin 'zsh-syntax-highlighting'..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting
fi
cd "$CURRENT_DIR"

# Setup git text editor to use VS Code
git config --global core.editor "code"

# Symlink VS Code settings to the present `settings.json` file
if [[ ! `uname` =~ "darwin" ]]; then
  CODE_PATH=~/.config/Code/User
else
  CODE_PATH=~/Library/Application\ Support/Code/User
fi
backup "$CODE_PATH/settings.json"
ln -sf $PWD/settings.json $CODE_PATH/settings.json

# Symlink SSH config file to the present `config` file for macOS and add SSH
# passphrase to the keychain
if [[ `uname` =~ "darwin" ]]; then
  backup ~/.ssh/config
  ln -sf $PWD/config ~/.ssh/config
  ssh-add -K ~/.ssh/id_25519
fi

# Refresh the current terminal with the newly installed configuration
zsh ~/.zshrc

echo "👌 Carry on with git setup!"
