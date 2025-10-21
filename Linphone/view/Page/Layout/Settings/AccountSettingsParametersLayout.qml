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
        if (!registrarUriIsValid || !outboundProxyIsValid) {
            var message = !registrarUriIsValid
            //: Registrar uri is invalid. Please make sure it matches the following format : sip:<host>:<port>;transport=<transport> (:<port> is optional)
            ? qsTr("info_popup_invalid_registrar_uri_message")
            //: Outbound proxy uri is invalid. Please make sure it matches the following format : sip:<host>:<port>;transport=<transport> (:<port> is optional)
            : qsTr("info_popup_invalid_outbound_proxy_message")
            mainWindow.showInformationPopup(qsTr("info_popup_error_title"), message, false)
        }
        else account.core.save()
    }
    onUndo: account.core.undo()
    Connections {
        target: account.core
        function onIsSavedChanged() {
            if (account.core.isSaved) {
                UtilsCpp.showInformationPopup(
                            qsTr("information_popup_success_title"),
                            //: "Modifications sauvegardés"
                            qsTr("contact_editor_saved_changes_toast"), true,
                            mainWindow)
            }
        }
        function onSetValueFailed(error) {
            if (error) {
                UtilsCpp.showInformationPopup(
                            qsTr("information_popup_error_title"),
                            error, false,
                            mainWindow)
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
                //: "URI du serveur de messagerie vocale"
                title: qsTr("account_settings_mwi_uri_title")
                Layout.fillWidth: true
                isValid: function (text) {
                    return text.length == 0 || !text.endsWith(".")
                } // work around sdk crash when adress ends with .
                toValidate: true

                Connections {
                    enabled: account
                    target: account.core
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
                //: "URI de messagerie vocale"
                title: qsTr("account_settings_voicemail_uri_title")
                Layout.fillWidth: true
                toValidate: true

                Connections {
                    enabled: account
                    target: account.core
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
            Text {
                //: "Transport"
                text: qsTr("account_settings_transport_title")
                color: DefaultStyle.main2_600
                font: Typography.p2l
            }
            DecoratedTextField {
                Layout.fillWidth: true
                //:"Registrar URI"
                title: qsTr("account_settings_registrar_uri_title")
                propertyName: "registrarUri"
                propertyOwnerGui: account
                toValidate: true
                isValid: function(text) {
                    var valid = text === "" || UtilsCpp.stringMatchFormat(text, ConstantsCpp.uriRegExp)
                    mainItem.registrarUriIsValid = valid
                    return valid
                }
            }
            DecoratedTextField {
                Layout.fillWidth: true
                //:"Outbound SIP Proxy URI"
                title: qsTr("account_settings_sip_proxy_url_title")
                propertyName: "outboundProxyUri"
                propertyOwnerGui: account
                toValidate: true
                //: "If this field is filled, the outbound proxy will be enabled automatically. Leave it empty to disable it."
                tooltip: qsTr("login_proxy_server_url_tooltip")
                isValid: function(text) {
                    var isValid = text === "" || UtilsCpp.stringMatchFormat(text, ConstantsCpp.uriRegExp)
                    mainItem.outboundProxyIsValid = isValid
                    return isValid
                }
            }
            DecoratedTextField {
                Layout.fillWidth: true
                propertyName: "stunServer"
                propertyOwnerGui: account
                //: "Adresse du serveur STUN"
                title: qsTr("account_settings_stun_server_url_title")
                toValidate: true
            }
            SwitchSetting {
                //: "Activer ICE"
                titleText: qsTr("account_settings_enable_ice_title")
                propertyName: "iceEnabled"
                propertyOwnerGui: account
            }
            SwitchSetting {
                //: "AVPF"
                titleText: qsTr("account_settings_avpf_title")
                propertyName: "avpfEnabled"
                propertyOwnerGui: account
            }
            SwitchSetting {
                //: "Mode bundle"
                titleText: qsTr("account_settings_bundle_mode_title")
                propertyName: "bundleModeEnabled"
                propertyOwnerGui: account
            }
            DecoratedTextField {
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
            }
            DecoratedTextField {
                id: conferenceFactoryUriField
                Layout.fillWidth: true
                //: "URI du serveur de conversations"
                title: qsTr("account_settings_conference_factory_uri_title")
                propertyName: "conferenceFactoryAddress"
                propertyOwnerGui: account
                Connections {
                    target: account.core
                    function onConferenceFactoryAddressChanged() {
                        if (conferenceFactoryUriField.text != conferenceFactoryUriField.propertyOwnerGui.core[conferenceFactoryUriField.propertyName]) 
                            conferenceFactoryUriField.text = conferenceFactoryUriField.propertyOwnerGui.core[conferenceFactoryUriField.propertyName]
                    }
                }
                toValidate: true
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
                    target: account.core
                    function onAudioVideoConferenceFactoryAddressChanged() {
                        if (audioVideoConfUriField.text != audioVideoConfUriField.propertyOwnerGui.core[audioVideoConfUriField.propertyName]) 
                            audioVideoConfUriField.text = audioVideoConfUriField.propertyOwnerGui.core[audioVideoConfUriField.propertyName]
                    }
                }
            }
            DecoratedTextField {
                Layout.fillWidth: true
                //: "URL du serveur d’échange de clés de chiffrement"
                title: qsTr("account_settings_lime_server_url_title")
                propertyName: "limeServerUrl"
                propertyOwnerGui: account
                toValidate: true
            }
        }
    }
}
