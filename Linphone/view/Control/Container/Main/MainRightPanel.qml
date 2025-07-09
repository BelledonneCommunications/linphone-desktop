import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp 1.0

ColumnLayout {
	id: mainItem
	property color panelColor: DefaultStyle.grey_100
	property alias headerContentItem: rightPanelHeader.contentItem
	property alias content: rightPanelContent.children
	property alias header: rightPanelHeader
	spacing: 0

	Control.Control {
		id: rightPanelHeader
		Layout.fillWidth: true
		z: rightPanelContent.z + 1
		topPadding: Math.round(30 * DefaultStyle.dp)
		bottomPadding: Math.round(24 * DefaultStyle.dp)
		leftPadding: Math.round(32 * DefaultStyle.dp)
		rightPadding: Math.round(32 * DefaultStyle.dp)

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
				shadowVerticalOffset: Math.round(10 * DefaultStyle.dp)
			}
		}
	}
	Rectangle {
		id: rightPanelContent
		color: mainItem.panelColor
		Layout.fillWidth: true
		Layout.fillHeight: true
        MouseArea {
            anchors.fill: parent
            onClicked: {
                rightPanelContent.forceActiveFocus()
            }
        }
	}
}
