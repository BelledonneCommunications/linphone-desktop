import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import Common 1.0
import Linphone 1.0
import LinphoneEnums 1.0
import UtilsCpp 1.0

import Common.Styles 1.0
import App.Styles 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils


// =============================================================================

Rectangle {
	id: mainItem
	color: WaitingRoomStyle.backgroundColor.color
	property ConferenceInfoModel conferenceInfoModel
	property CallModel callModel	// Store the call for processing calling.
	property bool previewLoaderEnabled: callModel ? callModel.videoEnabled : SettingsModel.videoAvailable
	property var _sipAddressObserver: callModel ? SipAddressesModel.getSipAddressObserver(callModel.fullPeerAddress, callModel.fullLocalAddress) : undefined
	property bool isEnded: callModel && callModel.status == CallModel.CallStatusEnded
	property bool _simpleGraphRunning: false
	
	signal cancel()
	
	function reset(){
		close()
		open()
	}
	function close(){
		mainItem.previewLoaderEnabled = false// Need it to close camera.
		updateSimpleGraph(false)
	}
	function open(){
		mainItem.previewLoaderEnabled = callModel ? callModel.videoEnabled : true
		updateSimpleGraph(true)
	}
	function updateSimpleGraph(enable){
		if(enable != _simpleGraphRunning){
			_simpleGraphRunning = enable;
			if(_simpleGraphRunning) SettingsModel.startCaptureGraph()
			else SettingsModel.stopCaptureGraph();
		}
	}

	onEnabledChanged: updateSimpleGraph(enabled)
	//onCallModelChanged: callModel ? contentsStack.replace(callingComponent) : contentsStack.replace(cameraComponent)
	//onCallModelChanged: contentsStack.flipped = !!callModel
	Component.onCompleted: updateSimpleGraph(true)
	Component.onDestruction: {mainItem.previewLoaderEnabled = false;_sipAddressObserver=null;updateSimpleGraph(false)}// Need to set it to null because of not calling destructor if not.
	
	Connections{
		target:window
		onClosing: mainItem.close()
	}

	ColumnLayout {
		anchors.fill: parent
		ColumnLayout{
			Layout.alignment: Qt.AlignCenter
			Layout.bottomMargin: (mainItem.conferenceInfoModel && mainItem.callModel ? 10 : 30)
			spacing: 10
			BusyIndicator {
				id: busyIndicator
				Layout.alignment: Qt.AlignCenter
				Layout.preferredHeight: WaitingRoomStyle.header.busyIndicator.height
				Layout.preferredWidth: WaitingRoomStyle.header.busyIndicator.width
				Layout.topMargin: 30
				color: WaitingRoomStyle.header.busyIndicator.colorModel.color
				visible: mainItem.callModel && mainItem.callModel.status !== CallModel.CallStatusConnected && !mainItem.isEnded
			}
			
			Text{
				Layout.alignment: Qt.AlignCenter
				Layout.topMargin: busyIndicator.visible ? 0 : 30
				text: mainItem.callModel
						? mainItem.isEnded
						//: "Call ended" : status of the call in waiting room when the call end.
							? qsTr("endCallStatus")
							: mainItem.callModel.isOutgoing 
						//: "Outgoing call" : status of the call in waiting room when user is calling.
								? qsTr("outgoingCallStatus")
						//: "Incoming call" : status of the call in waiting room when user receive a call.
								: qsTr("incomingCallStatus")
						: ''
				color: WaitingRoomStyle.title.colorModel.color
				font.pointSize:  WaitingRoomStyle.title.pointSize
				horizontalAlignment: Qt.AlignHCenter
				verticalAlignment: Qt.AlignVCenter
				visible: mainItem.callModel
			}
			Text {
				id: elapsedTime
				Layout.alignment: Qt.AlignCenter
				color: WaitingRoomStyle.elapsedTime.colorModel.color
				font.pointSize: WaitingRoomStyle.elapsedTime.pointSize
				horizontalAlignment: Text.AlignHCenter
				width: parent.width
				visible: mainItem.callModel && !mainItem.isEnded
				Timer {
					interval: 1000
					repeat: true
					running: mainItem.callModel
					triggeredOnStart: true
					property var startDate
					onRunningChanged: if( running) {
										elapsedTime.text = Utils.formatElapsedTime(0);
										startDate = new Date()
									}
					onTriggered: {elapsedTime.text = Utils.formatElapsedTime((new Date() - startDate)/1000)}
				}
			}
			Text{
				Layout.alignment: Qt.AlignCenter
				Layout.topMargin:  mainItem.callModel ? 0 : 40
				text: mainItem.conferenceInfoModel ? mainItem.conferenceInfoModel.subject 
												   : (mainItem._sipAddressObserver ? UtilsCpp.getDisplayName(mainItem._sipAddressObserver.peerAddress) : '')
				color: WaitingRoomStyle.title.colorModel.color
				font.pointSize:  WaitingRoomStyle.title.pointSize
				horizontalAlignment: Qt.AlignHCenter
				verticalAlignment: Qt.AlignVCenter
				visible: mainItem.conferenceInfoModel
			}
		}
		Text {
			id: errorArea
			Layout.fillWidth: true
			Layout.preferredHeight: implicitHeight
			Layout.bottomMargin: 10
			horizontalAlignment: Qt.AlignHCenter
			verticalAlignment: Qt.AlignVCenter
				
			color: WaitingRoomStyle.callError.colorModel.color
			font.pointSize: WaitingRoomStyle.callError.pointSize
			width: parent.width
			visible: mainItem.callModel && mainItem.callModel.callError
			text: mainItem.callModel && mainItem.callModel.callError ? mainItem.callModel.callError : ''
		}
		RowLayout{
			Layout.fillWidth: true
			Layout.fillHeight: true
			spacing: 0
			Item{
				id: stickerView
				Layout.fillHeight: true
				Layout.fillWidth: true
				Layout.leftMargin: 10
				Layout.rightMargin: 10
				Sticker{
					id: contentsStack
					
					property var previewDefinition: SettingsModel.getCurrentPreviewVideoDefinition()
					property real cameraRatio: previewDefinition.height > 0 ? previewDefinition.width/previewDefinition.height : 1.0
					property int minSize: Math.min( stickerView.height, stickerView.width)
					property int cameraHeight: Math.min(Math.min(cameraRatio * minSize, stickerView.width) / cameraRatio, minSize)
					property int cameraWidth: cameraRatio * cameraHeight
				
					anchors.centerIn: parent
					height: cameraHeight
					width : cameraWidth
					cameraQmlName: 'WaitingRoom'
					callModel:  mainItem.callModel
					conferenceInfoModel: mainItem.conferenceInfoModel
											? mainItem.conferenceInfoModel
											: mainItem.callModel
												? mainItem.callModel.conferenceModel
												: null
					deactivateCamera: !SettingsModel.videoAvailable || !mainItem.previewLoaderEnabled || mainItem.isEnded
					
					/*
					image: mainItem._sipAddressObserver && mainItem._sipAddressObserver.contact && mainItem._sipAddressObserver.contact.vcard.avatar
					
					username: mainItem.conferenceInfoModel ? mainItem.conferenceInfoModel.subject 
															   : (mainItem._sipAddressObserver ? UtilsCpp.getDisplayName(mainItem._sipAddressObserver.peerAddress) : '')
					*/					
					avatarRatio: 2/3
					
					showUsername: false
					
					
					
					onVideoDefinitionChanged: previewDefinition = SettingsModel.getCurrentPreviewVideoDefinition()
				}
			}
			Loader{
				id: multimediaLoader
				Layout.fillHeight: true
				Layout.leftMargin: 0
				Layout.rightMargin: 10
				Layout.minimumHeight: item? item.fitHeight : 0
				Layout.minimumWidth: item? item.fitWidth : 0
				
				sourceComponent: multimediaComponent
				active: false
				
				Component{
					id: multimediaComponent
					MultimediaParametersDialog{
						radius: 8
						flat: true
						showMargins: true
						fixedSize: false
						onExitStatus: multimediaLoader.active = false
					}
				}
			}
		}
		ColumnLayout{
			Layout.fillWidth: true
			//Layout.preferredHeight: 120 + 30
			Layout.topMargin: 20
			Layout.bottomMargin: 70
			Layout.alignment: Qt.AlignCenter
			visible: !mainItem.conferenceInfoModel
			spacing: 10
			Text{
				id: displayName
				Layout.alignment: Qt.AlignCenter
				text: mainItem._sipAddressObserver ? UtilsCpp.getDisplayName(mainItem._sipAddressObserver.peerAddress) : ''
				color: WaitingRoomStyle.callee.colorModel.color
				font.pointSize:  WaitingRoomStyle.callee.displayNamePointSize
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				visible: !mainItem.conferenceInfoModel
			}
			Text{
				Layout.fillWidth: true
				text: mainItem.callModel && UtilsCpp.toDisplayString(SipAddressesModel.cleanSipAddress(mainItem.callModel.peerAddress), SettingsModel.sipDisplayMode)
				color: WaitingRoomStyle.callee.colorModel.color
				font.pointSize:  WaitingRoomStyle.callee.addressPointSize
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				visible: mainItem.callModel && !mainItem.conferenceInfoModel && text != displayName.text
			}
		}
		// -------------------------------------------------------------------------
		// Action Buttons.
		// -------------------------------------------------------------------------
		RowLayout{
			Layout.preferredHeight: 40
			Layout.alignment: Qt.AlignCenter
			Layout.topMargin: 20
			Layout.bottomMargin: 15
			visible: mainItem.conferenceInfoModel && !mainItem.isEnded
			
			spacing: 30
			TextButtonA {
				//: 'Cancel' : Cancel button.
				text: qsTr('cancelButton')
				capitalization: Font.AllUppercase
				
				onClicked: {
					mainItem.close()
					if(mainItem.callModel)
						callModel.terminate()
					mainItem.cancel()
				}
			}
			TextButtonB {
				//: 'Start' : Button label for starting the conference.
				text: qsTr('startButton')
				capitalization: Font.AllUppercase
				visible: !mainItem.callModel
				
				onClicked: {CallsListModel.launchVideoCall(conferenceInfoModel.uri, '', 0,
														   {	video: modeChoice.selectedMode != 2
															   , camera: camera.cameraEnabled
															   , micro: !micro.microMuted
															   , audio: !speaker.speakerMuted
															   , layout: (modeChoice.selectedMode % 2)}) }
			}
		}
		Item{
			Layout.fillWidth: true
			Layout.preferredHeight: actionsButtons.height
			Layout.bottomMargin: 30
			Layout.topMargin: 20
			visible: !mainItem.isEnded
			// Action buttons
			RowLayout{
				id: actionsButtons
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.bottom: parent.bottom
				height: 40
				spacing: 10
				ActionSwitch {
					id: micro
					visible: SettingsModel.muteMicrophoneEnabled
					property bool microMuted: false
					onMicroMutedChanged: if(mainItem.callModel) mainItem.callModel.microMuted = microMuted
					isCustom: true
					backgroundRadius: 90
					colorSet: microMuted ? WaitingRoomStyle.buttons.microOff : WaitingRoomStyle.buttons.microOn
					onClicked: microMuted = !microMuted
				}
				VuMeter {
					enabled: !micro.microMuted
					Timer {
						interval: 50
						repeat: true
						running: parent.enabled
						
						onTriggered: parent.value = SettingsModel.getMicVolume()
					}
				}
				ActionSwitch {
					id: speaker
					property bool speakerMuted: false
					onSpeakerMutedChanged: if(mainItem.callModel) mainItem.callModel.speakerMuted = speakerMuted
					isCustom: true
					backgroundRadius: 90
					colorSet: speakerMuted  ? WaitingRoomStyle.buttons.speakerOff : WaitingRoomStyle.buttons.speakerOn
					onClicked: speakerMuted = !speakerMuted
				}
				ActionSwitch {
					id: camera
					property bool cameraEnabled: true
					visible: !mainItem.callModel && SettingsModel.videoAvailable
					isCustom: true
					backgroundRadius: 90
					colorSet: cameraEnabled  ? WaitingRoomStyle.buttons.cameraOn : WaitingRoomStyle.buttons.cameraOff
					enabled: modeChoice.selectedMode != 2
					onClicked: cameraEnabled = !cameraEnabled
					onCameraEnabledChanged: mainItem.previewLoaderEnabled = cameraEnabled
				}
				ActionButton{
					isCustom: true
					backgroundRadius: width/2
					colorSet: WaitingRoomStyle.buttons.call
					visible: false &&  !callModel && conferenceInfoModel
					onClicked: {mainItem.close()
								CallsListModel.launchVideoCall(conferenceInfoModel.uri, '', 0,
														   {	video: modeChoice.selectedMode != 2
															   , camera: camera.cameraEnabled
															   , micro: !micro.microMuted
															   , audio: !speaker.speakerMuted
															   , layout: (modeChoice.selectedMode % 2)}) }
				}
				ActionButton{
					isCustom: true
					backgroundRadius: width/2
					colorSet: WaitingRoomStyle.buttons.hangup
					visible: callModel
					onClicked: {
						mainItem.close()
						if(mainItem.callModel)
							callModel.terminate()
						mainItem.cancel()
					}
				}
			}
			
			ActionButton{
				id: optionsButton
				anchors.centerIn: parent
				anchors.horizontalCenterOffset: contentsStack.cameraWidth/2 - modeChoice.width/2
				
				visible: !mainItem.callModel
				isCustom: true
				colorSet: WaitingRoomStyle.buttons.options
				backgroundRadius: width/2
				toggled: multimediaLoader.active
				onClicked: multimediaLoader.active = !multimediaLoader.active
			}
			
			ActionButton{
				id: modeChoice
				property int selectedMode: SettingsModel.videoConferenceLayout
				anchors.verticalCenter: optionsButton.verticalCenter
				anchors.right: optionsButton.left
				anchors.rightMargin: 10
				
				visible: !mainItem.callModel && SettingsModel.videoAvailable
				toggled: layoutMenu.visible
				isCustom: true
				backgroundRadius: width/2
				colorSet: selectedMode == LinphoneEnums.ConferenceLayoutGrid ? WaitingRoomStyle.buttons.gridLayout :
											  selectedMode == LinphoneEnums.ConferenceLayoutActiveSpeaker ?  WaitingRoomStyle.buttons.activeSpeakerLayout : WaitingRoomStyle.buttons.audioOnly

				onClicked:layoutMenu.visible = !layoutMenu.visible
				onSelectedModeChanged: mainItem.previewLoaderEnabled = (selectedMode != 2) && camera.cameraEnabled

				Rectangle{
					id: layoutMenu
					anchors.bottom: parent.top
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.bottomMargin: 10
					height: menuLayout.implicitHeight + 10
					width: parent.width + 10
					
					visible: false
					color: WaitingRoomStyle.menuColor.color
					radius: 5
					
					ColumnLayout{
						id: menuLayout
						anchors.centerIn: parent
						ActionButton{
							isCustom: true
							backgroundRadius: width/2
							toggled: modeChoice.selectedMode == LinphoneEnums.ConferenceLayoutGrid
							colorSet: WaitingRoomStyle.buttons.gridLayout
							onClicked: {modeChoice.selectedMode = LinphoneEnums.ConferenceLayoutGrid ; layoutMenu.visible = false}
						}
						ActionButton{
							isCustom: true
							backgroundRadius: width/2
							toggled: modeChoice.selectedMode == LinphoneEnums.ConferenceLayoutActiveSpeaker
							colorSet: WaitingRoomStyle.buttons.activeSpeakerLayout
							onClicked: {modeChoice.selectedMode = LinphoneEnums.ConferenceLayoutActiveSpeaker ; layoutMenu.visible = false}
						}
						ActionButton{
							isCustom: true
							backgroundRadius: width/2
							toggled: modeChoice.selectedMode == 2
							colorSet: WaitingRoomStyle.buttons.audioOnly
							onClicked: {modeChoice.selectedMode = 2 ; layoutMenu.visible = false}
						}
					}
				}
			}
			
		}
	}
}
