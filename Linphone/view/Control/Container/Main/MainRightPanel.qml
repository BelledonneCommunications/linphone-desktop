import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp 1.0

ColumnLayout {
	id: mainItem
	property color panelColor: DefaultStyle.grey_100
	property alias headerContent: rightPanelHeader.children
	property alias content: rightPanelContent.children
	property alias header: rightPanelHeader
	spacing: 0

	Item {
		Layout.preferredHeight: Math.round(57 * DefaultStyle.dp)
		Layout.fillWidth: true
		z: rightPanelContent.z + 1
		Rectangle {
			id: rightPanelHeader
			anchors.fill: parent
			color: DefaultStyle.grey_0
		}
		MultiEffect {
			anchors.fill: rightPanelHeader
			source: rightPanelHeader
			shadowEnabled: true
			shadowColor: DefaultStyle.grey_1000
			shadowBlur: 1
			shadowOpacity: 0.05
			shadowVerticalOffset: Math.round(10 * DefaultStyle.dp)
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
