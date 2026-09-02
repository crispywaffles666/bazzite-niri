#!/usr/bin/bash
# Fedora and Nerd Fonts do not ship Overpass Nerd Font, so use Arch's build.
# Pin its version and hash to keep builds repeatable.
set -euxo pipefail

version="3.4.0-2"
checksum="38c2396c7014a1708f3251186a565867b15e401cdd6397865f98e1a5527b40e9"
url="https://archive.archlinux.org/packages/o/otf-overpass-nerd/otf-overpass-nerd-${version}-any.pkg.tar.zst"
archive="/tmp/overpass-nerd.pkg.tar.zst"

curl -fSL --retry 3 -o "$archive" "$url"
echo "${checksum}  ${archive}" | sha256sum -c -

mkdir -p /usr/share/fonts/OTF/overpass-nerd
zstdcat "$archive" \
    | tar -x -C /usr/share/fonts/OTF/overpass-nerd --strip-components=4 --wildcards 'usr/share/fonts/OTF/*.otf'

fc-cache -f /usr/share/fonts/OTF/overpass-nerd
rm -f "$archive"
