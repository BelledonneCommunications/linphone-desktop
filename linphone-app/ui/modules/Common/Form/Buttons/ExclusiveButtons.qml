import QtQuick 2.7

import Common.Styles 1.0

// =============================================================================

Row {
	id: item
	
	// ---------------------------------------------------------------------------
	
	property int selectedButton: 0
	property var texts
	property int capitalization
	property QtObject style: ExclusiveButtonsStyle
	
	// ---------------------------------------------------------------------------
	
	// Emitted when the selected button is changed.
	// Gives the selected button id.
	signal clicked (int button)
	
	// ---------------------------------------------------------------------------
	
	spacing: ExclusiveButtonsStyle.buttonsSpacing
	
	Keys.onLeftPressed: {
		if (selectedButton > 0) {
			clicked(--selectedButton)
		}
	}
	
	Keys.onRightPressed: {
		if (selectedButton < repeater.count - 1) {
			clicked(++selectedButton)
		}
	}
	
	// ---------------------------------------------------------------------------
	
	Repeater {
		id: repeater
		
		model: texts
		
		SmallButton {
			capitalization: item.capitalization
			anchors.verticalCenter: parent.verticalCenter
			backgroundColor: selectedButton === index
							 ? item.style.button.color.selected
							 : (down
								? item.style.button.color.pressed
								: (hovered
								   ? item.style.button.color.hovered
								   : item.style.button.color.normal
								   )
								)
			text: modelData
			radius: height/2
			
			onClicked: {
				if (selectedButton !== index) {
					selectedButton = index
					item.clicked(index)
				}
			}
		}
	}
}
