import QtQuick
import QtQuick.Layouts

import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

/*
Layout with line separator used in several views
*/

ColumnLayout {
    spacing: Utils.getSizeWithScreenRatio(15)
	property alias content: contentLayout.data
	property alias contentLayout: contentLayout
	ColumnLayout {
		id: contentLayout
        spacing: Utils.getSizeWithScreenRatio(8)
		// width: parent.width
		// Layout.fillWidth: true
		// Layout.preferredHeight: childrenRect.height
		// Layout.preferredWidth: parent.width
        // Layout.leftMargin: Utils.getSizeWithScreenRatio(8)
	}
	Rectangle {
		color: DefaultStyle.main2_200
		Layout.fillWidth: true 
        Layout.preferredHeight: Utils.getSizeWithScreenRatio(1)
		width: parent.width
	}
}
