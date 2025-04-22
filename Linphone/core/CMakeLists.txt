list(APPEND _LINPHONEAPP_SOURCES
	core/account/AccountCore.cpp
	core/account/AccountGui.cpp
	core/account/AccountList.cpp
	core/account/AccountProxy.cpp
	core/account/AccountDeviceCore.cpp
	core/account/AccountDeviceGui.cpp
	core/account/AccountDeviceList.cpp
	core/account/AccountDeviceProxy.cpp
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
	core/camera/PreviewManager.cpp
	core/chat/ChatCore.cpp
	core/chat/ChatGui.cpp
	core/chat/ChatList.cpp
	core/chat/ChatProxy.cpp
	core/chat/message/ChatMessageCore.cpp
	core/chat/message/ChatMessageGui.cpp
	core/chat/message/ChatMessageList.cpp
	core/chat/message/ChatMessageProxy.cpp
	core/fps-counter/FPSCounter.cpp
	core/friend/FriendCore.cpp
	core/friend/FriendGui.cpp
	core/logger/QtLogger.cpp
	core/login/LoginPage.cpp
	core/notifier/Notifier.cpp
	core/path/Paths.cpp
	core/phone-number/PhoneNumber.cpp
	core/phone-number/PhoneNumberList.cpp
	core/phone-number/PhoneNumberProxy.cpp
	core/register/RegisterPage.cpp
	
	core/search/MagicSearchList.cpp
	core/search/MagicSearchProxy.cpp
	
	core/setting/SettingsCore.cpp
	
	core/proxy/ListProxy.cpp
	core/proxy/Proxy.cpp
	core/proxy/SortFilterProxy.cpp
	core/proxy/LimitProxy.cpp
	
	core/variant/VariantList.cpp

	core/conference/ConferenceCore.cpp
	core/conference/ConferenceGui.cpp
	core/conference/ConferenceInfoCore.cpp
	core/conference/ConferenceInfoGui.cpp
	core/conference/ConferenceInfoList.cpp
	core/conference/ConferenceInfoProxy.cpp

	core/timezone/TimeZoneList.cpp
	core/timezone/TimeZoneProxy.cpp
	core/timezone/TimeZone.cpp

	core/translator/DefaultTranslatorCore.cpp

	core/participant/ParticipantCore.cpp
	core/participant/ParticipantGui.cpp
	core/participant/ParticipantDeviceCore.cpp
	core/participant/ParticipantDeviceGui.cpp
	core/participant/ParticipantDeviceList.cpp
	core/participant/ParticipantDeviceProxy.cpp
	core/participant/ParticipantList.cpp
	core/participant/ParticipantProxy.cpp
	
	core/screen/ScreenList.cpp
	core/screen/ScreenProxy.cpp

	core/videoSource/VideoSourceDescriptorCore.cpp
	core/videoSource/VideoSourceDescriptorGui.cpp
	
	core/address-books/ldap/LdapCore.cpp
	core/address-books/ldap/LdapGui.cpp
	core/address-books/ldap/LdapProxy.cpp
	core/address-books/ldap/LdapList.cpp

	core/address-books/carddav/CarddavCore.cpp
	core/address-books/carddav/CarddavGui.cpp
	core/address-books/carddav/CarddavProxy.cpp
	core/address-books/carddav/CarddavList.cpp

	core/payload-type/PayloadTypeCore.cpp
	core/payload-type/DownloadablePayloadTypeCore.cpp
	core/payload-type/PayloadTypeGui.cpp
	core/payload-type/PayloadTypeProxy.cpp
	core/payload-type/PayloadTypeList.cpp

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
