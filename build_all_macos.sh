#!/bin/sh
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
################################################################################

#-------------------------------------------------------------------------------
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
cd build-desktop

#SDK building
#LINPHONESDK_DOXYGEN_PROGRAM is set just to be sure to get the version of the Application folder
cmake .. -DLINPHONESDK_DOXYGEN_PROGRAM=/Applications/Doxygen.app/Contents/Resources/doxygen -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build . --target all --config RelWithDebInfo --parallel 10

#MiniZip Building
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build . --target all --config RelWithDebInfo --parallel 10
cmake --build . --target install

#Desktop Building
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build . --target all --config RelWithDebInfo
cmake --build . --target install



