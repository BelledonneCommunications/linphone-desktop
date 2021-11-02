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
	property string icon
	property color overwriteColor
// Use this slot because of testing overwriteColor in layer doesn't seem to work
	onOverwriteColorChanged: if(overwriteColor) 
								image.colorOverwriteEnabled = true
							else
								image.colorOverwriteEnabled = false
	height: iconSize
	width: iconSize
	
	Image {
		id:image
		property bool colorOverwriteEnabled : false
		mipmap: SettingsModel.mipmapEnabled
		cache: Images.areReadOnlyImages
		function getIconSize () {
			Utils.assert(
						(icon == null ||  icon == '' || iconSize != null && iconSize >= 0),
						'`iconSize` must be defined and must be positive. (icon=`' +
						icon + '`, iconSize=' + iconSize + ')'
						)
			
			return iconSize
		}
		
		anchors.centerIn: parent
		
		width: iconSize
		height: iconSize
		
		fillMode: Image.PreserveAspectFit
		source: Utils.resolveImageUri(icon)
		sourceSize.width: getIconSize()
		sourceSize.height: getIconSize()
		layer {
			enabled: image.colorOverwriteEnabled
			effect: ColorOverlay {
				color: mainItem.overwriteColor
			}
		}
	}
}
