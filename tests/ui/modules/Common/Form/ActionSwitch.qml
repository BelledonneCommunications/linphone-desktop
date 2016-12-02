import QtQuick 2.7

// ===================================================================

Item {
	property alias useStates: actionButton.useStates
  property int iconSize // Optionnal.
  property string icon

	property bool enabled: true

	signal onClicked

	// -----------------------------------------------------------------

	height: iconSize || parent.iconSize || parent.height
  width: iconSize || parent.iconSize || parent.height

	ActionButton {
		id: actionButton

		anchors.fill: parent
		icon: parent.icon + (parent.enabled ? '_on' : '_off')

		onClicked: parent.onClicked
	}
}
