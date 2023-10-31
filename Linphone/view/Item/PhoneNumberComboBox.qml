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

	Text {
		visible: label.length > 0
		textItem.verticalAlignment: Text.AlignVCenter
		textItem.text: mainItem.label
		textItem.color: DefaultStyle.formItemLabelColor
		textItem.font {
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
			color: DefaultStyle.formItemBackgroundColor
		}
		contentItem: Item {
			anchors.fill: parent
			readonly property var currentItem: combobox.model.getAt(combobox.currentIndex)
			anchors.leftMargin: 15
			Text {
				visible: text.length > 0
				id: selectedItemFlag
				textItem.text: parent.currentItem ? parent.currentItem.flag : ""
				textItem.font.family: DefaultStyle.emojiFont
				anchors.rightMargin: 5
				anchors.verticalCenter: parent.verticalCenter
			}
			Text {
				textItem.leftPadding: 5
				textItem.text: parent.currentItem ? "+" + parent.currentItem.countryCallingCode : ""
				textItem.color: DefaultStyle.formItemLabelColor
				anchors.right: parent.right
				anchors.left: selectedItemFlag.right
				anchors.verticalCenter: parent.verticalCenter 
				textItem.elide: Text.ElideRight
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
						textItem.text: $modelData.flag
						textItem.font.family: DefaultStyle.emojiFont
						anchors.left: parent.left
						anchors.verticalCenter: parent.verticalCenter 
						anchors.leftMargin: 15
						anchors.rightMargin: 5
					}

					Text {
						textItem.text: "+" + $modelData.countryCallingCode
						textItem.elide: Text.ElideRight
						textItem.leftPadding: 5
						anchors.left: delegateImg.right
						anchors.right: parent.right
						anchors.verticalCenter: parent.verticalCenter 
						textItem.color: DefaultStyle.formItemLabelColor
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