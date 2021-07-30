import Common.Styles 1.0

// =============================================================================

AbstractTextButton {
	property var textButtonStyle : TextButtonBStyle

	colorDisabled: textButtonStyle.backgroundColor.disabled
	colorHovered: textButtonStyle.backgroundColor.hovered
	colorNormal: textButtonStyle.backgroundColor.normal
	colorPressed: textButtonStyle.backgroundColor.pressed
	
	textColorDisabled: textButtonStyle.textColor.disabled
	textColorHovered: textButtonStyle.textColor.hovered
	textColorNormal: textButtonStyle.textColor.normal
	textColorPressed: textButtonStyle.textColor.pressed
	
	borderColorDisabled: textButtonStyle.borderColor.disabled
	borderColorHovered: textButtonStyle.borderColor.hovered
	borderColorNormal: textButtonStyle.borderColor.normal
	borderColorPressed: textButtonStyle.borderColor.pressed
}
