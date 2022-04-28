import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import LinphoneUtils 1.0

import UtilsCpp 1.0

import App.Styles 1.0


// Temp
import 'Incall.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

Item {
	id: grid
	property alias callModel: participantDevices.callModel
	anchors.fill: parent
	
	property ParticipantDeviceProxyModel participantDevices : ParticipantDeviceProxyModel {
			id: participantDevices
			showMe: true
			onParticipantSpeaking: cameraView.currentDevice = speakingDevice
		}
	
	CameraView{
		id: cameraView
		enabled: index >=0
		anchors.fill: parent
		isPaused: callModel.pausedByUser || currentDevice && currentDevice.isPaused //callModel.pausedByUser
		showCloseButton: false
	//	onCloseRequested: grid.remove( index)
		color: 'black'
	}
}

