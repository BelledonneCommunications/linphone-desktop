import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import Linphone

Button {
	id: mainItem
	property alias popup: popup
	property var contentImageColor
	property bool shadowEnabled: mainItem.activeFocus  || hovered
	property alias popupBackgroundColor: popupBackground.color
	checked: popup.visible
	implicitWidth: 24 * DefaultStyle.dp
	implicitHeight: 24 * DefaultStyle.dp
	width: 24 * DefaultStyle.dp
	height: 24 * DefaultStyle.dp
	leftPadding: 0
	rightPadding: 0
	topPadding: 0
	bottomPadding: 0
	icon.source: AppIcons.more
	icon.width: 24 * DefaultStyle.dp
	icon.height: 24 * DefaultStyle.dp
	function close() {
		popup.close()
	}
	function open() {
		popup.open()
	}

	Keys.onPressed: (event) => {
		if(popup.checked && event.key == Qt.Key_Escape){
			mainItem.close()
			event.accepted = true
		}
	}
	background: Item {
		anchors.fill: mainItem
		Rectangle {
			id: buttonBackground
			anchors.fill: parent
			visible: mainItem.checked || mainItem.shadowEnabled
			color:  mainItem.checked ? DefaultStyle.main2_300 : DefaultStyle.grey_100
			radius: 40 * DefaultStyle.dp
		}
		MultiEffect {
			enabled: mainItem.shadowEnabled
			anchors.fill: buttonBackground
			source: buttonBackground
			visible:  mainItem.shadowEnabled
			// Crash : https://bugreports.qt.io/browse/QTBUG-124730
			shadowEnabled: true //mainItem.shadowEnabled
			shadowColor: DefaultStyle.grey_1000
			shadowBlur: 0.1
			shadowOpacity: mainItem.shadowEnabled ? 0.5 : 0.0
		}
	}
	contentItem: EffectImage {
		imageSource: mainItem.icon.source
		imageWidth: mainItem.icon.width
		imageHeight: mainItem.icon.height
		colorizationColor: mainItem.contentImageColor
	}
	onPressed: {
		if (popup.visible) popup.close()
		else popup.open()
	}
	Control.Popup {
		id: popup
		x: 0
		y: mainItem.height
		closePolicy: Popup.CloseOnPressOutsideParent | Popup.CloseOnPressOutside | Popup.CloseOnEscape
		padding: 10 * DefaultStyle.dp
		parent: mainItem	// Explicit define for coordinates references.
		function updatePosition(){
			if (!visible) return
			var popupHeight = popup.height + popup.padding
			var popupWidth = popup.width + popup.padding
			var winPosition = mainItem.Window.contentItem.mapToItem(mainItem,0 , 0)
			
			y = Math.max( Math.min( winPosition.y + mainItem.Window.height - popupHeight, mainItem.height), winPosition.y)
			x = Math.max( Math.min( winPosition.x + mainItem.Window.width - popupWidth, 0), winPosition.x)
			popup.contentItem.forceActiveFocus()
		}
		onHeightChanged: Qt.callLater(updatePosition)
		onWidthChanged: Qt.callLater(updatePosition)
		Connections{
			target: mainItem.Window
			function onHeightChanged(){ Qt.callLater(popup.updatePosition)}
			function onWidthChanged(){ Qt.callLater(popup.updatePosition)}
		}
		onVisibleChanged: Qt.callLater(updatePosition)

		background: Item {
			anchors.fill: parent
			Rectangle {
				id: popupBackground
				anchors.fill: parent
				color: DefaultStyle.grey_0
				radius: 16 * DefaultStyle.dp
			}
			MultiEffect {
				source: popupBackground
				anchors.fill: popupBackground
				shadowEnabled: true
				shadowBlur: 0.1
				shadowColor: DefaultStyle.grey_1000
				shadowOpacity: 0.4
			}
		}
	}
}
