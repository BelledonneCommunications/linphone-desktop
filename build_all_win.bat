
:: Preparing folders
IF NOT EXIST build-desktop mkdir build-desktop
cd linphone-sdk
IF NOT EXIST build-sdk mkdir build-sdk
cd ../submodules/externals/minizip
IF NOT EXIST build-minizip mkdir build-minizip
cd ../../..

:: SDK Building
cd linphone-sdk/build-sdk 
cmake .. -DLINPHONESDK_PLATFORM=Desktop -DENABLE_CSHARP_WRAPPER=YES -DCMAKE_BUILD_TYPE=Debug -DENABLE_VPX=ON -A Win32
if %errorlevel% neq 0 exit /b %errorlevel%
cmake --build . --target sdk --parallel 5
if %errorlevel% neq 0 exit /b %errorlevel%
robocopy linphone-sdk\desktop ..\..\build-desktop\OUTPUT /e /njh /njs /ndl /nc /ns
cd ../..

:: Minizip Submodule Building
cd submodules/externals/minizip/build-minizip
cmake ..  -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=../../build-desktop/OUTPUT -DCMAKE_PREFIX_PATH="../../../linphone-sdk/build-sdk/linphone-sdk/desktop" -A Win32
cmake --build . --target all_build --config Debug -- /maxcpucount /nodeReuse:true /p:TrackFileAccess=false
cmake --build . --target install --config Debug -- /maxcpucount /nodeReuse:true /p:TrackFileAccess=false
cd ../../../..

:: Desktop Building
cd build-desktop
cmake ..  -DENABLE_CSHARP_WRAPPER=YES -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=OUTPUT -DCMAKE_PREFIX_PATH="linphone-sdk/build-sdk/linphone-sdk/desktop;submodules/externals/minizip/build-minizip/OUTPUT" -A Win32
if %errorlevel% neq 0 exit /b %errorlevel%
cmake --build . --target all_build --config Debug -- /maxcpucount /nodeReuse:true /p:TrackFileAccess=false
cmake --build . --target install --config Debug -- /maxcpucount /nodeReuse:true /p:TrackFileAccess=false
