import QtQuick
import QtQuick.Effects

import QtQuick.Layouts
import QtQuick.Controls as Control


import Linphone
import UtilsCpp

Rectangle{
	id: mainItem
	property AccountGui account
	signal avatarClicked()
	signal backgroundClicked()
	
	height: 45 * DefaultStyle.dp
	MouseArea{
		anchors.fill: parent
		onClicked: mainItem.backgroundClicked()
	}
	RowLayout{
		anchors.fill: parent
		spacing: 0
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
			Layout.leftMargin: 10 * DefaultStyle.dp
			Layout.rightMargin: 10 * DefaultStyle.dp
			ContactDescription{
				id: description
				anchors.fill: parent
				account: mainItem.account
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
		// Item {
		// 	Layout.fillWidth: true
		// }
		Item{
			Layout.preferredWidth: 27 * DefaultStyle.dp
			Layout.preferredHeight: 27 * DefaultStyle.dp
			Layout.fillHeight: true
			Rectangle{
				id: unreadNotifications
				anchors.verticalCenter: parent.verticalCenter
				property int unread: mainItem.account.core.unreadNotifications
				visible: unread > 0
				width: 27 * DefaultStyle.dp
				height: 27 * DefaultStyle.dp
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
					text: parent.unread > 100 ? '99+' : parent.unread
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
		EffectImage {
			id: manageAccount
			imageSource: AppIcons.manageProfile
			Layout.preferredWidth: 24 * DefaultStyle.dp
			Layout.preferredHeight: 24 * DefaultStyle.dp
			Layout.alignment: Qt.AlignHCenter
			width: 24 * DefaultStyle.dp
			fillMode: Image.PreserveAspectFit
			colorizationColor: DefaultStyle.main2_500main
			MouseArea{ // TODO
				anchors.fill: parent
				onClicked: console.log('TODO: Manage!')
			}
		}
	}
}
