# ==============================================================================
# assets/languages/CMakeLists.txt
# ==============================================================================

# This line prevent `.ts` files deletion.
# See: https://bugreports.qt.io/browse/QTBUG-31860
#
# On October 17, 2016, this issue was marked `invalid` but it's a
# bullshit. It's not tolerated to remove sources files.
set_directory_properties(PROPERTIES CLEAN_NO_CUSTOM true)

# Build languages resource file.
set(TS_FILES)
set(I18N_CONTENT "<!DOCTYPE RCC>\n<RCC version=\"1.0\">\n  <qresource prefix=\"/\">\n")
foreach (lang ${LANGUAGES})
  list(APPEND TS_FILES "${CMAKE_CURRENT_SOURCE_DIR}/${lang}.ts")

  # Note: the below `languages/` path is not the same as the `${LANGUAGES_DIRECTORY}` value.
  # It's the symbolic path used by the linphone binary in the qrc model.
  # This path is used in `app.cpp`.
  set(I18N_CONTENT "${I18N_CONTENT}    <file alias=\"languages/${lang}\">${lang}.qm</file>\n")
endforeach ()
set(I18N_CONTENT "${I18N_CONTENT}  </qresource>\n</RCC>\n")

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${I18N_FILENAME}" "${I18N_CONTENT}")

# Create `qm` files from `ts` files.
qt5_create_translation(QM_FILES ${TS_FILES} ${SOURCES} ${HEADERS} ${QML_SOURCES} OPTIONS -no-obsolete)

# Update translations.
add_custom_target(update_translations
  COMMAND ${CMAKE_COMMAND} "-DLANGUAGES=\"${LANGUAGES}\"" -P "${CMAKE_CURRENT_SOURCE_DIR}/clean_translations.cmake"
  DEPENDS ${QM_FILES}
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
)

# Remove `*.qm` when `clean` is called.
set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${QM_FILES}")

# Command to just remove `.qm` files.
add_custom_target(remove_qm_files
  COMMAND ${CMAKE_COMMAND} -E remove ${QM_FILES}
)
