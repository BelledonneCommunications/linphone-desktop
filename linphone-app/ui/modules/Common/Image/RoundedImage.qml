import QtQuick 2.7
import QtGraphicalEffects 1.0

import Linphone 1.0

// =============================================================================

Item {
	id: item
	
	property alias source: image.source
	property color backgroundColor: '#00000000'
	property color foregroundColor: '#00000000'
	readonly property alias status: image.status
	
	Rectangle {
		id: backgroundArea
		anchors.fill: parent
		color: item.backgroundColor
		radius: width/2
	}
	Image {
		id: image
		mipmap: SettingsModel.mipmapEnabled
		anchors.fill: parent
		fillMode: Image.PreserveAspectCrop
		sourceSize.width: parent.width
		sourceSize.height: parent.height
		layer.enabled: true
		layer.effect: OpacityMask {
			maskSource: backgroundArea
		}
	}
	Rectangle {
		id: foregroundArea
		anchors.fill: parent
		visible: color != 'transparent'
		color: item.foregroundColor
		radius: width/2
	}
}
