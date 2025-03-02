#!/bin/bash
# Set bash "strict mode"
set -euo pipefail
IFS=$'\n\t'

BASE=$(dirname "$0")

link ()
{
    local file="$BASE/$1"

    if [ "$#" -eq 1 ]; then
        # If the destination is empty, then we will link it
        # to ~/.original_filename
        dest="$HOME/.$(basename "$file")"
    else
        dest="$2"
    fi

    if [ -f "$dest" ]; then
        echo "[W] Making backup for ${dest}"
        mv "$dest" "${dest}.back"
    fi

    echo "[I] Creating symlink $dest -> $file"
    ln -nfs "$file" "$dest"
}


# Symlink the appropriate .config files
link "zshrc"
link "p10k.zsh"

link "ideavimrc"

link "tmux/tmux.conf"
