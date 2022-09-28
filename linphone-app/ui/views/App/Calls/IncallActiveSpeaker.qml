import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import LinphoneEnums 1.0

import UtilsCpp 1.0

import App.Styles 1.0


// Temp
import 'Incall.js' as Logic
import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

Item {
	id: mainItem
	property CallModel callModel
	property bool isRightReducedLayout: false
	property bool isLeftReducedLayout: false
	property bool cameraEnabled: true
	property bool showMe : !(callModel && callModel.pausedByUser) && (callModel.isConference || callModel.localVideoEnabled)
	property int participantCount: callModel.isConference ? allDevices.count + 1 : 2	// +me
	
	onParticipantCountChanged: {console.log("Conf count: " +participantCount);allDevices.updateCurrentDevice()}
	
	property ParticipantDeviceProxyModel participantDevices : ParticipantDeviceProxyModel {
			id: allDevices
			callModel: mainItem.callModel
			showMe: false
			
			onParticipantSpeaking: updateCurrentDevice()
			
			
			onConferenceCreated: cameraView.resetCamera()
			function updateCurrentDevice(){
				var device = getLastActiveSpeaking()
				if(device)	// Get 
					cameraView.currentDevice = device
			}
			onMeChanged: if( cameraView.isPreview) {
					cameraView.currentDevice = me
					cameraView.resetCamera()
				}
		}
	
	function clearAll(layoutMode){
		if( layoutMode != LinphoneEnums.ConferenceLayoutActiveSpeaker){
			mainItem.cameraEnabled = false
			miniViews.model = []
		}
	}

	Sticker{
		id: cameraView
		callModel: mainItem.callModel
		deactivateCamera: (callModel && callModel.pausedByUser) || !mainItem.cameraEnabled || (currentDevice && !currentDevice.videoEnabled)
		isPreview: mainItem.showMe && allDevices.count == 0
		onIsPreviewChanged: if( isPreview){
			currentDevice = allDevices.me
			cameraView.resetCamera()
		}
		isCameraFromDevice: isPreview
		anchors.fill: parent
		anchors.leftMargin: isRightReducedLayout || isLeftReducedLayout? 30 : 140
		anchors.rightMargin: isRightReducedLayout ? 10 : 140
		isPaused: (callModel && callModel.pausedByUser) || (currentDevice && currentDevice.isPaused) //callModel.pausedByUser
		quickTransition: true
		showCloseButton: false
		showActiveSpeakerOverlay: false	// This is an active speaker. We don't need to show the indicator.
		showCustomButton:  false
		avatarStickerBackgroundColor: isPreview ?  IncallStyle.container.avatar.stickerPreviewBackgroundColor : IncallStyle.container.avatar.stickerBackgroundColor
		avatarBackgroundColor: IncallStyle.container.avatar.backgroundColor
	}
	Item{// Need an item to not override Sticker internal states. States are needed for changing anchors.
		id: preview
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.rightMargin: 30
		anchors.bottomMargin: 15
		
		height: miniViews.cellHeight
		width: 16 * height / 9
		
		visible: mainItem.showMe && (!callModel.isConference  || allDevices.count >= 1)
		onVisibleChanged: if(visible) previewSticker.resetCamera()
		Sticker{
			id: previewSticker
			anchors.fill: parent
			
			anchors.margins: 3
			deactivateCamera: !mainItem.callModel || !mainItem.showMe || !mainItem.callModel.cameraEnabled
			//onDeactivateCameraChanged: console.log(deactivateCamera + " = " +mainItem.callModel +" / " +mainItem.showMe +" / " +mainItem.callModel.localVideoEnabled)
			currentDevice: allDevices.me
			isPreview: true
			callModel: mainItem.callModel
			isCameraFromDevice:  true
			showCloseButton: false
			showCustomButton:  false
			showAvatarBorder: true
			avatarStickerBackgroundColor: IncallStyle.container.avatar.stickerPreviewBackgroundColor
			avatarBackgroundColor: IncallStyle.container.avatar.backgroundColor
		}
	}
	Item{
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.bottom: preview.top
		anchors.rightMargin: 30
		anchors.topMargin: 15
//---------------

		anchors.bottomMargin: 15
		width: 16 * miniViews.cellHeight / 9
		ScrollableListView{
			id: miniViews
			property int cellHeight: 150
			anchors.fill: parent
			model : mainItem.callModel.isConference && mainItem.participantDevices.count > 1 ? mainItem.participantDevices : []
			onModelChanged: {
				console.log( mainItem.callModel.isConference+"/"+mainItem.callModel.localVideoEnabled + "/" +mainItem.callModel.cameraEnabled + " / " +count)
				
				}
			spacing: 15
			verticalLayoutDirection: ListView.BottomToTop
			fitCacheToContent: false
			onCountChanged: updateView()
			onHeightChanged: updateView()
			function updateView(){
				if(contentItem.height < miniViews.height){ 
					contentItem.y = miniViews.height	// Qt workaround because it do not set correctly value with positionning to beginning
				}
			}
			Component.onCompleted: updateView()
			Timer{
				running: true
				interval: 500
				repeat: true
				onTriggered: miniViews.updateView()
			}
			delegate:Item{
					height: miniViews.cellHeight
					width: miniViews.width
					clip:false
					Sticker{
						id: miniView
						anchors.fill: parent
						anchors.margins: 3
						deactivateCamera: index <0 || !mainItem.cameraEnabled || (!modelData.videoEnabled) || (callModel && callModel.pausedByUser)
						currentDevice: modelData.isPreview ? null : modelData
						callModel: modelData.isPreview ? null : mainItem.callModel
						isCameraFromDevice:  mainItem.callModel.isConference
						isPaused: currentDevice && currentDevice.isPaused
						showCloseButton: false
						showCustomButton:  false
						showAvatarBorder: true
						avatarStickerBackgroundColor: IncallStyle.container.avatar.stickerBackgroundColor
						avatarBackgroundColor: IncallStyle.container.avatar.backgroundColor
					}
				}
		}
	}
}

