#!/usr/bin/env bash

for i in 16 22 24 32 64 128
do
  mkdir -p hicolor/${i}x${i}/apps
  inkscape -z -e hicolor/${i}x${i}/apps/icon.png -w $i -h $i ../images/linphone_logo.svg
done
convert hicolor/16x16/apps/icon.png hicolor/22x22/apps/icon.png hicolor/24x24/apps/icon.png hicolor/32x32/apps/icon.png hicolor/64x64/apps/icon.png hicolor/128x128/apps/icon.png -colors 256 ../icon.ico
