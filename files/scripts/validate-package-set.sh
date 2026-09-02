#!/usr/bin/bash
# Catch Fedora or Bazzite package changes that would break the Niri desktop.
set -euxo pipefail

required=(
    niri
    gnome-keyring
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    nautilus
)

banned=(
    gnome-shell
    mutter
    gdm
    gnome-session
)

for pkg in "${required[@]}"; do
    if ! rpm -q --quiet "$pkg"; then
        echo "ERROR: required package is not installed: $pkg" >&2
        exit 1
    fi
done

for pkg in "${banned[@]}"; do
    if rpm -q --quiet "$pkg"; then
        echo "ERROR: forbidden GNOME desktop package is installed: $pkg" >&2
        exit 1
    fi
done
