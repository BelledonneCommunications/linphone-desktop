import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Linphone
import UtilsCpp


Rectangle {
	id: mainItem
	
	property var accountCore
	property var presence
	signal click()
	
    color: mouseArea.containsMouse ? DefaultStyle.main2_100 : "transparent"
	width: 236 * DefaultStyle.dp
    height: 22 * DefaultStyle.dp
    radius: 5 * DefaultStyle.dp

	RowLayout {
		anchors.fill: parent
		spacing: 10 * DefaultStyle.dp
		Layout.alignment: Qt.AlignLeft

		Image {
			sourceSize.width: 11 * DefaultStyle.dp
			sourceSize.height: 11 * DefaultStyle.dp
			smooth: false
			Layout.preferredWidth: 11 * DefaultStyle.dp
			Layout.preferredHeight: 11 * DefaultStyle.dp
			source: UtilsCpp.getPresenceIcon(mainItem.presence)
		}

		Text {
			text: UtilsCpp.getPresenceStatus(mainItem.presence)
			font: Typography.p1
			horizontalAlignment: Text.AlignLeft
    		Layout.alignment: Qt.AlignLeft
    		Layout.fillWidth: true
    		color: UtilsCpp.getPresenceColor(mainItem.presence)
		}
	}
	MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
			mainItem.accountCore.presence = mainItem.presence
			mainItem.click()
		}
    }
}
