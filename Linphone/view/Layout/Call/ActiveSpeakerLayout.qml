import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQml.Models
import QtQuick.Controls as Control
import Linphone
import EnumsToStringCpp 1.0
import UtilsCpp 1.0
import SettingsCpp 1.0
// =============================================================================

Item{
	id: mainItem
	property alias call: allDevices.currentCall
	property ConferenceGui conference: call && call.core.conference || null
	property var callState: call && call.core.state || undefined
	
	property ParticipantDeviceProxy participantDevices : ParticipantDeviceProxy {
			id: allDevices
	}
	onCallChanged: {
		waitingTime.seconds = 0
		waitingTimer.restart()
		console.log("call changed", call, waitingTime.seconds)
	}
	RowLayout{
		anchors.fill: parent
		spacing: 16 * DefaultStyle.dp
		
		Sticker {
			id: activeSpeakerSticker
			//call: mainItem.call
			Layout.fillWidth: true
			Layout.fillHeight: true
			call: mainItem.call
			participantDevice: mainItem.conference && mainItem.conference.core.activeSpeaker
			property var address: participantDevice && participantDevice.core.address
			onAddressChanged: console.log(address)
			cameraEnabled: true
			qmlName: 'AS'
	
			Timer {
				id: waitingTimer
				interval: 1000
				repeat: true
				onTriggered: waitingTime.seconds += 1
			}
			ColumnLayout {
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: parent.top
				anchors.topMargin: 30 * DefaultStyle.dp
				visible: mainItem.callState === LinphoneEnums.CallState.OutgoingInit
						|| mainItem.callState === LinphoneEnums.CallState.OutgoingProgress
						|| mainItem.callState === LinphoneEnums.CallState.OutgoingRinging
						|| mainItem.callState === LinphoneEnums.CallState.OutgoingEarlyMedia
						|| mainItem.callState === LinphoneEnums.CallState.IncomingReceived
				BusyIndicator {
					indicatorColor: DefaultStyle.main2_100
					Layout.alignment: Qt.AlignHCenter
				}
				Text {
					id: waitingTime
					property int seconds
					text: UtilsCpp.formatElapsedTime(seconds)
					color: DefaultStyle.grey_0
					Layout.alignment: Qt.AlignHCenter
					horizontalAlignment: Text.AlignHCenter
					font {
						pixelSize: 30 * DefaultStyle.dp
						weight: 300 * DefaultStyle.dp
					}
					Component.onCompleted: {
						waitingTimer.restart()
					}
				}
			}
		}
		ListView{
			Layout.fillHeight: true
			Layout.preferredWidth: 300 * DefaultStyle.dp
			Layout.rightMargin: 10 * DefaultStyle.dp
			Layout.bottomMargin: 10 * DefaultStyle.dp
			visible: allDevices.count > 2
			spacing: 15 * DefaultStyle.dp
			model: allDevices
			delegate:
				Sticker {
					visible: mainItem.callState != LinphoneEnums.CallState.End  && mainItem.callState != LinphoneEnums.CallState.Released
					&& modelData.core.address != activeSpeakerSticker.address
					onVisibleChanged: console.log(modelData.core.address)
					height: visible ? 180 * DefaultStyle.dp : 0
					width: 300 * DefaultStyle.dp
					qmlName: 'M_'+index
					
					participantDevice: modelData
					cameraEnabled: visible
					Component.onCompleted: console.log(modelData.core.address)
					//previewEnabled: mainItem.call.core.cameraEnabled
				}
		}
	}
	Sticker {
		id: preview
		visible: allDevices.count <= 2
		height: 180 * DefaultStyle.dp
		width: 300 * DefaultStyle.dp
		anchors.right: mainItem.right
		anchors.bottom: mainItem.bottom
		anchors.rightMargin: 10 * DefaultStyle.dp
		anchors.bottomMargin: 10 * DefaultStyle.dp
		//participantDevice: allDevices.me
		cameraEnabled: allDevices.count <= 2
		previewEnabled: true
		qmlName: 'P'

		MovableMouseArea {
			id: previewMouseArea
			anchors.fill: parent
			movableArea: mainItem
			margin: 10 * DefaultStyle.dp
			function resetPosition(){
				preview.anchors.right = mainItem.right
				preview.anchors.bottom = mainItem.bottom
				preview.anchors.rightMargin = previewMouseArea.margin
				preview.anchors.bottomMargin = previewMouseArea.margin
			}
			onVisibleChanged: if(!visible){
				resetPosition()
			}
			drag.target: preview
			onDraggingChanged: if(dragging) {
				preview.anchors.right = undefined
				preview.anchors.bottom = undefined
			}
			onRequestResetPosition: resetPosition()
		}
	}
}
	/*
	Sticker {
		id: preview
		visible: mainItem.callState != LinphoneEnums.CallState.End
			&& mainItem.callState != LinphoneEnums.CallState.Released
		height: 180 * DefaultStyle.dp
		width: 300 * DefaultStyle.dp
		anchors.right: mainItem.right
		anchors.bottom: mainItem.bottom
		anchors.rightMargin: 10 * DefaultStyle.dp
		anchors.bottomMargin: 10 * DefaultStyle.dp
		AccountProxy{
			id: accounts
		}
		account: accounts.defaultAccount
		previewEnabled: mainItem.call.core.cameraEnabled

		MovableMouseArea {
			id: previewMouseArea
			anchors.fill: parent
			// visible: mainItem.participantCount <= 2
			movableArea: mainItem
			margin: 10 * DefaultStyle.dp
			function resetPosition(){
				preview.anchors.right = mainItem.right
				preview.anchors.bottom = mainItem.bottom
				preview.anchors.rightMargin = previewMouseArea.margin
				preview.anchors.bottomMargin = previewMouseArea.margin
			}
			onVisibleChanged: if(!visible){
				resetPosition()
			}
			drag.target: preview
			onDraggingChanged: if(dragging) {
				preview.anchors.right = undefined
				preview.anchors.bottom = undefined
			}
			onRequestResetPosition: resetPosition()
		}
	}
	
	property int previousWidth
	Component.onCompleted: {
		previousWidth = width
	}
	onWidthChanged: {
		if (width < previousWidth) {
			previewMouseArea.updatePosition(0, 0)
		} else {
			previewMouseArea.updatePosition(width - previousWidth, 0)
		}
		previousWidth = width
	}*/

