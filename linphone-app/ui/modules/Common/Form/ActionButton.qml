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
	property color defaultBackgroundColor: 'white'
	property color defaultForegroundColor: 'black'
	
	// ---------------------------------------------------------------------------
	readonly property QtObject defaultColorSet : QtObject {
		property int iconSize: 30
		property string icon : ''
		property color backgroundNormalColor : defaultBackgroundColor
		property color backgroundDisabledColor : defaultBackgroundColor
		property color backgroundHoveredColor : defaultBackgroundColor
		property color backgroundUpdatingColor : defaultBackgroundColor
		property color backgroundPressedColor : defaultBackgroundColor
	// Color for shown part
		property color foregroundNormalColor : defaultForegroundColor
		property color foregroundDisabledColor : defaultForegroundColor
		property color foregroundHoveredColor : defaultForegroundColor
		property color foregroundUpdatingColor : defaultForegroundColor
		property color foregroundPressedColor : defaultForegroundColor
	}
	property QtObject colorSet: defaultColorSet
	onColorSetChanged: if(!colorSet) colorSet = defaultColorSet
	property bool isCustom : false
	property bool iconIsCustom: isCustom
	property bool enabled: true
	property bool updating: false
	property bool useStates: true
	property bool toggled: false
	//property bool autoIcon : false    // hovered/pressed : use an automatic layer instead of specific icon image
	property int iconSize : colorSet ? colorSet.iconSize : 0
	property int iconHeight: colorSet.iconHeight ? colorSet.iconHeight : 0
	property int iconWidth: colorSet.iconWidth ? colorSet.iconWidth : 0
	readonly property alias hovered: button.hovered
	property alias text: button.text
	property alias longPressedTimeout: longPressedTimeout.interval	// default: 500ms

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
	signal pressed(real x, real y)
	signal released(real x, real y)
	signal longPressed()
	// ---------------------------------------------------------------------------
		
	function _getIcon () {
		if(isCustom)
			return wrappedButton.icon
		if(wrappedButton.icon == '')
			return wrappedButton.icon;
		if (wrappedButton.updating || wrappedButton.toggled) {
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
	function getColor(color, defaultColor, debugVar){
		if(color)
			return color
			else{
				console.warn("No color defined for :"+debugVar+ " on "+_getIcon())
				return defaultColor
			}
	}
	function getBackgroundColor(){
		var defaultColor = 'transparent'
		if(isCustom){
			//if(wrappedButton.icon == '')
				//return getColor(wrappedButton.colorSet.backgroundNormalColor, defaultColor, 'backgroundNormalColor')
			if (wrappedButton.updating || wrappedButton.toggled)
				return getColor(wrappedButton.colorSet.backgroundUpdatingColor, defaultColor, 'backgroundUpdatingColor')
			if (!useStates)
				return getColor(wrappedButton.colorSet.backgroundNormalColor, defaultColor, 'backgroundNormalColor')
			if (!wrappedButton.enabled)
				return getColor(wrappedButton.colorSet.backgroundDisabledColor, defaultColor, 'backgroundDisabledColor')
			return button.down ? getColor(wrappedButton.colorSet.backgroundPressedColor, defaultColor, 'backgroundPressedColor')
							   : (button.hovered ? getColor(wrappedButton.colorSet.backgroundHoveredColor, defaultColor, 'backgroundHoveredColor')
									: getColor(wrappedButton.colorSet.backgroundNormalColor, defaultColor, 'backgroundNormalColor'))
		}else
			return defaultColor
	}
	function getForegroundColor(){
		var defaultColor = 'black'
		if(isCustom){
			//if(wrappedButton.icon == '')
				//return getColor(wrappedButton.colorSet.foregroundNormalColor, defaultColor, 'foregroundNormalColor')
			if (wrappedButton.updating || wrappedButton.toggled)
				return getColor(wrappedButton.colorSet.foregroundUpdatingColor, defaultColor, 'foregroundUpdatingColor')
			if (!useStates)
				return getColor(wrappedButton.colorSet.foregroundNormalColor, defaultColor, 'foregroundNormalColor')
			if (!wrappedButton.enabled)
				return getColor(wrappedButton.colorSet.foregroundDisabledColor, defaultColor, 'foregroundDisabledColor')
			return button.down ? getColor(wrappedButton.colorSet.foregroundPressedColor, defaultColor, 'foregroundPressedColor')
							   : (button.hovered ? getColor(wrappedButton.colorSet.foregroundHoveredColor, defaultColor, 'foregroundHoveredColor')
									: getColor(wrappedButton.colorSet.foregroundNormalColor, defaultColor, 'foregroundNormalColor'))
		}else
			return defaultColor
	}
	function getBackgroundHiddenPartColor(){
		var defaultColor = 'transparent'
		if(isCustom){
			//if(wrappedButton.icon == '')
				//return getColor(wrappedButton.colorSet.backgroundHiddenPartNormalColor, defaultColor, 'backgroundHiddenPartNormalColor')
			if (wrappedButton.updating || wrappedButton.toggled)
				return getColor(wrappedButton.colorSet.backgroundHiddenPartUpdatingColor, defaultColor, 'backgroundHiddenPartUpdatingColor')
			if (!useStates)
				return getColor(wrappedButton.colorSet.backgroundHiddenPartNormalColor, defaultColor, 'backgroundHiddenPartNormalColor')
			if (!wrappedButton.enabled)
				return getColor(wrappedButton.colorSet.backgroundHiddenPartDisabledColor, defaultColor, 'backgroundHiddenPartDisabledColor')
			return button.down ? getColor(wrappedButton.colorSet.backgroundHiddenPartPressedColor, defaultColor, 'backgroundHiddenPartPressedColor')
							   : (button.hovered ? getColor(wrappedButton.colorSet.backgroundHiddenPartHoveredColor, defaultColor, 'backgroundHiddenPartHoveredColor')
									: getColor(wrappedButton.colorSet.backgroundHiddenPartNormalColor, defaultColor, 'backgroundHiddenPartNormalColor'))
		}else
			return defaultColor
	}
	function getForegroundHiddenPartColor(){
	var defaultColor = '#80FFFFFF'
		if(isCustom){
			//if(wrappedButton.icon == '')
				//return getColor(wrappedButton.colorSet.foregroundHiddenPartNormalColor, defaultColor, 'foregroundHiddenPartNormalColor')
			if (wrappedButton.updating || wrappedButton.toggled)
				return getColor(wrappedButton.colorSet.foregroundHiddenPartUpdatingColor, defaultColor, 'foregroundHiddenPartUpdatingColor')
			if (!useStates)
				return getColor(wrappedButton.colorSet.foregroundHiddenPartNormalColor, defaultColor, 'foregroundHiddenPartNormalColor')
			if (!wrappedButton.enabled)
				return getColor(wrappedButton.colorSet.foregroundHiddenPartDisabledColor, defaultColor, 'foregroundHiddenPartDisabledColor')
			return button.down ? getColor(wrappedButton.colorSet.foregroundHiddenPartPressedColor, defaultColor, 'foregroundHiddenPartPressedColor')
							   : (button.hovered ? getColor(wrappedButton.colorSet.foregroundHiddenPartHoveredColor, defaultColor, 'foregroundHiddenPartHoveredColor')
									: getColor(wrappedButton.colorSet.foregroundHiddenPartNormalColor, defaultColor, 'foregroundHiddenPartNormalColor'))
		}else
			return defaultColor
	}
	// ---------------------------------------------------------------------------
	property int fitHeight: iconHeight || iconSize || parent.iconSize || parent.height
	property int fitWidth: iconWidth || iconSize || parent.iconSize || parent.width
	height: fitHeight
	width: fitWidth
	
	
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
					color: width > 0 ? getBackgroundHiddenPartColor() : 'transparent'
				}
			}
		hoverEnabled: !wrappedButton.updating//|| wrappedButton.autoIcon
		onClicked: {
						longPressedTimeout.stop()
						if(!wrappedButton.updating && wrappedButton.enabled) wrappedButton.clicked(pressX, pressY)
					}
		onPressed: if(!wrappedButton.updating && wrappedButton.enabled){
						longPressedTimeout.restart()
						wrappedButton.pressed(pressX, pressY)
					}
		onReleased: {
						longPressedTimeout.stop()
						if(!wrappedButton.updating && wrappedButton.enabled)
							wrappedButton.released(pressX, pressY)
					}
		onHoveredChanged: if(!hovered) longPressedTimeout.stop()
		
		Timer{
			id: longPressedTimeout
			interval: 500
			repeat: false
			onTriggered: if(!wrappedButton.updating && wrappedButton.enabled) wrappedButton.longPressed()
		}
		
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
				color: percentageDisplayed != 100 ? getForegroundHiddenPartColor() : 'transparent'
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
			visible: !iconIsCustom
		}
		
		OpacityMask{
			anchors.fill: foregroundColor
			source: foregroundColor
			maskSource: icon

			visible: iconIsCustom
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

			visible: iconIsCustom && percentageDisplayed != 100
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
		MouseArea{
			anchors.fill:parent
			hoverEnabled: true
			acceptedButtons: Qt.NoButton
			cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
			visible: !iconIsCustom
		}
	}
	
}
