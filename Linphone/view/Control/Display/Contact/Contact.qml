import QtQuick
import QtQuick.Effects

import QtQuick.Layouts
import QtQuick.Controls.Basic as Control


import Linphone
import UtilsCpp
import SettingsCpp
import CustomControls 1.0
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

Control.Control{
	id: mainItem
	activeFocusOnTab: true
    padding: Utils.getSizeWithScreenRatio(10)
	property AccountGui account
    leftPadding: Utils.getSizeWithScreenRatio(8)
    rightPadding: Utils.getSizeWithScreenRatio(8)
	property var style

	property bool isSelected
	property bool keyboardFocus: FocusHelper.keyboardFocus

	// Background properties
    readonly property color defaultBackgroundColor: style?.color?.normal ?? DefaultStyle.grey_0
	readonly property color hoveredBackgroundColor: style?.color?.hovered ?? defaultBackgroundColor
	readonly property color selectedBackgroundColor: style?.color?.selected ?? defaultBackgroundColor
	readonly property color focusedBackgroundColor: style?.color?.keybaordFocused ?? defaultBackgroundColor
	// Border properties
	readonly property color defaultBorderColor: style?.borderColor?.normal ?? "transparent"
	readonly property color hoveredBorderColor: style?.borderColor?.hovered ?? defaultBorderColor
	readonly property color selectedBorderColor: style?.borderColor?.selected ?? defaultBorderColor
	readonly property color keyboardFocusedBorderColor: style?.borderColor?.keybaordFocused || DefaultStyle.main2_900
	property real borderWidth: Utils.getSizeWithScreenRatio(1)
	property real keyboardFocusedBorderWidth: Utils.getSizeWithScreenRatio(3)

	signal avatarClicked()
	signal backgroundClicked()
	signal edit()

	background: Rectangle {
        radius: Utils.getSizeWithScreenRatio(10)
		color: mainItem.isSelected ? mainItem.selectedBackgroundColor : hovered ? mainItem.hoveredBackgroundColor : mainItem.defaultBackgroundColor
		border.color: mainItem.keyboardFocus ? mainItem.keyboardFocusedBorderColor : mainItem.isSelected ? mainItem.selectedBorderColor : hovered ? mainItem.hoveredBorderColor : mainItem.defaultBorderColor
		border.width: mainItem.keyboardFocus ? mainItem.keyboardFocusedBorderWidth : mainItem.borderWidth 
		MouseArea{
			id: mouseArea
			anchors.fill: parent
			onClicked: mainItem.backgroundClicked()
		}
	}
	contentItem: RowLayout{
		spacing: 0
		RowLayout {
            spacing: Utils.getSizeWithScreenRatio(10)
			Button {
				id: avatarButton
				onClicked: mainItem.avatarClicked()
				Layout.preferredWidth: Utils.getSizeWithScreenRatio(45)
				Layout.preferredHeight: Utils.getSizeWithScreenRatio(45)
				color: "transparent"
				contentItem: Item{
					anchors.fill: parent
					width: avatarButton.width
					height: avatarButton.height
					Avatar{
						id: avatar
						height: avatarButton.height
						width: avatarButton.width
						account: mainItem.account
					}
					Rectangle{
						// Black border for keyboard navigation
						visible: avatarButton.keyboardFocus
						width: avatarButton.width
						height: avatarButton.height
						color: "transparent"
						border.color: DefaultStyle.main2_900
						border.width: Utils.getSizeWithScreenRatio(3)
						radius: width / 2
					}
				}	
			}
			Item {
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(200)
				Layout.fillHeight: true
                Layout.rightMargin: Utils.getSizeWithScreenRatio(10)
				ContactDescription{
					id: description
					anchors.fill: parent
					account: mainItem.account
				}
			}
		}
		Item {
			Layout.minimumWidth: Utils.getSizeWithScreenRatio(86)
    		Layout.maximumWidth: Utils.getSizeWithScreenRatio(150)
			width: contactStatusPopup.width
			height: contactStatusPopup.height
			ContactStatusPopup{
				id: contactStatusPopup
			}
			MouseArea {
				anchors.fill: contactStatusPopup
				enabled: !contactStatusPopup.enabled
				cursorShape: Qt.PointingHandCursor
				onClicked: mainItem.account.core.lSetRegisterEnabled(true)
			}
		}
		Item{
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(26)
            Layout.preferredHeight: Utils.getSizeWithScreenRatio(26)
			Layout.fillHeight: true
            Layout.leftMargin: Utils.getSizeWithScreenRatio(40)
			visible: mainItem.account.core.unreadNotifications > 0
			Rectangle{
				id: unreadNotifications
				anchors.verticalCenter: parent.verticalCenter
                width: Utils.getSizeWithScreenRatio(26)
                height: Utils.getSizeWithScreenRatio(26)
				radius: width/2
				color: DefaultStyle.danger_500_main
				border.color: DefaultStyle.grey_0
                border.width: Utils.getSizeWithScreenRatio(2)
				Text{
					id: unreadCount
					anchors.fill: parent
                    anchors.margins: Utils.getSizeWithScreenRatio(2)
					verticalAlignment: Text.AlignVCenter
					horizontalAlignment: Text.AlignHCenter
					color: DefaultStyle.grey_0
					minimumPixelSize: 5
					fontSizeMode: Text.Fit
                    font.pixelSize: Utils.getSizeWithScreenRatio(11)
                    font.weight: Utils.getSizeWithScreenRatio(700)
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
            Layout.leftMargin: Utils.getSizeWithScreenRatio(18)
            Layout.rightMargin: Utils.getSizeWithScreenRatio(20)
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(30)
            Layout.preferredHeight: Utils.getSizeWithScreenRatio(26)
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
		Button {				
			id: manageAccount
			style: ButtonStyle.noBackground
			icon.source: AppIcons.manageProfile
            Layout.preferredWidth: Utils.getSizeWithScreenRatio(30)
            Layout.preferredHeight: Utils.getSizeWithScreenRatio(30)
            icon.width: Utils.getSizeWithScreenRatio(24)
            icon.height: Utils.getSizeWithScreenRatio(24)
			visible: !SettingsCpp.hideAccountSettings
			//: Account settings of %1
			Accessible.name: qsTr("account_settings_name_accessible_name")
			onClicked: {
				mainItem.edit()
			}
		}
	}
}
