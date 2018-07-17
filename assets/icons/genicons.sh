#!/usr/bin/env bash

if [ -f ../images/custom/app_logo.svg ] ; then
  src=../images/custom/app_logo.svg
else
  src=../images/app_logo.svg
fi

for i in 16 22 24 32 64 128
do
  mkdir -p hicolor/${i}x${i}/apps
  inkscape -z -e hicolor/${i}x${i}/apps/icon.png -w $i -h $i $src
done
