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


# Create the desktop directory that will contain the merged content of all architectures
execute_process(
	COMMAND "${CMAKE_COMMAND}" "-E" "remove_directory" "${CMAKE_INSTALL_PREFIX}"
	COMMAND "${CMAKE_COMMAND}" "-E" "make_directory" "${CMAKE_INSTALL_PREFIX}"
)

# Copy and merge content of all architectures in the desktop directory
list(GET _MACOS_ARCHS 0 _FIRST_ARCH)
execute_process(# Do not use copy_directory because of symlinks
	COMMAND "cp" "-R"  "${LINPHONEAPP_NAME}/${LINPHONEAPP_PLATFORM}-${_FIRST_ARCH}/" "${CMAKE_INSTALL_PREFIX}"
	WORKING_DIRECTORY "${LINPHONEAPP_BUILD_DIR}"
)

#message(FATAL_ERROR "${LINPHONEAPP_NAME}/${LINPHONEAPP_PLATFORM}-${_FIRST_ARCH}/ == ${CMAKE_INSTALL_PREFIX} == ${LINPHONEAPP_BUILD_DIR}")
#if(NOT ENABLE_FAT_BINARY)
#	execute_process(
#		COMMAND "${CMAKE_COMMAND}" "-E" "remove_directory" "${CMAKE_INSTALL_PREFIX}/Frameworks"
#		COMMAND "${CMAKE_COMMAND}" "-E" "make_directory" "${CMAKE_INSTALL_PREFIX}/XCFrameworks"
#	)
#endif()

#####		MIX
# Get all files in output
file(GLOB_RECURSE _BINARIES RELATIVE "${LINPHONEAPP_BUILD_DIR}/${LINPHONEAPP_NAME}/${LINPHONEAPP_PLATFORM}-${_FIRST_ARCH}/" "${LINPHONEAPP_BUILD_DIR}/${LINPHONEAPP_NAME}/${LINPHONEAPP_PLATFORM}-${_FIRST_ARCH}/*")

if(NOT ENABLE_FAT_BINARY)
	# Remove all .framework inputs from the result
	list(FILTER _BINARIES EXCLUDE REGEX ".*\\.framework.*")
endif()

foreach(_FILE IN LISTS ${_BINARIES})
	get_filename_component(ABSOLUTE_FILE "${LINPHONEAPP_NAME}/${LINPHONEAPP_PLATFORM}-${_FIRST_ARCH}/${_FILE}" ABSOLUTE)
	if(NOT IS_SYMLINK ${ABSOLUTE_FILE})
		# Check if lipo can detect an architecture
		execute_process(COMMAND lipo -archs "${LINPHONEAPP_NAME}/${LINPHONEAPP_PLATFORM}-${_FIRST_ARCH}/${_FILE}"
			OUTPUT_VARIABLE FILE_ARCHITECTURE
			OUTPUT_STRIP_TRAILING_WHITESPACE
			WORKING_DIRECTORY "${LINPHONEAPP_BUILD_DIR}"
			ERROR_QUIET
		)
		if(NOT "${FILE_ARCHITECTURE}" STREQUAL "")
			# There is at least one architecture : Use this candidate to mix with another architecture
			set(_ALL_ARCH_FILES)
			foreach(_ARCH IN LISTS ${_ARCHS})
				list(APPEND _ALL_ARCH_FILES "${LINPHONEAPP_NAME}/${LINPHONEAPP_PLATFORM}-${_ARCH}/${_FILE}")
			endforeach()
			string(REPLACE ";" " " _ARCH_STRING "${_ARCHS}")
			message(STATUS "Mixing ${_FILE} for archs [${_ARCH_STRING}]")
			execute_process(
				COMMAND "lipo" "-create" "-output" "${CMAKE_INSTALL_PREFIX}/${_FILE}" ${_ALL_ARCH_FILES}
				WORKING_DIRECTORY "${LINPHONEAPP_BUILD_DIR}"
			)
		endif()
	endif()
endforeach()
#[[
if(NOT ENABLE_FAT_BINARY)
	# Generate XCFrameworks
	file(GLOB _FRAMEWORKS "${LINPHONEAPP_BUILD_DIR}/${LINPHONEAPP_NAME}/${LINPHONEAPP_PLATFORM}-${_FIRST_ARCH}/Frameworks/*.framework")
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
