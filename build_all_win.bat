
:: Preparing folders
IF NOT EXIST build-desktop mkdir build-desktop

:: SDK Building
cd build-desktop
:: Default config
cmake .. -DLINPHONESDK_PLATFORM=Desktop -DCMAKE_BUILD_TYPE=RelWithDebInfo -A Win32
:: Mini config
::cmake .. -DLINPHONESDK_PLATFORM=Desktop -DCMAKE_BUILD_TYPE=RelWithDebInfo -DENABLE_VPX=NO -DENABLE_OPUS=NO -A Win32 -DENABLE_VIDEO=YES -DENABLE_GL=YES
if %errorlevel% neq 0 exit /b %errorlevel%
cmake --build . --target sdk --config RelWithDebInfo --parallel 10 -- /maxcpucount /nodeReuse:true /p:TrackFileAccess=false;DoNotCopyLocalIfInGac=true;CL_MPCount=16
if %errorlevel% neq 0 exit /b %errorlevel%

:: Minizip Submodule Building
cmake ..  -DCMAKE_BUILD_TYPE=RelWithDebInfo -A Win32
cmake --build . --target install --config RelWithDebInfo --parallel 10 -- /maxcpucount /nodeReuse:true /p:TrackFileAccess=false;DoNotCopyLocalIfInGac=true;CL_MPCount=16

:: Desktop Building
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -A Win32
if %errorlevel% neq 0 exit /b %errorlevel%
cmake --build . --target install --config RelWithDebInfo --parallel 10 -- /maxcpucount /nodeReuse:true /p:TrackFileAccess=false;DoNotCopyLocalIfInGac=true;CL_MPCount=16
