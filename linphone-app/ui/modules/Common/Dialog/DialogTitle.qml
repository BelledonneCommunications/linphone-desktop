import QtQuick 2.7

import Common 1.0
import Linphone 1.0

import Common.Styles 1.0
import Units 1.0

// =============================================================================
// Title bar used by dialogs.
// =============================================================================

Item {
  property alias text: title.text
	signal close()

  height: text ? 30 : undefined
  
	Rectangle{
		anchors.fill:parent
		gradient: Gradient {
				 GradientStop { position: 0.0; color: "white" }
				 GradientStop { position: 1.0; color: "#E2E2E2" }
			 }
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
  }
  ActionButton{
	  anchors.right:parent.right
	  anchors.rightMargin: 14
	  anchors.top:parent.top
	  anchors.bottom:parent.bottom
	  icon: 'close'
	  iconSize: 12
	  useStates: false
	  
	  onClicked: close()
  }
}
