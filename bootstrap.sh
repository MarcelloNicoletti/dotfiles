#!/usr/bin/env bash

DIR=$(dirname "$0")
FULL_RELATIVE_PATH=$(cd "$DIR" && pwd)

DEFINITION_FILE="$FULL_RELATIVE_PATH/definitions.sh"
if [[ ! -e $DEFINITION_FILE ]]; then
    echo "Definitions file missing"
    exit 1
fi

source "$DEFINITION_FILE"

if [[ $1 = "-h" || $1 = "--help" ]]; then
    cat <<EOF
Bootstraps a new device's dotfiles creating a symlink in $HOME
for each file inside $dotfiles_dir
while creating backups of old dotfiles in $old_dotfiles_dir.

Usage: $(basename "$0") [-h|--help]
-h or --help: Show this message and exit
EOF
    exit 0
fi

echo "Creating $old_dotfiles_dir for backup of any existing dotfiles in ~"
mkdir -p "$old_dotfiles_dir"
echo "...done"

echo "Changing to the $dotfiles_dir directory"
cd "$dotfiles_dir" || exit 1
echo "...done"

echo "Initializing git submodules if needed"
git submodule update --init --recursive
echo "...done"

echo "Creating symlinks in $HOME"
while read -r -d '' file; do
    file=$(basename "$file")
    if [[ -e $HOME/$file ]]; then
        echo "Moving $file from ~ to $old_dotfiles_dir"
        mv "$HOME/$file" "$old_dotfiles_dir"
    fi
    echo "Creating symlink to $file in home directory."
    ln -s "$dotfiles_dir/$file" "$HOME/$file"
done < <(find . -maxdepth 1 -not \( -name "." -o -name ".DS_Store" \) -print0)
echo "...done"

echo
echo "Don't forget to update the Git GPG variables for this platform."
echo "Both gpg.program and user.signingkey are placeholders."
if which gpg > /dev/null 2>&1; then
    echo " GPG is installed at $(which gpg)"
    echo ' Try: git config --global gpg.program $(which gpg)'
else
    echo " You need to install GPG first"
fi
