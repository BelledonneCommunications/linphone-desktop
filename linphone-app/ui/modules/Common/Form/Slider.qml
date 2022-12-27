import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls

import Common.Styles 1.0

// =============================================================================

Controls.Slider {
	id: slider
	property alias backgroundImplicitHeight: backgroundItem.implicitHeight
	property alias backgroundImplicitWidth: backgroundItem.implicitWidth

	property alias handleImplicitHeight: handleItem.implicitHeight
	property alias handleImplicitWidth: handleItem.implicitWidth

	background: Rectangle {
		id: backgroundItem
		color: SliderStyle.background.colorModel.color

		x: slider.leftPadding
		y: slider.topPadding + slider.availableHeight / 2 - height / 2

		implicitHeight: SliderStyle.background.height
		implicitWidth: SliderStyle.background.width

		height: implicitHeight
		width: slider.availableWidth

		radius: SliderStyle.background.radius

		Rectangle {
			color: SliderStyle.background.content.colorModel.color

			height: parent.height
			width: slider.visualPosition * parent.width

			radius: SliderStyle.background.content.radius
		}
	}

	handle: Rectangle {
		id: handleItem
		border.color: slider.pressed
					  ? SliderStyle.handle.border.color.pressed.color
					  : SliderStyle.handle.border.color.normal.color

		color: slider.pressed
			   ? SliderStyle.handle.color.pressed.color
			   : SliderStyle.handle.color.normal.color

		x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
		y: slider.topPadding + slider.availableHeight / 2 - height / 2

		implicitWidth: SliderStyle.handle.width
		implicitHeight: SliderStyle.handle.height

		radius: SliderStyle.handle.radius
	}
}
