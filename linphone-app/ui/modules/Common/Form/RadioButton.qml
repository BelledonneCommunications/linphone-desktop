import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.12 as Control

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0


// =============================================================================

Control.RadioButton{
	id: radio
	font.weight: checked ? RadioButtonStyle.selectedWeight : RadioButtonStyle.weight
	font.pointSize: RadioButtonStyle.pointSize
	spacing: 10
	FontMetrics{id: fontMetrics}
	indicator: Rectangle {
		height: fontMetrics.height - 5 
		width: height
		//onHeightChanged: height = fontMetrics.height - 5
		//onWidthChanged: width = fontMetrics.height - 5
		x: parent.leftPadding
		y: parent.height / 2 - height / 2
		radius: width/2
		border.color: RadioButtonStyle.color
		property bool checked: parent.checked
		Rectangle {
			width: parent.width - 8
			height: width
			x: 4
			y: 4
			radius: width/2
			color: RadioButtonStyle.color
			visible: parent.checked
		}
	}
	contentItem: Text{
		text: parent.text
		font: parent.font
		width: parent.width - (parent.indicator.width + parent.spacing)
		height: implicitHeight
		y:0
		// Override unwanted auto changes
		onYChanged: y = 0
		onHeightChanged: height=implicitHeight
		//---------------------------------------
		color: RadioButtonStyle.color
		verticalAlignment: Text.AlignVCenter
		leftPadding: parent.indicator.width + parent.spacing
		wrapMode: Text.WordWrap
		elide: Text.ElideRight
	}
}