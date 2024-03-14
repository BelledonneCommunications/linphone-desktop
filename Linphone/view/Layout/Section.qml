import QtQuick 2.15
import QtQuick.Layouts

import Linphone
/*
Layout with line separator used in several views
*/

ColumnLayout {
	spacing: 15 * DefaultStyle.dp
	property alias content: contentLayout.data
	property alias contentLayout: contentLayout
	implicitHeight: contentLayout.implicitHeight + 1 * DefaultStyle.dp + spacing
	ColumnLayout {
		id: contentLayout
		spacing: 8 * DefaultStyle.dp
		// width: parent.width
		// Layout.fillWidth: true
		// Layout.preferredHeight: childrenRect.height
		// Layout.preferredWidth: parent.width
		// Layout.leftMargin: 8 * DefaultStyle.dp
	}
	Rectangle {
		color: DefaultStyle.main2_200
		Layout.fillWidth: true 
		Layout.preferredHeight: 1 * DefaultStyle.dp
		width: parent.width
	}
}