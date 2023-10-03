import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
  
  
  
Control.Button {
	id: mainItem
	property int capitalization
	
	background: Rectangle {
		color: '#F50000'
		radius: 10
		border.color: 'white'
	}
	
	contentItem: Text {
		color: 'white'
		font {
			bold: true
			pointSize: 10
			capitalization: mainItem.capitalization
		}
		wrapMode: Text.WordWrap
		horizontalAlignment: Text.AlignHCenter
		text: mainItem.text
		verticalAlignment: Text.AlignVCenter
	}
	
	hoverEnabled: true
	/*
	MouseArea {
		id: mouseArea
		anchors.fill: parent
		onPressed:  mouse.accepted = false
	}*/
}