import QtQuick
import Linphone
import CustomControls 1.0
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Item {
	id: mainItem
	property string richText
	property bool tabStops: false
	property var links: Utils.extractLinks(richText)
	signal linkActivated(string link)

	Repeater {
		model: mainItem.links
		Item {
			id: linkItem
			required property var modelData
			anchors.fill: parent
			activeFocusOnTab: mainItem.tabStops
			property bool keyboardFocus: FocusHelper.keyboardFocus
			Accessible.role: Accessible.Link
			Accessible.name: modelData.label
			Accessible.focusable: true
			Accessible.onPressAction: mainItem.linkActivated(modelData.url)
			Keys.onPressed: (event) => {
				if (event.key === Qt.Key_Space || event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
					if (!event.isAutoRepeat)
						mainItem.linkActivated(linkItem.modelData.url)
					event.accepted = true
				}
			}
			Rectangle {
				anchors.fill: parent
				anchors.margins: -Utils.getSizeWithScreenRatio(2)
				visible: linkItem.keyboardFocus
				color: "transparent"
				border.color: DefaultStyle.main2_900
				border.width: Utils.getSizeWithScreenRatio(2)
				radius: Utils.getSizeWithScreenRatio(4)
			}
		}
	}
}
