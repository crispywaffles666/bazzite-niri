#!/usr/bin/bash
# greetd replaces gdm (removed in remove-gnome.sh) as the display manager.
set -euxo pipefail

systemctl enable greetd.service
systemctl set-default graphical.target

# tuigreet --remember/--remember-session persist to /var/cache/tuigreet,
# which must be writable by the greeter user (Fedora: greetd, uid 999)
install -d -m 0755 -o greetd -g greetd /var/cache/tuigreet
