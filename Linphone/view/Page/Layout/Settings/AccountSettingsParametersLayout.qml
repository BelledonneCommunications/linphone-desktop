import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import Linphone
import SettingsCpp 1.0
import UtilsCpp

AbstractSettingsLayout {
    id: mainItem
    width: parent?.width
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
        target: account.core
        function onIsSavedChanged() {
            if (account.core.isSaved)
                UtilsCpp.showInformationPopup(
                            qsTr("information_popup_success_title"),
                            //: "Modifications sauvegardés"
                            qsTr("contact_editor_saved_changes_toast"), true,
                            mainWindow)
        }
    }

    // General parameters
    /////////////////////
    Component {
        id: generalParametersComponent
        ColumnLayout {
            id: column
            Layout.fillWidth: true
            spacing: Math.round(20 * DefaultStyle.dp)
            DecoratedTextField {
                propertyName: "mwiServerAddress"
                propertyOwnerGui: account
                //: "URI du serveur de messagerie vocale"
                title: qsTr("account_settings_mwi_uri_title")
                Layout.fillWidth: true
                isValid: function (text) {
                    return text.length == 0 || !text.endsWith(".")
                } // work around sdk crash when adress ends with .
                toValidate: true
            }
            DecoratedTextField {
                propertyName: "voicemailAddress"
                propertyOwnerGui: account
                //: "URI de messagerie vocale"

                title: qsTr("account_settings_voicemail_uri_title")
                Layout.fillWidth: true
                toValidate: true
            }
        }
    }

    // Advanced parameters
    /////////////////////
    Component {
        id: advancedParametersComponent
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Math.round(20 * DefaultStyle.dp)
            Text {
                //: "Transport"
                text: qsTr("account_settings_transport_title")
                color: DefaultStyle.main2_600
                font: Typography.p2l
            }
            ComboSetting {
                Layout.fillWidth: true
                Layout.topMargin: Math.round(-15 * DefaultStyle.dp)
                entries: account.core.transports
                propertyName: "transport"
                propertyOwnerGui: account
            }
            DecoratedTextField {
                Layout.fillWidth: true
                //:"URL du serveur mandataire"
                title: qsTr("account_settings_sip_proxy_url_title")
                propertyName: "serverAddress"
                propertyOwnerGui: account
                toValidate: true
            }
            SwitchSetting {
                //: "Serveur mandataire sortant"
                titleText: qsTr("account_settings_outbound_proxy_title")
                propertyName: "outboundProxyEnabled"
                propertyOwnerGui: account
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
                Layout.fillWidth: true
                //: "URI du serveur de conversations"
                title: qsTr("account_settings_conference_factory_uri_title")
                propertyName: "conferenceFactoryAddress"
                propertyOwnerGui: account
                toValidate: true
            }
            DecoratedTextField {
                Layout.fillWidth: true
                propertyName: "audioVideoConferenceFactoryAddress"
                //: "URI du serveur de réunions"
                title: qsTr("account_settings_audio_video_conference_factory_uri_title")
                propertyOwnerGui: account
                toValidate: true
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
