list(APPEND _LINPHONEAPP_SOURCES
	model/account/AccountModel.cpp
	model/account/AccountManager.cpp
	
	model/call/CallModel.cpp

	model/core/CoreModel.cpp
	
	model/listener/Listener.hpp
	
	model/logger/LoggerModel.cpp
	model/logger/LoggerListener.cpp
	
	model/object/VariantObject.cpp
	
	model/setting/SettingsModel.cpp
	
	model/tool/ToolModel.cpp
)

set(_LINPHONEAPP_SOURCES ${_LINPHONEAPP_SOURCES} PARENT_SCOPE)
