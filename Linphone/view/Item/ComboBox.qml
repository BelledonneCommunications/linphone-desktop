import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.0
import Linphone
  
ColumnLayout {
	id: cellLayout
	property string label: ""
	property int backgroundWidth: 200
	property variant modelList: []

	Layout.bottomMargin: 8
	Text {
		verticalAlignment: Text.AlignVCenter
		text: cellLayout.label
		color: DefaultStyle.formItemLabelColor
		font {
			pointSize: DefaultStyle.formItemLabelSize
			bold: true
		}
	}

	ComboBox {
		id: combobox
		model: cellLayout.modelList
		background: Loader {
			sourceComponent: backgroundRectangle
		}
		contentItem: Text {
			leftPadding: 10
			text: combobox.displayText
			font.family: DefaultStyle.defaultFont
			font.pointSize: DefaultStyle.formItemLabelSize
			color: DefaultStyle.formItemLabelColor
			verticalAlignment: Text.AlignVCenter
			elide: Text.ElideRight
		}

		indicator: Image {
			x: combobox.width - width - combobox.rightPadding
			y: combobox.topPadding + (combobox.availableHeight - height) / 2
			source: AppIcons.downArrow
			// width: 12
			// height: 8
		}

		popup: Popup {
			y: combobox.height - 1
			width: combobox.width
			implicitHeight: contentItem.implicitHeight
			padding: 1

			contentItem: ListView {
				clip: true
				implicitHeight: contentHeight
				model: combobox.popup.visible ? combobox.delegateModel : null
				currentIndex: combobox.highlightedIndex

				ScrollIndicator.vertical: ScrollIndicator { }
			}

			background: Loader {
				sourceComponent: backgroundRectangle
			}
		}
		Component {
			id: backgroundRectangle
			Rectangle {
				implicitWidth: cellLayout.backgroundWidth
				implicitHeight: 30
				radius: 20
				color: DefaultStyle.formItemBackgroundColor
				opacity: 0.7
			}
		}
	}
}