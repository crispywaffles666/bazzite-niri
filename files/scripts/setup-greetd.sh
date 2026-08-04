#!/usr/bin/bash
# greetd replaces gdm (removed in remove-gnome.sh) as the display manager.
set -euxo pipefail

systemctl enable greetd.service
systemctl set-default graphical.target

# tuigreet --remember/--remember-session persist to /var/cache/tuigreet,
# writable by the greeter user (Fedora: greetd, uid 999). /var is NOT shipped
# in the image on ostree systems — creating it here would only touch the
# build container. Handled at boot by files/system/usr/lib/tmpfiles.d/tuigreet.conf.
