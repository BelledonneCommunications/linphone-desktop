
add_subdirectory(linphone-sdk/)
if(ENABLE_QT_KEYCHAIN)
    find_package(Qt6 REQUIRED COMPONENTS Test)
    add_subdirectory(qtkeychain/)
endif()
add_subdirectory(google)