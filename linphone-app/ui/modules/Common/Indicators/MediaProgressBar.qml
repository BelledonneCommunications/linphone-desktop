import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import Common 1.0
import Linphone 1.0
import Utils 1.0
import Units 1.0
import Common.Styles 1.0

// =============================================================================

ProgressBar {
	id: progressBar
	
	property bool stopAtEnd: true
	property bool resetAtEnd: false
	property int progressDuration			// Max duration
	property int progressPosition	// Position of progress bar in [0 ; progressDuration]
	property alias colorSet: progression.colorSet
	property alias backgroundColor: backgroundArea.color
	property alias durationTextColor: durationText.color
	property int waveLeftMargin: 0
	
	function start(){
		progressBar.value = 0
		animationTest.start()
	}
	function resume(){
		if(progressBar.value >= 100)
			progressBar.value = 0
		animationTest.start()
	}
	function stop(){
		animationTest.stop()
	}
	signal endReached()
	signal refreshPositionRequested()
	signal seekRequested(int ms)
	Timer{
		id: animationTest
		repeat: true
		onTriggered: progressBar.refreshPositionRequested()
		interval: 5
	}
	to: 101
	value: 0
	onValueChanged:{
					if(value > 100){
						if( progressBar.stopAtEnd)
							stop()
						if(progressBar.resetAtEnd) {
							progressBar.value = 0
							progressPosition = 0
						}else{
							progressBar.value = 100// Stay at 100
							progressPosition = progressDuration
						}
						progressBar.endReached()
					}else
						progression.percentageDisplayed = value
		}
	
	anchors.topMargin: 2
	anchors.bottomMargin: 2
			
	background: Rectangle {
		id: backgroundArea
		color: MediaProgressBarStyle.backgroundColor
		radius: 5
		clip: false
	}
	
	
	contentItem: 
		Rectangle{
			anchors.fill: parent
			radius: 5
			color: 'transparent'
			clip: false
			RowLayout{
				anchors.fill: parent
				spacing: 0
				ActionButton{
					id: progression
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.leftMargin: progressBar.waveLeftMargin
					backgroundRadius: 5
					fillMode: Image.TileHorizontally
					verticalAlignment: Image.AlignLeft
					horizontalAlignment: Image.AlignLeft
					isCustom: true
					colorSet: MediaProgressBarStyle.progressionWave
					percentageDisplayed: 0
					onClicked: progressBar.seekRequested(x * progressBar.progressDuration/width)
				}
				Text{
					id: durationText
					Layout.fillHeight: true
					Layout.preferredWidth: implicitWidth
					Layout.leftMargin: 15
					Layout.rightMargin: 6
					horizontalAlignment: Qt.AlignRight
					verticalAlignment: Qt.AlignVCenter
					text: progressBar.progressPosition > 0 ? Utils.formatElapsedTime( progressBar.progressPosition / 1000 ) 
										:( progressBar.progressPosition == 0 ? Utils.formatElapsedTime( progressBar.progressDuration / 1000) : '-')
					property font customFont : SettingsModel.textMessageFont
					font.family: customFont.family
					font.pointSize: Units.dp * (customFont.pointSize + 1)
				}
			}
	}
}
