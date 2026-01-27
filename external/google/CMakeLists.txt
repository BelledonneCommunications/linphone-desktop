set(DEPOT_TOOLS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/chromium-depot-tools")
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
	set(CRASHPAD_BIN_DIR  "out/debug")
else()
	set(CRASHPAD_BIN_DIR  "out/release")
endif()
set(CRASHPAD_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/crashpad/${CRASHPAD_BIN_DIR})

if(WIN32)
	set(GCLIENT_SCRIPT "${DEPOT_TOOLS_DIR}/gclient.bat")
	set(GN_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/bc_gn.bat")
	set(GN_COMMAND ${GN_SCRIPT} ${CRASHPAD_BUILD_DIR} ${CMAKE_BUILD_TYPE})
else()
	set(GCLIENT_SCRIPT "${DEPOT_TOOLS_DIR}/gclient")
	set(GN_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/bc_gn.sh")
	set(GN_COMMAND ${GN_SCRIPT} ${CRASHPAD_BUILD_DIR} ${CMAKE_BUILD_TYPE})
endif()
message(STATUS "gn used ${GN_SCRIPT}")

if (ENABLE_CRASH_HANDLER AND WIN32)
	##########################################
	#Hack utils/Build.gn by adding cflags = ["-Wno-nontrivial-memcall"]
	#because newer version of clang cannot build with this warning and it is not fixed by crashpad
	message(STATUS "Syncing with gclient")
	execute_process(
		COMMAND "${GCLIENT_SCRIPT}" sync --nohooks --shallow
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
		RESULT_VARIABLE gclient_sync_result
		OUTPUT_VARIABLE gclient_sync_output
		ERROR_VARIABLE gclient_sync_error
		COMMAND_ECHO  STDOUT
	)
	if(gclient_sync_result)
		message(FATAL_ERROR "Failed syncing with gclient: ${gclient_sync_result} ${gclient_sync_output} ${gclient_sync_error}")
	endif()

	message(STATUS "Generating build files for crashpad")
	#We use GN_COMMAND because CMAKE mess up with quotes, spaces and arguments on Windows
	execute_process(
		COMMAND ${GN_COMMAND}
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/crashpad"
		RESULT_VARIABLE crashpad_gn_result
		OUTPUT_VARIABLE crashpad_gn_output
		ERROR_VARIABLE crashpad_gn_error
		COMMAND_ECHO  STDOUT
	)
	if(crashpad_gn_result)
		message(FATAL_ERROR "Failed generate crashpad build files: ${crashpad_gn_result} ${crashpad_gn_output} ${crashpad_gn_error}")
	endif()
	message(STATUS "Crashpad build files generated")
	set(TARGET_NAME Crashpad)

#NOTE: Order is important
	if(WIN32)
		set(CRASHPAD_OUTPUTS
				"${CRASHPAD_BUILD_DIR}/obj/client/common.lib"
				"${CRASHPAD_BUILD_DIR}/obj/client/client.lib"
				"${CRASHPAD_BUILD_DIR}/obj/util/util.lib"
				"${CRASHPAD_BUILD_DIR}/obj/third_party/mini_chromium/mini_chromium/base/base.lib"
		)
	elseif(APPLE)
		set(CRASHPAD_OUTPUTS
				"${CRASHPAD_BUILD_DIR}/obj/client/libcommon.a"
				"${CRASHPAD_BUILD_DIR}/obj/client/libclient.a"
				"${CRASHPAD_BUILD_DIR}/obj/util/libutil.a"
				"${CRASHPAD_BUILD_DIR}/obj/util/libmig_output.a"
				"${CRASHPAD_BUILD_DIR}/obj/third_party/mini_chromium/mini_chromium/base/libbase.a"
				)
	else()
		set(CRASHPAD_OUTPUTS
				"${CRASHPAD_BUILD_DIR}/obj/client/libcommon.a"
				"${CRASHPAD_BUILD_DIR}/obj/client/libclient.a"
				"${CRASHPAD_BUILD_DIR}/obj/util/libutil.a"
				"${CRASHPAD_BUILD_DIR}/obj/third_party/mini_chromium/mini_chromium/base/libbase.a"
		)
	endif()

	add_custom_command(
			OUTPUT ${CRASHPAD_OUTPUTS}
			COMMAND ninja -C .
			WORKING_DIRECTORY "${CRASHPAD_BUILD_DIR}"
			COMMENT "Crashpad build files generated"
	)

	add_custom_target(Crashpad_build DEPENDS ${CRASHPAD_OUTPUTS})

	add_library(${TARGET_NAME} STATIC IMPORTED GLOBAL)
	add_dependencies(${TARGET_NAME} Crashpad_build)

	target_include_directories(${TARGET_NAME} INTERFACE
			"${CMAKE_CURRENT_SOURCE_DIR}/crashpad"
			"${CMAKE_CURRENT_SOURCE_DIR}/crashpad/third_party/mini_chromium/mini_chromium"
			"${CRASHPAD_BUILD_DIR}/gen")
	target_link_libraries(${TARGET_NAME} INTERFACE ${CRASHPAD_OUTPUTS})
	set_target_properties(${TARGET_NAME} PROPERTIES CRASHPAD_EXECUTABLE_NAME "crashpad_handler${CMAKE_EXECUTABLE_SUFFIX}")
	if(WIN32)
		target_link_libraries(${TARGET_NAME} INTERFACE advapi32)
		set_target_properties(${TARGET_NAME} PROPERTIES
				IMPORTED_LOCATION "${CRASHPAD_BUILD_DIR}/obj/client/client.lib")
	else()
		set_target_properties(${TARGET_NAME} PROPERTIES
			IMPORTED_LOCATION "${CRASHPAD_BUILD_DIR}/obj/client/libclient.a"
		)
	endif()
	set_target_properties(${TARGET_NAME} PROPERTIES
			CRASHPAD_BIN_DIR "${CRASHPAD_BUILD_DIR}"
			CRASHPAD_BUILD_DIR "${CRASHPAD_BUILD_DIR}"
			CRASHPAD_GEN_DIR "${CRASHPAD_BUILD_DIR}/gen"
			CRASHPAD_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/crashpad"
			CRASHPAD_LIB_DIR "${CRASHPAD_BUILD_DIR}/obj"
			CRASHPAD_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/crashpad"
	)

	set(HAVE_CRASH_HANDLER 1)

endif()