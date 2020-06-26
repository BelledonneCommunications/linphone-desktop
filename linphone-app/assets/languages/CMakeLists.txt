# ==============================================================================
# assets/languages/CMakeLists.txt
# ==============================================================================

# This line prevent `.ts` files deletion.
# See: https://bugreports.qt.io/browse/QTBUG-31860
#
# On October 17, 2016, this issue was marked `invalid` but it's a
# bullshit. It's not tolerated to remove source files.
set_directory_properties(PROPERTIES CLEAN_NO_CUSTOM true)

# Build languages resource file.
set(TS_FILES)
set(QM_FILES)
set(QM_FILES_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}")

set(I18N_CONTENT "<!DOCTYPE RCC>\n<RCC version=\"1.0\">\n  <qresource>\n")
foreach (lang ${LANGUAGES})
  # Note: the below `languages/` path is not the same as the `${LANGUAGES_DIRECTORY}` value.
  # It's the symbolic path used by the linphone binary in the qrc model.
  # This path is used in `app.cpp`.
  set(I18N_CONTENT "${I18N_CONTENT}    <file alias=\"languages/${lang}\">${lang}.qm</file>\n")

  list(APPEND TS_FILES "${CMAKE_CURRENT_SOURCE_DIR}/${lang}.ts")
  list(APPEND TARGET_TS_FILES "${CMAKE_CURRENT_BINARY_DIR}/${lang}.ts")
  list(APPEND QM_FILES "${CMAKE_CURRENT_BINARY_DIR}/${lang}.qm")
endforeach()

set(I18N_CONTENT "${I18N_CONTENT}  </qresource>\n</RCC>\n")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${I18N_FILENAME}" "${I18N_CONTENT}")

#Files or directories to inspect for translations references
set(TRANSLATION_SOURCES)
list(APPEND TRANSLATION_SOURCES "${PROJECT_SOURCE_DIR}/src")
list(APPEND TRANSLATION_SOURCES "${PROJECT_SOURCE_DIR}/ui")

if (WIN32)
  foreach (lang ${LANGUAGES})
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/${lang}.ts" content)
    set(cleanedContent)
    string(REPLACE "\r" "" cleanedContent "${content}")
    file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/${lang}.ts" "${cleanedContent}")
  endforeach()
endif()

set(LUPDATE_OPTIONS "-no-obsolete")
set(LRELEASE_OPTIONS "")

#Clean existing generated file to force re-creation
file(REMOVE ${QM_FILES})
file(REMOVE ${TARGET_TS_FILES})
#file(REMOVE ${QRC_BIG_RESOURCES})	#Remove .o of resources before build. It is need to update resources from changes

add_custom_command(OUTPUT ${TARGET_TS_FILES}
  COMMAND ${Qt5_LUPDATE_EXECUTABLE}
  ARGS ${LUPDATE_OPTIONS} ${TRANSLATION_SOURCES} -ts ${TS_FILES}
  COMMAND ${CMAKE_COMMAND} -E copy ${TS_FILES} ${CMAKE_CURRENT_BINARY_DIR}
  VERBATIM
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  COMMENT "Updating translation source files (ts)..."
)

add_custom_command(OUTPUT ${QM_FILES}
  COMMAND ${Qt5_LRELEASE_EXECUTABLE}
  ARGS ${TARGET_TS_FILES} ${LRELEASE_OPTIONS}
  DEPENDS ${TARGET_TS_FILES}
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  VERBATIM
  COMMENT "Creating compiled translation files (qm)..."
)

#The dependency	on custom_command Output is important
add_custom_target(update_translations
  DEPENDS ${QM_FILES}
)

# Remove `*.qm` when `clean` is called.
set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${QM_FILES}")

# Workaround: Create empty files for some cmake versions. Otherwise, the qm rules can't be used.
# foreach (qm ${QM_FILES})
#   if (NOT EXISTS "${qm}")
#     file(GENERATE OUTPUT "${qm}" CONTENT "")
#   endif()
# endforeach()
