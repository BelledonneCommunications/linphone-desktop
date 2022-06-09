import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0

import UtilsCpp 1.0

import App.Styles 1.0


// Temp
import 'Incall.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

Item {
	id: mainItem
	property alias callModel: allDevices.callModel
	property bool isRightReducedLayout: false
	property bool isLeftReducedLayout: false
	property bool cameraEnabled: true
	property alias showMe : allDevices.showMe
	property int participantCount: allDevices.count

	property ParticipantDeviceProxyModel participantDevices : ParticipantDeviceProxyModel {
			id: allDevices
			showMe: true
			onParticipantSpeaking: cameraView.currentDevice = speakingDevice
			property bool cameraEnabled: callModel && callModel.cameraEnabled
			onCameraEnabledChanged: showMe = cameraEnabled	// Do it on changed to ignore hard bindings (that can be override)
		}
	
	CameraView{
		id: cameraView
		callModel: mainItem.callModel
		enabled: mainItem.cameraEnabled
		isCameraFromDevice: false
		isPreview: false
		anchors.fill: parent
		anchors.leftMargin: isRightReducedLayout || isLeftReducedLayout? 30 : 140
		anchors.rightMargin: isRightReducedLayout ? 10 : 140
		isPaused: (callModel && callModel.pausedByUser) || (currentDevice && currentDevice.isPaused) //callModel.pausedByUser
		showCloseButton: false
		showActiveSpeakerOverlay: false	// This is an active speaker. We don't need to show the indicator.
		color: 'black'
	}
	ScrollableListView{
		id: miniViews
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		anchors.rightMargin: 30
		anchors.topMargin: 30
		anchors.bottomMargin: 30
		property int cellHeight: 150
		
		width: 16 * cellHeight / 9
		model: mainItem.participantDevices
		spacing: 15
		verticalLayoutDirection: ItemView.BottomToTop
		delegate:Item{
				height: miniViews.cellHeight
				width: miniViews.width
				CameraView{
					id: miniView
					anchors.centerIn: parent
					height: miniViews.cellHeight - 6
					width: miniViews.width - 6
					enabled: index >=0 && mainItem.cameraEnabled
					currentDevice: modelData
					callModel: mainItem.callModel
					isCameraFromDevice: true
					isPaused: mainItem.callModel.pausedByUser || currentDevice && currentDevice.isPaused
					onCloseRequested: mainItem.showMe = false
				}
			}
	}
}

