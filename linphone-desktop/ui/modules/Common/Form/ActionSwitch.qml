import QtQuick 2.7

// =============================================================================

Item {
  property alias updating: actionButton.updating
  property alias useStates: actionButton.useStates
  property bool enabled: true
  property int iconSize // Optionnal.
  property string icon

  // ---------------------------------------------------------------------------

  signal clicked

  // ---------------------------------------------------------------------------

  height: iconSize || parent.iconSize || parent.height
  width: iconSize || parent.iconSize || parent.height

  ActionButton {
    id: actionButton

    anchors.fill: parent
    icon: parent.icon + (parent.enabled ? '_on' : '_off')
    iconSize: parent.iconSize

    onClicked: parent.clicked()
  }
}
