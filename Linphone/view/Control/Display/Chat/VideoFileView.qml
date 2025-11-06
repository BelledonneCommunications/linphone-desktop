import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts
import QtMultimedia

import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

// =============================================================================

Rectangle {
	id: mainItem
	color: DefaultStyle.grey_1000
	property ChatMessageContentGui contentGui
	property string filePath: contentGui && contentGui.core.filePath
	property var fillMode: playbackState === MediaPlayer.PlayingState ? VideoOutput.PreserveAspectFit : VideoOutput.PreserveAspectCrop
	property alias videoOutput: output
	property string source: mediaPlayer.source

	MediaPlayer {
		id: mediaPlayer
		source: UtilsCpp.isVideo(mainItem.filePath) ? "file:///" + mainItem.filePath : ""
		position: 100
		videoOutput: output
	}
	VideoOutput {
		id: output
		fillMode: mainItem.fillMode
		endOfStreamPolicy: VideoOutput.KeepLastFrame
		width: mainItem.width
		height: mainItem.height
		Component.onCompleted: {
			// We need to start the video so the content rect of the
			// video output is updated
			mediaPlayer.play()
			mediaPlayer.pause()
		}
		Text {
			z: parent.z + 1
			property int timeDisplayed: mediaPlayer.playbackState === MediaPlayer.PlayingState ? mediaPlayer.position : mediaPlayer.duration
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.bottomMargin: Utils.getSizeWithScreenRatio(6)
			anchors.leftMargin: Utils.getSizeWithScreenRatio(6)
			text: UtilsCpp.formatDuration(timeDisplayed)
			color: DefaultStyle.grey_0
			font {
				pixelSize: Typography.d1.pixelSize
				weight: Typography.d1.weight
			}
		}
	}
	MouseArea {
		propagateComposedEvents: false
		enabled: mainItem.visible
		anchors.fill: parent
		hoverEnabled: true
		acceptedButtons: Qt.LeftButton
		cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
		// Changing cursor in MouseArea seems not to work with the Loader
		// Use override cursor for this case
		onContainsMouseChanged: {
			if (containsMouse) UtilsCpp.setGlobalCursor(Qt.PointingHandCursor)
			else UtilsCpp.restoreGlobalCursor()
		}
		onPressed: (mouse) => {
			mouse.accepted = true
			mainItem.contentGui.core.lOpenFile()
		}
	}
	EffectImage {
		anchors.centerIn: parent
		visible: mediaPlayer.playbackState !== MediaPlayer.PlayingState
		width: Utils.getSizeWithScreenRatio(24)
		height: Utils.getSizeWithScreenRatio(24)
		imageSource: AppIcons.playFill
		colorizationColor: DefaultStyle.main2_0
	}
}