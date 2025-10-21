import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import Linphone
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ProgressBar{
	id: mainItem
	property string text: value + '%'
	implicitHeight: 35
	implicitWidth: 35
	to: 100
	value: 0
	background: Item {}
	Timer{
		id: animationTest
		repeat: true
		onTriggered: value = (value + 1) % to
		interval: 5
	}
	contentItem: Item{
		Shape {
			id: shape
			anchors.fill: parent
			anchors.margins: Utils.getSizeWithScreenRatio(2)
			
			property real progressionRadius : Math.round(Math.min(shape.width / 2, shape.height / 2) - Utils.getSizeWithScreenRatio(3) / 2)
			
			layer.enabled: true
			layer.samples: 8
			layer.smooth: true
			vendorExtensionsEnabled: false
			
			ShapePath {
				id: pathDial
				strokeColor: DefaultStyle.main1_100
				fillColor: 'transparent'
				strokeWidth: Utils.getSizeWithScreenRatio(3)
				capStyle: Qt.RoundCap
				
				PathAngleArc {
					radiusX: shape.progressionRadius
					radiusY: shape.progressionRadius
					centerX: Math.round(shape.width / 2)
					centerY: Math.round(shape.height / 2)
					startAngle: -90	// top start
					sweepAngle: 360
				}
			}
			
			ShapePath {
				id: pathProgress
				strokeColor: DefaultStyle.main1_500_main
				fillColor: 'transparent'
				strokeWidth: Utils.getSizeWithScreenRatio(3)
				capStyle: Qt.RoundCap
				
				PathAngleArc {
					radiusX: shape.progressionRadius
					radiusY: shape.progressionRadius
					centerX: Math.round(shape.width / 2)
					centerY: Math.round(shape.height / 2)
					startAngle: -90 // top start
					sweepAngle: (360/ mainItem.to * mainItem.value)
				}
			}
		}
		Text{
			anchors.centerIn: parent
			text: mainItem.text
			color: DefaultStyle.main1_500_main
			font.pixelSize: Typography.p4.pixelSize
			font.weight: Typography.p2.weight
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
		}
	}
}
