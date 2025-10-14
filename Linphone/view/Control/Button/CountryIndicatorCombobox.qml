import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import QtQuick.Effects
import Linphone
  
Control.ComboBox {
	id: mainItem
	property string defaultCallingCode: ""
	property bool enableBackgroundColors: false
	property string text: combobox.model.getAt(combobox.currentIndex) ? combobox.model.getAt(combobox.currentIndex).countryCallingCode : ""
	currentIndex: phoneNumberModel.count > 0 ? Math.max(0, phoneNumberModel.findIndexByCountryCallingCode(defaultCallingCode)) : -1
	Accessible.name: mainItem.Accessible.name	
	model: PhoneNumberProxy {
		id: phoneNumberModel
	}
	background: Rectangle {
		anchors.fill: parent
		radius: Math.round(63 * DefaultStyle.dp)
		color: mainItem.enableBackgroundColor ? DefaultStyle.grey_100 : "transparent"
		border.color: mainItem.enableBackgroundColors 
					? (mainItem.errorMessage.length > 0 
						? DefaultStyle.danger_500_main 
						: textField.activeFocus
							? DefaultStyle.main1_500_main
							: DefaultStyle.grey_200)
					: "transparent"
	}
	contentItem: RowLayout {
		readonly property var currentItem: combobox.model.getAt(combobox.currentIndex)
		spacing: 0// Math.round(5 * DefaultStyle.dp)
		Text {
			id: selectedItemFlag
			visible: text.length > 0
			font.pixelSize: Math.round(21 * DefaultStyle.dp)
			text: parent.currentItem ? parent.currentItem.flag : ""
			font.family: DefaultStyle.flagFont
		}
		// Rectangle{
		// 	id: mask
		// 	visible: false
		// 	layer.enabled: true
		// 	anchors.centerIn: selectedItemFlag
		// 	radius: Math.round(600 * DefaultStyle.dp)
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
			id: countryCallingcode
			text: parent.currentItem ? "+" + parent.currentItem.countryCallingCode : ""
			color: DefaultStyle.main2_600
			elide: Text.ElideRight
			font: Typography.p1
		}
	}

	indicator: EffectImage {
		id: indicImage
		z: 1
		anchors.right: parent.right
		anchors.rightMargin: Math.round(15 * DefaultStyle.dp)
		anchors.verticalCenter: parent.verticalCenter
		imageSource: AppIcons.downArrow
		width: Math.round(15 * DefaultStyle.dp)
		height: Math.round(15 * DefaultStyle.dp)
		fillMode: Image.PreserveAspectFit
		colorizationColor: mainItem.indicatorColor
	}
	
	popup: Control.Popup {
		id: listPopup
		y: combobox.height - 1
		width: Math.round(311 * DefaultStyle.dp)
		height: Math.round(250 * DefaultStyle.dp)

		contentItem: ListView {
			id: listView
			clip: true
			anchors.fill: parent
			model: PhoneNumberProxy{}
			currentIndex: combobox.highlightedIndex >= 0 ? combobox.highlightedIndex : 0
			keyNavigationEnabled: true
			keyNavigationWraps: true
			maximumFlickVelocity: 1500
			spacing: Math.round(10 * DefaultStyle.dp)
			highlight: Rectangle {
				anchors.left: parent.left
				anchors.right: parent.right
				width: listView.width
				height: listView.height
				color: DefaultStyle.main2_300
				// radius: Math.round(15 * DefaultStyle.dp)
			}

			delegate: Item {
				width: listView.width
				height: contentLayout.implicitHeight
				RowLayout {
					id: contentLayout
					anchors.fill: parent
					anchors.leftMargin: Math.round(20 * DefaultStyle.dp)
					spacing: Math.round(5 * DefaultStyle.dp)
					
					Text {
						id: delegateImg
						visible: text.length > 0
						text: $modelData.flag
						font {
							pixelSize: Math.round(28 * DefaultStyle.dp)
							family: DefaultStyle.flagFont
						}
					}

					Text {
						id: countryText
						text: $modelData.country
						elide: Text.ElideRight
						color: DefaultStyle.main2_500_main
						font {
							pixelSize: Typography.p1.pixelSize
							weight: Typography.p1.weight
						}
					}

					Rectangle {
						id: separator
						width: Math.max(Math.round(1 * DefaultStyle.dp), 1)
						height: combobox.height / 2
						color: DefaultStyle.main2_500_main
					}

					Text {
						text: "+" + $modelData.countryCallingCode
						elide: Text.ElideRight
						color: DefaultStyle.main2_500_main
						font {
							pixelSize: Typography.p1.pixelSize
							weight: Typography.p1.weight
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
						radius: Math.round(15 * DefaultStyle.dp)
						color: DefaultStyle.main2_500_main
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
				radius: Math.round(15 * DefaultStyle.dp)
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
