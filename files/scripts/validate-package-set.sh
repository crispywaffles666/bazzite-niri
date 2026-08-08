#!/usr/bin/bash
# Fail the image build if Fedora/Bazzite dependency changes alter the intended
# Niri desktop package composition.
set -euxo pipefail

REQUIRED_PACKAGES=(
    niri
    gnome-keyring
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    nautilus
)

FORBIDDEN_PACKAGES=(
    gnome-shell
    mutter
    gdm
    gnome-session
)

for package in "${REQUIRED_PACKAGES[@]}"; do
    if ! rpm -q --quiet "$package"; then
        echo "ERROR: required package is not installed: $package" >&2
        exit 1
    fi
done

for package in "${FORBIDDEN_PACKAGES[@]}"; do
    if rpm -q --quiet "$package"; then
        echo "ERROR: forbidden GNOME desktop package is installed: $package" >&2
        exit 1
    fi
done
