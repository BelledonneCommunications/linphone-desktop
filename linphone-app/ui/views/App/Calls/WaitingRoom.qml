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
	color: WaitingRoomStyle.backgroundColor
	property ConferenceInfoModel conferenceInfoModel
	property CallModel callModel	// Store the call for processing calling.
	property bool previewLoaderEnabled: callModel ? callModel.videoEnabled : true
	property var _sipAddressObserver: callModel ? SipAddressesModel.getSipAddressObserver(callModel.fullPeerAddress, callModel.fullLocalAddress) : undefined
	
	signal cancel()
	
	function close(){
		mainItem.previewLoaderEnabled = false// Need it to close camera.
	}
	function open(){
		mainItem.previewLoaderEnabled = callModel ? callModel.videoEnabled : true
	}
	
	//onCallModelChanged: callModel ? contentsStack.replace(callingComponent) : contentsStack.replace(cameraComponent)
	onCallModelChanged: contentsStack.flipped = !!callModel
	
	Component.onDestruction: {mainItem.previewLoaderEnabled = false;_sipAddressObserver=null}// Need to set it to null because of not calling destructor if not.
	
	ColumnLayout {
		anchors.fill: parent
		ColumnLayout{
			Layout.preferredHeight: 60
			Layout.alignment: Qt.AlignCenter
			Layout.topMargin: 15
			spacing: 5
			BusyIndicator {
				Layout.alignment: Qt.AlignCenter
				Layout.preferredHeight: WaitingRoomStyle.header.busyIndicator.height
				Layout.preferredWidth: WaitingRoomStyle.header.busyIndicator.width
				color: WaitingRoomStyle.header.busyIndicator.color
				visible: mainItem.callModel && mainItem.callModel.isOutgoing
			}
			Text{
				Layout.preferredHeight: 60
				Layout.alignment: Qt.AlignCenter
				text: mainItem.conferenceInfoModel ? mainItem.conferenceInfoModel.subject 
												   : (mainItem._sipAddressObserver ? UtilsCpp.getDisplayName(mainItem._sipAddressObserver.peerAddress) : '')
				color: WaitingRoomStyle.title.color
				font.pointSize:  WaitingRoomStyle.title.pointSize
				horizontalAlignment: Qt.AlignHCenter
				verticalAlignment: Qt.AlignVCenter
			}
		}
		Text {
			Layout.fillWidth: true
			horizontalAlignment: Qt.AlignHCenter
			verticalAlignment: Qt.AlignVCenter
				
			color: WaitingRoomStyle.callError.color
			font.pointSize: WaitingRoomStyle.callError.pointSize
			width: parent.width
			visible: mainItem.callModel && mainItem.callModel.callError
			text: mainItem.callModel && mainItem.callModel.callError ? mainItem.callModel.callError : ''
		}
		RowLayout{
			id: loader
			Layout.fillWidth: true
			Layout.fillHeight: true
			property var previewDefinition: SettingsModel.getCurrentPreviewVideoDefinition()
			onPreviewDefinitionChanged: console.log(Utils.printObject(previewDefinition))
			property real cameraRatio: previewDefinition.height > 0 ? previewDefinition.width/previewDefinition.height : 1.0
			property int minSize: Math.min( loader.height, loader.width)
			property int cameraHeight: Math.min(Math.min(cameraRatio * minSize, loader.width) / cameraRatio, minSize)
			property int cameraWidth: cameraRatio * cameraHeight
			Item{
				Layout.fillHeight: true
				Layout.fillWidth: true
				
				Flipable{
					id: contentsStack
					anchors.centerIn: parent
					height: loader.cameraHeight
					width : loader.cameraWidth
					property bool flipped: false
					
					transform: Rotation {
						id: rotation
						origin.x: contentsStack.width/2
						origin.y: contentsStack.height/2
						axis.x: 0; axis.y: 1; axis.z: 0     // set axis.y to 1 to rotate around y-axis
						angle: 0    // the default angle
					}
					
					states: State {
						name: "back"
						PropertyChanges { target: rotation; angle: 180 }
						when: contentsStack.flipped
					}
					
					transitions: Transition {
						NumberAnimation { target: rotation; property: "angle"; duration: 500 }
					}
					
					front: CameraView{
						id: previewLoader
						showCloseButton: false
						enabled: mainItem.previewLoaderEnabled
						height: loader.cameraHeight
						width : loader.cameraWidth
						onVideoDefinitionChanged: loader.previewDefinition = SettingsModel.getCurrentPreviewVideoDefinition()
						ActionButton{
							anchors.top: parent.top
							anchors.right: parent.right
							anchors.topMargin: 10
							anchors.rightMargin: 10
							isCustom: true
							backgroundRadius: width/2
							colorSet: WaitingRoomStyle.buttons.options
							toggled: mediaMenu.visible
							onClicked: mediaMenu.visible = !mediaMenu.visible
						}
					}
					back: IncallAvatar {
						id: avatar
						anchors.centerIn: parent
						height: Utils.computeAvatarSize(loader, CallStyle.container.avatar.maxSize)
						width: height
						backgroundColor: WaitingRoomStyle.avatar.backgroundColor
						image: mainItem._sipAddressObserver && mainItem._sipAddressObserver.contact && mainItem._sipAddressObserver.contact.vcard.avatar
						username: mainItem.conferenceInfoModel ? mainItem.conferenceInfoModel.subject 
															   : (mainItem._sipAddressObserver ? UtilsCpp.getDisplayName(mainItem._sipAddressObserver.peerAddress) : '')
					}
				}
			}
			MultimediaParametersDialog{
				id: mediaMenu
				Layout.fillHeight: true
				Layout.leftMargin: 10
				Layout.rightMargin: 10
				Layout.minimumHeight: fitHeight
				Layout.minimumWidth: fitWidth
				radius: 8
				flat: true
				showMargins: true
				fixedSize: false
				onExitStatus: visible = false
				visible: false
			}
		}
		// -------------------------------------------------------------------------
		// Action Buttons.
		// -------------------------------------------------------------------------
		Item{
			Layout.fillWidth: true
			Layout.topMargin: 25
			Layout.bottomMargin: 25
			Layout.leftMargin: 25
			Layout.rightMargin: 25
			// Action buttons
			RowLayout{
				anchors.centerIn: parent
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
					visible: !mainItem.callModel
					isCustom: true
					backgroundRadius: 90
					colorSet: cameraEnabled  ? WaitingRoomStyle.buttons.cameraOn : WaitingRoomStyle.buttons.cameraOff
					enabled: modeChoice.selectedMode != 2
					onClicked: cameraEnabled = !cameraEnabled
				}
			}
			RowLayout{
				anchors.centerIn: parent
				anchors.horizontalCenterOffset: loader.cameraWidth/2 - modeChoice.width/2
				visible: !mainItem.callModel
				ActionButton{
					id: modeChoice
					property int selectedMode: SettingsModel.videoConferenceLayout
					isCustom: true
					backgroundRadius: width/2
					colorSet: selectedMode == LinphoneEnums.ConferenceLayoutGrid ? WaitingRoomStyle.buttons.gridLayout :
												  selectedMode == LinphoneEnums.ConferenceLayoutActiveSpeaker ?  WaitingRoomStyle.buttons.activeSpeakerLayout : WaitingRoomStyle.buttons.audioOnly
					onClicked: selectedMode = (selectedMode + 1) % 3
				}
			}
			Item{
				Layout.fillWidth: true
			}
		}
		RowLayout{
			Layout.alignment: Qt.AlignCenter
			Layout.bottomMargin: 15
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
		
	}
	
}
