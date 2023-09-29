import QtQuick 2.15
import QtQuick.Layouts 1.0
import Linphone
//import UI 1.0

Window {
	width: 640
	height: 480
	visible: true
	title: qsTr("Linphone")
	
	ColumnLayout{
		anchors.fill: parent
		
		Login{
			height: 100
			width: 640
		}
	}
}
 