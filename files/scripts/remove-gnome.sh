#!/usr/bin/bash
# Remove the GNOME desktop stack from bazzite-gnome while keeping:
#   - xdg-desktop-portal-gnome (niri has no portal backend of its own)
#   - gnome-keyring            (secret service / SSH agent)
#   - nautilus                 (user's GUI file manager)
#   - gtk4/libadwaita/gvfs     (needed by ghostty, noctalia, nautilus deps)
# Package names are filtered through rpm -q first, so the script stays
# correct even when bazzite upstream changes its package set.
set -euxo pipefail

EXPLICIT=(
    # shell / session / display manager
    gnome-shell gnome-session gnome-session-wayland-session
    gnome-session-xsession mutter mutter-common gdm
    # settings / system daemons
    gnome-control-center gnome-settings-daemon gnome-remote-desktop
    gnome-bluetooth gnome-color-manager gnome-user-share rygel
    # gnome apps (nautilus deliberately kept)
    gnome-disk-utility gnome-system-monitor gnome-tour gnome-software
    gnome-initial-setup gnome-terminal ptyxis yelp gnome-user-docs
    gnome-browser-connector gnome-characters
    # indexers (NOT tinysparql/localsearch: Fedora nautilus hard-requires
    # both, unlike Arch where tracker is optional - they must stay)
    # bazzite's gnome-only additions
    steamdeck-gnome-presets steamdeck-backgrounds
    gnome-search-yafti nautilus-gsconnect rom-properties-gtk4
    rom-properties-localsearch3
    # misc shell integrations
    gnome-backgrounds gnome-epub-thumbnailer
    gnome-shell-extension-user-theme gnome-shell-extension-gsconnect
)

# glob-style families caught via rpm -qa
PATTERNS='^(gnome-shell-extension-|papers)'

TO_REMOVE=()
for pkg in "${EXPLICIT[@]}"; do
    if rpm -q --quiet "$pkg"; then
        TO_REMOVE+=("$pkg")
    fi
done
while read -r pkg; do
    [ -n "$pkg" ] && TO_REMOVE+=("$pkg")
done < <(rpm -qa --qf '%{NAME}\n' | grep -E "$PATTERNS" || true)

# protect the keepers from the autoremove pass below
dnf5 -y mark user xdg-desktop-portal-gnome xdg-desktop-portal-gtk gnome-keyring nautilus

if [ "${#TO_REMOVE[@]}" -gt 0 ]; then
    # clean_requirements_on_remove=false: dnf5's orphan cascade on remove
    # ignores install reasons and would take nautilus out with
    # nautilus-gsconnect/papers-nautilus. Autoremove below does respect them.
    dnf5 -y remove --setopt=clean_requirements_on_remove=false "${TO_REMOVE[@]}"
fi

dnf5 -y autoremove
