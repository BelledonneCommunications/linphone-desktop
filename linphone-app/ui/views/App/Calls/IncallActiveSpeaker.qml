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
	property bool isConferenceReady: callModel.isConference && callModel.conferenceModel && callModel.conferenceModel.isReady
	
	property int participantCount: callModel.isConference ? allDevices.count + 1 : 2	// +me. allDevices==0 if !conference
	
	onParticipantCountChanged: {console.log("Conf count: " +participantCount); Qt.callLater(allDevices.updateCurrentDevice)}
	
	property ParticipantDeviceProxyModel participantDevices : ParticipantDeviceProxyModel {
			id: allDevices
			callModel: mainItem.callModel
			showMe: false
			
			onParticipantSpeaking: updateCurrentDevice()
			
			
			onConferenceCreated: cameraView.resetCamera()
			function updateCurrentDevice(){
				if( callModel ){
					if( callModel.isConference) {
						var device = getLastActiveSpeaking()
						if(device)	// Get 
							cameraView.currentDevice = device
					}
    			}
			}
			onMeChanged: if(cameraView.isPreview) {
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
		anchors.fill: parent
		anchors.leftMargin: isRightReducedLayout || isLeftReducedLayout? 30 : 140
		anchors.rightMargin: isRightReducedLayout ? 10 : 140
		callModel: mainItem.callModel
		deactivateCamera: isPreview && callModel.pausedByUser
							? true
							: callModel.isConference
								?  (callModel && (callModel.pausedByUser || callModel.status === CallModel.CallStatusPaused) )
									|| (!callModel.cameraEnabled && mainItem.participantCount == 1)
									|| (currentDevice && !currentDevice.videoEnabled)// && mainItem.participantCount == 2)
									|| !mainItem.isConferenceReady
								: (callModel && (callModel.pausedByUser || callModel.status === CallModel.CallStatusPaused || !callModel.videoEnabled) )
									|| currentDevice && !currentDevice.videoEnabled
								
		isVideoEnabled: !deactivateCamera
		onDeactivateCameraChanged: console.log("deactivateCamera? "+deactivateCamera)
		isPreview: !preview.visible && mainItem.participantCount == 1
		onIsPreviewChanged: {
            console.log("ispreview ? " +isPreview + "visible?"+preview.visible +", pCount="+mainItem.participantCount
				+" / ready?" +mainItem.isConferenceReady
				+" / allCount=" +allDevices.count
            )
			if( isPreview){
				currentDevice = allDevices.me
				cameraView.resetCamera()
			}else
				allDevices.updateCurrentDevice()
				cameraView.resetCamera()
			}
		isCameraFromDevice: isPreview
		onCurrentDeviceChanged: console.log("CurrentDevice: "+currentDevice)
		isPaused: isPreview && callModel.pausedByUser
					? false
					: callModel.isConference
						? //callModel && callModel.pausedByUser && mainItem.participantCount != 2 || 
							(currentDevice && currentDevice.isPaused)
						: callModel && !callModel.pausedByUser && (callModel.status === CallModel.CallStatusPaused)
		
		onIsPausedChanged: console.log("ispaused ? " +isPaused + " = " +callModel.pausedByUser + " / " + (currentDevice ? currentDevice.isPaused : 'noDevice') +" / " +callModel.isConference + " / " +callModel.status )
		quickTransition: true
		showCloseButton: false
		showActiveSpeakerOverlay: false	// This is an active speaker. We don't need to show the indicator.
		showCustomButton:  false
		avatarStickerBackgroundColor: isPreview ?  IncallStyle.container.avatar.stickerPreviewBackgroundColor : IncallStyle.container.avatar.stickerBackgroundColor
		avatarBackgroundColor: IncallStyle.container.avatar.backgroundColor
		Component.onCompleted: console.log("Completed: "+isPaused + " = " +callModel.pausedByUser + " / " + (currentDevice ? currentDevice.isPaused : 'noDevice') 
												+" isPreview?" +isPreview
												+" / Video?" +(currentDevice  ? currentDevice.videoEnabled : "NoDevice") + "-"+(callModel ? callModel.videoEnabled : "NoCall")
												+" / Camera?" +(currentDevice  ? currentDevice.cameraEnabled : "NoDevice") + "-"+(callModel ? callModel.cameraEnabled : "NoCall")
												+" / Deactivated?"+deactivateCamera
												+" / " +callModel.isConference + " / " +callModel.status)
	}
	Item{// Need an item to not override Sticker internal states. States are needed for changing anchors.
		id: preview
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.rightMargin: 30
		anchors.bottomMargin: 15
		
		height: visible ? miniViews.cellHeight : 0
		width: 16 * height / 9
		
		//property bool showMe : !(callModel && callModel.pausedByUser) && (callModel.isConference || callModel.localVideoEnabled)
		
		visible: mainItem.isConferenceReady && allDevices.count >= 1
				|| (!callModel.isConference && mainItem.callModel.cameraEnabled)// use videoEnabled if we want to show the preview sticker
				
		onVisibleChanged: console.log("visible? "+visible + " / video?" +(callModel ? callModel.videoEnabled : "NoCall")
											+ " / camera?" +(callModel ? callModel.cameraEnabled : "NoCall")
											)
		
		Loader{
			anchors.fill: parent
			anchors.margins: 3
			sourceComponent: 
			Sticker{
				id: previewSticker
				deactivateCamera: !mainItem.callModel || callModel.pausedByUser || !mainItem.callModel.cameraEnabled
										//|| (!callModel.isConference && !mainItem.callModel.videoEnabled)
										//|| (callModel.isConference && !mainItem.callModel.cameraEnabled)
				
				//|| ( (callModel.isConference && !mainItem.callModel.cameraEnabled) || (!callModel.isConference && !mainItem.callModel.localVideoEnabled) )
				onDeactivateCameraChanged: console.log(deactivateCamera + " = " +mainItem.callModel +" / " +mainItem.callModel.localVideoEnabled + " / " +mainItem.callModel.cameraEnabled)
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
			active: parent.visible
		}
	}
	Item{
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.bottom: preview.top
		anchors.rightMargin: 30
		anchors.topMargin: 15
		anchors.bottomMargin: 15
//---------------
		width: 16 * miniViews.cellHeight / 9
		visible: mainItem.isConferenceReady || !callModel.isConference
		
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
						deactivateCamera: (!mainItem.isConferenceReady || !callModel.isConference)
											&& (index <0 || !mainItem.cameraEnabled || (!modelData.videoEnabled) || (callModel && callModel.pausedByUser) )
						currentDevice: modelData.isPreview ? null : modelData
						callModel: modelData.isPreview ? null : mainItem.callModel
						isCameraFromDevice:  mainItem.callModel.isConference
						isPaused: currentDevice && currentDevice.isPaused
						onIsPausedChanged: console.log("paused:"+isPaused)
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

