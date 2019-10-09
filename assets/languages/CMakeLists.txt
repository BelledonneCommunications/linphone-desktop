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

  #Clean existing generated file
  file(REMOVE "${QM_FILES_OUTPUT_DIR}/${lang}.qm")
  #Force re-interpretation of ts files
  file(TOUCH "${CMAKE_CURRENT_SOURCE_DIR}/${lang}.ts")

  list(APPEND TS_FILES "${CMAKE_CURRENT_SOURCE_DIR}/${lang}.ts")
endforeach()
set(I18N_CONTENT "${I18N_CONTENT}  </qresource>\n</RCC>\n")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${I18N_FILENAME}" "${I18N_CONTENT}")

# Workaround: Create empty files for some cmake versions. Otherwise, the qm rules can't be used.
foreach (qm ${QM_FILES})
  if (NOT EXISTS "${qm}")
    file(GENERATE OUTPUT "${qm}" CONTENT "")
  endif()
endforeach()

#qt5 macro: creates or updates ts files from translation routines from all sources files (h,cpp,qml)
#Then creates `qm` files from `ts` files which are referenced by the i18n qrc files
qt5_create_translation(QM_FILES ${TS_FILES} ${SOURCES} ${HEADERS} ${QML_SOURCES} OPTIONS -no-obsolete)

# Update translations.
add_custom_target(update_translations
  COMMAND ${CMAKE_COMMAND} "-DLANGUAGES=\"${LANGUAGES}\"" -P "${CMAKE_CURRENT_SOURCE_DIR}/clean_translations.cmake"
  DEPENDS ${QM_FILES}
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
)

# Remove `*.qm` when `clean` is called.
set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${QM_FILES}")
