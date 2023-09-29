


if( APPLE )
	set(LINPHONESDK_BUILD_TYPE "Macos")
	set(ENABLE_FAT_BINARY "ON")
	if( NOT CMAKE_OSX_DEPLOYMENT_TARGET)
		set(CMAKE_OSX_DEPLOYMENT_TARGET "10.9" CACHE STRING "Minimum OS X deployment version")
	endif()
	if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "arm64")# TODO: add universal build
		set(LINPHONESDK_MACOS_ARCHS "x86_64" CACHE STRING "MacOS architectures to build for: comma-separated list of values in [x86_64]")
	else()
		set(LINPHONESDK_MACOS_ARCHS "x86_64" CACHE STRING "MacOS architectures to build for: comma-separated list of values in [x86_64]")
	endif()
	set(CMAKE_OSX_ARCHITECTURES ${LINPHONESDK_MACOS_ARCHS} CACHE STRING "")
	set(CMAKE_SYSTEM_PROCESSOR "x86_64")
elseif(WIN32)
    set(LINPHONESDK_BUILD_TYPE "Default")
endif()



add_subdirectory(linphone-sdk/)
