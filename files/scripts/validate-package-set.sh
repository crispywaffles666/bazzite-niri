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

if rpm -q --quiet sassc; then
    echo "ERROR: theme build-only package leaked into the final image: sassc" >&2
    exit 1
fi

graphite_theme=/usr/share/themes/Graphite-purple-Dark-dracula
graphite_files=(
    "$graphite_theme/index.theme"
    "$graphite_theme/gtk-3.0/gtk.css"
    "$graphite_theme/gtk-3.0/gtk-dark.css"
    "$graphite_theme/gtk-4.0/gtk.css"
    "$graphite_theme/gtk-4.0/gtk-dark.css"
)
for theme_file in "${graphite_files[@]}"; do
    if [[ ! -s "$theme_file" ]]; then
        echo "ERROR: generated Graphite theme file is missing: $theme_file" >&2
        exit 1
    fi
done
for asset_dir in "$graphite_theme/gtk-3.0/assets" "$graphite_theme/gtk-4.0/assets"; do
    if [[ ! -d "$asset_dir" || -z "$(find "$asset_dir" -type f -print -quit)" ]]; then
        echo "ERROR: generated Graphite assets are missing: $asset_dir" >&2
        exit 1
    fi
done

dracula_icons=/usr/share/icons/dracula-icons-main
for icon_file in "$dracula_icons/index.theme" "$dracula_icons/icon-theme.cache"; do
    if [[ ! -s "$icon_file" ]]; then
        echo "ERROR: Dracula icon theme file is missing: $icon_file" >&2
        exit 1
    fi
done
if [[ ! -s /usr/share/licenses/Graphite-gtk-theme/LICENSE ]]; then
    echo "ERROR: Graphite upstream license is missing" >&2
    exit 1
fi
if [[ ! -s /usr/share/licenses/dracula-icons/README.md ]]; then
    echo "ERROR: Dracula Icons upstream licensing notice is missing" >&2
    exit 1
fi

for gtk_settings in /etc/skel/.config/gtk-{3,4}.0/settings.ini; do
    if ! grep -Fxq 'gtk-theme-name=Graphite-purple-Dark-dracula' "$gtk_settings"; then
        echo "ERROR: configured GTK theme name is incorrect: $gtk_settings" >&2
        exit 1
    fi
    if ! grep -Fxq 'gtk-icon-theme-name=dracula-icons-main' "$gtk_settings"; then
        echo "ERROR: configured icon theme name is incorrect: $gtk_settings" >&2
        exit 1
    fi
done
theme_schema=/usr/share/glib-2.0/schemas/zz_bazzite-niri.gschema.override
if ! grep -Fxq "gtk-theme='Graphite-purple-Dark-dracula'" "$theme_schema"; then
    echo "ERROR: GNOME schema override has the wrong GTK theme name" >&2
    exit 1
fi
if ! grep -Fxq "icon-theme='dracula-icons-main'" "$theme_schema"; then
    echo "ERROR: GNOME schema override has the wrong icon theme name" >&2
    exit 1
fi
