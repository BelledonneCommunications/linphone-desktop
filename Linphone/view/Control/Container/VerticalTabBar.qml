import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import Linphone
import SettingsCpp
import CustomControls 1.0
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

Control.TabBar {
	id: mainItem
    //spacing: Utils.getSizeWithScreenRatio(32)
    topPadding: Utils.getSizeWithScreenRatio(36)

	property var model
	readonly property alias cornerRadius: bottomLeftCorner.radius

	property AccountGui defaultAccount

	property int visibleCount: 0

	signal enterPressed()
	signal spacePressed()
	
	// Call it after model is ready. If done before, Repeater will not be updated
	function initButtons(){
		actionsRepeater.model = mainItem.model
	}
	function updateVisibleCount() {
		mainItem.visibleCount = 0
		contentChildren.forEach(child => {
			if (child.visible) mainItem.visibleCount = mainItem.visibleCount + 1
		})
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
            radius: Utils.getSizeWithScreenRatio(25)
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
			parent: visible ? mainItem: null
			width: mainItem.width
            bottomInset:  Utils.getSizeWithScreenRatio(32)
            topInset:  Utils.getSizeWithScreenRatio(32)
			hoverEnabled: true
			visible: modelData?.visible != undefined ? modelData.visible : true
			onVisibleChanged: mainItem.updateVisibleCount()
			text: modelData.accessibilityLabel
			property bool keyboardFocus: FocusHelper.keyboardFocus
			focusPolicy: Qt.StrongFocus
			activeFocusOnTab: true
			UnreadNotification {
				badgeType: modelData.label
				unread: !defaultAccount 
				? -1
				: index === 0 
					? defaultAccount.core?.unreadCallNotifications || -1
					: index === 2 
						? defaultAccount.core?.unreadMessageNotifications || -1
						: 0
				anchors.right: parent.right
                anchors.rightMargin: Utils.getSizeWithScreenRatio(15)
				anchors.top: parent.top
			}
			MouseArea {
				anchors.fill: tabButton
				cursorShape: tabButton.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
				acceptedButtons: Qt.NoButton				
			}
			background: Rectangle{
				// Black border for keyboard navigation
				visible: tabButton.keyboardFocus
				color: "transparent"
				border.color: DefaultStyle.main2_900
				border.width: Utils.getSizeWithScreenRatio(3)
				radius: Utils.getSizeWithScreenRatio(5)
				anchors.fill: tabButton
			}
			contentItem: ColumnLayout {
				EffectImage {
					id: buttonIcon
					property real buttonSize: Utils.getSizeWithScreenRatio(mainItem.currentIndex !== index && tabButton.hovered ? 26 : 24)
					imageSource: mainItem.currentIndex === index ? modelData.selectedIcon : modelData.icon
					Layout.preferredWidth: buttonSize
					Layout.preferredHeight: buttonSize
					Layout.alignment: Qt.AlignHCenter
					fillMode: Image.PreserveAspectFit
					colorizationColor: DefaultStyle.grey_0
					useColor: !modelData.colored
					onStatusChanged: if (status === Image.Ready && !buttonText.visible) buttonText.visible = true
				}
				Text {
					id: buttonText
					text: modelData.label
					visible: false
					font {
						weight: mainItem.currentIndex === index
							? Utils.getSizeWithScreenRatio(800)
							: tabButton.hovered
								? Utils.getSizeWithScreenRatio(600)
								: Utils.getSizeWithScreenRatio(400)
						pixelSize: Utils.getSizeWithScreenRatio(11)
					}
					color: DefaultStyle.grey_0
					Layout.fillWidth: true
					Layout.preferredHeight: txtMeter.height
					Layout.alignment: Qt.AlignHCenter
					horizontalAlignment: Text.AlignHCenter
					leftPadding: Utils.getSizeWithScreenRatio(3)
					rightPadding: Utils.getSizeWithScreenRatio(3)
				}
			}
			TextMetrics {
				id: txtMeter
				text: modelData.label
				font: buttonText.font
				Component.onCompleted: {
                    font.weight = Utils.getSizeWithScreenRatio(800)
					mainItem.implicitWidth = Math.max(mainItem.implicitWidth, advanceWidth + buttonIcon.buttonSize)
				}
			}
			Keys.onPressed: event => {
                if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                    mainItem.enterPressed()
                } else if(event.key === Qt.Key_Space){
					mainItem.spacePressed()
				} else if(event.key === Qt.Key_Down){
					event.accepted = true;
					if(TabBar.index >= mainItem.visibleCount - 1)
       					return;
					tabButton.nextItemInFocusChain(true).forceActiveFocus(Qt.TabFocusReason)
				} else if(event.key === Qt.Key_Up){
					event.accepted = true;
					if(TabBar.index <= 0)
       					return;
					tabButton.nextItemInFocusChain(false).forceActiveFocus(Qt.BacktabFocusReason)
				}
			}
			onClicked: {
				mainItem.setCurrentIndex(TabBar.index)
			}
		}
	}
}
