
:: Preparing folders
IF NOT EXIST build-desktop mkdir build-desktop

:: SDK Building
cd build-desktop
:: Full config
::cmake .. -DLINPHONESDK_PLATFORM=Desktop -DCMAKE_BUILD_TYPE=RelWithDebInfo -DENABLE_VPX=YES -A Win32 -DENABLE_GPL_THIRD_PARTIES=YES -DENABLE_NON_FREE_CODECS=YES -DENABLE_AMRNB=YES -DENABLE_AMRWB=YES -DENABLE_G729=YES -DENABLE_GSM=YES -DENABLE_ILBC=YES -DENABLE_ISAC=YES -DENABLE_OPUS=YES -DENABLE_SILK=YES -DENABLE_SPEEX=YES -DENABLE_H263=YES -DENABLE_H263P=YES -DENABLE_MPEG4=YES -DENABLE_OPENH264=YES -DENABLE_FFMPEG=YES -DENABLE_VIDEO=YES -DENABLE_GL=YES
:: Mini config
cmake .. -DLINPHONESDK_PLATFORM=Desktop -DCMAKE_BUILD_TYPE=RelWithDebInfo -DENABLE_VPX=NO -DENABLE_OPUS=NO -A Win32 -DENABLE_VIDEO=YES -DENABLE_GL=YES
if %errorlevel% neq 0 exit /b %errorlevel%
cmake --build . --target sdk --config RelWithDebInfo --parallel 10
if %errorlevel% neq 0 exit /b %errorlevel%

:: Minizip Submodule Building
cmake ..  -DCMAKE_BUILD_TYPE=RelWithDebInfo -A Win32
cmake --build . --target all_build --parallel 10 --config RelWithDebInfo -- /maxcpucount /nodeReuse:true /p:TrackFileAccess=false
cmake --build . --target install --config RelWithDebInfo -- /maxcpucount /nodeReuse:true /p:TrackFileAccess=false

:: Desktop Building
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -A Win32
if %errorlevel% neq 0 exit /b %errorlevel%
cmake --build . --target all_build --config RelWithDebInfo --parallel 10 -- /maxcpucount /nodeReuse:true /p:TrackFileAccess=false
cmake --build . --target install --config RelWithDebInfo -- /maxcpucount /nodeReuse:true /p:TrackFileAccess=false
