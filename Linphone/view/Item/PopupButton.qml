import QtQuick
import QtQuick.Controls 2.2 as Control
import QtQuick.Effects
import Linphone

Button {
	id: mainItem
	property alias popup: popup
	checked: popup.visible
	implicitWidth: 24 * DefaultStyle.dp
	implicitHeight: 24 * DefaultStyle.dp
	leftPadding: 0
	rightPadding: 0
	topPadding: 0
	bottomPadding: 0
	function close() {
		popup.close()
	}
	background: Rectangle {
		anchors.fill: mainItem
		visible: mainItem.checked
		color: DefaultStyle.main2_300
		radius: 40 * DefaultStyle.dp
	}
	contentItem: Image {
		source: AppIcons.more
		sourceSize.width: 24 * DefaultStyle.dp
		sourceSize.height: 24 * DefaultStyle.dp
		width: 24 * DefaultStyle.dp
		height: 24 * DefaultStyle.dp
	}
	onPressed: {
		if (popup.visible) popup.close()
		else popup.open()
	}
	Control.Popup {
		id: popup
		x: - width
		y: mainItem.height
		closePolicy: Popup.CloseOnPressOutsideParent |Popup.CloseOnPressOutside

		onAboutToShow: {
			var coord = mapToGlobal(mainItem.x, mainItem.y)
			if (coord.y + popup.height >= mainApplicationWindow.height) {
				y = -popup.height
			} else {
				y = mainItem.height
			}
		}

		padding: 20 * DefaultStyle.dp

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