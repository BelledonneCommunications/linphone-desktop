#!/usr/bin/env bash

for i in 16 22 24 32 64 128
do
  mkdir -p hicolor/${i}x${i}/apps
  inkscape -z -e hicolor/${i}x${i}/apps/icon.png -w $i -h $i ../images/linphone_logo.svg
done
inkscape -z -e ../icon.ico -w 255 -h 255 ../images/linphone_logo.svg