/*

Item {
	id: mainItem
	property CallModel callModel
	property bool isRightReducedLayout: false
	property bool isLeftReducedLayout: false
	property bool cameraEnabled: true
	property bool isConference: callModel && callModel.isConference
	property bool isConferenceReady: isConference && callModel.conferenceModel && callModel.conferenceModel.isReady
	
	property int participantCount: isConference ? allDevices.count + 1 : 2	// +me. allDevices==0 if !conference
	
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
		cameraQmlName: 'AS'
		callModel: mainItem.callModel
		currentDevice: isPreview
							? allDevices.me
							: mainItem.isConference
								? allDevices.activeSpeaker
								: null
		deactivateCamera: !mainItem.cameraEnabled || (isPreview && callModel.pausedByUser)
							? true
							: mainItem.isConference
								?  (callModel && (callModel.pausedByUser || callModel.status === CallModel.CallStatusPaused) )
									|| (!(callModel && callModel.cameraEnabled) && mainItem.participantCount == 1)
									|| (currentDevice && !currentDevice.videoEnabled)// && mainItem.participantCount == 2)
									|| !mainItem.isConferenceReady
								: (callModel && (callModel.pausedByUser || callModel.status === CallModel.CallStatusPaused || !callModel.videoEnabled) )
									|| currentDevice && !currentDevice.videoEnabled
		isPreview: !preview.visible && mainItem.participantCount == 1
		onIsPreviewChanged: {cameraView.resetCamera() }
		isCameraFromDevice: isPreview
		isPaused: isPreview && callModel.pausedByUser
					? false
					: mainItem.isConference
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
				|| (!mainItem.isConference && mainItem.callModel && mainItem.callModel.cameraEnabled)// use videoEnabled if we want to show the preview sticker
		
		Loader{
			anchors.fill: parent
			anchors.margins: 3
			sourceComponent: 
			Sticker{
				id: previewSticker
				cameraQmlName: 'AS_Preview'
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
		id: miniViewArea
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.bottom: preview.top
		anchors.rightMargin: 30
		anchors.topMargin: 15
		anchors.bottomMargin: 0
//---------------
		width: 16 * miniViews.cellHeight / 9
		visible: mainItem.isConferenceReady || !mainItem.isConference
		property int heightLeft: parent.height - preview.height
		onHeightLeftChanged: {Qt.callLater(miniViewArea.forceRefresh)}
		function forceRefresh(){// Force a content refresh via margins. Qt is buggy when managing sizes in ListView.
			++miniViewArea.anchors.topMargin
			--miniViewArea.anchors.topMargin
		}
		
		ScrollableListView{
			id: miniViews
			property int cellHeight: 150
			anchors.fill: parent
			model : mainItem.isConference && mainItem.participantDevices.count > 1 ? mainItem.participantDevices : []
			spacing: 0
			verticalLayoutDirection: ListView.BottomToTop
			fitCacheToContent: false
			property int oldCount : 0// Count changed can be called without a change... (bug?). Use oldCount to avoid it.
			onCountChanged: {if(oldCount != count){ oldCount = count ; Qt.callLater(miniViewArea.forceRefresh)}}
			Component.onCompleted: {Qt.callLater(miniViewArea.forceRefresh)}
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
						cameraQmlName: 'S_'+index
						deactivateCamera: (!mainItem.isConferenceReady || !mainItem.isConference)
											&& (index <0 || !mainItem.cameraEnabled || (!modelData.videoEnabled) || (callModel && callModel.pausedByUser) )
						currentDevice: modelData.isPreview ? null : modelData
						callModel: modelData.isPreview ? null : mainItem.callModel
						isCameraFromDevice:  mainItem.isConference
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
*/

