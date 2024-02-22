import QtQuick 2.15
import QtQuick.Layouts

import Linphone
/*
Layout with line separator used in several views
*/

ColumnLayout {
	spacing: 15 * DefaultStyle.dp
	property alias content: contentItem.data
	implicitHeight: contentItem.implicitHeight + 1 * DefaultStyle.dp + spacing
	Item {
		id: contentItem
		Layout.fillWidth: true
		Layout.preferredHeight: childrenRect.height
		Layout.preferredWidth: childrenRect.width
		// Layout.leftMargin: 8 * DefaultStyle.dp
	}
	Rectangle {
		color: DefaultStyle.main2_200
		Layout.fillWidth: true 
		Layout.preferredHeight: 1 * DefaultStyle.dp
		width: parent.width
	}
}