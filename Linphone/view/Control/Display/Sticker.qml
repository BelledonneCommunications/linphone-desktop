import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

// Display a sticker from a call or from an account.
// The Avatar is shown while the camera become available.
// The loader restart in case of resetting the renderer. This allow to display the avatar while loading.

// TODO: sizes, colors, decorations
Item {
	id: mainItem
	height: 300
	width: 200
	property bool previewEnabled
	property bool securityBreach
	property CallGui call: null
	property ConferenceGui conference: call && call.core.conference || null
	property var callState: call && call.core.state || undefined
	property AccountGui account: null
	property ParticipantDeviceGui participantDevice: null
	property bool displayBorder : participantDevice && participantDevice.core.isSpeaking || false
	property alias displayPresence: avatar.displayPresence
	property color color: DefaultStyle.grey_600
    property real radius: Utils.getSizeWithScreenRatio(15)
	property bool remoteIsPaused: participantDevice
		? participantDevice.core.isPaused
		: previewEnabled
			? callState === LinphoneEnums.CallState.Paused
			: callState === LinphoneEnums.CallState.PausedByRemote

	property string remoteAddress: account 
		? account.core.identityAddress
		: participantDevice
			? participantDevice.core.address
			: call
				? call.core.remoteAddress
				: ""
	property var localNameObj: previewEnabled && call
		? UtilsCpp.getDisplayName(call.core.localAddress)
		: null
	property string localName: localNameObj ? localNameObj.value : ""
	property string displayName: account
		? account.core.displayName
		: participantDevice
			? participantDevice.core.displayName
			: call
				? previewEnabled
					? localName
					: call.core.remoteName
				: ""

	property var contactObj: call ? UtilsCpp.findFriendByAddress(call.core.remoteAddress) : null
	property var contact: contactObj && contactObj.value || null
	
	property var identityAddress: account ? UtilsCpp.getDisplayName(account.core.identityAddress) : null
    property bool videoEnabled: (previewEnabled && call && call.core.localVideoEnabled)
        || (!previewEnabled && call && call.core.remoteVideoEnabled)
        || (participantDevice && participantDevice.core.videoEnabled)
	property string qmlName
	property bool displayAll : !!mainItem.call
	property bool mutedStatus: participantDevice 
		? participantDevice.core.isMuted 
		: account && call
			? call.core.conference && call.core.microphoneMuted
			: false
	clip: false
	Rectangle {
		id: background
		color: noCameraLayout.visible ? mainItem.color : 'transparent'
		radius: mainItem.radius
		anchors.fill: parent
		border.color: DefaultStyle.main2_200
        border.width: mainItem.displayBorder ? Utils.getSizeWithScreenRatio(3) : 0
        property real minSize: Math.min(height, width)
		Item {
			id: noCameraLayout
			anchors.fill: parent
			visible: !cameraLoader.active || cameraLoader.status != Loader.Ready || !cameraLoader.item.isReady
			ColumnLayout {
				anchors.top: parent.top
                anchors.topMargin: Utils.getSizeWithScreenRatio(81)
				anchors.horizontalCenter: parent.horizontalCenter
				// Layout.alignment: Qt.AlignHCenter |Qt.AlignTop
				spacing: 0
				visible: !mainItem.account && (mainItem.callState === LinphoneEnums.CallState.OutgoingInit
						|| mainItem.callState === LinphoneEnums.CallState.OutgoingProgress
						|| mainItem.callState === LinphoneEnums.CallState.OutgoingRinging
						|| mainItem.callState === LinphoneEnums.CallState.OutgoingEarlyMedia
						|| mainItem.callState === LinphoneEnums.CallState.IncomingReceived)
				BusyIndicator {
					indicatorColor: DefaultStyle.main2_100
					Layout.alignment: Qt.AlignHCenter
                    indicatorHeight: Utils.getSizeWithScreenRatio(42)
                    indicatorWidth: Utils.getSizeWithScreenRatio(42)
				}
			}
			Item{
				id: centerItem
				visible: !mainItem.remoteIsPaused
				anchors.centerIn: parent
				height: mainItem.conference 
					? background.minSize * 142 / 372
                    : Utils.getSizeWithScreenRatio(120)
				width: height
				Avatar{
					id: avatar
					anchors.fill: parent
					visible: !joiningView.visible
					account: mainItem.account
					call: !mainItem.previewEnabled ? mainItem.call : null
					displayNameVal: mainItem.displayName
					securityBreach: mainItem.securityBreach ? mainItem.securityBreach : securityLevel === LinphoneEnums.SecurityLevel.Unsafe
					secured: securityLevel === LinphoneEnums.SecurityLevel.EndToEndEncryptedAndVerified
				}
				ColumnLayout{
					id: joiningView
					anchors.centerIn: parent
					spacing: 0
					visible: mainItem.participantDevice && (mainItem.participantDevice.core.state == LinphoneEnums.ParticipantDeviceState.Joining || mainItem.participantDevice.core.state == LinphoneEnums.ParticipantDeviceState.Alerting) || false
					BusyIndicator {
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(42)
						indicatorColor: DefaultStyle.main2_100
						Layout.alignment: Qt.AlignHCenter
                        indicatorHeight: Utils.getSizeWithScreenRatio(42)
                        indicatorWidth: Utils.getSizeWithScreenRatio(42)
					}
					Text {
                        Layout.preferredHeight: Utils.getSizeWithScreenRatio(27)
                        Layout.topMargin: Utils.getSizeWithScreenRatio(15) // (84-27)-42
                        //: "rejoint…"
                        text: qsTr("conference_participant_joining_text")
						color: DefaultStyle.grey_0
						Layout.alignment: Qt.AlignHCenter
						horizontalAlignment: Text.AlignHCenter
						font {
                            pixelSize: Utils.getSizeWithScreenRatio(20)
                            weight: Utils.getSizeWithScreenRatio(500)
						}
					}
				}
			}
			ColumnLayout {
				anchors.centerIn: parent
                spacing: Utils.getSizeWithScreenRatio(12)
				visible: mainItem.remoteIsPaused
				EffectImage {
					imageSource: AppIcons.pause
					colorizationColor: DefaultStyle.grey_0
					Layout.preferredHeight: background.width / 8
					Layout.preferredWidth: height
					Layout.alignment: Qt.AlignHCenter
				}
				Text {
					color: DefaultStyle.grey_0
					Layout.alignment: Qt.AlignHCenter
                    //: "En pause"
                    text: qsTr("conference_participant_paused_text")
					font {
                        pixelSize: Utils.getSizeWithScreenRatio(20)
                        weight: Utils.getSizeWithScreenRatio(500)
					}
				}
			}
			ColumnLayout {
				spacing: 0
				visible: mainItem.displayAll && !mainItem.remoteIsPaused && !mainItem.conference
				anchors.top: centerItem.bottom
                anchors.topMargin: Utils.getSizeWithScreenRatio(21)
				anchors.left: parent.left
				anchors.right: parent.right

				Text {
					Layout.fillWidth: true
					horizontalAlignment: Text.AlignHCenter
					text: mainItem.displayName
					color: DefaultStyle.grey_0
					font {
                        pixelSize: Utils.getSizeWithScreenRatio(22)
                        weight: Utils.getSizeWithScreenRatio(300)
						capitalization: Font.Capitalize
					}
				}
				Text {
					Layout.fillWidth: true
					horizontalAlignment: Text.AlignHCenter
					property string _text: mainItem.call && mainItem.call.core.remoteAddress
					text: SettingsCpp.hideSipAddresses ? UtilsCpp.getUsername(_text) : _text
					color: DefaultStyle.grey_0
					font {
                        pixelSize: Utils.getSizeWithScreenRatio(14)
                        weight: Utils.getSizeWithScreenRatio(300)
					}
				}
			}
		}
		Loader{
			id: cameraLoader
			anchors.fill: parent
			property bool reset: false
			Timer{
				id: resetTimer
				interval: 1
				triggeredOnStart: true
				onTriggered: {cameraLoader.reset = !cameraLoader.reset}
			}
            active: mainItem.visible && !mainItem.remoteIsPaused
            && mainItem.videoEnabled
            && mainItem.callState !== LinphoneEnums.CallState.End
            && mainItem.callState !== LinphoneEnums.CallState.Released
            && !cameraLoader.reset
            onActiveChanged: console.log("("+mainItem.qmlName+") Camera active " + active +", visible="+mainItem.visible +", videoEnabled="+mainItem.videoEnabled +", reset="+cameraLoader.reset)
			sourceComponent: cameraComponent
		}
		Component{
			id: cameraComponent
			Item {
				height: cameraLoader.height
				width: cameraLoader.width
				property alias isReady: cameraItem.isReady
				CameraGui{
					id: cameraItem
					anchors.fill: parent
					visible: false
					qmlName: mainItem.qmlName
					isPreview: mainItem.previewEnabled
					call: mainItem.call
					participantDevice: mainItem.participantDevice
					
					onRequestNewRenderer: {
						console.log("Request new renderer for " +mainItem.qmlName)
						resetTimer.restart()
					}
					layer.enabled: true
				}

				ShaderEffect {
					id: roundEffect
					property variant src: cameraItem
					property real edge: 0.9
					property real edgeSoftness: 0.9
					property real radius: mainItem.radius
					property real shadowSoftness: 0.5
					property real shadowOffset: 0.01
					anchors.fill: parent
					visible: cameraItem.isReady
					fragmentShader: 'qrc:/data/shaders/roundEffect.frag.qsb'
				}
			}
		}
		Text {
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.bottom: parent.bottom
            anchors.leftMargin: Utils.getSizeWithScreenRatio(10)
            anchors.rightMargin: Utils.getSizeWithScreenRatio(10)
            anchors.bottomMargin: Utils.getSizeWithScreenRatio(10)
			width: implicitWidth
			maximumLineCount: 1
			property string _text: mainItem.displayName != ''
				? mainItem.displayName
				: mainItem.account && mainItem.identityAddress
					? mainItem.identityAddress.value
					: ""
			text: SettingsCpp.hideSipAddresses ? UtilsCpp.getUsername(_text) : _text
			color: DefaultStyle.grey_0
			font {
                pixelSize: Utils.getSizeWithScreenRatio(14)
                weight: Utils.getSizeWithScreenRatio(500)
			}
		}
	}
	MultiEffect {
		id: shadow
		source: background
		anchors.fill: background
		shadowEnabled: true
		shadowColor: DefaultStyle.grey_1000
		shadowBlur: 1
		shadowScale: 1.05
		shadowOpacity: 0.5
	}
	RowLayout{
		anchors.right: parent.right
		anchors.top: parent.top
        anchors.rightMargin: Utils.getSizeWithScreenRatio(8)
        anchors.topMargin: Utils.getSizeWithScreenRatio(8)
		
        height: Utils.getSizeWithScreenRatio(18)
		spacing: 0
		Rectangle {
			id: muteIcon
            Layout.preferredWidth: Math.min(Math.round(mainItem.width / 16), Utils.getSizeWithScreenRatio(20))
            Layout.preferredHeight: Math.min(Math.round(mainItem.width / 16), Utils.getSizeWithScreenRatio(20))
			visible: mainItem.mutedStatus
			color: DefaultStyle.grey_0
			radius: width /2
			EffectImage {
				anchors.centerIn: parent
                imageWidth: Math.min(Math.round(mainItem.width / 16),Utils.getSizeWithScreenRatio(20))
                imageHeight: Math.min(Math.round(mainItem.width / 16),Utils.getSizeWithScreenRatio(20))
				imageSource: AppIcons.microphoneSlash
				colorizationColor: DefaultStyle.main2_500_main
			}
		}
	}
}
