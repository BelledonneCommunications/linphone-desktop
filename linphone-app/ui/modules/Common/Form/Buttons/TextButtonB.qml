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
	
	borderColorDisabled: (textButtonStyle.borderColor?textButtonStyle.borderColor.disabled:colorDisabled)
	borderColorHovered: (textButtonStyle.borderColor?textButtonStyle.borderColor.hovered:colorHovered)
	borderColorNormal: (textButtonStyle.borderColor?textButtonStyle.borderColor.normal:colorNormal)
	borderColorPressed: (textButtonStyle.borderColor?textButtonStyle.borderColor.pressed:colorPressed)
}
