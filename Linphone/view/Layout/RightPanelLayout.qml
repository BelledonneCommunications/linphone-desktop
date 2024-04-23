import QtQuick 2.15
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls as Control
import Linphone
import UtilsCpp 1.0

Item {
	id: mainItem
	property color panelColor: DefaultStyle.grey_100
	property alias headerContent: rightPanelHeader.children
	property alias content: rightPanelContent.children

	Rectangle {
		id: rightPanelHeader
		color: DefaultStyle.grey_0
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		height: 57 * DefaultStyle.dp
	}
	Rectangle {
		id: rightPanelContent
		color: mainItem.panelColor
		anchors.top: rightPanelHeader.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
	}
}