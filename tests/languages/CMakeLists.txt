# Build languages resource file.
set(TS_FILES)
set(I18N_CONTENT "<!DOCTYPE RCC>\n<RCC version=\"1.0\">\n  <qresource prefix=\"/\">\n")
foreach (lang ${LANGUAGES})
  list(APPEND TS_FILES "${CMAKE_SOURCE_DIR}/${LANGUAGES_DIRECTORY}/${lang}.ts")

  # Note: the below `languages/` path is not the same as the `${LANGUAGES_DIRECTORY}` value.
  # It's the symbolic path used by the linphone binary in the qrc model.
  # This path is used in `app.cpp`.
  set(I18N_CONTENT "${I18N_CONTENT}    <file alias=\"languages/${lang}\">${lang}.qm</file>\n")
endforeach ()
set(I18N_CONTENT "${I18N_CONTENT}  </qresource>\n</RCC>\n")

file(WRITE "${CMAKE_BINARY_DIR}/${LANGUAGES_DIRECTORY}/${I18N_FILENAME}" "${I18N_CONTENT}")

# --------------------------------------------------------------------

# Prevent `.ts` files deletion.
# See: https://bugreports.qt.io/browse/QTBUG-31860
#
# On October 17, 2016, this issue is marked `invalid` but it's a
# bullshit. It's not tolerated to remove sources files.
set_directory_properties(PROPERTIES CLEAN_NO_CUSTOM true)

# Create `qm` files from `ts` files.
qt5_create_translation(QM_FILES ${TS_FILES} ${SOURCES} ${HEADERS})
add_custom_target(update_translations DEPENDS ${QM_FILES})
