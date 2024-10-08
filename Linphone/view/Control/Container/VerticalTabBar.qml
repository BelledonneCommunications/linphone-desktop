import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Effects

import Linphone

Control.TabBar {
	id: mainItem
	//spacing: 32 * DefaultStyle.dp
	topPadding: 36 * DefaultStyle.dp

	property var model
	readonly property alias cornerRadius: bottomLeftCorner.radius

	property AccountGui defaultAccount
	onDefaultAccountChanged: {
		if (defaultAccount) defaultAccount.core?.lRefreshNotifications()
	}
	Connections {
		enabled: defaultAccount
		target: defaultAccount.core
		onUnreadCallNotificationsChanged: {
			console.log("unread changed", currentIndex)
			if (currentIndex === 0) defaultAccount?.core.lResetMissedCalls()
		}
	}

	component UnreadNotification: Rectangle {
		id: unreadNotifications
		property int unread: 0
		visible: unread > 0
		width: 15 * DefaultStyle.dp
		height: 15 * DefaultStyle.dp
		radius: width/2
		color: DefaultStyle.danger_500main
		Text{
			id: unreadCount
			anchors.fill: parent
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
			color: DefaultStyle.grey_0
			fontSizeMode: Text.Fit
			font.pixelSize: 15 *  DefaultStyle.dp
			text: parent.unread > 100 ? '99+' : parent.unread
		}
	}
	
	contentItem: ListView {
		model: mainItem.contentModel
		currentIndex: mainItem.currentIndex

		spacing: mainItem.spacing
		orientation: ListView.Vertical
		// boundsBehavior: Flickable.StopAtBounds
		flickableDirection: Flickable.AutoFlickIfNeeded
		// snapMode: ListView.SnapToItem

		// highlightMoveDuration: 0
		// highlightRangeMode: ListView.ApplyRange
		// preferredHighlightBegin: 40
		// preferredHighlightEnd: width - 40
	}

	background: Item {
		id: background
		anchors.fill: parent
		Rectangle {
			id: bottomLeftCorner
			anchors.fill: parent
			color: DefaultStyle.main1_500_main
			radius: 25 * DefaultStyle.dp
		}
		Rectangle {
			color: DefaultStyle.main1_500_main
			anchors.left: parent.left
			anchors.top: parent.top
			width: parent.width/2
			height: parent.height/2
		}
		Rectangle {
			color: DefaultStyle.main1_500_main
			x: parent.x + parent.width/2
			y: parent.y + parent.height/2
			width: parent.width/2
			height: parent.height/2
		}
	}

	Repeater {
		id: actionsRepeater
		model: mainItem.model
		Control.TabButton {
			id: tabButton
			width: mainItem.width
			height: visible ? undefined : 0
			bottomInset:  32 * DefaultStyle.dp
			topInset:  32 * DefaultStyle.dp
			
			visible: modelData?.visible != undefined ? modelData?.visible : true
			UnreadNotification {
				unread: !defaultAccount 
				? -1
				: index == 0 
					? defaultAccount.core?.unreadCallNotifications || -1
					: index == 2 
						? defaultAccount.core?.unreadMessageNotifications || -1
						: 0
				anchors.right: parent.right
				anchors.rightMargin: 15 * DefaultStyle.dp
				anchors.top: parent.top
			}
			contentItem: ColumnLayout {
				// height: tabButton.height
				// width: tabButton.width
				EffectImage {
					id: buttonIcon
					property int buttonSize: 24 * DefaultStyle.dp
					imageSource: mainItem.currentIndex === index ? modelData.selectedIcon : modelData.icon
					Layout.preferredWidth: buttonSize
					Layout.preferredHeight: buttonSize
					Layout.alignment: Qt.AlignHCenter
					fillMode: Image.PreserveAspectFit
					colorizationColor: DefaultStyle.grey_0				
				}
				Text {
					id: buttonText
					text: modelData.label
					font {
						weight: mainItem.currentIndex === index ? 800 * DefaultStyle.dp : 400 * DefaultStyle.dp
						pixelSize: 9 * DefaultStyle.dp
						underline: tabButton.activeFocus || tabButton.hovered
					}
					color: DefaultStyle.grey_0
					Layout.fillWidth: true
					Layout.preferredHeight: txtMeter.height
					Layout.alignment: Qt.AlignHCenter
					horizontalAlignment: Text.AlignHCenter
					leftPadding: 3 * DefaultStyle.dp
					rightPadding: 3 * DefaultStyle.dp
				}
			}
			TextMetrics {
				id: txtMeter
				text: modelData.label
				font: buttonText.font
				Component.onCompleted: {
					font.weight = 800 * DefaultStyle.dp
					mainItem.implicitWidth = Math.max(mainItem.implicitWidth, advanceWidth + buttonIcon.buttonSize)
				}
			}
			onClicked: {
				mainItem.setCurrentIndex(TabBar.index)
			}

			background: Item {
			}
		}
	}
}
