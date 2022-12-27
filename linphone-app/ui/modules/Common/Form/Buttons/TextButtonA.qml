import Common.Styles 1.0

// =============================================================================

AbstractTextButton {
	property var textButtonStyle : TextButtonAStyle
	
	colorDisabled: textButtonStyle.backgroundColor.disabled.color
	colorHovered: textButtonStyle.backgroundColor.hovered.color
	colorNormal: textButtonStyle.backgroundColor.normal.color
	colorPressed: textButtonStyle.backgroundColor.pressed.color
	
	textColorDisabled: textButtonStyle.textColor.disabled.color
	textColorHovered: textButtonStyle.textColor.hovered.color
	textColorNormal: textButtonStyle.textColor.normal.color
	textColorPressed: textButtonStyle.textColor.pressed.color
	
	borderColorDisabled: textButtonStyle.borderColor.disabled.color
	borderColorHovered: textButtonStyle.borderColor.hovered.color
	borderColorNormal: textButtonStyle.borderColor.normal.color
	borderColorPressed: textButtonStyle.borderColor.pressed.color
}
