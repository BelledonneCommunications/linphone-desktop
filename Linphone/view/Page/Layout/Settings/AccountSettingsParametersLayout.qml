import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import Linphone
import SettingsCpp 1.0
import UtilsCpp
import ConstantsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

AbstractSettingsLayout {
    id: mainItem
    width: parent?.width
    property bool registrarUriIsValid
    property bool outboundProxyIsValid
    contentModel: [{
            "title": qsTr("settings_title"),
            "subTitle": "",
            "contentComponent": generalParametersComponent
        }, {
            "title": qsTr("settings_account_title"),
            "subTitle": "",
            "contentComponent": advancedParametersComponent
        }]

    property alias account: mainItem.model

    onSave: {
        account.core.save()
    }
    onUndo: account.core.undo()
    Connections {
        enabled: account
        target: account ? account.core : null
        function onIsSavedChanged() {
            console.log("saved changed", account.core.isSaved)
            if (account.core.isSaved) {
                UtilsCpp.showInformationPopup(qsTr("information_popup_success_title"),
                            //: "Modifications sauvegardés"
                            qsTr("contact_editor_saved_changes_toast"), true, mainWindow)
            }
        }
        function onSetValueFailed(error) {
            if (error) {
                UtilsCpp.showInformationPopup(
                            qsTr("information_popup_error_title"), error, false, mainWindow)
            }
        }
    }

    // General parameters
    /////////////////////
    Component {
        id: generalParametersComponent
        ColumnLayout {
            id: column
            Layout.fillWidth: true
            spacing: Utils.getSizeWithScreenRatio(20)
            DecoratedTextField {
                id: mwiServerAddressField
                propertyName: "mwiServerAddress"
                propertyOwnerGui: account
                //: "MWI server address"
                title: qsTr("account_settings_mwi_uri_title")
                Layout.fillWidth: true
                //: Address of the MWI server that sends SIP notifications to display new voicemail indicators
                tooltip: qsTr("mwi_server_address_tooltip")
                isValid: function (text) {
                    return text.length == 0 || !text.endsWith(".")
                } // work around sdk crash when adress ends with .
                toValidate: true

                Connections {
                    enabled: account
                    target: account ? account.core : null
                    function onMwiServerAddressChanged() {
                        if (mwiServerAddressField.text != mwiServerAddressField.propertyOwnerGui.core[mwiServerAddressField.propertyName]) 
                            mwiServerAddressField.text = mwiServerAddressField.propertyOwnerGui.core[mwiServerAddressField.propertyName]
                    }
                }
            }
            DecoratedTextField {
                id: voicemailAddressField
                propertyName: "voicemailAddress"
                propertyOwnerGui: account
                //: "Voicemail address"
                title: qsTr("account_settings_voicemail_uri_title")
                //: SIP address dialed when clicking the voicemail button
                tooltip: qsTr("voicemail_address_tooltip")
                Layout.fillWidth: true
                toValidate: true

                Connections {
                    enabled: account
                    target: account ? account.core : null
                    function onVoicemailAddressChanged() {
                        if (voicemailAddressField.text != voicemailAddressField.propertyOwnerGui.core[voicemailAddressField.propertyName]) 
                            voicemailAddressField.text = voicemailAddressField.propertyOwnerGui.core[voicemailAddressField.propertyName]
                    }
                }
            }
        }
    }

    // Advanced parameters
    /////////////////////
    Component {
        id: advancedParametersComponent
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Utils.getSizeWithScreenRatio(20)
            DecoratedTextField {
                id: registrarUriField
                Layout.fillWidth: true
                //:"Registrar URI"
                title: qsTr("account_settings_registrar_uri_title")
                propertyName: "registrarUri"
                propertyOwnerGui: account
                toValidate: true
                Connections {
                    enabled: account
                    target: account ? account.core : null
                    function onRegistrarUriChanged() {
                        if (registrarUriField.text != registrarUriField.propertyOwnerGui.core[registrarUriField.propertyName]) 
                            registrarUriField.text = registrarUriField.propertyOwnerGui.core[registrarUriField.propertyName]
                    }
                }
            }
            DecoratedTextField {
                id: outboundProxyUriField
                Layout.fillWidth: true
                //:"Outbound SIP Proxy URI"
                title: qsTr("account_settings_sip_proxy_url_title")
                propertyName: "outboundProxyUri"
                propertyOwnerGui: account
                //: "If this field is filled, the outbound proxy will be enabled automatically. Leave it empty to disable it."
                tooltip: qsTr("login_proxy_server_url_tooltip")
                toValidate: true
                Connections {
                    enabled: account
                    target: account ? account.core : null
                    function onOutboundProxyUriChanged() {
                        if (outboundProxyUriField.text != outboundProxyUriField.propertyOwnerGui.core[outboundProxyUriField.propertyName]) 
                            outboundProxyUriField.text = outboundProxyUriField.propertyOwnerGui.core[outboundProxyUriField.propertyName]
                    }
                }
            }
            DecoratedTextField {
                id: stunServerField
                Layout.fillWidth: true
                propertyName: "stunServer"
                propertyOwnerGui: account
                //: "Adresse du serveur STUN"
                title: qsTr("account_settings_stun_server_url_title")
                toValidate: true
                Connections {
                    enabled: account
                    target: account ? account.core : null
                    function onStunServerChanged() {
                        if (stunServerField.text != stunServerField.propertyOwnerGui.core[stunServerField.propertyName]) 
                            stunServerField.text = stunServerField.propertyOwnerGui.core[stunServerField.propertyName]
                    }
                }
            }
            SwitchSetting {
                id: iceSwitch
                //: "Activer ICE"
                titleText: qsTr("account_settings_enable_ice_title")
                propertyName: "iceEnabled"
                propertyOwnerGui: account
                Connections {
                    enabled: account
                    target: account ? account.core : null
                    function onIceEnabledChanged() {
                        if (iceSwitch.checked != iceSwitch.propertyOwnerGui.core[iceSwitch.propertyName]) 
                            iceSwitch.checked = iceSwitch.propertyOwnerGui.core[iceSwitch.propertyName]
                    }
                }
            }
            SwitchSetting {
                id: avpfSwitch
                //: "AVPF"
                titleText: qsTr("account_settings_avpf_title")
                propertyName: "avpfEnabled"
                propertyOwnerGui: account
                Connections {
                    enabled: account
                    target: account ? account.core : null
                    function onAvpfEnabledChanged() {
                        if (avpfSwitch.checked != avpfSwitch.propertyOwnerGui.core[avpfSwitch.propertyName]) 
                            avpfSwitch.checked = avpfSwitch.propertyOwnerGui.core[avpfSwitch.propertyName]
                    }
                }
            }
            SwitchSetting {
                id: bundleModeSwitch
                //: "Mode bundle"
                titleText: qsTr("account_settings_bundle_mode_title")
                propertyName: "bundleModeEnabled"
                propertyOwnerGui: account
                Connections {
                    enabled: account
                    target: account ? account.core : null
                    function onBundleModeEnabledChanged() {
                        if (bundleModeSwitch.checked != bundleModeSwitch.propertyOwnerGui.core[bundleModeSwitch.propertyName]) 
                            bundleModeSwitch.checked = bundleModeSwitch.propertyOwnerGui.core[bundleModeSwitch.propertyName]
                    }
                }
            }
            DecoratedTextField {
                id: expireField
                Layout.fillWidth: true
                propertyName: "expire"
                propertyOwnerGui: account
                //: "Expiration (en seconde)"
                title: qsTr("account_settings_expire_title")
                canBeEmpty: false
                isValid: function (text) {
                    return !isNaN(Number(text))
                }
                toValidate: true
                Connections {
                    target: account ? account.core : null
                    function onExpireChanged() {
                        if (expireField.text != expireField.propertyOwnerGui.core[expireField.propertyName]) 
                            expireField.text = expireField.propertyOwnerGui.core[expireField.propertyName]
                    }
                }
            }
            DecoratedTextField {
                id: conferenceFactoryUriField
                Layout.fillWidth: true
                //: "URI du serveur de conversations"
                title: qsTr("account_settings_conference_factory_uri_title")
                propertyName: "conferenceFactoryAddress"
                propertyOwnerGui: account
                toValidate: true
                Connections {
                    target: account ? account.core : null
                    function onConferenceFactoryAddressChanged() {
                        if (conferenceFactoryUriField.text != conferenceFactoryUriField.propertyOwnerGui.core[conferenceFactoryUriField.propertyName]) 
                            conferenceFactoryUriField.text = conferenceFactoryUriField.propertyOwnerGui.core[conferenceFactoryUriField.propertyName]
                    }
                }
            }
            DecoratedTextField {
                id: audioVideoConfUriField
                Layout.fillWidth: true
                propertyName: "audioVideoConferenceFactoryAddress"
                //: "URI du serveur de réunions"
                title: qsTr("account_settings_audio_video_conference_factory_uri_title")
                propertyOwnerGui: account
                toValidate: true
                Connections {
                    target: account ? account.core : null
                    function onAudioVideoConferenceFactoryAddressChanged() {
                        if (audioVideoConfUriField.text != audioVideoConfUriField.propertyOwnerGui.core[audioVideoConfUriField.propertyName]) 
                            audioVideoConfUriField.text = audioVideoConfUriField.propertyOwnerGui.core[audioVideoConfUriField.propertyName]
                    }
                }
            }
            DecoratedTextField {
                id: limeServerUrlField
                Layout.fillWidth: true
                //: "URL du serveur d’échange de clés de chiffrement"
                title: qsTr("account_settings_lime_server_url_title")
                propertyName: "limeServerUrl"
                propertyOwnerGui: account
                toValidate: true
                Connections {
                    target: account ? account.core : null
                    function onLimeServerUrlChanged() {
                        if (limeServerUrlField.text != limeServerUrlField.propertyOwnerGui.core[limeServerUrlField.propertyName]) 
                            limeServerUrlField.text = limeServerUrlField.propertyOwnerGui.core[limeServerUrlField.propertyName]
                    }
                }
            }
            DecoratedTextField {
                Layout.fillWidth: true
                //: "URL du serveur CCMP"
                title: qsTr("account_settings_ccmp_server_url_title")
                propertyName: "ccmpServerUrl"
                propertyOwnerGui: account
                toValidate: true
            }
        }
    }
}
