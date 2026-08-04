#!/usr/bin/bash
# greetd replaces gdm (removed in remove-gnome.sh) as the display manager.
set -euxo pipefail

systemctl enable greetd.service
systemctl set-default graphical.target
