import QtQuick 2.7
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.12

import Common 1.0

// =============================================================================
// An animated (or not) button with image(s).
// =============================================================================

Item {
  id: wrappedButton

  // ---------------------------------------------------------------------------

  property bool enabled: true
  property bool updating: false
  property bool useStates: true
  //property bool autoIcon : false    // hovered/pressed : use an automatic layer instead of specific icon image
  property int iconSize // Optional.
  readonly property alias hovered: button.hovered
  property alias text: button.text
  property alias tooltipText : tooltip.text

  // If `useStates` = true, the used icons are:
  // `icon`_pressed, `icon`_hovered and `icon`_normal.
  property string icon

  // ---------------------------------------------------------------------------

  signal clicked

  // ---------------------------------------------------------------------------

  function _getIcon () {
	if(wrappedButton.icon == '')
		return wrappedButton.icon;
    if (wrappedButton.updating) {
      return wrappedButton.icon + '_updating'
    }

    if (!useStates) {
      return wrappedButton.icon
    }

    if (!wrappedButton.enabled) {
      return wrappedButton.icon + '_disabled'
    }
   // if(!autoIcon) {
        return wrappedButton.icon + (
            button.down
            ? '_pressed'
            : (button.hovered ? '_hovered' : '_normal')
        )
   // }
   // return wrappedButton.icon;
  }

  // ---------------------------------------------------------------------------

  height: iconSize || parent.iconSize || parent.height
  width: iconSize || parent.iconSize || parent.width

  Button {
    id: button

    anchors.fill: parent
    background: Rectangle {
      color: 'transparent'
    }
    hoverEnabled: !wrappedButton.updating//|| wrappedButton.autoIcon

    onClicked: !wrappedButton.updating && wrappedButton.enabled && wrappedButton.clicked()

    Icon {
      id: icon

      anchors.centerIn: parent
      icon: Images[_getIcon()].id
      iconSize: wrappedButton.iconSize || (
        parent.width > parent.height ? parent.height : parent.width
      )
      MouseArea{
		anchors.fill:parent
		hoverEnabled: true
		acceptedButtons: Qt.NoButton
		cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
      }
	  
	  
	  /*
      Rectangle {
          anchors.fill:parent
          color:  button.down?'white':'black'
          opacity: 0.2
          visible:autoIcon && (button.down || button.hovered)
      }*/
    }
	/*
	Colorize{
		anchors.fill:icon
		source:icon
		hue:0.0
		saturation:0.0
		lightness: 0.5
		visible:autoIcon && button.down
	}*/
	/*
	GammaAdjust{
		anchors.fill:icon
		source:icon
		gamma:1.6
		visible:autoIcon && button.down
	}*/
	/*
	Colorize{
		anchors.fill:icon
		source:icon
		hue:0.0
		saturation:0.0
		lightness: -0.5
		visible:autoIcon && button.hovered && !button.down
	}*/	
	/*
	Desaturate{
		anchors.fill:icon
		source:icon
		desaturation: 1.0
		visible:autoIcon && button.hovered && !button.down
	}*/
	/*
	GammaAdjust{
		anchors.fill:icon
		source:icon
		gamma:0.4
		visible:autoIcon && button.hovered && !button.down
	}*/
	/*
	ColorOverlay{
		anchors.fill:icon
		source:icon
		color:button.down?'white':'orange'
		visible:autoIcon && (button.down || button.hovered)
	}*/
    TooltipArea {
        id:tooltip
        text: ''
        visible:text!=''
    }
  }
  
}
