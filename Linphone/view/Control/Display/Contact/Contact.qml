import QtQuick
import QtQuick.Effects

import QtQuick.Layouts
import QtQuick.Controls.Basic as Control


import Linphone
import UtilsCpp
import SettingsCpp

Rectangle{
	id: mainItem
	property AccountGui account

	signal avatarClicked()
	signal backgroundClicked()
	signal edit()
	
	height: 45 * DefaultStyle.dp
	MouseArea{
		anchors.fill: parent
		onClicked: mainItem.backgroundClicked()
	}
	RowLayout{
		anchors.fill: parent
		spacing: 0
		RowLayout {
			spacing: 10 * DefaultStyle.dp
			Avatar{
				id: avatar
				Layout.preferredWidth: 45 * DefaultStyle.dp
				Layout.preferredHeight: 45 * DefaultStyle.dp
				account: mainItem.account
				MouseArea{
					anchors.fill: parent
					onClicked: mainItem.avatarClicked()
				}
			}
			Item {
				Layout.preferredWidth: 200 * DefaultStyle.dp
				Layout.fillHeight: true
				Layout.rightMargin: 10 * DefaultStyle.dp
				ContactDescription{
					id: description
					anchors.fill: parent
					account: mainItem.account
				}
			}
		}
		Control.Control {
			id: registrationStatusItem
			Layout.minimumWidth: 49 * DefaultStyle.dp
			Layout.preferredHeight: 24 * DefaultStyle.dp
			topPadding: 4 * DefaultStyle.dp
			bottomPadding: 4 * DefaultStyle.dp
			leftPadding: 8 * DefaultStyle.dp
			rightPadding: 8 * DefaultStyle.dp
			Layout.preferredWidth: text.implicitWidth + (2 * 8 * DefaultStyle.dp)
			background: Rectangle{
				id: registrationStatus
				anchors.fill: parent
				color: DefaultStyle.main2_200
				radius: 90 * DefaultStyle.dp
			}
			contentItem: Text {
				id: text
				anchors.fill: parent
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
				font.weight: 300 * DefaultStyle.dp
				font.pixelSize: 12 * DefaultStyle.dp
				color: mode == 0 
						? DefaultStyle.success_500main
						: mode == 1
							? DefaultStyle.warning_600
							: mode == 2
								? DefaultStyle.main2_500main
								: DefaultStyle.danger_500main
				text: mode == 0
						? qsTr("Connecté")
						: mode == 1
							? qsTr("Désactivé")
							: mode == 2
								? qsTr("Connexion...")
								: qsTr("Erreur")
			}
		}
		Item{
			Layout.preferredWidth: 26 * DefaultStyle.dp
			Layout.preferredHeight: 26 * DefaultStyle.dp
			Layout.fillHeight: true
			Layout.leftMargin: 40 * DefaultStyle.dp
			visible: mainItem.account.core.unreadCallNotifications > 0
			Rectangle{
				id: unreadNotifications
				anchors.verticalCenter: parent.verticalCenter
				width: 26 * DefaultStyle.dp
				height: 26 * DefaultStyle.dp
				radius: width/2
				color: DefaultStyle.danger_500main
				border.color: DefaultStyle.grey_0
				border.width: 2 * DefaultStyle.dp
				Text{
					id: unreadCount
					anchors.fill: parent
					anchors.margins: 2 * DefaultStyle.dp
					verticalAlignment: Text.AlignVCenter
					horizontalAlignment: Text.AlignHCenter
					color: DefaultStyle.grey_0
					minimumPixelSize: 5
					fontSizeMode: Text.Fit
					font.pixelSize: 11 *  DefaultStyle.dp
					font.weight: 700 *  DefaultStyle.dp
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
			Layout.leftMargin: 18 * DefaultStyle.dp
			Layout.rightMargin: 20 * DefaultStyle.dp
			Layout.preferredWidth: 27 * DefaultStyle.dp
			Layout.preferredHeight: 28 * DefaultStyle.dp
			voicemailCount: mainItem.account.core.voicemailCount >= 100 ? '99+' : mainItem.account.core.voicemailCount
			onClicked: {
				if (mainItem.account.core.mwiServerAddress.length > 0)
					UtilsCpp.createCall(mainItem.account.core.mwiServerAddress)
				else
					UtilsCpp.showInformationPopup(qsTr("Erreur"), qsTr("L'adresse de la messagerie vocale n'est pas définie."), false)
			}
		}
		Item{Layout.fillWidth: true}
		EffectImage {
			id: manageAccount
			imageSource: AppIcons.manageProfile
			Layout.preferredWidth: 24 * DefaultStyle.dp
			Layout.preferredHeight: 24 * DefaultStyle.dp
			Layout.alignment: Qt.AlignHCenter
			visible: !SettingsCpp.hideAccountSettings
			width: 24 * DefaultStyle.dp
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
