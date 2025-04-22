import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Effects

import Linphone
import SettingsCpp

Control.TabBar {
	id: mainItem
    //spacing: Math.round(32 * DefaultStyle.dp)
    topPadding: Math.round(36 * DefaultStyle.dp)

	property var model
	readonly property alias cornerRadius: bottomLeftCorner.radius

	property AccountGui defaultAccount
	
	// Call it after model is ready. If done before, Repeater will not be updated
	function initButtons(){
		actionsRepeater.model = mainItem.model
	}
	
	onDefaultAccountChanged: {
		if (defaultAccount) defaultAccount.core?.lRefreshNotifications()
	}

    Connections {
        target: SettingsCpp
        function onDisableMeetingsFeatureChanged() {
            initButtons()
        }
        function onDisableChatFeatureChanged() {
            initButtons()
        }
    }

	component UnreadNotification: Rectangle {
		property int unread: 0
		visible: unread > 0
        width: Math.round(15 * DefaultStyle.dp)
        height: Math.round(15 * DefaultStyle.dp)
		radius: width/2
		color: DefaultStyle.danger_500main
		Text{
			id: unreadCount
			anchors.fill: parent
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
			color: DefaultStyle.grey_0
			fontSizeMode: Text.Fit
            font.pixelSize: Math.round(15 *  DefaultStyle.dp)
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
            radius: Math.round(25 * DefaultStyle.dp)
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
			y: parent.y + parent.height/2
			width: parent.width
			height: parent.height/2
		}
	}
	
    Repeater {
		id: actionsRepeater
		Control.TabButton {
			id: tabButton
			width: mainItem.width
			height: visible && buttonIcon.isImageReady ? undefined : 0
            bottomInset:  Math.round(32 * DefaultStyle.dp)
            topInset:  Math.round(32 * DefaultStyle.dp)
			hoverEnabled: true
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
                anchors.rightMargin: Math.round(15 * DefaultStyle.dp)
				anchors.top: parent.top
			}
			MouseArea {
				anchors.fill: tabButton
				cursorShape: tabButton.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
				acceptedButtons: Qt.NoButton
			}
			contentItem: ColumnLayout {
				EffectImage {
					id: buttonIcon
                    property real buttonSize: mainItem.currentIndex !== index && tabButton.hovered ? Math.round(26 * DefaultStyle.dp) : Math.round(24 * DefaultStyle.dp)
					imageSource: mainItem.currentIndex === index ? modelData.selectedIcon : modelData.icon
					Layout.preferredWidth: buttonSize
					Layout.preferredHeight: buttonSize
					Layout.alignment: Qt.AlignHCenter
					fillMode: Image.PreserveAspectFit
					colorizationColor: DefaultStyle.grey_0
					useColor: !modelData.colored
				}
				Text {
					id: buttonText
					visible: buttonIcon.isImageReady
					text: modelData.label
					font {
						weight: mainItem.currentIndex === index 
                            ? Math.round(800 * DefaultStyle.dp)
							: tabButton.hovered 
                                ? Math.round(600 * DefaultStyle.dp)
                                : Math.round(400 * DefaultStyle.dp)
                        pixelSize: Math.round(11 * DefaultStyle.dp)
					}
					color: DefaultStyle.grey_0
					Layout.fillWidth: true
					Layout.preferredHeight: txtMeter.height
					Layout.alignment: Qt.AlignHCenter
					horizontalAlignment: Text.AlignHCenter
                    leftPadding: Math.round(3 * DefaultStyle.dp)
                    rightPadding: Math.round(3 * DefaultStyle.dp)
				}
			}
			TextMetrics {
				id: txtMeter
				text: modelData.label
				font: buttonText.font
				Component.onCompleted: {
                    font.weight = Math.round(800 * DefaultStyle.dp)
					mainItem.implicitWidth = Math.max(mainItem.implicitWidth, advanceWidth + buttonIcon.buttonSize)
				}
			}
			onClicked: {
				mainItem.setCurrentIndex(TabBar.index)
			}

			background: Item {}
		}
	}
}
