import QtQuick 2.7
import QtQuick.Controls 2.4
import QtQuick.Shapes 1.10

import Common.Styles 1.0

// =============================================================================
// Checkbox with clickable text.
// =============================================================================

CheckBox {
	id: checkBox
	
	contentItem: Text {
		color: checkBox.down
			   ? CheckBoxTextStyle.color.pressed.color
			   : (
					 checkBox.hovered
					 ? CheckBoxTextStyle.color.hovered.color
					 : CheckBoxTextStyle.color.normal.color
					 )
		
		elide: Text.ElideRight
		font: checkBox.font
		leftPadding: checkBox.indicator.width + checkBox.spacing
		text: checkBox.text
		
		width: parent.width
		wrapMode: Text.WordWrap
		
		verticalAlignment: Text.AlignVCenter
		onLinkActivated: Qt.openUrlExternally(link)
		MouseArea {
			id: mouseArea
			anchors.fill: parent
			cursorShape: parent.hoveredLink != '' ? Qt.PointingHandCursor : Qt.ArrowCursor
			acceptedButtons: Qt.NoButton
		}
	}
	
	font.pointSize: CheckBoxTextStyle.pointSize
	hoverEnabled: true
	
	indicator: Rectangle {
		border.color: checkBox.down
					  ? CheckBoxTextStyle.color.pressed.color
					  : (
							checkBox.hovered
							? CheckBoxTextStyle.color.hovered.color
							: (
								checkBox.checked
								? CheckBoxTextStyle.color.selected.color
								: CheckBoxTextStyle.color.normal.color
							  )
							)
		
		implicitHeight: CheckBoxTextStyle.size
		implicitWidth: CheckBoxTextStyle.size
		
		radius: CheckBoxTextStyle.radius
		
		x: checkBox.leftPadding
		y: parent.height / 2 - height / 2
		
		Rectangle {
			color: checkBox.down
				   ? CheckBoxTextStyle.color.pressed.color
				   : (checkBox.hovered
					  ? CheckBoxTextStyle.color.hovered.color
					  : (
							checkBox.checked
							? CheckBoxTextStyle.color.selected.color
							: CheckBoxTextStyle.color.normal.color
							)
					  )
			
			height: parent.height - y * 2
			width: parent.width - x * 2
			
			radius: CheckBoxTextStyle.radius
			visible: checkBox.checkState == Qt.Checked
			
			x: 4 // Fixed, no needed to use style file.
			y: 4 // Same thing.
		}
		Shape{
			id: partiallyShape
			anchors.fill: parent
			visible: checkBox.checkState == Qt.PartiallyChecked
			ShapePath{
				strokeColor: checkBox.down
							 ? CheckBoxTextStyle.color.pressed.color
							 : (checkBox.hovered
								? CheckBoxTextStyle.color.hovered.color
								: (
									checkBox.checked
									? CheckBoxTextStyle.color.selected.color
									: CheckBoxTextStyle.color.normal.color
								  )
								)
				strokeWidth: 2
				fillColor: 'transparent'
				joinStyle: ShapePath.MiterJoin
				startX: 6
				startY: 6
				PathLine{x: partiallyShape.width - 6; y: partiallyShape.height - 6}
			}
			ShapePath{
				strokeColor: checkBox.down
							 ? CheckBoxTextStyle.color.pressed.color
							 : (checkBox.hovered
								? CheckBoxTextStyle.color.hovered.color
								: CheckBoxTextStyle.color.normal.color
								)
				strokeWidth: 2
				fillColor: 'transparent'
				joinStyle: ShapePath.MiterJoin
				startX: partiallyShape.width - 6
				startY: 6
				PathLine{x: 6; y: partiallyShape.height - 6}
			}
		}
	}
}
