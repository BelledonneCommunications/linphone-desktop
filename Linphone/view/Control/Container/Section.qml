import QtQuick
import QtQuick.Layouts

import Linphone
/*
Layout with line separator used in several views
*/

ColumnLayout {
    spacing: Math.round(15 * DefaultStyle.dp)
	property alias content: contentLayout.data
	property alias contentLayout: contentLayout
    implicitHeight: contentLayout.implicitHeight + Math.max(Math.round(1 * DefaultStyle.dp), 1) + spacing
	ColumnLayout {
		id: contentLayout
        spacing: Math.round(8 * DefaultStyle.dp)
		// width: parent.width
		// Layout.fillWidth: true
		// Layout.preferredHeight: childrenRect.height
		// Layout.preferredWidth: parent.width
        // Layout.leftMargin: Math.round(8 * DefaultStyle.dp)
	}
	Rectangle {
		color: DefaultStyle.main2_200
		Layout.fillWidth: true 
        Layout.preferredHeight: Math.max(Math.round(1 * DefaultStyle.dp), 1)
		width: parent.width
	}
}
