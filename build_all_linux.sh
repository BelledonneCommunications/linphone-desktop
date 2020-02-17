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

################################################################################
#           Linux First building script
#-------------------------------------------------------------------------------

#Stop at error
set -e

if [[ -z ${Qt5_DIR} ]]; then
	eval "$(qtchooser -print-env)"
        export Qt5_DIR=${QTLIBDIR}/cmake/Qt5
        export PATH=${QTTOOLDIR}:$PATH
fi

#Creation of folders
mkdir -p build-desktop
#Opus crash on Linux. The version for 4.3 is old. We have to use a switch in configuration to select the newest version for desktop.
#SDK building
cd build-desktop
#cmake .. -DLINPHONESDK_PLATFORM=Desktop -DCMAKE_BUILD_TYPE=RelWithDebInfo -DENABLE_VPX=YES -DENABLE_GPL_THIRD_PARTIES=YES -DENABLE_NON_FREE_CODECS=YES -DENABLE_AMRNB=YES -DENABLE_AMRWB=YES -DENABLE_G729=YES -DENABLE_GSM=YES -DENABLE_ILBC=YES -DENABLE_ISAC=YES -DENABLE_SILK=YES -DENABLE_SPEEX=YES -DENABLE_H263=YES -DENABLE_H263P=YES -DENABLE_MPEG4=YES -DENABLE_OPENH264=YES -DENABLE_FFMPEG=YES -DENABLE_VIDEO=YES -DENABLE_GL=YES -DENABLE_OPUS=NO
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DENABLE_OPUS=NO
cmake --build . --target sdk --config RelWithDebInfo --parallel 10

#MiniZip Building
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build . --target minizip --config RelWithDebInfo --parallel 10
cmake --build . --target install

#Desktop Building
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build . --target all --config RelWithDebInfo  --parallel 10
cmake --build . --target install



