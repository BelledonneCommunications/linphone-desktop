import QtQuick
import QtQuick.Effects

import QtQuick.Layouts
import QtQuick.Controls.Basic as Control


import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

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
		PopupButton {
			id: presenceAndRegistrationItem
			Layout.minimumWidth: Math.round(86 * DefaultStyle.dp)
			Layout.maximumWidth: Math.round(150 * DefaultStyle.dp)
			Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
			Layout.preferredWidth: presenceOrRegistrationText.implicitWidth + Math.round(50 * DefaultStyle.dp)
			enabled: mainItem.account && mainItem.account.core.registrationState === LinphoneEnums.RegistrationState.Ok
			onEnabledChanged: if(!enabled) close()
			contentItem: Rectangle {
				id: presenceBar
				property bool isRegistered: mainItem.account?.core.registrationState === LinphoneEnums.RegistrationState.Ok
				color: DefaultStyle.main2_200
				radius: Math.round(15 * DefaultStyle.dp)
				RowLayout {
					anchors.fill: parent
					Image {
						id: registrationImage
						sourceSize.width: Math.round(11 * DefaultStyle.dp)
						sourceSize.height: Math.round(11 * DefaultStyle.dp)
						smooth: false
						Layout.preferredWidth: Math.round(11 * DefaultStyle.dp)
						Layout.preferredHeight: Math.round(11 * DefaultStyle.dp)
						source: presenceBar.isRegistered 
							? mainItem.account.core.presenceIcon 
							: mainItem.account?.core.registrationIcon || ""
						Layout.leftMargin: Math.round(8 * DefaultStyle.dp)
						RotationAnimator on rotation {
							running: mainItem.account && mainItem.account.core.registrationState === LinphoneEnums.RegistrationState.Progress
							direction: RotationAnimator.Clockwise
							from: 0
							to: 360
							loops: Animation.Infinite
							duration: 10000
						}
					}
					Text {
						id: presenceOrRegistrationText
						verticalAlignment: Text.AlignVCenter
						horizontalAlignment: Text.AlignHCenter
						visible: mainItem.account
						// Test texts
						// Timer{
						// 	running: true
						// 	interval: 1000
						// 	repeat: true
						// 	onTriggered: text.mode = (++text.mode) % 4
						// }
						font.weight: Math.round(300 * DefaultStyle.dp)
						font.pixelSize: Math.round(12 * DefaultStyle.dp)
						color: presenceBar.isRegistered ? mainItem.account.core.presenceColor : mainItem.account?.core.registrationColor
						text: presenceBar.isRegistered ? mainItem.account.core.presenceStatus : mainItem.account?.core.humaneReadableRegistrationState
					}
					EffectImage {
						fillMode: Image.PreserveAspectFit
						imageSource: AppIcons.downArrow
						colorizationColor: DefaultStyle.main2_600
						Layout.preferredHeight: Math.round(14 * DefaultStyle.dp)
						Layout.preferredWidth: Math.round(14 * DefaultStyle.dp)
						Layout.rightMargin: 8 * DefaultStyle.dp
					}
				}
			}
			popup.contentItem: Rectangle {
				implicitWidth: 280 * DefaultStyle.dp
				implicitHeight: 20 * DefaultStyle.dp + (setCustomStatus.visible ? 240 * DefaultStyle.dp : setPresence.implicitHeight)
				Presence {
					id: setPresence
					anchors.fill: parent
					anchors.margins: 20 * DefaultStyle.dp
					accountCore: mainItem.account.core
					onSetCustomStatusClicked: {
						setPresence.visible = false
						setCustomStatus.visible = true
					}
					onIsSet: presenceAndRegistrationItem.popup.close()
				}
				PresenceSetCustomStatus {
					id: setCustomStatus
					visible: false
					anchors.fill: parent
					anchors.margins: 20 * DefaultStyle.dp
					accountCore: mainItem.account.core
					onVisibleChanged: {
						if (!visible) {
							setPresence.visible = true
							setCustomStatus.visible = false
						}
					}
					onIsSet: presenceAndRegistrationItem.popup.close()
				}
			}
		}
		
		Item{
            Layout.preferredWidth: Math.round(26 * DefaultStyle.dp)
            Layout.preferredHeight: Math.round(26 * DefaultStyle.dp)
			Layout.fillHeight: true
            Layout.leftMargin: Math.round(40 * DefaultStyle.dp)
			visible: mainItem.account.core.unreadNotifications > 0
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
					text: mainItem.account.core.unreadNotifications >= 100 ? '99+' : mainItem.account.core.unreadNotifications
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
