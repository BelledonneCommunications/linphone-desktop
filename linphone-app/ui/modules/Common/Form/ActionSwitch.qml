import QtQuick 2.7

// =============================================================================

Item {
	property alias updating: actionButton.updating
	property alias useStates: actionButton.useStates
	property alias text: actionButton.text
	property bool enabled: true
	
	// Custom mode  
	property alias isCustom : actionButton.isCustom
	property alias backgroundRadius : actionButton.backgroundRadius
	
	property alias colorSet : actionButton.colorSet
	property alias iconSize : actionButton.iconSize
	property alias icon : actionButton.icon
	
	// ---------------------------------------------------------------------------
	
	signal clicked
	
	// ---------------------------------------------------------------------------
	
	height: iconSize || parent.iconSize || parent.height
	width: iconSize || parent.iconSize || parent.width
	
	ActionButton {
		id: actionButton
		enabled: parent.enabled
		anchors.fill: parent
		//icon: parent.icon// + (parent.enabled ? '_on' : '_off')
		//iconSize: parent.iconSize
		
		onClicked: parent.clicked()
	}
}
