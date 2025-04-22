cmake_minimum_required(VERSION 3.16)

project(Linphone VERSION 6.1.0 LANGUAGES CXX)

################################################################
#						PACKAGES
################################################################
set(LINPHONE_PACKAGES Mediastreamer2 LinphoneCxx BCToolbox LibLinphone)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules")
foreach(PACKAGE ${LINPHONE_PACKAGES})
	message(STATUS "Trying to find ${PACKAGE}")
	find_package(${PACKAGE} REQUIRED)
	if(NOT ${PACKAGE}_FOUND)
		find_package(${PACKAGE} CONFIG REQUIRED)
	endif()
endforeach()


set(TARGET_NAME Linphone)
set(APP_TARGETS ${LinphoneCxx_TARGET}
				${Mediastreamer2_TARGET}#MediastreamerUtils
				${LibLinphone_TARGET})#MediastreamerUtils

set(QT_DEFAULT_MAJOR_VERSION 6)
set(QT_PACKAGES Core Quick Qml Widgets Svg Multimedia Test NetworkAuth Concurrent)# Search Core at first for initialize Qt scripts for next find_packages.
if (UNIX AND NOT APPLE)
	list(APPEND QT_PACKAGES DBus)
endif()
find_package(Qt6 REQUIRED COMPONENTS Core)	
find_package(Qt6 REQUIRED COMPONENTS ${QT_PACKAGES})
find_package(Qt6 REQUIRED COMPONENTS LinguistTools)

if(NOT WIN32)
	find_package(X11)
endif()

if(X11_FOUND)
	list(APPEND APP_TARGETS X11::X11)
endif()

################################################################
#						CONFIGS
################################################################
if(NOT WIN32)
	add_compile_options(-Werror=deprecated-declarations)
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -DNDEBUG -DQT_NO_DEBUG")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -DQT_QML_DEBUG -DQT_DECLARATIVE_DEBUG")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG -DQT_QML_DEBUG -DQT_DECLARATIVE_DEBUG" )
set(CMAKE_INCLUDE_CURRENT_DIR ON)#useful for config.h


if(NOT LINPHONEAPP_VERSION)
	bc_compute_full_version(LINPHONEAPP_VERSION)
endif()

set(LINPHONE_MAJOR_VERSION)
set(LINPHONE_MINOR_VERSION)
set(LINPHONE_MICRO_VERSION)
set(LINPHONE_BRANCH_VERSION)
bc_parse_full_version(${LINPHONEAPP_VERSION} LINPHONE_MAJOR_VERSION LINPHONE_MINOR_VERSION LINPHONE_MICRO_VERSION LINPHONE_BRANCH_VERSION)

set(LINPHONEAPP_SHORT_VERSION "${LINPHONE_MAJOR_VERSION}.${LINPHONE_MINOR_VERSION}.${LINPHONE_MICRO_VERSION}")

