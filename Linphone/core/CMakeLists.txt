list(APPEND _LINPHONEAPP_SOURCES
	core/account/Account.cpp
	core/account/AccountList.cpp
	core/account/AccountProxy.cpp
	core/App.cpp
	core/call/Call.cpp
	core/logger/QtLogger.cpp
	core/login/LoginPage.cpp
	core/notifier/Notifier.cpp
	core/path/Paths.cpp
	core/phone-number/PhoneNumber.cpp
	core/phone-number/PhoneNumberList.cpp
	core/phone-number/PhoneNumberProxy.cpp
	
	core/setting/Settings.cpp
	
	core/proxy/ListProxy.cpp
	core/proxy/Proxy.cpp
	core/proxy/SortFilterProxy.cpp
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
