import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts 1.0
import Linphone
  
ColumnLayout {
	id: mainItem
	property string label: ""
	property int backgroundWidth: 100
	readonly property string currentText: combobox.model.getAt(combobox.currentIndex) ? combobox.model.getAt(combobox.currentIndex).countryCallingCode : ""
	property string defaultCallingCode: ""
	property bool enableBackgroundColors: false

	Text {
		visible: mainItem.label.length > 0
		verticalAlignment: Text.AlignVCenter
		text: mainItem.label
		color: combobox.activeFocus ? DefaultStyle.formItemFocusBorderColor : DefaultStyle.formItemLabelColor
		font {
			pointSize: DefaultStyle.formItemLabelSize
			bold: true
		}
	}

	Control.ComboBox {
		id: combobox
		model: PhoneNumberProxy {
			id: phoneNumberModel
			onCountChanged: {
				combobox.currentIndex = Math.max(0, findIndexByCountryCallingCode(defaultCallingCode))
			}
		}
		background: Rectangle {
			implicitWidth: mainItem.backgroundWidth
			implicitHeight: 30
			radius: 15
			color: mainItem.enableBackgroundColor ? DefaultStyle.formItemBackgroundColor : "transparent"
			border.color: mainItem.enableBackgroundColors 
						? (mainItem.errorMessage.length > 0 
							? DefaultStyle.errorMessageColor 
							: textField.activeFocus
								? DefaultStyle.formItemFocusBorderColor
								: DefaultStyle.formItemBorderColor)
						: "transparent"
		}
		contentItem: Item {
			anchors.fill: parent
			readonly property var currentItem: combobox.model.getAt(combobox.currentIndex)
			anchors.leftMargin: 15
			Text {
				id: selectedItemFlag
				visible: text.length > 0
				text: parent.currentItem ? parent.currentItem.flag : ""
				font.family: DefaultStyle.emojiFont
				anchors.rightMargin: 5
				anchors.verticalCenter: parent.verticalCenter
			}
			Text {
				leftPadding: 5
				text: parent.currentItem ? "+" + parent.currentItem.countryCallingCode : ""
				color: DefaultStyle.formItemLabelColor
				anchors.right: parent.right
				anchors.left: selectedItemFlag.right
				anchors.verticalCenter: parent.verticalCenter 
				elide: Text.ElideRight
			}
		}
		
		indicator: Image {
			anchors.verticalCenter: parent.verticalCenter
			anchors.right: parent.right
			source: AppIcons.downArrow
		}

		popup: Control.Popup {
			id: listPopup
			y: combobox.height - 1
			width: combobox.width
			implicitHeight: contentItem.implicitHeight
			implicitWidth: contentItem.implicitWidth
			padding: 1

			contentItem: ListView {
				id: listView
				clip: true
				implicitHeight: contentHeight
				implicitWidth: contentWidth
				model: PhoneNumberProxy{}
				currentIndex: combobox.highlightedIndex >= 0 ? combobox.highlightedIndex : 0
				highlightFollowsCurrentItem: true
				highlight: Rectangle {
					width: listView.width
					height: listView.height
					color: DefaultStyle.comboBoxHighlightColor
					radius: 15
					y: listView.currentItem? listView.currentItem.y : 0
				}

				delegate: Item {
					width:combobox.width;
					height: combobox.height;

					Text {
						id: delegateImg;
						visible: text.length > 0
						text: $modelData.flag
						font.family: DefaultStyle.emojiFont
						anchors.left: parent.left
						anchors.verticalCenter: parent.verticalCenter 
						anchors.leftMargin: 15
						anchors.rightMargin: 5
					}

					Text {
						text: "+" + $modelData.countryCallingCode
						elide: Text.ElideRight
						leftPadding: 5
						anchors.left: delegateImg.right
						anchors.right: parent.right
						anchors.verticalCenter: parent.verticalCenter 
						color: DefaultStyle.formItemLabelColor
					}

					MouseArea {
						anchors.fill: parent
						hoverEnabled: true
						Rectangle {
							anchors.fill: parent
							opacity: 0.1
							radius: 15
							color: DefaultStyle.comboBoxHoverColor
							visible: parent.containsMouse
						}
						onPressed: {
							combobox.currentIndex = index
							listPopup.close()
						}
					}
				}
				Control.ScrollIndicator.vertical: Control.ScrollIndicator { }
			}

			onOpened: {
				listView.positionViewAtIndex(listView.currentIndex, ListView.Center)
			}

			background: Rectangle {
				implicitWidth: mainItem.backgroundWidth
				implicitHeight: 30
				radius: 15
				// color: DefaultStyle.formItemBackgroundColor
			}
		}
	}
}
