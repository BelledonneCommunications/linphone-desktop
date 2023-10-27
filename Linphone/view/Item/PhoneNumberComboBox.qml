import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts 1.0
import Linphone
  
ColumnLayout {
	id: cellLayout
	property string label: ""
	property int backgroundWidth: 100
	readonly property string currentText: combobox.model.getAt(combobox.currentIndex) ? combobox.model.getAt(combobox.currentIndex).countryCallingCode : ""
	property alias defaultCallingCode:  phoneNumberModel.defaultCountryCallingCode

	Text {
		visible: label.length > 0
		verticalAlignment: Text.AlignVCenter
		text: cellLayout.label
		color: DefaultStyle.formItemLabelColor
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
				var defaultIndex = findIndexByCountryCallingCode(defaultCallingCode)
				combobox.currentIndex = defaultIndex < 0 ? 0 : defaultIndex
			}
		}
		background: Loader {
			sourceComponent: backgroundRectangle
		}
		contentItem: Item {
			anchors.fill: parent
			anchors.leftMargin: 5
			Text {
				id: chosenItemFlag
				text: combobox.model.getAt(combobox.currentIndex) ? combobox.model.getAt(combobox.currentIndex).flag : ""
				font.family: 'Noto Color Emoji'
				anchors.leftMargin: 5
				anchors.verticalCenter: parent.verticalCenter
			}
			Text {
				id: chosenItemCountry
				leftPadding: 5
				text: combobox.model.getAt(combobox.currentIndex) ? "+" + combobox.model.getAt(combobox.currentIndex).countryCallingCode : ""
				font.family: DefaultStyle.defaultFont
				font.pointSize: DefaultStyle.formItemLabelSize
				color: DefaultStyle.formItemLabelColor
				anchors.right: parent.right
				anchors.left: chosenItemFlag.right
				anchors.verticalCenter: parent.verticalCenter 
				anchors.leftMargin: 5
				elide: Text.ElideRight
			}
			Item {
				Layout.fillWidth: true
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
				highlight: highlight

				delegate: Item {
					width:combobox.width;
					height: combobox.height;
					anchors.leftMargin: 5
					Text {
						id: delegateImg;
						text: $modelData.flag
						font.family: 'Noto Color Emoji'
						anchors.leftMargin: 5
					}

					Text {
						text: "+" + $modelData.countryCallingCode
						anchors.top: parent.top
						anchors.left: delegateImg.right
						anchors.leftMargin: 5
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

			Component {
				id: highlight
				Rectangle {
					width: listView.width
					height: listView.height
					color: DefaultStyle.comboBoxHighlightColor
					radius: 15
					y: listView.currentItem? listView.currentItem.y : 0
				}
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
				radius: 15
				color: DefaultStyle.formItemBackgroundColor
			}
		}
	}
}