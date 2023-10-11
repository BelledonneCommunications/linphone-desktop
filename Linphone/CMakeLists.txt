cmake_minimum_required(VERSION 3.16)

project(Linphone VERSION 0.1 LANGUAGES CXX)

################################################################
#						PACKAGES
################################################################
set(LINPHONE_PACKAGES LinphoneCxx)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules")
foreach(PACKAGE ${LINPHONE_PACKAGES})
	message(STATUS "Trying to find ${PACKAGE}")
	find_package(${PACKAGE} REQUIRED)
	if(NOT ${PACKAGE}_FOUND)
		find_package(${PACKAGE} CONFIG REQUIRED)
	endif()
endforeach()


set(TARGET_NAME Linphone)
set(APP_TARGETS ${LinphoneCxx_TARGET})


set(QT_DEFAULT_MAJOR_VERSION 6)
set(QT_PACKAGES Core Quick Qml Widgets)# Search Core at first for initialize Qt scripts for next find_packages.
if (UNIX AND NOT APPLE)
	list(APPEND QT_PACKAGES DBus)
endif()
find_package(Qt6 REQUIRED COMPONENTS Core)	
find_package(Qt6 REQUIRED COMPONENTS ${QT_PACKAGES})

################################################################
#						CONFIGS
################################################################
if(NOT WIN32)
	add_compile_options(-Werror=deprecated-declarations)
endif()
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)#useful for config.h
include(application_info.cmake)

if(APPLE)
	if(MS2_PLUGINS_LOCATION)
		set(MSPLUGINS_DIR ${MS2_PLUGINS_LOCATION})
	else()
		set(MSPLUGINS_DIR "Frameworks/mediastreamer2.framework/Versions/A/Libraries")
	endif()
else()
	set(MSPLUGINS_DIR "plugins/mediastreamer")
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

add_subdirectory(data)
add_subdirectory(tool)
add_subdirectory(model)
add_subdirectory(view)
add_subdirectory(core)

qt6_add_executable(Linphone
    ${_LINPHONEAPP_SOURCES}
)

qt6_add_qml_module(Linphone
    URI Linphone
    RESOURCE_PREFIX ""
    VERSION 1.0
    QML_FILES ${_LINPHONEAPP_QML_FILES}
)

qt_add_resources(Linphone
	PREFIX "/"
	FILES ${_LINPHONEAPP_RC_FILES}
)
################################################################
#						TARGETS LINKS
################################################################

set_target_properties(${TARGET_NAME} PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER org.linphone
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    OUTPUT_NAME "${EXECUTABLE_NAME}"
	ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}
	LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}
	RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}

)
if(MSVC)
	set_target_properties(${TARGET_NAME} PROPERTIES PDB_NAME "${EXECUTABLE_NAME}_app")
endif()

foreach(T ${APP_TARGETS})
	target_include_directories(${TARGET_NAME} SYSTEM PUBLIC  $<TARGET_PROPERTY:${T},INTERFACE_INCLUDE_DIRECTORIES>)
	target_link_libraries(${TARGET_NAME} PUBLIC ${T})
endforeach()

foreach(T ${QT_PACKAGES})
	target_link_libraries(${TARGET_NAME} PRIVATE Qt6::${T})
endforeach()

################################################################
#						INSTALL
################################################################


install(TARGETS ${TARGET_NAME}
    BUNDLE DESTINATION .
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(ENABLE_APP_PACKAGE_ROOTCA)
	install(FILES "${LINPHONE_OUTPUT_DIR}/share/linphone/rootca.pem" DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/${EXECUTABLE_NAME}")
endif()
