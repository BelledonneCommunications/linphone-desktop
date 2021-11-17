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
	
	anchors.topMargin: 5
	anchors.bottomMargin: 5
			
	background: Rectangle {
		color: MediaProgressBarStyle.backgroundColor
		radius: 5
	}
	
	
	contentItem: 
		Rectangle{
			anchors.fill: parent
			radius: 5
			RowLayout{
				anchors.fill: parent
				
				ActionButton{
					id: progression
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.topMargin: 5
					Layout.bottomMargin: 5
					Layout.leftMargin: 10
					backgroundRadius: 5
					fillMode: Image.TileHorizontally
					verticalAlignment: Image.AlignLeft
					isCustom: true
					colorSet: MediaProgressBarStyle.progressionWave
					percentageDisplayed: 0
					onClicked: progressBar.seekRequested(x * progressBar.progressDuration/width)
				}
				Text{
					Layout.fillHeight: true
					Layout.preferredWidth: 100
					Layout.rightMargin: 10
					horizontalAlignment: Qt.AlignRight
					verticalAlignment: Qt.AlignVCenter
					text: progressBar.progressPosition >= 0 ? Utils.formatElapsedTime( progressBar.progressPosition / 1000 ) : '-'					
					property font customFont : SettingsModel.textMessageFont
					font.family: customFont.family
					font.pointSize: Units.dp * (customFont.pointSize + 2)
				}
			}
	}
}
