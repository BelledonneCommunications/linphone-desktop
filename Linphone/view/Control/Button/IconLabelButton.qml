import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

Button {
	id: mainItem
    icon.width: Math.round(24 * DefaultStyle.dp)
    icon.height: Math.round(24 * DefaultStyle.dp)
    textSize: Typography.p1.pixelSize
    textWeight: Typography.p1.weight
    radius: Math.round(5 * DefaultStyle.dp)
	shadowEnabled: mainItem.activeFocus || hovered
	style: ButtonStyle.hoveredBackground
	
	contentItem: RowLayout {
        spacing: Math.round(5 * DefaultStyle.dp)
		EffectImage {
			imageSource: mainItem.icon.source
			imageWidth: mainItem.icon.width
			imageHeight: mainItem.icon.height
			colorizationColor: mainItem.pressed 
				? mainItem.pressedImageColor 
				: mainItem.hovered
					? mainItem.hoveredImageColor
					: mainItem.contentImageColor
			Layout.preferredWidth: mainItem.icon.width
			Layout.preferredHeight: mainItem.icon.height
		}
		Text {
			id: textItem
			horizontalAlignment: Text.AlignLeft
			verticalAlignment: Text.AlignVCenter
			Layout.preferredWidth: textMetrics.advanceWidth
			wrapMode: Text.WrapAnywhere
			text: mainItem.text
			maximumLineCount: 1
			color: pressed
				? mainItem.pressedTextColor
				: mainItem.hovered
					? mainItem.hoveredTextColor
					: mainItem.textColor
			font {
				pixelSize: mainItem.textSize
				weight: mainItem.textWeight
				family: DefaultStyle.defaultFont
				capitalization: mainItem.capitalization
				underline: mainItem.underline
				bold: (mainItem.style === ButtonStyle.noBackground || mainItem.style === ButtonStyle.noBackgroundRed) && (mainItem.hovered || mainItem.pressed)
			}
		}
		TextMetrics {
			id: textMetrics
			text: mainItem.text
			font {
				pixelSize: mainItem.textSize
				weight: mainItem.textWeight * 2
				family: DefaultStyle.defaultFont
				capitalization: mainItem.capitalization
				underline: mainItem.underline
				bold: true
			}
		}
        Item {Layout.fillWidth: true}
	}
}