set(GIT_BRANCH_NAME)
execute_process(
    COMMAND git name-rev --name-only HEAD
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    OUTPUT_VARIABLE GIT_BRANCH_NAME
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(LINPHONESDK_VERSION)
execute_process(
    COMMAND git describe
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/external/linphone-sdk
    OUTPUT_VARIABLE LINPHONESDK_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

include(application_info.cmake)
string(TIMESTAMP CURRENT_YEAR "%Y")
if(NOT APPLICATION_START_LICENCE OR "${CURRENT_YEAR}" STREQUAL "${APPLICATION_START_LICENCE}")
	set(COPYRIGHT_RANGE_DATE "${APPLICATION_START_LICENCE}")
else()
	set(COPYRIGHT_RANGE_DATE "${APPLICATION_START_LICENCE}-${CURRENT_YEAR}")
endif()


if(MEDIASTREAMER2_PLUGINS_LOCATION)
	set(MSPLUGINS_DIR ${MEDIASTREAMER2_PLUGINS_LOCATION})
elseif(APPLE)
	set(MSPLUGINS_DIR "Frameworks/mediastreamer2.framework/Versions/A/Libraries")
else()
	set(MSPLUGINS_DIR "${CMAKE_INSTALL_LIBDIR}/mediastreamer/plugins")
endif()

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/config.h.cmake" "${CMAKE_CURRENT_BINARY_DIR}/config.h")

if(${Qt6_VERSION} VERSION_LESS "6.3.0")
	set(CMAKE_AUTOMOC ON)
	set(CMAKE_AUTORCC ON)
	set(CMAKE_AUTOUIC ON)
else()
	qt6_standard_project_setup()
endif()




################################################################
#						SOURCES
################################################################


set(_LINPHONEAPP_SOURCES main.cpp)
set(_LINPHONEAPP_QML_FILES)
set(_LINPHONEAPP_RC_FILES)
set(_LINPHONEAPP_QML_SINGLETONS)

add_subdirectory(data)
add_subdirectory(tool)
add_subdirectory(model)
add_subdirectory(view)
add_subdirectory(core)

set(LANGUAGES_DIRECTORY "data/languages")
set(I18N_FILENAME i18n.qrc)
set(LANGUAGES en fr_FR de)

# Add languages support.
add_subdirectory("${LANGUAGES_DIRECTORY}" "data/languages")

qt_standard_project_setup(I18N_TRANSLATED_LANGUAGES ${LANGUAGES})

set(TS_FILES)
foreach (lang ${LANGUAGES})
  list(APPEND TS_FILES "${CMAKE_CURRENT_SOURCE_DIR}/${LANGUAGES_DIRECTORY}/${lang}.ts")
endforeach()

qt_add_translations(${TARGET_NAME}
TS_FILES ${TS_FILES}
RESOURCE_PREFIX ${LANGUAGES_DIRECTORY})

# set application details
if(WIN32)
	configure_file("${CMAKE_SOURCE_DIR}/cmake/install/windows/appDetailsWindows.rc.in" "${CMAKE_CURRENT_BINARY_DIR}/appDetailsWindows.rc")
	set(_APPDETAILS_RC_FILE ${CMAKE_CURRENT_BINARY_DIR}/appDetailsWindows.rc)
endif()

#fonts.qrc is in data and not in data/font because we want to use 'font' in path and not in prefix.
#TODO make prefix working
set(_LINPHONEAPP_FONTS_FILES)
qt6_add_big_resources(_LINPHONEAPP_FONTS_FILES data/fonts.qrc)

# Have big_resource.qrc treated as a source file by Qt Creator
list(APPEND _LINPHONEAPP_FONTS_FILES data/fonts.qrc)
set_property(SOURCE data/fonts.qrc PROPERTY SKIP_AUTORCC ON)

qt6_add_executable(Linphone
	${_LINPHONEAPP_SOURCES}
	${_LINPHONEAPP_FONTS_FILES}
	${_APPDETAILS_RC_FILE}
)

set_source_files_properties(${_LINPHONEAPP_QML_SINGLETONS} PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_policy(SET QTP0001 NEW)
qt6_add_qml_module(Linphone
    URI Linphone
    VERSION 1.0
    QML_FILES ${_LINPHONEAPP_QML_FILES} ${_LINPHONEAPP_QML_SINGLETONS}
    RESOURCES data/fonts.qrc
)

qt6_add_resources(Linphone "resources" PREFIX "/" FILES ${_LINPHONEAPP_RC_FILES})
set_property(TARGET Linphone PROPERTY POSITION_INDEPENDENT_CODE ON)   #Need by Qt

################################################################
#						TARGETS LINKS
################################################################
if(APPLE)
	configure_file("${CMAKE_SOURCE_DIR}/cmake/install/macos/Info.plist.in" "${CMAKE_BINARY_DIR}/cmake/install/macos/Info.plist" @ONLY)
endif()
set_target_properties(${TARGET_NAME} PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER org.linphone
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_INFO_PLIST ${CMAKE_BINARY_DIR}/cmake/install/macos/Info.plist
    WIN32_EXECUTABLE TRUE
    OUTPUT_NAME "${EXECUTABLE_NAME}"
# Added for Qt to set the correct path on run configurations.
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}"
)
if(MSVC)
	set_target_properties(${TARGET_NAME} PROPERTIES PDB_NAME "${EXECUTABLE_NAME}_app")
endif()

if(WIN32)
	if(ENABLE_SCREENSHARING)
		target_link_libraries(${TARGET_NAME} PUBLIC Dwmapi)
	endif()
elseif (APPLE)
	target_link_libraries(${TARGET_NAME} PUBLIC "-framework Cocoa" "-framework IOKit" "-framework AVFoundation" "-framework ScreenCaptureKit")
endif()


foreach(T ${APP_TARGETS})
	target_include_directories(${TARGET_NAME} SYSTEM PUBLIC  $<TARGET_PROPERTY:${T},INTERFACE_INCLUDE_DIRECTORIES>)
	target_link_libraries(${TARGET_NAME} PUBLIC ${T})
endforeach()

foreach(T ${QT_PACKAGES})
	target_link_libraries(${TARGET_NAME} PRIVATE Qt6::${T})
endforeach()


