#!/usr/bin/bash
set -euxo pipefail

systemctl enable greetd.service
systemctl set-default graphical.target

# OSTree does not ship /var, so the tmpfiles rule creates tuigreet's state
# directory at boot instead of here in the build container.
