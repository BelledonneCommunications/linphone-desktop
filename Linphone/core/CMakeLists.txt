list(APPEND _LINPHONEAPP_SOURCES
	core/App.cpp
	core/logger/QtLogger.cpp
	core/login/LoginPage.cpp
	core/path/Paths.cpp
	core/setting/Settings.cpp
	core/thread/Thread.cpp
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
