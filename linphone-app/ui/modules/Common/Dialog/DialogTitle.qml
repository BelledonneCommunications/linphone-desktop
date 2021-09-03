import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import Common.Styles 1.0
import Units 1.0

// =============================================================================
// Title bar used by dialogs.
// =============================================================================

Item {
	id:mainItem
	property alias text: title.text
	property bool showBar : text != ''
	property bool showCloseCross: showBar
	signal close()
	
	height: 30
	
	Rectangle{
		anchors.fill:parent
		gradient: Gradient {
			GradientStop { position: 0.0; color: Colors.y.color }
			GradientStop { position: 1.0; color: Colors.z.color}
		}
		visible:showBar
	}
	Text {
		id: title
		
		anchors {
			fill: parent
			leftMargin: DialogStyle.description.leftMargin
			rightMargin: DialogStyle.description.rightMargin
		}
		
		color: DialogStyle.description.color
		//font.pointSize: DialogStyle.description.pointSize
		font.pointSize: Units.dp * 10
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		wrapMode: Text.WordWrap
		visible: showBar
	}
	ActionButton{
		anchors.right:parent.right
		anchors.rightMargin: 14
		anchors.top:parent.top
		anchors.bottom:parent.bottom
		icon: 'close'
		iconSize: 12
		useStates: false
		visible:mainItem.showCloseCross
		
		onClicked: close()
	}
}
