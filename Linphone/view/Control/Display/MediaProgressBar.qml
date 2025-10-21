import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

import Linphone
import UtilsCpp

import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

// =============================================================================

ProgressBar {
	id: mainItem
	
	property bool stopAtEnd: true
	property bool resetAtEnd: true
	property int progressDuration	// Max duration
	property int progressPosition	// Position of progress bar in [0 ; progressDuration]
	property bool blockValueAtEnd: true

	property bool recording: false
	padding: 0
	clip: true
	
	function start(){
		mainItem.value = 0
		animationTest.start()
	}
	function resume(){
		if (mainItem.value >= 100)
			mainItem.value = 0
		animationTest.start()
	}
	function stop(){
		animationTest.stop()
	}
	signal playStopButtonToggled()
	signal endReached()
	signal refreshPositionRequested()
	signal seekRequested(int ms)
	Timer {
		id: animationTest
		repeat: true
		onTriggered: mainItem.refreshPositionRequested()
		interval: 5
	}
	to: 101
	value: progressPosition * to / progressDuration
	onValueChanged:{
		if(value > 100) {
			if( mainItem.stopAtEnd)
				stop()
			if(mainItem.resetAtEnd) {
				mainItem.value = 0
				progressPosition = 0
			} else if(mainItem.blockValueAtEnd){
				mainItem.value = 100// Stay at 100
				progressPosition = progressDuration
			}
			mainItem.endReached()
		}
	}
	
	background: Item {
		anchors.fill: parent
		Rectangle {
			id: backgroundArea
			anchors.fill: parent
			gradient: Gradient {
				orientation: Gradient.Horizontal
				GradientStop { position: 0.0; color: "#FF9E79" }
				GradientStop { position: 1.0; color: "#FE5E00" }
			}
			radius: Utils.getSizeWithScreenRatio(70)
		}
		Rectangle {
			id: mask
			anchors.fill: parent
			visible: false
			radius: backgroundArea.radius
		}
		Item {
			anchors.fill: parent
			id: progressRectangle
			visible: false
			Rectangle {
				color: DefaultStyle.grey_0
				width: mainItem.barWidth
				height: backgroundArea.height
				opacity: 0.5
			}
		}
		OpacityMask {
			anchors.fill: progressRectangle
			source: progressRectangle
			maskSource: mask
		}

		MouseArea {
			id: progression
			anchors.fill: parent
			onClicked: (mouse) => {
				mainItem.seekRequested(mouse.x * mainItem.progressDuration/width)
			}
		}
	}
	
	
	contentItem: Item {
		id: contentRect

		RoundButton {
			z: parent.z + 1
			anchors.left: parent.left
			anchors.leftMargin: Utils.getSizeWithScreenRatio(9)
			anchors.verticalCenter: parent.verticalCenter
			icon.width: Utils.getSizeWithScreenRatio(14)
			icon.height: Utils.getSizeWithScreenRatio(14)
			icon.source: animationTest.running
				? mainItem.recording
					? AppIcons.stopFill
					: AppIcons.pauseFill
				: AppIcons.playFill
			onClicked: {
				mainItem.playStopButtonToggled()
			}
			style: ButtonStyle.player
		}
		Control.Control {
			anchors.right: parent.right
			anchors.rightMargin: Utils.getSizeWithScreenRatio(9)
			anchors.verticalCenter: parent.verticalCenter
			leftPadding: Utils.getSizeWithScreenRatio(18)
			rightPadding: Utils.getSizeWithScreenRatio(18)
			topPadding: Utils.getSizeWithScreenRatio(5)
			bottomPadding: Utils.getSizeWithScreenRatio(5)
			background: Rectangle {
				anchors.fill: parent
				color: DefaultStyle.grey_0
				radius: Utils.getSizeWithScreenRatio(50)
			}
			contentItem: RowLayout {
				spacing: mainItem.recording ? Utils.getSizeWithScreenRatio(5) : 0
				EffectImage {
					visible: mainItem.recording
					colorizationColor: DefaultStyle.danger_500_main
					imageSource: AppIcons.recordFill
					Layout.preferredWidth: Utils.getSizeWithScreenRatio(14)
					Layout.preferredHeight: Utils.getSizeWithScreenRatio(14)
				}
				Text {
					id: durationText
					text: mainItem.progressPosition > 0 ? UtilsCpp.formatElapsedTime(mainItem.progressPosition / 1000 ) : UtilsCpp.formatElapsedTime(mainItem.progressDuration/1000)
					font {
						pixelSize: Typography.p1.pixelSize
						weight: Typography.p1.weight
					}
				}
			}
		}
	}
}
