################################################################################
#  GenerateFrameworks.cmake
#  Copyright (c) 2021-2023 Belledonne Communications SARL.
# 
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
# 
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>.
#
################################################################################

cmake_policy(SET CMP0009 NEW) # Do not follow symlinks when doing file(GLOB_RECURSE)

include("${LINPHONESDK_DIR}/cmake/LinphoneSdkUtils.cmake")


linphone_sdk_convert_comma_separated_list_to_cmake_list("${LINPHONEAPP_MACOS_ARCHS}" _MACOS_ARCHS)
list(GET _MACOS_ARCHS 0 _FIRST_ARCH)

set(MAIN_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/${LINPHONEAPP_FOLDER})	#OUTPUT/macos

################################
# Create the desktop directory that will contain the merged content of all architectures
################################

execute_process(
	COMMAND "${CMAKE_COMMAND}" "-E" "remove_directory" "${MAIN_INSTALL_DIR}"
	COMMAND "${CMAKE_COMMAND}" "-E" "make_directory" "${MAIN_INSTALL_DIR}"
)

################################
# Copy outside folders that should be in .app package
################################

function( copy_outside_folders _ARCH)
# Prepare .app
	execute_process(COMMAND rsync -a --force "${MAIN_INSTALL_DIR}-${_ARCH}/Frameworks/" "${MAIN_INSTALL_DIR}-${_ARCH}/${CMAKE_INSTALL_LIBDIR}/")
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory "${MAIN_INSTALL_DIR}-${_ARCH}/include/" "${MAIN_INSTALL_DIR}-${_ARCH}/${CMAKE_INSTALL_INCLUDEDIR}/")
# move share
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory "${MAIN_INSTALL_DIR}-${_ARCH}/share/" "${MAIN_INSTALL_DIR}-${_ARCH}/${CMAKE_INSTALL_DATAROOTDIR}/")
# move mkspecs
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory "${MAIN_INSTALL_DIR}-${_ARCH}/mkspecs/" "${MAIN_INSTALL_DIR}-${_ARCH}/${CMAKE_INSTALL_DATAROOTDIR}/")
endfunction()

set(_COPIED FALSE)
foreach(_ARCH IN LISTS ${_MACOS_ARCHS})
	set(_COPIED TRUE)
	message(STATUS "Copying outside folders for ${_ARCH}")
	copy_outside_folders(${_ARCH})
endforeach()

if(NOT _COPIED)	# this is a bug on cmake as there is one element but foreach doesn't do loop.
	message(STATUS "Copying outside folders for ${_FIRST_ARCH}")
	copy_outside_folders(${_FIRST_ARCH})
endif()

################################
# Copy and merge content of all architectures in the desktop directory
################################
# Do not use copy_directory because of symlinks
message(STATUS "Copying ${_FIRST_ARCH} into main")
execute_process(COMMAND rsync -a --force "${MAIN_INSTALL_DIR}-${_FIRST_ARCH}/" "${MAIN_INSTALL_DIR}" WORKING_DIRECTORY "${LINPHONEAPP_BUILD_DIR}")

#if(NOT ENABLE_FAT_BINARY)
#	execute_process(
#		COMMAND "${CMAKE_COMMAND}" "-E" "remove_directory" "${CMAKE_INSTALL_PREFIX}/Frameworks"
#		COMMAND "${CMAKE_COMMAND}" "-E" "make_directory" "${CMAKE_INSTALL_PREFIX}/XCFrameworks"
#	)
#endif()

################################
#####		MIX (TODO)
################################
message(STATUS "Mixing")
# Get all files in output
file(GLOB_RECURSE _BINARIES RELATIVE "${MAIN_INSTALL_DIR}-${_FIRST_ARCH}/" "${MAIN_INSTALL_DIR}-${_FIRST_ARCH}/*")

if(NOT ENABLE_FAT_BINARY)
	# Remove all .framework inputs from the result
	list(FILTER _BINARIES EXCLUDE REGEX ".*\\.framework.*")
endif()

foreach(_FILE IN LISTS ${_BINARIES})
	get_filename_component(ABSOLUTE_FILE "${MAIN_INSTALL_DIR}-${_FIRST_ARCH}/${_FILE}" ABSOLUTE)
	if(NOT IS_SYMLINK ${ABSOLUTE_FILE})
		# Check if lipo can detect an architecture
		execute_process(COMMAND lipo -archs "${MAIN_INSTALL_DIR}-${_FIRST_ARCH}/${_FILE}"
			OUTPUT_VARIABLE FILE_ARCHITECTURE
			OUTPUT_STRIP_TRAILING_WHITESPACE
			WORKING_DIRECTORY "${LINPHONEAPP_BUILD_DIR}"
			ERROR_QUIET
		)
		if(NOT "${FILE_ARCHITECTURE}" STREQUAL "")
			# There is at least one architecture : Use this candidate to mix with another architecture
			set(_ALL_ARCH_FILES)
			foreach(_ARCH IN LISTS ${_ARCHS})
				list(APPEND _ALL_ARCH_FILES "${MAIN_INSTALL_DIR}-${_ARCH}/${_FILE}")
			endforeach()
			string(REPLACE ";" " " _ARCH_STRING "${_ARCHS}")
			message(STATUS "Mixing ${_FILE} for archs [${_ARCH_STRING}]")
			execute_process(
				COMMAND "lipo" "-create" "-output" "${MAIN_INSTALL_DIR}/${_FILE}" ${_ALL_ARCH_FILES}
				WORKING_DIRECTORY "${LINPHONEAPP_BUILD_DIR}"
			)
		endif()
	endif()
endforeach()
execute_process(COMMAND codesign --force --deep --sign - "${MAIN_INSTALL_DIR}/${LINPHONEAPP_APPLICATION_NAME}.app")#If not code signed, app can crash because of APPLE on "Code Signature Invalid".


#[[
if(NOT ENABLE_FAT_BINARY)
	# Generate XCFrameworks
	file(GLOB _FRAMEWORKS "${LINPHONEAPP_BUILD_DIR}/${MAIN_INSTALL_DIR}-${_FIRST_ARCH}/Frameworks/*.framework")
	foreach(_FRAMEWORK IN LISTS _FRAMEWORKS)
		get_filename_component(_FRAMEWORK_NAME "${_FRAMEWORK}" NAME_WE)
		set(_ALL_ARCH_FRAMEWORKS)
		foreach(_ARCH IN LISTS _MACOS_ARCHS)
			list(APPEND _ALL_ARCH_FRAMEWORKS "-framework")
			list(APPEND _ALL_ARCH_FRAMEWORKS "${LINPHONEAPP_BUILD_DIR}/${LINPHONEAPP_NAME}/${LINPHONEAPP_PLATFORM}-${_ARCH}/Frameworks/${_FRAMEWORK_NAME}.framework")
		endforeach()
		string(REPLACE ";" " " _ARCH_STRING "${_MACOS_ARCHS}")
		message(STATUS "Creating XCFramework for ${_FRAMEWORK_NAME} for archs [${_ARCH_STRING}]")
		execute_process(
				COMMAND "xcodebuild" "-create-xcframework" "-output" "${CMAKE_INSTALL_PREFIX}/XCFrameworks/${_FRAMEWORK_NAME}.xcframework" ${_ALL_ARCH_FRAMEWORKS}
				WORKING_DIRECTORY "${LINPHONEAPP_BUILD_DIR}"
		)
	endforeach()
endif()
#]]
