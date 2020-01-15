#!/bin/bash

APP_NAME="linphone"

BIN_SOURCE_DIR="OUTPUT/desktop"

WORK_DIR="OUTPUT/AppDir/usr"

mkdir -p "${WORK_DIR}"

cp -rfv	"${BIN_SOURCE_DIR}"/* "${WORK_DIR}"

./AppImage/linuxdeployqt-continuous-x86_64.AppImage "${WORK_DIR}/bin/${APP_NAME}" -appimage -bundle-non-qt-libs -verbose=2
