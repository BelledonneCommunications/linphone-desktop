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

BIN_SOURCE_DIR="OUTPUT/"

WORK_DIR="WORK/Packages/AppImageDir"

rm -rf ${WORK_DIR}/AppDir
mkdir -p "${WORK_DIR}/AppDir/usr/"

#Copy all files from the output project
cp -rf "${BIN_SOURCE_DIR}"/* "${WORK_DIR}/AppDir/usr/"
#remove Packages folder : it is not part of the project
rm -rf "${WORK_DIR}/AppDir/usr/Packages"
#remove libraries : there are automatically found by linuxdeploy
rm -rf "${WORK_DIR}/AppDir/usr/lib"
rm -rf "${WORK_DIR}/AppDir/usr/lib64"

if [ -f "${WORK_DIR}/AppBin/linuxdeploy-x86_64.AppImage" ]; then
	echo "linuxdeploy-x86_64.AppImage exists"
else
	wget -P "${WORK_DIR}/AppBin" https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
	chmod +x "${WORK_DIR}/AppBin/linuxdeploy-x86_64.AppImage"
fi
if [ -f "${WORK_DIR}/AppBin/linuxdeploy-plugin-qt-x86_64.AppImage" ]; then
	echo "linuxdeploy-plugin-qt-x86_64.AppImage exists"
else
	wget -P "${WORK_DIR}/AppBin" https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
	chmod +x "${WORK_DIR}/AppBin/linuxdeploy-plugin-qt-x86_64.AppImage"
fi
export QML_SOURCES_PATHS=${QML_SOURCES_PATHS}:${WORK_DIR}/..
./${WORK_DIR}/AppBin/linuxdeploy-x86_64.AppImage --appdir=${WORK_DIR}/AppDir -e ${WORK_DIR}/AppDir/usr/bin/linphone --output appimage --desktop-file=${WORK_DIR}/AppDir/usr/share/applications/linphone.desktop -i ${WORK_DIR}/AppDir/usr/share/icons/hicolor/scalable/apps/linphone.svg --plugin qt
#./linuxdeploy-x86_64.AppImage --appdir=${WORK_DIR}/ -e ${WORK_DIR}/app/bin/linphone --output appimage --desktop-file=${WORK_DIR}/app/share/applications/linphone.desktop -i ${WORK_DIR}/app/share/icons/hicolor/scalable/apps/linphone.svg

mkdir -p "${BIN_SOURCE_DIR}/Packages"
mv Linphone*.AppImage "${BIN_SOURCE_DIR}/Packages/$1.AppImage"
