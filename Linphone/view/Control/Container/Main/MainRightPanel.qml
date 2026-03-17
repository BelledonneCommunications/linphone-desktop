import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ColumnLayout {
	id: mainItem
	property color panelColor: DefaultStyle.grey_100
	property alias headerContentItem: rightPanelHeader.contentItem
	property alias content: rightPanelContent.contentItem
	property alias header: rightPanelHeader
	property int contentTopPadding: 0
	spacing: 0

	Control.Control {
		id: rightPanelHeader
		Layout.fillWidth: true
		z: rightPanelContent.z + 1
		topPadding: Utils.getSizeWithScreenRatio(30)
		bottomPadding: Utils.getSizeWithScreenRatio(24)
		leftPadding: Utils.getSizeWithScreenRatio(32)
		rightPadding: Utils.getSizeWithScreenRatio(32)

		background: Item {
			anchors.fill: parent
			Rectangle {
				id: bg
				anchors.fill: parent
				color: DefaultStyle.grey_0
			}
			MultiEffect {
				anchors.fill: bg
				source: bg
				shadowEnabled: true
				shadowColor: DefaultStyle.grey_1000
				shadowBlur: 1
				shadowOpacity: 0.05
				shadowVerticalOffset: Utils.getSizeWithScreenRatio(10)
			}
		}
	}
	Control.Control {
		id: rightPanelContent
		Layout.fillWidth: true
		Layout.fillHeight: true
		topPadding: mainItem.contentTopPadding
		background: Rectangle {
			anchors.fill: parent
			color: mainItem.panelColor
			MouseArea {
				anchors.fill: parent
				onClicked: {
					rightPanelContent.forceActiveFocus()
				}
			}
		}
	}
}
