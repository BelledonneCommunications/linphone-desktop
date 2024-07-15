import QtQuick
import QtQuick.Controls 2.2 as Control
import QtQuick.Effects
import Linphone

Button {
	id: mainItem
	property alias popup: popup
	property var contentImageColor
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

	background: Rectangle {
		anchors.fill: mainItem
		visible: mainItem.checked
		color: DefaultStyle.main2_300
		radius: 40 * DefaultStyle.dp
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
		closePolicy: Popup.CloseOnPressOutsideParent | Popup.CloseOnPressOutside
		padding: 10 * DefaultStyle.dp
		parent: mainItem	// Explicit define for coordinates references.

		onVisibleChanged: {
			if (!visible) return
			// Do not use popup.height as it is not consistent.
			var position = mainItem.mapToItem(mainItem.Window.contentItem, mainItem.x + popup.implicitContentWidth + popup.padding, mainItem.y + mainItem.height + popup.implicitContentHeight + popup.padding)
			if (position.y >= mainItem.Window.height) {
				y = -mainItem.height - popup.implicitContentHeight - popup.padding
			}else {
				y = mainItem.height + popup.padding
			}
			if (position.x >= mainItem.Window.width) {
				x = mainItem.width - Math.max(popup.width, popup.implicitContentWidth)
			} else {
				x = 0
			}
		}

		background: Item {
			anchors.fill: parent
			Rectangle {
				id: callOptionsMenuPopup
				anchors.fill: parent
				color: DefaultStyle.grey_0
				radius: 16 * DefaultStyle.dp
			}
			MultiEffect {
				source: callOptionsMenuPopup
				anchors.fill: callOptionsMenuPopup
				shadowEnabled: true
				shadowBlur: 1
				shadowColor: DefaultStyle.grey_900
				shadowOpacity: 0.4
			}
		}
	}
}
