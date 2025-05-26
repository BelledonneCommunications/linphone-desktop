
add_subdirectory(linphone-sdk/)
if(ENABLE_QT_KEYCHAIN)
    function(add_linphone_keychain)
        add_subdirectory(qtkeychain/)
    endfunction()
    add_linphone_keychain()
endif()