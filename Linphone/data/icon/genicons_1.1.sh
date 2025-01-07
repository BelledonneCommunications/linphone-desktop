#!/usr/bin/env bash
##
## Copyright (c) 2010-2024 Belledonne Communications SARL.
##
## This file is part of linphone-desktop
## (see https://www.linphone.org).
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.
##

for i in 16 22 24 32 64 128 256 512 1024
do
  mkdir -p hicolor/${i}x${i}/apps
  inkscape -z --export-type=png --export-filename=hicolor/${i}x${i}/apps/icon.png -w $i -h $i ../image/logo_margins.svg
done

#Windows and Linux
convert -density 256x256 -background transparent ../image/logo.svg -define icon:auto-resize -colors 256 ../icon.ico

#Mac
png2icns ../../../cmake/install/macos/linphone.icns hicolor/16x16/apps/icon.png hicolor/32x32/apps/icon.png hicolor/128x128/apps/icon.png hicolor/256x256/apps/icon.png hicolor/512x512/apps/icon.png hicolor/1024x1024/apps/icon.png
