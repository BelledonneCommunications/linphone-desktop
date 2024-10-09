#!/bin/bash
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

# Arguments : 
#	$1 = Executable Name
#	$2 = Output Filename
#	$3 = Qt root path (eg. "~/Qt/5.15.2/gcc_64")
#	$4 = Key of the code sign (optional but mendatory if code signing)

APP_NAME="$1"
QT_PATH="$3"

BIN_SOURCE_DIR="OUTPUT/"

WORK_DIR="WORK/Packages/AppImageDir"

# Goal : avoid fuse on CI. --appimage-extract-and-run is not enough because of not propagate to plugins.
export APPIMAGE_EXTRACT_AND_RUN=1

rm -rf ${WORK_DIR}/AppDir
mkdir -p "${WORK_DIR}/AppDir/usr/"

copyFolder()
{
	mkdir -p "${WORK_DIR}/AppDir/usr/$1"
	cp -rf "${BIN_SOURCE_DIR}/$1"/* "${WORK_DIR}/AppDir/usr/$1"
}


#Copy all files from the output project
#cp -rf "${BIN_SOURCE_DIR}"/* "${WORK_DIR}/AppDir/usr/"
copyFolder bin
#cp -rf "${BIN_SOURCE_DIR}/bin"/* "${WORK_DIR}/AppDir/usr/bin"

# Copy share
copyFolder share/applications
copyFolder share/belr
copyFolder share/icons
copyFolder share/images
copyFolder share/linphone
copyFolder share/sounds
copyFolder share/$1

#remove Packages folder : it is not part of the project
#rm -rf "${WORK_DIR}/AppDir/usr/Packages"
#remove libraries : there are automatically found by linuxdeploy
#rm -rf "${WORK_DIR}/AppDir/usr/lib"
#rm -rf "${WORK_DIR}/AppDir/usr/lib64"
#Copy soci sqlite3 backend
mkdir -p "${WORK_DIR}/AppDir/usr/lib"
cp -f "${BIN_SOURCE_DIR}/lib"/libsoci_sqlite3* "${WORK_DIR}/AppDir/usr/lib/"
cp -f "${BIN_SOURCE_DIR}/lib"/libapp-plugin* "${WORK_DIR}/AppDir/usr/lib/"
cp -f "${BIN_SOURCE_DIR}/lib64"/libsoci_sqlite3* "${WORK_DIR}/AppDir/usr/lib/"
cp -f "${BIN_SOURCE_DIR}/lib64"/libapp-plugin* "${WORK_DIR}/AppDir/usr/lib/"

cp -f "${BIN_SOURCE_DIR}/lib"/libEQt* "${WORK_DIR}/AppDir/usr/lib/"
cp -f "${BIN_SOURCE_DIR}/lib64"/libEQt* "${WORK_DIR}/AppDir/usr/lib/"


if [ -d "${BIN_SOURCE_DIR}/lib64/mediastreamer" ]; then
	mkdir -p "${WORK_DIR}/AppDir/usr/lib64/"
	cp -rf "${BIN_SOURCE_DIR}"/lib64/mediastreamer "${WORK_DIR}/AppDir/usr/lib64/"
fi

if [ -d "${BIN_SOURCE_DIR}/lib/mediastreamer" ]; then
	mkdir -p "${WORK_DIR}/AppDir/usr/lib/"
	cp -rf "${BIN_SOURCE_DIR}"/lib/mediastreamer "${WORK_DIR}/AppDir/usr/lib/"
fi

if [ -f "${WORK_DIR}/AppBin/linuxdeploy-x86_64.AppImage" ]; then
	echo "linuxdeploy-x86_64.AppImage exists"
else
	wget -P "${WORK_DIR}/AppBin" https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
	#wget -P "${WORK_DIR}/AppBin" https://artifacts.assassinate-you.net/linuxdeploy/travis-456/linuxdeploy-x86_64.AppImage
	chmod +x "${WORK_DIR}/AppBin/linuxdeploy-x86_64.AppImage"
fi
if [ -f "${WORK_DIR}/AppBin/linuxdeploy-plugin-qt-x86_64.AppImage" ]; then
	echo "linuxdeploy-plugin-qt-x86_64.AppImage exists"
else
	wget -P "${WORK_DIR}/AppBin" https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
	chmod +x "${WORK_DIR}/AppBin/linuxdeploy-plugin-qt-x86_64.AppImage"
fi

###########################################################################################

export QMAKE=${QT_PATH}/bin/qmake
export QML_SOURCES_PATHS=${QML_SOURCES_PATHS}:${WORK_DIR}/..
export LD_LIBRARY_PATH=${QT_PATH}/lib:${BIN_SOURCE_DIR}/lib:${BIN_SOURCE_DIR}/lib64
#export EXTRA_QT_PLUGINS=webenginecore;webview;webengine

echo "QML_SOURCES_PATHS=${QML_SOURCES_PATHS}"
echo "QML_MODULES_PATHS=${QML_MODULES_PATHS}"
echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"

echo "-- Generating AppDir for AppImage"
if [ -z "$4" ]; then
	echo "./${WORK_DIR}/AppBin/linuxdeploy-x86_64.AppImage --appimage-extract-and-run --appdir=${WORK_DIR}/AppDir -e ${WORK_DIR}/AppDir/usr/bin/${APP_NAME} --output appimage --desktop-file=${WORK_DIR}/AppDir/usr/share/applications/${APP_NAME}.desktop -i ${WORK_DIR}/AppDir/usr/share/icons/hicolor/scalable/apps/${APP_NAME}.svg --plugin qt"
	./${WORK_DIR}/AppBin/linuxdeploy-x86_64.AppImage --appimage-extract-and-run --appdir=${WORK_DIR}/AppDir -e ${WORK_DIR}/AppDir/usr/bin/${APP_NAME} --output appimage --desktop-file=${WORK_DIR}/AppDir/usr/share/applications/${APP_NAME}.desktop -i ${WORK_DIR}/AppDir/usr/share/icons/hicolor/scalable/apps/${APP_NAME}.svg --plugin qt
else
	if [ -f "${WORK_DIR}/AppBin/appimagetool-x86_64.AppImage" ]; then
		echo "appimagetool-x86_64.AppImage exists"
	else
		wget -P "${WORK_DIR}/AppBin" https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
		chmod +x "${WORK_DIR}/AppBin/appimagetool-x86_64.AppImage"
	fi
	./${WORK_DIR}/AppBin/linuxdeploy-x86_64.AppImage --appimage-extract-and-run --appdir=${WORK_DIR}/AppDir -e ${WORK_DIR}/AppDir/usr/bin/${APP_NAME} --desktop-file=${WORK_DIR}/AppDir/usr/share/applications/${APP_NAME}.desktop -i ${WORK_DIR}/AppDir/usr/share/icons/hicolor/scalable/apps/${APP_NAME}.svg --plugin qt
	#./linuxdeploy-x86_64.AppImage --appdir=${WORK_DIR}/ -e ${WORK_DIR}/app/bin/${APP_NAME} --output appimage --desktop-file=${WORK_DIR}/app/share/applications/${APP_NAME}.desktop -i ${WORK_DIR}/app/share/icons/hicolor/scalable/apps/${APP_NAME}.svg
	echo "-- Code Signing of AppImage"
	# APPIMAGETOOL_SIGN_PASSPHRASE has to the parent environment (not here). Do not use export.
	./${WORK_DIR}/AppBin/appimagetool-x86_64.AppImage --appimage-extract-and-run ${WORK_DIR}/AppDir --sign --sign-key $4
fi

echo "Move Appimages into ${BIN_SOURCE_DIR}/Packages/$2.AppImage"
mkdir -p "${BIN_SOURCE_DIR}/Packages"
mv *.AppImage "${BIN_SOURCE_DIR}/Packages/$2.AppImage"
