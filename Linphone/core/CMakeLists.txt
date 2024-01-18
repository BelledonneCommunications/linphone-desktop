list(APPEND _LINPHONEAPP_SOURCES
	core/account/AccountCore.cpp
	core/account/AccountGui.cpp
	core/account/AccountList.cpp
	core/account/AccountProxy.cpp
	core/App.cpp
	core/call/CallCore.cpp
	core/call/CallGui.cpp
	core/call/CallList.cpp
	core/call/CallProxy.cpp
	core/call-history/CallHistoryCore.cpp
	core/call-history/CallHistoryGui.cpp
	core/call-history/CallHistoryList.cpp
	core/call-history/CallHistoryProxy.cpp
	core/camera/CameraGui.cpp
	core/camera/CameraDummy.cpp
	core/friend/FriendCore.cpp
	core/friend/FriendGui.cpp
	core/friend/FriendInitialProxy.cpp
	core/logger/QtLogger.cpp
	core/login/LoginPage.cpp
	core/notifier/Notifier.cpp
	core/path/Paths.cpp
	core/phone-number/PhoneNumber.cpp
	core/phone-number/PhoneNumberList.cpp
	core/phone-number/PhoneNumberProxy.cpp
	
	core/search/MagicSearchList.cpp
	core/search/MagicSearchProxy.cpp
	
	core/setting/Settings.cpp
	
	core/proxy/ListProxy.cpp
	core/proxy/Proxy.cpp
	core/proxy/SortFilterProxy.cpp
	
	core/variant/VariantList.cpp
)

## Single Application
if(APPLE OR WIN32)
	list(APPEND _LINPHONEAPP_SOURCES core/singleapplication/singleapplication.cpp
		core/singleapplication/singleapplication_p.cpp)
else() # Use QDBus for Linux
	list(APPEND _LINPHONEAPP_SOURCES
		core/singleapplication/singleapplication.h	#Added for Moc
		core/singleapplication/SingleApplicationDBusPrivate.hpp
		core/singleapplication/SingleApplicationDBus.cpp)
endif()

set(_LINPHONEAPP_SOURCES ${_LINPHONEAPP_SOURCES} PARENT_SCOPE)
