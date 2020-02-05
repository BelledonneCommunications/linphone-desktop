#!/bin/sh
################################################################################
# CMakeLists.txt
# Copyright (C) 2020  Belledonne Communications, Grenoble France
#
################################################################################
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
################################################################################
#           MAC OSX First building script
#-------------------------------------------------------------------------------
#Stop at error
set -e

if [[ -z ${Qt5_DIR} ]]; then
	export Qt5_DIR=/usr/opt/qt/lib/cmake
	export PATH=$PATH:/usr/local/opt/qt/bin
fi

#Creation of folders
mkdir -p build-desktop
mkdir -p linphone-sdk/build-sdk
mkdir -p submodules/externals/minizip/build-minizip

#SDK building
cd linphone-sdk/build-sdk
#LINPHONESDK_DOXYGEN_PROGRAM is set just to be sure to get the version of the Application folder
cmake .. -DLINPHONESDK_DOXYGEN_PROGRAM=/Applications/Doxygen.app/Contents/Resources/doxygen -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build . --target all --config RelWithDebInfo --parallel 5
rsync -a linphone-sdk/desktop/ ../../build-desktop/OUTPUT/
cd ../..

#MiniZip Building
cd submodules/externals/minizip/build-minizip
cmake .. -DCMAKE_INSTALL_PREFIX=../../../../build-desktop/OUTPUT -DCMAKE_PREFIX_PATH=../../../build-desktop/OUTPUT -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build . --target all --config RelWithDebInfo --parallel 5
cmake --build . --target install
cd ../../../..

#Desktop Building
cd build-desktop
cmake .. -DCMAKE_INSTALL_PREFIX=OUTPUT -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build . --target all --config RelWithDebInfo
cmake --build . --target install



