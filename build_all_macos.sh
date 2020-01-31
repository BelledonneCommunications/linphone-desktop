#!/bin/sh

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
cmake .. -DLINPHONESDK_DOXYGEN_PROGRAM=/Applications/Doxygen.app/Contents/Resources/doxygen -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9
cmake --build . --target all --parallel 5
rsync -a linphone-sdk/desktop/ ../../build-desktop/OUTPUT/
cd ../..
#MiniZip Building
cd submodules/externals/minizip/build-minizip
cmake .. -DCMAKE_INSTALL_PREFIX=../../../../build-desktop/OUTPUT -DCMAKE_PREFIX_PATH=../../../build-desktop/OUTPUT
cmake --build . --target all --parallel 5
cmake --build . --target install
cd ../../../..

#Desktop Building
cd build-desktop
cmake .. -DCMAKE_INSTALL_PREFIX=OUTPUT
cmake --build . --target all
cmake --build . --target install



