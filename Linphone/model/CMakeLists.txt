list(APPEND _LINPHONEAPP_SOURCES
	model/account/AccountModel.cpp
	model/account/AccountManager.cpp

	model/core/CoreModel.cpp
	model/core/CoreListener.cpp
	
	model/listener/Listener.hpp
	
	model/logger/LoggerModel.cpp
	model/logger/LoggerListener.cpp
	
	model/setting/SettingsModel.cpp
)

set(_LINPHONEAPP_SOURCES ${_LINPHONEAPP_SOURCES} PARENT_SCOPE)
