#!/bin/bash
##
## Copyright (c) 2010-2020 Belledonne Communications SARL.
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

APP_NAME="linphone"

BIN_SOURCE_DIR="OUTPUT/desktop"

WORK_DIR="OUTPUT/AppDir/usr"

mkdir -p "${WORK_DIR}"

cp -rfv	"${BIN_SOURCE_DIR}"/* "${WORK_DIR}"

./AppImage/linuxdeployqt-continuous-x86_64.AppImage "${WORK_DIR}/bin/${APP_NAME}" -appimage -bundle-non-qt-libs -verbose=2
