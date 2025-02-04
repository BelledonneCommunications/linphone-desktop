
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

Rectangle {
	id: mainItem
	width: container.width
	height: container.height
	property string titleText
	property var contentModel
	property var topbarOptionalComponent
	property var model
	color: DefaultStyle.grey_0
	property var container
	property int contentHeight: contentRepeater.count > 0 ? contentRepeater.itemAt(0).height * contentRepeater.count : 0
	property int minimumWidthForSwitchintToRowLayout: 981 * DefaultStyle.dp
	property var useVerticalLayout
	property bool saveButtonVisible: true
	signal save()
	signal undo()
	function setResponsivityFlags() {
		var newValue = width < minimumWidthForSwitchintToRowLayout * DefaultStyle.dp
		if (useVerticalLayout != newValue) {
			useVerticalLayout = newValue
		}
	}
	onWidthChanged: {
		setResponsivityFlags()
    }
	Component.onCompleted: {
			setResponsivityFlags()
	}
	ColumnLayout {
		spacing: 0
		anchors.fill: parent
		Control.Control {
			id: header
			Layout.fillWidth: true
			leftPadding: 45 * DefaultStyle.dp
			rightPadding: 45 * DefaultStyle.dp
			z: 1
			background: Rectangle {
				anchors.fill: parent
				color: DefaultStyle.grey_0
			}
			contentItem: ColumnLayout {
				RowLayout {
					Layout.fillWidth: true
					Layout.topMargin: 20 * DefaultStyle.dp
					spacing: 5 * DefaultStyle.dp
					Layout.bottomMargin: 10 * DefaultStyle.dp
					Button {
						id: backButton
						Layout.preferredHeight: 24 * DefaultStyle.dp
						Layout.preferredWidth: 24 * DefaultStyle.dp
						icon.source: AppIcons.leftArrow
						focus: true
						visible: mainItem.container.depth > 1
						Layout.rightMargin: 41 * DefaultStyle.dp
						style: ButtonStyle.noBackground
						onClicked: {
							mainItem.container.pop()
						}
					}
					Text {
						text: titleText
						color: DefaultStyle.main2_600
						font: Typography.h3
					}
					Item {
						Layout.fillWidth: true
					}
					Loader {
						Layout.alignment: Qt.AlignRight
						sourceComponent: mainItem.topbarOptionalComponent
						Layout.rightMargin: 34 * DefaultStyle.dp
					}
					MediumButton {
						id: saveButton
						style: ButtonStyle.main
						text: qsTr("Enregistrer")
						Layout.rightMargin: 6 * DefaultStyle.dp
						visible: mainItem.saveButtonVisible
						onClicked: {
							mainItem.save()
						}
					}
				}
				Rectangle {
					Layout.fillWidth: true
					height: 1 * DefaultStyle.dp
					color: DefaultStyle.main2_500main
				}
			}
		}
		Control.ScrollView {
			id: scrollView
			Layout.topMargin: 16 * DefaultStyle.dp
			Layout.fillWidth: true
			Layout.fillHeight: true
			leftPadding: 45 * DefaultStyle.dp
			rightPadding: 45 * DefaultStyle.dp
			Control.ScrollBar.vertical: ScrollBar {
				active: scrollViewContent.implicitHeight > scrollView.height
				visible: scrollViewContent.implicitHeight > scrollView.height
				interactive: true
				policy: Control.ScrollBar.AsNeeded
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				anchors.right: parent.right
				anchors.rightMargin: 15 * DefaultStyle.dp
			}
			Control.ScrollBar.horizontal: ScrollBar {
				active: false
			}
			ColumnLayout {
				id: scrollViewContent
				width: scrollView.width - scrollView.leftPadding - scrollView.rightPadding
				spacing: 10 * DefaultStyle.dp
				Repeater {
					id: contentRepeater
					model: mainItem.contentModel
					delegate: ColumnLayout {
						Rectangle {
							visible: index !== 0
							Layout.topMargin: (modelData.hideTopSeparator ? 0 : 16) * DefaultStyle.dp
							Layout.bottomMargin: 16 * DefaultStyle.dp
							Layout.fillWidth: true
							height: 1 * DefaultStyle.dp
							color: modelData.hideTopSeparator ? 'transparent' : DefaultStyle.main2_500main
						}
						GridLayout {
							rows: 1
							columns: mainItem.useVerticalLayout ? 1 : 2
							Layout.fillWidth: true
							Layout.preferredWidth: parent.width
							rowSpacing: (modelData.title.length > 0 || modelData.subTitle.length > 0 ? 20 : 0) * DefaultStyle.dp
							columnSpacing: 47 * DefaultStyle.dp
							ColumnLayout {
								Layout.preferredWidth: 341 * DefaultStyle.dp
								Layout.maximumWidth: 341 * DefaultStyle.dp
								spacing: 3 * DefaultStyle.dp
								Text {
									text: modelData.title
									visible: modelData.title.length > 0
									font: Typography.h4
									wrapMode: Text.WordWrap
									color: DefaultStyle.main2_600
									Layout.preferredWidth: parent.width
								}
								Text {
									text: modelData.subTitle
									visible: modelData.subTitle.length > 0
									font: Typography.p1s
									wrapMode: Text.WordWrap
									color: DefaultStyle.main2_600
									Layout.preferredWidth: parent.width
								}
								Item {
									Layout.fillHeight: true
								}
							}
							RowLayout {
								Layout.topMargin: (modelData.hideTopMargin ? 0 : (mainItem.useVerticalLayout ? 10 : 21)) * DefaultStyle.dp
								Layout.bottomMargin: 21 * DefaultStyle.dp
								Layout.leftMargin: (mainItem.useVerticalLayout ? 0 : 17) * DefaultStyle.dp
								Layout.preferredWidth: (modelData.customWidth > 0 ? modelData.customWidth : 545) * DefaultStyle.dp
								Layout.alignment: Qt.AlignRight
								Loader {
									Layout.fillWidth: true
									sourceComponent: modelData.contentComponent
								}
								Item {
									Layout.preferredWidth: (modelData.customRightMargin > 0 ? modelData.customRightMargin : 17) * DefaultStyle.dp
								}
							}
						}
					}
				}
			}
		}
	}
}

