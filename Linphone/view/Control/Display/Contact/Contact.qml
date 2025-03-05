import QtQuick
import QtQuick.Effects

import QtQuick.Layouts
import QtQuick.Controls.Basic as Control


import Linphone
import UtilsCpp
import SettingsCpp

Control.Control{
	id: mainItem
    padding: Math.round(10 * DefaultStyle.dp)
	property AccountGui account
    property color backgroundColor: DefaultStyle.grey_0
    leftPadding: Math.round(8 * DefaultStyle.dp)
    rightPadding: Math.round(8 * DefaultStyle.dp)

	signal avatarClicked()
	signal backgroundClicked()
	signal edit()

	background: Rectangle {
        radius: Math.round(10 * DefaultStyle.dp)
		color: mainItem.backgroundColor
		MouseArea{
			id: mouseArea
			anchors.fill: parent
			onClicked: mainItem.backgroundClicked()
		}
	}
	contentItem: RowLayout{
		spacing: 0
		RowLayout {
            spacing: Math.round(10 * DefaultStyle.dp)
			Avatar{
				id: avatar
                Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
                Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
				account: mainItem.account
				MouseArea{
					anchors.fill: parent
					onClicked: mainItem.avatarClicked()
				}
			}
			Item {
                Layout.preferredWidth: Math.round(200 * DefaultStyle.dp)
				Layout.fillHeight: true
                Layout.rightMargin: Math.round(10 * DefaultStyle.dp)
				ContactDescription{
					id: description
					anchors.fill: parent
					account: mainItem.account
				}
			}
		}
		Control.Control {
			id: registrationStatusItem
            Layout.minimumWidth: Math.round(49 * DefaultStyle.dp)
            Layout.maximumWidth: 150
            Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
            topPadding: Math.round(4 * DefaultStyle.dp)
            bottomPadding: Math.round(4 * DefaultStyle.dp)
            leftPadding: Math.round(8 * DefaultStyle.dp)
            rightPadding: Math.round(8 * DefaultStyle.dp)
            Layout.preferredWidth: text.implicitWidth + (2 * Math.round(8 * DefaultStyle.dp))
			background: Rectangle{
				id: registrationStatus
				anchors.fill: parent
				color: DefaultStyle.main2_200
                radius: Math.round(90 * DefaultStyle.dp)
			}
			contentItem: Text {
				id: text
                anchors.fill: parent
                anchors.leftMargin: registrationStatusItem.leftPadding
                anchors.rightMargin: registrationStatusItem.rightPadding
                verticalAlignment: Text.AlignVCenter
				horizontalAlignment: Text.AlignHCenter
				visible: mainItem.account
				property int mode : !mainItem.account || mainItem.account.core.registrationState == LinphoneEnums.RegistrationState.Ok
												? 0
												: mainItem.account.core.registrationState == LinphoneEnums.RegistrationState.Cleared || mainItem.account.core.registrationState == LinphoneEnums.RegistrationState.None
													? 1
													: mainItem.account.core.registrationState == LinphoneEnums.RegistrationState.Progress || mainItem.account.core.registrationState == LinphoneEnums.RegistrationState.Refreshing
														? 2
														: 3
				// Test texts
				// Timer{
				// 	running: true
				// 	interval: 1000
				// 	repeat: true
				// 	onTriggered: text.mode = (++text.mode) % 4
				// }
                font.weight: Math.round(300 * DefaultStyle.dp)
                font.pixelSize: Math.round(12 * DefaultStyle.dp)
				color: mode == 0 
						? DefaultStyle.success_500main
						: mode == 1
							? DefaultStyle.warning_600
							: mode == 2
								? DefaultStyle.main2_500main
								: DefaultStyle.danger_500main
				text: mode == 0
                        //: "Connecté"
                        ? qsTr("drawer_menu_account_connection_status_connected")
						: mode == 1
                            //: "Désactivé"
                            ? qsTr("drawer_menu_account_connection_status_cleared")
							: mode == 2
                                //: "Connexion…"
                                ? qsTr("drawer_menu_account_connection_status_refreshing")
                                //: "Erreur"
                                : qsTr("drawer_menu_account_connection_status_failed")
			}
		}
		Item{
            Layout.preferredWidth: Math.round(26 * DefaultStyle.dp)
            Layout.preferredHeight: Math.round(26 * DefaultStyle.dp)
			Layout.fillHeight: true
            Layout.leftMargin: Math.round(40 * DefaultStyle.dp)
			visible: mainItem.account.core.unreadCallNotifications > 0
			Rectangle{
				id: unreadNotifications
				anchors.verticalCenter: parent.verticalCenter
                width: Math.round(26 * DefaultStyle.dp)
                height: Math.round(26 * DefaultStyle.dp)
				radius: width/2
				color: DefaultStyle.danger_500main
				border.color: DefaultStyle.grey_0
                border.width: Math.round(2 * DefaultStyle.dp)
				Text{
					id: unreadCount
					anchors.fill: parent
                    anchors.margins: Math.round(2 * DefaultStyle.dp)
					verticalAlignment: Text.AlignVCenter
					horizontalAlignment: Text.AlignHCenter
					color: DefaultStyle.grey_0
					minimumPixelSize: 5
					fontSizeMode: Text.Fit
                    font.pixelSize: Math.round(11 *  DefaultStyle.dp)
                    font.weight: Math.round(700 *  DefaultStyle.dp)
					text: mainItem.account.core.unreadCallNotifications >= 100 ? '99+' : mainItem.account.core.unreadCallNotifications
				}
			}
			MultiEffect {
				anchors.fill: unreadNotifications
				source: unreadNotifications
				shadowEnabled: true
				shadowBlur: 0.1
				shadowOpacity: 0.15
			}
		}
		Voicemail {
            Layout.leftMargin: Math.round(18 * DefaultStyle.dp)
            Layout.rightMargin: Math.round(20 * DefaultStyle.dp)
            Layout.preferredWidth: Math.round(30 * DefaultStyle.dp)
            Layout.preferredHeight: Math.round(26 * DefaultStyle.dp)
			scaleFactor: 0.7
			showMwi: mainItem.account.core.showMwi
			visible: mainItem.account.core.voicemailAddress.length > 0 || mainItem.account.core.showMwi
			voicemailCount: mainItem.account.core.voicemailCount
			onClicked: {
				if (mainItem.account.core.voicemailAddress.length > 0)
					UtilsCpp.createCall(mainItem.account.core.voicemailAddress)
				else
                    //: Erreur
                    UtilsCpp.showInformationPopup(qsTr("information_popup_error_title"),
                    //: L'URI de messagerie vocale n'est pas définie.
                    qsTr("information_popup_voicemail_address_undefined_message"), false)
			}
		}
		Item{Layout.fillWidth: true}
		EffectImage {
			id: manageAccount
			imageSource: AppIcons.manageProfile
            Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
            Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
			Layout.alignment: Qt.AlignHCenter
			visible: !SettingsCpp.hideAccountSettings
            width: Math.round(24 * DefaultStyle.dp)
			fillMode: Image.PreserveAspectFit
			colorizationColor: DefaultStyle.main2_500main
			MouseArea{
				anchors.fill: parent
				onClicked: mainItem.edit()
				cursorShape: Qt.PointingHandCursor
			}
		}
	}
}
