import QtQuick 2.7
import QtGraphicalEffects 1.12

import Common 1.0
import Linphone 1.0
import Utils 1.0
import UtilsCpp 1.0

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
		anchors.fill: parent
		
		property bool colorOverwriteEnabled : false
		mipmap: SettingsModel.mipmapEnabled
		cache: Images.areReadOnlyImages	
		asynchronous: true
		smooth: true
		antialiasing: false
// Better quality is only available from Qt5.15
		fillMode: !qtIsNewer_5_15_0 ? Image.PreserveAspectFit : Image.Stretch // Stretch is default from Qt's doc
		// Keep aspect ratio is done by ImagePovider that use directly SVG scalings (=no loss quality).
		source: width != 0 && height != 0 ?  Utils.resolveImageUri(icon) : ''	// Do not load image with unknown requested size
		sourceSize.width: qtIsNewer_5_15_0
							? fillMode == Image.TileHorizontally
								? height
								: width
							: 0
		sourceSize.height: qtIsNewer_5_15_0
							? fillMode == Image.TileVertically
								? width
								: height
							: 0
		
		layer {
			enabled: image.colorOverwriteEnabled
			effect: ColorOverlay {
				color: mainItem.overwriteColor
			}
		}
	}
}
