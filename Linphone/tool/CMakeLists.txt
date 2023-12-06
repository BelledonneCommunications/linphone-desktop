list(APPEND _LINPHONEAPP_SOURCES
	tool/Constants.cpp
	tool/EnumsToString.cpp
	tool/Utils.cpp

	tool/LinphoneEnums.cpp
	tool/thread/SafeSharedPointer.hpp
	tool/thread/SafeConnection.hpp
	tool/thread/Thread.cpp
	tool/providers/AvatarProvider.cpp
	tool/providers/ImageProvider.cpp
)

set(_LINPHONEAPP_SOURCES ${_LINPHONEAPP_SOURCES} PARENT_SCOPE)


