import Common.Styles 1.0

// =============================================================================

AbstractTextButton {
	property var textButtonStyle : TextButtonCStyle

	colorDisabled: textButtonStyle.backgroundColor.disabled.color
	colorHovered: textButtonStyle.backgroundColor.hovered.color
	colorNormal: textButtonStyle.backgroundColor.normal.color
	colorPressed: textButtonStyle.backgroundColor.pressed.color
	
	textColorDisabled: textButtonStyle.textColor.disabled.color
	textColorHovered: textButtonStyle.textColor.hovered.color
	textColorNormal: textButtonStyle.textColor.normal.color
	textColorPressed: textButtonStyle.textColor.pressed.color
	
	borderColorDisabled: (textButtonStyle.borderColor?textButtonStyle.borderColor.disabled.color:colorDisabled)
	borderColorHovered: (textButtonStyle.borderColor?textButtonStyle.borderColor.hovered.color:colorHovered)
	borderColorNormal: (textButtonStyle.borderColor?textButtonStyle.borderColor.normal.color:colorNormal)
	borderColorPressed: (textButtonStyle.borderColor?textButtonStyle.borderColor.pressed.color:colorPressed)
}
