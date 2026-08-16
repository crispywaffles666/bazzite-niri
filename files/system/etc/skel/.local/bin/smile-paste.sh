#!/bin/bash
# Launch Smile (emoji picker) and type the picked emoji into the previously
# focused window. Replaces the GNOME Shell "Smile complementary extension"
# on niri: Smile can only copy to the clipboard on Wayland, so once its
# window closes and niri refocuses the previous window, we type the new
# clipboard contents with wtype (virtual-keyboard protocol).
#
# Requires: wtype, wl-clipboard, flatpak smile (it.mijorus.smile).

before="$(wl-paste --no-newline 2>/dev/null)"

flatpak run it.mijorus.smile

# Closed with Esc / nothing picked: clipboard unchanged, type nothing.
after="$(wl-paste --no-newline 2>/dev/null)"
if [ -z "$after" ] || [ "$after" = "$before" ]; then
    exit 0
fi

# Only type text; never spew a copied image/binary into the focused window.
if ! wl-paste --list-types 2>/dev/null | grep -q '^text/plain'; then
    exit 0
fi

sleep 0.15 # let niri settle focus back on the previous window
wtype -- "$after"
