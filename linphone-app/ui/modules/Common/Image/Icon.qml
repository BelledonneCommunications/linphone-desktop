import QtQuick 2.7
import QtGraphicalEffects 1.12

import Common 1.0
import Linphone 1.0
import Utils 1.0

// =============================================================================
// An icon image properly resized.
// =============================================================================

Item {
	id: mainItem
	property var iconSize // Required.
	property int iconHeight: 0	// Or this
	property int iconWidth: 0	//	<-- too
	
	property string icon
	property color overwriteColor
	property alias horizontalAlignment: image.horizontalAlignment
	property alias verticalAlignment: image.verticalAlignment
	property alias fillMode: image.fillMode
	
	
// Use this slot because of testing overwriteColor in layer doesn't seem to work
	onOverwriteColorChanged: if(overwriteColor) 
								image.colorOverwriteEnabled = true
							else
								image.colorOverwriteEnabled = false
	height: iconHeight > 0 ? iconHeight : iconSize
	width: iconWidth > 0 ? iconWidth : iconSize
	
	Image {
		id:image
		property bool colorOverwriteEnabled : false
		mipmap: SettingsModel.mipmapEnabled
		cache: Images.areReadOnlyImages	
		asynchronous: true
		smooth: true
		//anchors.centerIn: parent
		anchors.fill: parent
		
		//width: iconWidth > 0 ? iconWidth : mainItem.width
		//height: iconHeight > 0 ? iconHeight : mainItem.height
		
		fillMode: Image.PreserveAspectFit
		source: Utils.resolveImageUri(icon)
		sourceSize.width:  (iconWidth > 0 ? iconWidth : iconSize)
		sourceSize.height: ( iconHeight > 0 ? iconHeight : iconSize)
		layer {
			enabled: image.colorOverwriteEnabled
			effect: ColorOverlay {
				color: mainItem.overwriteColor
			}
		}
	}
}
