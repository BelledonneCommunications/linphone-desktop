import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import QtQuick.Effects
import Linphone
  
ColumnLayout {
	id: mainItem
	property string label: ""
	readonly property string currentText: combobox.model.getAt(combobox.currentIndex) ? "+" + combobox.model.getAt(combobox.currentIndex).countryCallingCode : ""
	property string defaultCallingCode: ""
	property bool enableBackgroundColors: false

	Text {
		visible: mainItem.label.length > 0
		verticalAlignment: Text.AlignVCenter
		text: mainItem.label
		color: combobox.activeFocus ? DefaultStyle.main1_500_main : DefaultStyle.main2_600
		font {
			pixelSize: 13 * DefaultStyle.dp
			weight: 700 * DefaultStyle.dp
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
			implicitWidth: mainItem.implicitWidth
			implicitHeight: mainItem.implicitHeight
			radius: 63 * DefaultStyle.dp
			color: mainItem.enableBackgroundColor ? DefaultStyle.grey_100 : "transparent"
			border.color: mainItem.enableBackgroundColors 
						? (mainItem.errorMessage.length > 0 
							? DefaultStyle.danger_500main 
							: textField.activeFocus
								? DefaultStyle.main1_500_main
								: DefaultStyle.grey_200)
						: "transparent"
		}
		contentItem: Item {
			anchors.fill: parent
			readonly property var currentItem: combobox.model.getAt(combobox.currentIndex)
			anchors.leftMargin: 15 * DefaultStyle.dp
			Text {
				id: selectedItemFlag
				visible: text.length > 0
				font.pixelSize: 21 * DefaultStyle.dp
				text: parent.currentItem ? parent.currentItem.flag : ""
				font.family: DefaultStyle.emojiFont
				anchors.rightMargin: 5 * DefaultStyle.dp
				anchors.verticalCenter: parent.verticalCenter
			}
			// Rectangle{
			// 	id: mask
			// 	visible: false
			// 	layer.enabled: true
			// 	anchors.centerIn: selectedItemFlag
			// 	radius: 600 * DefaultStyle.dp
			// 	width: selectedItemFlag.width/2
			// 	height: selectedItemFlag.height/2
			// }
			// MultiEffect {
			// 	visible: selectedItemFlag.text.length > 0
			// 	anchors.centerIn: selectedItemFlag
			// 	clip: true
			// 	source: selectedItemFlag
			// 	maskEnabled: true
			// 	width: selectedItemFlag.width/2
			// 	height: selectedItemFlag.height/2
			// 	maskSource: mask
			// }
			Text {
				leftPadding: 5 * DefaultStyle.dp
				text: parent.currentItem ? "+" + parent.currentItem.countryCallingCode : ""
				color: DefaultStyle.main2_600
				anchors.right: parent.right
				anchors.left: selectedItemFlag.right
				anchors.verticalCenter: parent.verticalCenter 
				elide: Text.ElideRight
				font {
					pixelSize: 14 * DefaultStyle.dp
					weight: 400 * DefaultStyle.dp
				}
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
			width: 311 * DefaultStyle.dp
			height: 250 * DefaultStyle.dp

			contentItem: ListView {
				id: listView
				clip: true
				anchors.fill: parent
				model: PhoneNumberProxy{}
				currentIndex: combobox.highlightedIndex >= 0 ? combobox.highlightedIndex : 0
				keyNavigationEnabled: true
				keyNavigationWraps: true
				maximumFlickVelocity: 1500
				spacing: 10 * DefaultStyle.dp
				highlight: Rectangle {
					anchors.left: parent.left
					anchors.right: parent.right
					width: listView.width
					height: listView.height
					color: DefaultStyle.main2_300
					// radius: 15 * DefaultStyle.dp
					y: listView.currentItem? listView.currentItem.y : 0
				}

				delegate: Item {
					width: listView.width
					height: combobox.height
					RowLayout {
						anchors.fill: parent
						anchors.leftMargin: 20 * DefaultStyle.dp
						Text {
							id: delegateImg
							visible: text.length > 0
							text: $modelData.flag
							font {
								pixelSize: 28 * DefaultStyle.dp
								family: DefaultStyle.emojiFont
							}
						}

						Text {
							id: countryText
							text: $modelData.country
							elide: Text.ElideRight
							color: DefaultStyle.main2_500main
							font {
								pixelSize: 14 * DefaultStyle.dp
								weight: 400 * DefaultStyle.dp
							}
						}

						Rectangle {
							id: separator
							width: 1 * DefaultStyle.dp
							height: combobox.height / 2
							color: DefaultStyle.main2_500main
						}

						Text {
							text: "+" + $modelData.countryCallingCode
							elide: Text.ElideRight
							color: DefaultStyle.main2_500main
							font {
								pixelSize: 14 * DefaultStyle.dp
								weight: 400 * DefaultStyle.dp
							}
						}
						Item {
							Layout.fillWidth: true
						}
					}
					MouseArea {
						anchors.fill: parent
						hoverEnabled: true
						Rectangle {
							anchors.fill: parent
							opacity: 0.1
							radius: 15 * DefaultStyle.dp
							color: DefaultStyle.main2_500main
							visible: parent.containsMouse
						}
						onClicked: {
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

			background: Item {
				anchors.fill: parent
				Rectangle {
					id: popupBg
					anchors.fill: parent
					radius: 15 * DefaultStyle.dp
					color: DefaultStyle.grey_100
				}
				MultiEffect {
					anchors.fill: popupBg
					source: popupBg
					shadowEnabled: true
					shadowColor: DefaultStyle.grey_1000
					shadowBlur: 0.1
					shadowOpacity: 0.1
				}
			}
		}
	}
}
