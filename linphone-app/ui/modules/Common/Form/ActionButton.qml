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
    }
    TooltipArea {
        id:tooltip
        text: ''
        visible:text!=''
    }
  }
  
}
