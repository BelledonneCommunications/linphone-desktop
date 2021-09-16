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
	property QtObject colorSet: QtObject {
		property int iconSize: 30
		property string icon : ''
		property color backgroundNormalColor : "white"
		property color backgroundDisabledColor : "white"
		property color backgroundHoveredColor : "white"
		property color backgroundUpdatingColor : "white"
		property color backgroundPressedColor : "white"
	// Color for shown part
		property color foregroundNormalColor : "black"
		property color foregroundDisabledColor : "black"
		property color foregroundHoveredColor : "black"
		property color foregroundUpdatingColor : "black"
		property color foregroundPressedColor : "black"
	}
	property bool isCustom : false
	property bool enabled: true
	property bool updating: false
	property bool useStates: true
	//property bool autoIcon : false    // hovered/pressed : use an automatic layer instead of specific icon image
	property int iconSize : colorSet.iconSize
	readonly property alias hovered: button.hovered
	property alias text: button.text
	// Tooltip aliases
	property alias tooltipText : tooltip.text
	property alias tooltipIsClickable : tooltip.isClickable
	property alias tooltipMaxWidth: tooltip.maxWidth
	property alias tooltipVisible: tooltip.visible
	// Custom mode  
	
	property alias backgroundRadius : backgroundColor.radius
	
	
// AutoColor for hide part	alpha /4
	property color foregroundHiddenPartNormalColor : colorSet.foregroundNormalColor ? Qt.rgba(colorSet.foregroundNormalColor.r, colorSet.foregroundNormalColor.g, colorSet.foregroundNormalColor.b, colorSet.foregroundNormalColor.a/4) : 'transparent'
	property color foregroundHiddenPartDisabledColor : colorSet.foregroundDisabledColor ? Qt.rgba(colorSet.foregroundDisabledColor.r, colorSet.foregroundDisabledColor.g, colorSet.foregroundDisabledColor.b, colorSet.foregroundDisabledColor.a/4): 'transparent'
	property color foregroundHiddenPartHoveredColor : colorSet.foregroundHoveredColor ? Qt.rgba(colorSet.foregroundHoveredColor.r, colorSet.foregroundHoveredColor.g, colorSet.foregroundHoveredColor.b, colorSet.foregroundHoveredColor.a/4): 'transparent'
	property color foregroundHiddenPartUpdatingColor : colorSet.foregroundUpdatingColor ? Qt.rgba(colorSet.foregroundUpdatingColor.r, colorSet.foregroundUpdatingColor.g, colorSet.foregroundUpdatingColor.b, colorSet.foregroundUpdatingColor.a/4): 'transparent'
	property color foregroundHiddenPartPressedColor : colorSet.foregroundPressedColor ? Qt.rgba(colorSet.foregroundPressedColor.r, colorSet.foregroundPressedColor.g, colorSet.foregroundPressedColor.b, colorSet.foregroundPressedColor.a/4): 'transparent'
	
	property int percentageDisplayed : 100
	
	
	// If `useStates` = true, the used icons are:
	// `icon`_pressed, `icon`_hovered and `icon`_normal.
	property string icon : colorSet.icon
	
	// ---------------------------------------------------------------------------
	
	signal clicked
	
	// ---------------------------------------------------------------------------
	
	function _getIcon () {
		if(isCustom)
			return wrappedButton.icon
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
	function getBackgroundColor(){
		if(isCustom){
			if(wrappedButton.icon == '')
				return wrappedButton.colorSet.backgroundNormalColor
			if (wrappedButton.updating)
				return wrappedButton.colorSet.backgroundUpdatingColor
			if (!useStates)
				return wrappedButton.colorSet.backgroundNormalColor
			if (!wrappedButton.enabled)
				return wrappedButton.colorSet.backgroundDisabledColor
			return button.down ? wrappedButton.colorSet.backgroundPressedColor
							   : (button.hovered ? wrappedButton.colorSet.backgroundHoveredColor: wrappedButton.colorSet.backgroundNormalColor)
		}else
			return 'transparent'
	}
	function getForegroundColor(){
		if(isCustom){
			if(wrappedButton.icon == '')
				return wrappedButton.colorSet.foregroundNormalColor
			if (wrappedButton.updating)
				return wrappedButton.colorSet.foregroundUpdatingColor
			if (!useStates)
				return wrappedButton.colorSet.foregroundNormalColor
			if (!wrappedButton.enabled)
				return wrappedButton.colorSet.foregroundDisabledColor
			return button.down ? wrappedButton.colorSet.foregroundPressedColor
							   : (button.hovered ? wrappedButton.colorSet.foregroundHoveredColor: wrappedButton.colorSet.foregroundNormalColor)
		}else
			return "black"
	}
	function getForegroundHiddenPartColor(){
		if(isCustom){
			if(wrappedButton.icon == '')
				return wrappedButton.foregroundHiddenPartNormalColor
			if (wrappedButton.updating)
				return wrappedButton.foregroundHiddenPartUpdatingColor
			if (!useStates)
				return wrappedButton.foregroundHiddenPartNormalColor
			if (!wrappedButton.enabled)
				return wrappedButton.foregroundHiddenPartDisabledColor
			return button.down ? wrappedButton.foregroundHiddenPartPressedColor
							   : (button.hovered ? wrappedButton.foregroundHiddenPartHoveredColor: wrappedButton.foregroundHiddenPartNormalColor)
		}else
			return "#80FFFFFF"
	}
	// ---------------------------------------------------------------------------
	
	height: iconSize || parent.iconSize || parent.height
	width: iconSize || parent.iconSize || parent.width
	
	Button {
		id: button
		
		anchors.fill: parent
		background: Rectangle {
			id: backgroundColor
			color: getBackgroundColor()
		}
		hoverEnabled: !wrappedButton.updating//|| wrappedButton.autoIcon
		
		onClicked: !wrappedButton.updating && wrappedButton.enabled && wrappedButton.clicked()
		Rectangle{
			id: foregroundColor
			anchors.fill:parent
			visible: false
			color: 'transparent'
			Rectangle{
				anchors.fill:parent
				color: getForegroundColor()	
				anchors.rightMargin: parent.width  * ( 1 - wrappedButton.percentageDisplayed / 100 )
			}
		}	
		Rectangle{
			id: foregroundHiddenPartColor
			anchors.fill:parent
			visible: false
			color: 'transparent'
			Rectangle{
				anchors.fill:parent
				color: getForegroundHiddenPartColor()	
				anchors.leftMargin: parent.width  * wrappedButton.percentageDisplayed / 100
			}
		}	
		
		
		Icon {
			id: icon
			
			anchors.centerIn: parent
			icon: {
				if(!Images[_getIcon()])
					console.log(_getIcon())
				return Images[_getIcon()].id
				}
			iconSize: wrappedButton.iconSize || (
						  parent.width > parent.height ? parent.height : parent.width
						  )
			visible: !isCustom
		}
		
		
		OpacityMask{
			anchors.fill: foregroundColor
			source: foregroundColor
			maskSource: icon
			visible: isCustom
			MouseArea{
				anchors.fill:parent
				hoverEnabled: true
				acceptedButtons: Qt.NoButton
				cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
			}
		}
	 
     
		OpacityMask{
			id: mask
			anchors.fill: foregroundHiddenPartColor
			source: foregroundHiddenPartColor
			maskSource: icon
			visible: isCustom && percentageDisplayed != 100
			/*
			layer {
				enabled: true
				effect: ColorOverlay {
					color: "#80FFFFFF"
				}
			}*/
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
