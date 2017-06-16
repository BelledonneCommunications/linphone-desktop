# ==============================================================================
# assets/languages/clean_translations.cmake
# ==============================================================================

if (WIN32)
  foreach (lang ${LANGUAGES})
    file(READ "${lang}.ts" content)
    set(cleanedContent)
    string(REPLACE "\r" "" cleanedContent "${content}")
    file(WRITE "${lang}.ts" "${cleanedContent}")
  endforeach ()
endif ()
