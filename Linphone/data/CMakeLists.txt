list(APPEND _LINPHONEAPP_RC_FILES data/assistant/use-app-sip-account.rc
	data/assistant/create-app-sip-account.rc
	data/assistant/use-other-sip-account.rc
	data/shaders/roundEffect.frag.qsb
	data/emoji/emoji.json
)

file(GLOB files LIST_DIRECTORIES false  image/*)
foreach(f ${files})
	get_filename_component(filename  ${f} NAME)
	list(APPEND _LINPHONEAPP_RC_FILES data/image/${filename})
endforeach()

file(GLOB files LIST_DIRECTORIES false  emoji/emojiSvgs/*)
foreach(f ${files})
	get_filename_component(filename  ${f} NAME)
	list(APPEND _LINPHONEAPP_RC_FILES data/emoji/emojiSvgs/${filename})
endforeach()

file(GLOB files LIST_DIRECTORIES false  emoji/icons/*)
foreach(f ${files})
	get_filename_component(filename  ${f} NAME)
	list(APPEND _LINPHONEAPP_RC_FILES data/emoji/icons/${filename})
endforeach()

#file(GLOB files LIST_DIRECTORIES false  languages/*)
#foreach(f ${files})
#        get_filename_component(filename  ${f} NAME)
#        list(APPEND _LINPHONEAPP_RC_FILES data/languages/${filename})
#endforeach()
set(_LINPHONEAPP_RC_FILES ${_LINPHONEAPP_RC_FILES} PARENT_SCOPE)
