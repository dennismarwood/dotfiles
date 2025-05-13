#!/usr/bin/env bash
set -euo pipefail

echo "🛠️  Starting NixOS bootstrap..."

DOTFILES_DIR="$(pwd)"

# Symlink helper
link_or_backup() {
  local target="$1"
  local source="$2"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "⚠️  Found existing file/dir at $target (not a symlink). Backing up..."
    mv "$target" "${target}-bak"
  fi

  if [ ! -L "$target" ]; then
    echo "→ Linking $target → $source"
    ln -s "$source" "$target"
  fi
}

echo "🔗 Linking configs..."

# ~/.config/home-manager
link_or_backup "$HOME/.config/home-manager" "$DOTFILES_DIR/home-manager"

# ~/.config/nixpkgs
link_or_backup "$HOME/.config/nixpkgs" "$DOTFILES_DIR/nixpkgs"

# /etc/nixos/configuration.nix (requires sudo)
if [ -f "$DOTFILES_DIR/configuration.nix" ]; then
  if [ -e "/etc/nixos/configuration.nix" ] && [ ! -L "/etc/nixos/configuration.nix" ]; then
    echo "⚠️  Backing up existing /etc/nixos/configuration.nix to /etc/nixos/configuration.nix-bak"
    sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix-bak
  fi

  if [ ! -L "/etc/nixos/configuration.nix" ]; then
    echo "→ Linking /etc/nixos/configuration.nix → $DOTFILES_DIR/configuration.nix"
    sudo ln -s "$DOTFILES_DIR/configuration.nix" /etc/nixos/configuration.nix
  fi
fi

echo "Nix's configuration.nix imports a machine specific file called 'hardware-configuration.nix'."
echo "It will have mount points etc specific to your machine."
echo "Review the list below and select an existing hw config."
echo "If this is an install on a machine with no matching hw config then you should choose"
echo "the 'Use system generated config' option."

echo
echo "Nix's configuration.nix imports a machine-specific file called 'hardware-configuration.nix'."
echo "It contains mount points, filesystems, and hardware driver settings unique to this machine."
echo "Review the list below and select an existing hardware config if available."
echo "Otherwise, this is a new machine and you should choose the 'Use system generated config' option."

HW_CONFIG_DIR="./hardware_configs"

echo
echo "Available hardware configurations:"
shopt -s nullglob
hw_files=("$HW_CONFIG_DIR"/*_hardware-configuration.nix)

i=1
for file in "${hw_files[@]}"; do
  echo "  [$i] $(basename "$file")"
  ((i++))
done

echo "  [0] Use system generated config"
echo

  while true; do
  read -rp "Enter the number of the hardware config to use: " choice

  if [[ "$choice" == "0" ]]; then
    read -rp "Enter an identifier for this machine (e.g. laptop, office, thinkpad): " ident
    new_file="$HW_CONFIG_DIR/${ident}_hardware-configuration.nix"

    if [ -e "$new_file" ]; then
      echo "❌ A hardware config for '$ident' already exists: $new_file"
      echo "Choose a different name or delete the existing file."
      exit 1
    fi

    echo "Copying system hardware config to $new_file"
    sudo cp /etc/nixos/hardware-configuration.nix "$new_file"
    sudo chown "$USER:$(id -gn)" "$new_file"
    chmod u+rw,go-rwx "$new_file"

    #git add "$new_file"
    selected="$new_file"
    break

  elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#hw_files[@]} )); then
    selected="${hw_files[$((choice-1))]}"
    break

  else
    echo "Invalid selection. Please try again."
  fi
done

echo "Linking /etc/nixos/hardware-configuration.nix → $selected"
if [ -e /etc/nixos/hardware-configuration.nix ] && [ ! -L /etc/nixos/hardware-configuration.nix ]; then
  if [ -e /etc/nixos/hardware-configuration.nix.bak ]; then
    echo "⚠️  Warning: /etc/nixos/hardware-configuration.nix.bak already exists."
    echo "This is unexpected, so NOT overwriting existing backup. You may want to inspect or remove it manually."
    echo "Aborting to avoid data loss."
    exit 1
  fi

  echo "Backing up original /etc/nixos/hardware-configuration.nix → .bak"
  sudo mv /etc/nixos/hardware-configuration.nix /etc/nixos/hardware-configuration.nix.bak
fi

selected_abs=$(realpath "$selected")
sudo ln -sf "$selected_abs" /etc/nixos/hardware-configuration.nix

echo "Hardware config setup complete."
echo


echo "✅ Symlinks set up."

echo "🔄 Running nixos-rebuild switch..."
sudo nixos-rebuild switch

echo "🎯 Running home-manager switch..."
home-manager switch

echo "✅ Bootstrap complete!"

