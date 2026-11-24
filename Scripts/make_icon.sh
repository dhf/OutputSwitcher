#!/bin/zsh
# Regenerates Resources/AppIcon.icns from Scripts/make_icon.swift.
set -euo pipefail
cd "${0:A:h}/.."

WORK="$(mktemp -d)"
MASTER="$WORK/master.png"
ICONSET="$WORK/AppIcon.iconset"
mkdir -p "$ICONSET" Resources

swift Scripts/make_icon.swift "$MASTER"

# name:pixel-size pairs required by an .iconset
for entry in 16:icon_16x16 32:icon_16x16@2x 32:icon_32x32 64:icon_32x32@2x \
             128:icon_128x128 256:icon_128x128@2x 256:icon_256x256 512:icon_256x256@2x \
             512:icon_512x512 1024:icon_512x512@2x; do
    size="${entry%%:*}"; name="${entry#*:}"
    sips -z "$size" "$size" "$MASTER" --out "$ICONSET/$name.png" >/dev/null
done

iconutil -c icns "$ICONSET" -o Resources/AppIcon.icns
cp "$MASTER" Resources/AppIcon-1024.png
echo "Wrote Resources/AppIcon.icns"
