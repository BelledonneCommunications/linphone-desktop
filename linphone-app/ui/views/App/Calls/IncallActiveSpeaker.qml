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
	
	property ParticipantDeviceProxyModel participantDevices : ParticipantDeviceProxyModel {
			id: allDevices
			callModel: mainItem.callModel
			showMe: false		
			
			onConferenceCreated: cameraView.resetCamera()
		}
	
	Sticker{
		id: cameraView
		anchors.fill: parent
		anchors.leftMargin: isRightReducedLayout || isLeftReducedLayout? 30 : 140
		anchors.rightMargin: isRightReducedLayout ? 10 : 140
		callModel: mainItem.callModel
		currentDevice: isPreview
							? allDevices.me
							: callModel.isConference
								? allDevices.activeSpeaker
								: null
		deactivateCamera: !mainItem.cameraEnabled || (isPreview && callModel.pausedByUser)
							? true
							: callModel.isConference
								?  (callModel && (callModel.pausedByUser || callModel.status === CallModel.CallStatusPaused) )
									|| (!callModel.cameraEnabled && mainItem.participantCount == 1)
									|| (currentDevice && !currentDevice.videoEnabled)// && mainItem.participantCount == 2)
									|| !mainItem.isConferenceReady
								: (callModel && (callModel.pausedByUser || callModel.status === CallModel.CallStatusPaused || !callModel.videoEnabled) )
									|| currentDevice && !currentDevice.videoEnabled
		isPreview: !preview.visible && mainItem.participantCount == 1
		onIsPreviewChanged: {cameraView.resetCamera() }
		isCameraFromDevice: isPreview
		isPaused: isPreview && callModel.pausedByUser
					? false
					: callModel.isConference
						? //callModel && callModel.pausedByUser && mainItem.participantCount != 2 || 
							(currentDevice && currentDevice.isPaused)
						: callModel && !callModel.pausedByUser && (callModel.status === CallModel.CallStatusPaused)
		
		quickTransition: true
		showCloseButton: false
		showActiveSpeakerOverlay: false	// This is an active speaker. We don't need to show the indicator.
		showCustomButton:  false
		avatarStickerBackgroundColor: isPreview ?  IncallStyle.container.avatar.stickerPreviewBackgroundColor.color : IncallStyle.container.avatar.stickerBackgroundColor.color
		avatarBackgroundColor: IncallStyle.container.avatar.backgroundColor.color
	}
	Item{// Need an item to not override Sticker internal states. States are needed for changing anchors.
		id: preview
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.rightMargin: 30
		anchors.bottomMargin: 15
		
		height: visible ? miniViews.cellHeight : 0
		width: 16 * height / 9
		
		visible: mainItem.isConferenceReady && allDevices.count >= 1
				|| (!callModel.isConference && mainItem.callModel.cameraEnabled)// use videoEnabled if we want to show the preview sticker
		
		Loader{
			anchors.fill: parent
			anchors.margins: 3
			sourceComponent: 
			Sticker{
				id: previewSticker
				deactivateCamera: !mainItem.cameraEnabled || !mainItem.callModel || callModel.pausedByUser || !mainItem.callModel.cameraEnabled
				currentDevice: allDevices.me
				isPreview: true
				callModel: mainItem.callModel
				isCameraFromDevice:  true
				showCloseButton: false
				showCustomButton:  false
				showAvatarBorder: true
				avatarStickerBackgroundColor: IncallStyle.container.avatar.stickerPreviewBackgroundColor.color
				avatarBackgroundColor: IncallStyle.container.avatar.backgroundColor.color
			}
			active: parent.visible
		}
		
		MovableMouseArea{
			id: dragger
			anchors.fill: parent
			visible: mainItem.participantCount <= 2
			function resetPosition(){
				preview.anchors.right = mainItem.right
				preview.anchors.bottom = mainItem.bottom
			}
			onVisibleChanged: if(!visible){
				resetPosition()
			}
			drag.target: preview
			onDraggingChanged: if(dragging){
				preview.anchors.right = undefined
				preview.anchors.bottom = undefined
			}
			onRequestResetPosition: resetPosition()
		}
	}
	Item{
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.bottom: preview.top
		anchors.rightMargin: 30
		anchors.topMargin: 15
		anchors.bottomMargin: 0
//---------------
		width: 16 * miniViews.cellHeight / 9
		visible: mainItem.isConferenceReady || !callModel.isConference
		
		ScrollableListView{
			id: miniViews
			property int cellHeight: 150
			anchors.fill: parent
			model : mainItem.callModel.isConference && mainItem.participantDevices.count > 1 ? mainItem.participantDevices : []
			spacing: 0
			verticalLayoutDirection: ListView.BottomToTop
			fitCacheToContent: false
			property int oldCount : 0// Count changed can be called without a change... (bug?). Use oldCount to avoid it.
			onCountChanged: {if(oldCount != count){ oldCount = count ; Qt.callLater(forceRefresh)}}
			onHeightChanged: Qt.callLater(forceRefresh)
			function forceRefresh(){// Force a content refresh via layout direction. Qt is buggy when managing sizes in ListView.
				miniViews.verticalLayoutDirection = ListView.TopToBottom
				miniViews.verticalLayoutDirection = ListView.BottomToTop
			}
			Component.onCompleted: {Qt.callLater(forceRefresh)}
			delegate:Item{
					height: visible ? miniViews.cellHeight + 15 : 0
					width: visible ? miniViews.width : 0
					visible: cameraView.currentDevice != modelData
					clip:false
					Sticker{
						id: miniView
						anchors.fill: parent
						anchors.topMargin: 3
						anchors.leftMargin: 3
						anchors.rightMargin: 3
						anchors.bottomMargin: 18
						deactivateCamera: (!mainItem.isConferenceReady || !callModel.isConference)
											&& (index <0 || !mainItem.cameraEnabled || (!modelData.videoEnabled) || (callModel && callModel.pausedByUser) )
						currentDevice: modelData.isPreview ? null : modelData
						callModel: modelData.isPreview ? null : mainItem.callModel
						isCameraFromDevice:  mainItem.callModel.isConference
						isPaused: currentDevice && currentDevice.isPaused
						showCloseButton: false
						showCustomButton:  false
						showAvatarBorder: true
						avatarStickerBackgroundColor: IncallStyle.container.avatar.stickerBackgroundColor.color
						avatarBackgroundColor: IncallStyle.container.avatar.backgroundColor.color
					}
				}
		}
	}
}


