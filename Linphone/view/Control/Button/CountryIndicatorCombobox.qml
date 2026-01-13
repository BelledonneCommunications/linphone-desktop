import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import QtQuick.Effects
import Linphone
import CustomControls 1.0
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.ComboBox {
	id: mainItem
	property string defaultCallingCode: ""
	property bool enableBackgroundColors: false
	onKeyboardFocusChanged: console.log("keyboard focus combobox", keyboardFocus)
	property bool keyboardFocus: FocusHelper.keyboardFocus
	property color keyboardFocusedBorderColor: DefaultStyle.main2_900
	property real borderWidth: Utils.getSizeWithScreenRatio(1)
	property real keyboardFocusedBorderWidth: Utils.getSizeWithScreenRatio(3)
	property string text: combobox.model.getAt(combobox.currentIndex) ? combobox.model.getAt(combobox.currentIndex).countryCallingCode : ""
	currentIndex: phoneNumberModel.count > 0 ? Math.max(0, phoneNumberModel.findIndexByCountryCallingCode(defaultCallingCode)) : -1
	Accessible.name: mainItem.Accessible.name	
	model: PhoneNumberProxy {
		id: phoneNumberModel
	}
	background: Rectangle {
		anchors.fill: parent
		radius: Utils.getSizeWithScreenRatio(63)
		color: mainItem.enableBackgroundColor ? DefaultStyle.grey_100 : "transparent"
		border.color: mainItem.keyboardFocus 
			? mainItem.keyboardFocusedBorderColor
			: mainItem.enableBackgroundColors 
				? (mainItem.errorMessage.length > 0 
					? DefaultStyle.danger_500_main 
					: mainItem.activeFocus || textField.activeFocus
						? DefaultStyle.main1_500_main
						: DefaultStyle.grey_200)
				: "transparent"
		border.width: mainItem.keyboardFocus ? mainItem.keyboardFocusedBorderWidth : mainItem.borderWidth
	}
	contentItem: RowLayout {
		readonly property var currentItem: combobox.model.getAt(combobox.currentIndex)
		spacing: 0
		Text {
			id: selectedItemFlag
			visible: text.length > 0
			font.pixelSize: Utils.getSizeWithScreenRatio(21)
			text: parent.currentItem ? parent.currentItem.flag : ""
			font.family: DefaultStyle.flagFont
		}
		// Rectangle{
		// 	id: mask
		// 	visible: false
		// 	layer.enabled: true
		// 	anchors.centerIn: selectedItemFlag
		// 	radius: Utils.getSizeWithScreenRatio(600)
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
		anchors.rightMargin: Utils.getSizeWithScreenRatio(15)
		anchors.verticalCenter: parent.verticalCenter
		imageSource: AppIcons.downArrow
		width: Utils.getSizeWithScreenRatio(15)
		height: Utils.getSizeWithScreenRatio(15)
		fillMode: Image.PreserveAspectFit
		colorizationColor: mainItem.indicatorColor
	}
	
	popup: Control.Popup {
		id: listPopup
		y: combobox.height - 1
		width: Utils.getSizeWithScreenRatio(311)
		height: Utils.getSizeWithScreenRatio(250)

		contentItem: ListView {
			id: listView
			clip: true
			anchors.fill: parent
			model: PhoneNumberProxy{}
			currentIndex: combobox.highlightedIndex >= 0 ? combobox.highlightedIndex : 0
			keyNavigationEnabled: true
			keyNavigationWraps: true
			maximumFlickVelocity: 1500
			spacing: Utils.getSizeWithScreenRatio(10)
			highlight: Rectangle {
				width: listView.width
				height: listView.height
				color: DefaultStyle.main2_300
				// radius: Utils.getSizeWithScreenRatio(15)
			}

			delegate: Item {
				width: listView.width
				height: contentLayout.implicitHeight
				RowLayout {
					id: contentLayout
					anchors.fill: parent
					anchors.leftMargin: Utils.getSizeWithScreenRatio(20)
					spacing: Utils.getSizeWithScreenRatio(5)
					
					Text {
						id: delegateImg
						visible: text.length > 0
						text: $modelData.flag
						font {
							pixelSize: Utils.getSizeWithScreenRatio(28)
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
						width: Utils.getSizeWithScreenRatio(1)
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
						radius: Utils.getSizeWithScreenRatio(15)
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
				radius: Utils.getSizeWithScreenRatio(15)
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
