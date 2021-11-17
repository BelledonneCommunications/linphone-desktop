import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import Common 1.0

// =============================================================================
// An animated (or not) button with image(s).
// =============================================================================

Item {
	id: wrappedButton
	
	// ---------------------------------------------------------------------------
	readonly property QtObject defaultColorSet : QtObject {
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
	property QtObject colorSet: defaultColorSet
	onColorSetChanged: if(!colorSet) colorSet = defaultColorSet
	property bool isCustom : false
	property bool enabled: true
	property bool updating: false
	property bool useStates: true
	//property bool autoIcon : false    // hovered/pressed : use an automatic layer instead of specific icon image
	property int iconSize : colorSet ? colorSet.iconSize : 0
	property int iconHeight: colorSet.iconHeight ? colorSet.iconHeight : 0
	property int iconWidth: colorSet.iconWidth ? colorSet.iconWidth : 0
	readonly property alias hovered: button.hovered
	property alias text: button.text
	// Tooltip aliases
	property alias tooltipText : tooltip.text
	property alias tooltipIsClickable : tooltip.isClickable
	property alias tooltipMaxWidth: tooltip.maxWidth
	property alias tooltipVisible: tooltip.visible
	// Custom mode  
	
	property alias backgroundRadius : backgroundColor.radius
	
	property alias horizontalAlignment: icon.horizontalAlignment
	property alias verticalAlignment: icon.verticalAlignment
	property alias fillMode: icon.fillMode
	
	
// Hidden part : transparent if not specified
	property color backgroundHiddenPartNormalColor : colorSet.backgroundHiddenPartNormalColor ? colorSet.backgroundHiddenPartNormalColor : (colorSet.backgroundNormalColor ? colorSet.backgroundNormalColor : 'transparent')
	property color backgroundHiddenPartDisabledColor : colorSet.backgroundHiddenPartDisabledColor ? colorSet.backgroundHiddenPartDisabledColor : (colorSet.backgroundDisabledColor ? colorSet.backgroundDisabledColor : 'transparent')
	property color backgroundHiddenPartHoveredColor : colorSet.backgroundHiddenPartHoveredColor ? colorSet.backgroundHiddenPartHoveredColor : (colorSet.backgroundHoveredColor ? colorSet.backgroundHoveredColor : 'transparent')
	property color backgroundHiddenPartUpdatingColor : colorSet.backgroundHiddenPartUpdatingColor ? colorSet.backgroundHiddenPartUpdatingColor : (colorSet.backgroundUpdatingColor ? colorSet.backgroundUpdatingColor : 'transparent')
	property color backgroundHiddenPartPressedColor : colorSet.backgroundHiddenPartPressedColor ? colorSet.backgroundHiddenPartPressedColor : (colorSet.backgroundPressedColor ? colorSet.backgroundPressedColor : 'transparent')
	
// AutoColor : alpha /4	for foreground
	property color foregroundHiddenPartNormalColor : colorSet.foregroundHiddenPartNormalColor ? colorSet.foregroundHiddenPartNormalColor : (colorSet.foregroundNormalColor ? Qt.rgba(colorSet.foregroundNormalColor.r, colorSet.foregroundNormalColor.g, colorSet.foregroundNormalColor.b, colorSet.foregroundNormalColor.a/4) : 'transparent')
	property color foregroundHiddenPartDisabledColor : colorSet.foregroundHiddenPartDisabledColor ? colorSet.foregroundHiddenPartDisabledColor : (colorSet.foregroundDisabledColor ? Qt.rgba(colorSet.foregroundDisabledColor.r, colorSet.foregroundDisabledColor.g, colorSet.foregroundDisabledColor.b, colorSet.foregroundDisabledColor.a/4): 'transparent')
	property color foregroundHiddenPartHoveredColor : colorSet.foregroundHiddenPartHoveredColor ? colorSet.foregroundHiddenPartHoveredColor : (colorSet.foregroundHoveredColor ? Qt.rgba(colorSet.foregroundHoveredColor.r, colorSet.foregroundHoveredColor.g, colorSet.foregroundHoveredColor.b, colorSet.foregroundHoveredColor.a/4): 'transparent')
	property color foregroundHiddenPartUpdatingColor : colorSet.foregroundHiddenPartUpdatingColor ? colorSet.foregroundHiddenPartUpdatingColor : (colorSet.foregroundUpdatingColor ? Qt.rgba(colorSet.foregroundUpdatingColor.r, colorSet.foregroundUpdatingColor.g, colorSet.foregroundUpdatingColor.b, colorSet.foregroundUpdatingColor.a/4): 'transparent')
	property color foregroundHiddenPartPressedColor : colorSet.foregroundHiddenPartPressedColor ? colorSet.foregroundHiddenPartPressedColor : (colorSet.foregroundPressedColor ? Qt.rgba(colorSet.foregroundPressedColor.r, colorSet.foregroundPressedColor.g, colorSet.foregroundPressedColor.b, colorSet.foregroundPressedColor.a/4): 'transparent')
//---------------------------------------------	
	property int percentageDisplayed : 100
	
	// If `useStates` = true, the used icons are:
	// `icon`_pressed, `icon`_hovered and `icon`_normal.
	property string icon : colorSet ? colorSet.icon : ''
	
	// ---------------------------------------------------------------------------
	
	signal clicked(real x, real y)
	
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
	function getBackgroundHiddenPartColor(){
		if(isCustom){
			if(wrappedButton.icon == '')
				return wrappedButton.backgroundHiddenPartNormalColor
			if (wrappedButton.updating)
				return wrappedButton.backgroundHiddenPartUpdatingColor
			if (!useStates)
				return wrappedButton.backgroundHiddenPartNormalColor
			if (!wrappedButton.enabled)
				return wrappedButton.backgroundHiddenPartDisabledColor
			return button.down ? wrappedButton.backgroundHiddenPartPressedColor
							   : (button.hovered ? wrappedButton.backgroundHiddenPartHoveredColor: wrappedButton.backgroundHiddenPartNormalColor)
		}else
			return 'transparent'
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
	
	height: iconHeight || iconSize || parent.iconSize || parent.height
	width: iconWidth || iconSize || parent.iconSize || parent.width
	
	Button {
		id: button
		
		anchors.fill: parent
		background: Row{
				anchors.fill: parent
				Rectangle {
					height: parent.height
					width:parent.width  * wrappedButton.percentageDisplayed / 100
					id: backgroundColor
					color: getBackgroundColor()
				}
				Rectangle {
					height: parent.height
					width: parent.width  * ( 1 - wrappedButton.percentageDisplayed / 100 )
					id: backgroundHiddenPartColor
					color: getBackgroundHiddenPartColor()
				}
			}
		hoverEnabled: !wrappedButton.updating//|| wrappedButton.autoIcon
		
		onClicked: !wrappedButton.updating && wrappedButton.enabled && wrappedButton.clicked(pressX, pressY)
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
			anchors.fill: iconHeight>0 || iconWidth ? parent : undefined
			icon: {
				var iconString = _getIcon()
				if( iconString ) {
					if(Images[iconString])
						return Images[iconString].id
					else
						console.log("No images for: "+iconString)
				}
				return ''
			}
			iconSize: wrappedButton.iconSize || (
						  parent.width > parent.height ? parent.height : parent.width
						  )
			iconHeight: wrappedButton.iconHeight
			iconWidth: wrappedButton.iconWidth
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
