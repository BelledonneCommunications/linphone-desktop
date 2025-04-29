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

	Rectangle {
		id: rightPanelHeader
		color: DefaultStyle.grey_0
        Layout.preferredHeight: Math.round(57 * DefaultStyle.dp)
		Layout.fillWidth: true
		z: 1
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
