import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Shapes 1.12

import Units 1.0

import Common.Styles 1.0


ProgressBar{
	id: mainItem
	property string text: value + '%'
	implicitHeight: 35
	implicitWidth: 35
	to: 100
	value: 0
	background: Rectangle {
		color: RoundProgressBarStyle.backgroundColor.color
		radius: width
	}
	Timer{
		id: animationTest
		repeat: true
		onTriggered: value = (value + 1) % to
		interval: 5
	}
	contentItem:
		Item{
		Shape {
			id: shape
			anchors.fill: parent
			anchors.margins: RoundProgressBarStyle.borderWidth
			
			property real progressionRadius : Math.min(shape.width / 2, shape.height / 2) - RoundProgressBarStyle.progressionWidth / 2
			
			layer.enabled: true
			layer.samples: 8
			layer.smooth: true
			vendorExtensionsEnabled: false
			
			ShapePath {
				id: pathDial
				strokeColor: RoundProgressBarStyle.progressRemainColor.color
				fillColor: 'transparent'
				strokeWidth: RoundProgressBarStyle.progressionWidth
				capStyle: Qt.RoundCap
				
				PathAngleArc {
					radiusX: shape.progressionRadius
					radiusY: shape.progressionRadius
					centerX: shape.width / 2
					centerY: shape.height / 2
					startAngle: -90	// top start
					sweepAngle: 360
				}
			}
			
			ShapePath {
				id: pathProgress
				strokeColor: RoundProgressBarStyle.progressColor.color
				fillColor: 'transparent'
				strokeWidth: RoundProgressBarStyle.progressionWidth
				capStyle: Qt.RoundCap
				
				PathAngleArc {
					radiusX: shape.progressionRadius
					radiusY: shape.progressionRadius
					centerX: shape.width / 2
					centerY: shape.height / 2
					startAngle: -90 // top start
					sweepAngle: (360/ mainItem.to * mainItem.value)
				}
			}
		}
		Text{
			anchors.centerIn: parent
			text: mainItem.text
			color: RoundProgressBarStyle.progressRemainColor.color
			font.pointSize: RoundProgressBarStyle.pointSize
			font.bold: true
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
		}
	}
}
