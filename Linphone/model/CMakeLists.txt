list(APPEND _LINPHONEAPP_SOURCES
	model/account/AccountDeviceModel.cpp
	model/account/AccountModel.cpp
	model/account/AccountManager.cpp
	model/account/AccountManagerServicesModel.cpp
	model/account/AccountManagerServicesRequestModel.cpp

	model/auth/OIDCModel.cpp
	
	model/call/CallModel.cpp

	model/call-history/CallHistoryModel.cpp
	
    model/chat/ChatModel.cpp
    model/chat/message/ChatMessageModel.cpp

	model/conference/ConferenceInfoModel.cpp
	model/conference/ConferenceModel.cpp
	model/conference/ConferenceSchedulerModel.cpp

	model/participant/ParticipantDeviceModel.cpp
	model/participant/ParticipantModel.cpp

	model/cli/CliModel.cpp
	model/core/CoreModel.cpp
	
	model/friend/FriendModel.cpp
	model/friend/FriendsManager.cpp

	model/listener/Listener.hpp
	
	model/logger/LoggerModel.cpp
	model/logger/LoggerListener.cpp
	
	model/object/SafeObject.cpp
	model/object/VariantObject.cpp
	
	model/search/MagicSearchModel.cpp
	
	model/setting/SettingsModel.cpp
	model/setting/MediastreamerUtils.cpp

	
	model/tool/ToolModel.cpp

	model/videoSource/VideoSourceDescriptorModel.cpp
	
	model/address-books/ldap/LdapModel.cpp
	model/address-books/carddav/CarddavModel.cpp
	model/payload-type/PayloadTypeModel.cpp
	model/payload-type/DownloadablePayloadTypeModel.cpp

)

set(_LINPHONEAPP_SOURCES ${_LINPHONEAPP_SOURCES} PARENT_SCOPE)
