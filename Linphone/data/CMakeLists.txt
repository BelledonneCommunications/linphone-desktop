list(APPEND _LINPHONEAPP_RC_FILES data/assistant/use-app-sip-account.rc
	data/assistant/create-app-sip-account.rc
	data/assistant/use-other-sip-account.rc
	"data/image/info-logo.svg" 
	"data/image/belledonne.svg"
	"data/image/profil.svg"
	"data/image/logo.svg" 
	"data/image/login-image.svg" 
	"data/image/show.svg"
	"data/image/welcome-linphone-logo.svg"
	"data/image/welcome-lock.svg"
	"data/image/welcome-opensource.svg"
	"data/image/hide.svg"
	"data/image/down-arrow.svg"
	"data/image/return-arrow.svg"
)

set(_LINPHONEAPP_RC_FILES ${_LINPHONEAPP_RC_FILES} PARENT_SCOPE)
